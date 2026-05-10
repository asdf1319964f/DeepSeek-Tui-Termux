# Running DeepSeek-TUI on Termux (Android)

DeepSeek-TUI ships official prebuilt binaries for **glibc Linux**, macOS, and Windows. Termux uses **Bionic libc** on Android, so those release artifacts will not load — you must build from source. This document covers the Termux-specific setup and the platform differences you need to know about.

This port is the `termux-port` branch of [Hmbown/DeepSeek-TUI](https://github.com/Hmbown/DeepSeek-TUI). All adaptations are gated behind `cfg(target_os = "android")` so the patch is a no-op for Linux/macOS/Windows builds.

## TL;DR

```bash
pkg install rust binutils pkg-config openssl libsqlite git gh
git clone -b termux-port https://github.com/Hmbown/DeepSeek-TUI.git ~/deepseek-tui
cd ~/deepseek-tui
bash install-termux.sh
deepseek auth set --provider deepseek
deepseek
```

> **Important:** the repo MUST live on Termux's native filesystem (`$HOME` or anywhere under `/data/data/com.termux/files/`). Building from `/storage/emulated/0/...` (Android shared storage) fails because the FUSE mount is `noexec` — Cargo cannot run the build scripts it just compiled.

## System packages

Required to build:

| Package | Why |
|---|---|
| `rust` | rustc ≥ 1.88 (Cargo workspace requires it) |
| `binutils` | Linker (`ld.lld`) for the final binary |
| `pkg-config`, `openssl`, `libsqlite` | Some transitive crates probe these |
| `git` | The dispatcher uses `git` for workspace snapshots and cloning skills |

Optional but useful at runtime:

| Package | Why |
|---|---|
| `gh` | The `github_*` tools shell out to `gh` |
| `nodejs`, `python` | If you'll run any JS/Python tasks via the agent |
| `termux-api` (plus the Termux:API APK) | Enables `termux-clipboard-*` and `termux-open` integration |

Optional language servers (install only those for languages you use):

```bash
pkg install rust-analyzer gopls clang        # Rust, Go, C/C++
pip install pyright                          # Python
npm install -g typescript-language-server    # TypeScript/JavaScript
```

## What's different on Termux

| Feature | Behavior |
|---|---|
| **Secrets storage** | Always uses `~/.deepseek/secrets/secrets.json` (mode 0600). Android Keystore is not reachable from a CLI without JNI; D-Bus / Secret Service does not exist on Termux. |
| **Self-update (`deepseek update`)** | Disabled. Official prebuilts are glibc Linux and won't run on Bionic. Re-run `cargo install --path crates/cli && cargo install --path crates/tui` to upgrade. |
| **Sandbox** | None. macOS Seatbelt and Linux Landlock are not available; commands run with the same permissions as the Termux process. Use `Plan` mode for read-only sessions. |
| **Browser open (OAuth, etc.)** | Tries `termux-open` first (Termux:API), then `xdg-open`. Install `pkg install termux-api` plus the Termux:API app from F-Droid for this to work. |
| **Clipboard** | Tries arboard's stub (always fails) → `termux-clipboard-set` / `-get` (requires Termux:API) → OSC 52 escape sequence (works in any modern terminal). |
| **GitHub `gh` discovery** | Probes `$PREFIX/bin/gh` (Termux), `/opt/homebrew/bin/gh` (macOS), `/usr/local/bin/gh`, then the bare PATH. Set `DEEPSEEK_GH_BIN=/path/to/gh` to override. |
| **Generated `~/.deepseek/tools/example.sh`** | Uses `#!/data/data/com.termux/files/usr/bin/env sh` so it is directly executable in Termux. |

## Verifying the install

```bash
deepseek --version              # → deepseek 0.8.17
deepseek doctor                 # should report keyring backend = file-based (~/.deepseek/secrets/)
deepseek auth status            # safe to run before setting a key
```

## Known limitations

- **No image clipboard paste.** Termux:API does not pass image bytes through `termux-clipboard-get`, so the @-mention image flow is text-only.
- **No `landlock` / Seatbelt sandbox.** Treat the agent like any other Termux process. The shell tools still respect the workspace-trust prompt and `command_safety` blocklist.
- **`portable-pty` upgraded to 0.9.** The pinned 0.8.x release pulled in `serial 0.4` → `termios 0.2.2`, which has no Android cfg arm and breaks the build. 0.9 switches to `serial2` which compiles for Android cleanly. The PTY surface is otherwise identical.
- **OS keyring-related warnings in `deepseek doctor`.** Expected — Android lacks both Secret Service and a CLI-reachable Keystore. The file backend at `~/.deepseek/secrets/secrets.json` is the supported path.
- **Performance.** A full release build is roughly 15–40 minutes on modern phones. Incremental rebuilds after a single source edit are typically under a minute.

## Reporting Termux-specific issues

When filing issues against this port, please include:

```bash
uname -a                                     # kernel + arch
echo "$PREFIX"                               # confirms Termux
rustc --version
deepseek --version
```

…and the relevant section from `deepseek doctor`.
