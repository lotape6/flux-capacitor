#!/usr/bin/env bash
# Test_CustomInstallation2.sh
# Test custom installation with same directory for config and install
# without force flag to keep configuration file

set -e

echo "Running custom installation test with same directory for config and install..."

# Define custom directory - same for both config and install
CUSTOM_DIR="/tmp/flux-capacitor-both"

# Ensure directory is clean
rm -rf "$CUSTOM_DIR"

# Run installation script with same directory for config and install
INSTALL_OUTPUT=$(../install.sh -i "$CUSTOM_DIR" -c "$CUSTOM_DIR" 2>&1)

# Check if installation script produced any output - it should be empty
if [ -n "$INSTALL_OUTPUT" ]; then
    echo "ERROR: Installation produced output when it should be silent:"
    echo "$INSTALL_OUTPUT"
    exit 1
fi

# Check if directory was properly created
if [ ! -d "$CUSTOM_DIR" ]; then
    echo "ERROR: Custom directory was not created: $CUSTOM_DIR"
    exit 1
fi

# Check for essential files
if [ ! -f "$CUSTOM_DIR/flux.conf" ]; then
    echo "ERROR: Configuration file was not installed in custom location"
    exit 1
fi

# Make sure the flux-capacitor binary exists before uninstall
if [ ! -f "$CUSTOM_DIR/flux-capacitor" ]; then
    echo "ERROR: Binary file was not installed: $CUSTOM_DIR/flux-capacitor"
    exit 1
fi

echo "Custom installation successful, now testing uninstallation without force flag..."

# Run uninstallation script without force flag and with custom directories
UNINSTALL_OUTPUT=$(../uninstall.sh -i "$CUSTOM_DIR" -c "$CUSTOM_DIR" 2>&1)

# Check if the configuration file still exists (should be kept)
if [ ! -f "$CUSTOM_DIR/flux.conf" ]; then
    echo "ERROR: Configuration file was removed when it should be kept"
    exit 1
fi

# Check if other files were removed
if [ -f "$CUSTOM_DIR/flux-capacitor" ]; then
    echo "ERROR: Program files were not removed from: $CUSTOM_DIR"
    exit 1
fi

echo "Custom installation test keeping configuration completed successfully!"
exit 0