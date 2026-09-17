# OpenCode Personal Configuration

Personal OpenCode configuration and instructions: global config, system prompt, plugin, MCP setup, and skills.

## Contents

| Path | Purpose |
|---|---|
| `opencode.jsonc` | Global OpenCode config: instructions, agent settings, MCP servers, formatter/LSP toggles. |
| `instructions/SYSTEM-PROMPT.md` | The system prompt injected into every session (PROPOSE/EXECUTE consultant behavior). |
| `plugins/system-trim.ts` | Plugin that trims repeated "Instructions from:" segments from the system prompt. Auto-loaded from `plugins/`. |
| `playwright-mcp.json` | Playwright MCP browser settings (headless Chromium). |
| `install.sh` | One-shot installer: prerequisites, config clone, dependencies, and browser setup. |
| `skills/` | Global skills (frontend design, security, testing, semantic HTML, debugging, grilling, etc.). |

## Required packages

| Package | Version | Why |
|---|---|---|
| `opencode` | latest | The application itself. |
| `bun` | latest | Runtime used by the MCP command (`bun x @playwright/mcp@latest`). |
| `@opencode-ai/plugin` | `1.18.31` | Plugin SDK; `plugins/system-trim.ts` imports its `Plugin` type. |
| `@playwright/mcp` | latest (fetched on demand) | MCP server for browser automation; run via `bun x`, no install needed. |
| Playwright browser binaries | latest | Chromium headless shell required by `@playwright/mcp`; installed with `bunx playwright install chromium`. |

Note: `package.json`, lockfiles, and `node_modules/` are excluded from this repo via `.gitignore`, so the dependency manifest is not versioned. Recreate it locally as shown below.

## Applying the config

### Quick install (one-shot)

`install.sh` installs everything in one run: prerequisites (bun, opencode), the config repo, dependencies, and the Playwright browser. It is idempotent and safe to re-run.

```bash
curl -fsSL https://raw.githubusercontent.com/azrialwork/opencode-settings/main/install.sh | bash
```

Or download first, then run (recommended for security):

```bash
curl -fsSL -o install.sh https://raw.githubusercontent.com/azrialwork/opencode-settings/main/install.sh
bash install.sh
```

What the script does:

1. Installs `bun` and `opencode` if missing.
2. Clones the repo into `~/.config/opencode/` (or pulls updates; backs up an existing non-repo directory first).
3. Recreates the gitignored `package.json` and runs `bun install`.
4. Installs the Playwright chromium browser.
5. Rewrites absolute paths in `opencode.jsonc` to your `$HOME`.
6. Prints a reminder to restart opencode.

### Manual install (step by step)

1. Install prerequisites:

   ```bash
   # opencode (see https://opencode.ai/docs/ for install options)
   # bun
   curl -fsSL https://bun.sh/install | bash
   ```

2. Clone or copy this repo to the global config directory:

   ```bash
   git clone https://github.com/azrialwork/opencode-settings.git ~/.config/opencode
   ```

   Or copy the files manually into `~/.config/opencode/`.

3. Recreate `package.json` (gitignored, not in the repo) and install the plugin SDK:

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
- Skills are auto-scanned from `~/.config/opencode/skills/<name>/SKILL.md`.