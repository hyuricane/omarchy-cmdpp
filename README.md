# Command++ (`yuri.cmdpp`)

A fast, keyboard-driven command palette and workflow manager plugin for [Omarchy](https://omarchy.org/) and Hyprland, wrapping the [`cmdpp`](https://github.com/hyuricane/cmdpp) TUI application.

Press **`SUPER + SHIFT + H`** to open the interactive Command++ palette anywhere on your desktop.

---

## Features

- **Global Shortcut**: Summon instantly with `SUPER + SHIFT + H`.
- **Pure TUI**: Direct wrapper around `cmdpp` BubbleTea TUI — lightweight, fast, and no duplicate GUI overhead.
- **Floating Modal Window**: Centered floating terminal window configured specifically for Hyprland.
- **Interactive & Persistent Execution**: Seamlessly run long-running commands, SSH sessions, tunnels, and interactive TUI tools without fear of accidental closure.
- **cmdpp Capabilities**:
  - Real-time search & fuzzy filtering across command names, scripts, and descriptions.
  - In-TUI command management: Add (`a`), Edit (`e`), Delete (`d` or `x`).
  - Copy command to clipboard with `c`.
  - Execution counter & last-run history tracking.
- **App Launcher Integration**: Ships with a `.desktop` entry for Omarchy's menu/app launcher (`SUPER + SPACE`).

---

## Requirements

- [Omarchy](https://omarchy.org/) Linux with Hyprland
- [`cmdpp`](https://github.com/hyuricane/cmdpp) (installed automatically by `install.sh` if missing)
- Standard Omarchy terminal (`foot`, `ghostty`, `alacritty`, or `kitty` via `xdg-terminal-exec`)

---

## Installation

### Option 1: Using the Installer Script
Clone or download this repository, then run:
```bash
git clone https://github.com/hyuricane/omarchy-cmdpp.git
cd omarchy-cmdpp
./install.sh
```

### Option 2: Using the Omarchy CLI
```bash
omarchy plugin add https://github.com/hyuricane/omarchy-cmdpp.git --enable
```
Then ensure the following line is in `~/.config/hypr/bindings.lua`:
```lua
dofile(os.getenv("HOME") .. "/.config/omarchy/plugins/yuri.cmdpp/cmdpp-bindings.lua")
```
And reload Hyprland:
```bash
hyprctl reload
```

---

## Keyboard Shortcuts

### Global
| Shortcut | Action |
|---|---|
| `SUPER + SHIFT + H` | Open Command++ Floating Palette |

### Inside Command++ TUI
| Key | Action |
|---|---|
| `↑` / `↓` or `k` / `j` | Navigate commands |
| `Enter` | Execute selected command |
| `/` | Focus search / filter bar |
| `a` | Add new command dialog |
| `e` | Edit selected command |
| `d` or `x` | Delete selected command |
| `c` | Copy command to clipboard |
| `Esc` | Clear filter / cancel dialog |
| `q` / `Ctrl+C` | Quit Command++ |

---

## Uninstallation

```bash
omarchy plugin remove yuri.cmdpp
```
Remove the `dofile` line from `~/.config/hypr/bindings.lua` and reload with `hyprctl reload`.

---

## License

[MIT](LICENSE)
