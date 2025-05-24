#!/usr/bin/env bash

set -e

echo "Running default installation ..."

echo "Step 1: Setting up variables"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname "${SCRIPT_DIR}")"
CONFIG_FILE="${REPO_DIR}/config/flux.conf"

echo "Step 2: Sourcing configuration file: ${CONFIG_FILE}"
# Source the configuration
source "${CONFIG_FILE}"

echo "Step 3: Sourcing error codes"
# Source the error codes
source "${REPO_DIR}/config/err_codes"

echo "Step 4: Running installation script"
# Run installation script with VERBOSE_MODE flag
INSTALL_OUTPUT=$(yes | ${REPO_DIR}/install.sh)
echo $INSTALL_OUTPUT

echo "Step 5: Checking for output"
# Check if installation script produced output with VERBOSE_MODE flag
if [ -z "$INSTALL_OUTPUT" ]; then
    echo "ERROR: VERBOSE_MODE installation produced no output when it should be VERBOSE_MODE"
    exit ${EXIT_UNEXPECTED_OUTPUT}
fi

echo "Step 6: Checking if root directory was created"
# Check if files were properly installed
if [ ! -d "${FLUX_ROOT}" ]; then
    echo "ERROR: Flux root directory was not created: ${FLUX_ROOT}"
    exit ${EXIT_DIR_NOT_CREATED}
fi

echo "Step 7: Checking for configuration file"
# Check for essential files (adjust these based on actual expected files)
if [ ! -f "$FLUX_ROOT/config/flux.conf" ]; then
    echo "ERROR: Configuration file was not installed"
    exit ${EXIT_FILE_NOT_INSTALLED}
fi

echo "Step 8: Starting uninstallation"
echo "Installation successful, now testing uninstallation with VERBOSE_MODE flag..."

echo "Step 9: Running uninstallation script"
# Run uninstallation script with -f
UNINSTALL_OUTPUT=$(${REPO_DIR}/uninstall.sh -q -f)

echo "Step 10: Checking for output"
# Check if uninstallation script produced output with -f flag
if [ "$UNINSTALL_OUTPUT" ]; then
    echo "ERROR: Uninstallation produced no output when it should be VERBOSE_MODE"
    exit ${EXIT_UNEXPECTED_OUTPUT}
fi

echo "Step 11: Checking if directory was removed"
# Check if directories were properly removed
if [ -d "$FLUX_ROOT" ]; then
    echo "ERROR: Flux root directory was not removed: $FLUX_ROOT"
    exit ${EXIT_DIR_NOT_CREATED}
fi

echo "Step 12: Test completed"
echo "Default installation test with VERBOSE_MODE flag completed successfully!"
exit ${EXIT_SUCCESS}