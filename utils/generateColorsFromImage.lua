local pixel = require "gameobjects.pixel"
local color = require "gameobjects.color"


---Returns a 2d array of all pixels in the image
---@param imageData table
---@param pixelSize number
---@param totalColors number
---@return table
local function generateColorsFromImage(imageData, pixelSize, pixelScale, totalColors)
    local colors = {}
    local pixelSize = pixelSize or 10
    local totalColors = totalColors or 10

    local w = math.floor(imageData:getWidth() / pixelSize)
    local h = math.floor(imageData:getHeight() / pixelSize)

    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local r, g, b = imageData:getPixel(x * pixelSize, y * pixelSize)
            table.insert(colors, { r, g, b })
        end
    end

    return colors
end


return generateColorsFromImage
