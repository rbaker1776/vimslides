local parser = require("vimslides.parser")
local windows = require("vimslides.windows")

local M = {}

M.state = {
    slides = {},
    current_slide = 1,
    floats = {},
}

M.restore = {}

M.options = {
    executors = {
        cpp = execute_cpp_code,
    }
}

local function keymap(mode, keystroke, callback)
    vim.keymap.set(mode, keystroke, callback, {
        buffer = M.state.floats.body.buf
    })
end

M.enable_keymaps = function()
    keymap('n', '.', function()
        M.state.current_slide = math.min(M.state.current_slide + 1, #M.state.slides)
        M.project()
    end)

    keymap('n', ',', function()
        M.state.current_slide = math.max(M.state.current_slide - 1, 1)
        M.project()
    end)

    keymap('n', 'q', M.quit)
end

M.generate_footer = function()
    local width = vim.o.columns - 2
    
    local seperator = '|'
    local elements = {
        M.state.title,
        --"Section 3.1.4",
        "Slide " .. M.state.current_slide .. " / " .. #M.state.slides,
        --os.date(),
    }

    local total_element_length = (#elements - 1) * #seperator
    for i, element in ipairs(elements) do
        total_element_length = total_element_length + #element
    end

    local base_n_spaces = math.floor((width - total_element_length) / (2 * (#elements - 1)))
    local extra_n_spaces = (width - total_element_length) % (2 * (#elements - 1))

    local footer = " "
    for i, element in ipairs(elements) do
        footer = footer .. element
        if i == #elements then break end

        local seperator_string = string.rep(' ', base_n_spaces) .. seperator .. string.rep(' ', base_n_spaces)
        if 2 * (i - 1) < extra_n_spaces then
            seperator_string = ' ' .. seperator_string
        end
        if 2 * (i - 1) + 1 < extra_n_spaces then
            seperator_string = seperator_string .. ' '
        end

        footer = footer .. seperator_string
    end

    return footer
end

M.quit = function()
    for option, config in pairs(M.restore) do
        vim.opt[option] = config.original
    end
    for name, float in pairs(M.state.floats) do
        pcall(vim.api.nvim_win_close, float.win, true)
    end
end

M.project = function()
    local width = vim.o.columns
    local slide = M.state.slides[M.state.current_slide]
    
    local title = string.rep('#', slide.title.level - 1)
               .. string.rep(' ', ((width - #slide.title.text) / 2) - slide.title.level + 1)
               .. slide.title.text
    local footer = M.generate_footer()

    vim.api.nvim_buf_set_lines(M.state.floats.header.buf, 0, -1, false, { title  })
    vim.api.nvim_buf_set_lines(M.state.floats.body.buf,   0, -1, false, slide.body)
    vim.api.nvim_buf_set_lines(M.state.floats.footer.buf, 0, -1, false, { footer })

    for _, block in ipairs(slide.blocks) do
        local float = windows.create_float(windows.create_block_config(block.bounds.begin_idx, block.bounds.end_idx, M.state.floats.body.win))
        vim.api.nvim_buf_set_lines(float.buf, 0, -1, false, block.body)
    end
end

M.refresh = function()
    if not vim.api.nvim_win_is_valid(M.state.floats.body.win) or M.state.floats.body.win == nil then
        return
    end

    local updated = windows.create_configs()
    for name, float in pairs(M.state.floats) do
        vim.api.nvim_win_set_config(M.state.floats[name].win, updated[name])
    end
    
    M.project()
end

M.present = function(config)
    config = config or {}
    config.bufnr = config.bufnr or 0

    local lines = vim.api.nvim_buf_get_lines(config.bufnr, 0, -1, false)
    M.state.slides = parser.parse_slides(lines)
    M.state.current_slide = 1
    M.state.title = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(config.bufnr), ":t")

    local window_configs = windows.create_configs()
    M.state.floats.background = windows.create_float(window_configs.background)
    M.state.floats.header = windows.create_float(window_configs.header)
    M.state.floats.footer = windows.create_float(window_configs.footer)
    M.state.floats.body = windows.create_float(window_configs.body, true)

    for name, float in pairs(M.state.floats) do
        vim.bo[flot.buf].filetype = "markdown"
    end

    M.enable_keymaps()

    M.restore = {
        cmdheight = {
            original = vim.o.cmdheight,
            present = 0,
        },
    }

    for option, config in pairs(M.restore) do
        vim.opt[option] = config.present
    end

    vim.api.nvim_create_autocmd("VimResized", {
        group = vim.api.nvim_create_augroup("slide-resized", {}),
        callback = M.refresh,
    })

    M.project()
end

return M
