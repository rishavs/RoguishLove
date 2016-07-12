debug = true

local inspect = require "inspect"

local vpolies_Count = 0
local vpolies_Obj = {}
local window_intercept
local pbisector_line, connecting_line
local last_parent_site, last_child_site, last_bisector_point
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
    love.graphics.print(mousex .. ", " .. mousey, mousex -30, mousey -30)
end

function love.update(dt)
    mousex, mousey = love.mouse.getPosition()
end
function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        -- add_to_points_Obj(x, y)
        add_to_vpolies_Obj(x, y)
        print("ID list is: " , inspect(id_list))
        print ("Poly List are : ")
        for id, vpoly in pairs(vpolies_Obj) do
           print(id)
       end
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
            neighbour_indices = {}
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
                print("Getting Perpendicular Bisector between : " .. vpoly.site.x .. ", ".. vpoly.site.y .. " & " .. sitex .. ", " .. sitey)
                xm, ym, bm, slope = get_perpendicular_bisector (vpoly.site.x, vpoly.site.y, sitex, sitey)
                print(xm, ym, bm, slope)
                print("Y = ".. slope .. "  X + " .. bm.. "\n")
                window_intercept = get_window_intercept_of_line(ym, slope, xm, bm)

                local poly_points = {vpoly.poly_Obj:getPoints()}
                print ("Parent poly points are: " , inspect(poly_points))
                local poly_sides = unpack_polygon (vpoly.poly_Obj:getPoints())
                
                connecting_line = {}
                
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
                        table.insert(connecting_line, clipping_point[1])
                        table.insert(connecting_line, clipping_point[2])
                    end
                end
                
                
                -- split parent poly
                        
                local poly_points = {vpoly.poly_Obj:getPoints()}
                
                print("Splitting the Polygon with points...", inspect(poly_points))
                local child_poly1_points = {}
                local child_poly2_points = {}
                
                child_poly1_points, child_poly2_points = split_polygon  (poly_points, connecting_line[1], connecting_line[2], connecting_line[3], connecting_line[4])
                
                print("POLY 1 is ", inspect(child_poly1_points))
                print("POLY 2 is ", inspect(child_poly2_points))
                    
                temp_id1 = get_unique_random_str()
                temp_id2 = get_unique_random_str()
                
                print("Temp ids are: ", temp_id1, temp_id2)
                
                -- add polies to the poly object
                temp_poly1 = { 
                    index = vpolies_Count,
                    site = {x=sitex, y=sitey},
                    color =  {get_random_color()},
                    poly_Obj =  love.physics.newPolygonShape ( child_poly1_points ),
                    neighbour_indices = {}
                }                
                
                temp_poly2 = { 
                    index = vpolies_Count,
                    site = {x=sitex, y=sitey},
                    color =  {get_random_color()},
                    poly_Obj =  love.physics.newPolygonShape  ( child_poly2_points ),
                    neighbour_indices = {}
                }
                -- now check in wich polygon does the parent site lies 
                local temp1 = get_side_of_line(connecting_line[1], connecting_line[2], connecting_line[3], connecting_line[4], vpoly.site.x, vpoly.site.y)
                if  temp1 == 1 then
                    temp_poly1.site = vpoly.site
                    temp_poly2.site = {x = sitex, y = sitey}
                elseif temp1 == -1 then
                    temp_poly1.site = {x = sitex, y = sitey}
                    temp_poly2.site = vpoly.site
                elseif temp1 == 0 then
                    print("Parent site lies on bisector line??!! what nonsense!")
                end
                
                -- check if the new plies are valid and if yes, then add them to the main poly object
                if  temp_poly1.poly_Obj:validate( ) and temp_poly1.poly_Obj:validate( ) then
                -- reomve parent polygon
                    print("Removing Parent poly : ", id)
                    vpolies_Obj[id] = nil
                    id_list[id] = nil
                    
                --insert into poly object
                    vpolies_Obj[temp_id1] = temp_poly1
                    vpolies_Obj[temp_id2] = temp_poly2
                -- now for the line joiing the parent site witrh child site
                    last_parent_site = {vpoly.site.x, vpoly.site.y}
                    last_child_site = {sitex, sitey}
                    last_bisector_point = {Xm, Ym}

                -- merge with new poly
                else
                    print ("SPLIT POLYGONS ARE NOT VALID!!!")
                end
                

                -- find neighbours of the new poly and add to dataset
                
                -- repeat task with all neighbouring polies which share a side with parent poly
                
                
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
            print(ix, iy)
            print("Scenario :  m1 = 0 and m2 = inf")
            
        -- m1 = inf and m2 = 0
        elseif (m == math.huge or m == -math.huge) and slope == 0 then
            iy = Ym
            ix = x1
            print(ix, iy)
            print("Scenario :  m1 = inf and m2 = 0")
            
        -- m1 = 0 and m2 = valid
        elseif m == 0 and (slope ~= math.huge or slope ~= -math.huge) then
            iy = y1
            ix = (iy - bm) / slope
            print(ix, iy)
            print("Scenario :  m1 = 0 and m2 = valid")
            
        -- m1 = valid and m2 = 0 --
        elseif (m ~= math.huge or m ~= -math.huge) and slope == 0 then
            iy = Ym
            ix = (iy - b) / m
            print(ix, iy)
            print("Scenario :  m1 = valid and m2 = 0")
            
        -- m1 = inf and m2 = valid
        elseif (m == math.huge or m == -math.huge) and  (slope ~= math.huge or slope ~= -math.huge) then
            ix = x1
            iy = (slope * ix) + bm
            print(ix, iy)
            print("Scenario :  m1 = inf and m2 = valid")
        
        -- m1 = valid and m2 = inf
        elseif (m ~= math.huge or m ~= -math.huge) and  (slope == math.huge or slope == -math.huge) then
            ix = Xm
            iy = (m * ix) + b
            print(ix, iy)
            print("Scenario :  m1 = valid and m2 = inf")
            
        -- m1 = valid and m2 = valid
        else
            ix = -( (b - bm)/(m - slope))
            iy = (slope * ix) + bm
            print(ix, iy)
            print("Scenario :  m1 = valid and m2 = valid")
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
