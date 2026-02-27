-- AeroGenesis A330-300
-- MFDcapt_popout.lua
-- by @quackderbruchpilot_ (Discord)

function draw()
	drawRectangle(0, 0, (MFDcapt_width + 3), (MFDcapt_height + 3), {0, 0, 0})
	drawTexture(texture_MFDcapt, 0, 0, MFDcapt_width, MFDcapt_height, {1, 1, 1})
end