#!/usr/bin/env bash
# Mock functions for system commands

# Create mock command that records calls and returns success
create_mock() {
    local cmd="$1"
    local return_code="${2:-0}"
    local mock_dir="${MOCK_BIN_DIR:-$TEST_HOME/.local/mock-bin}"

    mkdir -p "$mock_dir"

    cat > "$mock_dir/$cmd" << EOF
#!/bin/sh
echo "\$0 \$*" >> "$mock_dir/calls.log"
exit $return_code
EOF
    chmod +x "$mock_dir/$cmd"
    export PATH="$mock_dir:$PATH"
}

# Mock sudo to just run the command without privilege
mock_sudo() {
    local mock_dir="${MOCK_BIN_DIR:-$TEST_HOME/.local/mock-bin}"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/sudo" << 'EOF'
#!/bin/sh
# Skip sudo flags and just run the command
while [ $# -gt 0 ]; do
    case "$1" in
        -v|-n) shift ;;
        *) break ;;
    esac
done
[ $# -eq 0 ] && exit 0
exec "$@"
EOF
    chmod +x "$mock_dir/sudo"
    export PATH="$mock_dir:$PATH"
}

# Mock pacman to avoid system package operations
mock_pacman() {
    local mock_dir="${MOCK_BIN_DIR:-$TEST_HOME/.local/mock-bin}"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/pacman" << 'EOF'
#!/bin/sh
echo "mock pacman: $*" >> "${MOCK_BIN_DIR:-/tmp}/pacman.log"
case "$1" in
    -Q*) exit 0 ;;
    -S*) exit 0 ;;
    *) exit 0 ;;
esac
EOF
    chmod +x "$mock_dir/pacman"
    export PATH="$mock_dir:$PATH"
}

# Mock systemctl
mock_systemctl() {
    local mock_dir="${MOCK_BIN_DIR:-$TEST_HOME/.local/mock-bin}"
    mkdir -p "$mock_dir"

    cat > "$mock_dir/systemctl" << 'EOF'
#!/bin/sh
echo "mock systemctl: $*" >> "${MOCK_BIN_DIR:-/tmp}/systemctl.log"
case "$*" in
    *is-active*) echo "active"; exit 0 ;;
    *is-enabled*) exit 0 ;;
    *) exit 0 ;;
esac
EOF
    chmod +x "$mock_dir/systemctl"
    export PATH="$mock_dir:$PATH"
}

# Get recorded mock calls
get_mock_calls() {
    local mock_dir="${MOCK_BIN_DIR:-$TEST_HOME/.local/mock-bin}"
    cat "$mock_dir/calls.log" 2>/dev/null || true
}
