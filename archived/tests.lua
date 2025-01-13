local parser = require("./lua/vimslides.parser")


local function assert_equal(a, b)
    if a == nil or b == nil then
        if a ~= nil or b ~= nil then
            error("One argument is nil.")
        end
    end

    local function assert_table_equal(t1, t2)
        if t1 == t2 then return true end
        if type(t1) ~= "table" or type(t2) ~= "table" then
            error("Attempted to pass non-table to assert_table_equal().")
        end

        local n_t1 = 0
        for key, value in pairs(t1) do
            n_t1 = n_t1 + 1
            assert_equal(t2[key], value)
        end

        local n_t2 = 0
        for key, value in pairs(t2) do
            n_t2 = n_t2 + 1
            assert_equal(t1[key], value)
        end
        
        if n_t1 ~= n_t2 then
            error("Tables are not equal.")
        end
    end

    if type(a) ~= type(b) then return false end
    if type(a) == "table" then
        assert_table_equal(a, b)
        return
    end

    if a ~= b then
        error("Test failed: expexted " .. a .. ", got " .. b)
    end
end


-- test title parsing
assert_equal(parser.parse_title("##### Title"), { text = "Title", level = 5 })
assert_equal(parser.parse_title("# Title"), { text = "Title", level = 1 })
assert_equal(parser.parse_title("###### Title"), { text = "Title", level = 6 })
assert_equal(parser.parse_title("###### This is a title"), { text = "This is a title", level = 6 })
assert_equal(parser.parse_title("# title "), { text = "title", level = 1 })
assert_equal(
    parser.parse_title("###### This: # -, this... is a v e r y s t r A N G 3 T:I:T:7:3     .    "),
    { text = "This: # -, this... is a v e r y s t r A N G 3 T:I:T:7:3     .", level = 6 }
)
assert_equal(parser.parse_title("####### Seven octothorpes"), nil)
