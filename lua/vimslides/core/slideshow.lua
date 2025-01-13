local Config = require("vimslides.core.config")
local Parser = require("vimslides.data.parser")
local Window = require("vimslides.ui.window")
local Renderer = require("vimslides.ui.renderer")
local Highlight = require("vimslides.ui.highlight")
local Utils = require("vimslides.data.utils")

local M = {}

M.is_running = false

M.slides = {}
M.current_slide = 1
M.title = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")

M.project = function(is_editing)
    local slide = M.slides[M.current_slide]

    Renderer.render_header(slide.title)

    if not is_editing then
        Renderer.render_body(slide.body)
    end

    local edit_mode = Utils.edit_mode()
    local mode_highlight = Highlight[edit_mode.highlight]
    Renderer.render_footer({{
        { (" %s "):format(edit_mode.text), mode_highlight.a },
        { (" § %d⁄%d "):format(M.current_slide, #M.slides), mode_highlight.b },
        { "", Highlight.footer_transition },
        { (" %s "):format(M.title), Highlight.footer_background },
    }, {
        { "", Highlight.footer_transition },
        { (" %d:%d "):format(vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_win_get_cursor(0)[2] + 1), mode_highlight.b },
        { (" %s "):format(os.date("%H:%M")), mode_highlight.a }
    }})

    Renderer.render_code_outlines(vim.api.nvim_buf_get_lines(Window.floats.body.buf, 0, -1, false))
end

M.goto_slide = function(slide)
    M.current_slide = slide 
    M.project()
end

M.next_slide = function()
    M.current_slide = math.min(M.current_slide + 1, #M.slides)
    M.project()
end

M.prev_slide = function()
    M.current_slide = math.max(M.current_slide - 1, 1)
    M.project()
end

M.quit = function()
    if not M.is_running then
        error("slideshow module quit before initialization")
        return
    end
    
    M.is_running = false
end

M.init = function()
    if M.is_running then
        error("slideshow module initialized twice")
        return
    end

    local lines = vim.api.nvim_buf_get_lines(Config.bufnr, 0, -1, false)
    M.slides = Parser.parse_slides(lines)

    M.project()

    M.is_running = true
end

return M
