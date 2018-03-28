
function clamp(x, a, b)
	if a < b then
		return math.min(math.max(x, a), b)
	else
		return math.min(math.max(x, b), a)
	end
end

function lerp(a, b, t)
	if math.abs(b-a) < 1e-9 then return b end
    return clamp((1-t)*a + t*b, a, b)
end

function lerpAngle(a, b, t)
	local theta = b - a
	if theta > math.pi then
		a = a + 2*math.pi
	elseif theta < -math.pi then
		a = a - 2*math.pi
	end
	return lerp(a, b, t)
end

function hash(x, y)
	local v = math.sin(x*12.9898 + y*78.233)*33758.5453
	return v - math.floor(v)
end

function rotate(x, y, a)
	local s = math.sin(a);
	local c = math.cos(a);
	local x2 = x*c + y*s
	local y2 = y*c - x*s
	return x2, y2
end

function setGameState(state)
	lastGameState = gameState
	gameState = state
end

function sendCamera(shader)
	shader:send('camPos', {camera.x, camera.y})
	shader:send('camScale', camera.scale)
	shader:send('camRot', camera.rotation)
end
