-- AeroGenesis A330-300
-- ECAMlwr_driver.lua
-- by @quackderbruchpilot_ (Discord)

-----------------------------------------------------------------------------------------------------
-- SELF TEST logic 40secs after turning on GPU/APU PWR
--

-- declaring variables
size = {ECAMlwr_width, ECAMlwr_height}                          -- define component size
-----------------------------------------------------------------------------------------------------------------
-- draw
--

function draw()
    sasl.gl.drawRectangle(0, 0, ECAMlwr_width, ECAMlwr_height, {0, 0, 0, 0})
    getTargetTextureData(texture_ECAMlwr, ECAMlwr_x, ECAMlwr_y, ECAMlwr_width, ECAMlwr_height)
end
-----------------------