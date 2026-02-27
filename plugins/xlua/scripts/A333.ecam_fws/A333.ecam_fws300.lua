--[[
*****************************************************************************************
* Script Name :	A333.ecam_fws300.lua
* Process: FWS Warning Trigger Logic
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
*       					 COPYRIGHT © 2021, 2022, 2025
*					 	   L A M I N A R   R E S E A R C H
*								  ALL RIGHTS RESERVED
*****************************************************************************************
--]]


--print("LOAD: A333.ecam_fws300.lua")

--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--[[

SIM_PERIOD: this contains the duration of the current frame in seconds (so it is alway a
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



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local bool2num = {[true] = 1, [false] = 0}
local m = math

local logic = {}

logic.eng1FireConf01 = newLeadingEdgeDelayedConfirmation('eng1FireConf01', 5.0)
logic.eng1FireConf02 = newLeadingEdgeDelayedConfirmation('eng1FireConf02', 5.0)

logic.eng2FireConf01 = newLeadingEdgeDelayedConfirmation('eng2FireConf01', 5.0)
logic.eng2FireConf02 = newLeadingEdgeDelayedConfirmation('eng2FireConf02', 5.0)

logic.apuFireConf01 = newLeadingEdgeDelayedConfirmation('apuFireConf01', 5.0)
logic.apuFireConf02 = newLeadingEdgeDelayedConfirmation('apuFireConf02', 5.0)

logic.toInhibConf01 = newLeadingEdgeDelayedConfirmation('toInhibConf01', 3.0)
logic.ldgInhibConf01 = newLeadingEdgeDelayedConfirmation('ldgInhibConf01', 3.0)

logic.vMOmMOMtrig01 = newLeadingEdgeTrigger('vMOmMOMtrig01', 6.0)

logic.lgShockAbsConf01 = newLeadingEdgeDelayedConfirmation('lgShockAbsConf01', 5.0)
logic.lgShockAbsConf02 = newLeadingEdgeDelayedConfirmation('lgShockAbsConf02', 10.0)

logic.lgNotDnLckConf01 = newLeadingEdgeDelayedConfirmation('lgNotDnLckConf01', 30.0)
logic.lgNotDnLckSRR01 = newSRlatchResetPriority('lgNotDnLckSRR01')

logic.APoffUnvPulse01 = newLeadingEdgePulse('APoffUnvPulse01')
logic.APoffUnvMtrig01 = newLeadingEdgeTrigger('APoffUnvMtrig01', 1.0)
logic.APoffUnvMtrig02 = newLeadingEdgeTrigger('APoffUnvMtrig02', 1.0)
logic.APoffUnvPulse02 = newFallingEdgePulse('APoffUnvPulse02')
logic.APoffUnvPulse03 = newLeadingEdgePulse('APoffUnvPulse03')
logic.APoffUnvPulse04 = newLeadingEdgePulse('APoffUnvPulse04')
logic.APoffUnvPulse05 = newLeadingEdgePulse('APoffUnvPulse05')
logic.APoffUnvPulse06 = newLeadingEdgePulse('APoffUnvPulse06')
logic.APoffUnvMtrig03 = newLeadingEdgeTrigger('APoffUnvMtrig03', 1.5)
logic.APoffUnvSRr01 = newSRlatchResetPriority('APoffUnvSRr01')
logic.APoffUnvSRr02 = newSRlatchResetPriority('APoffUnvSRr02')

logic.APoffMWpulse01 = newLeadingEdgePulse('APoffMWpulse01')
logic.APoffMWpulse02 = newLeadingEdgePulse('APoffMWpulse02')
logic.APoffMWSRr01 = newSRlatchResetPriority('APoffUnvSRr02')

logic.lgNotDnAltThreshold01 = newThreshold('lgNotDnAltThreshold01', '<', 750.0)
logic.lgNotDnAltThreshold02 = newThreshold('lgNotDnAltThreshold02', '<', 750.0)
logic.lgNotDnPulse01 = newLeadingEdgePulse('lgNotDnPulse01')
logic.lgNotDnPulse02 = newLeadingEdgePulse('lgNotDnPulse02')

logic.lgNotUpLckConf01 = newLeadingEdgeDelayedConfirmation('lgNotUpLckConf01', 30.0)
logic.lgNotUpLckConf02 = newLeadingEdgeDelayedConfirmation('lgNotUpLckConf02', 5.0)
logic.lgNotUpLckSRR01 = newSRlatchResetPriority('lgNotUpLckSRR01')

logic.doorNotClsdConf01 = newLeadingEdgeDelayedConfirmation('doorNotClsdConf01', 30.0)
logic.doorNotClsdSRR01 = newSRlatchResetPriority('doorNotClsdSRR01')

logic.excessCabAltConf01 = newLeadingEdgeDelayedConfirmation('excessCabAltConf01', 1.0)

logic.eng1oilLoPrFConf01 = newLeadingEdgeDelayedConfirmation('eng1oilLoPrFConf01', 1.5)
logic.eng2oilLoPrFConf01 = newLeadingEdgeDelayedConfirmation('eng2oilLoPrFConf01', 1.5)

logic.eng1oilHiTempConf01 = newLeadingEdgeDelayedConfirmation('eng1oilHiTempConf01', 900.0)
logic.eng1oilHiTempConf02 = newLeadingEdgeDelayedConfirmation('eng1oilHiTempConf02', 5.0)
logic.eng1oilHiTempSRR01 = newSRlatchResetPriority('eng1oilHiTempSRR01')

logic.eng2oilHiTempConf01 = newLeadingEdgeDelayedConfirmation('eng2oilHiTempConf01', 900.0)
logic.eng2oilHiTempConf02 = newLeadingEdgeDelayedConfirmation('eng2oilHiTempConf02', 5.0)
logic.eng2oilHiTempSRR01 = newSRlatchResetPriority('eng2oilHiTempSRR01')

logic.eng1failConf01 = newLeadingEdgeDelayedConfirmation('eng1failConf01', 3.0)
logic.eng1failSRR01 = newSRlatchResetPriority('eng1failSRR01')
logic.eng1failSRR02 = newSRlatchResetPriority('eng1failSRR02')

logic.eng2failConf01 = newLeadingEdgeDelayedConfirmation('eng2failConf01', 3.0)
logic.eng2failSRR01 = newSRlatchResetPriority('eng2failSRR01')
logic.eng2failSRR02 = newSRlatchResetPriority('eng2failSRR02')

logic.lWingLoLvlConf01 = newLeadingEdgeDelayedConfirmation('lWingLoLvlConf01', 30.0)
logic.rWingLoLvlConf01 = newLeadingEdgeDelayedConfirmation('rWingLoLvlConf01', 30.0)
logic.lrWingLoLvlConf01 = newLeadingEdgeDelayedConfirmation('lrWingLoLvlConf01', 30.0)

logic.dcBus12OffConf01 = newLeadingEdgeDelayedConfirmation('dcBus12OffCConf01', 2.0)

logic.gen1FaultConf01 = newLeadingEdgeDelayedConfirmation('gen1FaultConf01', 2.0)
logic.gen1FaultConf02 = newLeadingEdgeDelayedConfirmation('gen1FaultConf02', 5.5)
logic.gen1FaultSRR01 = newSRlatchResetPriority('gen1FaultSRR01')

logic.gen2FaultConf01 = newLeadingEdgeDelayedConfirmation('gen2FaultConf01', 2.0)
logic.gen2FaultConf02 = newLeadingEdgeDelayedConfirmation('gen2FaultConf02', 5.5)
logic.gen2FaultSRR01 = newSRlatchResetPriority('gen2FaultSRR01')

logic.apuGenFaultConf01 = newLeadingEdgeDelayedConfirmation('apuGenFaultConf01', 2.0)
logic.apuGenFaultConf02 = newLeadingEdgeDelayedConfirmation('apuGenFaultConf02', 5.0)
logic.apuGenFaultSRR01 = newSRlatchResetPriority('apuGenFaultSRR01')

logic.toMemoConf01 = newLeadingEdgeDelayedConfirmation('toMemoConf01', 120.0)
logic.toMemoSRR01 = newSRlatchResetPriority('toMemoSRR01')

logic.ldgThresh01 = newThreshold('ldgThresh01', '<', 2000.0)
logic.ldgThresh02 = newThreshold('ldgThresh02', '<', 2000.0)
logic.ldgThresh03 = newThreshold('ldgThresh03', '>', 2200.0)
logic.ldgThresh04 = newThreshold('ldgThresh04', '>', 2200.0)
logic.ldgMemoConf01 = newLeadingEdgeDelayedConfirmation('ldgMemoConf01', 1.0)
logic.ldgMemoConf02 = newLeadingEdgeDelayedConfirmation('ldgMemoConf02', 10.0)
logic.ldgMemoSRS01 = newSRlatchResetPriority('ldgMemoSRR01')
logic.ldgMemoSRR02 = newSRlatchSetPriority('ldgMemoSRR02')

logic.irsAlignMRtrig01 = newLeadingEdgeTriggerReTrigger('irsAlignMRtrig01', 10.0)
logic.irsAlignMRtrig02 = newLeadingEdgeTriggerReTrigger('irsAlignMRtrig02', 10.0)
logic.irsAlignMRtrig03 = newLeadingEdgeTriggerReTrigger('irsAlignMRtrig03', 10.0)

logic.gndSplrArmedConf01 = newLeadingEdgeDelayedConfirmation('gndSplrArmedConf01', 2.0)

logic.rAvioPulse01 = newLeadingEdgePulse('rAvioPulse01')
logic.rAvioPulse02 = newLeadingEdgePulse('rAvioPulse02')
logic.rAvioMtrig01 = newLeadingEdgeTrigger('rAvioMtrig01', 0.5)

logic.rudTrimCfgSRS01 = newSRlatchSetPriority('rudTrimCfgSRS01')

logic.slatsCfgSRS01 = newSRlatchSetPriority('slatsCfgSRS01')

logic.flapsCfgSRS01 = newSRlatchSetPriority('flapsCfgSRS01')

logic.pitchCfgSRS01 = newSRlatchSetPriority('pitchCfgSRS01')

logic.spdBrkCfgSRS01 = newSRlatchSetPriority('spdBrkCfgSRS01')

logic.prkBrkCfgSRS01 = newSRlatchSetPriority('prkBrkCfgSRS01')

logic.eng1OilTmpThreshold01 = newThreshold('eng1OilTmpThreshold01', '<', 50.0)
logic.eng1OilTmpThreshold02 = newThreshold('eng1OilTmpThreshold02', '<', -10.0)
logic.eng1OilTmpConf01 = newLeadingEdgeDelayedConfirmation('eng1OilTmpConf01', 60.0)
logic.eng1OilTmpSRS01 = newSRlatchResetPriority('eng1OilTmpSRS01')

logic.eng2OilTmpThreshold01 = newThreshold('eng2OilTmpThreshold01', '<', 50.0)
logic.eng2OilTmpThreshold02 = newThreshold('eng2OilTmpThreshold02', '<', -10.0)
logic.eng2OilTmpConf01 = newLeadingEdgeDelayedConfirmation('eng2OilTmpConf01', 60.0)
logic.eng2OilTmpSRS01 = newSRlatchResetPriority('eng2OilTmpSRS01')

logic.cabRdyConf01 = newLeadingEdgeDelayedConfirmation('cabRdyConf01', 10.0)

logic.iceNotDetConf01 = newLeadingEdgeDelayedConfirmation('iceNotDetConf01', 130.0)
logic.iceNotDetConf02 = newLeadingEdgeDelayedConfirmation('iceNotDetConf02', 60.0)

logic.eng1RevUnlkConf01 = newFallingEdgeDelayedConfirmation('eng1RevUnlkConf01', 8.0)
logic.eng2RevUnlkConf01 = newFallingEdgeDelayedConfirmation('eng2RevUnlkConf01', 8.0)

logic.stdAltiDiscrepancyConf01 = newLeadingEdgeDelayedConfirmation('alti_discrepancy', 5.0)
logic.stdAltiDiscrepancyConf02 = newLeadingEdgeDelayedConfirmation('alti_discrepancy', 5.0)

logic.tcasFaultConf01 = newLeadingEdgeDelayedConfirmation('tcasFaultConf01', 3.0)

logic.aiVlvClsdFltConf01 = newLeadingEdgeDelayedConfirmation('aiVlvClsdFltConf01', 15.0)
logic.aiVlvClsdFltConf02 = newLeadingEdgeDelayedConfirmation('aiVlvClsdFltConf02', 25.0)
logic.aiVlvClsdFltConf03 = newLeadingEdgeDelayedConfirmation('aiVlvClsdFltConf03', 2.0)
logic.aiVlvClsdFltPulse01 = newLeadingEdgePulse('aiVlvClsdFltPulse01')
logic.aiVlvClsdFltsrS01 = newSRlatchSetPriority('aiVlvClsdFltsrS01')

logic.xbld_UE1FPBpulse01 = newLeadingEdgePulse('xbld_UE1FPBpulse01')
logic.xbleedVlvFltConf01 = newLeadingEdgeDelayedConfirmation('xbleedVlvFltConf01', 10.0)
logic.xbleedVlvFltConf02 = newFallingEdgeDelayedConfirmation('xbleedVlvFltConf02', 10.0)
logic.xbleedVlvFltConf03 = newFallingEdgeDelayedConfirmation('xbleedVlvFltConf03', 15.0)

logic.eng1NacVlvClsdConf01 = newLeadingEdgeDelayedConfirmation('eng1NacVlvClsdConf01', 10.0)

logic.eng2NacVlvClsdConf01 = newLeadingEdgeDelayedConfirmation('eng2NacVlvClsdConf01', 10.0)

logic.lrElevFltConf01 = newLeadingEdgeDelayedConfirmation('lrElevFltConf01', 0.3)

logic.eng1hungStrtPulse01 = newLeadingEdgePulse('eng1hungStrtPulse01')
logic.eng1hungStrtSRR01 = newSRlatchResetPriority('eng1hungStrtSRR01')

logic.eng2hungStrtPulse01 = newLeadingEdgePulse('eng2hungStrtPulse01')
logic.eng2hungStrtSRR01 = newSRlatchResetPriority('eng2hungStrtSRR01')





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
local function A333_fws_trigger_reset(warning_name)

    if A333_ewd_msg[warning_name].Monitor.video.IN == 0
        and A333_ewd_msg[warning_name].Monitor.video.INlast > 0
    then
        A333_ewd_msg[warning_name].Reset()
    end

end




function A333_ewd_msg.FLAP_LEVER_NOT_ZERO.WarningMonitor()

    local flNotZeroThresh01 = NALTI_1 >= 22000.0
    local flNotZeroThresh02 = NALTI_2 >= 22000.0
    local flNotZeroThresh03 = NALTI_3 >= 22000.0

    local a = NCAS_1_INV or NCAS_1_NCD
    local b = NCAS_2_INV or NCAS_2_NCD
    local c = NCAS_3_INV or NCAS_3_NCD
    local d = SS0F0_1_INV or SS0F0_1_NCD
    local e = SS0F0_2_INV or SS0F0_2_NCD
    local f = (not a) and flNotZeroThresh01
    local g = (not b) and flNotZeroThresh02
    local h = (not c) and flNotZeroThresh03
    local i = (not d) and (not SS00F00_1)
    local j = (not e) and (not SS00F00_2)
    local k = f or g or h
    local l = i or j
    local m = k and WSFLPLVRNOT0 and ZPH6 and l

	A333_ewd_msg.FLAP_LEVER_NOT_ZERO.Monitor.audio.IN = bool2num[m]
	A333_ewd_msg.FLAP_LEVER_NOT_ZERO.Monitor.video.IN = bool2num[m]

end




function A333_ewd_msg.OVER_SPEED_VFE1.WarningMonitor()	-- CONF FULL

	local a = SFLPSF and SSLTSG
	local b =  a and NASS184

	NVFE1 = b

	A333_ewd_msg.OVER_SPEED_VFE1.Monitor.audio.IN = bool2num[b]
	A333_ewd_msg.OVER_SPEED_VFE1.Monitor.video.IN = bool2num[b]

end




function A333_ewd_msg.OVER_SPEED_VFE2.WarningMonitor()		-- CONF 3

	local a = SFLPSD and NASS190 and (not NVFE1)

	NVFE2 = a

	A333_ewd_msg.OVER_SPEED_VFE2.Monitor.audio.IN = bool2num[a]
	A333_ewd_msg.OVER_SPEED_VFE2.Monitor.video.IN = bool2num[a]

end




function A333_ewd_msg.OVER_SPEED_VFE3.WarningMonitor()		-- CONF 2

    local a = (not SSLTIE) and SSLTVAL
    local b = SFLPSC and a
    local c = NASS200 and (not NVFE1) and (not NVFE2) and b

	NVFE3 = c

	A333_ewd_msg.OVER_SPEED_VFE3.Monitor.audio.IN = bool2num[c]
	A333_ewd_msg.OVER_SPEED_VFE3.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.OVER_SPEED_VFE4.WarningMonitor()	-- NEW LOGIC FOR A333 (CONF 1*)

    local a = SFLPSB and not SSLTIE and SSLTVAL
    local b = a and NASS209 and (not NVFE1) and (not NVFE2) and (not NVFE3)

	NVFE4 = b

	A333_ewd_msg.OVER_SPEED_VFE4.Monitor.audio.IN = bool2num[b]
	A333_ewd_msg.OVER_SPEED_VFE4.Monitor.video.IN = bool2num[b]

end




function A333_ewd_msg.OVER_SPEED_VFE5.WarningMonitor() 	-- A320 VFE4		(CONF 1+F)

    local a = SFLPVAL and SFLPSB
    local b = SSLTIE and a and (not NVFE1) and (not NVFE2) and (not NVFE3) and (not NVFE4) and NASS219

	NVFE5 = b

	A333_ewd_msg.OVER_SPEED_VFE5.Monitor.audio.IN = bool2num[b]
	A333_ewd_msg.OVER_SPEED_VFE5.Monitor.video.IN = bool2num[b]

end




function A333_ewd_msg.OVER_SPEED_VFE6.WarningMonitor()	 -- A320 VFE5		(CONF 1)

    local a = SSLTSA and SSLTIE
    local b = NASS244 and (not NVFE1) and (not NVFE2) and (not NVFE3) and (not NVFE4) and (not NVFE5) and a

	NVFE6 = b

	A333_ewd_msg.OVER_SPEED_VFE6.Monitor.audio.IN = bool2num[b]
	A333_ewd_msg.OVER_SPEED_VFE6.Monitor.video.IN = bool2num[b]

end




function A333_ewd_msg.OVER_SPEED_VLE.WarningMonitor()

    local a = GSAF or GDNC or GGUPENG or GLGNUP or GLGDNLKD
    local b = NASS250 and a

	WVLE = b

	A333_ewd_msg.OVER_SPEED_VLE.Monitor.audio.IN = bool2num[b]
	A333_ewd_msg.OVER_SPEED_VLE.Monitor.video.IN = bool2num[b]

end




function A333_ewd_msg.OVER_SPEED_VMO_MMO.WarningMonitor()

    local a = NVMOW_1_FT and NVMOW_2_FT
    local b = NVMOW_3_FT or a
    local c = NVMOW_3 and b
    local d = NVMOW_1_FT or NVMOW_2_FT or NVMOW_3_FT
    local e = NVMOW_1 or NVMOW_2 or c
    logic.vMOmMOMtrig01:update(d)
    local f = (not logic.vMOmMOMtrig01.OUT) and d
    local g = (not f) and e

	WVMOMMO = e

	A333_ewd_msg.OVER_SPEED_VMO_MMO.Monitor.audio.IN = bool2num[g]
	A333_ewd_msg.OVER_SPEED_VMO_MMO.Monitor.video.IN = bool2num[e]

end




function A333_ewd_msg.ENG_DUAL_FAULT.WarningMonitor()

	WWJENGSDF	= JENGSOUTR
	JENGSOUT	= JENGSOUTR

	A333_ewd_msg.ENG_DUAL_FAULT.Monitor.audio.IN = bool2num[JENGSOUTR]
	A333_ewd_msg.ENG_DUAL_FAULT.Monitor.video.IN = bool2num[JENGSOUTR]

end





function A333_ewd_msg.ENG_1_FIRE.WarningMonitor()

    logic.eng1FireConf01:update(UE1LBF)
    logic.eng1FireConf02:update(UE1LAF)
    local a = UE1FA and UE1FB
    local b = UE1FA and logic.eng1FireConf01.OUT
    local c = UE1FB and logic.eng1FireConf02.OUT
    local d = a or b or c
    local e = (not UE1FPBOUT) and d
    local f = e or (A333_engine_fire_test == 1)
    local g = d or (A333_engine_fire_test == 1)

	WWE1FI	= d
	UE1FIRE	= d

	A333_ewd_msg.ENG_1_FIRE.Monitor.audio.IN = bool2num[f]
	A333_ewd_msg.ENG_1_FIRE.Monitor.video.IN = bool2num[g]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_1_FIRE.Name)
	A333_ewd_msg.ENG_1_FIRE.Monitor.video.INlast = A333_ewd_msg.ENG_1_FIRE.Monitor.video.IN

end

function A333_ewd_msg.ENG_1_FIRE.Reset()
	logic.eng1FireConf01:resetTimer()
	logic.eng1FireConf02:resetTimer()
	A333_ewd_msg.ENG_1_FIRE.ActionReset()
end



function A333_ewd_msg.ENG_2_FIRE.WarningMonitor()

    logic.eng2FireConf01:update(UE2LBF)
    logic.eng2FireConf02:update(UE2LAF)
    local a = UE2FA and UE2FB
    local b = UE2FA and logic.eng2FireConf01.OUT
    local c = UE2FB and logic.eng2FireConf02.OUT
    local d = a or b or c
    local e = (not UE2FPBOUT) and d
    local f = e or (A333_engine_fire_test == 1)
    local g = d or (A333_engine_fire_test == 1)

	WWE2FI	= d
	UE2FIRE	= d

	A333_ewd_msg.ENG_2_FIRE.Monitor.audio.IN = bool2num[f]
	A333_ewd_msg.ENG_2_FIRE.Monitor.video.IN = bool2num[g]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_2_FIRE.Name)
	A333_ewd_msg.ENG_2_FIRE.Monitor.video.INlast = A333_ewd_msg.ENG_2_FIRE.Monitor.video.IN

end

function A333_ewd_msg.ENG_2_FIRE.Reset()
	logic.eng2FireConf01:resetTimer()
	logic.eng2FireConf02:resetTimer()
	A333_ewd_msg.ENG_2_FIRE.ActionReset()
end




function A333_ewd_msg.APU_FIRE.WarningMonitor()

    logic.apuFireConf01:update(UAPULBF)
    logic.apuFireConf02:update(UAPULAF)
    local a = UAPUFA and UAPUFB
    local b = UAPUFA and logic.apuFireConf01.OUT
    local c = UAPUFB and logic.apuFireConf02.OUT
    local d = a or b or c
    local e = (not UAPUFPBOUT) and d
    local f = e or (A333_apu_fire_test == 1)
    local g = d or (A333_apu_fire_test == 1)

	WWAPUFI		= d
	UAPUFIRE	= d

	A333_ewd_msg.APU_FIRE.Monitor.audio.IN = bool2num[f]
	A333_ewd_msg.APU_FIRE.Monitor.video.IN = bool2num[g]
	A333_fws_trigger_reset(A333_ewd_msg.APU_FIRE.Name)
	A333_ewd_msg.APU_FIRE.Monitor.video.INlast = A333_ewd_msg.APU_FIRE.Monitor.video.IN

end

function A333_ewd_msg.APU_FIRE.Reset()
	logic.apuFireConf01:resetTimer()
	logic.apuFireConf02:resetTimer()
	A333_ewd_msg.APU_FIRE.ActionReset()
end




function A333_ewd_msg.SLATS_CONFIG.WarningMonitor()

    local a = ZPH9 or ZPH1 or ZPH2
    local b = SSLTID or SSLTSG
    local c = ZPH3 or ZPH4
    local d = WTOCT_2 and a and b
    local e = b and c
    local f = (not b) or ZPH5
    logic.slatsCfgSRS01:update(e, f)
    local g = b and a
    local h = d or e
    local i = d or logic.slatsCfgSRS01.Q

	SSLTNTO = g

	A333_ewd_msg.SLATS_CONFIG.Monitor.audio.IN = bool2num[h]
	A333_ewd_msg.SLATS_CONFIG.Monitor.video.IN = bool2num[i]
	A333_fws_trigger_reset(A333_ewd_msg.SLATS_CONFIG.Name)
	A333_ewd_msg.SLATS_CONFIG.Monitor.video.INlast = A333_ewd_msg.SLATS_CONFIG.Monitor.video.IN

end

function A333_ewd_msg.SLATS_CONFIG.Reset()
	logic.slatsCfgSRS01:reset()
end




function A333_ewd_msg.FLAPS_CONFIG.WarningMonitor()

    local a = ZPH1 or ZPH2 or ZPH9
    local b = ZPH4 or ZPH3
    local c = SFLPSF or SFLPIA
    local d = SFLPSF or SFLPIA
    local e = WTOCT_2 and a and c
    local f = b and d
    local g = (not d) or ZPH5
    logic.flapsCfgSRS01:update(f, g)
    local h = d and a
    local i = e or f
    local j = e or logic.flapsCfgSRS01.Q

	SFLPNTO = h

	A333_ewd_msg.FLAPS_CONFIG.Monitor.audio.IN = bool2num[i]
	A333_ewd_msg.FLAPS_CONFIG.Monitor.video.IN = bool2num[j]
	A333_fws_trigger_reset(A333_ewd_msg.FLAPS_CONFIG.Name)
	A333_ewd_msg.FLAPS_CONFIG.Monitor.video.INlast = A333_ewd_msg.FLAPS_CONFIG.Monitor.video.IN

end

function A333_ewd_msg.FLAPS_CONFIG.Reset()
	logic.flapsCfgSRS01:reset()
end




function A333_ewd_msg.SPD_BRK_CONFIG.WarningMonitor()

    local a = ZPH9 or ZPH1 or ZPH2
    local b = SSPBR_1 or SSPBR_2
    local c = ZPH3 or ZPH4
    local d = WTOCT_2 and a and b
    local e = b and c
    local f = (not b) or ZPH5
    logic.spdBrkCfgSRS01:update(e, f)
    local g = b and a
    local h = d or e
    local i = d or logic.spdBrkCfgSRS01.Q

	SSBNTO = g

	A333_ewd_msg.SPD_BRK_CONFIG.Monitor.audio.IN = bool2num[h]
	A333_ewd_msg.SPD_BRK_CONFIG.Monitor.video.IN = bool2num[i]
	A333_fws_trigger_reset(A333_ewd_msg.SPD_BRK_CONFIG.Name)
	A333_ewd_msg.SPD_BRK_CONFIG.Monitor.video.INlast = A333_ewd_msg.SPD_BRK_CONFIG.Monitor.video.IN

end

function A333_ewd_msg.SPD_BRK_CONFIG.Reset()
	logic.spdBrkCfgSRS01:reset()
end




function A333_ewd_msg.PITCH_TRIM_CONFIG.WarningMonitor()

    local a = ZPH9 or ZPH1 or ZPH2
    local b = SPCT1A330 or SPCT2A330
    local c = ZPH3 or ZPH4
    local g = WTOCT_2 and a and b
    local h = b and c
    local i = (not b) or ZPH5
    logic.pitchCfgSRS01:update(h, i)
    local j = b and a
    local k = g or h
    local l = g or logic.pitchCfgSRS01.Q

	SPTNTO = j

	A333_ewd_msg.PITCH_TRIM_CONFIG.Monitor.audio.IN = bool2num[k]
	A333_ewd_msg.PITCH_TRIM_CONFIG.Monitor.video.IN = bool2num[l]
	A333_fws_trigger_reset(A333_ewd_msg.PITCH_TRIM_CONFIG.Name)
	A333_ewd_msg.PITCH_TRIM_CONFIG.Monitor.video.INlast = A333_ewd_msg.PITCH_TRIM_CONFIG.Monitor.video.IN

end

function A333_ewd_msg.PITCH_TRIM_CONFIG.Reset()
	logic.pitchCfgSRS01:reset()
end




function A333_ewd_msg.RUDDER_TRIM_CONFIG.WarningMonitor()

    local a = ZPH9 or ZPH1 or ZPH2
    local b = ZPH3 or ZPH4
    local c = WTOCT_2 and a and SRUDTC
    local d = SRUDTC and b
    local e = (not SRUDTC) or ZPH5
    logic.rudTrimCfgSRS01:update(d, e)
    local f = SRUDTC and a
    local g = c or d
    local h = c or logic.rudTrimCfgSRS01.Q

	SRUDTNTO = f

	A333_ewd_msg.RUDDER_TRIM_CONFIG.Monitor.audio.IN = bool2num[g]
	A333_ewd_msg.RUDDER_TRIM_CONFIG.Monitor.video.IN = bool2num[h]
	A333_fws_trigger_reset(A333_ewd_msg.RUDDER_TRIM_CONFIG.Name)
	A333_ewd_msg.RUDDER_TRIM_CONFIG.Monitor.video.INlast = A333_ewd_msg.RUDDER_TRIM_CONFIG.Monitor.video.IN

end

function A333_ewd_msg.RUDDER_TRIM_CONFIG.Reset()
	logic.rudTrimCfgSRS01:reset()
end




function A333_ewd_msg.PARK_BRK_ON_CONFIG.WarningMonitor()

    local a = ZPH3 or ZPH4
    local b = a and GPBRKON
    local c = not GPBRKON or ZPH5
    logic.prkBrkCfgSRS01:update(b, c)

	A333_ewd_msg.PARK_BRK_ON_CONFIG.Monitor.audio.IN = bool2num[b]
	A333_ewd_msg.PARK_BRK_ON_CONFIG.Monitor.video.IN = bool2num[logic.prkBrkCfgSRS01.Q]
	A333_fws_trigger_reset(A333_ewd_msg.PARK_BRK_ON_CONFIG.Name)
	A333_ewd_msg.PARK_BRK_ON_CONFIG.Monitor.video.INlast = A333_ewd_msg.PARK_BRK_ON_CONFIG.Monitor.video.IN

end

function A333_ewd_msg.PARK_BRK_ON_CONFIG.Reset()
	logic.prkBrkCfgSRS01:reset()
end




function A333_ewd_msg.EXCESS_CAB_ALT.WarningMonitor()

    local a = PEXCA_1 or PEXCA_2
    local b = PEXCA_3 and (not ZGND) and PAS12F
    local c = a or bp
    logic.excessCabAltConf01:update(c)
	WWCABPR = logic.excessCabAltConf01.OUT

	A333_ewd_msg.EXCESS_CAB_ALT.Monitor.audio.IN = bool2num[logic.excessCabAltConf01.OUT]
	A333_ewd_msg.EXCESS_CAB_ALT.Monitor.video.IN = bool2num[logic.excessCabAltConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.EXCESS_CAB_ALT.Name)
	A333_ewd_msg.EXCESS_CAB_ALT.Monitor.video.INlast = A333_ewd_msg.EXCESS_CAB_ALT.Monitor.video.IN

end

function A333_ewd_msg.EXCESS_CAB_ALT.Reset()
	logic.excessCabAltConf01:resetTimer()
end




function A333_ewd_msg.ENG_1_OIL_LO_PR.WarningMonitor()

	local a = JR1OLP and (not JR1NORUN) and JTML1ON and WRRT
	logic.eng1oilLoPrFConf01:update(a)

	A333_ewd_msg.ENG_1_OIL_LO_PR.Monitor.audio.IN = bool2num[logic.eng1oilLoPrFConf01.OUT]
	A333_ewd_msg.ENG_1_OIL_LO_PR.Monitor.video.IN = bool2num[logic.eng1oilLoPrFConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_1_OIL_LO_PR.Name)
	A333_ewd_msg.ENG_1_OIL_LO_PR.Monitor.video.INlast = A333_ewd_msg.ENG_1_OIL_LO_PR.Monitor.video.IN

end

function A333_ewd_msg.ENG_1_OIL_LO_PR.Reset()
	logic.eng1oilLoPrFConf01:resetTimer()
end




function A333_ewd_msg.ENG_2_OIL_LO_PR.WarningMonitor()

	local a = JR2OLP and (not JR2NORUN) and JTML2ON and WRRT
	logic.eng2oilLoPrFConf01:update(a)

	A333_ewd_msg.ENG_2_OIL_LO_PR.Monitor.audio.IN = bool2num[logic.eng2oilLoPrFConf01.OUT]
	A333_ewd_msg.ENG_2_OIL_LO_PR.Monitor.video.IN = bool2num[logic.eng2oilLoPrFConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_2_OIL_LO_PR.Name)
	A333_ewd_msg.ENG_2_OIL_LO_PR.Monitor.video.INlast = A333_ewd_msg.ENG_2_OIL_LO_PR.Monitor.video.IN

end

function A333_ewd_msg.ENG_2_OIL_LO_PR.Reset()
	logic.eng2oilLoPrFConf01:resetTimer()
end




function A333_ewd_msg.L_R_ELEV_FAULT.WarningMonitor()

    local a = SLELVBA_1_VAL and (not SLELVBA_1)
    local b = SLELVBA_2_VAL and (not SLELVBA_2)
    local c = SLELVGA_1_VAL and (not SLELVGA_1)
    local d = SLELVGA_2_VAL and (not SLELVGA_2)
    local e = SRELVBA_1_VAL and (not SRELVBA_1)
    local f = SRELVBA_2_VAL and (not SRELVBA_2)
    local g = SRELVYA_1_VAL and (not SRELVYA_1)
    local h = SRELVYA_2_VAL and (not SRELVYA_2)
    local i = a or b
    local j = c or d
    local k = e or f
    local l = g or h
    local m =ZPH1 or ZPH10
    local n = i and j and k and l and m
    logic.lrElevFltConf01:update(n)

	SLRELVFT = n
	WWLRELVFT = n

	A333_ewd_msg.L_R_ELEV_FAULT.Monitor.audio.IN = bool2num[logic.lrElevFltConf01.OUT]
	A333_ewd_msg.L_R_ELEV_FAULT.Monitor.video.IN = bool2num[logic.lrElevFltConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.L_R_ELEV_FAULT.Name)
	A333_ewd_msg.L_R_ELEV_FAULT.Monitor.video.INlast = A333_ewd_msg.L_R_ELEV_FAULT.Monitor.video.IN

end

function A333_ewd_msg.L_R_ELEV_FAULT.Reset()
	logic.lrElevFltConf01:resetTimer()
end




function A333_ewd_msg.GEAR_NOT_DOWN.WarningMonitor()

    logic.lgNotDnAltThreshold01:update(NRADH_1)
    logic.lgNotDnAltThreshold01:update(NRADH_2)
    local a = (not NRADH_1_NCD) and logic.lgNotDnAltThreshold01.out and (not NRADH_1_INV)
    local b = (not NRADH_2_INV) and logic.lgNotDnAltThreshold02.out and (not NRADH_2_NCD)
    local c = a or b
    local d = NRADH_1_NCD or NRADH_1_INV
    local e = NRADH_2_NCD or NRADH_2_INV
    local f = NRADH_2_INV or  NRADH_1_INV
    local g = d and e
    local h = SFLPSD and (not SFLPSF)
    local i = GLGCIU1FT and GLGCIU2FT
    local j = f and h
    local k = SFLPSF and g
    local l = not GLGDNLKD and (not i)
    local m = not ZR1O2TOPWR and JRN1AP
    local n = j or k
    local o = SFLPDSLTC and (not ZR1O2TOPWR) and c and l
    logic.lgNotDnPulse01:update(o)
    local p = l and (not ZPH5) and ZPH6 and n
    logic.lgNotDnPulse02:update(p)
    local q = ZPH6 and (not g)
    local r = c and m and l
    local s = q or ZPH4 or ZPH5
    local t = o or p
    local u = (not logic.lgNotDnPulse01.OUT) and t and (not logic.lgNotDnPulse02.OUT)
    local v = u or r
    local w = v and not s

	GLGNDNE		= u
	WBRACSW		= w
	WRACSW_S	= w
	GLGNDOWN	= r

	A333_ewd_msg.GEAR_NOT_DOWN.Monitor.audio.IN = bool2num[u]
	A333_ewd_msg.GEAR_NOT_DOWN.Monitor.video.IN = bool2num[u]

end




function A333_ewd_msg.GEAR_NOT_DOWNLOCKED.WarningMonitor()

	logic.lgNotDnLckConf01:update(GLGNLDSD)
	logic.lgNotDnLckSRR01:update(logic.lgNotDnLckConf01.OUT, GLGDNLKD)

	WWGNDNLD	= logic.lgNotDnLckSRR01.Q
	GGNDNLD		= logic.lgNotDnLckSRR01.Q

	A333_ewd_msg.GEAR_NOT_DOWNLOCKED.Monitor.audio.IN = bool2num[logic.lgNotDnLckSRR01.Q]
	A333_ewd_msg.GEAR_NOT_DOWNLOCKED.Monitor.video.IN = bool2num[logic.lgNotDnLckSRR01.Q]
	A333_fws_trigger_reset(A333_ewd_msg.GEAR_NOT_DOWNLOCKED.Name)
	A333_ewd_msg.GEAR_NOT_DOWNLOCKED.Monitor.video.INlast = A333_ewd_msg.GEAR_NOT_DOWNLOCKED.Monitor.video.IN

end

function A333_ewd_msg.GEAR_NOT_DOWNLOCKED.Reset()
	logic.lgNotDnLckConf01:resetTimer()
	logic.lgNotDnLckSRR01:reset()
	A333_ewd_msg.GEAR_NOT_DOWNLOCKED.ActionReset()
end




function A333_ewd_msg.AP_OFF_UNVOLUNTARY.WarningMonitor()

    local a = ZPH1 and HBSLP and HYSLP and HGSLP
    local b = KID1APE or KID2APE
    logic.APoffUnvPulse03:update(b)
    local c = KAP1EC_1 and KAP1EM_1
    local d = KAP2EC_2 and KAP2EM_2
    local e = WCMWC or WFOMWC
    local ee = c or d
    local f = e and KCCE
    local g = (not ee) and f
    local h = logic.APoffUnvPulse03.OUT and (not ee)
    logic.APoffUnvPulse01:update(ZPH1)
    logic.APoffUnvPulse04:update(ee)
    local i = logic.APoffUnvPulse04.OUT or logic.APoffUnvPulse01.OUT
    logic.APoffUnvMtrig01:update(KID1APE)
    logic.APoffUnvMtrig02:update(KID2APE)
    local j = logic.APoffUnvMtrig01.OUT or logic.APoffUnvMtrig02.OUT
    logic.APoffUnvPulse02:update(ee)
    local k = (not a) and not j and logic.APoffUnvPulse02.OUT
    logic.APoffUnvPulse05:update(g)
    logic.APoffUnvSRr01:update(k, i)
    local l = h or logic.APoffUnvPulse05.OUT
    logic.APoffUnvPulse06:update(logic.APoffUnvSRr01.Q)
    logic.APoffUnvMtrig03:update(logic.APoffUnvPulse06.OUT)
    local m = (not logic.APoffUnvMtrig03.OUT) and l
    local n = i or m
    local o = WAPOT or logic.APoffUnvSRr01.Q
    logic.APoffUnvSRr02:update(logic.APoffUnvPulse06.OUT, n)

	WWAPOFW = o
	KAPUNVOFF = logic.APoffUnvSRr01.Q
	KAPOR = n
	KAPMW = logic.APoffUnvPulse05.OUT
	WWKCCE = KCCE

	A333_ewd_msg.AP_OFF_UNVOLUNTARY.Monitor.audio.IN = bool2num[logic.APoffUnvSRr02.Q]
	A333_ewd_msg.AP_OFF_UNVOLUNTARY.Monitor.video.IN = bool2num[logic.APoffUnvSRr01.Q]
	A333_fws_trigger_reset(A333_ewd_msg.AP_OFF_UNVOLUNTARY.Name)
	A333_ewd_msg.AP_OFF_UNVOLUNTARY.Monitor.video.INlast = A333_ewd_msg.AP_OFF_UNVOLUNTARY.Monitor.video.IN

end

function A333_ewd_msg.AP_OFF_UNVOLUNTARY.Reset()
	logic.APoffUnvSRr01:reset()
	logic.APoffUnvSRr02:reset()
end




function A333_ewd_msg.AP_OFF_MW_UNVOLUNTARY.WarningMonitor()

	logic.APoffMWpulse01:update(KAPUNVOFF)
	logic.APoffMWpulse02:update(ZPH1)
	local a = KAPOR or KAPMW or logic.APoffMWpulse02.OUT
	logic.APoffMWSRr01:update(logic.APoffMWpulse01.OUT, a)

	if a then
		if simDR_master_warning_anunn == 1 then
			simCMD_master_warn_canx:once()
		end
	end

end

function A333_ewd_msg.AP_OFF_MW_UNVOLUNTARY.Reset()
	logic.APoffMWSRr01:reset()
end




function AP_OFF_MW_VOLUNTARY_OFF()

	if not KAPOMW then
		if simDR_master_warning_anunn == 1 then
			simCMD_master_warn_canx:once()
		end
	end
end

function A333_ewd_msg.AP_OFF_MW_VOLUNTARY.WarningMonitor()

	if KAPOMW then
		if not(is_timer_scheduled(AP_OFF_MW_VOLUNTARY_OFF)) then
			run_after_time(AP_OFF_MW_VOLUNTARY_OFF, 3.1)
		end
	end

end




function A333_ewd_msg.CAVALRY_CHARGE_VOLUNTARY_DISC.WarningMonitor()

	A333_ewd_msg.CAVALRY_CHARGE_VOLUNTARY_DISC.Monitor.audio.IN = bool2num[KAPOA]

	--see ecam_fws710 for control

end




function A333_ewd_msg.AP_OFF_TEXT.WarningMonitor()

	A333_ewd_msg.AP_OFF_TEXT.Monitor.video.IN = bool2num[WAPOT]
	WWAPOV = WAPOT

end




function A333_ewd_msg.FWD_CARGO_SMOKE.WarningMonitor()

    local a = USFLC_1 or USFLC_2
    local b = UFCSDI_1 or UFCSDI_2
    local c = a and b
    local d = c or (A333_cargo_fire_test == 1)

	UFCSDI = b

	A333_ewd_msg.FWD_CARGO_SMOKE.Monitor.audio.IN = bool2num[d]
	A333_ewd_msg.FWD_CARGO_SMOKE.Monitor.video.IN = bool2num[d]

end

function A333_ewd_msg.FWD_CARGO_SMOKE.Reset()
	A333_ewd_msg.FWD_CARGO_SMOKE.ActionReset()
end




function A333_ewd_msg.AFT_CARGO_SMOKE.WarningMonitor()

    local a = USALC_1 or USALC_2
    local b = UACSDI_1 or UACSDI_2
    local c = a and b
    local d = c or (A333_cargo_fire_test == 1)

	UACSDI = b

	A333_ewd_msg.AFT_CARGO_SMOKE.Monitor.audio.IN = bool2num[d]
	A333_ewd_msg.AFT_CARGO_SMOKE.Monitor.video.IN = bool2num[d]

end

function A333_ewd_msg.AFT_CARGO_SMOKE.Reset()
    A333_ewd_msg.AFT_CARGO_SMOKE.ActionReset()
end




function A333_ewd_msg.ELEC_EMER_CONFIG.WarningMonitor()

    local a = EGN1PBOF or ENG1INOP
    local b = EGN2PBOF or ENG2INOP
    local c = EAPUGNPBOF or ENG3INOP or not(QAVAIL)
    local d = EAC1OF and EAC2OF
    local e = (not EEPWRCON) and a and b and c
    local f = d or e
    local g = (not WENA330EMERC) and (not USKD) and f and (not JENGSOUT) and WA330

    EEMER = f

    A333DR_elec_emer_config = bool2num[EEMER]

	A333_ewd_msg.ELEC_EMER_CONFIG.Monitor.audio.IN = bool2num[g]
	A333_ewd_msg.ELEC_EMER_CONFIG.Monitor.video.IN = bool2num[g]

end




function A333_ewd_msg.HYD_BY_SYS_LO_PR.WarningMonitor()

	local a = HBSYSLP and HYSYSLP

	HBYLP = a

	A333_ewd_msg.HYD_BY_SYS_LO_PR.Monitor.audio.IN = bool2num[a]
	A333_ewd_msg.HYD_BY_SYS_LO_PR.Monitor.video.IN = bool2num[a]

end




function A333_ewd_msg.HYD_GB_SYS_LO_PR.WarningMonitor()

	local a = HGSYSLP and HBSYSLP

	HBGLP = a

	A333_ewd_msg.HYD_GB_SYS_LO_PR.Monitor.audio.IN = bool2num[a]
	A333_ewd_msg.HYD_GB_SYS_LO_PR.Monitor.video.IN = bool2num[a]

end




function A333_ewd_msg.HYD_GY_SYS_LO_PR.WarningMonitor()

	local a = HGSYSLP and HYSYSLP

	HYGLP = a

	A333_ewd_msg.HYD_GY_SYS_LO_PR.Monitor.audio.IN = bool2num[a]
	A333_ewd_msg.HYD_GY_SYS_LO_PR.Monitor.video.IN = bool2num[a]

end




-- One reverser cowl not locked in stowed position, with no deploy order.
function A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.WarningMonitor()

    local aa = GELLGCOMPR and EEMER
    local bb = ZGND or aa
    ZGNDRU = bb

    local a = JR1IDLE_1A or JR1IDLE_1B
    local b = GW1SGT_1 or GW1SGT_2
    local c = a or (not ZPH4)
    local d = ZPH7 and b
    logic.eng1RevUnlkConf01:update(JR1TLREV)
    local e = logic.eng1RevUnlkConf01.OUT and bb
    local f = c and WRRT and JR1RUSTWD and (not d) and (not ZPH8) and (not e)
    local g = a and f

	JR1REVUNLK = g
	JR1REVULK = f

	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.Monitor.audio.IN = bool2num[f]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.Monitor.video.IN = bool2num[f]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.Name)
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.Monitor.video.INlast = A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.Monitor.video.IN

	if JR1TLA_1A < 0.0 and is_timer_scheduled(logic.eng1RevUnlkConf01.timerFunc) then -- TL in reverse and timer running
		logic.eng1RevUnlkConf01:resetTimer()
	end

end

function A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.Reset()
	logic.eng1RevUnlkConf01:resetTimer()
end




function A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.WarningMonitor()

    local a = JR2IDLE_2A or JR2IDLE_2B
    local b = GW1SGT_1 or GW1SGT_2
    local c = a or (not ZPH4)
    local d = ZPH7 and b
    logic.eng2RevUnlkConf01:update(JR2TLREV)
    local e = logic.eng2RevUnlkConf01.OUT and ZGNDRU
    local f = c and WRRT and JR2RUSTWD and (not d) and (not ZPH8) and (not e)
    local g = a and f

	JR2REVUNLK = g
	JR2REVULK = f

	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.Monitor.audio.IN = bool2num[f]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.Monitor.video.IN = bool2num[f]

    A333_fws_trigger_reset(A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.Name)
    A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.Monitor.video.INlast = A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.Monitor.video.IN

    if JR2TLA_2A < 0.0 and is_timer_scheduled(logic.eng2RevUnlkConf01.timerFunc) then -- TL in reverse and timer running
        logic.eng2RevUnlkConf01:resetTimer()
    end

end

function A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.Reset()
	logic.eng2RevUnlkConf01:resetTimer()
end




function A333_ewd_msg.ENG_1_FAIL.WarningMonitor()

    local a = JR1AIDLE_1B or JR1AIDLE_1A
    logic.eng1failConf01:update(a)
    local b = JR1AIDLE_1A_INV and JR1AIDLE_1B_INV
    local c = (not JR1AIDLE_1A) and (not JR1AIDLE_1B)
    local d = (not JML1ON) or UE1FPBOUT
    logic.eng1failSRR01:update(logic.eng1failConf01.OUT, d)
    local e = a or JENGSOUT
    local f = JML1ON and (not UE1FPBOUT) and WRRT and (not b) and c and logic.eng1failSRR01.Q
    logic.eng1failSRR02:update(f, e)

	JR1FAIL	= logic.eng1failSRR02.Q

	A333_ewd_msg.ENG_1_FAIL.Monitor.audio.IN = bool2num[logic.eng1failSRR02.Q]
	A333_ewd_msg.ENG_1_FAIL.Monitor.video.IN = bool2num[logic.eng1failSRR02.Q]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_1_FAIL.Name)
	A333_ewd_msg.ENG_1_FAIL.Monitor.video.INlast = A333_ewd_msg.ENG_1_FAIL.Monitor.video.IN

end

function A333_ewd_msg.ENG_1_FAIL.Reset()
	logic.eng1failConf01:resetTimer()
	logic.eng1failSRR01:reset()
	logic.eng1failSRR02:reset()
	A333_ewd_msg.ENG_1_FAIL.ActionReset()

end




function A333_ewd_msg.ENG_1_OIL_HI_TEMP.WarningMonitor()

    logic.eng1oilHiTempConf01:update(JR1OTAD)
    local a = (not JML1ON) or ZPH10 or ZPH1
    local b = logic.eng1oilHiTempConf01.OUT or JR1OOT
    logic.eng1oilHiTempConf02:update(b)
    logic.eng1oilHiTempSRR01:update(logic.eng1oilHiTempConf02.OUT, a)

	WE1OHT	= logic.eng1oilHiTempConf02.OUT

	A333_ewd_msg.ENG_1_OIL_HI_TEMP.Monitor.audio.IN = bool2num[logic.eng1oilHiTempSRR01.Q]
	A333_ewd_msg.ENG_1_OIL_HI_TEMP.Monitor.video.IN = bool2num[logic.eng1oilHiTempSRR01.Q]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_1_OIL_HI_TEMP.Name)
	A333_ewd_msg.ENG_1_OIL_HI_TEMP.Monitor.video.INlast = A333_ewd_msg.ENG_1_OIL_HI_TEMP.Monitor.video.IN

end

function A333_ewd_msg.ENG_1_OIL_HI_TEMP.Reset()
	logic.eng1oilHiTempConf01:resetTimer()
	logic.eng1oilHiTempConf02:resetTimer()
	logic.eng1oilHiTempSRR01:reset()
end



function A333_ewd_msg.ENG_1_SHUT_DOWN.WarningMonitor()

    local a = ZPH1 or ZPH2 or ZPH9 or ZPH10
    local b = a or (not ZGND)
    local c = (not JML1ON) and JML1OFF and (not a)
    local d = b and UE1FPBOUT
    local e = c or d
    local f = e and (not JENGSOUT) and WRRT
    local g = (not JR1FAIL) and f
    local h = f or JR1FAIL

	JR1SD	= f
	JR1OUT	= h

	A333_ewd_msg.ENG_1_SHUT_DOWN.Monitor.audio.IN = bool2num[g]
	A333_ewd_msg.ENG_1_SHUT_DOWN.Monitor.video.IN = bool2num[f]

end




function A333_ewd_msg.ENG_2_FAIL.WarningMonitor()

    local a = R2AIDLE_2B or JR2AIDLE_2A
    logic.eng2failConf01:update(a)
    local b = JR2AIDLE_2A_INV and JR2AIDLE_2B_INV
    local c = (not JR2AIDLE_2A) and (not JR2AIDLE_2B)
    local d = (not JML2ON) or UE2FPBOUT
    logic.eng2failSRR01:update(logic.eng2failConf01.OUT, d)
    local e = a or JENGSOUT
    local f = JML2ON and (not UE2FPBOUT) and WRRT and (not b) and c and logic.eng2failSRR01.Q
    logic.eng2failSRR02:update(f, e)

	JR2FAIL	= logic.eng2failSRR02.Q

	A333_ewd_msg.ENG_2_FAIL.Monitor.audio.IN = bool2num[logic.eng2failSRR02.Q]
	A333_ewd_msg.ENG_2_FAIL.Monitor.video.IN = bool2num[logic.eng2failSRR02.Q]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_2_FAIL.Name)
	A333_ewd_msg.ENG_2_FAIL.Monitor.video.INlast = A333_ewd_msg.ENG_2_FAIL.Monitor.video.IN

end

function A333_ewd_msg.ENG_2_FAIL.Reset()
	logic.eng2failConf01:resetTimer()
	logic.eng2failSRR01:reset()
	logic.eng2failSRR02:reset()
	A333_ewd_msg.ENG_2_FAIL.ActionReset()
end




function A333_ewd_msg.ENG_2_OIL_HI_TEMP.WarningMonitor()

    logic.eng2oilHiTempConf01:update(JRp2OTAD)
    local a = (not JML2ON) or ZPH10 or ZPH1
    local b = logic.eng2oilHiTempConf01.OUT or JR2OOT
    logic.eng2oilHiTempConf02:update(b)
    logic.eng2oilHiTempSRR01:update(logic.eng2oilHiTempConf02.OUT, a)

	WE2OHT	= logic.eng2oilHiTempConf02.OUT

	A333_ewd_msg.ENG_2_OIL_HI_TEMP.Monitor.audio.IN = bool2num[logic.eng2oilHiTempSRR01.Q]
	A333_ewd_msg.ENG_2_OIL_HI_TEMP.Monitor.video.IN = bool2num[logic.eng2oilHiTempSRR01.Q]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_2_OIL_HI_TEMP.Name)
	A333_ewd_msg.ENG_2_OIL_HI_TEMP.Monitor.video.INlast = A333_ewd_msg.ENG_2_OIL_HI_TEMP.Monitor.video.IN

end

function A333_ewd_msg.ENG_2_OIL_HI_TEMP.Reset()
	logic.eng2oilHiTempConf01:resetTimer()
	logic.eng2oilHiTempConf02:resetTimer()
	logic.eng2oilHiTempSRR01:reset()
end




function A333_ewd_msg.ENG_2_SHUT_DOWN.WarningMonitor()

    local a = ZPH1 or ZPH2 or ZPH9 or ZPH10
    local b = a or (not ZGND)
    local c = (not JML2ON) and JML2OFF and (not a)
    local d = b and UE2FPBOUT
    local e = c or d
    local f = e and (not JENGSOUT) and WRRT
    local g = (not JR2FAIL) and f
    local h = f or JR1FAIL

	JR2SD	= f
	JR2OUT	= h

	A333_ewd_msg.ENG_2_SHUT_DOWN.Monitor.audio.IN = bool2num[g]
	A333_ewd_msg.ENG_2_SHUT_DOWN.Monitor.video.IN = bool2num[f]

end




function A333_ewd_msg.ENG_1_HUNG_START.WarningMonitor()

    logic.eng1hungStrtPulse01:update(JML1ON)
    local a = JR1HGST_1A and JR1CHCTL_1A
    local b = JR1HGST_1B and JR1CHCTL_1B
    local c = JR1MANST_1A or JR1MANST_1B or JR1AUTOST_1A or JR1AUTOST_1B
    local d = JR1AIDLE_1A or JR1AIDLE_1B
    local e = a or b
    local f = d or logic.eng1hungStrtPulse01.OUT
    local g = WRRT and e
    logic.eng1hungStrtSRR01:update(g, f)
    local h = c and WRRT

	JR1START = h

	A333_ewd_msg.ENG_1_HUNG_START.Monitor.audio.IN = bool2num[logic.eng1hungStrtSRR01.Q]
	A333_ewd_msg.ENG_1_HUNG_START.Monitor.video.IN = bool2num[logic.eng1hungStrtSRR01.Q]

end




function A333_ewd_msg.ENG_2_HUNG_START.WarningMonitor()

    logic.eng1hungStrtPulse01:update(JML2ON)
    local a = JR2HGST_2A and JR2CHCTL_2A
    local b = JR2HGST_1B and JR2CHCTL_1B
    local c = JR2MANST_2A or JR2MANST_2B or JR2AUTOST_2A or JR2AUTOST_2B
    local d = JR2AIDLE_2A or JR2AIDLE_2B
    local e = a or b
    local f = d or logic.eng2hungStrtPulse01.OUT
    local g = WRRT and e
    logic.eng2hungStrtSRR01:update(g, f)
    local h = c and WRRT

	JR2START = h

	A333_ewd_msg.ENG_2_HUNG_START.Monitor.audio.IN = bool2num[logic.eng2hungStrtSRR01.Q]
	A333_ewd_msg.ENG_2_HUNG_START.Monitor.video.IN = bool2num[logic.eng2hungStrtSRR01.Q]

end




function A333_ewd_msg.ENG_1_OIL_LO_TEMP.WarningMonitor()

    logic.eng1OilTmpThreshold01:update(JR1OT)
    logic.eng1OilTmpThreshold02:update(JR1OT)
    local a = JR1OT_INV or JR1OT_NCD
    local b = WTOCT_2 and ZPH2
    local c = logic.eng1OilTmpThreshold01.out and (not a)
    local d = logic.eng1OilTmpThreshold02.out and ZPH2 and (not a)
    logic.eng1OilTmpConf01:update(d)
    local e = b and c
    local f = ZPH1 or ZPH6 or ZPH9 or (not c)
    logic.eng1OilTmpSRS01:update(e, f)
    local g = ZPH3 and c
    local h = logic.eng1OilTmpSRS01.Q or g or logic.eng1OilTmpConf01.OUT
    local i = h and (not JR1NORUN) and WRRT

	A333_ewd_msg.ENG_1_OIL_LO_TEMP.Monitor.audio.IN = bool2num[i]
	A333_ewd_msg.ENG_1_OIL_LO_TEMP.Monitor.video.IN = bool2num[i]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_1_OIL_LO_TEMP.Name)
	A333_ewd_msg.ENG_1_OIL_LO_TEMP.Monitor.video.INlast = A333_ewd_msg.ENG_1_OIL_LO_TEMP.Monitor.video.IN

end

function A333_ewd_msg.ENG_1_OIL_LO_TEMP.Reset()
	logic.eng1OilTmpConf01:resetTimer()
	logic.eng1OilTmpSRS01:reset()
end




function A333_ewd_msg.ENG_2_OIL_LO_TEMP.WarningMonitor()

    logic.eng2OilTmpThreshold01:update(JR1OT)
    logic.eng2OilTmpThreshold02:update(JR1OT)
    local a = JR2OT_INV or JR2OT_NCD
    local b = WTOCT_2 and ZPH2
    local c = logic.eng2OilTmpThreshold01.out and (not a)
    local d = logic.eng2OilTmpThreshold02.out and ZPH2 and (not a)
    logic.eng2OilTmpConf01:update(d)
    local e = b and c
    local f = ZPH1 or ZPH6 or ZPH9 or (not c)
    logic.eng2OilTmpSRS01:update(e, f)
    local g = ZPH3 and c
    local h = logic.eng2OilTmpSRS01.Q or g or logic.eng2OilTmpConf01.OUT
    local i = h and (not JR2NORUN) and WRRT

	A333_ewd_msg.ENG_2_OIL_LO_TEMP.Monitor.audio.IN = bool2num[i]
	A333_ewd_msg.ENG_2_OIL_LO_TEMP.Monitor.video.IN = bool2num[i]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_2_OIL_LO_TEMP.Name)
	A333_ewd_msg.ENG_2_OIL_LO_TEMP.Monitor.video.INlast = A333_ewd_msg.ENG_2_OIL_LO_TEMP.Monitor.video.IN

end

function A333_ewd_msg.ENG_2_OIL_LO_TEMP.Reset()
	logic.eng2OilTmpConf01:resetTimer()
	logic.eng2OilTmpSRS01:reset()
end




function A333_ewd_msg.DC_EMER_CONFIG.WarningMonitor()

	local a = EADCGNL and EDCSOF and not EEMER

	EDCEC	= a

	A333_ewd_msg.DC_EMER_CONFIG.Monitor.audio.IN = bool2num[a]
	A333_ewd_msg.DC_EMER_CONFIG.Monitor.video.IN = bool2num[a]

end




function A333_ewd_msg.DC_BUS_1_2_OFF.WarningMonitor()

	local a = EEMER or EDCEC
	local b = EDC1OF and EDC2OF and (not a)
	logic.dcBus12OffConf01:update(b)

	EDC12OF	= logic.dcBus12OffConf01.OUT

	A333_ewd_msg.DC_BUS_1_2_OFF.Monitor.audio.IN = bool2num[logic.dcBus12OffConf01.OUT]
	A333_ewd_msg.DC_BUS_1_2_OFF.Monitor.video.IN = bool2num[logic.dcBus12OffConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.DC_BUS_1_2_OFF.Name)
	A333_ewd_msg.DC_BUS_1_2_OFF.Monitor.video.INlast = A333_ewd_msg.DC_BUS_1_2_OFF.Monitor.video.IN

end

function A333_ewd_msg.DC_BUS_1_2_OFF.Reset()
	logic.dcBus12OffConf01:resetTimer()
end




function A333_ewd_msg.GEN_1_FAULT.WarningMonitor()

    logic.gen1FaultConf01:update(not EGN1COF)
    local a = EIDG1D or EGN1PBOF
    local b = (not JR1NORUN) and EGN1COF
    local c = USKD and UG1LPBOF
    local d = (not a) and b
    logic.gen1FaultConf02:update(d)
    local e = logic.gen1FaultConf01.OUT or ZPH1 or ZPH10 or EEMER or c
    logic.gen1FaultSRR01:update(logic.gen1FaultConf02.OUT, e)
    
    ENG1INOP = b
    EG1FM = logic.gen1FaultSRR01.Q

    A333DR_fws_eng_gen1_fault = bool2num[EG1FM]

    A333_ewd_msg.GEN_1_FAULT.Monitor.audio.IN = bool2num[logic.gen1FaultSRR01.Q]
    A333_ewd_msg.GEN_1_FAULT.Monitor.video.IN = bool2num[logic.gen1FaultSRR01.Q]
    A333_fws_trigger_reset(A333_ewd_msg.GEN_1_FAULT.Name)
    A333_ewd_msg.GEN_1_FAULT.Monitor.video.INlast = A333_ewd_msg.GEN_1_FAULT.Monitor.video.IN

end

function A333_ewd_msg.GEN_1_FAULT.Reset()
	logic.gen1FaultConf01:resetTimer()
	logic.gen1FaultConf02:resetTimer()
	logic.gen1FaultSRR01:reset()
	A333_ewd_msg.GEN_1_FAULT.ActionReset()
end




function A333_ewd_msg.GEN_2_FAULT.WarningMonitor()

    logic.gen2FaultConf01:update(not EGN2COF)
    local a = EIDG2D or EGN2PBOF
    local b = (not JR2NORUN) and EGN2COF
    local c = USKD and UG1LPBOF
    local d = (not a) and b
    logic.gen2FaultConf02:update(d)
    local e = logic.gen2FaultConf01.OUT or ZPH1 or ZPH10 or EEMER or c
    logic.gen2FaultSRR01:update(logic.gen2FaultConf02.OUT, e)

    ENG2INOP = b
    EG2FM = logic.gen2FaultSRR01.Q

    A333DR_fws_eng_gen2_fault = bool2num[EG2FM]

    A333_ewd_msg.GEN_2_FAULT.Monitor.audio.IN = bool2num[logic.gen2FaultSRR01.Q]
    A333_ewd_msg.GEN_2_FAULT.Monitor.video.IN = bool2num[logic.gen2FaultSRR01.Q]
    A333_fws_trigger_reset(A333_ewd_msg.GEN_2_FAULT.Name)
    A333_ewd_msg.GEN_2_FAULT.Monitor.video.INlast = A333_ewd_msg.GEN_2_FAULT.Monitor.video.IN

end

function A333_ewd_msg.GEN_2_FAULT.Reset()
	logic.gen2FaultConf01:resetTimer()
	logic.gen2FaultConf02:resetTimer()
	logic.gen2FaultSRR01:reset()
	A333_ewd_msg.GEN_2_FAULT.ActionReset()
end




function A333_ewd_msg.APU_GEN_FAULT.WarningMonitor()

    local a = EAPUGNF and QAVAIL
    local b = (not EAPUGNPBOF) and (not EAPUGNF) and QAVAIL
    local c = not EAPUGNPBOF and a
    local d = b or ZPH1
    logic.apuGenFaultConf01:update(d)
    logic.apuGenFaultConf02:update(c)
    logic.apuGenFaultSRR01:update(logic.apuGenFaultConf02.OUT, logic.apuGenFaultConf01.OUT)

	ENG3INOP = a
	EGAPUM = logic.apuGenFaultSRR01.Q

    A333DR_apu_fault = bool2num[logic.apuGenFaultSRR01.Q]

	A333_ewd_msg.APU_GEN_FAULT.Monitor.audio.IN = bool2num[logic.apuGenFaultSRR01.Q]
	A333_ewd_msg.APU_GEN_FAULT.Monitor.video.IN = bool2num[logic.apuGenFaultSRR01.Q]
	A333_fws_trigger_reset(A333_ewd_msg.APU_GEN_FAULT.Name)
	A333_ewd_msg.APU_GEN_FAULT.Monitor.video.INlast = A333_ewd_msg.APU_GEN_FAULT.Monitor.video.IN

end

function A333_ewd_msg.APU_GEN_FAULT.Reset()
	logic.apuGenFaultConf01:resetTimer()
	logic.apuGenFaultConf02:resetTimer()
	logic.apuGenFaultSRR01:reset()
	A333_ewd_msg.APU_GEN_FAULT.ActionReset()
end




function A333_ewd_msg.ALTI_DISCREPANCY.WarningMonitor()

	logic.stdAltiDiscrepancyConf01:update(NALTSTDD)
	logic.stdAltiDiscrepancyConf02:update(NALTBD)
	local a =  logic.stdAltiDiscrepancyConf01.OUT or logic.stdAltiDiscrepancyConf02.OUT

	WWALTSTDD = logic.stdAltiDiscrepancyConf01.OUT
	WWALTBD = logic.stdAltiDiscrepancyConf02.OUT

	A333_ewd_msg.ALTI_DISCREPANCY.Monitor.audio.IN = bool2num[a]
	A333_ewd_msg.ALTI_DISCREPANCY.Monitor.video.IN = bool2num[a]
	A333_fws_trigger_reset(A333_ewd_msg.ALTI_DISCREPANCY.Name)
	A333_ewd_msg.ALTI_DISCREPANCY.Monitor.video.INlast = A333_ewd_msg.ALTI_DISCREPANCY.Monitor.video.IN

	A333_pfd_check_alt = bool2num[a]

end

function A333_ewd_msg.ALTI_DISCREPANCY.Reset()
	logic.stdAltiDiscrepancyConf01:resetTimer()
	logic.stdAltiDiscrepancyConf02:resetTimer()
end




function A333_ewd_msg.TCAS_FAULT.WarningMonitor()

    local a = NTCASF or NTCASCT_INV
    local b = a and WTCASI
    local c = (not WTCASSTBY) and b
    logic.tcasFaultConf01:update(c)
    local d = (not EAC1OF) and logic.tcasFaultConf01.OUT

    NTCAS = logic.tcasFaultConf01.OUT

    A333_ewd_msg.TCAS_FAULT.Monitor.audio.IN = bool2num[d]
    A333_ewd_msg.TCAS_FAULT.Monitor.video.IN = bool2num[d]

end




function A333_ewd_msg.DOORS_NOT_CLOSED.WarningMonitor()

    local a = GLDNUPL_1_INV or GLDNUPL_2_INV
    local b = GLDNUPL_1 and GLDNUPL_2
    local c = GLDNUPL_1 or GLDNUPL_2
    local d = GRDNUPL_1_INV or GRDNUPL_2_INV
    local e = GRDNUPL_1 and GRDNUPL_2
    local f = GRDNUPL_1 or GRDNUPL_2
    local g = GLGNUP or GGNDNLD
    local h = GNDNUPL_1_INV or GNDNUPL_2_INV
    local i = GNDNUPL_1 and GNDNUPL_2
    local j = GNDNUPL_1 or GNDNUPL_2
    local k = a and c
    local l = d and f
    local m = h and j
    local n = b or k
    local o = e or l
    local p = i or m
    local q = n or o or p
    logic.doorNotClsdConf01:update(q)
    local r = logic.doorNotClsdConf01.OUT and (not g)
    local s = (not n) and (not o) and (not p)
    logic.doorNotClsdSRR01:update(r, s)
    local t = n and p and o

	GODNC	= logic.doorNotClsdConf01.OUT
	GDNC	= logic.doorNotClsdSRR01.Q
	GADNC	= t
	GNDNU 	= p

	A333_ewd_msg.DOORS_NOT_CLOSED.Monitor.audio.IN = bool2num[logic.doorNotClsdSRR01.Q]
	A333_ewd_msg.DOORS_NOT_CLOSED.Monitor.video.IN = bool2num[logic.doorNotClsdSRR01.Q]
	A333_fws_trigger_reset(A333_ewd_msg.DOORS_NOT_CLOSED.Name)
	A333_ewd_msg.DOORS_NOT_CLOSED.Monitor.video.INlast = A333_ewd_msg.DOORS_NOT_CLOSED.Monitor.video.IN

end

function A333_ewd_msg.DOORS_NOT_CLOSED.Reset()
	logic.doorNotClsdConf01:resetTimer()
	logic.doorNotClsdSRR01:reset()
	A333_ewd_msg.DOORS_NOT_CLOSED.ActionReset()
end




function A333_ewd_msg.GEAR_NOT_UPLOCKED.WarningMonitor()

	logic.lgNotUpLckConf01:update(GGNLUPANSD)
	logic.lgNotUpLckConf02:update(GGLUP)
	local a = GLGDNLKD or GLGNLKD
	local b = (not HTHOUT) and a and logic.lgNotUpLckConf01.OUT
	logic.lgNotUpLckSRR01:update(b, logic.lgNotUpLckConf02.OUT)

	GLGNUP	= b
	GLGNUM	= logic.lgNotUpLckSRR01.Q

    A333_ewd_msg.GEAR_NOT_UPLOCKED.Monitor.audio.IN = bool2num[logic.lgNotUpLckSRR01.Q]
	A333_ewd_msg.GEAR_NOT_UPLOCKED.Monitor.video.IN = bool2num[logic.lgNotUpLckSRR01.Q]
	A333_fws_trigger_reset(A333_ewd_msg.GEAR_NOT_UPLOCKED.Name)
	A333_ewd_msg.GEAR_NOT_UPLOCKED.Monitor.video.INlast = A333_ewd_msg.GEAR_NOT_UPLOCKED.Monitor.video.IN

end

function A333_ewd_msg.GEAR_NOT_UPLOCKED.Reset()
	logic.lgNotUpLckConf01:resetTimer()
	logic.lgNotUpLckConf02:resetTimer()
	A333_ewd_msg.GEAR_NOT_UPLOCKED.ActionReset()
end




function A333_ewd_msg.GEAR_UPLOCK_FAULT.WarningMonitor()

    local a = GLGUWGD_1 and GLGUWGD_2
    local b = GRGUWGD_1 and GRGUWGD_2
    local c = GNGUWGD_1 and GNGUWGD_2
    local d = a or b or c

	GGUPENG	= d

	A333_ewd_msg.GEAR_NOT_UPLOCKED.Monitor.audio.IN = bool2num[d]
	A333_ewd_msg.GEAR_NOT_UPLOCKED.Monitor.video.IN = bool2num[d]

end




function A333_ewd_msg.SHOCK_ABSORBER_FAULT.WarningMonitor()

    local a = ZPH5 or ZPH6
    local b = ZPH10 or ZPH9
    local c = GLGNE and a and (not EEMER)
    local d = GRETIN_1_INV or GRETIN_2_INV
    local e = GRETIN_1 and GRETIN_2
    local f = GRETIN_1 or GRETIN_2
    local g = GLGEXT and b
    local h = d and f
    logic.lgShockAbsConf01:update(c)
    logic.lgShockAbsConf02:update(g)
    local i = e or h
    local j = i or logic.lgShockAbsConf01.OUT
    local k = j or logic.lgShockAbsConf02.OUT

	GSAF = j

	A333_ewd_msg.SHOCK_ABSORBER_FAULT.Monitor.audio.IN = bool2num[k]
	A333_ewd_msg.SHOCK_ABSORBER_FAULT.Monitor.video.IN = bool2num[k]
	A333_fws_trigger_reset(A333_ewd_msg.SHOCK_ABSORBER_FAULT.Name)
	A333_ewd_msg.SHOCK_ABSORBER_FAULT.Monitor.video.INlast = A333_ewd_msg.SHOCK_ABSORBER_FAULT.Monitor.video.IN

end

function A333_ewd_msg.SHOCK_ABSORBER_FAULT.Reset()
	logic.lgShockAbsConf01:resetTimer()
	logic.lgShockAbsConf02:resetTimer()
end




function A333_ewd_msg.BRAKES_HOT.WarningMonitor()

    local a = GBRK1OVHT or GBRK2OVHT or GBRK3OVHT or GBRK4OVHT
    local b = GBRK5OVHT or GBRK6OVHT or  GBRK7OVHT or GBRK8OVHT
    local c = GBI_1 or GBI_2
    local d = b and c
    local e = a or d
    local f = DTOCTPH3 and e

	GBRKOVHT = e

	A333_ewd_msg.BRAKES_HOT.Monitor.audio.IN = bool2num[f]
	A333_ewd_msg.BRAKES_HOT.Monitor.video.IN = bool2num[f]

end




function A333_ewd_msg.L_R_WING_TK_LO_LVL.WarningMonitor()

	local a = FLWLL and FRWLL
	logic.lrWingLoLvlConf01:update(a)
	FLRWLL = logic.lrWingLoLvlConf01.OUT

	A333_ewd_msg.L_R_WING_TK_LO_LVL.Monitor.audio.IN = bool2num[logic.lrWingLoLvlConf01.OUT]
	A333_ewd_msg.L_R_WING_TK_LO_LVL.Monitor.video.IN = bool2num[logic.lrWingLoLvlConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.L_R_WING_TK_LO_LVL.Name)
	A333_ewd_msg.L_R_WING_TK_LO_LVL.Monitor.video.INlast = A333_ewd_msg.L_R_WING_TK_LO_LVL.Monitor.video.IN

end

function A333_ewd_msg.L_R_WING_TK_LO_LVL.Reset()
	logic.lrWingLoLvlConf01:resetTimer()
end




function A333_ewd_msg.L_WING_TK_LO_LVL.WarningMonitor()

    local a = (not EDCBSSCOF) and FLWTLLA
    local b = FLWTLLB and (not EDC2OF)
    local c = a or b
    local d = (not FLRWLL) and c
    logic.lWingLoLvlConf01:update(d)

	FLWLL = c

	A333_ewd_msg.L_WING_TK_LO_LVL.Monitor.audio.IN = bool2num[logic.lWingLoLvlConf01.OUT]
	A333_ewd_msg.L_WING_TK_LO_LVL.Monitor.video.IN = bool2num[logic.lWingLoLvlConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.L_WING_TK_LO_LVL.Name)
	A333_ewd_msg.L_WING_TK_LO_LVL.Monitor.video.INlast = A333_ewd_msg.L_WING_TK_LO_LVL.Monitor.video.IN

end

function A333_ewd_msg.L_WING_TK_LO_LVL.Reset()
	logic.lWingLoLvlConf01:resetTimer()
end




function A333_ewd_msg.R_WING_TK_LO_LVL.WarningMonitor()

    local a = (not EDC2OF) and FRWTLLA
    local b = FRWTLLB and (not EDCBSSCOF)
    local c = a or b
    local d = not FLRWLL and c
    logic.rWingLoLvlConf01:update(d)

	FRWLL = c

	A333_ewd_msg.R_WING_TK_LO_LVL.Monitor.audio.IN = bool2num[logic.rWingLoLvlConf01.OUT]
	A333_ewd_msg.R_WING_TK_LO_LVL.Monitor.video.IN = bool2num[logic.rWingLoLvlConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.R_WING_TK_LO_LVL.Name)
	A333_ewd_msg.R_WING_TK_LO_LVL.Monitor.video.INlast = A333_ewd_msg.R_WING_TK_LO_LVL.Monitor.video.IN

end

function A333_ewd_msg.R_WING_TK_LO_LVL.Reset()
	logic.rWingLoLvlConf01:resetTimer()
end




function A333_ewd_msg.X_BLEED_FAULT.WarningMonitor()

    logic.xbld_UE1FPBpulse01:update(UE1FPBOUT)
    local a = UE1FPBOUT and logic.xbld_UE1FPBpulse01.OUT
    logic.xbleedVlvFltConf03:update(a)
    local b = BXFVOAD_1 or BXFVOAD_2
    local c = b and (not EDC2OF)
    local e = BXFVOMD_1 or BXFVOMD_2
    local d = c or BXFVCD or e
    logic.xbleedVlvFltConf01:update(d)
    logic.xbleedVlvFltConf02:update(logic.xbleedVlvFltConf01.OUT)
    local f = (not logic.xbleedVlvFltConf03.OUT) and logic.xbleedVlvFltConf02.OUT
    local g = c or e
    local h = f or logic.xbleedVlvFltConf01.OUT

	BXFDOD = g
	BXFDOMD = e

	A333_ewd_msg.X_BLEED_FAULT.Monitor.audio.IN = bool2num[h]
	A333_ewd_msg.X_BLEED_FAULT.Monitor.video.IN = bool2num[h]
	A333_fws_trigger_reset(A333_ewd_msg.X_BLEED_FAULT.Name)
	A333_ewd_msg.X_BLEED_FAULT.Monitor.video.INlast = A333_ewd_msg.X_BLEED_FAULT.Monitor.video.IN

end

function A333_ewd_msg.X_BLEED_FAULT.Reset()
	logic.xbleedVlvFltConf01:resetTimer()
	logic.xbleedVlvFltConf02:resetTimer()
	logic.xbleedVlvFltConf03:resetTimer()
end




function A333_ewd_msg.AI_ENG1_VALVE_CLOSED.WarningMonitor()

	local a = IE1AIPBON and IE1AIVF and (not JR1NORUN)
	logic.eng1NacVlvClsdConf01:update(a)

	IE1NVNO = logic.eng1NacVlvClsdConf01.OUT

	A333_ewd_msg.AI_ENG1_VALVE_CLOSED.Monitor.audio.IN = bool2num[logic.eng1NacVlvClsdConf01.OUT]
	A333_ewd_msg.AI_ENG1_VALVE_CLOSED.Monitor.video.IN = bool2num[logic.eng1NacVlvClsdConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.AI_ENG1_VALVE_CLOSED.Name)
	A333_ewd_msg.AI_ENG1_VALVE_CLOSED.Monitor.video.INlast = A333_ewd_msg.AI_ENG1_VALVE_CLOSED.Monitor.video.IN


end

function A333_ewd_msg.AI_ENG1_VALVE_CLOSED.Reset()
	logic.eng1NacVlvClsdConf01:resetTimer()
end




function A333_ewd_msg.AI_ENG2_VALVE_CLOSED.WarningMonitor()

	local a = IE2AIPBON and IE2AIVF and (not JR2NORUN)
	logic.eng2NacVlvClsdConf01:update(a)

	IE2NVNO = logic.eng2NacVlvClsdConf01.OUT

	A333_ewd_msg.AI_ENG2_VALVE_CLOSED.Monitor.audio.IN = bool2num[logic.eng2NacVlvClsdConf01.OUT]
	A333_ewd_msg.AI_ENG2_VALVE_CLOSED.Monitor.video.IN = bool2num[logic.eng2NacVlvClsdConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.AI_ENG2_VALVE_CLOSED.Name)
	A333_ewd_msg.AI_ENG2_VALVE_CLOSED.Monitor.video.INlast = A333_ewd_msg.AI_ENG2_VALVE_CLOSED.Monitor.video.IN


end

function A333_ewd_msg.AI_ENG2_VALVE_CLOSED.Reset()
	logic.eng2NacVlvClsdConf01:resetTimer()
end




function A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.WarningMonitor()

    logic.aiVlvClsdFltConf02:update(IWAIPBON)
    logic.aiVlvClsdFltConf03:update(ZPH1)
    local a = (not ILWAIVC) and AB1AVAIL and IWAION
    local b = (not ZGND) and IWAIPBON
    logic.aiVlvClsdFltPulse01:update(b)
    local c = ZGND and not logic.aiVlvClsdFltConf02.OUT
    local d = ILWAILP or ILWAIVC
    local e = a or logic.aiVlvClsdFltConf03.OUT
    local f = b or c
    local g = f and IWAIPBON and d and AB1AVAIL
    logic.aiVlvClsdFltConf01:update(g)
    logic.aiVlvClsdFltsrS01:update(logic.aiVlvClsdFltConf01.OUT, e)
    local h = logic.aiVlvClsdFltsrS01.Q or IRVCLSDF
    local i = (not logic.aiVlvClsdFltPulse01.OUT) and h
    local j = i or IPROCWAIESD

	ILVCLSDF = logic.aiVlvClsdFltsrS01.Q

	A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Monitor.audio.IN = bool2num[j]
	A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Monitor.video.IN = bool2num[j]
	A333_fws_trigger_reset(A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Name)
	A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Monitor.video.INlast = A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Monitor.video.IN

end

function A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Reset()
	logic.aiVlvClsdFltConf01:resetTimer()
	logic.aiVlvClsdFltConf02:resetTimer()
	logic.aiVlvClsdFltConf03:resetTimer()
	logic.aiVlvClsdFltsrS01:reset()
end




function A333_ewd_msg.DOOR_L_FWD_CABIN.WarningMonitor()

    local a = EDC1OF or ZPH1 or ZPH10
    local b = DLFCDNC and (not a)
    local c = b and DTOCTPH3

	A333_ewd_msg.DOOR_L_FWD_CABIN.Monitor.audio.IN = bool2num[c]
	A333_ewd_msg.DOOR_L_FWD_CABIN.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.DOOR_L_MID_CABIN.WarningMonitor()

	local a = EDC1OF or ZPH1 or ZPH10
	local b = DLMCDNC and (not a)
	local c = b and DTOCTPH3

	A333_ewd_msg.DOOR_L_MID_CABIN.Monitor.audio.IN = bool2num[c]
	A333_ewd_msg.DOOR_L_MID_CABIN.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.DOOR_L_AFT_CABIN.WarningMonitor()

	local a = EDC1OF or ZPH1 or ZPH10
	local b = DLACDNC and (not a)
	local c = b and DTOCTPH3

	A333_ewd_msg.DOOR_L_AFT_CABIN.Monitor.audio.IN = bool2num[c]
	A333_ewd_msg.DOOR_L_AFT_CABIN.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.DOOR_R_FWD_CABIN.WarningMonitor()

	local a = EDC1OF or ZPH1 or ZPH10
	local b = DRFCDNC and (not a)
	local c = b and DTOCTPH3

	A333_ewd_msg.DOOR_R_FWD_CABIN.Monitor.audio.IN = bool2num[c]
	A333_ewd_msg.DOOR_R_FWD_CABIN.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.DOOR_R_MID_CABIN.WarningMonitor()

	local a = EDC1OF or ZPH1 or ZPH10
	local b = DRMCDNC and (not a)
	local c = b and DTOCTPH3

	A333_ewd_msg.DOOR_R_MID_CABIN.Monitor.audio.IN = bool2num[c]
	A333_ewd_msg.DOOR_R_MID_CABIN.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.DOOR_R_AFT_CABIN.WarningMonitor()

	local a = EDC1OF or ZPH1 or ZPH10
	local b = DRACDNC and (not a)
	local c = b and DTOCTPH3

	A333_ewd_msg.DOOR_R_AFT_CABIN.Monitor.audio.IN = bool2num[c]
	A333_ewd_msg.DOOR_R_AFT_CABIN.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.DOOR_L_EMER_EXIT.WarningMonitor()

	local a = EDC1OF or ZPH1 or ZPH10
	local b = DLEEDNC and (not a)
	local c = b and DTOCTPH3

	A333_ewd_msg.DOOR_L_EMER_EXIT.Monitor.audio.IN = bool2num[c]
	A333_ewd_msg.DOOR_L_EMER_EXIT.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.DOOR_R_EMER_EXIT.WarningMonitor()

	local a = EDC1OF or ZPH1 or ZPH10
	local b = DREEDNC and (not a)
	local c = b and DTOCTPH3

	A333_ewd_msg.DOOR_R_EMER_EXIT.Monitor.audio.IN = bool2num[c]
	A333_ewd_msg.DOOR_R_EMER_EXIT.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.DOOR_R_AVIONICS.WarningMonitor()		-- NOTE: THIS DOOR IS ACTUALLY NOT MODELED

    logic.rAvioPulse01:update(WTOCT_2)
    logic.rAvioPulse02:update(ZPH3)
    local a = EDC2OF or ZPH1 or ZPH10
    local b = DRAVDNC and not a
    logic.rAvioMtrig01:update(logic.rAvioPulse01.OUT)
    local c = logic.rAvioMtrig01.OUT or logic.rAvioPulse02.OUT
    local d = b and not c

	DTOCTPH3 = (not c)
	WTOCT = logic.rAvioMtrig01.OUT

	A333_ewd_msg.DOOR_R_AVIONICS.Monitor.audio.IN = bool2num[d]
	A333_ewd_msg.DOOR_R_AVIONICS.Monitor.video.IN = bool2num[d]

end




function A333_ewd_msg.TO_MEMO.WarningMonitor()

    local a = ZPH2 or ZPH9
    local b = (not JR1NORUN) and (not JR2NORUN)
    local c = a and WTOCT_2
    local d = ZPH10 or ZPH3 or ZPH1 or ZPH6
    logic.toMemoConf01:update(b)
    logic.toMemoSRR01:update(c, d)
    local e = ZPH2 and logic.toMemoConf01.OUT
    local f = logic.toMemoSRR01.Q or e

	ZTOMEMC = f

	A333_ewd_msg.TO_MEMO.Monitor.video.IN = bool2num[f]
	A333_fws_trigger_reset(A333_ewd_msg.TO_MEMO.Name)
	A333_ewd_msg.TO_MEMO.Monitor.video.INlast = A333_ewd_msg.TO_MEMO.Monitor.video.IN

end

function A333_ewd_msg.TO_MEMO.Reset()
	logic.toMemoConf01:resetTimer()
	logic.toMemoSRR01:reset()
	A333_ewd_msg.TO_MEMO.ActionReset()
end

function A333_ewd_msg.TO_MEMO.EnginesRunning()
	logic.toMemoConf01.OUT = true					-- SHOW THE T.O MEMO IMMEDIATELY IF ENGINES RUNNING
end




function A333_ewd_msg.LDG_MEMO.WarningMonitor()

    logic.ldgThresh01:update(NRADH_2_APPR or NRADH_2)
    logic.ldgThresh02:update(NRADH_1_APPR or NRADH_1)
    logic.ldgThresh03:update(NRADH_1_APPR or NRADH_1)
    logic.ldgThresh04:update(NRADH_2_APPR or NRADH_2)
    local a = NRADH_1_INV or NRADH_1_NCD
    local b = NRADH_2_INV or NRADH_2_NCD
    local c = logic.ldgThresh01.out and not b
    local d = logic.ldgThresh02.out and not a
    local e = a and b
    local f = a or logic.ldgThresh03.out
    local g = b or logic.ldgThresh04.out
    local h = NRADH_1_INV and NRADH_2_INV and GLGDNLKD and ZPH6
    local i = c or d
    local k = f and g
    local j = not e and k
    logic.ldgMemoConf01:update(j)
    logic.ldgMemoSRS01:update(i, k)
    logic.ldgMemoConf02:update(h)
    local n = ZPH7 or ZPH8 or ZPH6
    logic.ldgMemoSRR02:update(logic.ldgMemoConf01.OUT, (not n))
    local l = logic.ldgMemoSRR02.Q and logic.ldgMemoSRS01.Q and ZPH6
    local m = l or logic.ldgMemoConf02.OUT or ZPH8 or ZPH7
    local o = m or ZTOMEMC

	ZLDGMEM = m
	ZCMEMC = o

	A333_ewd_msg.LDG_MEMO.Monitor.video.IN = bool2num[m]
	A333_fws_trigger_reset(A333_ewd_msg.LDG_MEMO.Name)
	A333_ewd_msg.LDG_MEMO.Monitor.video.INlast = A333_ewd_msg.LDG_MEMO.Monitor.video.IN

end

function A333_ewd_msg.LDG_MEMO.Reset()
	logic.ldgMemoConf01:resetTimer()
	logic.ldgMemoConf02:resetTimer()
	logic.ldgMemoSRS01:reset()
	logic.ldgMemoSRR02:reset()
end

function A333_ewd_msg.LDG_MEMO.FlightStart()
	local alt_ft_agl = simDR_pos_y_agl * 3.28084
	if alt_ft_agl > 100.0 then
		run_after_time(A333_ewd_msg_LDG_MEMO_FlightStart1, 0.5)
		run_after_time(A333_ewd_msg_LDG_MEMO_FlightStart2, 2.0)
		--run_after_time(A333_ewd_msg_LDG_MEMO_FlightStart3, 4.0)
	end
end

function A333_ewd_msg_LDG_MEMO_FlightStart1()
    NRADH_1_APPR = 2300.00 --100.0
    NRADH_2_APPR = 2300.00 --100.0
end

function A333_ewd_msg_LDG_MEMO_FlightStart2()
    NRADH_1_APPR = nil --100.00 --2300.0
    NRADH_2_APPR = nil --100.00 --2300.0
end

function A333_ewd_msg_LDG_MEMO_FlightStart3()
	NRADH_1_APPR = nil
	NRADH_2_APPR = nil
end




function A333_ewd_msg.IRS_IN_ALIGN.WarningMonitor()

    logic.irsAlignMRtrig01:update(NIRS1AL)
    logic.irsAlignMRtrig02:update(NIRS2AL)
    logic.irsAlignMRtrig03:update(NIRS3AL)
    local a = ZPH1 or ZPH2
    local b = logic.irsAlignMRtrig01.OUT or NIRS1AL
        or logic.irsAlignMRtrig02.OUT or NIRS2AL
        or logic.irsAlignMRtrig03.OUT or NIRS3AL

    local c = (not NIRSALG_1_NCD) and NIRSALG_1
    local d = (not NIRSALG_2_NCD) and NIRSALG_2
    local e = c or d
    local f = b or e
    local g = f and a and (not ZCMEMC)

	NOIRSAL = b

	A333_ewd_msg.IRS_IN_ALIGN.Monitor.video.IN = bool2num[g]

end




function A333_ewd_msg.GND_SPLRS_ARMED.WarningMonitor()

    local a = SGNDSPLRA_1 or SGNDSPLRA_2
    logic.gndSplrArmedConf01:update(a)
    local b = SALLGSSI or ZTOMEMC or ZLDGMEM
    local c = logic.gndSplrArmedConf01.OUT and (not b)

	A333_ewd_msg.GND_SPLRS_ARMED.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.SEAT_BELTS.WarningMonitor()

	local a = CFSBLT and (not ZCMEMC)

	A333_ewd_msg.SEAT_BELTS.Monitor.video.IN = bool2num[a]

end





function A333_ewd_msg.NO_SMOKING.WarningMonitor()

	local a = CNOSMOK and (not ZCMEMC)

	A333_ewd_msg.NO_SMOKING.Monitor.video.IN = bool2num[a]

end




function A333_ewd_msg.STROBE_LT_OFF.WarningMonitor()

	local a = LSLPBOF and (not ZCMEMC) and (not ZGND)

	A333_ewd_msg.STROBE_LT_OFF.Monitor.video.IN = bool2num[a]

end




function A333_ewd_msg.GPWS_FLAP_MODE_OFF.WarningMonitor()

	A333_ewd_msg.GPWS_FLAP_MODE_OFF.Monitor.video.IN = bool2num[NGPWSFMOF]

end




function A333_ewd_msg.TO_INHIBIT.WarningMonitor()

	local a = ZPH3 or ZPH4 or ZPH5
	local b = a and (not ZFPION)

	logic.toInhibConf01:update(b)

	A333_ewd_msg.TO_INHIBIT.Monitor.video.IN = bool2num[logic.toInhibConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.TO_INHIBIT.Name)
	A333_ewd_msg.TO_INHIBIT.Monitor.video.INlast = A333_ewd_msg.TO_INHIBIT.Monitor.video.IN

end

function A333_ewd_msg.TO_INHIBIT.Reset()
	logic.toInhibConf01:resetTimer()
end




function A333_ewd_msg.LDG_INHIBIT.WarningMonitor()

	local a = ZPH7 or ZPH8
	local b = a and (not ZFPION)

	logic.ldgInhibConf01:update(b)

	A333_ewd_msg.LDG_INHIBIT.Monitor.video.IN = bool2num[logic.ldgInhibConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.LDG_INHIBIT.Name)
	A333_ewd_msg.LDG_INHIBIT.Monitor.video.INlast = A333_ewd_msg.LDG_INHIBIT.Monitor.video.IN

end

function A333_ewd_msg.LDG_INHIBIT.Reset()
	logic.ldgInhibConf01:resetTimer()
end




function A333_ewd_msg.LAND_ASAP_RED.WarningMonitor()

    local a =  USFLC_1 or USFLC_2
    local b =  USALC_1 or USALC_2
    local c = UE1FIRE or UE2FIRE or UAPUFIRE
    local d = HGSYSLP and HYSYSLP
    local e = HYSYSLP and HBSYSLP
    local f = HBSYSLP and HGSYSLP
    local g = UFCSDI and a
    local h = b and UACSDI
    local i = g or h
    local j = d or e or f
    local k = i or c or EEMER or j
    local l = (not ZGND) and k

	ZLAPR = l

	A333_ewd_msg.LAND_ASAP_RED.Monitor.video.IN = bool2num[l]

end




function A333_ewd_msg.LAND_ASAP_AMBER.WarningMonitor()

    local a = USKD or EDCEC or JR1FAIL or JR2FAIL
    local b = JR1TLAKO or JR1TLAKO or JR1TLADISC or JR2TLADISC or JR1REVKO or JR2REVKO or JR1REVUNLK or JR2REVUNLK
    local c = JR2SD or JR1SD or JR1FAIL or JR2FAIL or FLRWLL or SFCLA or a or b
    local d = (not ZLAPR) and (not ZGND) and c

	A333_ewd_msg.LAND_ASAP_AMBER.Monitor.video.IN = bool2num[d]

end




function A333_ewd_msg.AIR_BLEED.WarningMonitor()

	local a =  JR1OUT or JR2OUT
	local b = a and (not EEMER)

	A333_ewd_msg.AIR_BLEED.Monitor.video.IN = bool2num[b]

end




function A333_ewd_msg.CAB_PRESS.WarningMonitor()

    local a = PS1F_1 or PS1F_1_INV
    local b = PS2F_2_INV or PS2F_2
    local c = a and EDCSOF
    local d = EDC2OF and b
    local e = c or d
    local f = (not EEMER) and e

    PSCPR = e

	A333_ewd_msg.CAB_PRESS.Monitor.video.IN = bool2num[f]

end




function A333_ewd_msg.AVNCS_VENT.WarningMonitor()

    local a = VAVEF and EDC1OF
    local b = VAVEF and EAC2OF
    local c = VAVEF and EDCBSSCOF
    local f = a or b or c
    local g = f and (not PSCPR)

	A333_ewd_msg.AVNCS_VENT.Monitor.video.IN = bool2num[g]

end




function A333_ewd_msg.ELEC.WarningMonitor()

	local a = JR1OUT or JR2OUT
	local b = a and (not EEMER)

	A333_ewd_msg.ELEC.Monitor.video.IN = bool2num[b]

end




function A333_ewd_msg.HYDB.WarningMonitor()

    local a = HBROVHT or HBRLAP or HBRLL or HBEPPBOF
    local b = EDCSOF or EAC1OF
    local c = HBEPLP or HBSYSLP
    local d = ZPH1 or ZPH10
    local e = (not a) and b and c and (not d) and (not EEMER)

	A333_ewd_msg.HYDB.Monitor.video.IN = bool2num[e]

end




function A333_ewd_msg.HYDY.WarningMonitor()

    local a =  EDC2OF or EAC2OF
    local b = ZPH1 or ZPH10 or ZPH2 or ZPH9 or EEMER
    local c = (not EEMER) and HYEPON and a and HYSLP
    local d = (not HYPPBOF) and HYPLP and JR2OUT and (not b)
    local e = d or c

	A333_ewd_msg.HYDY.Monitor.video.IN = bool2num[e]

end




function A333_ewd_msg.HYDG.WarningMonitor()

	local a = ZPH1 or ZPH10 or ZPH2 or ZPH9
	local b = (not a) and JR1OUT and HGPLP and (not HGPPBOF) and (not EEMER)

	A333_ewd_msg.HYDG.Monitor.video.IN = bool2num[b]

end




function A333_ewd_msg.FUEL.WarningMonitor()

    local a =  EAC1OF or EDC1OF
    local b =  EAC2OF or EDC2OF
    local c =  FLTP1LP and a
    local d =  b and FLTP2LP
    local e =  c or d
    local f = e and (not EEMER)

	A333_ewd_msg.FUEL.Monitor.audio.IN = bool2num[f]
	A333_ewd_msg.FUEL.Monitor.video.IN = bool2num[f]

end






function A333_ewd_msg.AIR_COND.WarningMonitor()

    local a = EDC2OF or EAC2OF
    local b =  EAC1OF or EDC1OF
    local c =  AP2CF and a
    local d = b and AP1CF
    local e = c and d
    local f = e and (not EEMER)

	A333_ewd_msg.AIR_COND.Monitor.video.IN = bool2num[f]

end





function A333_ewd_msg.BRAKES.WarningMonitor()

    local a = EDC2OF or EAC2OF
    local b = EDC1OF or EAC1OF
    local c = EEMER or WSDACF
    local d = a and b
    local e = not c and not GNABF and d

	GEBF = d

	A333_ewd_msg.BRAKES.Monitor.video.IN = bool2num[e]

end




function A333_ewd_msg.WHEEL.WarningMonitor()

	local a = (not EDC12OF) and (not EEMER) and GLGCIU2FT and EDC2OF
	local b = HGSYSLP or a

	A333_ewd_msg.WHEEL.Monitor.video.IN = bool2num[b]

end




function A333_ewd_msg.FCTLG.WarningMonitor()

	A333_ewd_msg.FCTLG.Monitor.video.IN = bool2num[HGSYSLP]

end




function A333_ewd_msg.FCTLY.WarningMonitor()

	A333_ewd_msg.FCTLY.Monitor.video.IN = bool2num[HYSYSLP]

end





function A333_ewd_msg.FCTLB.WarningMonitor()

	A333_ewd_msg.FCTLB.Monitor.video.IN = bool2num[HBSYSLP]

end





function A333_ewd_msg.FCTLDC2.WarningMonitor()

	local a = not EEMER and EDC2OF

	A333_ewd_msg.FCTLDC2.Monitor.video.IN = bool2num[a]

end




function A333_ewd_msg.FCTLESS.WarningMonitor()

	-- NOT MODELED

end




function A333_ewd_msg.SPEED_BRAKE.WarningMonitor()

    local a =  SSPBR_1 or SSPBR_2
    local b = ZPH1 or ZPH8 or ZPH9 or ZPH10
    local c = a and not b

	A333_ewd_msg.SPEED_BRAKE.Monitor.video.IN = bool2num[c]

	if A333_ewd_msg.SPEED_BRAKE.Monitor.video.OUT == 1 then
		if SASPDBRK then
			A333_ewd_msg.SPEED_BRAKE.TitleColor = 1						    -- AMBER
			if not is_timer_scheduled(A333_ewd_msg_SPEED_BRAKE_amberPulse) then
				run_at_interval(A333_ewd_msg_SPEED_BRAKE_amberPulse, 0.5)	-- PULSING
			end


		else
			if is_timer_scheduled(A333_ewd_msg_SPEED_BRAKE_amberPulse) then
				stop_timer(A333_ewd_msg_SPEED_BRAKE_amberPulse)
			end
			A333_ewd_msg.SPEED_BRAKE.TitleColor = 2						-- GREEN
			A333_ewd_msg.SPEED_BRAKE.ItemTitle = 'SPEED BRAKE'


		end
	else
		if is_timer_scheduled(A333_ewd_msg_SPEED_BRAKE_amberPulse) then
			stop_timer(A333_ewd_msg_SPEED_BRAKE_amberPulse)
		end
		A333_ewd_msg.SPEED_BRAKE.TitleColor = 1
		A333_ewd_msg.SPEED_BRAKE.ItemTitle = 'SPEED BRAKE'
	end

end

function A333_ewd_msg_SPEED_BRAKE_amberPulse()
	if A333_ewd_msg.SPEED_BRAKE.ItemTitle == 'SPEED BRAKE' then
		A333_ewd_msg.SPEED_BRAKE.ItemTitle = '           '
	elseif A333_ewd_msg.SPEED_BRAKE.ItemTitle == '           ' then
		A333_ewd_msg.SPEED_BRAKE.ItemTitle = 'SPEED BRAKE'
	end
end




function A333_ewd_msg.PARK_BRAKE.WarningMonitor()

	local a =  GPBRKON and not ZPH3

	A333_ewd_msg.PARK_BRAKE.Monitor.video.IN = bool2num[a]

	local b =  ZPH4 or ZPH5 or ZPH6 or ZPH7 or ZPH8

	if b then
		A333_ewd_msg.PARK_BRAKE.TitleColor = 1
	else
		A333_ewd_msg.PARK_BRAKE.TitleColor = 2
	end

end




function A333_ewd_msg.RAT_OUT.WarningMonitor()

	A333_ewd_msg.RAT_OUT.Monitor.video.IN = bool2num[HRATNFS]

	local a = ZPH1 or ZPH2

	if a then
		A333_ewd_msg.RAT_OUT.TitleColor = 1
	else
		A333_ewd_msg.RAT_OUT.TitleColor = 2
	end

end




function A333_ewd_msg.RAM_AIR_ON.WarningMonitor()

	A333_ewd_msg.RAM_AIR_ON.Monitor.video.IN = bool2num[ARAPBON]

end







function A333_ewd_msg.IGNITION.WarningMonitor()

	local a = JR1CONTIGN_1A or R1CONTIGN_1B or JR2CONTIGN_2A or JR2CONTIGN_2B
	local b = a and WRRT

	A333_ewd_msg.IGNITION.Monitor.video.IN = bool2num[b]

end




function A333_ewd_msg.CABIN_READY.WarningMonitor()

    local a = CCR1 or CCR2
    local b = ZPH6 or ZPH7
    local c = b and GLGDNLKD
    local d = ZPH2 or c
    local e = a and d

	CCABR = a

	A333_ewd_msg.CABIN_READY.Monitor.video.IN = bool2num[e]

	logic.cabRdyConf01:update(CCABR)


	if A333_ewd_msg.CABIN_READY.Monitor.video.OUT == 1 then
		if logic.cabRdyConf01.OUT then
			if is_timer_scheduled(A333_ewd_msg_CABIN_READY_greenPulse) then
				stop_timer(A333_ewd_msg_CABIN_READY_greenPulse)
			end
			A333_ewd_msg.CABIN_READY.ItemTitle = 'CABIN READY'
		else
			if not is_timer_scheduled(A333_ewd_msg_CABIN_READY_greenPulse) then
				run_at_interval(A333_ewd_msg_CABIN_READY_greenPulse, 0.5)			-- PULSING
			end
		end
	else
		if is_timer_scheduled(A333_ewd_msg_CABIN_READY_greenPulse) then
			stop_timer(A333_ewd_msg_CABIN_READY_greenPulse)
		end
		A333_ewd_msg.CABIN_READY.ItemTitle = 'CABIN READY'
	end

end

function A333_ewd_msg_CABIN_READY_greenPulse()
	if A333_ewd_msg.CABIN_READY.ItemTitle == 'CABIN READY' then
		A333_ewd_msg.CABIN_READY.ItemTitle = '           '
	elseif A333_ewd_msg.CABIN_READY.ItemTitle == '           ' then
		A333_ewd_msg.CABIN_READY.ItemTitle = 'CABIN READY'
	end
end




function A333_ewd_msg.TCAS_STBY.WarningMonitor()

    local a = NTCASSTBY or NATCSTBY
    local b = NATC1F and NATC2F
    local c = NRADH_1_INV and NRADH_2_INV
    local d = b or c
    local e = a or d or NATCALTROF
    local f = e and WTCASI

    WTCASSTBY = f

    A333_ewd_msg.TCAS_STBY.Monitor.video.IN = bool2num[f]
    A333_ewd_msg.TCAS_STBY.Monitor.audio.IN = bool2num[f]

end




function A333_ewd_msg.COMPANY_MSG.WarningMonitor()

	local a = WATSUINS and CATSUMSGACT and CAOCMSG

	A333_ewd_msg.COMPANY_MSG.Monitor.video.IN = bool2num[a]

end




function A333_ewd_msg.ENG_A_ICE.WarningMonitor()

    local a = IE1AIPBON or IE2AIPBON
    local b = EDC1OF or EDC2OF
    local c = a or b

	A333_ewd_msg.ENG_A_ICE.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.WING_A_ICE.WarningMonitor()

	A333_ewd_msg.WING_A_ICE.Monitor.video.IN = bool2num[IWAIPBON]

end




function A333_ewd_msg.ICE_NOT_DET.WarningMonitor()

    local a =  IE1IDF and IE2IDF
    local b = (not IE1IDF) and IE1ID
    local c = IE2ID and (not IE2IDF)
    local d = IE1AIPBON or IWAIPBON or IE2AIPBON
    logic.iceNotDetConf02:update(d)
    local e =  WIDID and (not ZGND)
    local f = b or c
    local g = (not f) and logic.iceNotDetConf02.OUT
    logic.iceNotDetConf01:update(g)
    local h = (not a) and logic.iceNotDetConf01.OUT and e

	A333_ewd_msg.ICE_NOT_DET.Monitor.video.IN = bool2num[h]

end




function A333_ewd_msg.APU_BLEED.WarningMonitor()

    local a = BAPUBPBOF_1_VAL and (not BAPUBPBOF_1)
    local b = (not BAPUBPBOF_2) and BAPUBPBOF_2_VAL
    local c = (not BAPUBVFC_1) and (not BAPUBVFC_2)
    local d = a or b
    local e = d and QAVAIL and c

	QBLEED = e

	A333_ewd_msg.APU_BLEED.Monitor.video.IN = bool2num[e]

end




function A333_ewd_msg.APU_AVAIL.WarningMonitor()

	local a = QAVAIL and (not QBLEED)

	A333_ewd_msg.APU_AVAIL.Monitor.video.IN = bool2num[a]

end




function A333_ewd_msg.BRK_FAN.WarningMonitor()

    local a = (not GBFANCON_1_NCD) and GBFANCON_1
    local b = GBFANCON_2 and (not GBFANCON_2_NCD)
    local c = GBFI_1 or GBFI_2
    local d = a or b
    local e = c and d

	A333_ewd_msg.BRK_FAN.Monitor.video.IN = bool2num[e]

end




--function A333_ewd_msg.GPWS_FLAP_3.WarningMonitor()
--
--	local a = NFFMSLDG3 and (not EEMER)
--
--	A333_ewd_msg.GPWS_FLAP_3.Monitor.video.IN = bool2num[a]
--
--end




function A333_ewd_msg.HF_VOICE.WarningMonitor()

	local a = CATSUHF1VAL or CATSUHF2VAL
	local b = CATSUHF1VF and CATSUHF1VAL
	local c = CATSUHF2VAL and CATSUHF2VAL
	local d = ZPH1 or ZPH2 or ZPH6 or ZPH9 or ZPH10
	local e = WCHFDR1I and b and not WCHFDR2I
	local f = WCHFDR1I and not WCHFDR1I and c
	local g = WCHFDR2I and WCHFDR1I and CATSUHF1VF and CATSUHF2VF and a
	local h = e or f or g
	local i = h and WATSUINS and d

	CHFDRVOICE = i
	CATSUMSGACT = d

	A333_ewd_msg.HF_VOICE.Monitor.video.IN = bool2num[i]

end




function A333_ewd_msg.AUTO_BRK_LO.WarningMonitor()

	local a = (not GDLORA_1_NCD) and GDLORA_1
	local b = GDLORA_2 and (not GDLORA_2_NCD)
	local c = a or b

	A333_ewd_msg.AUTO_BRK_LO.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.AUTO_BRK_MED.WarningMonitor()

	local a = (not GDMDRA_1_NCD) and GDMDRA_1
	local b = GDMDRA_2 and (not GDMDRA_2_NCD)
	local c = a or b

	A333_ewd_msg.AUTO_BRK_MED.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.AUTO_BRK_MAX.WarningMonitor()

	local a = (not GDMXRA_1_NCD) and GDMXRA_1
	local b = GDMXRA_2 and (not GDMXRA_2_NCD)
	local c = a or b

	A333_ewd_msg.AUTO_BRK_MAX.Monitor.video.IN = bool2num[c]

end




function A333_ewd_msg.AUTO_BRK_OFF.WarningMonitor()

	local a = GABRKF_1 or GABRKF_2

	A333_ewd_msg.AUTO_BRK_OFF.Monitor.video.IN = bool2num[a]

end




function A333_ewd_msg.CTR_TK_FEEDG.WarningMonitor()

    local a = ZPH1 or ZPH10 or FMITD
    local b = FCTI_1 or FCTI_2
    local c = (not FCTP1COF_INV) and (not FCTP1COF)
    local d = (not FCTP2COF) and (not FCTP2COF_INV)
    local e = c or d
    local f = (not EAC1OF) and (not EAC2OF) and b and e and (not a)

	A333_ewd_msg.CTR_TK_FEEDG.Monitor.video.IN = bool2num[f]

end




function A333_ewd_msg.FUEL_X_FEED.WarningMonitor()

	local a = FXFVPBON and not FXFVFC

	A333_ewd_msg.FUEL_X_FEED.Monitor.video.IN = bool2num[a]

	local b = ZPH3 or ZPH4 or ZPH5

	if b then
		A333_ewd_msg.FUEL_X_FEED.TitleColor = 1
	else
		A333_ewd_msg.FUEL_X_FEED.TitleColor = 2
	end

end





















local function A333_fws_warning_triggers()

	for _, message in pairs(A333_ewd_msg) do
        if message.WarningMonitor then
            message.WarningMonitor()
        end
	end

end








--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_300_init_ER()

	A333_ewd_msg.TO_MEMO.EnginesRunning()

end

function A333_fws_300_flight_start()

	A333_ewd_msg.LDG_MEMO.FlightStart()

end

function A333_fws_300()

	A333_fws_warning_triggers()

end






--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")











