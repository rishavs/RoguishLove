debug = true
local points = {}

function love.load(arg)

end

function love.draw(dt)

    if #points == 4 then
        love.graphics.line(points[1].x, points[1].y, points[2].x, points[2].y)
        love.graphics.line(points[3].x, points[3].y, points[4].x, points[4].y)
    elseif #points==2 or #points == 3 then
        love.graphics.line(points[1].x, points[1].y, points[2].x, points[2].y)
    end
    
    for _, point in pairs(points) do
        love.graphics.setPointSize(5)
        love.graphics.points(point.x, point.y)
        love.graphics.print(point.x .. ", " .. point.y, point.x-30, point.y-30)
    end
    
    local mousex, mousey =  love.mouse.getPosition( )
    love.graphics.print(mousex .. ", " .. mousey, mousex -30, mousey -30)
end

function love.update(dt)

end

function love.mousepressed(x, y, button, istouch)
    if button == 1 then
        if #points < 4 then
            table.insert(points, {x=x, y=y})
            
            if #points == 4 then

                int2 = get_lineEqn_intersection (
                    points[1].x, points[1].y, 
                    points[2].x, points[2].y, 
                    points[3].x, points[3].y, 
                    points[4].x, points[4].y
                )                
                
                local line1 = {
                    seg = true,
                    P1x = points[1].x,
                    P1y = points[1].y, 
                    P2x = points[2].x,
                    P2y = points[2].y
                }
                line1.m, line1.b = get_lineEqn_from_segment (line1.P1x, line1.P1y, line1.P2x, line1.P2y)
                
                local line2 = {
                    seg = true,
                    P1x = points[3].x,
                    P1y = points[3].y, 
                    P2x = points[4].x,
                    P2y = points[4].y
                }
                line2.m, line2.b = get_lineEqn_from_segment (line2.P1x, line2.P1y, line2.P2x, line2.P2y)
                
                int1 = get_line_intersection (line1, line2)
                
                print("Intersection using LINE check??" )
                if int1.intersection == true then
                    print(int1.intersection, int1.colinear, int1.ix, int1.iy)
                else
                    print("false")
                end
                print("\n   ooo                ooo  \n")
                
                int2 = get_lineEqn_intersection (
                    points[1].x, points[1].y, 
                    points[2].x, points[2].y, 
                    points[3].x, points[3].y, 
                    points[4].x, points[4].y
                )

                print("Intersection using SEG check??" )
                if int2.result == true then
                    print(int2.result, int2.ix, int2.iy)
                else
                    print("false")
                end
                print("--------------------------------------------------")
            end
        else
            points = {}
            table.insert(points, {x=x, y=y})
        end
    end
end

local Line = {
    seg = true,
    m = 10,
    b = 5, 
    Tx = 100, -- test point which lies on this line
    Ty = 200, 
    P1x = 10, 
    P1y = 10, 
    P2x = 10, 
    P2y = 10
}

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
    
    -- First lets test for colinear and parallel lines
    if Am == Bm or Am == -Bm then
        print("Parallel Lines")
        
        -- test for colinear lines
        if Am == 0 and Bm == 0 then
            print("Scenario :  Am = Bm = 0")
            
            if Ay == By then
                print("Colinear Lines")
                return {intersection = true, colinear = true}
            else
                print("Non Colinear Lines")
                return {intersection = false}
            end
            
        elseif (Am == math.huge or Am == -math.huge) and (Bm == math.huge or Bm == -math.huge) then
            print("Scenario :  Am = Bm = inf")
            
            if Ax == Bx then
                print("Colinear")
                return {intersection = true, colinear = true}
            else
                print("Non Colinear Lines")
                return {intersection = false}
            end
            
        else 
            print("Scenario :  Am = Bm = valid")
            
            d = (math.abs(Bb - Ab)) / (math.sqrt((Bm * Bm) + 1))
            
            if d == 0 then
                print("Colinear")
                return {intersection = true, colinear = true}
            else
                print("Non Colinear Lines")
                return {intersection = false}
            end
        end
        
    else
        print("Non parallel lines")
        
        -- Am = 0 and Bm = inf
        if Am == 0 and (Bm == math.huge or Bm == -math.huge) then
            print("Scenario :  Am = 0 and Bm = inf")
            
            iy = Ay
            ix = Bx
            print(ix, iy)
            
        -- Am = inf and Bm = 0
        elseif (Am == math.huge or Am == -math.huge) and Bm == 0 then
            print("Scenario :  Am = inf and Bm = 0")
            
            iy = By
            ix = Ax
            print(ix, iy)
            
        -- Am = 0 and Bm = valid
        elseif Am == 0 and (Bm ~= math.huge or Bm ~= -math.huge) then
            print("Scenario :  Am = 0 and Bm = valid")
            
            iy = Ay
            ix = (iy - Bb) / Bm
            print(ix, iy)
            
        -- Am = valid and Bm = 0 
        elseif (Am ~= math.huge or Am ~= -math.huge) and Bm == 0 then
            print("Scenario :  Am = valid and Bm = 0")

            iy = By
            ix = (iy - Ab) / Am
            print(ix, iy)
            
        -- Am = inf and Bm = valid
        elseif (Am == math.huge or Am == -math.huge) and  (Bm ~= math.huge or Bm ~= -math.huge) then
            print("Scenario :  Am = inf and Bm = valid")

            ix = Ax
            iy = (Bm * ix) + Bb
            print(ix, iy)
        
        -- Am = valid and Bm = inf
        elseif (Am ~= math.huge or Am ~= -math.huge) and  (Bm == math.huge or Bm == -math.huge) then
            print("Scenario :  Am = valid and Bm = inf")

            ix = Bx
            iy = (Am * ix) + Ab
            print(ix, iy)
            
        -- Am = valid and Bm = valid
        elseif  (Am ~= math.huge or Am ~= -math.huge) and  (Bm ~= math.huge or Bm ~= -math.huge) then
            print("Scenario :  Am = valid and Bm = valid")

            ix = -( (Bb - Ab)/(Bm - Am))
            iy = (Bm * ix) + Bb            
            print(ix, iy)

        else
            print("WHAT IS THIS I CANT EVEN!")
            print("UNHANDLED SCENARIO ALERT!!!")
        end
        
        -- Now that we have the Intersection points ix and iy, we need to check if they fall on the lines
        -- for lines, the intersection points just being +ve is sufficient
        local minAx, minAy, maxAx, maxAy, minBx, minBy, maxBx, maxBy
        
        if lineA.seg == true and lineB.seg == true then
        
            minAx = math.min(lineA.P1x, lineA.P2x)
            maxAx = math.max(lineA.P1x, lineA.P2x)        
            minBx = math.min(lineB.P1x, lineB.P2x)
            maxBx = math.max(lineB.P1x, lineB.P2x)
            
            minAy = math.min(lineA.P1y, lineA.P2y)
            maxAy = math.max(lineA.P1y, lineA.P2y)        
            minBy = math.min(lineB.P1y, lineB.P2y)
            maxBy = math.max(lineB.P1y, lineB.P2y)

        elseif lineA.seg == false and lineB.seg == true then

            minAx = 0
            maxAx = math.huge
            minBx = 0
            maxBx = math.huge
            
            minAy = math.min(lineA.P1y, lineA.P2y)
            maxAy = math.max(lineA.P1y, lineA.P2y)        
            minBy = math.min(lineB.P1y, lineB.P2y)
            maxBy = math.max(lineB.P1y, lineB.P2y)
            
        elseif lineA.seg == true and lineB.seg == false then

            minAx = math.min(lineA.P1x, lineA.P2x)
            maxAx = math.max(lineA.P1x, lineA.P2x)        
            minBx = math.min(lineB.P1x, lineB.P2x)
            maxBx = math.max(lineB.P1x, lineB.P2x)
            
            minAy = 0
            maxAy = math.huge
            minBy = 0
            maxBy = math.huge
            
        elseif lineA.seg == false and lineB.seg == false then
            
            minAx = 0
            maxAx = math.huge
            minBx = 0
            maxBx = math.huge
            
            minAy = 0
            maxAy = math.huge
            minBy = 0
            maxBy = math.huge
            
        else
            print("Some error with the line.seg attribute")
            return {intersection = false}
        end
        
        -- for the intersection point to be valid, it should fall on both the lines
            -- for the intersection point to be valid, it should fall on both the lines
        if (
            (minAx <= ix and ix <= maxAx) 
            and (minBx <= ix and ix <= maxBx) 
            and (minAy <= iy and iy <= maxAy) 
            and (minBy <= iy and iy <= maxBy) 
            ) then
            -- print("Found Intersection!")
            return {intersection = true, colinear = false, ix = ix, iy = iy}
        else
            -- print("Found NO Intersection!")
            return {intersection = false}
        end
        
    end

end

function get_lineEqn_intersection (A1x, A1y, A2x, A2y, B1x, B1y, B2x, B2y)
    -- m1= Am, m2 = Bm
    Am, Ab = get_lineEqn_from_segment (A1x, A1y, A2x, A2y)
    Bm, Bb = get_lineEqn_from_segment (B1x, B1y, B2x, B2y)

    if Am == Bm or Am == -Bm then
        -- print("Parallel Lines")
        
        -- test for colinear lines
        if Am == 0 and Bm == 0 then
            -- print("Scenario :  Am = Bm = 0")
            
            if A1y == B1y then
                -- print("Colinear Lines")
                return {result = true}
            else
                -- print("Non Colinear Lines")
                return {result = false}
            end
            
        elseif (Am == math.huge or Am == -math.huge) and (Bm == math.huge or Bm == -math.huge) then
            -- print("Scenario :  Am = Bm = inf")
            
            if Ab == Bb then
                -- print("Colinear")
                return {result = true}
            else
                -- print("Non Colinear Lines")
                return {result = false}
            end
            
        else 
            -- print("Scenario :  Am = Bm = valid")
            
            local d = (math.abs(Bb - Ab)) / (math.sqrt((Bm * Bm) + 1))
            
            if d == 0 then
                -- print("Colinear")
                return {result = true}
            else
                -- print("Non Colinear Lines")
                return {result = false}
            end
        end
        
        return false
    else
        
        print("Non parallel lines")
        
        -- Am = 0 and Bm = inf
        if Am == 0 and (Bm == math.huge or Bm == -math.huge) then
            -- print("Scenario :  Am = 0 and Bm = inf")
            
            iy = A1y
            ix = B1x
            print(ix, iy)
            
        -- Am = inf and Bm = 0
        elseif (Am == math.huge or Am == -math.huge) and Bm == 0 then
            -- print("Scenario :  Am = inf and Bm = 0")
            
            iy = B1y
            ix = A1x
            print(ix, iy)
            
        -- Am = 0 and Bm = valid
        elseif Am == 0 and (Bm ~= math.huge or Bm ~= -math.huge) then
            -- print("Scenario :  Am = 0 and Bm = valid")
            
            iy = A1y
            ix = (iy - Bb) / Bm
            print(ix, iy)
            
        -- Am = valid and Bm = 0 
        elseif (Am ~= math.huge or Am ~= -math.huge) and Bm == 0 then
            -- print("Scenario :  Am = valid and Bm = 0")

            iy = B1y
            ix = (iy - Ab) / Am
            print(ix, iy)
            
        -- Am = inf and Bm = valid
        elseif (Am == math.huge or Am == -math.huge) and  (Bm ~= math.huge or Bm ~= -math.huge) then
            -- print("Scenario :  Am = inf and Bm = valid")

            ix = A1x
            iy = (Bm * ix) + Bb
            print(ix, iy)
        
        -- Am = valid and Bm = inf
        elseif (Am ~= math.huge or Am ~= -math.huge) and  (Bm == math.huge or Bm == -math.huge) then
            -- print("Scenario :  Am = valid and Bm = inf")

            ix = B1x
            iy = (Am * ix) + Ab
            print(ix, iy)
            
        -- Am = valid and Bm = valid
        elseif  (Am ~= math.huge or Am ~= -math.huge) and  (Bm ~= math.huge or Bm ~= -math.huge) then
            -- print("Scenario :  Am = valid and Bm = valid")

            ix = -( (Bb - Ab)/(Bm - Am))
            iy = (Bm * ix) + Bb            
            print(ix, iy)

        else
            -- print("WHAT IS THIS I CANT EVEN")
            
        end

        local minAx, minAy, maxAx, maxAy, minBx, minBy, maxBx, maxBy
        
        minAx = math.min(A1x, A2x)
        maxAx = math.max(A1x, A2x)        
        minBx = math.min(B1x, B2x)
        maxBx = math.max(B1x, B2x)
        
        minAy = math.min(A1y, A2y)
        maxAy = math.max(A1y, A2y)        
        minBy = math.min(B1y, B2y)
        maxBy = math.max(B1y, B2y)
        
        -- for the intersection point to be valid, it should fall on both the lines
        if (
            (0 <= ix) 
            and (0 <= iy) 
            and (minAx <= ix and ix <= maxAx) 
            and (minBx <= ix and ix <= maxBx) 
            and (minAy <= iy and iy <= maxAy) 
            and (minBy <= iy and iy <= maxBy) 
            ) then
            -- print("Found Intersection!")
            return {result = true, ix = ix, iy = iy}
        else
            -- print("Found NO Intersection!")
            return {result = false}
        end
    end

end

function get_lineEqn_from_segment (x1, y1, x2, y2)
        m = (y2-y1)/(x2-x1)
        
        b = y1 - (m * x1)
        -- print("The Line eqn for points ".. "[" .. x1 .. ", " .. y1 .. "] & [" .. x2 .. ", " .. y2 .. "]")
        -- print("m = " .. m .. ", b = " .. b)
    return m, b
end