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
| `gh` (GitHub CLI) | latest | Required to fetch the config from the private repo. |
| `bun` | latest | Runtime used by the MCP command (`bun x @playwright/mcp@latest`) and dependency installs. On Termux it comes from the official `bun` package. |
| `@opencode-ai/plugin` | `1.18.31` | Plugin SDK; `plugins/system-trim.ts` imports its `Plugin` type. |
| `playwright` | latest (fetched on demand) | CLI used to install the browser binaries (`bunx playwright install chromium`). Not used on Termux. |
| `@playwright/mcp` | latest (fetched on demand) | MCP server for browser automation; run via `bun x` (via `bunx --bun @playwright/mcp@0.0.78` on Termux), no install needed. |
| Playwright browser binaries | latest | Chromium headless shell required by `@playwright/mcp`; installed with `bunx playwright install chromium`. On Termux, chromium comes from the `x11-repo` instead. |

Note: `package.json`, lockfiles, and `node_modules/` are excluded from this repo via `.gitignore`, so the dependency manifest is not versioned. Recreate it locally as shown below.

Note (proot): bun's default install backend is `hardlink`. proot's link2symlink converts hardlinks into `.l2s` symlinks, which breaks `bunx` and `bun install`. `install.sh` sets `BUN_OPTIONS="--backend=copyfile"` in `~/.bashrc` to force bun to copy files instead.

Note (Termux): on native Termux (Android, no proot) `install.sh` detects the environment and takes a different path: bun comes from the official Termux package, opencode is installed from the `bd-loser/opencode-bionic` aarch64 build (falling back to `guysoft/opencode-termux`; upstream ships no Android binary), and chromium comes from the Termux `x11-repo`, launched via `--executable-path` with `--no-sandbox` (the Android sandbox is unusable).

## Applying the config

### Quick install (one-shot)

The repo is private, so fetching the installer requires the GitHub CLI (`gh`). Install it and authenticate first:

```bash
# install gh (see https://cli.github.com/), then:
gh auth login
```

`install.sh` installs everything in one run: prerequisites (bun, opencode), the config repo, dependencies, and the browser (Playwright chromium, or the Termux `x11-repo` chromium on native Termux). It is idempotent and safe to re-run.

```bash
gh api repos/azrialwork/opencode-settings/contents/install.sh -q '.content' | base64 -d | bash
```

Or download first, then run (recommended for security):

```bash
gh api repos/azrialwork/opencode-settings/contents/install.sh -q '.content' | base64 -d > install.sh
bash install.sh
```

What the script does:

1. Checks that `gh` is installed and authenticated (required for the private repo).
2. Installs `bun` and `opencode` if missing (on Termux: the `bun` package and the `bd-loser/opencode-bionic` aarch64 build, falling back to `guysoft/opencode-termux`).
3. Adds `BUN_OPTIONS="--backend=copyfile"` to `~/.bashrc` (required under proot; skipped on Termux).
4. Clones the repo into `~/.config/opencode/` via `gh repo clone` (or pulls updates; backs up an existing non-repo directory first).
5. Recreates the gitignored `package.json` and runs `bun install` (on Termux it also patches playwright-core in the bun cache so android is treated as linux).
6. Installs the Playwright chromium browser (`pkg install chromium` from the Termux `x11-repo` on Termux).
7. Rewrites absolute paths in `opencode.jsonc` to your `$HOME` (on Termux it also rewrites the `mcp.playwright` command to `bunx --bun @playwright/mcp` with `--executable-path`).
8. Prints a reminder to restart opencode.

### Termux (native, no proot)

On native Termux the script detects the environment (`$PREFIX` set and `uname -o` = `Android`) and installs a fully native stack — no proot required:

- `pkg upgrade` runs first so the package set is consistent; a mismatched set (e.g. ffmpeg vs libplacebo) breaks the chromium install with "cannot locate symbol" link errors. `libc++` is then reinstalled and broken packages fixed, which recovers from an interrupted update that corrupted `libc++_shared.so`.
- bun comes from the official Termux package (`pkg install bun`); the MCP server runs via `bunx --bun @playwright/mcp@0.0.78`. playwright-core is patched in the bun cache so android is treated as linux (playwright-core only supports linux/darwin/win32 and rejects android with "Unsupported platform").
- opencode comes from the `bd-loser/opencode-bionic` aarch64 build (upstream ships no Android binary), falling back to `guysoft/opencode-termux`.
- chromium is installed from the Termux `x11-repo` and launched with `--executable-path $PREFIX/bin/chromium-browser --no-sandbox` (Android cannot use the Chromium sandbox).
- `PLAYWRIGHT_BROWSERS_PATH=0` is set for the MCP server so it never looks for downloaded browser binaries.

Requirements: an aarch64 device and `gh auth login` first. Run the same one-shot command as above.

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

2. Clone or copy this repo to the global config directory (the repo is private, so use `gh`):

   ```bash
   gh repo clone azrialwork/opencode-settings ~/.config/opencode
   ```

   Or copy the files manually into `~/.config/opencode/`.

3. Recreate `package.json` (gitignored, not in the repo) and install the dependencies:

   ```bash
   cd ~/.config/opencode
   cat > package.json <<'EOF'
   {
     "dependencies": {
       "@opencode-ai/plugin": "1.18.31"
     }
   }
   EOF
   bun install
   ```

4. Install the Playwright browser used by the MCP server:

   ```bash
   bunx playwright install chromium
   ```

5. Adjust absolute paths in `opencode.jsonc` if your home directory differs:

   - `instructions` → `~/.config/opencode/instructions/SYSTEM-PROMPT.md`
   - `mcp.playwright.command` → the `--config` flag points at `~/.config/opencode/playwright-mcp.json`

6. Restart opencode. Config is loaded once at startup and is not hot-reloaded, so a running session keeps the old config until you quit and start it again.

7. Verify: open a session and check that the system prompt is applied, the `playwright` MCP server is listed, and the `system-trim` plugin is active.

## Notes

- `opencode.jsonc` disables `lsp`, `formatter`, `autoupdate`, `share`, and `snapshot`; only the `BASE` agent is enabled (`default_agent: "BASE"`).
- The plugin is auto-discovered: any `*.ts`/`*.js` file under `~/.config/opencode/plugins/` is loaded without a `plugin` entry in the config.