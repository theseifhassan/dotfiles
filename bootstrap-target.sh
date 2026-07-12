#!/bin/bash
set -euo pipefail

# Prepare a FRESH remote Mac for Ansible push — run FROM the controller:
#   ./bootstrap-target.sh macbook
#
# Installs Xcode Command Line Tools (provides git + python3, which Ansible
# needs on the target) and Homebrew over SSH. Prerequisite: the target must be
# reachable over SSH — either Remote Login enabled (System Settings > General
# > Sharing) on the LAN, or already joined to the tailnet with Tailscale SSH.
# After this completes, provision it with:
#   ansible-playbook site.yml --limit work --ask-vault-pass

HOST="${1:?usage: ./bootstrap-target.sh <ssh-host>}"

echo "==> Preparing $HOST for Ansible push..."

# Ship the script to the target first, then execute it with `ssh -t` and
# stdin left alone — piping the script over stdin (`bash -s <<EOF`) would
# leave no terminal for the remote sudo prompts.
REMOTE_SCRIPT="/tmp/bootstrap-target-remote.sh"
ssh "$HOST" "cat > $REMOTE_SCRIPT" <<'EOF'
set -euo pipefail

# 1. Xcode Command Line Tools (non-interactive via softwareupdate)
if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode Command Line Tools..."
  sudo -v
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  # Label formats vary by macOS release ("...for Xcode-16.4", "...for Xcode
  # 27.0 beta 3-27.0"); match anything after "Command Line Tools". sed exits 0
  # on no match, so set -e can't kill the script before the guard below.
  PROD="$(softwareupdate -l 2>/dev/null \
    | sed -n 's/^\* Label: \(Command Line Tools.*\)$/\1/p' \
    | tail -1)"
  if [[ -z "$PROD" ]]; then
    rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    echo "ERROR: no Command Line Tools package found via softwareupdate." >&2
    exit 1
  fi
  sudo softwareupdate -i "$PROD" --verbose
  rm -f /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  echo "    Xcode CLT installed."
else
  echo "==> Xcode Command Line Tools already installed."
fi

# 2. Homebrew
if [[ ! -x /opt/homebrew/bin/brew && ! -x /usr/local/bin/brew ]]; then
  echo "==> Installing Homebrew..."
  sudo -v
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo "    Homebrew installed."
else
  echo "==> Homebrew already installed."
fi

echo "==> Target ready."
EOF

# -t: real TTY so the CLT and Homebrew installs can prompt for sudo.
ssh -t "$HOST" "bash $REMOTE_SCRIPT; rc=\$?; rm -f $REMOTE_SCRIPT; exit \$rc"

echo "==> Done. Provision with: ansible-playbook site.yml --limit work --ask-vault-pass"
