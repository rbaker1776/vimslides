
local State = {}

State.title = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")


local Windows = {}

Windows.default_window_config = {
    relative = "editor",
    row = 0,
    col = 0,
    width = 1,
    height = 1,
}

Windows.floats = {
    header = { buf = nil, win = nil, config = Windows.default_window_config, },
    body   = { buf = nil, win = nil, config = Windows.default_window_config, },
    footer = { buf = nil, win = nil, config = Windows.default_window_config, },
    background = { buf = nil, win = nil, config = Windows.default_window_config, },
}

Windows.namespace = vim.api.nvim_create_namespace("vimslides-windows")

Windows.layout = function()
    Windows.floats.header.config = {    
        relative = "editor",
        style = "minimal",
        border = "rounded",
        row = 0,
        col = 1,
        width = vim.o.columns - 4,
        height = 1,
        zindex = 3,
    }

    Windows.floats.body.config = {
        relative = "editor",
        style = "minimal",
        border = "none",
        row = 4,
        col = 6,
        width = vim.o.columns - 12,
        height = vim.o.lines - 6,
        zindex = 3,
    }

    Windows.floats.footer.config = {
        relative = "editor",
        style = "minimal",
        border = "none",
        row = vim.o.lines - 1,
        col = 0,
        width = vim.o.columns,
        height = 1,
        zindex = 3,
    }

    Windows.floats.background.config = {
        relative = "editor",
        style = "minimal",
        border = "none",
        row = 0,
        col = 0,
        width = vim.o.columns,
        height = vim.o.lines,
        zindex = 2,
    }

    for _, float in pairs(Windows.floats) do
        pcall(vim.api.nvim_win_set_config, float.win, float.config)
    end
end

Windows.quit = function()
    for _, float in pairs(Windows.floats) do
        pcall(vim.api.nvim_win_close, float.win, true)
    end
end

Windows.init = function()
    for _, float in pairs(Windows.floats) do
        float.buf = vim.api.nvim_create_buf(false, true)
        float.win = vim.api.nvim_open_win(float.buf, false, float.config)
        vim.api.nvim_win_set_option(float.win, "winhighlight", "Normal:Normal,FloatBorder:Normal")
        vim.bo[float.buf].filetype = "markdown"
    end

    Windows.layout()
    vim.api.nvim_set_current_win(Windows.floats.body.win)
end


local function vim_mode()
     local mode_displays = {
        n = { name = "NORMAL",   highlight = "normal" },
        i = { name = "INSERT",   highlight = "insert" },
        v = { name = "VISUAL",   highlight = "visual" },
        V = { name = "V-LINE",   highlight = "visual" },
        [''] = { name = "V-BLOCK", highlight = "visual" },
        c = { name = "COMMAND",  highlight = "command" },
        R = { name = "REPLACE",  highlight = "replace" },
        s = { name = "SELECT",   highlight = "visual" },
        S = { name = "S-LINE",   highlight = "visual" },
        t = { name = "TERMINAL", highlight = "normal" },
    }

    return mode_displays[vim.fn.mode()] or { name = "UNKNOWN" .. vim.fn.mode(), highlight = "normal" }    
end

local function write_footer()
    local buf = Windows.floats.footer.buf
    local ns_id = Windows.namespace
    local current_col = 0

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { (' '):rep(vim.o.columns) })

    local mode = vim_mode()  
    local slide_progress = "2⁄20"
    vim.api.nvim_buf_set_extmark(buf, ns_id, 0, current_col, {
        virt_text = {
            { ' ' .. mode.name .. ' ', "lualine_a_" .. mode.highlight },
            { " § " .. slide_progress .. "  ", "lualine_b_" .. mode.highlight }
        },
        virt_text_pos = "overlay",
    })
    current_col = current_col + #mode.name + 2 -- ' ' .. mode.name .. ' '
    current_col = current_col + (#slide_progress - 2) + 7

    --[[
    local slide_progress = "2⁄20"
    vim.api.nvim_buf_set_extmark(buf, ns_id, 0, current_col, {
        virt_text = {{ " § " .. slide_progress .. "  ", "lualine_b_" .. mode.highlight }},
        virt_text_pos = "overlay",
    })
    current_col = current_col + (#slide_progress - 2) + 7
    --]]

    local lualine_b_normal = vim.api.nvim_get_hl_by_name("lualine_b_normal", true)
    local statusline = vim.api.nvim_get_hl_by_name("StatusLine", true)
    vim.api.nvim_set_hl(0, "VimslidesFooterTransition", {
        fg = string.format("#%06x", lualine_b_normal.background),
        bg = string.format("#%06x", statusline.background),
    })

    vim.api.nvim_buf_set_extmark(buf, ns_id, 0, current_col, {
        virt_text = {{ " ", "VimslidesFooterTransition" }},
        virt_text_pos = "overlay"
    })
    current_col = current_col + 2

    vim.api.nvim_buf_set_extmark(buf, ns_id, 0, current_col, {
        virt_text = {{ State.title, "lualine_c_normal" }},
        virt_text_pos = "overlay",
    })
    current_col = current_col + #State.title

    local current_col_reverse = vim.o.columns

    local time = os.date("%H:%M")
    current_col_reverse = current_col_reverse - #time - 2
    vim.api.nvim_buf_set_extmark(buf, ns_id, 0, current_col_reverse, {
        virt_text = {{ ' ' .. time .. ' ', "lualine_a_" .. mode.highlight }},
        virt_text_pos = "overlay",
    })

    local cursor = vim.api.nvim_win_get_cursor(0)
    local cursor_pos = ("%d:%d"):format(cursor[1], cursor[2] + 1)
    current_col_reverse = current_col_reverse - #cursor_pos - 4
    vim.api.nvim_buf_set_extmark(buf, ns_id, 0, current_col_reverse, {
        virt_text = {{ ' ' .. cursor_pos .. " ", "lualine_b_" .. mode.highlight }},
        virt_text_pos = "overlay",
    })

    vim.api.nvim_buf_set_extmark(buf, ns_id, 0, current_col, {
        virt_text = {{ (' '):rep(current_col_reverse - current_col), "StatusLine" }},
        virt_text_pos = "overlay",
    })
end


local Keymaps = {}

Keymaps.init = function()
    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = Windows.floats.body.buf,
        callback = Windows.quit,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = Windows.floats.body.buf,
        callback = write_footer,
    })

    vim.api.nvim_create_autocmd("ModeChanged", {
        buffer = Windows.floats.body.buf,
        callback = write_footer,
    })
end


Windows.init()
Keymaps.init()
write_footer()
