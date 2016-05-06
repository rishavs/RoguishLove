------------------------------------------------
-- libs
------------------------------------------------
local Anim = require "libs.Anim8.anim8"

------------------------------------------------
-- Componants
------------------------------------------------
local HUD = require "src.HUD"
local GUI = require "src.GUI"

------------------------------------------------
-- Declarations
------------------------------------------------
local _state_Game = {}

local _layer_Tilemap = {}
local _layer_Sprites = {}
local _layer_Foreground = {}
local _layer_HUD = {}
local _layer_UI = {}

------------------------------------------------
-- Variable Declarations
------------------------------------------------
local startPoint, endPoint

------------------------------------------------
-- State Definition: _state_Game
------------------------------------------------
function _state_Game:init()

    -- State Declarations ----------------------
    local camX, camY, camZoom, camRot = 0, 0, 1, 0
    
    
    screenEdge = 0.95   -- The area at the screen edge where panning needs to start. eg after 98% of screen size. value < 1
    --------------------------------------------
    
    self.cam = Camera(camX, camY, camZoom, camRot)
    
    windowWidth  = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()

    -- Load map
    self.map = STI.new("modules/base/maps/tileMap.lua")
      
    print(STI._VERSION) -- Print STI Version
    print(self.map.tiledversion)    -- Print Tiled Version
    
    self.mapWidthPixels = self.map.width * self.map.tilewidth 
    self.mapHeightPixels = self.map.height * self.map.tileheight
    
--    print (self.map.height, self.map.tileheight, self.mapHeightPixels )
--    print (self.map.width, self.map.tilewidth, self.mapWidthPixels )
    
    -- Create a sprite layer
    _layer_Sprites = self.map:addCustomLayer("Sprites", 4)


    -- Get spawn & Destination points

    for k, object in pairs(self.map.objects) do
        if object.name == "startPoint" then
            startPointX, startPointY = self.cam:worldCoords(object.x, object.y)
            print("startpoint", object.x, object.y)
            print("startpoint WORLD COORD", startPointX, startPointY)
            print("NUM WORLD COORD", self.cam:worldCoords(320, 2880)) --8592054888
            print("startpoint CAM COORD", self.cam:cameraCoords(708, 1602))
            print("startpoint isoToScreen", self.map:convertIsometricTileToScreen (object.x, object.y)	)
            print("startpoint isoToScreen", self.map:convertIsometricTileToScreen (self.cam:worldCoords(320, 2880)))
            print("startpoint ScreenToIso", self.map:convertScreenToIsometricTile (self.cam:worldCoords(320, 2880)))
            
            
            print("startpoint ScreenToIso", self.map:convertScreenToIsometricTile (320, 2880)	)
            
            
            
        elseif object.name == "endPoint" then
            endPointX, endPointY = self.cam:cameraCoords(object.x, object.y)
--            print("endpoint", object.x, object.y)
        end
    end
    

--    print("endPoint", Inspect(endPoint))


    -- Create a player object at startPoint
    
    img = love.graphics.newImage("modules/base/assets/art/arrow.png")    
    imgWidth = img:getWidth()
    imgHeight = img:getHeight()
    
    
    -- Just a test animated sprite for now
    sprite_img = love.graphics.newImage('modules/base/assets/art/sprites/knight.png')
    local sprite_grid = Anim.newGrid(128, 128, sprite_img:getWidth(), sprite_img:getHeight())
    anim_test = Anim.newAnimation(sprite_grid('1-4',1), 0.3)
    
    HUD:init()
end
    
function _state_Game:draw()

    -- Translation would normally be based on a player's x/y
    local translateX = 0
    local translateY = 0
    
    self.cam:attach() 
    -- Everything inside the camera goes here
    ------------------------------------------------
    
    -- Draw Range culls unnecessary tiles. this is currently causing issues with the bottom edge detection
    -- self.map:setDrawRange(0, 0, windowWidth, windowHeight)
    self.map:draw()

    love.graphics.draw(img, 708, 1602, 0, 1, 1, imgWidth / 2, imgHeight / 2)

    anim_test:draw(sprite_img, 300, 500)

    
    self.cam:detach() 
    -- Everything outside the camera goes here
    ------------------------------------------------
    

    -- Fixed Position stuff like HUD go here --
    ------------------------------------------------
    HUD:draw()
    
end

function _state_Game:update(dt)
    self.map:update(dt)

    -- Camera Edge definition
    local mouseX, mouseY = love.mouse.getPosition( )
    local panBottomEdge = windowHeight * screenEdge 
    local panTopEdge = windowHeight * (1 - screenEdge)
    local panRightEdge = windowWidth * screenEdge
    local panLeftEdge = windowWidth * (1-screenEdge)
    
    camX, camY = self.cam:position()
    
    -- Camera edge panning. Currently starts too slow and builds up way too much velocity. need to set a max speed clamper
    local panEdgeStartSpeed = 100
    local panEdgeMaxSpeed = 1000
    if mouseY > panBottomEdge and camY < self.mapHeightPixels then 
        self.cam:move(0, (camY + panEdgeStartSpeed) * dt)
    elseif mouseY < panTopEdge and camY > 0 then 
        self.cam:move(0, - (camY + panEdgeStartSpeed) * dt)    
    elseif mouseX > panRightEdge and camX < self.mapWidthPixels then 
        self.cam:move((camX + panEdgeStartSpeed) * dt , 0)    
    elseif mouseX < panLeftEdge and camX > 0 then 
        self.cam:move(-(camX + panEdgeStartSpeed) * dt , 0)
    end
    
    anim_test:update(dt)
    
    HUD:update(dt)
end

    -- Camera Zoom using Mouse Wheel
function _state_Game:wheelmoved(x,y)
    
    if y > 0 then
        self.cam.scale = self.cam.scale * 1.2
    elseif y < 0 then
        self.cam.scale = self.cam.scale * 0.8
    end
 end
 
function _state_Game:keyreleased(key)
    
    if key == 'escape' then
        Gamestate.switch(_state_MainMenu)
    end    
    if key == 'space' then
        self.cam:lookAt(self.mapWidthPixels/2, self.mapHeightPixels/2)
        self.cam:zoomTo(1)
    end
 end

function _state_Game:keypressed(key) 
    if key == 'left' then
        self.cam:move(-50, 0)
    elseif key == 'right' then
        self.cam:move(50, 0)
    elseif key == 'up' then
        self.cam:move(0, -50)
    elseif key == 'down' then
        self.cam:move(0, 50)
    end    
end

function _state_Game:mousereleased(x, y, button)
    print ("MButton :" .. button .. ", X :" .. x .. ", Y :" .. y)
    print ("worldCoord", self.cam:worldCoords (x, y))
    print ("camCoord", self.cam:cameraCoords (x, y))
end

return _state_Game