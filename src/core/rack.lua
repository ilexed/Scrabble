local tile = require "src.core.tile"

local Rack = {}
Rack.__index = Rack

function Rack:new()
    local o = {}
    o.tiles = {}

    return setmetatable(o, self)
end

function Rack:set(letters)
    self.tiles = {}
    for _, letter in ipairs(letters) do
        self.tiles[#self.tiles + 1] = letter
    end
end

function Rack:add(letter)
    self.tiles[#self.tiles + 1] = letter
end

function Rack:take(letter)
    for idx, t in ipairs(self.tiles) do
        if t == letter then
            table.remove(self.tiles, idx)
            return true
        end
    end

    return false
end

function Rack:scoreOn()
    -- Returns the score of all letters on a rack.
    local score = 0
    for _, letter in ipairs(self.tiles) do
        score = score + tile.score(letter)
    end
    return score
end

function Rack:numTiles()
    return #self.tiles
end

function Rack:isEmpty()
    return #self.tiles == 0
end

function Rack:has(letter)
    for _, t in ipairs(self.tiles) do
        if t == letter then
            return true
        end
    end

    return false
end

return Rack