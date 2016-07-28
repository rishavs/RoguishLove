debug = true

local inspect = require "inspect"

local vpolies_Count = 0
local vpolies_Obj = {}

local neighbour_lines_obj = {}
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
    


    if next(neighbour_lines_obj) then
        love.graphics.setColor(0, 0, 0)
        for _, line in pairs(neighbour_lines_obj) do
            love.graphics.line(line[1], line[2], line[3], line[4])
            love.graphics.setPointSize(4)
            love.graphics.points((line[1] + line[3]) / 2, (line[2] + line[4]) / 2)
        end
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

        local stime =  love.timer.getTime()
        add_to_vpolies_Obj(x, y)
        print("NEW SITE ADDED in t = %.3f ms"  ,  (love.timer.getTime() - stime)*1000)

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
  
    elseif key == "escape" then
       love.event.quit()
    end

 end
--------------------------------------------------------------------

function add_to_vpolies_Obj(sitex, sitey)
    
    vpolies_Count = vpolies_Count + 1

    
    -- If this is the very first site
    if next(vpolies_Obj) == nil then
        vpolies_Obj[get_unique_random_str()] = { 
            index = vpolies_Count,
            site = {x = sitex, y = sitey},
            color =  {get_random_color()},
            poly_Obj =  love.physics.newPolygonShape ( 
                0,0,
                love.graphics.getWidth(), 0, 
                love.graphics.getWidth(), love.graphics.getHeight(), 
                0, love.graphics.getHeight() 
            ),
            neighbours = {}
        }
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

                    -- parents and children are always neighbours of each other
                    vpolies_Obj[child_poly_id].neighbours[parent_poly_id] = true
                    vpolies_Obj[parent_poly_id].neighbours[child_poly_id] = true
                    
                    -- iterate through potential neighbours for both parent and child and discard all values which are not neighbours
                    for neighbour, _ in pairs(potential_neighbours) do

                    -- check if the neighbour is clipped by the pb of the child site
                        print("\nxxxxxxxxxxxxxxxxxxxxxx\n")
                        print("Checking neighbour : " .. neighbour)
                        print("\nxxxxxxxxxxxxxxxxxxxxxx\n")
                        
                        if check_if_polies_neighbours (neighbour, child_poly_id) then
                            print("\nPoly " .. neighbour .. " *IS* neighbour of poly " .. child_poly_id)
                            
                        -- add to the child's neighbour list. first check that a duplicate id doesnt exists
                            vpolies_Obj[child_poly_id].neighbours[neighbour] = true

                        -- and add a corresponding child poly id to the neighbour poly's own neighbour list
                            vpolies_Obj[neighbour].neighbours[child_poly_id] = true
                            
                        else
                            print("\nPoly " .. neighbour .. " is *NOT* neighbour of poly " .. child_poly_id)
                        end

                        if check_if_polies_neighbours (neighbour, parent_poly_id) then
                            print("Poly " .. neighbour .. " *IS* neighbour of poly " .. parent_poly_id)
                            
                            -- add to the parent's neighbour list. first check that a duplicate id doesnt exists
                            vpolies_Obj[parent_poly_id].neighbours[neighbour] = true
                            
                            -- and add a corresponding parent poly id to the neighbour poly's own neighbour list
                            vpolies_Obj[neighbour].neighbours[parent_poly_id] = true

                        else
                            print("Poly " .. neighbour .. " is *NOT* neighbour of poly " .. parent_poly_id)
                        end
                    end


                    print ( "Parent Polygon " .. parent_poly_id .. " Neighbours are: " .. inspect( vpolies_Obj[parent_poly_id].neighbours))
                    print ( "Child Polgygon " .. child_poly_id .. " Neighbours are: " .. inspect( vpolies_Obj[child_poly_id].neighbours))
                        
                    -- Lets fil the neighbour liens obj so we can draw it
                    neighbour_lines_obj = {}
                    for n, _ in pairs(vpolies_Obj[child_poly_id].neighbours) do
                        table.insert(neighbour_lines_obj, { vpolies_Obj[child_poly_id].site.x, vpolies_Obj[child_poly_id].site.y, vpolies_Obj[n].site.x, vpolies_Obj[n].site.y})
                    end
                        
                    break
                end
            end
        end
    end
    

    -- print(inspect(temp_poly.poly_Obj:getPoints()))
end

function get_random_color() 
    return love.math.random(0,255), love.math.random(0,255), love.math.random(0,255)
end

function round(num, dp)
  local mult = 10^(dp or 0)
  return (math.floor(num * mult + 0.5)) / mult
end

function equals( x, y, delta )
    return math.abs( x - y ) <= ( delta or 0.01 )
end

function get_perpendicular_bisector(x1, y1, x2, y2) 
    -- mid point calclulation
    xm = (x1+x2)/2
    ym = (y1+y2)/2
    
    -- slope
    slope = -(x2-x1)/(y2-y1)
    
    bm = ym - (slope * xm)
    return round(xm), round(ym), bm, slope
end


function get_lineEqn_from_segment (x1, y1, x2, y2)
        m = (y2-y1)/(x2-x1)
        
        b = y1 - (m * x1)
        -- print("The Line eqn for points ".. "[" .. x1 .. ", " .. y1 .. "] & [" .. x2 .. ", " .. y2 .. "]")
        -- print("m = " .. m .. ", b = " .. b)
    return m, b
end

function check_if_polies_neighbours (id1, id2)
    local result = false
    
    local poly1_sides = unpack_polygon(id1)
    local poly2_sides = unpack_polygon(id2)
    
    for _, poly1_side in pairs(poly1_sides) do
        for _, poly2_side in pairs(poly2_sides) do
           
           local line1 = {
                seg = true,
                P1x = poly1_side.x1,
                P1y = poly1_side.y1, 
                P2x = poly1_side.x2,
                P2y = poly1_side.y2
            }
            line1.m, line1.b = get_lineEqn_from_segment (poly1_side.x1, poly1_side.y1, poly1_side.x2, poly1_side.y2)
            
            local line2 = {
                seg = true,
                P1x = poly2_side.x1,
                P1y = poly2_side.y1,
                P2x = poly2_side.x2,
                P2y = poly2_side.y2
            }
            line2.m, line2.b = get_lineEqn_from_segment (poly2_side.x1, poly2_side.y1, poly2_side.x2, poly2_side.y2)
            
            temp_result = get_line_intersection (line1, line2)
            print("Checking poly ".. id1 .. " side : " .. poly1_side.x1 ..", " .. poly1_side.y1 .. " :: " .. poly1_side.x2 .. ", " .. poly1_side.y2)
            print("Checking poly ".. id2 .. " side : " .. poly2_side.x1 ..", " .. poly2_side.y1 .. " :: " .. poly2_side.x2 .. ", " .. poly2_side.y2)
            
            if temp_result.intersection == true then
                print("Sides Intersect! \n")
            else
                print("Sides DONT Intersect! \n")
            end
            
            if temp_result.intersection == true then 
                result = true
                -- break 
            end
        end
    end
    return result
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
        
       local line1 = {
            seg = false,
            Tx = xm,
            Ty = ym
        }
        line1.m, line1.b = slope, bm
        
        local line2 = {
            seg = true,
            P1x = side.x1,
            P1y = side.y1,
            P2x = side.x2,
            P2y = side.y2
        }
        
        line2.m, line2.b = get_lineEqn_from_segment (side.x1, side.y1, side.x2, side.y2)
        
        local intersection = get_line_intersection (line1, line2)
        
        if intersection.intersection == true and intersection.colinear ~= true then
        
            print("Clipping points are: [" .. intersection.ix .. ", " .. intersection.iy .. "]")

            table.insert(clipping_line, intersection.ix)
            table.insert(clipping_line, intersection.iy)
        end
    end
                
    return clipping_line

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
                x1 = round(px1),
                y1 = round(py1),
                x2 = round(px2),
                y2 = round(py2)
            })
        end
    end
    -- print(inspect(arg))
    
    return sides
end


function get_line_intersection (lineA, lineB)

    local Ax, Ay, d
    
    -- m1= Am, m2 = Bm
    local Am, Ab = lineA.m, lineA.b
    local Bm, Bb = lineB.m, lineB.b
    
    -- For this function to work, both lines need at least one defined point in them. This is the testing point Tx, Ty
    -- for segments, we can take either of the points as Testing Points
    --Lets define testing points for line A
    if lineA.seg == true then
        Ax = lineA.P1x
        Ay = lineA.P1y
    else
        Ax = lineA.Tx
        Ay = lineA.Ty
    end
    
    -- And line B
    if lineB.seg == true then
        Bx = lineB.P1x
        By = lineB.P1y
    else
        Bx = lineB.Tx
        By = lineB.Ty
    end
    
    -- Finding the min and max of the two points. This is used for checking if a point falls in a line.
    local minAx, minAy, maxAx, maxAy, minBx, minBy, maxBx, maxBy
    
    if lineA.seg == true and lineB.seg == true then
    
        minAx = math.min(lineA.P1x, lineA.P2x)
        maxAx = math.max(lineA.P1x, lineA.P2x)        
        minAy = math.min(lineA.P1y, lineA.P2y)
        maxAy = math.max(lineA.P1y, lineA.P2y)        

        minBx = math.min(lineB.P1x, lineB.P2x)
        maxBx = math.max(lineB.P1x, lineB.P2x)
        minBy = math.min(lineB.P1y, lineB.P2y)
        maxBy = math.max(lineB.P1y, lineB.P2y)

    elseif lineA.seg == false and lineB.seg == true then

        minAx = 0
        maxAx = math.huge
        minAy = 0
        maxAy = math.huge

        minBx = math.min(lineB.P1x, lineB.P2x)
        maxBx = math.max(lineB.P1x, lineB.P2x)
        minBy = math.min(lineB.P1y, lineB.P2y)
        maxBy = math.max(lineB.P1y, lineB.P2y)
        
    elseif lineA.seg == true and lineB.seg == false then

        minAx = math.min(lineA.P1x, lineA.P2x)
        maxAx = math.max(lineA.P1x, lineA.P2x)        
        minAy = math.min(lineA.P1y, lineA.P2y)
        maxAy = math.max(lineA.P1y, lineA.P2y)        

        minBx = 0
        maxBx = math.huge
        minBy = 0
        maxBy = math.huge
        
    elseif lineA.seg == false and lineB.seg == false then
        
        minAx = 0
        maxAx = math.huge
        minAy = 0
        maxAy = math.huge
        
        minBx = 0
        maxBx = math.huge
        minBy = 0
        maxBy = math.huge
        
    else
        print("Some error with the line.seg attribute")
        return {intersection = false}
    end
    
    
    -- First lets test for colinear and parallel lines
    if Am == Bm or Am == -Bm then
        print("Parallel Lines")
        
        -- test for colinear lines
        if Am == 0 and Bm == 0 then
            print("Scenario :  Am = Bm = 0")
            
            -- here both have same y intercept
            if Ay == By then

                if lineA.seg == true and lineB.seg == true then
                    -- if both lines are segments, there is a chance they lie side by side
                    -- check if the points for any line lie between the bounding points of the other line
                    if ( 
                        (minAx <= minBx and minBx <= maxAx)
                        or (minAx <= maxBx and maxBx <= maxAx)
                        or (minBx <= minAx and minAx <= maxBx)
                        or (minBx <= maxAx and maxAx <= maxBx)
                        ) then
                        print("Colinear Lines")
                        return {intersection = true, colinear = true}
                    else
                        print("Non Colinear Lines")
                        print("Lines lie Side by Side")
                        return {intersection = false}
                    end
                else
                    -- if either of the lines is not a segment, then they will definitely be collinear
                    print("Colinear Lines")
                    return {intersection = true, colinear = true}
                end
            else
                print("Non Colinear Lines")
                return {intersection = false}
            end
            
        elseif (Am == math.huge or Am == -math.huge) and (Bm == math.huge or Bm == -math.huge) then
            print("Scenario :  Am = Bm = inf")
            
            -- here both have same x intercept
            if Ax == Bx then
            
                if lineA.seg == true and lineB.seg == true then
                    -- if both lines are segments, there is a chance they lie side by side
                    -- check if the points for any line lie between the bounding points of the other line
                    if ( 
                        (minAy <= minBy and minBy <= maxAy)
                        or (minAy <= maxBy and maxBy <= maxAy)
                        or (minBy <= minAy and minAy <= maxBy)
                        or (minBy <= maxAy and maxAy <= maxBy)
                        ) then
                        print("Colinear Lines")
                        return {intersection = true, colinear = true}
                    else
                        print("Non Colinear Lines")
                        print("Lines lie Side by Side")
                        return {intersection = false}
                    end
                else
                    -- if either of the lines is not a segment, then they will definitely be collinear
                    print("Colinear Lines")
                    return {intersection = true, colinear = true}
                end
            else
                print("Non Colinear Lines")
                return {intersection = false}
            end
            
        else 
            print("Scenario :  Am = Bm = valid")
            print("Am = ", Am)
            print("Bm = ", Bm)
            print("Ab = ", Ab)
            print("Bb = ", Bb)
            -- local d = round((math.abs(Bb - Ab)) / (math.sqrt((Bm * Bm) + 1)))
            -- print("d = ", d)
            if Ab == Bb then
                if lineA.seg == true and lineB.seg == true then
                    -- if both lines are segments, there is a chance they lie side by side
                    -- check if the points for any line lie between the bounding points of the other line
                    if ( 
                        (minAx <= minBx and minBx <= maxAx)
                        or (minAx <= maxBx and maxBx <= maxAx)
                        or (minBx <= minAx and minAx <= maxBx)
                        or (minBx <= maxAx and maxAx <= maxBx)
                        )
                        and
                        (
                        (minAy <= minBy and minBy <= maxAy)
                        or (minAy <= maxBy and maxBy <= maxAy)
                        or (minBy <= minAy and minAy <= maxBy)
                        or (minBy <= maxAy and maxAy <= maxBy)
                        ) then
                        print("Colinear Lines")
                        return {intersection = true, colinear = true}
                    else
                        print("Non Colinear Lines")
                        print("Lines lie Side by Side")
                        return {intersection = false}
                    end
                else
                    -- if either of the lines is not a segment, then they will definitely be collinear
                    print("Colinear Lines")
                    return {intersection = true, colinear = true}
                end
            else
                print("Non Colinear Lines")
                return {intersection = false}
            end
        end
        
    else
        -- print("Non parallel lines")
        
        -- Am = 0 and Bm = inf
        if Am == 0 and (Bm == math.huge or Bm == -math.huge) then
            print("Scenario :  Am = 0 and Bm = inf")
            
            iy = Ay
            ix = Bx
            -- print(ix, iy)
            
        -- Am = inf and Bm = 0
        elseif (Am == math.huge or Am == -math.huge) and Bm == 0 then
            print("Scenario :  Am = inf and Bm = 0")
            
            iy = By
            ix = Ax
            -- print(ix, iy)
            
        -- Am = 0 and Bm = valid
        elseif Am == 0 and (Bm ~= math.huge or Bm ~= -math.huge) then
            print("Scenario :  Am = 0 and Bm = valid")
            
            iy = Ay
            ix = (iy - Bb) / Bm
            -- print(ix, iy)
            
        -- Am = valid and Bm = 0 
        elseif (Am ~= math.huge or Am ~= -math.huge) and Bm == 0 then
            print("Scenario :  Am = valid and Bm = 0")

            iy = By
            ix = (iy - Ab) / Am
            -- print(ix, iy)
            
        -- Am = inf and Bm = valid
        elseif (Am == math.huge or Am == -math.huge) and  (Bm ~= math.huge or Bm ~= -math.huge) then
            print("Scenario :  Am = inf and Bm = valid")

            ix = Ax
            iy = (Bm * ix) + Bb
            -- print(ix, iy)
        
        -- Am = valid and Bm = inf
        elseif (Am ~= math.huge or Am ~= -math.huge) and  (Bm == math.huge or Bm == -math.huge) then
            print("Scenario :  Am = valid and Bm = inf")

            ix = Bx
            iy = (Am * ix) + Ab
            -- print(ix, iy)
            
        -- Am = valid and Bm = valid
        elseif  (Am ~= math.huge or Am ~= -math.huge) and  (Bm ~= math.huge or Bm ~= -math.huge) then
            print("Scenario :  Am = valid and Bm = valid")
            print("Am = ", Am)
            print("Bm = ", Bm)
            
            ix = -( (Bb - Ab)/(Bm - Am))
            iy = (Bm * ix) + Bb            
            -- print(ix, iy)

        else
            print("WHAT IS THIS I CANT EVEN!")
            print("UNHANDLED SCENARIO ALERT!!!")
        end
        
        
        -- Now that we have the Intersection points ix and iy, we need to check if they fall on the lines
        -- for lines, the intersection points just being +ve is sufficient
        -- for the intersection point to be valid, it should fall on both the lines
        -- for the intersection point to be valid, it should fall on both the lines
        if (
            (minAx <= ix and ix <= maxAx) 
            and (minBx <= ix and ix <= maxBx) 
            and (minAy <= iy and iy <= maxAy) 
            and (minBy <= iy and iy <= maxBy) 
            ) then
            print("Found Intersection!")
            return {intersection = true, colinear = false, ix = round(ix), iy = round(iy)}
        else
            -- print("Found NO Intersection!")
            return {intersection = false}
        end
        
    end

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
    table.insert(poly1_points,  round(x1))
    table.insert(poly1_points,  round(y1))   
    table.insert(poly1_points,  round(x2))
    table.insert(poly1_points,  round(y2))
    
    table.insert(poly2_points,  round(x1))
    table.insert(poly2_points,  round(y1))
    table.insert(poly2_points,  round(x2))
    table.insert(poly2_points,  round(y2))
    
    return poly1_points, poly2_points
end

function get_side_of_line(x1, y1, x2, y2, xt, yt)
    
    local value = round(((x2 - x1)*(yt - y1)) - ((xt - x1)*(y2 - y1)))

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
