import sys

print("Executable:", sys.executable)
assert sys.executable.startswith("/usr/local")
print("OK path")
