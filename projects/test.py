import os
import sqlite3
import json

# Simulate a web request
def simulate_request(route, params):
    if route == "/arbitrary_file_write":
        handle_arbitrary_file_write(params)
    elif route == "/sql_injection":
        handle_sql_injection(params)
    elif route == "/command_injection":
        handle_command_injection(params)
    elif route == "/deserialization":
        handle_deserialization(params)
    elif route == "/stored_xss":
        handle_stored_xss(params)
    elif route == "/resource_injection":
        handle_resource_injection(params)
    else:
        print("[ERROR] Invalid route")


# Vulnerabilities with Data Flow and Sinks

# Arbitrary File Write Sink
def handle_arbitrary_file_write(params):
    file_path = get_file_path(params["filename"])
    write_file(file_path, params["content"])  # Sink

def get_file_path(filename):
    return f"./uploads/{filename}"

def write_file(path, content):
    with open(path, "w") as file:
        file.write(content)
    print(f"[SINK] File written at: {path}")


# SQL Injection Sink
def handle_sql_injection(params):
    query = build_sql_query(params["username"])
    execute_sql(query)  # Sink

def build_sql_query(username):
    return f"SELECT * FROM users WHERE username = '{username}';"

def execute_sql(query):
    conn = sqlite3.connect("demo.db")
    print(f"[SINK] Executing SQL: {query}")
    cursor = conn.execute(query)
    for row in cursor:
        print(f"Fetched User: {row}")
    conn.close()


# Command Injection Sink
def handle_command_injection(params):
    cmd = build_command(params["cmd"])
    run_command(cmd)  # Sink

def build_command(user_input):
    return f"ls {user_input}"

def run_command(cmd):
    print(f"[SINK] Executing Command: {cmd}")
    os.system(cmd)


# Dangerous Deserialization Sink
def handle_deserialization(params):
    payload = params["payload"]
    execute_payload(payload)  # Sink

def execute_payload(payload):
    func = compile(payload, "<string>", "exec")
    exec(func)
    print("[SINK] Deserialized and Executed Payload")


# Stored XSS Sink
def handle_stored_xss(params):
    content = params["content"]
    store_comment(content)  # Sink
    display_comments()

def store_comment(content):
    conn = sqlite3.connect("demo.db")
    query = f"INSERT INTO comments (content) VALUES ('{content}');"
    print(f"[SINK] Storing Comment: {query}")
    conn.execute(query)
    conn.commit()
    conn.close()

def display_comments():
    conn = sqlite3.connect("demo.db")
    cursor = conn.execute("SELECT content FROM comments;")
    for row in cursor:
        print(f"[SINK] Displayed Comment: <div>{row[0]}</div>")
    conn.close()


# Resource Injection Sink
def handle_resource_injection(params):
    file_path = params["file"]
    read_file(file_path)  # Sink

def read_file(path):
    with open(path, "r") as file:
        content = file.read()
        print(f"[SINK] File Content: {content}")


# Simulated Requests for Vulnerability Testing
simulate_request("/arbitrary_file_write", {"filename": "../../etc/passwd", "content": "malicious content"})
simulate_request("/sql_injection", {"username": "admin' OR '1'='1"})
simulate_request("/command_injection", {"cmd": "; rm -rf /"})
simulate_request("/deserialization", {"payload": "os.system('rm -rf /')"})
simulate_request("/stored_xss", {"content": "<script>alert('Stored XSS');</script>"})
simulate_request("/resource_injection", {"file": "../../etc/passwd"})
