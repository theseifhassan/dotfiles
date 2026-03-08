#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

echo "==> Starting dotfiles bootstrap..."

# 1. Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  echo "==> Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "    Waiting for Xcode CLT installation to complete..."
  elapsed=0
  until xcode-select -p &>/dev/null; do
    if (( elapsed >= 600 )); then
      echo "ERROR: Timed out waiting for Xcode CLT. Install manually and re-run." >&2
      exit 1
    fi
    sleep 10
    elapsed=$((elapsed + 10))
  done
  echo "    Xcode CLT installed."
else
  echo "==> Xcode Command Line Tools already installed."
fi

# 2. Homebrew
if ! command -v brew &>/dev/null; then
  echo "==> Installing Homebrew..."
  installer="$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
    echo "ERROR: Failed to download Homebrew installer." >&2; exit 1;
  }
  /bin/bash -c "$installer" || {
    echo "ERROR: Homebrew installation failed." >&2; exit 1;
  }
  echo "    Homebrew installed."
else
  echo "==> Homebrew already installed."
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v brew &>/dev/null; then
  echo "ERROR: Homebrew not found on PATH after install." >&2
  exit 1
fi

# 3. Ansible (formula)
if ! brew list --formula ansible &>/dev/null; then
  echo "==> Installing ansible..."
  brew install ansible
else
  echo "==> ansible already installed."
fi

# 4. 1Password CLI (cask)
if ! brew list --cask 1password-cli &>/dev/null; then
  echo "==> Installing 1password-cli..."
  brew install --cask 1password-cli
else
  echo "==> 1password-cli already installed."
fi

# 5. 1Password CLI authentication
if ! op whoami &>/dev/null; then
  if ! op account list 2>/dev/null | grep -q .; then
    echo "==> No 1Password accounts configured. Let's add one."
    read -rp "    1Password sign-in address (e.g. my.1password.com): " op_address
    read -rp "    Email: " op_email
    op account add --address "$op_address" --email "$op_email"
  fi
  echo "==> Please sign in to 1Password CLI:"
  eval "$(op signin)"
  if ! op whoami &>/dev/null; then
    echo "ERROR: 1Password authentication failed." >&2
    exit 1
  fi
else
  echo "==> 1Password CLI already authenticated."
fi

# 6. Install Ansible collections
echo "==> Installing Ansible collections..."
ansible-galaxy collection install -r requirements.yml

# 7. Run the playbook
echo "==> Running Ansible playbook..."
ansible-playbook playbook.yml
