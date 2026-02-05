#!/usr/bin/env bash
set -e

# ================================
# Python 3.14 full build script
# downloads, builds, installs,
# adds to PATH and runs tests/
# ================================

PY_VER="3.14.3"
PY_MAJ="3.14"
SRC_URL="https://www.python.org/ftp/python/${PY_VER}/Python-${PY_VER}.tgz"
WORKDIR="/tmp/python314-build"
PREFIX="/usr/local/python314"
TEST_DIR="tests"
LINK_DIR="/usr/local/bin"

# ---------- sudo ----------
if [ "$EUID" -ne 0 ]; then
  exec sudo bash "$0" "$@"
fi

clear
echo "========================================"
echo " Python ${PY_VER} build & test script"
echo "========================================"
echo

# ---------- BUILD OPTIONS ----------
echo "Choose build type:"
echo " 1) Minimal (no optimizations, fastest build)"
echo " 2) Normal (recommended)"
echo " 3) Optimized (PGO)"
echo " 4) Optimized + LTO (slow, max performance)"
echo
read -rp "Select [1-4]: " BUILD_TYPE

case "$BUILD_TYPE" in
  1)
    CONFIG_OPTS=""
    ;;
  2)
    CONFIG_OPTS="--enable-shared"
    ;;
  3)
    CONFIG_OPTS="--enable-shared --enable-optimizations"
    ;;
  4)
    CONFIG_OPTS="--enable-shared --enable-optimizations --with-lto"
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

echo
echo "Build options: $CONFIG_OPTS"
echo

# ---------- DEPENDENCIES ----------
echo "Installing dependencies..."
apt update
apt install -y \
  build-essential \
  wget \
  libssl-dev \
  zlib1g-dev \
  libbz2-dev \
  libreadline-dev \
  libsqlite3-dev \
  libffi-dev \
  libncursesw5-dev \
  xz-utils \
  tk-dev \
  libxml2-dev \
  libxmlsec1-dev

# ---------- PREPARE ----------
echo
echo "Preparing build directory..."
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# ---------- DOWNLOAD ----------
echo "Downloading Python ${PY_VER}..."
wget -q "$SRC_URL"

echo "Extracting sources..."
tar xf "Python-${PY_VER}.tgz"
cd "Python-${PY_VER}"

# ---------- CONFIGURE ----------
echo
echo "Configuring build..."
./configure \
  --prefix="$PREFIX/$PY_VER" \
  --with-ensurepip=install \
  $CONFIG_OPTS

# ---------- BUILD ----------
echo
echo "Building Python (this may take time)..."
make -j"$(nproc)"

# ---------- INSTALL ----------
echo
echo "Installing Python..."
make install

# ---------- SYMLINK CURRENT ----------
echo
echo "Updating current symlink..."
ln -sfn "$PREFIX/$PY_VER" "$PREFIX/current"

PY_BIN="$PREFIX/current/bin/python${PY_MAJ}"

# ---------- ADD TO PATH ----------
echo
echo "Adding Python to PATH..."
if [ ! -e "$LINK_DIR/python" ]; then
  ln -sf "$PY_BIN" "$LINK_DIR/python"
  PY_CMD="$LINK_DIR/python"
elif [ ! -e "$LINK_DIR/python3" ]; then
  ln -sf "$PY_BIN" "$LINK_DIR/python3"
  PY_CMD="$LINK_DIR/python3"
else
  ln -sf "$PY_BIN" "$LINK_DIR/python314"
  PY_CMD="$LINK_DIR/python314"
fi

echo "Python command: $PY_CMD"
"$PY_CMD" --version

# ---------- TESTS ----------
echo
echo "========================================"
echo " Running tests from ./$TEST_DIR"
echo "========================================"

if [ ! -d "$TEST_DIR" ]; then
  echo "ERROR: tests directory not found"
  exit 1
fi

TOTAL=0
PASSED=0

for t in "$TEST_DIR"/*.py; do
  [ -f "$t" ] || continue
  TOTAL=$((TOTAL+1))
  echo "RUN $t"
  if "$PY_CMD" "$t"; then
    echo "PASS"
    PASSED=$((PASSED+1))
  else
    echo "FAIL"
    exit 1
  fi
  echo
done

# ---------- RESULT ----------
echo "========================================"
echo " Tests passed: $PASSED / $TOTAL"
echo "========================================"
echo
echo "DONE. Python installed and tested successfully."
echo "Use: $PY_CMD"
