debug = true

local inspect = require "inspect"
local parent_poly, window_poly,
    parent_site, child_site, ray_site, win_intercept_p1, win_intercept_p2,
    pbisector_line, connecting_line,
    mousex, mousey

function love.load()
    
    love.physics.setMeter(1)
    
    window_poly =  love.physics.newPolygonShape ( 
        0, 0,
        love.graphics.getWidth(), 0, 
        love.graphics.getWidth(), love.graphics.getHeight(), 
        0, love.graphics.getHeight() 
    )
            
    parent_poly = love.physics.newPolygonShape ( 
        150, 100, 
        500, 150, 
        600, 300,
        550, 500,
        300, 550,
        100, 400,
        50, 150
    )
    
    parent_site = {300, 300}

end

function love.draw()
    love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    
    love.graphics.print(mousex .. ", " .. mousey, mousex -30, mousey -30)
    
    love.graphics.polygon ("line", window_poly:getPoints())
    love.graphics.polygon ("line", parent_poly:getPoints())
    
    love.graphics.setPointSize(5)
    love.graphics.points(parent_site)
    

    if child_site then
        love.graphics.points(child_site)
        love.graphics.line(parent_site[1], parent_site[2], child_site[1], child_site[2])
        love.graphics.points(
            (parent_site[1] + child_site[1])/2, 
            (parent_site[2] + child_site[2])/2
        )

        
        love.graphics.line(window_intercept.x1, window_intercept.y1, window_intercept.x2, window_intercept.y2)
        
    end

    if pbisector_line then
        love.graphics.line(pbx, pbm)
    end
    
    if connecting_line then
        love.graphics.line(connecting_line.x1, connecting_line.y1, connecting_line.x2, connecting_line.y2)
    end
end

function love.update()
    mousex, mousey = love.mouse.getPosition()
end


function love.mousepressed(x, y, button, istouch)
   if button == 1 then
        add_to_vpolies_Obj(x, y)
   end
   -- print(inspect(points_Obj))
   -- print(inspect(vpolies_Obj))
end

--------------------------------------------------------------------

function add_to_vpolies_Obj(sitex, sitey)

    child_site = {sitex, sitey}
        
    if parent_poly:testPoint( 0, 0, 0, sitex, sitey ) then
        
        print("Point " .. sitex .. ", " .. sitey .. " is INSIDE the polygon\n")
        
        print("The Perpendicular Bisector is...")
        xm, ym, bm, slope = get_perpendicular_bisector (parent_site[1], parent_site[2], sitex, sitey)
        print(xm, ym, bm, slope)
        print("Y = ".. slope .. "  X + " .. bm.. "\n")
        

        -- dist = get_distance_between_2_Points (parent_site[1], parent_site[2], sitex, sitey)
        -- print("The Distance Between the 2 points = " .. dist)

        
        
        -- print("The bisector intersects window at:")
        
        window_intercept = get_window_intercept_of_line(ym, slope, xm, bm)
        
        -- print(window_intercept.x1, window_intercept.y1 , window_intercept.x2, window_intercept.y2)
        
        win_intercept_p1 = {window_intercept.x1, window_intercept.y1 }
        win_intercept_p2 = {window_intercept.x2, window_intercept.y2}
       
        -- Lets try another approach
        print ("Unpacking Polygon into following sides:")
        local poly_sides = unpack_polygon (window_poly:getPoints())
        
        local intersection_point = {}
        
        -- for each side, find if intersect occurs
        for _, side in pairs(poly_sides) do
            print ("\nFor side ", side.x1, side.y1, side.x2, side.y2) 
            -- convert to line eqn
            local m, b = get_lineEqn_from_segment(side.x1, side.y1, side.x2, side.y2)
            print("Eqn of unpacked line is:")
            print("Y = ".. m .. "  X + " .. b)

              
            
            -- if side.y2 == side.y1 then
                -- local m = 0
                -- local b = y1
                
                -- intersection_point.x = (b - bm)/(slope)
                -- intersection_point.y = b
                
            -- elseif side.x2 == side.x1 then
                -- local x = x1
                -- local b = y1 - (m * x)
                -- intersection_point.x = x1
                -- intersection_point.y = ((slope *b) - (m * bm))/(slope - m)
            -- else
                -- m = (x2-x1)/(y2-y1)
                -- b = y1 - (m * x1)
                -- intersection_point.x = (b - bm)/(slope - m)
                -- intersection_point.y = ((slope *b) - (m * bm))/(slope - m)
            -- end
            -- now we find intersection point
            local temp_point = get_lineEqn_intersection(slope, bm, m, b, side.x1, side.y1, side.x2, side.y2)
            print("Intersection point is: ")
            print(inspect(temp_point))

            
        end
        
        
        
        
        -- print("The clipping points are...")
        -- print("Splitting the Polygon...")
    else
        print("Point " .. sitex .. ", " .. sitey .. " is OUTSIDE the polygon")
        
    end
    
    print("-------------------------------\n\n")

end


function get_perpendicular_bisector(x1, y1, x2, y2) 
    -- mid point calclulation
    xm = (x1+x2)/2
    ym = (y1+y2)/2
    
    -- slope
    slope = -(x2-x1)/(y2-y1)
    
    bm = ym - (slope * xm)
    return xm, ym, bm, slope
end

function get_distance_between_2_Points(x1,y1, x2,y2) 
    return ((x2-x1)^2+(y2-y1)^2)^0.5 
end

function get_window_intercept_of_line (Y, m, X, b)
        window_slope = -love.graphics.getHeight()/love.graphics.getWidth()
        local x1, y1, x2, y2
        
        if - window_slope < math.abs(m) and math.abs(m) < window_slope then
            -- print(m .. " < " .. window_slope)
            -- cuts on the top n bottom

            -- consider when x1 = 0
            x1 = 0
            y1 = b
            -- consider when x2 = love.graphics.getWidth()
            x2 = love.graphics.getWidth()
            y2 = (x2 * m) - b
        else
            -- print(m .. " > " .. window_slope)
            -- cuts on the side
            -- consider when y1 = love.graphics.getHeight()
            y1 = love.graphics.getHeight()
            x1 = (y1 - b)/m
            -- consider when y2 = 0
            y2 = 0
            x2 = - b / m
        -- elseif m == window_slope then
            -- print(m .. " = " .. window_slope)
            
            
            
        end
        return {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
end

function unpack_polygon(...)
    local arg = {...}
    local points_count = table.getn(arg)
    local sides = {}
    local px1, px2, py1, py2
    local starting_X = arg[1]
    local starting_Y = arg[2]

    if points_count % 2 ~= 0 then
        print("ERROR:: ODD NUMBER OF POINTS!!!!")
    else
    
        for i=1, points_count, 2 do 
            px1 = arg[i]
            py1 = arg[i+1]
            
            if arg[i+2] then
                px2 = arg[i+2]
            else
                px2 = starting_X
            end
            
            if arg[i+3] then
                py2 = arg[i+3]
            else
                py2 = starting_Y
            end
            
            table.insert(sides, {
                x1 = px1,
                y1 = py1,
                x2 = px2,
                y2 = py2
            })
        end
    end
    print(inspect(arg))
    
    return sides
end

function get_lineEqn_from_segment (x1, y1, x2, y2)
        m = (y2-y1)/(x2-x1)
        
        b = y1 - (m * x1)
        print("The Line eqn for points ".. "[" .. x1 .. ", " .. y1 .. "] & [" .. x2 .. ", " .. y2 .. "]")
        print("m = " .. m .. ", b = " .. b)
    return m, b
end

function get_lineEqn_intersection (slope, bm, m, b, x1, y1, x2, y2)
    result = false
    print(slope, m)
    if slope == m then
        print("Parallel lines")
        
    elseif m == math.huge or m == -math.huge then
        print("** UNHANDLED case with M = INF")
    
    elseif slope == math.huge or slope == -math.huge then
            print("** UNHANDLED case with SLOPE = INF")
            
    elseif slope > -math.huge and slope < math.huge and m > -math.huge and m < math.huge  then
        if m == 0 and b == 0 then
            print("** UNHANDLED case with m")
            iy = y1
            ix = (iy - bm) / slope
        elseif slope == 0 and bm == 0 then
            print("** UNHANDLED case with slope")
        else
            ix = -( (b - bm)/(m - slope))
            iy = (slope * ix) + bm
        end
        

        ix = math.abs(ix)
        iy = math.abs(iy)
        print("Testing point : " .. ix, iy)
        
        local minx, miny, maxx, maxy
        minx = math.min(x1, x2)
        maxx = math.max(x1, x2)
        
        miny = math.min(y1, y2)
        maxy =math.max(y1, y2)
        
        -- if (x1 <= ix and ix <= x2) or (x2 <= ix and ix <= x1) then
        if (minx <= ix and ix <= maxx) and (miny <= iy and iy <= maxy) then
            print("Found Intersection!")
            result = {ix, iy}
        end
    end

    return result
end