function drawStar(group, x, y, size)
  -- this function is not my own code, however was slightly modified by me
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
  star:setFillColor(1, 1, 1)
end

