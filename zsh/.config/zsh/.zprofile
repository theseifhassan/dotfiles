# Login shell setup - runs BEFORE zshrc

# Autostart X on tty1 (Arch Wiki xinit pattern, desktop mode only)
if [ "$DOTFILES_MINIMAL" != "1" ] && [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ] && command -v startx >/dev/null 2>&1; then
    exec startx "$XINITRC"
fi
