#!/usr/bin/env bash
# session-switch.sh - Interactive tmux session switcher using fzf
#
# This script provides a command-line interface for the session switching functionality.
# The actual implementation is in session-switch-functions.sh which can be sourced
# directly by shell initialization files.

# Exit on error
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source session switching functions
if [ -f "${SCRIPT_DIR}/session-switch-functions.sh" ]; then
    source "${SCRIPT_DIR}/session-switch-functions.sh"
else
    echo "Error: session-switch-functions.sh not found"
    exit 1
fi

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

# Call the main switch_session function
switch_session