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
echo "📦 Extracting..."
tar -xf "$PY_TARBALL"
cd "$PY_DIR"

### ===== configure =====
echo "⚙️  Configuring..."
./configure \
  --prefix="$INSTALL_PREFIX" \
  --enable-optimizations \
  --with-lto \
  --enable-shared

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
echo "🧪 Running basic test..."
"$INSTALL_PREFIX/bin/python3.14" - <<EOF
import ssl, sqlite3, zlib, ctypes
print("✅ Python $PY_VERSION OK")
EOF

### ===== cleanup =====
echo "🧹 Cleaning up..."
rm -rf "$BUILD_ROOT"

echo "🎉 Done! Python $PY_VERSION installed."
echo "👉 Run: python3.14 --version"
