#!/bin/bash
# install-dependency.sh - Install a dependency using the appropriate package manager

# Detect if we're running in verbose mode (inherited from parent script)
# If FLUX_VERBOSE_MODE is not set, default to false
FLUX_VERBOSE_MODE=${FLUX_VERBOSE_MODE:-false}

# Try to find and source the error codes file
if [ -n "$CONFIG_DIR" ] && [ -f "${CONFIG_DIR}/err_codes" ]; then
    source "${CONFIG_DIR}/err_codes"
elif [ -f "$(dirname "$(dirname "$0")")/config/err_codes" ]; then
    source "$(dirname "$(dirname "$0")")/config/err_codes"
else
    # Define minimal error codes if we can't find the file
    readonly EXIT_SUCCESS=0
    readonly EXIT_NO_DEPENDENCY=20
    readonly EXIT_NO_PACKAGE_MANAGER=21
fi

# Get the dependency name from arguments
DEPENDENCY=$1

if [ -z "$DEPENDENCY" ]; then
  echo "Error: No dependency specified"
  exit ${EXIT_NO_DEPENDENCY}
fi

# Handle special cases for package names
if [[ "$DEPENDENCY" == "bat" && $(command -v apt &> /dev/null && echo "apt" || echo "") == "apt" ]]; then
  DEPENDENCY="batcat"
fi

# Detect package manager and prepare install command
PACKAGE_MANAGER=""
if command -v apt &> /dev/null; then
  PACKAGE_MANAGER="apt"
  CMD="sudo apt install -y $DEPENDENCY"
elif command -v dnf &> /dev/null; then
  PACKAGE_MANAGER="dnf"
  CMD="sudo dnf install -y $DEPENDENCY"
elif command -v yum &> /dev/null; then
  PACKAGE_MANAGER="yum"
  CMD="sudo yum install -y $DEPENDENCY"
elif command -v pacman &> /dev/null; then
  PACKAGE_MANAGER="pacman"
  CMD="sudo pacman -S --noconfirm $DEPENDENCY"
elif command -v brew &> /dev/null; then
  PACKAGE_MANAGER="brew"
  CMD="brew install $DEPENDENCY"
else
  echo "Could not detect package manager. Please install $DEPENDENCY manually."
  exit ${EXIT_NO_PACKAGE_MANAGER}
fi

# Execute the command with or without verbose output
if $FLUX_VERBOSE_MODE; then
  echo "Using $PACKAGE_MANAGER to install $DEPENDENCY"
  eval $CMD
else
  eval $CMD &>/dev/null
fi

exit ${EXIT_SUCCESS}