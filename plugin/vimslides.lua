local vimslides = require("vimslides.core.init")

vim.api.nvim_create_user_command("Present", vimslides.start_presentation, {})
