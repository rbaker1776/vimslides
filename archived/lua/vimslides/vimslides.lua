local Windows = require("vimslides.windows")
local Scribe = require("vimslides.scribe")
local Parser = require("vimslides.parser")
local Content = require("vimslides.content")

local M = {}

M.state = {
    slides = {},
    current_slide = 1,
    title = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t"),
}

M.options = {
    cmdheight = {
        original = vim.o.cmdheight,
        present = 0,
    }
}

M.group = vim.api.nvim_create_augroup("vimslides-vimslides", {})

local function set_title()
    local title = M.state.slides[M.state.current_slide].title
    vim.api.nvim_buf_set_lines(Windows.floats.header.buf, 0, -1, false, { title.text })
end

M.project = function()
    Content.setup_highlights()
    set_title()
    Content.generate_footer(M.state)
end

M.quit = function()
    Windows.quit()
    vim.api.nvim_clear_autocmds({ group = M.group })
    for option, config in pairs(M.options) do vim.opt[option] = config.original end 
end

M.enable_autocmds = function()
    vim.api.nvim_create_autocmd("VimResized", {
        group = M.group,
        callback = function()
            Windows.arrange()
            M.project()
        end
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = Windows.floats.body.buf,
        group = M.group,
        callback = M.project,
    })

    vim.api.nvim_create_autocmd("ModeChanged", {
        buffer = Windows.floats.body.buf,
        group = M.group,
        callback = M.project,
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = '*',
        group = M.group,
        callback = function()
            Content.setup_highlights()
            M.project()
        end
    })
end

M.init = function()
    Windows.init()
    for option, config in pairs(M.options) do vim.opt[option] = config.present end 

    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    lines = {
    "# Features",
    "* Content",
    "* Content",
    "# Content",
    "# Title",
    }
    M.state.slides = Parser.parse_slides(lines)

    M.enable_autocmds()
    Content.setup_highlights()
    M.project()
end

M.init()

return M
