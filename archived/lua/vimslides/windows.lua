local M = {}

M.default_win_config = {
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
    header = { buf = nil, win = nil, config = vim.tbl_deep_extend("force", M.default_win_config, { border = "rounded", col = 1, width = vim.o.columns - 4, zindex = 3, }), },
    body   = { buf = nil, win = nil, config = vim.tbl_deep_extend("force", M.default_win_config, { row = 4, col = 6, width = vim.o.columns - 12, height = vim.o.lines - 6, zindex = 3, }), },
    footer = { buf = nil, win = nil, config = vim.tbl_deep_extend("force", M.default_win_config, { row = vim.o.lines - 1, width = vim.o.columns, zindex = 3, }), },
    background = { buf = nil, win = nil, config = vim.tbl_deep_extend("force", M.default_win_config, { width = vim.o.columns, height = vim.o.lines, zindex = 2, }), },
}

M.namespaces = {
    header = vim.api.nvim_create_namespace("vimslides-header"),
    body = vim.api.nvim_create_namespace("vimslides-body"),
    footer = vim.api.nvim_create_namespace("vimslides-footer"),
}

M.group = vim.api.nvim_create_augroup("vimslides-windows", {})

M.arrange = function()
    M.floats.header.config = vim.tbl_deep_extend("force", M.floats.header.config, { width = vim.o.columns - 4, })
    M.floats.body.config   = vim.tbl_deep_extend("force", M.floats.body.config, { width = vim.o.columns - 12, height = vim.o.lines - 6, })
    M.floats.footer.config = vim.tbl_deep_extend("force", M.floats.footer.config, { row = vim.o.lines - 1, width = vim.o.columns, })
    M.floats.background.config = vim.tbl_deep_extend("force", M.floats.background.config, { width = vim.o.columns, height = vim.o.lines })
    
    for _, float in pairs(M.floats) do
        vim.api.nvim_win_set_config(float.win, float.config)
    end
end

M.quit = function()
    for _, float in pairs(M.floats) do
        pcall(vim.api.nvim_win_close, float.win, true)
    end
end

M.init = function()
    for _, float in pairs(M.floats) do
        float.buf = vim.api.nvim_create_buf(false, true)
        float.win = vim.api.nvim_open_win(float.buf, false, float.config)
        vim.api.nvim_win_set_option(float.win, "winhighlight", "Normal:Normal,FloatBorder:Normal")
    end

    --vim.bo[M.floats.body.buf].filetype = "markdown"

    --vim.api.nvim_set_current_win(M.floats.body.win)

    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = M.floats.body.buf,
        callback = M.quit,
    })
end

--M.init()

return M
