#!/bin/bash

source "$(dirname "$0")/../lib/paths.sh"
source "$DOTFILES_DIR/setup/lib/output.sh"

echo_section "🪄 Configuring AI tools..."

CLAUDE_SETTINGS="$HOME/.claude/settings.json"
REPO_CLAUDE_SETTINGS="$DOTFILES_DIR/claude-settings.json"
CLAUDE_JSON="$HOME/.claude.json"
REPO_MCP_SETTINGS="$DOTFILES_DIR/claude-mcp.json"

mkdir -p "$HOME/.claude"

if [ -f "$REPO_CLAUDE_SETTINGS" ]; then
	EXPANDED_SETTINGS=$(envsubst <"$REPO_CLAUDE_SETTINGS")

	if [ -f "$CLAUDE_SETTINGS" ]; then
		MERGED=$(jq -s '.[0] * .[1]' "$CLAUDE_SETTINGS" <(echo "$EXPANDED_SETTINGS"))
		CURRENT_SORTED=$(jq -S '.' "$CLAUDE_SETTINGS")
		MERGED_SORTED=$(echo "$MERGED" | jq -S '.')

		if [ "$CURRENT_SORTED" = "$MERGED_SORTED" ]; then
			echo_success "Claude Code settings already up to date"
		else
			echo "$MERGED" >"$CLAUDE_SETTINGS"
			echo_success "Merged settings into Claude Code config"
		fi
	else
		echo "$EXPANDED_SETTINGS" >"$CLAUDE_SETTINGS"
		echo_success "Created Claude Code settings with hooks"
	fi
else
	echo_warn "claude-settings.json not found in repo"
fi

if [ -f "$REPO_MCP_SETTINGS" ]; then
	if [ -f "$CLAUDE_JSON" ]; then
		CURRENT_MCP=$(jq '.mcpServers // {}' "$CLAUDE_JSON" 2>/dev/null)
		NEW_MCP=$(jq '.mcpServers // {}' "$REPO_MCP_SETTINGS")
		MERGED_MCP=$(jq -s '.[0] * .[1]' <(echo "$CURRENT_MCP") <(echo "$NEW_MCP"))

		if [ "$CURRENT_MCP" = "$MERGED_MCP" ]; then
			echo_success "MCP servers already configured"
		else
			MERGED=$(jq --argjson mcp "$MERGED_MCP" '.mcpServers = $mcp' "$CLAUDE_JSON")
			echo "$MERGED" >"$CLAUDE_JSON"
			echo_success "Merged MCP servers into Claude Code config"
		fi
	else
		cp -f "$REPO_MCP_SETTINGS" "$CLAUDE_JSON"
		echo_success "Created Claude Code config with MCP servers"
	fi
else
	echo_warn "claude-mcp.json not found in repo"
fi
