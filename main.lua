require("globals")

local Color = require("gameobjects.color")
local Pixel = require("gameobjects.pixel")

local imageData
local image
local pixelCanvas
local textCanvas

local pixels = {}
local pixelsChanged = {}

local fpsFont = love.graphics.newFont(12)

local pixelSize = 10

local prevMousePosX = 0
local prevMousePosY = 0

local camera

local function createPixelsFromImage()
    local w = math.floor(imageData:getWidth() / pixelSize)
    local h = math.floor(imageData:getHeight() / pixelSize)
    for x = 0, w - 1 do
        local row = {}
        for y = 0, h - 1 do
            local r, g, b = imageData:getPixel(x * pixelSize, y * pixelSize)
            local pixel = Pixel(x, y, Color(r, g, b))
            table.insert(row, pixel)
        end
        table.insert(pixels, row)
    end
end

local function drawInitialPixelCanvas(pixels)
    love.graphics.setCanvas(pixelCanvas)

    for x, row in ipairs(pixels) do
        for y, p in ipairs(row) do
            if p.x == 0 and p.y == 0 then
                print("hi")
            end
            love.graphics.setColor(p.color.r, p.color.g, p.color.b)
            love.graphics.points(p.x, p.y)
        end
    end
    love.graphics.setCanvas()
end

local function drawPixelsOnCanvas(p)
    -- print(Inspect(p))
    love.graphics.setCanvas(pixelCanvas)
    for i, p in ipairs(p) do
        if p.x == 0 and p.y == 0 then
            print("hiho")
        end
        love.graphics.setColor(p.color.r, p.color.g, p.color.b)
        love.graphics.points(p.x, p.y)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()
end

local function plotLine(x0, y0, x1, y1)
    local dx = math.abs(x1 - x0)
    local sx = x0 < x1 and 1 or -1
    local dy = -math.abs(y1 - y0)
    local sy = y0 < y1 and 1 or -1
    local err = dx + dy
    local e2
    while true do
        local pixel = pixels[x0][y0]
        pixel.color = Color(1, 0, 0)
        table.insert(pixelsChanged, pixel)

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


function love.load()
    love.window.setMode(800, 800)
    love.graphics.setBackgroundColor(0.5, 0.5, 0.5)



    imageData = love.image.newImageData("assets/sprites/Man.png")
    camera = Camera(0, 0)
    -- camera:lookAt(imageData:getWidth() / 2, imageData:getHeight() / 2)
    camera:zoomTo(1)

    pixelCanvas = love.graphics.newCanvas(imageData:getWidth(), imageData:getHeight())
    textCanvas = love.graphics.newCanvas(imageData:getWidth(), imageData:getHeight())
    pixelCanvas:setFilter("nearest", "nearest")
    textCanvas:setFilter("nearest", "nearest")
    createPixelsFromImage()
    drawInitialPixelCanvas(pixels)
end

function love.update()
    if love.mouse.isDown(1) then
        local x, y = camera:worldCoords(love.mouse.getPosition())
        local localX = math.floor(x / pixelSize)
        local localY = math.floor(y / pixelSize)

        -- local pixel = pixels[localX + 2][localY + 2]
        -- pixel.color = Color(1, 0, 0)
        -- table.insert(pixelsChanged, pixel)
        local localPrevMouseX = math.floor(prevMousePosX / pixelSize)
        local localPrevMouseY = math.floor(prevMousePosY / pixelSize)
        plotLine(localPrevMouseX, localPrevMouseY, localX, localY)


        prevMousePosX, prevMousePosY = camera:worldCoords(love.mouse.getPosition())
    else
        prevMousePosX, prevMousePosY = camera:worldCoords(love.mouse.getPosition())
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    if #pixelsChanged > 0 then
        drawPixelsOnCanvas(pixelsChanged)
        pixelsChanged = {}
    end
    camera:attach()
    love.graphics.draw(pixelCanvas, 0, 0, 0, pixelSize, pixelSize)

    camera:detach()

    -- draw fps counter top left
    love.graphics.setFont(fpsFont)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end
