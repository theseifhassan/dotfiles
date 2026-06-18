# zed-tmux — inside a Zed terminal, transparently hand off to a persistent
# tmux session (see ~/.local/bin/zed-term) so terminals and their running
# processes survive Zed restarts and SSH drops.
#
# Why the login shell and not Zed's terminal.shell setting: terminal.shell is
# ignored for remote SSH terminals (zed-industries/zed#35226), and the login
# shell is the one thing Zed reliably runs on the remote. Detect via the env
# Zed sets in its terminals (ZED_TERM=true / TERM_PROGRAM=zed).
#
# No-ops outside Zed, when already inside tmux, when the wrapper isn't present
# (e.g. thin clients without the tmux role), or when ZED_TERM_NO_TMUX is set
# (escape hatch for debugging / one-off raw shells).
if [[ ( "$ZED_TERM" == "true" || "$TERM_PROGRAM" == "zed" ) \
      && -z "$TMUX" && -z "$ZED_TERM_NO_TMUX" \
      && -x "$HOME/.local/bin/zed-term" ]]; then
  exec "$HOME/.local/bin/zed-term"
fi
