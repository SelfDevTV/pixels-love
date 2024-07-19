local getPaletteFromPixels = require "utils.getPaletteFromPixels"
local indexOf              = require "utils.indexOf"
local luminance            = require "utils.luminance"

if arg[2] == "debug" then
    require("lldebugger").start()
end

require("globals")

local PalettePanel = require "ui.palettePanel"

local Color        = require("gameobjects.color")
local Pixel        = require("gameobjects.pixel")
local Controls     = require("controls")

local imageData
local image

local pixelCanvas
local pixelBorderCanvas
local textCanvas


local pixels              = {}
local pixelsChanged       = {}

local currentDrawingColor = Color(1, 0, 0)

local palettePanel

local pixelSize           = 20
local pixelScale          = 2

local fpsFont             = love.graphics.newFont(12)
local myFont              = love.graphics.newFont("assets/fonts/joystix monospace.otf", pixelSize - 4)

local prevMousePosX       = 0
local prevMousePosY       = 0


local tempNum = 1


local camera
local controls

local palette

-- Creates pixels from an image by dividing it into smaller pixel-sized sections
local function createPixelsFromImage()
    local w = math.floor(imageData:getWidth() / pixelSize)
    local h = math.floor(imageData:getHeight() / pixelSize)
    for x = 0, w - 1 do
        local row = {}
        for y = 0, h - 1 do
            local r, g, b = imageData:getPixel(x * pixelSize, y * pixelSize)
            local pixel = Pixel(x + 0.5, y + 0.5, Color(1, 1, 1))
            pixel.correctColor = Color(r, g, b)
            table.insert(row, pixel)
        end
        table.insert(pixels, row)
    end
end

-- Draws the initial pixel canvas based on the provided pixel data.
-- @param pixels The table containing the pixel data.
local function drawInitialPixelCanvas(pixels)
    love.graphics.setCanvas(pixelCanvas)

    for x, row in ipairs(pixels) do
        for y, p in ipairs(row) do
            love.graphics.setColor(p.color.r, p.color.g, p.color.b)
            love.graphics.points(p.x, p.y)
        end
    end
    love.graphics.setCanvas()
end

-- Draws pixels on a canvas.
-- @param p The table of pixels to draw.
local function drawPixelsOnCanvas(pixels)
    -- print(Inspect(p))
    love.graphics.setCanvas(pixelCanvas)
    for i, p in ipairs(pixels) do
        love.graphics.setColor(p.color.r, p.color.g, p.color.b)
        love.graphics.points(p.x, p.y)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()
end

local function drawInitialPixelBorderOnCanvas(pixels)
    love.graphics.setCanvas(pixelBorderCanvas)

    for x, row in ipairs(pixels) do
        for y, p in ipairs(row) do
            if not p.drawnCorrectly then
                love.graphics.setColor(0, 0, 0)
                love.graphics.rectangle("line", (p.x - 0.5) * pixelSize, (p.y - 0.5) * pixelSize, pixelSize, pixelSize)
            end
        end
    end
    love.graphics.setCanvas()
end

local function drawPixelBorderOnCanvas(pixels)
    love.graphics.setCanvas(pixelBorderCanvas)
    for i, p in ipairs(pixels) do
        if not p.drawnCorrectly then
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("line", (p.x - 0.5) * pixelSize, (p.y - 0.5) * pixelSize, pixelSize, pixelSize)
        else
            love.graphics.setScissor((p.x - 0.5) * pixelSize, (p.y - 0.5) * pixelSize, pixelSize, pixelSize)
            love.graphics.clear()
            love.graphics.setScissor()
        end
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()
end

local function drawInitialTextOnCanvas(pixels)
    love.graphics.setCanvas(textCanvas)
    love.graphics.clear()
    for x, row in ipairs(pixels) do
        for y, pixel in ipairs(row) do
            local myindex = indexOf(palette, pixel.correctColor)
            print(myindex)
            local luminance = luminance(pixel.color.r, pixel.color.g, pixel.color.b)

            if luminance > 0.5 then
                love.graphics.setColor(0, 0, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end

            if not pixel.drawnCorrectly then
                love.graphics.printf(tostring(myindex), myFont, (pixel.x - 0.5) * pixelSize,
                    (pixel.y - 0.5) * pixelSize, pixelSize,
                    "center")
            end
            -- love.graphics.print(tostring(myindex), x * pixelSize, y * pixelSize)
        end
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()
end

local function drawTextOnCanvas(pixels)
    love.graphics.setCanvas(textCanvas)

    for i, pixel in ipairs(pixels) do
        -- get luminance of pixel
        love.graphics.setScissor((pixel.x - 0.5) * pixelSize, (pixel.y - 0.5) * pixelSize, pixelSize, pixelSize)
        love.graphics.clear()
        local myindex = indexOf(palette, pixel.correctColor)
        local luminance = luminance(pixel.color.r, pixel.color.g, pixel.color.b)

        if luminance > 0.5 then
            love.graphics.setColor(0, 0, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end

        if not pixel.drawnCorrectly then
            love.graphics.printf(tostring(myindex), myFont, (pixel.x - 0.5) * pixelSize,
                (pixel.y - 0.5) * pixelSize, pixelSize,
                "center")
        end
        love.graphics.setScissor()
        -- love.graphics.print(tostring(myindex), x * pixelSize, y * pixelSize)
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
        -- +1 to to account for 0 based indexing to 1 based indexing
        local pixel = pixels[x0 + 1][y0 + 1]
        pixel:setColor(currentDrawingColor)

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
    camera:lookAt(imageData:getWidth() / 2, imageData:getHeight() / 2)
    -- camera:lookAt(imageData:getWidth() / 8, imageData:getHeight() / 8)
    camera:zoomTo(.8)

    controls = Controls(camera)

    pixelCanvas = love.graphics.newCanvas(imageData:getWidth(), imageData:getHeight())
    textCanvas = love.graphics.newCanvas(imageData:getWidth(), imageData:getHeight())
    pixelBorderCanvas = love.graphics.newCanvas(imageData:getWidth(), imageData:getHeight())

    pixelCanvas:setFilter("nearest", "nearest")
    textCanvas:setFilter("nearest", "nearest")
    createPixelsFromImage()
    palette = getPaletteFromPixels(pixels)
    palettePanel = PalettePanel(50, palette)
    Signal.register("colorSelected", function(color)
        currentDrawingColor = color
    end)
    currentDrawingColor = palette[1]

    drawInitialTextOnCanvas(pixels)
    tempNum = tempNum + 1
    drawInitialPixelCanvas(pixels)
    drawInitialPixelBorderOnCanvas(pixels)
end

function love.update(dt)
    Flux.update(dt)
    controls:update(dt)
    palettePanel:update(dt)
    if love.mouse.isDown(1) then
        local x, y = camera:worldCoords(love.mouse.getPosition())
        local localX = math.floor(x / pixelSize)
        local localY = math.floor(y / pixelSize)

        if localX < 0 or localX > #pixels - 1 or localY < 0 or localY > #pixels[1] - 1 then
            return
        end

        -- local pixel = pixels[localX + 2][localY + 2]
        -- pixel.color = Color(1, 0, 0)
        -- table.insert(pixelsChanged, pixel)
        local localPrevMouseX = math.floor(prevMousePosX / pixelSize)
        local localPrevMouseY = math.floor(prevMousePosY / pixelSize)
        plotLine(localPrevMouseX, localPrevMouseY, localX, localY)




        prevMousePosX, prevMousePosY = camera:worldCoords(love.mouse.getPosition())
    else
        local x, y = camera:worldCoords(love.mouse.getPosition())
        local localX = math.floor(x / pixelSize)
        local localY = math.floor(y / pixelSize)
        if localX < 0 or localX > #pixels - 2 or localY < 0 or localY > #pixels[1] - 2 then
            return
        end
        prevMousePosX, prevMousePosY = camera:worldCoords(love.mouse.getPosition())
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    if #pixelsChanged > 0 then
        drawPixelsOnCanvas(pixelsChanged)
        drawPixelBorderOnCanvas(pixelsChanged)
        drawTextOnCanvas(pixelsChanged)
        pixelsChanged = {}
    end
    camera:attach()
    love.graphics.draw(pixelCanvas, 0, 0, 0, pixelSize, pixelSize)
    love.graphics.draw(pixelBorderCanvas, 0, 0)
    love.graphics.draw(textCanvas, 0, 0)
    camera:detach()
    palettePanel:draw()

    -- draw fps counter top left
    love.graphics.setFont(fpsFont)
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end

function love.keypressed(key)
    palettePanel:keypressed(key)
    controls:keyPressed(key)
end

function love.mousepressed(x, y, button)
    palettePanel:mousepressed(x, y, button)
end

function love.keyreleased(key)
    controls:keyReleased(key)
end

-- function that moves the camera by drag and middle mouse button click
function love.mousemoved(x, y, dx, dy, istouch)
    controls:mouseMoved(x, y, dx, dy, istouch)
end

-- function that zooms the camera by scrolling
function love.wheelmoved(x, y)
    controls:wheelMoved(x, y)
end

local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end
