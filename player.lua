
player = {spd=400, friction=0.05}

function player.update(dt)
	local pb = objects.player.body
	
	local gx = objects.planet.body:getX() - pb:getX()
	local gy = objects.planet.body:getY() - pb:getY()
	local ga = math.atan2(gx, gy) - math.pi/2
	local gd = math.sqrt(gx^2 + gy^2)
	gx = math.cos(ga)
	gy = -math.sin(ga)
	pb:applyForce(gx/gd^2*1e9, gy/gd^2*1e9)
	
	if love.keyboard.isDown('d') then
		local a = ga + math.pi/2
		local xv = math.cos(a)*player.spd
		local yv = -math.sin(a)*player.spd
		pb:applyForce(xv, yv)
	elseif love.keyboard.isDown('a') then
		local a = ga - math.pi/2
		local xv = math.cos(a)*player.spd
		local yv = -math.sin(a)*player.spd
		pb:applyForce(xv, yv)
	end
	if love.keyboard.isDown('w') then
		local a = ga + math.pi
		local xv = math.cos(a)*player.spd
		local yv = -math.sin(a)*player.spd
		pb:applyForce(xv, yv)
	elseif love.keyboard.isDown('s') then
		local a = ga
		local xv = math.cos(a)*player.spd
		local yv = -math.sin(a)*player.spd
		pb:applyForce(xv, yv)
	end
	local xv, yv = pb:getLinearVelocity()
	pb:applyForce(-xv*player.friction, -yv*player.friction)
	
	camera.x = lerp(camera.x, pb:getX(), dt*8)
	camera.y = lerp(camera.y, pb:getY(), dt*8)
end

function player.draw()
	local p = objects.player
	love.graphics.setColor(160, 64, 64)
	love.graphics.circle('fill', p.body:getX(), p.body:getY(), p.shape:getRadius()+1)
end