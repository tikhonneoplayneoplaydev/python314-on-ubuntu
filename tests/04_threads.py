import threading

x = 0
def work():
    global x
    for _ in range(100_000):
        x += 1

t1 = threading.Thread(target=work)
t2 = threading.Thread(target=work)
t1.start(); t2.start()
t1.join(); t2.join()

print("OK threads")
