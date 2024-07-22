local MainMenuState = {
    old = {}
}

local Menu = require("ui.menu")

local menu

function MainMenuState:enter(old)
    self.old = old

    local w, h = love.graphics.getDimensions()

    menu = Menu(w / 2 - 400 / 2, 50, 400, 500, oldState)
end

function MainMenuState:update(dt)
    menu:update(dt)
end

function MainMenuState:keypressed(key)
    if key == "escape" then
        Gamestate.switch(self.old)
    end
end

function MainMenuState:mousepressed(x, y, button)
    menu:mousepressed(x, y, button)
end

function MainMenuState:draw()
    if self.old.draw then
        self.old:draw()
    end
    menu:draw()
end

return MainMenuState
