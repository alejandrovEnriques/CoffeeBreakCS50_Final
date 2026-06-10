local Character = require("character")
local Difficulty = require("difficulty")
local Customers = require("customers")
local Save = require("save")

local G = {}

function love.load()
    love.window.setTitle("Coffee Break")
    love.graphics.setDefaultFilter("nearest", "nearest")

    love.window.setMode(0, 0, {
        fullscreen = true,
        resizable = false,
        borderless = true
    })

    G.virtualWidth = 900
    G.virtualHeight = 600
    G.lanes = {150, 250, 350, 450}

    G.player = { lane = 1, x = 80, y = G.lanes[1] }
    G.backgroundImage = love.graphics.newImage("Envirorment/background.png")

    G.customers = {}
    G.coffees = {}
    G.emptyCups = {}
    G.pendingSpawns = {}

    G.score = 0
    G.highScore = Save.loadHighScore()
    G.highScores = loadScoreBoard()
    G.enteringHighScore = false
    G.pendingHighScore = nil
    G.highScoreInitials = { "A", "A", "A" }
    G.highScoreSelectedSlot = 1
    G.gameOverReceipt = nil
    G.lives = 3
    G.gameOver = false
    G.paused = false

    G.comboServed = 0
    G.multiplier = 1
    G.extraLivesAwarded = 0

    G.levelMessage = ""
    G.levelMessageTimer = 0

    G.gameTime = 0
    G.spawnTimer = 0
    G.spawnCooldownTimer = 0
    G.lastSpawnLane = 0
    G.currentLevel = 1

    G.spawnInterval = 2.1
    G.maxActiveCustomers = 3
    G.targetActiveCustomers = 2
    G.perLaneLimit = 1
    G.customerBaseSpeed = 55
    G.customerApproachSpeed = 55
    G.customerReturnSpeed = 160
    G.cupSpeed = 185
    G.drinkDuration = 0.40
    G.spawnRandomRange = 0.20
    G.fullSpawnCooldown = 1.4

    -- 4 zonas táctiles reales, una por carril.
    G.laneTouchZones = {
        { x = 0, y = 105, w = 400, h = 90 }, -- lane 1
        { x = 0, y = 205, w = 400, h = 90 }, -- lane 2
        { x = 0, y = 305, w = 400, h = 90 }, -- lane 3
        { x = 0, y = 400, w = 400, h = 120 }   -- lane 4
    }

    -- Debug visual de zonas táctiles. Ponlo en false cuando ya esté bien.
    G.showTouchDebug = true

    G.serveButton = { x = 720, y = 490, w = 140, h = 100, label = "SERVE" }
    G.pauseButton = { x = 760, y = 25, w = 110, h = 45, label = "PAUSE" }
    G.restartButton = { x = 320, y = 300, w = 260, h = 70, label = "RESTART" }
    G.gameOverRestartButton = { x = 320, y = 510, w = 260, h = 70, label = "RESTART" }

    G.pauseMenuButtons = {
        continue = { x = 320, y = 210, w = 260, h = 60, label = "CONTINUE" },
        restart = { x = 320, y = 290, w = 260, h = 60, label = "RESTART" },
        mainMenu = { x = 320, y = 370, w = 260, h = 60, label = "MAIN MENU" }
    }

    G.nameEntryButtons = {
        ok = { x = 320, y = 465, w = 260, h = 55, label = "OK" },
        slots = {
            { up = { x = 315, y = 220, w = 70, h = 45, label = "+" }, down = { x = 315, y = 340, w = 70, h = 45, label = "-" } },
            { up = { x = 415, y = 220, w = 70, h = 45, label = "+" }, down = { x = 415, y = 340, w = 70, h = 45, label = "-" } },
            { up = { x = 515, y = 220, w = 70, h = 45, label = "+" }, down = { x = 515, y = 340, w = 70, h = 45, label = "-" } }
        }
    }

    Character.load(G)

    G.coffeeImage = love.graphics.newImage("Props/Coffee/Coffee_Full.png")
    G.coffeeScale = 0.06

    G.moneyImage = love.graphics.newImage("Props/Money/Money.png")
    G.moneyScale = 0.08

    G.serveButtonImage = love.graphics.newImage("UI/ServeButton.png")
    G.serveButtonPressedImage = love.graphics.newImage("UI/ServeButton_Pressed.png")
    G.serveButtonPressedTimer = 0

    G.pauseButtonImage = love.graphics.newImage("UI/PauseButton.png")
    G.pauseButtonPressedImage = love.graphics.newImage("UI/PauseButton_Pressed.png")
    G.pauseButtonPressedTimer = 0

    Difficulty.updateByLevel(G)

    G.screen = "press_start"
end

function G:loseLife()
    self.lives = self.lives - 1
    self.comboServed = 0
    self.multiplier = 1
    self.extraLivesAwarded = 0

    self.levelMessage = "COMBO LOST"
    self.levelMessageTimer = 1.2
    self.spawnCooldownTimer = math.max(self.spawnCooldownTimer, 0.6)

    if self.lives <= 0 then
        self:endGame()
    end
end

function G:endGame()
    if self.score > self.highScore then
        self.highScore = self.score
        Save.saveHighScore(self.highScore)
    end

    self.gameOverReceipt = buildGameOverReceipt(self.score, self.highScore)
    self.enteringHighScore = qualifiesForScoreBoard(self.score)
    self.pendingHighScore = self.enteringHighScore and self.score or nil
    self.highScoreInitials = { "A", "A", "A" }
    self.highScoreSelectedSlot = 1
    self.gameOver = true
end

function buildGameOverReceipt(totalEarned, bestDay)
    local takeHome = 0

    if totalEarned > 0 then
        takeHome = math.min(totalEarned, love.math.random(5, 15))
    end

    local totalDeductions = math.max(0, totalEarned - takeHome)

    local nightShiftTax = math.floor(totalDeductions * 0.34)
    local cupMaintenance = math.floor(totalDeductions * 0.23)
    local managementTip = math.floor(totalDeductions * 0.28)
    local emotionalDamages = totalDeductions - nightShiftTax - cupMaintenance - managementTip

    return {
        totalEarned = totalEarned,
        bestDay = bestDay,
        deductions = {
            { label = "NIGHT SHIFT TAX", amount = nightShiftTax },
            { label = "CUP MAINTENANCE", amount = cupMaintenance },
            { label = "MANAGEMENT TIP", amount = managementTip },
            { label = "EMOTIONAL DAMAGES", amount = emotionalDamages }
        },
        takeHome = takeHome
    }
end

function formatMoney(amount)
    return "$" .. tostring(math.floor(amount or 0))
end

function loadScoreBoard()
    local defaultScores = {
        { name = "AAA", score = 0 },
        { name = "BBB", score = 0 },
        { name = "CCC", score = 0 },
        { name = "DDD", score = 0 }
    }

    if not love.filesystem.getInfo("coffee_break_scores.txt") then
        return defaultScores
    end

    local contents = love.filesystem.read("coffee_break_scores.txt")
    local scores = {}

    for line in string.gmatch(contents or "", "[^\r\n]+") do
        local name, scoreText = line:match("^([A-Z][A-Z][A-Z]),(%d+)$")

        if name and scoreText then
            table.insert(scores, { name = name, score = tonumber(scoreText) or 0 })
        end
    end

    table.sort(scores, function(a, b) return a.score > b.score end)

    while #scores < 4 do
        table.insert(scores, defaultScores[#scores + 1])
    end

    while #scores > 4 do
        table.remove(scores)
    end

    return scores
end

function saveScoreBoard(scores)
    local lines = {}

    for i = 1, math.min(4, #scores) do
        local entry = scores[i]
        table.insert(lines, string.format("%s,%d", entry.name, math.floor(entry.score or 0)))
    end

    love.filesystem.write("coffee_break_scores.txt", table.concat(lines, "\n"))
end

function qualifiesForScoreBoard(score)
    if score <= 0 then
        return false
    end

    for i = 1, 4 do
        if score > (G.highScores[i] and G.highScores[i].score or 0) then
            return true
        end
    end

    return false
end

function insertScore(name, score)
    table.insert(G.highScores, { name = name, score = math.floor(score or 0) })
    table.sort(G.highScores, function(a, b) return a.score > b.score end)

    while #G.highScores > 4 do
        table.remove(G.highScores)
    end

    saveScoreBoard(G.highScores)
end

function currentInitialsText()
    return table.concat(G.highScoreInitials or { "A", "A", "A" })
end

function changeInitial(slot, delta)
    local letters = G.highScoreInitials
    local byte = string.byte(letters[slot]) + delta

    if byte > string.byte("Z") then
        byte = string.byte("A")
    elseif byte < string.byte("A") then
        byte = string.byte("Z")
    end

    letters[slot] = string.char(byte)
end

function submitHighScoreName()
    insertScore(currentInitialsText(), G.pendingHighScore or G.score)
    G.enteringHighScore = false
    G.pendingHighScore = nil
end

function G:resetGame()
    self.player = { lane = 1, x = 80, y = self.lanes[1] }

    self.customers = {}
    self.coffees = {}
    self.emptyCups = {}
    self.pendingSpawns = {}
    
    G.customerTypes = {
        "office_worker",
        "wizard",
        "robot",
        "clown"
    }

    self.score = 0
    self.gameOverReceipt = nil
    self.enteringHighScore = false
    self.pendingHighScore = nil
    self.highScoreInitials = { "A", "A", "A" }
    self.highScoreSelectedSlot = 1
    self.lives = 3
    self.gameOver = false
    self.paused = false

    self.comboServed = 0
    self.multiplier = 1
    self.extraLivesAwarded = 0

    self.levelMessage = ""
    self.levelMessageTimer = 0

    self.gameTime = 0
    self.spawnTimer = 0
    self.spawnCooldownTimer = 0
    self.lastSpawnLane = 0
    self.currentLevel = 1

    Character.reset(self)
    Difficulty.updateByLevel(self)
end

function love.update(dt)
    if G.screen ~= "playing" then
        return
    end

    if G.gameOver or G.paused then
        return
    end

    Character.update(G, dt)

    G.gameTime = G.gameTime + dt

    updateDifficultyFlow(dt)
    Difficulty.updateByLevel(G)

    if G.levelMessageTimer > 0 then
        G.levelMessageTimer = math.max(0, G.levelMessageTimer - dt)
    end

    if G.spawnCooldownTimer > 0 then
        G.spawnCooldownTimer = math.max(0, G.spawnCooldownTimer - dt)
    end

    Customers.updatePendingSpawns(G, dt)

    G.spawnTimer = G.spawnTimer + dt

    if G.spawnTimer >= G.spawnInterval then
        G.spawnTimer = 0
        Customers.trySpawnPulse(G)
    end

    Customers.updateCoffees(G, dt)
    Customers.updateCustomers(G, dt)
    Customers.updateEmptyCups(G, dt)
    Customers.checkCollisions(G)

    if G.score > G.highScore then
        G.highScore = G.score
        Save.saveHighScore(G.highScore)
    end

    if G.serveButtonPressedTimer > 0 then
        G.serveButtonPressedTimer = math.max(0, G.serveButtonPressedTimer - dt)
    end
end

function updateDifficultyFlow(dt)
    local oldLevel = G.currentLevel
    local t = G.gameTime

    if t < 15 then
        G.currentLevel = 1
    elseif t < 30 then
        G.currentLevel = 2
    elseif t < 45 then
        G.currentLevel = 3
    elseif t < 60 then
        G.currentLevel = 4
    elseif t < 120 then
        G.currentLevel = 5
    elseif t < 180 then
        G.currentLevel = 6
    elseif t < 240 then
        G.currentLevel = 7
    elseif t < 300 then
        G.currentLevel = 8
    else
        G.currentLevel = 9
    end

    if G.currentLevel > oldLevel then
        G.levelMessage = "LEVEL UP!"
        G.levelMessageTimer = 1.2
    end
end

function love.draw()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local scaleX = screenWidth / G.virtualWidth
    local scaleY = screenHeight / G.virtualHeight
    local scale = math.min(scaleX, scaleY)

    local offsetX = (screenWidth - G.virtualWidth * scale) / 2
    local offsetY = (screenHeight - G.virtualHeight * scale) / 2

    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)

    love.graphics.draw(
        G.backgroundImage,
        0,
        0,
        0,
        G.virtualWidth / G.backgroundImage:getWidth(),
        G.virtualHeight / G.backgroundImage:getHeight()
    )

    if G.screen == "press_start" then
        love.graphics.printf("COFFEE BREAK", 0, 220, G.virtualWidth, "center")
        love.graphics.printf("PRESS START", 0, 300, G.virtualWidth, "center")
        love.graphics.pop()
        return
    end

    if G.screen == "level_select" then
        love.graphics.printf("WORLD 1", 0, 120, G.virtualWidth, "center")

        love.graphics.rectangle("line", 300, 220, 300, 70)
        love.graphics.printf("1-1 MORNING RUSH", 300, 245, 300, "center")

        love.graphics.rectangle("line", 300, 320, 300, 70)
        love.graphics.printf("1-2 COMING SOON", 300, 345, 300, "center")

        love.graphics.rectangle("line", 300, 420, 300, 70)
        love.graphics.printf("1-3 COMING SOON", 300, 445, 300, "center")

        love.graphics.pop()
        return
    end

    love.graphics.print("Score: " .. G.score, 30, 20)
    love.graphics.print("Lives: " .. G.lives, 30, 45)
    love.graphics.print("x" .. G.multiplier, 30, 70)

    local minute = math.floor(G.gameTime / 60)
    local second = math.floor(G.gameTime % 60)
    love.graphics.print(string.format("Time: %01d:%02d", minute, second), 140, 20)
    love.graphics.print("Level: " .. G.currentLevel, 140, 45)

    if G.levelMessageTimer > 0 then
        love.graphics.print(G.levelMessage, 390, 80)
    end

    -- Pause menu is drawn later, after gameplay objects, so it appears on top.

    for i = 1, 4 do
        love.graphics.line(0, G.lanes[i] + 20, 900, G.lanes[i] + 20)
    end

    -- Debug: dibuja las zonas táctiles de cada carril.
    if G.showTouchDebug then
        for laneIndex, zone in ipairs(G.laneTouchZones) do
            love.graphics.rectangle("line", zone.x, zone.y, zone.w, zone.h)
            love.graphics.print("TOUCH LANE " .. laneIndex, zone.x + 10, zone.y + 10)
        end
    end

    Character.draw(G)
    Customers.draw(G)

    local serveImage = G.serveButtonImage

    if G.serveButtonPressedTimer > 0 then
        serveImage = G.serveButtonPressedImage
    end

    love.graphics.draw(
        serveImage,
        G.serveButton.x,
        G.serveButton.y,
        0,
        G.serveButton.w / serveImage:getWidth(),
        G.serveButton.h / serveImage:getHeight()
    )

    love.graphics.rectangle("line", G.pauseButton.x, G.pauseButton.y, G.pauseButton.w, G.pauseButton.h)
    love.graphics.printf("PAUSE", G.pauseButton.x, G.pauseButton.y + 15, G.pauseButton.w, "center")

    if G.gameOver then
        drawGameOverScreen()
    end

    if G.paused and not G.gameOver then
        drawPauseMenu()
    end

    love.graphics.pop()
end

function drawGameOverScreen()
    love.graphics.setColor(0, 0, 0, 0.72)
    love.graphics.rectangle("fill", 0, 0, G.virtualWidth, G.virtualHeight)
    love.graphics.setColor(1, 1, 1, 1)

    if G.enteringHighScore then
        drawNameEntryScreen()
        return
    end

    local receipt = G.gameOverReceipt or buildGameOverReceipt(G.score, G.highScore)

    local x = 285
    local y = 80
    local w = 330
    local h = 395

    love.graphics.rectangle("line", x, y, w, h)

    love.graphics.printf("END OF SHIFT", x, y + 25, w, "center")
    love.graphics.printf("JOHN STARBUCKS RECEIPT", x, y + 50, w, "center")

    love.graphics.print("TOTAL EARNED", x + 35, y + 95)
    love.graphics.print(formatMoney(receipt.totalEarned), x + 215, y + 95)

    love.graphics.print("BEST DAY", x + 35, y + 120)
    love.graphics.print(formatMoney(receipt.bestDay), x + 215, y + 120)

    love.graphics.line(x + 30, y + 150, x + w - 30, y + 150)

    local lineY = y + 175

    for _, deduction in ipairs(receipt.deductions) do
        love.graphics.print(deduction.label, x + 35, lineY)
        love.graphics.print("-" .. formatMoney(deduction.amount), x + 215, lineY)
        lineY = lineY + 25
    end

    love.graphics.line(x + 30, y + 285, x + w - 30, y + 285)

    love.graphics.print("TAKE HOME", x + 35, y + 310)
    love.graphics.print(formatMoney(receipt.takeHome), x + 215, y + 310)

    love.graphics.printf("THANK YOU FOR YOUR PRODUCTIVITY", x + 20, y + 345, w - 40, "center")

    drawScoreBoard(620, 115)

    drawButton(G.gameOverRestartButton)
end


function drawNameEntryScreen()
    love.graphics.printf("NEW BEST SHIFT!", 0, 120, G.virtualWidth, "center")
    love.graphics.printf("ENTER INITIALS", 0, 155, G.virtualWidth, "center")
    love.graphics.printf(formatMoney(G.pendingHighScore or G.score), 0, 185, G.virtualWidth, "center")

    for i = 1, 3 do
        local slot = G.nameEntryButtons.slots[i]
        drawButton(slot.up)

        local letterX = slot.up.x
        local letterY = 280

        if G.highScoreSelectedSlot == i then
            love.graphics.rectangle("line", letterX - 5, letterY - 5, 80, 45)
        end

        love.graphics.printf(G.highScoreInitials[i], letterX, letterY + 8, 70, "center")
        drawButton(slot.down)
    end

    drawButton(G.nameEntryButtons.ok)
    drawScoreBoard(40, 170)
end

function drawScoreBoard(x, y)
    love.graphics.print("BEST SHIFTS", x, y)

    for i = 1, 4 do
        local entry = G.highScores[i] or { name = "---", score = 0 }
        local line = string.format("%d. %s  %s", i, entry.name, formatMoney(entry.score))
        love.graphics.print(line, x, y + 30 + (i - 1) * 28)
    end
end

function drawButton(rect, label)
    love.graphics.rectangle("line", rect.x, rect.y, rect.w, rect.h)
    love.graphics.printf(label or rect.label or "", rect.x, rect.y + rect.h / 2 - 8, rect.w, "center")
end

function drawPauseMenu()
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, G.virtualWidth, G.virtualHeight)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.printf("PAUSED", 0, 145, G.virtualWidth, "center")

    drawButton(G.pauseMenuButtons.continue)
    drawButton(G.pauseMenuButtons.restart)
    drawButton(G.pauseMenuButtons.mainMenu)
end

function love.keypressed(key)
    if G.screen == "press_start" then
        G.screen = "level_select"
        return
    end

    if G.screen == "level_select" then
        if key == "space" or key == "return" then
            G:resetGame()
            G.screen = "playing"
        end
        return
    end

    if key == "p" then
        G.paused = not G.paused
        return
    end

    if G.gameOver then
        if G.enteringHighScore then
            if key == "left" or key == "a" then
                G.highScoreSelectedSlot = math.max(1, G.highScoreSelectedSlot - 1)
            elseif key == "right" or key == "d" then
                G.highScoreSelectedSlot = math.min(3, G.highScoreSelectedSlot + 1)
            elseif key == "up" or key == "w" then
                changeInitial(G.highScoreSelectedSlot, 1)
            elseif key == "down" or key == "s" then
                changeInitial(G.highScoreSelectedSlot, -1)
            elseif key == "return" or key == "space" then
                submitHighScoreName()
            elseif #key == 1 then
                local upper = string.upper(key)

                if upper:match("^[A-Z]$") then
                    G.highScoreInitials[G.highScoreSelectedSlot] = upper
                    G.highScoreSelectedSlot = math.min(3, G.highScoreSelectedSlot + 1)
                end
            end
        elseif key == "r" then
            G:resetGame()
            G.screen = "playing"
        end

        return
    end

    if G.paused then
        return
    end

    if (key == "up" or key == "w") and G.player.lane > 1 then
        Character.moveToLane(G, G.player.lane - 1)
    elseif (key == "down" or key == "s") and G.player.lane < 4 then
        Character.moveToLane(G, G.player.lane + 1)
    elseif key == "space" then
        Customers.shootCoffee(G)
    end
end

function love.mousepressed(x, y, button)
    if button ~= 1 then
        return
    end

    local worldX, worldY = screenToWorld(x, y)
    handlePress(worldX, worldY)
end

function love.touchpressed(id, x, y, dx, dy, pressure)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local screenX = x * screenWidth
    local screenY = y * screenHeight

    local worldX, worldY = screenToWorld(screenX, screenY)
    handlePress(worldX, worldY)
end

function screenToWorld(screenX, screenY)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local scaleX = screenWidth / G.virtualWidth
    local scaleY = screenHeight / G.virtualHeight
    local scale = math.min(scaleX, scaleY)

    local offsetX = (screenWidth - G.virtualWidth * scale) / 2
    local offsetY = (screenHeight - G.virtualHeight * scale) / 2

    local worldX = (screenX - offsetX) / scale
    local worldY = (screenY - offsetY) / scale

    return worldX, worldY
end

function handlePress(x, y)
    if G.screen == "press_start" then
        G.screen = "level_select"
        return
    end

    if G.screen == "level_select" then
        if x >= 300 and x <= 600 and y >= 220 and y <= 290 then
            G:resetGame()
            G.screen = "playing"
        end
        return
    end

    if G.gameOver then
        if G.enteringHighScore then
            for i = 1, 3 do
                local slot = G.nameEntryButtons.slots[i]

                if isInsideRect(x, y, slot.up) then
                    G.highScoreSelectedSlot = i
                    changeInitial(i, 1)
                    return
                end

                if isInsideRect(x, y, slot.down) then
                    G.highScoreSelectedSlot = i
                    changeInitial(i, -1)
                    return
                end
            end

            if isInsideRect(x, y, G.nameEntryButtons.ok) then
                submitHighScoreName()
            end

            return
        end

        if isInsideRect(x, y, G.gameOverRestartButton) then
            G:resetGame()
            G.screen = "playing"
        end
        return
    end

    if isInsideRect(x, y, G.pauseButton) then
        G.paused = not G.paused
        return
    end

    if G.paused then
        if isInsideRect(x, y, G.pauseMenuButtons.continue) then
            G.paused = false
            return
        end

        if isInsideRect(x, y, G.pauseMenuButtons.restart) then
            G:resetGame()
            G.screen = "playing"
            return
        end

        if isInsideRect(x, y, G.pauseMenuButtons.mainMenu) then
            G:resetGame()
            G.screen = "level_select"
            return
        end

        return
    end

    if isInsideRect(x, y, G.serveButton) then
        Customers.shootCoffee(G)
        return
    end

    for laneIndex, zone in ipairs(G.laneTouchZones) do
        if isInsideRect(x, y, zone) then
            Character.moveToLane(G, laneIndex)
            return
        end
    end
end

function isInsideRect(x, y, rect)
    return x >= rect.x and x <= rect.x + rect.w
       and y >= rect.y and y <= rect.y + rect.h
end

function love.focus(focused)
    if not focused then
        G.paused = true
    end
end

function love.visible(visible)
    if not visible then
        G.paused = true
    end
end