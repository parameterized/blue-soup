
ssx = love.graphics.getWidth()
ssy = love.graphics.getHeight()

love.filesystem.setIdentity(love.window.getTitle())
math.randomseed(love.timer.getTime())

gfx = {
	brush = love.graphics.newImage('gfx/brush.png')
}

fonts = {
	f12 = love.graphics.newFont(12),
	f24 = love.graphics.newFont(24),
	f32 = love.graphics.newFont(32)
}

canvases = {
	
}

shaders = {
	blur = love.graphics.newShader('shaders/blur.glsl')
}