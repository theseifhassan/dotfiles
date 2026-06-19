# The Resident — §9 Verification Record & Decision Log

> Companion to the build handoff spec. This file records what was verified against current
> docs before any code was written (per the spec's "§9 Verify First" gate), and any
> amendments to the locked decisions that the verification forced. The handoff spec remains
> the architecture authority; this file is the source of truth for *what changed and why*.

_Verified: 2026-06-19. Claude Code Channels / Remote Control are research-preview — re-check
before depending on anything here._

## §9 verification results (doc-verifiable)

| Item | Result | Status |
|------|--------|--------|
| Channels min version / auth | **v2.1.80+**. claude.ai login works (API key now also supported, but we stay on Max per D2). | ✅ |
| Allowlisted channel plugins | Telegram, Discord, **iMessage**, Fakechat. Custom channels require `--dangerously-load-development-channels`. | ✅ |
| iMessage prereqs | macOS + **Bun** runtime. Reads `~/Library/Messages/chat.db` directly; sends via AppleScript. **FDA required.** | ⚠️ see D7 amendment |
| Background mode | No native daemon. Pattern is **tmux + launchd KeepAlive**. Reboot survival untested on-box. | ✅ (verify on-box) |
| Remote approval | **v2.1.81+** relays tool-approval prompts over the channel (e.g. reply `yes abcde`). Project-trust + MCP-consent dialogs are **terminal-only**, do not relay. | ✅ |
| Channels + Remote Control coexistence | Documented as complementary; one Remote Control session per process. Not explicitly tested together. | 🟡 verify on-box |
| Remote Control cross-account | Login required. Owner's phone on a *different* account controlling the agent's session: **not documented, likely unsupported.** Reinforces D8 (keep secondary). | 🟡 |
| Hooks classify-and-defer | `allow`/`deny`/`ask` confirmed. A `defer` decision exists but is **under-documented / unstable** — do NOT depend on it. Build the approval queue inside the hook (deny + record to queue file). | ✅ with caveat |
| Gmail forward-filter vs delegation | **Filter-forwarding chosen.** Fully attributable, works regardless of Workspace org. Delegation needs same-org on Workspace, which breaks the own-account model. | ✅ |
| iCloud calendar/reminders/notes between two Apple IDs | All support **write access** between distinct Apple IDs, provided the agent's Apple ID lives in its **own macOS user** (the D5 topology). | ✅ |

## Amendment to D7 (FDA scoping)

**Original D7:** FDA scoped to a tiny non-LLM relay helper, never the Claude Code process.

**Verification finding:** The official iMessage plugin reads `chat.db` from inside the Claude
Code process tree, and channel plugins run as subprocesses **under the launching terminal's TCC
responsibility** — so they inherit the terminal's FDA grant. The clean relay/agent FDA split D7
imagined is **not achievable** with the official plugin without building a custom channel behind
`--dangerously-load-development-channels` (a flagged, unsupported lane in a fast-moving preview).

**Decision (2026-06-19, owner-approved):** Use the **official iMessage plugin** and grant FDA to
**Ghostty** (the terminal that launches the long-lived `resident` session). D7 is amended:

> *FDA lives only on the agent's terminal (Ghostty), running under the contained `resident`
> macOS user. Containment comes from D5 (user boundary) + D9 (no skip-permissions, hooks gate
> irreversible actions) + the channel sender allow-list — not from withholding FDA.*

**Rationale:** D7's real protection against cross-user reads was always D5's job (POSIX ownership
gates `seif`'s and employer files regardless of FDA). D7 only added keeping the FDA *capability*
in a non-promptable relay. Since the plugin can't cleanly deliver that split anyway, the effort of
a custom relay doesn't buy the guarantee it promised. The compensating controls below recover the
intent.

**Compensating controls (must all hold):**
1. Channel sender allow-list = **`seif` only**. Forwarded mail / web content stays *data, never instructions*.
2. **D9 holds** — never `--dangerously-skip-permissions`; hooks gate every irreversible action.
3. **D5 is the boundary** — `resident` is a non-admin user; `seif`'s sensitive dirs stay POSIX-protected.
4. **Only Ghostty holds FDA** — audit System Settings → Privacy → Full Disk Access; it must be the sole entry.

**Load-bearing on-box check — PASSED (2026-06-19).** Initial test showed `resident` could read
`seif`'s files, but the cause was loose POSIX perms (`/Users/seifhassan` was `755`), **not** an FDA
bypass. After `chmod 700 /Users/seifhassan`, `resident` can no longer traverse or read `seif`'s
home — confirmed "Permission denied". D5 containment holds; FDA-on-Ghostty (Option B) is sound.

**Required hardening (carried into the build):** `seif`'s home directory must be `700`
(`chmod 700 /Users/seifhassan`). macOS defaults new homes to `755`; this must be set/verified, since
the whole containment model rests on POSIX gating cross-user reads.

## Chosen mechanisms (carried into the build)

- **Gmail:** owner sets a filter that auto-forwards relevant mail to the agent's own Gmail; agent replies from its own address. (No delegation.)
- **iCloud:** agent's Apple ID in its own `resident` macOS user; owner shares calendars / Reminders / Notes with "allow editing".
- **Liveness:** tmux session + launchd KeepAlive under `resident`.
- **Approvals:** relayed over iMessage for tool prompts; irreversible actions gated by hooks → approval queue.

## Per-seat tool access — bot/app identity, no extra seats (verified 2026-06-19)

The double-identity / per-seat problem is solved by giving the agent its **own bot/app identity**
in each tool (delegation per D3 — the agent owns the app; the owner installs it with scoped access;
revoke = uninstall). No paid seats, no owner-credential impersonation.

**Access splits into READ vs WRITE.** Most responsibilities (check mail, see project progress, draft
kickoff notes / team updates) are **read + draft → you post** — autonomy charter v1. The agent never
needs to act inside a per-seat tool to do those.

| Tool | Free path (agent's own identity) | Avoid |
|------|----------------------------------|-------|
| **Slack** | Slack App + bot token (`xoxb-`): reads invited channels, posts as the bot. Bots are never billable members. | Multi-channel guest = full paid seat |
| **Notion** | Internal integration token: read/update/comment on pages explicitly shared to it. Guests free up to plan limit (Free=10; paid=unlimited). | Over-limit members |
| **Linear** | OAuth app with `actor=app`: own identity, assignable, create/comment; officially **not** a billable user. Webhooks + API free from Free plan. | **Guest = a full paid seat** (Business/Enterprise only); personal API key = acts as *you* = impersonation, breaks D10 |
| **GitHub** | Personal repos: free unlimited collaborator. Org repos: a **GitHub App** (free, acts as itself). | Org member / outside-collaborator / machine-user = paid seat. Webhooks are outbound-only — they do **not** grant read access |

Rules carried into the build:
- **Never use Linear's personal API key** (impersonation). Use `actor=app`.
- **GitHub webhooks read nothing** — use a GitHub App for repo reads.
- **Employer instances stay gated by D10** — the bot path is free, but installing the agent's app
  into the employer's Slack/GitHub org/Notion needs employer sign-off. Personal instances proceed.
- All bot/app tokens live in the agent's 1Password vault (§7).

## Remaining §9 items — machine-only (do on the Mac mini)

- [ ] Confirm installed Claude Code version ≥ v2.1.80 under `resident`.
- [ ] Install Bun under `resident`.
- [ ] Grant FDA to Ghostty only; audit the FDA list afterward.
- [x] Run the load-bearing cross-user read check — PASSED after `chmod 700 /Users/seifhassan`.
- [ ] Confirm tmux + launchd KeepAlive survives a real reboot (and a macOS update).
- [ ] Confirm Channels + Remote Control can share one session, or decide on two.
- [ ] Set up Gmail forwarding filter + destination verification on the agent's account.
- [ ] Set up iCloud calendar/reminders/notes sharing between the two Apple IDs.
- [ ] Measure a real day of heartbeat density against Max plan rate limits before tuning.
