#!/usr/bin/env bash
# session-switch-functions.sh - Interactive tmux session switcher using fzf (function library)
#
# This library provides functions for switching between existing tmux sessions
# using fzf with emojis and fancy formatting. These functions are meant to be sourced
# by shell initialization files and bound to keyboard shortcuts.

# Check if tmux is installed
_check_tmux_available() {
    if ! command -v tmux >/dev/null 2>&1; then
        echo "Error: tmux is not installed or not in PATH"
        return 1
    fi
    return 0
}

# Check if fzf is installed
_check_fzf_available() {
    if ! command -v fzf >/dev/null 2>&1; then
        echo "Error: fzf is not installed or not in PATH"
        echo "Please install fzf to use session switching functionality"
        return 1
    fi
    return 0
}

tmux_print(){
    if [ -n "${1:-}" ]; then
        # Show a temporary popup message for 2 seconds if supported (tmux >= 3.2)
        local tmux_major tmux_minor
        tmux_major=$(tmux -V 2>/dev/null | grep -oE '[0-9]+' | head -1)
        tmux_minor=$(tmux -V 2>/dev/null | grep -oE '[0-9]+' | sed -n '2p')
        if [ "${tmux_major:-0}" -gt 3 ] || { [ "${tmux_major:-0}" -eq 3 ] && [ "${tmux_minor:-0}" -ge 2 ]; }; then
            tmux display-popup -E "echo '$1'; sleep 2"
        else
            tmux display-message "$1"
        fi
    fi
}

# Format existing sessions for display with emojis and fancy formatting
# Output format: SESSION_NAME<TAB>DISPLAY_LINE
format_existing_sessions() {
    local sessions="$1"
    local current_session="$2"
    local session_name
    local session_windows
    local session_attached
    local session_path
    local emoji
    local status_emoji
    local display_line

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

        # Format the display line — tab-separated: name<TAB>display
        display_line="${status_emoji} ${emoji} ${session_name} (${session_windows} windows) 📍 ${session_path}"
        printf '%s\t%s\n' "${session_name}" "${display_line}"
    done
}

# Select a session using fzf
# Input lines are tab-separated: SESSION_NAME<TAB>DISPLAY
# Returns the full tab-separated line of the selection
select_session() {
    local formatted_sessions="$1"

    echo "$formatted_sessions" | fzf \
        --height=40% \
        --reverse \
        --border \
        --with-nth=2 \
        --delimiter='\t' \
        --prompt="🔄 Select session to switch to: " \
        --header="🎯 Use Alt+S to switch sessions | ESC to cancel" \
        --preview-window="right:50%" \
        --preview="tmux list-windows -t {1} -F '  #{window_index}: #{window_name} #{?window_active,(active),} — #{pane_current_path}' 2>/dev/null || echo 'No details available'" \
        --bind="alt-s:accept" \
        --color="header:italic:cyan,prompt:bold:blue,pointer:red,marker:yellow" \
        2>/dev/null || true
}

# Main session switching function
switch_session() {
    # Check tmux first (always required)
    if ! _check_tmux_available; then
        return 1
    fi

    # Get list of sessions before checking fzf — if empty, fzf isn't needed
    local sessions
    sessions=$(tmux list-sessions -F "#{session_name}:#{session_windows}:#{session_attached}:#{pane_current_path}" 2>/dev/null || true)

    if [ -z "$sessions" ]; then
        echo "No tmux sessions found."
        echo "Create a new session with: flux connect <directory>"
        return 0
    fi

    # Only require fzf if there are sessions to switch between
    if ! _check_fzf_available; then
        return 1
    fi
    
    # Check if we're currently inside a tmux session
    local current_session=""
    if [ -n "${TMUX:-}" ]; then
        current_session=$(tmux display-message -p '#S' 2>/dev/null || true)
    fi
    
    # Format sessions for display
    local formatted_sessions
    formatted_sessions=$(format_existing_sessions "$sessions" "$current_session")
    
    # Use fzf to select a session
    local selected_line
    selected_line=$(select_session "$formatted_sessions")
    
    # Check if user cancelled selection
    if [ -z "$selected_line" ]; then
        tmux_print "Session switching cancelled."
        return 0
    fi
    
    # Extract session name from tab-delimited line (field 1)
    local selected_session
    selected_session=$(echo "$selected_line" | cut -f1)
    
    # Validate that the session still exists
    if ! tmux has-session -t "$selected_session" 2>/dev/null; then
        tmux_print "Error: Session '$selected_session' no longer exists"
        return 1
    fi
    
    # Check if we're trying to switch to the current session
    if [ "$selected_session" = "$current_session" ]; then
        tmux_print "🌟 Already attached to session '$current_session'"
    fi
    
    tmux_print "Switching to session $selected_session..."
    
    # Switch to the selected session
    if [ -n "$current_session" ]; then
        # If we're in a tmux session, use switch-client
        tmux switch-client -t "$selected_session"
    else
        # If we're not in a tmux session, attach to it
        tmux attach-session -t "$selected_session"
    fi
}