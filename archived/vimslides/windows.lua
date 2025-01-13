local M = {}

local function create_background_config()
    return {
        relative = "editor",
        width = vim.o.columns,
        height = vim.o.lines,
        style = "minimal",
        col = 0,
        row = 0,
        zindex = 1,
    }
end

local function create_header_config()
    return {
        relative = "editor",
        width = vim.o.columns,
        height = 1,
        style = "minimal",
        border = "rounded",
        col = 0,
        row = 0,
        zindex = 2,
    }
end

local function create_body_config(fancy)
    local body_config = {}

    body_config = {
        relative = "editor",
        width = vim.o.columns - 12,
        height = vim.o.lines - 6,
        col = 5,
        row = 3,
        zindex=10,
    }

    if not fancy then
        body_config.border = { ' ' }
        body_config.style = "minimal"
    else
        body_config.border = { "", ' ', ' ', ' ', ' ', ' ', "", "" }
    end

    return body_config
end

local function create_footer_config()
    return {
        relative = "editor",
        width = vim.o.columns,
        height = 1,
        style = "minimal",
        col = 0,
        row = vim.o.lines - 1,
        zindex = 3,
    }
end

M.create_block_config = function(begin_line, end_line, slide_window)
    return {
        relative = "win",
        win = slide_window,
        width = vim.o.columns - 12,
        height = end_line - begin_line - 1,
        border = "rounded",
        zindex = 20,
        row = begin_line,
        col = 0,
    }
end

M.create_configs = function()
    return {
        background = create_background_config(),
        header = create_header_config(),
        body = create_body_config(),
        footer = create_footer_config(),
    }
end

M.create_float = function(config, enter)
    if enter == nil then enter = false end

    local buf = vim.api.nvim_create_buf(false, true) -- no file, scratch buffer
    local win = vim.api.nvim_open_win(buf, enter or false, config)

    vim.api.nvim_win_set_option(win, "winhighlight", "Normal:Normal,FloatBorder:Normal")

    return {
        buf = buf,
        win = win,
    }
end

return M
