
------------------------------------------------
-- libs
------------------------------------------------
Gamestate = require "libs.hump.gamestate"
UI = require "libs.thranduil.ui"
Theme = require "libs.thranduil.TestTheme"
Camera = require "libs.hump.camera"
STI = require "libs.sti"
LDebug = require "libs.lovedebug.lovedebug"
Inspect = require 'libs.inspect.inspect'
------------------------------------------------
-- Componants
------------------------------------------------
Utils = require "src.Utils"
_state_MainMenu = require "src._state_MainMenu"
_state_Game = require "src._state_Game"
_state_MainLoader = require "src._state_MainLoader"
_state_Settings = require "src._state_Settings"
------------------------------------------------
-- Declarations
------------------------------------------------


------------------------------------------------
-- Base functions
------------------------------------------------
function love.load()
    Gamestate.registerEvents()
    Gamestate.switch(_state_MainMenu)

    UI.registerEvents()

end

function love.quit()

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
