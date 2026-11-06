local move = {}

function move.play(placements)
    return {type = "play", placements = placements}
end

function move.exchange(tiles)
    return {type = "exchange", tiles = tiles}
end

function move.pass()
    return {type = "pass"}
end

return move