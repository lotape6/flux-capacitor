#!/usr/bin/env bash
# Test_session_switch.sh - Test session switch functionality

# Source test utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# Test logging functions
log() {
    echo -e "${BLUE}[TEST]${RESET} $1"
}

error() {
    echo -e "${RED}[ERROR]${RESET} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${RESET} $1"
}

# Clean up any existing test sessions
cleanup() {
    tmux kill-server 2>/dev/null || true
    rm -rf "/tmp/flux-test-session-switch-"* 2>/dev/null || true
}

# Cleanup on exit
trap cleanup EXIT

# Test script paths
SESSION_SWITCH_SCRIPT="$REPO_DIR/src/session-switch.sh"
FLUX_SCRIPT="$REPO_DIR/src/flux.sh"

log "Testing session switch functionality..."

# Test 1: Check if session-switch script exists and is executable
log "Test 1: Checking if session-switch script exists and is executable"

if [ ! -f "$SESSION_SWITCH_SCRIPT" ]; then
    error "session-switch.sh script not found at $SESSION_SWITCH_SCRIPT"
    exit 1
fi

if [ ! -x "$SESSION_SWITCH_SCRIPT" ]; then
    error "session-switch.sh script is not executable"
    exit 1
fi

success "✓ session-switch.sh script exists and is executable"

# Test 2: Test help functionality
log "Test 2: Testing help functionality"

help_output=$("$SESSION_SWITCH_SCRIPT" --help 2>&1)
if [[ "$help_output" =~ "Interactive tmux session switcher" ]]; then
    success "✓ Help message displays correctly"
else
    error "✗ Help message not found or incorrect"
    echo "Got: $help_output"
    exit 1
fi

# Test 3: Test flux CLI integration
log "Test 3: Testing flux CLI integration"

flux_help=$("$FLUX_SCRIPT" --help 2>&1 || "$FLUX_SCRIPT" 2>&1)
if [[ "$flux_help" =~ "session-switch" ]]; then
    success "✓ session-switch command is listed in flux CLI"
else
    error "✗ session-switch command not found in flux CLI"
    echo "Got: $flux_help"
    exit 1
fi

# Test 4: Test flux session-switch help
log "Test 4: Testing flux session-switch help"

flux_session_help=$("$FLUX_SCRIPT" session-switch --help 2>&1)
if [[ "$flux_session_help" =~ "Interactive tmux session switcher" ]]; then
    success "✓ flux session-switch help works correctly"
else
    error "✗ flux session-switch help not working"
    echo "Got: $flux_session_help"
    exit 1
fi

# Test 5: Test behavior when no sessions exist
log "Test 5: Testing behavior when no tmux sessions exist"

cleanup

no_sessions_output=$("$SESSION_SWITCH_SCRIPT" 2>&1 || true)
if [[ "$no_sessions_output" =~ "No tmux sessions found" ]]; then
    success "✓ Correctly reports no sessions found"
else
    error "✗ Incorrect behavior when no sessions exist"
    echo "Got: $no_sessions_output"
    exit 1
fi

# Test 6: Test behavior when fzf is not available (if fzf is not installed)
log "Test 6: Testing error handling for missing dependencies"

# Check if fzf is available
if ! command -v fzf >/dev/null 2>&1; then
    no_fzf_output=$("$SESSION_SWITCH_SCRIPT" 2>&1 || true)
    if [[ "$no_fzf_output" =~ "fzf is not installed" ]]; then
        success "✓ Correctly reports missing fzf dependency"
    else
        error "✗ Incorrect error message for missing fzf"
        echo "Got: $no_fzf_output"
        exit 1
    fi
else
    log "fzf is available, skipping fzf dependency test"
fi

# Test 7: Test behavior when tmux is not available (simulate by temporarily renaming)
log "Test 7: Testing error handling for missing tmux"

# Create a temporary directory and script that simulates missing tmux
temp_dir=$(mktemp -d)
temp_script="$temp_dir/session-switch-test.sh"

# Copy the script and modify PATH to exclude tmux
cat > "$temp_script" << 'EOF'
#!/usr/bin/env bash
# Temporarily remove tmux from PATH
export PATH="/tmp/no-tmux-path"
EOF
cat "$SESSION_SWITCH_SCRIPT" >> "$temp_script"
chmod +x "$temp_script"

no_tmux_output=$("$temp_script" 2>&1 || true)
if [[ "$no_tmux_output" =~ "tmux is not installed" ]]; then
    success "✓ Correctly reports missing tmux dependency"
else
    error "✗ Incorrect error message for missing tmux"
    echo "Got: $no_tmux_output"
    exit 1
fi

# Clean up temp files
rm -rf "$temp_dir"

# Test 8: Test that session-switch is included in completion scripts
log "Test 8: Testing completion script integration"

bash_completion="$REPO_DIR/src/completion/flux-completion.bash"
if grep -q "session-switch" "$bash_completion"; then
    success "✓ session-switch found in bash completion"
else
    error "✗ session-switch not found in bash completion"
    exit 1
fi

zsh_completion="$REPO_DIR/src/completion/flux-completion.zsh"
if grep -q "session-switch" "$zsh_completion"; then
    success "✓ session-switch found in zsh completion"
else
    error "✗ session-switch not found in zsh completion"
    exit 1
fi

fish_completion="$REPO_DIR/src/completion/flux-completion.fish"
if grep -q "session-switch" "$fish_completion"; then
    success "✓ session-switch found in fish completion"
else
    error "✗ session-switch not found in fish completion"
    exit 1
fi

# Test 9: Test that keybindings are added to shell initialization
log "Test 9: Testing shell initialization keybindings"

init_script="$REPO_DIR/src/flux-capacitor-init.sh"
if grep -q "flux_session_switch" "$init_script"; then
    success "✓ Session switch keybindings found in initialization script"
else
    error "✗ Session switch keybindings not found in initialization script"
    exit 1
fi

log "All session switch tests completed successfully!"