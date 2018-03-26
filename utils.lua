
function lerp(a, b, t)
    return (1-t)*a + t*b
end

function hash(x, y)
	local v = math.sin(x*12.9898 + y*78.233)*33758.5453
	return v - math.floor(v)
end