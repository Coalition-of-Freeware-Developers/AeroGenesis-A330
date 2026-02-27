-- AeroGenesis A330-300
-- MFDfo_popout.lua
-- by @quackderbruchpilot_ (Discord)

function draw()
	drawRectangle(0, 0, (MFDfo_width + 3), (MFDfo_height + 3), {0, 0, 0})
	drawTexture(texture_MFDfo, 0, 0, MFDfo_width, MFDfo_height, {1, 1, 1})
end