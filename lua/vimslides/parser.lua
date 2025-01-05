local M = {}


local function remove_leading_empty_strings(body)
    local i = 1
    while i <= #body and body[i] == "" do
        table.remove(body, i)
    end
end

local function remove_trailing_empty_strings(body)
    while #body > 0 and body[#body] == "" do
        table.remove(body, #body)
    end
end

local function parse_slide_content(slides)
    for _, slide in ipairs(slides) do
        remove_leading_empty_strings(slide.body)
        remove_trailing_empty_strings(slide.body)
    end
end

local function parse_code_blocks(slides)
    local code_delimiter = "^```"

    for _, slide in ipairs(slides) do
        local block = {
            language = nil,
            body = "",
        }
        local inside_block = false

        for _, line in ipairs(slide.body) do
            if line:find(code_delimiter) then
                if not inside_block then
                    inside_block = true
                    block.language = string.gsub(line, "```[ \t]*", "", 1)
                else
                    inside_block = false
                    block.body = vim.trim(block.body)
                    table.insert(slide.blocks, block)
                end
            else
                if inside_block then
                    block.body = block.body .. line .. '\n'
                end
            end
        end
    end
end

M.parse_slides = function(lines)
    local slides = {}
    local current_slide = {
        title = "",
        body = {},
        blocks = {},
    }

    local slide_delimiter = "^#"

    for _, line in ipairs(lines) do
        if line:find(slide_delimiter) then
            if #current_slide.title > 0 then
                table.insert(slides, current_slide)
            end

            current_slide = {
                title = line,
                body = {},
                blocks = {},
            }
        else
            table.insert(current_slide.body, line)
        end
    end

    if #current_slide.title > 0 then
        table.insert(slides, current_slide)
    end

    parse_code_blocks(slides)
    parse_slide_content(slides)
    
    return slides
end


return M
