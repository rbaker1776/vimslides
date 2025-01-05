local parser = require("vimslide.parser")
local window = require("vimslide.window")

local M = {}

M.state = {
    parsed = {},
    current_slide = {},
    floats = {},
}

M.set_slide_content = function(idx)
    local width = vim.o.columns
    local slide = M.state.parsed.slides[idx]

    local padding = string.rep(' ', (width - #slide.title) / 2)
    local title = padding .. slide.title
    vim.api.nvim_buf_set_lines(M.state.floats.header.buffer, 0, -1, false, { title })
    vim.api.nvim_buf_set_lines(M.state.floats.body.buffer, 0, -1, false, slide.body)

    local footer = string.format(
        "  %d / %d | %s",
        M.state.current_slide,
        #(M.state.parsed.slides),
        M.state.title
    )
    vim.api.nvim_buf_set_lines(M.state.floats.footer.buffer, 0, -1, false, { footer })
end

M.start_presentation = function(opts)
    opts = opts or {}
    opts.bufnr = opts.bufnr or 0

    local lines = vim.api.nvim_buf_get_lines(opts.bufnr, 0, -1, false)
    M.state.parsed = parser.parse_slides
    M.state.current_slide = 1
    M.state.title = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(opts.bufnr), ":t")

    local windows = window.create_window_configurations()
    M.state.floats.background = window.create_floating_window(windows.background)
    M.state.floats.header = window.create_floating_window(windows.header)
    M.state.floats.body = window.create_floating_window(windows.body, true)
    M.state.floats.footer = window.create_floating_window(windows.footer)

    for name, float in pairs(M.state.floats) do
        vim.bo[float.buffer].filetype = "markdown"
    end

end

return M
