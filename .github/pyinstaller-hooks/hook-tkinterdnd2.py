# SPDX-License-Identifier: AGPL-3.0-only
"""Keep both Tk 8 drag-and-drop backends in the universal macOS app.

The default hook collects only the build host's architecture. These Tcl
plugins can remain thin: tkinterdnd2 selects a directory at runtime.
The python.org 3.12 installer bundles Tcl/Tk 8.6.
"""
from pathlib import Path

from PyInstaller.utils.hooks import get_package_paths

_, package_dir = get_package_paths("tkinterdnd2")
datas = []
binaries = []
for architecture in ("osx-arm64", "osx-x64"):
    source = Path(package_dir) / "tkdnd" / architecture
    destination = f"tkinterdnd2/tkdnd/{architecture}"
    libraries = list(source.glob("*.dylib"))
    if not libraries:
        raise RuntimeError(f"Missing drag-and-drop libraries: {source}")
    binaries.extend((str(path), destination) for path in libraries)
    datas.extend((str(path), destination) for path in source.glob("*.tcl"))
