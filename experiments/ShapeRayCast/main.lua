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
        love.graphics.setColor(50, 100, 250)
        love.graphics.line(connecting_line[1], connecting_line[2], connecting_line[3], connecting_line[4])
        love.graphics.setColor(255, 255, 255)
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
        -- print(xm, ym, bm, slope)
        print("Y = ".. slope .. "  X + " .. bm.. "\n")
        window_intercept = get_window_intercept_of_line(ym, slope, xm, bm)
        
        win_intercept_p1 = {window_intercept.x1, window_intercept.y1 }
        win_intercept_p2 = {window_intercept.x2, window_intercept.y2}
       
        -- Lets try another approach
        print ("Unpacking Polygon into following sides:")
        
        local poly_sides = unpack_polygon (parent_poly:getPoints())
        
        connecting_line = {}
        
        -- for each side, find if intersect occurs
        for _, side in pairs(poly_sides) do
            print ("\nFor side ", side.x1, side.y1, side.x2, side.y2) 
            -- convert to line eqn
            local m, b = get_lineEqn_from_segment(side.x1, side.y1, side.x2, side.y2)
            print("Eqn of unpacked line is:")
            print("Y = ".. m .. "  X + " .. b)

            local clipping_point = get_lineEqn_intersection(xm, ym, slope, bm, m, b, side.x1, side.y1, side.x2, side.y2)
            if clipping_point[1] and clipping_point[2] then
                print("Intersection point is: [" .. clipping_point[1] .. ", " .. clipping_point[2] .. "]")
                -- print(inspect(clipping_point))
                table.insert(connecting_line, clipping_point[1])
                table.insert(connecting_line, clipping_point[2])
            end
        end

        -- print("The clipping points are...")

        
        
        local poly_points = {parent_poly:getPoints()}
        
        print("Splitting the Polygon with points...", inspect(poly_points))
        local child_poly1_points = {}
        local child_poly2_points = {}
        
        child_poly1_points, child_poly2_points = split_polygon  (poly_points, connecting_line[1], connecting_line[2], connecting_line[3], connecting_line[4])
        
        print("POLY 1 is ", inspect(child_poly1))
        print("POLY 2 is ", inspect(child_poly2))
        
        -- delete old polygon
        -- parent_poly = nil
        -- get new polygon points
        
        -- create new polygons
        
        

        
        
        
        
        
        
        
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
        -- print("The Line eqn for points ".. "[" .. x1 .. ", " .. y1 .. "] & [" .. x2 .. ", " .. y2 .. "]")
        -- print("m = " .. m .. ", b = " .. b)
    return m, b
end

function get_lineEqn_intersection (Xm, Ym, slope, bm, m, b, x1, y1, x2, y2)


    local result = {}

    if slope == m or slope == -m then
        print("Parallel lines")
    else
        -- m1 = 0 and m2 = inf
        if m == 0 and (slope == math.huge or slope == -math.huge) then
            iy = Ym
            ix = Xm
            print("Scenario :  m1 = 0 and m2 = inf")
            
        -- m1 = inf and m2 = 0
        elseif (m == math.huge or m == -math.huge) and slope == 0 then
            ix = Xm
            iy = Ym
            print("Scenario :  m1 = inf and m2 = 0")
            
        -- m1 = 0 and m2 = valid
        elseif m == 0 and (slope ~= math.huge or slope ~= -math.huge) then
            iy = Ym
            ix = (iy - bm) / slope
            print("Scenario :  m1 = 0 and m2 = valid")
            
        -- m1 = valid and m2 = 0
        elseif (m ~= math.huge or m ~= -math.huge) and slope == 0 then
            iy = Ym
            ix = (iy - b) / m
            print("Scenario :  m1 = valid and m2 = 0")
            
        -- m1 = inf and m2 = valid
        elseif (m == math.huge or m == -math.huge) and  (slope ~= math.huge or slope ~= -math.huge) then
            ix = Xm
            iy = (slope * ix) + bm
        print("Scenario :  m1 = inf and m2 = valid")
        
        -- m1 = valid and m2 = inf
        elseif (m ~= math.huge or m ~= -math.huge) and  (slope == math.huge or slope == -math.huge) then
            ix = Xm
            iy = (m * ix) + b
            print("Scenario :  m1 = valid and m2 = inf")
            
        -- m1 = valid and m2 = valid
        else
            ix = -( (b - bm)/(m - slope))
            iy = (slope * ix) + bm
            print("Scenario :  m1 = valid and m2 = valid")
        end
        
        print("Testing point : " .. ix, iy)
        
        local minx, miny, maxx, maxy
        minx = math.min(x1, x2)
        maxx = math.max(x1, x2)
        
        miny = math.min(y1, y2)
        maxy =math.max(y1, y2)
        
        -- if (x1 <= ix and ix <= x2) or (x2 <= ix and ix <= x1) then
        if (0 <= ix) and (0 <= iy) and (minx <= ix and ix <= maxx) and (miny <= iy and iy <= maxy) then
            print("Found Intersection!")
            result = {ix, iy}
        end
    end
    return result
end


function split_polygon(poly_points, x1, y1, x2, y2)
    local poly1_points = {}
    local poly2_points = {}
    local points_count = table.getn(poly_points)
    
    for i=1, points_count, 2 do
        print("Polymaking. Checking point " , poly_points[i], poly_points[i+1])
        side = get_side_of_line(x1, y1, x2, y2, poly_points[i], poly_points[i+1])
        if side == 1 then
            table.insert(poly1_points,  poly_points[i])
            table.insert(poly1_points,  poly_points[i+1])
        elseif side == -1 then
            table.insert(poly2_points,  poly_points[i])
            table.insert(poly2_points,  poly_points[i+1])
        elseif side == 0 then
            table.insert(poly1_points,  poly_points[i])
            table.insert(poly1_points,  poly_points[i+1])
            
            table.insert(poly2_points,  poly_points[i])
            table.insert(poly2_points,  poly_points[i+1])
        end
    end
    
    -- now all the clipping points
    table.insert(poly1_points,  x1)
    table.insert(poly1_points,  y1)    
    table.insert(poly1_points,  x2)
    table.insert(poly1_points,  y2)    
    
    table.insert(poly2_points,  x1)
    table.insert(poly2_points,  y1)    
    table.insert(poly2_points,  x2)
    table.insert(poly2_points,  y2)

    
    return poly1_points, poly2_points
end

function get_side_of_line(x1, y1, x2, y2, xt, yt)
    local value = ((x2 - x1)*(yt - y1)) - ((xt - x1)*(y2 - y1))

    if value > 0 then
        return 1
    elseif value == 0 then 
        return 0
    elseif value < 0 then 
        return -1
    end
end

function get_random_id ()
    return id
end