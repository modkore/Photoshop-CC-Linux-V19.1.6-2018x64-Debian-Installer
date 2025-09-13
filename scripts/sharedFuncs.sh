#!/usr/bin/env bash
set -euo pipefail

# Defaults (can be overridden by env)
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine-photoshopcc2018}"
export WINEDEBUG="${WINEDEBUG:--all}"
export WINETRICKS_CACHE="${WINETRICKS_CACHE:-$HOME/.cache/winetricks}"
export LC_ALL=C

# For some setups, these overrides help Photoshop CC 2018
export WINEDLLOVERRIDES="${WINEDLLOVERRIDES:-msxml3,msxml6=n;atl=native,builtin;gdiplus=native;uxtheme,mscoree,mshtml="}"

banner() {
  echo "====================================================="
  echo "  Photoshop CC 2018 (v19.1.6) Linux Installer"
  echo "  Prefix:      $WINEPREFIX"
  echo "  Winetricks:  $WINETRICKS_CACHE"
  echo "====================================================="
}

detect_pm() {
  if command -v apt-get >/dev/null 2>&1; then echo apt; return; fi
  if command -v dnf >/dev/null 2>&1; then echo dnf; return; fi
  if command -v pacman >/dev/null 2>&1; then echo pacman; return; fi
  echo unknown
}

ensure_deps() {
  local missing=()
  for bin in wine winetricks cabextract 7z; do
    command -v "$bin" >/dev/null 2>&1 || missing+=("$bin")
  done

  if ((${#missing[@]})); then
    echo "Installing missing dependencies: ${missing[*]}"
    local pm
    pm="$(detect_pm)"
    case "$pm" in
      apt)
        sudo apt-get update
        sudo apt-get install -y --no-install-recommends \
          wine winetricks cabextract p7zip-full
        ;;
      dnf)
        sudo dnf install -y wine winetricks cabextract p7zip p7zip-plugins
        ;;
      pacman)
        sudo pacman -Syu --noconfirm wine winetricks cabextract p7zip
        ;;
      *)
        echo "Please install: wine, winetricks, cabextract, p7zip (7z)."
        exit 1
        ;;
    esac
  fi
}

ensure_cache_dir() {
  mkdir -p "$WINETRICKS_CACHE"
}

ensure_prefix() {
  if [[ ! -d "$WINEPREFIX" ]]; then
    echo "Creating Wine prefix at $WINEPREFIX ..."
    WINEARCH=win64 wineboot -u
  fi
}

run_script() {
  local path="$1"
  if [[ ! -x "$path" ]]; then
    chmod +x "$path"
  fi
  "$path"
}

ask_for_file() {
  local prompt="$1"
  local default_dir="$2"
  local path=""

  echo "$prompt"
  echo "Press ENTER to search in: $default_dir"
  read -rp "Or provide full path to the installer file: " path || true

  if [[ -z "${path// }" ]]; then
    path="$default_dir"
  fi

  if [[ -d "$path" ]]; then
    # choose first .exe/.msi found
    local cand
    cand="$(find "$path" -maxdepth 2 -type f \( -iname '*.exe' -o -iname '*.msi' \) | head -n1)"
    if [[ -z "$cand" ]]; then
      echo "No installer found in $path. Please try again."
      exit 1
    fi
    echo "$cand"
  elif [[ -f "$path" ]]; then
    echo "$path"
  else
    echo "Path not found: $path"
    exit 1
  fi
}

winetricks_install_common() {
  # Core fonts + VC runtimes + GDI+ etc. used frequently by PS CC 2018
  WINEPREFIX="$WINEPREFIX" WINETRICKS_CACHE="$WINETRICKS_CACHE" \
  winetricks -q \
    fontsmooth=rgb corefonts atmlib gdiplus msxml6 msxml3 \
    vcrun2015 vcrun2013 vcrun2012 vcrun2010

  # Set Windows version to Win7/Win10 (PS CC 2018 tends to be happy with Win7)
  WINEPREFIX="$WINEPREFIX" WINETRICKS_CACHE="$WINETRICKS_CACHE" \
  winetricks -q win7
}

create_shortcuts() {
  # Try to find Photoshop.exe in prefix; paths vary depending on installer
  local exe
  exe="$(find "$WINEPREFIX/drive_c" -type f -iname 'Photoshop.exe' | head -n1 || true)"

  if [[ -z "$exe" ]]; then
    # fallback to typical CC 2018 path
    exe="$WINEPREFIX/drive_c/Program Files/Adobe/Adobe Photoshop CC 2018/Photoshop.exe"
  fi

  if [[ ! -f "$exe" ]]; then
    echo "Warning: Could not locate Photoshop.exe (launcher will still be created)."
  fi

  mkdir -p "$HOME/.local/bin" "$HOME/.local/share/applications"
  cat > "$HOME/.local/bin/photoshopcc2018" <<EOF
#!/usr/bin/env bash
export WINEPREFIX="$WINEPREFIX"
export WINEDLLOVERRIDES="$WINEDLLOVERRIDES"
exec wine "$exe" "\$@"
EOF
  chmod +x "$HOME/.local/bin/photoshopcc2018"

  # .desktop entry
  cat > "$HOME/.local/share/applications/photoshopcc2018.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Adobe Photoshop CC 2018
Exec=$HOME/.local/bin/photoshopcc2018
Icon=photoshop
Terminal=false
Categories=Graphics;2DGraphics;RasterGraphics;
StartupWMClass=photoshop.exe
EOF

  update_desktop_db >/dev/null 2>&1 || true
}

clean_confirm() {
  read -rp "This will remove $WINEPREFIX and shortcuts. Continue? [y/N]: " yn
  [[ "${yn:-N}" =~ ^[Yy]$ ]]
}
