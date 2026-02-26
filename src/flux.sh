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
    echo "  connect        Create or attach to a tmux session"
    echo "  session-switch Interactive tmux session switcher"
    echo "  launch         Launch a tmux session from a .flux.yml config file"
    echo "  save           Save current session layout to a .flux.yml file"
    echo "  restore        Restore a session from a .flux.yml file (alias: launch)"
    echo "  list           List all active tmux sessions"
    echo "  kill           Kill a tmux session"
    echo "  rename         Rename a tmux session"
    echo "  clean          Kill all sessions and reset the tmux server"
    echo "  help           Show this help message"
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
    session-switch)
        "${SCRIPT_DIR}/session-switch.sh" "$@"
        ;;
    launch)
        # Launch a tmux session from a .flux.yml config file
        "${SCRIPT_DIR}/launch.sh" "$@"
        ;;
    save)
        "${SCRIPT_DIR}/save.sh" "$@"
        ;;
    restore)
        "${SCRIPT_DIR}/restore.sh" "$@"
        ;;
    list)
        "${SCRIPT_DIR}/list.sh" "$@"
        ;;
    kill)
        "${SCRIPT_DIR}/kill.sh" "$@"
        ;;
    rename)
        "${SCRIPT_DIR}/rename.sh" "$@"
        ;;
    clean)
        "${SCRIPT_DIR}/clean.sh" "$@"
        ;;
    help)
        if [ -n "${1:-}" ]; then
            "${SCRIPT_DIR}/${1}.sh" --help 2>/dev/null || echo "No help available for '$1'"
        else
            show_help
        fi
        ;;
    *)
        echo "Error: Unknown command '${command}'"
        show_help
        exit 1
        ;;
esac
