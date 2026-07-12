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

# -t: the CLT and Homebrew installs need sudo, so keep a TTY for the password.
ssh -t "$HOST" 'bash -s' <<'EOF'
set -euo pipefail

# 1. Xcode Command Line Tools (non-interactive via softwareupdate)
if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode Command Line Tools..."
  sudo -v
  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  PROD="$(softwareupdate -l 2>/dev/null \
    | grep -o 'Label: Command Line Tools for Xcode-[0-9.]*' \
    | tail -1 | sed 's/^Label: //')"
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

echo "==> Done. Provision with: ansible-playbook site.yml --limit work --ask-vault-pass"
