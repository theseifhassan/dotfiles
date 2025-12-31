# dotfiles

Minimal Arch Linux dotfiles with dwm.

## Quick Start

```sh
git clone https://github.com/theseifhassan/dotfiles ~/dotfiles
cd ~/dotfiles && ./install.sh
# reboot, then: startx
```

## Usage

All management through the `dot` command:

```sh
dot update              # pull, recompile suckless, reload
dot link                # symlink configs
dot packages            # install packages
dot packages -d         # show missing packages
dot suckless [target]   # recompile dwm/dmenu/dwmblocks
dot hardware <type>     # install drivers: nvidia|bluetooth|printer|fingerprint|virtualcam|all
dot hardware check      # verify driver setup
dot monitor save <name> # save current display profile
dot monitor switch <name> # switch to a display profile
dot monitor list        # list available profiles
```

## Keybinds

### Window Management
| Key | Action |
|-----|--------|
| `mod+j/k` | focus next/prev |
| `mod+h/l` | resize master |
| `mod+shift+h/l` | resize stack |
| `mod+enter` | zoom to master |
| `mod+shift+c` | kill window |
| `mod+space` | toggle layout |
| `mod+shift+space` | toggle floating |
| `mod+b` | toggle bar |
| `mod+1-9` | switch tag |
| `mod+shift+1-9` | move to tag |
| `mod+tab` | previous tag |
| `mod+,/.` | focus prev/next monitor |
| `mod+shift+,/.` | move to prev/next monitor |

### Layouts
| Key | Action |
|-----|--------|
| `mod+t` | tile |
| `mod+f` | monocle |
| `mod+m` | spiral |

### Apps
| Key | Action |
|-----|--------|
| `mod+p` | dmenu |
| `mod+shift+enter` | terminal |
| `mod+s` | screenshot (select) |
| `mod+shift+s` | screenshot (full) |
| `mod+w` | launch webapp |
| `mod+shift+w` | manage webapps |
| `mod+v` | clipboard history |
| `mod+shift+a` | audio settings |
| `mod+n` | network (impala) |
| `mod+shift+m` | system monitor (btop) |
| `mod+shift+p` | power profile menu |

### System
| Key | Action |
|-----|--------|
| `mod+`` | toggle statusbar (minimal/full) |
| `mod+shift+b` | restart dwmblocks |
| `mod+F5` | reload xresources |
| `mod+shift+q` | quit dwm |
| `mod+ctrl+shift+q` | restart dwm |

### Media Keys
Volume, brightness, and media keys work as expected.

## Machine-Specific Config

For per-machine settings, create local override files in `~/.config/x11/`:

| File | Purpose |
|------|---------|
| `xresources.local` | X resources (DPI, colors) |
| `xprofile.local` | Startup commands (xrandr, etc) |

Example `xresources.local`:
```
Xft.dpi: 192
```

Example `xprofile.local`:
```sh
xrandr --dpi 192
```

These files are gitignored and loaded automatically.

## Multi-Monitor / Docking

Uses [autorandr](https://github.com/phillipberndt/autorandr) for automatic display switching with per-profile DPI.

### Initial Setup

1. **Create laptop profile** (with only laptop screen):
   ```sh
   dot monitor save laptop
   ```

2. **Create docked profile** (connect external monitor, disable laptop):
   ```sh
   xrandr --output eDP-1 --off --output DP-2 --primary --auto
   dot monitor save docked
   ```

### How It Works

- Profiles auto-switch when displays connect/disconnect (via udev)
- DPI adjusts automatically: `laptop` = 96, `docked` = 192
- dwm, dwmblocks, and dunst restart to apply new DPI
- Manual switch: `dot monitor switch <profile>`

## Structure

```
dotfiles/
├── default/           # base configs (source these, don't edit)
├── install/
│   ├── setup.sh       # main installer
│   ├── hardware.sh    # driver installer
│   └── packages       # package list
├── scripts/.local/bin/
│   └── dot            # management command
├── dwm/               # window manager
├── dmenu/             # launcher
└── dwmblocks/         # status bar
```

### Layered Config

User configs source defaults then override:
```sh
# ~/.config/zsh/.zshrc
source "$DOTS_DEFAULT/zsh/rc"
# your overrides here
```

## Stack

- **WM**: dwm (gaps, pertag, xrdb, statuscmd, center)
- **Terminal**: ghostty
- **Shell**: zsh + starship
- **Editor**: neovim (lazyvim)
- **Launcher**: dmenu
- **Notifications**: dunst
- **Compositor**: picom
