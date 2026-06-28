# Google Cloud CLI (gcloud) multi-account wrapper.
# Sourced from conf.d. Wraps the real `gcloud` binary so an optional leading
# profile arg selects which account's credentials and config are used.
#
# Usage:
#   gcloud <args...>            # profile defaults to "personal"
#   gcloud personal <args...>   # explicit personal account
#   gcloud work <args...>       # work account
#
# Each profile gets its own isolated state dir (~/.config/gcloud-<profile>),
# keeping logged-in accounts, active project, and ADC self-contained per
# profile rather than sharing the default ~/.config/gcloud store.
# Authenticate each once with:
#   gcloud auth login        (personal)
#   gcloud work auth login   (work)
gcloud() {
  local profile="personal"
  if [[ "$1" == "personal" || "$1" == "work" ]]; then
    profile="$1"
    shift
  fi
  CLOUDSDK_CONFIG="$HOME/.config/gcloud-$profile" \
  command gcloud "$@"
}
