local M = {}

local title_pattern = "^##?#?%s"

local function parse_title(line)
    return {
        text = line:match("^#+%s+([^%s].*)$"):gsub("%s+$", ""),
        level = #line:match(title_pattern),
    }
end

M.parse_slides = function(lines)
    local slides = {}
    local current_slide = {
        title = {},
        body = {},
        --section = "",
        --blocks = {},
    }

    for _, line in ipairs(lines) do
        if line:match(title_pattern) then
            if current_slide.title.text then
                table.insert(slides, current_slide)
            end

            current_slide = {
                title = parse_title(line),
                body = {}
                --section = "",
                --blocks = "",
            }
        else
            if current_slide.title.text then
                table.insert(current_slide.body, line)
            end
        end
    end

    table.insert(slides, current_slide)

    for _, slide in ipairs(slides) do
    end

    return slides
end

return M
