local _state_Game = {}

local _layer_Tilemap = {}
local _layer_Sprites = {}
local _layer_Foreground = {}
local _layer_HUD = {}
local _layer_UI = {}

------------------------------------------------
-- State Definition: _state_Game
------------------------------------------------
function _state_Game:init()

    -- State Declarations ----------------------
    local camX, camY, camZoom, camRot = 0, 0, 1, 0
    
    camSpeed = 1000 -- Scrolling speed for the camera
    camAcclr = 10  -- Acceleration factor for the camera
    screenEdge = 0.98   -- The area at the screen edge where panning needs to start. eg after 98% of screen size. value < 1
    --------------------------------------------
    
    self.cam = Camera(camX, camY, camZoom, camRot)
    
    windowWidth  = love.graphics.getWidth()
    windowHeight = love.graphics.getHeight()

	-- Load map
	self.map = STI.new("modules/base/maps/isometric_grass_and_water.lua")
    
	-- print(STI._VERSION) -- Print STI Version
	-- print(self.map.tiledversion)    -- Print Tiled Version
    
    self.mapWidthPixels = self.map.width * self.map.tilewidth 
    self.mapHeightPixels = self.map.height * self.map.tileheight
    
    -- Add a Custom Layer
	sprite = love.graphics.newImage("modules/base/assets/art/frowny.png")    
    width = sprite:getWidth()
    height = sprite:getHeight()
end
    
function _state_Game:draw()


    
    -- Translation would normally be based on a player's x/y
    local translateX = 0
    local translateY = 0


    
    self.cam:attach() -- Everything inside the camera goes here
    
    -- Draw Range culls unnecessary tiles
    self.map:setDrawRange(-translateX, -translateY, windowWidth, windowHeight)
    self.map:draw()

    love.graphics.draw(sprite, 100, 100, math.rad(90), 1, 1, width / 2, height / 2)
    
    self.cam:detach() -- Everything outside the camera goes here
    

    -- Fixed Position stuff like HUD go here --
    ------------------------------------------------
        
end

function _state_Game:update(dt)
    self.map:update(dt)

    -- Edge Panning
    local mouseX, mouseY = love.mouse.getPosition( )
    local screenBottomEdge = windowHeight * screenEdge 
    local screenTopEdge = windowHeight * (1 - screenEdge)
    local screenRightEdge = windowWidth * screenEdge
    local screenLeftEdge = windowWidth * (1-screenEdge)
    
    local camX, camY = self.cam:position()
    
    if mouseY > screenBottomEdge and camY < self.mapHeightPixels then 
        self.cam:move(0, camSpeed * dt )
    elseif mouseY < screenTopEdge and camY > 0 then 
        self.cam:move(0, -camSpeed * dt)    
    elseif mouseX > screenRightEdge and camX < self.mapWidthPixels then 
        self.cam:move(camSpeed * dt , 0)    
    elseif mouseX < screenLeftEdge and camX > 0 then 
        self.cam:move(-camSpeed * dt , 0)
    end
    
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
        self.cam:lookAt(30, 30)
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
end

return _state_Game