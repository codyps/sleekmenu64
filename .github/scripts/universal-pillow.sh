#!/usr/bin/env bash
# SPDX-License-Identifier: AGPL-3.0-only
set -euo pipefail

# PyPI supplies separate Pillow wheels. Merge matching versions, including
# their bundled image libraries, before PyInstaller analyzes the package.
python -m pip install 'delocate>=0.13,<1'
pillow_version="$(python -c 'import PIL; print(PIL.__version__)')"
wheel_dir="$RUNNER_TEMP/pillow-wheels"
mkdir -p "$wheel_dir/arm64" "$wheel_dir/x86_64" "$wheel_dir/universal"
python -m pip download --only-binary=:all: --no-deps \
  --platform macosx_11_0_arm64 --dest "$wheel_dir/arm64" "Pillow==$pillow_version"
python -m pip download --only-binary=:all: --no-deps \
  --platform macosx_11_0_x86_64 --dest "$wheel_dir/x86_64" "Pillow==$pillow_version"
delocate-merge "$wheel_dir/arm64/"*.whl "$wheel_dir/x86_64/"*.whl \
  --wheel-dir "$wheel_dir/universal"
python -m pip install --force-reinstall --no-deps "$wheel_dir/universal/"*.whl
