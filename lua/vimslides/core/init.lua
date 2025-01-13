local Window = require("vimslides.ui.window")
local Highlight = require("vimslides.ui.highlight")
local KeyBinds = require("vimslides.events.keybinds")
local AutoCommands = require("vimslides.events.autocommands")
local SlideShow = require("vimslides.core.slideshow")

local M = {}

M.end_presentation = function()
    SlideShow.quit()
    AutoCommands.quit()
    KeyBinds.quit()
    Highlight.quit()
    Window.quit()
end

M.start_presentation = function()
    Window.init(Config)
    Highlight.init()
    KeyBinds.init(M.end_presentation)
    AutoCommands.init(M.end_presentation)
    SlideShow.init()
end

return M
