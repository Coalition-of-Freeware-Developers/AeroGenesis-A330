jit.off()
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
*       					     COPYRIGHT © 2021, 2022
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

local excessCabAltThreshold01 = newThreshold('excessCabAltThreshold01', '>', 10000.0)

local lgNotDnLckActPulse01 = newFallingEdgePulse('lgNotDnLckActPulse01')
local lgNotDnLckActSRS01 = newSRlatchSetPriority('lgNotDnLckActSRS01')

local lgNotUpLckActThr01 = newThreshold('lgNotUpLckActThr01', '>', 220.0)
local lgNotUpLckActThr02 = newThreshold('lgNotUpLckActThr02', '>', 220.0)
local lgNotUpLckActThr03 = newThreshold('lgNotUpLckActThr03', '>', 220.0)
local lgNotUpLckActConf01 = newLeadingEdgeDelayedConfirmation('lgNotUpLckActConf01', 10.0)
local lgNotUpLckActPulse01 = newFallingEdgePulse('lgNotUpLckActPulse01')
local lgNotUpLckActSRS01 = newSRlatchSetPriority('lgNotUpLckActSRS01')

local doorNotClsdActThr01 = newThreshold('doorNotClsdActThr01', '>', 220.0)
local doorNotClsdActThr02 = newThreshold('doorNotClsdActThr02', '>', 220.0)
local doorNotClsdActThr03 = newThreshold('doorNotClsdActThr03', '>', 220.0)
local doorNotClsdActPulse01 = newFallingEdgePulse('doorNotClsdActPulse01')
local doorNotClsdActSRS01 = newSRlatchSetPriority('doorNotClsdActSRS01')

local eng1failActMtrig01 = newLeadingEdgeTrigger('eng1failActMtrig01', 30.0)
local eng1failActVL01 = newVariableText('eng1failActVL01', 10.0, 0.0, 1.0, 'dn', 1.0)

local eng2failActMtrig01 = newLeadingEdgeTrigger('eng2failActMtrig01', 30.0)
local eng2failActVL01 = newVariableText('eng2failActVL01', 10.0, 0.0, 1.0, 'dn', 1.0)

local toMemoSRR01 = newSRlatchResetPriority('toMemoSRR01')

local eng1OilTmpThreshold01 = newThreshold('eng1OilTmpThreshold01', '<', 50.0)
local eng1OilTmpThreshold02 = newThreshold('eng1OilTmpThreshold02', '<', -10.0)

local eng2OilTmpThreshold01 = newThreshold('eng2OilTmpThreshold01', '<', 50.0)
local eng2OilTmpThreshold02 = newThreshold('eng2OilTmpThreshold02', '<', -10.0)

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

	local a = {E1 = BAPUBPBOF_1, E2 = BAPUBPBOF_2}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = bNOT(JR1TLAI), E2 = bNOT(JR2TLAI)}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = KYAWLC_1, E2 = KRUDLC_1, E3 = KRTLLC_1, E4 = KFACNOH_1}
	c.S = bAND4(c.E1, c.E2, c.E3, c.E4)

	local e = {E1 = IWAIPBON, E2 = QAVAIL}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = QAVAIL, E2 = a.S}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = WETOPS, E2 = EEMER}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = EEMER, E2 = bNOT(WETOPS)}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = c.S, E2 = KFACNOH_1}
	i.S = bOR(i.E1, i.E2)

	local l = {E1 = JML1ON, E2 = JML2ON}
	l.S = bOR(l.E1, l.E2)

	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[1].MsgStatus = bool2num[bNOT(JRIGNSEL)]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[2].MsgStatus = bool2num[b.S]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[3].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[4].MsgStatus = 0								-- TODO:  THIS SYSTEM IS NOT MODELED
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[5].MsgStatus = bool2num[g.S]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[6].MsgStatus = bool2num[h.S]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[7].MsgStatus = bool2num[i.S]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[8].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[9].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[10].MsgStatus = bool2num[WA330]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[11].MsgStatus = bool2num[WA330]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[12].MsgStatus = bool2num[e.S]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[13].MsgStatus = bool2num[f.S]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[14].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[15].MsgStatus = bool2num[QAVAIL]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[16].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[17].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[18].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[19].MsgStatus = bool2num[bNOT(GLGDNLKD)]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[20].MsgStatus = bool2num[bNOT(GLGDNLKD)]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[21].MsgStatus = bool2num[WA330]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[22].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[23].MsgStatus = bool2num[l.S]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[24].MsgStatus = bool2num[QMSON]
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[25].MsgStatus = 1
	A333_ewd_msg.ENG_DUAL_FAULT.MsgLine[26].MsgStatus = 1

end



function A333_ewd_msg.ENG_1_FIRE.Action()

	eng1FireActVL01:update(UE1FPBOUT)

	local a = {E1 = bNOT(ZGND), E2 = UE1FBLP}
	a.S = bAND(a.E1, a.E2)

	eng1FireActVL02:update(a.s)

	local b = {E1 = EBA1PBON, E2 = EBA2PBON}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = bNOT(JR2TLAI), E2 = bNOT(JR1TLAI)}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = JML1ON_INV, E2 = JML1ON}
	d.S = bOR(d.E1, d.E2)

	local e = { E1 = eng1FireActVL02.s1, E2 = bNOT(UE1ABLP)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = bNOT(UE1ABLP), E2 = eng1FireActVL02.s2}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = ZGND, E2 = JML2ON}
	g.S = bAND(g.E1, g.E2)

	local h = { E1 = eng1FireActVL01.s2, E2 = bNOT(ZGND), E3 = bNOT(UE1FBLP)}
	h.S = bAND3(h.E1, h.E2, h.E3)

	local i = {E1 = ZGND, E2 = bNOT(UE1FBLP)}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = QMSON, E2 = ZGND, E3 = QAVAIL}
	j.S = bAND3(j.E1, j.E2, j.E3)

	local k = {E1 = bNOT(JR1TLAI), E2 = bNOT(ZGND)}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = c.S, E2 = ZGND}
	l.S = bAND(l.E1, l.E2)

	local m = {E1 = bNOT(GPBRKON), E2 = ZGND}
	m.S = bAND(m.E1, m.E2)

	local n = { E1 = bNOT(ZGND), E2 = eng1FireActVL01.s1, E3 = bNOT(UE1FBLP)}
	n.S = bAND3(n.E1, n.E2, n.E3)

	local o = {E1 = bNOT(UE1ABLP), E2 = ZGND}
	o.S = bAND(o.E1, o.E2)

	local p = {E1 = e.S, E2 = f.S}
	p.S = bOR(p.E1, p.E2)

	local q = {E1 = ZGND, E2 = b.S}
	q.S = bAND(q.E1, q.E2)

	A333_ewd_msg.ENG_1_FIRE.MsgLine[1].MsgStatus = bool2num[k.S]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[2].MsgStatus = bool2num[l.S]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[3].MsgStatus = bool2num[m.S]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[4].MsgStatus = bool2num[m.S]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[5].MsgStatus = bool2num[d.S]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[6].MsgStatus = bool2num[bNOT(UE1FPBOUT)]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[7].MsgText = string.format(' -AGENT 1 AFT %2dS..DISCH', eng1FireActVL01.out); A333_ewd_msg.ENG_1_FIRE.MsgLine[7].MsgStatus = bool2num[n.S]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[8].MsgStatus = bool2num[h.S]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[9].MsgStatus = bool2num[i.S]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[10].MsgStatus = bool2num[o.S]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[11].MsgStatus = bool2num[g.S]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[12].MsgStatus = 1
	A333_ewd_msg.ENG_1_FIRE.MsgLine[13].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[14].MsgText = string.format('  .IF FIRE AFTER %2dS:   ', eng1FireActVL02.out); A333_ewd_msg.ENG_1_FIRE.MsgLine[14].MsgStatus = bool2num[e.S]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[15].MsgStatus = bool2num[p.S]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[16].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[17].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[18].MsgStatus = bool2num[j.S]
	A333_ewd_msg.ENG_1_FIRE.MsgLine[19].MsgStatus = bool2num[q.S]

end

function A333_ewd_msg.ENG_1_FIRE.ActionReset()
	eng1FireActVL01:init()
	eng1FireActVL02:init()
end





function A333_ewd_msg.ENG_2_FIRE.Action()

	eng2FireActVL01:update(UE1FPBOUT)

	local a = {E1 = bNOT(ZGND), E2 = UE2FBLP}
	a.S = bAND(a.E1, a.E2)

	eng2FireActVL02:update(a.s)

	local b = {E1 = EBA1PBON, E2 = EBA2PBON}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = bNOT(JR1TLAI), E2 = bNOT(JR2TLAI)}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = JML2ON_INV, E2 = JML2ON}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = eng2FireActVL02.s1, E2 = bNOT(UE2ABLP)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = bNOT(UE2ABLP), E2 = eng2FireActVL02.s2}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = ZGND, E2 = JML2ON}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = eng2FireActVL01.s2, E2 = bNOT(ZGND), E3 = bNOT(UE2FBLP)}
	h.S = bAND3(h.E1, h.E2, h.E3)

	local i = {E1 = ZGND, E2 = bNOT(UE2FBLP)}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = QMSON, E2 = ZGND, E3 = QAVAIL}
	j.S = bAND3(j.E1, j.E2, j.E3)

	local k = {E1 = bNOT(JR2TLAI), E2 = bNOT(ZGND)}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = c.S, E2 = ZGND}
	l.S = bAND(l.E1, l.E2)

	local m = {E1 = bNOT(GPBRKON), E2 = ZGND}
	m.S = bAND(m.E1, m.E2)

	local n = {E1 = bNOT(ZGND), E2 = eng2FireActVL01.s1, E3 = bNOT(UE2FBLP)}
	n.S = bAND3(n.E1, n.E2, n.E3)

	local o = {E1 = bNOT(UE2ABLP), E2 = ZGND}
	o.S = bAND(o.E1, o.E2)

	local p = {E1 = e.S, E2 = f.S}
	p.S = bOR(p.E1, p.E2)

	local q = {E1 = ZGND, E2 = b.S}
	q.S = bAND(q.E1, q.E2)

	A333_ewd_msg.ENG_2_FIRE.MsgLine[1].MsgStatus = bool2num[k.S]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[2].MsgStatus = bool2num[l.S]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[3].MsgStatus = bool2num[m.S]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[4].MsgStatus = bool2num[m.S]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[5].MsgStatus = bool2num[d.S]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[6].MsgStatus = bool2num[bNOT(UE2FPBOUT)]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[7].MsgText = string.format(' -AGENT 1 AFT %2dS..DISCH', eng2FireActVL01.out); A333_ewd_msg.ENG_2_FIRE.MsgLine[7].MsgStatus = bool2num[n.S]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[8].MsgStatus = bool2num[h.S]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[9].MsgStatus = bool2num[i.S]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[10].MsgStatus = bool2num[o.S]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[11].MsgStatus = bool2num[g.S]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[12].MsgStatus = 1
	A333_ewd_msg.ENG_2_FIRE.MsgLine[13].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[14].MsgText = string.format('  .IF FIRE AFTER %2dS:  ', eng2FireActVL02.out); A333_ewd_msg.ENG_2_FIRE.MsgLine[14].MsgStatus = bool2num[e.S]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[15].MsgStatus = bool2num[p.S]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[16].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[17].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[18].MsgStatus = bool2num[j.S]
	A333_ewd_msg.ENG_2_FIRE.MsgLine[19].MsgStatus = bool2num[q.S]

end

function A333_ewd_msg.ENG_2_FIRE.ActionReset()
	eng2FireActVL01:init()
	eng2FireActVL02:init()
end




function A333_ewd_msg.APU_FIRE.Action()

	apuFireActVL01:update(UAPUFPBOUT)

	local a = {E1 = apuFireActVL01.s1, E2 = bNOT(UAPUELP)}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = apuFireActVL01.s2, E2 = bNOT(UAPUELP)}
	b.S = bAND(b.E1, b.E2)

	A333_ewd_msg.APU_FIRE.MsgLine[1].MsgStatus = bool2num[bNOT(UAPUFPBOUT)]
	A333_ewd_msg.APU_FIRE.MsgLine[2].MsgText = string.format(' -AGENT AFT %2dS...DISCH', apuFireActVL01.out); MsgStatus = bool2num[a.S]
	A333_ewd_msg.APU_FIRE.MsgLine[3].MsgStatus = bool2num[b.S]
	A333_ewd_msg.APU_FIRE.MsgLine[4].MsgStatus = bool2num[QMSON]

end

function A333_ewd_msg.APU_FIRE.ActionReset()
	apuFireActVL01:init()
end






function A333_ewd_msg.SLATS_CONFIG.Action()

	A333_ewd_msg.SLATS_CONFIG.MsgLine[1].MsgStatus = 1

end



function A333_ewd_msg.FLAPS_CONFIG.Action()

	A333_ewd_msg.FLAPS_CONFIG.MsgLine[1].MsgStatus = 0

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

	excessCabAltThreshold01:update(PALTI)

	local a = {E1 = JR1TLAI, E2 = JR2TLAI}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = SSPBR_1, E2 = SSPBR_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = JR1ESI, E2 = JR2ESI}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = bNOT(a.S), E2 = bNOT(KATHRE)}
	d.S = bAND(d.E1, d.E2)

	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[1].MsgStatus = bool2num[excessCabAltThreshold01.out]
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[2].MsgStatus = bool2num[excessCabAltThreshold01.out]
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[3].MsgStatus = 1
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[4].MsgStatus = 1
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[5].MsgStatus = bool2num[d.S]
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[6].MsgStatus = bool2num[bNOT(b.S)]
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[7].MsgStatus = 1
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[8].MsgStatus = bool2num[bNOT(CSIGNSONP)]
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[9].MsgStatus = bool2num[bNOT(c.S)]
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[10].MsgStatus = 1
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[11].MsgStatus = 1
	A333_ewd_msg.EXCESS_CAB_ALT.MsgLine[12].MsgStatus = 1

end






function A333_ewd_msg.ENG_1_OIL_LO_PR.Action()

	A333_ewd_msg.ENG_1_OIL_LO_PR.MsgLine[1].MsgStatus = bool2num[JML1ON]
	A333_ewd_msg.ENG_1_OIL_LO_PR.MsgLine[2].MsgStatus = bool2num[bNOT(JR1TLAI)]
	A333_ewd_msg.ENG_1_OIL_LO_PR.MsgLine[3].MsgStatus = bool2num[JML1ON]

end



function A333_ewd_msg.ENG_2_OIL_LO_PR.Action()

	A333_ewd_msg.ENG_2_OIL_LO_PR.MsgLine[1].MsgStatus = bool2num[JML2ON]
	A333_ewd_msg.ENG_2_OIL_LO_PR.MsgLine[2].MsgStatus = bool2num[bNOT(JR2TLAI)]
	A333_ewd_msg.ENG_2_OIL_LO_PR.MsgLine[3].MsgStatus = bool2num[JML2ON]

end






function A333_ewd_msg.L_R_ELEV_FAULT.Action()

	A333_ewd_msg.L_R_ELEV_FAULT.MsgLine[1].MsgStatus = 1
	A333_ewd_msg.L_R_ELEV_FAULT.MsgLine[2].MsgStatus = 1
	A333_ewd_msg.L_R_ELEV_FAULT.MsgLine[3].MsgStatus = 1

end












function A333_ewd_msg.GEAR_NOT_DOWNLOCKED.Action()

	local a = {E1 = GGLSD_1_INV, E2 = GGLSD_2_INV}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = GGLSD_1, E2 = GGLSD_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = ZPH6, E2 = ZPH7}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = GGLSD_1, E2 = GGLSD_2}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = a.S, E2 = b.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = d.S, E2 = e.S}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = GGNDNLD, E2 = f.S, E3 = c.S}
	g.S = bAND3(g.E1, g.E2, g.E3)

	lgNotDnLckActPulse01:update(g.S)
	lgNotDnLckActSRS01:update(lgNotDnLckActPulse01.OUT, ZPH8)

	local h = {E1 = bNOT(lgNotDnLckActSRS01.Q), E2 = g.S}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = h.S, E2 = bNOT(GLGDNLKD)}
	i.S = bAND(i.E1, i.E2)

	A333_ewd_msg.GEAR_NOT_DOWNLOCKED.MsgLine[1].MsgStatus = bool2num[h.S]
	A333_ewd_msg.GEAR_NOT_DOWNLOCKED.MsgLine[2].MsgStatus = bool2num[i.S]
	A333_ewd_msg.GEAR_NOT_DOWNLOCKED.MsgLine[3].MsgStatus = bool2num[bNOT(GLGDNLKD)]

end

function A333_ewd_msg.GEAR_NOT_DOWNLOCKED.ActionReset()
	lgNotDnLckActSRS01:reset()
end






function A333_ewd_msg.FWD_CARGO_SMOKE.Action()

	local a = {E1 = XAFCGHT, E2 = XAFCGVENT}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = UFEB1I_1, E2 = UFEB1I_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = bNOT(UCB1LP_1), E2 = bNOT(UCB1LP_2)}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = UFEB2I_1, E2 = UFEB2I_2}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = bNOT(VFCDNIVFC), E2 = bNOT(VFCUPIVFC)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = e.S, E2 = bNOT(VFCIVPBOF), E3 = a.S}
	f.S = bAND3(f.E1, f.E2, f.E3)

	fwdCargoSmkConf01:update(f.S)

	local g = {E1 = b.S, E2 = c.S, E3 = bNOT(d.S)}
	g.S = bAND3(g.E1, g.E2, g.E3)

	local h = {E1 = b.S, E2 = c.S, E3 = d.S}
	h.S = bAND3(h.E1, h.E2, h.E3)

	A333_ewd_msg.FWD_CARGO_SMOKE.MsgLine[1].MsgStatus = bool2num[fwdCargoSmkConf01.OUT]
	A333_ewd_msg.FWD_CARGO_SMOKE.MsgLine[2].MsgStatus = bool2num[g.S]
	A333_ewd_msg.FWD_CARGO_SMOKE.MsgLine[3].MsgStatus = bool2num[h.S]

end

function A333_ewd_msg.FWD_CARGO_SMOKE.ActionReset()
	fwdCargoSmkConf01:resetTimer()
end






function A333_ewd_msg.AFT_CARGO_SMOKE.Action()

	local a = {E1 = XAACGHT, E2 = XAACGVENT}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = UFEB1I_1, E2 = UFEB1I_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = bNOT(UCB1LP_1), E2 = bNOT(UCB1LP_2)}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = UFEB2I_1, E2 = UFEB2I_2}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = bNOT(VACDNIVFC), E2 = bNOT(VACUPIVFC)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = e.S, E2 = bNOT(VACIVPBOF), E3 = a.S}
	f.S = bAND3(f.E1, f.E2, f.E3)

	aftCargoSmkConf01:update(f.S)

	local g = {E1 = b.S, E2 = c.S, E3 = bNOT(d.S)}
	g.S = bAND3(g.E1, g.E2, g.E3)

	local h = {E1 = b.S, E2 = c.S, E3 = d.S}
	h.S = bAND3(h.E1, h.E2, h.E3)

	A333_ewd_msg.AFT_CARGO_SMOKE.MsgLine[1].MsgStatus = bool2num[aftCargoSmkConf01.OUT]
	A333_ewd_msg.AFT_CARGO_SMOKE.MsgLine[2].MsgStatus = bool2num[g.S]
	A333_ewd_msg.AFT_CARGO_SMOKE.MsgLine[3].MsgStatus = bool2num[h.S]

end

function A333_ewd_msg.AFT_CARGO_SMOKE.ActionReset()
	aftCargoSmkConf01:resetTimer()
end







function A333_ewd_msg.ELEC_EMER_CONFIG.Action()

	local a = {E1 = QMSON, E2 = bNOT(QAVAIL)}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = bNOT(KRTLLC_1), E2 = bNOT(KRUDLC_1), E3 = bNOT(KYAWLC_1), E4 = bNOT(KFACNOH_1)}
	b.S = bAND4(b.E1, b.E2, b.E3, b.E4)

	--local d = {E1 = bNOT(PLESM_1), E2 = bNOT(PLESM_2)}			--TODO:  PLESM_1  PLESM_2
	--d.S = bOR(d.E1, d.E2)

	local e = {E1 = b.S, E2 = KFACNOH_1}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = GLGDNLKD, E2 = EEGNCON}
	f.S = bAND(f.E1, f.E2)

	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[1].MsgStatus = bool2num[HRATNFS]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[2].MsgStatus = bool2num[EGEN12R]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[3].MsgStatus = bool2num[EGENRESET]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[4].MsgStatus = bool2num[bNOT(EBTIEPBOF)]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[5].MsgStatus = bool2num[EGENRESET]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[6].MsgStatus = bool2num[bNOT(EEGNCON)]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[7].MsgStatus = bool2num[bNOT(JRIGNSEL)]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[8].MsgStatus = bool2num[bNOT(WETOPS)]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[9].MsgStatus = bool2num[WETOPS]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[10].MsgStatus = 1
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[11].MsgStatus = 1
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[12].MsgStatus = bool2num[bNOT(WMBE)]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[13].MsgStatus = 1
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[14].MsgStatus = 1
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[15].MsgStatus = bool2num[f.S]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[16].MsgStatus = bool2num[f.S]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[17].MsgStatus = bool2num[f.S]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[18].MsgStatus = bool2num[a.S]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[19].MsgStatus = bool2num[e.S]
	A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[20].MsgStatus = bool2num[VAVEPBO]
	--A333_ewd_msg.ELEC_EMER_CONFIG.MsgLine[21].MsgStatus = bool2num[d.S]			-- TODO: NOT MODELED

end










function A333_ewd_msg.ENG_1_FAIL.Action()

	eng1failActMtrig01:update(ZPH5)
	eng1failActVL01:update(UE1FPBOUT)

	local a = {E1 = JR1TLA_1A_VAL, E2 = JR1TLA_1B_VAL}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = ZPH2, E2 = ZPH9}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = ZPH4, E2 = eng1failActMtrig01.OUT, E3 = bNOT(JML1ON)}
	c.S = bOR3(c.E1, c.E2, c.E3)

	local d = {E1 = eng1failActMtrig01.OUT, E2 = ZPH4}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = bNOT(UE1FBLP), E2 = bNOT(ZGND), E3 = bNOT(d.S), E4 = eng1failActVL01.s1}
	e.S = bAND4(e.E1, e.E2, e.E3, e.E4)

	local f = {E1 = eng1failActVL01.s2, E2 = bNOT(d.S), E3 = bNOT(ZGND), E4 = bNOT(UE1FBLP)}
	f.S = bAND4(f.E1, f.E2, f.E3, f.E4)

	local g = {E1 = bNOT(UE1FBLP), E2 = ZGND, E3 = bNOT(d.S)}
	g.S = bAND(g.E1, g.E2, g.E3)

	local h = {E1 = bNOT(b.S), E2  = bNOT(JR1ESI)}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = bNOT(b.S), E2  = bNOT(c.S)}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = bNOT(JR1TLAI), E2 = a.S, E3 = bNOT(d.S)}
	j.S = bAND3(j.E1, j.E2, j.E3)

	local k = {E1 = JML1ON, E2 = bNOT(d.S)}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = bNOT(d.S), E2 = bNOT(UE1FPBOUT)}
	l.S = bAND(l.E1, l.E2)

	local m = {E1 = bNOT(d.S), E2 = bNOT(UE1FPBOUT)}
	m.S = bAND(m.E1, m.E2)

	A333_ewd_msg.ENG_1_FAIL.MsgLine[1].MsgStatus = bool2num[h.S]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[2].MsgStatus = bool2num[j.S]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[3].MsgStatus = bool2num[i.S]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[4].MsgStatus = bool2num[k.S]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[5].MsgStatus = bool2num[l.S]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[6].MsgStatus = bool2num[m.S]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[7].MsgText = string.format(' -AGENT 1 AFT %2dS..DISCH', eng1failActVL01.out); A333_ewd_msg.ENG_1_FAIL.MsgLine[1].MsgStatus = bool2num[e.S]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[8].MsgStatus = bool2num[f.S]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[9].MsgStatus = bool2num[g.S]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[10].MsgStatus = bool2num[bNOT(d.s)]
	A333_ewd_msg.ENG_1_FAIL.MsgLine[11].MsgStatus = bool2num[bNOT(d.S)]

end

function A333_ewd_msg.ENG_1_FAIL.ActionReset()
	eng1failActVL01:init()
end





function A333_ewd_msg.ENG_1_OIL_HI_TEMP.Action()

	A333_ewd_msg.ENG_1_OIL_HI_TEMP.MsgLine[1].MsgStatus = bool2num[bNOT(JR1TLAI)]
	A333_ewd_msg.ENG_1_OIL_HI_TEMP.MsgLine[2].MsgStatus = bool2num[JML1ON]

end



function A333_ewd_msg.ENG_1_SHUT_DOWN.Action()

	local a = {E1 = bNOT(BXFVFC_1), E2 = BXFVFC_1_VAL}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = bNOT(BXFVFC_2), E2 = BXFVFC_2_VAL}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = ZPH4, E2 = ZPH5}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = BXFVFC_1, E2 = BXFVFC_2}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = a.S, E2 = b.S}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = IWAION, E2 = bNOT(UE1FPBOUT)}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = UE1FPBOUT, E2 = ZGND}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = bNOT(AP1PBOF), E2 = bNOT(AP2PBOF), E3 = IWAION, E4 = bNOT(c.S), E5 = bNOT(UE1FPBOUT)}
	h.S = bAND5(h.E1, h.E2, h.E3, h.E4, h.E5)

	local i = {E1 = IWAION, E2 = UE1FPBOUT}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = f.S, E2 = bNOT(c.S), E3 = d.S}
	j.S = bAND3(j.E1, j.E2, j.E3)

	local k = {E1 = UE1FPBOUT, E2 = e.S}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = bNOT(JR2ESI), E2 = bNOT(g.S)}
	l.S = bAND(l.E1, l.E2)

	local m = {E1 = bNOT(FXFVPBON), E2 = bNOT(g.S)}
	m.S = bAND(m.E1, m.E2)

	local n = {E1 = bNOT(c.S), E2 = bNOT(ZGND), E3 = JR1RUSTWD}
	n.S = bAND3(n.E1, n.E2, n.E3)

	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[1].MsgStatus = bool2num[h.S]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[2].MsgStatus = bool2num[j.S]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[3].MsgStatus = bool2num[l.S]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[4].MsgStatus = bool2num[m.S]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[5].MsgStatus = bool2num[n.S]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[6].MsgStatus = bool2num[n.S]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[7].MsgStatus = bool2num[k.S]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[8].MsgStatus = bool2num[i.S]
	A333_ewd_msg.ENG_1_SHUT_DOWN.MsgLine[9].MsgStatus = bool2num[UE1FPBOUT]

end






function A333_ewd_msg.ENG_2_FAIL.Action()

	eng2failActMtrig01:update(ZPH5)
	eng2failActVL01:update(UE2FPBOUT)

	local a = {E1 = JR2TLA_2A_VAL, E2 = JR2TLA_2B_VAL}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = ZPH2, E2 = ZPH9}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = ZPH4, E2 = eng2failActMtrig01.OUT, E3 = bNOT(JML2ON)}
	c.S = bOR3(c.E1, c.E2, c.E3)

	local d = {E1 = eng2failActMtrig01.OUT, E2 = ZPH4}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = bNOT(UE2FBLP), E2 = bNOT(ZGND), E3 = bNOT(d.S), E4 = eng2failActVL01.s1}
	e.S = bAND4(e.E1, e.E2, e.E3, e.E4)

	local f = {E1 = eng2failActVL01.s2, E2 = bNOT(d.S), E3 = bNOT(ZGND), E4 = bNOT(UE2FBLP)}
	f.S = bAND4(f.E1, f.E2, f.E3, f.E4)

	local g = {E1 = bNOT(UE2FBLP), E2 = ZGND, E3 = bNOT(d.S)}
	g.S = bAND3(g.E1, g.E2, g.E3)

	local h = {E1 = bNOT(b.S), E2  = bNOT(JR2ESI)}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = bNOT(b.S), E2  = bNOT(c.S)}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = bNOT(JR2TLAI), E2 = a.S, E3 = bNOT(d.S)}
	j.S = bAND3(j.E1, j.E2, j.E3)

	local k = {E1 = JML2ON, E2 = bNOT(d.S)}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = bNOT(d.S), E2 = bNOT(UE2FPBOUT)}
	l.S = bAND(l.E1, l.E2)

	local m = {E1 = bNOT(d.S), E2 = bNOT(UE2FPBOUT)}
	m.S = bAND(m.E1, m.E2)

	A333_ewd_msg.ENG_2_FAIL.MsgLine[1].MsgStatus = bool2num[h.S]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[2].MsgStatus = bool2num[j.S]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[3].MsgStatus = bool2num[i.S]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[4].MsgStatus = bool2num[k.S]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[5].MsgStatus = bool2num[l.S]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[6].MsgStatus = bool2num[m.S]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[7].MsgText = string.format(' -AGENT 1 AFT %2dS..DISCH', eng2failActVL01.out); A333_ewd_msg.ENG_2_FAIL.MsgLine[1].MsgStatus = bool2num[e.S]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[8].MsgStatus = bool2num[f.S]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[9].MsgStatus = bool2num[g.S]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[10].MsgStatus = bool2num[bNOT(d.s)]
	A333_ewd_msg.ENG_2_FAIL.MsgLine[11].MsgStatus = bool2num[bNOT(d.S)]

end

function A333_ewd_msg.ENG_2_FAIL.ActionReset()
	eng2failActVL01:init()
end




function A333_ewd_msg.ENG_2_OIL_HI_TEMP.Action()

	A333_ewd_msg.ENG_2_OIL_HI_TEMP.MsgLine[1].MsgStatus = bool2num[bNOT(JR2TLAI)]
	A333_ewd_msg.ENG_2_OIL_HI_TEMP.MsgLine[2].MsgStatus = bool2num[JML2ON]

end






function A333_ewd_msg.ENG_2_SHUT_DOWN.Action()

	local a = {E1 = bNOT(BXFVFC_1), E1 = BXFVFC_1_VAL}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = bNOT(BXFVFC_2), E1 = BXFVFC_2_VAL}
	b.S = bAND(b.E1, b.E2)

	local bb = {E1 = WETOPS, E2 = EEMER}
	bb.S = bAND(bb.E1, bb.E2)

	local c = {E1 = ZPH4, E2 = ZPH5}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = BXFVFC_1, E2 = BXFVFC_2}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = a.S, E2 = b.S}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = IWAION, E2 = bNOT(UE2FPBOUT)}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = UE2FPBOUT, E2 = ZGND}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = bNOT(AP1PBOF), E2 = bNOT(AP2PBOF), E3 = IWAION, E4 = bNOT(c.S), E5 = bNOT(UE2FPBOUT)}
	h.S = bAND5(h.E1, h.E2, h.E3, h.E4, h.E5)

	local i = {E1 = IWAION, E2 = UE2FPBOUT}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = f.S, E2 = bNOT(c.S), E3 = d.S}
	j.S = bAND3(j.E1, j.E2, j.E3)

	local k = {E1 = UE2FPBOUT, E2 = e.S}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = bNOT(JR1ESI), E2 = bNOT(g.S)}
	l.S = bAND(l.E1, l.E2)

	local m = {E1 = bNOT(FXFVPBON), E2 = bNOT(g.S)}
	m.S = bAND(m.E1, m.E2)

	local n = {E1 = bNOT(c.S), E2 = bNOT(ZGND), E3 = JR2RUSTWD}
	n.S = bAND3(n.E1, n.E2, n.E3)

	local o = {E1 = h.S,  E2 = bb.S}
	o.S = bAND(o.E1, o.E2)

	local p = {E1 = h.S, E2 = bNOT(bb.S)}
	p.S = bAND(p.E1, p.E2)

	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[1].MsgStatus = bool2num[o.S]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[2].MsgStatus = bool2num[p.S]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[3].MsgStatus = bool2num[j.S]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[4].MsgStatus = bool2num[l.S]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[5].MsgStatus = bool2num[m.S]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[6].MsgStatus = bool2num[n.S]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[7].MsgStatus = bool2num[n.S]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[8].MsgStatus = bool2num[k.S]
	A333_ewd_msg.ENG_2_SHUT_DOWN.MsgLine[9].MsgStatus = bool2num[i.S]
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

	eng1OilTmpThreshold01:update(JR1OT)
	eng1OilTmpThreshold02:update(JR1OT)

	local a = { E1 = JR1OT_INV, E2 = JR1OT_NCD }
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = eng1OilTmpThreshold01.out, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = bNOT(a.S), E2 = eng1OilTmpThreshold02.out}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.ENG_1_OIL_LO_TEMP.MsgLine[1].MsgStatus = bool2num[b.S]
	A333_ewd_msg.ENG_1_OIL_LO_TEMP.MsgLine[2].MsgStatus = bool2num[c.S]

end





function A333_ewd_msg.ENG_2_OIL_LO_TEMP.Action()

	eng2OilTmpThreshold01:update(JR2OT)
	eng2OilTmpThreshold02:update(JR2OT)

	local a = { E1 = JR2OT_INV, E2 = JR2OT_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = eng2OilTmpThreshold01.out, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = bNOT(a.S), E2 = eng2OilTmpThreshold02.out}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.ENG_2_OIL_LO_TEMP.MsgLine[1].MsgStatus = bool2num[b.S]
	A333_ewd_msg.ENG_2_OIL_LO_TEMP.MsgLine[2].MsgStatus = bool2num[c.S]

end







function A333_ewd_msg.DC_EMER_CONFIG.Action()

	A333_ewd_msg.DC_EMER_CONFIG.MsgLine[1].MsgStatus = bool2num[EEGNCON]

end






function A333_ewd_msg.HYD_BY_SYS_LO_PR.Action()

	local a = {E1 = HBRTUP, E2 = HBROVHT}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = HBRQLO, E2 = HBRLL}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = HBRLAP, E2 = a.S, E3 = b.S}
	c.S = bOR3(c.E1, c.E2, c.E3)

	local d = {E1 = bNOT(HNVMYEPF), E2 = bNOT(HYEPON)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = bNOT(HRATNFS), E2 = bNOT(c.S)}
	e.S = bAND(e.E1, e.E2)

	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[1].MsgStatus = bool2num[HRATNFS]
	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[2].MsgStatus = bool2num[d.S]
	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[3].MsgStatus = bool2num[e.S]
	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[4].MsgStatus = bool2num[bNOT(HBEPPBOF)]
	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[5].MsgStatus = bool2num[bNOT(HYPPBOF)]
	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[6].MsgStatus = 1
	A333_ewd_msg.HYD_BY_SYS_LO_PR.MsgLine[7].MsgStatus = 1

end





function A333_ewd_msg.HYD_GB_SYS_LO_PR.Action()

	local a = {E1 = HBRTUP, E2 = HBROVHT}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = HBRQLO, E2 = HBRLL}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = HBRLAP, E2 = a.S, E3 = b.S}
	c.S = bOR3(c.E1, c.E2, c.E3)

	local d = {E1 = bNOT(HRATNFS), E2 = bNOT(c.S)}
	d.S = bAND(d.E1, d.E2)

	A333_ewd_msg.HYD_GB_SYS_LO_PR.MsgLine[1].MsgStatus = bool2num[HRATNFS]
	A333_ewd_msg.HYD_GB_SYS_LO_PR.MsgLine[2].MsgStatus = bool2num[d.S]
	A333_ewd_msg.HYD_GB_SYS_LO_PR.MsgLine[3].MsgStatus = bool2num[bNOT(HBEPPBOF)]
	A333_ewd_msg.HYD_GB_SYS_LO_PR.MsgLine[4].MsgStatus = bool2num[bNOT(HGPPBOF)]
	A333_ewd_msg.HYD_GB_SYS_LO_PR.MsgLine[5].MsgStatus = 1

end





function A333_ewd_msg.HYD_GY_SYS_LO_PR.Action()

	local a = {E1 = HYRLL, E2 = HYROVHT, E3 = HYRLAP}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = HYEPON, E2 = HNVMYEPF}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = bNOT(a.S), E2 = bNOT(b.S)}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.HYD_GY_SYS_LO_PR.MsgLine[1].MsgStatus = bool2num[bNOT(HGPPBOF)]
	A333_ewd_msg.HYD_GY_SYS_LO_PR.MsgLine[2].MsgStatus = bool2num[bNOT(HYPPBOF)]
	A333_ewd_msg.HYD_GY_SYS_LO_PR.MsgLine[3].MsgStatus = bool2num[c.S]
	A333_ewd_msg.HYD_GY_SYS_LO_PR.MsgLine[4].MsgStatus = 1

end







function A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.Action()

	local a = {E1 = JR1IDLE_1A, E2 = JR1IDLE_1B}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = ZPH4, E2 = ZPH3}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = JR1REVD_1A, E2 = JR1REVD_1B}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = bNOT(JR1TLAI), E2 = bNOT(ZPH4)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = bNOT(b.S), E2 = JML1ON}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = ZGND, E2 = c.S}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = d.S, E2 = e.S}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = ZGND, E2 = g.S}
	h.S = bAND(h.E1, h.E2)

	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[1].MsgStatus = bool2num[a.S]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[2].MsgStatus = bool2num[bNOT(JR1TLAI)]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[3].MsgStatus = bool2num[bNOT(ZGND)]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[4].MsgStatus = bool2num[h.S]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[5].MsgStatus = bool2num[bNOT(ZGND)]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[6].MsgStatus = bool2num[e.S]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[7].MsgStatus = bool2num[f.S]
	A333_ewd_msg.ENG_1_REVERSE_UNLOCKED.MsgLine[8].MsgStatus = bool2num[f.S]

end







function A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.Action()

	local a = {E1 = JR2IDLE_2A, E2 = JR2IDLE_2B}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = ZPH4, E2 = ZPH3}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = JR2REVD_2A, E2 = JR2REVD_2B}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = bNOT(JR2TLAI), E2 = bNOT(ZPH4)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = bNOT(b.S), E2 = JML2ON}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = ZGND, E2 = c.S}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = d.S, E2 = e.S}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = ZGND, E2 = g.S}
	h.S = bAND(h.E1, h.E2)

	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[1].MsgStatus = bool2num[a.S]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[2].MsgStatus = bool2num[bNOT(JR2TLAI)]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[3].MsgStatus = bool2num[bNOT(ZGND)]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[4].MsgStatus = bool2num[h.S]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[5].MsgStatus = bool2num[bNOT(ZGND)]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[6].MsgStatus = bool2num[e.S]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[7].MsgStatus = bool2num[f.S]
	A333_ewd_msg.ENG_2_REVERSE_UNLOCKED.MsgLine[8].MsgStatus = bool2num[f.S]

end








function A333_ewd_msg.DC_BUS_1_2_OFF.Action()

	A333_ewd_msg.DC_BUS_1_2_OFF.MsgLine[1].MsgStatus = bool2num[bNOT(VAVEPBO)]
	A333_ewd_msg.DC_BUS_1_2_OFF.MsgLine[2].MsgStatus = 1
	A333_ewd_msg.DC_BUS_1_2_OFF.MsgLine[3].MsgStatus = bool2num[bNOT(WMBE)]
	A333_ewd_msg.DC_BUS_1_2_OFF.MsgLine[4].MsgStatus = 1

end









function A333_ewd_msg.GEN_1_FAULT.Action()

	gen1faultPulse01:update(bNOT(EGN1PBOF))

	local a = {E1 = ZPH1, E2 = ZPH10}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = EG1FM, E2 = gen1faultPulse01.OUT}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = bNOT(EG1FM), E2 = a.S}
	c.S = bOR(c.E1, c.E2)

	gen1faultSRR01:update(b.S, c.S)

	A333_ewd_msg.GEN_1_FAULT.MsgLine[1].MsgStatus = bool2num[bNOT(gen1faultSRR01.Q)]
	A333_ewd_msg.GEN_1_FAULT.MsgLine[2].MsgStatus = bool2num[bNOT(EGN1PBOF)]
	A333_ewd_msg.GEN_1_FAULT.MsgLine[3].MsgStatus = bool2num[bNOT(EGN1PBOF)]

end

function A333_ewd_msg.GEN_1_FAULT.ActionReset()
	gen1faultSRR01:init()
end






function A333_ewd_msg.GEN_2_FAULT.Action()

	gen2faultPulse01:update(bNOT(EGN2PBOF))

	local a = {E1 = ZPH1, E2 = ZPH10}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = EG2FM, E2 = gen2faultPulse01.OUT}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = bNOT(EG2FM), E2 = a.S}
	c.S = bOR(c.E1, c.E2)

	gen2faultSRR01:update(b.S, c.S)

	A333_ewd_msg.GEN_2_FAULT.MsgLine[1].MsgStatus = bool2num[bNOT(gen2faultSRR01.Q)]
	A333_ewd_msg.GEN_2_FAULT.MsgLine[2].MsgStatus = bool2num[bNOT(EGN2PBOF)]
	A333_ewd_msg.GEN_2_FAULT.MsgLine[3].MsgStatus = bool2num[bNOT(EGN2PBOF)]

end

function A333_ewd_msg.GEN_2_FAULT.ActionReset()
	gen2faultSRR01:init()
end






function A333_ewd_msg.APU_GEN_FAULT.Action()

	apuGenFaultPulse01:update(bNOT(EAPUGNPBOF))

	local a = {E1 = ZPH1, E2 = ZPH10}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = EGAPUM, E2 = apuGenFaultPulse01.OUT}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = bNOT(EGAPUM), E2 = a.S}
	c.S = bOR(c.E1, c.E2)

	apuGenFaultSRR01:update(b.S, c.S)

	A333_ewd_msg.APU_GEN_FAULT.MsgLine[1].MsgStatus = bool2num[bNOT(apuGenFaultSRR01.Q)]
	A333_ewd_msg.APU_GEN_FAULT.MsgLine[2].MsgStatus = bool2num[bNOT(EAPUGNPBOF)]
	A333_ewd_msg.APU_GEN_FAULT.MsgLine[3].MsgStatus = bool2num[bNOT(EAPUGNPBOF)]

end

function A333_ewd_msg.APU_GEN_FAULT.ActionReset()
	apuGenFaultSRR01:init()
end






function A333_ewd_msg.DOORS_NOT_CLOSED.Action()

	doorNotClsdActThr01:update(NCAS_1)
	doorNotClsdActThr02:update(NCAS_2)
	doorNotClsdActThr03:update(NCAS_3)

	local a = {E1 = GGLSUP_1_INV, E2 = GGLSUP_2_INV}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = GGLSUP_1, E2 = GGLSUP_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = GGLSUP_1, E2 = GGLSUP_2}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = a.S, E2 = c.S}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = NCAS_1_INV, E2 = NCAS_1_NCD}
	e.S = bOR(e.E1m, e.E2)

	local f = {E1 = NCAS_2_INV, E2 = NCAS_2_NCD}
	f.S = bOR(f.E1m, f.E2)

	local g = {E1 = NCAS_3_INV, E2 = NCAS_3_NCD}
	g.S = bOR(g.E1m, g.E2)

	local h = {E1 = b.S, E2 = d.S}
	h.S = bOR(h.E1m, h.E2)

	local i = {E1 = h.S, E2 = GDNC}
	i.S = bAND(i.E1, i.E2)

	doorNotClsdActPulse01:update(i.S)
	doorNotClsdActSRS01:update(doorNotClsdActPulse01.OUT, ZPH8)

	local j = {E1 = bNOT(e.S), E2 = doorNotClsdActThr01.out}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = bNOT(f.S), E2 = doorNotClsdActThr02.out}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = bNOT(g.S), E2 = doorNotClsdActThr03.out}
	l.S = bAND(l.E1, l.E2)

	local n = {E1 = j.S, E2 = k.S, E3 = l.S}
	n.S = bOR3(n.E1, n.E2, n.E3)

	local m = {E1 = bNOT(doorNotClsdActSRS01.Q), E2 = i.S, E3 = bNOT(n.S)}
	m.S = bAND3(m.E1, m.E2, m.E3)

	A333_ewd_msg.DOORS_NOT_CLOSED.MsgLine[1].MsgStatus = bool2num[m.S]
	A333_ewd_msg.DOORS_NOT_CLOSED.MsgLine[2].MsgStatus = bool2num[m.S]
	A333_ewd_msg.DOORS_NOT_CLOSED.MsgLine[3].MsgStatus = 1

end

function A333_ewd_msg.DOORS_NOT_CLOSED.ActionReset()
	doorNotClsdActSRS01:reset()
end



function A333_ewd_msg.GEAR_NOT_UPLOCKED.Action()

	lgNotUpLckActThr01:update(NCAS_1)
	lgNotUpLckActThr02:update(NCAS_2)
	lgNotUpLckActThr03:update(NCAS_3)
	lgNotUpLckActConf01:update(GLGDNLKD)

	local a = {E1 = ZPH6, E2 = ZPH5}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = GGLSUP_1_INV, E2 = GGLSUP_2_INV}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = GGLSUP_1, E2 = GGLSUP_2}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = GGLSUP_1, E2 = GGLSUP_2}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = NCAS_1_INV, E2 = NCAS_1_NCD}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = NCAS_2_INV, E2 = NCAS_2_NCD}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = NCAS_3_INV, E2 = NCAS_3_NCD}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = b.S, E2 = d.S}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = c.S, E2 = h.S}
	i.S = bOR(i.E1, i.E2)

	local j = {E1 = lgNotUpLckActThr01.out, E2 = bNOT(e.S)}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = lgNotUpLckActThr02.out, E2 = bNOT(f.S)}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = lgNotUpLckActThr03.out, E2 = bNOT(g.S)}
	l.S = bAND(l.E1, l.E2)

	local m = {E1 = i.S, E2 = a.S, E3 = GLGNUM}
	m.S = bAND3(m.E1, m.E2, m.E3)

	lgNotUpLckActPulse01:update(m.S)
	lgNotUpLckActSRS01:update(lgNotUpLckActPulse01.OUT, ZPH8)

	local n = {E1 = j.S, E2 = k.S, E3 = l.S}
	n.S = bOR3(n.E1, n.E2, n.E3)

	local o = {E1 = bNOT(lgNotUpLckActSRS01.Q), E2 = m.S, E3 = bNOT(n.S)}
	o.S = bAND3(o.E1, o.E2, o.E3)

	local p = {E1 = bNOT(n.S), E2 = bNOT(lgNotUpLckActConf01.OUT)}
	p.S = bAND(p.E1, p.E2)

	local q = {E1 = o.S, E2 = o.S}
	q.S = bAND(q.E1, q.E2)

	local r = {E1 = bNOT(GLGDNLKD), E2 = bNOT(GODNC)}
	r.S = bAND(r.E1, r.E2)

	A333_ewd_msg.GEAR_NOT_UPLOCKED.MsgLine[1].MsgStatus = bool2num[bNOT(GLGDNLKD)]
	A333_ewd_msg.GEAR_NOT_UPLOCKED.MsgLine[2].MsgStatus = bool2num[o.S]
	A333_ewd_msg.GEAR_NOT_UPLOCKED.MsgLine[3].MsgStatus = bool2num[q.S]
	A333_ewd_msg.GEAR_NOT_UPLOCKED.MsgLine[4].MsgStatus = bool2num[p.S]
	A333_ewd_msg.GEAR_NOT_UPLOCKED.MsgLine[5].MsgStatus = bool2num[GLGDNLKD]
	A333_ewd_msg.GEAR_NOT_UPLOCKED.MsgLine[6].MsgStatus = bool2num[r.S]

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

	local a = {E1 = GLGNE, E2 = bNOT(ZGND)}
	a.S = bAND(a.E1, a.E2)

	A333_ewd_msg.SHOCK_ABSORBER_FAULT.MsgLine[1].MsgStatus = bool2num[GLGNE]
	A333_ewd_msg.SHOCK_ABSORBER_FAULT.MsgLine[2].MsgStatus = bool2num[a.S]

end





function A333_ewd_msg.BRAKES_HOT.Action()

	local a = {E1 = bNOT(GBFANCON_1_NCD), E2 = GBFANCON_1}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = GBFANCON_2, E2 = bNOT(GBFANCON_2_NCD)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = GBFI_1, E2 = GBFI_2}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = bNOT(c.S), E2 = d.S}
	e.S = bAND(e.E1, e.E2)

	A333_ewd_msg.BRAKES_HOT.MsgLine[1].MsgStatus = bool2num[bNOT(ZGND)]
	A333_ewd_msg.BRAKES_HOT.MsgLine[2].MsgStatus = bool2num[bNOT(ZGND)]
	A333_ewd_msg.BRAKES_HOT.MsgLine[3].MsgStatus = bool2num[e.s]
	A333_ewd_msg.BRAKES_HOT.MsgLine[4].MsgStatus = bool2num[ZGND]
	A333_ewd_msg.BRAKES_HOT.MsgLine[5].MsgStatus = bool2num[bNOT(ZGND)]

end






function A333_ewd_msg.L_R_WING_TK_LO_LVL.Action()

	A333_ewd_msg.L_R_WING_TK_LO_LVL.MsgLine[1].MsgStatus = bool2num[bNOT(FLTP1COF)]
	A333_ewd_msg.L_R_WING_TK_LO_LVL.MsgLine[2].MsgStatus = bool2num[bNOT(FLTP2COF)]
	A333_ewd_msg.L_R_WING_TK_LO_LVL.MsgLine[3].MsgStatus = bool2num[bNOT(FRTP1COF)]
	A333_ewd_msg.L_R_WING_TK_LO_LVL.MsgLine[4].MsgStatus = bool2num[bNOT(FRTP2COF)]
	A333_ewd_msg.L_R_WING_TK_LO_LVL.MsgLine[5].MsgStatus = bool2num[bNOT(FXFVPBON)]

end



function A333_ewd_msg.L_WING_TK_LO_LVL.Action()

	A333_ewd_msg.L_WING_TK_LO_LVL.MsgLine[1].MsgStatus = bool2num[bNOT(FXFVPBON)]
	A333_ewd_msg.L_WING_TK_LO_LVL.MsgLine[2].MsgStatus = bool2num[bNOT(FXFVPBON)]
	A333_ewd_msg.L_WING_TK_LO_LVL.MsgLine[3].MsgStatus = bool2num[bNOT(FLTP1COF)]
	A333_ewd_msg.L_WING_TK_LO_LVL.MsgLine[4].MsgStatus = bool2num[bNOT(FLTP2COF)]

end



function A333_ewd_msg.R_WING_TK_LO_LVL.Action()

	A333_ewd_msg.R_WING_TK_LO_LVL.MsgLine[1].MsgStatus = bool2num[bNOT(FXFVPBON)]
	A333_ewd_msg.R_WING_TK_LO_LVL.MsgLine[2].MsgStatus = bool2num[bNOT(FXFVPBON)]
	A333_ewd_msg.R_WING_TK_LO_LVL.MsgLine[3].MsgStatus = bool2num[bNOT(FRTP1COF)]
	A333_ewd_msg.R_WING_TK_LO_LVL.MsgLine[4].MsgStatus = bool2num[bNOT(FRTP2COF)]

end











function A333_ewd_msg.X_BLEED_FAULT.Action()

	local a = {E1 = BE1PRVFC_1, E2 = BE1PRVFC_2, E3 = BE2PRVFC_1, E4 = BE2PRVFC_2}
	a.S = bAND4(a.E1, a.E2, a.E3, a.E4)

	local b = {E1 = bNOT(BAPUBPBOF_1), E2 = bNOT(BAPUBPBOF_2)}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = BXFVSSH_2, E2 = BXFVSSH_1}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = BXFVSOP_2, E2 = BXFVSOP_1}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = BXFDOD, E2 = a.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = b.S, E2 = QAVAIL}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = e.S, E2 = f.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = bNOT(c.S), E2 = bNOT(d.S)}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = IWAIPBON, E2 = g.S}
	i.S = bAND(i.E1, i.E2)

	IXBAIC = g.S

	A333_ewd_msg.X_BLEED_FAULT.MsgLine[1].MsgStatus = bool2num[h.S]
	A333_ewd_msg.X_BLEED_FAULT.MsgLine[2].MsgStatus = bool2num[i.S]
	A333_ewd_msg.X_BLEED_FAULT.MsgLine[3].MsgStatus = bool2num[g.S]

end









function A333_ewd_msg.AI_ENG1_VALVE_CLOSED.Action()

	A333_ewd_msg.AI_ENG1_VALVE_CLOSED.MsgLine[1].MsgStatus = 1

end




function A333_ewd_msg.AI_ENG2_VALVE_CLOSED.Action()

	A333_ewd_msg.AI_ENG2_VALVE_CLOSED.MsgLine[1].MsgStatus = 1

end








function A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.Action()

	local a = {E1 = ILVCLSDF, E2 = IRVCLSDF}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = IPROCWAIESD, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = IWAIPBON, E2 = a.S}
	c.S = bAND(c.E1, c.E2)

	A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.MsgLine[1].MsgStatus = bool2num[b.S]
	A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.MsgLine[2].MsgStatus = bool2num[c.S]
	A333_ewd_msg.WING_ANTI_ICE_SYS_FAULT.MsgLine[3].MsgStatus = bool2num[a.S]

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

	local a = {E1 = ZPH2, E2 = ZPH9}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = SGNDSPLRA_1, E2 = SGNDSPLRA_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = SS16F08_1, E2 = SS16F08_2}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = SS20F14_1, E2 = SS20F14_2}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = SS23F22_1, E2 = SS23F22_2}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = WTOCT, E2 = a.S}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = bNOT(GDMXRA_1_NCD), E2 = GDMXRA_1}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = bNOT(GDMXRA_2_NCD), E2 = GDMXRA_2}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = c.S, E2 = d.S, E3 = e.S}
	i.S = bOR3(i.E1, i.E2, i.E3)

	local j = {E1 = bNOT(WTOCNORM), E2 = ZPH6}
	j.S = bOR(j.E1, j.E2)

	toMemoSRR01:update(f.S, j.S)

	local k = {E1 = g.S, E2 = h.S}
	k.S = bOR(k.E1, k.E2)

	local l = {E1 = toMemoSRR01.Q, E2 = WTOCNORM}
	l.S = bAND(l.E1, l.E2)

	A333_ewd_msg.TO_MEMO.MsgLine[1].MsgStatus = bool2num[bNOT(k.S)]
	A333_ewd_msg.TO_MEMO.MsgLine[2].MsgStatus = bool2num[bNOT(k.S)]
	A333_ewd_msg.TO_MEMO.MsgLine[3].MsgStatus = bool2num[k.S]
	A333_ewd_msg.TO_MEMO.MsgLine[4].MsgStatus = bool2num[bNOT(CSIGNSONP)]
	A333_ewd_msg.TO_MEMO.MsgLine[5].MsgStatus = bool2num[bNOT(CSIGNSONP)]
	A333_ewd_msg.TO_MEMO.MsgLine[6].MsgStatus = bool2num[CSIGNSONP]
	A333_ewd_msg.TO_MEMO.MsgLine[7].MsgStatus = bool2num[WCABNR]
	A333_ewd_msg.TO_MEMO.MsgLine[8].MsgStatus = bool2num[WCABNR]
	A333_ewd_msg.TO_MEMO.MsgLine[9].MsgStatus = bool2num[WCABR]
	A333_ewd_msg.TO_MEMO.MsgLine[10].MsgStatus = bool2num[bNOT(b.S)]
	A333_ewd_msg.TO_MEMO.MsgLine[11].MsgStatus = bool2num[bNOT(b.S)]
	A333_ewd_msg.TO_MEMO.MsgLine[12].MsgStatus = bool2num[b.S]
	A333_ewd_msg.TO_MEMO.MsgLine[13].MsgStatus = bool2num[bNOT(i.S)]
	A333_ewd_msg.TO_MEMO.MsgLine[14].MsgStatus = bool2num[bNOT(i.S)]
	A333_ewd_msg.TO_MEMO.MsgLine[15].MsgStatus = bool2num[i.S]
	A333_ewd_msg.TO_MEMO.MsgLine[16].MsgStatus = bool2num[bNOT(toMemoSRR01.Q)]
	A333_ewd_msg.TO_MEMO.MsgLine[17].MsgStatus = bool2num[bNOT(toMemoSRR01.Q)]
	A333_ewd_msg.TO_MEMO.MsgLine[18].MsgStatus = bool2num[l.S]

end

function A333_ewd_msg.TO_MEMO.ActionReset()
	toMemoSRR01:reset()
end






function A333_ewd_msg.LDG_MEMO.Action()

	local a = {E1 = SFLPFY, E2 = bNOT(SSLTFY)}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = SGNDSPLRA_1, E2 = SGNDSPLRA_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = SS23F32_1, E2 = SS23F32_2}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = HGSYSLP, E2 = HYSYSLP}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = GNGDL_1, E2 = GNGDL_2}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = GLGDL_1, E2 = GLGDL_2}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = GRGDL_1, E2 = GRGDL_2}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = bNOT(a.S), E2 = bNOT(NFFMSLDG3)}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = a.S, E2 = SFLPSF, E3 = bNOT(d.S)}
	i.S = bAND3(i.E1, i.E2, i.E3)

	local j = {E1 = NFFMSLDG3, E2 = bNOT(a.S)}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = e.S, E2 = f.S, E3 = g.S}
	k.S = bAND3(k.E1, k.E2, k.E3)

	local l = {E1 = bNOT(i.S), E2 = a.S}
	l.S = bAND(l.E1, l.E2)

	local m = {E1 = h.S, E2 = i.S}
	m.S = bOR(m.E1, m.E2)

	local n = {E1 = j.S, E2 = l.S, E3 = NAPPRAL}
	n.S = bOR3(n.E1, n.E2, n.E3)

	local o = {E1 = bNOT(CSIGNSONP), E2 = bNOT(EEMER)}
	o.S = bAND(o.E1, o.E2)

	local p = {E1 = CSIGNSONP, E2 = bNOT(EEMER)}
	p.S = bAND(p.E1, p.E2)

	local q = {E1 = bNOT(c.S), E2 = m.S, E3 = bNOT(NAPPRAL)}
	q.S = bAND3(q.E1, q.E2, q.E3)

	local r = {E1 = c.S, E2 = m.S, E3 = bNOT(NAPPRAL)}
	r.S = bAND3(r.E1, r.E2, r.E3)

	local s = {E1 = NSFCONF3NS, E2 = n.S}
	s.S = bAND(s.E1, s.E2)

	local t = {E1 = bNOT(NSFCONF3NS), E2 = n.S}
	t.S = bAND(t.E1, t.E2)

	A333_ewd_msg.LDG_MEMO.MsgLine[1].MsgStatus = bool2num[bNOT(k.S)]
	A333_ewd_msg.LDG_MEMO.MsgLine[2].MsgStatus = bool2num[bNOT(k.S)]
	A333_ewd_msg.LDG_MEMO.MsgLine[3].MsgStatus = bool2num[k.S]
	A333_ewd_msg.LDG_MEMO.MsgLine[4].MsgStatus = bool2num[o.S]
	A333_ewd_msg.LDG_MEMO.MsgLine[5].MsgStatus = bool2num[o.S]
	A333_ewd_msg.LDG_MEMO.MsgLine[6].MsgStatus = bool2num[p.S]
	A333_ewd_msg.LDG_MEMO.MsgLine[7].MsgStatus = bool2num[WCABNR]
	A333_ewd_msg.LDG_MEMO.MsgLine[8].MsgStatus = bool2num[WCABNR]
	A333_ewd_msg.LDG_MEMO.MsgLine[9].MsgStatus = bool2num[WCABR]
	A333_ewd_msg.LDG_MEMO.MsgLine[10].MsgStatus = bool2num[bNOT(b.S)]
	A333_ewd_msg.LDG_MEMO.MsgLine[11].MsgStatus = bool2num[bNOT(b.S)]
	A333_ewd_msg.LDG_MEMO.MsgLine[12].MsgStatus = bool2num[b.S]
	A333_ewd_msg.LDG_MEMO.MsgLine[13].MsgStatus = bool2num[q.S]
	A333_ewd_msg.LDG_MEMO.MsgLine[14].MsgStatus = bool2num[q.S]
	A333_ewd_msg.LDG_MEMO.MsgLine[15].MsgStatus = bool2num[r.S]
	A333_ewd_msg.LDG_MEMO.MsgLine[16].MsgStatus = bool2num[s.S]
	A333_ewd_msg.LDG_MEMO.MsgLine[17].MsgStatus = bool2num[s.S]
	A333_ewd_msg.LDG_MEMO.MsgLine[18].MsgStatus = bool2num[t.S]

end















function A333_fws_run_action_functions()

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





