debug = true

local inspect = require "inspect"

local vpolies_Count = 0
local vpolies_Obj = {}

local window_slope = 0

function love.load(arg)

    -- window_slope = -love.graphics.getHeight()/love.graphics.getWidth()
    -- print(window_slope)
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
            
            love.graphics.setColor(50,50,50)    
            love.graphics.setPointSize(3)
            love.graphics.points(vpoly.site.x, vpoly.site.y)
            love.graphics.print(vpoly.site.x .. ", " .. vpoly.site.y, vpoly.site.x - 30, vpoly.site.y - 30 )
            
        end
    end   
end


function love.mousepressed(x, y, button, istouch)
   if button == 1 then
        -- add_to_points_Obj(x, y)
        add_to_vpolies_Obj(x, y)
   end
   -- print(inspect(points_Obj))
   -- print(inspect(vpolies_Obj))
end

--------------------------------------------------------------------

function add_to_vpolies_Obj(sitex, sitey)
    
    vpolies_Count = vpolies_Count + 1
    local temp_poly = {}
    
    -- If this is the very first site
    if next(vpolies_Obj) == nil then
        temp_poly = { 
            index = vpolies_Count,
            site = {x=sitex, y=sitey},
            color =  {get_random_color()},
            poly_Obj =  love.physics.newPolygonShape ( 
                0,0,
                love.graphics.getWidth(), 0, 
                love.graphics.getWidth(), love.graphics.getHeight(), 
                0, love.graphics.getHeight() 
            ),
            neighbour_indices = {}
        }

    else
        -- At least 1 parent site exists
        -- Find the polygon inside which this new point lies 
        for _, vpoly in pairs(vpolies_Obj) do
            if vpoly.poly_Obj:testPoint( 0, 0, 0, sitex, sitey ) then
           
                print ("inside polygon with index", vpoly.index)
                
                -- now that we know its inside this polygon, time to draw a perpendicular bisector between the two points
                
                
                -- get perpendicular biscetor
                local xm, ym, slope = get_perpendicular_bisector (sitex, sitey, vpoly.site.x, vpoly.site.y)
                print (xm, ym, slope)
                
                local x1, y1, x2, y2, x3, y3, x4, y4, x5, y5, x6, y6, x7, y7, x8, y8 = vpoly.poly_Obj:getPoints()
                local temp_polyVert_obj = {{x1, y1}, {x2, y2}, {x3, y3}, {x4, y4}, {x5, y5}, {x6, y6}, {x7, y7}, {x8, y8}}
                print("Looking at poly: ", vpoly.index)
                print(inspect(temp_polyVert_obj))
                
                -- get intersection points with containing poly
                p1x, p1y, p2x,p2y = get_line_poly_intersection(xm, ym, slope, temp_polyVert_obj)
                print (p1x, p1y, p2x, p2y)
              
                
                
                -- split parent poly
                -- merge with new poly
                
                -- find neighbours of the new poly and add to dataset
                
                -- repeat task with all neighbouring polies which share a side with parent poly
                
                
                break
            end
        end
    end
    
    table.insert(vpolies_Obj, temp_poly)
    -- print(inspect(temp_poly.poly_Obj:getPoints()))
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


function get_line_poly_intersection(xm, ym, slope, poly_vertices)


    -- create line segments using vertices
    for _, vert_pair in pairs(poly_vertices) do
        if vert_pair ~= nil then
        
        print(vert_pair[1], vert_pair[2])
        
        
        
        end
    end
    
    return x1, y1, x2, y2
end

function find_2lines_intersection (x1, y1, x2, y2, x3, y3, x4, y4)
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