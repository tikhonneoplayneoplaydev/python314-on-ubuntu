import sqlite3, time

db = sqlite3.connect(":memory:")
c = db.cursor()
c.execute("create table t(x int)")

start = time.time()
for i in range(10_000):
    c.execute("insert into t values (?)", (i,))
db.commit()

print("OK sqlite speed", round(time.time() - start, 2), "s")
