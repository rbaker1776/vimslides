local config = require("vimslide.config")
local keymaps = require("vimslide.keymaps")
local parser = require("vimslide.parser")
local presentation = require("vimslide.presentation")

local M = {}

M.init = function(usr_config)
    config = vim.tbl_deep_extend("force", config, usr_config or {})
end

return M
