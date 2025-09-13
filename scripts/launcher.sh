#!/usr/bin/env bash
set -euo pipefail

# shellcheck disable=SC1091
. "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)/sharedFuncs.sh"

main() {
  banner
  echo "Recreating Photoshop launcher and desktop entry..."
  create_shortcuts
  echo "Done."
}

main "$@"
