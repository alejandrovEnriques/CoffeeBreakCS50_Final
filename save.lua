local Save = {}

function Save.saveHighScore(value)
    love.filesystem.write("highscore.txt", tostring(value))
end

function Save.loadHighScore()
    if love.filesystem.getInfo("highscore.txt") then
        local contents = love.filesystem.read("highscore.txt")
        return tonumber(contents) or 0
    end

    return 0
end

return Save