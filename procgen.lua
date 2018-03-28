
procgen = {}

function procgen.load()
	local density = 
[[
	float dist = distance(uv, vec2(0.0));
	float c1 = cnoise(uv/400.0);
	float c2 = cnoise((uv + vec2(10000))/50.0);
	float dist2 = dist + c1*60 + c2*c1*c1*20;
	float moonRadius = 5000.0;
	float d = (moonRadius - dist2)/100.0 + 0.5;
	float c3 = cnoise((uv - vec2(10000))/600.0);
	float d2 = sin(dist/200.0 + 400.0) + c3;
	d = min(d, d2);
]]
	
	local s = '\n'
	.. 'extern vec2 camPos;\n'
	.. 'extern float camScale;\n'
	.. 'extern float camRot;\n'
	.. love.filesystem.read('shaders/procgen.h')
	.. [[
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec2 uv = screen_coords;
	uv -= love_ScreenSize.xy*0.5;
	uv /= camScale;
	uv = rotate(uv, camRot);
	uv += camPos;
]]
	.. density
	.. [[
	float a = d > 0.5 ? 1.0 : 0.0;
	float g = 0.9;
	//float c4 = cnoise((uv + vec2(20000.0))/200.0);
	//float c5 = cnoise((uv + vec2(30000.0))/50.0);
	if (dist2 < moonRadius && (c1*2.0 + c2)/3.0 > 0.3) {
		g = 0.7;
	}
	return vec4(vec3(g), a);
}
]]
	shaders.moon = love.graphics.newShader(s)
	
	s = '\n'
	.. 'extern vec2 chunkPos;\n'
	.. 'extern float tileSize;\n'
	.. love.filesystem.read('shaders/procgen.h')
	.. [[
vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = chunkPos + screen_coords*tileSize - tileSize*0.5;
]]
	.. density
	.. [[
    return vec4(vec3(d), 1.0);
}
]]
	shaders.moonDensity = love.graphics.newShader(s)
end