local Utils = require "src.utils"
Utils.foo()

------------------------------------------------
-- libs
------------------------------------------------
local Gamestate = require "libs.hump.gamestate"
-- local Utils = require "src.utils"
local UI = require "libs.thranduil.ui"
local Theme = require "libs.thranduil.TestTheme"
-- local Uare = require "libs.uare"

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

function _state_MainMenu:init()
    -- _frame_MainMenu_Container = UI.Frame(0, 0, 100, 100, {extensions = {Theme.Frame}, draggable = true, drag_margin = 10, resizable = true, resize_margin = 5})
    _button_MainMenu_New = UI.Button(100, 100, 100, 40, {extensions = {Theme.Button}, text = "New"})
    _button_MainMenu_Save = UI.Button(100, 150, 100, 40, {extensions = {Theme.Button}, text = "Save"})
    _button_MainMenu_Load = UI.Button(100, 200, 100, 40, {extensions = {Theme.Button}, text = "Load"})
    _button_MainMenu_Settings = UI.Button(100, 250, 100, 40, {extensions = {Theme.Button}, text = "Settings"})
    _button_MainMenu_Quit = UI.Button(100, 300, 100, 40, {extensions = {Theme.Button}, text = "Quit"})
end

function _state_MainMenu:draw()
    love.graphics.print("State: _state_MainMenu", 10, 10)
    love.graphics.print("Press ENTER to goto next screen", 10, 30)
    
    _button_MainMenu_New:draw();
    _button_MainMenu_Save:draw();
    _button_MainMenu_Load:draw();
    _button_MainMenu_Settings:draw();
    _button_MainMenu_Quit:draw();
end

function _state_MainMenu:update(dt)
    _button_MainMenu_New:update(dt);
    if _button_MainMenu_New.released then print("New") end;
    _button_MainMenu_Save:update(dt);
    if _button_MainMenu_Save.released then print("Save") end;
    _button_MainMenu_Load:update(dt);
    if _button_MainMenu_Load.released then print("Load") end;
    _button_MainMenu_Settings:update(dt);
    if _button_MainMenu_Settings.released then print("Settings") end;
    _button_MainMenu_Quit:update(dt);
    if _button_MainMenu_Quit.released then print("Quit") end;
end


function _state_MainMenu:keyreleased(key)
    if key == 'return' then
        Gamestate.switch(_state_Settings)
    end
end


------------------------------------------------
-- State Definition: _state_Settings
------------------------------------------------
function _state_Settings:init()
    button = UI.Button(10, 100, 90, 20, {extensions = {Theme.Button}})
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
