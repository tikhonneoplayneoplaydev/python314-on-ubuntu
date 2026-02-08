#!/usr/bin/env bash
set -e

# ============================================================
# Python 3.14 build & install script with checks and tests
# ============================================================

if [[ $EUID -ne 0 ]]; then
  echo "[*] Need sudo"
  exec sudo "$0" "$@"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/tests"
PREFIX="/usr/local"
PY_VER="3.14.3"
PY_TAR="Python-$PY_VER.tgz"
PY_DIR="Python-$PY_VER"
PY_URL="https://www.python.org/ftp/python/$PY_VER/$PY_TAR"

echo "==============================================="
echo " Python 3.14 build script"
echo "==============================================="

# ---- system checks ----
if grep -qi raspberrypi /etc/os-release && grep -qi trixie /etc/os-release; then
  echo "ERROR: Debian Trixie + Raspberry Pi repo detected"
  echo "This breaks libssl-dev dependencies."
  echo "Use Raspberry Pi OS (Bookworm) or Debian stable."
  exit 1
fi

if ! command -v gcc >/dev/null; then
  echo "ERROR: gcc not found"
  exit 1
fi

if ! command -v make >/dev/null; then
  echo "ERROR: make not found"
  exit 1
fi

# ---- build type ----
echo "Select build type:"
echo "1) Fast (no PGO, no LTO)"
echo "2) Optimized (PGO, no LTO)"
echo "3) Max (PGO + LTO)"
read -rp "Choice [1-3]: " BUILD_TYPE

CFLAGS=""
CONFIG_OPTS="--enable-shared --with-ensurepip=install"

case "$BUILD_TYPE" in
  1)
    echo "[*] Fast build"
    ;;
  2)
    echo "[*] PGO build"
    CONFIG_OPTS="$CONFIG_OPTS --enable-optimizations"
    ;;
  3)
    echo "[*] PGO + LTO build"
    CONFIG_OPTS="$CONFIG_OPTS --enable-optimizations --with-lto"
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

# ---- dependencies ----
apt update
apt install -y \
  build-essential wget \
  libssl-dev zlib1g-dev \
  libffi-dev libsqlite3-dev \
  uuid-dev libbz2-dev \
  libreadline-dev libncurses-dev

# ---- download ----
cd "$SCRIPT_DIR"
if [[ ! -f "$PY_TAR" ]]; then
  wget "$PY_URL"
fi

rm -rf "$PY_DIR"
tar xf "$PY_TAR"
cd "$PY_DIR"

# ---- build ----
./configure --prefix="$PREFIX" $CONFIG_OPTS
make -j"$(nproc)"
make install
ldconfig

# ---- PATH / symlinks ----
BIN="$PREFIX/bin/python3.14"

if [[ ! -x "$BIN" ]]; then
  echo "ERROR: python3.14 not installed"
  exit 1
fi

if [[ ! -e "$PREFIX/bin/python" ]]; then
  ln -s "$BIN" "$PREFIX/bin/python"
elif [[ ! -e "$PREFIX/bin/python3" ]]; then
  ln -s "$BIN" "$PREFIX/bin/python3"
else
  ln -s "$BIN" "$PREFIX/bin/314"
fi

# ---- tests ----
echo "==============================================="
echo " Running tests from $TEST_DIR"
echo "==============================================="

if [[ ! -d "$TEST_DIR" ]]; then
  echo "ERROR: tests directory not found"
  exit 1
fi

for t in "$TEST_DIR"/*.py; do
  echo "[TEST] $t"
  "$BIN" "$t"
done

echo "==============================================="
echo " Python 3.14 installed successfully"
echo " Binary: $BIN"
echo "==============================================="

"$BIN" --version
