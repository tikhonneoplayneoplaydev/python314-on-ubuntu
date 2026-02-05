import sqlite3

db = sqlite3.connect(":memory:")
c = db.cursor()
c.execute("create table t(x int)")
c.execute("insert into t values (1)")
c.execute("select x from t")
assert c.fetchone()[0] == 1
db.close()

print("OK sqlite")
