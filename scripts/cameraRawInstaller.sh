#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/sharedFuncs.sh"

main() {
  banner
  echo "Adobe Camera Raw (optional)."

  local default_dir="$WINETRICKS_CACHE/AdobeCameraRaw"
  mkdir -p "$default_dir"
  local installer
  installer="$(ask_for_file "Provide path to Adobe Camera Raw installer (.exe/.msi):" "$default_dir")"

  echo "Running ACR installer..."
  WINEPREFIX="$WINEPREFIX" wine "$installer"

  echo "ACR installation finished."
}

main "$@"
