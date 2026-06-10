local Difficulty = require("difficulty")
local Save = require("save")

local Customers = {}

function Customers.draw(G)
    for _, customer in ipairs(G.customers) do
        if customer.drinking then
            love.graphics.rectangle("line", customer.x, customer.y, 30, 30)
            love.graphics.print("...", customer.x + 35, customer.y)
        elseif customer.served then
            love.graphics.rectangle("line", customer.x, customer.y, 30, 30)
        else
            love.graphics.rectangle("fill", customer.x, customer.y, 30, 30)
        end

        -- Debug temporal para ver qué tipo de cliente es.
        -- Cuando metas sprites, puedes borrar estas 3 líneas.
        if customer.type then
            love.graphics.print(customer.type, customer.x - 20, customer.y - 20)
        end
    end

    for _, coffee in ipairs(G.coffees) do
        love.graphics.draw(
            G.coffeeImage,
            coffee.x,
            coffee.y + 15,
            0,
            G.coffeeScale,
            G.coffeeScale,
            G.coffeeImage:getWidth() / 2,
            G.coffeeImage:getHeight() / 2
        )
    end

    for _, money in ipairs(G.emptyCups) do
        love.graphics.draw(
            G.moneyImage,
            money.x,
            money.y + 15,
            0,
            G.moneyScale,
            G.moneyScale,
            G.moneyImage:getWidth() / 2,
            G.moneyImage:getHeight() / 2
        )
    end
end

function Customers.shootCoffee(G)
    G.serveButtonPressedTimer = 0.08

    table.insert(G.coffees, {
        lane = G.player.lane,
        x = G.player.x + 30,
        y = G.player.y,
        speed = 500,
        hitSomeone = false
    })
end

function Customers.chooseCustomerType(G)
    local activeTypes = {}

    for _, customer in ipairs(G.customers) do
        if customer.type then
            activeTypes[customer.type] = true
        end
    end

    local availableTypes = {}

    for _, customerType in ipairs(G.customerTypes) do
        if not activeTypes[customerType] then
            table.insert(availableTypes, customerType)
        end
    end

    -- Si todos están ocupados, permitir repetir.
    if #availableTypes == 0 then
        availableTypes = G.customerTypes
    end

    return availableTypes[love.math.random(1, #availableTypes)]
end

function Customers.spawnCustomer(G, lane)
    table.insert(G.customers, {
        type = Customers.chooseCustomerType(G),

        lane = lane,
        x = 850,
        y = G.lanes[lane],
        speed = G.customerBaseSpeed,

        served = false,
        drinking = false,
        drinkTimer = 0
    })

    G.lastSpawnLane = lane
end

function Customers.spawnEmptyCup(G, x, lane)
    table.insert(G.emptyCups, {
        lane = lane,
        x = x,
        y = G.lanes[lane],
        speed = G.cupSpeed
    })
end

function Customers.updateCoffees(G, dt)
    for i = #G.coffees, 1, -1 do
        local coffee = G.coffees[i]
        coffee.x = coffee.x + coffee.speed * dt

        if coffee.x > 900 then
            if not coffee.hitSomeone then
                G:loseLife()
            end

            table.remove(G.coffees, i)
        end
    end
end

function Customers.updateCustomers(G, dt)
    for i = #G.customers, 1, -1 do
        local customer = G.customers[i]

        if customer.drinking then
            customer.drinkTimer = customer.drinkTimer - dt

            if customer.drinkTimer <= 0 then
                customer.drinking = false
                customer.served = true
                customer.speed = G.customerReturnSpeed

                Customers.spawnEmptyCup(G, customer.x, customer.lane)
            end

        elseif customer.served then
            customer.x = customer.x + customer.speed * dt

            if customer.x > 950 then
                G.score = G.score + (100 * G.multiplier)
                G.comboServed = G.comboServed + 1

                Customers.updateMultiplier(G)

                if G.comboServed % 50 == 0 and G.extraLivesAwarded < 2 then
                    G.lives = G.lives + 1
                    G.extraLivesAwarded = G.extraLivesAwarded + 1
                end

                if G.score > G.highScore then
                    G.highScore = G.score
                    Save.saveHighScore(G.highScore)
                end

                table.remove(G.customers, i)
            end

        else
            customer.x = customer.x - customer.speed * dt

            if customer.x <= G.player.x + 20 then
                G:loseLife()
                table.remove(G.customers, i)
            end
        end
    end
end

function Customers.updateEmptyCups(G, dt)
    for i = #G.emptyCups, 1, -1 do
        local money = G.emptyCups[i]
        money.x = money.x - money.speed * dt

        if money.lane == G.player.lane and math.abs(money.x - (G.player.x + 20)) < 20 then
            table.remove(G.emptyCups, i)
        elseif money.x < 0 then
            G:loseLife()
            table.remove(G.emptyCups, i)
        end
    end
end

function Customers.checkCollisions(G)
    for i = #G.customers, 1, -1 do
        local customer = G.customers[i]

        if not customer.served and not customer.drinking then
            for j = #G.coffees, 1, -1 do
                local coffee = G.coffees[j]

                if customer.lane == coffee.lane and math.abs(customer.x - coffee.x) < 20 then
                    customer.drinking = true
                    customer.drinkTimer = G.drinkDuration
                    coffee.hitSomeone = true

                    table.remove(G.coffees, j)
                    break
                end
            end
        end
    end
end

function Customers.updatePendingSpawns(G, dt)
    for i = #G.pendingSpawns, 1, -1 do
        local pending = G.pendingSpawns[i]
        pending.delay = pending.delay - dt

        if pending.delay <= 0 then
            if Customers.canSpawnMoreCustomers(G) and Customers.laneCanAcceptSpawn(G, pending.lane) then
                Customers.spawnCustomer(G, pending.lane)
            end

            table.remove(G.pendingSpawns, i)
        end
    end
end

function Customers.trySpawnPulse(G)
    if G.spawnCooldownTimer > 0 then
        return
    end

    local occupancy = Customers.countWorldOccupancy(G)

    if occupancy == 0 then
        local lane = Customers.chooseSmartLane(G)

        if lane then
            Customers.spawnCustomer(G, lane)
        end

        G.spawnTimer = 0
        return
    end

    if occupancy >= G.maxActiveCustomers then
        G.spawnCooldownTimer = G.fullSpawnCooldown
        return
    end

    local lane = Customers.chooseSmartLane(G)

    if lane then
        Customers.spawnCustomer(G, lane)
    end
end

function Customers.tryScheduleSpawnPattern(G)
    Customers.trySpawnPulse(G)
end

function Customers.chooseSmartLane(G)
    local candidates = {}

    for lane = 1, 4 do
        if Customers.laneCanAcceptSpawn(G, lane) then
            table.insert(candidates, lane)
        end
    end

    if #candidates == 0 then
        return nil
    end

    local filtered = {}

    for _, lane in ipairs(candidates) do
        if lane ~= G.lastSpawnLane and lane ~= G.player.lane then
            table.insert(filtered, lane)
        end
    end

    if #filtered > 0 then
        candidates = filtered
    else
        filtered = {}

        for _, lane in ipairs(candidates) do
            if lane ~= G.lastSpawnLane then
                table.insert(filtered, lane)
            end
        end

        if #filtered > 0 then
            candidates = filtered
        end
    end

    return candidates[love.math.random(1, #candidates)]
end

function Customers.choosePatternLanes(G, desiredCount)
    local lanes = {}

    for i = 1, desiredCount do
        local lane = Customers.chooseSmartLane(G)

        if lane then
            table.insert(lanes, lane)
        end
    end

    return lanes
end

function Customers.getAvailableSpawnLanes(G)
    local candidates = {}

    for lane = 1, 4 do
        if Customers.laneCanAcceptSpawn(G, lane) then
            table.insert(candidates, {
                lane = lane,
                blockingCount = Customers.getLaneBlockingCount(G, lane)
            })
        end
    end

    return candidates
end

function Customers.getLaneBlockingCount(G, lane)
    local count = 0

    for _, customer in ipairs(G.customers) do
        if customer.lane == lane and not customer.served then
            count = count + 1
        end
    end

    for _, pending in ipairs(G.pendingSpawns) do
        if pending.lane == lane then
            count = count + 1
        end
    end

    return count
end

function Customers.getBlockingCountsPerLane(G)
    local counts = {0, 0, 0, 0}

    for _, customer in ipairs(G.customers) do
        if not customer.served then
            counts[customer.lane] = counts[customer.lane] + 1
        end
    end

    return counts
end

function Customers.getPendingCountsPerLane(G)
    local counts = {0, 0, 0, 0}

    for _, pending in ipairs(G.pendingSpawns) do
        if pending.lane then
            counts[pending.lane] = counts[pending.lane] + 1
        end
    end

    return counts
end

function Customers.laneCanAcceptSpawn(G, lane)
    return Customers.getLaneBlockingCount(G, lane) < G.perLaneLimit
end

function Customers.countWorldOccupancy(G)
    return #G.customers + #G.emptyCups + #G.pendingSpawns
end

function Customers.canSpawnMoreCustomers(G)
    return Customers.countWorldOccupancy(G) < G.maxActiveCustomers
end

function Customers.updateMultiplier(G)
    if G.comboServed >= 90 then
        G.multiplier = 5
    elseif G.comboServed >= 60 then
        G.multiplier = 4
    elseif G.comboServed >= 35 then
        G.multiplier = 3
    elseif G.comboServed >= 15 then
        G.multiplier = 2
    else
        G.multiplier = 1
    end
end

return Customers