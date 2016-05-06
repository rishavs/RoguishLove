debug = true

local _voronoi = require "LuaFortune.voronoi"
local _points = require "LuaFortune.points"

local blue_PointsList = {}
local loveform_PointsList = {}

local Voronoi_EdgesList = {}
local loveform_EdgesList = {}

local Voronoi_FacesList ={}

function love.load(arg)
    
    local step1Start_time = love.timer.getTime()
    
    ----------------------------------------------
    -- Step 1: Generate Points field
    ----------------------------------------------

    print("Generating Points field....")

    blue_PointsList = _points.blue_noise(0, love.graphics.getWidth(), 0, love.graphics.getHeight(), 10, 40)
    -- (min_x, max_x, min_y, max_y, missed_points, min_dist, rnd_func)
    local count = 0
    for _, point in ipairs(blue_PointsList) do
        -- print("- "..point.x..", "..point.y)
        table.insert (loveform_PointsList, point.x)
        table.insert (loveform_PointsList, point.y)
        
        count = count + 1
        
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
      
    Voronoi_EdgesList = _voronoi.fortunes_algorithm(blue_PointsList,0,0,love.graphics.getWidth(),love.graphics.getHeight())  
      
    local count = 0
    for i, edge in ipairs(Voronoi_EdgesList) do
        
        count = count + 1
        
    end  
 
    print ("Total Number of Edges =", count)
    
    
    Voronoi_FacesList = _voronoi.find_faces_from_edges(Voronoi_EdgesList, blue_PointsList)
    
    local count = 0
    for _,face in ipairs(Voronoi_FacesList) do
        for i=#face, 1, -1 do
            count = count + 1
        end
    end
    print ("Total Number of Faces =", count)
        
    local step2End_time = love.timer.getTime()
    print ("Voronoi Graph Generated!")
    print(string.format("It took %.3f milliseconds to Generate Voronoi Graph", 1000 * (step2End_time - step1End_time)))
    
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
    for _,edge in ipairs(Voronoi_EdgesList) do
        love.graphics.line(edge.p1.x,edge.p1.y,edge.p2.x,edge.p2.y)
        love.graphics.line(edge.p1.x,edge.p1.y,edge.p2.x,edge.p2.y)
    end
        
    -- love.graphics.setColor(0,255,0)
    -- for _,face in ipairs(Voronoi_FacesList) do
        -- for i=#face, 1, -1 do
            -- love.graphics.line(face[i].x,face[i].y,face[i%#face+1].x,face[i%#face+1].y)
        -- end
    -- end
    love.graphics.print(love.timer.getFPS())
end

function love.update(dt)

end

-- public class Center {
    -- public var index:int;
  
    -- public var point:Point;  // location
    -- public var water:Boolean;  // lake or ocean
    -- public var ocean:Boolean;  // ocean
    -- public var coast:Boolean;  // land polygon touching an ocean
    -- public var border:Boolean;  // at the edge of the map
    -- public var biome:String;  // biome type (see article)
    -- public var elevation:Number;  // 0.0-1.0
    -- public var moisture:Number;  // 0.0-1.0

    -- public var neighbors:Vector.<Center>;
    -- public var borders:Vector.<Edge>;
    -- public var corners:Vector.<Corner>;
-- };

-- public class Corner {
    -- public var index:int;

    -- public var point:Point;  // location
    -- public var ocean:Boolean;  // ocean
    -- public var water:Boolean;  // lake or ocean
    -- public var coast:Boolean;  // touches ocean and land polygons
    -- public var border:Boolean;  // at the edge of the map
    -- public var elevation:Number;  // 0.0-1.0
    -- public var moisture:Number;  // 0.0-1.0

    -- public var touches:Vector.<Center>;
    -- public var protrudes:Vector.<Edge>;
    -- public var adjacent:Vector.<Corner>;

    -- public var river:int;  // 0 if no river, or volume of water in river
    -- public var downslope:Corner;  // pointer to adjacent corner most downhill
    -- public var watershed:Corner;  // pointer to coastal corner, or null
    -- public var watershed_size:int;
-- };

-- public class Edge {
    -- public var index:int;
    -- public var d0:Center, d1:Center;  // Delaunay edge
    -- public var v0:Corner, v1:Corner;  // Voronoi edge
    -- public var midpoint:Point;  // halfway between v0,v1
    -- public var river:int;  // volume of water, or 0
-- };

function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

