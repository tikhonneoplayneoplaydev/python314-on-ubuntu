#!/usr/bin/env bash
set -e

############################
# python314 build script  #
############################

# ---------- paths ----------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKDIR="/tmp/python314-build"
SRC_DIR="$WORKDIR/Python-3.14.3"
TEST_DIR="$SCRIPT_DIR/tests"
PREFIX="/usr/local"

# ---------- sudo ----------
if [ "$EUID" -ne 0 ]; then
  echo "[*] Need sudo"
  exec sudo bash "$0" "$@"
fi

# ---------- menu ----------
echo "Select build type:"
echo "1) Fast (no PGO, no LTO)"
echo "2) Optimized (PGO, no LTO)"
echo "3) Max (PGO + LTO)"
read -rp "Choice [1-3]: " BUILD_TYPE

CONFIG_FLAGS="--prefix=$PREFIX --enable-shared"
MAKE_FLAGS="-j$(nproc)"

case "$BUILD_TYPE" in
  1)
    echo "[*] Fast build"
    ;;
  2)
    echo "[*] PGO build"
    CONFIG_FLAGS="$CONFIG_FLAGS --enable-optimizations"
    ;;
  3)
    echo "[*] PGO + LTO build"
    CONFIG_FLAGS="$CONFIG_FLAGS --enable-optimizations --with-lto"
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac

# ---------- deps ----------
apt update
apt install -y \
  build-essential wget \
  libssl-dev zlib1g-dev libbz2-dev liblzma-dev \
  libsqlite3-dev libreadline-dev libffi-dev \
  uuid-dev tk-dev

# ---------- clean ----------
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

# ---------- download ----------
wget https://www.python.org/ftp/python/3.14.3/Python-3.14.3.tgz
tar xf Python-3.14.3.tgz
cd "$SRC_DIR"

# ---------- build ----------
./configure $CONFIG_FLAGS
make $MAKE_FLAGS
make altinstall

# ---------- linker ----------
echo "$PREFIX/lib" > /etc/ld.so.conf.d/python314.conf
ldconfig

# ---------- PATH / symlinks ----------
BIN="$PREFIX/bin/python3.14"

if [ ! -e "$PREFIX/bin/python" ]; then
  ln -s "$BIN" "$PREFIX/bin/python"
elif [ ! -e "$PREFIX/bin/python3" ]; then
  ln -s "$BIN" "$PREFIX/bin/python3"
else
  ln -s "$BIN" "$PREFIX/bin/314"
fi

# ---------- verify ----------
"$BIN" --version
"$BIN" - <<'EOF'
import ssl, sqlite3, zlib, ctypes
print("stdlib OK")
EOF

# ---------- tests ----------
if [ -d "$TEST_DIR" ]; then
  echo "==============================================="
  echo " Running tests from $TEST_DIR"
  echo "==============================================="
  for t in "$TEST_DIR"/*.py; do
    [ -f "$t" ] || continue
    echo "[TEST] $t"
    "$BIN" "$t"
  done
  echo "[*] All tests passed"
else
  echo "[!] Tests directory not found, skipping"
fi

# ---------- cleanup ----------
rm -rf "$WORKDIR"

echo "==============================================="
echo " Python 3.14 installed successfully"
echo " Binary: $BIN"
echo "==============================================="
