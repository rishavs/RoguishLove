local Utils = require "src.utils"
Utils.foo()

------------------------------------------------
-- libs
------------------------------------------------
local Gamestate = require "libs/hump/gamestate"
-- local Utils = require "src.utils"
local UI = require "libs/thranduil/ui"
local Theme = require "libs/thranduil/TestTheme"

------------------------------------------------
-- Declarations
------------------------------------------------
local _state_MainLoader = {}
local _state_MainMenu = {}
local _state_Settings = {}
local _state_Game = {}

------------------------------------------------
-- Base functions
------------------------------------------------
function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(_state_MainLoader)

    UI.registerEvents()

end

function love.quit()

end

------------------------------------------------
-- State Definition: _state_MainLoader
------------------------------------------------

function _state_MainLoader:draw()
    love.graphics.print("State: _state_MainLoader", 10, 10)
    love.graphics.print("Press ENTER to goto next screen", 10, 30)
end

function _state_MainLoader:keyreleased(key)
    if key == 'return' then
        Gamestate.switch(_state_MainMenu)
    end
end

------------------------------------------------
-- State Definition: _state_MainMenu
------------------------------------------------

function _state_MainMenu:draw()
    love.graphics.print("State: _state_MainMenu", 10, 10)
    love.graphics.print("Press ENTER to goto next screen", 10, 30)
end

function _state_MainMenu:keyreleased(key)
    if key == 'return' then
        Gamestate.switch(_state_Settings)
    end
end


------------------------------------------------
-- State Definition: _state_Settings
------------------------------------------------
function _state_Settings:load()
    button = UI.Button(10, 10, 90, 90, {extensions = {Theme.Button}})
end

function _state_Settings:draw()
    love.graphics.print("State: _state_Settings", 10, 10)
    love.graphics.print("Press ENTER to goto next screen", 10, 30)

    button:draw()
end

function _state_Settings:update(dt)
    button:update(dt)
end

function _state_Settings:keyreleased(key)
    if key == 'return' then
        Gamestate.switch(_state_MainMenu)
    end
end
------------------------------------------------
-- State Definition: _state_Game
------------------------------------------------
function _state_Game:draw()
    love.graphics.print("State: _state_Game", 10, 10)
end

function _state_Game:keyreleased(key)
    if key == 'return' then
        Gamestate.switch(_state_MainMenu)
    end
end
------------------------------------------------
-- Custom functions
------------------------------------------------

------------------------------------------------
-- Utils. Toolbelt stuff needed to run this app
------------------------------------------------

------------------------------------------------
-- Debug. Stuff here gets removed after debugging is done
------------------------------------------------
