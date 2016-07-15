debug = true

local inspect = require "inspect"

local vpolies_Count = 0
local vpolies_Obj = {}
local window_intercept
local pbisector_line
local last_parent_site, last_child_site, last_bisector_point
local neighbour_lines_obj
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
                love.graphics.setColor(50,50,50)    
                love.graphics.setPointSize(3)
                love.graphics.points(vpoly.site.x, vpoly.site.y)
                love.graphics.print(vpoly.site.x .. ", " .. vpoly.site.y .. " : @ ".. id, vpoly.site.x - 30, vpoly.site.y - 30 )
                

            else
                print("POLY IS CONCAVE!! RUN!!")
            end
        end
    end   
    
    if last_parent_site then
        love.graphics.setColor(255, 255, 255)
        love.graphics.line(last_parent_site[1], last_parent_site[2], last_child_site[1], last_child_site[2])
        love.graphics.points(last_bisector_point[1], last_bisector_point[2])
    end
    
    if window_intercept then

        love.graphics.setColor(255, 255, 255)
        love.graphics.line(window_intercept.x1, window_intercept.y1, window_intercept.x2, window_intercept.y2)
        love.graphics.print(window_intercept.x1 .. ", " .. window_intercept.y1, window_intercept.x1 - 30, window_intercept.y1 - 30 )
        love.graphics.print(window_intercept.x2 .. ", " .. window_intercept.y2, window_intercept.x2 - 30, window_intercept.y2 - 30 )
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
        add_to_vpolies_Obj(x, y)
        print("\nID list is: " , inspect(id_list))
        print ("Poly List are : ")
        for id, vpoly in pairs(vpolies_Obj) do
           print("Poly " .. id .. " has neighbours " .. inspect(vpoly.neighbours))
       end
    end
    
    if button == 2 then
         for id, vpoly in pairs(vpolies_Obj) do
            if vpoly.poly_Obj:testPoint( 0, 0, 0, x, y ) then
                print("\n++++++++++++++++++++++++")
                print("Right clicked on Ploygon ", id)
                print ("\nIts Site is ..." , vpoly.site.x, vpoly.site.y)
                print ("\nIts neighbours are ...")
                print (inspect(vpoly.neighbours))
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
        connecting_line = nil
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
                print("It has neighbours : " .. inspect(vpoly.neighbours))
                print("Getting Perpendicular Bisector between : " .. vpoly.site.x .. ", ".. vpoly.site.y .. " & " .. sitex .. ", " .. sitey)
                xm, ym, bm, slope = get_perpendicular_bisector (vpoly.site.x, vpoly.site.y, sitex, sitey)
                print("Xm = " .. xm .. ", " .. "Ym = " .. ym .. ", " .. "Bm = " .. bm .. ", " .. "Slope = " .. slope)

                window_intercept = get_window_intercept_of_line(ym, slope, xm, bm)

                local poly_points = {vpoly.poly_Obj:getPoints()}
                print ("\nParent poly points are: " , inspect(poly_points))
                local poly_sides = unpack_polygon (vpoly.poly_Obj:getPoints())
                
                pbisector_line = {}
                
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
                        table.insert(pbisector_line, clipping_point[1])
                        table.insert(pbisector_line, clipping_point[2])
                    end
                end
                
                
                -- split parent poly
                        
                local poly_points = {vpoly.poly_Obj:getPoints()}
                
                print("Splitting the Polygon with points...", inspect(poly_points))
                local split_poly1_points = {}
                local split_poly2_points = {}
                
                split_poly1_points, split_poly2_points = split_polygon  (poly_points, pbisector_line[1], pbisector_line[2], pbisector_line[3], pbisector_line[4])
                
                print("POLY 1 vertices are: ", inspect(split_poly1_points))
                print("POLY 2 vertices are: ", inspect(split_poly2_points))
                
                local parent_poly_id, child_poly_id
                local parent_poly = {}
                local child_poly = {}
                
                
                parent_poly_id = id
                child_poly_id = get_unique_random_str()
            
                parent_poly.site = vpoly.site
                child_poly.site = {x = sitex, y = sitey}
                
                parent_poly.color = vpoly.color
                child_poly.color = {get_random_color()}
                
                parent_poly.neighbours = vpoly.neighbours
                child_poly.neighbours = {}
                
                -- parents and children are always neighbours of each other
                table.insert(parent_poly.neighbours, child_poly_id)
                table.insert(child_poly.neighbours, parent_poly_id)
                
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

                    

                
                

                
                local potential_parent_neighbours = vpoly.neighbours
                local potential_child_neighbours = vpoly.neighbours
                print(potential_child_neighbours)
                -- iterate through potential neighbours for bot parent and child and discard all values which are not neighbours
                if next(potential_child_neighbours) then
                
                    print("Potential Neighbours of child polygon are: ")
                    for i, neighbour in ipairs(potential_child_neighbours) do
                        
                        print(neighbour)
                        
                        
                        
                    end
                end
                -- for i, neighbour in ipairs(potential_child_neighbours) do
                
                -- end
                
                -- then add the parent to child and child to parents neighbours list
                -- now we check if ech potential neighbour is actualy a neighbour (has line intersection or shared side) or not
                -- if yes, then add it to the neighbours list for current pol
                
                    

                
                
                -- if find neighbour also update neighbours so that it gets current pol in neighbors list
                -- repeat task with all neighbouring polies which share a side with parent poly
                
                
                
                -- we will also need to update the neighbors list for the parent poly. it might have lost some.
                
                print ( "Parent Polygon's Neighbours are: " .. inspect( vpolies_Obj[parent_poly_id].neighbours))
                print ( "Child Polgygon's Neighbours are: " .. inspect( vpolies_Obj[child_poly_id].neighbours))
                    
                    
                -- now for the line joiing the parent site with child site
                last_parent_site = {vpoly.site.x, vpoly.site.y}
                last_child_site = {sitex, sitey}
                last_bisector_point = {Xm, Ym}
                    
                -- Add neighbours to neighbour_lines_obj so we can draw them
                
                
                
                -- check if the new plies are valid and if yes, then add them to the main poly object


                -- find neighbours of the new poly and add to dataset
                
                

                
                
                break
            end
        end
    end
    

    -- print(inspect(temp_poly.poly_Obj:getPoints()))
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
