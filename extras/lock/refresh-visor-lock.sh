#!/bin/bash
# Runs after every Omarchy update (see auto-refresh.sh). If Omarchy changed its
# lock code, rebuilds the Visor lock copy from the new code. If the new code no
# longer fits the patch, the installer removes the copy and you get Omarchy's
# normal lock screen. Does nothing when the Visor lock isn't installed.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
id="${USER:-$(id -un)}.lock"
[[ -d $HOME/.config/omarchy/plugins/$id ]] || exit 0
src=$(omarchy-plugin-catalog | jq -r '.[] | select(.firstParty and .id == "omarchy.lock") | .sourceDir')
[[ -n $src && -d $src ]] || { echo "Visor lock: can't find Omarchy's lock code, leaving it alone."; exit 0; }
now=$(cd "$src" && cat -- *.qml manifest.json | sha256sum | cut -d' ' -f1)
was=$(cat "$HOME/.local/state/omarchy/visor-lock.source" 2>/dev/null || true)
[[ $now == "$was" ]] && exit 0
echo "Visor lock: Omarchy's lock screen changed, refreshing your copy."
bash "$here/uninstall-visor-lock.sh" >/dev/null
if bash "$here/install-visor-lock.sh" >/dev/null; then
  echo "Visor lock: refreshed."
else
  echo "Visor lock: this Omarchy version doesn't fit the patch. You're on Omarchy's normal lock screen."
fi
