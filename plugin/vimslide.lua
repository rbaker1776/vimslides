vim.api.nvim_create_user_command("Vimslides", function()
    require("vimslides").start_presentation()
end, {})
