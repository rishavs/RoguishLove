local _state_Settings = {}

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

return _state_Settings