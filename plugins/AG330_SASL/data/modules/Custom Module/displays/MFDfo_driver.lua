-- AeroGenesis A330-300
-- MFDfo_driver.lua
-- by @quackderbruchpilot_ (Discord)

-----------------------------------------------------------------------------------------------------
-- SELF TEST logic 40secs after turning on GPU/APU PWR
--

-- declaring variables
size = {MFDfo_width, MFDfo_height}                          -- define component size
-----------------------------------------------------------------------------------------------------------------
-- draw
--

function draw()
    sasl.gl.drawRectangle(0, 0, MFDfo_width, MFDfo_height, {0, 0, 0, 0})
    getTargetTextureData(texture_MFDfo, MFDfo_x, MFDfo_y, MFDfo_width, MFDfo_height)
end
-----------------------