# Bash Scripting Guidelines for Code Agents

This document provides comprehensive guidelines for writing, documenting, and structuring Bash scripts that are maintainable, robust, and accessible to both human developers and code agents.

## Table of Contents

- [Coding Style](#coding-style)
- [Script Structure](#script-structure)
- [Error Handling](#error-handling)
- [Documentation](#documentation)
- [Functions and Modularity](#functions-and-modularity)
- [Variables and Parameters](#variables-and-parameters)
- [Testing and Validation](#testing-and-validation)
- [Portability](#portability)
- [Code Agent Considerations](#code-agent-considerations)
- [References](#references)

## Coding Style

### Shebang and Script Options

Always start scripts with a proper shebang and enable strict error handling:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

- `set -e`: Exit immediately if a command exits with a non-zero status
- `set -u`: Treat unset variables as an error
- `set -o pipefail`: The return value of a pipeline is the status of the last command to exit with a non-zero status

### Naming Conventions

**Variables:**
- Use `UPPERCASE` for environment variables and constants
- Use `lowercase_with_underscores` for local variables
- Use descriptive names, avoid single-letter variables (except for simple loops)

```bash
# Good
readonly CONFIG_DIR="/etc/myapp"
local user_input=""
local file_count=0

# Avoid
readonly D="/etc/myapp"
local x=""
local n=0
```

**Functions:**
- Use `lowercase_with_underscores` for function names
- Use verbs that clearly describe the action

```bash
# Good
check_dependencies() { ... }
create_backup_directory() { ... }
validate_user_input() { ... }

# Avoid
chkdep() { ... }
backup() { ... }
validate() { ... }
```

### Indentation and Formatting

- Use 4 spaces for indentation (no tabs)
- Keep lines under 80 characters when possible
- Use consistent spacing around operators and brackets

```bash
# Good
if [[ "${VERBOSE_MODE}" == "true" ]]; then
    log_message "Starting operation..."
    process_files "${input_dir}" "${output_dir}"
fi

# Avoid
if [[ "$VERBOSE_MODE"=="true" ]];then
log_message "Starting operation..."
process_files "$input_dir" "$output_dir"
fi
```

## Script Structure

### Standard Script Template

```bash
#!/usr/bin/env bash
# script_name.sh - Brief description of what the script does
#
# Usage: script_name.sh [OPTIONS] [ARGUMENTS]
# 
# Description:
#   Detailed description of the script's purpose and functionality.
#
# Options:
#   -h, --help     Show this help message
#   -v, --VERBOSE_MODE  Enable VERBOSE_MODE output
#   -c, --config   Configuration file path
#
# Examples:
#   script_name.sh -v --config config.conf
#   script_name.sh --help
#
# Author: Your Name
# Version: 1.0
# Last Modified: YYYY-MM-DD

set -euo pipefail

# Script directory and common paths
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "${0}")"

# Default configuration
readonly DEFAULT_CONFIG_DIR="${HOME}/.config/myapp"
readonly DEFAULT_LOG_LEVEL="INFO"

# Global variables (initialize with defaults)
config_dir="${DEFAULT_CONFIG_DIR}"
VERBOSE_MODE=false
log_level="${DEFAULT_LOG_LEVEL}"

# Function definitions...

# Main execution
main() {
    parse_arguments "$@"
    setup_environment
    perform_main_operations
    cleanup_and_exit
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Directory Structure for Scripts

Organize scripts logically within your project:

```
project/
├── bin/                    # Main executable scripts
├── lib/                    # Reusable function libraries
├── config/                 # Configuration files
├── test/                   # Test scripts
├── docs/                   # Documentation
└── install.sh             # Installation script
```

## Error Handling

### Exit Codes

Use meaningful exit codes and document them:

```bash
# Exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_GENERAL_ERROR=1
readonly EXIT_MISUSE=2
readonly EXIT_NO_PERMISSION=3
readonly EXIT_DEPENDENCY_MISSING=4

# Function to exit with message
die() {
    local exit_code="${1:-$EXIT_GENERAL_ERROR}"
    local message="${2:-"An error occurred"}"
    
    echo "ERROR: ${message}" >&2
    exit "${exit_code}"
}

# Usage
command -v git >/dev/null 2>&1 || die "$EXIT_DEPENDENCY_MISSING" "git is required but not installed"
```

### Trap for Cleanup

Always use traps for cleanup operations:

```bash
# Temporary file handling
readonly TEMP_DIR="$(mktemp -d)"
readonly TEMP_FILE="${TEMP_DIR}/temp_file"

# Cleanup function
cleanup() {
    local exit_code=$?
    
    if [[ -d "${TEMP_DIR}" ]]; then
        rm -rf "${TEMP_DIR}"
    fi
    
    exit "${exit_code}"
}

# Set trap for cleanup
trap cleanup EXIT INT TERM
```

### Input Validation

Always validate inputs and handle edge cases:

```bash
validate_file_path() {
    local file_path="${1:-}"
    
    if [[ -z "${file_path}" ]]; then
        die "$EXIT_MISUSE" "File path cannot be empty"
    fi
    
    if [[ ! -f "${file_path}" ]]; then
        die "$EXIT_GENERAL_ERROR" "File does not exist: ${file_path}"
    fi
    
    if [[ ! -r "${file_path}" ]]; then
        die "$EXIT_NO_PERMISSION" "File is not readable: ${file_path}"
    fi
}
```

## Documentation

### Inline Comments

- Comment the "why", not the "what"
- Use comments to explain complex logic or business rules
- Update comments when code changes

```bash
# Good: Explains why this approach is used
# Use a temporary directory to avoid conflicts with existing files
# during the atomic operation
readonly TEMP_DIR="$(mktemp -d)"

# Avoid: States the obvious
# Create a temporary directory
readonly TEMP_DIR="$(mktemp -d)"
```

### Function Documentation

Document all functions with their purpose, parameters, and return values:

```bash
# Processes log files and extracts error messages
# 
# Arguments:
#   $1 - Log file path (required)
#   $2 - Output file path (optional, defaults to stdout)
#   $3 - Log level filter (optional, defaults to "ERROR")
# 
# Returns:
#   0 - Success
#   1 - Log file not found
#   2 - Permission denied
#
# Examples:
#   extract_errors "/var/log/app.log"
#   extract_errors "/var/log/app.log" "/tmp/errors.txt" "WARN"
extract_errors() {
    local log_file="${1:-}"
    local output_file="${2:-/dev/stdout}"
    local log_level="${3:-ERROR}"
    
    # Function implementation...
}
```

### Help Messages

Provide comprehensive help messages:

```bash
show_help() {
    cat << EOF
Usage: ${SCRIPT_NAME} [OPTIONS] [ARGUMENTS]

Description:
    Detailed description of what the script accomplishes and its main use cases.

Options:
    -h, --help              Show this help message and exit
    -v, --VERBOSE_MODE           Enable VERBOSE_MODE output
    -c, --config FILE       Use specified configuration file
    -o, --output DIR        Set output directory (default: current directory)
    -n, --dry-run          Show what would be done without executing
    
Arguments:
    INPUT_FILE             Input file to process (required)
    
Examples:
    ${SCRIPT_NAME} input.txt
    ${SCRIPT_NAME} -v --config custom.conf input.txt
    ${SCRIPT_NAME} --dry-run --output /tmp input.txt

Environment Variables:
    MYAPP_CONFIG_DIR       Override default configuration directory
    MYAPP_LOG_LEVEL        Set logging level (DEBUG, INFO, WARN, ERROR)

Exit Codes:
    0    Success
    1    General error
    2    Invalid arguments
    3    Permission denied
    4    Dependency missing

For more information, see the documentation at: https://example.com/docs
EOF
}
```

## Functions and Modularity

### Single Responsibility Principle

Each function should have one clear responsibility:

```bash
# Good: Single, clear purpose
check_git_repository() {
    local repo_dir="${1:-$(pwd)}"
    
    if [[ ! -d "${repo_dir}/.git" ]]; then
        return 1
    fi
    
    return 0
}

# Avoid: Multiple responsibilities
setup_everything() {
    check_dependencies
    create_directories  
    copy_files
    set_permissions
    start_services
}
```

### Parameter Passing

Pass parameters explicitly rather than relying on global variables:

```bash
# Good: Explicit parameters
process_file() {
    local input_file="${1}"
    local output_dir="${2}"
    local options="${3:-}"
    
    # Process the file...
}

# Avoid: Implicit global variables
process_file() {
    # Uses global INPUT_FILE, OUTPUT_DIR, OPTIONS
    # Makes testing and reuse difficult
}
```

### Library Functions

Create reusable function libraries:

```bash
# lib/logging.sh
log_debug() { [[ "${LOG_LEVEL}" == "DEBUG" ]] && echo "[DEBUG] $*" >&2; }
log_info()  { echo "[INFO] $*" >&2; }
log_warn()  { echo "[WARN] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

# lib/file_utils.sh
ensure_directory() {
    local dir="${1}"
    
    if [[ ! -d "${dir}" ]]; then
        mkdir -p "${dir}" || die "Failed to create directory: ${dir}"
    fi
}

# Source libraries in main script
source "${SCRIPT_DIR}/lib/logging.sh"
source "${SCRIPT_DIR}/lib/file_utils.sh"
```

## Variables and Parameters

### Quoting and Variable Expansion

Always quote variables and use proper expansion:

```bash
# Good: Proper quoting
local file_name="${1}"
if [[ -f "${file_name}" ]]; then
    cp "${file_name}" "${backup_dir}/"
fi

# Avoid: Unquoted variables (vulnerable to word splitting)
local file_name=$1
if [[ -f $file_name ]]; then
    cp $file_name $backup_dir/
fi
```

### Parameter Substitution

Use parameter substitution for defaults and validation:

```bash
# Provide defaults
local config_file="${1:-${DEFAULT_CONFIG_FILE}}"
local timeout="${TIMEOUT:-30}"

# Require parameters
local required_param="${1:?Error: Required parameter missing}"

# Check if variable is set
if [[ -z "${REQUIRED_VAR:-}" ]]; then
    die "REQUIRED_VAR environment variable must be set"
fi
```

### Arrays

Use arrays for collections of related data:

```bash
# Declare and populate arrays
declare -a files_to_process=()
declare -A config_options=()

# Add elements
files_to_process+=("file1.txt")
files_to_process+=("file2.txt")

config_options["timeout"]="30"
config_options["retries"]="3"

# Iterate over arrays
for file in "${files_to_process[@]}"; do
    process_file "${file}"
done

for key in "${!config_options[@]}"; do
    echo "${key}: ${config_options[${key}]}"
done
```

## Testing and Validation

### Unit Testing

Create testable functions and test them:

```bash
# test/test_utils.sh
#!/usr/bin/env bash

source "../lib/file_utils.sh"

test_ensure_directory() {
    local test_dir="/tmp/test_$$"
    
    # Test: Directory creation
    ensure_directory "${test_dir}"
    
    if [[ ! -d "${test_dir}" ]]; then
        echo "FAIL: Directory was not created"
        return 1
    fi
    
    # Cleanup
    rmdir "${test_dir}"
    echo "PASS: ensure_directory creates missing directory"
}

# Run tests
test_ensure_directory
```

### Validation Functions

Create functions to validate common inputs:

```bash
validate_email() {
    local email="${1}"
    local email_regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    
    if [[ ! "${email}" =~ ${email_regex} ]]; then
        return 1
    fi
    
    return 0
}

validate_url() {
    local url="${1}"
    
    if ! curl -s --head "${url}" > /dev/null 2>&1; then
        return 1
    fi
    
    return 0
}
```

## Portability

### POSIX Compatibility

When possible, use POSIX-compatible constructs:

```bash
# POSIX-compatible
if [ -f "${file}" ]; then
    echo "File exists"
fi

# Bash-specific (when bash features are needed)
if [[ "${string}" =~ ${regex} ]]; then
    echo "Pattern matches"
fi
```

### Command Availability

Check for required commands before using them:

```bash
check_dependencies() {
    local missing_commands=()
    
    for cmd in git curl jq; do
        if ! command -v "${cmd}" >/dev/null 2>&1; then
            missing_commands+=("${cmd}")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        die "Missing required commands: ${missing_commands[*]}"
    fi
}
```

### Platform Differences

Handle platform-specific differences gracefully:

```bash
get_os_type() {
    case "$(uname -s)" in
        Linux*)     echo "linux" ;;
        Darwin*)    echo "macos" ;;
        CYGWIN*)    echo "windows" ;;
        MINGW*)     echo "windows" ;;
        *)          echo "unknown" ;;
    esac
}

# Platform-specific commands
if [[ "$(get_os_type)" == "macos" ]]; then
    # macOS-specific implementation
    date -r "${timestamp}"
else
    # Linux/GNU implementation
    date -d "@${timestamp}"
fi
```

## Code Agent Considerations

### Clear Structure for AI Analysis

Structure code in a way that makes it easy for code agents to understand:

```bash
# Use clear, descriptive names that indicate purpose
validate_configuration_file() { ... }
download_and_verify_package() { ... }
create_secure_temporary_directory() { ... }

# Group related functionality
# === CONFIGURATION MANAGEMENT ===
load_configuration() { ... }
validate_configuration() { ... }
save_configuration() { ... }

# === FILE OPERATIONS ===
backup_existing_files() { ... }
copy_new_files() { ... }
restore_on_failure() { ... }
```

### Comprehensive Documentation

Provide context that helps code agents understand the codebase:

```bash
# This script automates the deployment process for the Flux Capacitor project.
# It handles:
# 1. Environment validation and dependency checking
# 2. Configuration backup and update
# 3. Service stop/start cycle with rollback capability
# 4. Health checks and verification
#
# The script is designed to be idempotent - running it multiple times
# should produce the same result without negative side effects.
#
# Integration points:
# - Reads configuration from: ${CONFIG_DIR}/flux.conf
# - Logs operations to: ${LOG_DIR}/deployment.log
# - Sends notifications via: webhook defined in config
# - Stores backups in: ${BACKUP_DIR}/YYYY-MM-DD-HHMMSS/
```

### Consistent Patterns

Use consistent patterns throughout the codebase:

```bash
# Standard error handling pattern
perform_operation() {
    local operation_name="${1}"
    
    log_info "Starting ${operation_name}..."
    
    if ! execute_operation; then
        log_error "Failed to complete ${operation_name}"
        return 1
    fi
    
    log_info "Successfully completed ${operation_name}"
    return 0
}

# Standard validation pattern
validate_input() {
    local input="${1}"
    local input_name="${2:-input}"
    
    if [[ -z "${input}" ]]; then
        die "ERROR: ${input_name} cannot be empty"
    fi
    
    # Additional validation...
}
```

### Machine-Readable Output

When appropriate, provide structured output for automation:

```bash
# Support both human and machine-readable output
output_results() {
    local format="${1:-human}"
    
    case "${format}" in
        json)
            jq -n --arg status "success" --arg files "$files_processed" \
               '{status: $status, files_processed: ($files | tonumber)}'
            ;;
        human)
            echo "Operation completed successfully!"
            echo "Files processed: ${files_processed}"
            ;;
        *)
            die "Unsupported output format: ${format}"
            ;;
    esac
}
```

## References

- [Google Bash Style Guide](https://google.github.io/styleguide/shellguide.html)
- [Bash best practices - cheat-sheets](https://bertvv.github.io/cheat-sheets/Bash.html)
- [10 Best Practices for Bash Scripting](https://infotechys.com/10-best-practices-for-bash-scripting/)
- [A Practical Guide to Writing Better Bash Scripts](https://dev.to/mdarifulhaque/a-practical-guide-to-writing-better-bash-scripts-3mma)
- [ShellCheck - A shell script static analysis tool](https://www.shellcheck.net/)
- [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/)
- [Bash Hackers Wiki](https://wiki.bash-hackers.org/)

---

*These guidelines are designed to help create maintainable, robust, and AI-agent-friendly Bash scripts. They should be adapted to fit the specific needs of your project while maintaining consistency across the codebase.*