# Git Log Functions
# Provides: lg (short log), lf (full log with pager), lgm (my commits)
# Features: HEAD marker (👉), unpushed marker (✏️)

# Format: full SHA (for unpushed detection) + tab + display content
GIT_LOG_FORMAT='tformat:%H	%C(yellow)%h%C(reset) %C(italic magenta)%cd%C(reset) %C(bold blue)[%aN]%C(reset) %C(italic)%s%C(reset)%C(auto)%d%C(reset) %C(green)%G?%C(reset)'

# Add 👉 (HEAD) and ✏️ (unpushed) markers
_git_log_enhance() {
  # Get commits not on any remote (subshell isolates from pipeline stdin)
  local unpushed
  unpushed=$( (git log --format=%H HEAD --not --remotes 2>/dev/null) | tr '\n' '|' | sed 's/|$//')

  # Fast awk processing (BSD awk compatible)
  awk -F'\t' -v up="$unpushed" '
    BEGIN { if (up) { n = split(up, arr, "|"); for (i=1; i<=n; i++) unpushed[arr[i]] = 1 } }
    NF >= 2 {
      prefix_and_sha = $1
      rest = substr($0, length($1) + 2)  # everything after tab

      # Find 40-char hex SHA using regex (handles ANSI color codes in graph)
      if (match(prefix_and_sha, /[a-f0-9]{40}/)) {
        sha = substr(prefix_and_sha, RSTART, RLENGTH)
        prefix = substr(prefix_and_sha, 1, RSTART - 1)
      } else {
        print; next  # no SHA found, pass through
      }

      # Determine icon: 👉 for HEAD, ✏️ for unpushed
      icon = ""
      if (rest ~ /\([^\/]*HEAD/) icon = "👉 "
      else if (sha in unpushed) icon = "✏️ "

      # Insert icon after "* " if present
      if (icon) sub(/\* /, "* " icon, prefix)

      print prefix rest
    }
    NF < 2 { print }  # pass through graph-only lines
  '
}

# Core git log function: _git_log [--hierarchical] [--pager] [git-log-args...]
_git_log() {
  local use_pager=false
  local -a args=()

  # Parse our flags
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --hierarchical) args+=(--branches) ;;
      --pager) use_pager=true ;;
      *) args+=("$1") ;;
    esac
    shift
  done

  # Run git log with enhancement
  if $use_pager; then
    # -R: colors, -F: quit if one screen, -X: don't clear screen
    git --no-pager log --color=always --graph --pretty="$GIT_LOG_FORMAT" --abbrev-commit --date=relative "${args[@]}" | _git_log_enhance | less -RFX
  else
    git --no-pager log --color=always --graph --pretty="$GIT_LOG_FORMAT" --abbrev-commit --date=relative "${args[@]}" | _git_log_enhance
  fi
}

# Unalias any existing log aliases before defining functions
unalias lg lf lgm lga lgh 2>/dev/null

# Short log (no pager, limited commits, all branches)
lg()  { _git_log --max-count=10 --hierarchical "$@"; }

# Full log (with pager)
lf()  { _git_log --pager --hierarchical "$@"; }
lgm() { _git_log --pager '--author=Ankit\ Sardesai' "$@"; }
