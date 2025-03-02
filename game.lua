--[[
    SCREEN DIMENSIONS
    * top left == 0, 0
    * top right == windowX - 65, 0
    * bottom left == 0, windowY - 65
    * bottom right == windowX - 65, windowY - 65
]]

game = {}

windowX, windowY = 1000, 700 -- 1200, 900
local points = 0
player = {}
fruits = {}
local anim8 = require "anim8"

local bananaX, bananaY = -100, -100
local grapeX, grapeY = -100, -100
local orangeX, orangeY = -100, -100

function game.load()
    love.window.setMode(windowX, windowY)

    -- Initialize player
    player.x = (windowX / 2) - 30
    player.y = (windowY / 2) - 50
    player.width = 60
    player.height = 90
    player.speed = 2
    player.spriteSheet = love.graphics.newImage('assets/player-sheet.png')
    player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())
    player.animations = {
        down = anim8.newAnimation(player.grid('1-4', 1), 0.1),
        left = anim8.newAnimation(player.grid('1-4', 2), 0.1),
        right = anim8.newAnimation(player.grid('1-4', 3), 0.1),
        up = anim8.newAnimation(player.grid('1-4', 4), 0.1)
    }
    player.anim = player.animations.down

    -- Initialize tractor
    tractorImg = {
        up = love.graphics.newImage('assets/tractorUP.png'),
        down = love.graphics.newImage('assets/tractorDOWN.png'),
        left = love.graphics.newImage('assets/tractorLEFT.png'),
        right = love.graphics.newImage('assets/tractorRIGHT.png')
    }
    tractorCurrentImg = tractorImg.left

    tractor = {
        x = (windowX / 2) - 50,
        y = (windowY / 2) - 200,
        speed = 150,
        currentImg = tractorImg.down
    }

    -- Initialize fruitX, fruitY
    game.resetBanana()
    game.resetGrape()
    game.resetOrange()
end

local minDistance = 100 

function distance(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function isTooClose(x1, y1, x2, y2)
    return distance(x1, y1, x2, y2) < minDistance
end

function generateValidCoords()
    local x, y
    repeat
        x = love.math.random(0, windowX - 65)
        y = love.math.random(0, windowY - 65)
    until not (
        isTooClose(x, y, player.x, player.y) or
        isTooClose(x, y, bananaX, bananaY) or
        isTooClose(x, y, grapeX, grapeY) or
        isTooClose(x, y, orangeX, orangeY) 
    )
    return x, y 

end

function game.resetBanana()
    bananaX, bananaY = generateValidCoords()
end

function game.resetGrape()
    grapeX, grapeY = generateValidCoords()
end

function game.resetOrange()
    orangeX, orangeY = generateValidCoords()
end

function game.update(dt)
    game.checkCollision()
end

function game.checkCollision()
    local playerLeft = player.x 
    local playerRight = player.x + player.width 
    local playerTop = player.y 
    local playerBottom = player.y + player.height 

    local bananaLeft = bananaX + 35
    local bananaRight = bananaX + 35
    local bananaTop = bananaY + 35
    local bananaBottom = bananaY + 35

    if (playerRight > bananaLeft) and (playerLeft < bananaRight) and (playerBottom > bananaTop) and (playerTop < bananaBottom) then 
        points = points + 1
        game.eatSound:play()
        game.resetBanana()
    end

    local grapeLeft = grapeX + 35
    local grapeRight = grapeX + 35
    local grapeTop = grapeY + 35
    local grapeBottom = grapeY + 35

    if (playerRight > grapeLeft) and (playerLeft < grapeRight) and (playerBottom > grapeTop) and (playerTop < grapeBottom) then 
        points = points + 3
        game.eatSound:play()
        game.resetGrape()
    end

    local orangeLeft = orangeX + 35
    local orangeRight = orangeX + 35
    local orangeTop = orangeY + 35
    local orangeBottom = orangeY + 35

    if (playerRight > orangeLeft) and (playerLeft < orangeRight) and (playerBottom > orangeTop) and (playerTop < orangeBottom) then 
        points = points + 5
        game.eatSound:play()
        game.resetOrange()
    end

    for i = #tomatoPositions, 1, -1 do
        local tomato = tomatoPositions[i]
        local tomatoLeft = tomato.x + 35
        local tomatoRight = tomato.x + 35
        local tomatoTop = tomato.y + 35
        local tomatoBottom = tomato.y + 35

        if (playerRight > tomatoLeft) and (playerLeft < tomatoRight) and (playerBottom > tomatoTop) and (playerTop < tomatoBottom) then
            points = points - 4
            game.squishSound:play()
            table.remove(tomatoPositions, i)
        end
    end
    -- local tomatoLeft = tomatoX + 35
    -- local tomatoRight = tomatoX + 35
    -- local tomatoTop = tomatoY + 35
    -- local tomatoBottom = tomatoY + 35

    -- if (playerRight > tomatoLeft) and (playerLeft < tomatoRight) and (playerBottom > tomatoTop) and (playerTop < tomatoBottom) then 
    --     points = points - 4
    --     game.squishSound:play()
    --     game.resetTomato()
    -- end
end

function game.draw()
    -- Background
    love.graphics.setColor(37/255, 190/255, 126/255)
    love.graphics.rectangle('fill', 0, 0, windowX, windowY)

    love.graphics.setColor(1, 1, 1)

    -- Draw fruits
    love.graphics.draw(fruits.banana, bananaX, bananaY, nil, 2.5)
    love.graphics.draw(fruits.grape, grapeX, grapeY, nil, 2.5)
    love.graphics.draw(fruits.orange, orangeX, orangeY, nil, 2.5)

    -- Draw tomato
    -- love.graphics.draw(fruits.tomato, 400, 400, nil, 2.5)

    -- Draw player
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 5)

    -- Draw score and time
    love.graphics.setColor(0, 0, 0)
    local font = love.graphics.newFont(20)
    love.graphics.setFont(font)
    love.graphics.print('score: ' .. points, 10, 10)

    -- draw tractor
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(tractor.currentImg, tractor.x, tractor.y, nil, 4)
end

return game

--[[ Tomato projected methodology
if space key pressed --> place tomato at tractor location + begin 5 sec cooldown
if cooldown done --> resume functionality - else - disable functionality
]]
