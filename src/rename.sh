#!/usr/bin/env bash
# rename.sh - Rename a tmux session
#
# Usage: rename.sh [old-name] <new-name>
# If only one argument is given and we're inside tmux, renames the current session.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/utils.sh" ]; then source "${SCRIPT_DIR}/utils.sh"; else
    RED='\033[0;31m'; GREEN='\033[0;32m'; BOLD='\033[1m'; RESET='\033[0m'
fi

show_help() {
    echo -e "${BOLD}Usage:${RESET} flux rename [old-name] <new-name>"
    echo
    echo "Rename a tmux session."
    echo "If only new-name is given and inside tmux, renames the current session."
    echo
    echo -e "${BOLD}Examples:${RESET}"
    echo "  flux rename myproject          # rename current session to 'myproject'"
    echo "  flux rename oldname newname    # rename 'oldname' to 'newname'"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help) show_help; exit 0 ;;
        *) break ;;
    esac
done

if ! command -v tmux >/dev/null 2>&1; then
    echo -e "${RED}Error:${RESET} tmux is not installed."; exit 1
fi

old_name=""
new_name=""

if [ $# -eq 1 ]; then
    # Single arg: rename current session
    if [ -z "${TMUX:-}" ]; then
        echo -e "${RED}Error:${RESET} Not inside a tmux session. Provide both old and new name."
        show_help; exit 1
    fi
    old_name=$(tmux display-message -p '#S' 2>/dev/null)
    new_name="$1"
elif [ $# -eq 2 ]; then
    old_name="$1"
    new_name="$2"
else
    echo -e "${RED}Error:${RESET} Expected 1 or 2 arguments."
    show_help; exit 1
fi

if ! tmux has-session -t "$old_name" 2>/dev/null; then
    echo -e "${RED}Error:${RESET} Session '$old_name' does not exist."
    exit 1
fi

if tmux has-session -t "$new_name" 2>/dev/null; then
    echo -e "${RED}Error:${RESET} Session '$new_name' already exists."
    exit 1
fi

tmux rename-session -t "$old_name" "$new_name"
echo -e "${GREEN}✓${RESET} Session renamed: ${BOLD}${old_name}${RESET} → ${BOLD}${new_name}${RESET}"
