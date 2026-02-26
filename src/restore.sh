#!/usr/bin/env bash
# restore.sh - Restore a tmux session from a .flux.yml config file
#
# Usage: restore.sh [config-file]
#
# This is a semantic alias for 'flux launch'. It looks for .flux.yml in
# the current directory if no file is given.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_help() {
    echo "Usage: flux restore [config-file]"
    echo
    echo "Restore a tmux session from a .flux.yml config file."
    echo "If no file is given, looks for .flux.yml in the current directory."
    echo
    echo "This is equivalent to: flux launch [config-file]"
    echo
    echo "Options:"
    echo "  --force, -f    Force new session even if one already exists"
    echo "  --help, -h     Show this help message"
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    show_help; exit 0
fi

# Delegate entirely to launch.sh
exec "${SCRIPT_DIR}/launch.sh" "$@"
