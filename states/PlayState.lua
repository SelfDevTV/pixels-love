local Drawing = require("gameobjects.drawing")
local Controls = require("controls")

local PlayState = {

    drawing = {},
    controls = {}
}


function PlayState:enter(prev, camera)
    self.drawing = Drawing(camera, "assets/sprites/Man.png")
    self.controls = Controls(camera)

    love.graphics.setBackgroundColor(1, 0, 0)
end

function PlayState:keypressed(key)
    self.controls:keyPressed(key)
    self.drawing:keypressed(key)
    if key == "escape" then
        Gamestate.switch(GameStates.MainMenuState)
    end
end

function PlayState:update(dt)
    self.controls:update(dt)
    self.drawing:update(dt)
end

function PlayState:mousepressed(x, y, button)
    self.drawing:mousepressed(x, y, button)
end

function PlayState:mousemoved(x, y, dx, dy, istouch)
    self.controls:mouseMoved(x, y, dx, dy, istouch)
end

function PlayState:keyreleased(key)
    self.controls:keyReleased(key)
end

function PlayState:wheelmoved(x, y)
    self.controls:wheelMoved(x, y)
end

function PlayState:draw()
    self.drawing:draw()
end

return PlayState
