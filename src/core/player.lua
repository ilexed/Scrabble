local Rack = require "src.core.rack"

local Player = {}
Player.__index = Player

function Player:new()
    local o = {}

    o.rack = Rack:new()
    o.points = 0

    return setmetatable(o, self)
end

function Player:draw(n, bag)
    local drawn = bag:draw(n)

    for _, letter in ipairs(drawn) do
        self.rack:add(letter)
    end
end

return Player