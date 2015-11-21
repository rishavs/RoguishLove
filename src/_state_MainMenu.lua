local _state_MainMenu = {}

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
    
    if key == 'escape' then
        love.event.quit()
    end
end

return _state_MainMenu