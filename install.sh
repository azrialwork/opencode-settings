#!/usr/bin/env bash
#
# install.sh — one-shot installer for the personal OpenCode configuration.
#
# The repo is private, so this script requires the GitHub CLI (gh) to be
# installed and authenticated. It installs prerequisites (bun, opencode,
# Playwright chromium), clones or updates the config repo into
# ~/.config/opencode, recreates the gitignored package.json, installs
# dependencies, and fixes absolute paths for the current user. Safe to
# re-run: existing steps are skipped or updated.

set -euo pipefail

REPO_URL="https://github.com/azrialwork/opencode-settings.git"
CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"

# Repo directory when run as a file; empty when piped to bash via stdin.
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

log() { printf '\033[1;32m[install]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[install]\033[0m %s\n' "$*"; }

# 1. Prerequisites: curl, git, and gh (GitHub CLI) are required.
for cmd in curl git gh; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
done

# The repo is private, so gh must be authenticated to clone or fetch it.
if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated. Run 'gh auth login' first." >&2
  exit 1
fi

# 2. bun — runtime used by the Playwright MCP command and dependency installs.
if ! command -v bun >/dev/null 2>&1; then
  log "Installing bun..."
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
fi
command -v bun >/dev/null 2>&1 || { echo "bun install failed" >&2; exit 1; }

# 3. BUN_OPTIONS — proot's link2symlink converts hardlinks to .l2s symlinks,
#    which breaks bunx and bun install. Force bun to copy files instead.
if ! grep -q 'BUN_OPTIONS' "$HOME/.bashrc" 2>/dev/null; then
  log "Adding BUN_OPTIONS=--backend=copyfile to ~/.bashrc..."
  cat >> "$HOME/.bashrc" <<'EOF'

# bun: proot link2symlink breaks hardlinks; force copyfile backend.
export BUN_OPTIONS="--backend=copyfile"
EOF
fi
export BUN_OPTIONS="--backend=copyfile"

# 4. opencode — the application itself.
if ! command -v opencode >/dev/null 2>&1; then
  log "Installing opencode..."
  curl -fsSL https://opencode.ai/install | bash
  export PATH="$HOME/.opencode/bin:$PATH"
fi
command -v opencode >/dev/null 2>&1 || { echo "opencode install failed" >&2; exit 1; }

# 5. Config directory: clone, update, or back up and replace.
if [ -n "$SCRIPT_DIR" ] && [ "$SCRIPT_DIR" = "$CONFIG_DIR" ]; then
  log "Running from inside the config repo; skipping clone."
  cd "$CONFIG_DIR"
elif [ -d "$CONFIG_DIR/.git" ]; then
  remote="$(git -C "$CONFIG_DIR" remote get-url origin 2>/dev/null || true)"
  if [ "$remote" = "$REPO_URL" ]; then
    log "Updating existing config repo..."
    git -C "$CONFIG_DIR" pull --ff-only
  else
    backup_dir="${CONFIG_DIR}.bak-$(date +%Y%m%d-%H%M%S)"
    warn "Existing config has a different origin; backing it up to $backup_dir"
    mv "$CONFIG_DIR" "$backup_dir"
    gh repo clone azrialwork/opencode-settings "$CONFIG_DIR"
  fi
elif [ -d "$CONFIG_DIR" ]; then
  backup_dir="${CONFIG_DIR}.bak-$(date +%Y%m%d-%H%M%S)"
  warn "Existing config directory found; backing it up to $backup_dir"
  mv "$CONFIG_DIR" "$backup_dir"
  git clone "$REPO_URL" "$CONFIG_DIR"
else
  log "Cloning config repo..."
  gh repo clone azrialwork/opencode-settings "$CONFIG_DIR"
fi
cd "$CONFIG_DIR"

# 6. package.json is gitignored, so recreate it when missing.
if [ ! -f package.json ]; then
  log "Creating package.json..."
  cat > package.json <<'EOF'
{
  "dependencies": {
    "@opencode-ai/plugin": "1.18.31"
  }
}
EOF
fi

# 7. Install dependencies (plugin SDK).
log "Installing dependencies (bun install)..."
bun install

# 8. Playwright browser used by the MCP server. Install through the MCP
#    package itself so the chromium revision always matches the
#    playwright-core bundled with @playwright/mcp; a bare `bunx playwright
#    install` can drift to a different revision and break the MCP server.
log "Installing Playwright chromium browser..."
bunx @playwright/mcp install-browser chromium

# 8b. System dependencies for the chromium browser. The MCP server launches
#     a real chromium binary, which needs shared libraries that a minimal
#     container does not ship. Playwright's own `install-deps` only covers
#     Debian/Ubuntu and Alpine, so the lists are maintained here per distro.
install_playwright_system_deps() {
  if command -v pacman >/dev/null 2>&1; then
    log "Installing chromium system dependencies (pacman)..."
    pacman -S --needed --noconfirm \
      alsa-lib atk at-spi2-atk at-spi2-core cairo dbus expat fontconfig \
      freetype2 gdk-pixbuf2 glib2 gtk3 libcups libdrm libx11 libxcb \
      libxcomposite libxdamage libxext libxfixes libxkbcommon libxrandr \
      libxshmfence mesa nss nspr pango wayland xcb-util-cursor \
      xcb-util-image xcb-util-keysyms xcb-util-renderutil xcb-util-wm \
      xorg-xrandr
  elif command -v apt-get >/dev/null 2>&1; then
    log "Installing chromium system dependencies (apt-get)..."
    apt-get update
    apt-get install -y \
      libnss3 libnspr4 libatk1.0-0 libatk-bridge2.0-0 libcups2 libdrm2 \
      libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 \
      libgbm1 libasound2 libpango-1.0-0 libcairo2 libx11-6 libxcb1 \
      libxext6 libxi6 libxtst6 libxss1 fonts-liberation
  elif command -v dnf >/dev/null 2>&1; then
    log "Installing chromium system dependencies (dnf)..."
    dnf install -y \
      nss nspr atk at-spi2-atk cups-libs libdrm libxkbcommon libXcomposite \
      libXdamage libXfixes libXrandr mesa-libgbm alsa-lib pango cairo \
      libX11 libxcb libXext libXi libXtst libXScrnSaver
  elif command -v apk >/dev/null 2>&1; then
    log "Installing chromium system dependencies (apk)..."
    apk add --no-cache \
      nss nspr atk at-spi2-atk cups-libs libdrm libxkbcommon libxcomposite \
      libxdamage libxfixes libxrandr mesa-gbm alsa-lib pango cairo \
      libx11 libxcb libxext
  else
    warn "Unknown package manager; trying 'bunx playwright install-deps chromium'..."
    bunx playwright install-deps chromium
  fi
}
install_playwright_system_deps

# 8c. Verify the chromium binary resolves every shared library it needs.
CHROME_BIN="$(find "$HOME/.cache/ms-playwright" -path '*/chrome-linux*/chrome' 2>/dev/null | head -n1 || true)"
if [ -n "$CHROME_BIN" ] && command -v ldd >/dev/null 2>&1; then
  missing="$(ldd "$CHROME_BIN" 2>/dev/null | awk '/not found/{print $1}' | sort -u || true)"
  if [ -n "$missing" ]; then
    warn "Chromium still missing libraries: $missing"
  else
    log "Chromium shared libraries resolved."
  fi
fi

# 8d. Smoke test: launch the exact chromium binary the MCP server uses.
if [ -n "$CHROME_BIN" ]; then
  log "Smoke-testing chromium launch..."
  if "$CHROME_BIN" --headless --no-sandbox --disable-gpu --disable-dev-shm-usage \
      --dump-dom "data:text/html,<h1>playwright-ok</h1>" 2>/dev/null | grep -q "playwright-ok"; then
    log "Chromium launched successfully."
  else
    warn "Chromium smoke test failed; the MCP server may not start."
  fi
fi

# 9. Fix absolute paths in opencode.jsonc for the current user.
if grep -q "/home/azrial" opencode.jsonc; then
  log "Adjusting absolute paths in opencode.jsonc to $HOME..."
  sed -i "s|/home/azrial|$HOME|g" opencode.jsonc
fi

# 10. Done.
log "Installation complete."
echo
echo "Next step: quit and restart opencode so the new config is loaded."
echo "Config directory: $CONFIG_DIR"