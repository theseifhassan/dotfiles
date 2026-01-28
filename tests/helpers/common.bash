#!/usr/bin/env bash
# shellcheck shell=bash
# Common test setup and utilities

# Load BATS libraries
TESTS_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
load "${TESTS_DIR}/bats/bats-support/load"
load "${TESTS_DIR}/bats/bats-assert/load"
load "${TESTS_DIR}/bats/bats-file/load"

# Set up isolated test environment
setup_test_environment() {
    TEST_HOME="$(mktemp -d)"
    TEST_DOTFILES="$(mktemp -d)"
    export TEST_HOME TEST_DOTFILES
    export HOME="$TEST_HOME"
    export DOTFILES="$TEST_DOTFILES"
    export XDG_CONFIG_HOME="$TEST_HOME/.config"
    export XDG_DATA_HOME="$TEST_HOME/.local/share"
    export XDG_STATE_HOME="$TEST_HOME/.local/state"

    mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME"
    mkdir -p "$TEST_HOME/.local/bin"

    # Copy source files to test location
    REAL_DOTFILES="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd)"
    cp -r "$REAL_DOTFILES/install" "$TEST_DOTFILES/"
    cp -r "$REAL_DOTFILES/scripts" "$TEST_DOTFILES/"
}

teardown_test_environment() {
    rm -rf "$TEST_HOME" "$TEST_DOTFILES"
}

# Source the library under test
source_lib() {
    . "$TEST_DOTFILES/install/lib.sh"
}
