#!/usr/bin/env bash
# connect.sh - Create a new tmux session with the name of the topmost directory
#
# Usage: connect.sh [-p|--pre-cmd <some cmd>] [-P|--post-cmd <some-cmd>] [-n|--session-name <name>] <path to dir>

# Exit on error
set -e

# Initialize variables
pre_cmd=""
post_cmd=""
session_name=""
target_dir=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--pre-cmd)
            pre_cmd="$2"
            shift 2
            ;;
        -P|--post-cmd)
            post_cmd="$2"
            shift 2
            ;;
        -n|--session-name)
            session_name="$2"
            shift 2
            ;;
        -*)
            echo "Error: Unknown option: $1"
            echo "Usage: connect.sh [-p|--pre-cmd <some cmd>] [-P|--post-cmd <some-cmd>] [-n|--session-name <name>] <path to dir>"
            exit 1
            ;;
        *)
            target_dir="$1"
            shift
            ;;
    esac
done

# Check if target directory is provided
if [ -z "$target_dir" ]; then
    echo "Error: No target directory specified"
    echo "Usage: connect.sh [-p|--pre-cmd <some cmd>] [-P|--post-cmd <some-cmd>] [-n|--session-name <name>] <path to dir>"
    exit 1
fi

# Check if target directory exists
if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' does not exist"
    exit 1
fi

# Convert target_dir to absolute path
target_dir=$(cd "$target_dir" && pwd)

# If session name is not provided, use the name of the topmost directory
if [ -z "$session_name" ]; then
    session_name=$(basename "$target_dir")
fi

# Create a new tmux session
if command -v tmux >/dev/null 2>&1; then
    # Check if session already exists
    if tmux has-session -t "$session_name" 2>/dev/null; then
        # If session exists, attach to it
        tmux switch-client -t "$session_name" 2>/dev/null || tmux attach-session -t "$session_name"
        exit 0
    fi
    
    # Create a new tmux session with the session name
    tmux new-session -d -s "$session_name" -c "$target_dir" 2>/dev/null || true
    
    # Store the commands in tmux environment variables for this session
    tmux set-environment -t "$session_name" FLUX_TARGET_DIR "$target_dir"
    if [ -n "$pre_cmd" ]; then
        tmux set-environment -t "$session_name" FLUX_PRE_CMD "$pre_cmd"
    fi
    if [ -n "$post_cmd" ]; then
        tmux set-environment -t "$session_name" FLUX_POST_CMD "$post_cmd"
    fi
    
    # Create custom tmux commands for this session
    
    # Set default-command to execute cd and pre_cmd for each new pane/window
    cmd_string="cd \"$target_dir\"; "
    if [ -n "$pre_cmd" ]; then
        # Escape any double quotes in the pre_cmd
        escaped_pre_cmd="${pre_cmd//\"/\\\"}"
        cmd_string="$escaped_pre_cmd; $cmd_string"
    fi
    cmd_string="${cmd_string}exec \$SHELL"
    
    # Set the default-command for all panes in this session
    tmux set-option -t "$session_name" default-command "$cmd_string"
    
    # Run the pre_cmd in the initial pane
    if [ -n "$pre_cmd" ]; then
        # No need to escape here as send-keys handles raw commands
        tmux send-keys -t "$session_name" "$pre_cmd" C-m
    fi
    
    # Attach to the session
    tmux switch-client -t "$session_name" 2>/dev/null || tmux attach-session -t "$session_name"
    
    # Check if post_cmd is set and execute it after the session ends
    if [ -n "$post_cmd" ]; then
        eval "$post_cmd"
    fi
else
    echo "Error: tmux is not installed or not in PATH"
    exit 1
fi