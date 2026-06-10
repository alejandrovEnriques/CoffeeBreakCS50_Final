local Character = {}

function Character.load(G)
    G.barista = {}
    G.barista.frames = {
        
        love.graphics.newImage("Character/idle/barista_idle_01.png"),
        love.graphics.newImage("Character/idle/barista_idle_02.png"),
        love.graphics.newImage("Character/idle/barista_idle_03.png"),
        love.graphics.newImage("Character/idle/barista_idle_04.png"),
        love.graphics.newImage("Character/idle/barista_idle_05.png")
    }
    G.barista.currentFrame = 1
    G.barista.animTimer = 0
    G.barista.animSpeed = 0.18
    G.barista.scale = 0.1
end

function Character.update(G, dt)
    G.barista.animTimer = G.barista.animTimer + dt

    if G.barista.animTimer >= G.barista.animSpeed then
        G.barista.animTimer = 0
        G.barista.currentFrame = G.barista.currentFrame + 1

        if G.barista.currentFrame > #G.barista.frames then
            G.barista.currentFrame = 1
        end
    end
end

function Character.draw(G)
    local currentImage = G.barista.frames[G.barista.currentFrame]

    love.graphics.draw(
        currentImage,
        G.player.x + 15,
        G.player.y + 18,
        0,
        G.barista.scale,
        G.barista.scale,
        currentImage:getWidth() / 2,
        currentImage:getHeight() / 2
    )
end

function Character.moveToLane(G, lane)
    G.player.lane = lane
    G.player.y = G.lanes[lane]
end

function Character.reset(G)
    G.barista.currentFrame = 1
    G.barista.animTimer = 0
end

return Character