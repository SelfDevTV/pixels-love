local createPixelsFromImage = require "utils.createPixelsFromImage"
local Color                 = require "gameobjects.color"
local plotLine              = require "utils.plotLine"
local getPaletteFromPixels  = require "utils.getPaletteFromPixels"
local PalettePanel          = require "ui.palettePanel"
local indexOf               = require "utils.indexOf"
local luminance             = require "utils.luminance"
local Drawing               = Class {
    init = function(self, camera, imageSrc)
        self.pixelScale      = 2
        self.pixelSize       = 25
        self.myFont          = love.graphics.newFont("assets/fonts/joystix monospace.otf", self.pixelSize + 2)
        self.pixelScaledSize = self.pixelSize * self.pixelScale
        self.imageData       = love.image.newImageData(imageSrc)
        self.pixelsChanged   = {}
        self.camera          = camera
        self.camera:lookAt(self.imageData:getWidth() / 2, self.imageData:getHeight() / 2)
        self.prevMousePosX       = 0
        self.prevMousePosY       = 0
        self.currentDrawingColor = Color(1, 0, 0)
        Signal.register("colorSelected", function(color)
            self.currentDrawingColor = color
        end)
        self.pixelCanvas = love.graphics.newCanvas(self.imageData:getWidth() * self.pixelScale,
            self.imageData:getHeight() * self.pixelScale)
        self.textCanvas = love.graphics.newCanvas(self.imageData:getWidth() * self.pixelScale,
            self.imageData:getHeight() * self.pixelScale)
        self.pixelBorderCanvas = love.graphics.newCanvas(self.imageData:getWidth() * self.pixelScale,
            self.imageData:getHeight() * self.pixelScale)

        self.pixels = createPixelsFromImage(self.imageData, self.pixelSize)

        self.palette = getPaletteFromPixels(self.pixels)
        self.palettePanel = PalettePanel(50, self.palette)

        self:drawInitialPixelCanvas()
        self:drawBorderOnCanvas(self.pixels)
        self:drawInitialTextOnCanvas(self.pixels)
    end
}

function Drawing:update(dt)
    self:updateDrawing()
end

function Drawing:draw()
    love.graphics.setColor(1, 1, 1)
    if #self.pixelsChanged > 0 then
        self:drawPixelsOnCanvas(self.pixelsChanged)
        self:drawBorderOnCanvas(self.pixels)
        self:drawTextOnCanvas(self.pixelsChanged)
        self.pixelsChanged = {}
    end
    self.camera:attach()
    love.graphics.draw(self.pixelCanvas, 0, 0)
    love.graphics.draw(self.pixelBorderCanvas, 0, 0)
    love.graphics.draw(self.textCanvas, 0, 0)
    self.camera:detach()
    self.palettePanel:draw()
end

-- **PIXELS**
function Drawing:drawInitialPixelCanvas()
    love.graphics.setCanvas(self.pixelCanvas)

    for x, row in ipairs(self.pixels) do
        for y, p in ipairs(row) do
            love.graphics.setColor(p.color.r, p.color.g, p.color.b)
            -- love.graphics.setColor(p.correctColor.r, p.correctColor.g, p.correctColor.b)
            -- love.graphics.points(p.x * pixelScaledSize, p.y * pixelScaledSize)
            love.graphics.rectangle("fill", (p.x) * self.pixelScaledSize, (p.y) * self.pixelScaledSize,
                self.pixelScaledSize,
                self.pixelScaledSize)
        end
    end
    love.graphics.setCanvas()
end

function Drawing:drawPixelsOnCanvas(lastPixels)
    love.graphics.setCanvas(self.pixelCanvas)
    for i, p in ipairs(lastPixels) do
        love.graphics.setColor(p.color.r, p.color.g, p.color.b)
        love.graphics.rectangle("fill", (p.x) * self.pixelScaledSize, (p.y) * self.pixelScaledSize,
            self.pixelScaledSize,
            self.pixelScaledSize)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()
end

-- **PIXEL BORDER**

function Drawing:drawBorderOnCanvas(allPixels)
    love.graphics.setCanvas(self.pixelBorderCanvas)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setLineWidth(2)
    love.graphics.setLineStyle("rough")
    love.graphics.clear()

    for x, row in ipairs(allPixels) do
        for y, p in ipairs(row) do
            if not p.drawnCorrectly then
                love.graphics.rectangle("line", (p.x) * self.pixelScaledSize, (p.y) * self.pixelScaledSize,
                    self.pixelScaledSize, self.pixelScaledSize)
            end
        end
    end
    love.graphics.setColor(1, 1, 1)

    love.graphics.setCanvas()
end

-- **TEXT**

function Drawing:drawInitialTextOnCanvas(allPixels)
    love.graphics.setCanvas(self.textCanvas)
    love.graphics.clear()
    for x, row in ipairs(allPixels) do
        for y, pixel in ipairs(row) do
            local myindex = indexOf(self.palette, pixel.correctColor)
            local luminance = luminance(pixel.color.r, pixel.color.g, pixel.color.b)

            if luminance > 0.5 then
                love.graphics.setColor(0, 0, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end

            if not pixel.drawnCorrectly then
                love.graphics.printf(tostring(myindex), self.myFont, (pixel.x) * self.pixelScaledSize,
                    (pixel.y) * self.pixelScaledSize, self.pixelScaledSize,
                    "center")
            end
            -- love.graphics.print(tostring(myindex), x * pixelSize, y * pixelSize)
        end
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()
end

function Drawing:drawTextOnCanvas(lastPixels)
    love.graphics.setCanvas(self.textCanvas)

    for i, pixel in ipairs(lastPixels) do
        -- get luminance of pixel
        love.graphics.setScissor((pixel.x) * self.pixelScaledSize, (pixel.y) * self.pixelScaledSize, self
            .pixelScaledSize,
            self.pixelScaledSize)
        love.graphics.clear()
        local myindex = indexOf(self.palette, pixel.correctColor)
        local luminance = luminance(pixel.color.r, pixel.color.g, pixel.color.b)

        if luminance > 0.5 then
            love.graphics.setColor(0, 0, 0)
        else
            love.graphics.setColor(1, 1, 1)
        end

        if not pixel.drawnCorrectly then
            love.graphics.printf(tostring(myindex), self.myFont, (pixel.x) * self.pixelScaledSize,
                (pixel.y) * self.pixelScaledSize, self.pixelScaledSize,
                "center")
        end
        love.graphics.setScissor()
        -- love.graphics.print(tostring(myindex), x * pixelSize, y * pixelSize)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setCanvas()
end

function Drawing:updateDrawing()
    if love.mouse.isDown(1) then
        local x, y = self.camera:worldCoords(love.mouse.getPosition())
        local localX = math.floor(x / self.pixelScaledSize)
        local localY = math.floor(y / self.pixelScaledSize)

        if localX < 0 or localX > #self.pixels - 1 or localY < 0 or localY > #self.pixels[1] - 1 then
            return
        end

        -- local pixel = pixels[localX + 2][localY + 2]
        -- pixel.color = Color(1, 0, 0)
        -- table.insert(pixelsChanged, pixel)
        local localPrevMouseX = math.floor(self.prevMousePosX / self.pixelScaledSize)
        local localPrevMouseY = math.floor(self.prevMousePosY / self.pixelScaledSize)
        self.pixelsChanged = plotLine(localPrevMouseX, localPrevMouseY, localX, localY, self.pixels,
            self.currentDrawingColor)




        self.prevMousePosX, self.prevMousePosY = self.camera:worldCoords(love.mouse.getPosition())
    else
        local x, y = self.camera:worldCoords(love.mouse.getPosition())
        local localX = math.floor(x / self.pixelScaledSize)
        local localY = math.floor(y / self.pixelScaledSize)
        if localX < 0 or localX > #self.pixels - 2 or localY < 0 or localY > #self.pixels[1] - 2 then
            return
        end
        self.prevMousePosX, self.prevMousePosY = self.camera:worldCoords(love.mouse.getPosition())
    end
end

function Drawing:mousepressed(x, y, button)
    self.palettePanel:mousepressed(x, y, button)
end

function Drawing:keypressed(key)
    self.palettePanel:keypressed(key)
end

function Drawing:resize()
    self.palettePanel.y = love.graphics.getHeight() - self.palettePanel.h
end

return Drawing
