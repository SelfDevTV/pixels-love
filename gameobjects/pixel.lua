---@class Pixel
---@field x number
---@field y number
---@field color Color
---@field correctColor Color

local Pixel = Class {
    init = function(self, x, y, color)
        self.x = x
        self.y = y
        ---@type Color
        self.color = color
        ---@type Color
        self.correctColor = nil
        self.drawnCorrectly = false
    end
}


function Pixel:setColor(color)
    self.color = color
    if self.color == self.correctColor then
        self.drawnCorrectly = true
    else
        self.drawnCorrectly = false
    end
end

return Pixel
