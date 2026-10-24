#!/bin/bash
# Removes the Visor lock copy and goes back to Omarchy's built-in lock screen.
set -euo pipefail
id="${USER:-$(id -un)}.lock"
if [[ -d $HOME/.config/omarchy/plugins/$id ]]; then
  omarchy-plugin-remove "$id" --yes
  rm -f "$HOME/.local/state/omarchy/visor-lock.source"
  omarchy-restart-shell
  echo "Back on the built-in lock screen."
else
  echo "No Visor lock copy found. Nothing to undo."
fi
