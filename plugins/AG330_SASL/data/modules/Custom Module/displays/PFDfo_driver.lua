-- AeroGenesis A330-300
-- PFDfo_driver.lua
-- by @quackderbruchpilot_ (Discord)

-----------------------------------------------------------------------------------------------------
-- SELF TEST logic 40secs after turning on GPU/APU PWR
--

-- declaring variables
size = {PFDfo_width, PFDfo_height}                          -- define component size
-----------------------------------------------------------------------------------------------------------------
-- draw
--

function draw()
    sasl.gl.drawRectangle(0, 0, PFDfo_width, PFDfo_height, {0, 0, 0, 0})
    getTargetTextureData(texture_PFDfo, PFDfo_x, PFDfo_y, PFDfo_width, PFDfo_height)
end
-----------------------