local Board = require "src.core.board"
local Player = require "src.core.player"
local Bag = require "src.core.bag"

local Game = {}
Game.__index = Game

function Game:new()
    local o = {}
    o.board = Board:new()
    o.players = {Player:new()}
    o.bag = Bag:new()
    o.onTurn = 1
    
    return setmetatable(o, self)
end

function Game:start()
    -- Deal out tiles to players.
    for _, player in ipairs(self.players) do
        player:draw(7, self.bag)
    end

end

function Game:currentPlayer()
    return self.players[self.onTurn]
end

function Game:advanceTurn()
    self.onTurn = (self.onTurn % #self.players) + 1
end

return Game
