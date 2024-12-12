local M = {}

function M.renderPage(rawInput)
    local processed = M.prepareContent(rawInput)
    M.vulnerableXSS(processed)
end

function M.prepareContent(userData)
    -- Just passing data along
    return userData
end

function M.vulnerableXSS(userInput)
    local template = "<html><body><h1>" .. userInput .. "</h1></body></html>"
    print(template)
    return template
end

return M
