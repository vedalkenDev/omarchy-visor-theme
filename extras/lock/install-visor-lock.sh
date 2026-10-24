#!/bin/bash
# Visor sharp lock screen (Route B). Copies Omarchy's built-in lock plugin to
# ~/.config/omarchy/plugins/$USER.lock and makes one visual change: it shows the
# current theme's lock.png without blur. Password handling is not touched.
# Undo: bash uninstall-visor-lock.sh
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
id="${USER:-$(id -un)}.lock"
dir="$HOME/.config/omarchy/plugins/$id"

command -v python3 >/dev/null || { echo "python3 is needed"; exit 1; }
[[ ! -e $dir ]] || { echo "$dir already exists. Run uninstall-visor-lock.sh first."; exit 1; }
[[ -f $HOME/.local/state/omarchy/current/theme/lock.png ]] ||
  echo "Note: the current theme has no lock.png, so the lock will look stock until Visor is active."

omarchy-plugin-clone omarchy.lock
if ! python3 "$here/patch-lockview.py" "$dir/LockView.qml"; then
  echo "Patch did not apply (Omarchy's lock code has changed). Removing the copy."
  omarchy-plugin-remove "$id" --yes
  exit 1
fi
rm -f "$dir/LockView.qml.orig"
# Remember which Omarchy lock code this copy came from, for refresh-visor-lock.sh.
src=$(omarchy-plugin-catalog | jq -r '.[] | select(.firstParty and .id == "omarchy.lock") | .sourceDir')
mkdir -p "$HOME/.local/state/omarchy"
(cd "$src" && cat -- *.qml manifest.json | sha256sum | cut -d' ' -f1) >"$HOME/.local/state/omarchy/visor-lock.source"
omarchy-restart-shell
echo "Done. Preview with: omarchy-shell lock preview   (click to close)"
