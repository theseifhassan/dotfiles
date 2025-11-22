#!/bin/sh
# Theme toggle script for dwm, neovim, and tmux
# Uses dmenu to select between dark and light gruvbox themes

# dmenu with gruvbox dark colors (matches current theme)
choice=$(printf "dark\nlight" | dmenu -p "Theme:" \
    -nb "#282828" -nf "#ebdbb2" \
    -sb "#458588" -sf "#ebdbb2")

# Exit if no selection
[ -z "$choice" ] && exit 0

XRESOURCES="${XDG_CONFIG_HOME:-$HOME/.config}/x11/xresources"

if [ "$choice" = "dark" ]; then
    # 1. Update gsettings
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        
    # 2. Update tmux symlink
    ln -sf "$HOME/.config/tmux/theme-dark.conf" "$HOME/.config/tmux/theme.conf"
    
else
    # 1. Update gsettings
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
    
    # 2. Update tmux symlink
    ln -sf "$HOME/.config/tmux/theme-light.conf" "$HOME/.config/tmux/theme.conf"
    
fi

# 3. Reload Xresources
xrdb -merge "$XRESOURCES"

# 4. Reload tmux (all sessions)
tmux source-file "$HOME/.config/tmux/tmux.conf" 2>/dev/null

# 5. Notify user
notify-send --icon=blank "Theme switched to $choice" -t 2000
