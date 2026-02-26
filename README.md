# ⚡ Flux Capacitor

> *"The way I see it, if you're gonna build a time machine out of a car, why not do it with some style?"*
> — Doc Brown, probably talking about tmux sessions

A terminal session manager that makes you go **88 mph** through your projects.
Completely inspired by [sesh](https://github.com/joshmedeski/sesh) — the real DeLorean. This is the learning replica built in a garage.

<p align="center">
  <img src="resources/flux.gif" alt="animated" />
</p>

## Build Status

| Workflow | Status |
|---|---|
| Basic Integration | ![Basic Integration](https://github.com/lotape6/flux-capacitor/actions/workflows/BasicIntegration.yml/badge.svg?branch=master) |
| Daily Integration | ![Daily Integration](https://github.com/lotape6/flux-capacitor/actions/workflows/DailyIntegration.yml/badge.svg?branch=master) |

---

## Installation

### Prerequisites

```
git  curl  tmux  fzf  bat  delta
```
…and the basic willpower to keep using a terminal.

### Quick Install

```bash
git clone https://github.com/lotape6/flux-capacitor.git
cd flux-capacitor
./install.sh
```

Then restart your shell (or `source ~/.zshrc` / `source ~/.bashrc`).

### Uninstall

```bash
~/.flux/uninstall.sh
```

---

## Commands

### `flux connect <directory>`
Warp into a tmux session rooted at a directory. If a session already exists for that path, it re-attaches — no duplicates.

```bash
flux connect ~/projects/skynet
flux connect -p "source .venv/bin/activate" ~/projects/myapp   # run cmd in every new pane
flux connect -e .env ~/projects/myapp                           # auto-load env file
flux connect -f ~/projects/myapp                                # force a brand new session
```

| Flag | What it does |
|---|---|
| `-p / --pre-cmd` | Command to run in every new pane |
| `-P / --post-cmd` | Command to run after session ends |
| `-n / --session-name` | Override the session name |
| `-e / --env-file` | Source an env file in every pane |
| `-f / --force-new` | Always create a fresh session |

---

### `flux launch [config-file]`
Spin up a full tmux workspace from a `.flux.yml` config. No file given? It looks for `.flux.yml` in your current directory like a well-trained hound.

```bash
flux launch                        # uses .flux.yml in current dir
flux launch ~/configs/work.yml     # explicit path
flux launch --validate .flux.yml   # check the config without launching
flux launch --force                # nuke existing session and rebuild
```

**`.flux.yml` format:**
```yaml
session: skynet
root: ~/projects/skynet

windows:
  - name: editor
    cmd: nvim .

  - name: server
    dir: ~/projects/skynet/backend
    cmd: npm run dev

  - name: db
    cmd: docker compose up

  - name: shell
    # no cmd = just a shell. sometimes that's enough.
```

See `.flux.yml.example` in the repo root for a full template.

---

### `flux session-switch`
Interactive fzf session picker. Press `Alt+S` from anywhere in your shell — no need to remember session names like it's 1987.

Shows attached/detached status, window count, and current directory. Preview pane shows live window tree.

---

### `flux list`
Print a table of all active sessions. No sessions? It tells you, gently.

```bash
flux list          # pretty table
flux list --json   # machine-readable, for the scripters among us
```

---

### `flux kill [session-name]`
Terminate a session with extreme prejudice.

```bash
flux kill                  # fzf picker (outside tmux) or kills current (inside)
flux kill skynet            # specific session
flux kill --all             # scorched earth (same as flux clean)
flux kill skynet --yes      # skip the "are you sure?" prompt
```

---

### `flux rename [old-name] <new-name>`
Give your session a better name. We've all had sessions called `bash-1` in shame.

```bash
flux rename better-name          # rename current session
flux rename skynet terminator    # rename by name
```

---

### `flux save [session-name]`
Serialize your session layout to a `.flux.yml` file. Window names, directories, running commands — captured. Shell processes are skipped because nobody wants `bash` as a startup command.

```bash
flux save                        # save current session to ./.flux.yml
flux save myproject              # save a specific session
flux save -o ~/backups/work.yml  # custom output path
```

---

### `flux restore [config-file]`
The yin to `flux save`'s yang. Restores a session from a `.flux.yml` file. Alias for `flux launch` — same engine, more semantic name.

```bash
flux restore                      # looks for .flux.yml here
flux restore ~/backups/work.yml   # explicit path
```

---

### `flux clean`
Kill the entire tmux server. Everything. Gone. Use when you want to start fresh or have a dramatic moment.

```bash
flux clean
```

---

### `flux help [command]`
Shows help. Or help for a specific command. Revolutionary.

```bash
flux help
flux help kill
```

---

## Shell Integration

After install, your shell gets:

- **`flux` alias** — points to the main CLI
- **`Alt+S` keybinding** — triggers `session-switch` from anywhere
- **Tab completions** — for all commands, flags, and live session names (bash, zsh, fish)

---

## Configuration

Config lives at `~/.flux/config/flux.conf`. Tune it to your liking:

| Option | Default | Description |
|---|---|---|
| `FLUX_VERBOSE_MODE` | `true` | Chatty install/uninstall output |
| `FLUX_ROOT` | `~/.flux` | Where everything lives |
| `FLUX_LOGS_DIR` | `~/.flux/logs` | Log files |

<p align="center">
  <img src="resources/tune.gif" alt="tuning"/>
</p>

---

## Contributing

Found a bug? Think you can make this 1.21 gigawatts better?

- Bugs = time paradoxes. Fix them.
- PRs welcome. AI-assisted PRs doubly welcome.
- Tests live in `test/`. Run them with `bash test/run_all_tests.sh`. All green before you push, please.

```bash
git clone https://github.com/lotape6/flux-capacitor.git
cd flux-capacitor
bash test/run_all_tests.sh
```

---

## Acknowledgments

🚀 Shamelessly inspired by **[sesh](https://github.com/joshmedeski/sesh)** by [@joshmedeski](https://github.com/joshmedeski).
If you want production-grade session management, use sesh. This project exists to learn from the best — and maybe add a few twists.

---

## Disclaimer

No time machines, mice, or terminal emulators were harmed in the making of this project.
Provided as-is. Side effects may include: increased productivity, neglected mouse, and an irrational attachment to tmux splits.

---

## References

- [sesh](https://github.com/joshmedeski/sesh) — the original, the legend
- [Modern Unix tools](https://github.com/ibraheemdev/modern-unix) — because `ls` deserved better
