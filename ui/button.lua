local Button = Class {
    init = function(self, x, y, w, h, text, onClick, fillColor, borderColor, font)
        self.x = x
        self.y = y
        self.w = w
        self.h = h
        self.text = text
        self.onClick = onClick
        self.fillColor = fillColor
        self.borderColor = borderColor or { 0, 0, 0 }
        self.mousedown = false
        self.font = font or love.graphics.getFont()
        self.hoverColor = self.borderColor
        self.buttonColor = self.fillColor or { 0.6, 0.6, 0.6 }
        self.tweenGroup = Flux.group()
        self.time = 0
    end
}

---
-- Clamps a value to a certain range.
-- @param min - The minimum value.
-- @param val - The value to clamp.
-- @param max - The maximum value.
--
local function clamp(val, min, max)
    return math.max(min, math.min(val, max));
end

local function lerp(a, b, t) return (1 - t) * a + t * b end

function Button:isHovering()
    local mx, my = love.mouse.getPosition()
    self.hover = mx > self.x and mx < self.x + self.w and my > self.y and my < self.y + self.h
end

function Button:update(dt)
    self:isHovering()
    local animationDuration = 0.1
    local animationSpeed = 1 / animationDuration
    if self.hover then
        self.time = clamp(self.time + animationSpeed * dt, 0, 1)
    else
        self.time = clamp(self.time - animationSpeed * dt, 0, 1)
    end
    local r = lerp(self.fillColor[1], self.hoverColor[1], self.time)
    local g = lerp(self.fillColor[2], self.hoverColor[2], self.time)
    local b = lerp(self.fillColor[3], self.hoverColor[3], self.time)
    self.buttonColor = { r, g, b }
end

function Button:draw()
    local y = self.y

    love.graphics.setColor(self.buttonColor)


    love.graphics.rectangle("fill", self.x, y, self.w, self.h, 12)
    love.graphics.setColor(self.borderColor)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", self.x, y, self.w, self.h, 12)
    love.graphics.setColor(0.15, 0.15, 0.15, 1)
    love.graphics.printf(self.text, self.font, self.x, y + self.h / 2 - self.font:getHeight() / 2, self.w,
        "center")
end

function Button:mousepressed(x, y, button)
    if button == 1 and self.hover then
        if not self.isAnimating then
            self.isAnimating = true
            self.onClick()
            Flux.to(self, 0.1, { y = self.y + 5 }):after(self, 0.1, { y = self.y }):oncomplete(function() self.isAnimating = false end)
        end
    end
end

return Button
