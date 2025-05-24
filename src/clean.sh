#!/usr/bin/env bash
# clean.sh - Reset the tmux server
#
# Usage: clean.sh

# Exit on error
set -e

# Check if tmux is installed
if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux is not installed or not in PATH"
    exit 1
fi

# Reset the tmux server
echo "Resetting tmux server..."
tmux kill-server 2>/dev/null || true
echo "tmux server has been reset."