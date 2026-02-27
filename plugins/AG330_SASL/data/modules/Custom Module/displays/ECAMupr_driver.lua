-- AeroGenesis A330-300
-- ECAMupr_driver.lua
-- by @quackderbruchpilot_ (Discord)

-----------------------------------------------------------------------------------------------------
-- SELF TEST logic 40secs after turning on GPU/APU PWR
--

-- declaring variables
size = {ECAMupr_width, ECAMupr_height}                          -- define component size
-----------------------------------------------------------------------------------------------------------------
-- draw
--

function draw()
    sasl.gl.drawRectangle(0, 0, ECAMupr_width, ECAMupr_height, {0, 0, 0, 0})
    getTargetTextureData(texture_ECAMupr, ECAMupr_x, ECAMupr_y, ECAMupr_width, ECAMupr_height)
end
-----------------------------------------------------------------------------------------------------
