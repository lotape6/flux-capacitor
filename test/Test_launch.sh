#!/usr/bin/env bash
# Test_launch.sh - Tests for launch.sh (YAML config validation and parsing)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LAUNCH_SCRIPT="${SCRIPT_DIR}/../src/launch.sh"

PASS=0
FAIL=0
WORK_DIR=$(mktemp -d)

log() { echo -e "\t\e[1;36m$1\e[0m"; }

cleanup() { rm -rf "${WORK_DIR}"; }
trap cleanup EXIT

# run_scenario <description> <expected_exit> <expected_pattern> [args...]
run_scenario() {
    local description="$1"
    local expected_exit="$2"
    local expected_pattern="$3"
    shift 3

    local output
    local actual_exit=0
    output=$(bash "${LAUNCH_SCRIPT}" "$@" 2>&1) || actual_exit=$?

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
bash -n "${LAUNCH_SCRIPT}" && log "  PASS: syntax OK" && PASS=$((PASS + 1)) || { log "  FAIL: syntax error"; FAIL=$((FAIL + 1)); }

# --- Help flag ---
log "Scenario: help flag"
run_scenario "--help exits 0"           0 "Usage:"  --help
run_scenario "--help shows options"     0 "Options" --help
run_scenario "--help shows config format" 0 "session:" --help
run_scenario "-h exits 0"              0 "Usage:"  -h

# --- Missing config (no .flux.yml in cwd, no arg) ---
log "Scenario: no config file"
(
    cd "${WORK_DIR}"
    run_scenario "no config in cwd exits non-zero" 1 "No config file"
)

# --- Non-existent config path ---
log "Scenario: non-existent config file path"
run_scenario "non-existent file exits non-zero" 1 "does not exist" "${WORK_DIR}/nonexistent.yml"

# --- Unknown option ---
log "Scenario: unknown option"
run_scenario "unknown option exits non-zero" 1 "Unknown option" --notanoption

# --- Valid config + --validate (no tmux needed) ---
log "Scenario: valid config --validate"

cat > "${WORK_DIR}/valid.yml" <<'EOF'
session: testproject
root: /tmp
windows:
  - name: editor
    cmd: echo hello
  - name: shell
EOF

run_scenario "valid config validates OK"           0 "Config is valid"      --validate "${WORK_DIR}/valid.yml"
run_scenario "validate shows session name"         0 "testproject"          --validate "${WORK_DIR}/valid.yml"
run_scenario "validate shows window count"         0 "2"                    --validate "${WORK_DIR}/valid.yml"
run_scenario "-v flag works same as --validate"    0 "Config is valid"      -v         "${WORK_DIR}/valid.yml"

# --- Minimal valid config (no windows key) ---
log "Scenario: minimal valid config"
cat > "${WORK_DIR}/minimal.yml" <<'EOF'
session: minimal
root: /tmp
EOF
run_scenario "minimal config (no windows) validates" 0 "Config is valid" --validate "${WORK_DIR}/minimal.yml"

# --- Invalid YAML ---
log "Scenario: invalid YAML"
cat > "${WORK_DIR}/invalid.yml" <<'EOF'
session: [unclosed bracket
  bad indent
EOF
run_scenario "invalid YAML exits non-zero" 1 "" "${WORK_DIR}/invalid.yml"

# --- Config with wrong root type ---
log "Scenario: non-mapping YAML"
cat > "${WORK_DIR}/notmapping.yml" <<'EOF'
- just
- a list
EOF
run_scenario "non-mapping YAML exits non-zero" 1 "" "${WORK_DIR}/notmapping.yml"

# --- Auto-detect .flux.yml from cwd ---
log "Scenario: auto-detect .flux.yml from cwd"
cat > "${WORK_DIR}/.flux.yml" <<'EOF'
session: autodetect
root: /tmp
EOF
(
    cd "${WORK_DIR}"
    run_scenario "auto-detects .flux.yml in cwd" 0 "Config is valid" --validate
)

# --- Auto-detect flux.yml (fallback) ---
log "Scenario: auto-detect flux.yml fallback"
SUB_DIR=$(mktemp -d "${WORK_DIR}/sub.XXXXXX")
cat > "${SUB_DIR}/flux.yml" <<'EOF'
session: fallback
root: /tmp
EOF
(
    cd "${SUB_DIR}"
    run_scenario "auto-detects flux.yml as fallback" 0 "Config is valid" --validate
)

# --- Summary ---
echo ""
log "Results: ${PASS} passed, ${FAIL} failed"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
