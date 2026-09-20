local tileData = require "src.config.tileData"

local Bag = {}
Bag.__index = Bag

function Bag:new(rng, distribution)
    local o = {
        tiles = {},
        rng = rng or math.random,
    }

    local distribution = distribution or tileData

    -- Fill the bags tiles table with letters from the distribution.
    for letter, data in pairs(distribution) do 
        local count = data.count

        for i = 1, count do
            o.tiles[#o.tiles + 1] = letter
        end
    end

    table.sort(o.tiles)

    return setmetatable(o, self)

end

function Bag:draw(n)
    assert(n >= 0, "Tried to draw " .. tostring(n) .. " tiles, a negative number.")

    if (n > #self.tiles) then
        return nil, "Tried to draw " .. tostring(n) .. " tiles, bag contains " .. tostring(#self.tiles) .. "."
    end

    local drawn = {}

    for i = 1, n do
        local idx = self.rng(1, #self.tiles)

        drawn[i] = self.tiles[idx]
        self.tiles[idx] = self.tiles[#self.tiles]
        table.remove(self.tiles)
    end
    
    return drawn
end

function Bag:drawAtMost(n)
    assert(n >= 0, "Tried to draw " .. tostring(n) .. " tiles, a negative number.")

    if (n > #self.tiles) then
        n = #self.tiles
    end

    local drawn = self:draw(n)
    return drawn

end

function Bag:putBack(letters)
    for _, letter in ipairs(letters) do
        self.tiles[#self.tiles + 1] = letter
    end
end

function Bag:exchange(letters)
    local newTiles, err = self:draw(#letters)

    if not newTiles then
        return nil, err
    end

    self:putBack(letters)

    return newTiles
end

function Bag:tilesRemaining()
    return #self.tiles
end


return Bag