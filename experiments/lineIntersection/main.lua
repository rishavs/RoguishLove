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

                print("Intersection??" )
                if int2.result == true then
                    print(int2.result, int2.ix, int2.iy)
                else
                    print("false")
                end
                print()
            end
        else
            points = {}
            table.insert(points, {x=x, y=y})
        end
    end
end

function get_lineEqn_intersection (A1x, A1y, A2x, A2y, B1x, B1y, B2x, B2y)
    -- m1= Am, m2 = Bm
    Am, Ab = get_lineEqn_from_segment (A1x, A1y, A2x, A2y)
    Bm, Bb = get_lineEqn_from_segment (B1x, B1y, B2x, B2y)

    if Am == Bm or Am == -Bm then
        print("Parallel Lines")
        
        -- test for colinear lines
        if Am == 0 and Bm == 0 then
            print("Scenario :  Am = Bm = 0")
            
            if A1y == B1y then
                print("Colinear Lines")
                return {result = true}
            else
                print("Non Colinear Lines")
                return {result = false}
            end
            
        elseif (Am == math.huge or Am == -math.huge) and (Bm == math.huge or Bm == -math.huge) then
            print("Scenario :  Am = Bm = inf")
            
            if Ab == Bb then
                print("Colinear")
                return {result = true}
            else
                print("Non Colinear Lines")
                return {result = false}
            end
            
        else 
            print("Scenario :  Am = Bm = valid")
            
            local d = (math.abs(Bb - Ab)) / (math.sqrt((Bm * Bm) + 1))
            
            if d == 0 then
                print("Colinear")
                return {result = true}
            else
                print("Non Colinear Lines")
                return {result = false}
            end
        end
        
        return false
    else
        
        print("Non parallel lines")
        
        -- Am = 0 and Bm = inf
        if Am == 0 and (Bm == math.huge or Bm == -math.huge) then
            print("Scenario :  Am = 0 and Bm = inf")
            
            iy = A1y
            ix = B1x
            print(ix, iy)
            
        -- Am = inf and Bm = 0
        elseif (Am == math.huge or Am == -math.huge) and Bm == 0 then
            print("Scenario :  Am = inf and Bm = 0")
            
            iy = B1y
            ix = A1x
            print(ix, iy)
            
        -- Am = 0 and Bm = valid
        elseif Am == 0 and (Bm ~= math.huge or Bm ~= -math.huge) then
            print("Scenario :  Am = 0 and Bm = valid")
            
            iy = A1y
            ix = (iy - Bb) / Bm
            print(ix, iy)
            
        -- Am = valid and Bm = 0 
        elseif (Am ~= math.huge or Am ~= -math.huge) and Bm == 0 then
            print("Scenario :  Am = valid and Bm = 0")

            iy = B1y
            ix = (iy - Ab) / Am
            print(ix, iy)
            
        -- Am = inf and Bm = valid
        elseif (Am == math.huge or Am == -math.huge) and  (Bm ~= math.huge or Bm ~= -math.huge) then
            print("Scenario :  Am = inf and Bm = valid")

            ix = A1x
            iy = (Bm * ix) + Bb
            print(ix, iy)
        
        -- Am = valid and Bm = inf
        elseif (Am ~= math.huge or Am ~= -math.huge) and  (Bm == math.huge or Bm == -math.huge) then
            print("Scenario :  Am = valid and Bm = inf")

            ix = B1x
            iy = (Am * ix) + Ab
            print(ix, iy)
            
        -- Am = valid and Bm = valid
        elseif  (Am ~= math.huge or Am ~= -math.huge) and  (Bm ~= math.huge or Bm ~= -math.huge) then
            print("Scenario :  Am = valid and Bm = valid")

            ix = -( (Bb - Ab)/(Bm - Am))
            iy = (Bm * ix) + Bb            
            print(ix, iy)

        else
            print("WHAT IS THIS I CANT EVEN")
            
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
            print("Found Intersection!")
            return {result = true, ix = ix, iy = iy}
        else
            print("Found NO Intersection!")
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