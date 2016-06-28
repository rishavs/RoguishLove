debug = true

local inspect = require "inspect"

local points_Count = 0
local points_Obj = {}

local polies_Count = 0
local vpolies_Obj = {}

local window_slope = 0

function love.load(arg)

    window_slope = -love.graphics.getHeight()/love.graphics.getWidth()
    print(window_slope)
end

function love.draw(dt)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    
    if next(vpolies_Obj) ~= nil then                     -- Only iterate when the obj has content
        for _, vpoly in pairs(vpolies_Obj) do

            love.graphics.setColor(vpoly.color)
            if  vpoly.poly_Obj:validate( ) then
                love.graphics.polygon('fill', vpoly.poly_Obj:getPoints( ))
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
        add_to_vpolies_Obj()
   end
   -- print(inspect(points_Obj))
   -- print(inspect(vpolies_Obj))
end

--------------------------------------------------------------------

function add_to_vpolies_Obj()
    if next(points_Obj) ~= nil then
        for _, point in pairs(points_Obj) do
            
            print("Current point  index", point.index)
            print("...........................")
            
            if points_Count <=1 then
                -- vertices are mentioned clockwise starting from North/12'0 clock
                shape = love.physics.newPolygonShape( 0,0, love.graphics.getWidth(), 0, love.graphics.getWidth(), love.graphics.getHeight(), 0,love.graphics.getHeight() )
                -- shape = love.physics.newChainShape( loop, 
                                -- 0,0, love.graphics.getWidth(), 0, love.graphics.getWidth(), love.graphics.getHeight(), 0,love.graphics.getHeight() )
                -- shape.site= {u=point.x, v=point.y}
                -- shape.color =  {get_random_color()}
                vpoly = { 
                    index = point.index,
                    site = {u=point.x, v=point.y},
                    color =  {get_random_color()},
                    poly_Obj = shape
                    }

            else
                -- print(point.x, point.y .."\n")
                
                
                -- Find the polygon inside which this new point lies 
                for _, vpoly in pairs(vpolies_Obj) do
                   if vpoly.poly_Obj:testPoint( 0, 0, 0, point.x, point.y ) then
                   
                        print ("inside polygon with index", vpoly.index)
                        
                        -- now that we know its inside this polygon, time to draw a perpendicular bisector between the two points
                        
                        
                        -- get perpendicular biscetor
                        local xm, ym, slope = get_perpendicular_bisector (point.x, point.y)
                        
                        -- get intersection points with containing poly
                        
                        -- split poly
                        
                        -- repeat task with all neighbouring polies which share a side with parent poly
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        
                        break
                   end
                end

            end
        end
        
        table.insert(vpolies_Obj, vpoly)
            
    end
    

end

function add_to_points_Obj (x, y)
    points_Count = points_Count + 1
    table.insert(points_Obj, {index= points_Count, x= x, y= y})
end

function is_point_in_polygon(x, y)
    
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

function get_perpendicular_bisector(x1,y1, x2, y2) 
    -- mid point calclulation
    xm = (x1+x2)/2
    ym = (y1+y2)/2
    
    -- slope
    slope = (y2-y1)/(x2-x1)
    
    return xm, ym, slope
end

function find_line_intersection (x1, y1, x2, y2, x3, y3, x4, y4)
    d = (y4-y3)*(x2-x1)-(x4-x3)*(y2-y1)
    Ua_n = ((x4-x3)*(y1-y3)-(y4-y3)*(x1-x3))
    Ub_n = ((x2-x1)*(y1-y3)-(y2-y1)*(x1-x3))
    Ua = Ua_n / d
    Ub = Ub_n / d
    if d ~= 0 then
        x=x1+Ua*(x2-x1)
        y=y1+Ua*(y2-y1)
        print(x,y)
        ellipse(x,y,20,20)
    else
        print("parallel")
    end
end