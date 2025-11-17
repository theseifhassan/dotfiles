#!/bin/sh
# Configure GPG to use XDG directories instead of ~/.gnupg
# Creates systemd drop-in, migrates existing data, and restarts gpg-agent

set -e

XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

# Create systemd drop-in directory and override file
mkdir -p ~/.config/systemd/user/gpg-agent.service.d/
cat > ~/.config/systemd/user/gpg-agent.service.d/override.conf << EOF
[Service]
Environment="GNUPGHOME=%h/.local/share/gnupg"
EOF

# Create new GPG directory
mkdir -p "$XDG_DATA_HOME/gnupg"
chmod 700 "$XDG_DATA_HOME/gnupg"

# Migrate existing GPG data if it exists and has content
if [ -d ~/.gnupg ] && [ -n "$(ls -A ~/.gnupg 2>/dev/null)" ]; then
    echo "Migrating existing GPG data..."
    cp -r ~/.gnupg/* "$XDG_DATA_HOME/gnupg/" || {
        echo "Error: Failed to migrate GPG data"
        exit 1
    }
    chmod 700 "$XDG_DATA_HOME/gnupg"
    find "$XDG_DATA_HOME/gnupg" -type f -exec chmod 600 {} \;
fi

# Reload systemd and restart GPG agent
systemctl --user daemon-reload
gpgconf --kill gpg-agent 2>/dev/null || true
