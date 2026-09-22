#!/bin/bash
set -euo pipefail

TARGET_DIR="$HOME/.config/omarchy/plugins/yuri.cmdpp"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Installing Command++ Plugin (yuri.cmdpp) ==="

# 1. Deploy plugin files and wrapper into ~/.config/omarchy/plugins/yuri.cmdpp
mkdir -p "$TARGET_DIR/bin"
cp -f "$REPO_DIR/manifest.json" "$TARGET_DIR/"
cp -f "$REPO_DIR/Service.qml" "$TARGET_DIR/"
cp -f "$REPO_DIR/cmdpp-bindings.lua" "$TARGET_DIR/"
cp -f "$REPO_DIR/bin/cmdpp-wrapper" "$TARGET_DIR/bin/"
chmod +x "$TARGET_DIR/bin/cmdpp-wrapper"
cp -f "$REPO_DIR/README.md" "$TARGET_DIR/" 2>/dev/null || true
cp -f "$REPO_DIR/LICENSE" "$TARGET_DIR/" 2>/dev/null || true

# 2. Ensure cmdpp binary exists within the plugin directory
if [[ ! -x "$TARGET_DIR/bin/cmdpp" ]]; then
  if command -v cmdpp >/dev/null 2>&1; then
    echo "Copying existing cmdpp binary into plugin directory..."
    cp -f "$(command -v cmdpp)" "$TARGET_DIR/bin/cmdpp"
    chmod +x "$TARGET_DIR/bin/cmdpp"
  else
    echo "Downloading cmdpp into plugin directory..."
    curl -fsSL https://raw.githubusercontent.com/hyuricane/cmdpp/master/install.sh | BINDIR="$TARGET_DIR/bin" bash
  fi
fi

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
