local Window = require("vimslides.ui.window")

local M = {}

local function execute_cpp(lines)
    local tempfile = vim.fn.tempname() .. ".cpp"
    local outfile = tempfile:sub(1, -4)
    vim.fn.writefile(lines, tempfile)
    local result = vim.system({ "clang++", "-std=c++23", tempfile, "-o", outfile }, { text = true }):wait()

    if result.code ~= 0 then
        local output = vim.split(result.stderr, '\n')
        return output
    end
    
    result = vim.system({ outfile }, { text = true }):wait()
    return vim.split(result.stdout, '\n')
end

M.execute = function(block)
    if not block then
        vim.api.nvim_echo({{ "Vimslides: attempted to execute code outside of a code block", "ErrorMsg" }}, {}, {})
        return
    end

    Window.show_code()
    vim.bo[Window.code_floats.code.buf].filetype = block.language
    vim.api.nvim_buf_set_lines(Window.code_floats.code.buf, 0, -1, false, block.body)

    if block.language == "cpp" then
        vim.api.nvim_buf_set_lines(Window.code_floats.output.buf, 0, -1, false, execute_cpp(block.body))
    end
end

return M
