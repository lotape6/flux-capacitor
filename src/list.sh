#!/usr/bin/env bash
# list.sh - List all active tmux sessions
#
# Usage: list.sh [OPTIONS]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/utils.sh" ]; then source "${SCRIPT_DIR}/utils.sh"; else
    GREEN='\033[0;32m'; YELLOW='\033[0;33m'; CYAN='\033[0;36m'
    BOLD='\033[1m'; RESET='\033[0m'
fi

JSON_OUTPUT=false

show_help() {
    echo -e "${BOLD}Usage:${RESET} flux list [OPTIONS]"
    echo
    echo "List all active tmux sessions."
    echo
    echo -e "${BOLD}Options:${RESET}"
    echo "  -j, --json    Output as JSON"
    echo "  -h, --help    Show this help message"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -j|--json) JSON_OUTPUT=true; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo "Error: Unknown option: $1"; show_help; exit 1 ;;
    esac
done

if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux is not installed or not in PATH"; exit 1
fi

sessions=$(tmux list-sessions \
    -F "#{session_name}\t#{session_windows}\t#{session_attached}\t#{pane_current_path}\t#{session_created}" \
    2>/dev/null || true)

if [ -z "$sessions" ]; then
    echo -e "${YELLOW}No active tmux sessions.${RESET}"
    echo "Create one with: flux connect <directory>"
    exit 0
fi

current_session=""
if [ -n "${TMUX:-}" ]; then
    current_session=$(tmux display-message -p '#S' 2>/dev/null || true)
fi

if $JSON_OUTPUT; then
    echo "$sessions" | python3 -c "
import sys, json, datetime
rows = []
for line in sys.stdin:
    parts = line.rstrip('\n').split('\t')
    if len(parts) < 5: continue
    name, windows, attached, path, created = parts
    rows.append({
        'name': name,
        'windows': int(windows),
        'attached': int(attached) > 0,
        'path': path,
        'created': datetime.datetime.fromtimestamp(int(created)).isoformat()
    })
print(json.dumps(rows, indent=2))
"
    exit 0
fi

# Pretty table
printf '\n'
printf "${BOLD}${CYAN}%-20s  %-8s  %-10s  %-40s  %s${RESET}\n" \
    "SESSION" "WINDOWS" "STATUS" "DIRECTORY" "CREATED"
printf '%s\n' "$(printf '%.0s─' {1..90})"

echo "$sessions" | while IFS=$'\t' read -r name windows attached path created; do
    if [ "$attached" -gt 0 ]; then
        status="${GREEN}● attached${RESET}"
    else
        status="${YELLOW}○ detached${RESET}"
    fi

    marker=""
    [ "$name" = "$current_session" ] && marker=" ${CYAN}◀ current${RESET}"

    created_fmt=$(date -d "@${created}" '+%m/%d %H:%M' 2>/dev/null || \
                  date -r "${created}" '+%m/%d %H:%M' 2>/dev/null || echo "?")

    # Truncate path if too long
    short_path="${path/#$HOME/\~}"
    if [ ${#short_path} -gt 38 ]; then short_path="…${short_path: -37}"; fi

    printf "%-20s  %-8s  %-10b  %-40s  %s%b\n" \
        "$name" "$windows" "$status" "$short_path" "$created_fmt" "$marker"
done

printf '\n'
total=$(echo "$sessions" | wc -l | tr -d ' ')
echo -e "  ${BOLD}${total}${RESET} session(s) total"
printf '\n'
