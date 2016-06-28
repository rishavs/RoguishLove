debug = true

local inspect = require "inspect"

local pointsObj = {}
local pointsList = {}
local dEdges = {}

function love.load(arg)

    local start_time = love.timer.getTime()
    
    -- generate points field
    pointsObj = pointsSetGenerator (500000,0.4)
    pointsList = flattenPointsObj(pointsObj)
    
    -- generate debbinoi edges

    
    
    
    print(string.format("%.3f ms to Generate Points field", 1000 * (love.timer.getTime() - start_time)))
end

function love.draw(dt)
    love.graphics.print("Hello World", 400, 300)
    love.graphics.points(pointsList)

end

function love.update(dt)

end


function pointsSetGenerator (n,s)
    local pointsList = {} -- output
    local pointsObj = {}
    
    
    -- n = number of points, d = max deviance allowed. between 0 and 0.5
    local scrW = love.graphics.getWidth()
    local scrH = love.graphics.getHeight()
    
    -- n * d^2 = scrW * scrH
    local d = roundToInt(math.sqrt(scrW * scrH / n))
    -- print(d)
    
    -- set random seed for maths lib
    math.randomseed( os.time() )
    
    -- Generate points set 
    local count = 0
    local de = (d-d*s)            -- max distance form the edge
    
    local cntU = 0                -- counters for each loop
    for y = de, scrH, d do
        cntU = cntU + 1
        local cntV = 0            -- counters for each loop
        for x = de, scrW,d do
            cntV = cntV + 1
            -- apply deviance to get randomness
            local dx = x + (d * math.random(0, s*100)/100 * ((math.random(1,2)*2)-3))
            local dy = y + (d * math.random(0, s*100)/100 * ((math.random(1,2)*2)-3))
            
            dx = roundToInt(dx)
            dy = roundToInt(dy)
            -- discard all points where the distance from the edge is less than de
            if (dx + d * s) <  scrW and (dy + d * s) < scrH then
                table.insert(pointsList, dx)
                table.insert(pointsList, dy)
                
                table.insert(pointsObj, {x = dx, y = dy, u = cntU, v = cntV})
               
                
                count = count + 1
                
                -- print (d, count, scrW, scrH, x, y, dx, dy)
            end
            
        end
    end

    -- return pointsList
    return pointsObj

    end

function roundToInt(n)
    return (math.floor(n+0.5))
end

-- flatten our points object to get a sequence of xy cords of the points for use in love.graphics.points
function flattenPointsObj (pointsObj)
    local pointsList ={}
    
    for k, point in pairs(pointsObj) do
        table.insert(pointsList, point.x)
        table.insert(pointsList, point.y)
    end
    -- print (inspect(pointsList))
    return pointsList
end

function getCenterFromIndex (u,v, point)
    return point.x, point.y
end

function triangulate()
    triangulate()
    {
       create supertriangle and add it to the triangulation
       for (each vertex)
       {
          add_vertex(vertex)
       }
       for (each triangle)
       {
          if (one or more vertices stem from supertriangle)
          {
             remove triangle
          }
       }
    }
end


function add_vertex()
    add_vertex(vertex)
    {
       for (each triangle)
       {
          if (vertex is inside triangle's circumscribed circle)
          {
             store triangle's edges in edgebuffer
             remove triangle
          }
       }
       remove all double edges from edgebuffer,
          keeping only unique ones
       for (each edge in edgebuffer)
       {
          form a new triangle between edge and vertex
       }
end
