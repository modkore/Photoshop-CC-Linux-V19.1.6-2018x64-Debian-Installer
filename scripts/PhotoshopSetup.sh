#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/sharedFuncs.sh"

main() {
  banner
  echo "Step 1/3: Installing common Winetricks components..."
  winetricks_install_common

  echo "Step 2/3: Locate Photoshop CC 2018 installer (v19.1.6 recommended)."
  local default_dir="$WINETRICKS_CACHE/AdobePhotoshopCC2018"
  mkdir -p "$default_dir"
  local installer
  installer="$(ask_for_file "Provide path to Photoshop CC 2018 installer (.exe/.msi):" "$default_dir")"

  echo "Running installer under prefix: $WINEPREFIX"
  WINEPREFIX="$WINEPREFIX" wine "$installer"

  echo "Step 3/3: Creating shortcuts..."
  create_shortcuts

  echo "Done. You can run Photoshop with: photoshopcc2018"
}

main "$@"
