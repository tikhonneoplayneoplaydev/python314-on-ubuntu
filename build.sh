#!/usr/bin/env bash
set -e

### ===== sudo auto-request =====
if [[ $EUID -ne 0 ]]; then
  echo "🔒 Root privileges required. Asking for sudo..."
  exec sudo bash "$0" "$@"
fi

### ===== config =====
PY_VERSION="3.14.3"
PY_TARBALL="Python-$PY_VERSION.tgz"
PY_DIR="Python-$PY_VERSION"
BUILD_ROOT="/tmp/python314-build"
INSTALL_PREFIX="/usr/local"

### ===== choose build type =====
echo "======================================"
echo " Choose Python build type (NO LTO)"
echo "======================================"
echo "1) Fast build (recommended)"
echo "   - very fast"
echo "   - no PGO"
echo
echo "2) Optimized build"
echo "   - uses PGO"
echo "   - slower build"
echo
read -rp "Select option [1-2]: " BUILD_TYPE

case "$BUILD_TYPE" in
  1)
    CONFIGURE_FLAGS="--prefix=$INSTALL_PREFIX"
    BUILD_NAME="FAST"
    ;;
  2)
    CONFIGURE_FLAGS="--prefix=$INSTALL_PREFIX --enable-optimizations"
    BUILD_NAME="OPTIMIZED (PGO)"
    ;;
  *)
    echo "❌ Invalid option"
    exit 1
    ;;
esac

echo "✅ Selected: $BUILD_NAME build"
echo

### ===== deps =====
echo "📦 Installing build dependencies..."
apt update
apt install -y \
  build-essential \
  wget \
  libssl-dev \
  zlib1g-dev \
  libncurses5-dev \
  libncursesw5-dev \
  libreadline-dev \
  libsqlite3-dev \
  libffi-dev \
  libbz2-dev \
  liblzma-dev \
  uuid-dev \
  tk-dev

### ===== prepare =====
echo "📁 Preparing build directory..."
rm -rf "$BUILD_ROOT"
mkdir -p "$BUILD_ROOT"
cd "$BUILD_ROOT"

### ===== download =====
if [ ! -f "$PY_TARBALL" ]; then
  echo "⬇️  Downloading Python $PY_VERSION..."
  wget https://www.python.org/ftp/python/$PY_VERSION/$PY_TARBALL
fi

### ===== extract =====
echo "📦 Extracting sources..."
tar -xf "$PY_TARBALL"
cd "$PY_DIR"

### ===== configure =====
echo "⚙️  Configuring ($BUILD_NAME)..."
./configure $CONFIGURE_FLAGS

### ===== build =====
echo "🛠️  Building..."
make -j"$(nproc)"

### ===== install =====
echo "📥 Installing..."
make altinstall

### ===== ldconfig =====
echo "🔗 Updating linker cache..."
ldconfig

### ===== test =====
echo "🧪 Running test..."
"$INSTALL_PREFIX/bin/python3.14" - <<EOF
import sys, ssl, sqlite3, zlib, ctypes
print("✅ Python OK")
print("Version:", sys.version)
EOF

### ===== cleanup =====
echo "🧹 Cleaning up..."
rm -rf "$BUILD_ROOT"

echo
echo "🎉 Done!"
echo "👉 Run: python3.14 --version"
