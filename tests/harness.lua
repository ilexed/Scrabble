local harness = {tests = {}}

function harness.test(name, fn)
    harness.tests[#harness.tests + 1] = {name = name, fn = fn}
end

function harness.eq(actual, expected, label)
    if actual ~= expected then
        error(string.format("%sexpected %s, got %s", label and (label .. ": ") or "", tostring(expected), tostring(actual)), 2)
    end
end

function harness.run()
    local failed = 0
    for _, t in ipairs(harness.tests) do
        local ok, err = pcall(t.fn)

        if ok then
            print("PASS " .. t.name)
        else
            failed = failed + 1
            print("FAIL " .. t.name .. "\n" .. tostring(err))
        end
    end

    print(string.format("\n%d run, %d failed", #harness.tests, failed))
    return failed == 0
end

return harness