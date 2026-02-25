#!/usr/bin/env bash
# launch.sh - Check if a file is a valid YAML
#
# Usage: launch.sh <some-file>

# Exit on error
set -e

# Display help message
show_help() {
    echo "Usage: launch.sh <some-file>"
    echo
    echo "Check if the provided file is a valid YAML file."
    echo
}

# Check if a file was provided
if [ $# -eq 0 ]; then
    echo "Error: No file specified"
    show_help
    exit 1
fi

file_path="$1"

# Check if file exists
if [ ! -f "$file_path" ]; then
    echo "Error: File '$file_path' does not exist"
    exit 1
fi

# Check if the file is a valid YAML
# We can do this by trying to parse it with a YAML parser
# For basic validation, we can use Python if available
if command -v python3 >/dev/null 2>&1; then
    if python3 -c "import yaml, sys; yaml.safe_load(sys.stdin)" < "$file_path" 2>/dev/null; then
        echo "File '$file_path' is a valid YAML file"
        exit 0
    else
        echo "Error: File '$file_path' is not a valid YAML file"
        exit 1
    fi
elif command -v python >/dev/null 2>&1; then
    if python -c "import yaml, sys; yaml.safe_load(sys.stdin)" < "$file_path" 2>/dev/null; then
        echo "File '$file_path' is a valid YAML file"
        exit 0
    else
        echo "Error: File '$file_path' is not a valid YAML file"
        exit 1
    fi
else
    echo "Warning: Python with PyYAML is not installed or not in PATH, cannot validate YAML"
    echo "Checking if file has YAML extension as a basic check"
    if [[ "$file_path" == *.yml ]] || [[ "$file_path" == *.yaml ]]; then
        echo "File '$file_path' has a YAML extension"
        exit 0
    else
        echo "Warning: File '$file_path' does not have a YAML extension"
        exit 1
    fi
fi