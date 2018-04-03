
player = {spd=400, friction=0.05}

function player.load()
	local px = 0
	local py = -(moonRadius + 80)
	
	objects.player = {
		body = love.physics.newBody(world, px, py, 'dynamic'),
		shape = love.physics.newCircleShape(18)
	}
	objects.playerSensorDown = {
		body = love.physics.newBody(world, px, py + 6, 'dynamic'),
		shape = love.physics.newCircleShape(16)
	}
	
	objects.player.fixture = love.physics.newFixture(
		objects.player.body, objects.player.shape)
	objects.player.fixture:setUserData{type='player'}
	objects.player.body:setFixedRotation(true)
	
	objects.playerSensorDown.fixture = love.physics.newFixture(
		objects.playerSensorDown.body, objects.playerSensorDown.shape)
	objects.playerSensorDown.fixture:setUserData{type='playerSensorDown'}
	objects.playerSensorDown.fixture:setSensor(true)
	objects.playerSensorDown.body:setFixedRotation(true)
	
	player.inAir = true	
	player.cursor = {x=0, y=0}
	
	local pb = objects.player.body
	player.camera = Camera{x=pb:getX(), y=pb:getY()}
end

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
	
	local psd = objects.playerSensorDown
	local lastpsdx, lastpsdy = psd.body:getPosition()
	local psdx, psdy = pb:getX() + math.cos(ga)*6, pb:getY() - math.sin(ga)*6
	psd.body:setPosition(psdx, psdy)
	-- need to set velocity?
	psd.body:setLinearVelocity((psdx - lastpsdx)/dt, (psdy - lastpsdy)/dt)
	
	local jumpContacts = psd.body:getContacts()
	player.inAir = true
	for _, v in pairs(jumpContacts) do
		if v:isTouching() then
			local fix = {v:getFixtures()}
			for i=1, 2 do
				local ud = fix[i]:getUserData()
				if type(ud) == 'table' then
					if not (ud.type == 'playerSensorDown' or ud.type == 'player') then
						player.inAir = false
					end
				else
					player.inAir = false
				end
			end
		end
	end
	
	local mx, my = love.mouse.getPosition()
	mx, my = player.camera:screen2world(mx, my)
	player.cursor = {x=mx, y=my}
	
	local pc = player.camera
	local ct = player.getCameraTarget()
	pc.x = lerp(pc.x, ct.x, dt*8)
	pc.y = lerp(pc.y, ct.y, dt*8)
	pc.scale = lerp(pc.scale, ct.scale, dt*8)
	pc.rotation = lerpAngle(pc.rotation, ct.rotation, dt*8)
end

function player.jump()
	local pb = objects.player.body
	local gx = 0 - pb:getX()
	local gy = 0 - pb:getY()
	local ga = math.atan2(gx, gy) - math.pi/2
	local xv, yv = pb:getLinearVelocity()
	-- todo: get horizontal/vertical velocity and set vertical
	xv = xv + math.cos(ga + math.pi)*5e2
	yv = yv - math.sin(ga + math.pi)*5e2
	pb:setLinearVelocity(xv, yv)
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

function player.keypressed(k, scancode, isrepeat)
	if k == 'space' then
		if not player.inAir then
			player.jump()
		end
	end
end

function player.draw()
	local p = objects.player
	local px, py = p.body:getX(), p.body:getY()
	love.graphics.setColor(160/255, 64/255, 64/255)
	love.graphics.circle('fill', px, py, p.shape:getRadius()+1)
	local a = math.atan2(player.cursor.x-px, player.cursor.y-py) - math.pi/2
	love.graphics.circle('fill', px + math.cos(a)*18, py - math.sin(a)*18, 12)
end