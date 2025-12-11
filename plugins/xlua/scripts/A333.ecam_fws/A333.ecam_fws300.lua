jit.off()
--[[
*****************************************************************************************
* Script Name :	A333.ecam_fws300.lua
* Process: FWS Warning Trigger Logic
*
* Author Name :	Jim Gregory
*
* Revisions:
* -- DATE --  --- REV NO ---  --- DESCRIPTION -------------------------------------------
* 10/09/2025   AG330 v1.2.0   add ADIRS ALIGN MSG to EWD
* 10/12/2025   AG330 v1.3.0	  add PACK 1/2 OFF announcement on EWD
*
*
*
*****************************************************************************************
*       					     COPYRIGHT © 2021, 2022
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

local logic = {}

logic.flNotZeroThresh01 = newThreshold('flNotZeroThresh01', '>=', 22000.0)
logic.flNotZeroThresh02 = newThreshold('flNotZeroThresh02', '>=', 22000.0)
logic.flNotZeroThresh03 = newThreshold('flNotZeroThresh03', '>=', 22000.0)

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

logic.aiVlvClsdFltConf01 = newLeadingEdgeDelayedConfirmation('aiVlvClsdFltConf01', 15.0)
logic.aiVlvClsdFltConf02 = newLeadingEdgeDelayedConfirmation('aiVlvClsdFltConf02', 25.0)
logic.aiVlvClsdFltConf03 = newLeadingEdgeDelayedConfirmation('aiVlvClsdFltConf03', 2.0)
logic.aiVlvClsdFltPulse01 = newLeadingEdgePulse('aiVlvClsdFltPulse01')
logic.aiVlvClsdFltsrS01 = newSRlatchSetPriority('aiVlvClsdFltsrS01')

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
-- PFD Messages
A333_pfd_check_alt = create_dataref("laminar/A333/annun/pfd_check_alt", "number")



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

function A333_ewd_msg.FLAP_LEVER_NOT_ZERO.WarningMonitor()

	logic.flNotZeroThresh01:update(NALTI_1)
	logic.flNotZeroThresh02:update(NALTI_2)
	logic.flNotZeroThresh03:update(NALTI_3)

	local a = {E1 = NCAS_1_INV, E2 = NCAS_1_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = NCAS_2_INV, E2 = NCAS_2_NCD}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = NCAS_3_INV, E2 = NCAS_3_NCD}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = SS0F0_1_INV, E2 = SS0F0_1_NCD}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = SS0F0_2_INV, E2 = SS0F0_2_NCD}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = bNOT(a.S), E2 = logic.flNotZeroThresh01.out}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = bNOT(b.S), E2 = logic.flNotZeroThresh02.out}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = bNOT(c.S), E2 = logic.flNotZeroThresh03.out}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = bNOT(d.S), E2 = bNOT(SS00F00_1)}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = bNOT(e.S), E2 = bNOT(SS00F00_2)}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = f.S, E2 = g.S, E3 = h.S}
	k.S = bOR3(k.E1, k.E2, k.E3)

	local l = {E1 = i.S, E2 = j.S}
	l.S = bOR(l.E1, l.E2)

	local m = {E1 = k.S, E2 = WSFLPLVRNOT0, E3 = ZPH6, E4 = l.S}
	m.S = bAND4(m.E1, m.E2, m.E3, m.E4)

	A333_ewd_msg.FLAP_LEVER_NOT_ZERO.Monitor.audio.IN = bool2num[m.S]
	A333_ewd_msg.FLAP_LEVER_NOT_ZERO.Monitor.video.IN = bool2num[m.S]

end



function A333_ewd_msg.OVER_SPEED_VFE1.WarningMonitor()	-- CONF FULL

	local a = {E1 = SFLPSF, E2 = SSLTSG}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = a.S, E2 = NASS184}
	b.S = bAND(b.E1, b.E2)

	NVFE1 = b.S

	A333_ewd_msg.OVER_SPEED_VFE1.Monitor.audio.IN = bool2num[b.S]
	A333_ewd_msg.OVER_SPEED_VFE1.Monitor.video.IN = bool2num[b.S]

end



function A333_ewd_msg.OVER_SPEED_VFE2.WarningMonitor()		-- CONF 3

	local a = {E1 = SFLPSD, E2 = NASS190, E3 = bNOT(NVFE1)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	NVFE2 = a.S

	A333_ewd_msg.OVER_SPEED_VFE2.Monitor.audio.IN = bool2num[a.S]
	A333_ewd_msg.OVER_SPEED_VFE2.Monitor.video.IN = bool2num[a.S]

end



function A333_ewd_msg.OVER_SPEED_VFE3.WarningMonitor()		-- CONF 2

	local a = {E1 = bNOT(SSLTIE), E2 = SSLTVAL}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = SFLPSC, E2 = a.S}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = NASS200, E2 = bNOT(NVFE1), E3 = bNOT(NVFE2), E4 = b.S}
	c.S = bAND4(c.E1, c.E2, c.E3, c.E4)

	NVFE3 = c.S

	A333_ewd_msg.OVER_SPEED_VFE3.Monitor.audio.IN = bool2num[c.S]
	A333_ewd_msg.OVER_SPEED_VFE3.Monitor.video.IN = bool2num[c.S]

end



function A333_ewd_msg.OVER_SPEED_VFE4.WarningMonitor()	-- NEW LOGIC FOR A333 (CONF 1*)

	local a = {E1 = SFLPSB, E2 = bNOT(SSLTIE), E3 = SSLTVAL}
	a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = a.S, E2 = NASS209, E3 = bNOT(NVFE1), E4 = bNOT(NVFE2), E5 = bNOT(NVFE3)}
	b.S = bAND5(b.E1, b.E2, b.E3, b.E4, b.E5)

	NVFE4 = b.S

	A333_ewd_msg.OVER_SPEED_VFE4.Monitor.audio.IN = bool2num[b.S]
	A333_ewd_msg.OVER_SPEED_VFE4.Monitor.video.IN = bool2num[b.S]

end



function A333_ewd_msg.OVER_SPEED_VFE5.WarningMonitor() 	-- A320 VFE4		(CONF 1+F)

	local a = {E1 = SFLPVAL, E2 = SFLPSB}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = SSLTIE, E2 = a.S, E3 = bNOT(NVFE1), E4 = bNOT(NVFE2), E5 = bNOT(NVFE3), E6 = bNOT(NVFE4), E7 = NASS219}
	b.S = bAND7(b.E1, b.E2, b.E3, b.E4, b.E5, b.E6, b.E7)

	NVFE5 = b.S

	A333_ewd_msg.OVER_SPEED_VFE5.Monitor.audio.IN = bool2num[b.S]
	A333_ewd_msg.OVER_SPEED_VFE5.Monitor.video.IN = bool2num[b.S]

end



function A333_ewd_msg.OVER_SPEED_VFE6.WarningMonitor()	 -- A320 VFE5		(CONF 1)

	local a = {E1 = SSLTSA, E2 = SSLTIE}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = NASS244, E2 = bNOT(NVFE1), E3 = bNOT(NVFE2), E4 = bNOT(NVFE3), E5 = bNOT(NVFE4), E6 = bNOT(NVFE5), E7 = a.S}
	b.S = bAND7(b.E1, b.E2, b.E3, b.E4, b.E5, b.E6, b.E7)

	NVFE6 = b.S

	A333_ewd_msg.OVER_SPEED_VFE6.Monitor.audio.IN = bool2num[b.S]
	A333_ewd_msg.OVER_SPEED_VFE6.Monitor.video.IN = bool2num[b.S]

end



function A333_ewd_msg.OVER_SPEED_VLE.WarningMonitor()

	local a = {E1 = GSAF, E2 = GDNC, E3 = GGUPENG, E4 = GLGNUP, E5 = GLGDNLKD}
	a.S = bOR5(a.E1, a.E2, a.E3, a.E4, a.E5)

	local b = {E1 = NASS250, E2 = a.S}
	b.S = bAND(b.E1, b.E2)

	WVLE = b.S

	A333_ewd_msg.OVER_SPEED_VLE.Monitor.audio.IN = bool2num[b.S]
	A333_ewd_msg.OVER_SPEED_VLE.Monitor.video.IN = bool2num[b.S]

end



function A333_ewd_msg.OVER_SPEED_VMO_MMO.WarningMonitor()

	local a = {E1 = NVMOW_1_FT, E2 = NVMOW_2_FT}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = NVMOW_3_FT, E2 = a.S}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = NVMOW_3, E2 = b.S}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = NVMOW_1_FT, E2 = NVMOW_2_FT, E3 = NVMOW_3_FT}
	d.S = bOR3(d.E1, d.E2, d.E3)

	local e = {E1 = NVMOW_1, E2 = NVMOW_2, E3 = c.S}
	e.S = bOR3(e.E1, e.E2, e.E3)

	logic.vMOmMOMtrig01:update(d.S)

	local f = {E1 = bNOT(logic.vMOmMOMtrig01.OUT), E2 = d.S}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = bNOT(f.S), E2 = e.S}
	g.S = bAND(g.E1, g.E2)

	WVMOMMO = e.S

	A333_ewd_msg.OVER_SPEED_VMO_MMO.Monitor.audio.IN = bool2num[g.S]
	A333_ewd_msg.OVER_SPEED_VMO_MMO.Monitor.video.IN = bool2num[e.S]

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

	local a = {E1 = UE1FA, E2 = UE1FB}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = UE1FA, E2 = logic.eng1FireConf01.OUT}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = UE1FB, E2 = logic.eng1FireConf02.OUT}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S, E3 = c.S}
	d.S = bOR3(d.E1, d.E2, d.E3)

	local e = {E1 = bNOT(UE1FPBOUT), E2 = d.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = e.S, E2 = toboolean(A333_engine_fire_test)}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = d.S, E2 = toboolean(A333_engine_fire_test)}
	g.S = bOR(g.E1, g.E2)

	WWE1FI	= d.S
	UE1FIRE	= d.S

	A333_ewd_msg.ENG_1_FIRE.Monitor.audio.IN = bool2num[f.S]
	A333_ewd_msg.ENG_1_FIRE.Monitor.video.IN = bool2num[g.S]
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

	local a = {E1 = UE2FA, E2 = UE2FB}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = UE2FA, E2 = logic.eng2FireConf01.OUT}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = UE2FB, E2 = logic.eng2FireConf02.OUT}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S, E3 = c.S}
	d.S = bOR3(d.E1, d.E2, d.E3)

	local e = {E1 = bNOT(UE2FPBOUT), E2 = d.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = e.S, E2 = toboolean(A333_engine_fire_test)}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = d.S, E2 = toboolean(A333_engine_fire_test)}
	g.S = bOR(g.E1, g.E2)

	WWE2FI	= d.S
	UE2FIRE	= d.S

	A333_ewd_msg.ENG_2_FIRE.Monitor.audio.IN = bool2num[f.S]
	A333_ewd_msg.ENG_2_FIRE.Monitor.video.IN = bool2num[g.S]
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

	local a = {E1 = UAPUFA, E2 = UAPUFB}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = UAPUFA, E2 = logic.apuFireConf01.OUT}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = UAPUFB, E2 = logic.apuFireConf02.OUT}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S, E3 = c.S}
	d.S = bOR(d.E1, d.E2, d.E3)

	local e = {E1 = bNOT(UAPUFPBOUT) , E2 = d.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = e.S, E2 = toboolean(A333_apu_fire_test)}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = d.S, E2 = toboolean(A333_apu_fire_test)}
	g.S = bOR(g.E1, g.E2)

	WWAPUFI		= d.S
	UAPUFIRE	= d.S

	A333_ewd_msg.APU_FIRE.Monitor.audio.IN = bool2num[f.S]
	A333_ewd_msg.APU_FIRE.Monitor.video.IN = bool2num[g.S]
	A333_fws_trigger_reset(A333_ewd_msg.APU_FIRE.Name)
	A333_ewd_msg.APU_FIRE.Monitor.video.INlast = A333_ewd_msg.APU_FIRE.Monitor.video.IN

end

function A333_ewd_msg.APU_FIRE.Reset()
	logic.apuFireConf01:resetTimer()
	logic.apuFireConf02:resetTimer()
	A333_ewd_msg.APU_FIRE.ActionReset()
end







function A333_ewd_msg.SLATS_CONFIG.WarningMonitor()

	local a = {E1 = ZPH9, E2 = ZPH1, E3 = ZPH2}
	a.S = bOR3(a.E1, a.E2, a.E3)

	--local b = {}
	--b.S = SSLTSC

	local b = {E1 = SSLTID, E2 = SSLTSG}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = ZPH3, E2 = ZPH4}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = WTOCT_2, E2 = a.S, E3 = b.S}
	d.S = bAND3(d.E1, d.E2, d.E3)

	local e = {E1 = b.S, E2 = c.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = bNOT(b.S), E2 = ZPH5}
	f.S = bOR(f.E1, f.E2)

	logic.slatsCfgSRS01:update(e.S, f.S)

	local g = {E1 = b.S, E2 = a.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = d.S, E2 = e.S}
	h.S = bOR(h.E1, h.E2)

	local i = {E1 = d.S, E2 = logic.slatsCfgSRS01.Q}
	i.S = bOR(i.E1, i.E2)

	SSLTNTO = g.S

	A333_ewd_msg.SLATS_CONFIG.Monitor.audio.IN = bool2num[h.S]
	A333_ewd_msg.SLATS_CONFIG.Monitor.video.IN = bool2num[i.S]
	A333_fws_trigger_reset(A333_ewd_msg.SLATS_CONFIG.Name)
	A333_ewd_msg.SLATS_CONFIG.Monitor.video.INlast = A333_ewd_msg.SLATS_CONFIG.Monitor.video.IN

end

function A333_ewd_msg.SLATS_CONFIG.Reset()
	logic.slatsCfgSRS01:reset()
end







function A333_ewd_msg.FLAPS_CONFIG.WarningMonitor()

	local a = {E1 = ZPH1, E2 = ZPH2, E3 = ZPH9}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = ZPH4, E2 = ZPH3}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = SFLPSF, E2 = SFLPIA}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = SFLPSF, E2 = SFLPIA}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = WTOCT_2, E2 = a.S, E3 = c.S}
	e.S = bAND3(e.E1, e.E2, e.E3)

	local f = {E1 = b.S, E2 = d.S}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = bNOT(d.S), E2 = ZPH5}
	g.S = bOR(g.E1, g.E2)

	logic.flapsCfgSRS01:update(f.S, g.S)

	local h = {E1 = d.S, E2 = a.S}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = e.S, E2 = f.S}
	i.S = bOR(i.E1, i.E2)

	local j = {E1 = e.S, E2 = logic.flapsCfgSRS01.Q}
	j.S = bOR(j.E1, j.E2)

	SFLPNTO = h.S

	A333_ewd_msg.FLAPS_CONFIG.Monitor.audio.IN = bool2num[i.S]
	A333_ewd_msg.FLAPS_CONFIG.Monitor.video.IN = bool2num[j.S]
	A333_fws_trigger_reset(A333_ewd_msg.FLAPS_CONFIG.Name)
	A333_ewd_msg.FLAPS_CONFIG.Monitor.video.INlast = A333_ewd_msg.FLAPS_CONFIG.Monitor.video.IN

end

function A333_ewd_msg.FLAPS_CONFIG.Reset()
	logic.flapsCfgSRS01:reset()
end







function A333_ewd_msg.SPD_BRK_CONFIG.WarningMonitor()

	local a = {E1 = ZPH9, E2 = ZPH1, E3 = ZPH2}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = SSPBR_1, E2 = SSPBR_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = ZPH3, E2 = ZPH4}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = WTOCT_2, E2 = a.S, E3 = b.S}
	d.S = bAND3(d.E1, d.E2, d.E3)

	local e = {E1 = b.S, E2 = c.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = bNOT(b.S), E2 = ZPH5}
	f.S = bOR(f.E1, f.E2)

	logic.spdBrkCfgSRS01:update(e.S, f.S)

	local g = {E1 = b.S, E2 = a.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = d.S, E2 = e.S}
	h.S = bOR(h.E1, h.E2)

	local i = {E1 = d.S, E2 = logic.spdBrkCfgSRS01.Q}
	i.S = bOR(i.E1, i.E2)

	SSBNTO = g.S

	A333_ewd_msg.SPD_BRK_CONFIG.Monitor.audio.IN = bool2num[h.S]
	A333_ewd_msg.SPD_BRK_CONFIG.Monitor.video.IN = bool2num[i.S]
	A333_fws_trigger_reset(A333_ewd_msg.SPD_BRK_CONFIG.Name)
	A333_ewd_msg.SPD_BRK_CONFIG.Monitor.video.INlast = A333_ewd_msg.SPD_BRK_CONFIG.Monitor.video.IN

end

function A333_ewd_msg.SPD_BRK_CONFIG.Reset()
	logic.spdBrkCfgSRS01:reset()
end







function A333_ewd_msg.PITCH_TRIM_CONFIG.WarningMonitor()

	local a = {E1 = ZPH9, E2 = ZPH1, E3 = ZPH2}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = SPCT1A330, E2 = SPCT2A330}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = ZPH3, E2 = ZPH4}
	c.S = bOR(c.E1, c.E2)

	local g = {E1 = WTOCT_2, E2 = a.S, E3 = b.S}
	g.S = bAND3(g.E1, g.E2, g.E3)

	local h = {E1 = b.S, E2 = c.S}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = bNOT(b.S), E2 = ZPH5}
	i.S = bOR(i.E1, i.E2)

	logic.pitchCfgSRS01:update(h.S, i.S)

	local j = {E1 = b.S, E2 = a.S}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = g.S, E2 = h.S}
	k.S = bOR(k.E1, k.E2)

	local l = {E1 = g.S, E2 = logic.pitchCfgSRS01.Q}
	l.S = bOR(l.E1, l.E2)

	SPTNTO = j.S

	A333_ewd_msg.PITCH_TRIM_CONFIG.Monitor.audio.IN = bool2num[k.S]
	A333_ewd_msg.PITCH_TRIM_CONFIG.Monitor.video.IN = bool2num[l.S]
	A333_fws_trigger_reset(A333_ewd_msg.PITCH_TRIM_CONFIG.Name)
	A333_ewd_msg.PITCH_TRIM_CONFIG.Monitor.video.INlast = A333_ewd_msg.PITCH_TRIM_CONFIG.Monitor.video.IN

end

function A333_ewd_msg.PITCH_TRIM_CONFIG.Reset()
	logic.pitchCfgSRS01:reset()
end







function A333_ewd_msg.RUDDER_TRIM_CONFIG.WarningMonitor()

	local a = {E1 = ZPH9, E2 = ZPH1, E3 = ZPH2}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = ZPH3, E2 = ZPH4}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = WTOCT_2, E2 = a.S, E3 = SRUDTC}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = SRUDTC, E2 = b.S}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = bNOT(SRUDTC), E2 = ZPH5}
	e.S = bOR(e.E1, e.E2)

	logic.rudTrimCfgSRS01:update(d.S, e.S)

	local f = {E1 = SRUDTC, E2 = a.S}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = c.S, E2 = d.S}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = c.S, E2 = logic.rudTrimCfgSRS01.Q}
	h.S = bOR(h.E1, h.E2)

	SRUDTNTO = f.S

	A333_ewd_msg.RUDDER_TRIM_CONFIG.Monitor.audio.IN = bool2num[g.S]
	A333_ewd_msg.RUDDER_TRIM_CONFIG.Monitor.video.IN = bool2num[h.S]
	A333_fws_trigger_reset(A333_ewd_msg.RUDDER_TRIM_CONFIG.Name)
	A333_ewd_msg.RUDDER_TRIM_CONFIG.Monitor.video.INlast = A333_ewd_msg.RUDDER_TRIM_CONFIG.Monitor.video.IN

end

function A333_ewd_msg.RUDDER_TRIM_CONFIG.Reset()
	logic.rudTrimCfgSRS01:reset()
end




function A333_ewd_msg.PARK_BRK_ON_CONFIG.WarningMonitor()

	local a = {E1 = ZPH3, E2 = ZPH4}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = a.S, E2 = GPBRKON}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = bNOT(GPBRKON), E2 = ZPH5}
	c.S = bOR(c.E1, c.E2)

	logic.prkBrkCfgSRS01:update(b.S, c.S)

	A333_ewd_msg.PARK_BRK_ON_CONFIG.Monitor.audio.IN = bool2num[b.S]
	A333_ewd_msg.PARK_BRK_ON_CONFIG.Monitor.video.IN = bool2num[logic.prkBrkCfgSRS01.Q]
	A333_fws_trigger_reset(A333_ewd_msg.PARK_BRK_ON_CONFIG.Name)
	A333_ewd_msg.PARK_BRK_ON_CONFIG.Monitor.video.INlast = A333_ewd_msg.PARK_BRK_ON_CONFIG.Monitor.video.IN

end

function A333_ewd_msg.PARK_BRK_ON_CONFIG.Reset()
	logic.prkBrkCfgSRS01:reset()
end






function A333_ewd_msg.EXCESS_CAB_ALT.WarningMonitor()

	local a = {E1 = PEXCA_1, E2 = PEXCA_2}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = PEXCA_3, E2 = bNOT(ZGND), E3 = PAS12F}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	logic.excessCabAltConf01:update(c.S)

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

	local a = {E1 = JR1OLP, E2 = bNOT(JR1NORUN), E3 = JTML1ON, E4 = WRRT}
	a.S = bAND4(a.E1, a.E2, a.E3, a.EE4)

	logic.eng1oilLoPrFConf01:update(a.S)

	A333_ewd_msg.ENG_1_OIL_LO_PR.Monitor.audio.IN = bool2num[logic.eng1oilLoPrFConf01.OUT]
	A333_ewd_msg.ENG_1_OIL_LO_PR.Monitor.video.IN = bool2num[logic.eng1oilLoPrFConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_1_OIL_LO_PR.Name)
	A333_ewd_msg.ENG_1_OIL_LO_PR.Monitor.video.INlast = A333_ewd_msg.ENG_1_OIL_LO_PR.Monitor.video.IN

end

function A333_ewd_msg.ENG_1_OIL_LO_PR.Reset()
	logic.eng1oilLoPrFConf01:resetTimer()
end



function A333_ewd_msg.ENG_2_OIL_LO_PR.WarningMonitor()

	local a = {E1 = JR2OLP, E2 = bNOT(JR2NORUN), E3 = JTML2ON, E4 = WRRT}
	a.S = bAND4(a.E1, a.E2, a.E3, a.EE4)

	logic.eng2oilLoPrFConf01:update(a.S)

	A333_ewd_msg.ENG_2_OIL_LO_PR.Monitor.audio.IN = bool2num[logic.eng2oilLoPrFConf01.OUT]
	A333_ewd_msg.ENG_2_OIL_LO_PR.Monitor.video.IN = bool2num[logic.eng2oilLoPrFConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_2_OIL_LO_PR.Name)
	A333_ewd_msg.ENG_2_OIL_LO_PR.Monitor.video.INlast = A333_ewd_msg.ENG_2_OIL_LO_PR.Monitor.video.IN

end

function A333_ewd_msg.ENG_2_OIL_LO_PR.Reset()
	logic.eng2oilLoPrFConf01:resetTimer()
end






function A333_ewd_msg.L_R_ELEV_FAULT.WarningMonitor()

	local a = {E1 = SLELVBA_1_VAL, E2 = bNOT(SLELVBA_1)}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = SLELVBA_2_VAL, E2 = bNOT(SLELVBA_2)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = SLELVGA_1_VAL, E2 = bNOT(SLELVGA_1)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = SLELVGA_2_VAL, E2 = bNOT(SLELVGA_2)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = SRELVBA_1_VAL, E2 = bNOT(SRELVBA_1)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = SRELVBA_2_VAL, E2 = bNOT(SRELVBA_2)}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = SRELVYA_1_VAL, E2 = bNOT(SRELVYA_1)}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = SRELVYA_2_VAL, E2 = bNOT(SRELVYA_2)}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = a.S, E2 = b.S}
	i.S = bOR(i.E1, i.E2)

	local j = {E1 = c.S, E2 = d.S}
	j.S = bOR(j.E1, j.E2)

	local k = {E1 = e.S, E2 = f.S}
	k.S = bOR(k.E1, k.E2)

	local l = {E1 = g.S, E2 = h.S}
	l.S = bOR(l.E1, l.E2)

	local m = {E1 = ZPH1, E2 = ZPH10}
	m.S = bOR(m.E1, m.E2)

	local n = {E1 = i.S, E2 = j.S, E3 = k.S, E4 = l.S, E5 = m.S}
	n.S = bAND5(n.E1, n.E2, n.E3, n.E4, n.E5)

	logic.lrElevFltConf01:update(n.S)

	SLRELVFT = n.S
	WWLRELVFT = n.S

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

	local a = {E1 = bNOT(NRADH_1_NCD), E2 = logic.lgNotDnAltThreshold01.out, E3 = bNOT(NRADH_1_INV)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = bNOT(NRADH_2_INV), E2 = logic.lgNotDnAltThreshold02.out, E3 = bNOT(NRADH_2_NCD)}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = NRADH_1_NCD, E2 = NRADH_1_INV}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = NRADH_2_NCD, E2 = NRADH_2_INV}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = NRADH_2_INV, E2 = NRADH_1_INV}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = d.S, E2 = e.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = SFLPSD, E2 = bNOT(SFLPSF)}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = GLGCIU1FT, E2 = GLGCIU2FT}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = f.S, E2 = h.S}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = SFLPSF, E2 = g.S}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = bNOT(GLGDNLKD), E2 = bNOT(i.S)}
	l.S = bAND(l.E1, l.E2)

	local m = {E1 = bNOT(ZR1O2TOPWR), E2 = JRN1AP}
	m.S = bAND(m.E1, m.E2)

	local n = {E1 = j.S, E2 = k.S}
	n.S = bOR(n.E1, n.E2)

	local o = {E1 = SFLPDSLTC, E2 = bNOT(ZR1O2TOPWR), E3 = c.S, E4 = l.S}
	o.S = bAND4(o.E1, o.E2, o.E3, o.E4)

	logic.lgNotDnPulse01:update(o.S)

	local p = {E1 = l.S, E2 = bNOT(ZPH5), E3 = ZPH6, E4 = n.S}
	p.S = bAND4(p.E1, p.E2, p.E3, p.E4)

	logic.lgNotDnPulse02:update(p.S)

	local q = {E1 = ZPH6, E2 = bNOT(g.S)}
	q.S = bAND(q.E1, q.E2)

	local r = {E1 = c.S, E2 = m.S, E3 = l.S}
	r.S = bAND3(r.E1, r.E2, r.E3)

	local s = {E1 = q.S, E2 = ZPH4, E3 = ZPH5 }
	s.S = bOR3(a.E1, s.E2, s.E3)

	local t = {E1 = o.S, E2 = p.S}
	t.S = bOR(t.E1, t.E2)

	local u = {E1 = bNOT(logic.lgNotDnPulse01.OUT), E2 = t.S, E3 = bNOT(logic.lgNotDnPulse02.OUT)}
	u.S = bAND3(u.E1, u.E2, u.E3)

	local v = {E1 = u.S, E2 = r.S}
	v.S = bOR(v.E1, v.E2)

	local w = {E1 = v.S, E2 = bNOT(s.S)}
	w.S = bAND(w.E1, w.E2)

	GLGNDNE		= u.S
	WBRACSW		= w.S
	WRACSW_S	= w.S
	GLGNDOWN	= r.S

	A333_ewd_msg.GEAR_NOT_DOWN.Monitor.audio.IN = bool2num[u.S]
	A333_ewd_msg.GEAR_NOT_DOWN.Monitor.video.IN = bool2num[u.S]

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





--| AP OFF UNVOLUNTARY
function A333_ewd_msg.AP_OFF_UNVOLUNTARY.WarningMonitor()

	local a = {E1 = ZPH1, E2 = HBSLP, E3 = HYSLP, E4 = HGSLP}
	a.S = bAND4(a.E1, a.E2, a.E3, a.E4)

	local b = {E1 = KID1APE, E2 = KID2APE}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = KAP1EC_1, E2 = KAP1EM_1}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = KAP2EC_2, E2 = KAP2EM_2}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = WCMWC, E2 = WFOMWC}
	e.S = bOR(e.E1, e.E2)

	local ee = {E1 = c.S, E2 = d.S}
	ee.S = bOR(ee.E1, ee.E2)

	local f = {E1 = e.S, E2 = KCCE}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = bNOT(ee.S), E2 = f.S}
	g.S = bAND(g.E1, g.E2)

	logic.APoffUnvPulse03:update(b.S)

	local h = {E1 = logic.APoffUnvPulse03.OUT, E2 = bNOT(ee.S)}
	h.S = bAND(h.E1, h.E2)

	logic.APoffUnvPulse01:update(ZPH1)
	logic.APoffUnvPulse04:update(ee.S)

	local i = {E1 = logic.APoffUnvPulse04.OUT, E2 = logic.APoffUnvPulse01.OUT}
	i.S = bOR(i.E1, i.E2)

	logic.APoffUnvMtrig01:update(KID1APE)
	logic.APoffUnvMtrig02:update(KID2APE)

	local j = {E1 = logic.APoffUnvMtrig01.OUT, E2 = logic.APoffUnvMtrig02.OUT}
	j.S = bOR(j.E1, j.E2)

	logic.APoffUnvPulse02:update(ee.S)

	local k = {E1 = bNOT(a.S), E2 = bNOT(j.S), E3 = logic.APoffUnvPulse02.OUT}
	k.S = bAND3(k.E1, k.E2, k.E3)

	logic.APoffUnvPulse05:update(g.S)
	logic.APoffUnvSRr01:update(k.S, i.S)

	local l = {E1 = h.S, E2 = logic.APoffUnvPulse05.OUT}
	l.S = bOR(l.E1, l.E2)

	logic.APoffUnvPulse06:update(logic.APoffUnvSRr01.Q)
	logic.APoffUnvMtrig03:update(logic.APoffUnvPulse06.OUT)

	local m = {E1 = bNOT(logic.APoffUnvMtrig03.OUT), E2 = l.S}
	m.S = bAND(m.E1, m.E2)

	local n = {E1 = i.S, E2 = m.S}
	n.S = bOR(n.E1, n.E2)

	local o = {E1 = WAPOT, E2 = logic.APoffUnvSRr01.Q}
	o.S = bOR(o.E1, o.E2)

	logic.APoffUnvSRr02:update(logic.APoffUnvPulse06.OUT, n.S)

	WWAPOFW = o.S
	KAPUNVOFF = logic.APoffUnvSRr01.Q
	KAPOR = m.S
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







--| AP OFF MW - UNVOLUNTARY
function A333_ewd_msg.AP_OFF_MW_UNVOLUNTARY.WarningMonitor()

	logic.APoffMWpulse01:update(KAPUNVOFF)
	logic.APoffMWpulse02:update(ZPH1)

	local a = {E1 = KAPOR, E2 = KAPMW, E3 = logic.APoffMWpulse02.OUT}
	a.S = bOR3(a.E1, a.E2, a.E3)

	logic.APoffMWSRr01:update(logic.APoffMWpulse01.OUT, a.S)

	if a.S then
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


--| AP OFF MW - VOLUNTARY
function A333_ewd_msg.AP_OFF_MW_VOLUNTARY.WarningMonitor()

	if KAPOMW then
		if not(is_timer_scheduled(AP_OFF_MW_VOLUNTARY_OFF)) then
			run_after_time(AP_OFF_MW_VOLUNTARY_OFF, 3.1)
		end
	end

end





--| AP OFF AUDIO - VOLUNTARY
function A333_ewd_msg.CAVALRY_CHARGE_VOLUNTARY_DISC.WarningMonitor()

	A333_ewd_msg.CAVALRY_CHARGE_VOLUNTARY_DISC.Monitor.audio.IN = bool2num[KAPOA]

	--see ecam_fws710 Ln 226 for control

end





--| AP OFF TEXT - VOLUNTARY
function A333_ewd_msg.AP_OFF_TEXT.WarningMonitor()

	A333_ewd_msg.AP_OFF_TEXT.Monitor.video.IN = bool2num[WAPOT]
	WWAPOV = WAPOT

end







function A333_ewd_msg.FWD_CARGO_SMOKE.WarningMonitor()

	local a = {E1 = USFLC_1, E2 = USFLC_2}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = UFCSDI_1, E2 = UFCSDI_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = c.S, E2 = toboolean(A333_cargo_fire_test)}
	d.S = bOR(d.E1, d.E2)

	UFCSDI = b.S

	A333_ewd_msg.FWD_CARGO_SMOKE.Monitor.audio.IN = bool2num[d.S]
	A333_ewd_msg.FWD_CARGO_SMOKE.Monitor.video.IN = bool2num[d.S]

end

function A333_ewd_msg.FWD_CARGO_SMOKE.Reset()
	A333_ewd_msg.FWD_CARGO_SMOKE.ActionReset()
end





function A333_ewd_msg.AFT_CARGO_SMOKE.WarningMonitor()

	local a = {E1 = USALC_1, E2 = USALC_2}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = UACSDI_1, E2 = UACSDI_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = c.S, E2 = toboolean(A333_cargo_fire_test)}
	d.S = bOR(d.E1, d.E2)

	UACSDI = b.S

	A333_ewd_msg.AFT_CARGO_SMOKE.Monitor.audio.IN = bool2num[d.S]
	A333_ewd_msg.AFT_CARGO_SMOKE.Monitor.video.IN = bool2num[d.S]

end

function A333_ewd_msg.AFT_CARGO_SMOKE.Reset()
	A333_ewd_msg.AFT_CARGO_SMOKE.ActionReset()
end













function A333_ewd_msg.ELEC_EMER_CONFIG.WarningMonitor()

	local a = {E1 = EGN1PBOF, E2 = ENG1INOP}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = EGN2PBOF, E2 = ENG2INOP}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = EAPUGNPBOF, E2 = ENG3INOP, E3 = bNOT(QAVAIL)}
	c.S = bOR3(c.E1, c.E1, c.E3)

	local d = {E1 = EAC1OF, E2 = EAC2OF}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = bNOT(EEPWRCON), E2 = a.S, E3 = b.S, E4 = c.S}
	e.S = bAND4(e.E1, e.E2, e.E3, e.E4)

	local f = {E1 = e.S, E2 = d.S}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = bNOT(WENA330EMERC), E2 = bNOT(USKD), E3 = f.S, E4 = bNOT(JENGSOUT), E5 = WA330}
	g.S = bAND5(g.E1, g.E2, g.E3, g.E4, g.E5)

	EEMER = f.S

	A333_ewd_msg.ELEC_EMER_CONFIG.Monitor.audio.IN = bool2num[g.S]
	A333_ewd_msg.ELEC_EMER_CONFIG.Monitor.video.IN = bool2num[g.S]

end







function A333_ewd_msg.HYD_BY_SYS_LO_PR.WarningMonitor()

	local a = {E1 = HBSYSLP, E2 = HYSYSLP}
	a.S = bAND(a.E1, a.E2)

	HBYLP = a.S

	A333_ewd_msg.HYD_BY_SYS_LO_PR.Monitor.audio.IN = bool2num[a.S]
	A333_ewd_msg.HYD_BY_SYS_LO_PR.Monitor.video.IN = bool2num[a.S]

end






function A333_ewd_msg.HYD_GB_SYS_LO_PR.WarningMonitor()

	local a = {E1 = HGSYSLP, E2 = HBSYSLP}
	a.S = bAND(a.E1, a.E2)

	HBGLP = a.S

	A333_ewd_msg.HYD_GB_SYS_LO_PR.Monitor.audio.IN = bool2num[a.S]
	A333_ewd_msg.HYD_GB_SYS_LO_PR.Monitor.video.IN = bool2num[a.S]

end






function A333_ewd_msg.HYD_GY_SYS_LO_PR.WarningMonitor()

	local a = {E1 = HGSYSLP, E2 = HYSYSLP}
	a.S = bAND(a.E1, a.E2)

	HYGLP = a.S

	A333_ewd_msg.HYD_GY_SYS_LO_PR.Monitor.audio.IN = bool2num[a.S]
	A333_ewd_msg.HYD_GY_SYS_LO_PR.Monitor.video.IN = bool2num[a.S]

end






function A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.WarningMonitor()

	local aa = {E1 = GELLGCOMPR, E2 = EEMER}
	aa.S = bAND(aa.E1, aa.E2)

	local bb = {E1 = ZGND, E2 = aa.S}
	bb.S = bOR(bb.E1, bb.E2)

	ZGNDRU = bb.S

	local a = {E1 = JR1IDLE_1A, E2 = JR1IDLE_1B}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = GW1SGT_1, E2 = GW1SGT_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = a.S, E2 = bNOT(ZPH4)}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = ZPH7, E2 = b.S}
	d.S = bAND(d.E1, d.E2)

	logic.eng1RevUnlkConf01:update(JR1TLREV)

	local e = {E1 = logic.eng1RevUnlkConf01.OUT, E2 = ZGNDRU}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = c.S, E2 = WRRT, E3 = JR1RUSTWD, E4 = bNOT(d.S), E5 = bNOT(ZPH8), E6 = bNOT(e.S)}
	f.S = bAND6(f.E1, f.E2, f.E3, f.E4, f.E5, f.E6)

	local g = {E1 = a.S, E2 = f.S}
	g.S = bAND(g.E1, g.E2)

	JR1REVUNLK = g.S
	JR1REVULK = f.S

	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.Monitor.audio.IN = bool2num[f.S]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.Monitor.video.IN = bool2num[f.S]
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

	local a = {E1 = JR2IDLE_2A, E2 = JR2IDLE_2B}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = GW1SGT_1, E2 = GW1SGT_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = a.S, E2 = bNOT(ZPH4)}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = ZPH7, E2 = b.S}
	d.S = bAND(d.E1, d.E2)

	logic.eng2RevUnlkConf01:update(JR2TLREV)

	local e = { E1 = logic.eng2RevUnlkConf01.OUT, E2 = ZGNDRU}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = c.S, E2 = WRRT, E3 = JR2RUSTWD, E4 = bNOT(d.S), E5 = bNOT(ZPH8), E6 = bNOT(e.S)}
	f.S = bAND6(f.E1, f.E2, f.E3, f.E4, f.E5, f.E6)

	local g = {E1 = a.S, E2 = f.S}
	g.S = bAND(g.E1, g.E2)

	JR2REVUNLK = g.S
	JR2REVULK = f.S

	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.Monitor.audio.IN = bool2num[f.S]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.Monitor.video.IN = bool2num[f.S]
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

	local a = {E1 = JR1AIDLE_1B, E2 = JR1AIDLE_1A}
	a.S = bOR(a.E1, a. E2)

	logic.eng1failConf01:update(a.S)

	local b = {E1 = JR1AIDLE_1A_INV, E2 = JR1AIDLE_1B_INV}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = bNOT(JR1AIDLE_1A), E2 = bNOT(JR1AIDLE_1B)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = bNOT(JML1ON), E2 = UE1FPBOUT}
	d.S = bOR(d.E1, d.E2)

	logic.eng1failSRR01:update(logic.eng1failConf01.OUT, d.S)

	local e = {E1 = a.S, E2 = JENGSOUT}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = JML1ON, E2 = bNOT(UE1FPBOUT), E3 = WRRT, E4 = bNOT(b.S), E5 = c.S, E6 = logic.eng1failSRR01.Q}
	f.S = bAND6(f.E1, f.E2, f.E3, f.E4, f.E5, f.E6)

	logic.eng1failSRR02:update(f.S, e.S)

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

	local a = {E1 = bNOT(JML1ON), E2 = ZPH10, E3 = ZPH1}
	a.S = bOR3(a.E1, a.E1, a.E3)

	local b = {E1 = logic.eng1oilHiTempConf01.OUT, E2 = JR1OOT}
	b.S = bOR(b.E1, b.E2)

	logic.eng1oilHiTempConf02:update(b.S)
	logic.eng1oilHiTempSRR01:update(logic.eng1oilHiTempConf02.OUT, a.S)

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

	local a = {E1 = ZPH1, E2 = ZPH2, E3 = ZPH9, E4 = ZPH10}
	a.S = bOR4(a.E1, a.E2, a.E3, a.E4)

	local b = {E1 = a.S, E2 = bNOT(ZGND)}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = bNOT(JML1ON), E2 = JML1OFF, E3 = bNOT(a.S)}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = b.S, E2 = UE1FPBOUT}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = c.S, E2 = d.S}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = e.S, E2 = bNOT(JENGSOUT), E3 = WRRT}
	f.S = bAND3(f.E1, f.E2, f.E3)

	local g = {E1 = bNOT(JR1FAIL), E2 = f.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = f.S, E2 = JR1FAIL}
	h.S = bOR(h.E1, h.E2)

	JR1SD	= f.S
	JR1OUT	= JR1FAIL

	A333_ewd_msg.ENG_1_SHUT_DOWN.Monitor.audio.IN = bool2num[g.S]
	A333_ewd_msg.ENG_1_SHUT_DOWN.Monitor.video.IN = bool2num[f.S]

end



function A333_ewd_msg.ENG_2_FAIL.WarningMonitor()

	local a = {E1 = JR2AIDLE_2B, E2 = JR2AIDLE_2A}
	a.S = bOR(a.E1, a.E2)

	logic.eng2failConf01:update(a.S)

	local b = {E1 = JR2AIDLE_2A_INV, E2 = JR2AIDLE_2B_INV}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = bNOT(JR2AIDLE_2A), E2 = bNOT(JR2AIDLE_2B)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = bNOT(JML2ON), E2 = UE2FPBOUT}
	d.S = bOR(d.E1, d.E2)

	logic.eng2failSRR01:update(logic.eng2failConf01.OUT, d.S)

	local e = {E1 = a.S, E2 = JENGSOUT}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = JML2ON, E2 = bNOT(UE2FPBOUT), E3 = WRRT, E4 = bNOT(b.S), E5 = c.S, E6 = logic.eng2failSRR01.Q}
	f.S = bAND6(f.E1, f.E2, f.E3, f.E4, f.E5, f.E6)

	logic.eng2failSRR02:update(f.S, e.S)

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

	logic.eng2oilHiTempConf01:update(JR2OTAD)

	local a = {E1 = bNOT(JML2ON), E2 = ZPH10, E3 = ZPH1}
	a.S = bOR3(a.E1, a.E1, a.E3)

	local b = {E1 = logic.eng2oilHiTempConf01.OUT, E2 = JR2OOT}
	b.S = bOR(b.E1, b.E2)

	logic.eng2oilHiTempConf02:update(b.S)
	logic.eng2oilHiTempSRR01:update(logic.eng2oilHiTempConf02.OUT, a.S)

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

	local a = {E1 = ZPH1, E2 = ZPH2, E3 = ZPH9, E4 = ZPH10}
	a.S = bOR4(a.E1, a.E2, a.E3, a.E4)

	local b = {E1 = a.S, E2 = bNOT(ZGND)}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = bNOT(JML2ON), E2 = JML2OFF, E3 = bNOT(a.S)}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = b.S, E2 = UE2FPBOUT}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = c.S, E2 = d.S}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = e.S, E2 = bNOT(JENGSOUT), E3 = WRRT}
	f.S = bAND3(f.E1, f.E2, f.E3)

	local g = {E1 = bNOT(JR2FAIL), E2 = f.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = f.S, E2 = JR1FAIL}
	h.S = bOR(h.E1, h.E2)

	JR2SD	= f.S
	JR2OUT	= JR2FAIL

	A333_ewd_msg.ENG_2_SHUT_DOWN.Monitor.audio.IN = bool2num[g.S]
	A333_ewd_msg.ENG_2_SHUT_DOWN.Monitor.video.IN = bool2num[f.S]

end






function A333_ewd_msg.ENG_1_HUNG_START.WarningMonitor()

	logic.eng1hungStrtPulse01:update(JML1ON)

	local a = {E1 = JR1HGST_1A, E2 = true}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = JR1HGST_1B, E2 = true}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = JR1MANST_1A, E2 = JR1MANST_1B, E3 = JR1AUTOST_1A, E4 = JR1AUTOST_1B}
	c.S = bOR4(c.E1, c.E2, c.E3, c.E4)

	local d = {E1 = JR1AIDLE_1A, E2 = JR1AIDLE_1B}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = a.S, E2 = b.S}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = d.S, E2 = logic.eng1hungStrtPulse01.OUT}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = WRRT, E2 = e.S}
	g.S = bAND(g.E1, g.E2)

	logic.eng1hungStrtSRR01:update(g.S, f.S)

	local h = {E1 = c.S, E2 = WRRT}
	h.S = bAND(h.E1, h.E2)

	JR1START = h.S

	A333_ewd_msg.ENG_1_HUNG_START.Monitor.audio.IN = bool2num[logic.eng1hungStrtSRR01.Q]
	A333_ewd_msg.ENG_1_HUNG_START.Monitor.video.IN = bool2num[logic.eng1hungStrtSRR01.Q]

end




function A333_ewd_msg.ENG_2_HUNG_START.WarningMonitor()

	logic.eng2hungStrtPulse01:update(JML2ON)

	local a = {E1 = JR2HGST_2A, E2 = true}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = JR2HGST_2B, E2 = true}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = JR2MANST_1A, E2 = JR2MANST_1B, E3 = JR1AUTOST_1A, E4 = JR1AUTOST_1B}
	c.S = bOR4(c.E1, c.E2, c.E3, c.E4)

	local d = {E1 = JR2AIDLE_2A, E2 = JR2AIDLE_2B}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = a.S, E2 = b.S}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = d.S, E2 = logic.eng2hungStrtPulse01.OUT}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = WRRT, E2 = e.S}
	g.S = bAND(g.E1, g.E2)

	logic.eng2hungStrtSRR01:update(g.S, f.S)

	local h = {E1 = c.S, E2 = WRRT}
	h.S = bAND(h.E1, h.E2)

	JR2START = h.S

	A333_ewd_msg.ENG_2_HUNG_START.Monitor.audio.IN = bool2num[logic.eng2hungStrtSRR01.Q]
	A333_ewd_msg.ENG_2_HUNG_START.Monitor.video.IN = bool2num[logic.eng2hungStrtSRR01.Q]

end







function A333_ewd_msg.ENG_1_OIL_LO_TEMP.WarningMonitor()

	logic.eng1OilTmpThreshold01:update(JR1OT)
	logic.eng1OilTmpThreshold02:update(JR1OT)

	local a = { E1 = JR1OT_INV, E2 = JR1OT_NCD }
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = WTOCT_2, E2 = ZPH2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = logic.eng1OilTmpThreshold01.out, E2 = bNOT(a.S)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = logic.eng1OilTmpThreshold02.out, E2 = ZPH2, E3 = bNOT(a.S)}
	d.S = bAND3(d.E1, d.E2, d.E3)

	logic.eng1OilTmpConf01:update(d.S)

	local e = {E1 = b.S, E2 = c.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = ZPH1, E2 = ZPH6, E3 = ZPH9, E4 = bNOT(c.S)}
	f.S = bOR4(f.E1, f.E2, f.E3, f.E4)

	logic.eng1OilTmpSRS01:update(e.S, f.S)

	local g = {E1 = ZPH3, E2 = c.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = logic.eng1OilTmpSRS01.Q, E2 = g.S, E3 = logic.eng1OilTmpConf01.OUT}
	h.S = bOR3(h.E1, h.E2, h.E3)

	local i = {E1 = h.S, E2 = bNOT(JR1NORUN), E3 = WRRT}
	i.S = bAND3(i.E1, i.E2, i.E3)

	A333_ewd_msg.ENG_1_OIL_LO_TEMP.Monitor.audio.IN = bool2num[i.S]
	A333_ewd_msg.ENG_1_OIL_LO_TEMP.Monitor.video.IN = bool2num[i.S]
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

	local a = { E1 = JR2OT_INV, E2 = JR2OT_NCD }
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = WTOCT_2, E2 = ZPH2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = logic.eng2OilTmpThreshold01.out, E2 = bNOT(a.S)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = logic.eng2OilTmpThreshold02.out, E2 = ZPH2, E3 = bNOT(a.S)}
	d.S = bAND3(d.E1, d.E2, d.E3)

	logic.eng2OilTmpConf01:update(d.S)

	local e = {E1 = b.S, E2 = c.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = ZPH1, E2 = ZPH6, E3 = ZPH9, E4 = bNOT(c.S)}
	f.S = bOR4(f.E1, f.E2, f.E3, f.E4)

	logic.eng2OilTmpSRS01:update(e.S, f.S)

	local g = {E1 = ZPH3, E2 = c.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = logic.eng2OilTmpSRS01.Q, E2 = g.S, E3 = logic.eng2OilTmpConf01.OUT}
	h.S = bOR3(h.E1, h.E2, h.E3)

	local i = {E1 = h.S, E2 = bNOT(JR2NORUN), E3 = WRRT}
	i.S = bAND3(i.E1, i.E2, i.E3)

	A333_ewd_msg.ENG_2_OIL_LO_TEMP.Monitor.audio.IN = bool2num[i.S]
	A333_ewd_msg.ENG_2_OIL_LO_TEMP.Monitor.video.IN = bool2num[i.S]
	A333_fws_trigger_reset(A333_ewd_msg.ENG_2_OIL_LO_TEMP.Name)
	A333_ewd_msg.ENG_2_OIL_LO_TEMP.Monitor.video.INlast = A333_ewd_msg.ENG_2_OIL_LO_TEMP.Monitor.video.IN

end

function A333_ewd_msg.ENG_2_OIL_LO_TEMP.Reset()
	logic.eng2OilTmpConf01:resetTimer()
	logic.eng2OilTmpSRS01:reset()
end








function A333_ewd_msg.DC_EMER_CONFIG.WarningMonitor()

	local a = {E1 = EADCGNL, E2 = EDCSOF, E3 = bNOT(EEMER)}
	a.S = bAND(a.E1, a.E2, a.E3)

	EDCEC	= a.S

	A333_ewd_msg.DC_EMER_CONFIG.Monitor.audio.IN = bool2num[a.S]
	A333_ewd_msg.DC_EMER_CONFIG.Monitor.video.IN = bool2num[a.S]

end







function A333_ewd_msg.DC_BUS_1_2_OFF.WarningMonitor()

	local a = {E1 = EEMER, E2 = EDCEC}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = EDC1OF, E2 = EDC2OF, E3 = EDCEC}
	b.S = bAND3(b.E1, b.E2, b.E3)

	logic.dcBus12OffConf01:update(b.S)

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

	logic.gen1FaultConf01:update(EGN1COF)

	local a = {E1 = EIDG1D, E2 = EGN1PBOF}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = bNOT(JR1NORUN), E2 = EGN1COF}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = USKD, E2 = UG1LPBOF}
	c.S =  bAND(c.E1, c.E2)

	local d = {E1 = bNOT(a.S), E2 = b.S}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = logic.gen1FaultConf01.OUT, E2 = ZPH1, E3 = ZPH10, E4 = EEMER, E5 = c.S}
	e.S = bOR5(e.E1, e.E2, e.E3, e.E4, e.E5)

	logic.gen1FaultConf02:update(d.S)
	logic.gen1FaultSRR01:update(logic.gen1FaultConf02.OUT, e.S)

	ENG1INOP = b.S
	EG1FM = logic.gen1FaultSRR01.Q

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

	logic.gen2FaultConf01:update(EGN1COF)

	local a = {E1 = EIDG2D, E2 = EGN2PBOF}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = bNOT(JR2NORUN), E2 = EGN2COF}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = USKD, E2 = UG1LPBOF}
	c.S =  bAND(c.E1, c.E2)

	local d = {E1 = bNOT(a.S), E2 = b.S}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = logic.gen2FaultConf01.OUT, E2 = ZPH1, E3 = ZPH10, E4 = EEMER, E5 = c.S}
	e.S = bOR5(e.E1, e.E2, e.E3, e.E4, e.E5)

	logic.gen2FaultConf02:update(d.S)
	logic.gen2FaultSRR01:update(logic.gen2FaultConf02.OUT, e.S)

	ENG2INOP = b.S
	EG2FM = logic.gen2FaultSRR01.Q

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

	local a = {E1 = EAPUGNF, E2 = QAVAIL}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = bNOT(EAPUGNPBOF), E2 = bNOT(EAPUGNF), E3 = QAVAIL}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = bNOT(EAPUGNPBOF), E2 = a.S}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = b.S, E2 = ZPH1}
	d.S = bOR(d.E1, d.E2)

	logic.apuGenFaultConf01:update(d.S)
	logic.apuGenFaultConf02:update(c.S)
	logic.apuGenFaultSRR01:update(logic.apuGenFaultConf02.OUT, logic.apuGenFaultConf01.OUT)

	ENG3INOP = a.S
	EGAPUM = logic.apuGenFaultSRR01.Q

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

	local a = {E1 = logic.stdAltiDiscrepancyConf01.OUT, E2 = logic.stdAltiDiscrepancyConf02.OUT}
	a.S = bOR(a.E1, a.E2)

	WWALTSTDD = logic.stdAltiDiscrepancyConf01.OUT
	WWALTBD = logic.stdAltiDiscrepancyConf02.OUT

	A333_ewd_msg.ALTI_DISCREPANCY.Monitor.audio.IN = bool2num[a.S]
	A333_ewd_msg.ALTI_DISCREPANCY.Monitor.video.IN = bool2num[a.S]
	A333_fws_trigger_reset(A333_ewd_msg.ALTI_DISCREPANCY.Name)
	A333_ewd_msg.ALTI_DISCREPANCY.Monitor.video.INlast = A333_ewd_msg.ALTI_DISCREPANCY.Monitor.video.IN

	A333_pfd_check_alt = bool2num[a.S]

end

function A333_ewd_msg.ALTI_DISCREPANCY.Reset()
	logic.stdAltiDiscrepancyConf01:resetTimer()
	logic.stdAltiDiscrepancyConf02:resetTimer()
end






function A333_ewd_msg.DOORS_NOT_CLOSED.WarningMonitor()

	local a = {E1 = GLDNUPL_1_INV, E2 = GLDNUPL_2_INV}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = GLDNUPL_1, E2 = GLDNUPL_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = GLDNUPL_1, E2 = GLDNUPL_2}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = GRDNUPL_1_INV, E2 = GRDNUPL_2_INV}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = GRDNUPL_1, E2 = GRDNUPL_2}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = GRDNUPL_1, E2 = GRDNUPL_2}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = GLGNUP, E2 = GGNDNLD}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = GNDNUPL_1_INV, E2 =GNDNUPL_2_INV }
	h.S = bOR(h.E1, h.E2)

	local i = {E1 = GNDNUPL_1, E2 = GNDNUPL_2}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = GNDNUPL_1, E2 = GNDNUPL_2}
	j.S = bOR(j.E1, j.E2)

	local k = {E1 = a.S, E2 = c.S}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = d.S, E2 = f.S}
	l.S = bAND(l.E1, l.E2)

	local m = {E1 = h.S, E2 = j.S}
	m.S = bAND(m.E1, m.E2)

	local n = {E1 = b.S, E2 = k.S}
	n.S = bOR(n.E1, n.E2)

	local o = {E1 = e.S, E2 = l.S}
	o.S = bOR(o.E1, o.E2)

	local p = {E1 = i.S, E2 = m.S}
	p.S = bOR(p.E1, p.E2)

	local q = {E1 = n.S, E2 = o.S, E3 = p.S}
	q.S = bOR3(q.E1, q.E2, q.E3)

	logic.doorNotClsdConf01:update(q.S)

	local r = {E1 = logic.doorNotClsdConf01.OUT, E2 = bNOT(g.S)}
	r.S = bAND(r.E1, r.E2)

	local s = {E1 = bNOT(n.S), E2 = bNOT(o.S), E3 = bNOT(p.S)}
	s.S = bAND3(s.E1, s.E2, s.E3)

	logic.doorNotClsdSRR01:update(r.S, s.S)

	local t = {E1 = n.S, E2 = p.S, E3 = o.S}
	t.S = bAND3(t.E1, t.E2, t.E3)

	GODNC	= logic.doorNotClsdConf01.OUT
	GDNC	= logic.doorNotClsdSRR01.Q
	GADNC	= t.S
	GNDNU 	= p.S

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

	local a = {E1 = GLGDNLKD, E2 = GLGNLKD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = bNOT(HTHOUT), E2 = a.S, E3 = logic.lgNotUpLckConf01.OUT}
	b.S = bAND3(b.E1, b.E1, b.E3)

	logic.lgNotUpLckSRR01:update(b.S, logic.lgNotUpLckConf02.OUT)

	GLGNUP	= b.S
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

	local a = {E1 = GLGUWGD_1, E2 = GLGUWGD_2}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = GRGUWGD_1, E2 = GRGUWGD_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = GNGUWGD_1, E2 = GNGUWGD_2}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S, E3 = c.S}
	d.S = bOR3(d.E1, d.E2, d.E3)

	GGUPENG	= d.S

	A333_ewd_msg.GEAR_NOT_UPLOCKED.Monitor.audio.IN = bool2num[d.S]
	A333_ewd_msg.GEAR_NOT_UPLOCKED.Monitor.video.IN = bool2num[d.S]

end



function A333_ewd_msg.SHOCK_ABSORBER_FAULT.WarningMonitor()

	local a = {E1 = ZPH5, E2 = ZPH6}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = ZPH10, E2 = ZPH9}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = GLGNE, E2 = a.S, E3 = bNOT(EEMER)}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d ={E1 = GRETIN_1_INV, E2 = GRETIN_2_INV}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = GRETIN_1, E2 = GRETIN_2}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = GRETIN_1, E2 = GRETIN_2}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = GLGEXT, E2 = b.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = d.S, E2 = f.S}
	h.S = bAND(h.E1, h.E2)

	logic.lgShockAbsConf01:update(c.S)
	logic.lgShockAbsConf02:update(g.S)

	local i = {E1 =e.S, E2 = h.S}
	i.S = bOR(i.E1, i.E2)

	local j = {E1 = i.S, E2 = logic.lgShockAbsConf01.OUT}
	j.S = bOR(j.E1, j.E2)

	local k = {E1 = j.S, E2 = logic.lgShockAbsConf02.OUT}
	k.S = bOR(k.E1, k.E2)

	GSAF = j.S

	A333_ewd_msg.SHOCK_ABSORBER_FAULT.Monitor.audio.IN = bool2num[k.S]
	A333_ewd_msg.SHOCK_ABSORBER_FAULT.Monitor.video.IN = bool2num[k.S]
	A333_fws_trigger_reset(A333_ewd_msg.SHOCK_ABSORBER_FAULT.Name)
	A333_ewd_msg.SHOCK_ABSORBER_FAULT.Monitor.video.INlast = A333_ewd_msg.SHOCK_ABSORBER_FAULT.Monitor.video.IN

end

function A333_ewd_msg.SHOCK_ABSORBER_FAULT.Reset()
	logic.lgShockAbsConf01:resetTimer()
	logic.lgShockAbsConf02:resetTimer()
end







function A333_ewd_msg.BRAKES_HOT.WarningMonitor()

	local a = {E1 = GBRK1OVHT, E2 = GBRK2OVHT, E3 = GBRK3OVHT, E4 = GBRK4OVHT}
	a.S = bOR4(a.E1, a.E2, a.E3, a.E4)

	local b = {E1 = GBRK5OVHT, E2 = GBRK6OVHT, E3 = GBRK7OVHT, E4 = GBRK8OVHT}
	b.S = bOR4(b.E1, b.E2, b.E3, b.E4)

	local c = {E1 = GBI_1, E2 = GBI_2}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = b.S, E2 = c.S}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = a.S, E2 = d.S}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = DTOCTPH3, E2 = e.S}
	f.S = bAND(f.E1, f.E2)

	GBRKOVHT = e.S

	A333_ewd_msg.BRAKES_HOT.Monitor.audio.IN = bool2num[f.S]
	A333_ewd_msg.BRAKES_HOT.Monitor.video.IN = bool2num[f.S]

end







function A333_ewd_msg.L_R_WING_TK_LO_LVL.WarningMonitor()

	local a = {E1 = FLWLL, E2 = FRWLL}
	a.S = bAND(a.E1, a.E2)

	logic.lrWingLoLvlConf01:update(a.S)

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

	local a = {E1 = bNOT(EDCBSSCOF), E2 = FLWTLLA}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = FLWTLLB, E2 = bNOT(EDC2OF)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = bNOT(FLRWLL), E2 = c.S}
	d.S = bAND(d.E1, d.E2)

	logic.lWingLoLvlConf01:update(d.S)

	FLWLL = c.S

	A333_ewd_msg.L_WING_TK_LO_LVL.Monitor.audio.IN = bool2num[logic.lWingLoLvlConf01.OUT]
	A333_ewd_msg.L_WING_TK_LO_LVL.Monitor.video.IN = bool2num[logic.lWingLoLvlConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.L_WING_TK_LO_LVL.Name)
	A333_ewd_msg.L_WING_TK_LO_LVL.Monitor.video.INlast = A333_ewd_msg.L_WING_TK_LO_LVL.Monitor.video.IN

end

function A333_ewd_msg.L_WING_TK_LO_LVL.Reset()
	logic.lWingLoLvlConf01:resetTimer()
end



function A333_ewd_msg.R_WING_TK_LO_LVL.WarningMonitor()

	local a = {E1 = bNOT(EDC2OF), E2 = FRWTLLA}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = FRWTLLB, E2 = bNOT(EDCBSSCOF)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = bNOT(FLRWLL), E2 = c.S}
	d.S = bAND(d.E1, d.E2)

	logic.rWingLoLvlConf01:update(d.S)

	FRWLL = c.S

	A333_ewd_msg.R_WING_TK_LO_LVL.Monitor.audio.IN = bool2num[logic.rWingLoLvlConf01.OUT]
	A333_ewd_msg.R_WING_TK_LO_LVL.Monitor.video.IN = bool2num[logic.rWingLoLvlConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.R_WING_TK_LO_LVL.Name)
	A333_ewd_msg.R_WING_TK_LO_LVL.Monitor.video.INlast = A333_ewd_msg.R_WING_TK_LO_LVL.Monitor.video.IN

end

function A333_ewd_msg.R_WING_TK_LO_LVL.Reset()
	logic.rWingLoLvlConf01:resetTimer()
end










function A333_ewd_msg.X_BLEED_FAULT.WarningMonitor()

	local a = {E1 = UE1FPBOUT, E2 = bNOT(UE1FPBOUT)}
	a.S = UE1FPBOUT --bAND(a.E1, a.E2)

	logic.xbleedVlvFltConf03:update(a.S)

	local b = {E1 = BXFVOAD_1, E2 = BXFVOAD_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = b.S, E2 = bNOT(EDC2OF)}
	c.S = bAND(c.E1, c.E2)

	local e = {E1 = BXFVOMD_1, E2 = BXFVOMD_2}
	e.S = bOR(e.E1, e.E2)

	local d = {E1 = c.S, E2 = BXFVCD, E3 = e.S}
	d.S = bOR3(d.E1, d.E2, d.E3)

	logic.xbleedVlvFltConf01:update(d.S)
	logic.xbleedVlvFltConf02:update(logic.xbleedVlvFltConf01.OUT)

	local f = {E1 = bNOT(logic.xbleedVlvFltConf03.OUT), E2 = logic.xbleedVlvFltConf02.OUT}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = c.S, E2 = e.S}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = f.S, E2 = logic.xbleedVlvFltConf01.OUT}
	h.S = bOR(h.E1, h.E2)

	BXFDOD = g.S
	BXFDOMD = e.S

	A333_ewd_msg.X_BLEED_FAULT.Monitor.audio.IN = bool2num[h.S]
	A333_ewd_msg.X_BLEED_FAULT.Monitor.video.IN = bool2num[h.S]
	A333_fws_trigger_reset(A333_ewd_msg.X_BLEED_FAULT.Name)
	A333_ewd_msg.X_BLEED_FAULT.Monitor.video.INlast = A333_ewd_msg.X_BLEED_FAULT.Monitor.video.IN

end

function A333_ewd_msg.X_BLEED_FAULT.Reset()
	logic.xbleedVlvFltConf01:resetTimer()
	logic.xbleedVlvFltConf02:resetTimer()
	logic.xbleedVlvFltConf03:resetTimer()
end







function A333_ewd_msg.AI_ENG1_VALVE_CLOSED.WarningMonitor()

	local a = {E1 = IE1AIPBON, E2 = IE1AIVF, E3 = bNOT(JR1NORUN)}
	a.S = bAND(a.E1, a.E2)

	logic.eng1NacVlvClsdConf01:update(a.S)

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

	local a = {E1 = IE2AIPBON, E2 = IE2AIVF, E3 = bNOT(JR2NORUN)}
	a.S = bAND(a.E1, a.E2)

	logic.eng2NacVlvClsdConf01:update(a.S)

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

	local a = {E1 = bNOT(ILWAIVC), E2 = AB1AVAIL, E3 = IWAION}
	a.S = bAND3(a.Ea, a.E2, a.E3)

	local b = {E1 = bNOT(ZGND), E2 = IWAIPBON}
	b.S = bAND(b.E1, b.E2)

	logic.aiVlvClsdFltPulse01:update(b.S)

	local c = {E1 = ZGND, E2 = bNOT(logic.aiVlvClsdFltConf02.OUT)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = ILWAILP, E2 = ILWAIVC}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = a.S, E2 = logic.aiVlvClsdFltConf03.OUT}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = b.S, E2 = c.S}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = f.S, E2 = IWAIPBON, E3 = d.S, E4 = AB1AVAIL}
	g.S = bAND4(g.E1, g.E2, g.E3, g.E4)

	logic.aiVlvClsdFltConf01:update(g.S)
	logic.aiVlvClsdFltsrS01:update(logic.aiVlvClsdFltConf01.OUT, e.S)

	local h = {E1 = logic.aiVlvClsdFltsrS01.Q, E2 = IRVCLSDF}
	h.S = bOR(h.E1, h.E2)

	local i = {E1 = bNOT(logic.aiVlvClsdFltPulse01.OUT), E2 = h.S}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = i.S, E2 = IPROCWAIESD}
	j.S = bOR(j.E1, j.E2)

	ILVCLSDF = logic.aiVlvClsdFltsrS01.Q

	A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Monitor.audio.IN = bool2num[j.S]
	A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Monitor.video.IN = bool2num[j.S]
	A333_fws_trigger_reset(A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Name)
	A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Monitor.video.INlast = A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Monitor.video.IN

end

function A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Reset()
	logic.aiVlvClsdFltConf01:resetTimer()
	logic.aiVlvClsdFltConf02:resetTimer()
	logic.aiVlvClsdFltConf03:resetTimer()
	logic.aiVlvClsdFltsrS01:resetTimer()
end





function A333_ewd_msg.DOOR_L_FWD_CABIN.WarningMonitor()

	local a = {E1 = EDC1OF, E2 = ZPH1, E3 = ZPH10}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = DLFCDNC, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = b.S, E2 = DTOCTPH3}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.DOOR_L_FWD_CABIN.Monitor.audio.IN = bool2num[c.S]
	A333_ewd_msg.DOOR_L_FWD_CABIN.Monitor.video.IN = bool2num[c.S]

end






function A333_ewd_msg.DOOR_L_MID_CABIN.WarningMonitor()

	local a = {E1 = EDC1OF, E2 = ZPH1, E3 = ZPH10}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = DLMCDNC, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = b.S, E2 = DTOCTPH3}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.DOOR_L_MID_CABIN.Monitor.audio.IN = bool2num[c.S]
	A333_ewd_msg.DOOR_L_MID_CABIN.Monitor.video.IN = bool2num[c.S]

end






function A333_ewd_msg.DOOR_L_AFT_CABIN.WarningMonitor()

	local a = {E1 = EDC1OF, E2 = ZPH1, E3 = ZPH10}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = DLACDNC, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = b.S, E2 = DTOCTPH3}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.DOOR_L_AFT_CABIN.Monitor.audio.IN = bool2num[c.S]
	A333_ewd_msg.DOOR_L_AFT_CABIN.Monitor.video.IN = bool2num[c.S]

end






function A333_ewd_msg.DOOR_R_FWD_CABIN.WarningMonitor()

	local a = {E1 = EDC1OF, E2 = ZPH1, E3 = ZPH10}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = DRFCDNC, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = b.S, E2 = DTOCTPH3}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.DOOR_R_FWD_CABIN.Monitor.audio.IN = bool2num[c.S]
	A333_ewd_msg.DOOR_R_FWD_CABIN.Monitor.video.IN = bool2num[c.S]

end






function A333_ewd_msg.DOOR_R_MID_CABIN.WarningMonitor()

	local a = {E1 = EDC1OF, E2 = ZPH1, E3 = ZPH10}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = DRMCDNC, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = b.S, E2 = DTOCTPH3}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.DOOR_R_MID_CABIN.Monitor.audio.IN = bool2num[c.S]
	A333_ewd_msg.DOOR_R_MID_CABIN.Monitor.video.IN = bool2num[c.S]

end






function A333_ewd_msg.DOOR_R_AFT_CABIN.WarningMonitor()

	local a = {E1 = EDC1OF, E2 = ZPH1, E3 = ZPH10}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = DRACDNC, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = b.S, E2 = DTOCTPH3}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.DOOR_R_AFT_CABIN.Monitor.audio.IN = bool2num[c.S]
	A333_ewd_msg.DOOR_R_AFT_CABIN.Monitor.video.IN = bool2num[c.S]

end






function A333_ewd_msg.DOOR_L_EMER_EXIT.WarningMonitor()

	local a = {E1 = EDC1OF, E2 = ZPH1, E3 = ZPH10}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = DLEEDNC, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = b.S, E2 = DTOCTPH3}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.DOOR_L_EMER_EXIT.Monitor.audio.IN = bool2num[c.S]
	A333_ewd_msg.DOOR_L_EMER_EXIT.Monitor.video.IN = bool2num[c.S]

end






function A333_ewd_msg.DOOR_R_EMER_EXIT.WarningMonitor()

	local a = {E1 = EDC1OF, E2 = ZPH1, E3 = ZPH10}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = DREEDNC, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = b.S, E2 = DTOCTPH3}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.DOOR_R_EMER_EXIT.Monitor.audio.IN = bool2num[c.S]
	A333_ewd_msg.DOOR_R_EMER_EXIT.Monitor.video.IN = bool2num[c.S]

end







function A333_ewd_msg.DOOR_R_AVIONICS.WarningMonitor()		-- NOTE: THIS DOOR IS ACTUALLY NOT MODELED

	logic.rAvioPulse01:update(WTOCT_2)
	logic.rAvioPulse02:update(ZPH3)

	local a = {E1 = EDC2OF, E2 = ZPH1, E3 = ZPH10}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = DRAVDNC, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	logic.rAvioMtrig01:update(logic.rAvioPulse01.OUT)

	local c = {E1 = logic.rAvioMtrig01.OUT, E2 = logic.rAvioPulse02.OUT}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = b.S, E2 = bNOT(c.S)}
	d.S = bAND(d.E1, d.E2)

	DTOCTPH3 = bNOT(c.S)
	WTOCT = logic.rAvioMtrig01.OUT

	A333_ewd_msg.DOOR_R_AVIONICS.Monitor.audio.IN = bool2num[d.S]
	A333_ewd_msg.DOOR_R_AVIONICS.Monitor.video.IN = bool2num[d.S]

end








function A333_ewd_msg.TO_MEMO.WarningMonitor()

	local a = {E1 = ZPH2, E2 = ZPH9}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = bNOT(JR1NORUN), E2 = bNOT(JR2NORUN)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = a.S, E2 = WTOCT_2}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = ZPH10, E2 = ZPH3, E3 = ZPH1, E4 = ZPH6}
	d.S = bOR4(d.E1, d.E2, d.E3, d.E4)

	logic.toMemoConf01:update(b.S)
	logic.toMemoSRR01:update(c.S, d.S)

	local e = {E1 = ZPH2, E2 = logic.toMemoConf01.OUT}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = logic.toMemoSRR01.Q, E2 = e.S}
	f.S = bOR(f.E1, f.E2)

	ZTOMEMC = f.S

	A333_ewd_msg.TO_MEMO.Monitor.video.IN = bool2num[f.S]
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

	local a = {E1 = NRADH_1_INV, E2 = NRADH_1_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = NRADH_2_INV, E2 = NRADH_2_NCD}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = logic.ldgThresh01.out, E2 = bNOT(b.S)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = logic.ldgThresh02.out, E2 = bNOT(a.S)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = a.S, E2 = b.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = a.S, E2 = logic.ldgThresh03.out}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = b.S, E2 = logic.ldgThresh04.out}
	g.S = bOR(g.E1, g.E2)

	local h = {E1= NRADH_1_INV, E2 = NRADH_2_INV, E3 = GLGDNLKD, E4 = ZPH6}
	h.S = bAND4(h.E1, h.E2, h.E3, h.E4)

	local i = {E1 = c.S, E2 = d.S}
	i.S = bOR(i.E1, i.E2)

	local k = {E1 = f.S, E2 = g.S}
	k.S = bAND(k.E1, k.E2)

	local j = {E1 = bNOT(e.S), E2 = k.S}
	j.S = bAND(j.E1, j.E2)

	logic.ldgMemoConf01:update(j.S)
	logic.ldgMemoSRS01:update(i.S, k.S)
	logic.ldgMemoConf02:update(h.S)

	local n = {E1 = ZPH7, E2 = ZPH8, E3 = ZPH6}
	n.S = bOR3(n.E1, n.E2, n.E3)

	logic.ldgMemoSRR02:update(logic.ldgMemoConf01.OUT, bNOT(n.S))

	local l = {E1 = logic.ldgMemoSRR02.Q, E2 = logic.ldgMemoSRS01.Q, E3 = ZPH6}
	l.S = bAND3(l.E1, l.E2, l.E3)

	local m = {E1 = l.S, E2 = logic.ldgMemoConf02.OUT, E3 = ZPH8, E4 = ZPH7}
	m.S = bOR4(m.E1, m.E2, m.E3, m.E4)

	local o = {E1 = m.S, E2 = ZTOMEMC}
	o.S = bOR(o.E1, o.E2)

	ZLDGMEM = m.S
	ZCMEMC = o.S


	A333_ewd_msg.LDG_MEMO.Monitor.video.IN = bool2num[m.S]
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








function A333_ewd_msg.GND_SPLRS_ARMED.WarningMonitor()

	local a = {E1 = SGNDSPLRA_1, E2 = SGNDSPLRA_2}
	a.S = bOR(a.E1, a.E2)

	logic.gndSplrArmedConf01:update(a.S)

	local b = {E1 = SALLGSSI, E2 = ZTOMEMC, E3 = ZLDGMEM}
	b.S = bOR3(b.E1, b.E2, b.E3)

	local c = {E1 = logic.gndSplrArmedConf01.OUT, E2 = bNOT(b.S)}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.GND_SPLRS_ARMED.Monitor.video.IN = bool2num[c.S]

end




	
function A333_ewd_msg.ADIRS_ALIGN.WarningMonitor()
	-- AG330 ADIRS ALIGN announcement
	A333_ewd_msg.ADIRS_ALIGN.Monitor.video.IN = bool2num[ADRALGN]
	A333_ewd_msg.ADIRS_ALIGN.WarningTitle = (ADRTIME .. " MN")
end




function A333_ewd_msg.SEAT_BELTS.WarningMonitor()

	local a = {E1 = CFSBLT, E2 = bNOT(ZCMEMC)}
	a.S = bAND(a.E1, a.E2)

	A333_ewd_msg.SEAT_BELTS.Monitor.video.IN = bool2num[a.S]

end





function A333_ewd_msg.NO_SMOKING.WarningMonitor()

	local a = {E1 = CNOSMOK, E2 = bNOT(ZCMEMC)}
	a.S = bAND(a.E1, a.E2)

	A333_ewd_msg.NO_SMOKING.Monitor.video.IN = bool2num[a.S]

end





function A333_ewd_msg.STROBE_LT_OFF.WarningMonitor()

	local a = {E1 = LSLPBOF, E2 = bNOT(ZCMEMC), E3 = bNOT(ZGND)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	A333_ewd_msg.STROBE_LT_OFF.Monitor.video.IN = bool2num[a.S]

end





function A333_ewd_msg.GPWS_FLAP_MODE_OFF.WarningMonitor()

	A333_ewd_msg.GPWS_FLAP_MODE_OFF.Monitor.video.IN = bool2num[NGPWSFMOF]

end





function A333_ewd_msg.TO_INHIBIT.WarningMonitor()

	local a = {E1 = ZPH3, E2 = ZPH4, E3 = ZPH5}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = a.S, E2 = bNOT(ZFPION)}
	b.S = bAND(b.E1, b.E2)

	logic.toInhibConf01:update(b.S)

	A333_ewd_msg.TO_INHIBIT.Monitor.video.IN = bool2num[logic.toInhibConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.TO_INHIBIT.Name)
	A333_ewd_msg.TO_INHIBIT.Monitor.video.INlast = A333_ewd_msg.TO_INHIBIT.Monitor.video.IN

end

function A333_ewd_msg.TO_INHIBIT.Reset()
	logic.toInhibConf01:resetTimer()
end



function A333_ewd_msg.LDG_INHIBIT.WarningMonitor()

	local a = {E1 = ZPH7, E2 = ZPH8}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = a.S, E2 = bNOT(ZFPION)}
	b.S = bAND(b.E1, b.E2)

	logic.ldgInhibConf01:update(b.S)

	A333_ewd_msg.LDG_INHIBIT.Monitor.video.IN = bool2num[logic.ldgInhibConf01.OUT]
	A333_fws_trigger_reset(A333_ewd_msg.LDG_INHIBIT.Name)
	A333_ewd_msg.LDG_INHIBIT.Monitor.video.INlast = A333_ewd_msg.LDG_INHIBIT.Monitor.video.IN

end

function A333_ewd_msg.LDG_INHIBIT.Reset()
	logic.ldgInhibConf01:resetTimer()
end



function A333_ewd_msg.LAND_ASAP_RED.WarningMonitor()

	local a  ={E1 = USFLC_1, E2 = USFLC_2}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = USALC_1, E2 = USALC_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = UE1FIRE, E2 = UE2FIRE, E3 = UAPUFIRE}
	c.S = bOR3(c.E1, c.E2, c.E3)

	local d = {E1 = HGSYSLP, E2 = HYSYSLP}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = HYSYSLP, E2 = HBSYSLP}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = HBSYSLP, E2 = HGSYSLP}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = UFCSDI, E2 = a.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = b.S, E2 = UACSDI}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = g.S, E2 = h.S}
	i.S = bOR(i.E1, i.E2)

	local j = {E1 = d.S, E2 = e.S, E3 = f.S}
	j.S = bOR3(j.E1, j.E2, j.E3)

	local k = {E1 = i.S, E2 = c.S, E3 = EEMER, E4 = j.S}
	k.S = bOR4(k.E1, k.E2, k.E3, k.E4)

	local l = {E1 = bNOT(ZGND), E2 = k.S}
	l.S = bAND(l.E1, l.E2)

	ZLAPR = l.S

	A333_ewd_msg.LAND_ASAP_RED.Monitor.video.IN = bool2num[l.S]

end







function A333_ewd_msg.LAND_ASAP_AMBER.WarningMonitor()

	local a = {E1 = USKD, E2 = EDCEC, E3 = JR1FAIL, E4 = JR2FAIL}
	a.S = bOR4(a.E1, a.E2, a.E3, a.E4)

	local b = {E1 = JR1TLAKO, E2 = JR1TLAKO, E3 = JR1TLADISC, E4 = JR2TLADISC, E5 = JR1REVKO, E6 = JR2REVKO, E7 = JR1REVUNLK, E8 = JR2REVUNLK}
	b.S = bOR8(b.E1, b.E2, b.E3, b.E4, b.E5, b.E6, b.E7, b.E8)

	local c = {E1 = JR2SD, E2 = JR1SD, E3 = JR1FAIL, E4 = JR2FAIL, E5 = FLRWLL, E6 = SFCLA, E7 = a.S, E8 = b.S}
	c.S = bOR8(c.E1, c.E2, c.E3, c.E4, c.E5, c.E6, c.E7, c.E8)

	local d = {E1 = bNOT(ZLAPR), E2 = bNOT(ZGND), E3 = c.S}
	d.S = bAND3(d.E1, d.E2, d.E3)

	A333_ewd_msg.LAND_ASAP_AMBER.Monitor.video.IN = bool2num[d.S]

end








function A333_ewd_msg.AIR_BLEED.WarningMonitor()

	local a = {E1 = JR1OUT, E2 = JR2OUT}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = a.S, E2 = bNOT(EEMER)}
	b.S = bAND(b.E1, b.E2)

	A333_ewd_msg.AIR_BLEED.Monitor.video.IN = bool2num[b.S]

end






function A333_ewd_msg.CAB_PRESS.WarningMonitor()

	local a = {E1 = PS1F_1, E2 = PS1F_1_INV}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = PS2F_2_INV, E2 = PS2F_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = a.S, E2 = EDCSOF}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = EDC2OF, E2 = b.S}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = c.S, E2 = d.S}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = bNOT(EEMER), E2 = e.S}
	f.S = bAND(f.E1, f.E2)

	PSCPR = e.S

	A333_ewd_msg.CAB_PRESS.Monitor.video.IN = bool2num[f.S]

end






function A333_ewd_msg.AVNCS_VENT.WarningMonitor()

	local a = {E1 = VAVEF, E2 = EDC1OF}				-- VAVEF TODO:  ASK ALEX IF THE AVNCS EXTRACT VENT IS FUNCTIONAL
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = VAVEF, E2 = EAC2OF}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = VAVEF, E2 = EDCBSSCOF}
	c.S = bAND(c.E1, c.E2)

	local f = {E1 = a.S, E2 = b.S, E3 = c.S}
	f.S = bOR3(f.E1, f.E2, f.E3)

	local g = {E1 = f.S, E2 = bNOT(PSCPR)}
	g.S = bAND(g.E1, g.E2)

	A333_ewd_msg.AVNCS_VENT.Monitor.video.IN = bool2num[g.S]

end







function A333_ewd_msg.ELEC.WarningMonitor()

	local a = {E1 = JR1OUT, E2 = JR2OUT}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = a.S, E2 = bNOT(EEMER)}
	b.S = bAND(b.E1, b.E2)

	A333_ewd_msg.ELEC.Monitor.video.IN = bool2num[b.S]

end








function A333_ewd_msg.HYDB.WarningMonitor()

	local a = {E1 = HBROVHT, E2 = HBRLAP, E3 = HBRLL, E4 = HBEPPBOF}
	a.S = bOR4(a.E1, a.E2, a.E3, a.E4)

	local b = {E1 = EDCSOF, E2 = EAC1OF}
	b.S = bOR(b.E1 , b.E2)

	local c = {E1 = HBEPLP, E2 = HBSYSLP}
	c.S = bOR(c.E1 , c.E2)

	local d = {E1 = ZPH1, E2 = ZPH10}
	d.S = bOR(d.E1 , d.E2)

	local e = {E1 = bNOT(a.S), E2 = b.S, E3 = c.S, E4 = bNOT(d.S), E5 = bNOT(EEMER)}
	e.S = bAND5(e.E1, e.E2, e.E3, e.E4, e.E5)

	A333_ewd_msg.HYDB.Monitor.video.IN = bool2num[e.S]

end







function A333_ewd_msg.HYDY.WarningMonitor()

	local a = {E1 = EDC2OF, E2 = EAC2OF}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = ZPH1, E2 = ZPH10, E3 = ZPH2, E4 = ZPH9, E5 = EEMER}
	b.S = bOR5(b.E1, b.E2, b.E3, b.E4, b.E5)

	local c = {E1 = bNOT(EEMER), E2 = HYEPON, E3 = a.S, E4 = HYSLP}
	c.S = bAND4(c.E1, c.E2, c.E3, c.E4)

	local d = {E1 = bNOT(HYPPBOF), E2 = HYPLP, E3 = JR2OUT, E4 = bNOT(b.S)}
	d.S = bAND4(d.E1, d.E2, d.E3, d.E4)

	local e = {E1 = d.S, E2 = c.S}
	e.S = bOR(e.E1, e.E2)

	A333_ewd_msg.HYDY.Monitor.video.IN = bool2num[e.S]

end







function A333_ewd_msg.HYDG.WarningMonitor()

	local a = {E1 = ZPH1, E2 = ZPH10, E3 = ZPH2, E4 = ZPH9}
	a.S = bAND4(a.E1, a.E2, a.E3, a.E4)

	local b = {E1 = bNOT(a.S), E2 = JR1OUT, E3 = HGPLP, E4 = bNOT(HGPPBOF), E5 = bNOT(EEMER)}
	b.S = bAND5(b.E1, b.E2, b.E3, b.E4, b.E5)

	A333_ewd_msg.HYDG.Monitor.video.IN = bool2num[b.S]

end








function A333_ewd_msg.FUEL.WarningMonitor()

	local a = {E1 = EAC1OF, E2 = EDC1OF}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = EAC2OF, E2 = EDC2OF}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = FLTP1LP, E2 = a.S}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = b.S, E2 = FLTP2LP}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = c.S, E2 = d.S}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = e.S, E2 = bNOT(EEMER)}
	f.S = bAND(f.E1, f.E2)

	A333_ewd_msg.FUEL.Monitor.audio.IN = bool2num[f.S]
	A333_ewd_msg.FUEL.Monitor.video.IN = bool2num[f.S]

end






function A333_ewd_msg.AIR_COND.WarningMonitor()

	local a = {E1 = EDC2OF, E2 = EAC2OF}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = EAC1OF, E2 = EDC1OF}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = AP2CF, E2 = a.S}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = b.S, E2 = AP1CF}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = c.S, E2 = d.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = e.S, E2 = bNOT(EEMER)}
	f.S = bAND(f.E1, f.E2)

	A333_ewd_msg.AIR_COND.Monitor.video.IN = bool2num[f.S]

end





function A333_ewd_msg.BRAKES.WarningMonitor()

	local a = {E1 = EDC2OF, E2 = EAC2OF}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = EDC1OF, E2 = EAC1OF}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = EEMER, E2 = WSDACF}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = bNOT(c.S), E2 = bNOT(GNABF), E3 = d.S}
	e.S = bAND3(e.E1, e.E2, e.E3)

	GEBF = d.S

	A333_ewd_msg.BRAKES.Monitor.video.IN = bool2num[e.S]

end






function A333_ewd_msg.WHEEL.WarningMonitor()

	local a = {E1 = bNOT(EDC12OF), E2 = bNOT(EEMER), E3 = GLGCIU2FT, E4 = EDC2OF}
	a.S = bAND4(a.E1, a.E2, a.E3, a.E4)

	local b = {E1 = HGSYSLP, E2 = a.S}
	b.S = bOR(b.E1, b.E2)

	A333_ewd_msg.WHEEL.Monitor.video.IN = bool2num[b.S]

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

	local a = {E1 = bNOT(EEMER), E2 = EDC2OF}
	a.S = bAND(a.E1, a.E2)

	A333_ewd_msg.FCTLDC2.Monitor.video.IN = bool2num[a.S]

end





function A333_ewd_msg.FCTLESS.WarningMonitor()

	-- NOT MODELED

end











function A333_ewd_msg.SPEED_BRAKE.WarningMonitor()

	local a = {E1 = SSPBR_1, E2 = SSPBR_2}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = ZPH1, E2 = ZPH8, E3 = ZPH9, E4 = ZPH10}
	bOR4(b.E1, b.E2, b.E3, b.E4)

	local c = {E1 = a.S, E2 = bNOT(b.S)}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.SPEED_BRAKE.Monitor.video.IN = bool2num[c.S]



	if A333_ewd_msg.SPEED_BRAKE.Monitor.video.OUT == 1 then
		if SASPDBRK then
			A333_ewd_msg.SPEED_BRAKE.TitleColor = 1						-- AMBER
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






function A333_ewd_msg.PACK2.WarningMonitor()

	local a = {E1 = AP2PBOF, E2 = bNOT(ZPH3)}
	a.S = bAND(a.E1, a.E2)

	A333_ewd_msg.PACK2.Monitor.video.IN = bool2num[a.S]

	local b = {E1 = ZPH4, E2 = ZPH5, E3 = ZPH6, E4 = ZPH7, E5 = ZPH8}
	b.S = bOR5(b.E1, b.E2, b.E3, b.E4, b.E5)

	if b.S then
		A333_ewd_msg.PACK2.TitleColor = 1
	else
		A333_ewd_msg.PACK2.TitleColor = 2
	end

end
function A333_ewd_msg.PACK1.WarningMonitor()

	local a = {E1 = AP1PBOF, E2 = bNOT(ZPH3)}
	a.S = bAND(a.E1, a.E2)

	A333_ewd_msg.PACK1.Monitor.video.IN = bool2num[a.S]

	local b = {E1 = ZPH4, E2 = ZPH5, E3 = ZPH6, E4 = ZPH7, E5 = ZPH8}
	b.S = bOR5(b.E1, b.E2, b.E3, b.E4, b.E5)

	if b.S then
		A333_ewd_msg.PACK1.TitleColor = 1
	else
		A333_ewd_msg.PACK1.TitleColor = 2
	end

end

function A333_ewd_msg.PARK_BRAKE.WarningMonitor()

	local a = {E1 = GPBRKON, E2 = bNOT(ZPH3)}
	a.S = bAND(a.E1, a.E2)

	A333_ewd_msg.PARK_BRAKE.Monitor.video.IN = bool2num[a.S]

	local b = {E1 = ZPH4, E2 = ZPH5, E3 = ZPH6, E4 = ZPH7, E5 = ZPH8}
	b.S = bOR5(b.E1, b.E2, b.E3, b.E4, b.E5)

	if b.S then
		A333_ewd_msg.PARK_BRAKE.TitleColor = 1
	else
		A333_ewd_msg.PARK_BRAKE.TitleColor = 2
	end

end






function A333_ewd_msg.RAT_OUT.WarningMonitor()

	A333_ewd_msg.RAT_OUT.Monitor.video.IN = bool2num[HRATNFS]

	local a = {E1 = ZPH1, E2 = ZPH2}
	a.S = bOR(a.E1, a.E2)

	if a.S then
		A333_ewd_msg.RAT_OUT.TitleColor = 1
	else
		A333_ewd_msg.RAT_OUT.TitleColor = 2
	end

end







function A333_ewd_msg.RAM_AIR_ON.WarningMonitor()

	A333_ewd_msg.RAM_AIR_ON.Monitor.video.IN = bool2num[ARAPBON]

end







function A333_ewd_msg.IGNITION.WarningMonitor()

	local a = {E1 = JR1CONTIGN_1A, E2 = JR1CONTIGN_1B, E3 = JR2CONTIGN_2A, E4 = JR2CONTIGN_2B}
	a.S = bOR4(a.E1, a.E2, a.E3, a.E4)

	local b = {E1 = a.S, E2 = WRRT}
	b.S = bAND(b.E1, b.E2)

	A333_ewd_msg.IGNITION.Monitor.video.IN = bool2num[b.S]

end





function A333_ewd_msg.CABIN_READY.WarningMonitor()

	local a = {E1 = CCR1, E2 = CCR2}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = ZPH6, E2 = ZPH7}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = b.S, E2 = GLGDNLKD}
	c.S = bAND(c.E1, c.E2)

	--local d = {E1 = bNOT(WNCMLI), E2 = a.S}
	--d.S = bAND(d.E1, d.E2)

	local d = {E1 = ZPH2, E2 = c.S}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = a.S, E2 = d.S}
	e.S = bAND(e.E1, e.E2)

	CCABR = a.S

	A333_ewd_msg.CABIN_READY.Monitor.video.IN = bool2num[e.S]

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






function A333_ewd_msg.COMPANY_MSG.WarningMonitor()

	local a = WATSUINS and CATSUMSGACT and CAOCMSG
	
	A333_ewd_msg.COMPANY_MSG.Monitor.video.IN = bool2num[a]

end








function A333_ewd_msg.ENG_A_ICE.WarningMonitor()

	local a = {E1 = IE1AIPBON, E2 = IE2AIPBON}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = EDC1OF, E2 = EDC2OF}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	A333_ewd_msg.ENG_A_ICE.Monitor.video.IN = bool2num[c.S]

end







function A333_ewd_msg.WING_A_ICE.WarningMonitor()

	A333_ewd_msg.WING_A_ICE.Monitor.video.IN = bool2num[IWAIPBON]

end





function A333_ewd_msg.ICE_NOT_DET.WarningMonitor()

	local a = {E1 = IE1IDF, E2 = IE2IDF}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = bNOT(IE1IDF), E2 = IE1ID}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = IE2ID, E2 = bNOT(IE2IDF)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = IE1AIPBON, E2 = IWAIPBON, E3 = IE2AIPBON}
	d.S = bOR3(d.E1, d.E2, d.E3)

	logic.iceNotDetConf02:update(d.S)

	local e = {E1 = WIDID, E2 = bNOT(ZGND)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = b.S, E2 = c.S}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = bNOT(f.S), E2 = logic.iceNotDetConf02.OUT}
	g.S = bAND(g.E1, g.E2)

	logic.iceNotDetConf01:update(g.S)

	local h = {E1 = bNOT(a.S), E2 = logic.iceNotDetConf01.OUT, E3 = e.S}
	h.S = bAND3(h.E1, h.E2, h.E3)

	A333_ewd_msg.ICE_NOT_DET.Monitor.video.IN = bool2num[h.S]

end








function A333_ewd_msg.APU_BLEED.WarningMonitor()

	local a = {E1 = BAPUBPBOF_1_VAL, E2 = bNOT(BAPUBPBOF_1)}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = bNOT(BAPUBPBOF_2), E2 = BAPUBPBOF_2_VAL}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = bNOT(BAPUBVFC_1), E2 = bNOT(BAPUBVFC_2)}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = d.S, E2 = QAVAIL, E3 = c.S}
	e.S = bAND3(e.E1, e.E2, e.E3)

	QBLEED = e.S

	A333_ewd_msg.APU_BLEED.Monitor.video.IN = bool2num[e.S]

end






function A333_ewd_msg.APU_AVAIL.WarningMonitor()

	local a = {E1 = QAVAIL, E2 = bNOT(QBLEED)}
	a.S = bAND(a.E1, a.E2)

	A333_ewd_msg.APU_AVAIL.Monitor.video.IN = bool2num[a.S]

end






function A333_ewd_msg.BRK_FAN.WarningMonitor()

	local a = {E1 = bNOT(GBFANCON_1_NCD), E2 = GBFANCON_1}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = GBFANCON_2, E2 = bNOT(GBFANCON_2_NCD)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = GBFI_1, E2 = GBFI_2}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = c.S, E2 = d.S}
	e.S = bAND(e.E1, e.E2)

	A333_ewd_msg.BRK_FAN.Monitor.video.IN = bool2num[e.S]

end






function A333_ewd_msg.GPWS_FLAP_3.WarningMonitor()

	local a = {E1 = NFFMSLDG3, E2 = bNOT(EEMER)}
	a.S = bAND(a.E1, a.E2)

	A333_ewd_msg.GPWS_FLAP_3.Monitor.video.IN = bool2num[a.S]

end







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

	local a = {E1 = bNOT(GDLORA_1_NCD), E2 = GDLORA_1}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = GDLORA_2, E2 = bNOT(GDLORA_2_NCD)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	A333_ewd_msg.AUTO_BRK_LO.Monitor.video.IN = bool2num[c.S]

end





function A333_ewd_msg.AUTO_BRK_MED.WarningMonitor()

	local a = {E1 = bNOT(GDMDRA_1_NCD), E2 = GDMDRA_1}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = GDMDRA_2, E2 = bNOT(GDMDRA_2_NCD)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	A333_ewd_msg.AUTO_BRK_MED.Monitor.video.IN = bool2num[c.S]

end






function A333_ewd_msg.AUTO_BRK_MAX.WarningMonitor()

	local a = {E1 = bNOT(GDMXRA_1_NCD), E2 = GDMXRA_1}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = GDMXRA_2, E2 = bNOT(GDMXRA_2_NCD)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	A333_ewd_msg.AUTO_BRK_MAX.Monitor.video.IN = bool2num[c.S]

end






function A333_ewd_msg.AUTO_BRK_OFF.WarningMonitor()

	local a = {E1 = GABRKF_1, E2 = GABRKF_2}
	a.S = bOR(a.E1, a.E2)

	A333_ewd_msg.AUTO_BRK_OFF.Monitor.video.IN = bool2num[a.S]

end






function A333_ewd_msg.CTR_TK_FEEDG.WarningMonitor()

	local a = {E1 = ZPH1, E2 = ZPH10, E3 = FMITD}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = FCTI_1, E2 = FCTI_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = bNOT(FCTP1COF_INV), E2 = bNOT(FCTP1COF)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = bNOT(FCTP2COF), E2 = bNOT(FCTP2COF_INV)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = c.S, E2 = d.S}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = bNOT(EAC1OF), E2 = bNOT(EAC2OF), E3 = b.S, E4 = e.S, E5 = bNOT(a.S)}
	f.S = bAND5(f.E1, f.E2, f.E3, f.E4, f.E5)

	A333_ewd_msg.CTR_TK_FEEDG.Monitor.video.IN = bool2num[f.S]

end






function A333_ewd_msg.FUEL_X_FEED.WarningMonitor()

	local a = {E1 = FXFVPBON, E2 = bNOT(FXFVFC)}
	a.S = bAND(a.E1, a.E2)

	A333_ewd_msg.FUEL_X_FEED.Monitor.video.IN = bool2num[a.S]

	local b = {E1 = ZPH3, E2 = ZPH4, E3 = ZPH5}
	b.S = bOR3(b.E1, b.E2, b.E3)

	if b.S then
		A333_ewd_msg.FUEL_X_FEED.TitleColor = 1
	else
		A333_ewd_msg.FUEL_X_FEED.TitleColor = 2
	end

end















function A333_fws_trigger_reset(warning_name)

	if A333_ewd_msg[warning_name].Monitor.video.IN == 0
		and A333_ewd_msg[warning_name].Monitor.video.INlast > 0
	then
		A333_ewd_msg[warning_name].Reset()
	end

end






function A333_fws_warning_triggers()

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











