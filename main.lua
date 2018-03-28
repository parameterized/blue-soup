
require 'utils'
require 'assets'
require 'camera'
require 'menu'
require 'procgen'
require 'physics'
require 'player'
require 'editor'

function love.load()
	gameState = 'menu'
	lastGameState = 'menu'
	moonRadius = 5000
	gctimer = love.timer.getTime()
	loadgame()
end

function loadgame()
	procgen.load()
	physics.load()
	editor.load()
	local pb = objects.player.body
	camera.x = pb:getX()
	camera.y = pb:getY()
	camera.scale = 1
	camera.rotation = 0
end

function love.update(dt)
	if gameState == 'menu' then
		menu.update(dt)
	elseif gameState == 'playing' then
		physics.update(dt)
		player.update(dt)
	elseif gameState == 'editor' then
		editor.update(dt)
	end
	
	love.window.setTitle('Blue Soup (' .. love.timer.getFPS() .. ' FPS)')
	
	if love.timer.getTime() - gctimer > 10 then
		collectgarbage()
		gctimer = gctimer + 10
	end
end

function love.mousepressed(x, y, btn, isTouch)
	if gameState == 'menu' then
		menu.mousepressed(x, y, btn, isTouch)
	elseif gameState == 'playing' then
		
	elseif gameState == 'editor' then
		editor.mousepressed(x, y, btn, isTouch)
	end
end

function love.mousemoved(x, y, dx, dy)
	if gameState == 'editor' then
		editor.mousemoved(x, y, dx, dy)
	end
end

function love.wheelmoved(x, y)
	if gameState == 'editor' then
		editor.wheelmoved(x, y)
	end
end

function love.keypressed(k, scancode, isrepeat)
	if gameState == 'menu' then
		menu.keypressed(k, scancode, isrepeat)
	elseif gameState == 'playing' then
		if k == 'r' then
			loadgame()
		elseif k == 'tab' then
			setGameState('editor')
		elseif k == 'escape' then
			setGameState('menu')
		end
	elseif gameState == 'editor' then
		editor.keypressed(k, scancode, isrepeat)
	end
end

function love.textinput(t)
	if gameState == 'editor' then
		editor.textinput(t)
	end
end

function love.draw()
	if gameState == 'menu' then
		menu.draw()
	elseif gameState == 'playing' or gameState == 'editor' then
		love.graphics.setBackgroundColor(20, 22, 26)
		
		local p = objects.player
		
		camera.set()
		
		local bx, by, bw, bh = camera.getAABB()
		local s = 100
		love.graphics.setColor(224, 224, 224, 200)
		if camera.scale > 1/10 then
			for i=math.floor(bx/s), math.floor((bx+bw)/s) do
				for j=math.floor(by/s), math.floor((by+bh)/s) do
					love.graphics.circle('fill', i*s + hash(i, j)*s,
						j*s + hash(i + 1/2, j + 1/2)*s, 2 + hash(i + 1/3, j + 1/3)*2)
				end
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
		--love.graphics.print(camera.scale, 4, 4)
		--love.graphics.print(camera.rotation, 4, 20)
	end
end
