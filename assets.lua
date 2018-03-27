
ssx = love.graphics.getWidth()
ssy = love.graphics.getHeight()

love.filesystem.setIdentity(love.window.getTitle())
math.randomseed(love.timer.getTime())

fonts = {
	f12 = love.graphics.newFont(12),
	f24 = love.graphics.newFont(24),
	f32 = love.graphics.newFont(32)
}

-- density is chunkSize+1 x chunkSize+1
canvases = {
	density = love.graphics.newCanvas(17, 17)
}

shaders = {
	moon = love.graphics.newShader('shaders/moon.glsl'),
	moonDensity = love.graphics.newShader('shaders/moonDensity.glsl')
}