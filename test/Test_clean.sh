#!/usr/bin/env bash
# Test_clean.sh - Tests for clean.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLEAN_SCRIPT="${SCRIPT_DIR}/../src/clean.sh"

PASS=0
FAIL=0

log() { echo -e "\t\e[1;36m$1\e[0m"; }

run_scenario() {
    local description="$1"
    local expected_exit="$2"
    local expected_pattern="$3"
    shift 3
    # remaining args: env overrides as VAR=val pairs before the command
    local env_overrides=()
    local cmd_args=()
    for arg in "$@"; do
        if [[ "$arg" == *=* && "${arg%%=*}" =~ ^[A-Z_]+$ ]]; then
            env_overrides+=("$arg")
        else
            cmd_args+=("$arg")
        fi
    done

    local output
    local actual_exit=0
    output=$(env "${env_overrides[@]}" bash "${CLEAN_SCRIPT}" "${cmd_args[@]}" 2>&1) || actual_exit=$?

    local ok=true
    [[ "$actual_exit" -eq "$expected_exit" ]] || ok=false
    if [[ -n "$expected_pattern" ]]; then
        echo "$output" | grep -q "$expected_pattern" || ok=false
    fi

    if $ok; then
        log "  PASS: $description"
        PASS=$((PASS + 1))
    else
        log "  FAIL: $description (exit=$actual_exit, expected=$expected_exit)"
        echo "    output: $output"
        FAIL=$((FAIL + 1))
    fi
}

# --- Syntax check ---
log "Scenario: syntax check"
bash -n "${CLEAN_SCRIPT}" && log "  PASS: syntax OK" && PASS=$((PASS + 1)) || { log "  FAIL: syntax error"; FAIL=$((FAIL + 1)); }

# --- Script is executable ---
log "Scenario: script exists"
[[ -f "${CLEAN_SCRIPT}" ]] && log "  PASS: script exists" && PASS=$((PASS + 1)) || { log "  FAIL: script missing"; FAIL=$((FAIL + 1)); }

# --- tmux not in PATH → error exit ---
log "Scenario: tmux not available"
NO_TMUX_DIR=$(mktemp -d)
# Provide bash but no tmux so the script starts but fails the tmux check
ln -s "$(command -v bash)" "${NO_TMUX_DIR}/bash"
run_scenario "exits with error when tmux is missing" 1 "tmux is not installed" PATH="${NO_TMUX_DIR}"
rm -rf "${NO_TMUX_DIR}"

# --- tmux available (mock): outputs expected messages ---
log "Scenario: tmux available (mocked)"
MOCK_DIR=$(mktemp -d)
cat > "${MOCK_DIR}/tmux" <<'EOF'
#!/usr/bin/env bash
# mock: kill-server succeeds silently
case "$1" in
    kill-server) exit 0 ;;
    *) exit 0 ;;
esac
EOF
chmod +x "${MOCK_DIR}/tmux"

run_scenario "prints 'Resetting tmux server' with mocked tmux" 0 "Resetting tmux server" PATH="${MOCK_DIR}:/usr/bin:/bin"
run_scenario "prints 'has been reset' with mocked tmux" 0 "has been reset" PATH="${MOCK_DIR}:/usr/bin:/bin"

# --- tmux kill-server fails gracefully (mock) ---
log "Scenario: tmux kill-server fails gracefully"
cat > "${MOCK_DIR}/tmux" <<'EOF'
#!/usr/bin/env bash
case "$1" in
    kill-server) exit 1 ;;
    *) exit 0 ;;
esac
EOF
chmod +x "${MOCK_DIR}/tmux"
run_scenario "does not error when kill-server fails (|| true)" 0 "has been reset" PATH="${MOCK_DIR}:/usr/bin:/bin"

rm -rf "${MOCK_DIR}"

# --- Summary ---
echo ""
log "Results: ${PASS} passed, ${FAIL} failed"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
