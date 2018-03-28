
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
	local gf = 6e9/gd^2
	-- assuming constant density underground, linear would be more accurate
	if gd < moonRadius then
		gf = lerp(0, 6e9/moonRadius^2, gd/moonRadius)
	end
	pb:applyForce(gx*gf, gy*gf)
	
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
	
	local ct = player.getCameraTarget()
	camera.x = lerp(camera.x, ct.x, dt*8)
	camera.y = lerp(camera.y, ct.y, dt*8)
	camera.scale = lerp(camera.scale, ct.scale, dt*8)
	camera.rotation = lerpAngle(camera.rotation, ct.rotation, dt*8)
end

function player.getCameraTarget()
	local ct = {}
	local pb = objects.player.body
	ct.x = pb:getX()
	ct.y = pb:getY()
	local gx = 0 - pb:getX()
	local gy = 0 - pb:getY()
	local ga = math.atan2(gx, gy) - math.pi/2
	local gd = math.sqrt(gx^2 + gy^2)
	local cst = 1/(math.max(gd - (moonRadius + 100), 1)^0.8/50+1)
	cst = cst > 0.5 and cst or cst^2 + 0.25
	ct.scale = cst
	ct.rotation = ga + math.pi/2
	return ct
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