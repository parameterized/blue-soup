
procgen = {}

function procgen.load()
	local pg = love.filesystem.read('shaders/procgen.h')
	local common = [[
	float dist = distance(uv, vec2(0.0));
	float c1 = cnoise(uv/400.0);
	float c2 = cnoise((uv + vec2(10000))/50.0);
	float dist2 = dist + c1*60 + c2*c1*c1*20;
	float moonRadius = 5000.0;
	float d = (moonRadius - dist2)/100.0 + 0.5;
	float c3 = cnoise((uv - vec2(10000))/600.0);
	float d2 = sin(dist/100.0 + 65.0) + c3;
	d = min(d, d2);
	vec4 v1 = voronoi(uv/500.0);
]]
	
	
	local s = [[
	uniform vec2 camPos;
	uniform float camScale;
	uniform float camRot;
]]
	.. pg
	.. [[
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec2 uv = screen_coords;
	uv -= love_ScreenSize.xy*0.5;
	uv /= camScale;
	uv = rotate(uv, camRot);
	uv += camPos;
]]
	.. common
	.. [[
	float a = d > 0.5 ? 1.0 : 0.0;
	float g;
	float c4 = cnoise((uv + vec2(20000.0))/200.0);
	float c5 = cnoise((uv + vec2(30000.0))/20.0);
	if (dist2 < moonRadius) {
		a = 1.0;
		if ((c4 + c5*3.0)/4.0 > 0.3) {
			g = 0.15;
		} else {
			g = 0.2;
		}
	}
	if (d > 0.5) {
		if (dist2 < moonRadius && (c1*2.0 + c2)/3.0 > 0.3) {
			g = 0.7;
		} else {
			g = 0.9;
		}
	} else {
		vec2 uvv1 = uv/500.0;
		float v1d1 = distance(uvv1, v1.xy);
		float v1d2 = distance(uvv1, v1.zw);
		if ((v1d2 - v1d1)/v1d2 > 0.7 + (moonRadius - dist)/5000.0) {
			a = 0.0;
		}
	}
	return vec4(vec3(g), a);
}
]]
	shaders.moon = love.graphics.newShader(s)
	
	
	s = [[
	uniform vec2 chunkPos;
	uniform float tileSize;
]]
	.. pg
	.. [[
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = chunkPos + screen_coords*tileSize - tileSize*0.5;
]]
	.. common
	.. [[
    return vec4(vec3(d), 1.0);
}
]]
	shaders.moonDensity = love.graphics.newShader(s)
	
	
	local s = [[
	uniform vec2 chunkPos;
	uniform float stepSize = 1.0;
]]
	.. pg
	.. [[
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec2 uv = chunkPos + screen_coords*stepSize;
]]
	.. common
	.. [[
	float g = 1.0;
	if (dist2 < moonRadius) {
		g = 0.0;
	}
	
	if (d < 0.5) {
		vec2 uvv1 = uv/500.0;
		float v1d1 = distance(uvv1, v1.xy);
		float v1d2 = distance(uvv1, v1.zw);
		if ((v1d2 - v1d1)/v1d2 > 0.7 + (moonRadius - dist)/5000.0) {
			g = 1.0;
		}
	}
	
	return vec4(vec3(g), 1.0);
}
]]
	shaders.moonLightMask = love.graphics.newShader(s)
end