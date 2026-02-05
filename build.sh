#!/usr/bin/env bash
set -e

# ===== CONFIG =====
PY_VERSION="3.14.3"
PY_MAJ_MIN="${PY_VERSION%.*}"   # 3.14
PY_ID="${PY_MAJ_MIN//./}"       # 314
JOBS=$(nproc)

WORKDIR="/tmp/python${PY_ID}-build"
PYBIN="/usr/local/bin/python${PY_MAJ_MIN}"

# ===== INFO =====
echo "==> Building Python $PY_VERSION (id=$PY_ID)"
echo "==> Cores: $JOBS"
echo "==> Temp dir: $WORKDIR"
echo

# ===== DEPS =====
echo "==> Installing dependencies"
sudo apt update
sudo apt install -y \
  build-essential pkg-config curl \
  libssl-dev zlib1g-dev libbz2-dev liblzma-dev libzstd-dev \
  libreadline-dev libsqlite3-dev libffi-dev uuid-dev \
  tk-dev libgdbm-dev libncursesw5-dev

# ===== DOWNLOAD =====
echo
echo "==> Preparing workdir"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "==> Downloading Python $PY_VERSION"
curl -LO "https://www.python.org/ftp/python/$PY_VERSION/Python-$PY_VERSION.tgz"
tar xf "Python-$PY_VERSION.tgz"
cd "Python-$PY_VERSION"

# ===== CONFIGURE =====
echo
echo "==> Configuring (PGO enabled)"
./configure --enable-optimizations

# ===== BUILD =====
echo
echo "==> Building (this takes time)"
make -j"$JOBS"

# ===== INSTALL =====
echo
echo "==> Installing (altinstall, system python untouched)"
sudo make altinstall

# ===== TESTS (PYTHON TESTS PYTHON) =====
echo
echo "==> Running sanity tests"
"$PYBIN" - <<EOF
import sys, subprocess, venv

print("Python:", sys.version)
assert sys.version_info >= (3, 14)

mods = ["ssl", "sqlite3", "zlib", "ctypes", "hashlib"]
for m in mods:
    __import__(m)
    print("OK:", m)

env = "/tmp/py${PY_ID}-test"
print("Creating venv:", env)
venv.create(env, with_pip=True)

pip = f"{env}/bin/pip"
py  = f"{env}/bin/python"

subprocess.check_call([pip, "install", "--upgrade", "pip"])
subprocess.check_call([pip, "install", "requests"])
subprocess.check_call([py, "-c", "import requests; print('requests OK')"])

print("ALL TESTS PASSED")
EOF

# ===== CLEANUP =====
echo
echo "==> Cleaning up (freeing disk space)"
rm -rf "$WORKDIR"

echo
echo "==> DONE 🎉"
echo "Binary: $PYBIN"
