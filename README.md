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
dot hardware <type>     # install drivers (nvidia|bluetooth|...)
dot hardware check      # verify driver setup
```

## Keybinds

### Window Management

| Key | Action |
| --- | ------ |
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
| --- | ------ |
| `mod+t` | tile |
| `mod+f` | monocle |
| `mod+m` | spiral |

### Apps

| Key | Action |
| --- | ------ |
| `mod+p` | dmenu (includes web apps) |
| `mod+shift+enter` | terminal |
| `mod+s` | screenshot (select) |
| `mod+shift+s` | screenshot (full) |
| `mod+shift+w` | manage web apps (create/remove) |
| `mod+shift+a` | audio switcher (sinks/sources) |

### System

| Key | Action |
| --- | ------ |
| `` mod+` `` | toggle statusbar (minimal/full) |
| `mod+shift+b` | restart dwmblocks |
| `mod+F5` | reload xresources |
| `mod+shift+q` | quit dwm |
| `mod+ctrl+shift+q` | restart dwm |

### Media Keys

Volume and media keys work as expected.

## Machine-Specific Config

For per-machine settings, create local override files in `~/.config/x11/`:

| File | Purpose |
| ---- | ------- |
| `xresources.local` | X resources (DPI, colors) |
| `xprofile.local` | Startup commands (xrandr, etc) |

Example `xresources.local`:

```txt
Xft.dpi: 192
```

Example `xprofile.local`:

```sh
xrandr --dpi 192
```

These files are gitignored and loaded automatically.

## Structure

```txt
dotfiles/
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

## SSH Keys (1Password)

SSH keys are managed via **1Password SSH Agent** - no more copying keys
between machines.

### First-Time Setup

1. **Install 1Password** and sign in

2. **Enable SSH Agent** in 1Password:
   - Settings → Developer → Turn on "SSH Agent"

3. **Add your SSH key to 1Password**:
   - Create new item → SSH Key
   - Either import existing key or generate new one
   - For GitHub: copy public key and add to github.com/settings/keys

4. **Run `dot link`** - this creates `~/.ssh/config` pointing to 1Password agent

### New Machine Setup

On a new machine, just:

1. Install 1Password and sign in
2. Enable SSH Agent in settings
3. Run `dot link`
4. Done - your SSH keys are available

### Multiple Keys (Personal + Work)

Keys are mapped to hosts via `~/.config/1Password/ssh/agent.toml`:

```toml
# Personal GitHub
[[ssh-keys]]
item = "GitHub Personal"    # Must match item name in 1Password
vault = "Personal"          # Vault name (case-sensitive)

# Work GitHub
[[ssh-keys]]
item = "GitHub Work"
vault = "Work"              # Can be in a different vault
host = "work.github"        # Use: git@work.github:org/repo.git
```

**Usage:**

```bash
# Personal repos (default)
git clone git@github.com:youruser/repo.git

# Work repos (use work.github alias)
git clone git@work.github:company/repo.git
```

Update the key names in `agent.toml` to match your 1Password item titles.

## Private Fonts

Paid/private fonts are stored in a separate private repo and cloned
automatically during `dot link`.

If you have access (SSH key configured), fonts are installed to
`~/.local/share/fonts`.

## Stack

- **WM**: dwm (gaps, pertag, xrdb, statuscmd, center)
- **Terminal**: ghostty
- **Shell**: zsh + starship
- **Editor**: neovim (lazyvim)
- **Launcher**: dmenu
- **Notifications**: dunst
- **Compositor**: picom
- **Secrets**: 1Password (SSH agent)
