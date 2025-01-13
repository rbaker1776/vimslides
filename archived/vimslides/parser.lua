local M = {}

local title_pattern = "^##?#?%s"

M.parse_title = function(line)
    return {
        text = line:match("^#+%s+([^%s].*)$"):gsub("%s+$", ""),
        level = #line:match(title_pattern),
    }
end

local function strip_ws(body)
    while #body > 0 and body[1] == "" do
        table.remove(body, 1)
    end

    while #body > 0 and body[#body] == "" do
        table.remove(body)
    end
end

local function parse_code_blocks(slide)
    local block = {
        language = nil,
        body = {},
        bounds = {},
    }
    local inside_block = false

    for i, line in ipairs(slide.body) do
        if line:match("^%s*```") then
            if not inside_block then
                inside_block = true
                block.language = line:match("^%s*```%s*(%w*)%s*$")
                block.bounds.begin_idx = i
            else
                inside_block = false
                strip_ws(block.body)
                block.bounds.end_idx = i
                table.insert(slide.blocks, block)
            end
        else
            if inside_block then
                table.insert(block.body, line) 
            end
        end
    end

    for i = #slide.blocks, 1, -1 do
        local block = slide.blocks[i]
        for j = block.bounds.end_idx, block.bounds.begin_idx, -1 do
            slide.body[j] = ""
        end
    end
end

M.parse_slides = function(lines)
    local slides = {}
    local current_slide = {
        title = {},
        body = {},
        --section = "",
        blocks = {},
    }

    for _, line in ipairs(lines) do
        if line:match(title_pattern) then
            if current_slide.title.text then
                table.insert(slides, current_slide)
            end

            current_slide = {
                title = M.parse_title(line),
                body = {},
                --section = "",
                blocks = {}
            }
        else 
            if current_slide.title.text then
                table.insert(current_slide.body, line)
            end
        end
    end

    table.insert(slides, current_slide)

    for _, slide in ipairs(slides) do
        strip_ws(slide.body)
        parse_code_blocks(slide)
    end

    return slides
end

return M
