pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- fps - fish person shooter
-- happy birthday, kovie!

-- START SCREEN VARIABLES
pupilTrueX = 35
pupilTrueY = 51
pupilX = pupilTrueX
pupilY = pupilTrueY
browTrueX = 20
browTrueY = 15
browX = browTrueX
browY = browTrueY

--Offset for facial features
xOffset = 0
yOffset = 0
zOffset = 16
offsetCounter = 0
escapeCounter = 0
--Offset mode 1: Idly bobble
--Offset mode 2: Rush offscreen to the left
mode = 1

--Animations for start screen
animCount = 0
animCount1 = 0

--World variables
--map width / height
cellSize = 16
h = 40
mapA = 
{
{3, 1, 1, 1, 1, 1, 3,},
{1, 0, 0, 2, 0, 0, 1,},
{1, 0, 0, 0, 0, 0, 1,},
{1, 0, 3, 0, 3, 0, 1,},
{1, 0, 0, 0, 0, 0, 1,},
{1, 0, 0, 2, 0, 0, 1,},
{3, 1, 1, 1, 1, 1, 3,},
}

mapB =
{
{3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3,},
{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,},
{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,},
{1, 0, 0, 2, 0, 0, 0, 0, 2, 0, 0, 1,},
{1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1,},
{1, 0, 0, 1, 0, 0, 0, 0, 2, 0, 0, 1,},
{1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1,},
{1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1,},
{1, 0, 0, 2, 1, 1, 1, 1, 1, 1, 2, 1,},
{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,},
{1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,},
{3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3,},
}

currentMap = mapB
currentCoords = {x = 2, y = 2,}
mapPlot = {}
seed = {}
drawStage = 0
drawSpeed = 1
drawMe = true
slowDraw = true

--Player variables
player = {}
player.xPos = cellSize * 2.5
player.yPos = cellSize * 2.5
player.xVel = 0
player.yVel = 0
player.zRot = 0
player.FOV = 90

--Screen IDs

screenID = 0
-- FUNCTIONS
--Draw start screen
function startScreen()
    idleAnim()
    offsetUpdate()
end

function idleAnim()
    palt(14, true)
    palt(0, false)
    
    cls(1)

    --Background: fishy blue
    rectfill(0,0,127,127,7)

    --Draw circle head
    circfill(-130 + xOffset,46 + yOffset,300,12)
    
    --Draw text
    printXOffset = xOffset / 3
    printYOffset = yOffset / 3
    print("fps",58 + printXOffset,96 + printYOffset,7)
    print("(FISH PERSON SHOOTER)",23 + printXOffset,102 + printYOffset,7)
    print("press ❎ to start",30 + printXOffset,112 + printYOffset,7)

    --Draw eyelash
    spr(64,25 + xOffset,32 + yOffset,11,8)
    --Draw face marking
    spr(11,75 + xOffset,73 + yOffset,3,3)
    --Draw and animate pupil / iris and eyebrow
    browAnimate()
    pupilAnimate()
end


-- ANIMATIONS
--return frame number given a counter, initial frame, width of frames and duration of each frame (30 = 1s)
function incFrame(counter, frame, width, duration)
    return frame + (width * (flr((width / duration) * (counter % duration))))
end

--sin function for tween frames
function sinTween(frm, speedMult, start, length)
    speed = 4 * speedMult
    
    x = frm / speed

    --when calculating sin, 0.25 is -1 and -.75 is 1
    return 1 + sin(start + ((x) * length))
end

--Bobble animation value - give speed and dist (try 6 / 2)
-- initPos: Initial position of object
-- frame: frame counter used when calling this object
-- speed: effectively the "max frame", divided by frame to get actual speed
-- dist: multiplier for sinTween results
-- start: start of sine wave
--   0 / 0.5: mid-swing
--   0.25 / 0.75: start at slow portion of swing
-- length: Desired length of sine wave
--   1: full sine wave
--   0.5: half a sine wave
--   takes any number from 
function bobble(initPos, frame, speed, dist, start, length)
    x = sinTween(frame, speed, start, length) * dist
    return initPos + x
end

function offsetUpdate()
    --Mode 1 = start screen
    if(mode == 1) then
        offsetCounter += 1
        --bobble() is an animation that will wobble a variable on a sine wave
        xOffset = bobble(0, offsetCounter, 9, 5, 0.25, 0.5) - 6
        yOffset = bobble(0, offsetCounter, 14, 5, 0.25, 0.5) - 6

        --If X is pressed...
        if(btn(5)) then
            --...Then change mode to 2
            mode = 2
        end
    --Mode 2 = transitioning to intro screen
    elseif(mode == 2) then
        --Shift the head and other title screen elements offscreen 
        escapeCounter += 2

        xOffset -= escapeCounter
        zOffset -= 0.25

        --Reset general-use variables that don't need preserved values and proceed to the intro
        if(escapeCounter > 48) then
            yOffset = 0
            escapeCounter = 0
            offsetCounter = 0
            animCount = 0
            animCount1 = 0
            screenID = 2
            mode = 1
        end
    end
end

--Brow twitch
function browAnimate()
    if(animCount < 48) then
        browX = bobble(browTrueX, animCount, 6, -1, 0.25, 0.75)
        browY = bobble(browTrueY, animCount, 6, 2, 0.25, 0.75)

        animCount += 1
    -- Use RNG to determine if brow should be twitching
    elseif(flr(rnd(100)) == 1) then
        animCount = 0
    end

    spr(7,browX + xOffset,browY + yOffset,4,2)
end

--Pupil wiggle
function pupilAnimate()
    -- Animate pupil for 36 frames, then don't animate for 12 frames, then start again
    if(animCount1 < 36) then
        pupilX = bobble(pupilTrueX, animCount1, 1.5, 1, 0.25, 0.75)
    elseif(animCount1 >= 48) then
        animCount1 = 0
    end

    animCount1 += 1

    spr(1,pupilX + xOffset,pupilY + yOffset,6,4)
end


-->8
-- Intro after starting game

-- Draw gradients for horizon
function drawHorizon(offset, startI, endJ, color)
    -- Fills follow a 4x4 map. example of the first one:
    -- 1111
    -- 0101
    -- 1111
    -- 0101
    fills = {0b1111010111110101, 0b0101101001011010, 0b0101000001010000}

    i = startI
    j = endJ

    height = (startI - endJ) / 3

    for k=1,3 do
        fillp(flr(fills[k]))
        rectfill(0, i + flr(offset), 128, j + flr(offset), color)
        i -= height
        j -= height
    end

    fillp(0)
end

-- Draw a single building (just a rectangle)
function drawBuilding(x, y, xOffset, yOffset, width, height, color)
    rectfill(((x + xOffset) % (128 + width)) - width, (y + yOffset) - height, (0 + xOffset) % (128 + width), y + yOffset, color)
end

-- Draw a horizon and multiple buildings
function drawBuildings(y, xOffset, yOffset, color)
    rectfill(0, (y + yOffset % 128), 128, 128, color)
    drawBuilding(0, y, xOffset, yOffset, 28, 64, color)
    drawBuilding(0, y, xOffset + 32, yOffset, 28, 48, color)
    drawBuilding(0, y, xOffset + 64, yOffset, 28, 56, color)
    drawBuilding(0, y, xOffset + 96, yOffset, 28, 48, color)
    drawBuilding(0, y, xOffset + 126, yOffset, 28, 56, color)
end

-- Intro animation structure
function introAnim()
    escapeCounter += 1
    if(escapeCounter < 400) then
       xOffset = -5*bobble(0, escapeCounter, 100, 500, 0, 0.25)
       animCount1 = bobble(24, escapeCounter, 100, 40, 0.5, 1.25)
    end
    
    if(yOffset < 24) then
        animCount += 1
        if(animCount < 80) then
            yOffset = -bobble(0, animCount, 20, 500, 0, 0.25)
        end
    end

    -- Background color white
    rectfill(0,0,127,127,1)
    -- Dynamic horizon shapes
    rectfill(0, 112 + flr(-yOffset / 4), 128, 128, 0)
    drawHorizon(yOffset / -4, 124, 80, 0x8e)
    drawHorizon(yOffset / -4, 80, 56, 0xe2)
    drawHorizon(yOffset / -4, 56, 22, 0x21)
    drawBuildings(100, xOffset / 4, yOffset / -4, 0)
    -- Entry building
    map(0, 0, 0 + xOffset, 0, 24, 16)

    for i=0,17 do
        pal(7, 7)
        spr(60, (((i * 8) + xOffset) % 136) - 8, 120 - yOffset, 1, 1)
    end

    spr(incFrame(escapeCounter, 75, 2, 90), animCount1, 90 - yOffset, 2, 3, true, false)
    spr(123, animCount1 - 3, 113 - yOffset, 3, 1)

    if(xOffset == 0) then
        screenID = 3
    end
end

function menuSelect()
    if(btn(5)) then
        screenID = 3
    end
    if(mode == 1) then
        introAnim()
    end
end

-->8
--Raycasting
function raycast()
    -- For each X position
    for i = 0, 127 do
        -- Find starting tile
        px = player.xPos
        py = player.yPos

        x = player.xPos / cellSize
        y = player.yPos / cellSize

        pa = player.zRot / 360

        -- Find ray direction (panoramic)
        vx = cos(pa - (i - 64) / 512)
        vy = sin(pa - (i - 64) / 512)

        -- Find standard distance
        dx = abs(1 / vx)
        dy = abs(1 / vy)

        -- Find increment value
        ix = vx > 0 and 1 or -1
        iy = vy > 0 and 1 or -1

        -- Find initial offset
        if (vx > 0) then
            ox = (flr(x) - x + 1) / vx
        else
            ox = abs((x - flr(x)) / vx)
        end

        if (vy > 0) then
            oy = (flr(y) - y + 1) / vy
        else
            oy = abs((y - flr(y)) / vy)
        end

        while true do
            -- Horizontal intersection
            if (abs(ox) < abs(oy)) then
                x += ix
                d = ox
                ox += dx
            -- Vertical intersection
            else
                y += iy
                d = oy
                oy += dy
            end
            if (d == nil or d == 0) then
                errorD(d)
            end

            // Check for collision
            if (mapCollide(currentMap, flr(x), flr(y)) > 0 or x > #currentMap or y > #currentMap[1] or x <= 0 or y <= 0) then
                _result = mapCollide(currentMap, flr(x), flr(y))
                if(_result != 7) then
                    line(i, 64 - h / d, i, 64 + h / d, _result)
                end
                break
            end
        end
    end
    printed = false
end

-- Get value from a map table - returns nil if out of range
function mapCollide(_mapVal, _x, _y)
    if (_x > 0 and _y > 0 and _x <= #_mapVal and _y <= #_mapVal[1]) then
        return _mapVal[_y][_x]
    else
        return 7
    end
end

-- Detect if edge of objects will be collided with after moving
function mapObjectCollision(_map, _x, _y, _xDist, _yDist)
    _result = {}
    
    -- Get floor of player's X position
    _playerX = flr(_x)
    _playerY = flr(_y)

    -- Get floor of player's X position plus the provided offsets if player moves on X or Y axis
    _objX = flr(_x + _xDist)
    _objY = flr(_y + _yDist)
    
    -- If the player's offset X position and true Y position don't intersect with an occupied cell on the map...
    if (_objX > 0 and _objX < #_map[1] and _playerY > 0 and _playerY < #_map) then
        -- ...Then check if the player's new X position intersects with an occupied cell on the map using a ternary statement
        -- If intersects, then mark as 0. If not, then mark as 1.
        _result[x] = _map[_playerY][_objX] > 0 and 0 or 1
    else
        _result[x] = 0
    end

    -- Same as above but for true X position and offset Y position
    if(_playerX > 0 and _playerX < #_map[1] and _objY > 0 and _objY < #_map) then
        _result[y] = _map[_objY][_playerX] > 0 and 0 or 1
    else
        _result[y] = 0
    end

    -- Return table with X and Y values mapped to whether or not the new X / Y positions intersect with an occupied cell on the map
    return _result
end

-- Used by move() function to calculate if edge of map will be collided with after moving 
function mapEdgeCollision(_i, _dist, _maxDist)
    if(flr(_i + _dist) > 0 and flr(_i + _dist) <= _maxDist) then
        return _dist
    else
        return 0
    end
end

function move(_x, _y, _xDist, _yDist)
    _moveDist = {}
    _mapObjects = mapObjectCollision(currentMap, _x, _y, _xDist, _yDist)

    _moveDist[x] = _mapObjects[x] == 0 and 0 or mapEdgeCollision(_x, _xDist, #currentMap)
    _moveDist[y] = _mapObjects[y] == 0 and 0 or mapEdgeCollision(_y, _yDist, #currentMap[1])

    return _moveDist
end

-- Move player if arrows are pressed
function movePlayer()
    -- Rotate player
    if(btn(0)) then
        player.zRot += 5
    elseif(btn(1)) then
        player.zRot -= 5
    end

    -- Move player forward / backward, determining direction speed 
    if(btn(2)) then
        pa = player.zRot / 360
        player.xVel = cos(pa)
        player.yVel = sin(pa)
        
        _coords = move(player.xPos / cellSize, player.yPos / cellSize, player.xVel / cellSize, player.yVel / cellSize)

        player.xPos += _coords[x] * cellSize
        player.yPos += _coords[y] * cellSize

    elseif(btn(3)) then
        pa = player.zRot / 360
        player.xVel = cos(pa)
        player.yVel = sin(pa)

        _coords = move(player.xPos / cellSize, player.yPos / cellSize, -player.xVel / cellSize, -player.yVel / cellSize)
        
        player.xPos += _coords[x] * cellSize
        player.yPos += _coords[y] * cellSize
    end
end

-- Map functions
function drawMap(mapVal, width, height)
    _prevX = 0
    _prevY = 0
    _mapWidth = 128 / width
    _mapHeight = 128 / height

    for i = 1, #mapVal do
        for j = 1, #mapVal[i] do
            -- rectfill(_prevX, _prevY, j * _mapWidth, i * _mapHeight, mapPlot[i][j])
            if(mapPlot[i][j] != 0 and i != 1 and i != #mapVal and j != 1 and j != #mapVal[i]) then
                rectfill(_prevX, _prevY, j * _mapWidth, i * _mapHeight, 12)
            else
                rectfill(_prevX, _prevY, j * _mapWidth, i * _mapHeight, mapPlot[i][j])
            end
            _prevX = j * _mapWidth
        end
        _prevX = 0
        _prevY = i * _mapHeight
    end

    -- rectfill(currentCoords.x * _mapWidth, currentCoords.y * _mapHeight, (currentCoords.x * _mapWidth) - _mapWidth, (currentCoords.y * _mapHeight) - _mapHeight, 9)

    -- circfill(((player.xPos / cellSize) - 1) * _mapWidth, ((player.yPos / cellSize) - 1) * _mapHeight, 1, 7)
end

function drawRoom()
    cls(0)
    rectfill(0,0,127,64,7)
    raycast()
    movePlayer()
end


-->8
-- CONTENT GENERATION
-- Generate a map with walls at map edges + algorithmic maze generation 
-- Map consists of tables of equal width within a larger table
-- Root table maps Y coords while sub-tables map X coords and contain the values for walls / empty space
function generateMap(_width, _height, _enemyCount, _goodiesCount, _difficulty, _tileset)
    -- Nested table containing values for map cells
    _genMap = {}
    -- Nested table containing values for whether a given cell's state is finalized
    -- 0: Not plotted
    -- 1: Plotted but not finalized (surrounding cells have not been fully inspected yet)
    -- 2: Plotted and finalized
    _plotted = {}
    -- Value for current map coords
    _currentCoords = {x = 2, y = 2}

    -- Set walls of map
    -- Iterate through all Y positions
    for i = 1, _height do
        -- Initialize Y axis table
        _genMap[i] = {}
        _plotted[i] = {}
        -- Iterate through all X positions on table
        for j = 1, _width do
            if(i == 1 or i == _height or j == 1 or j == _width) then
                _genMap[i][j] = 2
                _plotted[i][j] = 2
            else
                _genMap[i][j] = 1
                _plotted[i][j] = 0
            end
        end
    end

    -- Ensure that starting cell (2, 2) is finalized as empty
    _genMap[2][2] = 0
    _plotted[2][2] = 0

    _plotComplete = false

    _genSeed = {map = _genMap, plot = _plotted, ready = _plotComplete, coords = _currentCoords}

    if (slowDraw == false) then
        _seed = _genSeed

        while (_seed.ready == false) do
            _seed = stageMaze(_seed)
        end

        _genSeed = _seed
    end

    return _genSeed
end

function initiateMaze()
    _seed = seed

    if (slowDraw == true) then
        if (_seed.ready == false) then
            _seed = stageMaze(_seed)
        end
    else
        _seed.ready = true
    end

    seed = _seed

    if (seed.ready == true) then
        screenID = 1
    end
end

function stageMaze(_seed)
    _genProg = generateMaze(_seed.map, _seed.plot, _seed.coords)
    _seed.map = _genProg.genMap
    _seed.plot = _genProg.plotted
    _seed.coords = _genProg.coords
    
    currentMap = _seed.map

    _seed.ready = _genProg.plotComplete
    
    if (drawMe == true) then
        drawStage += 1
        if(drawStage % drawSpeed == 0) then
            drawMap(currentMap, #currentMap[1], #currentMap)
            mapFrame = 0
        end
    else
        print("Working...")
    end

    return _seed
end

function generateMaze(_genMap, _plotted, _coords)
    _map = _genMap
    _coordinates = _coords

    _maxY = #_genMap[1]
    _maxX = #_genMap
    _options = {}

    _genProg = {}

    _genProg.plotComplete = false

    -- Set current coords to 0
    _map[_coordinates.y][_coordinates.x] = 0

    -- List of all possible directions that lead the current cell to surrounding cells in cardinal directions
    _directions =
    {
        {x = 2, y = 0, ix = 1, iy = 0,},
        {x = 0, y = 2, ix = 0, iy = 1,},
        {x = -2, y = 0, ix = -1, iy = 0,},
        {x = 0, y = -2, ix = 0, iy = -1,},
    }

    -- If current cell isn't finalized, then search surroundings for unexplored cell and move to it
    if (_plotted[_coordinates.y][_coordinates.x] < 2) then
        -- Check if neighboring cells are out-of-bounds and not yet explored; if not, then add them to list of potential options for dest cell
        for i = 1, 4 do
            if (_coordinates.x + _directions[i].x > 1 and _coordinates.x + _directions[i].x < _maxX and _coordinates.y + _directions[i].y > 1 and _coordinates.y + _directions[i].y < _maxY and _plotted[_coordinates.y + _directions[i].y][_coordinates.x + _directions[i].x] == 0) then
                _options[#_options + 1] = i
            end
        end

        -- If options list isn't empty...
        if (#_options > 0) then
            if (#_options > 1) then
                --  Set choice to any of the option tables at random
                _choice = _options[flr(rnd(#_options)) + 1]
                -- Plot current cell as explored
                _plotted[_coordinates.y][_coordinates.x] = 1
                -- Plot intersecting cell as explored
                _plotted[_coordinates.y + _directions[_choice].iy][_coordinates.x + _directions[_choice].ix] = 1
            else
                -- Set choice to the only choice available
                _choice = _options[1]
                -- Plot current cell as finalized
                _plotted[_coordinates.y][_coordinates.x] = 2
                -- Plot intersecting cell as explored
                _plotted[_coordinates.y + _directions[_choice].iy][_coordinates.x + _directions[_choice].ix] = 1
            end
            -- Set intersecting square as empty space
            _map[_coordinates.y + _directions[_choice].iy][_coordinates.x + _directions[_choice].ix] = 0
            -- Set new coords
            _coordinates.x += _directions[_choice].x
            _coordinates.y += _directions[_choice].y
        else
            -- If options list is empty then mark the current cell as finalized
            _plotted[_coordinates.y][_coordinates.x] = 2
        end
    elseif (_plotted[_coordinates.y][_coordinates.x] == 2) then
        _options = {}

        -- Same as previous neighboring cell step, but look for any neighboring cell that isn't finalized, not just unexplored
        for i = 1, 4 do
            if (_coordinates.x + _directions[i].x > 1 and _coordinates.x + _directions[i].x < _maxX and _coordinates.y + _directions[i].y > 1 and _coordinates.y + _directions[i].y < _maxY and _plotted[_coordinates.y + _directions[i].y][_coordinates.x + _directions[i].x] < 2) then
                _options[#_options + 1] = i
            end
        end

        -- If there are free spaces to move to, then...
        if(#_options > 0) then
            -- Select an available direction at random
            _choice = _options[flr(rnd(#_options)) + 1]
            -- Set new coords
            _coordinates.x += _directions[_choice].x
            _coordinates.y += _directions[_choice].y
        else
            _solved = false
            for i = 1, flr(#_genMap / 2) do
                for j = 1, flr(#_genMap[1] / 2) do
                    if (_plotted[i * 2][j * 2] == 1 and _solved == false) then
                        _coordinates.x = j * 2
                        _coordinates.y = i * 2
                        _solved = true
                    end
                end
            end

            if (_solved == false) then
                -- Done exploring! 
                _genProg.plotComplete = true
            end
        end
    end

    _genProg.genMap = _genMap
    _genProg.plotted = _plotted
    _genProg.coords = _coordinates

    mapPlot = _plotted
    currentCoords.x = _coordinates.x
    currentCoords.y = _coordinates.y

    return _genProg
end


-->8
-- where the magic happens
function _init()
    seed = generateMap(32, 32, 0, 0, 0, 0)
    currentMap = seed.map
end

function _update()
    
end

function _draw()
    local c_tbl =
    {
        [0] = initiateMaze,
        [1] = startScreen,
        [2] = menuSelect,
        [3] = drawRoom
    }

    local func = c_tbl[screenID]
    
    if(func) then
        func()
    else
        print("ERROR", 8)
        print("Got lost! screenID: " .. screenID, 7)
    end
end
__gfx__
00000000e8989898989898000000000000eeeeeeeeeeeeeeeeeeeeeeeeee7777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8eeeeeeeeeeeeeeeee
00000000e98989898989890000000000008989898989898988eeeeeeee77777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8eedddddddeeeeeeee
00700700e89898989898980000000000009898989898989898eeeeeee77777777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee8eddddddddeeeeeeee
00077000898989898989890000000000008989898989898989eeeeeee7777777777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee88ed1d1d1d1eeeeeeee
00077000989899999999980000000000009899999999999898eeeeee7777777777777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee88e1d1d1d1deeeeeeee
00700700898989898989890000000000008989898989898989eeeeee777777777777777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee88e01010101eeeeeeee
00000000989999999999990000000000009999999999999998eeeeee777777777777777777777777eeeeee77eeeeeeeeeeeeeeeeeeee888e10101010eeeeeeee
00000000898989999999890000000000008989999999898989eeeeee777777777777777777777777777777eeeeeeeeeeeeeeeeeeeeee88ee00000000eeeeeeee
eeeeeeee797999999999797000000000097979999999997979eeeeee7777777777777777777777777777eeeeeeeeeeeeeeeeeeeeeeee88ee2100000000000012
eeeeeeee899999999999978000000000078799999999998787eeeeeee77777777777777777777777777eeeeeeeeeeeeeeeeeeeeeeee88eee1000000000000001
eeeeeeee797979999979797000000000097979799999797977eeeeeeee77777777777777777777777eeeeeeeeeeeeeeeeeeeeeeeee888eee0000000000000000
eeeeeeeee7979999999797900000000007979799999997978eeeeeeeeeee7777777777777777777eeeeeeeeeeeeeeeeeeeeeeeeee888eeee0000000000000000
eeeeeeeee7797979797977700000000007777779797979777eeeeeeeeeeeee77777777777777eeeeeeeeeeeeeeeeeeeeeeeeeeee888eeeee0000000000000000
eeeeeeeee7979797979797770000000077777777777777979eeeeeeeeeeeeeeee777777777eeeeeeeeeeeeeeeeeeeeeeeeeeeee888eeeeee0000000000000000
eeeeeeeee7797979797977770000000077777777777779797eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888eeeeeee0000000000000000
eeeeeeeee7979797979797970000000097979799999999979eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee888eeeeeeee0000000000000000
eeeeeeeee7797979797977777000000979797979797999797eeeeeee000000008eeeeeeeeeeeeee8eeeeeeeeeeeeeeeeeee8888eeeeeeeee0000000000000077
eeeeeeeeee97979797979797900000079797979799999999eeeeeeee0000000028eeeeeeeeeeee82eeeeeeeeeeeeeeeee8888eeeeeeeeeee0000000000007777
eeeeeeeeee77777777777777770000777777797979797999eeeeeeee00000000128eeeeeeeeee821eeeeeeeeeeeeeee8888eeeeeeeeeeeee0000000000777777
eeeeeeeeee97979797979797970000979797979799999999eeeeeeee000000000128eeeeeeee8210eeeeeeeeee888eeeeeeeeeeeeeeeeeee0000000777777777
eeeeeeeeeee777777777777777700777777779797979799eeeeeeeee0000000000128eeeeee82100eeeeeeee888eeeeeeeeeeeeeeeeeeeee0000077777777777
eeeeeeeeeee797777777777777777777779797979799999eeeeeeeee00000000000128eeee821000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0007777777777777
eeeeeeeeeeee7777777777777777777777777779797979eeeeeeeeee000000000000128ee8210000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee0777777777777777
eeeeeeeeeeeee77777777777777777777797979797999eeeeeeeeeee000000000000012882100000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee7777777777777777
eeeeeeeeeeeeee777777777777777777777777797979eeeeeeeeeeee0000000000000000000000000777777777777700eeeeeeee000000070777777000000000
eeeeeeeeeeeeeee7777777777777777777979797999eeeeeeeeeeeee0000000000000000000000000777777777777700e8888888000007770777700000000000
eeeeeeeeeeeeeeeee777777777777777777779797eeeeeeeeeeeeeee000000000777777777777700077777777777770088888888000777770770000000000000
eeeeeeeeeeeeeeeeeee77777777777979797979eeeeeeeeeeeeeeeee077777770777777777777700077777777777770082828282077777770000000000000000
eeeeeeeeeeeeeeeeeeeeee77777777777779eeeeeeeeeeeeeeeeeeee077777770777777777777700077777777777770028282828077777700000000000000007
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee077777770777777777777700077777777777770012121212077770000000000000000777
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee077777770777777777777700077777777777770021212121077000000000000000077777
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000777777777777700077777777777770011111111000000000000000007777777
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000eeeeeeeeeeeeeeeeeeeeeee1111eccc11eeeeee1111eccc11eeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000eeeeeeeeeeeeeeeeee1111cccc1eeeeeee1111cccc1eeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000eeeeeeeeeee111111ccccceeeee111111ccccceeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000eeeeeeee1111cccccceeeeee1111cccccceeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000eeeeeec11ccccccceeeeeec11ccccccceeeeeeeeee
eeeeeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000eeeeeecccccccccceeeeeeccccccccceeeeeeeeeee
eeeeeeeeeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000eeeeeeeccccccceeeeeeeeecccccccceeeeeeeeeee
eeeeeeeeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeecccccccceeeeeeeecccccccceeeeeeeeeee
eeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeccccccceeeeeeeeeccccccceeeeeeeeeee
eeeeeeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeccccccceeeeeeeeeccccccceeeeeeeeeeee
eeeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeecccccccdeeeeeeeecccccccdeeeeeeeeeeee
eeeeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeecccccccdeeeeeeeecccccccdeeeeeeeeeeee
eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeccccccccddeeeeeeccccccccddeeeeeeeeeee
eeeeee00000000010101010100000000000000000000000000000000000000000000000000000000000eeeeeeeeccecccccddeeeeeeccecccccddeeeeeeeeeee
eeeee000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeecccccccccdddeeeecccccccccdddeeeeeeeeee
eeee010101010101010101010101010101010000000000000000000000000000000000000000000000eeeeeeeecccccccccdddeeeecccccccccdddeeeeeeeeee
eee0000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeecccccccccdeeeeedcccccccdddeeeeeeeeeee
ee0101010101010101010101010101010101010101000000000000000000000000000000000000000eeeeeeeeeeddccccccceeeeeeddddccccddeeeeeeeeeeee
ee0000000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeedddccccccceeeeeddddddcccdeeeeeeeeeeeee
eeee0101010101010101010101010101010101010101010000000000000000000000000000000000eeeeeeeeeeddcccceccceeeeeddddddcccceeeeeeeeeeeee
eeee000000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeedddccceeccceeeedddeddddcccecceeeeeeeeee
eee101010101010101010101010101010101010101010101010000000000000000000000000000eeeeeeeeeeeddcccceeccceeeeddeedddecccccceeeeeeeeee
eee0000010000000000000000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeddccccceccccceeddeeddddeccccceeeeeeeeee
ee010101010101010101010101010101010101010101010101010000000000000000000000eeeeeeeeeeeeeeeeeecccceccccceeeeeeedddecccceeeeeeeeeee
ee1010101010101010100000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeee88eeeeeeeeeeeeeeeeeee88eeeeeeeeeeeeeeeee
ee0101111111111111111111110101010101010101010101010101000000000000000000eeeeeeeeeeeeeeee28888888888888888888882eeeeeeeeeeeeeeeee
ee1010101010101010101010101010000000000000000000000000000000000000000000eeeeeeeeeeeeeeeee222222222222222222222eeeeeeeeeeeeeeeeee
e10111111111111111111111111111111101010101010101010101010100000000000000eeeeeeeeeeeeeeeeeee66555eeeeeee55566eeeeeeeeeeeeeeeeeeee
e01010101010101010101010101010101010000000000000000000000000000000000000eeeeeeeeeeeeeeeeee75676eeeeeeeee67567eeeeeeeeeeeeeeeeeee
e10111111111111111111111111111111111110101010101010101010100000000000000eeeeeeeeeeeeeeeeee7677eeeeeeeeeee7677eeeeeeeeeeeeeeeeeee
e0101010101010101010101010101010101010100000000000000000000000000000000eeeeeeeeeeeeeeeeeeee77eeeeeeeeeeeee77eeeeeeeeeeeeeeeeeeee
e1111111111111111111111111111111111111111101010101010101010100000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e0101010101010101111111010101010101010101010000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
01111111111111111111111111111111111111111111110101010101010101000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
1010101011111111111111111111111010101010101010100000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
1111111111111111111111111111111111111111111111111101010101010100000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
1010101011111111111111111111111110101010101010101010000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
111111111111111111111111111111111111111111111111111101010101010100000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
101010101111111111111111111111111110101010101010101000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
111111111111111111111111111111111111111111111111110101010101010100000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
10101010111111111111111111111111111010101010101010101000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
11111111111111111111111111111111111111111111111101010101010101010000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
1010101011111111111111111111111111101010101010101010100000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
1111111111111111111111111111111111111111111111110101010101010101000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
101010101111111111111111111111111110101010101010101010000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
111111111111111111111111111111111111111111111101010101010101010100eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
10101010101111111111111111111110101010101010101010101000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
11111111111111111111111111111111111111111111010101010101010101010eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
1010101010101111111111111110101010101010101010101010100000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e111111111111111111111111111111111111111110101010101010101010101eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e01010101010101010101010101010101010101010101010101000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
e1111111111111111111111111111111111111110101010101010101010101eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
ee10101010101010101010101010101010101010101010101010000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eee111111111111111111111111111111111110101010101010101010101eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeee1010101010101010101010101010101010101010101000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeee1111111111111111111111111101010101010101010101eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeee1010101010101010101010101010101010000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeee1111110101010101010101010eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
__map__
0b0b0b0b0b0b3636292836363636363600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0b0b0b0b0b36291e1f28363636363600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0b0b0b0b0b291e27271f283636363636363636363636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0b0b0b0b291e3737373d1f2836363636363636363636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0b0b0b291e2727272727271f28363636363636363636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0b0b291e3737373737373d271f283636363636363636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b0b291e2727272727272727273f1f2836363636363636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b291e3737373737373737373d3e271f28363636363636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
291e2727272727272727272727273f3d1f283636363636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e3737373737373737373737373d3e27271f2836363636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2727272727272727272727272727273f3d271f28363636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
37373737373737373737373737373d3e2727271f283636360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
27273839272727272727272727272727272727271f2836360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
27273a3b27272727272727272727272727272727271f28360000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
27273a3b2727272727272727272727272727272727271f280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
