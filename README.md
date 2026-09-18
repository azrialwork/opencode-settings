# OpenCode Personal Configuration

Personal OpenCode configuration and instructions: global config, system prompt, plugin, and MCP setup.

## Contents

| Path | Purpose |
|---|---|
| `opencode.jsonc` | Global OpenCode config: instructions, agent settings, MCP servers, formatter/LSP toggles. |
| `instructions/SYSTEM-PROMPT.md` | The system prompt injected into every session (PROPOSE/EXECUTE consultant behavior). |
| `plugins/system-trim.ts` | Plugin that trims repeated "Instructions from:" segments from the system prompt. Auto-loaded from `plugins/`. |
| `playwright-mcp.json` | Playwright MCP browser settings (headless Chromium). |
| `install.sh` | One-shot installer: prerequisites, config clone, dependencies, and browser setup. |

## Required packages

| Package | Version | Why |
|---|---|---|
| `opencode` | latest | The application itself. |
| `bun` | latest | Runtime used by the MCP command (`bunx`) and dependency installs. On Termux it comes from the official `bun` package. |
| `@opencode-ai/plugin` | `1.18.31` | Plugin SDK; `plugins/system-trim.ts` imports its `Plugin` type. |
| `@playwright/mcp` | `latest` (non-Termux), `0.0.81` (Termux) | MCP server for browser automation, run via `bunx`; no install needed. On Termux it is pinned to `0.0.81` because that version bundles playwright-core `1.64.0-alpha-2026-09-14`, the first build whose registry fix allows Android. |
| Playwright browser binaries | latest | Chromium required by `@playwright/mcp`; installed with `bunx @playwright/mcp install-browser chromium`. On Termux, chromium comes from the `x11-repo` instead. |

Note: `package.json`, lockfiles, and `node_modules/` are excluded from this repo via `.gitignore`, so the dependency manifest is not versioned. Recreate it locally as shown below.

Note (proot): bun's default install backend is `hardlink`. proot's link2symlink converts hardlinks into `.l2s` symlinks, which breaks `bunx` and `bun install`. `install.sh` sets `BUN_OPTIONS="--backend=copyfile"` in `~/.bashrc` to force bun to copy files instead.

Note (Termux): on native Termux (Android, no proot) `install.sh` detects the environment and takes a different path: bun comes from the official Termux package, opencode is installed from the `bd-loser/opencode-bionic` aarch64 build (falling back to `guysoft/opencode-termux`; upstream ships no Android binary), and chromium comes from the Termux `x11-repo`, launched via `--executable-path` with `--no-sandbox` (the Android sandbox is unusable).

## Applying the config

### Quick install (one-shot)

The repo is public, so the installer can be fetched directly with curl — no GitHub authentication needed:

`install.sh` installs everything in one run: prerequisites (bun, opencode), the config repo, dependencies, and the browser (Playwright chromium, or the Termux `x11-repo` chromium on native Termux). It is idempotent and safe to re-run.

```bash
curl -fsSL https://raw.githubusercontent.com/azrialwork/opencode-settings/main/install.sh | bash
```

Or download first, then run (recommended for security):

```bash
curl -fsSL https://raw.githubusercontent.com/azrialwork/opencode-settings/main/install.sh -o install.sh
bash install.sh
```

What the script does:

1. Checks that `curl` and `git` are installed (on Termux: `pkg upgrade`, then installs `git`, `curl`, `unzip`, `ripgrep` via `pkg`).
2. Installs `bun` if missing (Termux package, or the bun.sh installer elsewhere).
3. Adds `BUN_OPTIONS="--backend=copyfile"` to `~/.bashrc` (required under proot; skipped on Termux).
4. Installs `opencode` if missing (on Termux: the `bd-loser/opencode-bionic` aarch64 build, falling back to `guysoft/opencode-termux`).
5. Clones the repo into `~/.config/opencode/` via `git clone` (or pulls updates; backs up an existing non-repo directory first).
6. Recreates the gitignored `package.json` and runs `bun install`.
7. Installs the Playwright chromium browser (`bunx @playwright/mcp install-browser chromium`; `pkg install chromium` from the Termux `x11-repo` on Termux).
8. Installs chromium system dependencies for the distro (skipped on Termux).
9. Verifies the chromium binary's shared libraries resolve (skipped on Termux).
10. Smoke-tests the chromium binary launch.
11. On Termux: rewrites the `mcp.playwright` command to `bunx --bun @playwright/mcp@0.0.81` with `--executable-path`, and sets four environment variables (`PLAYWRIGHT_BROWSERS_PATH=0`, `PWMCP_PROFILES_DIR_FOR_TEST`, `PWTEST_SERVER_REGISTRY`, `PWTEST_DAEMON_SESSION_DIR`) that bypass the remaining Android platform checks.
12. Rewrites absolute paths in `opencode.jsonc` to your `$HOME`.
13. Prints a reminder to restart opencode.

### Termux (native, no proot)

On native Termux the script detects the environment (`$PREFIX` set and `uname -o` = `Android`) and installs a fully native stack — no proot required:

- `pkg upgrade` runs first so the package set is consistent; a mismatched set (e.g. ffmpeg vs libplacebo) breaks the chromium install with "cannot locate symbol" link errors. `libc++` is then reinstalled and broken packages fixed, which recovers from an interrupted update that corrupted `libc++_shared.so`.
- bun comes from the official Termux package (`pkg install bun`).
- opencode comes from the `bd-loser/opencode-bionic` aarch64 build (upstream ships no Android binary), falling back to `guysoft/opencode-termux`.
- chromium is installed from the Termux `x11-repo` and launched with `--executable-path $PREFIX/bin/chromium-browser --no-sandbox` (Android cannot use the Chromium sandbox).
- The MCP server is pinned to `@playwright/mcp@0.0.81`, which bundles playwright-core `1.64.0-alpha-2026-09-14` — the first build whose `registryDirectory` fix allows Android. Three remaining platform checks are bypassed with environment variables: `PWMCP_PROFILES_DIR_FOR_TEST` (a direct `defaultCacheDirectory()` call in `createUserDataDir`), `PWTEST_SERVER_REGISTRY` (a direct `registryDirectory2()` call in the server registry), and `PWTEST_DAEMON_SESSION_DIR` (a direct `computeBaseDaemonDir()` call reached via `createClientInfo()`). `PLAYWRIGHT_BROWSERS_PATH=0` keeps the server from looking for downloaded browser binaries.

Requirements: an aarch64 device. Run the same one-shot command as above.

### Manual install (step by step)

The manual steps assume a normal Linux environment; on Termux use the one-shot installer above.

1. Install prerequisites:

   ```bash
   # opencode (see https://opencode.ai/docs/ for install options)
   # bun (see https://bun.sh/docs/installation)
   curl -fsSL https://bun.sh/install | bash
   # required under proot: force bun to copy files instead of hardlinking
   echo 'export BUN_OPTIONS="--backend=copyfile"' >> ~/.bashrc
   export BUN_OPTIONS="--backend=copyfile"
   ```

2. Clone or copy this repo to the global config directory:

   ```bash
   git clone https://github.com/azrialwork/opencode-settings ~/.config/opencode
   ```

   Or copy the files manually into `~/.config/opencode/`.

3. Recreate `package.json` (gitignored, not in the repo) and install the dependencies:

   ```bash
   cd ~/.config/opencode
   cat > package.json <<'EOF'
   {
     "dependencies": {
       "@opencode-ai/plugin": "1.18.31"
     },
     "allowScripts": {
       "msgpackr-extract": true
     }
   }
   EOF
   bun install
   ```

4. Install the Playwright browser used by the MCP server:

   ```bash
   bunx @playwright/mcp install-browser chromium
   ```

5. Adjust absolute paths in `opencode.jsonc` if your home directory differs:

   - `instructions` → `~/.config/opencode/instructions/SYSTEM-PROMPT.md`
   - `mcp.playwright.command` → the `--config` flag points at `~/.config/opencode/playwright-mcp.json`

6. Restart opencode. Config is loaded once at startup and is not hot-reloaded, so a running session keeps the old config until you quit and start it again.

7. Verify: open a session and check that the system prompt is applied, the `playwright` MCP server is listed, and the `system-trim` plugin is active.

## Notes

- `opencode.jsonc` disables `lsp`, `formatter`, `autoupdate`, `share`, and `snapshot`; only the `BASE` agent is enabled (`default_agent: "BASE"`).
- The plugin is auto-discovered: any `*.ts`/`*.js` file under `~/.config/opencode/plugins/` is loaded without a `plugin` entry in the config.