#!/usr/bin/env bash
# check-changed-sh-files.sh
# Script to detect if any .sh files were changed in a PR or push

set -e

# Try to find and source the error codes file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

if [ -f "${REPO_ROOT}/config/err.codes" ]; then
    source "${REPO_ROOT}/config/err.codes"
else
    # Define minimal error codes if we can't find the file
    readonly EXIT_SUCCESS=0
    readonly EXIT_DEPENDENCY_MISSING=4
fi

# Function to check for dependencies
check_dependencies() {
    local missing_commands=()
    
    for cmd in git; do
        if ! command -v "${cmd}" > /dev/null 2>&1; then
            missing_commands+=("${cmd}")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        echo "Error: Missing required commands: ${missing_commands[*]}" >&2
        exit ${EXIT_DEPENDENCY_MISSING}
    fi
}

# Function to get changed files in a PR
get_pr_changed_files() {
    local base_ref="$1"
    
    # Safely fetch the base branch
    if [[ -n "${base_ref}" ]]; then
        git fetch origin "${base_ref}" --depth=1 || true
        git diff --name-only "origin/${base_ref}" HEAD || git ls-files
    else
        # Fallback to listing all files if base_ref is not available
        git ls-files
    fi
}

# Function to get changed files in a push
get_push_changed_files() {
    local before_sha="$1"
    
    # If before_sha is available and valid, use it to find changed files
    if [[ -n "${before_sha}" && "${before_sha}" != "0000000000000000000000000000000000000000" ]]; then
        git diff --name-only "${before_sha}" HEAD || git ls-files
    else
        # Fallback to listing all files
        git ls-files
    fi
}

# Main function
main() {
    check_dependencies
    
    # Get parameters from environment or arguments
    local event_name="${GITHUB_EVENT_NAME:-$1}"
    local base_ref="${GITHUB_BASE_REF:-$2}"
    local before_sha="${GITHUB_EVENT_BEFORE:-$3}"
    
    echo "Event: ${event_name}"
    
    # Get changed files based on event type
    local changed_files
    if [[ "${event_name}" == "pull_request" ]]; then
        changed_files=$(get_pr_changed_files "${base_ref}")
    elif [[ "${event_name}" == "push" ]]; then
        changed_files=$(get_push_changed_files "${before_sha}")
    else
        echo "Warning: Unsupported event type: ${event_name}" >&2
        # Default to listing all files as a fallback
        changed_files=$(git ls-files)
    fi
    
    echo "Changed files:"
    echo "${changed_files}"
    echo "---"
    
    # Check if any .sh files were changed
    if echo "${changed_files}" | grep -q '\.sh$'; then
        echo "true"  # At least one .sh file was found
        exit ${EXIT_SUCCESS}
    else
        echo "false" # No .sh files were changed
        exit ${EXIT_SUCCESS}
    fi
}

# Run the main function
main "$@"