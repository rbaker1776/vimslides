local M = {}

M.is_running = false

local default_win_config = {
    relative = "editor",
    style = "minimal",
    border = "none",
    row = 0,
    col = 0,
    width = 1,
    height = 1,
    zindex = 1,
}
    
M.floats = {
    header = { config = vim.tbl_deep_extend("force", default_win_config, { border = "rounded", col = 1, width = vim.o.columns - 4, zindex = 2, }), },
    body   = { config = vim.tbl_deep_extend("force", default_win_config, { row = 4, col = 6, width = vim.o.columns - 12, height = vim.o.lines - 6, zindex = 2, }), },
    footer = { config = vim.tbl_deep_extend("force", default_win_config, { row = vim.o.lines - 1, width = vim.o.columns, zindex = 2, }), },
    background = { config = vim.tbl_deep_extend("force", default_win_config, { width = vim.o.columns, height = vim.o.lines, zindex = 1, }), },
}

M.is_showing_code = false

M.code_floats = {
    code   = { config = vim.tbl_deep_extend("force", default_win_config, { border = "rounded", row = 2, col = 3, width = vim.o.columns - 8, height = math.floor(vim.o.lines / 2) - 1, zindex = 4, }), },
    output = { config = vim.tbl_deep_extend("force", default_win_config, { border = "rounded", row = math.floor(vim.o.lines / 2) + 5, col = 3, width = vim.o.columns - 8, height = math.ceil(vim.o.lines / 2) - 10, zindex = 4, }), },
    background = { config = vim.tbl_deep_extend("force", default_win_config, { width = vim.o.columns, height = vim.o.lines, zindex = 3, }), },
}

M.arrange = function()
    M.floats.header.config = vim.tbl_deep_extend("force", M.floats.header.config, { width = vim.o.columns - 4, })
    M.floats.body.config   = vim.tbl_deep_extend("force", M.floats.body.config, { width = vim.o.columns - 12, height = vim.o.lines - 6, })
    M.floats.footer.config = vim.tbl_deep_extend("force", M.floats.footer.config, { row = vim.o.lines - 1, width = vim.o.columns, })
    M.floats.background.config = vim.tbl_deep_extend("force", M.floats.background.config, { width = vim.o.columns, height = vim.o.lines })
    M.code_floats.code.config = vim.tbl_deep_extend("force", M.code_floats.code.config, { width = vim.o.columns - 8, height = math.floor(vim.o.lines / 2) - 1, })
    M.code_floats.output.config = vim.tbl_deep_extend("force", M.code_floats.code.config, { width = vim.o.columns - 8, row = math.floor(vim.o.lines / 2) + 5, height = math.ceil(vim.o.lines / 2) - 10 })
    M.code_floats.background.config = vim.tbl_deep_extend("force", M.code_floats.background.config, { width = vim.o.columns, height = vim.o.lines })

    for _, float in pairs(M.floats) do
        pcall(vim.api.nvim_win_set_config, float.win, float.config)
    end

    if M.is_showing_code then
        for _, float in pairs(M.code_floats) do
            pcall(vim.api.nvim_win_set_config, float.win, float.config)
        end
    end
end

M.show_code = function()
    if M.is_showing_code then
        return
    end

    for name, float in pairs(M.code_floats) do
        float.win = vim.api.nvim_open_win(float.buf, false, float.config)
        vim.api.nvim_win_set_option(float.win, "winhighlight", "Normal:Normal,FloatBorder:Normal")
    end

    M.is_showing_code = true
end

M.hide_code = function()
    if not M.is_showing_code then
        return
    end
    
    for name, float in pairs(M.code_floats) do
        pcall(vim.api.nvim_win_close, float.win, true)
    end

    M.is_showing_code = false
end

M.quit = function()
    if not M.is_running then
        error("window module quit before initialization")
        return
    end

    for _, float in pairs(M.floats) do
        pcall(vim.api.nvim_win_close, float.win, true)
    end

    M.is_running = false
end

M.init = function()
    if M.is_running then
        error("window module initialized twice")
        return
    end

    for name, float in pairs(M.floats) do
        float.buf = vim.api.nvim_create_buf(false, true)
        float.win = vim.api.nvim_open_win(float.buf, false, float.config)
        float.ns = vim.api.nvim_create_namespace("vimslides-" .. name)
        vim.api.nvim_win_set_option(float.win, "winhighlight", "Normal:Normal,FloatBorder:Normal")
    end

    for name, float in pairs(M.code_floats) do
        float.buf = vim.api.nvim_create_buf(false, true)
        float.ns = vim.api.nvim_create_namespace("vimslides-" .. name)
    end

    vim.api.nvim_buf_set_lines(M.floats.background.buf, 0, -1, false, vim.split(("%s\n"):format((" "):rep(M.floats.background.config.width)):rep(M.floats.background.config.height), '\n'))

    pcall(vim.api.nvim_set_current_win, M.floats.body.win)

    M.arrange()
    M.is_running = true
end

--M.init()

return M
