local Controls = Class {
    init = function(self, camera)
        self.keys = {}
        self.mouse = {}
        self.mouse.x = 0
        self.mouse.y = 0
        self.mouse.left = false
        self.mouse.right = false
        self.mouse.middle = false
        self.camera = camera
        self.moveSpeed = 600
    end
}


function Controls:update(dt)
    self.mouse.x, self.mouse.y = self.camera:worldCoords(love.mouse.getPosition())
    self.mouse.left = love.mouse.isDown(1)
    self.mouse.right = love.mouse.isDown(2)
    self.mouse.middle = love.mouse.isDown(3)

    if self.keys["w"] then
        self.camera:move(0, -self.moveSpeed * dt)
    end

    if self.keys["s"] then
        self.camera:move(0, self.moveSpeed * dt)
    end

    if self.keys["a"] then
        self.camera:move(-self.moveSpeed * dt, 0)
    end

    if self.keys["d"] then
        self.camera:move(self.moveSpeed * dt, 0)
    end
end

function Controls:keyPressed(key)
    self.keys[key] = true
end

function Controls:keyReleased(key)
    self.keys[key] = false
end

function Controls:isDown(key)
    return self.keys[key]
end

function Controls:isMouseButtonDown(button)
    if button == "left" then
        return self.mouse.left
    elseif button == "right" then
        return self.mouse.right
    elseif button == "middle" then
        return self.mouse.middle
    end
end

function Controls:getMousePosition()
    return self.mouse.x, self.mouse.y
end

function Controls:mouseMoved(x, y, dx, dy, istouch)
    if self:isMouseButtonDown("middle") then
        self.camera:move(-dx, -dy)
    end
end

function Controls:wheelMoved(x, y)
    self.camera:zoom(1 + y * 0.1)
end

return Controls
