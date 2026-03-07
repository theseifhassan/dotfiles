# Modular Dotfiles System - Requirements Document

**Version:** 0.2.0-draft
**Date:** 2026-03-07

---

## 1. Overview

A modular, Ansible-based dotfiles system for macOS that treats each tool configuration as an independent, idempotent "brick". The system must support dual-identity (work/personal) switching across multiple tools, enforce strict XDG compliance, scoped package management, and use 1Password as the single source of truth for all secrets.

---

## 2. Architectural Requirements

### US-001: Modular Ansible Role Architecture

**As a** developer,
**I want** each tool's configuration to be an independent, self-contained Ansible role,
**so that** I can compose my system from individual bricks without hidden dependencies.

**Acceptance Criteria:**
1. Each tool MUST be represented as a standalone Ansible role with no cross-role dependencies.
2. Each role MUST be idempotent — running it multiple times SHALL produce the same result.
3. Each role MUST be individually executable (e.g., `ansible-playbook -t <role>`).
4. A top-level playbook SHALL compose roles together to build the full system.
5. Adding or removing a role from the top-level playbook SHALL NOT break other roles.

---

### US-002: XDG Base Directory Compliance

**As a** developer,
**I want** all tool configurations to follow the XDG Base Directory Specification,
**so that** my home directory remains clean and uncluttered.

**Acceptance Criteria:**
1. All configuration files MUST reside under `$XDG_CONFIG_HOME` (default `~/.config/`).
2. All data files MUST reside under `$XDG_DATA_HOME` (default `~/.local/share/`).
3. All cache files MUST reside under `$XDG_CACHE_HOME` (default `~/.cache/`).
4. All state files MUST reside under `$XDG_STATE_HOME` (default `~/.local/state/`).
5. The system SHALL export XDG environment variables in the shell configuration.
6. Where a tool does not natively support XDG, the role MUST configure it (via env vars, symlinks, or wrapper aliases) to comply.
7. The home directory (`~/`) SHALL contain no dotfiles or dotfolders beyond the essential exceptions (e.g., `~/.config`, `~/.local`, `~/.cache`).

---

### US-003: Scoped Package Management

**As a** developer,
**I want** runtime binaries and project-specific tools to be installed at project scope using mise,
**so that** no unnecessary global packages pollute my system.

**Acceptance Criteria:**
1. Runtime binaries (Node.js, pnpm, Go, Python, etc.) MUST NOT be installed globally.
2. Project-scoped tools SHALL be managed via mise using per-project `.mise.toml` files.
3. Only tools that are used across multiple projects or are system-level utilities MAY be installed globally.
4. The mise role SHALL configure mise to manage tool versions per project directory.
5. When a globally-installed package is no longer needed system-wide, it SHOULD be demoted to project scope.

---

### US-004: Homebrew Package Management

**As a** macOS user,
**I want** all CLI tools and GUI applications to be managed by Homebrew,
**so that** I have a single, declarative source of truth for installed software.

**Acceptance Criteria:**
1. All CLI tools SHALL be installed via Homebrew formulae.
2. All GUI applications SHALL be installed via Homebrew casks where available.
3. Each Ansible role that requires a Homebrew package MUST declare it within its own role (self-contained).
4. The system SHALL be able to produce a full list of Homebrew-managed packages for audit purposes.

---

## 3. Core Tool Requirements

### US-005: Terminal Environment (Ghostty + Tmux)

**As a** developer,
**I want** Ghostty as my terminal emulator and Tmux as my terminal multiplexer,
**so that** I have a fast, configurable terminal workspace.

**Acceptance Criteria:**
1. The Ghostty role SHALL install Ghostty via Homebrew and place its config under `$XDG_CONFIG_HOME/ghostty/`.
2. The Tmux role SHALL install Tmux via Homebrew and place its config under `$XDG_CONFIG_HOME/tmux/`.
3. Both roles SHALL be independently deployable.

---

### US-006: Neovim Configuration

**As a** developer,
**I want** Neovim managed as a standalone role,
**so that** my editor configuration is portable and self-contained.

**Acceptance Criteria:**
1. The Neovim role SHALL install Neovim via Homebrew.
2. Configuration SHALL reside under `$XDG_CONFIG_HOME/nvim/`.
3. Plugin data SHALL reside under `$XDG_DATA_HOME/nvim/`.

---

### US-007: Claude Code Setup

**As a** developer,
**I want** Claude Code installed and configured as a standalone role,
**so that** it integrates into my terminal workflow.

**Acceptance Criteria:**
1. The Claude Code role SHALL install Claude Code via Homebrew (or the officially supported method).
2. Configuration SHALL follow XDG conventions where supported.
3. The role SHALL support identity-aware MCP server configuration (see US-014).

---

### US-008: Zed Editor

**As a** developer,
**I want** Zed editor installed for collaborative work and screen recordings,
**so that** I have an alternative editor for pairing and demos.

**Acceptance Criteria:**
1. The Zed role SHALL install Zed via Homebrew cask.
2. Configuration SHALL reside under `$XDG_CONFIG_HOME/zed/` if supported, or the Zed default config path.

---

### US-009: Shell Environment (Zsh + Starship)

**As a** developer,
**I want** Zsh as my shell with a minimal Starship prompt showing `user@host:working_dir [git_branch_name]`,
**so that** I have a fast, informative, and distraction-free prompt.

**Acceptance Criteria:**
1. The Zsh role SHALL configure Zsh as the default shell.
2. Zsh configuration files SHALL reside under `$XDG_CONFIG_HOME/zsh/` (using `$ZDOTDIR`).
3. The Starship role SHALL install Starship via Homebrew.
4. The Starship config SHALL reside under `$XDG_CONFIG_HOME/starship.toml`.
5. The prompt format MUST display exactly: `user@host:working_dir [git_branch_name]`.
6. The prompt SHALL show no extra modules, icons, or decorations beyond the specified format.

---

### US-010: Window Management and App Launcher (Aerospace + Raycast)

**As a** macOS user,
**I want** Aerospace as my tiling window manager and Raycast as my app launcher,
**so that** I can navigate and launch apps efficiently with the keyboard.

**Acceptance Criteria:**
1. The Aerospace role SHALL install Aerospace via Homebrew cask and place config under `$XDG_CONFIG_HOME/aerospace/`.
2. The Raycast role SHALL install Raycast via Homebrew cask.

---

### US-011: Browser and Additional Applications

**As a** macOS user,
**I want** Google Chrome, Figma, Linear, Slack, and Gather installed,
**so that** my full application suite is declaratively managed.

**Acceptance Criteria:**
1. Each application SHALL be installed via Homebrew cask where available.
2. Each application MAY be its own role or grouped into a shared "apps" role, as long as removal of any single app does not break others.

---

## 4. Identity Resolution Requirements

### US-012: SSH Key Provisioning and Identity Switching

**As a** developer who uses one machine for work and personal projects,
**I want** SSH keys to be automatically provisioned from 1Password and routed to the correct identity based on context,
**so that** I never manually copy/paste keys and always authenticate with the right credentials.

**Acceptance Criteria:**
1. The SSH role SHALL retrieve SSH keys (work and personal) from 1Password automatically during provisioning.
2. SSH keys SHALL be written to the appropriate location on disk by Ansible, sourced from 1Password CLI (`op`).
3. SSH config SHALL use `Match` or `Host` directives to route to the correct key based on the target host or repository.
4. SSH configuration SHALL reside under `$XDG_CONFIG_HOME/ssh/` or `~/.ssh/` (whichever SSH supports natively).
5. Key management SHALL support adding new identities without modifying existing ones.
6. Private keys SHALL NOT be stored in the dotfiles repository.

---

### US-013: Git Identity Switching

**As a** developer,
**I want** Git to automatically use the correct user name, email, and signing key based on the project directory,
**so that** my commits are always attributed to the right identity.

**Acceptance Criteria:**
1. The Git role SHALL configure conditional includes (`includeIf`) based on project directory paths.
2. Work projects SHALL automatically use the work Git identity (name, email, signing key).
3. Personal projects SHALL automatically use the personal Git identity.
4. The Git config SHALL reside under `$XDG_CONFIG_HOME/git/`.

---

### US-014: GitHub CLI Identity Switching

**As a** developer,
**I want** the GitHub CLI (`gh`) to switch between work and personal accounts per project,
**so that** I interact with the correct GitHub organization in each context.

**Acceptance Criteria:**
1. The gh CLI role SHALL support identity switching via the `GH_TOKEN` environment variable.
2. `GH_TOKEN` SHALL be set per project using mise (`.mise.toml`).
3. `GH_TOKEN` values SHALL be sourced from 1Password (not hardcoded in `.mise.toml`).
4. The role SHALL document or template how to configure `GH_TOKEN` per project.

---

### US-015: Graphite CLI Identity Switching

**As a** developer,
**I want** the Graphite CLI to be automatically configured with my work and personal profiles, with tokens pulled from 1Password,
**so that** I never manually copy/paste auth tokens and can switch profiles per project.

**Acceptance Criteria:**
1. The Graphite role SHALL automatically generate `~/.config/graphite/user_config` with `alternativeProfiles` populated by Ansible.
2. Auth tokens for each profile (work, personal) SHALL be retrieved from 1Password during provisioning via the 1Password CLI (`op`).
3. Profile switching SHALL be driven by the `GRAPHITE_PROFILE` environment variable.
4. `GRAPHITE_PROFILE` SHALL be set per project using mise (`.mise.toml`).
5. Auth tokens SHALL NOT be stored in plaintext in the dotfiles repository.

---

### US-016: MCP Server Identity Switching

**As a** developer using Claude Code,
**I want** MCP server connections (Linear, Figma, and other dual-account services) to switch between work and personal accounts based on context,
**so that** my AI tools operate against the correct workspace without manual reconfiguration.

**Acceptance Criteria:**
1. The system SHALL support per-project MCP server configuration that resolves to the correct account (work or personal).
2. MCP server credentials SHALL be switchable via environment variables or per-project config files.
3. The identity switching mechanism SHALL work with at minimum: Linear and Figma MCP servers.
4. Adding a new dual-account MCP server SHALL NOT require changes to existing server configurations.
5. MCP credentials SHALL be sourced from 1Password and NOT committed to the dotfiles repository.

---

### US-017: Unified Identity Context

**As a** developer,
**I want** a single mechanism to set the identity context (work or personal) for a project,
**so that** all identity-aware tools (SSH, Git, gh, Graphite, MCP servers) resolve correctly from one configuration point.

**Acceptance Criteria:**
1. A project's identity context SHOULD be configurable from a single source (e.g., a project-level `.mise.toml` or directory convention).
2. When the identity context is set, all identity-aware tools (Git, gh, Graphite, MCP servers) SHALL resolve to the matching profile.
3. The system SHALL default to a safe fallback identity (e.g., personal) when no explicit context is set.

---

## 5. Secret Management Requirements

### US-018: 1Password as Secret Backend

**As a** developer,
**I want** 1Password to be the single source of truth for all secrets (SSH keys, API tokens, auth credentials),
**so that** secrets are never hardcoded in the dotfiles repo and are always fetched securely.

**Acceptance Criteria:**
1. The 1Password role SHALL install the 1Password desktop app and 1Password CLI (`op`) via Homebrew.
2. All Ansible roles that require secrets MUST retrieve them at provisioning time via the 1Password CLI (`op read`, `op inject`, or the Ansible `onepassword` lookup plugin).
3. No secrets SHALL be stored in plaintext within the dotfiles repository.
4. The system SHALL fail gracefully with a clear error if 1Password CLI is not authenticated when a secret is needed.
5. Secrets that need to be written to config files on disk (e.g., Graphite `user_config`) SHALL be templated by Ansible with values injected from 1Password at run time.

---

## 6. Font Management Requirements

### US-019: Berkeley Mono Font Provisioning

**As a** developer,
**I want** my paid Berkeley Mono font to be automatically cloned from my private repository and installed,
**so that** my font is available system-wide without manual setup on a new machine.

**Acceptance Criteria:**
1. The font role SHALL clone the private Berkeley Mono repository using SSH authentication (the SSH key must already be provisioned — see US-012).
2. The role SHALL install the font files to the macOS font directory (`~/Library/Fonts/` or the system font directory).
3. The role SHALL be idempotent — it SHALL skip cloning/installing if the font is already present and up to date.
4. The role SHALL NOT store the font files in the dotfiles repository itself.
5. The private repo URL SHALL be configurable via an Ansible variable.

---

## 7. Non-Functional Requirements

### US-020: Idempotent Bootstrap

**As a** developer setting up a new machine,
**I want** a single bootstrap command that installs everything from scratch,
**so that** I can go from a fresh macOS install to a fully configured system.

**Acceptance Criteria:**
1. A bootstrap script SHALL install Homebrew, Ansible, 1Password CLI, and any other prerequisites.
2. The bootstrap script SHALL then invoke the Ansible playbook to configure the full system.
3. Running the bootstrap script on an already-configured machine SHALL produce no unintended changes (idempotent).
4. The bootstrap script SHALL be a single command (e.g., `make bootstrap` or `./bootstrap.sh`).
