#!/usr/bin/env bash
#
# install.sh — one-shot installer for the personal OpenCode configuration.
#
# The repo is public, so no GitHub authentication is needed. It installs
# prerequisites (bun, opencode, Playwright chromium), clones or updates the
# config repo into ~/.config/opencode, recreates the gitignored package.json,
# installs dependencies, and fixes absolute paths for the current user. Safe
# to re-run: existing steps are skipped or updated.
#
# On native Termux (Android, no proot) the script takes a different path:
# bun comes from the official Termux package, opencode from the
# bd-loser/opencode-bionic aarch64 build (falling back to
# guysoft/opencode-termux), and chromium is installed from the Termux
# x11-repo and launched via --executable-path with --no-sandbox. The MCP
# server is pinned to @playwright/mcp@0.0.81, whose bundled playwright-core
# alpha carries the Android fix; three environment variables bypass the
# remaining platform checks (see step 12).

set -euo pipefail

REPO_URL="https://github.com/azrialwork/opencode-settings.git"
CONFIG_DIR="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"

# MCP server version pinned on Termux. 0.0.81 bundles playwright-core
# 1.64.0-alpha-2026-09-14, the first build whose registryDirectory fix
# allows Android; newer versions may work, but this one is verified.
MCP_VERSION="0.0.81"

# MCP server version pinned on Linux/macOS. 0.0.82's bundled playwright-core
# installs both the full chromium build and the separate
# chromium-headless-shell build that headless mode launches; pinning here —
# and rewriting the mcp.playwright command in opencode.jsonc to the same
# version (step 12b) — keeps the installed browser revision in lockstep with
# the MCP server. Without the pin, `@latest` resolves at different times
# (install.sh run vs. opencode startup) and the browser revision drifts.
MCP_VERSION_LINUX="0.0.82"

# Repo directory when run as a file; empty when piped to bash via stdin.
SCRIPT_DIR=""
if [ -n "${BASH_SOURCE[0]:-}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

# Detect native Termux (Android, no proot): $PREFIX is set and the kernel
# reports Android. Everything below branches on this flag.
TERMUX=0
if [ -n "${PREFIX:-}" ] && [ "$(uname -o 2>/dev/null)" = "Android" ]; then
  TERMUX=1
fi

log() { printf '\033[1;32m[install]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[install]\033[0m %s\n' "$*"; }

# 1. Prerequisites: curl and git are required. On Termux they are installed
#    via pkg, together with unzip (opencode release) and
#    ripgrep (opencode runtime dependency). pkg upgrade runs first because
#    Termux requires a consistent package set:
#    a mismatched one breaks the chromium install with "cannot locate
#    symbol" link errors (e.g. ffmpeg vs libplacebo). An interrupted update
#    can also corrupt libc++_shared.so, which `pkg upgrade` does not repair
#    (packages are already "up to date"); reinstalling libc++ and fixing
#    broken packages resolves that state.
if [ "$TERMUX" = "1" ]; then
  log "Termux detected; upgrading packages and installing prerequisites via pkg..."
  pkg upgrade -y || true
  pkg reinstall -y libc++
  pkg install -f -y
  pkg install -y git curl unzip ripgrep
else
  # On non-Termux the prerequisites are installed via the distro package
  # manager when missing, mirroring the Termux branch above. A fresh Arch
  # WSL2 ships neither git (not in the base group) nor which (dropped from
  # base) nor unzip (required by the bun installer), and the official
  # opencode installer calls `which opencode` (opencode.ai/install line 223),
  # so with `set -e` a missing command aborts the whole install.
  install_pkg() {
    if command -v pacman >/dev/null 2>&1; then
      pacman -S --needed --noconfirm "$@"
    elif command -v apt-get >/dev/null 2>&1; then
      apt-get update && apt-get install -y "$@"
    elif command -v dnf >/dev/null 2>&1; then
      dnf install -y "$@"
    elif command -v apk >/dev/null 2>&1; then
      apk add --no-cache "$@"
    else
      return 1
    fi
  }

  missing=""
  for cmd in curl git unzip; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing="$missing $cmd"
    fi
  done
  if [ -n "$missing" ]; then
    log "Installing missing prerequisites:$missing"
    if ! install_pkg $missing; then
      echo "Missing required command(s):$missing — install them manually." >&2
      exit 1
    fi
  fi

  if ! command -v which >/dev/null 2>&1; then
    log "Installing 'which' (required by the opencode installer)..."
    if ! install_pkg which; then
      warn "No package manager found to install 'which'; the opencode installer may fail."
    fi
  fi
fi

# 2. bun — runtime used by the Playwright MCP command and dependency installs.
#    On Termux it comes from the official Termux package (pkg install bun);
#    elsewhere from the bun.sh installer.
if [ "$TERMUX" = "1" ]; then
  if ! command -v bun >/dev/null 2>&1; then
    log "Installing bun (Termux package)..."
    pkg install -y bun
  fi
else
  if ! command -v bun >/dev/null 2>&1; then
    log "Installing bun..."
    curl -fsSL https://bun.sh/install | bash
    # The bun installer honors $BUN_INSTALL over $HOME; export the actual
    # install dir so the check below passes in both cases.
    export PATH="${BUN_INSTALL:-$HOME/.bun}/bin:$PATH"
  fi
fi
command -v bun >/dev/null 2>&1 || { echo "bun install failed" >&2; exit 1; }

# 3. BUN_OPTIONS — proot's link2symlink converts hardlinks to .l2s symlinks,
#    which breaks bunx and bun install. Only needed under proot; on a normal
#    system the default hardlink backend is faster. Irrelevant on Termux,
#    where hardlinks work natively.
if [ "$TERMUX" != "1" ] && command -v proot >/dev/null 2>&1; then
  if ! grep -q 'BUN_OPTIONS' "$HOME/.bashrc" 2>/dev/null; then
    log "Adding BUN_OPTIONS=--backend=copyfile to ~/.bashrc..."
    cat >> "$HOME/.bashrc" <<'EOF'

# bun: proot link2symlink breaks hardlinks; force copyfile backend.
export BUN_OPTIONS="--backend=copyfile"
EOF
  fi
  export BUN_OPTIONS="--backend=copyfile"
fi

# 4. opencode — the application itself. Upstream ships no Android binary and
#    the npm postinstall fails on Termux, so a native aarch64 build is used
#    there. bd-loser/opencode-bionic is preferred: it tracks upstream every
#    12 hours, while guysoft/opencode-termux lags behind. The bionic build
#    is a single self-contained binary (needs only libc/libdl/libm), so no
#    shared libraries are copied; guysoft stays as a fallback.
install_opencode_bionic() {
  log "Installing opencode (Termux native build from bd-loser/opencode-bionic)..."
  local deb_url tmpdir
  deb_url="$(curl -fsSL https://api.github.com/repos/bd-loser/opencode-bionic/releases/latest \
    | grep -o 'https://[^"]*_aarch64\.deb' | head -n1 || true)"
  [ -n "$deb_url" ] || return 1
  tmpdir="$(mktemp -d)"
  if curl -fsSL "$deb_url" -o "$tmpdir/opencode.deb" && dpkg -i "$tmpdir/opencode.deb"; then
    rm -rf "$tmpdir"
    return 0
  fi
  rm -rf "$tmpdir"
  return 1
}

# Fallback: the older guysoft/opencode-termux build. Its release bundles
# opencode.bin plus shared libraries; libc++_shared.so is deliberately NOT
# copied (see the comment in the loop below).
install_opencode_guysoft() {
  log "Installing opencode (Termux native build from guysoft/opencode-termux)..."
  local asset_url tmpdir lib
  asset_url="$(curl -fsSL https://api.github.com/repos/guysoft/opencode-termux/releases/latest \
    | grep -o 'https://[^"]*android-aarch64\.zip' | head -n1 || true)"
  if [ -z "$asset_url" ]; then
    echo "No android-aarch64.zip asset found in guysoft/opencode-termux releases." >&2
    return 1
  fi
  tmpdir="$(mktemp -d)"
  if ! curl -fsSL "$asset_url" -o "$tmpdir/opencode.zip"; then
    rm -rf "$tmpdir"
    return 1
  fi
  if ! unzip -q "$tmpdir/opencode.zip" -d "$tmpdir/opencode"; then
    rm -rf "$tmpdir"
    return 1
  fi
  mkdir -p "$PREFIX/bin" "$PREFIX/libexec/opencode" "$PREFIX/lib"
  mv "$tmpdir/opencode/opencode" "$PREFIX/bin/opencode"
  chmod +x "$PREFIX/bin/opencode"
  mv "$tmpdir/opencode/opencode.bin" "$PREFIX/libexec/opencode/opencode.bin"
  chmod +x "$PREFIX/libexec/opencode/opencode.bin"
  # Copy the shared libraries the opencode binary needs. libc++_shared.so
  # is deliberately NOT copied: the release bundles its own copy built
  # against an older NDK, and overwriting $PREFIX/lib/libc++_shared.so
  # (owned by the Termux libc++ package) drops symbols that libplacebo.so
  # needs, breaking ffmpeg/pipewire/chromium with "cannot locate symbol"
  # link errors. The opencode binaries only need libc/libdl/libm anyway.
  for lib in libtagfix.so libopentui.so librust_pty_arm64.so; do
    if [ -f "$tmpdir/opencode/$lib" ]; then
      mv "$tmpdir/opencode/$lib" "$PREFIX/lib/"
    else
      warn "Missing $lib in opencode release; skipping."
    fi
  done
  rm -rf "$tmpdir"
}

if [ "$TERMUX" = "1" ]; then
  # Upgrade path: an earlier guysoft install leaves opencode.bin and shared
  # libraries behind; remove them so the up-to-date bionic build replaces
  # the old binary.
  if [ -f "$PREFIX/libexec/opencode/opencode.bin" ]; then
    log "Removing old guysoft opencode install before upgrading..."
    rm -f "$PREFIX/bin/opencode"
    rm -rf "$PREFIX/libexec/opencode"
    rm -f "$PREFIX/lib/libtagfix.so" "$PREFIX/lib/libopentui.so" "$PREFIX/lib/librust_pty_arm64.so"
  fi
  if ! command -v opencode >/dev/null 2>&1; then
    if [ "$(uname -m)" != "aarch64" ]; then
      echo "The Termux opencode build only supports aarch64; got $(uname -m)." >&2
      exit 1
    fi
    if ! install_opencode_bionic; then
      warn "opencode-bionic install failed; falling back to guysoft/opencode-termux..."
      install_opencode_guysoft
    fi
  fi
else
  if ! command -v opencode >/dev/null 2>&1; then
    log "Installing opencode..."
    curl -fsSL https://opencode.ai/install | bash
    export PATH="$HOME/.opencode/bin:$PATH"
  fi
fi
command -v opencode >/dev/null 2>&1 || { echo "opencode install failed" >&2; exit 1; }

# 4b. PATH for future shells. On a fresh distro (e.g. a new Arch WSL2) there
#     is no ~/.bashrc, so the bun and opencode installers skip their PATH
#     setup and the binaries are only reachable in the current shell. Write
#     the exports ourselves, creating ~/.bashrc when missing; the grep checks
#     make this idempotent across re-runs.
if [ "$TERMUX" != "1" ]; then
  rc="$HOME/.bashrc"
  [ -f "$rc" ] || touch "$rc"
  if ! grep -q 'BUN_INSTALL' "$rc" 2>/dev/null; then
    log "Adding bun to PATH in ~/.bashrc..."
    cat >> "$rc" <<'EOF'

# bun
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
export PATH="$BUN_INSTALL/bin:$PATH"
EOF
  fi
  if ! grep -q '\.opencode/bin' "$rc" 2>/dev/null; then
    log "Adding opencode to PATH in ~/.bashrc..."
    cat >> "$rc" <<'EOF'

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
EOF
  fi
fi

# 5. Config directory: clone, update, or back up and replace.
if [ -n "$SCRIPT_DIR" ] && [ "$SCRIPT_DIR" = "$CONFIG_DIR" ]; then
  log "Running from inside the config repo; skipping clone."
  cd "$CONFIG_DIR"
elif [ -d "$CONFIG_DIR/.git" ]; then
  remote="$(git -C "$CONFIG_DIR" remote get-url origin 2>/dev/null || true)"
  if [ "$remote" = "$REPO_URL" ]; then
    log "Updating existing config repo..."
    # Local modifications (e.g. the per-user path rewrites below) make a
    # fast-forward pull fail; warn and keep the existing checkout instead of
    # aborting the whole install.
    if ! git -C "$CONFIG_DIR" pull --ff-only; then
      warn "git pull failed (local modifications?); keeping the existing checkout."
    fi
  else
    backup_dir="${CONFIG_DIR}.bak-$(date +%Y%m%d-%H%M%S)"
    warn "Existing config has a different origin; backing it up to $backup_dir"
    mv "$CONFIG_DIR" "$backup_dir"
    git clone "$REPO_URL" "$CONFIG_DIR"
  fi
elif [ -d "$CONFIG_DIR" ]; then
  backup_dir="${CONFIG_DIR}.bak-$(date +%Y%m%d-%H%M%S)"
  warn "Existing config directory found; backing it up to $backup_dir"
  mv "$CONFIG_DIR" "$backup_dir"
  git clone "$REPO_URL" "$CONFIG_DIR"
else
  log "Cloning config repo..."
  git clone "$REPO_URL" "$CONFIG_DIR"
fi
cd "$CONFIG_DIR"

# 6. package.json is gitignored, so recreate it when missing. allowScripts
#    pre-approves the msgpackr-extract native build so npm 11.6+ (which
#    blocks dependency install scripts by default) installs without warnings.
if [ ! -f package.json ]; then
  log "Creating package.json..."
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
fi

# 7. Install dependencies (plugin SDK) with bun on every platform, including
#    Termux. The allowScripts field in package.json is npm-specific and
#    ignored by bun; it is harmless to keep. On Termux the bun cache is
#    pre-warmed with the pinned MCP server so the first launch is fast.
log "Installing dependencies (bun install)..."
if [ "$TERMUX" = "1" ]; then
  if ! bun install; then
    warn "bun install failed; retrying with BUN_OPTIONS=--backend=copyfile..."
    if ! BUN_OPTIONS="--backend=copyfile" bun install; then
      echo "bun install failed on Termux. Try: pkg reinstall bun, then re-run this script." >&2
      exit 1
    fi
  fi
  log "Pre-warming the bun cache with @playwright/mcp@$MCP_VERSION..."
  if ! bunx --bun "@playwright/mcp@$MCP_VERSION" --help >/dev/null 2>&1; then
    warn "@playwright/mcp@$MCP_VERSION failed to start; the MCP server may fail at runtime."
  fi
else
  bun install
fi

# 8. Playwright browser used by the MCP server. Install through the MCP
#    package itself so the chromium revision always matches the
#    playwright-core bundled with @playwright/mcp; a bare `bunx playwright
#    install` can drift to a different revision and break the MCP server.
if [ "$TERMUX" = "1" ]; then
  log "Installing chromium from the Termux x11-repo..."
  pkg install -y x11-repo
  pkg install -y chromium
  # ffmpeg is a chromium dependency whose post-install runs the ffmpeg
  # binary; a broken libc++_shared.so (e.g. overwritten by a release copy)
  # makes it fail with "cannot locate symbol". Smoke-test it as a cheap
  # indicator that the C++ runtime is intact.
  if command -v ffmpeg >/dev/null 2>&1; then
    if ffmpeg -version >/dev/null 2>&1; then
      log "ffmpeg OK."
    else
      warn "ffmpeg is broken; libc++_shared.so may be corrupted. Run: pkg reinstall -y libc++ && pkg install -f -y"
    fi
  fi
else
  log "Installing Playwright chromium browser (matching @playwright/mcp@$MCP_VERSION_LINUX)..."
  bunx "@playwright/mcp@$MCP_VERSION_LINUX" install-browser chromium
fi

# 9. System dependencies for the chromium browser. The MCP server launches
#    a real chromium binary, which needs shared libraries that a minimal
#    container does not ship. Playwright's own `install-deps` only covers
#    Debian/Ubuntu and Alpine, so the lists are maintained here per distro.
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

# On Termux the chromium package pulls its own bionic dependencies, so the
# distro library lists above are skipped.
if [ "$TERMUX" != "1" ]; then
  install_playwright_system_deps
fi

# 10. Verify the chromium binary resolves every shared library it needs.
#     On Termux the binary is the native chromium-browser from the x11-repo
#     and ldd is not part of the default install, so this check is skipped.
if [ "$TERMUX" = "1" ]; then
  CHROME_BIN="$PREFIX/bin/chromium-browser"
else
  CHROME_BIN="$(find "$HOME/.cache/ms-playwright" -path '*/chrome-linux*/chrome' 2>/dev/null | head -n1 || true)"
  # Headless mode launches the separate chromium-headless-shell build, so
  # check its libraries too, not just the full chromium build.
  CHROME_HEADLESS_SHELL="$(find "$HOME/.cache/ms-playwright" -path '*/chrome-headless-shell-linux*/chrome-headless-shell' 2>/dev/null | head -n1 || true)"
  for bin in "$CHROME_BIN" "$CHROME_HEADLESS_SHELL"; do
    if [ -n "$bin" ] && command -v ldd >/dev/null 2>&1; then
      missing="$(ldd "$bin" 2>/dev/null | awk '/not found/{print $1}' | sort -u || true)"
      if [ -n "$missing" ]; then
        warn "Chromium still missing libraries: $missing"
      else
        log "Chromium shared libraries resolved ($(basename "$bin"))."
      fi
    fi
  done
fi

# 11. Smoke test: launch the exact chromium binary the MCP server uses.
#     Headless mode uses the chromium-headless-shell build; prefer it and
#     fall back to the full chromium build (which is what Termux uses).
SMOKE_BIN="${CHROME_HEADLESS_SHELL:-$CHROME_BIN}"
if [ -n "$SMOKE_BIN" ] && [ -x "$SMOKE_BIN" ]; then
  log "Smoke-testing chromium launch ($(basename "$SMOKE_BIN"))..."
  if "$SMOKE_BIN" --headless --no-sandbox --disable-gpu --disable-dev-shm-usage \
      --dump-dom "data:text/html,<h1>playwright-ok</h1>" 2>/dev/null | grep -q "playwright-ok"; then
    log "Chromium launched successfully."
  else
    warn "Chromium smoke test failed; the MCP server may not start."
  fi
fi

# 12. On Termux the repo's bun-based MCP command is rewritten to run under
#     bun (bunx --bun) against the native chromium binary, pinned to
#     @playwright/mcp@$MCP_VERSION. That version bundles playwright-core
#     1.64.0-alpha-2026-09-14, whose registryDirectory fix allows Android;
#     the three remaining platform checks are bypassed with environment
#     variables:
#       - PWMCP_PROFILES_DIR_FOR_TEST: createUserDataDir calls
#         defaultCacheDirectory() directly (coreBundle.js:74015);
#       - PWTEST_SERVER_REGISTRY: serverRegistry._browsersDir() calls
#         registryDirectory2() directly (coreBundle.js:52735);
#       - PWTEST_DAEMON_SESSION_DIR: createClientInfo() -> daemonProfilesDir()
#         -> baseDaemonDir() -> computeBaseDaemonDir() throws for android
#         (coreBundle.js:71413).
#     Idempotent: the sed replacement rewrites the command to the same value
#     once done, and the environment block is only rewritten when the
#     PWMCP_PROFILES_DIR_FOR_TEST marker is missing.
if [ "$TERMUX" = "1" ]; then
  log "Rewriting mcp.playwright command for Termux (bunx --bun + native chromium)..."
  sed -i "s|^\(\s*\)\"command\": \[\".*@playwright/mcp.*|\1\"command\": [\"bunx\", \"--bun\", \"@playwright/mcp@$MCP_VERSION\", \"--headless\", \"--no-sandbox\", \"--executable-path\", \"$PREFIX/bin/chromium-browser\", \"--config\", \"$CONFIG_DIR/playwright-mcp.json\"],|" opencode.jsonc
  if ! grep -q 'PWMCP_PROFILES_DIR_FOR_TEST' opencode.jsonc; then
    # Drop any existing environment block (upgrade from an older installer
    # that only set PLAYWRIGHT_BROWSERS_PATH), then append the full block.
    # Assumes a single environment block in the file, which holds for the
    # config this repo ships.
    sed -i '/"environment": {/,/},/d' opencode.jsonc
    sed -i '/"command": \["bunx"/a\      "environment": {\n        "PLAYWRIGHT_BROWSERS_PATH": "0",\n        "PWMCP_PROFILES_DIR_FOR_TEST": "'"$HOME"'/.cache/ms-playwright-mcp",\n        "PWTEST_SERVER_REGISTRY": "'"$HOME"'/.cache/ms-playwright/b",\n        "PWTEST_DAEMON_SESSION_DIR": "'"$HOME"'/.cache/ms-playwright/daemon"\n      },' opencode.jsonc
  fi
fi

# 12b. On Linux/macOS the mcp.playwright command is rewritten for the local
#      platform: the committed config ships a Termux command (bunx --bun,
#      --executable-path, Termux --config path) that must not survive here.
#      The version is pinned to the same @playwright/mcp used for the browser
#      install in step 8, so the chromium revision the server launches always
#      matches the one install.sh downloaded. Without the pin, `@latest`
#      resolves at opencode startup to a newer version whose playwright-core
#      expects a different browser revision. The Termux environment block
#      (PLAYWRIGHT_BROWSERS_PATH and the PWTEST/PWMCP Android workarounds) is
#      dropped too: on Linux those variables point at nonexistent
#      /data/data/com.termux paths and break browser discovery.
if [ "$TERMUX" != "1" ]; then
  if grep -q '"@playwright/mcp@' opencode.jsonc; then
    log "Rewriting mcp.playwright command for Linux/macOS (@playwright/mcp@$MCP_VERSION_LINUX)..."
    sed -i "s|^\(\s*\)\"command\": \[.*\"@playwright/mcp@[^\" ]*\".*|\1\"command\": [\"bun\", \"x\", \"@playwright/mcp@$MCP_VERSION_LINUX\", \"--headless\", \"--no-sandbox\", \"--config\", \"$CONFIG_DIR/playwright-mcp.json\"],|" opencode.jsonc
    sed -i '/"environment": {/,/},/d' opencode.jsonc
  else
    warn "Could not find the @playwright/mcp command in opencode.jsonc; pin it manually to @playwright/mcp@$MCP_VERSION_LINUX."
  fi
fi

# 13. Fix absolute paths in opencode.jsonc for the current user. The committed
#     config ships Termux paths (/data/data/com.termux/files/home and
#     /data/data/com.termux/files/usr); rewrite them for this machine. The
#     legacy /home/azrial form is handled too.
if grep -q "/data/data/com.termux" opencode.jsonc; then
  log "Adjusting Termux absolute paths in opencode.jsonc to $HOME..."
  sed -i "s|/data/data/com.termux/files/home|$HOME|g; s|/data/data/com.termux/files/usr|/usr|g" opencode.jsonc
fi
if grep -q "/home/azrial" opencode.jsonc; then
  log "Adjusting legacy absolute paths in opencode.jsonc to $HOME..."
  sed -i "s|/home/azrial|$HOME|g" opencode.jsonc
fi

# 14. Done.
log "Installation complete."
echo
echo "Next step: quit and restart opencode so the new config is loaded."
echo "Config directory: $CONFIG_DIR"