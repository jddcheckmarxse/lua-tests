local M = {}

function M.runCommand(rawInput)
    local processed = M.prepareCommand(rawInput)
    M.vulnerableCommandInjection(processed)
end

function M.prepareCommand(userData)
    -- Just passing data along
    return userData
end

function M.vulnerableCommandInjection(cmd)
    print(cmd)
    local handle = io.popen(cmd)
    local result = handle:read("*a")
    handle:close()
    print(result)
end

return M
