Class = require "libs.class"
Timer = require "libs.timer"
Flux = require "libs.flux"
Gamestate = require "libs.gamestate"
Inspect = require "libs.inspect"

-- Game States
require "states.init"

-- Fonts
Fonts = {
    pixel = love.graphics.newFont("assets/fonts/joystix monospace.otf", 20)
}
