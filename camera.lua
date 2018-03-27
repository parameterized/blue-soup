
camera = {x=0, y=0, scale=1, rotation=0}

function camera.set()
	local ssx, ssy = love.graphics.getDimensions()
	love.graphics.push()
	love.graphics.translate(ssx/2, ssy/2)
	love.graphics.scale(camera.scale)
	love.graphics.rotate(camera.rotation)
	love.graphics.translate(-camera.x, -camera.y)
end

function camera.reset()
	love.graphics.pop()	
end

function camera.screen2world(x, y)
	x = x - ssx/2
	y = y - ssy/2
	x = x / camera.scale
	y = y / camera.scale
	x, y = rotate(x, y, camera.rotation)
	x = x + camera.x
	y = y + camera.y
	return x, y
end

function camera.getAABB()
	-- probably optimizable
	local pts = {
		{x=ssx, y=0},
		{x=ssx, y=ssy},
		{x=0, y=ssy},
		{x=0, y=0}
	}
	local minx, maxx, miny, maxy
	for _, v in pairs(pts) do
		local x, y = camera.screen2world(v.x, v.y)
		minx = minx and math.min(x, minx) or x
		maxx = maxx and math.max(x, maxx) or x
		miny = miny and math.min(y, miny) or y
		maxy = maxy and math.max(y, maxy) or y
	end
	local x, y, w, h = minx, miny, maxx - minx, maxy - miny
	return x, y, w, h
end