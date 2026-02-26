#!/usr/bin/env bash
# save.sh - Save the current tmux session layout to a .flux.yml file
#
# Usage: save.sh [OPTIONS] [session-name]
#
# Serializes windows, directories, and running commands into a .flux.yml
# compatible with 'flux launch' / 'flux restore'.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "${SCRIPT_DIR}/utils.sh" ]; then source "${SCRIPT_DIR}/utils.sh"; else
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
    CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
fi

OUTPUT_PATH=""
session_name=""

show_help() {
    echo -e "${BOLD}Usage:${RESET} flux save [OPTIONS] [session-name]"
    echo
    echo "Save a tmux session layout to a .flux.yml file."
    echo "If no session name is given, saves the current session (must be inside tmux)."
    echo
    echo -e "${BOLD}Options:${RESET}"
    echo "  -o, --output <path>   Output file path (default: .flux.yml in session root)"
    echo "  -h, --help            Show this help message"
    echo
    echo -e "${BOLD}Example:${RESET}"
    echo "  flux save                        # save current session to ./.flux.yml"
    echo "  flux save myproject              # save 'myproject' session"
    echo "  flux save -o ~/configs/work.yml  # save to specific path"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output) OUTPUT_PATH="$2"; shift 2 ;;
        -h|--help)   show_help; exit 0 ;;
        -*)          echo "Error: Unknown option: $1"; show_help; exit 1 ;;
        *)           session_name="$1"; shift ;;
    esac
done

if ! command -v tmux >/dev/null 2>&1; then
    echo -e "${RED}Error:${RESET} tmux is not installed."; exit 1
fi

# Resolve session name
if [ -z "$session_name" ]; then
    if [ -z "${TMUX:-}" ]; then
        echo -e "${RED}Error:${RESET} Not inside a tmux session. Specify a session name."
        show_help; exit 1
    fi
    session_name=$(tmux display-message -p '#S' 2>/dev/null)
fi

if ! tmux has-session -t "$session_name" 2>/dev/null; then
    echo -e "${RED}Error:${RESET} Session '$session_name' does not exist."
    exit 1
fi

echo -e " ${CYAN}[SAVE]${RESET} Saving session: ${BOLD}${session_name}${RESET}"

# Get session root from first pane of first window
session_root=$(tmux list-panes -t "${session_name}:1" -F "#{pane_current_path}" 2>/dev/null | head -1)
session_root="${session_root:-$HOME}"

# Determine output path
if [ -z "$OUTPUT_PATH" ]; then
    OUTPUT_PATH="${session_root}/.flux.yml"
fi

# Gather window data
windows_yaml=""
window_list=$(tmux list-windows -t "$session_name" \
    -F "#{window_index}:#{window_name}:#{pane_current_path}:#{pane_current_command}" \
    2>/dev/null)

while IFS=':' read -r win_idx win_name win_path win_cmd; do
    # Skip shell processes — not useful to relaunch
    case "$win_cmd" in
        bash|zsh|fish|sh|dash|ksh|tcsh|csh) win_cmd="" ;;
    esac

    # Shorten path relative to root where possible
    if [[ "$win_path" == "$session_root"* ]]; then
        rel_path="${win_path#$session_root}"
        rel_path="${rel_path#/}"
        [ -z "$rel_path" ] && display_path="$session_root" || display_path="${session_root}/${rel_path}"
    else
        display_path="$win_path"
    fi
    # Replace $HOME with ~
    display_path="${display_path/#$HOME/\~}"

    windows_yaml+="  - name: ${win_name}\n"
    if [ "$display_path" != "${session_root/#$HOME/\~}" ]; then
        windows_yaml+="    dir: ${display_path}\n"
    fi
    if [ -n "$win_cmd" ]; then
        windows_yaml+="    cmd: ${win_cmd}\n"
    fi
done <<< "$window_list"

# Replace $HOME with ~ in root
short_root="${session_root/#$HOME/\~}"

# Write YAML
cat > "$OUTPUT_PATH" <<YAML
# .flux.yml — saved by flux save
# Session: ${session_name}
# Saved: $(date '+%Y-%m-%d %H:%M:%S')
# Restore with: flux restore ${OUTPUT_PATH}

session: ${session_name}
root: ${short_root}

windows:
$(printf '%b' "${windows_yaml}")
YAML

echo -e " ${GREEN}✓${RESET} Session saved to: ${BOLD}${OUTPUT_PATH}${RESET}"
echo -e "   Restore with: ${CYAN}flux restore ${OUTPUT_PATH}${RESET}"
