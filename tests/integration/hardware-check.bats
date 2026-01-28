#!/usr/bin/env bats

load "../helpers/common"
load "../helpers/mocks"

setup() {
    setup_test_environment
    export MOCK_BIN_DIR="$TEST_HOME/.local/mock-bin"
    mkdir -p "$MOCK_BIN_DIR"
    export PATH="$MOCK_BIN_DIR:$PATH"
}

teardown() {
    teardown_test_environment
}

@test "check_bluetooth succeeds when all components present" {
    # Mock pacman - bluez installed
    cat > "$MOCK_BIN_DIR/pacman" << 'EOF'
#!/bin/sh
exit 0
EOF
    chmod +x "$MOCK_BIN_DIR/pacman"

    # Mock systemctl - service running and enabled
    cat > "$MOCK_BIN_DIR/systemctl" << 'EOF'
#!/bin/sh
case "$*" in
    *is-active*bluetooth*) exit 0 ;;
    *is-enabled*bluetooth*) exit 0 ;;
    *) exit 1 ;;
esac
EOF
    chmod +x "$MOCK_BIN_DIR/systemctl"

    run "$TEST_DOTFILES/install/hardware.sh" check bluetooth

    assert_success
    assert_line --partial "Bluetooth: all good"
}

@test "check_bluetooth fails when service not running" {
    # Mock pacman - bluez installed
    cat > "$MOCK_BIN_DIR/pacman" << 'EOF'
#!/bin/sh
exit 0
EOF
    chmod +x "$MOCK_BIN_DIR/pacman"

    # Mock systemctl - service not running
    cat > "$MOCK_BIN_DIR/systemctl" << 'EOF'
#!/bin/sh
case "$*" in
    *is-active*) exit 1 ;;
    *is-enabled*) exit 0 ;;
esac
EOF
    chmod +x "$MOCK_BIN_DIR/systemctl"

    run "$TEST_DOTFILES/install/hardware.sh" check bluetooth

    assert_line --partial "bluetooth service not running"
    assert_line --partial "issues found"
}

@test "check_bluetooth fails when package not installed" {
    # Mock pacman - bluez not installed
    cat > "$MOCK_BIN_DIR/pacman" << 'EOF'
#!/bin/sh
exit 1
EOF
    chmod +x "$MOCK_BIN_DIR/pacman"

    # Mock systemctl
    cat > "$MOCK_BIN_DIR/systemctl" << 'EOF'
#!/bin/sh
exit 0
EOF
    chmod +x "$MOCK_BIN_DIR/systemctl"

    run "$TEST_DOTFILES/install/hardware.sh" check bluetooth

    assert_line --partial "bluez not installed"
    assert_line --partial "issues found"
}

@test "check_nvidia skips when no NVIDIA GPU" {
    # Mock lspci - no NVIDIA
    cat > "$MOCK_BIN_DIR/lspci" << 'EOF'
#!/bin/sh
echo "00:02.0 VGA compatible controller: Intel Corporation"
exit 0
EOF
    chmod +x "$MOCK_BIN_DIR/lspci"

    run "$TEST_DOTFILES/install/hardware.sh" check nvidia

    assert_success
    assert_output "No NVIDIA GPU"
}

@test "check_printer succeeds when all components present" {
    # Mock pacman - cups installed
    cat > "$MOCK_BIN_DIR/pacman" << 'EOF'
#!/bin/sh
exit 0
EOF
    chmod +x "$MOCK_BIN_DIR/pacman"

    # Mock systemctl - service running and enabled
    cat > "$MOCK_BIN_DIR/systemctl" << 'EOF'
#!/bin/sh
case "$*" in
    *is-active*cups*) exit 0 ;;
    *is-enabled*cups*) exit 0 ;;
    *) exit 1 ;;
esac
EOF
    chmod +x "$MOCK_BIN_DIR/systemctl"

    # Mock groups - user in lp group
    cat > "$MOCK_BIN_DIR/groups" << 'EOF'
#!/bin/sh
echo "wheel lp"
EOF
    chmod +x "$MOCK_BIN_DIR/groups"

    run "$TEST_DOTFILES/install/hardware.sh" check printer

    assert_success
    assert_line --partial "Printer: all good"
}

@test "check_fingerprint skips when no reader detected" {
    # Mock lsusb - no fingerprint reader
    cat > "$MOCK_BIN_DIR/lsusb" << 'EOF'
#!/bin/sh
echo "Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub"
exit 0
EOF
    chmod +x "$MOCK_BIN_DIR/lsusb"

    run "$TEST_DOTFILES/install/hardware.sh" check fingerprint

    assert_success
    assert_output "No fingerprint reader"
}
