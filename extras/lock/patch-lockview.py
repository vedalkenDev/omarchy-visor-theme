#!/usr/bin/env python3
"""Visor lock patch: show the theme's lock.png sharp on the cloned lock screen.
Visual-only edits to LockView.qml; authentication code is not touched.
Supports Omarchy 4.0.6 (Image wallpaper) and newer (BackgroundMedia).
Stops without writing if any required line is missing."""
import sys, pathlib, shutil
p = pathlib.Path(sys.argv[1]); s = p.read_text()
if "visor-lock" in s: print("already patched"); sys.exit(0)
URL = ('"file://" + String(root.themeLockImage).split("/").map(encodeURIComponent).join("/")'
       ' + "?v=" + root.backgroundVersion')
required = [
 [("import QtQuick.Effects\n", "import QtQuick.Effects\nimport Quickshell\n")],
 [('  property string passwordText: ""\n',
   '  property string passwordText: ""\n'
   '  // visor-lock: the current theme\'s lock.png, shown sharp when it loads.\n'
   '  readonly property string themeLockImage: Quickshell.env("HOME") + "/.local/state/omarchy/current/theme/lock.png"\n'
   '  readonly property bool useThemeImage: themeLockProbe.status === Image.Ready\n')],
 [("  TextMetrics {\n    id: dotMetrics\n",
   "  // visor-lock: tiny probe; falls back to the stock wallpaper if lock.png is missing.\n"
   "  Image {\n    id: themeLockProbe\n    visible: false\n    asynchronous: true\n    cache: false\n"
   f"    sourceSize: Qt.size(1, 1)\n    source: {URL}\n  }}\n\n"
   "  TextMetrics {\n    id: dotMetrics\n")],
 [ # wallpaper source: 4.0.6 form, then newer form
  ('      source: root.loadBackground ? root.fileUrl(root.backgroundPath) : ""\n',
   '      source: root.loadBackground ? root.fileUrl(root.useThemeImage ? root.themeLockImage : root.backgroundPath) : ""\n'),
  ('      path: root.loadBackground ? (root.video ? root.videoPosterPath : root.backgroundPath) : ""\n',
   '      path: root.loadBackground ? (root.useThemeImage ? root.themeLockImage : (root.video ? root.videoPosterPath : root.backgroundPath)) : ""\n')],
 [("      blurEnabled: root.loadBackground && wallpaper.status === Image.Ready\n",
   "      blurEnabled: !root.useThemeImage && root.loadBackground && wallpaper.status === Image.Ready\n"),
  ("      blurEnabled: root.loadBackground && wallpaper.ready\n",
   "      blurEnabled: !root.useThemeImage && root.loadBackground && wallpaper.ready\n")],
 [("      contrast: -0.08\n", "      contrast: root.useThemeImage ? 0 : -0.08\n")],
]
optional = [  # newer versions only (video wallpapers)
 ("  readonly property bool feedActive: root.video && root.loadBackground",
  "  readonly property bool feedActive: !root.useThemeImage && root.video && root.loadBackground"),
 ("      visible: root.video\n      color: \"#22000000\"\n",
  "      visible: root.video && !root.useThemeImage\n      color: \"#22000000\"\n"),
]
for alts in required:
    for old, new in alts:
        if s.count(old) == 1: s = s.replace(old, new); break
    else:
        sys.exit("patch-lockview: Omarchy's lock code has changed, nothing written. Missing:\n" + alts[0][0])
for old, new in optional:
    if s.count(old) == 1: s = s.replace(old, new)
if "root.video" in s and "!root.useThemeImage && root.video" not in s:
    sys.exit("patch-lockview: video wallpaper code not recognised, nothing written.")
shutil.copy2(p, str(p) + ".orig"); p.write_text(s); print("patched", p)
