local _state_MainLoader = {}

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


return _state_MainLoader