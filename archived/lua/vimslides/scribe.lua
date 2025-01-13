local Windows = require("vimslides.windows")

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

M.generate_footer = function()
end
