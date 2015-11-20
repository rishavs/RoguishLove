local Utils = require "src.utils"
Utils.foo()

------------------------------------------------
-- libs
------------------------------------------------
local Gamestate = require "libs.hump.gamestate"
-- local Utils = require "src.utils"
local UI = require "libs.thranduil.ui"
local Theme = require "libs.thranduil.TestTheme"
local Camera = require "libs.hump.camera"
local STI = require "libs.sti"
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
    self._frame_MainMenu_Container = UI.Frame(love.graphics.getWidth()/5, love.graphics.getHeight()/10, love.graphics.getWidth()*3/5, 500, {extensions = {Theme.Frame}})

    self._button_MainMenu_New = self._frame_MainMenu_Container:addElement(UI.Button(100, 100, 100, 40, {extensions = {Theme.Button}, text = "New"}))
    self._button_MainMenu_Save = self._frame_MainMenu_Container:addElement(UI.Button(100, 150, 100, 40, {extensions = {Theme.Button}, text = "Save"}))
    self._button_MainMenu_Load = self._frame_MainMenu_Container:addElement(UI.Button(100, 200, 100, 40, {extensions = {Theme.Button}, text = "Load"}))
    self._button_MainMenu_Settings = self._frame_MainMenu_Container:addElement(UI.Button(100, 250, 100, 40, {extensions = {Theme.Button}, text = "Settings"}))
    self._button_MainMenu_Quit = self._frame_MainMenu_Container:addElement(UI.Button(100, 300, 100, 40, {extensions = {Theme.Button}, text = "Quit"}))
end

function _state_MainMenu:draw()
    love.graphics.print("State: _state_MainMenu", 10, 10)
    love.graphics.print("Press ENTER to goto next screen", 10, 30)

    self._frame_MainMenu_Container:draw();

end

function _state_MainMenu:update(dt)
    self._frame_MainMenu_Container:update(dt);

    if self._button_MainMenu_New.released then 
        print("New") 
        Gamestate.switch(_state_Game)
    end;
    
    if self._button_MainMenu_Save.released then print("Save") end;
    if self._button_MainMenu_Load.released then print("Load") end;
    
    if self._button_MainMenu_Settings.released then 
        print("Settings") 
        Gamestate.switch(_state_Settings)
    end;
    
    if self._button_MainMenu_Quit.released then 
        print("Quit") 
        love.event.quit()
    end;
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
function _state_Game:init()

    -- State Declarations ----------------------
    local camX, camY, camZoom, camRot
    --------------------------------------------
    
    self.cam = Camera(0,0, 1, 0)
    
    windowWidth  = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()
    
	-- Load map
	self.map = STI.new("modules/base/maps/isometric_grass_and_water.lua")
    
	print(STI._VERSION) -- Print STI Version
	print(self.map.tiledversion)    -- Print Tiled Version
    
    -- Add a Custom Layer
	self.map:addCustomLayer("Sprite Layer", 3)

	local spriteLayer = self.map.layers["Sprite Layer"]

	-- Add Custom Data
	spriteLayer.sprite = love.graphics.circle( "fill", 30, 30, 50, 5 )

end
    
function _state_Game:draw()
    love.graphics.print("State: _state_Game", 10, 10)
    
    -- Translation would normally be based on a player's x/y
    local translateX = 0
    local translateY = 0

    -- Draw Range culls unnecessary tiles
    self.map:setDrawRange(-translateX, -translateY, windowWidth, windowHeight)
    self.cam:attach()
    self.map:draw()
    self.cam:detach()
end

function _state_Game:update(dt)
    self.map:update(dt)
    -- self.cam:move(dx * dt, dy * dt)
end

function _state_Game:keyreleased(key)
    
    if key == 'return' then
        Gamestate.switch(_state_MainMenu)
    end
 end

function _state_Game:keypressed(key) 
    if key == 'left' then
        self.cam:move(-50, 0)
    end    
    
    if key == 'right' then
        self.cam:move(50, 0)
    end    
    
    if key == 'up' then
        self.cam:move(0, -50)
    end    
    
    if key == 'down' then
        self.cam:move(0, 50)
    end    
end

function _state_Game:mousereleased(x, y, button)
    print ("MButton :" .. button .. ", X :" .. x .. ", Y :" .. y)
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
