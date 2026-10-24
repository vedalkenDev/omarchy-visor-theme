#!/bin/bash
# Makes Omarchy refresh the Visor lock after every update.
#   bash extras/lock/auto-refresh.sh           turn on
#   bash extras/lock/auto-refresh.sh --remove  turn off
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
hook="$HOME/.config/omarchy/hooks/post-update"
line="bash \"$here/refresh-visor-lock.sh\"  # visor-lock"
mkdir -p "$(dirname "$hook")"
touch "$hook"
grep -v '# visor-lock$' "$hook" >"$hook.tmp" || true
if [[ ${1:-} != --remove ]]; then
  echo "$line" >>"$hook.tmp"
  # Lock already installed before auto-refresh existed: record the code it came from.
  base="$HOME/.local/state/omarchy/visor-lock.source"
  if [[ -d $HOME/.config/omarchy/plugins/${USER:-$(id -un)}.lock && ! -f $base ]]; then
    src=$(omarchy-plugin-catalog | jq -r '.[] | select(.firstParty and .id == "omarchy.lock") | .sourceDir')
    mkdir -p "$(dirname "$base")"
    (cd "$src" && cat -- *.qml manifest.json | sha256sum | cut -d' ' -f1) >"$base"
  fi
  echo "Auto-refresh on. Omarchy will refresh the Visor lock after each update."
else
  echo "Auto-refresh off."
fi
mv "$hook.tmp" "$hook"
