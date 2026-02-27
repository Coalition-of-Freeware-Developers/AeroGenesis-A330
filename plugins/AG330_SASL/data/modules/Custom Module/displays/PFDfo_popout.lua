-- AeroGenesis A330-300
-- PFDfo_popout.lua
-- by @quackderbruchpilot_ (Discord)

function draw()
	drawRectangle(0, 0, (PFDfo_width + 3), (PFDfo_height + 3), {0, 0, 0})
	drawTexture(texture_PFDfo, 0, 0, PFDfo_width, PFDfo_height, {1, 1, 1})
end