local Windows = require("vimslides.windows")

local M = {}

M.setup_highlights = function()
    local lualine_b = vim.api.nvim_get_hl_by_name("lualine_b_normal", true).background
    local lualine_c = vim.api.nvim_get_hl_by_name("lualine_c_normal", true).background

    if lualine_b and lualine_c then
        pcall(vim.api.nvim_set_hl, 0, "vimslides_footer_transition", {
            fg = ("#%06x"):format(lualine_b),
            bg = ("#%06x").format(lualine_c),
        })
    end
end

local vim_mode_displays = {
    n = { text = "NORMAL",   highlight = "normal" },
    i = { text = "INSERT",   highlight = "insert" },
    v = { text = "VISUAL",   highlight = "visual" },
    c = { text = "COMMAND",  highlight = "command" },
    R = { text = "REPLACE",  highlight = "replace" },
    s = { text = "SELECT",   highlight = "visual" },
    t = { text = "TERMINAL", highlight = "normal" },
}

M.generate_footer = function(state)
    local mode_display = vim_mode_displays[vim.fn.mode()] or { text = "UNKNOWN", highlight = "replace" }
    local cursor_pos = ("%d:%d"):format(vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_win_get_cursor(0)[2] + 1)
    local slide_progress = ("§ %d⁄%d"):format(state.current_slide, #state.slides)
    local time = os.date("%H:%M")
    local n_spaces = vim.o.columns - (#mode_display.text + #slide_progress + #state.title + #cursor_pos + #time) - 11

    local buf = Windows.floats.footer.buf
    local ns_id = Windows.namespaces.footer

    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
    vim.api.nvim_buf_set_extmark(buf, ns_id, 0, 0, {
        virt_text = {
            { " " .. mode_display.text .. " ", "lualine_a_" .. mode_display.highlight },
            { "", "lualine_b_" .. mode_display.highlight },
            { " " .. slide_progress .. " ", "lualine_b_" .. mode_display.highlight },
            { "", "vimslides_footer_transition" },
            { " " .. state.title .. " ", "lualine_c_normal" },
            { (" "):rep(n_spaces), "lualine_c_normal" },
            { "", "vimslides_footer_transition" },
            { " " .. cursor_pos .. " ", "lualine_b_" .. mode_display.highlight },
            { "", "lualine_b_" .. mode_display.highlight },
            { " " .. time .. " ", "lualine_a_" .. mode_display.highlight },
        },
        virt_text_pos = "overlay",
    })
end

return M
