-- AeroGenesis A330-300
-- ECAMlwr_popout.lua
-- by @quackderbruchpilot_ (Discord)

function draw()
	drawRectangle(0, 0, (ECAMlwr_width + 3), (ECAMlwr_height + 3), {0, 0, 0})
	drawTexture(texture_ECAMlwr, 0, 0, ECAMlwr_width, ECAMlwr_height, {1, 1, 1})
end