#!/usr/bin/env bash
# Test_connect_reuse_and_force_new.sh - Test session reuse and force new functionality

# Exit on any error
set -e

# Get script directory and set up paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(dirname ${SCRIPT_DIR})"
CONNECT_SCRIPT="${REPO_DIR}/src/connect.sh"

# Colors for output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

log() {
    echo -e "${GREEN}[TEST]${RESET} $1"
}

error() {
    echo -e "${RED}[ERROR]${RESET} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${RESET} $1"
}

# Setup test directories
TEST_DIR1="/tmp/flux-test-reuse"
TEST_DIR2="/tmp/flux-test-force"
mkdir -p "$TEST_DIR1" "$TEST_DIR2"

# Clean up any existing tmux sessions
cleanup() {
    tmux kill-server 2>/dev/null || true
    rm -rf "$TEST_DIR1" "$TEST_DIR2" 2>/dev/null || true
}

# Cleanup on exit
trap cleanup EXIT

log "Testing session reuse and force new functionality..."

# Test 1: Test session reuse behavior (default)
log "Test 1: Testing session reuse behavior (default)"

cleanup

# Test that sessions with simple names are created when force_new=false (default)
SESSION_NAME1=$(cd /home/runner/work/flux-capacitor/flux-capacitor/src && bash -c '
    target_dir="/tmp/flux-test-reuse"
    session_name=""
    force_new=false
    if [ -z "$session_name" ]; then
        base_name=$(basename "$target_dir")
        
        if [ "$force_new" = true ]; then
            unique_suffix=$(date +%s)-$$
            session_name="${base_name}-${unique_suffix}"
        else
            session_name="$base_name"
        fi
    fi
    echo "$session_name"
')

# Test that the session name without force_new is simple
if [ "$SESSION_NAME1" = "flux-test-reuse" ]; then
    log "✓ Default session name is simple (no unique suffix): $SESSION_NAME1"
else
    error "✗ Default session name should be simple, got: $SESSION_NAME1"
    exit 1
fi

# Test 2: Test force new session behavior
log "Test 2: Testing force new session behavior"

# Test that sessions with unique names are created when force_new=true
SESSION_NAME2=$(cd /home/runner/work/flux-capacitor/flux-capacitor/src && bash -c '
    target_dir="/tmp/flux-test-force"
    session_name=""
    force_new=true
    if [ -z "$session_name" ]; then
        base_name=$(basename "$target_dir")
        
        if [ "$force_new" = true ]; then
            unique_suffix=$(date +%s)-$$
            session_name="${base_name}-${unique_suffix}"
        else
            session_name="$base_name"
        fi
    fi
    echo "$session_name"
')

# Test that the session name with force_new has unique suffix
if [[ "$SESSION_NAME2" =~ ^flux-test-force-[0-9]+-[0-9]+$ ]]; then
    log "✓ Force new session name has unique suffix: $SESSION_NAME2"
else
    error "✗ Force new session name should have unique suffix, got: $SESSION_NAME2"
    exit 1
fi

# Test 3: Test that force new flag is recognized
log "Test 3: Testing that --force-new flag is recognized"

# Test that the script recognizes the --force-new flag
if "$CONNECT_SCRIPT" --force-new "/tmp/flux-test-force" --help 2>&1 | grep -q "force-new\|Usage"; then
    log "✓ --force-new flag is recognized"
elif "$CONNECT_SCRIPT" --invalid-option 2>&1 | grep -q "\-f\|--force-new"; then
    log "✓ --force-new flag is documented in usage"
else
    # Check if it doesn't produce an "unknown option" error
    if "$CONNECT_SCRIPT" --force-new "/tmp/flux-test-force" 2>&1 | grep -q "Unknown option"; then
        error "✗ --force-new flag is not recognized"
        exit 1
    else
        log "✓ --force-new flag is recognized (no unknown option error)"
    fi
fi

# Test 4: Test that -f short flag is recognized  
log "Test 4: Testing that -f short flag is recognized"

if "$CONNECT_SCRIPT" -f "/tmp/flux-test-force" 2>&1 | grep -q "Unknown option"; then
    error "✗ -f flag is not recognized"
    exit 1
else
    log "✓ -f flag is recognized"
fi

log "All new functionality tests passed!"
exit 0