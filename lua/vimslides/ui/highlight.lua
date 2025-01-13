local Window = require("vimslides.ui.window")
local Utils = require("vimslides.data.utils")

local M = {}

M.is_running = false

M.normal = { a = "lualine_a_normal", b = "lualine_b_normal", c = "lualine_c_normal" }
M.insert = { a = "lualine_a_insert", b = "lualine_b_insert" }
M.visual = { a = "lualine_a_visual", b = "lualine_b_visual" }
M.command = { a = "lualine_a_command", b = "lualine_b_command" }
M.replace = { a = "lualine_a_replace", b = "lualine_b_replace" }

M.footer_background = "lualine_c_normal"
M.footer_transition = "vimslides_footer_transition"

M.titles = {
    "vimslides_title_1", "vimslides_title_2", "vimslides_title_3",
    "vimslides_title_4", "vimslides_title_5", "vimslides_title_6"
}

M.quit = function()
    if not M.is_running then
        error("highlight module quit before initialization")    
        return
    end

    vim.cmd("highlight clear vimslides_footer_transition")
        
    M.is_running = false
end

M.init = function()
    if M.is_running then
        error("highlight module initialized twice")
        return
    end

    require("lualine").setup()

    vim.api.nvim_set_hl(0, "vimslides_footer_transition", {
        fg = vim.api.nvim_get_hl_by_name(M.normal.b, true).background,
        bg = vim.api.nvim_get_hl_by_name(M.footer_background, true).background,
    })

    vim.api.nvim_set_hl(0, "vimslides_title_1", {
        fg = vim.api.nvim_get_hl_by_name("MarkdownH1", true).foreground,
        bg = vim.api.nvim_get_hl_by_name("MarkdownH1", true).background,
        bold = true,
    })
    vim.api.nvim_set_hl(0, "vimslides_title_2", {
        fg = vim.api.nvim_get_hl_by_name("MarkdownH2", true).foreground,
        bg = vim.api.nvim_get_hl_by_name("MarkdownH2", true).background,
        bold = true,
    })

    vim.api.nvim_set_hl(0, "vimslides_title_3", {
        fg = vim.api.nvim_get_hl_by_name("MarkdownH3", true).foreground,
        bg = vim.api.nvim_get_hl_by_name("MarkdownH3", true).background,
        bold = true,
    })

    vim.api.nvim_set_hl(0, "vimslides_title_4", {
        fg = vim.api.nvim_get_hl_by_name("MarkdownH4", true).foreground,
        bg = vim.api.nvim_get_hl_by_name("MarkdownH4", true).background,
        bold = true,
    })

    vim.api.nvim_set_hl(0, "vimslides_title_5", {
        fg = vim.api.nvim_get_hl_by_name("MarkdownH5", true).foreground,
        bg = vim.api.nvim_get_hl_by_name("MarkdownH5", true).background,
        bold = true,
    })

    vim.api.nvim_set_hl(0, "vimslides_title_6", {
        fg = vim.api.nvim_get_hl_by_name("MarkdownH6", true).foreground,
        bg = vim.api.nvim_get_hl_by_name("MarkdownH6", true).background,
        bold = true,
    })


    M.is_running = true
end

M.refresh = function()
    M.quit()
    M.init()
end

return M
