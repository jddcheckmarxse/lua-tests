local dbVuln   = require("db_vuln")
local xssVuln  = require("xss_vuln")
local cmdVuln  = require("cmd_vuln")
local desVuln  = require("deserialize_vuln")

-- Simulated user input sources
local function getUserInputForSQL()
    return "admin' OR '1'='1"
end

local function getUserInputForXSS()
    return "<script>alert('XSS');</script>"
end

local function getUserInputForCMD()
    return "ls; echo vulnerable"
end

local function getUserInputForDeserialize()
    return "os.execute('echo deserialized')"
end

-- Data flow: input -> intermediate function -> vulnerable sink

-- SQL Injection
local sqlInput = getUserInputForSQL()
dbVuln.processInput(sqlInput)

-- XSS
local xssInput = getUserInputForXSS()
xssVuln.renderPage(xssInput)

-- Command Injection
local cmdInput = getUserInputForCMD()
cmdVuln.runCommand(cmdInput)

-- Insecure Deserialization
local desInput = getUserInputForDeserialize()
desVuln.loadData(desInput)
