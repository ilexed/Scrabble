function love.load()
    love.window.setMode(1280, 720)
    Game = require "src.core.game"
    game = Game:new()
    love.graphics.setBackgroundColor(40/255, 40/255, 40/255)
    love.graphics.setNewFont(35)
    
    colors = {
        ["background"] = {40, 40, 40},
        ["tile_outline"] = {42, 42, 42},
        ["base"] = {49, 49, 49},
        ["dl"] = {109, 173, 201},
        ["tl"] = {17, 93, 146},
        ["dw"] = {169, 84, 90},
        ["tw"] = {107, 33, 37},
        ["white"] = {255, 255, 255},
        ["letter"] = {186, 173, 187}
    }
    tileSize = 40
    paddingH = 320
    paddingV = 60
    game.board:place(1, 1, "C")
    game.board:place(1, 2, "A")
    game.board:place(1, 3, "T")
end

function love.update(dt)
end

function love.draw()
    drawBoard(game.board)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function setColor(name)
    local c = colors[name]
    love.graphics.setColor(c[1] / 255, c[2] / 255, c[3] / 255, (c[4] or 255) / 255)
end

function drawSquare(type, x, y)
    setColor(type)
    love.graphics.rectangle("fill", x, y, tileSize, tileSize)
    setColor("tile_outline")
    love.graphics.rectangle("line", x, y, tileSize, tileSize)
    setColor("white")
end

function drawLetterSquare(letter, x, y)
    setColor("letter")
    love.graphics.rectangle("fill", x, y, tileSize, tileSize)
    setColor("tile_outline")
    love.graphics.rectangle("line", x, y, tileSize, tileSize)
    love.graphics.print(letter:upper(), x + 5, y)
    setColor("white")
end

function drawBoard(board)
    for row = 1, board:getDimensions() do 
        for col = 1, board:getDimensions() do
            local t = board:get(row, col)
            if t then
                drawLetterSquare(t, paddingH + (col-1) * tileSize, paddingV + (row-1) * tileSize)
            else
                local bonus = board:getBonusLetter(row, col)
                local type = "white"
                if bonus == "." then
                    type = "base"
                elseif bonus == "d" then
                    type = "dl"
                elseif bonus == "t" then
                    type = "tl"
                elseif bonus == "D" then 
                    type = "dw"
                elseif bonus == "T" then 
                    type = "tw"
                end

                drawSquare(type, paddingH + (col-1) * tileSize, paddingV + (row-1) * tileSize)
            end
        end
    end
end



