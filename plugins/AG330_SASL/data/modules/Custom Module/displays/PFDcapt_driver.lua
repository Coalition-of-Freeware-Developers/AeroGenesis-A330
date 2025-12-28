-- AeroGenesis A330-300
-- PFDcapt_driver.lua
-- by @quackderbruchpilot_ (Discord)

-----------------------------------------------------------------------------------------------------
-- SELF TEST logic 40secs after turning on GPU/APU PWR
--

-- declaring variables
size = {PFDcapt_width, PFDcapt_height}                          -- define component size
-----------------------------------------------------------------------------------------------------------------
-- draw
--

function draw()
    sasl.gl.drawRectangle(0, 0, PFDcapt_width, PFDcapt_height, {0, 0, 0, 0})
    getTargetTextureData(texture_PFDcapt, PFDcapt_x, PFDcapt_y, PFDcapt_width, PFDcapt_height)
end
-----------------------------------------------------------------------------------------------------
