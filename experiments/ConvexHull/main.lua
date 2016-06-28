debug = true

local inspect = require "inspect"

local points_Count = 0
local points_Obj = {}

local polies_Count = 0
local polies_Obj = {}

function love.load(arg)

end

function love.draw(dt)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    
    if next(polies_Obj) ~= nil then                     -- Only iterate when the obj has content
        for _, poly in pairs(polies_Obj) do

            love.graphics.setColor(poly.color)
            if love.math.isConvex( poly.vertices_List ) then
                love.graphics.polygon('fill', poly.vertices_List)
            else
                print("POLY IS CONCAVE!! RUN!!")
            end
        end
    end   

    if next(points_Obj) ~= nil then                     -- Only iterate when the obj has content
        for _, point in pairs(points_Obj) do
            love.graphics.setColor(50,50,50)    
            love.graphics.setPointSize(3)
            love.graphics.points(point.x, point.y)
            love.graphics.print(point.x .. ", " .. point.y, point.x - 30, point.y - 30 )
        end
    end
    


end


function love.mousepressed(x, y, button, istouch)
   if button == 1 then
        add_to_points_Obj(x, y)
        add_to_polies_Obj()
   end
   print(inspect(points_Obj))
   -- print(inspect(polies_Obj))
end

--------------------------------------------------------------------

function add_to_polies_Obj()
    if next(points_Obj) ~= nil then
        for _, point in pairs(points_Obj) do
            if points_Count <=1 then
                -- vertices are mentioned clockwise starting from North/12'0 clock
                -- shape = love.physics.newChainShape( loop, 
                                -- 0,0, love.graphics.getWidth(), 0, love.graphics.getWidth(), love.graphics.getHeight(), 0,love.graphics.getHeight() )
                -- shape.site= {u=point.x, v=point.y}
                -- shape.color =  {get_random_color()}
                vpoly = { 
                    site = {u=point.x, v=point.y},
                    color =  {get_random_color()},
                    vertices = {
                        {x = 0, y = 0}, 
                        {x = love.graphics.getWidth(), y = 0},
                        {x = love.graphics.getWidth(), y = love.graphics.getHeight()},
                        {x = 0, y = love.graphics.getHeight()}
                        },
                    vertices_List = {0,0, love.graphics.getWidth(), 0, love.graphics.getWidth(), 
                    love.graphics.getHeight(), 0,love.graphics.getHeight()}
                }
            else
                print(point.x, point.y .."\n")


            end
        end
        
        table.insert(polies_Obj, vpoly)
            
    end
    

end

function add_to_points_Obj (x, y)
    points_Count = points_Count + 1
    table.insert(points_Obj, {index= points_Count, x= x, y= y})
end

function is_point_in_polygon(x, y)
    -- //Cannot be part of empty polygon
    -- if (polygon.Count == 0)
    -- {
        -- return false;
    -- }

    -- //With 1-pt polygon, only if it's the point
    -- if (polygon.Count == 1)
    -- {
        -- return polygon[0] == testPoint;
    -- }

    -- //n>2 Keep track of cross product sign changes
    -- var pos = 0;
    -- var neg = 0;

    -- for (var i = 0; i < polygon.Count; i++)
    -- {
        -- //If point is in the polygon
        -- if (polygon[i] == testPoint)
            -- return true;

        -- //Form a segment between the i'th point
        -- var x1 = polygon[i].X;
        -- var y1 = polygon[i].Y;

        -- //And the i+1'th, or if i is the last, with the first point
        -- var i2 = i < polygon.Count - 1 ? i + 1 : 0;

        -- var x2 = polygon[i2].X;
        -- var y2 = polygon[i2].Y;

        -- var x = testPoint.X;
        -- var y = testPoint.Y;

        -- //Compute the cross product
        -- var d = (x - x1)*(y2 - y1) - (y - y1)*(x2 - x1);

        -- if (d > 0) pos++;
        -- if (d < 0) neg++;

        -- //If the sign changes, then point is outside
        -- if (pos > 0 && neg > 0)
            -- return false;
    -- }

    -- //If no change in direction, then on same side of all segments, and thus inside
    return true;
end

function split_polygon()

end

function get_convex_hull()

end

function get_voronoi_neighbours ()          -- alll the polies which share a side
end

function get_random_color() 
    return love.math.random(0,255), love.math.random(0,255), love.math.random(0,255)
end

function get_potential_bisector(x1,y1, x2, y2) 
    -- mid point calclulation
    xm = (x1+x2)/2
    ym = (y1+y2)/2
    
    -- slope
    slope = (y2-y1)/(x2-x1)
    
    return xm, ym, slope
    
end