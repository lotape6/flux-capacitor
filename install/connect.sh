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

# Change to the target directory
cd "$target_dir"

# If session name is not provided, use the name of the topmost directory
if [ -z "$session_name" ]; then
    session_name=$(basename "$PWD")
fi

# Create a new tmux session
if command -v tmux >/dev/null 2>&1; then
    # Check if pre_cmd is set and execute it
    if [ -n "$pre_cmd" ]; then
        eval "$pre_cmd"
    fi

    # Create a new tmux session with the session name
    tmux new-session -d -s "$session_name" 2>/dev/null || true
    tmux switch-client -t "$session_name" 2>/dev/null || tmux attach-session -t "$session_name"
    
    # Check if post_cmd is set and execute it after the session ends
    if [ -n "$post_cmd" ]; then
        eval "$post_cmd"
    fi
else
    echo "Error: tmux is not installed or not in PATH"
    exit 1
fi