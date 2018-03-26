
local camera = {x=0, y=0, scale=1, rotation=0}

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

return camera