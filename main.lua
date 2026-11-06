function love.load()
    love.window.setMode(1280, 720)
    Game = require "engine.core.game"
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
    local placements = {{1, 1, "L"}, {1, 2, "O"}, {1, 3, "Q"}}
    game.board:placeFromPlacements(placements)

    UIBoard = BoardView:new(game.board)
end

function love.update(dt)
    
end

function love.draw()
    UIBoard:draw()
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



