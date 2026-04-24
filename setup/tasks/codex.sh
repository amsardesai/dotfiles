#!/bin/bash

source "$(dirname "$0")/../lib/paths.sh"
source "$DOTFILES_DIR/setup/lib/output.sh"

upsert_codex_mcp_sections() {
	SOURCE_FILE="$1"
	DEST_FILE="$2"
	TMP_FILE=$(mktemp)
	TRIMMED_FILE=$(mktemp)

	if [ -f "$DEST_FILE" ]; then
		awk '
			function is_managed_section(line) {
				return line ~ /^\[mcp_servers\.(chrome-devtools|notion|figma)(\.|])/
			}

			/^\[/ {
				if (is_managed_section($0)) {
					skip = 1
					next
				}
				skip = 0
			}

			!skip { print }
		' "$DEST_FILE" >"$TMP_FILE"
	else
		: >"$TMP_FILE"
	fi

	awk '
		NF {
			for (i = 0; i < blank; i++) {
				print ""
			}
			blank = 0
			print
			next
		}

		{ blank++ }
	' "$TMP_FILE" >"$TRIMMED_FILE"
	mv -f "$TRIMMED_FILE" "$TMP_FILE"

	if [ -s "$TMP_FILE" ]; then
		printf "\n" >>"$TMP_FILE"
	fi
	cat "$SOURCE_FILE" >>"$TMP_FILE"

	if [ -f "$DEST_FILE" ] && cmp -s "$DEST_FILE" "$TMP_FILE"; then
		rm -f "$TMP_FILE"
		return 1
	fi

	mkdir -p "$(dirname "$DEST_FILE")"
	mv -f "$TMP_FILE" "$DEST_FILE"
	chmod 600 "$DEST_FILE" 2>/dev/null || true
	return 0
}

merge_codex_rules() {
	SOURCE_FILE="$1"
	DEST_FILE="$2"
	UPDATED=0

	mkdir -p "$(dirname "$DEST_FILE")"
	touch "$DEST_FILE"

	while IFS= read -r RULE || [ -n "$RULE" ]; do
		[ -z "$RULE" ] && continue

		if ! grep -Fq "$RULE" "$DEST_FILE" 2>/dev/null; then
			printf "%s\n" "$RULE" >>"$DEST_FILE"
			UPDATED=1
		fi
	done <"$SOURCE_FILE"

	return $UPDATED
}

CODEX_CONFIG="$HOME/.codex/config.toml"
REPO_CODEX_MCP="$DOTFILES_DIR/codex-mcp.toml"
CODEX_RULES="$HOME/.codex/rules/default.rules"
REPO_CODEX_RULES="$DOTFILES_DIR/codex-rules/default.rules"

mkdir -p "$HOME/.codex"

if [ -f "$REPO_CODEX_MCP" ]; then
	if upsert_codex_mcp_sections "$REPO_CODEX_MCP" "$CODEX_CONFIG"; then
		echo_success "Merged MCP servers into Codex config"
	else
		echo_success "Codex MCP servers already up to date"
	fi
else
	echo_warn "codex-mcp.toml not found in repo"
fi

if [ -f "$REPO_CODEX_RULES" ]; then
	if merge_codex_rules "$REPO_CODEX_RULES" "$CODEX_RULES"; then
		echo_success "Codex approval rules already up to date"
	else
		echo_success "Added default Codex approval rules"
	fi
else
	echo_warn "codex-rules/default.rules not found in repo"
fi
