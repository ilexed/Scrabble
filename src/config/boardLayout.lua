local bonusSquares = {
    "T..d...T...d..T",
    ".D...t...t...D.",
    "..D...d.d...D..",
    "d..D...d...D..d",
    "....D.....D....",
    ".t...t...t...t.",
    "..d...d.d...d..",
    "T..d...D...d..T",
    "..d...d.d...d..",
    ".t...t...t...t.",
    "....D.....D....",
    "d..D...d...D..d",
    "..D...d.d...D..",
    ".D...t...t...D.",
    "T..d...T...d..T",
}

local legend = {
    ["."] = {word = 1, letter = 1},
    d = {word = 1, letter = 2},
    t = {word = 1, letter = 3},
    D = {word = 2, letter = 1},
    T = {word = 3, letter = 1}
}

return {bonusSquares, legend}