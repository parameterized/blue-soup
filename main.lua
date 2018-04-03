
require 'utils'
require 'assets'
Camera = require 'camera'
require 'menu'
require 'procgen'
require 'physics'
require 'player'
require 'lighting'
require 'editor'
require 'debugger'

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
	player.load()
	lighting.load()
	editor.load()
	activeCamera = player.camera
end

function love.update(dt)
	if gameState == 'menu' then
		menu.update(dt)
	elseif gameState == 'playing' then
		physics.update(dt)
		player.update(dt)
		lighting.update(dt)
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
	if k == 'f1' then
		debugger.active = not debugger.active
	end
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
		player.keypressed(k, scancode, isrepeat)
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
		love.graphics.setBackgroundColor(20/255, 22/255, 26/255)
		
		local p = objects.player
		
		activeCamera:set()
		
		local bx, by, bw, bh = activeCamera:getAABB()
		local s = 100
		love.graphics.setColor(224/255, 224/255, 224/255, 200/255)
		if activeCamera.scale > 1/6 then
			for i=math.floor(bx/s), math.floor((bx+bw)/s) do
				for j=math.floor(by/s), math.floor((by+bh)/s) do
					love.graphics.circle('fill', i*s + hash(i, j)*s,
						j*s + hash(i + 1/2, j + 1/2)*s, 2 + hash(i + 1/3, j + 1/3)*2)
				end
			end
		end
		
		activeCamera:reset()
		
		love.graphics.setCanvas(canvases.preLight)
		love.graphics.clear()
		love.graphics.setShader(shaders.moon)
		sendCamera(shaders.moon)
		love.graphics.setColor(1, 1, 1)
		love.graphics.rectangle('fill', 0, 0, ssx, ssy)
		love.graphics.setShader()
		
		activeCamera:set()
		
		player.draw()
		
		activeCamera:reset()
		
		love.graphics.setCanvas()
		love.graphics.setShader(shaders.lighting)
		local lightCanvas = lighting.getLightCanvas()
		shaders.lighting:send('lightMap', lightCanvas)
		love.graphics.setColor(1, 1, 1)
		love.graphics.draw(canvases.preLight, 0, 0)
		love.graphics.setShader()
		
		--love.graphics.draw(lightCanvas, 0, 0)
		
		debugger.draw()
	end
end

function love.quit()
	-- love sometimes crashes on exit without this
	physics.removeAllChunks()
end