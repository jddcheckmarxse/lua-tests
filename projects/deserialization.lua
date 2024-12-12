local M = {}

function M.loadData(rawInput)
    local processed = M.prepareData(rawInput)
    M.vulnerableDeserialization(processed)
end

function M.prepareData(userData)
    -- Just passing data along
    return userData
end

function M.vulnerableDeserialization(serializedData)
    local loader = loadstring or load
    local func = loader(serializedData)
    if func then
        func()
    end
end

return M
