vim.api.nvim_create_user_command("Present", function()
    require("vimslides.slides").present()
end, {})
