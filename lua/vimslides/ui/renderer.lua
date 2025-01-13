local Window = require("vimslides.ui.window")
local Highlight = require("vimslides.ui.highlight")

local M = {}

M.render_header = function(title)
    local float = Window.floats.header
    local buf = float.buf
    local ns_id = float.ns

    local col = math.floor((float.config.width - vim.fn.strdisplaywidth(title.text) + 1) / 2)

    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, { (' '):rep(float.config.width) })
    vim.api.nvim_buf_set_extmark(buf, ns_id, 0, col, {
        virt_text = {{ title.text, Highlight.titles[title.degree] }},
        virt_text_pos = "overlay"
    })
end

M.render_body = function(body)
    local float = Window.floats.body
    local buf = float.buf
    local ns_id = float.ns

    vim.bo[buf].filetype = "markdown"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, body)
    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)

     for i, line in pairs(body) do
        if line:match("^```") then
            vim.api.nvim_buf_set_extmark(buf, ns_id, i - 1, 0, {
                virt_text = {{ ('─'):rep(float.config.width) }},
                virt_text_pos = "overlay"
            })
        end
    end
end

M.render_code_outlines = function(body)
    local float = Window.floats.background
    local buf = float.buf
    local ns_id = float.ns

    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
    vim.api.nvim_buf_set_lines(Window.floats.background.buf, 0, -1, false, vim.split(("%s\n"):format((" "):rep(Window.floats.background.config.width)):rep(Window.floats.background.config.height), '\n'))

    local inside_block = false

    for i, line in pairs(body) do
        if line:match("^```") then
            if not inside_block then
                vim.api.nvim_buf_set_lines(Window.floats.background.buf, i + 3, i + 4, false, { "    ╭─" .. (" "):rep(Window.floats.body.config.width) .. "─╮" })
            else
                vim.api.nvim_buf_set_lines(Window.floats.background.buf, i + 3, i + 4, false, { "    ╰─" .. (" "):rep(Window.floats.body.config.width) .. "─╯" })
            end

            inside_block = not inside_block
        elseif inside_block then
            vim.api.nvim_buf_set_lines(Window.floats.background.buf, i + 3, i + 4, false, { "    │ " .. (" "):rep(Window.floats.body.config.width) .. " │" })
        end
    end
end

M.render_footer = function(content)
    local l_cursor, r_cursor = 0, vim.o.columns

    for _, chunk in pairs(content[1]) do
        l_cursor = l_cursor + vim.fn.strdisplaywidth(chunk[1])
    end
    for _, chunk in pairs(content[2]) do
        r_cursor = r_cursor - vim.fn.strdisplaywidth(chunk[1])
    end
    table.insert(content[1], { (' '):rep(r_cursor - l_cursor), Highlight.footer_background })

    local float = Window.floats.footer
    local buf = float.buf
    local ns_id = float.ns

    vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
    vim.api.nvim_buf_set_lines(buf, 0, 1, false, { (' '):rep(float.config.width) })
    vim.api.nvim_buf_set_extmark(buf, ns_id, 0, 0,        { virt_text = content[1], virt_text_pos = "overlay" })
    vim.api.nvim_buf_set_extmark(buf, ns_id, 0, r_cursor, { virt_text = content[2], virt_text_pos = "overlay" })
end

return M
