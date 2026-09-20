local tileData = require "src.config.tileData"

local tile = {}

function tile.blank(letter)
    return letter:lower()
end

function tile.unblank(letter)
    return letter:upper()
end

function tile.isBlank(letter)
    return (letter == letter:lower() or letter == "?") and (letter:match("[a-z]$") ~= nil)
end

function tile.score(letter)
    local letter = tile.rackForm(letter)
    return tileData[letter].points
end

function tile.isValid(letter)
    return type(letter) == "string" and tileData[letter:upper()] ~= nil
end

function tile.rackForm(letter)
    if letter.isBlank(letter) then
        return "?"
    else
        return letter
    end
end

return tile
