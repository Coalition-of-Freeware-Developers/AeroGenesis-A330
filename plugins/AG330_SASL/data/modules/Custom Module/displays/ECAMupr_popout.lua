-- AeroGenesis A330-300
-- ECAMupr_popout.lua
-- by @quackderbruchpilot_ (Discord)

function draw()
	drawRectangle(0, 0, (ECAMupr_width + 3), (ECAMupr_height + 3), {0, 0, 0})
	drawTexture(texture_ECAMupr, 0, 0, ECAMupr_width, ECAMupr_height, {1, 1, 1})
end