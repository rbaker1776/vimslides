local Utils = require("vimslides.data.utils")
local Window = require("vimslides.ui.window")

local M = {}

local title_pattern = "^##?#?#?#?#?%s"

local function parse_title(line)
    return {
        text = line:match("^#+%s+([^%s].*)$"):gsub("%s+$", ""),
        degree = #line:match(title_pattern) - 1,
    }
end

local function new_title()
    return {
        text = nil,
        degree = nil,
    }
end

local function new_slide()
    return {
        title = new_title(),
        body = {},
        blocks = {},
    }
end

local function new_code_block()
    return {
        body = {},
        language = nil,
    }
end

M.parse_slides = function(lines)
    local slides = {}
    local current_slide = new_slide()

    for i, line in ipairs(lines) do
        if line:match(title_pattern) then
            if current_slide.title.text then
                table.insert(slides, current_slide)
            end

            current_slide = new_slide()
            current_slide.title = parse_title(line)
        elseif current_slide.title.text then
            table.insert(current_slide.body, line)
        end

        if line:match("^%s?%s?%s?```") then
            table.insert(current_slide.blocks, i)
        end
    end

    table.insert(slides, current_slide)

    for _, slide in pairs(slides) do
        Utils.strip_ws(slide.body)
        slide.blocks = Utils.pair_up(slide.blocks)
    end

    return slides
end

M.get_current_code_block = function()
    local block = new_code_block()
    local slide_body = vim.api.nvim_buf_get_lines(Window.floats.body.buf, 0, -1, false)
    local cursor_line = vim.api.nvim_win_get_cursor(Window.floats.body.win)[1]

    local inside_block = false

    for i, line in pairs(slide_body) do
        if i == cursor_line and not inside_block then
            break
        end

        if line:match("^```") then
            if inside_block then
                if i > cursor_line then
                    return block
                end
                block.body = {}
            else
                block.language = line:match("^```%s*(%w*)%s*")
            end

            inside_block = not inside_block
        else
            if inside_block then
                table.insert(block.body, line)
            end
        end
    end

    return false
end

return M
