local _state_Game = {}

------------------------------------------------
-- State Definition: _state_Game
------------------------------------------------
function _state_Game:init()

    -- State Declarations ----------------------
    local camX, camY, camZoom, camRot
    
    camSpeed = 1000
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
    
    -- Edge Panning
    local mouseX, mouseY = love.mouse.getPosition( )
    if mouseY >= windowHeight *0.98 then 
        self.cam:move(0, camSpeed * dt)
    elseif mouseY <= windowHeight *0.02 then 
        self.cam:move(0, -camSpeed * dt)    
    elseif mouseX >= windowWidth *0.98 then 
        self.cam:move(camSpeed * dt, 0)    
    elseif mouseX <= windowWidth *0.02 then 
        self.cam:move(-camSpeed * dt, 0)
    end
    
end

    -- Camera Zoom using Mouse Wheel
function _state_Game:wheelmoved(x,y)
    
    if y > 0 then
        print("Mouse wheel moved up")
        self.cam.scale = self.cam.scale * 1.2
    elseif y < 0 then
        print("Mouse wheel moved down")
        self.cam.scale = self.cam.scale * 0.8
    end
 end
 
function _state_Game:keyreleased(key)
    
    if key == 'escape' then
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

return _state_Game