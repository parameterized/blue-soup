
lighting = {chunks={}, chunkSize=512, blurSize=8, downsample=16}

function lighting.load()
	local cs, bs = lighting.chunkSize, lighting.blurSize
	local csd = math.floor(cs/lighting.downsample)
	lighting.canvases = {
		chunkWorld = love.graphics.newCanvas(csd + bs*2, csd + bs*2),
		chunkWorldBuffer = love.graphics.newCanvas(csd + bs*2, csd + bs*2),
		chunkLight = love.graphics.newCanvas(cs, cs),
		camLight = love.graphics.newCanvas(ssx, ssy)
	}
end

function lighting.update(dt)
	lighting.updateChunkWindow()
end

function lighting.updateChunkWindow()
	-- todo: compute asynchronously with margin? - for collision too
	--  - limit camera/player movement if not computed yet
	local cx1, cy1, cw, ch = lighting.getChunkWindow()
	local cx2, cy2 = cx1 + cw, cy1 + ch
	local newChunks = {}
	for i=cx1, cx2 do
		for j=cy1, cy2 do
			newChunks[i .. ',' .. j] = true
		end
	end
	for k, v in pairs(lighting.chunks) do
		if newChunks[k] then
			newChunks[k] = nil
		else
			lighting.removeChunk(k)
		end
	end
	for k, v in pairs(newChunks) do
		lighting.updateChunk(k)
	end
end

function lighting.getChunkWindow()
	local bx, by, bw, bh = player.camera:getAABB()
	local cs = lighting.chunkSize
	local cx = math.floor(bx/cs)
	local cy = math.floor(by/cs)
	local cw = math.floor((bx + bw)/cs) - cx
	local ch = math.floor((by + bh)/cs) - cy
	return cx, cy, cw, ch
end

function lighting.removeChunk(k)
	lighting.chunks[k] = nil
end

function lighting.removeAllChunks()
	for k, v in pairs(lighting.chunks) do
		lighting.removeChunk(k)
	end
end

function lighting.updateChunk(k)
	lighting.removeChunk(k)
	local kx, ky = k:match('([^,]+),([^,]+)')
	local originalCanvas = love.graphics.getCanvas()
	local originalShader = love.graphics.getShader()
	love.graphics.push()
	love.graphics.origin()
	
	local cs = lighting.chunkSize
	local bs = lighting.blurSize
	local ds = lighting.downsample
	local csd = math.floor(cs/ds)
	local cw = lighting.canvases.chunkWorld
	local cwb = lighting.canvases.chunkWorldBuffer
	local cl = lighting.canvases.chunkLight
	love.graphics.setCanvas(cw)
	love.graphics.clear(1, 1, 1)
	love.graphics.setColor(1, 1, 1)
	love.graphics.setShader(shaders.moonLightMask)
	shaders.moonLightMask:send('chunkPos', {kx*cs - bs*ds, ky*cs - bs*ds})
	shaders.moonLightMask:send('stepSize', ds)
	love.graphics.rectangle('fill', 0, 0, csd + bs*2, csd + bs*2)
	
	love.graphics.setCanvas(cwb)
	love.graphics.clear(1, 1, 1)
	love.graphics.setShader(shaders.blur)
	shaders.blur:send('steps', bs)
	shaders.blur:send('dir', {1, 0})
	love.graphics.draw(cw, 0, 0)
	love.graphics.setCanvas(cw)
	shaders.blur:send('dir', {0, 1})
	love.graphics.draw(cwb, 0, 0)
	
	love.graphics.setCanvas(cl)
	love.graphics.clear(1, 1, 1)
	love.graphics.setShader()
	love.graphics.draw(cw, -bs*ds, -bs*ds, 0, ds, ds)
	
	love.graphics.pop()
	love.graphics.setCanvas(originalCanvas)
	love.graphics.setShader(originalShader)
	
	lighting.chunks[k] = love.graphics.newImage(cl:newImageData())
end

function lighting.getLightCanvas()
	local originalCanvas = love.graphics.getCanvas()
	local originalShader = love.graphics.getShader()
	local originalBlendMode = love.graphics.getBlendMode()
	love.graphics.push()
	love.graphics.origin()
	
	activeCamera:set()
	
	local cx, cy, cw, ch = lighting.getChunkWindow()
	local cs = lighting.chunkSize
	local cl = lighting.canvases.camLight
	love.graphics.setCanvas(cl)
	love.graphics.setShader()
	love.graphics.clear(1, 1, 1)
	love.graphics.setColor(1, 1, 1)
	for i=cx, cx+cw do
		for j=cy, cy+ch do
			local chunk = lighting.chunks[i .. ',' .. j]
			if chunk then
				love.graphics.draw(chunk, i*cs, j*cs)
			end
		end
	end
	local pb = objects.player.body
	local a = math.atan2(player.cursor.x-pb:getX(), -(player.cursor.y-pb:getY())) - math.pi/2
	love.graphics.setBlendMode('add')
	love.graphics.draw(gfx.flashlight, pb:getX(), pb:getY(), a, 1, 1,
		gfx.flashlight:getWidth()/2, gfx.flashlight:getHeight()/2)
	
	activeCamera:reset()
	
	love.graphics.pop()
	love.graphics.setBlendMode(originalBlendMode)
	love.graphics.setCanvas(originalCanvas)
	love.graphics.setShader(originalShader)
	return cl
end
