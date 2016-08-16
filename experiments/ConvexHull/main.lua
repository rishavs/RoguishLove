debug = true

local inspect = require "inspect"
local numPoints
local pointSet = {}
local convexHull = {}
local timeTaken = 0

function love.load(arg)

    pointSet = get_random_points()

    convexHull = get_convex_hull (pointSet)
    
end

function love.draw(dt)

    
    if #pointSet > 0 then
        love.graphics.setPointSize(3)
        love.graphics.points(pointSet)
    
    end

    if #convexHull > 0 then
    
        -- love.graphics.polygon(convexHull)
    
    end
    
    love.graphics.print("Number of Points = " .. numPoints, 10, 10)
    love.graphics.print("Time Taken = " .. numPoints .. " ms", 10, 30)
    
    love.graphics.print(mousex .. ", " .. mousey, mousex -30, mousey -30)
    
end

function love.update(dt)
    mousex, mousey = love.mouse.getPosition()
end

function love.keypressed(key)
    if key == "space" then
        pointSet = get_random_points()
       
    elseif key == "escape" then
        love.event.quit()

    end

end

function get_random_points()
    -- math.randomseed( os.time() )
    
    numPoints = math.random(5, 50)
    local points = {}

    for i=1, numPoints do
        -- create a random point between x= 200 to 400 and y = 200 to 400
        table.insert(points, math.random(200, 600))
        table.insert(points, math.random(100, 500))
    end
    
    return points
end

function get_convex_hull (points)
    local stime =  love.timer.getTime()
    
    local pointsX = {}
    local pointsY = {}
    local startingPoint = {}
    local tempX = 800 -- any large random value
    local tempY
    
    for i=1, #points, 2 do
        -- table.insert(pointsX, points[i])
        -- table.insert(pointsY, points[i+1])
        
        if points[i] < tempX then
            tempX = points[i]
            tempY = points[i+1]
        end
        
    end
    
    -- print(inspect(points))
    -- print(inspect(pointsX))
    -- print(inspect(pointsY))
    
    startingPoint = {tempX, tempY}
    
    print("Starting Point = " .. tempX .. ", " .. tempY)
-- pointOnHull = leftmost point in S
-- i = 0
    -- repeat
    -- P[i] = pointOnHull
    -- endpoint = S[0]         // initial endpoint for a candidate edge on the hull
    -- for j from 1 to |S|
        -- if (endpoint == pointOnHull) or (S[j] is on left of line from P[i] to endpoint)
            -- endpoint = S[j]   // found greater left turn, update endpoint
    -- i = i+1
    -- pointOnHull = endpoint
    -- until ( endpoint == P[0] )
   
   timeTaken = (love.timer.getTime() - stime)*1000
   return {0}

end