
editor = {}

function editor.load()
	editor.camera = Camera()
	editor.camTarget = {x=0, y=0, scale=1/16, rotation=0}
end

function editor.update(dt)
	local ec = editor.camera
	local ect = editor.camTarget
	ec.x = lerp(ec.x, ect.x, dt*8)
	ec.y = lerp(ec.y, ect.y, dt*8)
	ec.scale = lerp(ec.scale, ect.scale, dt*8)
	ec.rotation = lerpAngle(ec.rotation, ect.rotation, dt*8)
end

function editor.mousepressed(x, y, btn, isTouch)
	
end

function editor.mousemoved(x, y, dx, dy)
	if love.mouse.isDown(2) then
		local wx1, wy1 = editor.camera:screen2world(x - dx, y - dy)
		local wx2, wy2 = editor.camera:screen2world(x, y)
		local wdx, wdy = wx2 - wx1, wy2 - wy1
		editor.camTarget.x = editor.camTarget.x - wdx
		editor.camTarget.y = editor.camTarget.y - wdy
	end
end

function editor.wheelmoved(x, y)
	if love.mouse.isDown(2) then
		local ectr = editor.camTarget.rotation
		ectr = ectr + y*math.pi/16
		ectr = ((ectr + math.pi) % (2*math.pi)) - math.pi
		editor.camTarget.rotation = ectr
	else
		editor.camTarget.scale =
			editor.camTarget.scale*(1 + y*0.2)
	end
end

function editor.keypressed(k, scancode, isrepeat)
	if k == 'tab' then
		setGameState('playing')
	elseif k == 'f' then
		local ct = player.getCameraTarget()
		editor.camTarget = {x=ct.x, y=ct.y, scale=ct.scale, rotation=ct.rotation}
	elseif k == 'escape' then
		setGameState('menu')
	end
end

function editor.textinput(t)
	
end