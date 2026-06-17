# Mac mini → Dev Server Migration

Converting the Mac mini (M4) from a thin client into the primary always-on dev
server, reachable directly and over Tailscale, while also hosting the
Claude-native AI stack (Claude Code, Cowork, Channels). The Hetzner box is
retired at the end.

This is the runbook. The dotfiles repo now carries a dedicated
`playbook-server.yml` (see README → *Playbooks*) plus four new roles —
`tailscale`, `colima`, `server`, `onepassword` — that implement most of
Phases 1–5 below.

---

## Guiding principles

- **Boring and default.** Prefer macOS-native and "just works" tooling over
  bespoke config. Headless reliability beats cleverness.
- **One repo, three playbooks.** The MacBook stays a thin client
  (`playbook-slim.yml`); the Mac mini runs `playbook-server.yml`, which is the
  full default set plus the server-only roles.
- **Tailnet is the network.** Nothing is exposed publicly. All remote access is
  over Tailscale.

---

## Phase 0 — Decisions & pre-flight

Resolve these before touching the box.

| Decision | Choice | Why it matters |
|---|---|---|
| **RAM** | 16 GB (confirmed) — budget it tightly | macOS (~3–4 GB) + Cowork (Electron, ~1–2 GB) + Claude Code/Channels + a Colima VM. Keep the VM modest (≈6 GB, see `colima_memory`) and avoid running heavy local DBs alongside everything; lean on containers you start on demand. |
| **Storage** | ≥ 512 GB; external NVMe for volumes if 256 GB | Container images, DB volumes, repos, and Time Machine churn add up fast. |
| **FileVault** | **On** + macOS "Start up automatically after a power failure" | Power-on is handled natively (so the `server` role does *not* manage autorestart). Caveat: with FileVault on, after a power loss the mini boots to the **locked login screen** — disk stays encrypted and services don't start until it's unlocked once (physically or via Screen Sharing). Fine for a home dev server; just know recovery isn't fully unattended. |
| **Tailscale auth** | Generate a reusable auth key; store as `vault_tailscale_authkey` | Lets the `tailscale` role bring the node up non-interactively. |
| **Container runtime** | Colima (headless Docker) | Both Colima and Podman run a Linux VM on macOS, so footprint ≈ VM size either way. Colima wins on zero-config Docker compatibility: a real Docker socket means `docker`, `docker-compose`, DataGrip's Docker integration, and testcontainers all work unchanged, and Hetzner compose files migrate as-is. Autostart is a native `brew services` unit. |

**Pre-flight checklist**

- [ ] Confirm the Mac mini's `LocalHostName`: `scutil --get LocalHostName`. It
      becomes the device's tailnet name; no repo config needs it (the
      `tailscale` role reads it at runtime).
- [ ] Inventory what the Hetzner box actually runs (services, containers, DBs,
      cron/systemd units, open ports, data volumes, DNS records). Capture it:
      `docker ps -a`, `systemctl list-units --type=service`, `crontab -l`,
      `ls -la` of data dirs.
- [ ] Note repo list and any uncommitted work on Hetzner.
- [ ] Confirm Apple ID / iCloud signed in (for App Store apps + Screen Sharing).

---

## Phase 1 — Make the host always-on (`server` role)

The one thing a headless dev server must do is **never sleep** — a sleeping Mac
drops SSH and pauses the assistant user's Channels agent. Power-on after a failure is handled by
the native macOS setting, not this role.

1. **Sleep prevention** — handled by the `server` role (`pmset`/`systemsetup`
   never-sleep, no disk sleep / Power Nap / standby). Run:
   ```bash
   ansible-playbook playbook-server.yml -t server --ask-vault-pass
   ```
2. **Power-on after failure** — already covered by macOS *Start up automatically
   after a power failure*. With FileVault on, the box powers on to the locked
   login screen after a power loss and needs one unlock (physically or via
   Screen Sharing) before SSH/services come back. Tailscale runs as a *system*
   daemon, so once unlocked the tailnet comes up without you opening any app.
3. **Headless display.** No monitor needed. If macOS misbehaves without a
   display, use a cheap HDMI dummy plug so the GPU reports a real resolution
   (helps Screen Sharing render at full size).

**Verify:** `pmset -g | grep -E 'sleep|powernap'` shows sleep disabled; leave it
idle and confirm it stays reachable over SSH.

---

## Phase 2 — Tailscale (`tailscale` role, every playbook)

The `tailscale` role installs the **open-source** `tailscale` Homebrew formula
(not the sandboxed App Store cask) and runs `tailscaled` as a **system daemon**,
so the tailnet is up before login and stays up while the box is headless.

- The server playbook enables **Tailscale SSH** (`--ssh`); the role also passes
  `--accept-routes`.
- Clients (MacBook) just join the tailnet (`tailscale_ssh` stays off).
- Provide `vault_tailscale_authkey` for hands-off login, or run the printed
  `sudo tailscale up …` once interactively.

```bash
ansible-playbook playbook-server.yml -t tailscale --ask-vault-pass
```

**Set up in the Tailscale admin console:**
- [ ] Enable **MagicDNS** so you can `ssh mac-mini` instead of an IP.
- [ ] Tag the mini (e.g. `tag:devserver`) and write an ACL allowing your other
      devices to reach it.
- [ ] Enable **Tailscale SSH** in ACLs for your user → the tagged server.
- [ ] (Optional) `--advertise-exit-node` if you want to route through it.

**Verify:** from the MacBook, `tailscale status` shows the mini, and
`ssh <you>@mac-mini` works with no key prompt (Tailscale SSH handles auth).

---

## Phase 3 — Remote dev access

Terminal-first plus remote editor, both over the tailnet.

- **SSH + tmux.** Tailscale SSH covers the transport. Your existing `tmux` +
  `tmux-sessionizer` setup works unchanged: `ssh mac-mini`, then `Ctrl-f` /
  `<prefix> f` to jump into a project session. Sessions persist across
  disconnects — close the laptop mid-task and reattach later.
- **Remote editor (Zed / VS Code).**
  - *Zed:* use `zed ssh://mac-mini/path/to/project` (Zed remote dev) so the UI
    runs on the MacBook while the server does the work.
  - *VS Code:* Remote-SSH extension → connect to `mac-mini`.
  - Because MagicDNS gives a stable hostname and Tailscale SSH handles keys,
    neither needs extra SSH config.
- **Screen Sharing (fallback).** Enable macOS Screen Sharing; reach it at
  `vnc://mac-mini` over the tailnet for the rare full-GUI task.

**Verify:** open a project in Zed/VS Code over SSH, run a build, confirm
terminals and port-forwarding work.

---

## Phase 4 — Containers & web services (`colima` role, server-only)

- **Runtime.** The `colima` role installs Colima + `docker` CLI + compose and
  starts a `vz` VM sized by `colima_*` vars (default ~6 GB / 4 CPU — keep it
  modest on 16 GB). Autostart is via `brew services`. Run:
  ```bash
  ansible-playbook playbook-server.yml -t colima --ask-vault-pass
  ```
- **Docker compatibility.** Colima exposes a real Docker socket, so `docker`,
  `docker-compose`, DataGrip, and testcontainers work with no extra config.
- **Databases / stateful services.** Run Postgres/Redis/etc. as containers with
  named volumes (or compose files kept in a repo). On 16 GB, start these on
  demand rather than keeping every service resident. Migrate Hetzner volumes in
  Phase 6.
- **Exposing web services over the tailnet.** Two clean options:
  - `tailscale serve <port>` to expose a dev server to your tailnet over HTTPS
    with a MagicDNS name (no public exposure).
  - A small **Caddy** reverse proxy if you want friendly hostnames / multiple
    services behind one entry point.
  - Use `tailscale funnel` *only* if you deliberately need public internet
    access to a service.

**Verify:** `docker run hello-world`; bring up a sample compose stack; hit a dev
server from the MacBook via its `tailscale serve` URL.

---

## Phase 5 — Claude-native AI stack (separate user)

The mini also hosts the personal AI assistant (Claude Code, Cowork, Channels),
but it runs under its **own dedicated macOS user account, provisioned
separately** — it is intentionally *not* part of these dotfiles or your dev
user's setup. This keeps the assistant's always-on session, channel tokens, and
permissions isolated from your dev environment. That setup is out of scope for
this repo; the only shared dependency is Phase 1 (the mini never sleeping) so
the assistant user's session stays alive.

For your **dev user**, the relevant AI piece is just Claude Code itself, already
provisioned by the `claude` role for interactive use over SSH.

### Headless secrets for the dev user (`onepassword` role)

When you work on the server over SSH, the 1Password desktop-app CLI integration
isn't reliably available (no GUI unlock), so the mise `op read` lookups
(`GH_TOKEN`, `GREPTILE_API_KEY`) would fail. The server-only `onepassword` role
fixes this with a **1Password service-account token**:

1. In the 1Password web UI, create a service account and grant it read access to
   the vault(s) holding your dev secrets.
2. Store its token in `group_vars/all/vault.yml` as
   `vault_op_service_account_token`.
3. Run `ansible-playbook playbook-server.yml -t onepassword --ask-vault-pass`. The role
   writes the token to `~/.config/op/service-account.env` (0600) and sources it
   in zsh, so `op read` — and therefore mise's env resolution — works headlessly.

**Verify:** over SSH (no GUI session), run `op read op://<vault>/<item>/<field>`
and confirm it returns the secret; then `cd` into a project and check
`mise env | grep GH_TOKEN` resolves.

---

## Phase 6 — Cut over from Hetzner

Do this once Phases 1–5 are verified on the mini.

1. **Repos.** Clone everything fresh on the mini (they live in GitHub anyway).
   Flush any uncommitted work on Hetzner first.
2. **Data volumes.** Dump and restore DBs (`pg_dump`/`pg_restore`,
   `redis` RDB snapshots) or `rsync` named-volume contents over the tailnet.
3. **Services.** Recreate Hetzner services as Colima containers / compose files;
   recreate cron jobs as `launchd` LaunchAgents or scheduled tasks.
4. **DNS / endpoints.** Repoint anything that referenced the Hetzner IP to the
   mini's MagicDNS name (or `tailscale serve`/`funnel` URL).
5. **Parallel run.** Keep Hetzner alive a few days as a fallback while you use
   the mini as primary.
6. **Decommission.** Once confident: snapshot/backup anything worth keeping,
   then cancel the Hetzner box (~€59/mo saved).

---

## Phase 7 — Backups & maintenance

The mini is now your primary dev machine — back it up like one.

- **Time Machine** to a local external SSD (hourly, automatic).
- **Offsite** for what matters: container volumes + DB dumps + dotfiles vault to
  an encrypted `restic`/Borg repo on B2/S3, on a `launchd` schedule.
- **Updates.** `brew upgrade` on a cadence; keep Claude Code current for Channels.
- **Monitoring.** Lightweight is fine — a daily health check (disk space, Colima
  up, tailnet up) pushed to yourself via a scheduled task (or the assistant
  user's Channels agent, if you wire one up there).

---

## Quick command reference

```bash
# Provision the whole server (first run); sudo comes from the vault
ansible-playbook playbook-server.yml --ask-vault-pass
#   or: ./bootstrap.sh playbook-server.yml

# Individual concerns
ansible-playbook playbook-server.yml -t server    --ask-vault-pass  # sleep prevention
ansible-playbook playbook-server.yml -t tailscale --ask-vault-pass  # tailnet
ansible-playbook playbook-server.yml -t colima    --ask-vault-pass  # containers

# Sanity checks
scutil --get LocalHostName
pmset -g | grep -E 'sleep|powernap'
tailscale status
colima status
docker run hello-world
```
