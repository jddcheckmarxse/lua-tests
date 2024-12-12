local M = {}

-- Intermediate step to show data flow
function M.processInput(raw)
    local prepared = M.prepareForQuery(raw)
    M.vulnerableSQL(prepared)
end

function M.prepareForQuery(userData)
    -- No sanitization, just passing data along
    return userData
end

function M.vulnerableSQL(queryParam)
    local luasql = require("luasql.sqlite3")
    local db = luasql.sqlite3()
    local conn = db:connect("demo.db")

    local query = "SELECT * FROM users WHERE username = '" .. queryParam .. "';"
    print(query)
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

return M
