local Window = require("vimslides.ui.window")
local SlideShow = require("vimslides.core.slideshow")
local Executor = require("vimslides.data.executor")
local Parser = require("vimslides.data.parser")

local M = {}

M.is_running = false

local group = nil

M.quit = function()
    if not M.is_running then
        error("keybinds module quit before initialization")
    end

    pcall(vim.api.nvim_del_augroup_by_name, "vimslides-keybinds")
    group = nil

    M.is_running = false
end

M.init = function()
    if M.is_running then
        error("keybinds module initialized twice")
        return
    end

    group = vim.api.nvim_create_augroup("vimslides-keybinds", { clear = true })

    vim.keymap.set('n', '<S-Left>',  SlideShow.prev_slide, { buffer = Window.floats.body.buf, noremap = true })
    vim.keymap.set('n', '<S-Right>', SlideShow.next_slide, { buffer = Window.floats.body.buf, noremap = true })

    vim.keymap.set('n', '<leader>x', function()
        Executor.execute(Parser.get_current_code_block())
    end, { buffer = Window.floats.body.buf, noremap = true })

    M.is_running = true
end

return M
