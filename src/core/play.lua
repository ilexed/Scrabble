local Game = require "src.core.game"

local function printBoard(board)
    for row = 1, board:getDimensions() do
        local line = {}
        for col = 1, board:getDimensions() do
            local t = board:get(row, col)
            line[col] = t or "."
        end
        print(table.concat(line, " "))
    end
end

local function printRack(rack) 
    print(table.concat(rack.tiles, ", "))
end

local function strToPlacements(row, col, vertical, word)
    local row, col = row, col
    
    local placements = {}

    for l = 1, #word do
        table.insert(placements, {row = row, col = col, letter = word:sub(l, l)})
        if vertical then
            row = row + 1
        else
            col = col + 1
        end
    end

    return placements
end

local function sleep (t) 
    local sec = tonumber(os.clock() + t); 
    while (os.clock() < sec) do 
    end 
end

local function clearScreen()
    io.write("\27[2J\27[H")
end

local function draw() end

local game = Game:new()
local row, col, word, vertical = 4, 8, true, "JASPER"
local placements = strToPlacements(row, col, word, vertical)
local err = game.board:errorIfIllegalPlay(row, col, word, vertical)

if err then 
    print(err)
else
    for _, p in ipairs(placements) do
        game.board:place(p.row, p.col, p.letter)
    end
end

printBoard(game.board)