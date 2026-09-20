local harness = require "tests.harness"
local test, eq = harness.test, harness.eq

local Rack = require "src.core.rack"

-- Builds a rack holding the given tiles (a string like "RETAINS").
local function rackOf(str)
    local letters = {}
    for i = 1, #str do
        letters[i] = str:sub(i, i)
    end
    local rack = Rack:new()
    rack:set(letters)
    return rack
end

-- The rack's tiles as one string, in rack order. Reads the internal list,
-- which is fine in a test, but non-test code should use methods.
local function contents(rack)
    return table.concat(rack.tiles)
end

---------------------------------------------------------------------
-- new
---------------------------------------------------------------------

test("new: rack starts empty", function()
    local rack = Rack:new()
    eq(rack:isEmpty(), true)
    eq(rack:numTiles(), 0)
end)

test("new: two racks are independent", function()
    local a, b = Rack:new(), Rack:new()
    a:add("A")
    eq(a:numTiles(), 1)
    eq(b:numTiles(), 0)
end)

---------------------------------------------------------------------
-- set
---------------------------------------------------------------------

test("set: fills the rack in the given order", function()
    local rack = rackOf("RETAINS")
    eq(rack:numTiles(), 7)
    eq(contents(rack), "RETAINS")
end)

test("set: replaces whatever was there before", function()
    local rack = rackOf("ABC")
    rack:set({ "X", "Y" })
    eq(contents(rack), "XY")
    eq(rack:numTiles(), 2)
end)

test("set: an empty list empties the rack", function()
    local rack = rackOf("ABC")
    rack:set({})
    eq(rack:isEmpty(), true)
end)

test("set: does not share the caller's table", function()
    local letters = { "A", "B" }
    local rack = Rack:new()
    rack:set(letters)
    letters[1] = "Z"
    letters[#letters + 1] = "Q"
    eq(contents(rack), "AB")
end)

---------------------------------------------------------------------
-- add
---------------------------------------------------------------------

test("add: appends a tile", function()
    local rack = rackOf("AB")
    rack:add("C")
    eq(contents(rack), "ABC")
    eq(rack:numTiles(), 3)
end)

test("add: the first tile makes the rack non-empty", function()
    local rack = Rack:new()
    rack:add("E")
    eq(rack:isEmpty(), false)
end)

test("add: duplicates are allowed", function()
    local rack = rackOf("E")
    rack:add("E")
    eq(rack:numTiles(), 2)
end)

---------------------------------------------------------------------
-- take
---------------------------------------------------------------------

test("take: removes the tile and returns true", function()
    local rack = rackOf("ABC")
    eq(rack:take("B"), true)
    eq(contents(rack), "AC")
end)

test("take: removes the requested tile, not just the last one", function()
    local rack = rackOf("ABC")
    rack:take("A")
    eq(contents(rack), "BC")
end)

test("take: removes only one copy of a duplicate", function()
    local rack = rackOf("EAE")
    eq(rack:take("E"), true)
    eq(rack:numTiles(), 2)
    eq(rack:has("E"), true)
end)

test("take: a tile that isn't there returns false", function()
    local rack = rackOf("ABC")
    eq(rack:take("Z"), false)
end)

test("take: a failed take changes nothing", function()
    local rack = rackOf("ABC")
    rack:take("Z")
    eq(contents(rack), "ABC")
end)

test("take: from an empty rack returns false", function()
    eq(Rack:new():take("A"), false)
end)

test("take: taking every tile leaves the rack empty", function()
    local rack = rackOf("AB")
    rack:take("A")
    rack:take("B")
    eq(rack:isEmpty(), true)
    eq(rack:numTiles(), 0)
end)

test("take: a blank is taken as '?'", function()
    local rack = rackOf("A?")
    eq(rack:take("?"), true)
    eq(contents(rack), "A")
end)

test("take: a designated (lowercase) blank is not on the rack", function()
    -- Racks hold '?', never 'e'. The validator must convert first
    -- (tile.rackForm). Taking 'e' directly should fail.
    local rack = rackOf("E?")
    eq(rack:take("e"), false)
    eq(rack:numTiles(), 2)
end)

---------------------------------------------------------------------
-- has
---------------------------------------------------------------------

test("has: true for a tile on the rack", function()
    eq(rackOf("ABC"):has("B"), true)
end)

test("has: false for a tile not on the rack", function()
    eq(rackOf("ABC"):has("Z"), false)
end)

test("has: false on an empty rack", function()
    eq(Rack:new():has("A"), false)
end)

test("has: becomes false after the last copy is taken", function()
    local rack = rackOf("EE")
    rack:take("E")
    eq(rack:has("E"), true)
    rack:take("E")
    eq(rack:has("E"), false)
end)

test("has: does not change the rack", function()
    local rack = rackOf("ABC")
    rack:has("B")
    eq(contents(rack), "ABC")
end)

---------------------------------------------------------------------
-- numTiles / isEmpty
---------------------------------------------------------------------

test("numTiles: tracks adds and takes", function()
    local rack = Rack:new()
    rack:add("A")
    rack:add("B")
    rack:add("C")
    eq(rack:numTiles(), 3)
    rack:take("B")
    eq(rack:numTiles(), 2)
end)

test("isEmpty: false when the rack has tiles", function()
    eq(rackOf("A"):isEmpty(), false)
end)

test("isEmpty: agrees with numTiles after set", function()
    local rack = rackOf("ABC")
    eq(rack:isEmpty(), rack:numTiles() == 0)
    rack:set({})
    eq(rack:isEmpty(), rack:numTiles() == 0)
end)

---------------------------------------------------------------------
-- scoreOn
---------------------------------------------------------------------

test("scoreOn: an empty rack scores 0", function()
    eq(Rack:new():scoreOn(), 0)
end)

test("scoreOn: sums tile points", function()
    eq(rackOf("QUIZ"):scoreOn(), 22)     -- 10 + 1 + 1 + 10
    eq(rackOf("RETAINS"):scoreOn(), 7)   -- seven 1-point tiles
    eq(rackOf("JAXK"):scoreOn(), 22)     -- 8 + 1 + 8 + 5
end)

test("scoreOn: blanks score 0", function()
    eq(rackOf("Q?"):scoreOn(), 10)
    eq(rackOf("??"):scoreOn(), 0)
end)

test("scoreOn: counts duplicates", function()
    eq(rackOf("ZZ"):scoreOn(), 20)
end)

test("scoreOn: does not change the rack", function()
    local rack = rackOf("QUIZ")
    rack:scoreOn()
    eq(contents(rack), "QUIZ")
end)