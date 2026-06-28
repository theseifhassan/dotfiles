# Google Workspace CLI (gws) multi-account wrapper.
# Sourced from conf.d. Wraps the real `gws` binary so an optional leading
# profile arg selects which account's credentials are used.
#
# Usage:
#   gws <args...>            # profile defaults to "personal"
#   gws personal <args...>   # explicit personal account
#   gws work <args...>       # work account
#
# Each profile gets its own isolated config dir (~/.config/gws-<profile>);
# file keyring keeps credentials self-contained per profile rather than
# colliding in the shared macOS keychain. Authenticate each once with:
#   gws auth login        (personal)
#   gws work auth login   (work)
gws() {
  local profile="personal"
  if [[ "$1" == "personal" || "$1" == "work" ]]; then
    profile="$1"
    shift
  fi
  GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws-$profile" \
  GOOGLE_WORKSPACE_CLI_KEYRING_BACKEND=file \
  command gws "$@"
}
