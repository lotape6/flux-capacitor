#!/usr/bin/env bash
# check-changed-sh-files.sh
# Script to detect if any .sh files were changed in a PR or push

set -e

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
        exit 1
    fi
}

# Function to get changed files
get_changed_files() {
    local event_name="$1"
    local base_ref="$2"
    local head_sha="$3"
    local before_sha="$4"
    
    if [[ "${event_name}" == "pull_request" ]]; then
        # For pull requests
        git fetch origin "${base_ref}" --depth=1
        git diff --name-only "origin/${base_ref}...${head_sha}"
    elif [[ "${event_name}" == "push" ]]; then
        # For pushes
        if [[ -n "${before_sha}" && "${before_sha}" != "0000000000000000000000000000000000000000" ]]; then
            git diff --name-only "${before_sha}" "${head_sha}"
        else
            # If this is a fresh branch or if before_sha is not provided, list all files
            git ls-files
        fi
    else
        echo "Error: Unsupported event type: ${event_name}" >&2
        exit 1
    fi
}

# Main function
main() {
    check_dependencies
    
    # Get parameters from environment or arguments
    local event_name="${GITHUB_EVENT_NAME:-$1}"
    local base_ref="${GITHUB_BASE_REF:-$2}"
    local head_sha="${GITHUB_SHA:-$3}"
    local before_sha="${GITHUB_EVENT_BEFORE:-$4}"
    
    if [[ -z "${event_name}" ]]; then
        echo "Error: Event name not provided" >&2
        exit 1
    fi
    
    # Get changed files
    local changed_files
    changed_files=$(get_changed_files "${event_name}" "${base_ref}" "${head_sha}" "${before_sha}")
    
    echo "Changed files:"
    echo "${changed_files}"
    echo "---"
    
    # Check if any .sh files were changed
    if echo "${changed_files}" | grep -q '\.sh$'; then
        echo "true"  # At least one .sh file was found
        exit 0
    else
        echo "false" # No .sh files were changed
        exit 0
    fi
}

# Run the main function
main "$@"