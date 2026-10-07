#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
set -euo pipefail

python - <<'PY'
from pathlib import Path
from tests.rom_fixtures import write_rom
from tests.test_sleekmenu_prep import write_collection
write_rom(Path("smoke/CARD/ROMS/Wave Race 64 (USA).z64"), 0x11, 0x22, game_code="WR")
write_collection(Path("smoke/CARD/release-metadata.zip"), "NWRE", zipped=True)
PY
case "$RUNNER_OS" in
  macOS)   app="dist/SleekMenu-Catalog-Manager.app/Contents/MacOS/SleekMenu-Catalog-Manager" ;;
  Windows) app="dist/SleekMenu-Catalog-Manager.exe" ;;
  *)       app="dist/SleekMenu-Catalog-Manager" ;;
esac
card="$PWD/smoke/CARD"
run=""
case "$RUNNER_OS" in
  Linux)   sudo apt-get install -y xvfb; run="xvfb-run -a" ;;
  Windows) card="$(pwd -W)/smoke/CARD" ;;
esac
$run "$app" --smoke --card "$card" | tee smoke/report.txt
test -f smoke/CARD/sleekmenu/catalog.ebc
test -f smoke/CARD/sleekmenu/covers.pak
# The window works without drag and drop, so a build where its
# library will not load is flagged here rather than failed. A
# windowed program on Windows prints nothing to read.
if [ "$RUNNER_OS" != "Windows" ]; then
  grep -q "drag and drop: yes" smoke/report.txt \
    || echo "::warning::drag and drop did not load in the $RUNNER_OS build"
fi
