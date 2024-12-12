local json = require("json") -- For simulating JWT operations
local luasql = require("luasql.sqlite3") -- For database operations

-- Arbitrary File Write
function arbitraryFileWrite(input)
    local filePath = "./output/" .. input.filename
    local file = io.open(filePath, "w")
    file:write(input.content)
    file:close()
    print("File written: " .. filePath)
end

-- Code Injection
function codeInjection(input)
    local func = load(input)
    func()
end

-- Command Injection
function commandInjection(input)
    local cmd = "ls " .. input
    os.execute(cmd)
end

-- SQL Injection
function sqlInjection(input)
    local db = luasql.sqlite3()
    local conn = db:connect("demo.db")
    local query = "SELECT * FROM users WHERE username = '" .. input .. "';"
    local cursor = conn:execute(query)
    if cursor then
        local row = cursor:fetch({}, "a")
        while row do
            print(row.username)
            row = cursor:fetch(row, "a")
        end
        cursor:close()
    end
    conn:close()
    db:close()
end

-- Second Order SQL Injection
function secondOrderSQLInjection(input)
    local db = luasql.sqlite3()
    local conn = db:connect("demo.db")
    local insertQuery = "INSERT INTO users (username) VALUES ('" .. input .. "');"
    conn:execute(insertQuery)
    local vulnerableQuery = "SELECT * FROM users WHERE username = '" .. input .. "';"
    local cursor = conn:execute(vulnerableQuery)
    if cursor then
        local row = cursor:fetch({}, "a")
        while row do
            print(row.username)
            row = cursor:fetch(row, "a")
        end
        cursor:close()
    end
    conn:close()
    db:close()
end

-- Stored Code Injection
function storedCodeInjection(input)
    local db = luasql.sqlite3()
    local conn = db:connect("demo.db")
    local query = "INSERT INTO scripts (content) VALUES ('" .. input .. "');"
    conn:execute(query)
    local cursor = conn:execute("SELECT content FROM scripts;")
    if cursor then
        local row = cursor:fetch({}, "a")
        while row do
            local func = load(row.content)
            func()
            row = cursor:fetch(row, "a")
        end
        cursor:close()
    end
    conn:close()
    db:close()
end

-- Stored Command Injection
function storedCommandInjection(input)
    local db = luasql.sqlite3()
    local conn = db:connect("demo.db")
    conn:execute("INSERT INTO commands (cmd) VALUES ('" .. input .. "');")
    local cursor = conn:execute("SELECT cmd FROM commands;")
    if cursor then
        local row = cursor:fetch({}, "a")
        while row do
            os.execute(row.cmd)
            row = cursor:fetch(row, "a")
        end
        cursor:close()
    end
    conn:close()
    db:close()
end

-- Stored XSS
function storedXSS(input)
    local db = luasql.sqlite3()
    local conn = db:connect("demo.db")
    conn:execute("INSERT INTO comments (content) VALUES ('" .. input .. "');")
    local cursor = conn:execute("SELECT content FROM comments;")
    if cursor then
        local row = cursor:fetch({}, "a")
        while row do
            print("<div>" .. row.content .. "</div>")
            row = cursor:fetch(row, "a")
        end
        cursor:close()
    end
    conn:close()
    db:close()
end

-- Lua High Risk
function luaHighRisk(input)
    local file = io.open(input, "r")
    if file then
        local content = file:read("*a")
        print(content)
        file:close()
    end
end

-- Connection String Injection
function connectionStringInjection(input)
    local connectionString = "Server=" .. input.server .. ";Port=" .. input.port
    print("Connecting to: " .. connectionString)
end

-- Dangerous File Inclusion
function dangerousFileInclusion(input)
    local module = require(input)
    module.execute()
end

-- Deserialization of Untrusted Data
function deserializationOfUntrustedData(input)
    local loader = loadstring or load
    local func = loader(input)
    func()
end

-- Insufficiently Secure Password Storage Algorithm Parameters
function insecurePasswordStorage(password)
    local salt = os.date()
    local hashed = password .. salt
    print("Stored password: " .. hashed)
end

-- JWT No Signature Verification
function jwtNoSignatureVerification(input)
    local payload = json.decode(input)
    print("JWT Payload: " .. payload.data)
end

-- Reflected XSS All Clients
function reflectedXSSAllClients(input)
    print("<div>" .. input .. "</div>")
end

-- Resource Injection
function resourceInjection(input)
    local file = io.open(input.filePath, "r")
    if file then
        print(file:read("*a"))
        file:close()
    end
end

-- Example Inputs
arbitraryFileWrite({ filename = "../../etc/passwd", content = "malicious content" })
codeInjection("print('Injected Code')")
commandInjection("; rm -rf /")
sqlInjection("admin' OR '1'='1")
secondOrderSQLInjection("maliciousUser")
storedCodeInjection("os.execute('rm -rf /')")
storedCommandInjection("ls; rm -rf /")
storedXSS("<script>alert('XSS');</script>")
luaHighRisk("/etc/passwd")
connectionStringInjection({ server = "localhost; DROP TABLE users", port = "3306" })
dangerousFileInclusion("../../malicious_module")
deserializationOfUntrustedData("os.execute('rm -rf /')")
insecurePasswordStorage("password123")
jwtNoSignatureVerification('{"alg":"none","data":"malicious"}')
reflectedXSSAllClients("<script>alert('Reflected XSS');</script>")
resourceInjection({ filePath = "../../etc/passwd" })
