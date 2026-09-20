local harness = require "tests.harness"

local tests_to_run = {"test_bag", "test_tile"}

for _, name in ipairs(tests_to_run) do
    require("tests." .. name)
end

harness.run()