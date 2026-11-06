local BoardView = {}
BoardView.__index = BoardView

function BoardView:new(board)
    local o = {}
    o.__index = self
    o.board = board
    o.dimensions = board:getDimensions()
    o.tileSize = 30



    return setmetatable(o, self)
end 

function BoardView:drawSquare(type, x, y)
    setColor(type)
    love.graphics.rectangle("fill", x, y, self.tileSize, self.tileSize)
    setColor("tile_outline")
    love.graphics.rectangle("line", x, y, self.tileSize, self.tileSize)
    setColor("white")
end

function BoardView:drawLetterSquare(letter, x, y)
    setColor("letter")
    love.graphics.rectangle("fill", x, y, self.tileSize, self.tileSize)
    setColor("tile_outline")
    love.graphics.rectangle("line", x, y, self.tileSize, self.tileSize)
    love.graphics.print(letter:upper(), x + 5, y)
    setColor("white")
end



function BoardView:draw()
    local board = self.board

    for row = 1, self.dimensions do 
        for col = 1, self.dimensions do
            local t = board:get(row, col)
            if t then
                drawLetterSquare(t, (col-1) * self.tileSize, (row-1) * self.tileSize)
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

                drawSquare(type, (col-1) * self.tileSize, (row-1) * self.tileSize)
            end
        end
    end
