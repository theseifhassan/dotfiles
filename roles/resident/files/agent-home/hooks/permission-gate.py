#!/usr/bin/env python3
"""
The Resident — PreToolUse permission gate.

Classifies every tool call before it runs:
  - reversible / read-only  -> allow
  - irreversible (send, push, delete, post, pay, contact-new)
        v1 autonomy -> deny  (draft-only: nothing irreversible happens)
        v2 autonomy -> ask   (routes to the owner; relays over the channel) + queue
  - unknown -> gate (default-deny; safer than guessing)

Why a hook and not --dangerously-skip-permissions: on a box holding real accounts,
skip-permissions auto-approves whatever an injection could trigger (decision D9). This
gate is the enforcement point for the autonomy charter.

Note: Claude Code's `defer` PreToolUse decision exists but is unstable/under-documented
(verified 2026-06-19), so we implement deferral ourselves: deny + append to the queue.

Config via env:
  RESIDENT_HOME      agent home dir (default: $HOME)
  RESIDENT_AUTONOMY  "v1" (default) or "v2"
"""
import json
import os
import re
import sys
from datetime import datetime, timezone

HOME = os.environ.get("RESIDENT_HOME") or os.path.expanduser("~")
AUTONOMY = os.environ.get("RESIDENT_AUTONOMY", "v1").lower()
QUEUE = os.path.join(HOME, "memory", "approval-queue.jsonl")

# --- Classification rules ---------------------------------------------------
# Tools that only read / observe -> always safe.
READ_TOOL_RE = re.compile(
    r"(?:^|__)(?:list|get|search|read|fetch|find|view|describe|show|"
    r"suggest|extract|resolve)[_A-Za-z]*$|^(?:Read|Grep|Glob|NotebookRead)$",
    re.IGNORECASE,
)

# MCP / native tools that cause irreversible, outward-facing effects.
IRREVERSIBLE_TOOL_RE = re.compile(
    r"(?:^|__)(?:send|post|create|update|delete|remove|save|merge|move|"
    r"add|respond|attach|deploy|schedule|complete|duplicate|grant)[_A-Za-z]*$",
    re.IGNORECASE,
)

# Reversible writes scoped to the agent's own home (git-backed -> revertible).
# create_draft is reversible (a draft never leaves), so it's explicitly allowed.
ALWAYS_ALLOW_TOOLS = {"create_draft"}

# Bash command patterns that are read-only / safe.
SAFE_BASH_RE = re.compile(
    r"^\s*(?:ls|cat|bat|head|tail|grep|rg|fd|find|wc|stat|file|"
    r"echo|pwd|whoami|date|uname|df|du|ps|top|env|which|type|"
    r"git\s+(?:status|log|diff|show|branch|remote|fetch|blame|stash\s+list)|"
    r"jq|tree|tmux\s+(?:ls|list-sessions))\b"
)

# Bash command patterns that are always irreversible / dangerous.
DANGER_BASH_RE = re.compile(
    r"\b(?:rm|rmdir|git\s+push|git\s+reset\s+--hard|curl|wget|"
    r"shutdown|reboot|kill|killall|launchctl|chmod|chown|"
    r"defaults\s+write|osascript|sudo|dd|mkfs|diskutil)\b"
)


def now():
    return datetime.now(timezone.utc).isoformat()


def decide(payload):
    tool = payload.get("tool_name", "")
    tinp = payload.get("tool_input", {}) or {}
    base = tool.split("__")[-1]  # strip mcp__server__ prefix

    if base in ALWAYS_ALLOW_TOOLS:
        return "allow", f"{base} is reversible (draft only)."

    # File writes inside the agent's own (git-backed) home are revertible.
    if tool in ("Write", "Edit", "MultiEdit", "NotebookEdit"):
        path = str(tinp.get("file_path") or tinp.get("notebook_path") or "")
        if path.startswith(HOME):
            return "allow", "Write within the git-backed agent home (revertible)."
        return gate(f"Write outside the agent home: {path}")

    if tool == "Bash":
        cmd = str(tinp.get("command", ""))
        if DANGER_BASH_RE.search(cmd):
            return gate(f"Irreversible/dangerous shell command: {cmd[:120]}")
        if SAFE_BASH_RE.match(cmd):
            return "allow", "Read-only shell command."
        return gate(f"Unclassified shell command: {cmd[:120]}")

    if READ_TOOL_RE.search(tool):
        return "allow", "Read-only tool."

    if IRREVERSIBLE_TOOL_RE.search(tool):
        return gate(f"Irreversible action: {tool}")

    # Unknown tool: default-deny rather than guess.
    return gate(f"Unclassified tool: {tool}")


def gate(reason):
    """Irreversible/unknown -> enforce the autonomy charter."""
    if AUTONOMY == "v2":
        return "ask", f"{reason} — needs owner approval (queued)."
    return "deny", f"{reason} — blocked by autonomy v1 (draft-only). Queued for review."


def enqueue(payload, decision, reason):
    try:
        os.makedirs(os.path.dirname(QUEUE), exist_ok=True)
        with open(QUEUE, "a") as f:
            f.write(json.dumps({
                "ts": now(),
                "tool": payload.get("tool_name", ""),
                "input": payload.get("tool_input", {}),
                "decision": decision,
                "reason": reason,
            }) + "\n")
    except Exception:
        pass  # never let queue I/O block the gate


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        # If we can't parse the event, fail closed.
        payload = {}

    decision, reason = decide(payload)
    if decision in ("deny", "ask"):
        enqueue(payload, decision, reason)

    print(json.dumps({
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": decision,
            "permissionDecisionReason": reason,
        }
    }))
    sys.exit(0)


if __name__ == "__main__":
    main()
