local Drawing = require("gameobjects.drawing")
local Controls = require("controls")

local PlayState = {

    drawing = {},
    controls = {}
}


function PlayState:enter(camera)
    self.drawing = Drawing(camera, "assets/sprites/Man.png")
    self.controls = Controls(camera)

    love.graphics.setBackgroundColor(1, 0, 0)
end

function PlayState:keypressed(key)
    if key == "escape" then
        Gamestate.switch(GameStates.MainMenuState)
    end
end

function PlayState:update(dt)
    self.controls:update(dt)
    self.drawing:update(dt)
end

function PlayState:mousepressed(x, y, button)

end

function PlayState:draw()
    self.drawing:draw()
end

return PlayState
