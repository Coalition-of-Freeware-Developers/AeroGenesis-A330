-- AeroGenesis A330-300
-- MFDcapt_driver.lua
-- by @quackderbruchpilot_ (Discord)

-----------------------------------------------------------------------------------------------------
-- SELF TEST logic 40secs after turning on GPU/APU PWR
--

-- declaring variables
size = {MFDcapt_width, MFDcapt_height}                          -- define component size
-----------------------------------------------------------------------------------------------------------------
-- draw
--

function draw()
    sasl.gl.drawRectangle(0, 0, MFDcapt_width, MFDcapt_height, {0, 0, 0, 0})
    getTargetTextureData(texture_MFDcapt, MFDcapt_x, MFDcapt_y, MFDcapt_width, MFDcapt_height)
end
-----------------------------------------------------------------------------------------------------
