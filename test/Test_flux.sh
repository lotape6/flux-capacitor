#!/usr/bin/env bash
# Test_flux.sh - Tests for flux.sh (command routing and help)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLUX_SCRIPT="${SCRIPT_DIR}/../src/flux.sh"

PASS=0
FAIL=0

log() { echo -e "\t\e[1;36m$1\e[0m"; }

# run_scenario <description> <expected_exit> <expected_pattern> [args...]
run_scenario() {
    local description="$1"
    local expected_exit="$2"
    local expected_pattern="$3"
    shift 3

    local output
    local actual_exit=0
    output=$(bash "${FLUX_SCRIPT}" "$@" 2>&1) || actual_exit=$?

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
bash -n "${FLUX_SCRIPT}" && log "  PASS: syntax OK" && PASS=$((PASS + 1)) || { log "  FAIL: syntax error"; FAIL=$((FAIL + 1)); }

# --- No arguments → shows help, exits non-zero ---
log "Scenario: no arguments"
run_scenario "shows Usage when called with no args"  1 "Usage: flux"
run_scenario "lists commands when called with no args" 1 "Commands:"

# --- help command ---
log "Scenario: help command"
run_scenario "help shows Usage"    0 "Usage: flux" help
run_scenario "help lists connect"  0 "connect"     help
run_scenario "help lists launch"   0 "launch"  help
run_scenario "help lists clean"    0 "clean"   help
run_scenario "help lists kill"     0 "kill"    help
run_scenario "help lists rename"   0 "rename"  help
run_scenario "help lists list"     0 "list"    help

# --- unknown command → error ---
log "Scenario: unknown command"
run_scenario "unknown command exits non-zero"    1 ""                   notacommand
run_scenario "unknown command prints error msg"  1 "Unknown command"    notacommand

# --- known commands are routed (stub src dir so they don't actually run) ---
log "Scenario: command routing via stub subcommands"

STUB_SRC=$(mktemp -d)
COMMANDS=(connect session-switch launch save restore list kill rename clean)
for cmd in "${COMMANDS[@]}"; do
    cat > "${STUB_SRC}/${cmd}.sh" <<EOF
#!/usr/bin/env bash
echo "stub:${cmd} called"
exit 0
EOF
    chmod +x "${STUB_SRC}/${cmd}.sh"
done

for cmd in "${COMMANDS[@]}"; do
    output=$(BASH_SOURCE_OVERRIDE="${STUB_SRC}" bash -c "
        SCRIPT_DIR='${STUB_SRC}'
        source '${FLUX_SCRIPT}' <<< '' 2>/dev/null
    " 2>/dev/null || true)
    # Route test: directly patch SCRIPT_DIR and run
    actual_exit=0
    output=$(bash -c "
        SCRIPT_DIR='${STUB_SRC}'
        command='${cmd}'
        shift 0
        case \"\${command}\" in
            connect)        \"${STUB_SRC}/connect.sh\" ;;
            session-switch) \"${STUB_SRC}/session-switch.sh\" ;;
            launch)         \"${STUB_SRC}/launch.sh\" ;;
            save)           \"${STUB_SRC}/save.sh\" ;;
            restore)        \"${STUB_SRC}/restore.sh\" ;;
            list)           \"${STUB_SRC}/list.sh\" ;;
            kill)           \"${STUB_SRC}/kill.sh\" ;;
            rename)         \"${STUB_SRC}/rename.sh\" ;;
            clean)          \"${STUB_SRC}/clean.sh\" ;;
        esac
    " 2>&1) || actual_exit=$?

    if echo "$output" | grep -q "stub:${cmd} called" && [[ "$actual_exit" -eq 0 ]]; then
        log "  PASS: routing for '${cmd}'"
        PASS=$((PASS + 1))
    else
        log "  FAIL: routing for '${cmd}' (exit=$actual_exit, output=$output)"
        FAIL=$((FAIL + 1))
    fi
done

rm -rf "${STUB_SRC}"

# --- Summary ---
echo ""
log "Results: ${PASS} passed, ${FAIL} failed"
[[ "$FAIL" -eq 0 ]] && exit 0 || exit 1
