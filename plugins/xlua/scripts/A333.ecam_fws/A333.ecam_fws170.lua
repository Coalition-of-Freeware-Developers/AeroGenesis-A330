jit.off()
--[[
*****************************************************************************************
* Script Name : A333.ecam_fws170.lua
* Process: FWS Global Status Message Table
*
* Author Name :	Jim Gregory
*
* Revisions:
* -- DATE --  --- REV NO ---  --- DESCRIPTION -------------------------------------------
*
*
*
*
*
*****************************************************************************************
*       					     COPYRIGHT © 2021, 2022
*					 	   L A M I N A R   R E S E A R C H
*								  ALL RIGHTS RESERVED
*****************************************************************************************
--]]


--print("LOAD: A333.ecam_fws170.lua")

--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--[[

SIM_PERIOD: this contains the duration of the current frame in seconds (so it is always a
fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you’d do fuel = fuel + 3 * SIM_PERIOD.


IN_REPLAY: evaluates to 0 if replay is off, 1 if replay mode is on

--]]


--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--


-----------------------------------    Z O N E  0    ------------------------------------


-- name, zone, type, sequence

-----| ZONE 0 (LEFT) LIMITATIONS

A333_sts_msg.MIN_RAT_SPEED = newSTSMessage('MIN_RAT_SPEED', 0, 0, 1010)
A333_sts_msg.MIN_RAT_SPEED.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.MIN_RAT_SPEED.CmdInputs = ':CLR:STS:'
A333_sts_msg.MIN_RAT_SPEED.Msg = {
	{Line = 1, Color = 4, Gfx = 0, Text = 'MIN RAT SPEED.....140 KT', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.MAX_SPEED_280 = newSTSMessage('MAX_SPEED_280', 0, 0, 1012)
A333_sts_msg.MAX_SPEED_280.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.MAX_SPEED_280.CmdInputs = ':CLR:STS:'
A333_sts_msg.MAX_SPEED_280.Msg = {
	{Line = 1, Color = 4, Gfx = 0, Text = 'MAX SPEED........280/.67', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.MAX_SPEED_300 = newSTSMessage('MAX_SPEED_300', 0, 0, 1014)
A333_sts_msg.MAX_SPEED_300.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.MAX_SPEED_300.CmdInputs = ':CLR:STS:'
A333_sts_msg.MAX_SPEED_300.Msg = {
	{Line = 1, Color = 4, Gfx = 0, Text = 'MAX SPEED........300/.78', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.IF_BUFFET = newSTSMessage('IF_BUFFET', 0, 0, 1016)
A333_sts_msg.IF_BUFFET.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.IF_BUFFET.CmdInputs = ':CLR:STS:'
A333_sts_msg.IF_BUFFET.Msg = {
	{Line = 1, Color = 3, Gfx = 0, Text = '      .IF BUFFET :      ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.MAX_SPEED_240 = newSTSMessage('MAX_SPEED_240', 0, 0, 1018)
A333_sts_msg.MAX_SPEED_240.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.MAX_SPEED_240.CmdInputs = ':CLR:STS:'
A333_sts_msg.MAX_SPEED_240.Msg = {
	{Line = 1, Color = 4, Gfx = 0, Text = 'MAX SPEED............240', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.MAX_SPEED_320_77 = newSTSMessage('MAX_SPEED_320_77', 0, 0, 1020)
A333_sts_msg.MAX_SPEED_320_77.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.MAX_SPEED_320_77.CmdInputs = ':CLR:STS:'
A333_sts_msg.MAX_SPEED_320_77.Msg = {
	{Line = 1, Color = 4, Gfx = 0, Text = 'MAX SPEED........320/.77', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.DOORS_NOT_CLOSED = newSTSMessage('DOORS_NOT_CLOSED', 0, 0, 1024)
A333_sts_msg.DOORS_NOT_CLOSED.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.DOORS_NOT_CLOSED.CmdInputs = ':CLR:STS:'
A333_sts_msg.DOORS_NOT_CLOSED.Msg = {
	{Line = 1, Color = 4, Gfx = 0, Text = 'MAX SPEED........250/.60', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.LG_KEEP_DOWN = newSTSMessage('LG_KEEP_DOWN', 0, 0, 1100)
A333_sts_msg.LG_KEEP_DOWN.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.LG_KEEP_DOWN.CmdInputs = ':CLR:STS:'
A333_sts_msg.LG_KEEP_DOWN.Msg = {
	{Line = 1, Color = 4, Gfx = 0, Text = 'L/G............KEEP DOWN', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.MAX_BRK_PR = newSTSMessage('MAX_BRK_PR', 0, 0, 1110)
A333_sts_msg.MAX_BRK_PR.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.MAX_BRK_PR.CmdInputs = ':CLR:STS:'
A333_sts_msg.MAX_BRK_PR.Msg = {
	{Line = 1, Color = 4, Gfx = 0, Text = 'MAX BRK PR.......1000PSI', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.L_R_FUEL_GRVTY_FEED = newSTSMessage('L_R_FUEL_GRVTY_FEED', 0, 0, 1120)
A333_sts_msg.L_R_FUEL_GRVTY_FEED.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.L_R_FUEL_GRVTY_FEED.CmdInputs = ':CLR:STS:'
A333_sts_msg.L_R_FUEL_GRVTY_FEED.Msg = {
	{Line = 1, Color = 4, Gfx = 0, Text = 'FUEL GRVTY FEED         ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.AVOID_ICING_CONDITIONS = newSTSMessage('AVOID_ICING_CONDITIONS', 0, 0, 1200)
A333_sts_msg.AVOID_ICING_CONDITIONS.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.AVOID_ICING_CONDITIONS.CmdInputs = ':CLR:STS:'
A333_sts_msg.AVOID_ICING_CONDITIONS.Msg = {
	{Line = 1, Color = 4, Gfx = 0, Text = 'AVOID ICING CONDITIONS  ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.AVOID_ADVERSE_CONDITIONS = newSTSMessage('AVOID_ADVERSE_CONDITIONS', 0, 0, 1300)
A333_sts_msg.AVOID_ADVERSE_CONDITIONS.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.AVOID_ADVERSE_CONDITIONS.CmdInputs = ':CLR:STS:'
A333_sts_msg.AVOID_ADVERSE_CONDITIONS.Msg = {
	{Line = 1, Color = 4, Gfx = 0, Text = 'AVOID ADVERSE CONDITIONS', Status = 0, Cleared = 0, Visible = 0}
}







-----| ZONE 0 (LEFT) APPROACH PROCEDURES

A333_sts_msg.AP_DUAL_HYD_LO_GB = newSTSMessage('AP_DUAL_HYD_LO_GB', 0, 1, 2010)
A333_sts_msg.AP_DUAL_HYD_LO_GB.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.AP_DUAL_HYD_LO_GB.CmdInputs = ':CLR:STS:'
A333_sts_msg.AP_DUAL_HYD_LO_GB.Msg = {
	{Line = 1, Color = 3, Gfx = 1, Text = 'APPR PROC               ', Status = 0, Cleared = 0, Visible = 0},
	{Line = 1, Color = 0, Gfx = 0, Text = '          DUAL HYD LO PR', Status = 0, Cleared = 0, Visible = 0},
	{Line = 2, Color = 3, Gfx = 0, Text = '   .IF BLUE OVHT OUT:   ', Status = 0, Cleared = 0, Visible = 0},
	{Line = 3, Color = 4, Gfx = 0, Text = '-BLUE ELEC PUMP.....AUTO', Status = 0, Cleared = 0, Visible = 0},
	{Line = 4, Color = 3, Gfx = 0, Text = '   .IF GREEN OVHT OUT:  ', Status = 0, Cleared = 0, Visible = 0},
	{Line = 5, Color = 4, Gfx = 0, Text = '-GREEN ENG 1 PUMP.....ON', Status = 0, Cleared = 0, Visible = 0},
	{Line = 6, Color = 4, Gfx = 0, Text = '-PTU................AUTO', Status = 0, Cleared = 0, Visible = 0}
}


A333_sts_msg.AP_DUAL_HYD_LO_BY = newSTSMessage('AP_DUAL_HYD_LO_BY', 0, 1, 2020)
A333_sts_msg.AP_DUAL_HYD_LO_BY.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.AP_DUAL_HYD_LO_BY.CmdInputs = ':CLR:STS:'
A333_sts_msg.AP_DUAL_HYD_LO_BY.Msg = {
	{Line = 1, Color = 3, Gfx = 1, Text = 'APPR PROC               ', Status = 0, Cleared = 0, Visible = 0},
	{Line = 1, Color = 0, Gfx = 0, Text = '          DUAL HYD LO PR', Status = 0, Cleared = 0, Visible = 0},
	{Line = 2, Color = 3, Gfx = 0, Text = '   .IF BLUE OVHT OUT:   ', Status = 0, Cleared = 0, Visible = 0},
	{Line = 3, Color = 4, Gfx = 0, Text = '-BLUE ELEC PUMP.....AUTO', Status = 0, Cleared = 0, Visible = 0},
	{Line = 4, Color = 3, Gfx = 0, Text = '   .IF YELLOW OVHT OUT: ', Status = 0, Cleared = 0, Visible = 0},
	{Line = 5, Color = 4, Gfx = 0, Text = '-YELLOW ENG 2 PUMP....ON', Status = 0, Cleared = 0, Visible = 0},
	{Line = 6, Color = 4, Gfx = 0, Text = '-PTU................AUTO', Status = 0, Cleared = 0, Visible = 0}
}




-----| ZONE 0 (LEFT) PROCEDURES

A333_sts_msg.L_TK_GRVTY_FEED_ONLY = newSTSMessage('L_TK_GRVTY_FEED_ONLY', 0, 2, 3010)
A333_sts_msg.L_TK_GRVTY_FEED_ONLY.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.L_TK_GRVTY_FEED_ONLY.CmdInputs = ':CLR:STS:'
A333_sts_msg.L_TK_GRVTY_FEED_ONLY.Msg = {
	{Line = 1, Color = 4, Gfx = 0, Text = 'L TK GRVTY FEED ONLY    ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.R_TK_GRVTY_FEED_ONLY = newSTSMessage('R_TK_GRVTY_FEED_ONLY', 0, 2, 3020)
A333_sts_msg.R_TK_GRVTY_FEED_ONLY.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.R_TK_GRVTY_FEED_ONLY.CmdInputs = ':CLR:STS:'
A333_sts_msg.R_TK_GRVTY_FEED_ONLY.Msg = {
	{Line = 1, Color = 4, Gfx = 0, Text = 'R TK GRVTY FEED ONLY    ', Status = 0, Cleared = 0, Visible = 0}
}




----- ZONE 0 (LEFT) INFORMATION

A333_sts_msg.PITCH_MECH_BACK_UP = newSTSMessage('PITCH_MECH_BACK_UP', 0, 3, 4500)
A333_sts_msg.PITCH_MECH_BACK_UP.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.PITCH_MECH_BACK_UP.CmdInputs = ':CLR:STS:'
A333_sts_msg.PITCH_MECH_BACK_UP.Msg = {
	{Line = 1, Color = 2, Gfx = 0, Text = 'PITCH MECH BACK UP      ', Status = 0, Cleared = 0, Visible = 0}
}




A333_sts_msg.ROLL_DIRECT_LAW = newSTSMessage('ROLL_DIRECT_LAW', 0, 3, 4502)
A333_sts_msg.ROLL_DIRECT_LAW.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.ROLL_DIRECT_LAW.CmdInputs = ':CLR:STS:'
A333_sts_msg.ROLL_DIRECT_LAW.Msg = {
	{Line = 1, Color = 2, Gfx = 0, Text = 'ROLL DIRECT LAW         ', Status = 0, Cleared = 0, Visible = 0}
}


A333_sts_msg.BAT_ONLY = newSTSMessage('BAT_ONLY', 0, 3, 4600)
A333_sts_msg.BAT_ONLY.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.BAT_ONLY.CmdInputs = ':CLR:STS:'
A333_sts_msg.BAT_ONLY.Msg = {
	{Line = 1, Color = 2, Gfx = 0, Text = '              BAT ONLY  ', Status = 0, Cleared = 0, Visible = 0}
}




A333_sts_msg.ONE_PACK_ONLY_IF_WAI_ON = newSTSMessage('ONE_PACK_ONLY_IF_WAI_ON', 0, 3, 4700)
A333_sts_msg.ONE_PACK_ONLY_IF_WAI_ON.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.ONE_PACK_ONLY_IF_WAI_ON.CmdInputs = ':CLR:STS:'
A333_sts_msg.ONE_PACK_ONLY_IF_WAI_ON.Msg = {
	{Line = 1, Color = 2, Gfx = 0, Text = 'ONE PACK ONLY IF WAI ON ', Status = 0, Cleared = 0, Visible = 0}
}













-----| ZONE 0 (LEFT) CANCELLED CAUTION















-----------------------------------    Z O N E  1    ------------------------------------


-----| ZONE 1 (RIGHT) INOP SYSTEMS

A333_sts_msg.HYD_GY_SYS_INOP = newSTSMessage('HYD_GY_SYS_INOP', 1, 3, 8000)
A333_sts_msg.HYD_GY_SYS_INOP.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.HYD_GY_SYS_INOP.CmdInputs = ':CLR:STS:'
A333_sts_msg.HYD_GY_SYS_INOP.Msg = {
	{Line = 1, Color = 0, Gfx = 0, Text = 'G+Y HYD     ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.HYD_GB_SYS_INOP = newSTSMessage('HYD_GB_SYS_INOP', 1, 3, 8005)
A333_sts_msg.HYD_GB_SYS_INOP.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.HYD_GB_SYS_INOP.CmdInputs = ':CLR:STS:'
A333_sts_msg.HYD_GB_SYS_INOP.Msg = {
	{Line = 1, Color = 0, Gfx = 0, Text = 'G+B HYD     ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.HYD_G_SYS_INOP = newSTSMessage('HYD_G_SYS_INOP', 1, 3, 8010)
A333_sts_msg.HYD_G_SYS_INOP.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.HYD_G_SYS_INOP.CmdInputs = ':CLR:STS:'
A333_sts_msg.HYD_G_SYS_INOP.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'GREEN HYD   ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.HYD_B_SYS_INOP = newSTSMessage('HYD_B_SYS_INOP', 1, 3, 8015)
A333_sts_msg.HYD_B_SYS_INOP.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.HYD_B_SYS_INOP.CmdInputs = ':CLR:STS:'
A333_sts_msg.HYD_B_SYS_INOP.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'BLUE HYD    ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.HYD_Y_SYS_INOP = newSTSMessage('HYD_Y_SYS_INOP', 1, 3, 8020)
A333_sts_msg.HYD_Y_SYS_INOP.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.HYD_Y_SYS_INOP.CmdInputs = ':CLR:STS:'
A333_sts_msg.HYD_Y_SYS_INOP.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'YELLOW HYD  ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.STABILIZER_INOP = newSTSMessage('STABILIZER_INOP', 1, 3, 8030)
A333_sts_msg.STABILIZER_INOP.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.STABILIZER_INOP.CmdInputs = ':CLR:STS:'
A333_sts_msg.STABILIZER_INOP.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'STABILIZER  ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.L_R_ELEV = newSTSMessage('L_R_ELEV', 1, 3, 8040)
A333_sts_msg.L_R_ELEV.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.L_R_ELEV.CmdInputs = ':CLR:STS:'
A333_sts_msg.L_R_ELEV.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'L+R ELEV    ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.L_ELEV = newSTSMessage('L_ELEV', 1, 3, 8050)
A333_sts_msg.L_ELEV.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.L_ELEV.CmdInputs = ':CLR:STS:'
A333_sts_msg.L_ELEV.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'L ELEV      ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.R_ELEV = newSTSMessage('R_ELEV', 1, 3, 8060)
A333_sts_msg.R_ELEV.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.R_ELEV.CmdInputs = ':CLR:STS:'
A333_sts_msg.R_ELEV.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'R ELEV      ', Status = 0, Cleared = 0, Visible = 0}
}







A333_sts_msg.PACK_1_2 = newSTSMessage('PACK_1_2', 1, 3, 8500)
A333_sts_msg.PACK_1_2.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.PACK_1_2.CmdInputs = ':CLR:STS:'
A333_sts_msg.PACK_1_2.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'PACK 1+2    ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.PACK_1 = newSTSMessage('PACK_1', 1, 3, 8505)
A333_sts_msg.PACK_1.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.PACK_1.CmdInputs = ':CLR:STS:'
A333_sts_msg.PACK_1.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'PACK 1      ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.PACK_2 = newSTSMessage('PACK_2', 1, 3, 8510)
A333_sts_msg.PACK_2.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.PACK_2.CmdInputs = ':CLR:STS:'
A333_sts_msg.PACK_2.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'PACK 2      ', Status = 0, Cleared = 0, Visible = 0}
}





A333_sts_msg.BAT_1 = newSTSMessage('BAT_1', 1, 3, 8700)
A333_sts_msg.BAT_1.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.BAT_1.CmdInputs = ':CLR:STS:'
A333_sts_msg.BAT_1.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'BAT 1      ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.BAT_2 = newSTSMessage('BAT_2', 1, 3, 8705)
A333_sts_msg.BAT_2.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.BAT_2.CmdInputs = ':CLR:STS:'
A333_sts_msg.BAT_2.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'BAT 2      ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.GEN_1 = newSTSMessage('GEN_1', 1, 3, 8720)
A333_sts_msg.GEN_1.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.GEN_1.CmdInputs = ':CLR:STS:'
A333_sts_msg.GEN_1.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'GEN 1      ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.GEN_2 = newSTSMessage('GEN_2', 1, 3, 8725)
A333_sts_msg.GEN_2.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.GEN_2.CmdInputs = ':CLR:STS:'
A333_sts_msg.GEN_2.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'GEN 2      ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.APU_GEN = newSTSMessage('APU_GEN', 1, 3, 8730)
A333_sts_msg.APU_GEN.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.APU_GEN.CmdInputs = ':CLR:STS:'
A333_sts_msg.APU_GEN.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'APU GEN      ', Status = 0, Cleared = 0, Visible = 0}
}



A333_sts_msg.B_ELEC_PUMP = newSTSMessage('B_ELEC_PUMP', 1, 3, 8800)
A333_sts_msg.B_ELEC_PUMP.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.B_ELEC_PUMP.CmdInputs = ':CLR:STS:'
A333_sts_msg.B_ELEC_PUMP.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'B ELEC PUMP  ', Status = 0, Cleared = 0, Visible = 0}
}

A333_sts_msg.Y_ELEC_PUMP = newSTSMessage('Y_ELEC_PUMP', 1, 3, 8805)
A333_sts_msg.Y_ELEC_PUMP.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_sts_msg.Y_ELEC_PUMP.CmdInputs = ':CLR:STS:'
A333_sts_msg.Y_ELEC_PUMP.Msg = {
	{Line = 1, Color = 1, Gfx = 0, Text = 'Y ELEC PUMP  ', Status = 0, Cleared = 0, Visible = 0}
}








--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND CUSTOM COMMANDS								**--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				            CUSTOM COMMAND HANDLERS            				     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				          X-PLANE WRAP COMMAND HANDLERS              	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              WRAP X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				         X-PLANE REPLACE COMMAND HANDLERS              	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				            REPLACE X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					          OBJECT CONSTRUCTORS         		        		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 CREATE OBJECTS              	     			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              FUNCTION DEFINITIONS         	    				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







