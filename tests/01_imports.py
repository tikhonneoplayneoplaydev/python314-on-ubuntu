modules = [
    "ssl",
    "sqlite3",
    "zlib",
    "ctypes",
    "hashlib",
    "math",
    "threading",
    "subprocess",
]

for m in modules:
    __import__(m)
    print("OK import", m)
