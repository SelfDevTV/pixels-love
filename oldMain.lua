require("globals")

local color = require("gameobjects.color")

local PalettePanel = require("ui.palettePanel")

local generatePixelsFromImage = require("utils.generatePixelsFromImage")


local palettePanel
local pixels
local pixels2D
local palette

local c1 = color(1, 1, 1)
local c2 = color(1, 1, 1)

local image
local imgData
local newImgData

local prevMousePosX = 0
local prevMousePosY = 0

local canvas
local camera

local myfont
local fpsFont

local drawingColor

local pixelSize = 20
local pixelScale = 3

local numbersToDrawNext = {}

local inputDisabled = true

local zoom = 3

local function cameraShake()
    local orig_x, orig_y = camera:position()
    Timer.during(.1, function()
        print("shaking")
        camera:lookAt(orig_x + math.random(-.1, -1), orig_y + math.random(-.1, .1))
    end, function()
        -- reset camera position
        camera:lookAt(orig_x, orig_y)
    end)
end

local function indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

local function luminance(r, g, b)
    return 0.299 * r + 0.587 * g + 0.114 * b
end




local function renderTextToCanvas()
    canvas:renderTo(function()
        love.graphics.clear()
        for x, row in ipairs(pixels2D) do
            for y, pixel in ipairs(row) do
                -- get luminance of pixel
                local myindex = indexOf(palette, pixel.correctColor)
                local luminance = luminance(pixel.color.r, pixel.color.g, pixel.color.b)
                if luminance > 0.5 then
                    love.graphics.setColor(0, 0, 0)
                else
                    love.graphics.setColor(1, 1, 1)
                end

                if not pixel.drawnCorrectly then
                    love.graphics.printf(tostring(myindex), myfont, pixel.x * pixelSize * pixelScale,
                        pixel.y * pixelSize * pixelScale, pixelSize * pixelScale,
                        "center")
                end
                -- love.graphics.print(tostring(myindex), x * pixelSize, y * pixelSize)
            end
        end
        love.graphics.setColor(1, 1, 1)
    end)
end


function love.load()
    love.window.setMode(800, 800)
    myfont = love.graphics.newFont((pixelSize * pixelScale) / 1.2)
    fpsFont = love.graphics.newFont(8)
    love.graphics.setFont(myfont)
    camera = Camera(0, 0)
    imgData = love.image.newImageData("assets/sprites/person.jpg")
    canvas = love.graphics.newCanvas(imgData:getWidth() * pixelScale, imgData:getHeight() * pixelScale)
    canvas:setFilter("nearest", "nearest")

    pixels, pixels2D, palette = generatePixelsFromImage(imgData, pixelSize, pixelScale, 9)
    Signal.register("colorSelected", function(color)
        drawingColor = color
    end)
    palettePanel = PalettePanel(50, palette)
    print(love.graphics:getHeight())
    Flux.to(palettePanel, .5, { y = love.graphics:getHeight() - 50 })



    -- drawingColor = palette[2]

    -- create function that gets luminance of a color

    newImgData = love.image.newImageData(imgData:getWidth() * pixelScale, imgData:getHeight() * pixelScale)

    for index, pixel in ipairs(pixels) do
        for w = 0, pixelSize * pixelScale - 1 do
            for h = 0, pixelSize * pixelScale - 1 do
                newImgData:setPixel(pixel.x * pixelSize * pixelScale + w, pixel.y * pixelSize * pixelScale + h,
                    pixel.color.r, pixel.color.g,
                    pixel.color.b)
            end
        end
    end
    image = love.graphics.newImage(newImgData)
    -- make the filter on image nearest
    image:setFilter("nearest", "nearest")

    camera:lookAt(image:getWidth() / 2, image:getHeight() / 2)
    Flux.to(camera, 1, { scale = 0.4 }):ease("backout"):oncomplete(function()
        inputDisabled = false
    end)




    -- local r = bitser.register("pixels", pixels)




    love.graphics.setBackgroundColor(.9, .8, .9)

    -- bitser.dumpLoveFile("game.dat", r)


    -- Gamestate.registerEvents()
    -- Gamestate.switch(GameStates.PlayState)
end

local function plotText(x0, y0, x1, y1)
    local dx = math.abs(x1 - x0)
    local sx = x0 < x1 and 1 or -1
    local dy = -math.abs(y1 - y0)
    local sy = y0 < y1 and 1 or -1
    local err = dx + dy
    local e2
    while true do
        local pixel = pixels2D[x0 + 1][y0 + 1]
        pixel:setColor(drawingColor)
        table.insert(numbersToDrawNext, pixel)
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

local function plotLine(x0, y0, x1, y1)
    local dx = math.abs(x1 - x0)
    local sx = x0 < x1 and (pixelSize * pixelScale) or -(pixelSize * pixelScale)
    local dy = -math.abs(y1 - y0)
    local sy = y0 < y1 and (pixelSize * pixelScale) or -(pixelSize * pixelScale)
    local err = dx + dy
    local e2
    while true do
        newImgData:setPixel(x0, y0, drawingColor.r, drawingColor.g, drawingColor.b)
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
    Flux.update(dt)
    Timer.update(dt)

    palettePanel:update(dt)
    if inputDisabled then
        return
    end
    if love.keyboard.isDown("a") then
        camera:move(-300 * dt * pixelScale, 0)
    end
    if love.keyboard.isDown("d") then
        camera:move(300 * dt * pixelScale, 0)
    end
    if love.keyboard.isDown("w") then
        camera:move(0, -300 * dt * pixelScale)
    end
    if love.keyboard.isDown("s") then
        camera:move(0, 300 * dt * pixelScale)
    end
    local pixelTotalSize = pixelSize * pixelScale
    if love.mouse.isDown(1) then
        local x, y = camera:worldCoords(love.mouse.getPosition())
        local localX = math.floor(x / pixelTotalSize)
        local localY = math.floor(y / pixelTotalSize)
        if localX < 0 or localY < 0 or localX > #pixels2D - 1 or localY > #pixels2D[1] - 1 then
            return
        end
        -- cameraShake()
        local localPrevMouseX = math.floor(prevMousePosX / pixelTotalSize)
        local localPrevMouseY = math.floor(prevMousePosY / pixelTotalSize)

        local pixel = pixels2D[localPrevMouseX + 1][localPrevMouseY + 1]

        pixel:setColor(drawingColor)



        for i = 0, pixelSize * pixelScale - 1 do
            for j = 0, pixelSize * pixelScale - 1 do
                -- imgData:setPixel(localX * pixelSize + i, localY * pixelSize + j, 0, 0, 0)
                plotLine(localPrevMouseX * pixelSize * pixelScale + i, localPrevMouseY * pixelSize * pixelScale + j,
                    localX * pixelSize * pixelScale + i,
                    localY * pixelSize * pixelScale + j)
            end
        end

        plotText(localPrevMouseX, localPrevMouseY, localX, localY)

        -- renderTextAtPixel(pixel)

        prevMousePosX, prevMousePosY = camera:worldCoords(love.mouse.getPosition())
    else
        local x, y = camera:worldCoords(love.mouse.getPosition())
        local localX = math.floor(x / pixelTotalSize)
        local localY = math.floor(y / pixelTotalSize)

        if localX < 0 or localY < 0 or localX > #pixels2D - 1 or localY > #pixels2D[1] - 1 then
            return
        end

        prevMousePosX, prevMousePosY = camera:worldCoords(love.mouse.getPosition())
    end
end

-- mouse wheel will zoom in and out of the image
function love.wheelmoved(x, y)
    if y > 0 then
        camera:zoom(1.1)
    elseif y < 0 then
        camera:zoom(0.9)
    end
end

function love.draw()
    renderTextToCanvas()

    camera:attach()
    image:replacePixels(newImgData)
    love.graphics.draw(image, 0, 0)
    love.graphics.draw(canvas, 0, 0)
    camera:detach()
    palettePanel:draw()
    love.graphics.setColor(1, 0, 0)

    -- draw fps
    love.graphics.setFont(fpsFont)
    love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(myfont)
end

function love.keypressed(key)
    if inputDisabled then
        return
    end
    palettePanel:keypressed(key)
end

function love.mousepressed(x, y, btn)
    if inputDisabled then
        return
    end
    palettePanel:mousepressed(x, y, btn)

    -- shake the camera for one second
end

-- K-means algorithm
