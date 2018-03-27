
player = {spd=400, friction=0.05}

function player.update(dt)
	local pb = objects.player.body
	
	-- 0,0 - moon pos
	local gx = 0 - pb:getX()
	local gy = 0 - pb:getY()
	local ga = math.atan2(gx, gy) - math.pi/2
	local gd = math.sqrt(gx^2 + gy^2)
	gx = math.cos(ga)
	gy = -math.sin(ga)
	pb:applyForce(gx/gd^2*1e9, gy/gd^2*1e9)
	
	local dx, dy = 0, 0
	dx = dx + (love.keyboard.isDown('d') and 1 or 0)
	dx = dx + (love.keyboard.isDown('a') and -1 or 0)
	dy = dy + (love.keyboard.isDown('w') and -1 or 0)
	dy = dy + (love.keyboard.isDown('s') and 1 or 0)
	local dd = math.sqrt(dx^2 + dy^2)
	local a = ga + math.atan2(dx, dy)
	if dd > 0 then
		pb:applyForce(math.cos(a)*player.spd, -math.sin(a)*player.spd)
	end
	
	local xv, yv = pb:getLinearVelocity()
	pb:applyForce(-xv*player.friction, -yv*player.friction)
	
	camera.x = lerp(camera.x, pb:getX(), dt*8)
	camera.y = lerp(camera.y, pb:getY(), dt*8)
	camera.scale = 1/(math.max(gd-1300, 1)^0.8/50+1)
	camera.scale = camera.scale > 0.5 and camera.scale or camera.scale^2 + 0.25
	camera.rotation = ga + math.pi/2
end

function player.draw()
	local p = objects.player
	local px, py = p.body:getX(), p.body:getY()
	love.graphics.setColor(160, 64, 64)
	love.graphics.circle('fill', px, py, p.shape:getRadius()+1)
	
	local mx, my = love.mouse.getPosition()
	mx, my = camera.screen2world(mx, my)
	local a = math.atan2(mx-px, my-py) - math.pi/2
	love.graphics.circle('fill', px + math.cos(a)*18, py - math.sin(a)*18, 12)
end