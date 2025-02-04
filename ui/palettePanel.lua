local luminance = require "utils.luminance"
local PalettePanel = Class {
    init = function(self, h, colors)
        self.h = h
        self.y = love.graphics.getHeight() - self.h
        self.colors = colors
        self.selectedColor = 1
        Signal.emit("colorSelected", self.colors[self.selectedColor])

        self.selectedColorBorderX = 0
        self.selectedColorBorderY = 0
    end
}

function PalettePanel:mousepressed(x, y, button)
    if button == 1 then
        local w = love.graphics.getWidth()
        local colorWidth = w / #self.colors
        if y > self.y and y < self.y + self.h then
            for i = 1, #self.colors do
                if x > 0 + (i - 1) * colorWidth and x < 0 + i * colorWidth then
                    self.selectedColor = i
                    Signal.emit("colorSelected", self.colors[i])
                    self:animateColorChange()
                    break
                end
            end
        end
    end
end

function PalettePanel:animateColorChange()
    -- Flux.to(self, 0.1, { selectedColorBorderX = (self.selectedColor - 1) * (love.graphics.getWidth() / #self.colors) })
    --     :ease("backinout")


    self.selectedColorBorderX = (self.selectedColor - 1) * (love.graphics.getWidth() / #self.colors)
end

-- pressing the numbers keys on the keyboard will select the correct color
function PalettePanel:keypressed(key)
    if tonumber(key) and tonumber(key) > 0 and tonumber(key) <= #self.colors then
        self.selectedColor = tonumber(key)
        Signal.emit("colorSelected", self.colors[self.selectedColor])
        self:animateColorChange()
    end
end

function PalettePanel:draw()
    local x = 0

    local w = love.graphics.getWidth()
    local h = self.h

    local font = love.graphics.getFont()

    love.graphics.setColor(self.colors[self.selectedColor].r, self.colors[self.selectedColor].g,
        self.colors[self.selectedColor].b)
    love.graphics.rectangle("fill", x, self.y, w, h)

    local colorWidth = w / #self.colors
    for i, color in ipairs(self.colors) do
        local luminance = luminance(color.r, color.g, color.b)

        love.graphics.setColor(color.r, color.g, color.b)
        if i == self.selectedColor then
            love.graphics.rectangle("fill", x + (i - 1) * colorWidth, self.y - 10, colorWidth, h)
            if luminance > 0.5 then
                love.graphics.setColor(0, 0, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end

            love.graphics.printf(tostring(i), x + (i - 1) * colorWidth, self.y + self.h / 2 - font:getHeight() / 2 - 10,
                colorWidth, "center")
        else
            love.graphics.rectangle("fill", x + (i - 1) * colorWidth, self.y, colorWidth, h)
            if luminance > 0.5 then
                love.graphics.setColor(0, 0, 0)
            else
                love.graphics.setColor(1, 1, 1)
            end

            love.graphics.printf(tostring(i), x + (i - 1) * colorWidth, self.y + self.h / 2 - font:getHeight() / 2,
                colorWidth, "center")
        end
        -- draw the index of the color as text in the center
    end

    -- draw the border around the selected color
    local lum = luminance(self.colors[self.selectedColor].r, self.colors[self.selectedColor].g,
        self.colors[self.selectedColor].b)
    if lum > 0.5 then
        love.graphics.setColor(0, 0, 0)
    else
        love.graphics.setColor(1, 1, 0)
    end
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", self.selectedColorBorderX, self.y - 10, colorWidth, h + 10)
    love.graphics.setColor(1, 1, 1)
end

return PalettePanel
