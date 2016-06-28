debug = true

-- Another solution generates Voronoi cells from Delaunay triangulation. The page Voronoi diagram/J/Delaunay triangulation also contains a convex hull algorithm. This is a vector based approach instead of a pixel based approach and is about twice as fast for this task's example. To be experimented later

local _voronoi = require "LuaFortune.voronoi"
local _points = require "LuaFortune.points"

local inspect = require "inspect"



local loveform_PointsList = {}

local voronoiDiag = {
    Polygons = {
        -- index = 0,
        -- center = {},
        -- corners = {}
        
    },
    Faces = {
        index = 0,
        
        neighbors = {},
        borders = {},
        corners = {},
        
        point = {0,0},
        water = false,
        ocean = false,
        coast = false,
        border = false,
        biome = "string",
        elevation = 0,
        moisture = 0
    },
    Edges = {
        index = 0,
        
        joins = {},
        continues = {},
        endpoints = {},
        
        d0 = 0, -- Delauney edge
        d1 = 0, -- Delauney edge
        v0 = 0, -- voronoi edge
        v1 = 0, -- voronoi edge
        midpoint = 0, -- halfway between v0,v1
        river = 0    -- volume of water, or 0
    },
    Vertices = {
        
        touches = {},
        protrudes = {},
        adjacent = {},

    }
}

function love.load(arg)
    
    local step1Start_time = love.timer.getTime()
    
    ----------------------------------------------
    -- Step 1: Generate Points field
    ----------------------------------------------

    print("Generating Points field....")

    voronoiDiag.Vertices = pointsSetGenerator (500,0.4)
    -- (min_x, max_x, min_y, max_y, missed_points, min_dist, rnd_func) 3,20 seems the best numbers
    local count = 0
    for _, point in ipairs(voronoiDiag.Vertices) do
        -- print("- "..point.x..", "..point.y)
        local pointX = math.floor(point.x+0.5)  -- Making all points have integet x and y values
        local pointY = math.floor(point.y+0.5)  -- Making all points have integet x and y values
        
        table.insert (loveform_PointsList, pointX)
        table.insert (loveform_PointsList, pointY)
        
        local tempObj = { index = 0, center = {}}
        tempObj.center.x = pointX
        tempObj.center.y = pointY
        
        count = count + 1

        tempObj.index = count

        voronoiDiag.Polygons[count] = tempObj
        
        print(inspect(tempObj))
    end

    print ("Points field generated!")
    print ("Total Number of Points =", count)
 
    local step1End_time = love.timer.getTime()
    
    print(string.format("It took %.3f milliseconds to Generate Points field", 1000 * (step1End_time - step1Start_time)))

    ----------------------------------------------
    -- Step 2: Build Graph using Points Field
    ----------------------------------------------
      -- Create a graph structure from the Voronoi edge list. The
      -- methods in the Voronoi object are somewhat inconvenient for
      -- my needs, so I transform that data into the data I actually
      -- need: edges connected to the Delaunay triangles and the
      -- Voronoi polygons, a reverse map from those four points back
      -- to the edge, a map from these four points to the points
      -- they connect to (both along the edge and crosswise).
      
      -- var voronoi:Voronoi = new Voronoi(points, null, new Rectangle(0, 0, SIZE, SIZE));
      -- buildGraph(points, voronoi);
      -- improveCorners();
      -- voronoi.dispose();
      -- voronoi = null;
      -- points = null;
      
    voronoiDiag.Edges = _voronoi.fortunes_algorithm(voronoiDiag.Vertices,0,0,love.graphics.getWidth(),love.graphics.getHeight())  
      
    local count = 0
    for i, edge in ipairs(voronoiDiag.Edges) do
        
        count = count + 1
        
    end  
 
    print ("Total Number of Edges =", count)
    
    voronoiDiag.Faces = _voronoi.find_faces_from_edges(voronoiDiag.Edges, voronoiDiag.Vertices)
    
    -- print_r(voronoiDiag)
    local count = 0
    for _,face in ipairs(voronoiDiag.Faces) do
        for i=#face, 1, -1 do
            count = count + 1
            -- face[i].index = count
            
            -- print_r(face[i])
        end
    end
    
    
    -- print(inspect(voronoiDiag))
    io.output("foo.lua")   -- creates file "foo", should set stdout to "foo"?
    io.write(inspect(voronoiDiag)) 
    print ("Total Number of Faces =", count)
        
    local step2End_time = love.timer.getTime()
    print ("Voronoi Graph Generated!")
    print(string.format("It took %.3f milliseconds to Generate Voronoi Graph", 1000 * (step2End_time - step1End_time)))
    
    ----------------------------------------------
    -- Step 3: Create Graph/Grid relations
    ----------------------------------------------
    
    
    ----------------------------------------------
    -- Step 3: Assign Elevations
    ----------------------------------------------    

    
    
    ----------------------------------------------
    -- Step 4: Assign Moisture
    ----------------------------------------------
    
    ----------------------------------------------
    -- Step 5: Decorate Map
    ----------------------------------------------
    
end

function love.draw(dt)
    love.graphics.setPointSize( 3 )
    love.graphics.setColor(255,0,0)
    love.graphics.points(loveform_PointsList)
    
    love.graphics.setColor(255,255,255)
    -- for _,edge in ipairs(voronoiDiag.Edges) do
        -- love.graphics.line(edge.p1.x,edge.p1.y,edge.p2.x,edge.p2.y)
        -- love.graphics.line(edge.p1.x,edge.p1.y,edge.p2.x,edge.p2.y)
    -- end
        
    -- love.graphics.setColor(0,255,0)
    
    local count = 0
    for _,face in ipairs(voronoiDiag.Faces) do
        for i=#face, 1, -1 do
            -- Draw the faces
            love.graphics.setColor(50,50,50)
            love.graphics.line(face[i].x, face[i].y, face[i%#face+1].x, face[i%#face+1].y)
            
            -- Draw the corners of each face
            love.graphics.setColor(0,255,0)
            love.graphics.points (face[i].x,face[i].y)
        end
    end

    love.graphics.print(love.timer.getFPS())
end

function love.update(dt)

end

function pointsSetGenerator (n,s)
    local pointsList = {} -- output
    local pointsObj = {}
    
    -- n = number of points, d = max deviance allowed. between 0 and 1
    local scrW = love.graphics.getWidth()
    local scrH = love.graphics.getHeight()
    
    -- n * d^2 = scrW * scrH
    local d = roundToInt(math.sqrt(scrW * scrH / n))
    -- print(d)
    
    -- set random seed for maths lib
    math.randomseed( os.time() )
    
    -- Generate points set 
    local count = 0
    local de = (d-d*s)          -- max distance form the edge
    for y = de, scrH, d do
        for x = de, scrW,d do
            -- apply deviance to get randomness
            local dx = x + (d * math.random(0, s*100)/100 * ((math.random(1,2)*2)-3))
            local dy = y + (d * math.random(0, s*100)/100 * ((math.random(1,2)*2)-3))
            
            dx = roundToInt(dx)
            dy = roundToInt(dy)
            -- discard all points where the distance from the edge is less than de
            if (dx + d * s) <  scrW and (dy + d * s) < scrH then
                table.insert(pointsList, dx)
                table.insert(pointsList, dy)
                
                table.insert(pointsObj, {x = dx, y = dy})
               
                
                count = count + 1
                
                -- print (d, count, scrW, scrH, x, y, dx, dy)
            end
            
        end
    end
    -- print (inspect(pointsObj))
    
    -- return pointsList
    return pointsObj
end

function roundToInt(n)
    return (math.floor(n+0.5))
end