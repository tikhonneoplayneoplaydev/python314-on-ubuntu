import hashlib

h = hashlib.sha256(b"python314").hexdigest()
assert len(h) == 64
print("OK hashlib")
