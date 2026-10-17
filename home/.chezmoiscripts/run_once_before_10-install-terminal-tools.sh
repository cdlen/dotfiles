#!/bin/sh
# Terminal (portable) layer: tools needed on EVERY machine, headless or GUI.
# Idempotent and sudo-free where possible. chezmoi re-runs this whenever the
# file's contents change (run_once_ is keyed on the rendered content hash).
set -eu

# ---------- helpers -------------------------------------------------------

# Fetch a URL with whichever downloader exists.
fetch() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1"
  else
    wget -qO- "$1"
  fi
}

# A writable, sudo-free install dir: /usr/local/bin when we are root (typical
# inside an LXC) or it is already writable, otherwise the user's ~/.local/bin.
bin_dir() {
  if [ "$(id -u)" -eq 0 ] || [ -w /usr/local/bin ]; then
    printf '/usr/local/bin'
  else
    mkdir -p "$HOME/.local/bin"
    printf '%s' "$HOME/.local/bin"
  fi
}

# ---------- starship ------------------------------------------------------
# Add more terminal tools below, each guarded by `command -v`.

if command -v starship >/dev/null 2>&1; then
  echo "starship: already installed"
else
  # A minimal Debian/Ubuntu container may have neither downloader.
  if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    if command -v apt-get >/dev/null 2>&1; then
      SUDO=""
      [ "$(id -u)" -eq 0 ] || SUDO="sudo"
      if ! $SUDO apt-get update && $SUDO apt-get install -y curl; then
        echo "starship: could not install curl, skipping" >&2
        exit 0
      fi
    else
      echo "starship: no curl/wget available, install manually" >&2
      exit 0
    fi
  fi

  starship_bin_dir="$(bin_dir)"
  echo "starship: installing into ${starship_bin_dir}"
  # -y  -> no confirmation prompt;  -b -> install dir (avoids sudo)
  fetch https://starship.rs/install.sh |
    sh -s -- -y -b "${starship_bin_dir}" ||
    echo "starship: install failed, continuing" >&2
fi
