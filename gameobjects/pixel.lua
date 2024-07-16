---@class Pixel
---@field x number
---@field y number
---@field color Color
---@field correctColor Color

local pixel = Class {
    init = function(self, x, y, color)
        self.x = x
        self.y = y
        ---@type Color
        self.color = color
        ---@type Color
        self.correctColor = nil
    end
}


return pixel
