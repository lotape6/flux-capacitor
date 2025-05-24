#!/usr/bin/env bash
# flux.sh - Main CLI for flux-capacitor
#
# This script serves as the main entry point for flux-capacitor commands
# and redirects to the appropriate scripts based on the command.

# Exit on error
set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Display help message
show_help() {
    echo "Usage: flux <command> [options]"
    echo
    echo "Commands:"
    echo "  connect     Create a new tmux session"
    echo "  launch      Check if a file is a valid YAML"
    echo "  clean       Reset the tmux server"
    echo "  help        Show this help message"
    echo
}

# Check if a command was provided
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Handle commands
command=$1
shift  # Remove the first argument (the command)

case "${command}" in
    connect)
        "${SCRIPT_DIR}/connect.sh" "$@"
        ;;
    launch)
        "${SCRIPT_DIR}/launch.sh" "$@"
        ;;
    clean)
        "${SCRIPT_DIR}/clean.sh" "$@"
        ;;
    help)
        show_help
        ;;
    *)
        echo "Error: Unknown command '${command}'"
        show_help
        exit 1
        ;;
esac