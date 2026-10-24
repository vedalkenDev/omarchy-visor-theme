#!/bin/bash
# Turns Visor's window shape on (10px corners, opaque terminals) or off.
#   bash extras/shape.sh           turn on
#   bash extras/shape.sh --remove  turn off
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dir="${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/toggles/hypr"
if [[ ${1:-} == --remove ]]; then
  rm -f "$dir/visor-shape.lua"
  echo "Visor shape off."
else
  mkdir -p "$dir"
  cp "$here/visor-shape.lua" "$dir/visor-shape.lua"
  omarchy-hyprland-corners theme >/dev/null
  echo "Visor shape on."
fi
hyprctl reload >/dev/null
