# shellcheck shell=bash
# True when running inside WSL (not plain Linux CI).
is_wsl() {
  [[ -n "${WSL_INTEROP:-}" || -n "${WSL_DISTRO_NAME:-}" ]] && return 0
  [[ -r /proc/version ]] && grep -qi microsoft /proc/version && return 0
  return 1
}
