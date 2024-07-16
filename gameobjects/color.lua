---@class Color
---@field r number
---@field g number
---@field b number
---@field euclideanDistance fun(self:Color, other:Color):number
local color = Class {
    init = function(self, r, g, b)
        self.r = r
        self.g = g
        self.b = b
    end
}

---Distance to other color
---@param other Color
function color:euclideanDistance(other)
    local sum = 0

    sum = sum + math.pow(other.r - self.r, 2)
    sum = sum + math.pow(other.g - self.g, 2)
    sum = sum + math.pow(other.b - self.b, 2)
    return math.sqrt(sum)
end

local colorMetaTable = {
    __eq = function(a, b)
        return a.r == b.r and a.g == b.g and a.b == b.b
    end,
    __tostring = function(self)
        return string.format("Color: %.1f, %.1f, %.1f", self.r, self.g, self.b)
    end
}

color.__eq = colorMetaTable.__eq
color.__tostring = colorMetaTable.__tostring

return color
