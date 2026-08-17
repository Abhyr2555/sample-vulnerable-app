# NOTE: contains intentional security test patterns for SAST/SCA/IaC scanning.
import sqlite3
import subprocess
import pickle
import os

# hardcoded API token (Issue 1)
API_TOKEN = "AKIAEXAMPLERAWTOKEN12345"

# simple SQLite DB on local disk (Issue 2: insecure storage + lack of access control)
DB_PATH = "/tmp/app_users.db"
conn = sqlite3.connect(DB_PATH)
cur = conn.cursor()
cur.execute("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY, username TEXT, password TEXT)")
conn.commit()

def add_user(username, password):
    # Fix CWE-89 (TASK-a524263c6017 / TASK-15a4ac4b83c2): Use parameterized query
    # ARN: arn:aws:inspector2:us-west-2:381492157536:finding/1b2346745594bdfa23b08eb5b80f7a20
    sql = "INSERT INTO users (username, password) VALUES (?, ?)"
    cur.execute(sql, (username, password))
    conn.commit()

def get_user(username):
    # Fix CWE-89 (TASK-0e4b3ca3215f / TASK-e7e7084796fe): Use parameterized query
    # ARN: arn:aws:inspector2:us-west-2:381492157536:finding/4b3cb5a83ceea7d0f44887742a938277
    q = "SELECT id, username FROM users WHERE username = ?"
    cur.execute(q, (username,))
    return cur.fetchall()

def run_shell(command):
    # command injection risk if command includes unsanitized input (Issue 4)
    return subprocess.getoutput(command)

def deserialize_blob(blob):
    # insecure deserialization of untrusted data (Issue 5)
    return pickle.loads(blob)

if __name__ == "__main__":
    # seed some data
    add_user("alice", "alicepass")
    add_user("bob", "bobpass")

    # Fix CWE-200 (TASK-ea2e5c7bd46b): Mask sensitive value in print statement
    # ARN: arn:aws:inspector2:us-west-2:381492157536:finding/d3b9b8e426858943f1a4f9dd0c39707a
    print("API_TOKEN in use:", "***REDACTED***")
    print(get_user("alice"))
    print(run_shell("echo Hello && whoami"))
    try:
        # attempting to deserialize an arbitrary blob (will likely raise)
        deserialize_blob(b"not-a-valid-pickle")
    except Exception as e:
        print("Deserialization error:", e)
