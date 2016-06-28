local CamController = {}

------------------------------------------------
-- State Definition: CamController
------------------------------------------------
function CamController:init()

-- State Declarations ----------------------
    local camX, camY, camZoom, camRot = 0, 0, 1, 0
    
    camSpeed = 1000 -- Scrolling speed for the camera
    camAcclr = 10  -- Acceleration factor for the camera
    screenEdge = 0.98   -- The area at the screen edge where panning needs to start. eg after 98% of screen size. value < 1
    --------------------------------------------
    
    self.cam = Camera(camX, camY, camZoom, camRot)
end

function CamController:draw()

end

function CamController:update(dt)

end


return CamController