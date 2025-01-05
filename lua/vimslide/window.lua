local M = {}

M.create_window_configs = function()
    local width = vim.o.columns
    local height = vim.o.lines

    local background_config = {
        relative = "editor",
        width = width,
        height = height,
        style = "minimal",
        col = 0,
        row = 0,
        zindex = 1,
    }

    local header_config = {
        relative = "editor",
        width = width,
        height = 1,
        style = "minimal",
        border = "rounded",
        col = 0,
        row = 0,
        zindex = 2,
    }

    local body_config = {
        relative = "editor",
        width = width - 8,
        height = height - 7,
        style = "minimal",
        border = { ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' },
        col = 8,
        row = 4,
    }

    local footer_config = {
        relative = "editor",
        width = width,
        height = 1,
        style = "normal",
        col = 0,
        row = height - 1,
        zindex = 3,
    }

    return {
        background = background_config,
        header = header_config,
        body = body_config,
        footer = footer_config,
    }
end

M.create_floating_window = function(config, enter)
    if enter == nil then enter = false end

    local buffer = vim.api.nvim_create_buf(false, true) -- no file, scratch buffer
    local window = vim.api.nvim_open_win(buffer, enter or false, config)

    return {
        buffer = buffer,
        window = window,
    }
end

return M
