
physics = {chunks={}, chunkSize=16, tileSize=16}

function physics.load()
	love.physics.setMeter(64)
	objects = {}
	canvases.density = love.graphics.newCanvas(physics.chunkSize+1, physics.chunkSize+1)
	physics.lastChunkWindow = nil
	physics.removeAllChunks()
	world = love.physics.newWorld(0, 0, true)
end

function physics.update(dt)
	world:update(dt)
	
	local cx1, cw, cy1, ch = physics.getChunkWindow()
	local cx2, cy2 = cx1 + cw, cy1 + ch
	local plcw = physics.lastChunkWindow
	if not plcw or not (plcw[1] == cx1 and plcw[2] == cx2
	and plcw[3] == cy1 and plcw[4] == cy2) then
		physics.lastChunkWindow = {cx1, cx2, cy1, cy2}
		physics.updateChunkWindow()
	end
end

function physics.getChunkWindow()
	-- todo: when multiple physics objects change to getActiveChunks and includ bb + margin of each
	local ctc = Camera(player.getCameraTarget())
	-- localize more for optimization - could be bb of player collider + margin for movement
	ctc.scale = ctc.scale * 4
	local bx, by, bw, bh = ctc:getAABB()
	local cs, ts = physics.chunkSize, physics.tileSize
	local cx = math.floor(bx/ts/cs)
	local cy = math.floor(by/ts/cs)
	local cw = math.floor((bx + bw)/ts/cs) - cx
	local ch = math.floor((by + bh)/ts/cs) - cy
	return cx, cy, cw, ch
end

function physics.updateChunkWindow()
	local cx1, cy1, cw, ch = physics.getChunkWindow()
	local cx2, cy2 = cx1 + cw, cy1 + ch
	local newChunks = {}
	for i=cx1, cx2 do
		for j=cy1, cy2 do
			newChunks[i .. ',' .. j] = true
		end
	end
	for k, v in pairs(physics.chunks) do
		if newChunks[k] then
			newChunks[k] = nil
		else
			-- todo: remove after out of larger range
			--  - (shouldnt recalculate when jumping in place)
			physics.removeChunk(k)
		end
	end
	for k, v in pairs(newChunks) do
		physics.updateChunk(k)
	end
end

function physics.removeChunk(k)
	local pck = physics.chunks[k]
	if type(pck) == 'table' then
		for k2, v in pairs(pck.colliders) do
			v.body:destroy()
		end
	end
	physics.chunks[k] = nil
end

function physics.removeAllChunks()
	for k, v in pairs(physics.chunks) do
		physics.removeChunk(k)
	end
end

function physics.updateChunk(k)
	physics.removeChunk(k)
	physics.chunks[k] = {polys={}, colliders={}}
	local pck = physics.chunks[k]
	local kx, ky = k:match('([^,]+),([^,]+)')
	local cs = physics.chunkSize
	local ts = physics.tileSize
	local originalCanvas = love.graphics.getCanvas()
	local originalShader = love.graphics.getShader()
	love.graphics.setCanvas(canvases.density)
	love.graphics.setShader(shaders.moonDensity)
	shaders.moonDensity:send('chunkPos', {kx*cs*ts, ky*cs*ts})
	shaders.moonDensity:send('tileSize', ts)
	love.graphics.rectangle('fill', 0, 0, cs+1, cs+1)
	love.graphics.setCanvas(originalCanvas)
	love.graphics.setShader(originalShader)
	local density = canvases.density:newImageData()
	for i=kx*cs, (kx+1)*cs-1 do
		for j=ky*cs, (ky+1)*cs-1 do
			local q1 = density:getPixel(i-kx*cs+1, j-ky*cs)
            local q2 = density:getPixel(i-kx*cs+1, j-ky*cs+1)
            local q3 = density:getPixel(i-kx*cs, j-ky*cs+1)
            local q4 = density:getPixel(i-kx*cs, j-ky*cs)
			q1, q2, q3, q4 = q1, q2, q3, q4
            local qa = (q1+q2+q3+q4)/4
            q1b = q1 > 0.5 and 1 or 0
            q2b = q2 > 0.5 and 1 or 0
            q3b = q3 > 0.5 and 1 or 0
            q4b = q4 > 0.5 and 1 or 0
            local pid = q1b+q2b*2+q3b*4+q4b*8
			if not (pid == 0) then
				local f1 = (0.5-q1)/(q2-q1)
	            local f2 = (0.5-q3)/(q2-q3)
	            local f3 = (0.5-q4)/(q3-q4)
	            local f4 = (0.5-q4)/(q1-q4)
	            --f1, f2, f3, f4 = 0.5, 0.5, 0.5, 0.5
	            if f1 > 0.9 then f1 = 0.9 end
	            if f1 < 0.1 then f1 = 0.1 end
	            if f2 > 0.9 then f2 = 0.9 end
	            if f2 < 0.1 then f2 = 0.1 end
	            if f3 > 0.9 then f3 = 0.9 end
	            if f3 < 0.1 then f3 = 0.1 end
	            if f4 > 0.9 then f4 = 0.9 end
	            if f4 < 0.1 then f4 = 0.1 end
	            local pts
	            -- should be counter-clockwise (fixes automatically?)
	            if pid == 1 then
	                pts = {i+1, j, i+1, j+f1, i+f4, j}
	            elseif pid == 2 then
	                pts = {i+1, j+1, i+f2, j+1, i+1, j+f1}
	            elseif pid == 3 then
	                pts = {i+1, j, i+1, j+1, i+f2, j+1, i+f4, j}
	            elseif pid == 4 then
	                pts = {i, j+1, i, j+f3, i+f2, j+1}
	            elseif pid == 5 then
	                if qa < 0.5 then
	                    pts = {i+1, j, i+1, j+f1, i+f2, j+1, i, j+1, i, j+f3, i+f4, j}
	                else
	                    local spts = {(i+1)*ts, j*ts, (i+1)*ts, j*ts+f1*ts, i*ts+f4*ts, j*ts}
	                    table.insert(pck.polys, {id=pid, i=i, j=j, pts=spts})
	                    spts = {i*ts, (j+1)*ts, i*ts, j*ts+f3*ts, i*ts+f2*ts, (j+1)*ts}
	                    table.insert(pck.polys, {id=pid, i=i, j=j, pts=spts})
	                end
	            elseif pid == 6 then
	                pts = {i+1, j+1, i, j+1, i, j+f3, i+1, j+f1}
	            elseif pid == 7 then
	                pts = {i+1, j, i+1, j+1, i, j+1, i, j+f3, i+f4, j}
	            elseif pid == 8 then
	                pts = {i, j, i+f4, j, i, j+f3}
	            elseif pid == 9 then
	                pts = {i+1, j, i+1, j+f1, i, j+f3, i, j}
	            elseif pid == 10 then
	                if qa < 0.5 then
	                    pts = {i+1, j+1, i+f2, j+1, i, j+f3, i, j, i+f4, j, i+1, j+f1}
	                else
	                    local spts = {(i+1)*ts, (j+1)*ts, i*ts+f2*ts, (j+1)*ts, (i+1)*ts, j*ts+f1*ts}
	                    table.insert(pck.polys, {id=pid, i=i, j=j, pts=spts})
	                    spts = {i*ts, j*ts, i*ts+f4*ts, j*ts, i*ts, j*ts+f3*ts}
	                    table.insert(pck.polys, {id=pid, i=i, j=j, pts=spts})
	                end
	            elseif pid == 11 then
	                pts = {i+1, j, i+1, j+1, i+f2, j+1, i, j+f3, i, j}
	            elseif pid == 12 then
	                pts = {i, j, i+f4, j, i+f2, j+1, i, j+1}
	            elseif pid == 13 then
	                pts = {i+1, j, i+1, j+f1, i+f2, j+1, i, j+1, i, j}
	            elseif pid == 14 then
	                pts = {i+1, j+1, i, j+1, i, j, i+f4, j, i+1, j+f1}
	            elseif pid == 15 then
	                pts = {i+1, j, i+1, j+1, i, j+1, i, j}
	            end
	            if pts then
	                for i, v in pairs(pts) do
	                    pts[i] = v*ts
	                end
					table.insert(pck.polys, {id=pid, i=i, j=j, pts=pts})
	            end
			end
		end
	end
	for _, v in pairs(pck.polys) do
		if not (v.id == 15) then
            -- todo: localize shape (may be physics glitches with large distances)
            local obj = {
                shape = love.physics.newPolygonShape(v.pts),
                body = love.physics.newBody(world, 0, 0)
            }
            obj.fixture = love.physics.newFixture(obj.body, obj.shape)
			obj.fixture:setUserData{type='terrain'}
            table.insert(pck.colliders, obj)

            -- tris error when f ~ 0 or 1, first error lags 5s
			-- fixed(?) by clamping to [0.1, 0.9]
            --[[
            local function pc()
                obj.shape = love.physics.newPolygonShape(v.pts)
            end
            if pcall(pc) then
                obj.body = love.physics.newBody(world, 0, 0)
                obj.fixture = love.physics.newFixture(obj.body, obj.shape)
                table.insert(colliderChunks[k], obj)
            end
            ]]
        end
	end
end
