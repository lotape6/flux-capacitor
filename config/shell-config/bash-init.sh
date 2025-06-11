# Flux-capacitor configuration
source "${CONFIG_FILE}"

# Add keybindings here
# Example: bind '\C-g:flux-command'

# Session switcher keybinding (Alt+S)
if [ -f "${FLUX_ROOT}/src/session-switch-functions.sh" ]; then
    source "${FLUX_ROOT}/src/session-switch-functions.sh"
    bind -x '"\es":"switch_session"'
fi

# Create flux alias
if [ -f "${FLUX_ROOT}/src/flux.sh" ]; then
    alias flux="${FLUX_ROOT}/src/flux.sh"
fi

# Load flux command completion
if [ -f "${FLUX_ROOT}/src/completion/flux-completion.bash" ]; then
    source "${FLUX_ROOT}/src/completion/flux-completion.bash"
fi

# FZF initialization (if installed)
if command -v fzf >/dev/null 2>&1; then
    source <(fzf --bash)
fi