local PlayState = {

}


function PlayState:enter()
    love.graphics.setBackgroundColor(1, 0, 0)
end

function PlayState:keypressed(key)
    if key == "escape" then
        Gamestate.switch(GameStates.MainMenuState)
    end
end

function PlayState:update(dt)

end

function PlayState:mousepressed(x, y, button)

end

function PlayState:draw()

end

return PlayState
