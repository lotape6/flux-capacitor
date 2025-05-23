#!/usr/bin/env bash
# install.sh - Installs flux-capacitor

set -e

# Default directories
INSTALL_DIR="$HOME/.local/share/flux-capacitor"
CONFIG_DIR="$HOME/.config/flux-capacitor"
VERBOSE=false

# Parse command line arguments
while getopts "i:c:vf" opt; do
  case $opt in
    i)
      INSTALL_DIR="$OPTARG"
      ;;
    c)
      CONFIG_DIR="$OPTARG"
      ;;
    v)
      VERBOSE=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Create directories
if $VERBOSE; then
  echo "Creating installation directory: $INSTALL_DIR"
  mkdir -p "$INSTALL_DIR"
  echo "Creating configuration directory: $CONFIG_DIR"
  mkdir -p "$CONFIG_DIR"
else
  mkdir -p "$INSTALL_DIR"
  mkdir -p "$CONFIG_DIR"
fi

# Create placeholder files for testing
if $VERBOSE; then
  echo "Installing files..."
  echo "Installing flux-capacitor to $INSTALL_DIR/flux-capacitor"
  echo "#!/bin/sh" > "$INSTALL_DIR/flux-capacitor"
  echo "echo 'Flux Capacitor v1.0'" >> "$INSTALL_DIR/flux-capacitor"
  chmod +x "$INSTALL_DIR/flux-capacitor"
  
  echo "Installing configuration to $CONFIG_DIR/flux.conf"
  echo "# Flux Capacitor Configuration" > "$CONFIG_DIR/flux.conf"
  echo "POWER_LEVEL=1.21" >> "$CONFIG_DIR/flux.conf"
else
  echo "#!/bin/sh" > "$INSTALL_DIR/flux-capacitor"
  echo "echo 'Flux Capacitor v1.0'" >> "$INSTALL_DIR/flux-capacitor"
  chmod +x "$INSTALL_DIR/flux-capacitor"
  
  echo "# Flux Capacitor Configuration" > "$CONFIG_DIR/flux.conf"
  echo "POWER_LEVEL=1.21" >> "$CONFIG_DIR/flux.conf"
fi

if $VERBOSE; then
  echo "Installation completed successfully!"
fi

exit 0