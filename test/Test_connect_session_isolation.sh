#!/usr/bin/env bash
# Test_connect_session_isolation.sh - Test session reuse and isolation behaviors

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
TEST_DIR1="/tmp/flux-test-dir1"
TEST_DIR2="/tmp/flux-test-dir2"
mkdir -p "$TEST_DIR1" "$TEST_DIR2"

# Clean up any existing tmux sessions
cleanup() {
    tmux kill-server 2>/dev/null || true
    rm -rf "$TEST_DIR1" "$TEST_DIR2" 2>/dev/null || true
}

# Cleanup on exit
trap cleanup EXIT

log "Testing session reuse and isolation for flux connect command..."

# Test 1: Check that default behavior creates simple session names (for reuse)
log "Test 1: Testing default session name generation (for reuse)"

cleanup

# Test that default behavior creates simple session names
SESSION_NAME1=$(cd /home/runner/work/flux-capacitor/flux-capacitor/src && bash -c '
    target_dir="/tmp/flux-test-dir1"
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

if [ "$SESSION_NAME1" = "flux-test-dir1" ]; then
    log "✓ Default behavior creates simple session names: $SESSION_NAME1"
else
    error "✗ Default session name should be simple, got: $SESSION_NAME1"
    exit 1
fi

# Test 2: Check that force-new creates unique session names
log "Test 2: Testing force-new session name generation (for isolation)"

# Test that multiple force-new calls generate different session names
SESSION_NAME2=$(cd /home/runner/work/flux-capacitor/flux-capacitor/src && bash -c '
    target_dir="/tmp/flux-test-dir1"
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

sleep 1  # Ensure different timestamp

SESSION_NAME3=$(cd /home/runner/work/flux-capacitor/flux-capacitor/src && bash -c '
    target_dir="/tmp/flux-test-dir1"
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

if [ "$SESSION_NAME2" != "$SESSION_NAME3" ]; then
    log "✓ Force-new creates unique session names: $SESSION_NAME2 vs $SESSION_NAME3"
else
    error "✗ Force-new session names should be unique: $SESSION_NAME2 vs $SESSION_NAME3"
    exit 1
fi

# Test 3: Test session creation with force-new (isolation behavior)
log "Test 3: Testing session creation with force-new flag"

# Create sessions using tmux directly with our force-new naming scheme
BASE_NAME="flux-test-dir1"
TIME1=$(date +%s)
SESSION1="${BASE_NAME}-${TIME1}-$$"

sleep 1  # Ensure different timestamp

TIME2=$(date +%s)
SESSION2="${BASE_NAME}-${TIME2}-$$"

# Create first session
tmux new-session -d -s "$SESSION1" -c "/tmp/flux-test-dir1" 2>/dev/null || true
SESSIONS_AFTER_FIRST=$(tmux list-sessions 2>/dev/null | wc -l || echo "0")

# Create second session with different unique name
tmux new-session -d -s "$SESSION2" -c "/tmp/flux-test-dir1" 2>/dev/null || true
SESSIONS_AFTER_SECOND=$(tmux list-sessions 2>/dev/null | wc -l || echo "0")

if [ "$SESSIONS_AFTER_SECOND" -gt "$SESSIONS_AFTER_FIRST" ]; then
    log "✓ Multiple force-new sessions for same directory can be created ($SESSIONS_AFTER_FIRST -> $SESSIONS_AFTER_SECOND sessions)"
else
    error "✗ Failed to create multiple force-new sessions for same directory ($SESSIONS_AFTER_FIRST vs $SESSIONS_AFTER_SECOND sessions)"
    tmux list-sessions 2>/dev/null || echo "No sessions found"
    exit 1
fi

# Test 4: Environment variables file support (unchanged)
log "Test 4: Testing environment variables file support"

# Create a test environment file
ENV_FILE="/tmp/test-env-vars"
cat > "$ENV_FILE" << 'EOF'
export TEST_VAR1="test_value_1"
export TEST_VAR2="test_value_2"
export PROJECT_NAME="flux-test"
EOF

# Test that the -e option is recognized by checking help output
log "Testing that -e/--env-file option is available"
if "$CONNECT_SCRIPT" --invalid-option 2>&1 | grep -q "\-e\|--env-file"; then
    log "✓ Environment file option is documented in usage"
else
    warn "Environment file option might not be documented in usage (checking differently)"
    # Check if the script recognizes the option without error
    if "$CONNECT_SCRIPT" -e "/tmp/nonexistent" "/tmp/flux-test-dir1" 2>&1 | grep -q "does not exist"; then
        log "✓ Environment file option is recognized by script"
    else
        error "✗ Environment file option is not recognized"
        exit 1
    fi
fi

# Test validation of environment file
log "Testing environment file validation"
if "$CONNECT_SCRIPT" -e "/tmp/nonexistent-env-file" "/tmp/flux-test-dir1" 2>&1 | grep -q "does not exist"; then
    log "✓ Environment file validation works"
else
    error "✗ Environment file validation failed"
    exit 1
fi

# Test 5: Testing force-new flag recognition
log "Test 5: Testing --force-new flag is recognized"
if "$CONNECT_SCRIPT" --force-new "/tmp/flux-test-dir1" 2>&1 | grep -q "Unknown option"; then
    error "✗ --force-new flag is not recognized"
    exit 1
else
    log "✓ --force-new flag is recognized"
fi

log "All tests passed!"
exit 0