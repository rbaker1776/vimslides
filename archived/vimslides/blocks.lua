local M = {}

M.execute_cpp_code = function(block)
    local tempfile = vim.fn.tempname() .. ".cpp"
    local outfile = tempfile:sub(1, -4)
    vim.fn.writefile(block, tempfile)
    local result = vim.system({ "clang++", "-std=c++23", tempfile, "-o", outfile }, { text = true }):wait()

    if result.code ~= 0 then
        local output = vim.split(result.stderr, '\n')
        return output
    end

    result = vim.system({ outfile }, { text = true }):wait()
    return vim.split(result.stdout, '\n')
end

M.create_system_executor = function(program)
    return function(block)
        local tempfile = vim.fn.tempname()
        vim.fn.writefile(block, tempfile)
        local result = vim.system({ program, tempfile }, { text = true }):wait()
        return vim.split(result.stdout, '\n')
    end
end

return M
