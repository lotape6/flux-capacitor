#!/bin/bash
# session-switch.sh - Interactive tmux session switcher using fzf
#
# This script provides an interactive way to switch between existing tmux sessions
# using fzf with emojis and fancy formatting. It handles detaching from current
# session before attaching to a new one.

# Exit on error
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source utilities for consistent output
if [ -f "${SCRIPT_DIR}/utils.sh" ]; then
    source "${SCRIPT_DIR}/utils.sh"
fi

# Display help message
show_help() {
    echo "Usage: flux session-switch [options]"
    echo
    echo "Options:"
    echo "  -h, --help      Show this help message"
    echo
    echo "Description:"
    echo "  Interactive tmux session switcher using fzf."
    echo "  Shows existing sessions with fancy formatting and emojis."
    echo "  Handles detaching from current session before switching."
    echo
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo "Error: Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            echo "Error: Unexpected argument: $1"
            show_help
            exit 1
            ;;
    esac
done

# Check if tmux is installed
if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux is not installed or not in PATH"
    exit 1
fi

# Check if fzf is installed
if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed or not in PATH"
    echo "Please install fzf to use session switching functionality"
    exit 1
fi

# Get list of tmux sessions
sessions=$(tmux list-sessions -F "#{session_name}:#{session_windows}:#{session_attached}:#{pane_current_path}" 2>/dev/null || true)

if [ -z "$sessions" ]; then
    echo "No tmux sessions found."
    echo "Create a new session with: flux connect <directory>"
    exit 0
fi

# Check if we're currently inside a tmux session
current_session=""
if [ -n "${TMUX:-}" ]; then
    current_session=$(tmux display-message -p '#S' 2>/dev/null || true)
fi

# Format sessions for fzf with emojis and fancy display
format_sessions() {
    local session_line
    local session_name
    local session_windows
    local session_attached
    local session_path
    local emoji
    local status_emoji
    local formatted_line
    
    echo "$sessions" | while IFS=':' read -r session_name session_windows session_attached session_path; do
        # Choose emoji based on session characteristics
        if [ "$session_attached" -gt 0 ]; then
            if [ "$session_name" = "$current_session" ]; then
                status_emoji="🔗"  # Current session
            else
                status_emoji="👥"  # Attached by others
            fi
        else
            status_emoji="💤"      # Detached session
        fi
        
        # Choose session emoji based on session name patterns
        case "$session_name" in
            *dev*|*develop*) emoji="🛠️ " ;;
            *test*|*staging*) emoji="🧪" ;;
            *prod*|*production*) emoji="🚀" ;;
            *main*|*master*) emoji="🏠" ;;
            *work*) emoji="💼" ;;
            *project*|*proj*) emoji="📁" ;;
            *flux*) emoji="⚡" ;;
            *) emoji="📂" ;;
        esac
        
        # Format the display line
        formatted_line="${status_emoji} ${emoji} ${session_name} (${session_windows} windows) 📍 ${session_path}"
        echo "${formatted_line}"
    done
}

# Create formatted session list
formatted_sessions=$(format_sessions)

# Use fzf to select a session
selected_line=$(echo "$formatted_sessions" | fzf \
    --height=40% \
    --reverse \
    --border \
    --prompt="🔄 Select session to switch to: " \
    --header="🎯 Use Alt+S to switch sessions | ESC to cancel" \
    --preview-window="right:50%" \
    --preview="echo 'Session Details:'; echo; tmux list-windows -t \$(echo {} | sed 's/^[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*//; s/ (.*//') 2>/dev/null || echo 'No details available'" \
    --bind="alt-s:accept" \
    --color="header:italic:cyan,prompt:bold:blue,pointer:red,marker:yellow" \
    2>/dev/null || true)

# Check if user cancelled selection
if [ -z "$selected_line" ]; then
    echo "Session switching cancelled."
    exit 0
fi

# Extract session name from selected line
selected_session=$(echo "$selected_line" | sed 's/^[^[:space:]]*[[:space:]]*[^[:space:]]*[[:space:]]*//; s/ (.*//')

# Validate that the session still exists
if ! tmux has-session -t "$selected_session" 2>/dev/null; then
    echo "Error: Session '$selected_session' no longer exists"
    exit 1
fi

# Check if we're trying to switch to the current session
if [ "$selected_session" = "$current_session" ]; then
    echo "Already attached to session '$current_session'"
    exit 0
fi

echo "Switching to session '$selected_session'..."

# Switch to the selected session
if [ -n "$current_session" ]; then
    # If we're in a tmux session, use switch-client
    tmux switch-client -t "$selected_session"
else
    # If we're not in a tmux session, attach to it
    # Check if we have proper TTY access (important for keybinding contexts)
    if [ -t 0 ] && [ -t 1 ] && [ -t 2 ]; then
        # We have proper stdin/stdout/stderr TTYs, safe to exec
        exec tmux attach-session -t "$selected_session"
    else
        # No proper TTY (likely from keybinding context)
        # Try to attach without exec first, and handle the error gracefully
        if ! tmux attach-session -t "$selected_session" 2>/dev/null; then
            # If attach fails, provide helpful instructions
            echo "Unable to attach directly due to terminal context."
            echo "To attach to session '$selected_session', run:"
            echo "  tmux attach-session -t '$selected_session'"
            echo ""
            echo "Or try running this command from a regular terminal prompt."
        fi
    fi
fi