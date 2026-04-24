#!/bin/bash
# =============================================================================
# SETUP FIXTURE TESTS
# =============================================================================
#
# Temp-HOME idempotency checks for setup tasks.
# No network access. No real HOME mutations.
#
# Usage: ./scripts/test-setup-fixtures.sh
# =============================================================================

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd -P)"
TMP_ROOT="$(mktemp -d)"
FAIL=0
SKIP=0

GREEN=2
YELLOW=3
RED=1
CYAN=6

cleanup() {
	rm -rf "$TMP_ROOT"
}
trap cleanup EXIT

set_color() {
	if command -v tput >/dev/null 2>&1 && [ -n "${TERM:-}" ]; then
		tput setaf "$1" 2>/dev/null || true
	fi
}

reset_color() {
	if command -v tput >/dev/null 2>&1 && [ -n "${TERM:-}" ]; then
		tput sgr0 2>/dev/null || true
	fi
}

echo_section() {
	printf "\n"
	set_color "$CYAN"
	printf "%s" "$1"
	reset_color
	printf "\n"
}

echo_success() {
	printf "   "
	set_color "$GREEN"
	printf "✓ %s" "$1"
	reset_color
	printf "\n"
}

echo_warn() {
	printf "   "
	set_color "$YELLOW"
	printf "⚠ %s" "$1"
	reset_color
	printf "\n"
}

echo_error() {
	printf "   "
	set_color "$RED"
	printf "✗ %s" "$1"
	reset_color
	printf "\n"
	FAIL=1
}

count_fixed() {
	grep -F "$1" "$2" 2>/dev/null | wc -l | tr -d " "
}

run_task() {
	local home="$1"
	local task="$2"
	local task_path="$DOTFILES_DIR/setup/tasks/$task"
	HOME="$home" DOTFILES_DIR="$DOTFILES_DIR" "$task_path" >/dev/null
}

assert_file_unchanged_after_second_run() {
	local before="$1"
	local after="$2"
	local label="$3"

	if cmp -s "$before" "$after"; then
		echo_success "$label is unchanged after second run"
	else
		echo_error "$label changed on second run"
	fi
}

test_shell_profiles() {
	echo_section "🐚 Shell profile fixtures..."

	local home="$TMP_ROOT/shell"
	mkdir -p "$home"

	run_task "$home" "shell-profiles.sh"
	cp "$home/.bash_profile" "$TMP_ROOT/bash_profile.first"
	cp "$home/.zshrc" "$TMP_ROOT/zshrc.first"
	run_task "$home" "shell-profiles.sh"

	if [ "$(count_fixed "source $DOTFILES_DIR/.profile" "$home/.bash_profile")" = "1" ]; then
		echo_success "bash profile source line is unique"
	else
		echo_error "bash profile source line is duplicated or missing"
	fi

	if [ "$(count_fixed "source $DOTFILES_DIR/.zshrc" "$home/.zshrc")" = "1" ]; then
		echo_success "zshrc source line is unique"
	else
		echo_error "zshrc source line is duplicated or missing"
	fi

	assert_file_unchanged_after_second_run "$TMP_ROOT/bash_profile.first" "$home/.bash_profile" ".bash_profile"
	assert_file_unchanged_after_second_run "$TMP_ROOT/zshrc.first" "$home/.zshrc" ".zshrc"
}

test_git_config() {
	echo_section "⚙️  Git config fixtures..."

	local home="$TMP_ROOT/git"
	mkdir -p "$home"
	printf "[user]\n\tname = Fixture User\n" >"$home/.gitconfig"

	run_task "$home" "git-config.sh"
	cp "$home/.gitconfig" "$TMP_ROOT/gitconfig.first"
	run_task "$home" "git-config.sh"

	if [ "$(count_fixed "path = $DOTFILES_DIR/.gitconfig" "$home/.gitconfig")" = "1" ]; then
		echo_success "git include path is unique"
	else
		echo_error "git include path is duplicated or missing"
	fi

	if grep -Fq "name = Fixture User" "$home/.gitconfig"; then
		echo_success "existing git config content is preserved"
	else
		echo_error "existing git config content was not preserved"
	fi

	assert_file_unchanged_after_second_run "$TMP_ROOT/gitconfig.first" "$home/.gitconfig" ".gitconfig"
}

test_codex() {
	echo_section "🤖 Codex fixtures..."

	local home="$TMP_ROOT/codex"
	local config="$home/.codex/config.toml"
	local rules="$home/.codex/rules/default.rules"
	mkdir -p "$home/.codex/rules"

	printf "[mcp_servers.custom]\ncommand = \"custom\"\n\n[mcp_servers.notion]\nurl = \"stale\"\n" >"$config"
	printf "prefix_rule(pattern=[\"git\", \"status\"], decision=\"allow\")\n" >"$rules"

	run_task "$home" "codex.sh"
	cp "$config" "$TMP_ROOT/codex-config.first"
	cp "$rules" "$TMP_ROOT/codex-rules.first"
	run_task "$home" "codex.sh"

	for section in chrome-devtools notion figma; do
		if [ "$(grep -Fxc "[mcp_servers.$section]" "$config")" = "1" ]; then
			echo_success "Codex MCP section $section is unique"
		else
			echo_error "Codex MCP section $section is duplicated or missing"
		fi
	done

	if grep -Fq "[mcp_servers.custom]" "$config"; then
		echo_success "unmanaged Codex MCP section is preserved"
	else
		echo_error "unmanaged Codex MCP section was removed"
	fi

	if [ "$(awk 'NF { print }' "$rules" | sort | uniq -d | wc -l | tr -d " ")" = "0" ]; then
		echo_success "Codex rules have no duplicate non-empty lines"
	else
		echo_error "Codex rules contain duplicate non-empty lines"
	fi

	assert_file_unchanged_after_second_run "$TMP_ROOT/codex-config.first" "$config" "Codex config"
	assert_file_unchanged_after_second_run "$TMP_ROOT/codex-rules.first" "$rules" "Codex rules"
}

test_claude() {
	echo_section "🪄 Claude fixtures..."

	if ! command -v jq >/dev/null 2>&1 || ! command -v envsubst >/dev/null 2>&1; then
		echo_warn "jq or envsubst unavailable; skipping Claude fixture"
		SKIP=$((SKIP + 1))
		return
	fi

	local home="$TMP_ROOT/claude"
	local settings="$home/.claude/settings.json"
	local claude_json="$home/.claude.json"
	mkdir -p "$home/.claude"

	printf '{"existing":true}\n' >"$settings"
	printf '{"other":true}\n' >"$claude_json"

	run_task "$home" "claude.sh"
	cp "$settings" "$TMP_ROOT/claude-settings.first"
	cp "$claude_json" "$TMP_ROOT/claude-json.first"
	run_task "$home" "claude.sh"

	if jq -e '.existing == true and .statusLine.type == "command"' "$settings" >/dev/null; then
		echo_success "Claude settings merge preserves existing fields"
	else
		echo_error "Claude settings merge did not preserve expected fields"
	fi

	if jq -e '.other == true and .mcpServers.notion.url' "$claude_json" >/dev/null; then
		echo_success "Claude MCP merge preserves existing fields"
	else
		echo_error "Claude MCP merge did not preserve expected fields"
	fi

	assert_file_unchanged_after_second_run "$TMP_ROOT/claude-settings.first" "$settings" "Claude settings"
	assert_file_unchanged_after_second_run "$TMP_ROOT/claude-json.first" "$claude_json" "Claude config"
}

test_terminfo() {
	echo_section "🖥️  Terminfo fixtures..."

	if ! command -v tic >/dev/null 2>&1 || ! command -v infocmp >/dev/null 2>&1; then
		echo_warn "tic or infocmp unavailable; skipping terminfo fixture"
		SKIP=$((SKIP + 1))
		return
	fi

	local home="$TMP_ROOT/terminfo"
	mkdir -p "$home"

	run_task "$home" "terminfo.sh"
	if infocmp -A "$home/.terminfo" wezterm >/dev/null 2>&1; then
		echo_success "WezTerm terminfo compiles into temp HOME"
	else
		echo_error "WezTerm terminfo did not compile into temp HOME"
	fi

	local terminfo_task="$DOTFILES_DIR/setup/tasks/terminfo.sh"
	HOME="$home" DOTFILES_DIR="$DOTFILES_DIR" "$terminfo_task" >"$TMP_ROOT/terminfo.second"
	if grep -Fq "WezTerm terminfo exists" "$TMP_ROOT/terminfo.second"; then
		echo_success "WezTerm terminfo second run is a no-op"
	else
		echo_error "WezTerm terminfo second run did not detect existing entry"
	fi
}

test_shell_profiles
test_git_config
test_codex
test_claude
test_terminfo

printf "\n"
if [ $FAIL -eq 0 ]; then
	set_color "$GREEN"
	if [ $SKIP -gt 0 ]; then
		printf "✓ Fixture checks passed (%s skipped)\n" "$SKIP"
	else
		printf "✓ Fixture checks passed\n"
	fi
	reset_color
	exit 0
else
	set_color "$RED"
	printf "✗ Fixture checks failed\n"
	reset_color
	exit 1
fi
