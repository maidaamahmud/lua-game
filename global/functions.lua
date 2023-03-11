local json = require("json")

function drawStar(group, x, y, size, style)
  -- this function drawing the actual star using polygons is not my own code, however was modified by me to fit my purpose
  local halfSize = size / 2
  local angle = math.pi / 5

  local points = {}
  for i = 0, 9 do
    local r = (i % 2 == 0) and size or halfSize
    local theta = i * angle
    points[#points + 1] = x + r * math.sin(theta)
    points[#points + 1] = y - r * math.cos(theta)
  end

  local star = display.newPolygon(group, x, y, points)
  if style == "filled" then
    star:setFillColor(1, 1, 1)
  else 
    star.strokeWidth = 1 -- change the stroke width to adjust the thickness of the outline
    star:setStrokeColor(1, 1, 1) -- set the stroke color to white
    star:setFillColor(0, 0, 0, 0) -- set the fill color to transparent
  end
end

function readHighscores()
  filePath = system.pathForFile("highscores.json", system.DocumentsDirectory)
  local file = io.open( filePath, "r" )
  if file then
      local contents = file:read( "*a" )
      if contents == "" then
        contents = "{}"
      end
      io.close( file )
      highscores = json.decode( contents )
  end
end