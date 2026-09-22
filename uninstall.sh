#!/bin/bash
set -euo pipefail

TARGET_DIR="$HOME/.config/omarchy/plugins/yuri.cmdpp"
DESKTOP_FILE="$HOME/.local/share/applications/Command++.desktop"
BINDINGS_FILE="$HOME/.config/hypr/bindings.lua"

echo "=== Uninstalling Command++ Plugin (yuri.cmdpp) ==="

# 1. Disable in Omarchy shell
if command -v omarchy >/dev/null 2>&1; then
  omarchy plugin disable yuri.cmdpp >/dev/null 2>&1 || true
fi

# 2. Remove plugin directory and backup directories
rm -rf "$TARGET_DIR"
rm -rf "$HOME/.config/omarchy/plugins/.yuri.cmdpp.bak."* 2>/dev/null || true

# 3. Rescan Omarchy plugins
if command -v omarchy-shell >/dev/null 2>&1; then
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true
fi

# 4. Remove desktop entry
if [[ -f "$DESKTOP_FILE" ]]; then
  rm -f "$DESKTOP_FILE"
fi

# 5. Clean up ~/.config/hypr/bindings.lua
if [[ -f "$BINDINGS_FILE" ]] && grep -Fq "yuri.cmdpp/cmdpp-bindings.lua" "$BINDINGS_FILE"; then
  echo "Cleaning up $BINDINGS_FILE..."
  # Remove the Command++ block safely
  python3 -c "
import pathlib
path = pathlib.Path('$BINDINGS_FILE')
content = path.read_text()
lines = content.splitlines()
out = []
skip = False
for line in lines:
    if '-- Command++' in line:
        skip = True
        continue
    if skip:
        if 'dofile(cmdpp_file)' in line or 'cmdpp-bindings.lua' in line or line.strip() == 'end':
            if line.strip() == 'end' or 'dofile' in line:
                skip = False
            continue
    out.append(line)
path.write_text('\n'.join(out) + '\n')
" 2>/dev/null || true
fi

# 6. Reload Hyprland
if command -v hyprctl >/dev/null 2>&1; then
  echo "Reloading Hyprland..."
  hyprctl reload >/dev/null 2>&1 || true
  hyprctl configerrors
fi

echo "=== Command++ uninstalled cleanly! ==="
