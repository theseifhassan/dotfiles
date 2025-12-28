# dotfiles

Minimal Arch Linux dotfiles with dwm, following suckless philosophy.

## Install

```sh
git clone https://github.com/theseifhassan/dotfiles ~/dotfiles
cd ~/dotfiles && ./install.sh
# reboot, then: startx
```

## Structure

```
dotfiles/
├── default/        # Base configs (don't edit)
│   ├── zsh/        # Shell defaults
│   ├── tmux/       # Tmux defaults + theme
│   ├── dunst/      # Notification defaults
│   └── x11/        # X11 defaults
├── install/
│   ├── setup.sh    # Main installer
│   ├── hardware.sh # Driver installer
│   └── packages    # Package list
├── scripts/.local/bin/
│   └── dot         # Management command
├── dwm/            # Window manager
├── dmenu/          # Launcher
└── dwmblocks/      # Status bar
```

## Commands

```sh
dot update              # Pull, recompile suckless, reload
dot link                # Symlink configs
dot packages            # Install packages
dot packages -d         # Show missing packages
dot suckless [target]   # Recompile dwm/dmenu/dwmblocks
dot hardware <type>     # Install: nvidia|bluetooth|printer|fingerprint|virtualcam
dot hardware check      # Verify driver setup
```

## Keybinds

| Key | Action |
|-----|--------|
| `mod+p` | dmenu |
| `mod+shift+enter` | terminal |
| `mod+j/k` | focus next/prev |
| `mod+h/l` | resize master |
| `mod+enter` | zoom to master |
| `mod+shift+c` | kill window |
| `mod+1-9` | switch tag |
| `mod+shift+1-9` | move to tag |
| `mod+s` | screenshot (select) |
| `mod+shift+s` | screenshot (full) |
| `mod+w` | launch webapp |
| `mod+v` | clipboard history |
| `mod+shift+q` | quit dwm |

## Stack

- **WM**: dwm (gaps, xrdb, statuscmd, center, pertag)
- **Terminal**: ghostty
- **Shell**: zsh + starship
- **Editor**: neovim (lazyvim)
- **Launcher**: dmenu
- **Notifications**: dunst
- **Compositor**: picom

## XDG

Only `~/.zshenv` and `~/.fehbg` in home. Everything else in `~/.config/`.
