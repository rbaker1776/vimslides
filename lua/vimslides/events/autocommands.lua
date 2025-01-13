local Window = require("vimslides.ui.window")
local Highlight = require("vimslides.ui.highlight")
local SlideShow = require("vimslides.core.slideshow")

local M = {}

M.is_running = false

local group = nil

M.quit = function()
    if not M.is_running then
        error("autocommands module quit before initialization")
        return
    end

    pcall(vim.api.nvim_del_augroup_by_name, "vimslides-autocommands")
    group = nil

    M.is_running = false
end

M.init = function(on_quit, redraw)
    if M.is_running then
        error("autocommands module initialized twice")
        return
    end

    group = vim.api.nvim_create_augroup("vimslides-autocommands", { clear = true })

    --[[
    vim.api.nvim_create_autocmd("BufLeave", {
        group = group,
        buffer = Window.floats.body.buf,
        callback = on_quit,
    })
    --]]

    vim.api.nvim_create_autocmd("VimResized", {
        group = group,
        buffer = Window.floats.body.buf,
        callback = function()
            Window.arrange()
            SlideShow.project()
        end,
    })

    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "ModeChanged" }, {
        group = group,
        buffer = Window.floats.body.buf,
        callback = SlideShow.project,
    })

    vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        pattern = '*',
        callback = function()
            Highlight.refresh()
            SlideShow.project(true)
        end
    })

    M.is_running = true
end

return M
