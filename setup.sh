#!/usr/bin/env bash
set -euo pipefail

# Resolve this script’s directory safely (even if called via symlink)
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Source shared helpers
# shellcheck disable=SC1091
. "$SCRIPT_DIR/sharedFuncs.sh"

main() {
  banner

  ensure_deps
  ensure_cache_dir
  ensure_prefix

  cat <<'MENU'
[1] Install Photoshop CC 2018 (v19.1.6)
[2] Install Adobe Camera Raw (optional)
[3] Open winecfg (Photoshop prefix)
[4] Uninstall Photoshop CC (remove prefix + shortcuts)
[5] Exit
MENU

  read -rp "Choose an option [1-5]: " answer
  case "${answer:-}" in
    1)
      run_script "$SCRIPT_DIR/PhotoshopSetup.sh"
      ;;
    2)
      run_script "$SCRIPT_DIR/cameraRawInstaller.sh"
      ;;
    3)
      run_script "$SCRIPT_DIR/winecfg.sh"
      ;;
    4)
      run_script "$SCRIPT_DIR/uninstaller.sh"
      ;;
    5|q|Q|exit)
      echo "Bye."
      exit 0
      ;;
    *)
      echo "Invalid choice."
      exit 1
      ;;
  esac
}

main "$@"
