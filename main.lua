
require 'utils'
camera = require 'camera'
require 'player'

ssx = love.graphics.getWidth()
ssy = love.graphics.getHeight()

love.filesystem.setIdentity(love.window.getTitle())
math.randomseed(love.timer.getTime())

killtmax = 0

function love.load()
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 0, true)
	
	objects = {}
	objects.planet = {
		body = love.physics.newBody(world, 0, 0, 'static'),
		shape = love.physics.newCircleShape(1200)
	}
	objects.planet.fixture = love.physics.newFixture(objects.planet.body, objects.planet.shape)
	decals = {}
	for i=1, 50 do
		local r = (objects.planet.shape:getRadius()-100)*math.sqrt(math.random())
		local a = math.random()*2*math.pi
		local pts = {}
		local r2 = 40 + math.random()*60
		local a2o = math.random()*2*math.pi
		for j=1, 8 do
			local a2 = a2o + j/8*2*math.pi
			local x = math.cos(a)*r + math.cos(a2)*r2
			local y = -math.sin(a)*r - math.sin(a2)*r2
			table.insert(pts, x)
			table.insert(pts, y)
		end
		table.insert(decals, pts)
	end
	
	objects.player = {
		body = love.physics.newBody(world, 0, -objects.planet.shape:getRadius() - 18, 'dynamic'),
		shape = love.physics.newCircleShape(18)
	}
	objects.player.fixture = love.physics.newFixture(objects.player.body, objects.player.shape)
	local pb = objects.player.body
	
	camera.x = pb:getX()
	camera.y = pb:getY()
	
	killa = 1150
	killb = 2000
	killt = 0
end

function love.update(dt)
	world:update(dt)
	
	player.update(dt)
	
	killt = killt + dt
	killa = killa + dt*10
	killb = killb - dt*10
	
	local gx = objects.planet.body:getX() - objects.player.body:getX()
	local gy = objects.planet.body:getY() - objects.player.body:getY()
	local gd = math.sqrt(gx^2 + gy^2)
	
	if gd - 18 < killa or gd + 18 > killb then
		killtmax = math.max(killt, killtmax)
		love.load()
	end
end

function love.keypressed(k, scancode, isrepeat)
	if k == 'r' then
		love.load()
	elseif k == 'escape' then
		love.event.quit()
	end
end

function love.draw()
	love.graphics.setBackgroundColor(20, 22, 26)
	
	local planet = objects.planet
	local p = objects.player
	
	local gx = planet.body:getX() - p.body:getX()
	local gy = planet.body:getY() - p.body:getY()
	local ga = math.atan2(gx, gy) - math.pi/2
	local gd = math.sqrt(gx^2 + gy^2)
	
	camera.rotation = ga + math.pi/2
	camera.scale = 1/((gd-planet.shape:getRadius())^0.8/50+1)
	camera.scale = camera.scale > 0.5 and camera.scale or camera.scale^2 + 0.25
	--camera.scale = 1
	
	camera.set()
	
	love.graphics.setColor(224, 224, 224, 200)
	local s = 100
	local px = math.floor(p.body:getX()/s)
	local py = math.floor(p.body:getY()/s)
	local d = math.floor(math.sqrt(ssx^2 + ssy^2)/2/s/camera.scale)
	for i=-d, d do
		for j=-d, d do
			love.graphics.circle('fill', px*s + i*s + hash(px + i, py + j)*s,
				py*s + j*s + hash(px + i + 1/2, py + j + 1/2)*s, 2 + hash(px + i + 1/3, py + j + 1/3)*2)
		end
	end
	
	love.graphics.setColor(224, 224, 224)
	love.graphics.circle('fill', planet.body:getX(), planet.body:getY(), planet.shape:getRadius()+1)
	love.graphics.setColor(200, 200, 200)
	for i, v in pairs(decals) do
		love.graphics.polygon('fill', v)
	end
	
	player.draw()
	
	love.graphics.setColor(255, 0, 0, 100)
	love.graphics.circle('fill', planet.body:getX(), planet.body:getY(), killa)
	
	love.graphics.stencil(function()
		love.graphics.circle('fill', planet.body:getX(), planet.body:getY(), killb)
	end, 'replace', 1)
	
	camera.reset()
	
	love.graphics.setStencilTest('equal', 0)
	
	love.graphics.setColor(255, 0, 0, 100)
	love.graphics.rectangle('fill', 0, 0, ssx, ssy)
	
	love.graphics.setStencilTest()
	
	love.graphics.setColor(0, 255, 0)
	--love.graphics.print(camera.scale, 0, 0)
	love.graphics.print('alive for ' .. math.floor(killt) .. ' seconds', 4, 4)
	love.graphics.print('max: ' .. math.floor(killtmax), 4, 20)
end
