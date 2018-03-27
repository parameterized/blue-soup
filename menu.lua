
menu = {}

menu.buttons = {}
local function addButton(t)
	t.text = t.text or 'Button'
	t.font = t.font or fonts.f24
	t.x = t.x and t.x - t.font:getWidth(t.text)/2 or ssx/2 - t.font:getWidth(t.text)/2
	t.y = t.y and t.y - t.font:getHeight(t.text)/2 or ssy/2 - t.font:getHeight(t.text)/2
	t.box = {
		x = t.x - 12,
		y = t.y - 6,
		w = t.font:getWidth(t.text) + 24,
		h = t.font:getHeight(t.text) + 12
	}
	table.insert(menu.buttons, t)
end
addButton{id='play', text='Play', y=ssy/3, font=fonts.f32}
addButton{id='exit', text='Exit', y=2*ssy/3, font=fonts.f32}

function menu.update(dt)
	
end

function menu.mousepressed(x, y, btn, isTouch)
	for _, v in pairs(menu.buttons) do
		if x > v.box.x and x < v.box.x + v.box.w
		and y > v.box.y and y < v.box.y + v.box.h then
			if v.id == 'play' then
				gamestate = 'playing'
			elseif v.id == 'exit' then
				love.event.quit()
			end
		end
	end
end

function menu.keypressed(k, scancode, isrepeat)
	
end

function menu.draw()
	love.graphics.setBackgroundColor(20, 22, 26)
	local mx, my = love.mouse.getPosition()
	for _, v in pairs(menu.buttons) do
		if mx > v.box.x and mx < v.box.x + v.box.w
		and my > v.box.y and my < v.box.y + v.box.h then
			love.graphics.setColor(40, 44, 52)
		else
			love.graphics.setColor(60, 66, 78)
		end
		love.graphics.rectangle('fill', v.box.x, v.box.y, v.box.w, v.box.h)
		love.graphics.setColor(224, 224, 224)
		love.graphics.setFont(v.font)
		love.graphics.print(v.text, v.x, v.y)
	end
end