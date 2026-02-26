#!/usr/bin/env bash
# launch.sh - Launch a tmux session from a .flux.yml config file
#
# Usage: launch.sh [OPTIONS] [config-file]
#
# If no config file is given, looks for .flux.yml or flux.yml in the current directory.
#
# Config file format (.flux.yml):
#   session: myproject
#   root: ~/projects/myproject
#   windows:
#     - name: editor
#       cmd: nvim .
#     - name: server
#       dir: ~/projects/myproject/backend
#       cmd: npm run dev
#     - name: shell

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared utilities
if [ -f "${SCRIPT_DIR}/utils.sh" ]; then
    source "${SCRIPT_DIR}/utils.sh"
else
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'
    CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
fi

# --- Flags ---
VALIDATE_ONLY=false
FORCE_NEW=false
config_file=""

# --- Help ---
show_help() {
    echo -e "${BOLD}Usage:${RESET} flux launch [OPTIONS] [config-file]"
    echo
    echo "Launch a tmux session from a .flux.yml config file."
    echo "If no file is given, looks for .flux.yml or flux.yml in the current directory."
    echo
    echo -e "${BOLD}Options:${RESET}"
    echo "  --validate, -v    Validate config file without launching"
    echo "  --force, -f       Force new session even if one already exists"
    echo "  --help, -h        Show this help message"
    echo
    echo -e "${BOLD}Config format (.flux.yml):${RESET}"
    echo "  session: myproject"
    echo "  root: ~/projects/myproject"
    echo "  windows:"
    echo "    - name: editor"
    echo "      cmd: nvim ."
    echo "    - name: server"
    echo "      dir: ~/projects/myproject/backend"
    echo "      cmd: npm run dev"
    echo "    - name: shell"
}

# --- Argument parsing ---
while [[ $# -gt 0 ]]; do
    case "$1" in
        --validate|-v)
            VALIDATE_ONLY=true
            shift
            ;;
        --force|-f)
            FORCE_NEW=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        -*)
            echo -e "${RED}Error:${RESET} Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            config_file="$1"
            shift
            ;;
    esac
done

# --- Find config file ---
if [ -z "$config_file" ]; then
    if [ -f ".flux.yml" ]; then
        config_file=".flux.yml"
    elif [ -f "flux.yml" ]; then
        config_file="flux.yml"
    else
        echo -e "${RED}Error:${RESET} No config file specified and no .flux.yml found in current directory."
        echo "Create a .flux.yml file or run: flux launch <path-to-config>"
        exit 1
    fi
fi

if [ ! -f "$config_file" ]; then
    echo -e "${RED}Error:${RESET} Config file '$config_file' does not exist."
    exit 1
fi

# --- Check Python + PyYAML ---
PYTHON=""
if command -v python3 >/dev/null 2>&1; then
    PYTHON="python3"
elif command -v python >/dev/null 2>&1; then
    PYTHON="python"
else
    echo -e "${RED}Error:${RESET} Python is required to parse YAML but was not found."
    exit 1
fi

if ! $PYTHON -c "import yaml" 2>/dev/null; then
    echo -e "${RED}Error:${RESET} PyYAML is required but not installed."
    echo "Install it with: pip install pyyaml"
    exit 1
fi

# --- Parse YAML with Python ---
parse_config() {
    $PYTHON - "$config_file" <<'PYEOF'
import sys, yaml, json, os

config_path = sys.argv[1]
with open(config_path, 'r') as f:
    try:
        cfg = yaml.safe_load(f)
    except yaml.YAMLError as e:
        print(f"YAML_ERROR: {e}", file=sys.stderr)
        sys.exit(1)

if not isinstance(cfg, dict):
    print("YAML_ERROR: Config must be a YAML mapping", file=sys.stderr)
    sys.exit(1)

# Expand tildes in root
root = cfg.get('root', os.getcwd())
root = os.path.expanduser(str(root))

session = cfg.get('session', os.path.basename(root))
windows = cfg.get('windows', [])

if not isinstance(windows, list):
    print("YAML_ERROR: 'windows' must be a list", file=sys.stderr)
    sys.exit(1)

output = {
    'session': str(session),
    'root': root,
    'windows': []
}

for i, win in enumerate(windows):
    if not isinstance(win, dict):
        print(f"YAML_ERROR: window #{i+1} must be a mapping", file=sys.stderr)
        sys.exit(1)
    w = {
        'name': str(win.get('name', f'window-{i+1}')),
        'dir': os.path.expanduser(str(win.get('dir', root))),
        'cmd': str(win.get('cmd', '')) if win.get('cmd') else ''
    }
    output['windows'].append(w)

print(json.dumps(output))
PYEOF
}

# --- Validate ---
echo -e " ${CYAN}[LAUNCH]${RESET} Parsing config: ${BOLD}${config_file}${RESET}"
parsed=$( parse_config 2>&1 )

if echo "$parsed" | grep -q "^YAML_ERROR"; then
    echo -e "${RED}Error:${RESET} Invalid config file:"
    echo "$parsed" | grep "^YAML_ERROR" | sed 's/^YAML_ERROR: /  /'
    exit 1
fi

echo -e " ${GREEN}✓${RESET} Config is valid."

if $VALIDATE_ONLY; then
    session_name=$( echo "$parsed" | $PYTHON -c "import sys,json; d=json.load(sys.stdin); print(d['session'])" )
    root_dir=$( echo "$parsed" | $PYTHON -c "import sys,json; d=json.load(sys.stdin); print(d['root'])" )
    win_count=$( echo "$parsed" | $PYTHON -c "import sys,json; d=json.load(sys.stdin); print(len(d['windows']))" )
    echo -e "  Session : ${BOLD}${session_name}${RESET}"
    echo -e "  Root    : ${root_dir}"
    echo -e "  Windows : ${win_count}"
    exit 0
fi

# --- Check tmux ---
if ! command -v tmux >/dev/null 2>&1; then
    echo -e "${RED}Error:${RESET} tmux is not installed."
    exit 1
fi

# --- Extract parsed values ---
session_name=$( echo "$parsed" | $PYTHON -c "import sys,json; d=json.load(sys.stdin); print(d['session'])" )
root_dir=$( echo "$parsed" | $PYTHON -c "import sys,json; d=json.load(sys.stdin); print(d['root'])" )
win_count=$( echo "$parsed" | $PYTHON -c "import sys,json; d=json.load(sys.stdin); print(len(d['windows']))" )

echo -e " ${CYAN}[LAUNCH]${RESET} Session: ${BOLD}${session_name}${RESET} | Root: ${root_dir} | Windows: ${win_count}"

# --- Handle existing session ---
if tmux has-session -t "$session_name" 2>/dev/null; then
    if $FORCE_NEW; then
        echo -e " ${YELLOW}[WARN]${RESET} Killing existing session '${session_name}'..."
        tmux kill-session -t "$session_name"
    else
        echo -e " ${YELLOW}[WARN]${RESET} Session '${session_name}' already exists."
        read -r -p "  Attach to it? [Y/n] " choice
        choice="${choice:-Y}"
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            tmux attach-session -t "$session_name" 2>/dev/null || tmux switch-client -t "$session_name"
            exit 0
        else
            echo "Aborted."
            exit 0
        fi
    fi
fi

# --- Create root dir if needed ---
mkdir -p "$root_dir" 2>/dev/null || true

# --- Create session (detached, no auto-window) ---
tmux new-session -d -s "$session_name" -c "$root_dir" -n "$(echo "$parsed" | $PYTHON -c "import sys,json; d=json.load(sys.stdin); print(d['windows'][0]['name'] if d['windows'] else 'main')")"

# --- Setup first window ---
first_dir=$( echo "$parsed" | $PYTHON -c "import sys,json; d=json.load(sys.stdin); print(d['windows'][0]['dir'] if d['windows'] else d['root'])" )
first_cmd=$( echo "$parsed" | $PYTHON -c "import sys,json; d=json.load(sys.stdin); print(d['windows'][0]['cmd'] if d['windows'] else '')" )

tmux send-keys -t "${session_name}:1" "cd \"${first_dir}\"" C-m
if [ -n "$first_cmd" ]; then
    tmux send-keys -t "${session_name}:1" "$first_cmd" C-m
fi

# --- Create remaining windows ---
win_total=$( echo "$parsed" | $PYTHON -c "import sys,json; d=json.load(sys.stdin); print(len(d['windows']))" )
i=1
while [ "$i" -lt "$win_total" ]; do
    win_name=$( echo "$parsed" | $PYTHON -c "import sys,json,os; d=json.load(sys.stdin); print(d['windows'][$i]['name'])" )
    win_dir=$(  echo "$parsed" | $PYTHON -c "import sys,json,os; d=json.load(sys.stdin); print(d['windows'][$i]['dir'])" )
    win_cmd=$(  echo "$parsed" | $PYTHON -c "import sys,json,os; d=json.load(sys.stdin); print(d['windows'][$i]['cmd'])" )

    tmux new-window -t "$session_name" -n "$win_name" -c "$win_dir"
    if [ -n "$win_cmd" ]; then
        tmux send-keys -t "${session_name}:$((i+1))" "$win_cmd" C-m
    fi
    i=$((i + 1))
done

# --- Focus first window ---
tmux select-window -t "${session_name}:1"

echo -e " ${GREEN}✓${RESET} Session '${BOLD}${session_name}${RESET}' launched with ${win_total} window(s)."

# --- Attach ---
if [ -n "${TMUX:-}" ]; then
    tmux switch-client -t "$session_name"
else
    tmux attach-session -t "$session_name"
fi
