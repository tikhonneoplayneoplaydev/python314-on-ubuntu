#!/usr/bin/env bash
set -e

# ===== python314 uninstall script =====

if [[ $EUID -ne 0 ]]; then
  echo "[*] Root required, requesting sudo..."
  exec sudo "$0" "$@"
fi

PY_PREFIX="/usr/local"
PY_VER="3.14"
PY_BIN="$PY_PREFIX/bin/python3.14"
PY_LIB="$PY_PREFIX/lib/python3.14"
PY_INC="$PY_PREFIX/include/python3.14"
PY_SO="$PY_PREFIX/lib/libpython3.14.so.1.0"

echo "==============================================="
echo " Python 3.14 UNINSTALL"
echo "==============================================="

if [[ ! -x "$PY_BIN" ]]; then
  echo "[!] Python 3.14 not found at $PY_BIN"
  exit 1
fi

read -rp "Remove Python 3.14 completely? [y/N]: " ans
[[ "$ans" != "y" && "$ans" != "Y" ]] && exit 0

echo "[*] Removing binaries"
rm -f "$PY_PREFIX/bin/python3.14" \
      "$PY_PREFIX/bin/python3.14-config" \
      "$PY_PREFIX/bin/pip3.14" \
      "$PY_PREFIX/bin/idle3.14" \
      "$PY_PREFIX/bin/pydoc3.14" || true

echo "[*] Removing libraries"
rm -rf "$PY_LIB"
rm -f "$PY_SO"
rm -f "$PY_PREFIX/lib/libpython3.14.so"
rm -f "$PY_PREFIX/lib/libpython3.14.a"

echo "[*] Removing headers"
rm -rf "$PY_INC"

echo "[*] Cleaning symlinks"
for name in python python3 314; do
  if [[ -L "$PY_PREFIX/bin/$name" ]]; then
    TARGET="$(readlink "$PY_PREFIX/bin/$name")"
    if [[ "$TARGET" == *python3.14* ]]; then
      rm -f "$PY_PREFIX/bin/$name"
    fi
  fi
done

echo "[*] Updating linker cache"
ldconfig

echo "==============================================="
echo " Python 3.14 removed successfully"
echo "==============================================="
