local HUD = {}

------------------------------------------------
-- State Definition: HUD
------------------------------------------------

function HUD:init()
    -- TOP HUD
    
    
    -- Bottom HUD
    self._frame_HUD_Bottom_Container = UI.Frame(0,0,0,0, {extensions = {Theme.Frame}})
    self._frame_HUD_Bottom_Container.x, self._frame_HUD_Bottom_Container.y = 0, windowHeight - 100
    self._frame_HUD_Bottom_Container.w, self._frame_HUD_Bottom_Container.h = windowWidth, 100
    
    self._button_HUD_Bottom_b1 = self._frame_HUD_Bottom_Container:addElement(UI.Button(10, 10, 100, 80, {extensions = {Theme.Button}, text = "Button 1"}))
    self._button_HUD_Bottom_b2 = self._frame_HUD_Bottom_Container:addElement(UI.Button(150, 10, 100, 80, {extensions = {Theme.Button}, text = "Button 2"}))

end

function HUD:draw()
    love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 50)

    self._frame_HUD_Bottom_Container:draw();
end

function HUD:update(dt)
    self._frame_HUD_Bottom_Container:update(dt);

    if self._button_HUD_Bottom_b1.released then 
        print("Button 1") 
    end;
    
    if self._button_HUD_Bottom_b2.released then 
        print("Button 2") 
    end;

end

return HUD