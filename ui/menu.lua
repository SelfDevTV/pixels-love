local Button = require("ui.button")
local PlayState = require("states.PlayState")

local Menu = Class {
    init = function(self, x, y, w, h)
        self.buttons = {}
        self.x = x
        self.y = y
        self.width = w
        self.height = h
        self:createButtons()
    end

}

function Menu:createButtons()
    self.buttons = {
        Button(100, 100, 200, 50, "Play", function()
                Gamestate.switch(PlayState)
            end, { 1, 1, 1, 1 },
            { 1, .5, 0 }, Fonts.pixel),
        Button(100, 100, 200, 50, "About", function()
                Gamestate.switch(PlayState)
            end, { 1, 1, 1, 1 },
            { 1, .5, .5 }, Fonts.pixel),

        Button(100, 170, 200, 50, "Quit", function()
                love.event.quit(0)
            end, { 1, 1, 1, 1 },
            { 1, 0, .5 }, Fonts.pixel)
    }
end

function Menu:update(dt)
    for index, btn in ipairs(self.buttons) do
        btn.x = self.x + 100
        btn.y = self.y + 70 * index
        btn:update(dt)
    end
end

function Menu:draw()
    love.graphics.setColor(0.15, 0.15, 0.15, 1)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, 12)
    for index, btn in ipairs(self.buttons) do
        btn:draw()
    end
end

function Menu:mousepressed(x, y, button)
    for index, btn in ipairs(self.buttons) do
        btn:mousepressed(x, y, button)
    end
end

return Menu
