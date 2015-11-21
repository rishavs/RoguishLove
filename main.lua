local Utils = require "src.utils"
Utils.foo()
_state_MainMenu = require "src._state_MainMenu"
_state_Game = require "src._state_Game"
_state_MainLoader = require "src._state_MainLoader"
_state_Settings = require "src._state_Settings"
------------------------------------------------
-- libs
------------------------------------------------
Gamestate = require "libs.hump.gamestate"
-- local Utils = require "src.utils"
UI = require "libs.thranduil.ui"
Theme = require "libs.thranduil.TestTheme"
Camera = require "libs.hump.camera"
STI = require "libs.sti"
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

function love.keypressed(key, u)
   --Debug
   if key == "`" then --set to whatever key you want to use
      debug.debug()
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
