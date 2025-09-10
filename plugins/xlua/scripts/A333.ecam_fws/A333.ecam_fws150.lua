jit.off()
--[[
*****************************************************************************************
* Script Name : A333.ecam_fws150.lua
* Process: FWS Global EW/D Message Table
*
* Author Name :	Jim Gregory
*
* Revisions:
* -- DATE --  --- REV NO ---  --- DESCRIPTION -------------------------------------------
* 10/09/2025   AG330 v1.2.0   add ADIRS ALIGN MSG to EWD
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


--print("LOAD: A333.ecam_fws150.lua")

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

--name, itemGroup, itemTitle, warningTitle, itemGfx, warningGfx, titleColor, zone, failType, level, master, sysPage, aural, priority


-----------------------------------    Z O N E  0    ------------------------------------


-----| EWD ZONE 0 (LEFT) PRIMARY & INDEPENEDENT FAILURES

A333_ewd_msg.FLAP_LEVER_NOT_ZERO = newEWDwarningMessage('FLAP_LEVER_NOT_ZERO', 'F/CTL$1', 'F/CTL', 'FLAP LVR NOT ZERO', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1010)
A333_ewd_msg.FLAP_LEVER_NOT_ZERO.Inhibit = {1,1,1,1,1,0,1,1,1,1}
A333_ewd_msg.FLAP_LEVER_NOT_ZERO.CmdInputs = ':CLR:RCL:C:EC:'

A333_ewd_msg.OVER_SPEED_VFE1 = newEWDwarningMessage('OVER_SPEED_VFE1', 'OVER SPEED$1', 'OVER SPEED', '', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1021)
A333_ewd_msg.OVER_SPEED_VFE1.Inhibit = {0,1,1,1,0,0,0,1,1,1}
A333_ewd_msg.OVER_SPEED_VFE1.CmdInputs = ':CLR:RCL:EC:'
A333_ewd_msg.OVER_SPEED_VFE1.MsgLine = {
	{MsgColor = 0, MsgText = " -VFE................180", MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.OVER_SPEED_VFE2 = newEWDwarningMessage('OVER_SPEED_VFE2', 'OVER SPEED$2', 'OVER SPEED', '', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1022)
A333_ewd_msg.OVER_SPEED_VFE2.Inhibit = {0,1,1,1,0,0,0,1,1,1}
A333_ewd_msg.OVER_SPEED_VFE2.CmdInputs = ':CLR:RCL:EC:'
A333_ewd_msg.OVER_SPEED_VFE2.MsgLine = {
	{MsgColor = 0, MsgText = " -VFE................186", MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.OVER_SPEED_VFE3 = newEWDwarningMessage('OVER_SPEED_VFE3', 'OVER SPEED$3', 'OVER SPEED', '', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1023)
A333_ewd_msg.OVER_SPEED_VFE3.Inhibit = {0,1,1,1,0,0,0,1,1,1}
A333_ewd_msg.OVER_SPEED_VFE3.CmdInputs = ':CLR:RCL:EC:'
A333_ewd_msg.OVER_SPEED_VFE3.MsgLine = {
	{MsgColor = 0, MsgText = " -VFE................196", MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.OVER_SPEED_VFE4 = newEWDwarningMessage('OVER_SPEED_VFE4', 'OVER SPEED$4', 'OVER SPEED', '', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1024)
A333_ewd_msg.OVER_SPEED_VFE4.Inhibit = {0,1,1,1,0,0,0,1,1,1}
A333_ewd_msg.OVER_SPEED_VFE4.CmdInputs = ':CLR:RCL:EC:'
A333_ewd_msg.OVER_SPEED_VFE4.MsgLine = {
	{MsgColor = 0, MsgText = " -VFE................205", MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.OVER_SPEED_VFE5 = newEWDwarningMessage('OVER_SPEED_VFE5', 'OVER SPEED$5', 'OVER SPEED', '', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1024)
A333_ewd_msg.OVER_SPEED_VFE5.Inhibit = {0,1,1,1,0,0,0,1,1,1}
A333_ewd_msg.OVER_SPEED_VFE5.CmdInputs = ':CLR:RCL:EC:'
A333_ewd_msg.OVER_SPEED_VFE5.MsgLine = {
	{MsgColor = 0, MsgText = " -VFE................215", MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.OVER_SPEED_VFE6 = newEWDwarningMessage('OVER_SPEED_VFE6', 'OVER SPEED$6', 'OVER SPEED', '', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1024)
A333_ewd_msg.OVER_SPEED_VFE6.Inhibit = {0,1,1,1,0,0,0,1,1,1}
A333_ewd_msg.OVER_SPEED_VFE6.CmdInputs = ':CLR:RCL:EC:'
A333_ewd_msg.OVER_SPEED_VFE6.MsgLine = {
	{MsgColor = 0, MsgText = " -VFE................240", MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.OVER_SPEED_VLE = newEWDwarningMessage('OVER_SPEED_VLE', 'OVER SPEED$7', 'OVER SPEED', '', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1027)
A333_ewd_msg.OVER_SPEED_VLE.Inhibit = {0,1,1,1,0,0,0,1,1,1}
A333_ewd_msg.OVER_SPEED_VLE.CmdInputs = ':CLR:RCL:EC:'
A333_ewd_msg.OVER_SPEED_VLE.MsgLine = {
	{MsgColor = 0, MsgText = " -VLE...........250/0.55", MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.OVER_SPEED_VMO_MMO = newEWDwarningMessage('OVER_SPEED_VMO_MMO', 'OVER SPEED$8', 'OVER SPEED', '', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1028)
A333_ewd_msg.OVER_SPEED_VMO_MMO.Inhibit = {0,1,1,1,0,0,0,1,1,1}
A333_ewd_msg.OVER_SPEED_VMO_MMO.CmdInputs = ':CLR:RCL:EC:'
A333_ewd_msg.OVER_SPEED_VMO_MMO.MsgLine = {
	{MsgColor = 0, MsgText = " -VMO/MMO.......330/0.86", MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.ENG_DUAL_FAULT = newEWDwarningMessage('ENG_DUAL_FAULT', 'ENG $1', 'ENG', 'DUAL FAILURE', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1100)
A333_ewd_msg.ENG_DUAL_FAULT.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.ENG_DUAL_FAULT.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_DUAL_FAULT.MsgLine = {
	{MsgColor = 4, MsgText = ' -ENG MODE SEL.......IGN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -THR LEVERS........IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' OPTIMUM RELIGHT SPD.300', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -EMER ELEC PWR...MAN ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -VHF1/HF1/ATC1......USE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -VHF1/ATC1..........USE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -FAC 1......OFF THEN ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '.IF NO RELIGHT AFTER 30S', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTERS.OFF 30S/ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '   .IF UNSUCCESSFUL :   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -APU (IF AVAIL)...START', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -WING ANTI ICE......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -APU BLEED...........ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTERS.OFF 30S/ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' OPTIMUM SPEED.....G DOT', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '     .EARLY IN APPR :   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -CAB SECURE.......ORDER', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -FOR LDG.....USE FLAP 3', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '   .AT 5000 FT AGL :    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -L/G.........GRVTY EXTN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' TARGET SPEED......150KT', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '    .AT TOUCH DOWN :    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTERS........OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -APU MASTER SW......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -EVAC..........INITIATE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -BAT 1+2............OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.ENG_1_FIRE = newEWDwarningMessage('ENG_1_FIRE', 'ENG 1 FIRE$1', 'ENG 1', 'FIRE', 1, 1, 0, 0, 1, 3, 1, 1, 1, 1200)
A333_ewd_msg.ENG_1_FIRE.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.ENG_1_FIRE.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_1_FIRE.MsgLine = {
	{MsgColor = 4, MsgText = ' -THR LEVER 1.......IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -THR LEVERS........IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '  .WHEN A/C IS STOPPED: ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -PARKING BRAKE.......ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 1.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG 1 FIRE P/B....PUSH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = ' -AGENT 1 AFT 10S..DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT 1..........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT 1..........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT 2..........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 2.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ATC.............NOTIFY', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -CABIN CREW.......ALERT', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '   .IF FIRE AFTER 30S:  ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT 2..........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '     .IF EVAC REQD:     ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -EVAC COMMAND........ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -APU MASTER SW......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -BAT 1+2............OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.ENG_2_FIRE = newEWDwarningMessage('ENG_2_FIRE', 'ENG 2 FIRE$1', 'ENG 2', 'FIRE', 1, 1, 0, 0, 1, 3, 1, 1, 1, 1210)
A333_ewd_msg.ENG_2_FIRE.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.ENG_2_FIRE.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_2_FIRE.MsgLine = {
	{MsgColor = 4, MsgText = ' -THR LEVER 2.......IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -THR LEVERS........IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '  .WHEN A/C IS STOPPED: ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -PARKING BRAKE.......ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 2.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG 2 FIRE P/B....PUSH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = ' -AGENT 1 AFT 10S..DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT 1..........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT 1..........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT 2..........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 1.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ATC.............NOTIFY', MsgVisible = 0, MsgCleared = 0, MsgStatus = 1},
	{MsgColor = 4, MsgText = ' -CABIN CREW.......ALERT', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '   .IF FIRE AFTER 30S:  ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT 2..........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '     .IF EVAC REQD:     ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -EVAC COMMAND........ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -APU MASTER SW......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -BAT 1+2............OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.APU_FIRE = newEWDwarningMessage('APU_FIRE', 'APU FIRE$1', 'APU', 'FIRE', 1, 1, 0, 0, 1, 3, 1, 8, 1, 1220)
A333_ewd_msg.APU_FIRE.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.APU_FIRE.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.APU_FIRE.MsgLine = {
	{MsgColor = 4, MsgText = ' -APU FIRE P/B......PUSH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT AFT %2dS...DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT............DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -MASTER SW..........OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}





A333_ewd_msg.SLATS_CONFIG = newEWDwarningMessage('SLATS_CONFIG', 'CONFIG$1', 'CONFIG', '', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1300)
A333_ewd_msg.SLATS_CONFIG.Inhibit = {0,0,0,0,1,1,1,1,0,0}
A333_ewd_msg.SLATS_CONFIG.CmdInputs = ':CLR:RCL:EC:'
A333_ewd_msg.SLATS_CONFIG.MsgLine = {
	{MsgColor = 0, MsgText = 'SLATS NOT IN T.O CONFIG ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}


A333_ewd_msg.FLAPS_CONFIG = newEWDwarningMessage('FLAPS_CONFIG', 'CONFIG$2', 'CONFIG', '', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1310)
A333_ewd_msg.FLAPS_CONFIG.Inhibit = {0,0,0,0,1,1,1,1,0,0}
A333_ewd_msg.FLAPS_CONFIG.CmdInputs = ':CLR:RCL:EC:'
A333_ewd_msg.FLAPS_CONFIG.MsgLine = {
	{MsgColor = 0, MsgText = 'FLAPS NOT IN T.O CONFIG ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}


A333_ewd_msg.SPD_BRK_CONFIG = newEWDwarningMessage('SPD_BRK_CONFIG', 'CONFIG$3', 'CONFIG', '', 1, 0, 0, 0, 1, 3, 1, 12, 1, 1320)
A333_ewd_msg.SPD_BRK_CONFIG.Inhibit = {0,0,0,0,1,1,1,1,0,0}
A333_ewd_msg.SPD_BRK_CONFIG.CmdInputs = ':CLR:RCL:EC:'
A333_ewd_msg.SPD_BRK_CONFIG.MsgLine = {
	{MsgColor = 0, MsgText = 'SPD BRK NOT RETRACTED   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}


A333_ewd_msg.PITCH_TRIM_CONFIG = newEWDwarningMessage('PITCH_TRIM_CONFIG', 'CONFIG$4', 'CONFIG', 'PITCH TRIM', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1330)
A333_ewd_msg.PITCH_TRIM_CONFIG.Inhibit = {0,0,0,0,1,1,1,1,0,0}
A333_ewd_msg.PITCH_TRIM_CONFIG.CmdInputs = ':CLR:RCL:EC:'
A333_ewd_msg.PITCH_TRIM_CONFIG.MsgLine = {
	{MsgColor = 0, MsgText = '    NOT IN T.O RANGE    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}


A333_ewd_msg.RUDDER_TRIM_CONFIG = newEWDwarningMessage('RUDDER_TRIM_CONFIG', 'CONFIG$8', 'CONFIG', 'RUD TRIM', 1, 0, 0, 0, 1, 3, 1, 12, 1, 1340)
A333_ewd_msg.RUDDER_TRIM_CONFIG.Inhibit = {0,0,0,0,1,1,1,1,0,0}
A333_ewd_msg.RUDDER_TRIM_CONFIG.CmdInputs = ':CLR:RCL:EC:'
A333_ewd_msg.RUDDER_TRIM_CONFIG.MsgLine = {
	{MsgColor = 0, MsgText = '    NOT IN T.O RANGE    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}

A333_ewd_msg.PARK_BRK_ON_CONFIG = newEWDwarningMessage('PARK_BRK_ON_CONFIG', 'CONFIG$5', 'CONFIG', 'PARK BRK ON', 1, 0, 0, 0, 1, 3, 1, 0, 1, 1350)
A333_ewd_msg.PARK_BRK_ON_CONFIG.Inhibit = {1,0,0,0,1,1,1,1,1,1}
A333_ewd_msg.PARK_BRK_ON_CONFIG.CmdInputs = ':CLR:RCL:C:EC:'





A333_ewd_msg.EXCESS_CAB_ALT = newEWDwarningMessage('EXCESS_CAB_ALT', 'CAB PR$1', 'CAB PR', 'EXCESS CAB ALT', 1, 0, 0, 0, 1, 3, 1, 3, 1, 2900)
A333_ewd_msg.EXCESS_CAB_ALT.Inhibit = {0,1,1,1,1,0,1,1,1,1}
A333_ewd_msg.EXCESS_CAB_ALT.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.EXCESS_CAB_ALT.MsgLine = {
	{MsgColor = 3, MsgText = ' -CREW OXY MASK.......ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -DESCENT.......INITIATE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = ' .IF RAPID DECOMPRESSION', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' EMER DESCENT FL 100/MEA', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -THR LEVERS........IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -SPD BRK...........FULL', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' SPD.....MAX/APPROPRIATE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -SIGNS...............ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MODE...........IGN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ATC............ NOTIFY', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = ' .IF CAB ALT>14000FT:   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -PAX OXY MASKS...MAN ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}





A333_ewd_msg.ENG_1_OIL_LO_PR = newEWDwarningMessage('ENG_1_OIL_LO_PR', 'ENG 1$2', 'ENG 1', 'OIL LO PR', 2, 2, 0, 0, 1, 3, 1, 1, 1, 3010)
A333_ewd_msg.ENG_1_OIL_LO_PR.Inhibit = {1,0,0,0,0,0,0,0,0,1}
A333_ewd_msg.ENG_1_OIL_LO_PR.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_1_OIL_LO_PR.MsgLine = {
	{MsgColor = 3, MsgText = ' .IF OIL PR < 25 PSI :  ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -THR LEVER 1.......IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 1.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}




A333_ewd_msg.ENG_2_OIL_LO_PR = newEWDwarningMessage('ENG_2_OIL_LO_PR', 'ENG 2$2', 'ENG 2', 'OIL LO PR', 2, 2, 0, 0, 1, 3, 1, 1, 1, 3015)
A333_ewd_msg.ENG_2_OIL_LO_PR.Inhibit = {1,0,0,0,0,0,0,0,0,1}
A333_ewd_msg.ENG_2_OIL_LO_PR.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_2_OIL_LO_PR.MsgLine = {
	{MsgColor = 3, MsgText = ' .IF OIL PR < 25 PSI :  ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -THR LEVER 2.......IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 2.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}




A333_ewd_msg.L_R_ELEV_FAULT = newEWDwarningMessage('L_R_ELEV_FAULT', 'F/CTL$2', 'F/CTL', 'L+R ELEV FAULT', 1, 0, 0, 0, 1, 3, 1, 12, 1, 3100)
A333_ewd_msg.L_R_ELEV_FAULT.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.L_R_ELEV_FAULT.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.L_R_ELEV_FAULT.MsgLine = {
	{MsgColor = 4, MsgText = ' MAX SPEED.......320/.77', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -MAN PITCH TRIM.....USE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -SPD BRK......DO NO USE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}




A333_ewd_msg.GEAR_NOT_DOWN = newEWDwarningMessage('GEAR_NOT_DOWN', 'L/G$1', 'L/G', 'GEAR NOT DOWN', 1, 0, 0, 0, 1, 3, 1, 0, 1, 4000)
A333_ewd_msg.GEAR_NOT_DOWN.Inhibit = {0,0,1,1,1,0,0,0,0,0}
A333_ewd_msg.GEAR_NOT_DOWN.CmdInputs = ':CLR:RCL:EC:'




A333_ewd_msg.GEAR_NOT_DOWNLOCKED = newEWDwarningMessage('GEAR_NOT_DOWNLOCKED', 'L/G$3', 'L/G', 'GEAR NOT DOWNLOCKED', 1, 0, 0, 0, 2, 3, 1, 11, 1, 4010)
A333_ewd_msg.GEAR_NOT_DOWNLOCKED.Inhibit = {0,0,1,1,1,0,0,0,0,0}
A333_ewd_msg.GEAR_NOT_DOWNLOCKED.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.GEAR_NOT_DOWNLOCKED.MsgLine = {
	{MsgColor = 4, MsgText = ' -L/G............RECYCLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '    .IF UNSUCCESSFUL :  ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = ' -L/G.........GRVTY EXTN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}









--name, itemGroup, itemTitle, warningTitle,        itemGfx, warningGfx, titleColor, zone, failType, level, master, sysPage, aural, priority

A333_ewd_msg.AP_OFF_UNVOLUNTARY = newEWDwarningMessage('AP_OFF_UNVOLUNTARY', 'AUTO FLT$1', 'AUTO FLT', 'AP OFF', 1, 0, 0, 0, 1, 3, 0, 0, 4, 4015)
A333_ewd_msg.AP_OFF_UNVOLUNTARY.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.AP_OFF_UNVOLUNTARY.CmdInputs = ':CLR:RCL:EC:'

A333_ewd_msg.AP_OFF_MW_UNVOLUNTARY = newEWDwarningMessage('AP_OFF_MW_UNVOLUNTARY', '', '', '', 0, 0, 0, 0, 1, 3, 1, 0, 0, 4017)
A333_ewd_msg.AP_OFF_MW_UNVOLUNTARY.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.AP_OFF_MW_UNVOLUNTARY.CmdInputs = ':CLR:RCL:C:EC:'

A333_ewd_msg.AP_OFF_MW_VOLUNTARY = newEWDwarningMessage('AP_OFF_MW_VOLUNTARY', '', '', '', 0, 0, 0, 0, 1, 3, 0, 0, 0, 4020)
A333_ewd_msg.AP_OFF_MW_VOLUNTARY.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.AP_OFF_MW_VOLUNTARY.CmdInputs = ':C:EC:'

A333_ewd_msg.CAVALRY_CHARGE_VOLUNTARY_DISC = newEWDwarningMessage('CAVALRY_CHARGE_VOLUNTARY_DISC', '', '', '', 0, 0, 0, 0, 1, 3, 0, 0, 3, 4022)
A333_ewd_msg.CAVALRY_CHARGE_VOLUNTARY_DISC.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.CAVALRY_CHARGE_VOLUNTARY_DISC.CmdInputs = ':C:EC:'










A333_ewd_msg.FWD_CARGO_SMOKE = newEWDwarningMessage('FWD_CARGO_SMOKE', 'SMOKE$1', 'SMOKE', 'FWD CARGO SMOKE', 1, 0, 0, 0, 1, 3, 1, 9, 1, 4050)
A333_ewd_msg.FWD_CARGO_SMOKE.Inhibit = {0,0,0,1,1,0,1,1,0,0}
A333_ewd_msg.FWD_CARGO_SMOKE.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.FWD_CARGO_SMOKE.MsgLine = {
	{MsgColor = 4, MsgText = ' -FWD ISOL VALVE.....OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT............DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT1...........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.AFT_CARGO_SMOKE = newEWDwarningMessage('AFT_CARGO_SMOKE', 'SMOKE$1', 'SMOKE', 'AFT CARGO SMOKE', 1, 0, 0, 0, 1, 3, 1, 9, 1, 4060)
A333_ewd_msg.AFT_CARGO_SMOKE.Inhibit = {0,0,0,1,1,0,1,1,0,0}
A333_ewd_msg.AFT_CARGO_SMOKE.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.AFT_CARGO_SMOKE.MsgLine = {
	{MsgColor = 4, MsgText = ' -AFT ISOL VALVE.....OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT............DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT1...........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}










A333_ewd_msg.ELEC_EMER_CONFIG = newEWDwarningMessage('ELEC_EMER_CONFIG', 'ELEC$1', 'ELEC', 'EMER CONFIG', 1, 2, 0, 0, 1, 3, 1, 5, 1, 4200)
A333_ewd_msg.ELEC_EMER_CONFIG.Inhibit = {0,0,0,1,0,0,0,1,0,0}
A333_ewd_msg.ELEC_EMER_CONFIG.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine = {
	{MsgColor = 4, MsgText = ' MIN RAT SPEED.....140KT', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -GEN 1+2....OFF THEN ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '   .IF UNSUCCESSFUL :   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -BUS TIE............OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -GEN 1+2....OFF THEN ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -EMER ELEC PWR...MAN ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MODE SEL.......IGN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -VHF1/ATC1..........USE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -VHF1/HF1/ATC1......USE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -APPR NAVAID....ON RMP1', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -IR 2+3(IF IR1 OK)..OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' AVOID ICING CONDITIONS ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' FUEL GRVTY FEED        ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' PROC:GRVTY FUEL FEEDING', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '.IF TIME TO LDG > 5 MN :', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -L/G.................UP', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -EMER ELEC PWR...MAN ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -APU MASTER SW......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -FAC 1......OFF THEN ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -VENT EXTRACT......OVRD', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
	--{MsgColor = 4, MsgText = ' -LDG ELEV....MAN ADJUST', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0} -- TODO: NOT MODELED
}












A333_ewd_msg.HYD_BY_SYS_LO_PR = newEWDwarningMessage('HYD_BY_SYS_LO_PR', 'HYD$1', 'HYD', 'B+Y SYS LO PR', 1, 2, 0, 0, 2, 3, 1, 6, 1, 4300)
A333_ewd_msg.HYD_BY_SYS_LO_PR.Inhibit = {0,0,0,1,1,0,0,0,0,0}
A333_ewd_msg.HYD_BY_SYS_LO_PR.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine = {
	{MsgColor = 4, MsgText = ' MIN RAT SPEED.....140KT', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -YELLOW ELEC PUMP....ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -RAT.............MAN ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -BLUE ELEC PUMP.....OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -YELLOW ENG 2 PUMP..OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX SPEED......320/.77 ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MANEUVER WITH CARE     ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.HYD_GB_SYS_LO_PR = newEWDwarningMessage('HYD_GB_SYS_LO_PR', 'HYD$1', 'HYD', 'G+B SYS LO PR', 1, 2, 0, 0, 2, 3, 1, 6, 1, 4305)
A333_ewd_msg.HYD_GB_SYS_LO_PR.Inhibit = {0,0,0,1,1,0,0,0,0,0}
A333_ewd_msg.HYD_GB_SYS_LO_PR.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.HYD_GB_SYS_LO_PR.MsgLine = {
	{MsgColor = 4, MsgText = ' MIN RAT SPEED.....140KT', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -RAT.............MAN ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -BLUE ELEC PUMP.....OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -GREEN ENG 1 PUMP...OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MANEUVER WITH CARE     ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}


A333_ewd_msg.HYD_GY_SYS_LO_PR = newEWDwarningMessage('HYD_GY_SYS_LO_PR', 'HYD$1', 'HYD', 'G+Y SYS LO PR', 1, 2, 0, 0, 2, 3, 1, 6, 1, 4310)
A333_ewd_msg.HYD_GY_SYS_LO_PR.Inhibit = {0,0,0,1,1,0,0,0,0,0}
A333_ewd_msg.HYD_GY_SYS_LO_PR.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.HYD_GY_SYS_LO_PR.MsgLine = {
	{MsgColor = 4, MsgText = ' -GREEN ENG 1 PUMP...OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -YELLOW ENG 2 PUMP..OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -YELLOW ELEC PUMP....ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MANEUVER WITH CARE     ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}






A333_ewd_msg.ENG_1_REVERSE_UNLOCKED = newEWDwarningMessage('ENG_1_REVERSE_UNLOCKED', 'ENG1$3', 'ENG 1', 'REVERSE UNLOCKED', 1, 0, 1, 0, 1, 2, 2, 0, 2, 4400)
A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.Inhibit = {0,0,0,0,0,0,0,1,0,0}
A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine = {
	{MsgColor = 1, MsgText = 'ENG 1 AT IDLE           ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -THR LEVER 1.......IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX SPEED.......300/.78', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '      .IF BUFFET :      ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX SPEED...........240', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 1.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -RUD TRIM........FULL R', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -CONTROL HDG WITH ROLL ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.ENG_1_FAIL = newEWDwarningMessage('ENG_1_FAIL', 'ENG 1$3', 'ENG 1', 'FAIL', 1, 2, 1, 0, 1, 2, 2, 0, 2, 4500)
A333_ewd_msg.ENG_1_FAIL.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.ENG_1_FAIL.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_1_FAIL.MsgLine = {
	{MsgColor = 4, MsgText = ' -ENG MODE SEL.......IGN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -THR LEVER 1.......IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '.IF NO RELIGHT AFTER 30S', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 1.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '      .IF DAMAGE:       ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG 1 FIRE P/B....PUSH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = '-AGENT 1 AFT 10S...DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT 1..........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT 1..........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '     .IF NO DAMAGE:     ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG 1 RELIGHT.INITIATE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.ENG_1_OIL_HI_TEMP = newEWDwarningMessage('ENG_1_OIL_HI_TEMP', 'ENG 1$3', 'ENG 1', 'OIL HI TEMP', 1, 0, 1, 0, 1, 2, 2, 1, 2, 4510)
A333_ewd_msg.ENG_1_OIL_HI_TEMP.Inhibit = {0,0,0,1,1,0,1,1,0,0}
A333_ewd_msg.ENG_1_OIL_HI_TEMP.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_1_OIL_HI_TEMP.MsgLine = {
	{MsgColor = 4, MsgText = ' -THR LEVER 1.......IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 1.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}


A333_ewd_msg.ENG_1_SHUT_DOWN = newEWDwarningMessage('ENG_1_SHUT_DOWN', 'ENG 1$3', 'ENG 1', 'SHUT DOWN', 2, 2, 1, 0, 2, 2, 2, 0, 2, 4520)
A333_ewd_msg.ENG_1_SHUT_DOWN.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.ENG_1_SHUT_DOWN.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine = {
	{MsgColor = 4, MsgText = ' -PACK 1.............OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -X BLEED...........OPEN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MOD SEL........IGN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -FUEL X FEED.........ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '     .IF BUFFET :       ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -MAX SPEED..........240', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -X BLEED...........SHUT', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -WING ANTI ICE......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AVOID ICING CONDITIONS', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}



A333_ewd_msg.ENG_2_REVERSE_UNLOCKED = newEWDwarningMessage('ENG_2_REVERSE_UNLOCKED', 'ENG2$3', 'ENG 2', 'REVERSE UNLOCKED', 1, 0, 1, 0, 1, 2, 2, 0, 2, 4600)
A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.Inhibit = {0,0,0,0,0,0,0,1,0,0}
A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine = {
	{MsgColor = 1, MsgText = 'ENG 2 AT IDLE           ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -THR LEVER 2.......IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX SPEED.......300/.78', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '      .IF BUFFET :      ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX SPEED...........240', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 2.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -RUD TRIM........FULL L', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -CONTROL HDG WITH ROLL ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}



A333_ewd_msg.ENG_2_FAIL = newEWDwarningMessage('ENG_2_FAIL', 'ENG 2$3', 'ENG 2', 'FAIL', 1, 2, 1, 0, 1, 2, 2, 0, 2, 4610)
A333_ewd_msg.ENG_2_FAIL.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.ENG_2_FAIL.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_2_FAIL.MsgLine = {
	{MsgColor = 4, MsgText = ' -ENG MODE SEL.......IGN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -THR LEVER 2.......IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '.IF NO RELIGHT AFTER 30S', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 2.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '      .IF DAMAGE:       ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG 2 FIRE P/B....PUSH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT 1 AFT 10S..DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT 1..........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AGENT 1..........DISCH', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '     .IF NO DAMAGE:     ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG 1 RELIGHT.INITIATE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.ENG_2_OIL_HI_TEMP = newEWDwarningMessage('ENG_2_OIL_HI_TEMP', 'ENG 2$3', 'ENG 2', 'OIL HI TEMP', 1, 0, 1, 0, 1, 2, 2, 1, 2, 4620)
A333_ewd_msg.ENG_2_OIL_HI_TEMP.Inhibit = {0,0,0,1,1,0,1,1,0,0}
A333_ewd_msg.ENG_2_OIL_HI_TEMP.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_2_OIL_HI_TEMP.MsgLine = {
	{MsgColor = 4, MsgText = ' -THR LEVER 2.......IDLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 2.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.ENG_2_SHUT_DOWN = newEWDwarningMessage('ENG_2_SHUT_DOWN', 'ENG 2$3', 'ENG 2', 'SHUT DOWN', 2, 2, 1, 0, 2, 2, 2, 0, 2, 4630)
A333_ewd_msg.ENG_2_SHUT_DOWN.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.ENG_2_SHUT_DOWN.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine = {
	{MsgColor = 4, MsgText = ' -PACK 1.............OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -PACK 2.............OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -X BLEED...........OPEN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MOD SEL........IGN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -FUEL X FEED.........ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '     .IF BUFFET :       ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -MAX SPEED..........240', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -X BLEED...........SHUT', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -WING ANTI ICE......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AVOID ICING CONDITIONS', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}









A333_ewd_msg.ENG_1_HUNG_START = newEWDwarningMessage('ENG_1_HUNG_START', 'ENG 1$B', 'ENG 1', 'START FAULT', 1, 0, 1, 0, 1, 2, 2, 1, 2, 4700)
A333_ewd_msg.ENG_1_HUNG_START.Inhibit = {0,0,1,1,1,0,1,1,0,0}
A333_ewd_msg.ENG_1_HUNG_START.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_1_HUNG_START.MsgLine = {
	{MsgColor = 1, MsgText = ' -HUNG START            ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AUTO CRANK IN PROGRESS', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -MAN START..........OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 1.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}




A333_ewd_msg.ENG_2_HUNG_START = newEWDwarningMessage('ENG_2_HUNG_START', 'ENG 2$B', 'ENG 2', 'START FAULT', 1, 0, 1, 0, 1, 2, 2, 1, 2, 4700)
A333_ewd_msg.ENG_2_HUNG_START.Inhibit = {0,0,1,1,1,0,1,1,0,0}
A333_ewd_msg.ENG_2_HUNG_START.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_2_HUNG_START.MsgLine = {
	{MsgColor = 1, MsgText = ' -HUNG START            ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AUTO CRANK IN PROGRESS', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -MAN START..........OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -ENG MASTER 2.......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}









A333_ewd_msg.ENG_1_OIL_LO_TEMP = newEWDwarningMessage('ENG_1_OIL_LO_TEMP', 'ENG 1$C', 'ENG 1', 'OIL LO TEMP', 1, 0, 1, 0, 1, 2, 2, 1, 2, 4900)
A333_ewd_msg.ENG_1_OIL_LO_TEMP.Inhibit = {1,0,0,1,1,1,1,1,1,1}
A333_ewd_msg.ENG_1_OIL_LO_TEMP.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_1_OIL_LO_TEMP.MsgLine = {
	{MsgColor = 4, MsgText = ' -DELAY T.O.	          ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' AVOIND HI POWER        ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}




A333_ewd_msg.ENG_2_OIL_LO_TEMP = newEWDwarningMessage('ENG_2_OIL_LO_TEMP', 'ENG 2$C', 'ENG 2', 'OIL LO TEMP', 1, 0, 1, 0, 1, 2, 2, 1, 2, 4900)
A333_ewd_msg.ENG_2_OIL_LO_TEMP.Inhibit = {1,0,0,1,1,1,1,1,1,1}
A333_ewd_msg.ENG_2_OIL_LO_TEMP.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.ENG_2_OIL_LO_TEMP.MsgLine = {
	{MsgColor = 4, MsgText = ' -DELAY T.O.	          ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' AVOID HI POWER         ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}







A333_ewd_msg.DC_EMER_CONFIG = newEWDwarningMessage('DC_EMER_CONFIG', 'ELEC$2', 'ELEC', 'DC EMER CONFIG', 1, 2, 1, 0, 1, 2, 2, 5, 2, 5000)
A333_ewd_msg.DC_EMER_CONFIG.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.DC_EMER_CONFIG.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.DC_EMER_CONFIG.MsgLine = {
	{MsgColor = 4, MsgText = ' -EMER ELEC PWR.......ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.DC_BUS_1_2_OFF = newEWDwarningMessage('DC_BUS_1_2_OFF', 'ELEC$2', 'ELEC', 'DC BUS 1+2 OFF', 1, 2, 1, 0, 2, 2, 2, 5, 2, 5005)
A333_ewd_msg.DC_BUS_1_2_OFF.Inhibit = {0,0,0,1,0,0,0,1,0,0}
A333_ewd_msg.DC_BUS_1_2_OFF.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.DC_BUS_1_2_OFF.MsgLine = {
	{MsgColor = 4, MsgText = ' -EXTRACT...........OVRD', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -BARO REF.........CHECK', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' AVOID ICING CONDITIONS ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX BRK........1000 PSI', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}








A333_ewd_msg.GEN_1_FAULT = newEWDwarningMessage('GEN_1_FAULT', 'ELEC$3', 'ELEC', 'GEN 1 FAULT', 1, 0, 1, 0, 1, 2, 2, 4, 2, 5020)
A333_ewd_msg.GEN_1_FAULT.Inhibit = {1,0,0,1,1,0,1,1,0,1}
A333_ewd_msg.GEN_1_FAULT.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.GEN_1_FAULT.MsgLine = {
	{MsgColor = 4, MsgText = ' -GEN 1......OFF THEN ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '   .IF UNSUCCESSFUL:    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -GEN1...............OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}

A333_ewd_msg.GEN_2_FAULT = newEWDwarningMessage('GEN_2_FAULT', 'ELEC$3', 'ELEC', 'GEN 2 FAULT', 1, 0, 1, 0, 1, 2, 2, 4, 2, 5020)
A333_ewd_msg.GEN_2_FAULT.Inhibit = {1,0,0,1,1,0,1,1,0,1}
A333_ewd_msg.GEN_2_FAULT.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.GEN_2_FAULT.MsgLine = {
	{MsgColor = 4, MsgText = ' -GEN 2......OFF THEN ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '   .IF UNSUCCESSFUL:    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -GEN 2..............OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}



A333_ewd_msg.APU_GEN_FAULT = newEWDwarningMessage('APU_GEN_FAULT', 'ELEC$3', 'ELEC', 'APU GEN FAULT', 1, 0, 1, 0, 1, 2, 2, 4, 2, 5040)
A333_ewd_msg.APU_GEN_FAULT.Inhibit = {1,1,1,0,0,1,0,0,1,1}
A333_ewd_msg.APU_GEN_FAULT.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.APU_GEN_FAULT.MsgLine = {
	{MsgColor = 4, MsgText = ' -APU GEN....OFF THEN ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '   .IF UNSUCCESSFUL:    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -APU GEN............OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}





--name, itemGroup, itemTitle, warningTitle, 		itemGfx, warningGfx, titleColor, zone, failType, level, master, sysPage, aural, priority
A333_ewd_msg.ALTI_DISCREPANCY = newEWDwarningMessage('ALTI_DISCREPANCY', 'NAV$1', 'NAV', 'ALTI DISCREPANCY', 1, 0, 1, 0, 1, 2, 2, 0, 2, 5700)
A333_ewd_msg.ALTI_DISCREPANCY.Inhibit = {0,0,0,1,1,0,0,1,0,0}
A333_ewd_msg.ALTI_DISCREPANCY.CmdInputs = ':CLR:RCL:C:EC:'








A333_ewd_msg.DOORS_NOT_CLOSED = newEWDwarningMessage('DOORS_NOT_CLOSED', 'L/G$4', 'L/G', 'DOORS NOT CLOSED', 1, 0, 1, 0, 1, 2, 2, 11, 2, 6500)
A333_ewd_msg.DOORS_NOT_CLOSED.Inhibit = {1,0,1,1,1,0,0,1,1,1}
A333_ewd_msg.DOORS_NOT_CLOSED.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.DOORS_NOT_CLOSED.MsgLine = {
	{MsgColor = 4, MsgText = ' -L/G............RECYCLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '    .IF UNSUCCESSFUL :  ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX SPEED.......250/.55', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.GEAR_NOT_UPLOCKED = newEWDwarningMessage('GEAR_NOT_UPLOCKED', 'L/G$4', 'L/G', 'GEAR NOT UPLOCKED', 1, 0, 1, 0, 1, 2, 2, 11, 2, 6505)
A333_ewd_msg.GEAR_NOT_UPLOCKED.Inhibit = {0,0,1,1,0,0,1,1,1,1}
A333_ewd_msg.GEAR_NOT_UPLOCKED.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.GEAR_NOT_UPLOCKED.MsgLine = {
	{MsgColor = 4, MsgText = ' MAX SPEED.......220/.54', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -L/G............RECYCLE', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 3, MsgText = '    .IF UNSUCCESSFUL :  ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -L/G...............DOWN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX SPEED.......250/.55', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' AVOID EXCESS G FACTOR  ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.GEAR_UPLOCK_FAULT = newEWDwarningMessage('GEAR_UPLOCK_FAULT', 'L/G$4', 'L/G', 'GEAR UPLOCK FAULT', 1, 0, 1, 0, 1, 2, 2, 11, 2, 6510)
A333_ewd_msg.GEAR_UPLOCK_FAULT.Inhibit = {0,0,0,1,0,0,0,0,0,0}
A333_ewd_msg.GEAR_UPLOCK_FAULT.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.GEAR_UPLOCK_FAULT.MsgLine = {
	{MsgColor = 4, MsgText = ' -L/G..........KEEP DOWN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX SPEED.......250/.55', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.SHOCK_ABSORBER_FAULT = newEWDwarningMessage('SHOCK_ABSORBER_FAULT', 'L/G$4', 'L/G', 'SHOCK ABSORBER FAULT', 1, 0, 1, 0, 1, 2, 2, 0, 2, 6520)
A333_ewd_msg.SHOCK_ABSORBER_FAULT.Inhibit = {1,0,1,1,0,0,0,0,0,0}
A333_ewd_msg.SHOCK_ABSORBER_FAULT.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.SHOCK_ABSORBER_FAULT.MsgLine = {
	{MsgColor = 4, MsgText = ' MAX SPEED.......250/.55', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -L/G..........KEEP DOWN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}




A333_ewd_msg.BRAKES_HOT = newEWDwarningMessage('BRAKES_HOT', 'BRAKES$1', 'BRAKES', 'HOT', 1, 0, 1, 0, 1, 2, 2, 11, 2, 6600)
A333_ewd_msg.BRAKES_HOT.Inhibit = {0,0,0,1,0,0,0,1,0,0}
A333_ewd_msg.BRAKES_HOT.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.BRAKES_HOT.MsgLine = {
	{MsgColor = 3, MsgText = '   .IF PERF PERMITS :   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -L/G........DN FOR COOL', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -BRK FAN.............ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -DELAY T.O. FOR COOL   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX SPEED.......250/.60', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}



A333_ewd_msg.L_R_WING_TK_LO_LVL = newEWDwarningMessage('L_R_WING_TK_LO_LVL', 'FUEL$1', 'FUEL', 'L+R WING TK LO LVL', 1, 0, 1, 0, 1, 2, 2, 13, 2, 6700)
A333_ewd_msg.L_R_WING_TK_LO_LVL.Inhibit = {0,0,1,1,1,0,1,1,1,0}
A333_ewd_msg.L_R_WING_TK_LO_LVL.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.L_R_WING_TK_LO_LVL.MsgLine = {
	{MsgColor = 4, MsgText = ' -L TK PUMP 1........OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -L TK PUMP 2........OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -R TK PUMP 1........OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -R TK PUMP 2........OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -FUEL X FEED.........ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.L_WING_TK_LO_LVL = newEWDwarningMessage('L_WING_TK_LO_LVL', 'FUEL$1', 'FUEL', 'L WING TK LO LVL', 1, 0, 1, 0, 1, 2, 2, 13, 2, 6710)
A333_ewd_msg.L_WING_TK_LO_LVL.Inhibit = {0,0,1,1,1,0,1,1,1,0}
A333_ewd_msg.L_WING_TK_LO_LVL.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.L_WING_TK_LO_LVL.MsgLine = {
	{MsgColor = 3, MsgText = '  .IF FUEL UNBALANCE:   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -FUEL X FEED.........ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -L TK PUMP 1........OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -L TK PUMP 2........OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}

A333_ewd_msg.R_WING_TK_LO_LVL = newEWDwarningMessage('R_WING_TK_LO_LVL', 'FUEL$1', 'FUEL', 'R WING TK LO LVL', 1, 0, 1, 0, 1, 2, 2, 13, 2, 6720)
A333_ewd_msg.R_WING_TK_LO_LVL.Inhibit = {0,0,1,1,1,0,1,1,1,0}
A333_ewd_msg.R_WING_TK_LO_LVL.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.R_WING_TK_LO_LVL.MsgLine = {
	{MsgColor = 3, MsgText = '  .IF FUEL UNBALANCE:   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -FUEL X FEED.........ON', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -R TK PUMP 1........OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -R TK PUMP 2........OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}








A333_ewd_msg.X_BLEED_FAULT = newEWDwarningMessage('X_BLEED_FAULT', 'AIR$1', 'AIR', 'X BLEED FAULT', 1, 0, 1, 0, 1, 2, 2, 2, 2, 6800)
A333_ewd_msg.X_BLEED_FAULT.Inhibit = {0,0,1,1,1,0,1,1,0,0}
A333_ewd_msg.X_BLEED_FAULT.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.X_BLEED_FAULT.MsgLine = {
	{MsgColor = 4, MsgText = ' -X BLEED........MAN CTL', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -WING ANTI ICE......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AVOID ICING CONDITIONS', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}






A333_ewd_msg.AI_ENG1_VALVE_CLOSED = newEWDwarningMessage('AI_ENG1_VALVE_CLOSED', 'ANTI ICE$2', 'ANTI ICE', 'ENG1 VALVE CLSD', 1, 0, 1, 0, 1, 2, 2, 0, 2, 6850)
A333_ewd_msg.AI_ENG1_VALVE_CLOSED.Inhibit = {0,0,1,1,1,0,1,1,0,0}
A333_ewd_msg.AI_ENG1_VALVE_CLOSED.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.AI_ENG1_VALVE_CLOSED.MsgLine = {
	{MsgColor = 4, MsgText = ' AVOID ICING CONDITIONS ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}



A333_ewd_msg.AI_ENG2_VALVE_CLOSED = newEWDwarningMessage('AI_ENG2_VALVE_CLOSED', 'ANTI ICE$2', 'ANTI ICE', 'ENG2 VALVE CLSD', 1, 0, 1, 0, 1, 2, 2, 0, 2, 6852)
A333_ewd_msg.AI_ENG2_VALVE_CLOSED.Inhibit = {0,0,1,1,1,0,1,1,0,0}
A333_ewd_msg.AI_ENG2_VALVE_CLOSED.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.AI_ENG2_VALVE_CLOSED.MsgLine = {
	{MsgColor = 4, MsgText = ' AVOID ICING CONDITIONS ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}





A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT = newEWDwarningMessage('WING_ANTI_ICE_SYS_FAULT', 'WING A.ICE$1', 'WING A.ICE', 'SYS FAULT', 1, 0, 1, 0, 1, 2, 2, 2, 2, 6900)
A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Inhibit = {0,0,1,1,1,0,1,1,0,0}
A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.MsgLine = {
	{MsgColor = 4, MsgText = ' -X BLEED...........OPEN', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -WING ANTI ICE......OFF', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' -AVOID ICING CONDITIONS', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0}
}









A333_ewd_msg.DOOR_L_FWD_CABIN = newEWDwarningMessage('DOOR_L_FWD_CABIN', 'DOOR$1', 'DOOR', 'L FWD CABIN', 1, 0, 1, 0, 1, 2, 2, 10, 2, 7000)
A333_ewd_msg.DOOR_L_FWD_CABIN.Inhibit = {1, 0, 0, 1, 1, 0, 1, 1, 0, 1}
A333_ewd_msg.DOOR_L_FWD_CABIN.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.DOOR_L_FWD_CABIN.MsgLine = {
	{MsgColor = 3, MsgText = '     .IF ABN CAB V/S:   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX FL..........100/MEA', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}

A333_ewd_msg.DOOR_L_MID_CABIN = newEWDwarningMessage('DOOR_L_MID_CABIN', 'DOOR$1', 'DOOR', 'L MID CABIN', 1, 0, 1, 0, 1, 2, 2, 10, 2, 7005)
A333_ewd_msg.DOOR_L_MID_CABIN.Inhibit = {1, 0, 0, 1, 1, 0, 1, 1, 0, 1}
A333_ewd_msg.DOOR_L_MID_CABIN.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.DOOR_L_MID_CABIN.MsgLine = {
	{MsgColor = 3, MsgText = '     .IF ABN CAB V/S:   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX FL..........100/MEA', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}

A333_ewd_msg.DOOR_L_AFT_CABIN = newEWDwarningMessage('DOOR_L_AFT_CABIN', 'DOOR$1', 'DOOR', 'L AFT CABIN', 1, 0, 1, 0, 1, 2, 2, 10, 2, 7010)
A333_ewd_msg.DOOR_L_AFT_CABIN.Inhibit = {1, 0, 0, 1, 1, 0, 1, 1, 0, 1}
A333_ewd_msg.DOOR_L_AFT_CABIN.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.DOOR_L_AFT_CABIN.MsgLine = {
	{MsgColor = 3, MsgText = '     .IF ABN CAB V/S:   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX FL..........100/MEA', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}

A333_ewd_msg.DOOR_R_FWD_CABIN = newEWDwarningMessage('DOOR_R_FWD_CABIN', 'DOOR$1', 'DOOR', 'R FWD CABIN', 1, 0, 1, 0, 1, 2, 2, 10, 2, 7015)
A333_ewd_msg.DOOR_R_FWD_CABIN.Inhibit = {1, 0, 0, 1, 1, 0, 1, 1, 0, 1}
A333_ewd_msg.DOOR_R_FWD_CABIN.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.DOOR_R_FWD_CABIN.MsgLine = {
	{MsgColor = 3, MsgText = '     .IF ABN CAB V/S:   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX FL..........100/MEA', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}

A333_ewd_msg.DOOR_R_MID_CABIN = newEWDwarningMessage('DOOR_R_MID_CABIN', 'DOOR$1', 'DOOR', 'R MID CABIN', 1, 0, 1, 0, 1, 2, 2, 10, 2, 7020)
A333_ewd_msg.DOOR_R_MID_CABIN.Inhibit = {1, 0, 0, 1, 1, 0, 1, 1, 0, 1}
A333_ewd_msg.DOOR_R_MID_CABIN.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.DOOR_R_MID_CABIN.MsgLine = {
	{MsgColor = 3, MsgText = '     .IF ABN CAB V/S:   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX FL..........100/MEA', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}

A333_ewd_msg.DOOR_R_AFT_CABIN = newEWDwarningMessage('DOOR_R_AFT_CABIN', 'DOOR$1', 'DOOR', 'R AFT CABIN', 1, 0, 1, 0, 1, 2, 2, 10, 2, 7025)
A333_ewd_msg.DOOR_R_AFT_CABIN.Inhibit = {1, 0, 0, 1, 1, 0, 1, 1, 0, 1}
A333_ewd_msg.DOOR_R_AFT_CABIN.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.DOOR_R_AFT_CABIN.MsgLine = {
	{MsgColor = 3, MsgText = '     .IF ABN CAB V/S:   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX FL..........100/MEA', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}

A333_ewd_msg.DOOR_L_EMER_EXIT = newEWDwarningMessage('DOOR_L_EMER_EXIT', 'DOOR$1', 'DOOR', 'L EMER EXIT', 1, 0, 1, 0, 1, 2, 2, 10, 2, 7030)
A333_ewd_msg.DOOR_L_EMER_EXIT.Inhibit = {1, 0, 0, 1, 1, 0, 1, 1, 0, 1}
A333_ewd_msg.DOOR_L_EMER_EXIT.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.DOOR_L_EMER_EXIT.MsgLine = {
	{MsgColor = 3, MsgText = '     .IF ABN CAB V/S:   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX FL..........100/MEA', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}

A333_ewd_msg.DOOR_R_EMER_EXIT = newEWDwarningMessage('DOOR_R_EMER_EXIT', 'DOOR$1', 'DOOR', 'R EMER EXIT', 1, 0, 1, 0, 1, 2, 2, 10, 2, 7035)
A333_ewd_msg.DOOR_R_EMER_EXIT.Inhibit = {1, 0, 0, 1, 1, 0, 1, 1, 0, 1}
A333_ewd_msg.DOOR_R_EMER_EXIT.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.DOOR_R_EMER_EXIT.MsgLine = {
	{MsgColor = 3, MsgText = '     .IF ABN CAB V/S:   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX FL..........100/MEA', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}

A333_ewd_msg.DOOR_R_AVIONICS = newEWDwarningMessage('DOOR_R_AVIONICS', 'DOOR$1', 'DOOR', 'R AVIONICS', 1, 0, 1, 0, 1, 2, 2, 10, 2, 7040)
A333_ewd_msg.DOOR_R_AVIONICS.Inhibit = {1, 0, 0, 1, 1, 0, 1, 1, 0, 1}
A333_ewd_msg.DOOR_R_AVIONICS.CmdInputs = ':CLR:RCL:C:EC:'
A333_ewd_msg.DOOR_R_AVIONICS.MsgLine = {
	{MsgColor = 3, MsgText = '     .IF ABN CAB V/S:   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = ' MAX FL..........100/MEA', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}






-----| EWD ZONE 0 (LEFT) CONFIG MEMO

A333_ewd_msg.TO_MEMO = newEWDwarningMessage('TO_MEMO', 'TO_MEMO', 'T.O', '', 1, 0, 2, 0, 5, 0, 0, 0, 0, 7900)
A333_ewd_msg.TO_MEMO.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.TO_MEMO.CmdInputs = ''
A333_ewd_msg.TO_MEMO.MsgLine = {
	{MsgColor = 2, MsgText = '    AUTO BRK            ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = '            .....MAX    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 2, MsgText = '    AUTO BRK MAX        ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},

	{MsgColor = 2, MsgText = '    SIGNS               ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = '         .........ON    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 2, MsgText = '    SIGNS ON            ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},

	{MsgColor = 2, MsgText = '    CABIN               ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = '         ......CHECK    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 2, MsgText = '    CABIN READY         ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},

	{MsgColor = 2, MsgText = '    SPLRS               ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = '         ........ARM    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 2, MsgText = '    SPLRS ARMED         ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},

	{MsgColor = 2, MsgText = '    FLAPS               ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = '         ........T.O    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 2, MsgText = '    FLAPS T.O           ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},

	{MsgColor = 2, MsgText = '    T.O CONFIG          ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = '              ..TEST    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 2, MsgText = '    T.O CONFIG NORMAL   ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}

A333_ewd_msg.LDG_MEMO = newEWDwarningMessage('LDG_MEMO', 'LDG_MEMO', 'LDG', '', 1, 0, 2, 0, 5, 0, 0, 0, 0, 7910)
A333_ewd_msg.LDG_MEMO.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.LDG_MEMO.CmdInputs = ''
A333_ewd_msg.LDG_MEMO.MsgLine = {
	{MsgColor = 2, MsgText = '    LDG GEAR            ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = '            ......DN    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 2, MsgText = '    LDG GEAR DN         ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},

	{MsgColor = 2, MsgText = '    SIGNS               ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = '         .........ON    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 2, MsgText = '    SIGNS ON            ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},

	{MsgColor = 2, MsgText = '    CABIN               ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = '         ......CHECK    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 2, MsgText = '    CABIN READY         ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},

	{MsgColor = 2, MsgText = '    SPLRS               ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = '         ........ARM    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 2, MsgText = '    SPLRS ARMED         ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},

	{MsgColor = 2, MsgText = '    FLAPS               ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = '         .......FULL    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 2, MsgText = '    FLAPS FULL          ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},

	{MsgColor = 2, MsgText = '    FLAPS               ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 4, MsgText = '         .....CONF 3    ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
	{MsgColor = 2, MsgText = '    FLAPS CONF 3        ', MsgVisible = 0, MsgCleared = 0, MsgStatus = 0},
}




-----| EWD ZONE 0 (LEFT) MEMO

A333_ewd_msg.GND_SPLRS_ARMED = newEWDwarningMessage('GND_SPLRS_ARMED', 'MEM0$0', 'GND SPLRS ARMED', '', 0, 0, 2, 0, 6, 0, 0, 0, 0, 7950)
A333_ewd_msg.GND_SPLRS_ARMED.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.GND_SPLRS_ARMED.CmdInputs = ''

A333_ewd_msg.ADIRS_ALIGN = newEWDwarningMessage('ADIRS_ALIGN', 'MEM0$1', 'IR IN ALIGN', '[time_remaining]', 0, 0, 2, 0, 6, 0, 0, 0, 0, 7975)
A333_ewd_msg.ADIRS_ALIGN.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.ADIRS_ALIGN.CmdInputs = ''

A333_ewd_msg.SEAT_BELTS = newEWDwarningMessage('SEAT_BELTS', 'MEM0$2', 'SEAT BELTS', '', 0, 0, 2, 0, 6, 0, 0, 0, 0, 7955)
A333_ewd_msg.SEAT_BELTS.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.SEAT_BELTS.CmdInputs = ''

A333_ewd_msg.NO_SMOKING = newEWDwarningMessage('NO_SMOKING', 'MEM0$3', 'NO SMOKING', '', 0, 0, 2, 0, 6, 0, 0, 0, 0, 7960)
A333_ewd_msg.NO_SMOKING.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.NO_SMOKING.CmdInputs = ''

A333_ewd_msg.STROBE_LT_OFF = newEWDwarningMessage('STROBE_LT_OFF', 'MEM0$4', 'STROBE LT OFF', '', 0, 0, 2, 0, 6, 0, 0, 0, 0, 7965)
A333_ewd_msg.STROBE_LT_OFF.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.STROBE_LT_OFF.CmdInputs = ''

A333_ewd_msg.GPWS_FLAP_MODE_OFF = newEWDwarningMessage('GPWS_FLAP_MODE_OFF', 'MEM0$5', 'GPWS FLAP MODE OFF', '', 0, 0, 2, 0, 6, 0, 0, 0, 0, 7970)
A333_ewd_msg.GPWS_FLAP_MODE_OFF.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.GPWS_FLAP_MODE_OFF.CmdInputs = ''

















-----------------------------------    Z O N E  1    ------------------------------------

-----| EWD ZONE 1 (RIGHT) SPECIAL LINES

A333_ewd_msg.TO_INHIBIT = newEWDwarningMessage('TO_INHIBIT', 'SL1$1', 'T.O INHIBIT ', '', 0, 0, 5, 1, 0, 0, 0, 0, 0, 8010)
A333_ewd_msg.TO_INHIBIT.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.TO_INHIBIT.CmdInputs = ''

A333_ewd_msg.LDG_INHIBIT = newEWDwarningMessage('LDG_INHIBIT', 'SL1$2', 'LDG INHIBIT ', '', 0, 0, 5, 1, 0, 0, 0, 0, 0, 8020)
A333_ewd_msg.LDG_INHIBIT.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.LDG_INHIBIT.CmdInputs = ''

A333_ewd_msg.LAND_ASAP_RED = newEWDwarningMessage('LAND_ASAP_RED', 'SL1$3', 'LAND ASAP   ', '', 0, 0, 0, 1, 0, 0, 0, 0, 0, 8030)
A333_ewd_msg.LAND_ASAP_RED.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.LAND_ASAP_RED.CmdInputs = ''

A333_ewd_msg.LAND_ASAP_AMBER = newEWDwarningMessage('LAND_ASAP_AMBER', 'SL1$4', 'LAND ASAP   ', '', 0, 0, 1, 1, 0, 0, 0, 0, 0, 8040)
A333_ewd_msg.LAND_ASAP_AMBER.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.LAND_ASAP_AMBER.CmdInputs = ''

A333_ewd_msg.AP_OFF_TEXT = newEWDwarningMessage('AP_OFF_TEXT', '', 'AP OFF      ', '', 0, 0, 1, 1, 0, 0, 0, 0, 0, 8050)
A333_ewd_msg.AP_OFF_TEXT.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.AP_OFF_TEXT.CmdInputs = ''

--name, itemGroup, itemTitle, warningTitle, itemGfx, warningGfx, titleColor, zone, failType, level, master, sysPage, aural, priority


-----| EWD ZONE 1 (RIGHT) SECONDARY FAILURES

A333_ewd_msg.AIR_BLEED = newEWDwarningMessage('AIR_BLEED', '*AIR BLEED$1', '_AIR BLEED  ', '', 0, 0, 1, 1, 4, 0, 0, 2, 0, 8500)
A333_ewd_msg.AIR_BLEED.Inhibit = {0,0,0,1,1,0,0,0,0,0}
A333_ewd_msg.AIR_BLEED.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.CAB_PRESS = newEWDwarningMessage('CAB_PRESS', '*CAB PRESS$1', '_CAB PRESS  ', '', 0, 0, 1, 1, 4, 0, 0, 2, 0, 8505)
A333_ewd_msg.CAB_PRESS.Inhibit = {0,0,0,1,1,0,0,0,0,0}
A333_ewd_msg.CAB_PRESS.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.AVNCS_VENT = newEWDwarningMessage('AVNCS_VENT', '*AVNCS_VENT$1', '_AVNCS_VENT ', '', 0, 0, 1, 1, 4, 0, 0, 3, 0, 8510)
A333_ewd_msg.AVNCS_VENT.Inhibit = {0,0,0,1,1,0,0,0,1,1}
A333_ewd_msg.AVNCS_VENT.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.ELEC = newEWDwarningMessage('ELEC', '*ELEC$4', '_ELEC       ', '', 0, 0, 1, 1, 4, 0, 0, 4, 0, 8515)
A333_ewd_msg.ELEC.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.ELEC.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.HYDB = newEWDwarningMessage('HYDB', '*HYD$3', '_HYD        ', '', 0, 0, 1, 1, 4, 0, 0, 6, 0, 8520)
A333_ewd_msg.HYDB.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.HYDB.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.HYDY = newEWDwarningMessage('HYDY', '*HYD$3', '_HYD        ', '', 0, 0, 1, 1, 4, 0, 0, 6, 0, 8525)
A333_ewd_msg.HYDY.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.HYDY.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.HYDG = newEWDwarningMessage('HYDG', '*HYD$3', '_HYD        ', '', 0, 0, 1, 1, 4, 0, 0, 6, 0, 8530)
A333_ewd_msg.HYDG.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.HYDG.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.FUEL = newEWDwarningMessage('FUEL', '*FUEL$4', '_FUEL       ', '', 0, 0, 1, 1, 4, 0, 0, 13, 0, 8535)
A333_ewd_msg.FUEL.Inhibit = {0,0,0,1,0,0,0,1,0,0}
A333_ewd_msg.FUEL.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.AIR_COND = newEWDwarningMessage('AIR_COND', '*AIR COND$1', '_AIR COND   ', '', 0, 0, 1, 1, 4, 0, 0, 2, 0, 8540)
A333_ewd_msg.AIR_COND.Inhibit = {0,0,0,1,0,0,0,1,0,0}
A333_ewd_msg.AIR_COND.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.BRAKES = newEWDwarningMessage('BRAKES', '*BRAKES$3', '_BRAKES     ', '', 0, 0, 1, 1, 4, 0, 0, 11, 0, 8545)
A333_ewd_msg.BRAKES.Inhibit = {0,0,0,1,0,0,0,1,0,0}
A333_ewd_msg.BRAKES.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.WHEEL = newEWDwarningMessage('WHEEL', '*WHEEL$2', '_WHEEL      ', '', 0, 0, 1, 1, 4, 0, 0, 11, 0, 8550)
A333_ewd_msg.WHEEL.Inhibit = {0,0,0,1,1,0,1,1,0,0}
A333_ewd_msg.WHEEL.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.FCTLG = newEWDwarningMessage('FCTLG', '*F/CTL$5', '_F/CTL      ', '', 0, 0, 1, 1, 4, 0, 0, 12, 0, 8555)
A333_ewd_msg.FCTLG.Inhibit = {0,0,0,1,1,0,1,1,0,0}
A333_ewd_msg.FCTLG.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.FCTLY = newEWDwarningMessage('FCTLY', '*F/CTL$5', '_F/CTL      ', '', 0, 0, 1, 1, 4, 0, 0, 12, 0, 8560)
A333_ewd_msg.FCTLY.Inhibit = {0,0,0,1,1,0,1,1,0,0}
A333_ewd_msg.FCTLY.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.FCTLB = newEWDwarningMessage('FCTLB', '*F/CTL$5', '_F/CTL      ', '', 0, 0, 1, 1, 4, 0, 0, 12, 0, 8565)
A333_ewd_msg.FCTLB.Inhibit = {0,0,0,1,1,0,1,1,0,0}
A333_ewd_msg.FCTLB.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.FCTLDC2 = newEWDwarningMessage('FCTLDC2', '*F/CTL$5', '_F/CTL      ', '', 0, 0, 1, 1, 4, 0, 0, 12, 0, 8570)
A333_ewd_msg.FCTLDC2.Inhibit = {0,0,0,1,0,0,0,1,0,0}
A333_ewd_msg.FCTLDC2.CmdInputs = ':CLR:RCL:'

A333_ewd_msg.FCTLESS = newEWDwarningMessage('FCTLESS', '*F/CTL$5', '_F/CTL      ', '', 0, 0, 1, 1, 4, 0, 0, 12, 0, 8575)
A333_ewd_msg.FCTLESS.Inhibit = {0,0,0,1,0,0,0,1,0,0}
A333_ewd_msg.FCTLESS.CmdInputs = ':CLR:RCL:'







-----| EWD ZONE 1 (RIGHT) MEMO

A333_ewd_msg.SPEED_BRAKE = newEWDwarningMessage('SPEED_BRAKE', 'MEM1$0010', 'SPEED BRAKE ', '', 0, 0, 1, 1, 6, 0, 0, 0, 0, 9000)
A333_ewd_msg.SPEED_BRAKE.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.SPEED_BRAKE.CmdInputs = ''

A333_ewd_msg.PARK_BRAKE = newEWDwarningMessage('PARK_BRAKE', 'MEM1$0020', 'PARK BRK    ', '', 0, 0, 1, 1, 6, 0, 0, 0, 0, 9010)
A333_ewd_msg.PARK_BRAKE.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.PARK_BRAKE.CmdInputs = ''

A333_ewd_msg.RAT_OUT = newEWDwarningMessage('RAT_OUT', 'MEM1$0030', 'RAT OUT     ', '', 0, 0, 1, 1, 6, 0, 0, 0, 0, 9020)
A333_ewd_msg.RAT_OUT.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.RAT_OUT.CmdInputs = ''

A333_ewd_msg.RAM_AIR_ON = newEWDwarningMessage('RAM_AIR_ON', 'MEM1$0040', 'RAM AIR ON  ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9030)
A333_ewd_msg.RAM_AIR_ON.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.RAM_AIR_ON.CmdInputs = ''

A333_ewd_msg.IGNITION = newEWDwarningMessage('IGNITION', 'MEM1$0050', 'IGNITION    ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9040)
A333_ewd_msg.IGNITION.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.IGNITION.CmdInputs = ''

A333_ewd_msg.CABIN_READY = newEWDwarningMessage('CABIN_READY', 'MEM1$0070', 'CABIN READY ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9060)
A333_ewd_msg.CABIN_READY.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.CABIN_READY.CmdInputs = ''

A333_ewd_msg.COMPANY_MSG = newEWDwarningMessage('COMPANY_MSG', 'MEM1$0080', 'COMPANY MSG ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9065)
A333_ewd_msg.COMPANY_MSG.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.COMPANY_MSG.CmdInputs = ''

A333_ewd_msg.ENG_A_ICE = newEWDwarningMessage('ENG_A_ICE', 'MEM1$0090', 'ENG A.ICE   ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9070)
A333_ewd_msg.ENG_A_ICE.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.ENG_A_ICE.CmdInputs = ''

A333_ewd_msg.WING_A_ICE = newEWDwarningMessage('WING_A_ICE', 'MEM1$0100', 'WING A.ICE  ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9080)
A333_ewd_msg.WING_A_ICE.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.WING_A_ICE.CmdInputs = ''

A333_ewd_msg.ICE_NOT_DET = newEWDwarningMessage('ICE_NOT_DET', 'MEM1$0110', 'ICE NOT DET ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9090)
A333_ewd_msg.ICE_NOT_DET.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.ICE_NOT_DET.CmdInputs = ''

A333_ewd_msg.APU_AVAIL = newEWDwarningMessage('APU_AVAIL', 'MEM1$0120', 'APU AVAIL   ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9100)
A333_ewd_msg.APU_AVAIL.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.APU_AVAIL.CmdInputs = ''

A333_ewd_msg.APU_BLEED = newEWDwarningMessage('APU_BLEED', 'MEM1$0130', 'APU BLEED   ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9110)
A333_ewd_msg.APU_BLEED.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.APU_BLEED.CmdInputs = ''

A333_ewd_msg.BRK_FAN = newEWDwarningMessage('BRK_FAN', 'MEM1$0140', 'BRK FAN     ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9120)
A333_ewd_msg.BRK_FAN.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.BRK_FAN.CmdInputs = ''

A333_ewd_msg.GPWS_FLAP_3 = newEWDwarningMessage('GPWS_FLAP_3', 'MEM1$0150', 'GPWS FLAP 3 ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9130)
A333_ewd_msg.GPWS_FLAP_3.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.GPWS_FLAP_3.CmdInputs = ''

--name, itemGroup, itemTitle, warningTitle, itemGfx, warningGfx, titleColor, zone, failType, level, master, sysPage, aural, priority
A333_ewd_msg.HF_VOICE = newEWDwarningMessage('HF_VOICE', 'MEM1$0153', 'HF VOICE    ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9133)
A333_ewd_msg.HF_VOICE.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.HF_VOICE.CmdInputs = ''

A333_ewd_msg.AUTO_BRK_LO = newEWDwarningMessage('AUTO_BRK_LO', 'MEM1$0160', 'AUTO BRK LO ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9140)
A333_ewd_msg.AUTO_BRK_LO.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.AUTO_BRK_LO.CmdInputs = ''

A333_ewd_msg.AUTO_BRK_MED = newEWDwarningMessage('AUTO_BRK_MED', 'MEM1$0170', 'AUTO BRK MED', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9150)
A333_ewd_msg.AUTO_BRK_MED.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.AUTO_BRK_MED.CmdInputs = ''

A333_ewd_msg.AUTO_BRK_MAX = newEWDwarningMessage('AUTO_BRK_MAX', 'MEM1$0180', 'AUTO BRK MAX', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9160)
A333_ewd_msg.AUTO_BRK_MAX.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.AUTO_BRK_MAX.CmdInputs = ''

A333_ewd_msg.AUTO_BRK_OFF = newEWDwarningMessage('AUTO_BRK_OFF', 'MEM1$0190', 'AUTO BRK OFF', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9170)
A333_ewd_msg.AUTO_BRK_OFF.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.AUTO_BRK_OFF.CmdInputs = ''

A333_ewd_msg.CTR_TK_FEEDG = newEWDwarningMessage('CTR_TK_FEEDG', 'MEM1$0200', 'CTR TK FEEDG', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9180)
A333_ewd_msg.CTR_TK_FEEDG.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.CTR_TK_FEEDG.CmdInputs = ''

A333_ewd_msg.FUEL_X_FEED = newEWDwarningMessage('FUEL_X_FEED', 'MEM1$0210', 'FUEL X FEED ', '', 0, 0, 2, 1, 6, 0, 0, 0, 0, 9190)
A333_ewd_msg.FUEL_X_FEED.Inhibit = {0,0,0,0,0,0,0,0,0,0}
A333_ewd_msg.FUEL_X_FEED.CmdInputs = ''





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







