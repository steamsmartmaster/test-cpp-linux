#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/build_debug_install.sh [INSTALL_PREFIX]
# Default install prefix: ./install

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
cd "$ROOT_DIR"

BUILD_DIR=${BUILD_DIR:-"$ROOT_DIR/build/debug"}
INSTALL_PREFIX=${1:-"$ROOT_DIR/install"}
JOBS=${JOBS:-$(nproc)}

echo "Configuring Debug build in: $BUILD_DIR"
mkdir -p "$BUILD_DIR"

cmake -S . -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Debug

echo "Building (jobs=$JOBS)..."
cmake --build "$BUILD_DIR" --config Debug -- -j"$JOBS"

echo "Installing to: $INSTALL_PREFIX"
cmake --install "$BUILD_DIR" --prefix "$INSTALL_PREFIX"

echo "Done. Installed to: $INSTALL_PREFIX"
