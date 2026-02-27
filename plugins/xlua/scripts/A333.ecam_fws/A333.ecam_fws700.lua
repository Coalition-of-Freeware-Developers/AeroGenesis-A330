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
*       					 COPYRIGHT © 2021, 2022, 2025
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
local function A333_fws_aco_dual_input1()

    local a = SRCCMD_1_INV or SRCCMD_1_NCD
    local b = SRCCMD_2_INV or SRCCMD_2_NCD
    local c = SPCCMD_1_INV or SPCCMD_1_NCD
    local d = SPCCMD_2_INV or SPCCMD_2_NCD
    local e = SRFOCMD_1_INV or SRFOCMD_1_NCD
    local f = SRFOCMD_2_INV or SRFOCMD_2_NCD
    local g = SPFOCMD_1_INV or SPFOCMD_1_NCD
    local h = SPFOCMD_2_INV or SPFOCMD_2_NCD
    dualInput1Switch01:update(a, SRCCMD_1, SRCCMD_2)
    dualInput1Switch02:update(c, SPCCMD_1, SPCCMD_2)
    dualInput1Switch03:update(e, SRFOCMD_1, SRFOCMD_2)
    dualInput1Switch04:update(g, SPFOCMD_1, SPFOCMD_2)
    local i = a and b
    local j = c and d
    local k = e and f
    local l = g and h
    local dualInput1Threshold01 = dualInput1Switch01.out >= 0.1
    local dualInput1Threshold02 = dualInput1Switch02.out >= 0.125
    local dualInput1Threshold03 = dualInput1Switch03.out >= 0.1
    local dualInput1Threshold04 = dualInput1Switch04.out >= 0.125
    local m = dualInput1Threshold01 and (not i)
    local n = dualInput1Threshold02 and (not j)
    local o = dualInput1Threshold03 and (not k)
    local p = dualInput1Threshold04 and (not l)
    local q = m or n
    local r = o or p
    local s = q and r

	SDUALSSI = s

end




local function A333_fws_aco_dual_input2()

    local a = SCSSF_1_INV or SCSSF_1_NCD
    local b = SCSSF_1 or SFOSSF_1
    local c = SCSSF_2 or SFOSSF_2
    dualInput2discSwitch01:update(a, c, b)
    local d = SDUALSSI and (not dualInput2discSwitch01.out)
    dualInput2Conf01:update(d)
    dualInput2mTrig01:update(NTCASINIB)
    local e = NGPWSINHIB or dualInput2mTrig01.OUT
    local f = dualInput2Conf01.OUT and (not dualInput2discSwitch01.out) and WSDUALI and (not e) and (not dualInput2mTrig02.OUT)
    dualInput2mTrig02:update(f)
    dualInput2Pulse01:update(f)

	A333DR_fws_aco_dual_input = bool2num[dualInput2Pulse01.OUT]

end





local function A333_fws_aco_priority_left()

	local a = SFOSSF_1 or SFOSSF_2
	prioLeftConf01:update(a)
	prioLeftPulse01:update(prioLeftConf01.OUT)

	A333DR_fws_aco_priority_left = bool2num[prioLeftPulse01.OUT]

end





local function A333_fws_aco_priority_right()

	local a = SCSSF_1 or SCSSF_2
	prioRightConf01:update(a)
	prioRightPulse01:update(prioRightConf01.OUT)

	A333DR_fws_aco_priority_right = bool2num[prioRightPulse01.OUT]

end




local function A333_fws_aco_altitude_threshold()

	local a =  NRADH_1_NCD or NRADH_1_INV
	altThresholdSwitch01:update(a, NRADH_1, NRADH_2)
	altThresholdDswitch02:update(a, NRADH_2_FT, NRADH_1_FT)
	altThresholdDswitch03:update(a, NRADH_2_NCD, NRADH_1_NCD)
	local b = a and NRADH_2_INV
	local altThreshold01 = (altThresholdSwitch01.out > 50.0)
	local altThreshold02 = (altThresholdSwitch01.out >= 410.0)
	alt400_threshold:update(altThresholdSwitch01.out)
	alt300_threshold:update(altThresholdSwitch01.out)
	alt200_threshold:update(altThresholdSwitch01.out)
	alt100_threshold:update(altThresholdSwitch01.out)
	alt050_threshold:update(altThresholdSwitch01.out)

	NRANCD	= altThresholdDswitch03.out
	NRAFT	= altThresholdDswitch02.out
	NRAINV 	= b
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




local function A333_fws_aco_altitude_threshold2()

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
	local a = not NRAINV and altI020_threshold.output
	local b = not NRAINV and altI010_threshold.output
	local c = not NRAINV and alt003_threshold
	altThreshold2dhInhibconf01:update(altThreshold2dhInhib.out)

	NDHINHIB 	= altThreshold2dhInhibconf01.OUT
	NHIE3		= c
	NH5			= alt005_threshold.output
	NHI10		= b
	NH10		= alt010_threshold.output
	NHI20		= a
	NH20		= alt020_threshold.output
	NH30		= alt030_threshold.output
	NH40		= alt040_threshold.output

end




local function A333_fws_aco_altitude_threshold3()

    local a = NH400 or NH300 or NH200 or NH100
    local b = NH50 or NH40 or NH30 or NH20 or NH10 or NH5
    local c = NHIE3 or NDHPO
    local d = NGSVA or NGPWSM
    local e = a or b
    altThreshold3Trig01:update(d)
    local f = d or altThreshold3Trig01.OUT
    local g = c or f or NDHGEN
    local h = c or NDHGEN
    local i = NDHGEN or NHIE3 or NDHINHIB

    NTHDEC		= e
	WSORMT		= altThreshold3Trig01.OUT
	NGPWSINHIB	= f				-- GPWS SYS OR G/S AURAL ALERTS ARE CURRENTLY PLAYING
	WMTRGPWS	= f
	WDHPOSITIVE	= NDHPO
	NTOAGD		= c
	NRENV1		= g
	WRENVOI1	= g
	NRENV2		= h
	WRENVOI2	= h
	NRENV3		= i

end




local function A333_fws_aco_inhibition()

    local a = ZGND and not ZPH8
    local b = JTML1ON and JTML2ON and ZGND
    local c = JRFLEX or JIFLEX or JEFLEX
    local d = GELLGCOMPR or GNLLGCOMPR
    local e = WSTO or NRAINV or NRANCD or c or NSPDO
    local f = JTML1ON and JTML2ON and ZGND
    local g = NRAFT and d
    local h = e or b
    local i = e or f
    local j = not g and h
    local k = not g and i

	NACOINIB = j
	NRETINIB = k

end




local function A333_fws_aco_altitude_threshold4()

    altThreshold4Margin01:update(NRAH)
    altThreshold4MRtrig01:update(NTCASINIB)
    altThreshold4Margin02:update(NRAH)
    altThreshold4Margin03:update(NRAH)
    altThreshold4Margin04:update(NRAH)
    altThreshold4Conf01:update(altThreshold4Margin01.output)
    altThreshold4Conf02:update(altThreshold4Margin02.output)
    altThreshold4Conf03:update(altThreshold4Margin03.output)
    altThreshold4Conf04:update(altThreshold4Margin04.output)
    local a = NGPWSINHIB or altThreshold4MRtrig01.OUT
    local b = NRENV1 or altThreshold4MRtrig01.OUT
    local c = WAC2500 and altThreshold4Conf01.OUT and (not a)
    local d = altThreshold4Conf01.OUT and WAC2500B and (not a)
    local e = (not a) and WAC2000 and altThreshold4Conf02.OUT
    local f = (not b) and WAC1000 and altThreshold4Conf03.OUT
    local g = (not b) and altThreshold4Conf04.OUT

	NS500 	= g
	NS1000	= f
	NS2000 	= e
	NS2500B	= d
	NS2500	= c

end







local function A333_fws_aco_threshold_detection()

    local a = (not NRENV1) and WAC400 and NH400
    local b = (not NRENV1) and WAC300 and NH300
    local c = (not NRENV1) and WAC200 and NH200
    local d = (not NRENV1) and WAC100 and NH100
    local e = (not NRENV1) and WAC50 and NH50

	NS050	= e
	NS100	= d
	NS200 	= c
	NS300	= b
	NS400 	= a

end




local function A333_fws_aco_threshold_detection2()

    local a = (not NRENV2) and WAC40
    local b = NRAFT or a
    local c = b and NH40
    local d = (not NRENV2) and WAC30 and NH30
    local e = (not NRENV2) and WAC20 and NH20
    local f = (not NRENV3) and WAC10 and NH10
    local g = (not NRENV3) and WAC5 and NH5

	NS005	= g
	NS010	= f
	NS020	= e
	NS030	= d
	NS040	= c

end




local function A333_fws_aco_windshear()

    local a =  ZPH2 or ZPH3 or ZPH4 or ZPH8 or ZPH9
    local b = KWINDSDV_1 and KWINDSD_1 and (not KFACNOH_1)
    local c = KWINDSDV_2 and KWINDSD_2 and (not KFACNOH_2)
    local d = b or c
    windshearTrig01:update(d)
    local e = windshearTrig01.OUT or d
    windshearSRRlatch01:update(KWINDSGEN, e)
    local f = (not a) and (not windshearSRRlatch01.Q) and e
    local g = f or KWINDSGEN

	WWINDSDON = g

	A333DR_fws_aco_windshear = bool2num[WWINDSDON]

end




local function A333_fws_aco_5ft_announce()

	local a = (not NRDINH) and NS005 and (not NACOINIB) and (not ann5ftMtrig01.OUT)
	ann5ftPulse01:update(a)
	ann5ftMtrig01:update(ann5ftPulse01.OUT)

	WACO5	= ann5ftPulse01.OUT
	NA005	= ann5ftPulse01.OUT

	A333DR_fws_aco_5 = bool2num[WACO5]

end




local function A333_fws_aco_10ft_announce()

    local a = KAP1E and KLTRKM_1
    local b = KAP2E and KLTRKM_2
    local c = NS010 and (not NACOINIB)
    local d = a or b
    local e = (not d) and KATHRE
    ann10ftPulse01:update(c)
    local f = e or (not KATHRE)
    local g =  f and (not NA005) and (not NRDINH) and ann10ftPulse01.OUT and (not ann10ftMtrig01.OUT)
    ann10ftMtrig01:update(g)

	WACO10	= g
	NA010 	= g

	A333DR_fws_aco_10 = bool2num[WACO10]

end




local function A333_fws_aco_20ft_announce()

    local a = KAP1E and KLTRKM_1
    local b = KAP2E and KLTRKM_2
    local c = NS020 and (not NACOINIB)
    local d = a or b
    ann20ftPulse01:update(c)
    local e = d and KATHRE and not NA010 and ann20ftPulse01.OUT and not ann20ftMtrig01.OUT
    ann20ftMtrig01:update(e)

	WACO20	= e
	NA020	= e

	A333DR_fws_aco_20 = bool2num[WACO20]

end




local function A333_fws_aco_30ft_announce()

	local a = NS030 and (not NACOINIB)
	ann30ftPulse01:update(a)
	local b = (not NA020) and ann30ftPulse01.OUT and (not ann30ftMtrig01.OUT)
	ann30ftMtrig01:update(b)

	WACO30		= b
	NA030		= b
	WPULSE30	= a

	A333DR_fws_aco_30 = bool2num[WPULSE30]

end




local function A333_fws_aco_40ft_announce()

	local a =  NS040 and (not NACOINIB)
	ann40ftPulse01:update(a)
	local b = (not NA030) and ann40ftPulse01.OUT and (not ann40ftMtrig01.OUT)
	ann40ftMtrig01:update(b)

	WACO40		= b
	NA040		= b
	WPULSE40	= a

	A333DR_fws_aco_40 = bool2num[WPULSE40]

end




local function A333_fws_aco_50ft_announce()

	local a = (not NACOINIB) and NS050
	ann50ftPulse01:update(a)
	local b = (not NA040) and ann50ftPulse01.OUT and (not ann50ftMtrig01.OUT)
	ann50ftMtrig01:update(b)

	WACO50		= b
	NA050		= b

	A333DR_fws_aco_50 = bool2num[b]

end




local function A333_fws_aco_100ft_announce()

	ann100ftPulse01:update(NS100)
	local a = (not NACOINIB) and ann100ftPulse01.OUT and (not ann100ftMtrig01.OUT)
	ann100ftMtrig01:update(a)

	WACO100		= a
	WPREC100	= ann100ftMtrig01.OUT

	A333DR_fws_aco_100 = bool2num[WACO100]

end




local function A333_fws_aco_200ft_announce()

	ann200ftPulse01:update(NS200)
	local a = (not NACOINIB) and ann200ftPulse01.OUT and (not ann200ftMtrig01.OUT)
	ann200ftMtrig01:update(a)

	WACO200		= a
	WPREC200	= ann200ftMtrig01.OUT

	A333DR_fws_aco_200 = bool2num[WACO200]

end




local function A333_fws_aco_300ft_announce()

	ann300ftPulse01:update(NS300)
	local a = (not NACOINIB) and ann300ftPulse01.OUT and (not ann300ftMtrig01.OUT)
	ann300ftMtrig01:update(a)

	WACO300		= a
	WPREC300	= ann300ftMtrig01.OUT

	A333DR_fws_aco_300 = bool2num[WACO300]

end




local function A333_fws_aco_400ft_announce()

	ann400ftPulse01:update(NS400)
	local a = (not NACOINIB) and ann400ftPulse01.OUT and (not ann400ftMtrig01.OUT)
	ann400ftMtrig01:update(a)

	WACO400 = a

	A333DR_fws_aco_400 = bool2num[WACO400]

end




local function A333_fws_aco_500ft_announce()

	local a = (not ann500ftMtrig01.OUT) and (not NACOINIB) and NS500 and WAC500
	ann500ftMtrig01:update(a)

	A333DR_fws_aco_500 = bool2num[a]

end






local function A333_fws_aco_1000ft_announce()

	ann1000ftHysteresis01:update(NRAH)
	ann1000ftPulse01:update(ann1000ftHysteresis01.out)
	ann1000ftSRRlatch01:update(ann1000ftPulse02.OUT, ann1000ftPulse01.OUT)
	local a = ann1000ftHysteresis01.out and NS1000 and (not NACOINIB) and (not ann1000ftSRRlatch01.Q)
	ann1000ftPulse02:update(a)

	A333DR_fws_aco_1000 = bool2num[a]

end




local function A333_fws_aco_2000ft_announce()

	ann2000ftHysteresis01:update(NRAH)
	ann2000ftPulse01:update(ann2000ftHysteresis01.out)
	ann2000ftSRRlatch01:update(ann2000ftPulse02.OUT, ann2000ftPulse01.OUT)
	local a = ann2000ftHysteresis01.out and NS2000 and (not NACOINIB) and (not ann2000ftSRRlatch01.Q)
	ann2000ftPulse02:update(a)

	A333DR_fws_aco_2000 = bool2num[a]

end




local function A333_fws_aco_2500ft_announce()

	ann2500ftHysteresis01:update(NRAH)
	ann2500ftPulse01:update(ann2500ftHysteresis01.out)
	ann2500ftSRRlatch01:update(ann2500ftPulse02.OUT, ann2500ftPulse01.OUT)
	local a = ann2500ftHysteresis01.out and NS2500 and (not NACOINIB) and (not ann2500ftSRRlatch01.Q)
	ann2500ftPulse02:update(a)

	A333DR_fws_aco_2500 = bool2num[a]

end





local function A333_fws_aco_2500Bft_announce()

	ann2500BftHysteresis01:update(NRAH)
	ann2500BftPulse01:update(ann2500BftHysteresis01.out)
	ann2500BftSRRlatch01:update(ann2500BftPulse02.OUT, ann2500BftPulse01.OUT)
	local a = ann2500BftHysteresis01.out and NS2500B and (not NACOINIB) and ann2500BftSRRlatch01.Q
	ann2500BftPulse02:update(a)

	A333DR_fws_aco_2500B = bool2num[a]

end




local function A333_fws_aco_20_retard_announce()

    ann20RETARDthreshold01:update(JR1TLA_1A)
    ann20RETARDthreshold02:update(JR1TLA_1A)
    local a = KAP1E and KLTRKM_1
    local b = KAP2E and KLTRKM_2
    local c = a or b
    local d = JR1TLASCL or JR2TLASCL
    local e = ann20RETARDthreshold01.out or ann20RETARDthreshold02.out
    local f = KATHRE and (not c)
    local g = (not KATHRE) or f
    local h = ZPH8 and d
    local i = WRRT and e
    local j = h or i
    local k = NRETINIB or j
    local l = NACOINIB or j
    local m = (not l) and NS020 and g and (not ann20RETARDMtrig01.OUT)
    ann20RETARDpulse01:update(m)
    ann20RETARDMtrig01:update(ann20RETARDpulse01.OUT)

	JRTOGA		= k
	JTOGA 		= l
	WRETTOGA	= k
	WJTOGA		= j
	W20RETARD	= m

	A333DR_fws_aco_20_retard = bool2num[ann20RETARDpulse01.OUT]

end




local function A333_fws_aco_toga_inhibition()

	togaInhib_pulse01:update(ZPH2)
	togaInhib_pulse02:update(ZPH3)
	togaInhib_pulse03:update(ZPH4)
	togaInhib_pulse04:update(ZPH9)
	togaInhib_pulse05:update(ZPH7)
	local a = JR12IDLE and ZPH8
	local b = togaInhib_pulse01.OUT or togaInhib_pulse02.OUT or togaInhib_pulse03.OUT or togaInhib_pulse04.OUT or togaInhib_pulse05.OUT
	togaInhib_srR01:update(a, b)

	JTOGAIN = togaInhib_srR01.Q

end




local function A333_fws_aco_10_retard_announce()


    local a = KAP1E and KLTRKM_1
    local b = KAP2E and KLTRKM_2
    local c = NACOINIB or JTOGA
    local d = a or b
    local e = KATHRE and d
    local f = (not c) and NS010 and e and (not ann10RETARDMtrig01.OUT)
    ann10RETARDpulse01:update(f)
    ann10RETARDMtrig01:update(ann10RETARDpulse01.OUT)

	W10RETARD = f

	A333DR_fws_aco_10_retard = bool2num[W10RETARD]

end




local function A333_fws_aco_tla_inhibition()

    local a = JR1TLAI or JR1TLAFG or JR1TLAFF
    local b = JR2TLAI or JR2TLAFG or JR2TLAFF
    local c = (not JR1NORUN) and JR2NORUN and a
    local d = JR1NORUN and (not JR2NORUN) and b
    local e = JR1TLREV or JR2TLREV
    local f = (not JR1NORUN) and (not JR2NORUN) and JR12IDLE
    local g = c or d or e or f
    local h = g or JTOGAIN

	JTLAINH = h

end




local function A333_fws_aco_retard_announce()

    annRETARDconf01:update(NHI20)
    annRETARDconf02:update(NHI10)
    local a =  KAP1E and KLTRKM_1
    local b =  KAP2E and KLTRKM_2
    local c =  a or b
    local d = KATHRE and c
    local e = KATHRE and (not c)
    local f = (not KATHRE) or e
    local h = ZPH6 or ZPH7 or ZPH8
    local i = JRFLEX or JRFLEX
    local j = JRTOGA or i or NDHINHIB
    local k = KATHRE and annRETARDconf01.OUT
    local l = annRETARDconf02.OUT and d
    local m = d  and (not WAC20) and NH20
    local n = d and (not WAC10) and NH10
    local o = k or l
    local p = m or n
    annRETARDpulse01:update(p)
    local q = not JTLAINH and o and h
    local r = q or annRETARDpulse01.OUT
    local s = r and not j

	WRETINHIB	= q
	NRDINH		= q
	WRETARD		= s

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







