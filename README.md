# python314-on-ubuntu

One-command build script for **Python 3.14.x** on Ubuntu.  
Downloads sources, installs dependencies, builds with PGO, runs tests, and cleans up.

`314` = Python 3.14 without dots (used for paths and names).

---

## Requirements

- Ubuntu 22.04 / 24.04
- ~20 minutes build time
- ~3 GB free disk space **during build** (temporary)
- Basic terminal usage
- sudo access

> Final installed Python size: ~60–100 MB

---

## Usage

```bash
git clone https://github.com/tikhonneoplayneoplaydev/python314-on-ubuntu.git
cd python314-on-ubuntu
chmod +x build.sh
./build.sh
