local json = require("json")
local luasql = require("luasql.sqlite3")

-- Simulated HTTP request function
function simulateRequest(route, params)
    if route == "/arbitrary_file_write" then
        handleArbitraryFileWrite(params)
    elseif route == "/sql_injection" then
        handleSQLInjection(params)
    elseif route == "/command_injection" then
        handleCommandInjection(params)
    elseif route == "/deserialization" then
        handleDeserialization(params)
    elseif route == "/stored_xss" then
        handleStoredXSS(params)
    elseif route == "/resource_injection" then
        handleResourceInjection(params)
    else
        print("[ERROR] Invalid route")
    end
end

-- Vulnerabilities with Data Flow and Sinks

-- Arbitrary File Write Sink
function handleArbitraryFileWrite(params)
    local filePath = getFilePath(params["filename"])
    writeFile(filePath, params["content"]) -- Sink
end

function getFilePath(filename)
    return "./uploads/" .. filename
end

function writeFile(path, content)
    local file = io.open(path, "w")
    file:write(content)
    file:close()
    print("[SINK] File written at: " .. path)
end

-- SQL Injection Sink
function handleSQLInjection(params)
    local query = buildSQLQuery(params["username"])
    executeSQL(query) -- Sink
end

function buildSQLQuery(username)
    return "SELECT * FROM users WHERE username = '" .. username .. "';"
end

function executeSQL(query)
    local db = luasql.sqlite3()
    local conn = db:connect("demo.db")
    print("[SINK] Executing SQL: " .. query)
    local cursor = conn:execute(query)
    if cursor then
        local row = cursor:fetch({}, "a")
        while row do
            print("Fetched User: " .. row.username)
            row = cursor:fetch(row, "a")
        end
        cursor:close()
    end
    conn:close()
end

-- Command Injection Sink
function handleCommandInjection(params)
    local cmd = buildCommand(params["cmd"])
    runCommand(cmd) -- Sink
end

function buildCommand(input)
    return "ls " .. input
end

function runCommand(cmd)
    print("[SINK] Executing Command: " .. cmd)
    os.execute(cmd)
end

-- Dangerous Deserialization Sink
function handleDeserialization(params)
    local payload = params["payload"]
    executePayload(payload) -- Sink
end

function executePayload(payload)
    local func = load(payload)
    if func then
        print("[SINK] Executing Deserialized Payload")
        func()
    end
end

-- Stored XSS Sink
function handleStoredXSS(params)
    local content = params["content"]
    storeComment(content) -- Sink
    displayComments()
end

function storeComment(content)
    local db = luasql.sqlite3()
    local conn = db:connect("demo.db")
    local query = "INSERT INTO comments (content) VALUES ('" .. content .. "');"
    print("[SINK] Storing Comment: " .. query)
    conn:execute(query)
    conn:close()
end

function displayComments()
    local db = luasql.sqlite3()
    local conn = db:connect("demo.db")
    local cursor = conn:execute("SELECT content FROM comments;")
    if cursor then
        local row = cursor:fetch({}, "a")
        while row do
            print("[SINK] Displayed Comment: <div>" .. row.content .. "</div>")
            row = cursor:fetch(row, "a")
        end
        cursor:close()
    end
    conn:close()
end

-- Resource Injection Sink
function handleResourceInjection(params)
    local file = params["file"]
    readFile(file) -- Sink
end

function readFile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        print("[SINK] File Content: " .. content)
        file:close()
    end
end

-- Simulated Requests for Vulnerability Testing
simulateRequest("/arbitrary_file_write", {filename = "../../etc/passwd", content = "malicious content"})
simulateRequest("/sql_injection", {username = "admin' OR '1'='1"})
simulateRequest("/command_injection", {cmd = "; rm -rf /"})
simulateRequest("/deserialization", {payload = "os.execute('rm -rf /')"})
simulateRequest("/stored_xss", {content = "<script>alert('Stored XSS');</script>"})
simulateRequest("/resource_injection", {file = "../../etc/passwd"})


unction handle(r)
        r.content_type = "text/html"
        local username = r:parseargs().username or ""
        local database, err = r:dbacquire("mysql", "host=localhost,user=user,pass=,dbname=dbname")
        if not err then
           local sl = 'SELECT * FROM users WHERE username="'..username..'"'
           local results, err = database:query(r,sl)
           -- (...)
           database:close()
        else
           r:puts("Could not connect to the database: " .. err)
        end
    end

    -- CGILua & LuaSQL
    -- /vulnerable.lua?name=John');SQLBELOW
    -- /shell.lp?cmd=dir
    cgilua.htmlheader()
    local sqlite3 = require "luasql.sqlite3"
    local name = cgilua.QUERY.name
    local env  = sqlite3.sqlite3()
    local conn = env:connect('mydb.sqlite')
    local sql = [[
    CREATE TABLE sample ('id' INTEGER, 'name' TEXT);
    INSERT INTO sample values('1','%s')
    ]]
    sql = string.format(sql, name)
    for l in string.gmatch(sql, "[^;]+") do 
        conn:execute(l) 
    end
    -- (...)
    conn:close()
    env:close()

    -- SQLLite shell upload example for CGILua
    -- ATTACH DATABASE 'shell.lp' AS shell;
    -- CREATE TABLE shell.demo (data TEXT);
    -- INSERT INTO shell.demo (data) VALUES ('<? os.execute(cgilua.QUERY.cmd) ?>

     -- Nginx & ngx_lua
    -- /vulnerable.lua?file=/etc/passwd%00
    -- /vulnerable.lua?file=c:\boot.ini%00
    ngx.header.content_type = "text/html"
    local file = ngx.req.get_uri_args().file or ""
    local f = io.open(file..".txt")
    local result = f:read("*a")
    f:close()
    ngx.say(result)
 

    -- ngx_lua
    -- /vulnerable.lua?name=John")%20os.execute("notepad.exe
    local name = ngx.req.get_uri_args().name or ""
    ngx.header.content_type = "text/html"
    local html = string.format([[
     ngx.say("Hello, %s")
     ngx.say("Today is "..os.date())
    ]], name)
    loadstring(html)()

    -- CGILua
    -- /vulnerable.lua?name=<? os.execute('ls -la') ?>
    -- /vulnerable.lua?name=<? os.execute('dir') ?>
    -- Print the source of the vulnerable script:
    -- /vulnerable.lua?name=<? cgilua.put(io.open(cgilua.script_path):read('*a')) ?>
    local name = cgilua.QUERY.name or ""
    cgilua.htmlheader()
    local html = string.format([[
    <html>
    <body>
    Hello, %s!
    Today is <?=os.date()?>
    </body>
    </html>
    ]], name)
    html = cgilua.lp.translate(html)
    loadstring(html)()


        -- /vulnerable.lua?user=demo%20|%20dir%20c:\
    -- mod_lua
    function handle(r)
        local user = r:parseargs().user or ""
        local handle = io.popen("dir "..user)
        local result = handle:read("*a")
        handle:close()
        r:puts(result)
       end
       -- mod_lua (2)
       function handle(r)
        local user = r:parseargs().user or ""
        os.execute("ls -l /home/"..user)
       end
   
       -- ngx_lua
       ngx.header.content_type = "text/plain"
       local user = ngx.req.get_uri_args().user or ""
       local handle = io.popen("ls -l /home/"..user)
       local result = handle:read("*a")
       handle:close()
       ngx.say(result)


         -- mod_lua
    -- /vulnerable.lua?user=demo%0d%0aNew-Header:SomeValue
    -- /vulnerable.lua?user=%0d%0a%0d%0a<script>alert('XSS')</script>
    function handle(r)
        local user = r:parseargs().user or ""
        r.content_type = "text/html"
        r.headers_out['X-Test'] = user
        r:puts('Some text')
        return apache2.OK
       end
   
       -- ngx_lua
       -- /vulnerable.lua?name=%0d%0aNewHeader:Value
       local name = ngx.req.get_uri_args().name or ""
       ngx.header.content_type = "text/html"
       ngx.redirect("http://www.somehost.com/"..name)
   
       -- ngx_lua (2)
       -- /vulnerable.lua?user=test%0d%0aNewHeader:Value
       local user = ngx.req.get_uri_args().user or ""
       ngx.header['X-Test'] = user
       ngx.say('Some text')
   
       -- CGILua
       -- /vulnerable.lua?url=http://someurl%0d%0aNew-Header:SomeValue
       local url = cgilua.QUERY.url or ""
       cgilua.redirect(url)
   
       -- CGILua (2)
       -- /vulnerable.lua?demo=test%0d%0aLocation:http://www.somehost.com
       local demo = cgilua.QUERY.demo or ""
       cgilua.header('X-Test',demo)
       cgilua.htmlheader()
    


    -- /vulnerable.lua?email=john@somedomain.com
    -- /vulnerable.lua?email=<script>alert('john@somedomain.com XSS')</script>
    local email = ngx.req.get_uri_args().email or ""
    ngx.header.content_type = "text/html"
    if email:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w+") then
       ngx.say(email)
    end
 