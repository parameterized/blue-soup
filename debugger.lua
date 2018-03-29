
debugger = {active=false}

function debugger.draw()
	if debugger.active then
		activeCamera:set()
		
		love.graphics.setColor(120, 180, 240, 224)
		for k, v in pairs(physics.chunks) do
			for k2, v2 in pairs(v.colliders) do
				love.graphics.polygon('fill', v2.body:getWorldPoints(v2.shape:getPoints()))
			end
		end
		
		local p = objects.player
		local px, py = p.body:getX(), p.body:getY()
		love.graphics.setColor(120, 180, 240, 120)
		love.graphics.circle('fill', px, py, p.shape:getRadius()+1)
		
		local psd = objects.playerSensorDown
		local psdx, psdy = psd.body:getX(), psd.body:getY()
		love.graphics.setColor(240, 180, 80, 120)
		love.graphics.circle('fill', psdx, psdy, psd.shape:getRadius()+1)
		
		local cs = physics.chunkSize
		local ts = physics.tileSize
		local cx1, cy1, cw, ch = physics.getChunkWindow()
		local cx2, cy2 = cx1 + cw, cy1 + ch
		cx, cy = cx1*cs*ts, cy1*cs*ts
		cx2, cy2 = (cx2+1)*cs*ts + cs*ts, (cy2+1)*cs*ts + cs*ts
		cw, ch = cx2-cx, cy2-cy
		love.graphics.setColor(120, 240, 180, 40)
		love.graphics.rectangle('fill', cx, cy, cw, ch)
		
		activeCamera:reset()
		
		love.graphics.setColor(0, 255, 0)
		love.graphics.setFont(fonts.f12)
		--love.graphics.print('cam scale: ' .. activeCamera.scale, 4, 4)
		--love.graphics.print('cam rot: ' .. activeCamera.rotation, 4, 20)
	end
end