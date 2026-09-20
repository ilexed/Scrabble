local harness = require "tests.harness"
local test, eq = harness.test, harness.eq

local Bag = require "src.core.bag"
local tileData = require "src.config.tileData"

-- Fake RNG: always picks the last position, so draws come off the end of
-- the (sorted) tile list in order. Note it must accept two arguments.
local function last(lo, hi)
    return hi
end

-- Counts how many of each tile are in a list.
local function countTiles(list)
    local counts = {}
    for _, t in ipairs(list) do
        counts[t] = (counts[t] or 0) + 1
    end
    return counts
end

-- Compares two count tables (both directions, so extras are caught).
local function sameCounts(a, b)
    for k, v in pairs(a) do
        if b[k] ~= v then return false, k end
    end
    for k, v in pairs(b) do
        if a[k] ~= v then return false, k end
    end
    return true
end

-- Expected counts straight from the distribution.
local function expectedCounts(distribution)
    local counts = {}
    for letter, data in pairs(distribution) do
        counts[letter] = data.count
    end
    return counts
end

-- A tiny bag makes exact behaviour easy to predict.
local small = { A = { count = 2 }, B = { count = 1 } }  -- tiles: A A B

---------------------------------------------------------------------
-- construction
---------------------------------------------------------------------

test("new: default bag holds 100 tiles", function()
    eq(Bag:new():tilesRemaining(), 100)
end)

test("new: tile counts match the distribution", function()
    local bag = Bag:new()
    local ok, badKey = sameCounts(countTiles(bag.tiles), expectedCounts(tileData))
    eq(ok, true, "mismatch on " .. tostring(badKey))
end)

test("new: contains exactly two blanks", function()
    eq(countTiles(Bag:new().tiles)["?"], 2)
end)

test("new: tiles start in sorted order, so bags are deterministic", function()
    local bag = Bag:new()
    eq(bag.tiles[1], "?")
    eq(bag.tiles[2], "?")
    eq(bag.tiles[3], "A")
    eq(bag.tiles[#bag.tiles], "Z")
    for i = 2, #bag.tiles do
        eq(bag.tiles[i - 1] <= bag.tiles[i], true, "position " .. i)
    end
end)

test("new: builds from a custom distribution", function()
    local bag = Bag:new(nil, small)
    eq(bag:tilesRemaining(), 3)
    eq(table.concat(bag.tiles), "AAB")
end)

test("new: two bags are independent", function()
    local a, b = Bag:new(), Bag:new()
    a:draw(10)
    eq(a:tilesRemaining(), 90)
    eq(b:tilesRemaining(), 100)
end)

test("new: drawing never modifies the distribution config", function()
    local bag = Bag:new()
    bag:draw(100)
    eq(tileData.A.count, 9)
    eq(tileData["?"].count, 2)
end)

test("new: uses the injected RNG", function()
    local called = false
    local bag = Bag:new(function(lo, hi)
        called = true
        return hi
    end)
    bag:draw(1)
    eq(called, true)
end)

---------------------------------------------------------------------
-- draw
---------------------------------------------------------------------

test("draw: zero tiles returns an empty table and changes nothing", function()
    local bag = Bag:new()
    local drawn = bag:draw(0)
    eq(#drawn, 0)
    eq(bag:tilesRemaining(), 100)
end)

test("draw: removes the drawn tiles from the bag", function()
    local bag = Bag:new()
    local drawn = bag:draw(7)
    eq(#drawn, 7)
    eq(bag:tilesRemaining(), 93)
end)

test("draw: only returns valid tiles", function()
    local bag = Bag:new()
    for _, t in ipairs(bag:draw(100)) do
        eq(tileData[t] ~= nil, true, t)
    end
end)

test("draw: fake RNG takes tiles from the end of the list", function()
    local bag = Bag:new(last)
    local drawn = bag:draw(2)
    eq(drawn[1], "Z")
    eq(drawn[2], "Y")
end)

test("draw: can take every tile in the bag", function()
    local bag = Bag:new()
    local drawn = bag:draw(100)
    eq(#drawn, 100)
    eq(bag:tilesRemaining(), 0)
end)

test("draw: too many tiles returns nil and a message", function()
    local bag = Bag:new()
    local drawn, err = bag:draw(101)
    eq(drawn, nil)
    eq(type(err), "string")
end)

test("draw: a failed draw leaves the bag untouched", function()
    local bag = Bag:new(last)
    bag:draw(101)
    eq(bag:tilesRemaining(), 100)
    local ok = sameCounts(countTiles(bag.tiles), expectedCounts(tileData))
    eq(ok, true)
end)

test("draw: drawing from an empty bag fails cleanly", function()
    local bag = Bag:new(nil, small)
    bag:draw(3)
    local drawn, err = bag:draw(1)
    eq(drawn, nil)
    eq(type(err), "string")
end)

test("draw: negative amounts are a programming error", function()
    local bag = Bag:new()
    local ok = pcall(bag.draw, bag, -1)
    eq(ok, false)
end)

test("draw: nothing is lost or duplicated (random RNG)", function()
    local bag = Bag:new()
    local all = {}
    for _, n in ipairs { 7, 7, 30, 1, 55 } do
        for _, t in ipairs(bag:draw(n)) do
            all[#all + 1] = t
        end
    end
    eq(bag:tilesRemaining(), 0)
    local ok, badKey = sameCounts(countTiles(all), expectedCounts(tileData))
    eq(ok, true, "mismatch on " .. tostring(badKey))
end)

test("draw: results vary between draws with the default RNG", function()
    -- Not a statistical test. With 100 tiles, 20 identical 7-tile draws
    -- in a row would mean the RNG isn't being used at all.
    math.randomseed(12345)
    local seen = {}
    for i = 1, 20 do
        seen[table.concat(Bag:new():draw(7))] = true
    end
    local distinct = 0
    for _ in pairs(seen) do distinct = distinct + 1 end
    eq(distinct > 1, true)
end)

---------------------------------------------------------------------
-- drawAtMost
---------------------------------------------------------------------

test("drawAtMost: behaves like draw when enough tiles remain", function()
    local bag = Bag:new()
    eq(#bag:drawAtMost(7), 7)
    eq(bag:tilesRemaining(), 93)
end)

test("drawAtMost: clamps to what is left", function()
    local bag = Bag:new(nil, small)
    local drawn = bag:drawAtMost(10)
    eq(#drawn, 3)
    eq(bag:tilesRemaining(), 0)
end)

test("drawAtMost: an empty bag returns an empty table", function()
    local bag = Bag:new(nil, small)
    bag:draw(3)
    local drawn = bag:drawAtMost(7)
    eq(#drawn, 0)
end)

test("drawAtMost: negative amounts are a programming error", function()
    local bag = Bag:new()
    eq(pcall(bag.drawAtMost, bag, -1), false)
end)

---------------------------------------------------------------------
-- putBack
---------------------------------------------------------------------

test("putBack: adds tiles to the bag", function()
    local bag = Bag:new()
    local drawn = bag:draw(7)
    bag:putBack(drawn)
    eq(bag:tilesRemaining(), 100)
end)

test("putBack: restores the original tile counts", function()
    local bag = Bag:new()
    bag:putBack(bag:draw(40))
    local ok, badKey = sameCounts(countTiles(bag.tiles), expectedCounts(tileData))
    eq(ok, true, "mismatch on " .. tostring(badKey))
end)

test("putBack: an empty list changes nothing", function()
    local bag = Bag:new()
    bag:putBack({})
    eq(bag:tilesRemaining(), 100)
end)

test("putBack: returned tiles can be drawn again", function()
    local bag = Bag:new(last, small)  -- A A B
    bag:draw(3)
    bag:putBack({ "Q" })
    eq(bag:draw(1)[1], "Q")
end)

---------------------------------------------------------------------
-- exchange
---------------------------------------------------------------------

test("exchange: returns as many tiles as were given", function()
    local bag = Bag:new()
    local newTiles = bag:exchange({ "A", "B", "C" })
    eq(#newTiles, 3)
end)

test("exchange: the bag size stays the same", function()
    local bag = Bag:new()
    bag:exchange({ "A", "B", "C" })
    eq(bag:tilesRemaining(), 100)
end)

test("exchange: the old tiles end up in the bag", function()
    local bag = Bag:new(nil, { A = { count = 1 } })
    local newTiles = bag:exchange({ "Q" })
    eq(newTiles[1], "A")
    eq(bag.tiles[1], "Q")
end)

test("exchange: you can never draw your own discards", function()
    -- Bag holds one A. With the last-position RNG, if the discard were put
    -- back BEFORE drawing, the Q would be drawn. Drawing first returns the A.
    local bag = Bag:new(last, { A = { count = 1 } })
    local newTiles = bag:exchange({ "Q" })
    eq(newTiles[1], "A")
end)

test("exchange: too few tiles in the bag fails", function()
    local bag = Bag:new(nil, { A = { count = 1 } })
    local newTiles, err = bag:exchange({ "X", "Y" })
    eq(newTiles, nil)
    eq(type(err), "string")
end)

test("exchange: a failed exchange changes nothing", function()
    local bag = Bag:new(nil, { A = { count = 1 } })
    bag:exchange({ "X", "Y" })
    eq(bag:tilesRemaining(), 1)
    eq(bag.tiles[1], "A")
end)

test("exchange: exchanging nothing is a no-op", function()
    local bag = Bag:new()
    local newTiles = bag:exchange({})
    eq(#newTiles, 0)
    eq(bag:tilesRemaining(), 100)
end)

---------------------------------------------------------------------
-- tilesRemaining
---------------------------------------------------------------------

test("tilesRemaining: tracks draws and put-backs", function()
    local bag = Bag:new()
    eq(bag:tilesRemaining(), 100)
    local drawn = bag:draw(7)
    eq(bag:tilesRemaining(), 93)
    bag:putBack({ drawn[1], drawn[2] })
    eq(bag:tilesRemaining(), 95)
end)