debug = true

-- worldWidth = 10 chunks
-- worldLength = 10 chunks
-- region
-- tile

-- Step 1: generate points field. Currently using just random points
vorPoly = {}

function love.load(arg)	
    love.math.setRandomSeed(os.time()) --set the random seed
    keys = {} --an empty table where we will store key presses
    number_cells = 500 --the number of cells we want in our diagram
        
     --draw the voronoi diagram to a canvas
    voronoiDiagram = generateVoronoi(love.graphics.getWidth(), love.graphics.getHeight(), number_cells)
end

 
--RENDER
function love.draw()
    --reset color
    love.graphics.setColor({255,255,255})
    --draw diagram
    love.graphics.draw(voronoiDiagram)
    --draw drop shadow text
    
    love.graphics.print(love.timer.getFPS())
end
 
--CONTROL
function love.keyreleased(key)
    if key == 'space' then
        voronoiDiagram = generateVoronoi(love.graphics.getWidth(), love.graphics.getHeight(), number_cells)
    elseif key == 'escape' then
        love.event.quit()
    end
end

 
function hypot(x,y)
    return math.sqrt(x*x + y*y)
end
 
function generateVoronoi(width, height, num_cells)

    local start_time = love.timer.getTime()
    local tempObj
    
    canvas = love.graphics.newCanvas(width, height)
    local scrWidth = canvas:getWidth()
    local scrHeight = canvas:getHeight()
    local nx = {}               -- random points x
    local ny = {}               -- random points y
    local nr = {}               -- random RGB value
    local ng = {}               -- random RGB value
    local nb = {}               -- random RGB value
    for a = 1, num_cells do
        table.insert(nx, love.math.random(0,scrWidth))
        table.insert(ny, love.math.random(0,scrHeight))
        table.insert(nr, love.math.random(0,255))
        table.insert(ng, love.math.random(0,255))
        table.insert(nb, love.math.random(0,255))
    end
    love.graphics.setColor({255,255,255})
    love.graphics.setCanvas(canvas)
    for y = 1, scrHeight do
        for x = 1, scrWidth do
                dmin = hypot(scrWidth-1, scrHeight-1)
            j = -1
            for i = 1, num_cells do
            d = hypot(nx[i]-x, ny[i]-y)
                if d < dmin then
                    dmin = d
                    j = i
                end
            end
            love.graphics.setColor({nr[j], ng[j], nb[j]})

            love.graphics.points(x, y)
        end
    end
    --reset color
    love.graphics.setColor({255,255,255})
    --draw points
    
    love.graphics.setPointSize(3)
    for b = 1, num_cells do
        love.graphics.points(nx[b], ny[b])
    end
    love.graphics.setCanvas()

    print(string.format("It took %.3f milliseconds to Generate Voronoi Diagram", 1000 * (love.timer.getTime() - start_time)))

    return canvas
end
