function love.load()
    math.randomseed(os.time())

    tile = require "src.core.tile"
    Bag = require "src.core.bag"

    

    bag = Bag:new(function(lo, hi) return hi end)

    drawn, error = bag:drawAtMost(101)
    if drawn == nil then
        print(error)
    else
        for _, l in ipairs(drawn) do
            print(l)
        end
    end
end

function love.update(dt)
    
end

function love.draw()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
