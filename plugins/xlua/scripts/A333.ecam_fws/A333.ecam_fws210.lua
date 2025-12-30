--[[
*****************************************************************************************
* Script Name :	A333.ecam_fws210.lua
* Process: FWS General Data Processing

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


--print("LOAD: A333.ecam_fws210.lua")

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
local m = math
local bool2num = {[true] = 1, [false] = 0}

local flight_phase_status = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

local A333_fws = {}
local logic = {}

logic.fph_pulse01 = newLeadingEdgePulse('fph_pulse01')

logic.fphIO_pulseF01 = newFallingEdgePulse('fphIO_pulseF01')
logic.fphIO_pulseF02 = newFallingEdgePulse('fphIO_pulseF02')
logic.fphIO_pulseF03 = newFallingEdgePulse('fphIO_pulseF03')
logic.fphIO_pulseF04 = newFallingEdgePulse('fphIO_pulseF04')
logic.fphIO_pulseF05 = newFallingEdgePulse('fphIO_pulseF05')
logic.fphIO_pulseF06 = newFallingEdgePulse('fphIO_pulseF06')
logic.fphIO_pulseF07 = newFallingEdgePulse('fphIO_pulseF07')
logic.fphIO_pulseF08 = newFallingEdgePulse('fphIO_pulseF08')
logic.fphIO_pulseF09 = newFallingEdgePulse('fphIO_pulseF09')
logic.fphIO_pulseF10 = newFallingEdgePulse('fphIO_pulseF10')
logic.fphIO_srR01 = newSRlatchResetPriority('fphIO_srR01')

logic.apOffVolMtrig01 = newLeadingEdgeTrigger('apOffVolMtrig01', 1.0)
logic.apOffVolMtrig02 = newLeadingEdgeTrigger('apOffVolMtrig02', 1.0)
logic.apOffVolMtrig03 = newLeadingEdgeTrigger('apOffVolMtrig03', 1.5)
logic.apOffVolMtrig05 = newLeadingEdgeTrigger('apOffVolMtrig05', 3.0)
logic.apOffVolMtrig06 = newLeadingEdgeTrigger('apOffVolMtrig06', 3.0)
logic.apOffVolMtrig07 = newLeadingEdgeTrigger('apOffVolMtrig07', 9.0)
logic.apOffVolMtrig08 = newLeadingEdgeTrigger('apOffVolMtrig08', 9.0)
logic.apOffVolMtrig09 = newLeadingEdgeTrigger('apOffVolMtrig09', 0.5)
logic.apOffVolMtrig10 = newLeadingEdgeTrigger('apOffVolMtrig10', 1.5)
logic.apOffVolConf01 = newLeadingEdgeDelayedConfirmation('apOffVolConf01', 0.2)
logic.apOffVolPulse01 = newLeadingEdgePulse('apOffVolPulse01')
logic.apOffVolPulse02 = newFallingEdgePulse('apOffVolPulse02')

logic.stallConf01 = newLeadingEdgeDelayedConfirmation('stallConf01', 3.0)
logic.stallPulse01 = newLeadingEdgePulse('stallPulse01')
logic.stallPulse02 = newFallingEdgePulse('stallPulse02')
logic.stallPulse03 = newLeadingEdgePulse('stallPulse03')
logic.stallSRRlatch01 = newSRlatchResetPriority('stallSRRlatch01')

logic.stallWarn_pulse01 = newLeadingEdgePulse('stallWarn_pulse01')

logic.alt_conf01 = newLeadingEdgeDelayedConfirmation('alt_conf01', 4.0)
logic.alt_srR01 = newSRlatchResetPriority('alt_srR01')

logic.pwrRev_conf01 = newFallingEdgeDelayedConfirmation('pwrRev_conf01', 10.0)
logic.pwrRev_conf02 = newFallingEdgeDelayedConfirmation('pwrRev_conf02', 10.0)

logic.e1o2topwr_conf01 = newFallingEdgeDelayedConfirmation('e1o2topwr_conf01', 60.0)

logic.e1or2nr_conf01 = newLeadingEdgeDelayedConfirmation('e1or2nr_conf01', 30.0)
logic.e1or2nr_conf02 = newLeadingEdgeDelayedConfirmation('e1or2nr_conf02', 30.0)
logic.e1or2nr_conf03 = newLeadingEdgeDelayedConfirmation('e1or2nr_conf03', 30.0)
logic.e1or2nr_conf04 = newLeadingEdgeDelayedConfirmation('e1or2nr_conf04', 30.0)

logic.e1or2run_conf01 = newLeadingEdgeDelayedConfirmation('e1or2run_conf01', 30.0)

logic.eng1MasterSwitch_conf01 = newLeadingEdgeDelayedConfirmation('eng1MasterSwitch_conf01', 30.0)
logic.eng2MasterSwitch_conf01 = newLeadingEdgeDelayedConfirmation('eng2MasterSwitch_conf01', 30.0)

logic.ng_conf01 = newLeadingEdgeDelayedConfirmation('ng_conf01', 1.0)
logic.ng_conf02 = newLeadingEdgeDelayedConfirmation('ng_conf02', 0.5)
logic.ng_conf03 = newLeadingEdgeDelayedConfirmation('ng_conf03', 1.0)
logic.ng_conf04 = newLeadingEdgeDelayedConfirmation('ng_conf04', 0.5)
logic.ng_srS01 = newSRlatchSetPriority('ng_srS01')
logic.ng_srS02 = newSRlatchSetPriority('ng_srS02')

logic.gr_conf01 = newLeadingEdgeDelayedConfirmation('gr_conf01', 1.0)
logic.gr_mrTrigR_01 = newLeadingEdgeTriggerReTrigger('gr_mrTrigR_01', 10.0)
logic.gr_srS01 = newSRlatchSetPriority('gr_srS01')
logic.gr_srS02 = newSRlatchSetPriority('gr_srS02')

logic.fph_UE1FPBpulse01 = newLeadingEdgePulse('fph_UE1FPBpulse01')
logic.fph_ZH800FTpulse01 = newLeadingEdgePulse('fph_ZH800FTpulse01')
logic.fph_conf01 = newLeadingEdgeDelayedConfirmation('fph_conf01', 0.2)
logic.fph_conf02 = newLeadingEdgeDelayedConfirmation('fph_conf02', 0.2)
logic.fph_mTrigF_01 = newFallingEdgeTrigger('fph_mTrigF_01', 1.0)
logic.fph_mTrigF_02 = newFallingEdgeTrigger('fph_mTrigF_02', 3.0)
logic.fph_mTrigR_03 = newLeadingEdgeTrigger('fph_mTrigR_03', 300.0)
logic.fph_mTrigR_04 = newLeadingEdgeTrigger('fph_mTrigR_04', 2.0)
logic.fph_mTrigR_05 = newLeadingEdgeTrigger('fph_mTrigR_05', 2.0)
logic.fph_mTrigR_06 = newLeadingEdgeTrigger('fph_mTrigR_06', 2.0)
logic.fph_mTrigR_07 = newLeadingEdgeTrigger('fph_mTrigR_07', 120.0)
logic.fph_mTrigR_08 = newLeadingEdgeTrigger('fph_mTrigR_08', 180.0)
logic.fph_mTrigR_09 = newLeadingEdgeTrigger('fph_mTrigR_09', 2.0)
logic.fph_srR01 = newSRlatchResetPriority('fph_srR01')
logic.fph_srS02 = newSRlatchSetPriority('fph_srS02')

logic.spd_mtrigF_01 = newFallingEdgeTrigger('spd_mtrigF_01', 0.5)
logic.spd_mtrigF_02 = newFallingEdgeTrigger('spd_mtrigF_02', 1.5)
logic.spd_srS01 = newSRlatchSetPriority('spd_srS01')

--													 DN   UP	  DN   	    UP
logic.flapSFLPIA_L = newMarginSensor('flapSFLPIA_L', '[', ']', -104.00,   65.00)
logic.flapSFLPIA_R = newMarginSensor('flapSFLPIA_R', '[', ']', -104.00,   65.00)
logic.flapSFLPSB_L = newMarginSensor('flapSFLPSB_L', '[', ']', -104.00,  115.00)
logic.flapSFLPSB_R = newMarginSensor('flapSFLPSB_R', '[', ']', -104.00,  115.00)
logic.flapSFLPSC_L = newMarginSensor('flapSFLPSC_L', '[', ']', -104.00,  136.00)
logic.flapSFLPSC_R = newMarginSensor('flapSFLPSC_R', '[', ']', -104.00,  136.00)
logic.flapSFLPSD_L = newMarginSensor('flapSFLPSD_L', '[', ']', -104.00,  152.00)
logic.flapSFLPSD_R = newMarginSensor('flapSFLPSD_R', '[', ']', -104.00,  152.00)
logic.flapSFLPSE_L = newMarginSensor('flapSFLPSE_L', '[', ']', -104.00,  165.00)
logic.flapSFLPSE_R = newMarginSensor('flapSFLPSE_R', '[', ']', -104.00,  165.00)
logic.flapSFLPSF_L = newMarginSensor('flapSFLPSF_L', '[', ']', -104.00,  179.00)
logic.flapSFLPSF_R = newMarginSensor('flapSFLPSF_R', '[', ']', -104.00,  179.00)

logic.slatSSLTSA_L = newMarginSensor('slatSSLTSA_L', '[', ']',  -22.00,   24.76)
logic.slatSSLTSA_R = newMarginSensor('slatSSLTSA_R', '[', ']',  -22.00,   24.76)
logic.slatNSLTIB_L = newMarginSensor('slatNSLTIB_L', '[', '[', -174.29,   -4.00)
logic.slatNSLTIB_R = newMarginSensor('slatNSLTIB_R', '[', '[', -174.29,   -4.00)
logic.slatSSLTSC_L = newMarginSensor('slatSSLTSC_L', '[', ']', -161.90,  -22.00)
logic.slatSSLTSC_R = newMarginSensor('slatSSLTSC_R', '[', ']', -161.90,  -22.00)
logic.slatSSLTID_L = newMarginSensor('slatSSLTID_L', '[', '[', -149.54,   -4.00)
logic.slatSSLTID_R = newMarginSensor('slatSSLTID_R', '[', '[', -149.54,   -4.00)
logic.slatSSLTIE_L = newMarginSensor('slatSSLTIE_L', '[', '[', -112.38,   -4.00)
logic.slatSSLTIE_R = newMarginSensor('slatSSLTIE_R', '[', '[', -112.38,   -4.00)
logic.slatSSLTSF_L = newMarginSensor('slatSSLTSF_L', '[', ']',  -70.00,   -4.00)
logic.slatSSLTSF_R = newMarginSensor('slatSSLTSF_R', '[', ']',  -70.00,   -4.00)
logic.slatSSLTSG_L = newMarginSensor('slatSSLTSG_L', '[', ']',  -50.47,  -22.00)
logic.slatSSLTSG_R = newMarginSensor('slatSSLTSG_R', '[', ']',  -50.47,  -22.00)
logic.slatSSLTCC_L = newMarginSensor('slatSSLTCC_L', '[', ']', -161.90,   -4.00)
logic.slatSSLTCC_R = newMarginSensor('slatSSLTCC_R', '[', ']', -161.90,   -4.00)

logic.dh_dt_pos_s01	= newAnalogSwitch2in1out('dh_dt_pos_s01')
logic.dh_dt_pos_threshold01 = newSlopeThreshold('dh_dt_pos_threshold01', '>', 0.0, 'meters/sec')

logic.decHeightVal_s01 = newAnalogSwitch2in1out('decHeightVal_s01')
logic.decHeightVal_s02 = newAnalogSwitch2in1out('decHeightVal_s02')
logic.decHeightVal_s03 = newAnalogSwitch2in1out('decHeightVal_s03')
logic.decHeightVal_comp01 = newComparison('decHeightVal_comp01', '>')

logic.hundrdAbvNum_01 = newNumerical('hundrdAbvNum_01', '+', '+')
logic.hundrdAbvNum_02 = newNumerical('hundrdAbvNum_02', '+', '+')
logic.hundrdAbvComp01 = newComparison('hundrdAbvComp01', '<')
logic.hundrdAbvComp02 = newComparison('hundrdAbvComp02', '<')
logic.hundrdAbvConf01 = newLeadingEdgeDelayedConfirmation('hundrdAbvConf01', 0.1)
logic.hundrdAbvMtrig01 = newLeadingEdgeTrigger('hundrdAbvMtrig01', 3.0)
logic.hundrdAbvSRRlatch01 = newSRlatchResetPriority('hundrdAbvSRRlatch01')

logic.dhNum_01	= newNumerical('dhNum_01', '+', '+')
logic.dhNum_02	= newNumerical('dhNum_02', '+', '+')
logic.dhComp01 = newComparison('dhComp01', '<')
logic.dhComp02 = newComparison('dhComp02', '<')
logic.dhConf01 = newLeadingEdgeDelayedConfirmation('dhConf01', 0.1)
logic.dhTrig01 = newLeadingEdgeTrigger('dhTrig01', 3.0)
logic.dhSRRlatch01 = newSRlatchResetPriority('dhSRRlatch01')

logic.lowEnergyMtrig01 = newLeadingEdgeTrigger('lowEnergyMtrig01', 3.0)
logic.lowEnergyMtrig02 = newLeadingEdgeTrigger('lowEnergyMtrig02', 6.0)

logic.hydLoPrConf01 = newLeadingEdgeDelayedConfirmation('hydloPrConf01', 1.0)
logic.hydLoPrConf02 = newLeadingEdgeDelayedConfirmation('hydloPrConf02', 5.0)
logic.hydLoPrConf03 = newLeadingEdgeDelayedConfirmation('hydloPrConf03', 1.0)
logic.hydLoPrConf04 = newLeadingEdgeDelayedConfirmation('hydloPrConf04', 1.0)

logic.oilTempAdvSwitcg01 = newAnalogSwitch2in1out('oilTempAdvSwitcg01')
logic.oilTempAdvSwitcg02 = newAnalogSwitch2in1out('oilTempAdvSwitcg02')
logic.oilTempAdvComp01 = newComparison('oilTempAdvComp01', '>')
logic.oilTempAdvComp02 = newComparison('oilTempAdvComp02', '>')

logic.oilOvertempSwitch01 = newAnalogSwitch2in1out('oilOvertempSwitch01')
logic.oilOvertempSwitch02 = newAnalogSwitch2in1out('oilOvertempSwitch02')
logic.oilOvertempComp01 = newComparison('oilOvertempComp01', '>')
logic.oilOvertempComp02 = newComparison('oilOvertempComp02', '>')


logic.engOutpulse01 = newLeadingEdgePulse('engOutpulse01')
logic.engOutConf01 = newLeadingEdgeDelayedConfirmation('engOutConf01', 2.0)
logic.engOutConf02 = newFallingEdgeDelayedConfirmation('engOutConf02', 10.0)

logic.genResetPulse01 = newLeadingEdgePulse('genResetPulse01')
logic.genResetPulse02 = newLeadingEdgePulse('genResetPulse02')
logic.genResetPulse03 = newLeadingEdgePulse('genResetPulse03')
logic.genResetPulse04 = newLeadingEdgePulse('genResetPulse04')
logic.genResetSRR01 = newSRlatchResetPriority('genResetSRR01')
logic.genResetSRR02 = newSRlatchResetPriority('genResetSRR02')
logic.genResetSRR03 = newSRlatchResetPriority('genResetSRR03')
logic.genResetSRR04 = newSRlatchResetPriority('genResetSRR04')

logic.cfgTstNmlConf01 = newFallingEdgeDelayedConfirmation('cfgTstNmlConf01', 0.3)

logic.cfgTstNmlConf01 = newFallingEdgeDelayedConfirmation('cfgTstNmlConf01', 10.0)
logic.cfgTstNmlConf02 = newLeadingEdgeDelayedConfirmation('cfgTstNmlConf02', 30.0)
logic.cfgTstNmlConf03 = newLeadingEdgeDelayedConfirmation('cfgTstNmlConf03', 50.0)

logic.procAftEngShutDwnPulse01 = newLeadingEdgePulse('procAftEngShutDwnPulse01')
logic.procAftEngShutDwnPulse02 = newLeadingEdgePulse('procAftEngShutDwnPulse02')
logic.procAftEngShutDwnConf01 = newLeadingEdgeDelayedConfirmation('procAftEngShutDwnConf01', 10.0)
logic.procAftEngShutDwnSRR01 = newSRlatchResetPriority('procAftEngShutDwnSRR01')

logic.aiRvlvClsdFltConf01 = newLeadingEdgeDelayedConfirmation('aiRvlvClsdFltConf01', 15.0)
logic.aiRvlvClsdFltConf02 = newLeadingEdgeDelayedConfirmation('aiRvlvClsdFltConf02', 2.0)
logic.aiRvlvClsdFltConf03 = newLeadingEdgeDelayedConfirmation('aiRvlvClsdFltConf03', 25.0)
logic.aiRvlvClsdFltsrS01 = newSRlatchSetPriority('aiRvlvClsdFltsrS01')

logic.avoidIcingConf01 = newLeadingEdgeDelayedConfirmation('avoidIcingConf01', 10.0)
logic.avoidIcingConf02 = newLeadingEdgeDelayedConfirmation('avoidIcingConf02', 5.0)
logic.avoidIcingConf03 = newLeadingEdgeDelayedConfirmation('avoidIcingConf03', 60.0)
logic.avoidIcingConf04 = newLeadingEdgeDelayedConfirmation('avoidIcingConf04', 60.0)
logic.avoidIcingPulse01 = newLeadingEdgePulse('avoidIcingPulse01')
logic.avoidIcingSRR01 = newSRlatchResetPriority('avoidIcingSRR01')
logic.avoidIcingSRR02 = newSRlatchResetPriority('avoidIcingSRR02')
logic.avoidIcingMTrig01 = newFallingEdgeTrigger('avoidIcingMTrig01', 1.0)

logic.stsAutoCallPulse01 = newLeadingEdgePulse('stsAutoCallPulse01')
logic.stsAutoCallPulse02 = newLeadingEdgePulse('stsAutoCallPulse02')
logic.stsAutoCallSRR01 = newSRlatchResetPriority('stsAutoCallSRR01')

logic.clearStsConf01 = newLeadingEdgeDelayedConfirmation('clearStsConf01', 2.0)
logic.clearStsPulse01 = newLeadingEdgePulse('clearStsPulse01')


logic.CabAltExcessive = false

logic.baroAltFO = newMarginSensor('baroAltFO', ']', '[', -250.0, 250.0)
logic.baroAltCAPT = newMarginSensor('baroAltCAPT', ']', '[', -250.0, 250.0)

logic.AltFO = newMarginSensor('AltFO', ']', '[', -500.0, 500.0)
logic.AltCAPT = newMarginSensor('AltCAPT', ']', '[', -500.0, 500.0)

logic.eng1_flex_mode_is_available = true
logic.eng1_idle_mode_selected = false
logic.eng1_flex_mode_selected = false
logic.eng1_clb_mode_selected = false

logic.eng2_flex_mode_is_available = true
logic.eng2_idle_mode_selected = false
logic.eng2_flex_mode_selected = false
logic.eng2_clb_mode_selected = false

local ac1_was_powered = false
local ac2_was_powered = false
local ac_ess_was_powered = false
local dc1_was_powered = false
local dc2_was_powered = false
local dc_ess_was_powered = false



--*************************************************************************************--
--** 				            LOCAL UTILITY FUNCTIONS          			    	 **--
--*************************************************************************************--
local rescale = rescale
local bMT = bMT


--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
DR_running_time = find_dataref("sim/time/total_running_time_sec")
simDR_flex_temp	= find_dataref("sim/flightmodel/engine/ENGN_assumed_temp")


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
function A333_fws.ac1_power_is_lost()

    if (not ac1_was_powered) and A333DR_ac_bus1_volts > 0 then
        EAC1OF = false
        ac1_was_powered = true
    end

    if ac1_was_powered and A333DR_ac_bus1_volts <= 0 then
        EAC1OF = true
        ac1_was_powered = false
    end

    A333DR_elec_loss_of_bus_ac1 = bool2num[EAC1OF]

end




function A333_fws.ac2_power_is_lost()

    if (not ac2_was_powered) and A333DR_ac_bus2_volts > 0 then
        EAC2OF = false
        ac2_was_powered = true
    end

    if ac2_was_powered and A333DR_ac_bus2_volts <= 0 then
        EAC2OF = true
        ac2_was_powered = false
    end

    A333DR_elec_loss_of_bus_ac2 = bool2num[EAC2OF]

end




function A333_fws.ac_ess_power_is_lost()

    if (not ac_ess_was_powered) and A333DR_ac_ess_bus_volts > 0 then
        EACSOF = false
        ac_ess_was_powered = true
    end

    if ac_ess_was_powered and A333DR_ac_ess_bus_volts <= 0 then
        EACSOF = true
        ac_ess_was_powered = false
    end

end




function A333_fws.dc1_power_is_lost()

    if (not dc1_was_powered) and A333DR_dc_bus1_volts > 0 then
        EDC1OF = false
        dc1_was_powered = true
    end

    if dc1_was_powered and A333DR_dc_bus1_volts <= 0 then
        EDC1OF = true
        dc1_was_powered = false
    end

end




function A333_fws.dc2_power_is_lost()

    if (not dc2_was_powered) and A333DR_dc_bus2_volts > 0 then
        EDC2OF = false
        dc2_was_powered = true
    end

    if dc2_was_powered and A333DR_dc_bus2_volts <= 0 then
        EDC2OF = true
        dc2_was_powered = false
    end

end




function A333_fws.dc_ess_power_is_lost()

    if (not dc_ess_was_powered) and A333DR_dc_ess_bus_volts > 0 then
        EDCSOF = false
        dc_ess_was_powered = true
    end

    if dc_ess_was_powered and A333DR_dc_ess_bus_volts <= 0 then
        EDCSOF = true
        dc_ess_was_powered = false
    end

end




function A333_fws.nav_vfe_speed()

	local speedThr184_1 = NCAS_1 > 184.0
	local speedThr184_2 = NCAS_2 > 184.0
	local speedThr184_3 = NCAS_3 > 184.0
	local speedThr190_1 = NCAS_1 > 190.0
	local speedThr190_2 = NCAS_2 > 190.0
	local speedThr190_3 = NCAS_3 > 190.0
	local speedThr200_1 = NCAS_1 > 200.0
	local speedThr200_2 = NCAS_2 > 200.0
	local speedThr200_3 = NCAS_3 > 200.0
	local speedThr204_1 = NCAS_1 > 204.0
	local speedThr204_2 = NCAS_2 > 204.0
	local speedThr204_3 = NCAS_3 > 204.0
	local speedThr209_1 = NCAS_1 > 209.0
	local speedThr209_2 = NCAS_2 > 209.0
	local speedThr209_3 = NCAS_3 > 209.0
	local speedThr219_1 = NCAS_1 > 219.0
	local speedThr219_2 = NCAS_2 > 219.0
	local speedThr219_3 = NCAS_3 > 219.0
	local speedThr244_1 = NCAS_1 > 244.0
	local speedThr244_2 = NCAS_2 > 244.0
	local speedThr244_3 = NCAS_3 > 244.0
	local speedThr250_1 = NCAS_1 > 250.0
	local speedThr250_2 = NCAS_2 > 250.0
	local speedThr250_3 = NCAS_3 > 250.0

    local a = NCAS_1_INV or NCAS_1_NCD
    local b = NCAS_2_INV or NCAS_2_NCD
    local c = NCAS_3_INV or NCAS_3_NCD
    local d = speedThr184_1 and (not a)
    local e = speedThr184_2 and (not b)
    local f = speedThr184_3 and (not c)
    local g = speedThr190_1 and (not a)
    local h = speedThr190_2 and (not b)
    local i = speedThr190_3 and (not c)
    local j = speedThr200_1 and (not a)
    local k = speedThr200_2 and (not b)
    local l = speedThr200_3 and (not c)
    local m = speedThr204_1 and (not a)
    local n = speedThr204_2 and (not b)
    local o = speedThr204_3 and (not c)
    local p = speedThr209_1 and (not a)
    local q = speedThr209_2 and (not b)
    local r = speedThr209_3 and (not c)
    local s = speedThr219_1 and (not a)
    local t = speedThr219_2 and (not b)
    local u = speedThr219_3 and (not c)
    local v = speedThr244_1 and (not a)
    local w = speedThr244_2 and (not b)
    local x = speedThr244_3 and (not c)
    local y = speedThr250_1 and (not a)
    local z = speedThr250_2 and (not b)
    local z1 = speedThr250_3 and (not c)

    local aa = d or e or f	    --184
    local bb = g or h or i	    --190
    local cc = j or k or l	    --200
    local dd = m or n or o	    --204
    local ee = p or q or r      --209
    local ff = s or t or u 	    --219
    local gg = v or w or x	    --244
    local hh = y or z or z1	    --250

    NASS184 = aa
	NASS190 = bb
	NASS200 = cc
	NASS204 = dd
	NASS209 = ee
	NASS219 = ff
	NASS244 = gg
	NASS250 = hh

end




function A333_fws.flap_deg_syn()

	-- Left
	local flap1DegSurf_L = simDR_flap1_deg[0]

	if flap1DegSurf_L <= 2.0 then
		SLFLPPOS = rescale(0, 0, 2.0, 65.00, flap1DegSurf_L)

	elseif flap1DegSurf_L > 2.0 and flap1DegSurf_L <= 7.0 then
		SLFLPPOS = rescale(2.0, 65.00, 7.0, 115.0, flap1DegSurf_L)

	elseif flap1DegSurf_L > 7.0 and flap1DegSurf_L <= 8.0 then
		SLFLPPOS = rescale(7.0, 115.00, 8.0, 121.0, flap1DegSurf_L)

	elseif flap1DegSurf_L > 8.0 and flap1DegSurf_L <= 14.0 then
		SLFLPPOS = rescale(8.0, 121.0, 14.0, 146.0, flap1DegSurf_L)

	elseif flap1DegSurf_L > 14.0 and flap1DegSurf_L <= 17.0 then
		SLFLPPOS = rescale(14.0, 146.0, 17.0, 152.00, flap1DegSurf_L)

	elseif flap1DegSurf_L > 17.0 and flap1DegSurf_L <= 21.0 then
		SLFLPPOS = rescale(17.0, 152.0, 21.0, 165.0, flap1DegSurf_L)

	elseif flap1DegSurf_L > 21.0 and flap1DegSurf_L <= 22.0 then
		SLFLPPOS = rescale(21.0, 165.0, 22.0, 168.0, flap1DegSurf_L)

	elseif flap1DegSurf_L > 22.0 and flap1DegSurf_L <= 26.0 then
		SLFLPPOS = rescale(22.0, 168.0, 26.0, 179.0, flap1DegSurf_L)

	elseif flap1DegSurf_L > 26.0 and flap1DegSurf_L <= 26.12 then
		SLFLPPOS = rescale(26.0, 179.0, 26.12, 180.0, flap1DegSurf_L)

	elseif flap1DegSurf_L >= 26.120001 and flap1DegSurf_L <= 32 then
		SLFLPPOS = rescale(26.120001, -179.999999, 32.0, -129.0, flap1DegSurf_L)

	elseif flap1DegSurf_L > 32.0 then
		SLFLPPOS = rescale(32.0, -129.00, 44.5, -104.0, flap1DegSurf_L)

	end



	-- Right
	local flap1DegSurf_R = simDR_flap1_deg[1]

	if flap1DegSurf_R <= 2.0 then
		SRFLPPOS = rescale(0, 0, 2.0, 65.00, flap1DegSurf_R)

	elseif flap1DegSurf_R > 2.0 and flap1DegSurf_R <= 7.0 then
		SRFLPPOS = rescale(2.0, 65.00, 7.0, 115.0, flap1DegSurf_R)

	elseif flap1DegSurf_R > 7.0 and flap1DegSurf_R <= 8.0 then
		SRFLPPOS = rescale(7.0, 115.00, 8.0, 121.0, flap1DegSurf_R)

	elseif flap1DegSurf_R > 8.0 and flap1DegSurf_R <= 14.0 then
		SRFLPPOS = rescale(8.0, 121.0, 14.0, 146.0, flap1DegSurf_R)

	elseif flap1DegSurf_R > 14.0 and flap1DegSurf_R <= 17.0 then
		SRFLPPOS = rescale(14.0, 146.0, 17.0, 152.00, flap1DegSurf_R)

	elseif flap1DegSurf_R > 17.0 and flap1DegSurf_R <= 21.0 then
		SRFLPPOS = rescale(17.0, 152.0, 21.0, 165.0, flap1DegSurf_R)

	elseif flap1DegSurf_R > 21.0 and flap1DegSurf_R <= 22.0 then
		SRFLPPOS = rescale(21.0, 165.0, 22.0, 168.0, flap1DegSurf_R)

	elseif flap1DegSurf_R > 22.0 and flap1DegSurf_R <= 26.0 then
		SRFLPPOS = rescale(22.0, 168.0, 26.0, 179.0, flap1DegSurf_R)

	elseif flap1DegSurf_R > 26.0 and flap1DegSurf_R <= 26.12 then
		SRFLPPOS = rescale(26.0, 179.0, 26.12, 180.0, flap1DegSurf_R)

	elseif flap1DegSurf_R >= 26.120001 and flap1DegSurf_R <= 32 then
		SRFLPPOS = rescale(26.120001, -179.999999, 32.0, -129.0, flap1DegSurf_R)

	elseif flap1DegSurf_R > 32.0 then
		SRFLPPOS = rescale(32.0, -129.00, 44.5, -104.0, flap1DegSurf_R)

	end

end




function A333_fws.sflpia()

	logic.flapSFLPIA_L:update(SLFLPPOS)
	logic.flapSFLPIA_R:update(SRFLPPOS)

    local a = SLFLPPOS_VAL and (not SLFLPPOS_NCD)
    local b = SRFLPPOS_VAL and (not SRFLPPOS_NCD)
    local c = SLFLPPOS_VAL and logic.flapSFLPIA_L.output and (not SLFLPPOS_NCD)
    local d = SRFLPPOS_VAL and logic.flapSFLPIA_R.output and (not SRFLPPOS_NCD)
    local e = SRFLPPOS_NCD and SLFLPPOS_NCD
    local f = a or b
    local g = c or d or e

	SFLPVAL = f
	SFLPIA = g

end




function A333_fws.sflpsb()

	logic.flapSFLPSB_L:update(SLFLPPOS)
	logic.flapSFLPSB_R:update(SRFLPPOS)

    local a = SLFLPPOS_VAL and (not logic.flapSFLPSB_L.output) and (not SLFLPPOS_NCD)
    local b = SRFLPPOS_VAL and (not logic.flapSFLPSB_R.output) and (not SRFLPPOS_NCD)
    local c = a or b

	SFLPSB = c

end




function A333_fws.sflpsc()

	logic.flapSFLPSC_L:update(SLFLPPOS)
	logic.flapSFLPSC_R:update(SRFLPPOS)

    local a = SLFLPPOS_VAL and (not logic.flapSFLPSC_L.output) and (not SLFLPPOS_NCD)
    local b = SRFLPPOS_VAL and (not logic.flapSFLPSC_R.output) and (not SRFLPPOS_NCD)
    local c = a or b

	SFLPSC = c

end




function A333_fws.sflpsd()

	logic.flapSFLPSD_L:update(SLFLPPOS)
	logic.flapSFLPSD_R:update(SRFLPPOS)

    local a = SLFLPPOS_VAL and (not logic.flapSFLPSD_L.output) and (not SLFLPPOS_NCD)
    local b = SRFLPPOS_VAL and (not logic.flapSFLPSD_R.output) and (not SRFLPPOS_NCD)
    local c = a or b

	SFLPSD = c

end




function A333_fws.sflpse()

	logic.flapSFLPSE_L:update(SLFLPPOS)
	logic.flapSFLPSE_R:update(SRFLPPOS)

    local a = SLFLPPOS_VAL and (not logic.flapSFLPSE_L.output) and (not SLFLPPOS_NCD)
    local b = SRFLPPOS_VAL and (not logic.flapSFLPSE_R.output) and (not SRFLPPOS_NCD)
    local c = a or b

	SFLPSE = c

end




function A333_fws.sflpsf()

	logic.flapSFLPSF_L:update(SLFLPPOS)
	logic.flapSFLPSF_R:update(SRFLPPOS)

    local a = SLFLPPOS_VAL and (not logic.flapSFLPSF_L.output) and (not SLFLPPOS_NCD)
    local b = SRFLPPOS_VAL and (not logic.flapSFLPSF_R.output) and (not SRFLPPOS_NCD)
    local c = a or b

	SFLPSF = c

end




function A333_fws.slat_deg_syn()

	local slatDegSurf = rescale(0.0, 0.0, 1.0, 23.0, simDR_slat1_deploy_rat)

	if slatDegSurf <= 2.0 then
		SLSLTPOS = rescale(0.0, 0.0, 2.0, 24.76, slatDegSurf)

	elseif slatDegSurf > 2.0 and slatDegSurf <= 12.59 then
		SLSLTPOS = rescale(2.0, 24.76, 12.59, 180.0, slatDegSurf)

	elseif slatDegSurf >= 12.590001 and slatDegSurf <= 13.0 then
		SLSLTPOS = rescale(12.590001, -179.999999, 13.0, -174.00, slatDegSurf)

	elseif slatDegSurf > 13.0 and slatDegSurf <= 14.0 then
		SLSLTPOS = rescale(13.0, -174.0, 14.0, -161.0, slatDegSurf)

	elseif slatDegSurf > 14.0 and slatDegSurf <= 15.0 then
		SLSLTPOS = rescale(14.0, -161.0, 15.0, -150.0, slatDegSurf)

	elseif slatDegSurf > 15.0 and slatDegSurf <= 16.0 then
		SLSLTPOS = rescale(15.0, -150.0, 16.0, -137.0, slatDegSurf)

	elseif slatDegSurf > 16.0 and slatDegSurf <= 18.0 then
		SLSLTPOS = rescale(16.0, -137.0, 18.0, -118.0, slatDegSurf)

	elseif slatDegSurf > 18.0 and slatDegSurf <= 20.0 then
		SLSLTPOS = rescale(18.0, -118.0, 20.0, -88.0, slatDegSurf)

	elseif slatDegSurf > 20.0 and slatDegSurf <= 21.2 then
		SLSLTPOS = rescale(20.0, -88.0, 21.2, -70.0, slatDegSurf)

	elseif slatDegSurf > 21.2 and slatDegSurf <= 21.8 then
		SLSLTPOS = rescale(21.2, -70.0, 21.8, -50.0, slatDegSurf)

	elseif slatDegSurf > 21.8 and slatDegSurf <= 23.0 then
		SLSLTPOS = rescale(21.8, -50.0, 23.0, -26.0, slatDegSurf)

	elseif slatDegSurf > 23.0 and slatDegSurf <= 25.0 then
		SLSLTPOS = rescale(23.0, -26.0, 25.0, -22.0, slatDegSurf)

	elseif slatDegSurf > 25.0 and slatDegSurf <= 35.5 then
		SLSLTPOS = rescale(25.0, -22.0, 35.5, -1.0, slatDegSurf)

	end

	SRSLTPOS = SLSLTPOS

end




function A333_fws.ssltsa()

	logic.slatSSLTSA_L:update(SLSLTPOS)
	logic.slatSSLTSA_R:update(SRSLTPOS)

    local a = SLSLTPOS_INV or SLSLTPOS_NCD
    local b = SRSLTPOS_INV or SRSLTPOS_NCD
    local d = (not logic.slatSSLTSA_L.output) and (not a)
    local e = (not logic.slatSSLTSA_R.output) and (not b)
    local f = d or e

    SSLTSA = f

end




function A333_fws.nsltib()

	logic.slatNSLTIB_L:update(SLSLTPOS)
	logic.slatNSLTIB_R:update(SRSLTPOS)

    local a = SLSLTPOS_VAL and (not logic.slatNSLTIB_L.output) and (not SLSLTPOS_NCD)
    local b = SRSLTPOS_VAL and (not logic.slatNSLTIB_R.output) and (not SRSLTPOS_NCD)
    local c = a or b

	NSLTIB = c

end




function A333_fws.ssltsc()

	logic.slatSSLTSC_L:update(SLSLTPOS)
	logic.slatSSLTSC_R:update(SRSLTPOS)

    local a = SLSLTPOS_INV or SLSLTPOS_NCD
    local b = SRSLTPOS_INV or SRSLTPOS_NCD
    local c = (not logic.slatSSLTSC_L.output) and (not a)
    local d = (not logic.slatSSLTSC_R.output) and (not b)
    local e = c or d

	SSLTSC = e

end




function A333_fws.ssltid()

	logic.slatSSLTID_L:update(SLSLTPOS)
	logic.slatSSLTID_R:update(SRSLTPOS)

    local a = SLSLTPOS_INV or SLSLTPOS_NCD
    local b = SRSLTPOS_INV or SRSLTPOS_NCD
    local c = (not logic.slatSSLTID_L.output) and (not a)
    local d = (not logic.slatSSLTID_R.output) and (not b)
    local e = c or d

	SSLTID = e

end




function A333_fws.ssltie()

	logic.slatSSLTIE_L:update(SLSLTPOS)
	logic.slatSSLTIE_R:update(SRSLTPOS)

    local a = SLSLTPOS_INV or SLSLTPOS_NCD
    local b = SRSLTPOS_INV or SRSLTPOS_NCD
    local c = (not logic.slatSSLTIE_L.output) and (not a)
    local d = (not logic.slatSSLTIE_R.output) and (not b)
    local e = c or d

	SSLTIE = e

end




function A333_fws.ssltsf()

	logic.slatSSLTSF_L:update(SLSLTPOS)
	logic.slatSSLTSF_R:update(SRSLTPOS)

    local a = SLSLTPOS_VAL and logic.slatSSLTSF_L.output and (not SLSLTPOS_NCD)
    local b = SRSLTPOS_VAL and logic.slatSSLTSF_R.output and (not SRSLTPOS_NCD)
    local c = a or b

	SSLTSF = c

end




function A333_fws.ssltsg()

	logic.slatSSLTSG_L:update(SLSLTPOS)
	logic.slatSSLTSG_R:update(SRSLTPOS)

    local a = SLSLTPOS_INV or SLSLTPOS_NCD
    local b = SRSLTPOS_INV or SRSLTPOS_NCD
    local c = logic.slatSSLTSG_L.output and (not a)
    local d = logic.slatSSLTSG_R.output and (not b)
    local e = c or d

	SSLTSG = e

end




function A333_fws.sflpdsltc()

	logic.slatSSLTCC_L:update(SLSLTPOS)
	logic.slatSSLTCC_R:update(SRSLTPOS)

    local a = SLSLTPOS_VAL and logic.slatSSLTCC_L.output and (not SLSLTPOS_NCD)
    local b = SRSLTPOS_VAL and logic.slatSSLTCC_R.output and (not SRSLTPOS_NCD)
    local d = a or b
    local g = SFLPSD or d

	SFLPDSLTC = f

end




function A333_fws.def_alt()

	local alt_th01 = NRADH_1 > 1500.0
	local alt_th02 = NRADH_2 > 1500.0
	local alt_th03 = NRADH_1 < 800.0
	local alt_th04 = NRADH_2 < 800.0

    local a = alt_th01 and (not NRADH_1_INV)
    local b = alt_th02 and (not NRADH_2_INV)
    local c = NRADH_1_INV and NRADH_2_INV
    local d = NRADH_1_NCD or NRADH_1_INV
    local e = NRADH_2_NCD or NRADH_2_INV
    local f = (not NRADH_1_INV) and alt_th03 and (not NRADH_1_NCD)
    local g = (not NRADH_2_INV) and alt_th04 and (not NRADH_2_NCD)
    local h = (not c) and d and e
    local i = f or g
    logic.alt_conf01:update(h)
    local j = a or b or logic.alt_conf01.OUT
    local k = (not logic.alt_conf01.OUT) and i
    logic.alt_srR01:update(j, k)

	ZH800FT		= logic.alt_srR01.Q
	ZH1500FT	= j
	ZHFAIL		= c

end




function A333_fws.tla_mct_flex()

    local TLAMCTorFlex01 = JR1TLA_1A < 0.7913
    local TLAMCTorFlex02 = JR1TLA_1A > 0.7287
    local TLAMCTorFlex03 = JR1TLA_1B < 0.7913
    local TLAMCTorFlex04 = JR1TLA_1B > 0.7287
    local TLAMCTorFlex05 = JR2TLA_2A < 0.7913
    local TLAMCTorFlex06 = JR2TLA_2A > 0.7287
    local TLAMCTorFlex07 = JR2TLA_2B < 0.7913
    local TLAMCTorFlex08 = JR2TLA_2B > 0.7287

    local a = TLAMCTorFlex01 and JR1TLA_1A_VAL and TLAMCTorFlex02
    local b = JR1TLA_1A_VAL and (not TLAMCTorFlex01)
    local c = TLAMCTorFlex03 and JR1TLA_1B_VAL and TLAMCTorFlex04
    local d = JR1TLA_1B_VAL and (not TLAMCTorFlex03)
    local e = TLAMCTorFlex05 and JR2TLA_2A_VAL and TLAMCTorFlex06
    local f = JR2TLA_2A_VAL and (not TLAMCTorFlex05)
    local g = TLAMCTorFlex07 and JR2TLA_2B_VAL and TLAMCTorFlex08
    local h = JR2TLA_2B_VAL and (not TLAMCTorFlex07)
    local i = a or c
    local j = b or d
    local k = e or g
    local l = f or h
    local m = i and WRRT
    local n = j and WRRT
    local o = k and WRRT
    local p = l and WRRT

	JR1TLAMCT	= m
	JR1SUPMCT	= n
	JR2TLAMCT	= o
	JR2SUPMCT	= p

end




function A333_fws.dto_installed()

    local a = JRDTOFINST_1A or JRDTOFINST_1B or JRDTOFINST_2A or JRDTOFINST_2B

	JRDTOI	= a

end




function A333_fws.eng1_or_2_norun()

	logic.e1or2nr_conf01:update(JR1AIDLE_1A)
	logic.e1or2nr_conf02:update(JR1AIDLE_1B)
	logic.e1or2nr_conf03:update(JR2AIDLE_2A)
	logic.e1or2nr_conf04:update(JR2AIDLE_2B)

    local a = WRRT and (not logic.e1or2nr_conf01.OUT) and (not logic.e1or2nr_conf02.OUT)
    local b = (not JML1ON) and JML1ON_VAL
    local c = WRRT and (not logic.e1or2nr_conf03.OUT) and (not logic.e1or2nr_conf04.OUT)
    local d = (not JML2ON) and JML2ON_VAL
    local e = a or b
    local f = c or d

	JR1NORUN = e
	JR2NORUN = f

end

function A333_fws.eng1_or_2_norun_ER()
	logic.e1or2nr_conf01:resetTimer()
	logic.e1or2nr_conf01.lastIN = true
	logic.e1or2nr_conf01.OUT = true
	logic.e1or2nr_conf02:resetTimer()
	logic.e1or2nr_conf02.lastIN = true
	logic.e1or2nr_conf02.OUT = true
	logic.e1or2nr_conf03:resetTimer()
	logic.e1or2nr_conf03.lastIN = true
	logic.e1or2nr_conf03.OUT = true
	logic.e1or2nr_conf04:resetTimer()
	logic.e1or2nr_conf04.lastIN = true
	logic.e1or2nr_conf04.OUT = true
end




function A333_fws.eng1_and_2_norun()

    local a = JR1NORUN and JR2NORUN

	ZR12NORUN = a

end




function A333_fws.eng1_or_2_run()

    local a = JR1AIDLE_1A or JR1AIDLE_1B or JR2AIDLE_2A or JR2AIDLE_2B
    local b = WRRT and a
    logic.e1or2run_conf01:update(b)

	ZR1O2RUN 	= logic.e1or2run_conf01.OUT
	ZOERG		= b

end

function A333_fws.eng1_or_2_run_ER()
	logic.e1or2run_conf01:resetTimer()
	logic.e1or2run_conf01.lastIN = true
	logic.e1or2run_conf01.OUT = true
end




function A333_fws.dto_sel()

    local a = JRDTOSEL_1A or JRDTOSEL_1B
    local b = JRDTOSEL_2A or JRDTOSEL_2B
    local c = a and WRRT
    local d = b and WRRT

	JR1DTOSELI = c
	JR2DTOSELI = d

end




function A333_fws.tr_mode_selected()

	-- ENGINE 1 FLEX MODE
	if A333DR_flight_phase <= 4
		and logic.eng1_flex_mode_is_available
		and JR1TLAMCT
		and (simDR_flex_temp[0] >= 15 and simDR_flex_temp[0] <= 70)
	then
		logic.eng1_flex_mode_selected = true

	elseif A333DR_flight_phase > 4 then
		if logic.eng1_flex_mode_selected == 1
			and
			(simDR_fadec_power_mode_eng1 == 1 or simDR_fadec_power_mode_eng1 == 3)
		then
			logic.eng1_flex_mode_is_available = false
			logic.eng1_flex_mode_selected = false
		end
	end

	if not logic.eng1_flex_mode_is_available
		and
		A333DR_flight_phase >= 8    -- Touchdown
		and
		simDR_flex_temp[0] == 0		-- MCDU has been reset @ touchdown
	then
		logic.eng1_flex_mode_is_available = true
	end

	-- ENGINE 2 FLEX MODE
	if A333DR_flight_phase <= 4
		and logic.eng2_flex_mode_is_available
		and JR2TLAMCT
		and (simDR_flex_temp[1] >= 15 and simDR_flex_temp[1] <= 70)
	then
		logic.eng2_flex_mode_selected = true

	elseif A333DR_flight_phase > 4 then
		if logic.eng2_flex_mode_selected == 1
			and
			(simDR_fadec_power_mode_eng2 == 1 or simDR_fadec_power_mode_eng2 == 3)
		then
			logic.eng2_flex_mode_is_available = false
			logic.eng2_flex_mode_selected = false
		end
	end

	if not logic.eng2_flex_mode_is_available
		and
		A333DR_flight_phase >= 8    -- Touchdown
		and
		simDR_flex_temp[0] == 0		-- MCDU has been reset @ touchdown
	then
		logic.eng2_flex_mode_is_available = true
	end


	JR1TRMDB19_1A = false								-- ENG 1 TR MODE IDLE SELECTED
	JR1TRMDB20_1A = JR1TLACL							-- ENG 1 TR MODE MAX CLIMB SELECTED
	JR1TRMDB21_1A = logic.eng1_flex_mode_selected		-- ENG 1 TR MODE FLEX TAKE OFF SELECTED
	JR1TRMDB19_1B = false								-- ENG 1 TR MODE IDLE SELECTED
	JR1TRMDB20_1B = JR1TLACL							-- ENG 1 TR MODE MAX CLIMB SELECTED
	JR1TRMDB21_1B = logic.eng1_flex_mode_selected		-- ENG 1 TR MODE FLEX TAKE OFF SELECTE

	JR2TRMDB19_2A = false								-- ENG 2 TR MODE IDLE SELECTED
	JR2TRMDB20_2A = JR2TLACL							-- ENG 2 TR MODE MAX CLIMB SELECTED
	JR2TRMDB21_2A = logic.eng2_flex_mode_selected		-- ENG 2 TR MODE FLEX TAKE OFF SELECTED
	JR2TRMDB19_2B = false								-- ENG 2 TR MODE IDLE SELECTED
	JR2TRMDB20_2B = JR2TLACL							-- ENG 2 TR MODE MAX CLIMB SELECTED
	JR2TRMDB21_2B = logic.eng2_flex_mode_selected		-- ENG 2 TR MODE FLEX TAKE OFF SELECTED


end




function A333_fws.fto_mode()

    local a = (not JR1TRMDB19_1A) and (not JR1TRMDB20_1A) and JR1TRMDB21_1A
    local b = (not JR1TRMDB19_1B )and (not JR1TRMDB20_1B) and JR1TRMDB21_1B
    local c = (not JR2TRMDB19_2A) and (not JR2TRMDB20_2A) and JR2TRMDB21_2A
    local d = (not JR2TRMDB19_2B) and (not JR2TRMDB20_2B) and JR2TRMDB21_2B
    local e = JR1TRMDB19_1A and (not JR1TRMDB20_1A) and JR1TRMDB21_1A
    local f = a or b
    local g = JR1TRMDB19_1B and (not JR1TRMDB20_1B) and JR1TRMDB21_1B
    local h = JR2TRMDB19_2A and (not JR2TRMDB20_2A) and JR2TRMDB21_2A
    local i = c or d
    local j = JR2TRMDB19_2B and (not JR2TRMDB20_2B) and JR2TRMDB21_2B
    local k = e or g
    local l = JR1DTOSELI or f
    local m = i or JR2DTOSELI
    local n = h or j
    local o = k and WRRT
    local p = l and WRRT
    local q = f and WRRT
    local r = WRRT and i
    local s = WRRT and m
    local t = WRRT and n

	JR1DTOSEL	= JR1DTOSELI
	JR2DTOSEL	= JR2DTOSELI

	JR1TGMD		= o
	JR1FTOMD	= p
	JR1FXMOD	= q

	JR2TGMD		= t
	JR2FTOMD	= s
	JR2FXMOD	= r

end




function A333_fws.takeoff()

	--| THRESHOLD
	local epwr_th01 = JR1N1_1A > 95.0
	local epwr_th02 = JR1N1_1B > 95.0

	local epwr_th03 = JR2N1_2A > 95.0
	local epwr_th04 = JR2N1_2B > 95.0

    local a = JR1N1_1A_INV or JR1N1_1A_NCD
    local b = JR1N1_1B_INV or JR1N1_1B_NCD
    local c = JR2N1_2A_INV or JR2N1_2A_NCD
    local d = JR2N1_2B_INV or JR2N1_2B_NCD
    local e = (not a) and epwr_th01
    local f = epwr_th02 and (not b)
    local g = (not c) and epwr_th03
    local h = epwr_th04 and (not d)
    local i = e or f
    local j = g or h
    local k = i and WRRT
    local l = WRRT and j

	JR1TOFF = k
	JR2TOFF = l

end




function A333_fws.tla_pwr_rev()

	--| THRESHOLD
    local pwrRev_th01 = JR1TLA_1A > 0.8012
    local pwrRev_th02 = JR1TLA_1B > 0.8012
    local pwrRev_th03 = JR1TLA_1A < 0.0
    local pwrRev_th04 = JR1TLA_1B < 0.0
    local pwrRev_th05 = JR2TLA_2A > 0.8012
    local pwrRev_th06 = JR2TLA_2B > 0.8012
    local pwrRev_th07 = JR2TLA_2A < 0.0
    local pwrRev_th08 = JR2TLA_2B < 0.0

    local a = JR1TLA_1A_INV or JR1TLA_1A_NCD
    local b = JR1TLA_1B_INV or JR1TLA_1B_NCD
    local c = JR2TLA_2A_INV or JR2TLA_2A_NCD
    local d = JR2TLA_2B_INV or JR2TLA_2B_NCD
    local e = (not a) and pwrRev_th03
    local f = pwrRev_th04 and (not b)
    local g = (not c) and  pwrRev_th07
    local h = pwrRev_th08 and (not d)
    local i = e or f or JR1CMDREV_1A or JR1CMDREV_1B
    logic.pwrRev_conf01:update(i)
    local j = g or h or JR2CMDREV_2A or JR2CMDREV_2B
    logic.pwrRev_conf02:update(j)
    local k = i or logic.pwrRev_conf01.OUT
    local l = i and WRRT
    local m = j or logic.pwrRev_conf02.OUT
    local n = j and WRRT
    local o = JR1TOFF and (not k)
    local p = JR2TOFF and (not m)
    local q = pwrRev_th01 or o or pwrRev_th02
    local r = pwrRev_th05 or p or pwrRev_th06
    local s = q and WRRT
    local t = WRRT and r

	JR1TLFPWR	= s
	JR1TLREV	= l

	JR2TLFPWR	= t
	JR2TLREV	= n

end




function A333_fws.tla_idle()

	local tlaIDLE_th01 = JR1TLA_1A < 0.05
	local tlaIDLE_th02 = JR1TLA_1A > -0.05

	local tlaIDLE_th03 = JR1TLA_1B < 0.05
	local tlaIDLE_th04 = JR1TLA_1B > -0.05

	local tlaIDLE_th05 = JR2TLA_2A < 0.05
	local tlaIDLE_th06 = JR2TLA_2A > -0.05

	local tlaIDLE_th07 = JR2TLA_2B < 0.05
	local tlaIDLE_th08 = JR2TLA_2B > -0.05

    local a = JR1TLA_1A_VAL and tlaIDLE_th01 and tlaIDLE_th02
    local b = JR1TLA_1B_VAL and tlaIDLE_th03 and tlaIDLE_th04
    local c = JR2TLA_2A_VAL and tlaIDLE_th05 and tlaIDLE_th06
    local d = JR2TLA_2B_VAL and tlaIDLE_th07 and tlaIDLE_th08
    local e = a or b
    local f = c or d
    local g = e and f

	JR1TLAI 	= e
	JR2TLAI 	= f
	JR12IDLE	= g

end




function A333_fws.tla_sup_cl()

    local tlaSupClThreshold01 = JR1TLA_1A > 0.63334
    local tlaSupClThreshold02 = JR1TLA_1B > 0.63334
    local tlaSupClThreshold03 = JR2TLA_2A > 0.63334
    local tlaSupClThreshold04 = JR2TLA_2B > 0.63334

    local a = JR1TLA_1A_INV or JR1TLA_1A_NCD
    local b = JR1TLA_1B_INV or JR1TLA_1B_NCD
    local c = JR2TLA_2A_INV or JR2TLA_2A_NCD
    local d = JR2TLA_2B_INV or JR2TLA_2B_NCD
    local e = tlaSupClThreshold01 and (not a)
    local f = tlaSupClThreshold02 and (not b)
    local g = tlaSupClThreshold03 and (not c)
    local h = tlaSupClThreshold04 and (not d)
    local i = e or f
    local j = g or h
    local k = i and WRRT
    local l = j and WRRT

	JR1TLASCL	= k
	JR2TLASCL	= l

end




function A333_fws.tla_cl()

	local tlaMCL_th01 = JR1TLA_1A < 0.57667
	local tlaMCL_th02 = JR1TLA_1A > 0.48333

	local tlaMCL_th03 = JR1TLA_1B < 0.57667
	local tlaMCL_th04 = JR1TLA_1B > 0.48333

	local tlaMCL_th05 = JR2TLA_2A < 0.57667
	local tlaMCL_th06 = JR2TLA_2A > 0.48333

	local tlaMCL_th07 = JR2TLA_2B < 0.57667
	local tlaMCL_th08 = JR2TLA_2B > 0.48333


    local a = tlaMCL_th01 and JR1TLA_1A_VAL and tlaMCL_th02
    local b = JR1TLA_1A_VAL and tlaMCL_th02
    local c = tlaMCL_th03 and JR1TLA_1B_VAL and tlaMCL_th04
    local d = JR1TLA_1B_VAL and tlaMCL_th04
    local e = tlaMCL_th05 and JR2TLA_2A_VAL and tlaMCL_th06
    local f = JR2TLA_2A_VAL and tlaMCL_th06
    local g = tlaMCL_th07 and JR2TLA_2B_VAL and tlaMCL_th08
    local h = JR2TLA_2B_VAL and tlaMCL_th08
    local i = a or c
    local j = b or d
    local k = e or g
    local l = f or h
    local m = i and WRRT
    local n = j and l and WRRT
    local o = k and WRRT

	JR1TLACL	= m
	JR2TLACL	= o
	JR12MCL		= n

end




function A333_fws.eng1_or_2_to_pwr()

    local a = JR1FTOMD and JR1TLAMCT
    local b = JR1TLFPWR or JR2TLFPWR
    local c = JR2FTOMD and JR2TLAMCT
    local d = JR1TLAMCT and JR1DTOSEL
    local e = JR2TLAMCT and JR2DTOSEL
    local f = a or b or c or d or e
    logic.e1o2topwr_conf01:update(f)
    local g =  a or c or d or e
    local h = logic.e1o2topwr_conf01.OUT and (not ZH1500FT) and JR12MCL
    local i = f or h
    local j = i and WRRT
    local k = WRRT and g

	ZR1O2TOPWR	= 	j
	JRFLEX		= 	k

end




function A333_fws.eng_start_switch_delayed()

	logic.eng1MasterSwitch_conf01:update(JML1ON)
	logic.eng2MasterSwitch_conf01:update(JML2ON)

	JTML1ON = logic.eng1MasterSwitch_conf01.OUT
	JTML2ON = logic.eng2MasterSwitch_conf01.OUT

end




function A333_fws.def_speed()

	local spd_th01 = NCAS_1 > 83.0
	local spd_th02 = NCAS_1 < 77.0

	local spd_th03 = NCAS_2 > 83.0
	local spd_th04 = NCAS_2 < 77.0

	local spd_th05 = NCAS_3 > 83.0
	local spd_th06 = NCAS_3 < 77.0


    local a = NCAS_1_INV or NCAS_1_NCD
    local b = NCAS_2_INV or NCAS_2_NCD
    local c = NCAS_3_INV or NCAS_3_NCD
    local d = spd_th01 and (not a)
    local e = (not a) and spd_th02
    local f = spd_th03 and (not b)
    local g = (not b) and spd_th04
    local h = spd_th05 and (not c)
    local i = (not c) and spd_th06
    local j = a or f or h
    local k = e or g or i
    local l = a or b or c
    local m = j and l
    local spd_mt1 = bMT(1, d, h, f, m)
    local n =  l and k
    local spd_mt2 = bMT(1, n, g, e, i)
    local o = NCAS_1_FT or NCAS_2_FT or NCAS_3_FT
    logic.spd_mtrigF_01:update(o)
    logic.spd_mtrigF_02:update(o)
    local p = spd_mt2 or logic.spd_mtrigF_01.OUT
    logic.spd_srS01:update(spd_mt1, p)

	ZACS80KT	= logic.spd_srS01.Q
	ZADCTI		= logic.spd_mtrigF_02.OUT

end




function A333_fws.def_new_ground()

    local a = GLLGC_1 ~= GELLGCOMPR
    local b = GLLGC_1 and GELLGCOMPR
    local c = GLLGC_2 and GNLLGCOMPR
    local d = GLLGC_2 ~= GNLLGCOMPR
    logic.ng_conf01:update(a)
    logic.ng_conf02:update(not a)
    logic.ng_conf03:update(d)
    logic.ng_conf04:update(not d)
    local e	= b ~= c
    local f = GLLGC_1_NCD or GLLGC_1_INV or logic.ng_conf01.OUT
    local g = GLLGC_2_NCD or GLLGC_2_INV or logic.ng_conf03.OUT
    logic.ng_srS01:update(f, logic.ng_conf02.OUT)
    local h = b and (not e) and c
    logic.ng_srS02:update(g, logic.ng_conf04.OUT)
    local i = logic.ng_srS01.Q or logic.ng_srS02.Q

	ZNEWGND 	= h
	ZLG12INV	= i

end




function A333_fws.def_ground()

	local alt_th01 = NRADH_1 < 5.0
	local alt_th02 = NRADH_2 < 5.0
    
    local a = (not GNLLGCOMPR ) or (not GELLGCOMPR)
    logic.gr_srS01:update(alt_th01, a)
    logic.gr_srS02:update(alt_th02, a)
    local b = logic.gr_srS01.Q or alt_th01
    local c = alt_th02 or logic.gr_srS02.Q
    local d = b and (not NRADH_1_NCD) and (not NRADH_1_INV)
    local e = NRADH_1_INV or NRADH_2_INV
    local f	= (not NRADH_2_INV) and (not NRADH_2_NCD) and c
    local gr_mt1 = bMT(2, GELLGCOMPR, GNLLGCOMPR, f, d)
    local gr_mt2 = bMT(1, GELLGCOMPR, GNLLGCOMPR, d, f)
    local g = NRADH_1_NCD and NRADH_2_NCD and (not ZLG12INV)
    local h = gr_mt1 and (not e)
    local i = gr_mt2 and e
    local j = h or i
    logic.gr_mrTrigR_01:update(g)
    local k = logic.gr_mrTrigR_01.OUT and ZNEWGND
    local l = j or k
    logic.gr_conf01:update(l)

	ZGNDI 	= l
	ZGND 	= logic.gr_conf01.OUT

end




function A333_fws.excess_cabin_alt()

	local climbing = false
	if simDR_vvi_pilot > 250.0 then
		climbing = true
	end

	local descending = false
	if simDR_vvi_pilot < -250.0 then
		descending = true
	end

	local excessCabAlt = m.max(9550.0, simDR_cabin_altitude_actuator_ft + 1000.0)

	if ((climbing or descending) and simDR_cabin_altitude_indicator_ft > excessCabAlt)
		or
		((not climbing )and (not descending)) and simDR_cabin_altitude_indicator_ft > 9550.0
	then
		logic.CabAltExcessive = true
	else
		logic.CabAltExcessive = false
	end

	PEXCA_1 = logic.CabAltExcessive
	PEXCA_2 = logic.CabAltExcessive
	PEXCA_3 = logic.CabAltExcessive

end




function A333_fws.flight_phases()

    logic.fph_mTrigF_01:update(ZR1O2TOPWR)
    logic.fph_mTrigR_04:update(ZACS80KT)
    logic.fph_mTrigR_06:update(ZGNDI)
    logic.fph_mTrigR_09:update(ZGNDI)

    logic.fph_UE1FPBpulse01:update(UE1FPBOUT)
    local a = UE1FPBOUT and logic.fph_UE1FPBpulse01.OUT
    logic.fph_conf01:update(a)
    logic.fph_mTrigR_05:update(logic.fph_conf01.OUT)
    logic.fph_ZH800FTpulse01:update(ZH800FT)
    local b = ZH800FT and logic.fph_ZH800FTpulse01.out
    logic.fph_conf02:update(b)
    logic.fph_pulse01:update(logic.fph_conf02.OUT)
    local c = ZGND and logic.fph_mTrigF_02.OUT
    local d = ZGND and logic.fph_mTrigF_01.OUT
    local e = logic.fph_mTrigR_03.OUT or ZGNDI
    local f = ZGND and logic.fph_mTrigR_05.OUT
    local g = ZGND and ZR1O2TOPWR
    local h = c or f or d
    local i = (not ZH1500FT) and ZR1O2TOPWR and (not ZHFAIL) and (not e)
    logic.fph_mTrigR_07:update(i)
    local j = (not e) and (not ZHFAIL) and (not ZR1O2TOPWR) and (not ZH1500FT) and (not ZH800FT) and (not logic.fph_pulse01.OUT)
    logic.fph_mTrigR_08:update(j)
    local l = (not logic.fph_mTrigR_04.OUT) and h and ZGND
    local o = l or ZADCTI
    local p = ZGND and (not ZR1O2TOPWR) and (not ZACS80KT)
    local q = logic.fph_mTrigR_07.OUT and i
    local r = j and logic.fph_mTrigR_08.OUT
    local s = logic.fph_mTrigR_06.OUT or ZGNDI
    local v = s and (not ZR1O2TOPWR) and ZACS80KT
    local y = (not ZACS80KT) and ZR1O2RUN and g
    local n = y or v
    logic.fph_srS02:update(n, o)
    local w = ZOERG and logic.fph_srS02.Q and p
    logic.fph_mTrigF_02:update(w)
    logic.fph_srR01:update(w, f)
    local k = (not w) and ZR12NORUN and ZGNDI
    local m = logic.fph_srR01.Q and k
    logic.fph_mTrigR_03:update(m)
    local t = k and (not logic.fph_mTrigR_03.OUT)
    local u = logic.fph_mTrigR_03.OUT and k
    local x = p and (not logic.fph_srS02.Q) and ZR1O2RUN
    local z = ZACS80KT and g
    local aa = (not q) and (not e) and (not r)
    local bb = r and (not ZPH8)

    ZPH1	= t
    ZPH2	= x
    ZPH3	= y
    ZPH4	= z
    ZPH5	= q
    ZPH6	= aa
    ZPH8	= v
    ZPH7	= bb
    ZPH9	= w
    ZPH10	= u

	flight_phase_status[1] = bool2num[ZPH1]
	flight_phase_status[2] = bool2num[ZPH2]
	flight_phase_status[3] = bool2num[ZPH3]
	flight_phase_status[4] = bool2num[ZPH4]
	flight_phase_status[5] = bool2num[ZPH5]
	flight_phase_status[6] = bool2num[ZPH6]
	flight_phase_status[7] = bool2num[ZPH7]
	flight_phase_status[8] = bool2num[ZPH8]
	flight_phase_status[9] = bool2num[ZPH9]
	flight_phase_status[10] = bool2num[ZPH10]

	local trueCounter = 0
	for phaseNum = 1, 10 do
		if flight_phase_status[phaseNum] == 1 then
			trueCounter = trueCounter + 1
		end
	end

	FlightPhaseIsValid = trueCounter > 0

	if FlightPhaseIsValid then
		for fp = 1, 10 do
			if flight_phase_status[fp] == 1 then
				A333DR_flight_phase = fp
			end
		end
	else
		A333DR_flight_phase = 1
	end

	A333DR_fws_grnd_flt_trans = bool2num[i]

end

local function A333_ResetFlightPhase10()
	logic.fph_mTrigR_03:resetTimer()
	logic.fph_mTrigR_03.lastIN = false
end




function A333_fws.flight_phase_inhibit_ovrd()

	logic.fphIO_pulseF01:update(ZPH1)
	logic.fphIO_pulseF02:update(ZPH2)
	logic.fphIO_pulseF03:update(ZPH3)
	logic.fphIO_pulseF04:update(ZPH4)
	logic.fphIO_pulseF05:update(ZPH5)
	logic.fphIO_pulseF06:update(ZPH6)
	logic.fphIO_pulseF07:update(ZPH7)
	logic.fphIO_pulseF08:update(ZPH8)
	logic.fphIO_pulseF09:update(ZPH9)
	logic.fphIO_pulseF10:update(ZPH10)

    local a = logic.fphIO_pulseF01.OUT or logic.fphIO_pulseF02.OUT or logic.fphIO_pulseF03.OUT or logic.fphIO_pulseF04.OUT or logic.fphIO_pulseF05.OUT
    local b = logic.fphIO_pulseF06.OUT or logic.fphIO_pulseF07.OUT or logic.fphIO_pulseF08.OUT or logic.fphIO_pulseF09.OUT or logic.fphIO_pulseF10.OUT
    local c = a or b
    logic.fphIO_srR01:update(ZRCLUP, c)

	ZFPION = logic.fphIO_srR01.Q

end




function A333_fws.red_warning()

    local a = WSTO or WVMOMMO or WVLE or NVFE1 or NVFE2 or NVFE4
    local b = NVFE3 or NVFE5 or UE1FIRE or UE2FIRE or UAPUFIRE
    local c = a or b

	WRW = c
	WWRW = c

end




function A333_fws.ap_off_voluntary()

    local a = KAP1EC_1 and KAP1EM_1
    local b = KAP2EC_2 and KAP2EM_2
    local c = WCMWC or WFOMWC
    local d = a or b
    local e = c and (not WRW)
    local f = KID1APE or KID2APE
    logic.apOffVolMtrig01:update(KID1APE)
    logic.apOffVolMtrig02:update(KID2APE)
    local g = logic.apOffVolMtrig01.OUT or logic.apOffVolMtrig02.OUT
    logic.apOffVolPulse01:update(f)
    local h = e or logic.apOffVolPulse01.OUT
    logic.apOffVolConf01:update(not d)
    local i = logic.apOffVolConf01.OUT and h
    logic.apOffVolPulse02:update(d)
    local j = logic.apOffVolPulse02.OUT and g
    logic.apOffVolMtrig03:update(j)
    logic.apOffVolMtrig09:update(i)
    logic.apOffVolMtrig10:update(logic.apOffVolMtrig09.OUT)
    local k = logic.apOffVolMtrig03.OUT and (not d) and (not logic.apOffVolMtrig10.OUT)
    logic.apOffVolMtrig05:update(j)
    logic.apOffVolMtrig06:update(i)
    local l = logic.apOffVolMtrig05.OUT and (not d) and (not logic.apOffVolMtrig06.OUT)
    logic.apOffVolMtrig07:update(j)
    logic.apOffVolMtrig08:update(i)
    local m = logic.apOffVolMtrig07.OUT and (not d) and (not logic.apOffVolMtrig08.OUT)

	KAP1E = a
	KOAPE = d
	KAP2E = b
	KAPOA = k
	KAPOMW = l
	WAPOT = m

end




function A333_fws.nav_stall_warn()

    logic.stallConf01:update(WRCL)
    logic.stallPulse01:update(logic.stallConf01.OUT)
    logic.stallPulse02:update(NSTALL1)
    local a = (not logic.stallPulse01.OUT) and NSTALL1
    logic.stallPulse03:update(a)
    local b = WEMERC and logic.stallSRRlatch01.Q
    local c = logic.stallPulse02.OUT or b
    logic.stallSRRlatch01:update(logic.stallPulse03.OUT, c)

	NSTALLW	= logic.stallSRRlatch01.Q

end




function A333_fws.nav_stall_warning()

    local a = ZPH5 or ZPH6 or ZPH7
    local b = NATEST and ZGND
    local c = a or b
    local d = logic.stallWarn_pulse01.OUT or NSTALLW
    local e = d and c
    local f = e and WEMERC
    logic.stallWarn_pulse01:update(f)
    local g = e or WWINDSDON

	NSTALLWO	= e
	WBSTALL		= e
	WSTALL_S	= g
	WSTO		= g

	A333DR_fws_aco_stall = bool2num[e]

end




function A333_fws.auto_flight_low_energy()

    local a = (not KFACNOH_1) and KLONRJ_1
    local b = (not KFACNOH_2) and KLONRJ_2
    local c = ZPH5 or ZPH6 or ZPH7
    local d = a or b
    logic.lowEnergyMtrig01:update(d)
    logic.lowEnergyMtrig02:update(KSPEEDGEN)
    local e = d or logic.lowEnergyMtrig01.OUT
    local f = c and e and (not logic.lowEnergyMtrig02.OUT)
    local g = (not NGPWSINHIB) and f
    local h = f or logic.lowEnergyMtrig02.OUT

	NSPDO = h

	A333DR_fws_aco_speed = bool2num[g]

end




function A333_fws.dh_dt_positive()

    local a = NRADH_1_NCD or NRADH_1_INV
    logic.dh_dt_pos_s01:update(a, NRADH_1, NRADH_2)
    local meters = logic.dh_dt_pos_s01.out * 0.3048
    logic.dh_dt_pos_threshold01:update(meters)

	NDHPO 		= logic.dh_dt_pos_threshold01.out
	WDHDTPOS	= logic.dh_dt_pos_threshold01.out

end




function A333_fws.decision_height()

    decision_height_pilot = ((simDR_radio_altimeter_bug_ft_pilot > 0 and simDR_radio_altimeter_bug_ft_pilot) or (simDR_baro_alt_bug_ft_pilot > -1000.00 and simDR_baro_alt_bug_ft_pilot)) or 0.0
	decision_height_copilot = ((simDR_radio_altimeter_bug_ft_copilot > 0 and simDR_radio_altimeter_bug_ft_copilot) or (simDR_baro_alt_bug_ft_copilot > -1000.00 and simDR_baro_alt_bug_ft_copilot)) or 0.0

    WDH_1 = decision_height_pilot
	WDH_2 = decision_height_copilot

end




function A333_fws.decision_height_value()

    logic.decHeightVal_comp01:update(WDH_1, WDH_2)
    local a = NRADH_1_INV or NRADH_1_NCD
    local aa = NCBAC_1_INV or NCBAC_1_NCD
    local b = WDH_2_INV or WDH_2_NCD
    local c = WDH_1_INV or WDH_1_NCD
    logic.decHeightVal_s01:update(a, NRADH_2, NRADH_1)		-- Radio
    logic.decHeightVal_s02:update(aa, NFOBAC_2, NCBAC_1)	-- Baro
    local refHeightVal = (simDR_radio_altimeter_bug_ft_pilot > 0 and logic.decHeightVal_s01.out) or (simDR_baro_alt_bug_ft_pilot > -1000.00 and logic.decHeightVal_s02.out) or 0.0
    local d = WDH_1_VAL and (not WDH_1_NCD) and WDH_2_VAL and (not WDH_2_NCD) and logic.decHeightVal_comp01.out
    local e = b and c
    local f = d or WDH_1_NCD or WDH_1_INV
    logic.decHeightVal_s03:update(f, WDH_1, WDH_2)

	NRHV 		= refHeightVal
    WDH2SELEC	= f
    NDHV		= logic.decHeightVal_s03.out
	NDINV		= e

end




function A333_fws.hundred_above()

	logic.hundrdAbvNum_01:update(NDHV, 105)
	logic.hundrdAbvNum_02:update(NDHV, 115)
	logic.hundrdAbvComp01:update(NRHV, logic.hundrdAbvNum_01.out)
	logic.hundrdAbvComp02:update(NRHV, logic.hundrdAbvNum_02.out)

    local hundrdAbvThreshold_01 = NDHV < 90.0
    local hundrdAbvThreshold_02 = NDHV <= 3.0


    local a = NRADH_1_INV or NRADH_1_NCD
    local b = NRADH_2_INV or NRADH_2_NCD
    local c = WDH100A and WDH100B
    local d = hundrdAbvThreshold_01 and logic.hundrdAbvComp01.out
    local e = (not hundrdAbvThreshold_01) and logic.hundrdAbvComp02.out
    local f = a and b
    local g = d or e
    local h = hundrdAbvThreshold_02 or NACOINIB or NDINV or f
    logic.hundrdAbvConf01:update(g)
    logic.hundrdAbvMtrig01:update(logic.hundrdAbvConf01.OUT)
    logic.hundrdAbvSRRlatch01:update(NHUNABGEN, logic.hundrdAbvMtrig01.OUT)
    local i = (not logic.hundrdAbvSRRlatch01.Q) and logic.hundrdAbvMtrig01.OUT
    local j = i and c and not h
    local k = NHUNABGEN or j

	WHACOMP 		= logic.hundrdAbvSRRlatch01.Q
	NDHHABOVE 		= k
	WHAGENERATED	= j
	WHAMTRIG 		= logic.hundrdAbvMtrig01.OUT

	A333DR_fws_aco_hndrd_abv = bool2num[j]

end




function A333_fws.dh_minimum()

	logic.dhNum_01:update(NDHV, 5)
	logic.dhNum_02:update(NDHV, 15)
	logic.dhComp01:update(NRHV, logic.dhNum_01.out)
	logic.dhComp02:update(NRHV, logic.dhNum_02.out)

    local dhThreshold01 = NDHV < 90.0
    local dhThreshold02 = NDHV <= 3.0

    local a = NRADH_1_INV or RADH_1_NCD
    local b = NRADH_2_INV or NRADH_2_NCD
    local c = WDHA and WDHB
    local d = dhThreshold01 and logic.dhComp01.out
    local e = (not dhThreshold01) and logic.dhComp02.out
    local f = a and b
    local g = d or e
    local h = dhThreshold02 or NACOINIB or NDINV or f
    logic.dhConf01:update(g)
    logic.dhTrig01:update(logic.dhConf01.OUT)
    logic.dhSRRlatch01:update(NMINGEN, logic.dhTrig01.OUT)
    local i = (not logic.dhSRRlatch01.Q) and logic.dhTrig01.OUT
    local j = i and c and (not h)
    local k = NDHHABOVE or NMINGEN or j

	WDHCOMP 		= logic.dhSRRlatch01.Q
	WDHGEN 			= k
	NDHGEN 			= k
	WDHGENERATED	= j
	WDHMTRIG 		= logic.dhTrig01.OUT
	WDHINF3FT 		= dhThreshold02

	A333DR_fws_aco_minimum = bool2num[j]

end




function A333_fws.n1_approach()

    local n1ApprThreshold01 = JR1N1_1A < 75.0
    local n1ApprThreshold02 = JR1N1_1B < 75.0
    local n1ApprThreshold03 = JR2N1_2A < 75.0
    local n1ApprThreshold04 = JR2N1_2B < 75.0
    local n1ApprThreshold05 = JR1N1_1A < 97.0
    local n1ApprThreshold06 = JR1N1_1B < 97.0
    local n1ApprThreshold07 = JR2N1_2A < 97.0
    local n1ApprThreshold08 = JR2N1_2B < 97.0


    local a = JR1N1_1A_VAL and n1ApprThreshold05
    local b = JR1N1_1B_VAL and n1ApprThreshold06
    local c = JR2N1_2A_VAL and n1ApprThreshold07
    local d = JR2N1_2B_VAL and n1ApprThreshold08
    local e = JR1N1_1A_VAL and n1ApprThreshold01
    local f = JR1N1_1B_VAL and n1ApprThreshold02
    local g = JR2N1_2A_VAL and n1ApprThreshold03
    local h = JR2N1_2B_VAL and n1ApprThreshold04
    local i = a or b
    local j = c or d
    local k = e or f
    local l = g or h
    local m = i and JML2OFF
    local n = j and JML1OFF
    local o = k and l
    local p = m or n
    local q = o or p

    JRN1AP = q

end




function A333_fws.rh_gear_extended()

	local a = (not GRGNOE_1) and (not GRGNOE_2)

	GRGE = a

end




function A333_fws.lh_gear_extended()

	local a = (not GLGNOE_1) and (not GLGNOE_2)

	GLGE = a

end




function A333_fws.gear_extended()

    local a = (not GNGNOE_1) and (not GNGNOE_2)
    local b = GLGE or a or GRGE

	GLGEXT = b

end




function A333_fws.gear_not_extended()

    local a = GLGNOE_1 and GLGNOE_2
    local b = GRGNOE_1 and GRGNOE_2
    local c = GNGNOE_1 and GNGNOE_2
    local d = a or b or c

	GLGNE = d

end





function A333_fws.lh_gear_locked_up()

	local a = (not GLGNLUP_1) and (not GLGNLUP_2)

	GLGLUP = a

end





function A333_fws.rh_gear_locked_up()

	local a = (not GRGNLUP_1) and (not GRGNLUP_2)

	GRGLUP = a

end




function A333_fws.gear_locked_up()

    local a = GNGNLUP_1 or GNGNLUP_2
    local b = GLGLUP and a and GRGLUP

	GGLUP = b

end




function A333_fws.gear_not_uplck_and_not_sel_dn()

    local a = GLGNLUPNSD_1 and GLGNLUPNSD_2
    local b = GRGNLUPNSD_1 and GRGNLUPNSD_2
    local c = GNGNLUPNSD_1 and GNGNLUPNSD_2
    local d = a or b or c

	GGNLUPANSD = d

end





function A333_fws.gear_downlocked()

    local a = GLGDL_1 and GLGDL_2
    local b = GRGDL_1 and GRGDL_2
    local c = GNGDL_1 and GNGDL_2
    local d = a and b and c

	GLGDNLKD = d

	A333DR_fws_landing_gear_down = bool2num[GLGDNLKD]

end





function A333_fws.gear_not_locked()

	local d =  GLLGNOLK or GRLGNOLK or GNLGNOLK

	GLGNLKD = d

end






function A333_fws.gear_not_dnlck_and_sel_dn()

    local a = GLGNLDSD_1 and GLGNLDSD_2
    local b = GRGNLDSD_1 and RGNLDSD_2
    local c = GNGNLDSD_1 and GNGNLDSD_2
    local d = a or b or c

	GLGNLDSD = d

end




function A333_fws.hyd_abnorm_lo_pr()

    local aa = ZPH1 or ZPH2 or ZPH9 or ZPH10
    local a = (not JR1NORUN) or (not JR2NORUN)
    local b = JR2NORUN and (not ZGND) and JR1NORUN
    local c = (not JR2NORUN) or (not aa)
    local d = (not JR1NORUN) or (not aa)
    logic.hydLoPrConf01:update(a)
    logic.hydLoPrConf02:update(b)
    logic.hydLoPrConf03:update(c)
    logic.hydLoPrConf04:update(d)
    local e = logic.hydLoPrConf01.OUT or logic.hydLoPrConf02.OUT
    local f = HYSLP and logic.hydLoPrConf03.OUT
    local g = HGSLP and logic.hydLoPrConf04.OUT
    local h = HBSLP and e
    local i = h and f
    local j = h and g
    local k = f and g
    local l = j or i
    local m = i or k
    local n = j or k

	HBSYSLP	= h
	WWBHLP	= h
	HYSYSLP	= f
	WWYHLP	= f
	HGSYSLP	= g
	WWGHLP	= g
	HBDF	= l
	HYDF	= m
	HGDF	= n

end




function A333_fws.hyd_not_recovered()

    local b = HBSYSLP or HYSYSLP or HGSYSLP
    local c = HBSYSLP and HGSYSLP and (not SSLTSA)
    local d = HYSYSLP and HGSYSLP and (not SFLPSE) and (not NGPWSFMOF) and (not EEMER)
    local hydNotRecMT01 = bMT(2, HGSYSLP, HYSYSLP, HBSYSLP, b)

	HTHOUT		= hydNotRecMT01
	HGBLP		= c
	HGPWSFOP	= d

end




function A333_fws.oil_temp_advisory()

    local a = JR1OT_INV or JR1OT_NCD
    local b = JR1OTAD_1_INV or JR1OTAD_1_NCD
    local c = JR2OT_INV or JR2OT_NCD
    local d = JR2OTAD_2_INV or JR2OTAD_2_NCD
    logic.oilTempAdvSwitcg01:update(b, JR1OTAD_1, JR1OTAD_2)
    logic.oilTempAdvSwitcg02:update(d, JR2OTAD_2, JR2OTAD_1)
    logic.oilTempAdvComp01:update(JR1OT, logic.oilTempAdvSwitcg01.out)
    logic.oilTempAdvComp02:update(JR2OT, logic.oilTempAdvSwitcg02.out)
    local e = JR1OTAD_2_INV or JR1OTAD_2_NCD
    local f = JR2OTAD_1_INV or JR2OTAD_1_NCD
    local g = b and e
    local h = d and f
    local i = (not a) and logic.oilTempAdvComp01.out and (not g) and WRRT
    local j = WRRT and (not c) and logic.oilTempAdvComp02.out and (not h)

	JR1OTAD = i
	JR2OTAD	= j

end




function A333_fws.oil_overtemp()

    local a = JR1OT_INV or JR1OT_NCD
    local b = JR1OOT_1_INV or JR1OOT_1_NCD
    local c = JR2OT_INV or JR2OT_NCD
    local d = JR2OOT_2_INV or JR2OOT_2_NCD
    logic.oilOvertempSwitch01:update(b, JR1OOT_1, JR1OOT_2)
    logic.oilOvertempSwitch02:update(d, JR2OOT_2, JR2OOT_1)
    logic.oilOvertempComp01:update(JR1OT, logic.oilOvertempSwitch01.out)
    logic.oilOvertempComp02:update(JR2OT, logic.oilOvertempSwitch02.out)
    local e = JR1OOT_2_INV or JR1OOT_2_NCD
    local f = JR2OOT_1_INV or JR2OOT_1_NCD
    local g = b and e
    local h = d and f
    local i = (not a) and logic.oilOvertempComp01.out and (not g) and WRRT
    local j = WRRT and (not c) and logic.oilOvertempComp02.out and (not h)

	JR1OOT = i
	JR2OOT = j

end




function A333_fws.engines_out()

	logic.engOutpulse01:update(UE2FPBOUT)
	local a = UE2FPBOUT and logic.engOutpulse01.OUT
	logic.engOutConf02:update(a)
	local b = (not JR1AIDLE_1A) and (not JR1AIDLE_1B)
	local c = (not JR2AIDLE_2A) and (not JR2AIDLE_2B)
	local d = b and c
	logic.engOutConf01:update(d)
	local e = JML1OFF and (not JML1ON) and JML1ON_VAL and JML2OFF and (notJML2ON) and JML2OFF
	local f = UE1FPBOUT and UE2FPBOUT
	local g = logic.engOutConf01.OUT or e or f
	local h = (not ZGND) and g and not(logic.engOutConf02.OUT) and WRRT

    JENGSOUTR = h

end




function A333_fws.gen_reset()

    logic.genResetPulse01:update(EGN1PBOF)
    logic.genResetPulse02:update(EGN2PBOF)
    logic.genResetPulse03:update(EGN1PBOF)
    logic.genResetPulse04:update(EGN2PBOF)

    local a = logic.genResetPulse01.OUT and EEMER and EBTIEPBOF
    local b = EBTIEPBOF and EEMER and logic.genResetPulse02.OUT
    local c = EEMER and logic.genResetPulse03.OUT
    local d = EEMER and logic.genResetPulse04.OUT
    logic.genResetSRR01:update(a, EEMER)
    logic.genResetSRR02:update(b, EEMER)
    logic.genResetSRR03:update(c, EEMER)
    logic.genResetSRR04:update(d, EEMER)
    local e = logic.genResetSRR01.Q and logic.genResetSRR02.Q
    local f = logic.genResetPulse03.OUT and logic.genResetPulse04.OUT

    EGENRESET	= (not e)
    EGEN12R		= (not f)

end




function A333_fws.signs_on()

    local a = CNOSMOK and CFSBLT and XCNOPEDINS

    CSIGNSONP = a

end




function A333_fws.rudder_trim_pos()

    local rudTrimThreshold01 = KRTP_1 > 3.6
    local rudTrimThreshold02 = KRTP_1 < -3.6
    local rudTrimThreshold03 = KRTP_2 > 3.6
    local rudTrimThreshold04 = KRTP_2 < -3.6

    local a = KRTP_1_INV or KRTP_1_NCD or KFACNOH_1
    local b = KRTP_2_INV or KRTP_2_NCD or KFACNOH_2
    local c = rudTrimThreshold01 and (not a)
    local d = (not a )and rudTrimThreshold02
    local e = rudTrimThreshold03 and (not b)
    local f = (not b) and rudTrimThreshold04
    local g = c or d
    local h = e or f
    local i = g or h

    SRUDTC = i

end




function A333_fws.elevator_trim_pos()

    local elevTrimThreshold01 = STAB1POS_1 > 6.42
    local elevTrimThreshold02 = STAB1POS_1 < -1.0
    local elevTrimThreshold03 = STAB1POS_2 > 6.42
    local elevTrimThreshold04 = STAB1POS_2 < -1.0

    local a = STAB1POS_1_INV or STAB1POS_1_NCD
    local b = STAB1POS_2_INV or STAB1POS_2_NCD
    local c = elevTrimThreshold01 and (not a)
    local d = (not a) and elevTrimThreshold02
    local e = elevTrimThreshold03 and (not b)
    local f = (not b) and elevTrimThreshold04
    local g = c or d
    local h = e or f
    local i = g or h
    local j = WRRT and i

    SPCT1A330 = j
    SPCT2A330 = j

end




function A333_fws.one_door_not_closed()

    local a = DLFCDNC or DRFCDNC or DLMCDNC or DRMCDNC or DLEEDNC or DREEDNC or DLACDNC or DRACDNC
    local b =  a and not EDC1OF
    local c = b or DAVCDNC

    DODNC = c

end




function A333_fws.config_test_normal()

    local a = (not GBRKOVHT) and (not SRUDTNTO) and (not SSLTNTO) and (not SFLPNTO) and (not SPTNTO) and (not SSBNTO) and (not DODNC) and (not SSTTO)
    logic.cfgTstNmlConf01:update(a)
    local b = CCR1 or CCR2

    WCABR = b
    WCABNR = (not b)
    WTOCNORM = logic.cfgTstNmlConf01.OUT

end




function A333_fws.speed_brake_logic()

    local a = JR1MINPWR_1A_VAL and (not JR1MINPWR_1A)
    local b = JR1MINPWR_1B_VAL and (not JR1MINPWR_1B)
    local c = JR2MINPWR_2A_VAL and (not JR2MINPWR_2A)
    local d = JR2MINPWR_2B_VAL and (not JR2MINPWR_2B)
    local e = ZPH6 or ZPH7
    local f = SSPBR_1 or SSPBR_2
    logic.cfgTstNmlConf03:update(f)
    local g = a or b
    local h = c or d
    local i = (not JR1NORUN) and g
    local j = h and (not JR2NORUN)
    local k = i or j
    local l = k and WRRT
    local o = logic.cfgTstNmlConf03.OUT and (not l)
    logic.cfgTstNmlConf01:update(o)
    local m = e and logic.cfgTstNmlConf03.OUT and (not logic.cfgTstNmlConf01.OUT)
    local n = not e or m
    logic.cfgTstNmlConf02:update(m)

    SASPDBRK = np
    SSPDBRKC = logic.cfgTstNmlConf02.OUT

end




function A333_fws.irs_in_align1()

    local adirs1_align_time = A333DR_adirs1_align_time
    NTUNIRSB28_1 = adirs1_align_time[0] == 1
    NTUNIRSB27_1 = adirs1_align_time[1] == 1
    NTUNIRSB26_1 = adirs1_align_time[2] == 1

    Z710NAVL	= NTUNIRSB26_1 and NTUNIRSB27_1 and NTUNIRSB28_1
    Z6NAVL 		= (not NTUNIRSB26_1) and NTUNIRSB27_1 and NTUNIRSB28_1
    Z5NAVL 		= NTUNIRSB26_1 and (not NTUNIRSB27_1) and NTUNIRSB28_1
    Z4NAVL 		= (not NTUNIRSB26_1) and (not NTUNIRSB27_1) and NTUNIRSB28_1
    Z3NAVL 		= NTUNIRSB26_1 and NTUNIRSB27_1 and (not NTUNIRSB28_1)
    Z2NAVL 		= (not NTUNIRSB26_1) and NTUNIRSB27_1 and (not NTUNIRSB28_1)
    Z1NAVL 		= NTUNIRSB26_1 and (not NTUNIRSB27_1) and (not NTUNIRSB28_1)
    ZNAVL  		= (not NTUNIRSB26_1) and (not NTUNIRSB27_1) and (not NTUNIRSB28_1)

end




function A333_fws.irs_in_align2()

    local adirs2_align_time = A333DR_adirs2_align_time
    NTUNIRSB28_2 = adirs2_align_time[0] == 1
    NTUNIRSB27_2 = adirs2_align_time[1] == 1
    NTUNIRSB26_2 = adirs2_align_time[2] == 1

    Z710NAVR	= NTUNIRSB26_2 and NTUNIRSB27_2 and NTUNIRSB28_2
    Z6NAVR 		= (not NTUNIRSB26_2) and NTUNIRSB27_2 and NTUNIRSB28_2
    Z5NAVR 		= NTUNIRSB26_2 and (not NTUNIRSB27_2) and NTUNIRSB28_2
    Z4NAVR 		= (not NTUNIRSB26_2) and (not NTUNIRSB27_2) and NTUNIRSB28_2
    Z3NAVR 		= NTUNIRSB26_2 and NTUNIRSB27_2 and (not NTUNIRSB28_2)
    Z2NAVR 		= (not NTUNIRSB26_2) and NTUNIRSB27_2 and (not NTUNIRSB28_2)
    Z1NAVR 		= NTUNIRSB26_2 and (not NTUNIRSB27_2) and (not NTUNIRSB28_2)
    ZNAVR  		= (not NTUNIRSB26_2) and (not NTUNIRSB27_2) and (not NTUNIRSB28_2)

end




function A333_fws.irs_in_align4()

    Z7 		= Z710NAVL or Z710NAVR
    Z6 		= (Z6NAVL or Z6NAVR) and (not Z7)
    Z5 		= (Z5NAVL or Z5NAVR) and (not Z7) and (not Z6)
    Z4 		= (Z4NAVL or Z4NAVR) and (not Z7) and (not Z6) and (not Z5)
    Z3 		= (Z3NAVL or Z3NAVR) and (not Z7) and (not Z6) and (not Z5) and (not Z4)
    Z2 		= (Z2NAVL or Z2NAVR) and (not Z7) and (not Z6) and (not Z5) and (not Z4) and (not Z3)
    Z1 		= (Z1NAVL or Z1NAVR) and (not Z7) and (not Z6) and (not Z5) and (not Z4) and (not Z3) and (not Z2)
    ZNAV	= (Z1NAVL or Z1NAVR) and (not Z7) and (not Z6) and (not Z5) and (not Z4) and (not Z3) and (not Z2) and (not Z1)

end




function A333_fws.cabin_ready()

    local a = ZPH10 or DODNC

    if ap then
        CCR1 = false
        CCR2 = false
    else
        CCR1 = true
        CCR2 = true
    end

end




function A333_fws.eng1_reverse_unstowed()

    local a =  JR1REVUNL_1A or JR1REVUNL_1B
    local b = JR1REVD_1A or JR1REVD_1B
    local c = a and not EDC1OF
    local d = c or b
    local e = d and WRRT

    JR1RUSTWD = e

end




function A333_fws.eng2_reverse_unstowed()

    local a = JR2REVUNL_2A or JR2REVUNL_2B
    local b = JR2REVD_2A or JR2REVD_2B
    local c = a and (not EDC2OF)
    local d = c or b
    local e = d and WRRT

    JR2RUSTWD = e

end




function A333_fws.bleed_not_avail()

    local a = BE1PRVACC_1 or BE1PRVACC_2
    local b = BE1BPBOF_1 or BE1BPBOF_2
    local c = BE2PRVACC_1 or BE2PRVACC_2
    local d = BE2BPBOF_1 or BE2BPBOF_2
    local e = a or b or JR1NORUN
    local f = c or d or JR2NORUN
    local g = e or f

    BB1NA = e
    BB2NA = f
    BBNA = g

end




function A333_fws.LorR_air_bleed_avail()

    local a = BAPUBPBOF_1_VAL and (not BAPUBPBOF_1)
    local b = (not BAPUBPBOF_2) and BAPUBPBOF_2_VAL
    local c = BXFVFO_1 or BXFVFO_2
    local d = a or b
    local e = QAVAIL and d
    local f = c and (not BB2NA)
    local g = (not BB1NA) or e or f
    local h = (not BB1NA) or e
    local i = h and c
    local j = i or (not BB2NA)
    local k = g and (not ep)
    local l = not e and j

    AB1AVAIL = g
    AB1WAIAV = k
    AB2AVAIL = j
    AB2WAIAV = l

end




function A333_fws.ai_aft_EngShutdown_proc()

    local a = (not ZGND) and IWAIPBON
    logic.procAftEngShutDwnPulse01:update(a)
    local b = JR1SD ~= R2SD
    local c = UE1FPBOUT or UE2FPBOUT
    local d = BXFVFC_1 and (not BXFVFC_1_INV)
    local e = BXFVFC_2 and (not BXFVFC_2_INV)
    local f = d or e
    local g = logic.procAftEngShutDwnPulse01.OUT and b and (not c) and f
    logic.procAftEngShutDwnPulse02:update(ZPH1)
    local h = (not f) or (not IWAION) or logic.procAftEngShutDwnPulse02.OUT
    logic.procAftEngShutDwnSRR01:update(g, h)
    logic.procAftEngShutDwnConf01:update(logic.procAftEngShutDwnSRR01.Q)

    IPROCWAIESD = logic.procAftEngShutDwnConf01.OUT

end




function A333_fws.ai_vlv_closed_fault_R()

    logic.aiRvlvClsdFltConf02:update(ZPH1)
    logic.aiRvlvClsdFltConf03:update(IWAIPBON)
    local a = (not ZGND) and IWAIPBON
    local b = ZGND and (not logic.aiRvlvClsdFltConf03.OUT)
    local c = a or b
    local d = IRWAILP or IRWAIVC
    local e = c and IWAIPBON and d and AB2AVAIL
    logic.aiRvlvClsdFltConf01:update(e)
    local f = not IRWAIVC and AB2AVAIL and IWAION
    local g = f or logic.aiRvlvClsdFltConf02.OUT
    logic.aiRvlvClsdFltsrS01:update(logic.aiRvlvClsdFltConf01.OUT, g)

    IRVCLSDF = logic.aiRvlvClsdFltsrS01.Q

end




function A333_fws.xbleed_vlv_locked_open()

    local a = BXFVCAD_1 or BXFVCAD_2
    local b = BXFVCMD_1 or BXFVCMD_2
    local c = a and (not EDC2OF)
    local d = c or b

    BXFVCD = d

end




function A333_fws.bleed_avoid_icing()

    logic.avoidIcingConf01:update(IXBAIC)
    logic.avoidIcingMTrig01:update(IWAION)
    logic.avoidIcingPulse01:update(ZPH1)
    local a = BE1LOTEMP_1 or BE1LOTEMP_2
    logic.avoidIcingConf03:update(a)
    local b = BE2LOTEMP_1 or BE2LOTEMP_2
    logic.avoidIcingConf04:update(b)
    local c = BLWL or BRWL or BRPL or BLPL
    logic.avoidIcingConf02:update(c)
    local d = logic.avoidIcingConf04.OUT and logic.avoidIcingConf03.OUT and (not ZGND)
    local e = (not ZGND) and logic.avoidIcingConf03.OUT and logic.avoidIcingMTrig01.OUT
    local f = (not ZGND) and logic.avoidIcingMTrig01.OUT and logic.avoidIcingConf04.OUT
    local g = not logic.avoidIcingConf04.OUT or AB1WAIAV or logic.avoidIcingPulse01.OUT
    logic.avoidIcingSRR02:update(f, g)
    local h = not logic.avoidIcingConf03.OUT or AB2WAIAV or logic.avoidIcingPulse01.OUT
    logic.avoidIcingSRR01:update(e, h)
    local i = logic.avoidIcingConf01.OUT or logic.avoidIcingConf02.OUT or d or logic.avoidIcingSRR01.Q or logic.avoidIcingSRR02.Q

    BBAIC = ip

end




function A333_fws.wai_avoid_icing()

    local a = IRVCLSDF or ILVCLSDF

    IWAIAIC = a

end




function A333_fws.wai_etops_power_supply()

    local a = EDC1OF and (not WMBE)
    local b = WMBE and EDCBSSCOF
    local c = a or b

    IWAIE = c

end




function A333_fws.status_computed()

    for _, msg in pairs(A333_sts_msg) do
        ZLSTSC = msg.Type == 0 and msg.Video.IN == 1
        ZAPSTSC = msg.Type == 1 and msg.Video.IN == 1
        ZPSTSC = msg.Type == 2 and msg.Video.IN == 1
        ZISTSC = msg.Type == 3 and msg.Video.IN == 1
        ZISSTSC = msg.Type == 5 and msg.Video.IN == 1
    end

end




function A333_fws.status_auto_call_approach()

    local a = ZPH6 or ZPH7
    local b = (not SS0F0_1_INV) and (not SS00F00_1)
    logic.stsAutoCallPulse01:update(b)
    local c = (not SS0F0_2_INV) and (not SS00F00_2)
    logic.stsAutoCallPulse02:update(c)
    local d = ZLSTSC or ZAPSTSC or ZPSTSC or ZSTSOEBPC or ZISTSC or ZISSTSC
    local e = logic.stsAutoCallPulse01.OUT or logic.stsAutoCallPulse02.OUT
    local f = e and d and a
    local g =  f and (not ZSINGDIS)
    local h = f and ZSINGDIS
    logic.stsAutoCallSRR01:update(h, ZSTSPD)

    ZSTSCAPPR = g
    ZSTSRPSD = logic.stsAutoCallSRR01.Q

end




function A333_fws.status_reminders()

    local a = ZPH2 or ZPH1
    local b = ZCCSTSC and a
    local c = ZPH1 and ZMSTSC
    local d = ZPH10 and ZMSTSC
    local e = ZSTSOEBPC or ZLSTSC or ZAPSTSC or ZPSTSC
    local f = ZISTSC or ZISSTSC or b or d or c
    local g = d or ZSTSRPSD
    local h =  ZCMEMD or ZLMEMD
    local i = e or f
    local j = (not ZSTSPD) and h and ZRMEMD
    local k = i and (not g) and j
    local l = j and i and g
    local m = k or l

    ZSTSREMS = k
    ZNOSTSREM = (not m)
    ZSTSREMP = l

    A333DR_ecam_ewd_show_sts = bool2num[ZSTSREMS]

end




function A333_fws.clear_status()

    logic.clearStsConf01:update(GLGDNLKD)
    logic.clearStsPulse01:update(logic.clearStsConf01.OUT)
    local a = logic.clearStsPulse01.OUT and (not ZMSTSPD)

    ZFCLRSTS = a

end




function A333_fws.sys_page_call_inhib()

    local sysPgCallInhibFT01 = NRADH_1 < 3000.0
    local sysPgCallInhibFT02 = NRADH_2 < 3000.0
    local a = (not NRADH_1_INV) and sysPgCallInhibFT01 and (not NRADH_1_NCD)
    local b = (not NRADH_2_INV) and sysPgCallInhibFT02 and (not NRADH_2_NCD)
    local c = ZLSTSC or ZAPSTSC or ZPSTSC
    local d = ZPH6 or ZPH7 or ZPH8 or ZPH9
    local e = a or b
    local f = e and c and ZSTSPD and d
    local g = f or JR1START or JR2START

    ZSYSPCI = g

end




function A333_fws.memo_msg_displayed()

    for _, msg in pairs(A333_ewd_msg) do
        ZCMEMD = msg.Zone == 0 and msg.Monitor.video.OUT == 1 and msg.FailType == 5
        ZLMEMD = msg.Zone == 0 and msg.Monitor.video.OUT == 1 and msg.FailType == 6
        ZRMEMD = msg.Zone == 1 and msg.Monitor.video.OUT == 1 and msg.FailType == 6
    end

end




function A333_fws.dmc_alt_select_L()

    local a = KFCU1H and NBRQ20_1 and NBRQ20_1_NO
    local b = KFCU1H and NBRQ21_1 and NBRQ21_1_NO
    local c = (not a) and b
    local d = a and (not b)
    local e = (not b) and (not a) and KFCU1H and NBRQ20_1_VAL and (not NBRQ21_1_NCD)

    NBAROSEL1 = a
    NDMCLQNH = c
    NDMCLS = d
    NBAROSEL3 = b
    NDMCLQFE = e

end




function A333_fws.dmc_alt_select_R()

    local a = KFCU2H and NBRQ20_2
    local b = KFCU1H and NBRQ21_2
    local c = (not a) and b
    local d = a and (not b)
    local e = (not b) and (not a) and KFCU2H and NBRQ21_2_VAL and (not NBRQ21_2_NCD)

    NBAROSELR = a
    NDMCRQNH = c
    NDMCRS = d
    NBAROSEL4 = b
    NDMCRQFE = e

end




function A333_fws.baro_alti_comp()

    local a = NALTFBK_1_INV and NALTFBK_1_NCD
    local b = NALTFBK_2_INV and NALTFBK_2_NCD
    local c = NDMCLQNH and NDMCRQNH
    local d = NDMCLQFE and NDMCRQFE
    local e = NFOBAC_2_INV or NFOBAC_2_NCD or a
    local f = NCBAC_1_INV or NCBAC_1_NCD or b
    local g = c or d
    local altitide_delta_capt = NALTFBK_2 - NCBAC_1
    local altitide_delta_fo = NALTFBK_1 - NFOBAC_2
    logic.baroAltFO:update(altitide_delta_fo)
    logic.baroAltCAPT:update(altitide_delta_capt)
    local h = (not logic.baroAltFO.output) and (not e)
    local i = (not logic.baroAltCAPT.output) and (not f)
    local j = h and g
    local k = i and g
    local l = j or k

    NALTBD = l

end




function A333_fws.std_alti_comp()

    local a = NALTFBK_1_INV or NALTFBK_1_NCD
    local b = NALTFBK_2_INV or NALTFBK_2_NCD
    local c = NALTI_2_INV or NALTI_2_NCD or a
    local d = NALTI_1_INV or NALTI_1_NCD or b
    local altitide_delta_capt = NALTFBK_2 - NALTI_1
    local altitide_delta_fo = NALTFBK_1 - NALTI_2
    logic.AltFO:update(altitide_delta_fo)
    logic.AltCAPT:update(altitide_delta_capt)
    local e = (not logic.AltFO.output) and (not c)
    local f = (not logic.AltCAPT.output) and (not d)
    local g = NDMCRS and e and NDMCLS
    local h = NDMCRS and f and NDMCLS
    local i = g or h

    NALTSTDD = i

end






--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_210_init_CD()

end

function A333_fws_210_init_ER()

    A333_fws.eng1_or_2_norun_ER()
    A333_fws.eng1_or_2_run_ER()
    logic.eng1MasterSwitch_conf01.OUT = true
    logic.eng2MasterSwitch_conf01.OUT = true

end

function A333_fws_210_aircraft_load()

    A333_ResetFlightPhase10()

end

function A333_fws_210_flight_start()

    A333_ResetFlightPhase10()
    logic.fph_srS02:reset()


end

function A333_fws_210()

    A333_fws.ac1_power_is_lost()
    A333_fws.ac2_power_is_lost()
    A333_fws.ac_ess_power_is_lost()
    A333_fws.dc1_power_is_lost()
    A333_fws.dc2_power_is_lost()
    A333_fws.dc_ess_power_is_lost()

    A333_fws.nav_vfe_speed()

    A333_fws.flap_deg_syn()
    A333_fws.sflpia()
    A333_fws.sflpsb()
    A333_fws.sflpsc()
    A333_fws.sflpsd()
    A333_fws.sflpse()
    A333_fws.sflpsf()

    A333_fws.slat_deg_syn()
    A333_fws.ssltsa()
    A333_fws.nsltib()
    A333_fws.ssltsc()
    A333_fws.ssltid()
    A333_fws.ssltie()
    A333_fws.ssltsf()
    A333_fws.ssltsg()

    A333_fws.sflpdsltc()

    A333_fws.def_alt()
    A333_fws.def_new_ground()
    A333_fws.def_ground()
    A333_fws.excess_cabin_alt()
    A333_fws.def_speed()
    A333_fws.dto_installed()
    A333_fws.dto_sel()
    A333_fws.fto_mode()

    A333_fws.eng1_or_2_norun()
    A333_fws.eng1_and_2_norun()
    A333_fws.eng1_or_2_run()

    A333_fws.eng1_or_2_to_pwr()
    A333_fws.eng_start_switch_delayed()
    A333_fws.takeoff()
    A333_fws.tla_pwr_rev()
    A333_fws.tla_idle()
    A333_fws.tla_sup_cl()
    A333_fws.tla_cl()
    A333_fws.tla_mct_flex()
    A333_fws.flight_phases()
    A333_fws.flight_phase_inhibit_ovrd()
    A333_fws.red_warning()
    A333_fws.ap_off_voluntary()
    A333_fws.nav_stall_warn()
    A333_fws.nav_stall_warning()
    A333_fws.auto_flight_low_energy()
    A333_fws.dh_dt_positive()
    A333_fws.decision_height()
    A333_fws.decision_height_value()
    A333_fws.hundred_above()
    A333_fws.dh_minimum()
    A333_fws.rh_gear_extended()
    A333_fws.lh_gear_extended()
    A333_fws.gear_extended()
    A333_fws.gear_not_extended()
    A333_fws.lh_gear_locked_up()
    A333_fws.rh_gear_locked_up()
    A333_fws.gear_locked_up()
    A333_fws.gear_not_uplck_and_not_sel_dn()
    A333_fws.gear_downlocked()
    A333_fws.gear_not_locked()
    A333_fws.gear_not_dnlck_and_sel_dn()
    A333_fws.hyd_abnorm_lo_pr()
    A333_fws.hyd_not_recovered()
    A333_fws.oil_temp_advisory()
    A333_fws.oil_overtemp()
    A333_fws.engines_out()
    A333_fws.gen_reset()
    A333_fws.signs_on()
    A333_fws.rudder_trim_pos()
    A333_fws.elevator_trim_pos()
    A333_fws.one_door_not_closed()
    A333_fws.config_test_normal()
    A333_fws.speed_brake_logic()
    A333_fws.irs_in_align1()
    A333_fws.irs_in_align2()
    A333_fws.irs_in_align4()
    A333_fws.cabin_ready()
    A333_fws.eng1_reverse_unstowed()
    A333_fws.eng2_reverse_unstowed()
    A333_fws.bleed_not_avail()
    A333_fws.LorR_air_bleed_avail()
    A333_fws.ai_aft_EngShutdown_proc()
    A333_fws.ai_vlv_closed_fault_R()
    A333_fws.xbleed_vlv_locked_open()
    A333_fws.bleed_avoid_icing()
    A333_fws.wai_avoid_icing()
    A333_fws.wai_etops_power_supply()
    A333_fws.status_computed()
    A333_fws.status_auto_call_approach()
    A333_fws.status_reminders()
    A333_fws.clear_status()
    A333_fws.sys_page_call_inhib()
    A333_fws.memo_msg_displayed()

    A333_fws.dmc_alt_select_L()
    A333_fws.dmc_alt_select_R()
    A333_fws.baro_alti_comp()
    A333_fws.std_alti_comp()
	A333_fws.tr_mode_selected()

end

function A333_fws_210_deferred() end





--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")








