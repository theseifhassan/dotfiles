SHELL := /bin/bash
BATS := ./tests/bats/bats-core/bin/bats

# Scripts to check (sh)
SH_SCRIPTS := install/setup.sh install/lib.sh install/hardware.sh \
	scripts/.local/bin/dot scripts/.local/bin/dmenu_run \
	scripts/.local/bin/sessionizer.sh scripts/.local/bin/audio.sh \
	scripts/.local/bin/lid-check.sh scripts/.local/bin/webappmgr.sh

# Test helpers (bash)
BASH_SCRIPTS := tests/helpers/common.bash tests/helpers/mocks.bash

.PHONY: all lint test test-unit test-integration clean help

all: lint test

lint:
	@echo "==> Running ShellCheck on sh scripts..."
	@shellcheck $(SH_SCRIPTS)
	@echo "==> Running ShellCheck on bash scripts..."
	@shellcheck --shell=bash $(BASH_SCRIPTS)
	@echo "==> ShellCheck passed!"

test: test-unit test-integration

test-unit:
	@echo "==> Running unit tests..."
	@$(BATS) tests/unit/

test-integration:
	@echo "==> Running integration tests..."
	@$(BATS) tests/integration/

test-file:
	@test -n "$(FILE)" || (echo "Usage: make test-file FILE=tests/unit/lib.bats" && exit 1)
	@$(BATS) $(FILE)

test-verbose:
	@$(BATS) --verbose-run tests/unit/ tests/integration/

check-deps:
	@command -v shellcheck >/dev/null || (echo "Install shellcheck: sudo pacman -S shellcheck" && exit 1)
	@test -f $(BATS) || (echo "BATS not found in tests/bats/" && exit 1)
	@echo "All dependencies satisfied."

clean:
	@find tests -name "*.bats.bak" -delete 2>/dev/null || true

help:
	@echo "Dotfiles Test Targets:"
	@echo "  make lint             - Run ShellCheck on all scripts"
	@echo "  make test             - Run all tests"
	@echo "  make test-unit        - Run unit tests only"
	@echo "  make test-integration - Run integration tests only"
	@echo "  make test-file FILE=x - Run specific test file"
	@echo "  make test-verbose     - Run tests with verbose output"
	@echo "  make check-deps       - Verify testing dependencies"
	@echo "  make clean            - Clean test artifacts"
