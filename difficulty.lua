local Difficulty = {}

function Difficulty.updateByLevel(G)
    if G.currentLevel == 1 then
        G.spawnInterval = 2.1
        G.maxActiveCustomers = 3
        G.targetActiveCustomers = 2
        G.perLaneLimit = 1
        G.customerBaseSpeed = 55
        G.cupSpeed = 185
        G.drinkDuration = 0.40
        G.customerReturnSpeed = 160
        G.spawnRandomRange = 0.20
        G.fullSpawnCooldown = 1.4

    elseif G.currentLevel == 2 then
        G.spawnInterval = 1.9
        G.maxActiveCustomers = 4
        G.targetActiveCustomers = 2
        G.perLaneLimit = 1
        G.customerBaseSpeed = 60
        G.cupSpeed = 190
        G.drinkDuration = 0.39
        G.customerReturnSpeed = 170
        G.spawnRandomRange = 0.18
        G.fullSpawnCooldown = 1.3

    elseif G.currentLevel == 3 then
        G.spawnInterval = 1.75
        G.maxActiveCustomers = 4
        G.targetActiveCustomers = 3
        G.perLaneLimit = 1
        G.customerBaseSpeed = 66
        G.cupSpeed = 195
        G.drinkDuration = 0.38
        G.customerReturnSpeed = 180
        G.spawnRandomRange = 0.16
        G.fullSpawnCooldown = 1.2

    elseif G.currentLevel == 4 then
        G.spawnInterval = 1.6
        G.maxActiveCustomers = 5
        G.targetActiveCustomers = 3
        G.perLaneLimit = 2
        G.customerBaseSpeed = 72
        G.cupSpeed = 200
        G.drinkDuration = 0.37
        G.customerReturnSpeed = 190
        G.spawnRandomRange = 0.15
        G.fullSpawnCooldown = 1.1

    elseif G.currentLevel == 5 then
        G.spawnInterval = 1.45
        G.maxActiveCustomers = 6
        G.targetActiveCustomers = 5
        G.perLaneLimit = 3
        G.customerBaseSpeed = 78
        G.cupSpeed = 205
        G.drinkDuration = 0.36
        G.customerReturnSpeed = 205
        G.spawnRandomRange = 0.14
        G.fullSpawnCooldown = 1.0

    elseif G.currentLevel == 6 then
        G.spawnInterval = 1.3
        G.maxActiveCustomers = 6
        G.targetActiveCustomers = 5
        G.perLaneLimit = 3
        G.customerBaseSpeed = 86
        G.cupSpeed = 212
        G.drinkDuration = 0.34
        G.customerReturnSpeed = 220
        G.spawnRandomRange = 0.12
        G.fullSpawnCooldown = 0.9

    elseif G.currentLevel == 7 then
        G.spawnInterval = 1.15
        G.maxActiveCustomers = 7
        G.targetActiveCustomers = 5
        G.perLaneLimit = 3
        G.customerBaseSpeed = 95
        G.cupSpeed = 220
        G.drinkDuration = 0.33
        G.customerReturnSpeed = 240
        G.spawnRandomRange = 0.10
        G.fullSpawnCooldown = 0.8

    elseif G.currentLevel == 8 then
        G.spawnInterval = 1.0
        G.maxActiveCustomers = 8
        G.targetActiveCustomers = 6
        G.perLaneLimit = 4
        G.customerBaseSpeed = 105
        G.cupSpeed = 230
        G.drinkDuration = 0.31
        G.customerReturnSpeed = 260
        G.spawnRandomRange = 0.08
        G.fullSpawnCooldown = 0.7

    else
        G.spawnInterval = 0.9
        G.maxActiveCustomers = 9
        G.targetActiveCustomers = 7
        G.perLaneLimit = 4
        G.customerBaseSpeed = 115
        G.cupSpeed = 240
        G.drinkDuration = 0.30
        G.customerReturnSpeed = 280
        G.spawnRandomRange = 0.06
        G.fullSpawnCooldown = 0.6
    end
end

return Difficulty