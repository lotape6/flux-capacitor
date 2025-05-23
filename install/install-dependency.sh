#!/bin/bash

# Install dependency using the appropriate package manager
# Usage: install-dependency.sh [dependency]

# Detect if we're running in verbose mode (inherited from parent script)
# If VERBOSE is not set, default to false
VERBOSE=${VERBOSE:-false}

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

# Detect package manager and install
if command -v apt &> /dev/null; then
  CMD="sudo apt update && sudo apt install -y $DEPENDENCY"
  if $VERBOSE; then
    echo "Using apt to install $DEPENDENCY"
    eval $CMD
  else
    eval $CMD &>/dev/null
  fi
elif command -v dnf &> /dev/null; then
  CMD="sudo dnf install -y $DEPENDENCY"
  if $VERBOSE; then
    echo "Using dnf to install $DEPENDENCY"
    eval $CMD
  else
    eval $CMD &>/dev/null
  fi
elif command -v yum &> /dev/null; then
  CMD="sudo yum install -y $DEPENDENCY"
  if $VERBOSE; then
    echo "Using yum to install $DEPENDENCY"
    eval $CMD
  else
    eval $CMD &>/dev/null
  fi
elif command -v pacman &> /dev/null; then
  CMD="sudo pacman -S --noconfirm $DEPENDENCY"
  if $VERBOSE; then
    echo "Using pacman to install $DEPENDENCY"
    eval $CMD
  else
    eval $CMD &>/dev/null
  fi
elif command -v brew &> /dev/null; then
  CMD="brew install $DEPENDENCY"
  if $VERBOSE; then
    echo "Using brew to install $DEPENDENCY"
    eval $CMD
  else
    eval $CMD &>/dev/null
  fi
else
  echo "Could not detect package manager. Please install $DEPENDENCY manually."
  exit 1
fi

exit 0