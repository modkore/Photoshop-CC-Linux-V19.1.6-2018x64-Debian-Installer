#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/sharedFuncs.sh"

main() {
  banner
  if clean_confirm; then
    echo "Removing prefix: $WINEPREFIX"
    rm -rf "$WINEPREFIX"

    echo "Removing launcher + desktop entry..."
    rm -f "$HOME/.local/bin/photoshopcc2018"
    rm -f "$HOME/.local/share/applications/photoshopcc2018.desktop"
    update_desktop_db >/dev/null 2>&1 || true

    echo "Done. (Winetricks cache at $WINETRICKS_CACHE not removed.)"
  else
    echo "Aborted."
  fi
}

main "$@"
