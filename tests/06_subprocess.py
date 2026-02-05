import subprocess, sys

out = subprocess.check_output([sys.executable, "--version"])
print("OK subprocess", out.decode().strip())
