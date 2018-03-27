
require 'utils'
require 'assets'
require 'camera'
require 'menu'
require 'physics'
require 'player'

function love.load()
	gamestate = 'menu'
	gctimer = love.timer.getTime()
	loadgame()
end

function loadgame()
	physics.load()
	local pb = objects.player.body
	camera.x = pb:getX()
	camera.y = pb:getY()
	camera.scale = 1
	camera.rotation = 0
end

function love.update(dt)
	if gamestate == 'menu' then
		menu.update(dt)
	elseif gamestate == 'playing' then
		physics.update(dt)
		player.update(dt)
	end
	
	if love.timer.getTime() - gctimer > 10 then
		collectgarbage()
		gctimer = gctimer + 10
	end
end

function love.mousepressed(x, y, btn, isTouch)
	if gamestate == 'menu' then
		menu.mousepressed(x, y, btn, isTouch)
	elseif gamestate == 'playing' then
		
	end
end

function love.keypressed(k, scancode, isrepeat)
	if gamestate == 'menu' then
		menu.keypressed(k, scancode, isrepeat)
	elseif gamestate == 'playing' then
		if k == 'r' then
			loadgame()
		elseif k == 'escape' then
			gamestate = 'menu'
		end
	end
end

function love.draw()
	if gamestate == 'menu' then
		menu.draw()
	elseif gamestate == 'playing' then
		love.graphics.setBackgroundColor(20, 22, 26)
		
		local p = objects.player
		
		camera.set()
		
		local bx, by, bw, bh = camera.getAABB()
		local s = 100
		love.graphics.setColor(224, 224, 224, 200)
		for i=math.floor(bx/s), math.floor((bx+bw)/s) do
			for j=math.floor(by/s), math.floor((by+bh)/s) do
				love.graphics.circle('fill', i*s + hash(i, j)*s,
					j*s + hash(i + 1/2, j + 1/2)*s, 2 + hash(i + 1/3, j + 1/3)*2)
			end
		end
		
		camera.reset()
		
		love.graphics.setShader(shaders.moon)
		sendCamera(shaders.moon)
		love.graphics.setColor(255, 255, 255)
		love.graphics.rectangle('fill', 0, 0, ssx, ssy)
		love.graphics.setShader()
		
		camera.set()
		
		player.draw()
		
		--debug collision
		--[[
		love.graphics.setColor(180, 244, 200, 244)
		for k, v in pairs(physics.chunks) do
			for k2, v2 in pairs(v.colliders) do
				love.graphics.polygon('fill', v2.body:getWorldPoints(v2.shape:getPoints()))
			end
		end
		]]
		
		camera.reset()
		
		love.graphics.setColor(0, 255, 0)
		love.graphics.setFont(fonts.f12)
		--love.graphics.print(camera.scale, 0, 0)
	end
end
