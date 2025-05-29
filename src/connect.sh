#!/usr/bin/env bash
# connect.sh - Create a new tmux session with the name of the topmost directory
#
# Usage: connect.sh [-p|--pre-cmd <some cmd>] [-P|--post-cmd <some-cmd>] [-n|--session-name <name>] [-e|--env-file <path>] <path to dir>
# 
# This script creates a tmux session with the specified parameters:
# - All new panes and windows will automatically change to the target directory
# - The pre-cmd will run in all new panes and windows
# - The post-cmd will run after the session ends
# - Environment variables from env-file will be exported in all new panes

# Exit on error
set -e

# Initialize variables
pre_cmd=""
post_cmd=""
session_name=""
target_dir=""
env_file=""

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
        -e|--env-file)
            env_file="$2"
            shift 2
            ;;
        -*)
            echo "Error: Unknown option: $1"
            echo "Usage: connect.sh [-p|--pre-cmd <some cmd>] [-P|--post-cmd <some-cmd>] [-n|--session-name <name>] [-e|--env-file <path>] <path to dir>"
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
    echo "Usage: connect.sh [-p|--pre-cmd <some cmd>] [-P|--post-cmd <some-cmd>] [-n|--session-name <name>] [-e|--env-file <path>] <path to dir>"
    exit 1
fi

# Check if target directory exists
if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' does not exist"
    exit 1
fi

# Check if environment file exists (if specified)
if [ -n "$env_file" ] && [ ! -f "$env_file" ]; then
    echo "Error: Environment file '$env_file' does not exist"
    exit 1
fi

# Convert target_dir to absolute path
target_dir=$(cd "$target_dir" && pwd)

# If session name is not provided, use the name of the topmost directory with unique suffix
if [ -z "$session_name" ]; then
    base_name=$(basename "$target_dir")
    # Create unique session name using timestamp and process ID to avoid conflicts
    unique_suffix=$(date +%s)-$$
    session_name="${base_name}-${unique_suffix}"
fi

# Create a new tmux session
if command -v tmux >/dev/null 2>&1; then
    # Create a new tmux session with the unique session name
    tmux new-session -d -s "$session_name" -c "$target_dir" 2>/dev/null || true
    
    # Store the commands in tmux environment variables for this session
    tmux set-environment -t "$session_name" FLUX_TARGET_DIR "$target_dir"
    if [ -n "$pre_cmd" ]; then
        tmux set-environment -t "$session_name" FLUX_PRE_CMD "$pre_cmd"
    fi
    if [ -n "$post_cmd" ]; then
        tmux set-environment -t "$session_name" FLUX_POST_CMD "$post_cmd"
    fi
    if [ -n "$env_file" ]; then
        tmux set-environment -t "$session_name" FLUX_ENV_FILE "$env_file"
    fi
    
    # Configure hooks for pane creation and session handling
    
    # Create a pane setup hook command that changes directory, sources env file, and runs pre_cmd
    pane_setup_cmd="cd \"$target_dir\""
    if [ -n "$env_file" ]; then
        # Add command to source environment file
        pane_setup_cmd="$pane_setup_cmd; set -a; source \"$env_file\"; set +a"
    fi
    if [ -n "$pre_cmd" ]; then
        # Escape single quotes in the pre_cmd for use with tmux's single quoted string
        escaped_pre_cmd="${pre_cmd//\'/\'\\\'\'}"
        pane_setup_cmd="$pane_setup_cmd; $escaped_pre_cmd"
    fi
    
    # Set hooks to run commands when new panes are created
    tmux set-hook -t "$session_name" after-split-window "send-keys -t '$session_name' '$pane_setup_cmd' C-m"
    tmux set-hook -t "$session_name" after-new-window "send-keys -t '$session_name' '$pane_setup_cmd' C-m"
    
    # Set hook for session detachment if post-cmd exists
    if [ -n "$post_cmd" ]; then
        # Store post-cmd in a session environment variable to be used by the hook
        escaped_post_cmd="${post_cmd//\'/\'\\\'\'}"
        # Note: We don't execute post_cmd on detach because it should only run after the session truly ends
        # The post_cmd will be executed after the attach-session call returns
    fi
    
    # Set hooks for window switching to ensure consistent directory
    tmux set-hook -t "$session_name" window-pane-changed "if-shell -F \"#{pane_start_command}\" 'send-keys -t \"$session_name\" \"cd \\\"$target_dir\\\"\" C-m'"
    
    # Run the cd command, source env file, and pre_cmd in the initial pane
    tmux send-keys -t "$session_name" "cd \"$target_dir\"" C-m
    if [ -n "$env_file" ]; then
        tmux send-keys -t "$session_name" "set -a; source \"$env_file\"; set +a" C-m
    fi
    if [ -n "$pre_cmd" ]; then
        tmux send-keys -t "$session_name" "$pre_cmd" C-m
    fi
    
    # Attach to the session
    tmux switch-client -t "$session_name" 2>/dev/null || tmux attach-session -t "$session_name"
    
    # Set up post-command execution
    if [ -n "$post_cmd" ]; then
        # Execute post command after the session ends
        eval "$post_cmd"
    fi
else
    echo "Error: tmux is not installed or not in PATH"
    exit 1
fi