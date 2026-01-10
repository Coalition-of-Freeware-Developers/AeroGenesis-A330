--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws500.lua
* Process: FWS Warning Message Action Functions
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


--print("LOAD: A333.ecam_fws500.lua")

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

local eng1FireActVL01 = newVariableText('eng1FireActVL01', 10.0, 0.0, 1.0, 'dn', 1.0)
local eng1FireActVL02 = newVariableText('eng1FireActVL02', 30.0, 0.0, 1.0, 'dn', 1.0)

local eng2FireActVL01 = newVariableText('eng2FireActVL01', 10.0, 0.0, 1.0, 'dn', 1.0)
local eng2FireActVL02 = newVariableText('eng2FireActVL02', 30.0, 0.0, 1.0, 'dn', 1.0)

local apuFireActVL01 = newVariableText('apuFireActVL01', 10.0, 0.0, 1.0, 'dn', 1.0)

local lgNotDnLckActPulse01 = newFallingEdgePulse('lgNotDnLckActPulse01')
local lgNotDnLckActSRS01 = newSRlatchSetPriority('lgNotDnLckActSRS01')

local lgNotUpLckActConf01 = newLeadingEdgeDelayedConfirmation('lgNotUpLckActConf01', 10.0)
local lgNotUpLckActPulse01 = newFallingEdgePulse('lgNotUpLckActPulse01')
local lgNotUpLckActSRS01 = newSRlatchSetPriority('lgNotUpLckActSRS01')

local doorNotClsdActPulse01 = newFallingEdgePulse('doorNotClsdActPulse01')
local doorNotClsdActSRS01 = newSRlatchSetPriority('doorNotClsdActSRS01')

local eng1failActMtrig01 = newLeadingEdgeTrigger('eng1failActMtrig01', 30.0)
local eng1failActVL01 = newVariableText('eng1failActVL01', 10.0, 0.0, 1.0, 'dn', 1.0)

local eng2failActMtrig01 = newLeadingEdgeTrigger('eng2failActMtrig01', 30.0)
local eng2failActVL01 = newVariableText('eng2failActVL01', 10.0, 0.0, 1.0, 'dn', 1.0)

local toMemoSRR01 = newSRlatchResetPriority('toMemoSRR01')

local gen1faultPulse01 = newLeadingEdgePulse('gen1faultPulse01')
local gen1faultSRR01 = newSRlatchResetPriority('gen1faultSRR01')

local gen2faultPulse01 = newLeadingEdgePulse('gen2faultPulse01')
local gen2faultSRR01 = newSRlatchResetPriority('gen2faultSRR01')

local apuGenFaultPulse01 = newLeadingEdgePulse('apuGenFaultPulse01')
local apuGenFaultSRR01 = newSRlatchResetPriority('apuGenFaultSRR01')

local fwdCargoSmkConf01 = newLeadingEdgeDelayedConfirmation('fwdCargoSmkConf01', 5.0)

local aftCargoSmkConf01 = newLeadingEdgeDelayedConfirmation('aftCargoSmkConf01', 5.0)



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
function A333_ewd_msg.OVER_SPEED_VFE1.Action()
	A333_ewd_msg.OVER_SPEED_VFE1.MsgLine[1].MsgStatus = bool2num[NVFE1]
end




function A333_ewd_msg.OVER_SPEED_VFE2.Action()
	A333_ewd_msg.OVER_SPEED_VFE2.MsgLine[1].MsgStatus = bool2num[NVFE2]
end




function A333_ewd_msg.OVER_SPEED_VFE3.Action()
	A333_ewd_msg.OVER_SPEED_VFE3.MsgLine[1].MsgStatus = bool2num[NVFE3]
end




function A333_ewd_msg.OVER_SPEED_VFE4.Action()
	A333_ewd_msg.OVER_SPEED_VFE4.MsgLine[1].MsgStatus = bool2num[NVFE4]
end




function A333_ewd_msg.OVER_SPEED_VFE5.Action()
	A333_ewd_msg.OVER_SPEED_VFE5.MsgLine[1].MsgStatus = bool2num[NVFE5]
end




function A333_ewd_msg.OVER_SPEED_VFE6.Action()
	A333_ewd_msg.OVER_SPEED_VFE6.MsgLine[1].MsgStatus = bool2num[NVFE6]
end




function A333_ewd_msg.OVER_SPEED_VLE.Action()
	A333_ewd_msg.OVER_SPEED_VLE.MsgLine[1].MsgStatus = bool2num[WVLE]
end




function A333_ewd_msg.OVER_SPEED_VMO_MMO.Action()
	A333_ewd_msg.OVER_SPEED_VMO_MMO.MsgLine[1].MsgStatus = bool2num[WVMOMMO]
end




function A333_ewd_msg.ENG_DUAL_FAULT.Action()

    local a = BAPUBPBOF_1 or BAPUBPBOF_2
    local b = not JR1TLAI and (not JR2TLAI)
    local c = KYAWLC_1 and KRUDLC_1 and KRTLLC_1 and KFACNOH_1
    local e = IWAIPBON and QAVAIL
    local f = QAVAIL and a
    local g = WETOPS and EEMER
    local h = EEMER and (not WETOPS)
    local i = c or KFACNOH_1
    local l = JML1ON or JML2ON

	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[1].MsgStatus = bool2num[not JRIGNSEL]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[2].MsgStatus = bool2num[b]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[3].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[4].MsgStatus = 0								-- TODO:  THIS SYSTEM IS NOT MODELED
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[5].MsgStatus = bool2num[g]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[6].MsgStatus = bool2num[h]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[7].MsgStatus = bool2num[i]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[8].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[9].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[10].MsgStatus = bool2num[WA330]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[11].MsgStatus = bool2num[WA330]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[12].MsgStatus = bool2num[e]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[13].MsgStatus = bool2num[f]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[14].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[15].MsgStatus = bool2num[QAVAIL]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[16].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[17].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[18].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[19].MsgStatus = bool2num[not GLGDNLKD]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[20].MsgStatus = bool2num[not GLGDNLKD]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[21].MsgStatus = bool2num[WA330]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[22].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[23].MsgStatus = bool2num[l]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[24].MsgStatus = bool2num[QMSON]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[25].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[26].MsgStatus = 1

end




function A333_ewd_msg.ENG_1_FIRE.Action()

    eng1FireActVL01:update(UE1FPBOUT)
    local a = not ZGND and UE1FBLP
    eng1FireActVL02:update(a)
    local b = EBA1PBON or EBA2PBON
    local c = (not JR2TLAI) or (not JR1TLAI)
    local d = JML1ON_INV or JML1ON
    local e = eng1FireActVL02.s1 and (not UE1ABLP)
    local f = (not UE1ABLP) and eng1FireActVL02.s2
    local g = ZGND and JML2ON
    local h = eng1FireActVL01.s2 and (not ZGND) and (not UE1FBLP)
    local i = ZGND and (not UE1FBLP)
    local j = QMSON and ZGND and QAVAIL
    local k = (not JR1TLAI) and (not ZGND)
    local l = c and ZGND
    local m = (not GPBRKON) and ZGND
    local n = (not ZGND) and eng1FireActVL01.s1 and (not UE1FBLP)
    local o = (not UE1ABLP) and ZGND
    local p = e or f
    local q = ZGND and b

	A333_ewd_msg.ENG_1_FIRE.MsgLine[1].MsgStatus = bool2num[k]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[2].MsgStatus = bool2num[l]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[3].MsgStatus = bool2num[m]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[4].MsgStatus = bool2num[m]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[5].MsgStatus = bool2num[d]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[6].MsgStatus = bool2num[not UE1FPBOUT]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[7].MsgText = string.format(' -AGENT 1 AFT %2dS..DISCH', eng1FireActVL01.out); A333_ewd_msg.ENG_1_FIRE.MsgLine[7].MsgStatus = bool2num[n]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[8].MsgStatus = bool2num[h]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[9].MsgStatus = bool2num[i]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[10].MsgStatus = bool2num[o]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[11].MsgStatus = bool2num[g]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[12].MsgStatus = 1
	A333_ewd_msg.ENG_1_FIRE.MsgLine[13].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[14].MsgText = string.format('  .IF FIRE AFTER %2dS:   ', eng1FireActVL02.out); A333_ewd_msg.ENG_1_FIRE.MsgLine[14].MsgStatus = bool2num[e]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[15].MsgStatus = bool2num[p]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[16].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[17].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[18].MsgStatus = bool2num[j]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[19].MsgStatus = bool2num[q]

end

function A333_ewd_msg.ENG_1_FIRE.ActionReset()
	eng1FireActVL01:init()
	eng1FireActVL02:init()
end





function A333_ewd_msg.ENG_2_FIRE.Action()

    eng2FireActVL01:update(UE1FPBOUT)
    local a = not ZGND and UE2FBLP
    eng2FireActVL02:update(a)
    local b = EBA1PBON or EBA2PBON
    local c = (not JR1TLAI) or (not JR2TLAI)
    local d = JML2ON_INV or JML2ON
    local e = eng2FireActVL02.s1 and (not UE2ABLP)
    local f = (not UE2ABLP) and eng2FireActVL02.s2
    local g = ZGND and JML2ON
    local h = eng2FireActVL01.s2 and (not ZGND) and (not UE2FBLP)
    local i = ZGND and (not UE2FBLP)
    local j = QMSON and ZGND and QAVAIL
    local k = (not JR2TLAI) and (not ZGND)
    local l = c and ZGND
    local m = (not GPBRKON) and ZGND
    local n = (not ZGND) and eng2FireActVL01.s1 and (not UE2FBLP)
    local o = (not UE2ABLP) and ZGND
    local p = e or f
    local q = ZGND and b

	A333_ewd_msg.ENG_2_FIRE.MsgLine[1].MsgStatus = bool2num[k]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[2].MsgStatus = bool2num[l]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[3].MsgStatus = bool2num[m]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[4].MsgStatus = bool2num[m]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[5].MsgStatus = bool2num[d]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[6].MsgStatus = bool2num[not UE2FPBOUT]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[7].MsgText = string.format(' -AGENT 1 AFT %2dS..DISCH', eng2FireActVL01.out); A333_ewd_msg.ENG_2_FIRE.MsgLine[7].MsgStatus = bool2num[n]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[8].MsgStatus = bool2num[h]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[9].MsgStatus = bool2num[i]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[10].MsgStatus = bool2num[o]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[11].MsgStatus = bool2num[g]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[12].MsgStatus = 1
	A333_ewd_msg.ENG_2_FIRE.MsgLine[13].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[14].MsgText = string.format('  .IF FIRE AFTER %2dS:  ', eng2FireActVL02.out); A333_ewd_msg.ENG_2_FIRE.MsgLine[14].MsgStatus = bool2num[e]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[15].MsgStatus = bool2num[p]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[16].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[17].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[18].MsgStatus = bool2num[j]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[19].MsgStatus = bool2num[q]

end

function A333_ewd_msg.ENG_2_FIRE.ActionReset()
	eng2FireActVL01:init()
	eng2FireActVL02:init()
end




function A333_ewd_msg.APU_FIRE.Action()

	apuFireActVL01:update(UAPUFPBOUT)

	local a =  apuFireActVL01.s1 and (not UAPUELP)
	local b = apuFireActVL01.s2 and (not UAPUELP)

	A333_ewd_msg.APU_FIRE.MsgLine[1].MsgStatus = bool2num[not UAPUFPBOUT]
	A333_ewd_msg.APU_FIRE.MsgLine[2].MsgText = string.format(' -AGENT AFT %2dS...DISCH', apuFireActVL01.out); MsgStatus = bool2num[a]
	A333_ewd_msg.APU_FIRE.MsgLine[3].MsgStatus = bool2num[b]
	A333_ewd_msg.APU_FIRE.MsgLine[4].MsgStatus = bool2num[QMSON]

end

function A333_ewd_msg.APU_FIRE.ActionReset()
	apuFireActVL01:init()
end




function A333_ewd_msg.SLATS_CONFIG.Action()

	A333_ewd_msg.SLATS_CONFIG.MsgLine[1].MsgStatus = 1

end




function A333_ewd_msg.FLAPS_CONFIG.Action()

	A333_ewd_msg.FLAPS_CONFIG.MsgLine[1].MsgStatus = 1

end




function A333_ewd_msg.SPD_BRK_CONFIG.Action()

	A333_ewd_msg.SPD_BRK_CONFIG.MsgLine[1].MsgStatus = 1

end




function A333_ewd_msg.PITCH_TRIM_CONFIG.Action()

	A333_ewd_msg.PITCH_TRIM_CONFIG.MsgLine[1].MsgStatus = 1

end




function A333_ewd_msg.RUDDER_TRIM_CONFIG.Action()

	A333_ewd_msg.RUDDER_TRIM_CONFIG.MsgLine[1].MsgStatus = 1

end




function A333_ewd_msg.EXCESS_CAB_ALT.Action()

    local excessCabAltThreshold01 = PALTI > 10000.0
    local a = JR1TLAI and JR2TLAI
    local b = SSPBR_1 or SSPBR_2
    local c = JR1ESI or JR2ESI
    local d = (not a) and (not KATHRE)

	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[1].MsgStatus = bool2num[excessCabAltThreshold01]
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[2].MsgStatus = bool2num[excessCabAltThreshold01]
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[3].MsgStatus = 1
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[4].MsgStatus = 1
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[5].MsgStatus = bool2num[d]
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[6].MsgStatus = bool2num[not b]
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[7].MsgStatus = 1
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[8].MsgStatus = bool2num[not CSIGNSONP]
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[9].MsgStatus = bool2num[not c]
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[10].MsgStatus = 1
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[11].MsgStatus = 1
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[12].MsgStatus = 1

end




function A333_ewd_msg.ENG_1_OIL_LO_PR.Action()

	A333_ewd_msg.ENG_1_OIL_LO_PR.MsgLine[1].MsgStatus = bool2num[JML1ON]
	A333_ewd_msg.ENG_1_OIL_LO_PR.MsgLine[2].MsgStatus = bool2num[not JR1TLAI]
	A333_ewd_msg.ENG_1_OIL_LO_PR.MsgLine[3].MsgStatus = bool2num[JML1ON]

end




function A333_ewd_msg.ENG_2_OIL_LO_PR.Action()

	A333_ewd_msg.ENG_2_OIL_LO_PR.MsgLine[1].MsgStatus = bool2num[JML2ON]
	A333_ewd_msg.ENG_2_OIL_LO_PR.MsgLine[2].MsgStatus = bool2num[not JR2TLAI]
	A333_ewd_msg.ENG_2_OIL_LO_PR.MsgLine[3].MsgStatus = bool2num[JML2ON]

end




function A333_ewd_msg.L_R_ELEV_FAULT.Action()

	A333_ewd_msg.L_R_ELEV_FAULT.MsgLine[1].MsgStatus = 1
	A333_ewd_msg.L_R_ELEV_FAULT.MsgLine[2].MsgStatus = 1
	A333_ewd_msg.L_R_ELEV_FAULT.MsgLine[3].MsgStatus = 1

end




function A333_ewd_msg.GEAR_NOT_DOWNLOCKED.Action()

    local a = GGLSD_1_INV or GGLSD_2_INV
    local b = GGLSD_1 or GGLSD_2
    local c = ZPH6 or ZPH7
    local d = GGLSD_1 and GGLSD_2
    local e = a and b
    local f = d or e
    local g = GGNDNLD and f and c
    lgNotDnLckActPulse01:update(g)
    lgNotDnLckActSRS01:update(lgNotDnLckActPulse01.OUT, ZPH8)
    local h = (not lgNotDnLckActSRS01.Q) and g
    local i = h and (not GLGDNLKD)

	A333_ewd_msg.GEAR_NOT_DOWNLOCKED.MsgLine[1].MsgStatus = bool2num[h]
	A333_ewd_msg.GEAR_NOT_DOWNLOCKED.MsgLine[2].MsgStatus = bool2num[i]
	A333_ewd_msg.GEAR_NOT_DOWNLOCKED.MsgLine[3].MsgStatus = bool2num[not(GLGDNLKD)]

end

function A333_ewd_msg.GEAR_NOT_DOWNLOCKED.ActionReset()
	lgNotDnLckActSRS01:reset()
end




function A333_ewd_msg.FWD_CARGO_SMOKE.Action()

    local a = XAFCGHT or XAFCGVENT
    local b = UFEB1I_1 or UFEB1I_2
    local c = (not UCB1LP_1) or (not UCB1LP_2)
    local d = UFEB2I_1 or UFEB2I_2
    local e = (not VFCDNIVFC) and (not VFCUPIVFC)
    local f = e and (not VFCIVPBOF) and a
    fwdCargoSmkConf01:update(f)
    local g = b and c and not d
    local h = b and c and d

	A333_ewd_msg.FWD_CARGO_SMOKE.MsgLine[1].MsgStatus = bool2num[fwdCargoSmkConf01.OUT]
	A333_ewd_msg.FWD_CARGO_SMOKE.MsgLine[2].MsgStatus = bool2num[g]
	A333_ewd_msg.FWD_CARGO_SMOKE.MsgLine[3].MsgStatus = bool2num[h]

end

function A333_ewd_msg.FWD_CARGO_SMOKE.ActionReset()
	fwdCargoSmkConf01:resetTimer()
end




function A333_ewd_msg.AFT_CARGO_SMOKE.Action()

    local a = XAACGHT or XAACGVENT
    local b = UFEB1I_1 or UFEB1I_2
    local c = (not UCB1LP_1) or (not UCB1LP_2)
    local d = UFEB2I_1 or UFEB2I_2
    local e = (not VACDNIVFC) and (not VACUPIVFC)
    local f = e and (not VACIVPBOF) and a
    aftCargoSmkConf01:update(f)
    local g = b and c and (not d)
    local h = b and c and d

	A333_ewd_msg.AFT_CARGO_SMOKE.MsgLine[1].MsgStatus = bool2num[aftCargoSmkConf01.OUT]
	A333_ewd_msg.AFT_CARGO_SMOKE.MsgLine[2].MsgStatus = bool2num[g]
	A333_ewd_msg.AFT_CARGO_SMOKE.MsgLine[3].MsgStatus = bool2num[h]

end

function A333_ewd_msg.AFT_CARGO_SMOKE.ActionReset()
	aftCargoSmkConf01:resetTimer()
end




function A333_ewd_msg.ELEC_EMER_CONFIG.Action()

	local a = QMSON and  not QAVAIL
	local b = (not KRTLLC_1) and (not KRUDLC_1) and (not KYAWLC_1) and (not KFACNOH_1)
	--local d = (not PLESM_1) or (not PLESM_2)			--TODO:  PLESM_1  PLESM_2
	local e = b or KFACNOH_1
	local f = GLGDNLKD and EEGNCON

	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[1].MsgStatus = bool2num[HRATNFS]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[2].MsgStatus = bool2num[EGEN12R]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[3].MsgStatus = bool2num[EGENRESET]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[4].MsgStatus = bool2num[not(EBTIEPBOF)]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[5].MsgStatus = bool2num[EGENRESET]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[6].MsgStatus = bool2num[not(EEGNCON)]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[7].MsgStatus = bool2num[not(JRIGNSEL)]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[8].MsgStatus = bool2num[not(WETOPS)]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[9].MsgStatus = bool2num[WETOPS]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[10].MsgStatus = 1
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[11].MsgStatus = 1
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[12].MsgStatus = bool2num[not(WMBE)]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[13].MsgStatus = 1
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[14].MsgStatus = 1
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[15].MsgStatus = bool2num[f]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[16].MsgStatus = bool2num[f]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[17].MsgStatus = bool2num[f]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[18].MsgStatus = bool2num[a]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[19].MsgStatus = bool2num[e]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[20].MsgStatus = bool2num[VAVEPBO]
	--A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[21].MsgStatus = bool2num[d]			-- TODO: NOT MODELED

end




function A333_ewd_msg.ENG_1_FAIL.Action()

    eng1failActMtrig01:update(ZPH5)
    eng1failActVL01:update(UE1FPBOUT)
    local a = JR1TLA_1A_VAL or JR1TLA_1B_VAL
    local b = ZPH2 or ZPH9
    local c = ZPH4 or eng1failActMtrig01.OUT or (not JML1ON)
    local d = eng1failActMtrig01.OUT or ZPH4
    local e = (not UE1FBLP) and (not ZGND) and (not d) and eng1failActVL01.s1
    local f = eng1failActVL01.s2 and (not d )and (not ZGND) and (not UE1FBLP)
    local g = (not UE1FBLP) and ZGND and (not d)
    local h = (not b) and (not JR1ESI)
    local i = (not b) and (not c)
    local j = (not JR1TLAI) and a and (not d)
    local k = JML1ON and (not d)
    local l = (not d) and (not UE1FPBOUT)
    local m = (not d) and (not UE1FPBOUT)

	A333_ewd_msg.ENG_1_FAIL.MsgLine[1].MsgStatus = bool2num[h]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[2].MsgStatus = bool2num[j]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[3].MsgStatus = bool2num[i]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[4].MsgStatus = bool2num[k]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[5].MsgStatus = bool2num[l]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[6].MsgStatus = bool2num[m]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[7].MsgText = string.format(' -AGENT 1 AFT %2dS..DISCH', eng1failActVL01.out); A333_ewd_msg.ENG_1_FAIL.MsgLine[1].MsgStatus = bool2num[e]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[8].MsgStatus = bool2num[f]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[9].MsgStatus = bool2num[g]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[10].MsgStatus = bool2num[not(d)]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[11].MsgStatus = bool2num[not(d)]

end

function A333_ewd_msg.ENG_1_FAIL.ActionReset()
	eng1failActVL01:init()
end




function A333_ewd_msg.ENG_1_OIL_HI_TEMP.Action()

	A333_ewd_msg.ENG_1_OIL_HI_TEMP.MsgLine[1].MsgStatus = bool2num[not(JR1TLAI)]
	A333_ewd_msg.ENG_1_OIL_HI_TEMP.MsgLine[2].MsgStatus = bool2num[JML1ON]

end




function A333_ewd_msg.ENG_1_SHUT_DOWN.Action()

    local a = (not BXFVFC_1) and BXFVFC_1_VAL
    local b = not BXFVFC_2 and BXFVFC_2_VAL
    local c = ZPH4 or ZPH5
    local d = BXFVFC_1 or BXFVFC_2
    local e = a or b
    local f = IWAION and (not UE1FPBOUT)
    local g = UE1FPBOUT and ZGND
    local h = (not AP1PBOF) and (not AP2PBOF) and IWAION and (not c) and (not UE1FPBOUT)
    local i = IWAION and UE1FPBOUT
    local j = f and (not c) and d
    local k = UE1FPBOUT and e
    local l = (not JR2ESI) and (not g)
    local m = (not FXFVPBON) and (not g)
    local n = not c and (not ZGND) and JR1RUSTWD

	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[1].MsgStatus = bool2num[h]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[2].MsgStatus = bool2num[j]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[3].MsgStatus = bool2num[l]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[4].MsgStatus = bool2num[m]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[5].MsgStatus = bool2num[n]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[6].MsgStatus = bool2num[n]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[7].MsgStatus = bool2num[k]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[8].MsgStatus = bool2num[i]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[9].MsgStatus = bool2num[UE1FPBOUT]

end




function A333_ewd_msg.ENG_2_FAIL.Action()

    eng2failActMtrig01:update(ZPH5)
    eng2failActVL01:update(UE2FPBOUT)

    local a = JR2TLA_2A_VAL or JR2TLA_2B_VAL
    local b = ZPH2 or ZPH9
    local c = ZPH4 or eng2failActMtrig01.OUT or (not JML2ON)
    local d = eng2failActMtrig01.OUT or ZPH4
    local e = (not UE2FBLP) and (not ZGND) and (not d) and eng2failActVL01.s1
    local f = eng2failActVL01.s2 and (not d) and (not ZGND) and (not UE2FBLP)
    local g = (not UE2FBLP) and ZGND and (not d)
    local h = (not b) and (not JR2ESI)
    local i = (not b) and (not c)
    local j = (not JR2TLAI) and a and (not d)
    local k = JML2ON and (not d)
    local l = (not d) and (not UE2FPBOUT)
    local m = (not d) and (not UE2FPBOUT)

	A333_ewd_msg.ENG_2_FAIL.MsgLine[1].MsgStatus = bool2num[h]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[2].MsgStatus = bool2num[j]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[3].MsgStatus = bool2num[i]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[4].MsgStatus = bool2num[k]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[5].MsgStatus = bool2num[l]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[6].MsgStatus = bool2num[m]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[7].MsgText = string.format(' -AGENT 1 AFT %2dS..DISCH', eng2failActVL01.out); A333_ewd_msg.ENG_2_FAIL.MsgLine[1].MsgStatus = bool2num[e]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[8].MsgStatus = bool2num[f]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[9].MsgStatus = bool2num[g]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[10].MsgStatus = bool2num[not(d)]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[11].MsgStatus = bool2num[not(d)]

end




function A333_ewd_msg.ENG_2_FAIL.ActionReset()
	eng2failActVL01:init()
end




function A333_ewd_msg.ENG_2_OIL_HI_TEMP.Action()

	A333_ewd_msg.ENG_2_OIL_HI_TEMP.MsgLine[1].MsgStatus = bool2num[not(JR2TLAI)]
	A333_ewd_msg.ENG_2_OIL_HI_TEMP.MsgLine[2].MsgStatus = bool2num[JML2ON]

end




function A333_ewd_msg.ENG_2_SHUT_DOWN.Action()

    local a = (not BXFVFC_1) and BXFVFC_1_VAL
    local b = (not BXFVFC_2) and BXFVFC_2_VAL
    local bb = WETOPS and EEMER
    local c = ZPH4 or ZPH5
    local d = BXFVFC_1 or BXFVFC_2
    local e = a or b
    local f = IWAION and (not UE2FPBOUT)
    local g = UE2FPBOUT and ZGND
    local h = (not AP1PBOF) and (not AP2PBOF) and IWAION and (not c) and (not UE2FPBOUT)
    local i = IWAION and UE2FPBOUT
    local j = f and (not c) and d
    local k = UE2FPBOUT and e
    local l = not JR1ESI and (not g)
    local m = (not FXFVPBON) and (not g)
    local n = (not c) and (not ZGND) and JR2RUSTWD
    local o = h and bb
    local p = h and (not bb)

	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[1].MsgStatus = bool2num[o]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[2].MsgStatus = bool2num[p]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[3].MsgStatus = bool2num[j]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[4].MsgStatus = bool2num[l]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[5].MsgStatus = bool2num[m]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[6].MsgStatus = bool2num[n]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[7].MsgStatus = bool2num[n]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[8].MsgStatus = bool2num[k]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[9].MsgStatus = bool2num[i]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[10].MsgStatus = bool2num[UE2FPBOUT]

end




function A333_ewd_msg.ENG_1_HUNG_START.Action()

	A333_ewd_msg.ENG_1_HUNG_START.MsgLine[1].MsgStatus = 0
	A333_ewd_msg.ENG_1_HUNG_START.MsgLine[2].MsgStatus = 0
	A333_ewd_msg.ENG_1_HUNG_START.MsgLine[3].MsgStatus = 0
	A333_ewd_msg.ENG_1_HUNG_START.MsgLine[4].MsgStatus = 0

end




function A333_ewd_msg.ENG_2_HUNG_START.Action()

	A333_ewd_msg.ENG_2_HUNG_START.MsgLine[1].MsgStatus = 0
	A333_ewd_msg.ENG_2_HUNG_START.MsgLine[2].MsgStatus = 0
	A333_ewd_msg.ENG_2_HUNG_START.MsgLine[3].MsgStatus = 0
	A333_ewd_msg.ENG_2_HUNG_START.MsgLine[4].MsgStatus = 0

end




function A333_ewd_msg.ENG_1_OIL_LO_TEMP.Action()

    local eng1OilTmpThreshold01 = JR1OT < 50.0
    local eng1OilTmpThreshold02 = JR1OT < -10.0
	local a =  JR1OT_INV or JR1OT_NCD
	local b = eng1OilTmpThreshold01 and (not a)
	local c = (not a) and eng1OilTmpThreshold02
	A333_ewd_msg.ENG_1_OIL_LO_TEMP.MsgLine[1].MsgStatus = bool2num[b]
	A333_ewd_msg.ENG_1_OIL_LO_TEMP.MsgLine[2].MsgStatus = bool2num[c]

end




function A333_ewd_msg.ENG_2_OIL_LO_TEMP.Action()

    local eng2OilTmpThreshold01 = JR2OT < 50.0
    local eng2OilTmpThreshold02 = JR2OT < -10.0
	local a =  JR2OT_INV or JR2OT_NCD
	local b = eng2OilTmpThreshold01 and (not a)
    local c = (not a) and eng2OilTmpThreshold02

	A333_ewd_msg.ENG_2_OIL_LO_TEMP.MsgLine[1].MsgStatus = bool2num[b]
	A333_ewd_msg.ENG_2_OIL_LO_TEMP.MsgLine[2].MsgStatus = bool2num[c]

end




function A333_ewd_msg.DC_EMER_CONFIG.Action()

	A333_ewd_msg.DC_EMER_CONFIG.MsgLine[1].MsgStatus = bool2num[EEGNCON]

end




function A333_ewd_msg.HYD_BY_SYS_LO_PR.Action()

    local a = HBRTUP or HBROVHT
    local b = HBRQLO or HBRLL
    local c = HBRLAP or a or b
    local d = (not HNVMYEPF) and (not HYEPON)
    local e = (not HRATNFS) and (not c)

	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[1].MsgStatus = bool2num[HRATNFS]
	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[2].MsgStatus = bool2num[d]
	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[3].MsgStatus = bool2num[e]
	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[4].MsgStatus = bool2num[not(HBEPPBOF)]
	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[5].MsgStatus = bool2num[not(HYPPBOF)]
	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[6].MsgStatus = 1
	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[7].MsgStatus = 1

end




function A333_ewd_msg.HYD_GB_SYS_LO_PR.Action()

	local a = HBRTUP or HBROVHT
	local b = HBRQLO or HBRLL
	local c = HBRLAP or a or b
	local d = (not HRATNFS) and (p)

	A333_ewd_msg.HYD_GB_SYS_LO_PR.MsgLine[1].MsgStatus = bool2num[HRATNFS]
	A333_ewd_msg.HYD_GB_SYS_LO_PR.MsgLine[2].MsgStatus = bool2num[d]
	A333_ewd_msg.HYD_GB_SYS_LO_PR.MsgLine[3].MsgStatus = bool2num[not(HBEPPBOF)]
	A333_ewd_msg.HYD_GB_SYS_LO_PR.MsgLine[4].MsgStatus = bool2num[not(HGPPBOF)]
	A333_ewd_msg.HYD_GB_SYS_LO_PR.MsgLine[5].MsgStatus = 1

end




function A333_ewd_msg.HYD_GY_SYS_LO_PR.Action()

	local a =HYRLL or HYROVHT or HYRLAP
	local b = HYEPON or HNVMYEPF
	local c = (not a) and (not b)

	A333_ewd_msg.HYD_GY_SYS_LO_PR.MsgLine[1].MsgStatus = bool2num[not(HGPPBOF)]
	A333_ewd_msg.HYD_GY_SYS_LO_PR.MsgLine[2].MsgStatus = bool2num[not(HYPPBOF)]
	A333_ewd_msg.HYD_GY_SYS_LO_PR.MsgLine[3].MsgStatus = bool2num[c]
	A333_ewd_msg.HYD_GY_SYS_LO_PR.MsgLine[4].MsgStatus = 1

end




function A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.Action()

    local a = JR1IDLE_1A or JR1IDLE_1B
    local b = ZPH4 or ZPH3
    local c = JR1REVD_1A or JR1REVD_1B
    local d = (not JR1TLAI) and (not ZPH4)
    local e = (not b) and JML1ON
    local f = ZGND and c
    local g = d or e
    local h = ZGND and g

	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[1].MsgStatus = bool2num[a]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[2].MsgStatus = bool2num[not JR1TLAI]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[3].MsgStatus = bool2num[not ZGND]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[4].MsgStatus = bool2num[h]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[5].MsgStatus = bool2num[not ZGND]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[6].MsgStatus = bool2num[e]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[7].MsgStatus = bool2num[f]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[8].MsgStatus = bool2num[f]

end





function A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.Action()

    local a = JR2IDLE_2A or JR2IDLE_2B
    local b = ZPH4 or ZPH3
    local c = JR2REVD_2A or JR2REVD_2B
    local d = (not JR2TLAI) and (not ZPH4)
    local e = (not b) and JML2ON
    local f = ZGND and c
    local g = d or e
    local h = ZGND and g

	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[1].MsgStatus = bool2num[a]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[2].MsgStatus = bool2num[not(JR2TLAI)]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[3].MsgStatus = bool2num[not(ZGND)]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[4].MsgStatus = bool2num[h]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[5].MsgStatus = bool2num[not(ZGND)]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[6].MsgStatus = bool2num[e]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[7].MsgStatus = bool2num[f]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[8].MsgStatus = bool2num[f]

end




function A333_ewd_msg.DC_BUS_1_2_OFF.Action()

	A333_ewd_msg.DC_BUS_1_2_OFF.MsgLine[1].MsgStatus = bool2num[not(VAVEPBO)]
	A333_ewd_msg.DC_BUS_1_2_OFF.MsgLine[2].MsgStatus = 1
	A333_ewd_msg.DC_BUS_1_2_OFF.MsgLine[3].MsgStatus = bool2num[not(WMBE)]
	A333_ewd_msg.DC_BUS_1_2_OFF.MsgLine[4].MsgStatus = 1

end




function A333_ewd_msg.GEN_1_FAULT.Action()

	gen1faultPulse01:update(EGN1PBOF)
	local a = ZPH1 or ZPH10
	local b = EG1FM and gen1faultPulse01.OUT
	local c = (not EG1FM) or a
	gen1faultSRR01:update(b, c)

	A333_ewd_msg.GEN_1_FAULT.MsgLine[1].MsgStatus = bool2num[not(gen1faultSRR01.Q)]
	A333_ewd_msg.GEN_1_FAULT.MsgLine[2].MsgStatus = bool2num[not(EGN1PBOF)]
	A333_ewd_msg.GEN_1_FAULT.MsgLine[3].MsgStatus = bool2num[not(EGN1PBOF)]

end

function A333_ewd_msg.GEN_1_FAULT.ActionReset()
    gen1faultSRR01:reset()
end






function A333_ewd_msg.GEN_2_FAULT.Action()

	gen2faultPulse01:update(EGN2PBOF)
	local a = ZPH1 or ZPH10
	local b = EG2FM and gen2faultPulse01.OUT
	local c = (not EG2FM) or a
	gen2faultSRR01:update(b, c)

	A333_ewd_msg.GEN_2_FAULT.MsgLine[1].MsgStatus = bool2num[not(gen2faultSRR01.Q)]
	A333_ewd_msg.GEN_2_FAULT.MsgLine[2].MsgStatus = bool2num[not(EGN2PBOF)]
	A333_ewd_msg.GEN_2_FAULT.MsgLine[3].MsgStatus = bool2num[not(EGN2PBOF)]

end

function A333_ewd_msg.GEN_2_FAULT.ActionReset()
    gen2faultSRR01:reset()
end




function A333_ewd_msg.APU_GEN_FAULT.Action()

	apuGenFaultPulse01:update(not EAPUGNPBOF)
	local a = ZPH1 or ZPH10
	local b = EGAPUM and apuGenFaultPulse01.OUT
	local c = not EGAPUM or a
	apuGenFaultSRR01:update(b, c)

	A333_ewd_msg.APU_GEN_FAULT.MsgLine[1].MsgStatus = bool2num[not(apuGenFaultSRR01.Q)]
	A333_ewd_msg.APU_GEN_FAULT.MsgLine[2].MsgStatus = bool2num[not(EAPUGNPBOF)]
	A333_ewd_msg.APU_GEN_FAULT.MsgLine[3].MsgStatus = bool2num[not(EAPUGNPBOF)]

end

function A333_ewd_msg.APU_GEN_FAULT.ActionReset()
    apuGenFaultSRR01:init()
end




function A333_ewd_msg.DOORS_NOT_CLOSED.Action()

    local doorNotClsdActThr01 = NCAS_1 > 220.0
    local doorNotClsdActThr02 = NCAS_2 > 220.0
    local doorNotClsdActThr03 = NCAS_3 > 220.0
    local a = GGLSUP_1_INV or GGLSUP_2_INV
    local b = GGLSUP_1 and GGLSUP_2
    local c = GGLSUP_1 or GGLSUP_2
    local d = a and c
    local e = NCAS_1_INV or NCAS_1_NCD
    local f = NCAS_2_INV or NCAS_2_NCD
    local g = NCAS_3_INV or NCAS_3_NCD
    local h = b or d
    local i = h and GDNC
    doorNotClsdActPulse01:update(i)
    doorNotClsdActSRS01:update(doorNotClsdActPulse01.OUT, ZPH8)
    local j = (not e) and doorNotClsdActThr01
    local k = (not f) and doorNotClsdActThr02
    local l = (not g) and doorNotClsdActThr03
    local n = j or k or l
    local m = (not doorNotClsdActSRS01.Q) and i and (not n)

	A333_ewd_msg.DOORS_NOT_CLOSED.MsgLine[1].MsgStatus = bool2num[m]
	A333_ewd_msg.DOORS_NOT_CLOSED.MsgLine[2].MsgStatus = bool2num[m]
	A333_ewd_msg.DOORS_NOT_CLOSED.MsgLine[3].MsgStatus = 1

end

function A333_ewd_msg.DOORS_NOT_CLOSED.ActionReset()
	doorNotClsdActSRS01:reset()
end




function A333_ewd_msg.GEAR_NOT_UPLOCKED.Action()

    local lgNotUpLckActThr01 = NCAS_1 > 220.0
    local lgNotUpLckActThr02 = NCAS_2 > 220.0
    local lgNotUpLckActThr03 = NCAS_3 > 220.0
    lgNotUpLckActConf01:update(GLGDNLKD)
    local a = ZPH6 or ZPH5
    local b = GGLSUP_1_IN or GGLSUP_2_INV
    local c = GGLSUP_1 and GGLSUP_2
    local d = GGLSUP_1 or GGLSUP_2
    local e = NCAS_1_INV or NCAS_1_NCD
    local f = NCAS_2_INV or NCAS_2_NCD
    local g = NCAS_3_INV or NCAS_3_NCD
    local h = b and d
    local j = lgNotUpLckActThr01 and (not e)
    local k = lgNotUpLckActThr02 and (not f)
    local l = {E1 = lgNotUpLckActThr03, E2 = (not g)}
    local m = i and a and GLGNUM
    lgNotUpLckActPulse01:update(m)
    lgNotUpLckActSRS01:update(lgNotUpLckActPulse01.OUT, ZPH8)
    local n = j or k or l
    local o = not lgNotUpLckActSRS01.Q and m and (not n)
    local p = not n and (not lgNotUpLckActConf01.OUT)
    local q = o and  o
    local r = not GLGDNLKD and not GODNC

	A333_ewd_msg.GEAR_NOT_UPLOCKED.MsgLine[1].MsgStatus = bool2num[not GLGDNLKD]
	A333_ewd_msg.GEAR_NOT_UPLOCKED.MsgLine[2].MsgStatus = bool2num[o]
	A333_ewd_msg.GEAR_NOT_UPLOCKED.MsgLine[3].MsgStatus = bool2num[q]
	A333_ewd_msg.GEAR_NOT_UPLOCKED.MsgLine[4].MsgStatus = bool2num[p]
	A333_ewd_msg.GEAR_NOT_UPLOCKED.MsgLine[5].MsgStatus = bool2num[GLGDNLKD]
	A333_ewd_msg.GEAR_NOT_UPLOCKED.MsgLine[6].MsgStatus = bool2num[r]

end

function A333_ewd_msg.GEAR_NOT_UPLOCKED.ActionReset()
	lgNotUpLckActConf01:resetTimer()
	lgNotUpLckActSRS01:reset()
end




function A333_ewd_msg.GEAR_UPLOCK_FAULT.Action()

	A333_ewd_msg.GEAR_UPLOCK_FAULT.MsgLine[1].MsgStatus = 1
	A333_ewd_msg.GEAR_UPLOCK_FAULT.MsgLine[2].MsgStatus = 1

end




function A333_ewd_msg.SHOCK_ABSORBER_FAULT.Action()

	local a = GLGNE and not ZGND

	A333_ewd_msg.SHOCK_ABSORBER_FAULT.MsgLine[1].MsgStatus = bool2num[GLGNE]
	A333_ewd_msg.SHOCK_ABSORBER_FAULT.MsgLine[2].MsgStatus = bool2num[a]

end





function A333_ewd_msg.BRAKES_HOT.Action()

    local a = not GBFANCON_1_NCD and GBFANCON_1
    local b = GBFANCON_2 and not GBFANCON_2_NCD
    local c = a or b
    local d = GBFI_1 or GBFI_2
    local e = not c and d

	A333_ewd_msg.BRAKES_HOT.MsgLine[1].MsgStatus = bool2num[not ZGND]
	A333_ewd_msg.BRAKES_HOT.MsgLine[2].MsgStatus = bool2num[not ZGND]
	A333_ewd_msg.BRAKES_HOT.MsgLine[3].MsgStatus = bool2num[e]
	A333_ewd_msg.BRAKES_HOT.MsgLine[4].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.BRAKES_HOT.MsgLine[5].MsgStatus = bool2num[not ZGND]

end




function A333_ewd_msg.L_R_WING_TK_LO_LVL.Action()

	A333_ewd_msg.L_R_WING_TK_LO_LVL.MsgLine[1].MsgStatus = bool2num[not FLTP1COF]
	A333_ewd_msg.L_R_WING_TK_LO_LVL.MsgLine[2].MsgStatus = bool2num[not FLTP2COF]
	A333_ewd_msg.L_R_WING_TK_LO_LVL.MsgLine[3].MsgStatus = bool2num[not FRTP1COF]
	A333_ewd_msg.L_R_WING_TK_LO_LVL.MsgLine[4].MsgStatus = bool2num[not FRTP2COF]
	A333_ewd_msg.L_R_WING_TK_LO_LVL.MsgLine[5].MsgStatus = bool2num[not FXFVPBON]

end



function A333_ewd_msg.L_WING_TK_LO_LVL.Action()

	A333_ewd_msg.L_WING_TK_LO_LVL.MsgLine[1].MsgStatus = bool2num[not FXFVPBON]
	A333_ewd_msg.L_WING_TK_LO_LVL.MsgLine[2].MsgStatus = bool2num[not FXFVPBON]
	A333_ewd_msg.L_WING_TK_LO_LVL.MsgLine[3].MsgStatus = bool2num[not FLTP1COF]
	A333_ewd_msg.L_WING_TK_LO_LVL.MsgLine[4].MsgStatus = bool2num[not FLTP2COF]

end



function A333_ewd_msg.R_WING_TK_LO_LVL.Action()

	A333_ewd_msg.R_WING_TK_LO_LVL.MsgLine[1].MsgStatus = bool2num[not FXFVPBON]
	A333_ewd_msg.R_WING_TK_LO_LVL.MsgLine[2].MsgStatus = bool2num[not FXFVPBON]
	A333_ewd_msg.R_WING_TK_LO_LVL.MsgLine[3].MsgStatus = bool2num[not FRTP1COF]
	A333_ewd_msg.R_WING_TK_LO_LVL.MsgLine[4].MsgStatus = bool2num[not FRTP2COF]

end




function A333_ewd_msg.X_BLEED_FAULT.Action()

    local a = BE1PRVFC_1 and BE1PRVFC_2 and BE2PRVFC_1 and BE2PRVFC_2
    local b = (not BAPUBPBOF_1) or (not BAPUBPBOF_2)
    local c = BXFVSSH_2 or BXFVSSH_1
    local d = BXFVSOP_2 or BXFVSOP_1
    local e = BXFDOD and a
    local f = b and QAVAIL
    local g = e and f
    local h = (not c) and (not d)
    local i = IWAIPBON and g

	IXBAIC = g

	A333_ewd_msg.X_BLEED_FAULT.MsgLine[1].MsgStatus = bool2num[h]
	A333_ewd_msg.X_BLEED_FAULT.MsgLine[2].MsgStatus = bool2num[i]
	A333_ewd_msg.X_BLEED_FAULT.MsgLine[3].MsgStatus = bool2num[g]

end




function A333_ewd_msg.AI_ENG1_VALVE_CLOSED.Action()

	A333_ewd_msg.AI_ENG1_VALVE_CLOSED.MsgLine[1].MsgStatus = 1

end




function A333_ewd_msg.AI_ENG2_VALVE_CLOSED.Action()

	A333_ewd_msg.AI_ENG2_VALVE_CLOSED.MsgLine[1].MsgStatus = 1

end




function A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Action()

	local a =  ILVCLSDF or IRVCLSDF
	local b = IPROCWAIESD and (not a)
	local c = IWAIPBON and a

	A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.MsgLine[1].MsgStatus = bool2num[b]
	A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.MsgLine[2].MsgStatus = bool2num[c]
	A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.MsgLine[3].MsgStatus = bool2num[a]

end




function A333_ewd_msg.DOOR_L_FWD_CABIN.Action()

	A333_ewd_msg.DOOR_L_FWD_CABIN.MsgLine[1].MsgStatus = bool2num[ZPH6]
	A333_ewd_msg.DOOR_L_FWD_CABIN.MsgLine[2].MsgStatus = bool2num[ZPH6]

end




function A333_ewd_msg.DOOR_L_MID_CABIN.Action()

	A333_ewd_msg.DOOR_L_MID_CABIN.MsgLine[1].MsgStatus = bool2num[ZPH6]
	A333_ewd_msg.DOOR_L_MID_CABIN.MsgLine[2].MsgStatus = bool2num[ZPH6]

end




function A333_ewd_msg.DOOR_L_AFT_CABIN.Action()

	A333_ewd_msg.DOOR_L_AFT_CABIN.MsgLine[1].MsgStatus = bool2num[ZPH6]
	A333_ewd_msg.DOOR_L_AFT_CABIN.MsgLine[2].MsgStatus = bool2num[ZPH6]

end




function A333_ewd_msg.DOOR_R_FWD_CABIN.Action()

	A333_ewd_msg.DOOR_R_FWD_CABIN.MsgLine[1].MsgStatus = bool2num[ZPH6]
	A333_ewd_msg.DOOR_R_FWD_CABIN.MsgLine[2].MsgStatus = bool2num[ZPH6]

end




function A333_ewd_msg.DOOR_R_MID_CABIN.Action()

	A333_ewd_msg.DOOR_R_MID_CABIN.MsgLine[1].MsgStatus = bool2num[ZPH6]
	A333_ewd_msg.DOOR_R_MID_CABIN.MsgLine[2].MsgStatus = bool2num[ZPH6]

end




function A333_ewd_msg.DOOR_R_AFT_CABIN.Action()

	A333_ewd_msg.DOOR_R_AFT_CABIN.MsgLine[1].MsgStatus = bool2num[ZPH6]
	A333_ewd_msg.DOOR_R_AFT_CABIN.MsgLine[2].MsgStatus = bool2num[ZPH6]

end




function A333_ewd_msg.DOOR_L_EMER_EXIT.Action()

	A333_ewd_msg.DOOR_L_EMER_EXIT.MsgLine[1].MsgStatus = bool2num[ZPH6]
	A333_ewd_msg.DOOR_L_EMER_EXIT.MsgLine[2].MsgStatus = bool2num[ZPH6]

end




function A333_ewd_msg.DOOR_R_EMER_EXIT.Action()

	A333_ewd_msg.DOOR_R_EMER_EXIT.MsgLine[1].MsgStatus = bool2num[ZPH6]
	A333_ewd_msg.DOOR_R_EMER_EXIT.MsgLine[2].MsgStatus = bool2num[ZPH6]

end




function A333_ewd_msg.DOOR_R_AVIONICS.Action()

	A333_ewd_msg.DOOR_R_AVIONICS.MsgLine[1].MsgStatus = bool2num[ZPH6]
	A333_ewd_msg.DOOR_R_AVIONICS.MsgLine[2].MsgStatus = bool2num[ZPH6]

end










function A333_ewd_msg.TO_MEMO.Action()

    local a = ZPH2 or ZPH9
    local b = SGNDSPLRA_1 or SGNDSPLRA_2
    local c = SS16F08_1 or SS16F08_2
    local d =  SS20F14_1 or SS20F14_2
    local e = SS23F22_1 or SS23F22_2
    local f = WTOCT and a
    local g = (not GDMXRA_1_NCD) and GDMXRA_1
    local h = (not GDMXRA_2_NCD) and GDMXRA_2
    local i = c or d or e
    local j = not WTOCNORM or ZPH6
    toMemoSRR01:update(f, j)
    local k = g or h
    local l = toMemoSRR01.Q and WTOCNORM

	A333_ewd_msg.TO_MEMO.MsgLine[1].MsgStatus = bool2num[not(k)]
	A333_ewd_msg.TO_MEMO.MsgLine[2].MsgStatus = bool2num[not(k)]
	A333_ewd_msg.TO_MEMO.MsgLine[3].MsgStatus = bool2num[k]
	A333_ewd_msg.TO_MEMO.MsgLine[4].MsgStatus = bool2num[not CSIGNSONP]
	A333_ewd_msg.TO_MEMO.MsgLine[5].MsgStatus = bool2num[not CSIGNSONP]
	A333_ewd_msg.TO_MEMO.MsgLine[6].MsgStatus = bool2num[CSIGNSONP]
	A333_ewd_msg.TO_MEMO.MsgLine[7].MsgStatus = bool2num[WCABNR]
	A333_ewd_msg.TO_MEMO.MsgLine[8].MsgStatus = bool2num[WCABNR]
	A333_ewd_msg.TO_MEMO.MsgLine[9].MsgStatus = bool2num[WCABR]
	A333_ewd_msg.TO_MEMO.MsgLine[10].MsgStatus = bool2num[not b]
	A333_ewd_msg.TO_MEMO.MsgLine[11].MsgStatus = bool2num[not b]
	A333_ewd_msg.TO_MEMO.MsgLine[12].MsgStatus = bool2num[b]
	A333_ewd_msg.TO_MEMO.MsgLine[13].MsgStatus = bool2num[not i]
	A333_ewd_msg.TO_MEMO.MsgLine[14].MsgStatus = bool2num[not i]
	A333_ewd_msg.TO_MEMO.MsgLine[15].MsgStatus = bool2num[i]
	A333_ewd_msg.TO_MEMO.MsgLine[16].MsgStatus = bool2num[not toMemoSRR01.Q]
	A333_ewd_msg.TO_MEMO.MsgLine[17].MsgStatus = bool2num[not toMemoSRR01.Q]
	A333_ewd_msg.TO_MEMO.MsgLine[18].MsgStatus = bool2num[l]

end

function A333_ewd_msg.TO_MEMO.ActionReset()
	toMemoSRR01:reset()
end




function A333_ewd_msg.LDG_MEMO.Action()

    local a =  SFLPFY and (not SSLTFY)
    local b =  SGNDSPLRA_1 or SGNDSPLRA_2
    local c = SS23F32_1 or SS23F32_2
    local d = HGSYSLP and HYSYSLP
    local e = GNGDL_1 or GNGDL_2
    local f = GLGDL_1 or GLGDL_2
    local g = GRGDL_1 or GRGDL_2
    local h = (not a) and (not NFFMSLDG3)
    local i = a and SFLPSF and (not d)
    local j = NFFMSLDG3 and (not a)
    local k = e and f and g
    local l = (not i) and a
    local m = h or i
    local n = j or l or NAPPRAL
    local o = (not CSIGNSONP) and (not EEMER)
    local p = CSIGNSONP and (not EEMER)
    local q = not c and m and (not NAPPRAL)
    local r = c and m and (not NAPPRAL)
    local s = NSFCONF3NS and n
    local t = (not NSFCONF3NS) and n

	A333_ewd_msg.LDG_MEMO.MsgLine[1].MsgStatus = bool2num[not k]
	A333_ewd_msg.LDG_MEMO.MsgLine[2].MsgStatus = bool2num[not k]
	A333_ewd_msg.LDG_MEMO.MsgLine[3].MsgStatus = bool2num[k]
	A333_ewd_msg.LDG_MEMO.MsgLine[4].MsgStatus = bool2num[o]
	A333_ewd_msg.LDG_MEMO.MsgLine[5].MsgStatus = bool2num[o]
	A333_ewd_msg.LDG_MEMO.MsgLine[6].MsgStatus = bool2num[p]
	A333_ewd_msg.LDG_MEMO.MsgLine[7].MsgStatus = bool2num[WCABNR]
	A333_ewd_msg.LDG_MEMO.MsgLine[8].MsgStatus = bool2num[WCABNR]
	A333_ewd_msg.LDG_MEMO.MsgLine[9].MsgStatus = bool2num[WCABR]
	A333_ewd_msg.LDG_MEMO.MsgLine[10].MsgStatus = bool2num[not b]
	A333_ewd_msg.LDG_MEMO.MsgLine[11].MsgStatus = bool2num[not b]
	A333_ewd_msg.LDG_MEMO.MsgLine[12].MsgStatus = bool2num[b]
	A333_ewd_msg.LDG_MEMO.MsgLine[13].MsgStatus = bool2num[q]
	A333_ewd_msg.LDG_MEMO.MsgLine[14].MsgStatus = bool2num[q]
	A333_ewd_msg.LDG_MEMO.MsgLine[15].MsgStatus = bool2num[r]
	A333_ewd_msg.LDG_MEMO.MsgLine[16].MsgStatus = bool2num[s]
	A333_ewd_msg.LDG_MEMO.MsgLine[17].MsgStatus = bool2num[s]
	A333_ewd_msg.LDG_MEMO.MsgLine[18].MsgStatus = bool2num[t]

end




function A333_ewd_msg.IRS_IN_ALIGN.Action()

	local a = Z7 and ZR1O2RUN
	local b = Z6 and ZR1O2RUN
	local c = Z5 and ZR1O2RUN
	local d = Z4 and ZR1O2RUN
	local e = Z3 and ZR1O2RUN
	local f = Z2 and ZR1O2RUN
	local g = Z1 and ZR1O2RUN
	local h = ZNAV and ZR1O2RUN
	local j = ZNAV and not(ZR1O2RUN)
	local k = h and NOIRSAL

	local m = Z7 and not(ZR1O2RUN)
	local n = Z6 and not(ZR1O2RUN)
	local p = Z5 and not(ZR1O2RUN)
	local q = Z4 and not(ZR1O2RUN)
	local r = Z3 and not(ZR1O2RUN)
	local s = Z2 and not(ZR1O2RUN)
	local t = Z1 and not(ZR1O2RUN)
	local u = j and not(NOIRSAL)
	local v = j and NOIRSAL

	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[1].MsgStatus = bool2num[m]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[2].MsgStatus = bool2num[a]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[3].MsgStatus = bool2num[n]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[4].MsgStatus = bool2num[b]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[5].MsgStatus = bool2num[p]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[6].MsgStatus = bool2num[c]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[7].MsgStatus = bool2num[q]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[8].MsgStatus = bool2num[d]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[9].MsgStatus = bool2num[r]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[10].MsgStatus = bool2num[e]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[11].MsgStatus = bool2num[s]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[12].MsgStatus = bool2num[f]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[13].MsgStatus = bool2num[t]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[14].MsgStatus = bool2num[g]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[15].MsgStatus = bool2num[v]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[16].MsgStatus = bool2num[k]
	A333_ewd_msg.IRS_IN_ALIGN.MsgLine[17].MsgStatus = bool2num[u]

end














local function A333_fws_run_action_functions()

	for _, msg in ipairs(A333_ewd_msg_cue_L) do
		if A333_ewd_msg[msg.Name].Action then
			A333_ewd_msg[msg.Name].Action()
		end
	end

end



--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_500()

	A333_fws_run_action_functions()

end


--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")





