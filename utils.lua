
function lerp(a, b, t)
    return (1-t)*a + t*b
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

function sendCamera(shader)
	shader:send('camPos', {camera.x, camera.y})
	shader:send('camScale', camera.scale)
	shader:send('camRot', camera.rotation)
end