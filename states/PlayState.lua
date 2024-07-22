local Drawing = require("gameobjects.drawing")
local Controls = require("controls")

local PlayState = {

    drawing = {},
    controls = {},
    updateDisabled = true,
    drawDisabled = true,
    camera = Camera(0, 0)
}


function PlayState:enter()
    self.drawing = Drawing(self.camera, "assets/sprites/pixel_art_america.jpg")
    self.controls = Controls(self.camera)

    love.graphics.setBackgroundColor(1, 0, 0)
    self.updateDisabled = false
    self.drawDisabled = false
end

function PlayState:keypressed(key)
    if key == "f1" then
        Gamestate.switch(GameStates.MainMenuState, self.drawing)
    end
    self.controls:keyPressed(key)
    self.drawing:keypressed(key)
    if key == "escape" then
        Gamestate.switch(GameStates.MainMenuState)
    end
end

function PlayState:update(dt)
    if self.updateDisabled then
        return
    end
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
    if self.drawDisabled then
        return
    end
    self.drawing:draw()
end

function PlayState:resize()
    self.drawing:resize()
end

return PlayState
