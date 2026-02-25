#!/usr/bin/env bash
# kill.sh - Kill tmux session(s)
#
# Usage: kill.sh [OPTIONS] [session-name]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/utils.sh" ]; then source "${SCRIPT_DIR}/utils.sh"; else
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
    CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
fi

KILL_ALL=false
YES=false
session_name=""

show_help() {
    echo -e "${BOLD}Usage:${RESET} flux kill [OPTIONS] [session-name]"
    echo
    echo "Kill a tmux session."
    echo "If no session name is given and inside tmux, kills the current session."
    echo "If no session name is given and outside tmux, opens an fzf picker."
    echo
    echo -e "${BOLD}Options:${RESET}"
    echo "  -a, --all     Kill all sessions (same as flux clean)"
    echo "  -y, --yes     Skip confirmation prompts"
    echo "  -h, --help    Show this help message"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -a|--all)  KILL_ALL=true; shift ;;
        -y|--yes)  YES=true; shift ;;
        -h|--help) show_help; exit 0 ;;
        -*)        echo "Error: Unknown option: $1"; show_help; exit 1 ;;
        *)         session_name="$1"; shift ;;
    esac
done

if ! command -v tmux >/dev/null 2>&1; then
    echo -e "${RED}Error:${RESET} tmux is not installed."; exit 1
fi

confirm() {
    local msg="$1"
    if $YES; then return 0; fi
    read -r -p "$msg [y/N] " choice
    [[ "$choice" =~ ^[Yy]$ ]]
}

# Kill all
if $KILL_ALL; then
    if confirm "Kill ALL tmux sessions?"; then
        tmux kill-server 2>/dev/null || true
        echo -e "${GREEN}✓${RESET} All sessions killed."
    else
        echo "Aborted."
    fi
    exit 0
fi

# Kill named session
if [ -n "$session_name" ]; then
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo -e "${RED}Error:${RESET} Session '$session_name' does not exist."
        exit 1
    fi
    if confirm "Kill session '${session_name}'?"; then
        tmux kill-session -t "$session_name"
        echo -e "${GREEN}✓${RESET} Session '${session_name}' killed."
    else
        echo "Aborted."
    fi
    exit 0
fi

# No name given — use current session or fzf picker
current_session=""
if [ -n "${TMUX:-}" ]; then
    current_session=$(tmux display-message -p '#S' 2>/dev/null || true)
fi

if [ -n "$current_session" ]; then
    if confirm "Kill current session '${current_session}'?"; then
        tmux kill-session -t "$current_session"
        echo -e "${GREEN}✓${RESET} Session '${current_session}' killed."
    else
        echo "Aborted."
    fi
    exit 0
fi

# fzf picker
if ! command -v fzf >/dev/null 2>&1; then
    echo -e "${RED}Error:${RESET} No session name given and fzf is not installed."
    echo "Specify a session name: flux kill <session-name>"
    exit 1
fi

sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null || true)
if [ -z "$sessions" ]; then
    echo -e "${YELLOW}No active tmux sessions.${RESET}"; exit 0
fi

selected=$(echo "$sessions" | fzf \
    --height=40% --reverse --border \
    --prompt="💀 Select session to kill: " \
    --header="Select session | ESC to cancel" \
    2>/dev/null || true)

if [ -z "$selected" ]; then echo "Cancelled."; exit 0; fi

if confirm "Kill session '${selected}'?"; then
    tmux kill-session -t "$selected"
    echo -e "${GREEN}✓${RESET} Session '${selected}' killed."
else
    echo "Aborted."
fi
