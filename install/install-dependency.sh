#!/bin/bash

# Install dependency using the appropriate package manager
# Usage: install-dependency.sh [dependency]

# Detect if we're running in verbose mode (inherited from parent script)
# If FLUX_VERBOSE_MODE is not set, default to false
FLUX_VERBOSE_MODE=${FLUX_VERBOSE_MODE:-false}

# Get the dependency name from arguments
DEPENDENCY=$1

if [ -z "$DEPENDENCY" ]; then
  echo "Error: No dependency specified"
  exit 1
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
  exit 1
fi

# Execute the command with or without verbose output
if $FLUX_VERBOSE_MODE; then
  echo "Using $PACKAGE_MANAGER to install $DEPENDENCY"
  eval $CMD
else
  eval $CMD &>/dev/null
fi

exit 0