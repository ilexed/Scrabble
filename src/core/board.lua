local bonusSquares, legend = unpack(require "src.config.boardLayout" )
local tile = require "src.core.tile"

local Board = {}
Board.__index = Board

function Board:new()
    local o = {
        dimensions = 15,
        tileCount = 0,
        squares = {}
    }

    for row = 1, o.dimensions do
        table.insert(o.squares, {})
        for col = 1, o.dimensions do 
            table.insert(o.squares[row], false)
        end
    end
    
    return setmetatable(o, self)
end

function Board:getDimensions()
    return self.dimensions
end

function Board:getTileCount()
    return self.tileCount
end

function Board:isEmpty()
    return self.tileCount == 0
end

function Board:getCenter()
    local dim = self:getDimensions()
    return math.ceil(dim / 2)
end

function Board:get(row, col)
    return self.squares[row][col]
end

function Board:place(row, col, letter)
    if not self:inBounds(row, col) then
        return nil, "Attempted to place tile out of bounds at [" .. tostring(row) .. "][" .. tostring(col) .. "]"
    end

    if self:get(row, col) ~= false then
        return nil, "Square at [" .. tostring(row) .. "][" .. tostring(col) .. "] is occupied."
    end

    if not tile.isValid(letter) or letter == "?" then
        return nil, "Cannot place " .. tostring(letter) .. " on the board." 
    end

    self.squares[row][col] = letter
    self.tileCount = self.tileCount + 1
    return true
end


function Board:hasLetter(row, col)
    return self:get(row, col) and true or false
end

function Board:hasNeighbour(row, col)
    for r = row-1, row+1, 2 do
        if self:inBounds(r, col) and self:get(r, col) then
            return true
        end
    end

    for c = col-1, col+1, 2 do
        if self:inBounds(row, c) and self:get(row, c) then
            return true
        end
    end

    return false
end

function Board:inBounds(row, col)
    local dim = self:getDimensions()

    if row < 1 or row > dim then
        return false
    elseif col < 1 or col > dim then
        return false
    else
        return true
    end
end

function Board:getBonus(row, col)
    if not self:inBounds(row, col) then
        return nil, "Attempted to index tile out of bounds at [" .. tostring(row) .. "][" .. tostring(col) .. "]"
    end
    return legend[bonusSquares[row]:sub(col, col)]
end

function Board:getBonusLetter(row, col)
    if not self:inBounds(row, col) then
        return nil, "Attempted to index tile out of bounds at [" .. tostring(row) .. "][" .. tostring(col) .. "]"
    end
    return bonusSquares[row]:sub(col, col)
end

function Board:errorIfIllegalPlay(row, col, vertical, word)
    local center = self:getCenter()
    local boardEmpty = self:isEmpty()

    ri, ci = 0, 1
    if vertical then
        ri, ci = ci, ri
    end

    
    local bordersATile = false
    local touchesCenter = false

    for idx = 0, #word - 1 do
        local newRow, newCol = row + (ri * idx), col + (ci * idx)

        if boardEmpty and newRow == center and newCol == center then
            touchesCenter = true
        end

        if not self:inBounds(newRow, newCol) then
            return "play extends off the board"
        end

        if self:hasNeighbour(newRow, newCol) then
            bordersATile = true
        end
    end

    if boardEmpty and not touchesCenter then
        return "starting play must touch the center"
    end

    if not boardEmpty and not bordersATile then
        return "play must border a tile already on the board"
    end

end

return Board



