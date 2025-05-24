#!/usr/bin/env bash

set -e

echo "Running default installation ..."

CONFIG_FILE="$(./install/find-config.sh)"
# Source the configuration
source "${CONFIG_FILE}"

# Source the error codes
if [ -f "${CONFIG_DIR}/err_codes" ]; then
    source "${CONFIG_DIR}/err_codes"
else
    source "$(dirname "$(dirname "$0")")/config/err_codes"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Run installation script with VERBOSE_MODE flag
INSTALL_OUTPUT=$(yes | ${SCRIPT_DIR}/../install.sh)
echo $INSTALL_OUTPUT
# Check if installation script produced output with VERBOSE_MODE flag
if [ -z "$INSTALL_OUTPUT" ]; then
    echo "ERROR: VERBOSE_MODE installation produced no output when it should be VERBOSE_MODE"
    exit ${EXIT_UNEXPECTED_OUTPUT}
fi

# Check if files were properly installed

if [ ! -d "${FLUX_INSTALLATION_DIR}" ]; then
    echo "ERROR: Installation directory was not created: ${FLUX_INSTALLATION_DIR}"
    exit ${EXIT_DIR_NOT_CREATED}
fi

if [ ! -d "${FLUX_CONFIG_DIR}" ]; then
    echo "ERROR: Configuration directory was not created: ${FLUX_CONFIG_DIR}"
    exit ${EXIT_DIR_NOT_CREATED}
fi

# Check for essential files (adjust these based on actual expected files)
if [ ! -f "$FLUX_CONFIG_DIR/flux.conf" ]; then
    echo "ERROR: Configuration file was not installed"
    exit ${EXIT_FILE_NOT_INSTALLED}
fi

echo "Installation successful, now testing uninstallation with VERBOSE_MODE flag..."

# Run uninstallation script with -f
INSTALL_OUTPUT=$(${SCRIPT_DIR}/../uninstall.sh -q -f)

# Check if uninstallation script produced output with -f flag
if [ "$UNINSTALL_OUTPUT" ]; then
    echo "ERROR: Uninstallation produced no output when it should be VERBOSE_MODE"
    exit ${EXIT_UNEXPECTED_OUTPUT}
fi

# Check if directories were properly removed
if [ -d "$FLUX_INSTALLATION_DIR" ]; then
    echo "ERROR: Installation directory was not removed: $FLUX_INSTALLATION_DIR"
    exit ${EXIT_DIR_NOT_CREATED}
fi

if [ -d "$FLUX_CONFIG_DIR" ]; then
    echo "ERROR: Configuration directory was not removed: $FLUX_CONFIG_DIR"
    exit ${EXIT_DIR_NOT_CREATED}
fi

echo "Default installation test with VERBOSE_MODE flag completed successfully!"
exit ${EXIT_SUCCESS}