uniform Image lightMap;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords)
{
	vec4 col = Texel(texture, texture_coords)*color;
	col.rgb *= min(Texel(lightMap, texture_coords).rgb*2.0, 1.0);
	return col;
}
