--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws700.lua
* Process: FWS Audio

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


--print("LOAD: A333.ecam_fws700.lua")

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

local dualInput1Switch01 = newAnalogSwitch2in1out('dualInput1Switch01')
local dualInput1Switch02 = newAnalogSwitch2in1out('dualInput1Switch02')
local dualInput1Switch03 = newAnalogSwitch2in1out('dualInput1Switch03')
local dualInput1Switch04 = newAnalogSwitch2in1out('dualInput1Switch04')
local dualInput1Threshold01 = newThreshold('dualInput1Threshold01', '>=', 0.1)
local dualInput1Threshold02 = newThreshold('dualInput1Threshold02', '>=', 0.125)
local dualInput1Threshold03 = newThreshold('dualInput1Threshold03', '>=', 0.1)
local dualInput1Threshold04 = newThreshold('dualInput1Threshold04', '>=', 0.125)

local dualInput2mTrig01 = newLeadingEdgeTrigger('dualInput2mTrig01', 5.0)
local dualInput2discSwitch01 = newDiscreteSwitch('dualInput2discSwitch01')
local dualInput2Conf01 = newLeadingEdgeDelayedConfirmation('dualInput2Conf01', 0.9)
local dualInput2Pulse01	= newLeadingEdgePulse('dualInput2Pulse01')
local dualInput2mTrig02 = newLeadingEdgeTrigger('dualInput2mTrig02', 5.0)


local prioLeftConf01 = newLeadingEdgeDelayedConfirmation('prioLeftConf01', 1.0)
local prioLeftPulse01 = newLeadingEdgePulse('prioLeftPulse01')

local prioRightConf01 = newLeadingEdgeDelayedConfirmation('prioRightConf01', 1.0)
local prioRightPulse01 = newLeadingEdgePulse('prioRightPulse01')

local altThresholdSwitch01 = newAnalogSwitch2in1out('altThresholdSwitch01')
local altThresholdDswitch02 = newDiscreteSwitch('altThresholdDswitch02')
local altThresholdDswitch03 = newDiscreteSwitch('altThresholdDswitch03')
local alt005_threshold	= newMarginSensor('alt005_threshold', '[', '[', 5.0, 6.0)
local altI010_threshold	= newMarginSensor('altI010_threshold', '[', '[', -5.0, 12.0)
local alt010_threshold	= newMarginSensor('alt010_threshold', '[', '[', 10.0, 12.0)
local altI020_threshold	= newMarginSensor('altI020_threshold', '[', '[', -5.0, 22.0)
local alt020_threshold	= newMarginSensor('alt020_threshold', '[', '[', 20.0, 22.0)
local alt030_threshold	= newMarginSensor('alt030_threshold', '[', '[', 30.0, 32.0)
local alt040_threshold	= newMarginSensor('alt040_threshold', '[', '[', 40.0, 42.0)
local alt050_threshold	= newMarginSensor('alt050_threshold', '[', '[', 50.0, 53.0)
local alt100_threshold	= newMarginSensor('alt100_threshold', '[', '[', 100.0, 110.0)
local alt200_threshold	= newMarginSensor('alt200_threshold', '[', '[', 200.0, 210.0)
local alt300_threshold	= newMarginSensor('alt300_threshold', '[', '[', 300.0, 310.0)
local alt400_threshold	= newMarginSensor('alt400_threshold', '[', '[', 400.0, 410.0)

local altThreshold2dhInhib = newSlopeThreshold('altThreshold2dhInhib', '>', 0.0, 'meters/sec')
local altThreshold2dhInhibconf01 = newFallingEdgeDelayedConfirmation('altThreshold2dhInhibconf01', 0.3)

local altThreshold3Trig01 = newLeadingEdgeTrigger('altThreshold3Trig01', 2.0)

local togaInhib_srR01 = newSRlatchResetPriority('togaInhib_srR01')
local togaInhib_pulse01 = newLeadingEdgePulse('togaInhib_pulse01')
local togaInhib_pulse02 = newLeadingEdgePulse('togaInhib_pulse02')
local togaInhib_pulse03 = newLeadingEdgePulse('togaInhib_pulse03')
local togaInhib_pulse04 = newLeadingEdgePulse('togaInhib_pulse04')
local togaInhib_pulse05 = newLeadingEdgePulse('togaInhib_pulse05')

local altThreshold4Margin01 = newMarginSensor('altThreshold4Margin01', '[', '[', 2500.0, 2530.0)
local altThreshold4MRtrig01 = newLeadingEdgeTriggerReTrigger('altThreshold4MRtrig01', 5.0)
local altThreshold4Margin02 = newMarginSensor('altThreshold4Margin02', '[', '[', 2000.0, 2020.0)
local altThreshold4Margin03 = newMarginSensor('altThreshold4Margin03', '[', '[', 1000.0, 1020.0)
local altThreshold4Margin04 = newMarginSensor('altThreshold4Margin04', '[', '[', 500.0, 513.0)
local altThreshold4Conf01 = newLeadingEdgeDelayedConfirmation('altThreshold4Conf01', 0.2)
local altThreshold4Conf02 = newLeadingEdgeDelayedConfirmation('altThreshold4Conf02', 0.2)
local altThreshold4Conf03 = newLeadingEdgeDelayedConfirmation('altThreshold4Conf03', 0.2)
local altThreshold4Conf04 = newLeadingEdgeDelayedConfirmation('altThreshold4Conf04', 0.2)

local ann5ftPulse01	= newLeadingEdgePulse('ann5ftPulse01')
local ann5ftMtrig01 = newLeadingEdgeTrigger('ann5ftMtrig01', 2.0)

local ann10ftPulse01 = newLeadingEdgePulse('ann10ftPulse01')
local ann10ftMtrig01 = newLeadingEdgeTrigger('ann10ftMtrig01', 2.0)

local ann20ftPulse01 = newLeadingEdgePulse('ann20ftPulse01')
local ann20ftMtrig01 = newLeadingEdgeTrigger('ann20ftMtrig01', 2.0)

local ann30ftPulse01 = newLeadingEdgePulse('ann30ftPulse01')
local ann30ftMtrig01 = newLeadingEdgeTrigger('ann30ftMtrig01', 2.0)

local ann40ftPulse01 = newLeadingEdgePulse('ann40ftPulse01')
local ann40ftMtrig01 = newLeadingEdgeTrigger('ann40ftMtrig01', 2.0)

local ann50ftPulse01 = newLeadingEdgePulse('ann50ftPulse01')
local ann50ftMtrig01 = newLeadingEdgeTrigger('ann50ftMtrig01', 2.0)

local ann100ftPulse01 = newLeadingEdgePulse('ann100ftPulse01')
local ann100ftMtrig01 = newLeadingEdgeTrigger('ann100ftMtrig01', 5.0)

local ann200ftPulse01 = newLeadingEdgePulse('ann200ftPulse01')
local ann200ftMtrig01 = newLeadingEdgeTrigger('ann200ftMtrig01', 5.0)

local ann300ftPulse01 = newLeadingEdgePulse('ann300ftPulse01')
local ann300ftMtrig01 = newLeadingEdgeTrigger('ann300ftMtrig01', 5.0)

local ann400ftPulse01 = newLeadingEdgePulse('ann400ftPulse01')
local ann400ftMtrig01 = newLeadingEdgeTrigger('ann400ftMtrig01', 5.0)

local ann500ftMtrig01 = newLeadingEdgeTrigger('ann500ftMtrig01', 5.0)

local ann1000ftHysteresis01 = newHysteresis('ann1000ftHysteresis01', 1000.0, 1100.0)
local ann1000ftPulse01 = newFallingEdgePulse('ann1000ftPulse01')
local ann1000ftPulse02 = newLeadingEdgePulse('ann1000ftPulse02')
local ann1000ftSRRlatch01 = newSRlatchResetPriority('ann1000ftSRRlatch01')

local ann2000ftHysteresis01 = newHysteresis('ann2000ftHysteresis01', 2000.0, 2400.0)
local ann2000ftPulse01 = newFallingEdgePulse('ann2000ftPulse01')
local ann2000ftPulse02 = newLeadingEdgePulse('ann2000ftPulse02')
local ann2000ftSRRlatch01 = newSRlatchResetPriority('ann2000ftSRRlatch01')

local ann2500ftHysteresis01 = newHysteresis('ann2500ftHysteresis01', 2500.0, 3000.0)
local ann2500ftPulse01 = newFallingEdgePulse('ann2500ftPulse01')
local ann2500ftPulse02 = newLeadingEdgePulse('ann2500ftPulse02')
local ann2500ftSRRlatch01 = newSRlatchResetPriority('ann2500ftSRRlatch01')

local ann2500BftHysteresis01 = newHysteresis('ann2500BftHysteresis01', 2500.0, 3000)
local ann2500BftPulse01 = newFallingEdgePulse('ann2500BftPulse01')
local ann2500BftPulse02 = newLeadingEdgePulse('ann2500BftPulse02')
local ann2500BftSRRlatch01 = newSRlatchResetPriority('ann2500BftSRRlatch01')

local ann20RETARDthreshold01 = newThreshold('ann20RETARDthreshold01', '>', 0.98110)
local ann20RETARDthreshold02 = newThreshold('ann20RETARDthreshold02', '>', 0.98110)
local ann20RETARDpulse01 = newLeadingEdgePulse('ann20RETARDpulse01')
local ann20RETARDMtrig01 = newLeadingEdgeTrigger('ann20RETARDMtrig01', 2.0)

local ann10RETARDpulse01 = newLeadingEdgePulse('ann10RETARDpulse01')
local ann10RETARDMtrig01 = newLeadingEdgeTrigger('ann10RETARDMtrig01', 2.0)

local annRETARDconf01 = newLeadingEdgeDelayedConfirmation('annRETARDconf01', 0.1)
local annRETARDconf02 = newLeadingEdgeDelayedConfirmation('annRETARDconf02', 0.1)
local annRETARDpulse01 = newLeadingEdgePulse('annRETARDpulse01')

local windshearTrig01 = newLeadingEdgeTrigger('windshearTrig01', 3.5)
local windshearSRRlatch01 = newSRlatchResetPriority('windshearSRRlatch01')







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

function A333_fws_aco_dual_input1()

	local a = {E1 = SRCCMD_1_INV, E2 = SRCCMD_1_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = SRCCMD_2_INV, E2 = SRCCMD_2_NCD}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = SPCCMD_1_INV, E2 = SPCCMD_1_NCD}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = SPCCMD_2_INV, E2 = SPCCMD_2_NCD}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = SRFOCMD_1_INV, E2 = SRFOCMD_1_NCD}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = SRFOCMD_2_INV, E2 = SRFOCMD_2_NCD}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = SPFOCMD_1_INV, E2 = SPFOCMD_1_NCD}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = SPFOCMD_2_INV, E2 = SPFOCMD_2_NCD}
	h.S = bOR(h.E1, h.E2)

	dualInput1Switch01:update(a.S, SRCCMD_1, SRCCMD_2)
	dualInput1Switch02:update(c.S, SPCCMD_1, SPCCMD_2)
	dualInput1Switch03:update(e.s, SRFOCMD_1, SRFOCMD_2)
	dualInput1Switch04:update(g.S, SPFOCMD_1, SPFOCMD_2)

	local i = {E1 = a.S, E2 = b.S}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = c.S, E2 = d.S}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = e.S, E2 = f.S}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = g.S, E2 = h.S}
	l.S = bAND(l.E1, l.E2)

	dualInput1Threshold01:update(math.abs(dualInput1Switch01.out))
	dualInput1Threshold02:update(math.abs(dualInput1Switch02.out))
	dualInput1Threshold03:update(math.abs(dualInput1Switch03.out))
	dualInput1Threshold04:update(math.abs(dualInput1Switch04.out))

	local m = {E1 = dualInput1Threshold01.out, E2 = bNOT(i.S)}
	m.S = bAND(m.E1, m.E2)

	local n = {E1 = dualInput1Threshold02.out, E2 = bNOT(j.S)}
	n.S = bAND(n.E1, n.E2)

	local o = {E1 = dualInput1Threshold03.out, E2 = bNOT(k.S)}
	o.S = bAND(o.E1, o.E2)

	local  p = {E1 = dualInput1Threshold04.out, E2 = bNOT(l.S)}
	p.S = bAND(p.E1, p.E2)

	local q = {E1 = m.S, E2 = n.S}
	q.S = bOR(q.E1, q.E2)

	local r = {E1 = o.S, E2 = p.S}
	r.S = bOR(r.E1, r.E2)

	local s = {E1 = q.S, E2 = r.S}
	s.S = bAND(s.E1, s.E2)

	SDUALSSI = s.S

end





function A333_fws_aco_dual_input2()

	local a = {E1 = SCSSF_1_INV, E2 = SCSSF_1_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = SCSSF_1, E2 = SFOSSF_1}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = SCSSF_2, E2 = SFOSSF_2}
	c.S = bOR(c.E1, c.E2)

	dualInput2discSwitch01:update(a.S, c.S, b.S)

	local  d = {E1 = SDUALSSI, E2 = bNOT(dualInput2discSwitch01.out)}
	d.S = bAND(d.E1, d.E2)

	dualInput2Conf01:update(d.S)
	dualInput2mTrig01:update(NTCASINIB)

	local e = {E1 = NGPWSINHIB, E2 = dualInput2mTrig01.OUT}
	e.S = bOR(e.E1, e.E2)

	local  f = {E1 = dualInput2Conf01.OUT, E2 = bNOT(dualInput2discSwitch01.out), E3 = WSDUALI, E4 = bNOT(e.S), E5 = bNOT(dualInput2mTrig02.OUT)}
	f.S = bAND5(f.E1, f.E2, f.E3, f.E4, f.E5)

	dualInput2mTrig02:update(f.S)
	dualInput2Pulse01:update(f.S)

	A333DR_fws_aco_dual_input = bool2num[dualInput2Pulse01.OUT]

end





function A333_fws_aco_priority_left()

	local a = {E1 = SFOSSF_1, E2 = SFOSSF_2}
	a.S = bOR(a.E1, a.E2)

	prioLeftConf01:update(a.S)
	prioLeftPulse01:update(prioLeftConf01.OUT)

	A333DR_fws_aco_priority_left = bool2num[prioLeftPulse01.OUT]

end





function A333_fws_aco_priority_right()

	local a = {E1 = SCSSF_1, E2 = SCSSF_2}
	a.S = bOR(a.E1, a.E2)

	prioRightConf01:update(a.S)
	prioRightPulse01:update(prioRightConf01.OUT)

	A333DR_fws_aco_priority_right = bool2num[prioRightPulse01.OUT]

end





function A333_fws_aco_altitude_threshold()

	local a = {E1 = NRADH_1_NCD, E2 = NRADH_1_INV}
	a.S = bOR(a.E1, a.E2)

	altThresholdSwitch01:update(a.S, NRADH_1, NRADH_2)
	altThresholdDswitch02:update(a.S, NRADH_2_FT, NRADH_1_FT)
	altThresholdDswitch03:update(a.S, NRADH_2_NCD, NRADH_1_NCD)

	local b = {E1 = a.S, E2 = NRADH_2_INV}
	b.S = bAND(b.E1, b.E2)

	local altThreshold01 = altThresholdSwitch01.out > 50.0
	local altThreshold02 = altThresholdSwitch01.out >= 410.0

	alt400_threshold:update(altThresholdSwitch01.out)
	alt300_threshold:update(altThresholdSwitch01.out)
	alt200_threshold:update(altThresholdSwitch01.out)
	alt100_threshold:update(altThresholdSwitch01.out)
	alt050_threshold:update(altThresholdSwitch01.out)

	NRANCD	= altThresholdDswitch03.out
	NRAFT	= altThresholdDswitch02.out
	NRAINV 	= b.S
	NRAH	= altThresholdSwitch01.out
	NH50	= alt050_threshold.output
	NHS50	= altThreshold01
	NH100	= alt100_threshold.output
	NH200	= alt200_threshold.output
	NH300	= alt300_threshold.output
	NH400	= alt400_threshold.output
	NHSE410	= altThreshold02
	WRA1INV = altThresholdSwitch01.out

end





function A333_fws_aco_altitude_threshold2()

	local alt003_threshold = NRAH <= 3.0

	local meters = NRAH * 0.3048
	altThreshold2dhInhib:update(meters)
	alt02Inhib = altThreshold2dhInhib.out

	alt005_threshold:update(NRAH)
	altI010_threshold:update(NRAH)
	alt010_threshold:update(NRAH)
	altI020_threshold:update(NRAH)
	alt020_threshold:update(NRAH)
	alt030_threshold:update(NRAH)
	alt040_threshold:update(NRAH)

	local a = {E1 = bNOT(NRAINV), E2 = altI020_threshold.output}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = bNOT(NRAINV), E2 = altI010_threshold.output}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = bNOT(NRAINV), E2 = alt003_threshold}
	c.S = bAND(c.E1, c.E2)

	altThreshold2dhInhibconf01:update(altThreshold2dhInhib.out)

	NDHINHIB 	= altThreshold2dhInhibconf01.OUT
	NHIE3		= c.S
	NH5			= alt005_threshold.output
	NHI10		= b.S
	NH10		= alt010_threshold.output
	NHI20		= a.S
	NH20		= alt020_threshold.output
	NH30		= alt030_threshold.output
	NH40		= alt040_threshold.output

end






function A333_fws_aco_altitude_threshold3()

	local a = {E1 = NH400, E2 = NH300, E3 = NH200, E4 = NH100}
	a.S = bOR4(a.E1, a.E2, a.E3, a.E4)

	local b = {E1 = NH50, E2 = NH40, E3 = NH30, E4 = NH20, E5 = NH10, E6 = NH5}
	b.S = bOR6(b.E1, b.E2, b.E3, b.E4, b.E5, b.E6)

	local c ={E1 = NHIE3, E2 = NDHPO}
	c.S = bOR(c.E1, c.E2)

	local d ={E1 = NGSVA, E2 = NGPWSM}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = a.S, E2 = b.S}
	e.S = bOR(e.E1, e.E2)

	altThreshold3Trig01:update(d.S)

	local f = {E1 = d.S, E2 = altThreshold3Trig01.OUT}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = c.S, E2 = f.S, E3 = NDHGEN}
	g.S = bOR3(g.E1, g.E2, g.E3)

	local h = {E1 = c.S, E2 = NDHGEN}
	h.S = bOR(h.E1, h.E2)

	local i = {E1 = NDHGEN, E2 = NHIE3, E3 = NDHINHIB}
	i.S = bOR3(i.E1, i.E2, i.E3)

	NTHDEC		= e.S
	WSORMT		= altThreshold3Trig01.OUT
	NGPWSINHIB	= f.S				-- GPWS SYS OR G/S AURAL ALERTS ARE CURRENTLY PLAYING
	WMTRGPWS	= f.S
	WDHPOSITIVE	= NDHPO
	NTOAGD		= c.S
	NRENV1		= g.S
	WRENVOI1	= g.S
	NRENV2		= h.S
	WRENVOI2	= h.S
	NRENV3		= i.S

end









function A333_fws_aco_inhibition()

	local a = {E1 = ZGND, E2 = bNOT(ZPH8)}
	a.S = bAND(a.E1, a.E2)

	local b = { E1 = JTML1ON, E2 = JTML2ON, E3 = ZGND}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = JRFLEX, E2 = JIFLEX, E3 = JEFLEX}
	c.S = bOR3(c.E1, c.E2, c.E3)

	local d = {E1 = GELLGCOMPR, E2 = GNLLGCOMPR}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = WSTO, E2= NRAINV, E3 = NRANCD, E4 = c.S, E5 = NSPDO}
	e.S = bOR5(e.E1, e.E2, e.E3, e.E4, e.E5)

	local f = { E1 = JTML1ON, E2 = JTML2ON, E3 = ZGND}
	f.S = bAND3(f.E1, f.E2, f.E3)

	local g = {E1 = NRAFT, E2 = d.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = e.S, E2 = b.S}
	h.S = bOR(h.E1, h.E2)

	local i = {E1 = e.S, E2 = f.S}
	i.S = bOR(i.E1, i.E2)

	local j = {E1 = bNOT(g.S), E2 = h.S}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = bNOT(g.S), E2 = i.S}
	k.S = bAND(k.E1, k.E2)

	NACOINIB = j.S
	NRETINIB = k.S

end







function A333_fws_aco_altitude_threshold4()

	altThreshold4Margin01:update(NRAH)
	altThreshold4MRtrig01:update(NTCASINIB)
	altThreshold4Margin02:update(NRAH)
	altThreshold4Margin03:update(NRAH)
	altThreshold4Margin04:update(NRAH)
	altThreshold4Conf01:update(altThreshold4Margin01.output)
	altThreshold4Conf02:update(altThreshold4Margin02.output)
	altThreshold4Conf03:update(altThreshold4Margin03.output)
	altThreshold4Conf04:update(altThreshold4Margin04.output)

	local a = {E1 = NGPWSINHIB, E2 = altThreshold4MRtrig01.OUT}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = NRENV1, E2 = altThreshold4MRtrig01.OUT}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = WAC2500, E2 = altThreshold4Conf01.OUT, E3 = bNOT(a.S)}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = altThreshold4Conf01.OUT, E2 = WAC2500B, E3 = bNOT(a.s)}
	d.S = bAND3(d.E1, d.E2, d.E3)

	local e = {E1 = bNOT(a.S), E2 = WAC2000, E3 = altThreshold4Conf02.OUT}
	e.S = bAND3(e.E1, e.E2,e.E3)

	local f = {E1 = bNOT(b.S), E2 = WAC1000, E3 = altThreshold4Conf03.OUT}
	f.S = bAND3(f.E1, f.E2, f.E3)

	local g = {E1 = bNOT(b.S), E2 = altThreshold4Conf04.OUT}
	g.S = bAND(g.E1, g.E2)

	NS500 	= g.S
	NS1000	= f.S
	NS2000 	= e.S
	NS2500B	= d.S
	NS2500	= c.S

end







function A333_fws_aco_threshold_detection()

	local a = {E1 = bNOT(NRENV1), E2 = WAC400, E3 = NH400}
	a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = bNOT(NRENV1), E2 = WAC300, E3 = NH300}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = bNOT(NRENV1), E2 = WAC200, E3 = NH200}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = bNOT(NRENV1), E2 = WAC100, E3 = NH100}
	d.S = bAND3(d.E1, d.E2, d.E3)

	local e = {E1 = bNOT(NRENV1), E2 = WAC50, E3 = NH50}
	e.S = bAND3(e.E1, e.E2, e.E3)

	NS050	= e.S
	NS100	= d.S
	NS200 	= c.S
	NS300	= b.S
	NS400 	= a.S

end









function A333_fws_aco_threshold_detection2()

	local a = {E1 = bNOT(NRENV2), E2 = WAC40}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = NRAFT, E2 = a.S}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = b.S, E2 = NH40}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = bNOT(NRENV2), E2 = WAC30, E3 = NH30}
	d.S = bAND3(d.E1, d.E2, d.E3)

	local e = {E1 = bNOT(NRENV2), E2 = WAC20, E3 = NH20}
	e.S = bAND3(e.E1, e.E2, e.E3)

	local f = {E1 = bNOT(NRENV3), E2 = WAC10, E3 = NH10}
	f.S = bAND3(f.E1, f.E2, f.E3)

	local g = {E1 = bNOT(NRENV3), E2 = WAC5, E3 = NH5}
	g.S = bAND3(g.E1, g.E2, g.E3)

	NS005	= g.S
	NS010	= f.S
	NS020	= e.S
	NS030	= d.S
	NS040	= c.S

end









function A333_fws_aco_windshear()

	local a = {E1 = ZPH2, E2 = ZPH3, E3 = ZPH4, E4 = ZPH8, E5 = ZPH9}
	a.S = bOR5(a.E1, a.E1, a.E3, a.E4, a.E5)

	local b = {E1 = KWINDSDV_1, E2 = KWINDSD_1, E3 = bNOT(KFACNOH_1)}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = KWINDSDV_2, E2 = KWINDSD_2, E3 = bNOT(KFACNOH_2)}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = b.S, E2 = c.S}
	d.S = bOR(d.E1, d.E2)

	windshearTrig01:update(d.S)

	local e = {E1 = windshearTrig01.OUT, E2 = d.S}
	e.S = bOR(e.E1, e.E2)

	windshearSRRlatch01:update(KWINDSGEN, e.S)

	local f = {E1 = bNOT(a.S), E2 = bNOT(windshearSRRlatch01.Q), E3 = e.S}
	f.S = bAND3(f.E1, f.E2, f.E3)

	local g = {E1 = f.S, E2 = KWINDSGEN}
	g.S = bOR(g.E1, g.E2)

	WWINDSDON = g.S

	A333DR_fws_aco_windshear = bool2num[WWINDSDON]

end









function A333_fws_aco_5ft_announce()

	local a = {E1 = bNOT(NRDINH), E2 = NS005, E3 = bNOT(NACOINIB), E4 = bNOT(ann5ftMtrig01.OUT)}
	a.S = bAND4(a.E1, a.E2, a.E3, a.E4)

	ann5ftPulse01:update(a.S)
	ann5ftMtrig01:update(ann5ftPulse01.OUT)

	WACO5	= ann5ftPulse01.OUT
	NA005	= ann5ftPulse01.OUT

	A333DR_fws_aco_5 = bool2num[WACO5]

end






function A333_fws_aco_10ft_announce()

	local a = {E1 = KAP1E, E2 = KLTRKM_1}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = KAP2E, E2 = KLTRKM_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = NS010, E2 = bNOT(NACOINIB)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = bNOT(d.S), E2 = KATHRE}
	e.S = bAND(e.E1, e.E2)

	ann10ftPulse01:update(c.S)

	local f = {E1 = e.S, E2 = bNOT(KATHRE)}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = f.S, E2 = bNOT(NA005), E3 = bNOT(NRDINH), E4 = ann10ftPulse01.OUT, E5 = bNOT(ann10ftMtrig01.OUT)}
	g.S = bAND5(g.E1, g.E2, g.E3, g.E4, g.E5)

	ann10ftMtrig01:update(g.S)

	WACO10	= g.S
	NA010 	= g.S

	A333DR_fws_aco_10 = bool2num[WACO10]

end








function A333_fws_aco_20ft_announce()

	local a = {E1 = KAP1E, E2 = KLTRKM_1}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = KAP2E, E2 = KLTRKM_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = NS020, E2 = bNOT(NACOINIB)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S}
	d.S = bOR(d.E1, d.E2)

	ann20ftPulse01:update(c.S)

	local e = {E1 = d.S, E2 = KATHRE, E3 = bNOT(NA010), E4 = ann20ftPulse01.OUT, E5 = bNOT(ann20ftMtrig01.OUT)}
	e.S = bAND5(e.E1, e.E2, e.E3, e.E4, e.E5)

	ann20ftMtrig01:update(e.S)

	WACO20	= e.S
	NA020	= e.S

	A333DR_fws_aco_20 = bool2num[WACO20]

end







function A333_fws_aco_30ft_announce()

	local a = {E1 = NS030, E2 = bNOT(NACOINIB)}
	a.S = bAND(a.E1, a.E2)

	ann30ftPulse01:update(a.S)

	local b = {E1 = bNOT(NA020), E2 = ann30ftPulse01.OUT, E3 = bNOT(ann30ftMtrig01.OUT)}
	b.S = bAND3(b.E1, b.E2, b.E3)

	ann30ftMtrig01:update(b.S)

	WACO30		= b.S
	NA030		= b.S
	WPULSE30	= a.S

	A333DR_fws_aco_30 = bool2num[WPULSE30]

end







function A333_fws_aco_40ft_announce()

	local a = {E1 = NS040, E2 = bNOT(NACOINIB)}
	a.S = bAND(a.E1, a.E2)

	ann40ftPulse01:update(a.S)

	local b = {E1 = bNOT(NA030), E2 = ann40ftPulse01.OUT, E3 = bNOT(ann40ftMtrig01.OUT)}
	b.S = bAND3(b.E1, b.E2, b.E3)

	ann40ftMtrig01:update(b.S)

	WACO40		= b.S
	NA040		= b.S
	WPULSE40	= a.S

	A333DR_fws_aco_40 = bool2num[WPULSE40]

end







function A333_fws_aco_50ft_announce()

	local a = {E1 = bNOT(NACOINIB), E2 = NS050}
	a.S = bAND(a.E1, a.E2)

	ann50ftPulse01:update(a.S)

	local b = {E1 = bNOT(NA040), E2 = ann50ftPulse01.OUT, E3 = bNOT(ann50ftMtrig01.OUT)}
	b.S = bAND3(b.E1, b.E2, b.E3)

	ann50ftMtrig01:update(b.S)

	WACO50		= b.S
	NA050		= b.S

	A333DR_fws_aco_50 = bool2num[b.S]

end







function A333_fws_aco_100ft_announce()

	ann100ftPulse01:update(NS100)

	local a = {E1 = bNOT(NACOINIB), E2 = ann100ftPulse01.OUT, E3 = bNOT(ann100ftMtrig01.OUT)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	ann100ftMtrig01:update(a.S)

	WACO100		= a.S
	WPREC100	= ann100ftMtrig01.OUT

	A333DR_fws_aco_100 = bool2num[WACO100]

end







function A333_fws_aco_200ft_announce()

	ann200ftPulse01:update(NS200)

	local a = {E1 = bNOT(NACOINIB), E2 = ann200ftPulse01.OUT, E3 = bNOT(ann200ftMtrig01.OUT)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	ann200ftMtrig01:update(a.S)

	WACO200		= a.S
	WPREC200	= ann200ftMtrig01.OUT

	A333DR_fws_aco_200 = bool2num[WACO200]

end







function A333_fws_aco_300ft_announce()

	ann300ftPulse01:update(NS300)

	local a = {E1 = bNOT(NACOINIB), E2 = ann300ftPulse01.OUT, E3 = bNOT(ann300ftMtrig01.OUT)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	ann300ftMtrig01:update(a.S)

	WACO300		= a.S
	WPREC300	= ann300ftMtrig01.OUT

	A333DR_fws_aco_300 = bool2num[WACO300]

end








function A333_fws_aco_400ft_announce()

	ann400ftPulse01:update(NS400)

	local a = {E1 = bNOT(NACOINIB), E2 = ann400ftPulse01.OUT, E3 = bNOT(ann400ftMtrig01.OUT)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	ann400ftMtrig01:update(a.S)

	WACO400 = a.S

	A333DR_fws_aco_400 = bool2num[WACO400]

end







function A333_fws_aco_500ft_announce()

	local a = {E1 = bNOT(ann500ftMtrig01.OUT), E2 = bNOT(NACOINIB), E3 = NS500, E4 = WAC500}
	a.S = bAND4(a.E1, a.E2, a.E3, a.E4)

	ann500ftMtrig01:update(a.S)

	A333DR_fws_aco_500 = bool2num[a.S]

end






function A333_fws_aco_1000ft_announce()

	ann1000ftHysteresis01:update(NRAH)
	ann1000ftPulse01:update(ann1000ftHysteresis01.out)
	ann1000ftSRRlatch01:update(ann1000ftPulse02.OUT, ann1000ftPulse01.OUT)

	local a = {E1 = ann1000ftHysteresis01.out, E2 = NS1000, E3 = bNOT(NACOINIB), E4 = bNOT(ann1000ftSRRlatch01.Q)}
	a.S = bAND4(a.E1, a.E2, a.E3, a.E4)

	ann1000ftPulse02:update(a.S)

	A333DR_fws_aco_1000 = bool2num[a.S]

end








function A333_fws_aco_2000ft_announce()

	ann2000ftHysteresis01:update(NRAH)
	ann2000ftPulse01:update(ann2000ftHysteresis01.out)
	ann2000ftSRRlatch01:update(ann2000ftPulse02.OUT, ann2000ftPulse01.OUT)

	local a = {E1 = ann2000ftHysteresis01.out, E2 = NS2000, E3 = bNOT(NACOINIB), E4 = bNOT(ann2000ftSRRlatch01.Q)}
	a.S = bAND4(a.E1, a.E2, a.E3, a.E4)

	ann2000ftPulse02:update(a.S)

	A333DR_fws_aco_2000 = bool2num[a.S]

end








function A333_fws_aco_2500ft_announce()

	ann2500ftHysteresis01:update(NRAH)
	ann2500ftPulse01:update(ann2500ftHysteresis01.out)
	ann2500ftSRRlatch01:update(ann2500ftPulse02.OUT, ann2500ftPulse01.OUT)

	local a = {E1 = ann2500ftHysteresis01.out, E2 = NS2500, E3 = bNOT(NACOINIB), E4 = bNOT(ann2500ftSRRlatch01.Q)}
	a.S = bAND4(a.E1, a.E2, a.E3, a.E4)

	ann2500ftPulse02:update(a.S)

	A333DR_fws_aco_2500 = bool2num[a.S]

end








function A333_fws_aco_2500Bft_announce()

	ann2500BftHysteresis01:update(NRAH)
	ann2500BftPulse01:update(ann2500BftHysteresis01.out)
	ann2500BftSRRlatch01:update(ann2500BftPulse02.OUT, ann2500BftPulse01.OUT)

	local a = {E1 = ann2500BftHysteresis01.out, E2 = NS2500B, E3 = bNOT(NACOINIB), E4 = ann2500BftSRRlatch01.Q}
	a.S = bAND4(a.E1, a.E2, a.E3, a.E4)

	ann2500BftPulse02:update(a.S)

	A333DR_fws_aco_2500B = bool2num[a.S]

end
















function A333_fws_aco_20_retard_announce()

	ann20RETARDthreshold01:update(JR1TLA_1A)
	ann20RETARDthreshold02:update(JR1TLA_1A)

	local a = {E1 = KAP1E, E2 = KLTRKM_1}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = KAP2E, E2 = KLTRKM_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = JR1TLASCL, E2 = JR2TLASCL}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = ann20RETARDthreshold01.out, E2 = ann20RETARDthreshold02.out}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = KATHRE, E2 = bNOT(c.S)}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = bNOT(KATHRE), E2 = f.S}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = ZPH8, E2 = d.S}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = WRRT, E2 = e.S}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = h.S, E2 = i.S}
	j.S = bOR(j.E1, j.E2)

	local k = {E1 = NRETINIB, E2 = j.S}
	k.S = bOR(k.E1, k.E2)

	local l = {E1 = NACOINIB, E2 = j.S}
	l.S = bOR(l.E1, l.E2)

	local m = {E1 = bNOT(l.s), E2 = NS020, E3 = g.S, E4 = bNOT(ann20RETARDMtrig01.OUT)}
	m.S = bAND4(m.E1, m.E2, m.E3, m.E4)

	ann20RETARDpulse01:update(m.S)
	ann20RETARDMtrig01:update(ann20RETARDpulse01.OUT)

	JRTOGA		= k.S
	JTOGA 		= l.s
	WRETTOGA	= k.S
	WJTOGA		= j.S
	W20RETARD	= m.S

	A333DR_fws_aco_20_retard = bool2num[ann20RETARDpulse01.OUT]

end









function A333_fws_aco_toga_inhibition()

	togaInhib_pulse01:update(ZPH2)
	togaInhib_pulse02:update(ZPH3)
	togaInhib_pulse03:update(ZPH4)
	togaInhib_pulse04:update(ZPH9)
	togaInhib_pulse05:update(ZPH7)

	local a = {E1 = JR12IDLE, E2 = ZPH8}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = togaInhib_pulse01.OUT, E2 = togaInhib_pulse02.OUT, E3 = togaInhib_pulse03.OUT, E4 = togaInhib_pulse04.OUT, E5 = togaInhib_pulse05.OUT}
	b.S = bOR5(b.E1, b.E2, b.E3, b.E4, b.E5)

	togaInhib_srR01:update(a.S, b.S)

	JTOGAIN = togaInhib_srR01.Q

end








function A333_fws_aco_10_retard_announce()

	local a = {E1 = KAP1E, E2 = KLTRKM_1}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = KAP2E, E2 = KLTRKM_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = NACOINIB, E2 = JTOGA}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = KATHRE, E2 = d.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = bNOT(c.S), E2 = NS010, E3 = e.S, E4 = bNOT(ann10RETARDMtrig01.OUT)}
	f.S = bAND4(f.E1, f.E2, f.E3, f.E4)

	ann10RETARDpulse01:update(f.S)
	ann10RETARDMtrig01:update(ann10RETARDpulse01.OUT)

	W10RETARD = f.S

	A333DR_fws_aco_10_retard = bool2num[W10RETARD]

end








function A333_fws_aco_tla_inhibition()

	local a = {E1 = JR1TLAI, E2 = JR1TLAFG, E3 = JR1TLAFF}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = JR2TLAI, E2 = JR2TLAFG, E3 = JR2TLAFF}
	b.S = bOR3(b.E1, b.E2, b.E3)

	local c = {E1 = bNOT(JR1NORUN), E2 = JR2NORUN, E3 = a.S}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = JR1NORUN, E2 = bNOT(JR2NORUN), E3 = b.S}
	d.S = bAND3(d.E1, d.E2, d.E3)

	local e = {E1 = JR1TLREV, E2 = JR2TLREV}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = bNOT(JR1NORUN), E2 = bNOT(JR2NORUN), E3 = JR12IDLE}
	f.S = bAND3(f.E1, f.E2, f.E3)

	local g = {E1 = c.S, E2 = d.S, E3 = e.S, E4 = f.S}
	g.S = bOR4(g.E1, g.E2, g.E3, g.E4)

	local h = {E1 = g.S, E2 = JTOGAIN}
	h.S = bOR(h.E1, h.E2)

	JTLAINH = h.S

end








function A333_fws_aco_retard_announce()

	annRETARDconf01:update(NHI20)
	annRETARDconf02:update(NHI10)

	local a = {E1 = KAP1E, E2 = KLTRKM_1}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = KAP2E, E2 = KLTRKM_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = KATHRE, E2 = c.S}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = KATHRE, E2 = bNOT(c.S)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = bNOT(KATHRE), E2 = e.S}
	f.S = bOR(f.E1, f.E2)

	local h = {E1 = ZPH6, E2 = ZPH7, E3 = ZPH8}
	h.S = bOR3(h.E1, h.E2, h.E3)

	local i = {E1 = JRFLEX, E2 = JRFLEX}
	i.S = bOR(i.E1, i.E2)

	local j = {E1 = JRTOGA, E2 = i.S, E3 = NDHINHIB}
	j.S = bOR3(j.E1, j.E2, j.E3)

	local k = {E1 = KATHRE, E2 = annRETARDconf01.OUT}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = annRETARDconf02.OUT, E2 = d.S}
	l.S = bAND(l.E1, l.E2)

	local m = {E1 = d.S, E2 = bNOT(WAC20), E3 = NH20}
	m.S = bAND3(m.E1, m.E2, m.E3)

	local n = {E1 = d.S, E2 = bNOT(WAC10), E3 = NH10}
	n.S = bAND3(n.E1, n.E2, n.E3)

	local o = {E1 = k.S, E2 = l.S}
	o.S = bOR(o.E1, o.E2)

	local p = {E1 = m.S, E2 = n.S}
	p.S = bOR(p.E1, p.E2)

	annRETARDpulse01:update(p.S)

	local q = {E1 = bNOT(JTLAINH), E2 = o.S, E3 = h.S}
	q.S = bAND3(q.E1, q.E2, q.E3)

	local r = {E1 = q.S, E2 = annRETARDpulse01.OUT}
	r.S = bOR(r.E1, r.E2)

	local s = {E1 = r.S, E2 = bNOT(j.S)}
	s.S = bAND(s.E1, s.E2)

	WRETINHIB	= q.S
	NRDINH		= q.S
	WRETARD		= s.S

	A333DR_fws_aco_retard = bool2num[WRETARD]

end








--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_700()



	A333_fws_aco_altitude_threshold()
	A333_fws_aco_altitude_threshold2()
	A333_fws_aco_altitude_threshold3()
	A333_fws_aco_inhibition()
	A333_fws_aco_altitude_threshold4()
	A333_fws_aco_threshold_detection()
	A333_fws_aco_threshold_detection2()
	A333_fws_aco_toga_inhibition()
	A333_fws_aco_tla_inhibition()

	A333_fws_aco_windshear()
	A333_fws_aco_50ft_announce()
	A333_fws_aco_5ft_announce()
	A333_fws_aco_10ft_announce()
	A333_fws_aco_20ft_announce()
	A333_fws_aco_30ft_announce()
	A333_fws_aco_40ft_announce()
	A333_fws_aco_100ft_announce()
	A333_fws_aco_200ft_announce()
	A333_fws_aco_300ft_announce()
	A333_fws_aco_400ft_announce()
	A333_fws_aco_500ft_announce()
	A333_fws_aco_1000ft_announce()
	A333_fws_aco_2000ft_announce()
	--A333_fws_aco_2500Bft_announce()
	A333_fws_aco_2500ft_announce()
	A333_fws_aco_10_retard_announce()
	A333_fws_aco_20_retard_announce()
	A333_fws_aco_retard_announce()

	A333_fws_aco_priority_left()
	A333_fws_aco_priority_right()
	A333_fws_aco_dual_input1()
	A333_fws_aco_dual_input2()


end






--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







