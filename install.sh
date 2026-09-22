#!/bin/bash
set -euo pipefail

TARGET_DIR="$HOME/.config/omarchy/plugins/yuri.cmdpp"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Installing Command++ Plugin (yuri.cmdpp) ==="

# 1. Ensure cmdpp binary is installed
if ! command -v cmdpp >/dev/null 2>&1; then
  echo "Installing cmdpp via official install script..."
  curl -fsSL https://raw.githubusercontent.com/hyuricane/cmdpp/master/install.sh | bash
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v cmdpp >/dev/null 2>&1; then
  echo "Warning: cmdpp binary not found in PATH. Ensure ~/.local/bin is in your PATH." >&2
fi

# 2. Deploy plugin files into ~/.config/omarchy/plugins/yuri.cmdpp
mkdir -p "$TARGET_DIR"
cp -f "$REPO_DIR/manifest.json" "$TARGET_DIR/"
cp -f "$REPO_DIR/Service.qml" "$TARGET_DIR/"
cp -f "$REPO_DIR/cmdpp-bindings.lua" "$TARGET_DIR/"
cp -f "$REPO_DIR/README.md" "$TARGET_DIR/" 2>/dev/null || true
cp -f "$REPO_DIR/LICENSE" "$TARGET_DIR/" 2>/dev/null || true

# 3. Validate plugin manifest
echo "Validating plugin..."
omarchy plugin validate "$TARGET_DIR"

# 4. Rescan and enable plugin in Omarchy shell
echo "Registering plugin in Omarchy..."
omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
if omarchy plugin list --json 2>/dev/null | grep -q '"id":"yuri.cmdpp"'; then
  omarchy plugin enable yuri.cmdpp >/dev/null 2>&1 || true
fi

# 5. Install desktop entry
if [[ -f "$REPO_DIR/applications/Command++.desktop" ]]; then
  mkdir -p "$HOME/.local/share/applications"
  cp -f "$REPO_DIR/applications/Command++.desktop" "$HOME/.local/share/applications/"
fi

# 6. Ensure keybinding is in ~/.config/hypr/bindings.lua
BINDINGS_FILE="$HOME/.config/hypr/bindings.lua"

if [[ -f "$BINDINGS_FILE" ]]; then
  if ! grep -Fq "yuri.cmdpp/cmdpp-bindings.lua" "$BINDINGS_FILE"; then
    echo "Adding Command++ binding to $BINDINGS_FILE..."
    cat << 'EOF' >> "$BINDINGS_FILE"

-- Command++
local cmdpp_file = (os.getenv("HOME") or "") .. "/.config/omarchy/plugins/yuri.cmdpp/cmdpp-bindings.lua"
local cmdpp_handle = io.open(cmdpp_file, "r")
if cmdpp_handle then
  cmdpp_handle:close()
  dofile(cmdpp_file)
end
EOF
  fi
fi

# 7. Reload Hyprland bindings
if command -v hyprctl >/dev/null 2>&1; then
  echo "Reloading Hyprland..."
  hyprctl reload >/dev/null 2>&1 || true
fi

echo "=== Command++ installed successfully! ==="
echo "Press SUPER + SHIFT + H to open Command++."
