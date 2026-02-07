# Python 3.14 on Ubuntu (build from source)

Build and install Python 3.14 from source on Ubuntu using a single Bash script.

No hangs. Just works.

---

## Features

- One Bash script
- Automatic dependency installation
- Build type selection (fast / optimized)
- No LTO
- Automatic sudo request
- Post-install test
- Automatic cleanup

---

## Build types

### Fast build
- Very fast compilation
- No PGO

### Optimized build
- Uses PGO (`--enable-optimizations`)
- Slower build


---

## Requirements

- Ubuntu 20.04 / 22.04 / 24.04
- ~3 GB free disk space
- Internet connection
- sudo access

---

## Usage

```bash
git clone https://github.com/tikhonneoplayneoplaydev/python314-on-ubuntu.git
cd python314-on-ubuntu

chmod +x build.sh
./build.sh
python3.14 --version
/usr/local/bin/python3.14
```
