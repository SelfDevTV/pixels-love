if arg[2] == "debug" then
    require("lldebugger").start()
end

require("globals")


local playstate = require("states.PlayState")



local fpsFont = love.graphics.newFont(12)



local camera



function love.load()
    love.window.setMode(800, 800)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setBackgroundColor(0.5, 0.5, 0.5)
    camera = Camera(0, 0)
    Gamestate.switch(playstate, camera)
    Gamestate.registerEvents()
end

function love.update(dt)
    Flux.update(dt)
end

function love.resize()

end

function love.draw()
    love.graphics.setColor(1, 1, 1)


    -- draw fps counter top left
    love.graphics.setFont(fpsFont)
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end

function love.keypressed(key)
    if key == "f" then
        love.window.setFullscreen(not love.window.getFullscreen())
    end

    if key == "escape" then
        love.event.quit()
    end
end

local love_errorhandler = love.errorhandler

-- function love.errorhandler(msg)
--     if lldebugger then
--         error(msg, 2)
--     else
--         return love_errorhandler(msg)
--     end
-- end
