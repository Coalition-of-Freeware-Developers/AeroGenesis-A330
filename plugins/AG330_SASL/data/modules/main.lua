-- AeroGenesis A330-300
-- main.lua
-- by @quackderbruchpilot_ (Discord)

-----------------------------------------------------------------------------------------------------
-- General settings
--

size = {2048, 1024}                 -- size of panel.png
panel2d = false                     -- don't draw on 2d panel
panelWidth3d = 2048                 -- width/height of panel.png
panelHeight3d = 1024                --

sasl.options.setAircraftPanelRendering(true)            -- enable panel rendering
sasl.options.set3DRendering(false)                      -- disable 3D rendering
sasl.options.setRenderingMode2D(SASL_RENDER_2D_DEFAULT) -- enable 2D rendering (contextWindows)
sasl.options.setInteractivity(true)                     -- enable click sensitivity (maybe needed later)

addSearchPath(moduleDirectory.."/Custom Module/displays/")
font_ECAM = loadFont("fonts/ECAMFontRegular.ttf")       -- load ECAM font

--[[Display coordinates on 2d Panel:
    (left corner x, y, width, heigth)
    CAPT PFD:   5, 517, 502, 502
    CAPT MFD:   517, 517, 502, 502
    ECAM:       1030, 517, 502, 502
    LWR ECAM:   1541, 518, 502, 502
    F/O PFD:    5, 5, 502, 502
    F/O MFD:    517, 5, 502, 502
    ACARS L:    1413, 315, 259, 195
    ACARS R:    1679, 315, 259, 195
]]
-----------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------
-- PFDcapt resources
--

PFDcapt_x = 5
PFDcapt_y = 517
PFDcapt_width = 502
PFDcapt_height = 502

texture_PFDcapt = createTexture(502, 502)
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- MFDcapt resources
--

MFDcapt_x = 517
MFDcapt_y = 517
MFDcapt_width = 502
MFDcapt_height = 502

texture_MFDcapt = createTexture(502, 502)
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- PFDfo resources
--

PFDfo_x = 5
PFDfo_y = 5
PFDfo_width = 502
PFDfo_height = 502

texture_PFDfo = createTexture(502, 502)
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- MFDfo resources
--

MFDfo_x = 517
MFDfo_y = 5
MFDfo_width = 502
MFDfo_height = 502

texture_MFDfo = createTexture(502, 502)
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- ECAMupr resources
--

ECAMupr_x = 1030
ECAMupr_y = 517
ECAMupr_width = 502
ECAMupr_height = 502

texture_ECAMupr = createTexture(502, 502)
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- ECAMlwr resources
--

ECAMlwr_x = 1541
ECAMlwr_y = 518
ECAMlwr_width = 502
ECAMlwr_height = 502

texture_ECAMlwr = createTexture(502, 502)
-----------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------
-- components
--

components = {
    PFDcapt_driver {
        position = {PFDcapt_x, PFDcapt_y, PFDcapt_width, PFDcapt_height},   -- postition/size on panel.png of component 
        visible = true,
    },

    MFDcapt_driver {
        position = {MFDcapt_x, MFDcapt_y, MFDcapt_width, MFDcapt_height},   -- postition/size on panel.png of component 
        visible = true,
    },

    PFDfo_driver {
        position = {PFDfo_x, PFDfo_y, PFDfo_width, PFDfo_height},           -- postition/size on panel.png of component 
        visible = true,
    },

    MFDfo_driver {
        position = {MFDfo_x, MFDfo_y, MFDfo_width, MFDfo_height},           -- postition/size on panel.png of component 
        visible = true,
    },

    ECAMupr_driver {
        position = {ECAMupr_x, ECAMupr_y, ECAMupr_width, ECAMupr_height},           -- postition/size on panel.png of component 
        visible = true,
    },

    ECAMlwr_driver {
        position = {ECAMlwr_x, ECAMlwr_y, ECAMlwr_width, ECAMlwr_height},           -- postition/size on panel.png of component 
        visible = true,
    },
}
-----------------------------------------------------------------------------------------------------





-----------------------------------------------------------------------------------------------------
-- PFDcapt_popout
--

PFDcapt_popout = contextWindow {
    name = "PFD CAPT";
    position = {15, 50, 505, 505};
    noFocus = true;
    command = "AG330/screens/PFDcapt/popout";
    description = "PFD Captain Popout";
    layer = SASL_CW_LAYER_FLIGHT_OVERLAY;
    components = {
        PFDcapt_popout {}
    };
}

-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- MFDcapt_popout
--

MFDcapt_popout = contextWindow {
    name = "MFD CAPT";
    position = {535, 50, 505, 505};
    noFocus = true;
    command = "AG330/screens/MFDcapt/popout";
    description = "MFD Captain Popout";
    layer = SASL_CW_LAYER_FLIGHT_OVERLAY;
    components = {
        MFDcapt_popout {}
    };
}
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- PFDfo_popout
--

PFDfo_popout = contextWindow {
    name = "PDF F/O";
    position = {535, 560, 505, 505};
    noFocus = true;
    command = "AG330/screens/PFDfo/popout";
    description = "PFD FO Popout";
    layer = SASL_CW_LAYER_FLIGHT_OVERLAY;
    components = {
        PFDfo_popout {}
    };
}
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- MFDfo_popout
--

MFDfo_popout = contextWindow {
    name = "MFD F/O";
    position = {15, 560, 505, 505};
    noFocus = true;
    command = "AG330/screens/MFDfo/popout";
    description = "MFD FO Popout";
    layer = SASL_CW_LAYER_FLIGHT_OVERLAY;
    components = {
        MFDfo_popout {}
    };
}
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- ECAMupr_popout
--

ECAMupr_popout = contextWindow {
    name = "UPR ECAM";
    position = {1070, 560, 505, 505};
    noFocus = true;
    command = "AG330/screens/ECAMupr/popout";
    description = "Upper ECAM Popout";
    layer = SASL_CW_LAYER_FLIGHT_OVERLAY;
    components = {
        ECAMupr_popout {}
    };
}
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- ECAMlwr_popout
--

ECAMlwr_popout = contextWindow {
    name = "LWR ECAM";
    position = {1070, 50, 505, 505};
    noFocus = true;
    command = "AG330/screens/ECAMlwr/popout";
    description = "Lower ECAM Popout";
    layer = SASL_CW_LAYER_FLIGHT_OVERLAY;
    components = {
        ECAMlwr_popout {}
    };
}
-----------------------------------------------------------------------------------------------------