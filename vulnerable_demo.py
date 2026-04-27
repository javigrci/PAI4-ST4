"""
Demo file with INTENTIONAL vulnerabilities for PAI4 DevSecOps testing.
These are introduced deliberately so that SAST/IAST tools can detect them.
DO NOT USE IN PRODUCTION.
"""
import sqlite3
import subprocess
import hashlib
import os


# ---- A03: SQL Injection ----
def get_user(username):
    conn = sqlite3.connect("app.db")
    # VULNERABLE: user input concatenated directly into SQL query
    query = "SELECT * FROM users WHERE username = '" + username + "'"
    return conn.execute(query).fetchall()


# ---- A03: Command Injection ----
def run_ping(host):
    # VULNERABLE: user-controlled input passed to shell
    result = subprocess.run("ping -c 1 " + host, shell=True, capture_output=True)
    return result.stdout


# ---- A02: Cryptographic Failure (weak hash) ----
def hash_password(password):
    # VULNERABLE: MD5 is cryptographically broken
    return hashlib.md5(password.encode()).hexdigest()


# ---- A02: Hardcoded secret ----
SECRET_KEY = "supersecretpassword123"
DB_PASSWORD = "admin1234"


# ---- A01: Path Traversal ----
def read_file(filename):
    # VULNERABLE: no path sanitization
    base_dir = "/var/www/uploads"
    with open(os.path.join(base_dir, filename), "r") as f:
        return f.read()


# ---- A05: Debug mode enabled (misconfiguration) ----
DEBUG = True
ALLOWED_HOSTS = ["*"]
