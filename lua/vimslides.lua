local parser = require("vimslides.parser")

local M = {}
    

local options = {}

local state = {
    slides = {},
    current_slide = {},
    floats = {},
}


local function create_window_configs()
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
        width = width - 14,
        height = height - 7,
        style = "minimal",
        border = { ' ' },
        col = 6,
        row = 4,
    }

    local footer_config = {
        relative = "editor",
        width = width,
        height = 1,
        style = "minimal",
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

local function create_floating_window(config, enter)
    if enter == nil then enter = false end

    local buf = vim.api.nvim_create_buf(false, true) -- no file, scratch buffer
    local win = vim.api.nvim_open_win(buf, enter or false, config)

    vim.api.nvim_win_set_option(win, "winhighlight", "Normal:Normal,FloatBorder:Normal")

    return {
        buf = buf,
        win = win,
    }
end


local function keymap(mode, key, callback)
    vim.keymap.set(mode, key, callback, {
        buffer = state.floats.body.buf
    })
end


M.start_presentation = function(opts)
    opts = opts or {}
    opts.bufnr = opts.bufnr or 0

    local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
    state.slides= parser.parse_slides(lines)
    state.current_slide = 1
    state.title = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(opts.bufnr), ":t")

    local windows = create_window_configs()
    state.floats.background = create_floating_window(windows.background)
    state.floats.header = create_floating_window(windows.header)
    state.floats.body = create_floating_window(windows.body, true)
    state.floats.footer = create_floating_window(windows.footer)

    for name, float in pairs(state.floats) do
        vim.bo[float.buf].filetype = "markdown"
    end

    local set_slide_content = function(idx)
        local width = vim.o.columns
        local slide = state.slides[idx]

        local padding = string.rep(" ", (width - #slide.title) / 2)
        local title = padding .. slide.title
        vim.api.nvim_buf_set_lines(state.floats.header.buf, 0, -1, false, { title })
        vim.api.nvim_buf_set_lines(state.floats.body.buf, 0, -1, false, slide.body)

        local footer = string.format(
            "  %d / %d | %s",
            state.current_slide,
            #(state.slides),
            state.title
        )
        vim.api.nvim_buf_set_lines(state.floats.footer.buf, 0, -1, false, { footer })
    end

    keymap('n', '.', function()
        state.current_slide = math.min(state.current_slide + 1, #state.slides)
        set_slide_content(state.current_slide)
    end)

    keymap('n', ',', function()
        state.current_slide = math.max(state.current_slide - 1, 1)
        set_slide_content(state.current_slide)
    end)

    keymap('n', 'q', function()
        vim.api.nvim_win_close(state.floats.body.win, true)
    end)

    local restore = {
        cmdheight = {
            original = vim.o.cmdheight,
            present = 0,
        }
    }

    for option, config in pairs(restore) do
        vim.opt[option] = config.present
    end

    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = state.floats.body.buf,
        callback = function()
            for option, config in pairs(restore) do
                vim.opt[option] = config.original
            end

            for name, float in pairs(state.floats) do
                pcall(vim.api.nvim_win_close, float.win, true)
            end
        end
    })

    vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("slide-resized", {}),
        callback = function()
            if not vim.api.nvim_win_is_valid(state.floats.body.win) or state.floats.body.win == nil then
                return
            end

            local updated = create_window_configs()
            for name, float in pairs(state.floats) do
                vim.api.nvim_win_set_config(state.floats[name].win, updated[name])
            end

            set_slide_content(state.current_slide)
        end,
    })

    set_slide_content(state.current_slide)
end


return M
