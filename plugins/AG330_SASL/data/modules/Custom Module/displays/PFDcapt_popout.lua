-- AeroGenesis A330-300
-- PFDcapt_popout.lua
-- by @quackderbruchpilot_ (Discord)

function draw()
	drawRectangle(0, 0, (PFDcapt_width + 3), (PFDcapt_height + 3), {0, 0, 0})
	drawTexture(texture_PFDcapt, 0, 0, PFDcapt_width, PFDcapt_height, {1, 1, 1})
end