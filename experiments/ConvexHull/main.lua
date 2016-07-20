debug = true

local inspect = require "inspect"

local vpolies_Count = 0
local vpolies_Obj = {}
local window_intercept
local pbisector_line
local last_parent_site, last_child_site, last_bisector_point
local neighbour_lines_obj = {}
local window_slope = 0
local id_list = {}

function love.load(arg)

end

function love.draw(dt)

    if next(vpolies_Obj) ~= nil then                     -- Only iterate when the obj has content
        for id, vpoly in pairs(vpolies_Obj) do

            if  vpoly.poly_Obj:validate( ) then
                love.graphics.setColor(vpoly.color)
                love.graphics.polygon('fill', vpoly.poly_Obj:getPoints( ))
                
                -- print("Rendering Poly : ", id)
                love.graphics.setColor(0,0,0)    
                love.graphics.circle('line', vpoly.site.x, vpoly.site.y, 5)
                love.graphics.setPointSize(3)
                love.graphics.points(vpoly.site.x, vpoly.site.y)
                love.graphics.print(vpoly.site.x .. ", " .. vpoly.site.y .. " : @ ".. id, vpoly.site.x - 30, vpoly.site.y - 30 )

            else
                print("POLY IS CONCAVE!! RUN!!")
            end
        end
    end   
    

    
    if window_intercept then

        love.graphics.setColor(255, 255, 255)
        love.graphics.line(window_intercept.x1, window_intercept.y1, window_intercept.x2, window_intercept.y2)
        love.graphics.print(window_intercept.x1 .. ", " .. window_intercept.y1, window_intercept.x1 - 30, window_intercept.y1 - 30 )
        love.graphics.print(window_intercept.x2 .. ", " .. window_intercept.y2, window_intercept.x2 - 30, window_intercept.y2 - 30 )
    end
    
    if next(neighbour_lines_obj) then
        love.graphics.setColor(0, 0, 0)
        for _, line in pairs(neighbour_lines_obj) do
            love.graphics.line(line[1], line[2], line[3], line[4])
            love.graphics.setPointSize(4)
            love.graphics.points((line[1] + line[3]) / 2, (line[2] + line[4]) / 2)
        end
    end

    if last_parent_site then
        love.graphics.setColor(255, 255, 255)
        love.graphics.line(last_parent_site[1], last_parent_site[2], last_child_site[1], last_child_site[2])
        love.graphics.points(last_bisector_point[1], last_bisector_point[2])
    end
    
    love.graphics.setColor(255, 255, 255)
    love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)    
    love.graphics.print("Press [Space] to Reset", 100, 10)
    love.graphics.print(mousex .. ", " .. mousey, mousex -30, mousey -30)
end

function love.update(dt)
    mousex, mousey = love.mouse.getPosition()
end


function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        -- add_to_points_Obj(x, y)
        local stime =  love.timer.getTime()
        add_to_vpolies_Obj(x, y)
        print("NEW SITE ADDED in t = %.3f ms"  ,  (love.timer.getTime() - stime)*1000)
        -- print("\nID list is: " , inspect(id_list))
        -- print ("Poly List are : ")
        -- for id, vpoly in pairs(vpolies_Obj) do
           -- print("Poly " .. id .. " has neighbours " .. inspect(vpoly.neighbours))
       -- end
    end
    
    if button == 2 then
         for id, vpoly in pairs(vpolies_Obj) do
            if vpoly.poly_Obj:testPoint( 0, 0, 0, x, y ) then
                print("\n++++++++++++++++++++++++")
                print("Right clicked on Ploygon ", id)
                print ("\nIts Site is ..." , vpoly.site.x, vpoly.site.y)
                print ("\nIts neighbours are ...")
                print (inspect(vpoly.neighbours))
                
                neighbour_lines_obj = {}
                for n, _ in pairs(vpoly.neighbours) do
                    table.insert(neighbour_lines_obj, { vpoly.site.x, vpoly.site.y, vpolies_Obj[n].site.x, vpolies_Obj[n].site.y})
                end
                print("++++++++++++++++++++++++")
             end
         end
    end
end

function love.keypressed(key)
    if key == "space" then
        -- reset everything
        vpolies_Count = 0
        vpolies_Obj = {}
        id_list = {}
        pbisector_line = nil
        last_parent_site = nil
        last_child_site = nil
        last_bisector_point = nil
        window_intercept = nil

    end
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
            neighbours = {}
        }
        -- local tmp_id = 
    vpolies_Obj[get_unique_random_str()] = temp_poly
    
    else
        -- At least 1 parent site exists
        -- Find the polygon inside which this new point lies 
        for id, vpoly in pairs(vpolies_Obj) do
            if vpoly.poly_Obj:testPoint( 0, 0, 0, sitex, sitey ) then

                print("\n--------------------------------------")
                print("Point " .. sitex .. ", " .. sitey .. " is INSIDE the polygon with Polygon Id :", id)
                
                -- If the points are same, run for your life!
                if vpoly.site.x == sitex and vpoly.site.y == sitey then
                    print("STOP FUCKING CLICKING ON THE SAME POINT, YE DIMWIT!")
                else

                    -- print("Getting Perpendicular Bisector between : " .. vpoly.site.x .. ", ".. vpoly.site.y .. " & " .. sitex .. ", " .. sitey)
        
                    local pbisector_line = pbisector_intersect_with_poly(sitex, sitey, id)
                    -- split parent poly
                            
                    local poly_points = {vpoly.poly_Obj:getPoints()}
                    
                    -- print("Splitting the Polygon with points...", inspect(poly_points))
                    local split_poly1_points = {}
                    local split_poly2_points = {}
                    
                    split_poly1_points, split_poly2_points = split_polygon  (poly_points, pbisector_line[1], pbisector_line[2], pbisector_line[3], pbisector_line[4])
                    
                    -- print("POLY 1 vertices are: ", inspect(split_poly1_points))
                    -- print("POLY 2 vertices are: ", inspect(split_poly2_points))
                    
                    local parent_poly_id, child_poly_id
                    local parent_poly = {}
                    local child_poly = {}
                    local potential_neighbours = vpoly.neighbours
                    print ("Potential Neighbours :" .. inspect(potential_neighbours))
                    
                    parent_poly_id = id
                    child_poly_id = get_unique_random_str()
                
                    parent_poly.site = vpoly.site
                    child_poly.site = {x = sitex, y = sitey}
                    
                    parent_poly.color = vpoly.color
                    child_poly.color = {get_random_color()}
                    
                    parent_poly.neighbours = {}
                    child_poly.neighbours = {}

                    print("NEW POLY CREATED : " .. child_poly_id)
                    
                    -- add polies to the poly object
                    local temp_poly1 = love.physics.newPolygonShape ( split_poly1_points )
                    local temp_poly2 = love.physics.newPolygonShape  ( split_poly2_points )
                    
                    -- reuse and set new ids
                    if temp_poly1:testPoint( 0, 0, 0, vpoly.site.x, vpoly.site.y ) then
                        parent_poly.poly_Obj = temp_poly1
                        child_poly.poly_Obj = temp_poly2
                        
                    elseif temp_poly2:testPoint( 0, 0, 0, vpoly.site.x, vpoly.site.y ) then
                        parent_poly.poly_Obj = temp_poly2
                        child_poly.poly_Obj = temp_poly1
                    end
                    
                    -- If both polies are valid then add them to the main poly object
                    if  parent_poly.poly_Obj:validate( ) and child_poly.poly_Obj:validate( ) then                    
                        --insert into poly object
                        vpolies_Obj[parent_poly_id] = parent_poly
                        vpolies_Obj[child_poly_id] = child_poly
                    else
                        print ("SPLIT POLYGONS ARE NOT VALID!!!")
                    end

                    -- iterate through potential neighbours for both parent and child and discard all values which are not neighbours
                    for neighbour, _ in pairs(potential_neighbours) do
                        -- check if the neighbour is clipped by the pb of the child site
                        print("\nChecking neighbour : " .. neighbour)
                        
                        if check_if_polies_neighbours (neighbour, child_poly_id) then
                            print("Poly " .. neighbour .. " *IS* neighbour of poly " .. child_poly_id)
                        else
                            print("Poly " .. neighbour .. " is *NOT* neighbour of poly " .. child_poly_id)
                        end
                        
                        local temp_cnt1 = pbisector_intersect_with_poly(child_poly.site.x, child_poly.site.y, neighbour)
                        print("temp_cnt1 " .. #temp_cnt1)
                        if check_if_polies_neighbours (neighbour, child_poly_id) then
                            -- if  #temp_cnt1 == 4 then
                            -- add to the child's neighbour list. first check that a duplicate id doesnt exists
                                vpolies_Obj[child_poly_id].neighbours[neighbour] = true

                            -- and add a corresponding child poly id to the neighbour poly's own neighbour list
                                vpolies_Obj[neighbour].neighbours[child_poly_id] = true
                        else
                            print("Poly " .. neighbour .. " is *NOT* neighbour of poly " .. child_poly_id)
                        end
                            -- end

                        local temp_cnt2 = pbisector_intersect_with_poly(parent_poly.site.x, parent_poly.site.y, neighbour)
                        print("temp_cnt2 " .. #temp_cnt2)
                        if check_if_polies_neighbours (neighbour, parent_poly_id) then
                            -- if #temp_cnt2 == 4 then
                        
                                -- add to the parent's neighbour list. first check that a duplicate id doesnt exists
                                vpolies_Obj[parent_poly_id].neighbours[neighbour] = true
                                
                                -- and add a corresponding parent poly id to the neighbour poly's own neighbour list
                                vpolies_Obj[neighbour].neighbours[parent_poly_id] = true
                            -- end
                        else
                            print("Poly " .. neighbour .. " is *NOT* neighbour of poly " .. parent_poly_id)
                        end
                    end

                    -- parents and children are always neighbours of each other

                    vpolies_Obj[child_poly_id].neighbours[parent_poly_id] = true
                    vpolies_Obj[parent_poly_id].neighbours[child_poly_id] = true

                    print ( "Parent Polygon " .. parent_poly_id .. " Neighbours are: " .. inspect( vpolies_Obj[parent_poly_id].neighbours))
                    print ( "Child Polgygon " .. child_poly_id .. " Neighbours are: " .. inspect( vpolies_Obj[child_poly_id].neighbours))
                        
                    -- Lets fil the neighbour liens obj so we can draw it
                    neighbour_lines_obj = {}
                    for n, _ in pairs(vpolies_Obj[child_poly_id].neighbours) do
                        table.insert(neighbour_lines_obj, { vpolies_Obj[child_poly_id].site.x, vpolies_Obj[child_poly_id].site.y, vpolies_Obj[n].site.x, vpolies_Obj[n].site.y})
                    end
                        
                    -- now for the line joining the parent site with child site
                    last_parent_site = {vpoly.site.x, vpoly.site.y}
                    last_child_site = {sitex, sitey}
                    last_bisector_point = {Xm, Ym}

                    break
                end
            end
        end
    end
    

    -- print(inspect(temp_poly.poly_Obj:getPoints()))
end

function check_poly_non_neighbours (id1, id2)
    local result = false

    local rad1 = get_dist_to_most_distant_point(vpolies_Obj[id1].site.x, vpolies_Obj[id1].site.y, {vpolies_Obj[id1].poly_Obj:getPoints()})
    local rad2 = get_dist_to_most_distant_point(vpolies_Obj[id2].site.x, vpolies_Obj[id2].site.y, {vpolies_Obj[id2].poly_Obj:getPoints()})
    
    local site_dist = get_distance_between_2_Points(vpolies_Obj[id1].site.x, vpolies_Obj[id1].site.y, vpolies_Obj[id2].site.x, vpolies_Obj[id2].site.y)
    
    if site_dist > rad1 + rad2 then
        result = true
    end
    
    return result
end

function get_dist_to_most_distant_point (x, y, poly_points)
    local dmax = 0
    local xd, yd, d
    
    for i=1, #poly_points, 2 do
        d = get_distance_between_2_Points(x,y, poly_points[i],poly_points[i+1]) 
        if d >= dmax then
            dmax = d
            xd = poly_points[i]
            yd = poly_points[i+1]
        end
    end
    if dmax == 0 then print("DMAX IS ZERO!") end
    return dmax

end

function check_if_polies_neighbours (id1, id2)
    local result = false
    
    local poly1_sides = unpack_polygon(id1)
    local poly2_sides = unpack_polygon(id2)
    
    for _, poly1_side in pairs(poly1_sides) do
        for _, poly2_side in pairs(poly2_sides) do
            temp_result = check_if_line_seg_intersect(poly1_side.x1, poly1_side.y1, poly1_side.x2, poly1_side.y2, poly2_side.x1, poly2_side.y1, poly2_side.x2, poly2_side.y2)

            if temp_result then 
                result = true
                break 
            end
        end
    end
    return result
end

function check_if_line_seg_intersect(x1, y1, x2, y2, x3, y3, x4, y4) 

    local result = false

   d = (y4-y3)*(x2-x1)-(x4-x3)*(y2-y1)
   Ua_n = ((x4-x3)*(y1-y3)-(y4-y3)*(x1-x3))
   Ub_n = ((x2-x1)*(y1-y3)-(y2-y1)*(x1-x3))
   if d == 0 then
       --if Ua_n == 0 and Ua_n == Ub_n then
       --    return true
       --end
       return false
   end
   Ua = Ua_n / d
   Ub = Ub_n / d
   if Ua >= 0 and Ua <= 1 and Ub >= 0 and Ub <= 1 then
       return true
   end
   return false

end

function pbisector_intersect_with_poly (pointx, pointy, poly_id)


    xm, ym, bm, slope = get_perpendicular_bisector (vpolies_Obj[poly_id].site.x, vpolies_Obj[poly_id].site.y, pointx, pointy)
    -- print("Xm = " .. xm .. ", " .. "Ym = " .. ym .. ", " .. "Bm = " .. bm .. ", " .. "Slope = " .. slope)

    local poly_points = {vpolies_Obj[poly_id].poly_Obj:getPoints()}
    -- print ("\nParent poly points are: " , inspect(poly_points))
    -- local poly_sides = unpack_polygon (vpolies_Obj[poly_id].poly_Obj:getPoints())
    local poly_sides = unpack_polygon (poly_id)
    
    local clipping_line = {}
    
    -- for each side, find if intersect occurs
    for _, side in pairs(poly_sides) do
        -- print ("\nFor side ", side.x1, side.y1, side.x2, side.y2) 
        -- convert to line eqn
        local m, b = get_lineEqn_from_segment(side.x1, side.y1, side.x2, side.y2)
        -- print("Eqn of unpacked line is:")
        -- print("Y = ".. m .. "  X + " .. b)

        local clipping_point = get_lineEqn_intersection(xm, ym, slope, bm, m, b, side.x1, side.y1, side.x2, side.y2)
        if clipping_point[1] and clipping_point[2] then
            print("Clipping points are: [" .. clipping_point[1] .. ", " .. clipping_point[2] .. "]")
            -- print(inspect(clipping_point))
            table.insert(clipping_line, clipping_point[1])
            table.insert(clipping_line, clipping_point[2])
        end
    end
                
    return clipping_line

end

function get_random_color() 
    return love.math.random(0,255), love.math.random(0,255), love.math.random(0,255)
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

function unpack_polygon(id)
    local poly_points = {vpolies_Obj[id].poly_Obj:getPoints()}
    local sides = {}
    local px1, px2, py1, py2
    local starting_X = poly_points[1]
    local starting_Y = poly_points[2]

    if #poly_points % 2 ~= 0 then
        print("ERROR:: ODD NUMBER OF POINTS!!!!")
    else
    
        for i=1, #poly_points, 2 do 
            px1 = poly_points[i]
            py1 = poly_points[i+1]
            
            if poly_points[i+2] then
                px2 = poly_points[i+2]
            else
                px2 = starting_X
            end
            
            if poly_points[i+3] then
                py2 = poly_points[i+3]
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
    -- print(inspect(arg))
    
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
            iy = y1
            ix = Xm
            -- print(ix, iy)
            -- print("Scenario :  m1 = 0 and m2 = inf")
            
        -- m1 = inf and m2 = 0
        elseif (m == math.huge or m == -math.huge) and slope == 0 then
            iy = Ym
            ix = x1
            -- print(ix, iy)
            -- print("Scenario :  m1 = inf and m2 = 0")
            
        -- m1 = 0 and m2 = valid
        elseif m == 0 and (slope ~= math.huge or slope ~= -math.huge) then
            iy = y1
            ix = (iy - bm) / slope
            -- print(ix, iy)
            -- print("Scenario :  m1 = 0 and m2 = valid")
            
        -- m1 = valid and m2 = 0 --
        elseif (m ~= math.huge or m ~= -math.huge) and slope == 0 then
            iy = Ym
            ix = (iy - b) / m
            -- print(ix, iy)
            -- print("Scenario :  m1 = valid and m2 = 0")
            
        -- m1 = inf and m2 = valid
        elseif (m == math.huge or m == -math.huge) and  (slope ~= math.huge or slope ~= -math.huge) then
            ix = x1
            iy = (slope * ix) + bm
            -- print(ix, iy)
            -- print("Scenario :  m1 = inf and m2 = valid")
        
        -- m1 = valid and m2 = inf
        elseif (m ~= math.huge or m ~= -math.huge) and  (slope == math.huge or slope == -math.huge) then
            ix = Xm
            iy = (m * ix) + b
            -- print(ix, iy)
            -- print("Scenario :  m1 = valid and m2 = inf")
            
        -- m1 = valid and m2 = valid
        else
            ix = -( (b - bm)/(m - slope))
            iy = (slope * ix) + bm
            -- print(ix, iy)
            -- print("Scenario :  m1 = valid and m2 = valid")
        end
        -- print("Testing point : " .. ix, iy)
        
        local minx, miny, maxx, maxy
        minx = math.min(x1, x2)
        maxx = math.max(x1, x2)
        
        miny = math.min(y1, y2)
        maxy =math.max(y1, y2)
        
        -- if (x1 <= ix and ix <= x2) or (x2 <= ix and ix <= x1) then
        if (0 <= ix) and (0 <= iy) and (minx <= ix and ix <= maxx) and (miny <= iy and iy <= maxy) then
            -- print("Found Intersection!")
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
        -- print("Polymaking. Checking point " , poly_points[i], poly_points[i+1])
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

function get_unique_random_str()
    local length = 8
	local str = string.char(math.random(97, 122))
	for i = 1, length-1 do
        local pool = math.random(1,3)
        
        if pool == 1 then
            str = str..string.char(math.random(48, 57))
        elseif pool == 2 then
            str = str..string.char(math.random(65, 90))
        elseif pool ==3 then
            str = str..string.char(math.random(97, 122))
        end

	end

       
    if id_list[str] == nil then
        id_list[str] = true  
        return str;
    else
        get_unique_random_str()
    end
end
