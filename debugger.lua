
debugger = {active=false}

function debugger.draw()
	if debugger.active then
		activeCamera:set()
		
		love.graphics.setColor(120/255, 180/255, 240/255, 224/255)
		for k, v in pairs(physics.chunks) do
			for k2, v2 in pairs(v.colliders) do
				love.graphics.polygon('fill', v2.body:getWorldPoints(v2.shape:getPoints()))
			end
		end
		
		local p = objects.player
		local px, py = p.body:getX(), p.body:getY()
		love.graphics.setColor(120/255, 180/255, 240/255, 120/255)
		love.graphics.circle('fill', px, py, p.shape:getRadius()+1)
		
		local psd = objects.playerSensorDown
		local psdx, psdy = psd.body:getX(), psd.body:getY()
		love.graphics.setColor(240/255, 180/255, 80/255, 120/255)
		love.graphics.circle('fill', psdx, psdy, psd.shape:getRadius()+1)
		
		local cs = physics.chunkSize
		local ts = physics.tileSize
		local cx, cy, cw, ch = physics.getChunkWindow()
		cx, cy = cx*cs*ts, cy*cs*ts
		cw, ch = (cw+1)*cs*ts, (ch+1)*cs*ts
		love.graphics.setColor(120/255, 240/255, 180/255, 40/255)
		love.graphics.rectangle('fill', cx, cy, cw, ch)
		
		activeCamera:reset()
		
		love.graphics.setColor(0/255, 255/255, 0/255)
		love.graphics.setFont(fonts.f12)
		--love.graphics.print('cam scale: ' .. activeCamera.scale, 4, 4)
		--love.graphics.print('cam rot: ' .. activeCamera.rotation, 4, 20)
	end
end