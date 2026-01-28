#!/usr/bin/env bats

load "../helpers/common"

setup() {
    setup_test_environment
    source_lib
}

teardown() {
    teardown_test_environment
}

@test "link() creates symlink to target" {
    local source_file="$TEST_DOTFILES/testfile"
    local target_link="$TEST_HOME/.config/testlink"

    echo "content" > "$source_file"

    link "$source_file" "$target_link"

    assert_link_exists "$target_link"
    assert_equal "$(readlink "$target_link")" "$source_file"
}

@test "link() creates parent directories" {
    local source_file="$TEST_DOTFILES/testfile"
    local target_link="$TEST_HOME/.config/deep/nested/link"

    echo "content" > "$source_file"

    link "$source_file" "$target_link"

    assert_dir_exists "$TEST_HOME/.config/deep/nested"
    assert_link_exists "$target_link"
}

@test "link() backs up existing file" {
    local source_file="$TEST_DOTFILES/testfile"
    local target_path="$TEST_HOME/.config/existing"

    echo "new content" > "$source_file"
    mkdir -p "$(dirname "$target_path")"
    echo "old content" > "$target_path"

    link "$source_file" "$target_path"

    assert_link_exists "$target_path"
    assert_file_exists "${target_path}.bak"
    assert_equal "$(cat "${target_path}.bak")" "old content"
}

@test "link() skips if symlink already correct" {
    local source_file="$TEST_DOTFILES/testfile"
    local target_link="$TEST_HOME/.config/testlink"

    echo "content" > "$source_file"
    mkdir -p "$(dirname "$target_link")"
    ln -s "$source_file" "$target_link"

    # Get inode (symlink itself won't change mtime reliably)
    local target_before="$(readlink "$target_link")"

    link "$source_file" "$target_link"

    local target_after="$(readlink "$target_link")"
    assert_equal "$target_before" "$target_after"
    # No backup should be created
    assert_file_not_exists "${target_link}.bak"
}

@test "link() replaces incorrect symlink" {
    local old_source="$TEST_DOTFILES/old"
    local new_source="$TEST_DOTFILES/new"
    local target_link="$TEST_HOME/.config/testlink"

    echo "old" > "$old_source"
    echo "new" > "$new_source"
    mkdir -p "$(dirname "$target_link")"
    ln -s "$old_source" "$target_link"

    link "$new_source" "$target_link"

    assert_equal "$(readlink "$target_link")" "$new_source"
}

@test "log() outputs with prefix" {
    run log "Test message"
    assert_output ">>> Test message"
}
