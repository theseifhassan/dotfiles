# Login shell setup - runs BEFORE zshrc

# Autostart X on tty1 (Arch Wiki xinit pattern)
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
    exec startx "$XINITRC"
fi
