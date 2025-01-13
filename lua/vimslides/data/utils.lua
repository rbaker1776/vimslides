local M = {}

local vim_mode_displays = {
    n = { text = "NORMAL",   highlight = "normal" },
    i = { text = "INSERT",   highlight = "insert" },
    v = { text = "VISUAL",   highlight = "visual" },
    c = { text = "COMMAND",  highlight = "command" },
    R = { text = "REPLACE",  highlight = "replace" },
    s = { text = "SELECT",   highlight = "visual" },
    t = { text = "TERMINAL", highlight = "normal" },
}

M.edit_mode = function()
    return vim_mode_displays[vim.fn.mode()] or { text = "UNKNOWN", highlight = "replace" }
end

-- removes leading and trailing empty strings from a table
M.strip_ws = function(body)
    while #body > 0 and body[1] == "" do
        table.remove(body, 1)
    end
    
    while #body > 0 and body[#body] == "" do
        table.remove(body)
    end
end

-- pairs elements of a table: { 1, 2, 3, 4 } -> {{ 1, 2 }, { 3, 4 }}
M.pair_up = function(tbl)
    local pairs = {}
    
    for i = 1, #tbl, 2 do
        table.insert(pairs, { tbl[i], tbl[i + 1] })
    end

    return pairs
end


return M
