import time

start = time.time()
s = 0
for i in range(1_500_000):
    s += i * i

print("OK speed", round(time.time() - start, 2), "s")
