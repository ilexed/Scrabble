local harness = require "tests.harness"
local test, eq = harness.test, harness.eq

local tile = require "src.core.tile"
local tileData = require "src.config.tileData"

local UPPER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

-- Calls fn(char) for every uppercase letter A-Z.
local function eachLetter(fn)
    for i = 1, #UPPER do
        fn(UPPER:sub(i, i))
    end
end

---------------------------------------------------------------------
-- tileData (config sanity)
---------------------------------------------------------------------

test("tileData: 100 tiles in total", function()
    local total = 0
    for _, data in pairs(tileData) do
        total = total + data.count
    end
    eq(total, 100)
end)

test("tileData: standard tile point total is 187", function()
    local total = 0
    for _, data in pairs(tileData) do
        total = total + data.count * data.points
    end
    eq(total, 187)
end)

test("tileData: has an entry for every letter and the blank", function()
    eachLetter(function(c)
        eq(tileData[c] ~= nil, true, c)
    end)
    eq(tileData["?"] ~= nil, true, "?")
end)

test("tileData: exactly two blanks, worth 0", function()
    eq(tileData["?"].count, 2)
    eq(tileData["?"].points, 0)
end)

test("tileData: vowels are exactly A E I O U", function()
    local vowels = {}
    for letter, data in pairs(tileData) do
        if data.vowel == true then
            vowels[#vowels + 1] = letter
        end
    end
    table.sort(vowels)
    eq(table.concat(vowels), "AEIOU")
end)

test("tileData: the blank is neither a vowel nor a consonant", function()
    -- vowel must be absent (nil), not false, so the blank never lands in
    -- the "consonant" bucket when counting.
    eq(tileData["?"].vowel, nil)
end)

test("tileData: every letter has a boolean vowel flag", function()
    eachLetter(function(c)
        eq(type(tileData[c].vowel), "boolean", c)
    end)
end)

---------------------------------------------------------------------
-- blank / unblank
---------------------------------------------------------------------

test("blank: uppercase letter becomes lowercase", function()
    eq(tile.blank("E"), "e")
end)

test("unblank: lowercase letter becomes uppercase", function()
    eq(tile.unblank("e"), "E")
end)

test("blank then unblank round-trips for every letter", function()
    eachLetter(function(c)
        eq(tile.unblank(tile.blank(c)), c, c)
    end)
end)

test("blank does not change the original string", function()
    local letter = "E"
    tile.blank(letter)
    eq(letter, "E")
end)

---------------------------------------------------------------------
-- isBlank
---------------------------------------------------------------------

test("isBlank: lowercase letters are blanks", function()
    eachLetter(function(c)
        eq(tile.isBlank(c:lower()), true, c:lower())
    end)
end)

test("isBlank: uppercase letters are not blanks", function()
    eachLetter(function(c)
        eq(tile.isBlank(c), false, c)
    end)
end)

test("isBlank: '?' is a blank", function()
    eq(tile.isBlank("?"), true)
end)

test("isBlank: non-letters are not blanks", function()
    eq(tile.isBlank("1"), false, "digit")
    eq(tile.isBlank(" "), false, "space")
    eq(tile.isBlank(""), false, "empty string")
    eq(tile.isBlank("."), false, "dot")
end)

test("isBlank: multi-character strings are not blanks", function()
    eq(tile.isBlank("ab"), false)
    eq(tile.isBlank("??"), false)
end)

test("isBlank: nil and non-strings are not blanks", function()
    eq(tile.isBlank(nil), false)
    eq(tile.isBlank(5), false)
end)

---------------------------------------------------------------------
-- isValid
---------------------------------------------------------------------

test("isValid: accepts every uppercase letter", function()
    eachLetter(function(c)
        eq(tile.isValid(c), true, c)
    end)
end)

test("isValid: accepts designated blanks (lowercase)", function()
    eachLetter(function(c)
        eq(tile.isValid(c:lower()), true, c:lower())
    end)
end)

test("isValid: accepts '?'", function()
    eq(tile.isValid("?"), true)
end)

test("isValid: rejects characters that aren't tiles", function()
    eq(tile.isValid("1"), false, "digit")
    eq(tile.isValid(""), false, "empty string")
    eq(tile.isValid(" "), false, "space")
    eq(tile.isValid("."), false, "dot")
    eq(tile.isValid("!"), false, "punctuation")
end)

test("isValid: rejects multi-character strings", function()
    eq(tile.isValid("ab"), false)
    eq(tile.isValid("AB"), false)
end)

test("isValid: rejects nil and non-strings without crashing", function()
    eq(tile.isValid(nil), false)
    eq(tile.isValid(5), false)
    eq(tile.isValid({}), false)
end)

---------------------------------------------------------------------
-- rackForm
---------------------------------------------------------------------

test("rackForm: uppercase letters are unchanged", function()
    eachLetter(function(c)
        eq(tile.rackForm(c), c, c)
    end)
end)

test("rackForm: designated blanks become '?'", function()
    eachLetter(function(c)
        eq(tile.rackForm(c:lower()), "?", c:lower())
    end)
end)

test("rackForm: '?' stays '?'", function()
    eq(tile.rackForm("?"), "?")
end)

test("rackForm: a non-tile is NOT silently turned into a blank", function()
    -- Pins the fail-safe behaviour: the character comes back unchanged, so
    -- a rack lookup for it fails. If you switch rackForm to assert(isValid),
    -- change this test to expect an error using pcall instead.
    eq(tile.rackForm("1"), "1")
end)

---------------------------------------------------------------------
-- score
---------------------------------------------------------------------

test("score: spot checks", function()
    eq(tile.score("A"), 1)
    eq(tile.score("D"), 2)
    eq(tile.score("B"), 3)
    eq(tile.score("F"), 4)
    eq(tile.score("K"), 5)
    eq(tile.score("J"), 8)
    eq(tile.score("X"), 8)
    eq(tile.score("Q"), 10)
    eq(tile.score("Z"), 10)
end)

test("score: matches tileData for every letter", function()
    eachLetter(function(c)
        eq(tile.score(c), tileData[c].points, c)
    end)
end)

test("score: designated blanks score 0", function()
    eachLetter(function(c)
        eq(tile.score(c:lower()), 0, c:lower())
    end)
end)

test("score: an unplaced blank scores 0", function()
    eq(tile.score("?"), 0)
end)