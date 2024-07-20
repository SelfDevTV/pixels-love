local Pixel = require "gameobjects.pixel"
local Color = require "gameobjects.color"

---Creates pixels out of an image
---@param imageData table
---@param pixelSize number
---@return table
local function createPixelsFromImage(imageData, pixelSize)
    local pixels = {}
    local w = math.floor(imageData:getWidth() / pixelSize)
    local h = math.floor(imageData:getHeight() / pixelSize)
    for x = 0, w - 1 do
        local row = {}
        for y = 0, h - 1 do
            local r, g, b = imageData:getPixel(x * pixelSize, y * pixelSize)
            local pixel = Pixel(x, y, Color(1, 1, 1))
            pixel.correctColor = Color(r, g, b)
            table.insert(row, pixel)
        end
        table.insert(pixels, row)
    end
    return pixels
end

return createPixelsFromImage
