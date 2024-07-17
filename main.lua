require("globals")
local bitser = require("libs.bitser")
local color = require("gameobjects.color")

local generatePixelsFromImage = require("utils.generatePixelsFromImage")




local pixels
local pixels2D
local palette

local c1 = color(1, 1, 1)
local c2 = color(1, 1, 1)

local image
local imgData

local prevMousePosX = 0
local prevMousePosY = 0

local canvas


local pixelSize = 10

function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

local function createText()
    local myfont = love.graphics.newFont(pixelSize - 2)


    canvas:renderTo(function()
        for y, row in ipairs(pixels2D) do
            for x, pixel in ipairs(row) do
                local myindex = indexOf(palette, pixel.color)
                love.graphics.setColor(0, 0, 0)

                local newX = x - 1
                local newY = y - 1

                local textWidth = myfont:getWidth(tostring(myindex))
                local textHeight = myfont:getHeight()



                if x == 0 then
                    print("hi")
                end

                -- now no number is beeing rendere???
                love.graphics.printf(tostring(myindex), myfont, newX * pixelSize, newY * pixelSize, pixelSize, "center")
                -- love.graphics.print(tostring(myindex), x * pixelSize, y * pixelSize)
            end
        end
        love.graphics.setColor(1, 1, 1)
    end)
end


function love.load()
    imgData = love.image.newImageData("assets/sprites/us.jpg")
    canvas = love.graphics.newCanvas(imgData:getWidth(), imgData:getHeight())

    pixels, pixels2D, palette = generatePixelsFromImage(imgData, pixelSize, 10)
    print(#pixels)

    for index, pixel in ipairs(pixels) do
        for w = 0, pixelSize - 1 do
            for h = 0, pixelSize - 1 do
                imgData:setPixel(pixel.x * pixelSize + w, pixel.y * pixelSize + h, pixel.color.r, pixel.color.g,
                    pixel.color.b)
            end
        end
    end
    image = love.graphics.newImage(imgData)
    love.window.setMode(image:getWidth() * 2, image:getHeight() * 1.5)


    -- local r = bitser.register("pixels", pixels)



    createText()

    -- bitser.dumpLoveFile("game.dat", r)


    Gamestate.registerEvents()
    Gamestate.switch(GameStates.PlayState)
end

local function plotLine(x0, y0, x1, y1)
    local dx = math.abs(x1 - x0)
    local sx = x0 < x1 and pixelSize or -pixelSize
    local dy = -math.abs(y1 - y0)
    local sy = y0 < y1 and pixelSize or -pixelSize
    local err = dx + dy
    local e2
    while true do
        imgData:setPixel(x0, y0, 0, 0, 0)

        if x0 == x1 and y0 == y1 then
            break
        end
        e2 = 2 * err
        if e2 >= dy then
            err = err + dy
            x0 = x0 + sx
        end
        if e2 <= dx then
            err = err + dx
            y0 = y0 + sy
        end
    end
end

function love.update(dt)
    if love.mouse.isDown(1) then
        local x, y = love.mouse.getPosition()
        local localX = math.floor(x / pixelSize)
        local localY = math.floor(y / pixelSize)
        if x < 0 or y < 0 or x > image:getWidth() or y > image:getHeight() then
            return
        end
        local localPrevMouseX = math.floor(prevMousePosX / pixelSize)
        local localPrevMouseY = math.floor(prevMousePosY / pixelSize)
        for i = 0, pixelSize - 1 do
            for j = 0, pixelSize - 1 do
                -- imgData:setPixel(localX * pixelSize + i, localY * pixelSize + j, 0, 0, 0)
                plotLine(localPrevMouseX * pixelSize + i, localPrevMouseY * pixelSize + j, localX * pixelSize + i,
                    localY * pixelSize + j)
            end
        end
        image:replacePixels(imgData)
        prevMousePosX, prevMousePosY = love.mouse.getPosition()
    else
        prevMousePosX, prevMousePosY = love.mouse.getPosition()
    end
end

function love.draw()
    love.graphics.draw(image, 0, 0)
    love.graphics.draw(canvas, 0, 0)
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1)
end

function love.mousepressed(x, y, button)

end

-- K-means algorithm
