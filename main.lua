BUTTON_HEIGHT = 64

local
function newButton(text, fn)
    return {
        text = text,
        fn = fn,

        now = false,
        last = false
    }
end

local buttons = {}
local font = nil

function love.load()
    font = love.graphics.newFont(32)

    camera = require 'libraries/camera'
    cam = camera()

    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require 'libraries/sti'
    gameMap = sti('maps/map1.lua')

    player = {}
    player.x = 500
    player.y = 500
    player.speed = 5
    player.spriteSheet = love.graphics.newImage('sprites/player1.png')
    player.grid = anim8.newGrid( 16, 16, 95, 159 )

    player.animation = {}
    player.animation.speed = 0.18
    player.animation.down = anim8.newAnimation( player.grid('2-3', 1), player.animation.speed )
    player.animation.up = anim8.newAnimation( player.grid('2-3', 4), player.animation.speed )
    player.animation.left = anim8.newAnimation( player.grid('2-3', 2), player.animation.speed )
    player.animation.right = anim8.newAnimation( player.grid('2-3', 3), player.animation.speed )
    
    player.anim = player.animation.down

    gameScene = false
    settingScene = false
    menu = true

    table.insert(buttons, newButton(
        "Start",
        function()
            settingScene = false
            gameScene = true
            menu = false
        end
    ))
    
    table.insert(buttons, newButton(
        "Settings",
        function()
            gameScene = false
            settingScene = true
            menu = false
        end
    ))

    table.insert(buttons, newButton(
        "Quit Game",
        function()
            love.event.quit(0)
        end
    ))

end

function love.update(dt)
    local isMoving = false

    if love.keyboard.isDown("s") then
        player.y = player.y + player.speed
        player.anim = player.animation.down
        isMoving = true
    end

    if love.keyboard.isDown("w") then
        player.y = player.y - player.speed
        player.anim = player.animation.up
        isMoving = true
    end
    
    if love.keyboard.isDown("a") then
        player.x = player.x - player.speed
        player.anim = player.animation.left
        isMoving = true
    end

    if love.keyboard.isDown("d") then
        player.x = player.x + player.speed
        player.anim = player.animation.right
        isMoving = true
    end

    if isMoving == false then
        player.anim:gotoFrame(1)
    end

    player.anim:update(dt)

    cam:lookAt(player.x, player.y)

    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    if cam.x < w/2 then
        cam.x = w/2
    end

    if cam.y < h/2 then
        cam.y = h/2
    end

    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Grass"])
        gameMap:drawLayer(gameMap.layers["Path"])
        gameMap:drawLayer(gameMap.layers["Trees2"])
        gameMap:drawLayer(gameMap.layers["Trees"])
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, 6, nil, 8, 8)
    cam:detach()

    if menu == true then
        local ww = love.graphics.getWidth()
        local wh = love.graphics.getHeight()

        local BUTTON_WIDTH = ww * (1/3)
        local margin = 16

        local total_height = (BUTTON_HEIGHT + margin) * #buttons
        local cursor_y = 0

        for i, button in ipairs(buttons) do
            button.last = button.now

            local bx = (ww * 0.5) - (BUTTON_WIDTH * 0.5)
            local by = (wh * 0.5) - (total_height * 0.5) + cursor_y

            local menuColor = {0.4, 0.4, 0.5, 1}

            local mx, my = love.mouse.getPosition()

            local hot = mx > bx and mx < bx + BUTTON_WIDTH and
                        my > by and my < by + BUTTON_HEIGHT

            if hot then
                menuColor =  {0.8, 0.8, 0.9, 1}
            end

            button.now = love.mouse.isDown(1)
            if button.now and not button.last and hot then
                button.fn()
            end

            love.graphics.setColor(unpack (menuColor))
            love.graphics.rectangle(
                "fill",
                bx,
                by,
                BUTTON_WIDTH,
                BUTTON_HEIGHT
            )

            love.graphics.setColor(0, 0, 0, 1)

            local textW = font:getWidth(button.text)
            local textH = font:getHeight(button.text)
            love.graphics.print(
                button.text,
                font,
                (ww * 0.5) - textW * 0.5,
                by + textH * 0.5
            )

            cursor_y = cursor_y + (BUTTON_HEIGHT + margin)
        end
    end
end