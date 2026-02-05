#!/usr/local/bin/python3.14

import sys
import subprocess
import venv
from pathlib import Path

PY_ID = "314"
MIN_VERSION = (3, 14)

print("==> Executable:", sys.executable)
print("==> Version:", sys.version)

# --- version check ---
if sys.version_info < MIN_VERSION:
    raise SystemExit(f"FAIL: Python >= {MIN_VERSION[0]}.{MIN_VERSION[1]} required")

print("[OK] version check")

# --- stdlib modules ---
MODULES = [
    "ssl",
    "sqlite3",
    "zlib",
    "ctypes",
    "hashlib",
]

for m in MODULES:
    try:
        __import__(m)
        print(f"[OK] import {m}")
    except Exception as e:
        raise SystemExit(f"[FAIL] import {m}: {e}")

# --- venv + pip ---
env_dir = Path(f"/tmp/py{PY_ID}-test")

print("==> Creating venv:", env_dir)
if env_dir.exists():
    subprocess.check_call(["rm", "-rf", str(env_dir)])

venv.create(env_dir, with_pip=True)

pip = env_dir / "bin" / "pip"
py  = env_dir / "bin" / "python"

print("==> Upgrading pip")
subprocess.check_call([pip, "install", "--upgrade", "pip"])

print("==> Installing test package (requests)")
subprocess.check_call([pip, "install", "requests"])

print("==> Import test (requests)")
subprocess.check_call([py, "-c", "import requests; print('requests OK')"])

print("==> ALL TESTS PASSED ✅")
