jit.off()
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
*       					     COPYRIGHT © 2021, 2022
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

logic.TLAMCTorFlex01 = newThreshold('TLAMCTorFlex01', '<', 0.7913)
logic.TLAMCTorFlex02 = newThreshold('TLAMCTorFlex02', '>', 0.7287)
logic.TLAMCTorFlex03 = newThreshold('TLAMCTorFlex03', '<', 0.7913)
logic.TLAMCTorFlex04 = newThreshold('TLAMCTorFlex04', '>', 0.7287)
logic.TLAMCTorFlex05 = newThreshold('TLAMCTorFlex05', '<', 0.7913)
logic.TLAMCTorFlex06 = newThreshold('TLAMCTorFlex06', '>', 0.7287)
logic.TLAMCTorFlex07 = newThreshold('TLAMCTorFlex07', '<', 0.7913)
logic.TLAMCTorFlex08 = newThreshold('TLAMCTorFlex08', '>', 0.7287)

logic.pwrRev_conf01 = newFallingEdgeDelayedConfirmation('pwrRev_conf01', 10.0)
logic.pwrRev_conf02 = newFallingEdgeDelayedConfirmation('pwrRev_conf02', 10.0)
logic.pwrRev_th01 = newThreshold('pwrRev_th01', '>', 0.8012)
logic.pwrRev_th02 = newThreshold('pwrRev_th02', '>', 0.8012)
logic.pwrRev_th03 = newThreshold('pwrRev_th03', '<', 0.0) -- -0.09999)
logic.pwrRev_th04 = newThreshold('pwrRev_th04', '<', 0.0) -- -0.09999)
logic.pwrRev_th05 = newThreshold('pwrRev_th05', '>', 0.8012)
logic.pwrRev_th06 = newThreshold('pwrRev_th06', '>', 0.8012)
logic.pwrRev_th07 = newThreshold('pwrRev_th07', '<', 0.0) -- -0.09999)
logic.pwrRev_th08 = newThreshold('pwrRev_th08', '<', 0.0) -- -0.09999)

logic.tlaSupClThreshold01 = newThreshold('tlaSupClThreshold01', '>', 0.63334)
logic.tlaSupClThreshold02 = newThreshold('tlaSupClThreshold02', '>', 0.63334)
logic.tlaSupClThreshold03 = newThreshold('tlaSupClThreshold03', '>', 0.63334)
logic.tlaSupClThreshold04 = newThreshold('tlaSupClThreshold04', '>', 0.63334)

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


logic.fo_baro_alti_comp = newMarginSensor('fo_baro_alti_comp', ']', '[', -250.0, 250.0)
logic.capt_baro_alti_comp = newMarginSensor('capt_baro_alti_comp', ']', '[', -250.0, 250.0)
logic.fo_std_alti_comp = newMarginSensor('fo_std_alti_comp', ']', '[', -500.0, 500.0)
logic.capt_std_alti_comp = newMarginSensor('capt_std_alti_comp', ']', '[', -500.0, 500.0)

logic.dh_dt_pos_s01	= newAnalogSwitch2in1out('dh_dt_pos_s01')
logic.dh_dt_pos_threshold01 = newSlopeThreshold('dh_dt_pos_threshold01', '>', 0.0, 'meters/sec')

logic.decHeightVal_s01 = newAnalogSwitch2in1out('decHeightVal_s01')
logic.decHeightVal_s02 = newAnalogSwitch2in1out('decHeightVal_s02')
logic.decHeightVal_s03 = newAnalogSwitch2in1out('decHeightVal_s03')
logic.decHeightVal_comp01 = newComparison('decHeightVal_comp01', '>')

logic.hundrdAbvNum_01 = newNumerical('hundrdAbvNum_01', '+', '+')
logic.hundrdAbvNum_02 = newNumerical('hundrdAbvNum_02', '+', '+')
logic.hundrdAbvThreshold_01 = newThreshold('hunAbvThreshold_01', '<', 90.0 )
logic.hundrdAbvThreshold_02 = newThreshold('hundrdAbvThreshold_02', '<=', 3.0 )
logic.hundrdAbvComp01 = newComparison('hundrdAbvComp01', '<')
logic.hundrdAbvComp02 = newComparison('hundrdAbvComp02', '<')
logic.hundrdAbvConf01 = newLeadingEdgeDelayedConfirmation('hundrdAbvConf01', 0.1)
logic.hundrdAbvMtrig01 = newLeadingEdgeTrigger('hundrdAbvMtrig01', 3.0)
logic.hundrdAbvSRRlatch01 = newSRlatchResetPriority('hundrdAbvSRRlatch01')

logic.dhNum_01	= newNumerical('dhNum_01', '+', '+')
logic.dhNum_02	= newNumerical('dhNum_02', '+', '+')
logic.dhThreshold01 = newThreshold('dhThreshold01', '<', 90.0 )
logic.dhThreshold02 = newThreshold('dhThreshold02', '<=', 3.0 )
logic.dhComp01 = newComparison('dhComp01', '<')
logic.dhComp02 = newComparison('dhComp02', '<')
logic.dhConf01 = newLeadingEdgeDelayedConfirmation('dhConf01', 0.1)
logic.dhTrig01 = newLeadingEdgeTrigger('dhTrig01', 3.0)
logic.dhSRRlatch01 = newSRlatchResetPriority('dhSRRlatch01')

logic.n1ApprThreshold01 = newThreshold('n1ApprThreshold01', '<', 75.0)
logic.n1ApprThreshold02 = newThreshold('n1ApprThreshold02', '<', 75.0)
logic.n1ApprThreshold03 = newThreshold('n1ApprThreshold03', '<', 75.0)
logic.n1ApprThreshold04 = newThreshold('n1ApprThreshold04', '<', 75.0)
logic.n1ApprThreshold05 = newThreshold('n1ApprThreshold05', '<', 97.0)
logic.n1ApprThreshold06 = newThreshold('n1ApprThreshold06', '<', 97.0)
logic.n1ApprThreshold07 = newThreshold('n1ApprThreshold07', '<', 97.0)
logic.n1ApprThreshold08 = newThreshold('n1ApprThreshold08', '<', 97.0)

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

logic.rudTrimThreshold01 = newThreshold('rudTrimThreshold01', '>', 3.6)
logic.rudTrimThreshold02 = newThreshold('rudTrimThreshold01', '<', -3.6)
logic.rudTrimThreshold03 = newThreshold('rudTrimThreshold01', '>', 3.6)
logic.rudTrimThreshold04 = newThreshold('rudTrimThreshold04', '<', -3.6)


logic.elevTrimThreshold01 = newThreshold('elevTrimThreshold01', '>', 6.42)
logic.elevTrimThreshold02 = newThreshold('elevTrimThreshold02', '<', -1.0)
logic.elevTrimThreshold03 = newThreshold('elevTrimThreshold03', '>', 6.42)
logic.elevTrimThreshold04 = newThreshold('elevTrimThreshold04', '<', -1.0)

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

logic.sysPgCallInhibFT01 = newThreshold('sysPgCallInhibFT01', '<', 3000.0)
logic.sysPgCallInhibFT02 = newThreshold('sysPgCallInhibFT02', '<', 3000.0)

logic.clearStsConf01 = newLeadingEdgeDelayedConfirmation('clearStsConf01', 2.0)
logic.clearStsPulse01 = newLeadingEdgePulse('clearStsPulse01')

logic.climb = false
logic.descend = false
logic.CabAltExcessive = false

logic.eng1_flex_mode_is_available = true
logic.eng1_idle_mode_selected = false
logic.eng1_flex_mode_selected = false
logic.eng1_clb_mode_selected = false

logic.eng2_flex_mode_is_available = true
logic.eng2_idle_mode_selected = false
logic.eng2_flex_mode_selected = false
logic.eng2_clb_mode_selected = false




--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--
DR_running_time = find_dataref("sim/time/total_running_time_sec")


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

	local a = {E1 = NCAS_1_INV, E2 = NCAS_1_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = NCAS_2_INV, E2 = NCAS_2_NCD}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = NCAS_3_INV, E2 = NCAS_3_NCD}
	c.S = bOR(c.E1, c.E2)

	local g = {E1 = speedThr184_1, E2 = bNOT(a.S)}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = speedThr184_2, E2 = bNOT(b.S)}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = speedThr184_3, E2 = bNOT(c.S)}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = speedThr190_1, E2 = bNOT(a.S)}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = speedThr190_2, E2 = bNOT(b.S)}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = speedThr190_3, E2 = bNOT(c.S)}
	l.S = bAND(l.E1, l.E2)

	local m = {E1 = speedThr200_1, E2 = bNOT(a.S)}
	m.S = bAND(m.E1, m.E2)

	local n = {E1 = speedThr200_2, E2 = bNOT(b.S)}
	n.S = bAND(n.E1, n.E2)

	local o = {E1 = speedThr200_3, E2 = bNOT(c.S)}
	o.S = bAND(o.E1, o.E2)

	local p = {E1 = speedThr204_1, E2 = bNOT(a.S)}
	p.S = bAND(p.E1, p.E2)

	local q = {E1 = speedThr204_2, E2 = bNOT(b.S)}
	q.S = bAND(q.E1, q.E2)

	local r = {E1 = speedThr204_3, E2 = bNOT(c.S)}
	r.S = bAND(r.E1, r.E2)

	local s = {E1 = speedThr209_1, E2 = bNOT(a.S)}
	s.S = bAND(s.E1, s.E2)

	local t = {E1 = speedThr209_2, E2 = bNOT(b.S)}
	t.S = bAND(t.E1, t.E2)

	local u = {E1 = speedThr209_3, E2 = bNOT(c.S)}
	u.S = bAND(u.E1, u.E2)

	local v = {E1 = speedThr219_1, E2 = bNOT(a.S)}
	v.S = bAND(v.E1, v.E2)

	local w = {E1 = speedThr219_2, E2 = bNOT(b.S)}
	w.S = bAND(w.E1, w.E2)

	local x = {E1 = speedThr219_3, E2 = bNOT(c.S)}
	x.S = bAND(x.E1, x.E2)

	local y = {E1 = speedThr244_1, E2 = bNOT(a.S)}
	y.S = bAND(y.E1, y.E2)

	local z = {E1 = speedThr244_2, E2 = bNOT(b.S)}
	z.S = bAND(z.E1, z.E2)

	local aa = {E1 = speedThr244_3, E2 = bNOT(c.S)}
	aa.S = bAND(aa.E1, aa.E2)

	local bb = {E1 = speedThr250_1, E2 = bNOT(a.S)}
	bb.S = bAND(bb.E1, bb.E2)

	local cc = {E1 = speedThr250_2, E2 = bNOT(b.S)}
	cc.S = bAND(cc.E1, cc.E2)

	local dd = {E1 = speedThr250_3, E2 = bNOT(c.S)}
	dd.S = bAND(dd.E1, dd.E2)



	local ee = {E1 = g.S, E2 = h.S, E3 = i.S}	--184
	ee.S = bOR3(ee.E1, ee.E2, ee.E3)

	local ff = {E1 = j.S, E2 = k.S, E3 = l.S}	--190
	ff.S = bOR3(ff.E1, ff.E2, ff.E3)

	local gg = {E1 = m.S, E2 = n.S, E3 = o.S}	--200
	gg.S = bOR3(gg.E1, gg.E2, gg.E3)

	local hh = {E1 = p.S, E2 = q.S, E3 = r.S}	--204
	hh.S = bOR3(hh.E1, hh.E2, hh.E3)

	local ii = {E1 = s.S, E2 = t.S, E3 = u.S}	--209
	ii.S = bOR3(ii.E1, ii.E2, ii.E3)

	local jj = {E1 = v.S, E2 = w.S, E3 = x.S} 	--219
	jj.S = bOR3(jj.E1, jj.E1, jj.E3)

	local kk = {E1 = y.S, E2 = z.S, E3 = aa.S}	--244
	kk.S = bOR3(kk.E1, kk.E1, kk.E3)

	local ll = {E1 = bb.S, E2 = cc.S, E3 = dd.S}	--250
	ll.S = bOR3(ll.E1, ll.E1, ll.E3)

	NASS184 = ee.S
	NASS190 = ff.S
	NASS200 = gg.S
	NASS204 = hh.S
	NASS209 = ii.S
	NASS219 = jj.S
	NASS244 = kk.S
	NASS250 = ll.S

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

	local a = {E1 = SLFLPPOS_VAL, E2 = bNOT(SLFLPPOS_NCD)}
	a.S = bAND(a.E1, a.E2)

	local b = {E1= SRFLPPOS_VAL, E2 = bNOT(SRFLPPOS_NCD)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1= SLFLPPOS_VAL, E2 = logic.flapSFLPIA_L.output, E3 = bNOT(SLFLPPOS_NCD)}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1= SRFLPPOS_VAL, E2 = logic.flapSFLPIA_R.output, E3 = bNOT(SRFLPPOS_NCD)}
	d.S = bAND3(d.E1, d.E2, d.E2)

	local e = {E1= SRFLPPOS_NCD, E2 = SLFLPPOS_NCD}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = a.S, E2 = b.S}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = c.S, E2 = d.S, E3 = e.S}
	g.S = bOR3(g.E1, g.E2, g.E3)

	SFLPVAL = f.S
	SFLPIA = g.S

end



function A333_fws.sflpsb()

	logic.flapSFLPSB_L:update(SLFLPPOS)
	logic.flapSFLPSB_R:update(SRFLPPOS)

	local a = {E1 = SLFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSB_L.output), E3 = bNOT(SLFLPPOS_NCD)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = SRFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSB_R.output), E3 = bNOT(SRFLPPOS_NCD)}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	SFLPSB = c.S

end



function A333_fws.sflpsc()

	logic.flapSFLPSC_L:update(SLFLPPOS)
	logic.flapSFLPSC_R:update(SRFLPPOS)

	local a = {E1 = SLFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSC_L.output), E3 = bNOT(SLFLPPOS_NCD)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = SRFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSC_R.output), E3 = bNOT(SRFLPPOS_NCD)}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	SFLPSC = c.S

end



function A333_fws.sflpsd()

	logic.flapSFLPSD_L:update(SLFLPPOS)
	logic.flapSFLPSD_R:update(SRFLPPOS)

	local a = {E1 = SLFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSD_L.output), E3 = bNOT(SLFLPPOS_NCD)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = SRFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSD_R.output), E3 = bNOT(SRFLPPOS_NCD)}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	SFLPSD = c.S

end



function A333_fws.sflpse()

	logic.flapSFLPSE_L:update(SLFLPPOS)
	logic.flapSFLPSE_R:update(SRFLPPOS)

	local a = {E1 = SLFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSE_L.output), E3 = bNOT(SLFLPPOS_NCD)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = SRFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSE_R.output), E3 = bNOT(SRFLPPOS_NCD)}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	SFLPSE = c.S

end



function A333_fws.sflpsf()

	logic.flapSFLPSF_L:update(SLFLPPOS)
	logic.flapSFLPSF_R:update(SRFLPPOS)

	local a = {E1 = SLFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSF_L.output), E3 = bNOT(SLFLPPOS_NCD)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = SRFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSF_R.output), E3 = bNOT(SRFLPPOS_NCD)}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)


	SFLPSF = c.S

end






--[=[
function A333_fws.flap_pos()

	-- SFLPIA
	logic.flapSFLPIA_L:update(SLFLPPOS)
	logic.flapSFLPIA_R:update(SRFLPPOS)

	local a = {E1= SLFLPPOS_VAL, E2 = bNOT(SLFLPPOS_NCD)}
	a.S = bAND(a.E1, a.E2)

	local b = {E1= SRFLPPOS_VAL, E2 = bNOT(SRFLPPOS_NCD)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1= SLFLPPOS_VAL, E2 = logic.flapSFLPIA_L.output, E3 = bNOT(SLFLPPOS_NCD)}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1= SRFLPPOS_VAL, E2 = logic.flapSFLPIA_R.output, E3 = bNOT(SRFLPPOS_NCD)}
	d.S = bAND3(d.E1, d.E2, d.E3)

	local e = {E1= SRFLPPOS_NCD, E2 = SLFLPPOS_NCD}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = a.S, E2 = b.S}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = c.S, E2 = d.S, E3 = e.S}
	g.S = bOR3(g.E1, g.E2, g.E3)

	SFLPVAL = f.S
	SFLPIA 	= g.S





	-- SFLPSB
	logic.flapSFLPSB_L:update(SLFLPPOS)
	logic.flapSFLPSB_R:update(SRFLPPOS)

	local h = {E1 = SLFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSB_L.output), E3 = bNOT(SLFLPPOS_NCD)}
	h.S = bAND3(h.E1, h.E2, h.E3)

	local i = {E1 = SRFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSB_R.output), E3 = bNOT(SRFLPPOS_NCD)}
	i.S = bAND3(i.E1, i.E2, i.E3)

	local j = {E1 = h.S, E2 = i.S}
	j.S = bOR(j.E1, j.E2)

	SFLPSB	= j.S







	-- SFLPSC
	logic.flapSFLPSC_L:update(SLFLPPOS)
	logic.flapSFLPSC_R:update(SRFLPPOS)

	local k = {E1 = SLFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSC_L.output), E3 = bNOT(SLFLPPOS_NCD)}
	k.S = bAND3(k.E1, k.E2, k.E3)

	local l = {E1 = SRFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSC_R.output), E3 = bNOT(SRFLPPOS_NCD)}
	l.S = bAND3(l.E1, l.E2, l.E3)

	local m = {E1 = k.S, E2 = l.S}
	m.S = bOR(m.E1, m.E2)

	SFLPSC	= m.S







	-- SFLPSD
	logic.flapSFLPSD_L:update(SLFLPPOS)
	logic.flapSFLPSD_R:update(SRFLPPOS)

	local n = {E1 = SLFLPPOS_VAL, E2 = logic.flapSFLPSD_L.output, E3 = bNOT(SLFLPPOS_NCD)}
	n.S = bAND3(n.E1, n.E2, n.E3)

	local o = {E1 = SRFLPPOS_VAL, E2 = logic.flapSFLPSD_R.output, E3 = bNOT(SRFLPPOS_NCD)}
	o.S = bAND3(o.E1, o.E2, o.E3)

	local p = {E1 = n.S, E2 = o.S}
	p.S = bOR(p.E1, p.E2)

	SFLPSD = p.S






	-- SFLPSE
	logic.flapSFLPSE_L:update(SLFLPPOS)
	logic.flapSFLPSE_R:update(SRFLPPOS)

	local q = {E1 = SLFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSE_L.output), E3 = bNOT(SLFLPPOS_NCD)}
	q.S = bAND3(q.E1, q.E2, q.E3)

	local r = {E1 = SRFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSE_R.output), E3 = bNOT(SRFLPPOS_NCD)}
	r.S = bAND3(r.E1, r.E2, r.E3)

	local s = {E1 = q.S, E2 = r.S}
	s.S = bOR(s.E1, s.E2)

	SFLPSE	= s.S








	-- SFLPSF
	logic.flapSFLPSF_L:update(SLFLPPOS)
	logic.flapSFLPSF_R:update(SRFLPPOS)

	local t = {E1 = SLFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSF_L.output), E3 = bNOT(SLFLPPOS_NCD)}
	t.S = bAND3(t.E1, t.E2, t.E3)

	local u = {E1 = SRFLPPOS_VAL, E2 = bNOT(logic.flapSFLPSF_R.output), E3 = bNOT(SRFLPPOS_NCD)}
	u.S = bAND3(u.E1, u.E2, u.E3)

	local v = {E1 = t.S, E2 = u.S}
	v.S = bOR(v.E1, v.E2)

	SFLPSF	= v.S


end
--]=]







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

	local a = {E1 = SLSLTPOS_INV, E2 = SLSLTPOS_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = SRSLTPOS_INV, E2 = SRSLTPOS_NCD}
	b.S = bOR(b.E1, b.E2)

	local d = {E1 = bNOT(logic.slatSSLTSA_L.output), E2 = bNOT(a.S)}
	d.S = bAND(a.E1, d.E2)

	local e = {E1 = bNOT(logic.slatSSLTSA_R.output), E2 = bNOT(b.S)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = d.S, E2 = e.S}
	f.S = bOR(f.E1, f.E2)

	SSLTSA = f.S

end



function A333_fws.nsltib()

	logic.slatNSLTIB_L:update(SLSLTPOS)
	logic.slatNSLTIB_R:update(SRSLTPOS)

	local a = {E1 = SLSLTPOS_VAL, E2 = bNOT(logic.slatNSLTIB_L.output), E3 = bNOT(SLSLTPOS_NCD)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = SRSLTPOS_VAL, E2 = bNOT(logic.slatNSLTIB_R.output), E3 = bNOT(SRSLTPOS_NCD)}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	NSLTIB = c.S

end



function A333_fws.ssltsc()

	logic.slatSSLTSC_L:update(SLSLTPOS)
	logic.slatSSLTSC_R:update(SRSLTPOS)

	local a = {E1 = SLSLTPOS_INV, E2 = SLSLTPOS_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = SRSLTPOS_INV, E2 = SRSLTPOS_NCD}
	b.S = bOR(b.E1, b.E2)

	local j = {E1 = bNOT(logic.slatSSLTSC_L.output), E2 = bNOT(a.S)}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = bNOT(logic.slatSSLTSC_R.output), E2 = bNOT(b.S)}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = j.S, E2 = k.S}
	l.S = bOR(l.E1, l.E2)

	SSLTSC = l.S

end



function A333_fws.ssltid()

	logic.slatSSLTID_L:update(SLSLTPOS)
	logic.slatSSLTID_R:update(SRSLTPOS)

	local a = {E1 = SLSLTPOS_INV, E2 = SLSLTPOS_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = SRSLTPOS_INV, E2 = SRSLTPOS_NCD}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = bNOT(logic.slatSSLTID_L.output), E2 = bNOT(a.S)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = bNOT(logic.slatSSLTID_R.output), E2 = bNOT(b.S)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = c.S, E2 = d.S}
	e.S = bOR(e.E1, e.E2)

	SSLTID = e.S

end



function A333_fws.ssltie()

	logic.slatSSLTIE_L:update(SLSLTPOS)
	logic.slatSSLTIE_R:update(SRSLTPOS)

	local a = {E1 = SLSLTPOS_INV, E2 = SLSLTPOS_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = SRSLTPOS_INV, E2 = SRSLTPOS_NCD}
	b.S = bOR(b.E1, b.E2)

	local p = {E1 = bNOT(logic.slatSSLTIE_L.output), E2 = bNOT(a.S)}
	p.S = bAND(p.E1, p.E2)

	local q = {E1 = bNOT(logic.slatSSLTIE_R.output), E2 = bNOT(b.S)}
	q.S = bAND(q.E1, q.E2)

	local r = {E1 = p.S, E2 = q.S}
	r.S = bOR(r.E1, r.E2)

	SSLTIE = r.S

end



function A333_fws.ssltsf()

	logic.slatSSLTSF_L:update(SLSLTPOS)
	logic.slatSSLTSF_R:update(SRSLTPOS)

	local a = {E1 = SLSLTPOS_VAL, E2 = logic.slatSSLTSF_L.output, E3 = bNOT(SLSLTPOS_NCD)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = SRSLTPOS_VAL, E2 = logic.slatSSLTSF_R.output, E3 = bNOT(SRSLTPOS_NCD)}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	ssltsf = c.S

end



function A333_fws.ssltsg()

	logic.slatSSLTSG_L:update(SLSLTPOS)
	logic.slatSSLTSG_R:update(SRSLTPOS)

	local a = {E1 = SLSLTPOS_INV, E2 = SLSLTPOS_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = SRSLTPOS_INV, E2 = SRSLTPOS_NCD}
	b.S = bOR(b.E1, b.E2)

	local v = {E1 = logic.slatSSLTSG_L.output, E2 = bNOT(a.S)}
	v.S = bAND(v.E1, v.E2)

	local w = {E1 = logic.slatSSLTSG_R.output, E2 = bNOT(b.S)}
	w.S = bAND(w.E1, w.E2)

	local x = {E1 = v.S, E2 = w.S}
	x.S = bOR(x.E1, x.E2)

	SSLTSG = x.S

end










--[=[
function A333_fws.slat_pos()


	local a = {E1 = SLSLTPOS_INV, E2 = SLSLTPOS_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = SRSLTPOS_INV, E2 = SRSLTPOS_NCD}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = bNOT(a.S), E2 = bNOT(b.S)}
	c.S = bOR(c.E1, c.E2)

	SSLTVAL	= c.S



	-- SSLTSA
	logic.slatSSLTSA_L:update(SLSLTPOS)
	logic.slatSSLTSA_R:update(SRSLTPOS)

	local d = {E1 = bNOT(logic.slatSSLTSA_L.output), E2 = bNOT(a.S)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = bNOT(logic.slatSSLTSA_R.output), E2 = bNOT(b.S)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = d.S, E2 = e.S}
	f.S = bOR(f.E1, f.E2)

	SSLTSA = f.S



	-- NSLTIB
	logic.slatNSLTIB_L:update(SLSLTPOS)
	logic.slatNSLTIB_R:update(SRSLTPOS)

	local g = {E1 = SLSLTPOS_VAL, E2 = bNOT(logic.slatNSLTIB_L.output), E2 = bNOT(SLSLTPOS_NCD)}
	g.S = bAND3(g.E1, g.E2)

	local h = {E1 = SRSLTPOS_VAL, E2 = bNOT(logic.slatNSLTIB_R.output), E3 = bNOT(SRSLTPOS_NCD)}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = g.S, E2 = h.S}
	i.S = bOR(i.E1, i.E2)

	NSLTIB = i.S



	-- SSLTSC
	logic.slatSSLTSC_L:update(SLSLTPOS)
	logic.slatSSLTSC_R:update(SRSLTPOS)

	local j = {E1 = logic.slatSSLTSC_L.output, E2 = bNOT(a.S)}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = logic.slatSSLTSC_R.output, E2 = bNOT(b.S)}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = j.S, E2 = k.S}
	l.S = bOR(l.E1, l.E2)

	SSLTSC = l.S



	-- SSLTID
	logic.slatSSLTID_L:update(SLSLTPOS)
	logic.slatSSLTID_R:update(SRSLTPOS)

	local m = {E1 = bNOT(logic.slatSSLTID_L.output), E2 = bNOT(a.S)}
	m.S = bAND(m.E1, m.E2)

	local n = {E1 = bNOT(logic.slatSSLTID_R.output), E2 = bNOT(b.S)}
	n.S = bAND(n.E1, n.E2)

	local o = {E1 = m.S, E2 = n.S}
	o.S = bOR(o.E1, o.E2)

	SSLTID = o.S




	-- SSLTIE
	logic.slatSSLTIE_L:update(SLSLTPOS)
	logic.slatSSLTIE_R:update(SRSLTPOS)

	local p = {E1 = bNOT(logic.slatSSLTIE_L.output), E2 = bNOT(a.S)}
	p.S = bAND(p.E1, p.E2)

	local q = {E1 = bNOT(logic.slatSSLTIE_R.output), E2 = bNOT(b.S)}
	q.S = bAND(q.E1, q.E2)

	local r = {E1 = p.S, E2 = q.S}
	r.S = bOR(r.E1, r.E2)

	SSLTIE = r.S








	-- SSLTSF
	logic.slatSSLTSF_L:update(SLSLTPOS)
	logic.slatSSLTSF_R:update(SRSLTPOS)

	local s = {E1 = SLSLTPOS_VAL, E2 = logic.slatSSLTSF_L.output, E3 = bNOT(SLSLTPOS_NCD)}
	s.S = bAND3(s.E1, s.E2, s.E3)

	local t = {E1 = SRSLTPOS_VAL, E2 = logic.slatSSLTSF_R.output, E3 = bNOT(SRSLTPOS_NCD)}
	t.S = bAND3(t.E1, t.E2, t.E3)

	local u = {E1 = s.S, E2 = t.S}
	u.S = bOR(u.E1, u.E2)

	SSLTSF = u.S




	-- SSLTSG
	logic.slatSSLTSG_L:update(SLSLTPOS)
	logic.slatSSLTSG_R:update(SRSLTPOS)

	local v = {E1 = logic.slatSSLTSG_L.output, E2 = bNOT(a.S)}
	v.S = bAND(v.E1, v.E2)

	local w = {E1 = logic.slatSSLTSG_R.output, E2 = bNOT(b.S)}
	w.S = bAND(w.E1, w.E2)

	local x = {E1 = v.S, E2 = w.S}
	x.S = bOR(x.E1, x.E2)

	SSLTSG = x.S



	-- SSLTC
	logic.slatSSLTC_L:update(SLSLTPOS)
	logic.slatSSLTC_R:update(SRSLTPOS)

	local y = {E1 = SLSLTPOS_VAL, E2 = logic.slatSSLTC_L.output, E3 = bNOT(SLSLTPOS_NCD)}
	y.S = bAND3(y.E1, y.E2, y.E3)

	local z = {E1 = SRSLTPOS_VAL, E2 = logic.slatSSLTC_R.output, E3 = bNOT(SRSLTPOS_NCD)}
	z.S = bAND3(z.E1, z.E2, z.E3)

	local aa = {E1 = y.S, E2 = z.S}
	aa.S = bOR(aa.E1, aa.E2)

	SSLTC = aa.S

end
--]=]





function A333_fws.sflpdsltc()

	logic.slatSSLTCC_L:update(SLSLTPOS)
	logic.slatSSLTCC_R:update(SRSLTPOS)

	local c = {E1 = SLSLTPOS_VAL, E2 = logic.slatSSLTCC_L.output, E3 = bNOT(SLSLTPOS_NCD)}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = SRSLTPOS_VAL, E2 = logic.slatSSLTCC_R.output, E3 = bNOT(SRSLTPOS_NCD)}
	d.S = bAND3(d.E1, d.E2, d.E3)

	local f = {E1 = c.S, E2 = d.S}
	f.S = bOR3(f.E1, f.E2)

	local g = {E1 = SFLPSD, E2 = f.S}
	g.S = bOR(g.E1, g.E2)

	SFLPDSLTC = f.S

end







function A333_fws.def_alt()

	local alt_th01 = NRADH_1 > 1500.0
	local alt_th02 = NRADH_2 > 1500.0
	local alt_th03 = NRADH_1 < 800.0
	local alt_th04 = NRADH_2 < 800.0

	local a = {E1 = alt_th01, E2 = bNOT(NRADH_1_INV)}
		a.S = bAND(a.E1, a.E2)

	local b = {E1 = alt_th02, E2 = bNOT(NRADH_2_INV)}
		b.S = bAND(b.E1, b.E2)

	local c = {E1 = NRADH_1_INV, E2 = NRADH_2_INV}
		c.S = bAND(c.E1, c.E2)

	local d = {E1 = NRADH_1_NCD, E2 = NRADH_1_INV}
		d.S = bOR(d.E1, d.E2)

	local e = {E1 = NRADH_2_NCD, E2 = NRADH_2_INV}
		e.S = bOR(e.E1, e.E2)

	local f = {E1 = bNOT(NRADH_1_INV), E2 = alt_th03, E3 = bNOT(NRADH_1_NCD)}
		f.S = bAND3(f.E1, f.E2, f.E3)

	local g = {E1 = bNOT(NRADH_2_INV), E2 = alt_th04, E3 = bNOT(NRADH_2_NCD)}
		g.S = bAND3(g.E1, g.E2, g.E3)

	local h = {E1 = bNOT(c.S), E2 = d.S, E3 = e.S}
		h.S = bAND3(h.E1, h.E2, h.E3)

	local i = {E1 = f.S, E2 = g.S}
		i.S = bOR(i.E1, i.E2)

	logic.alt_conf01:update(h.S)

	local j = {E1 = a.S, E2 = b.S, E3 = logic.alt_conf01.OUT}
		j.S = bOR3(j.E1, j.E2, j.E3)

	local k = {E1 = bNOT(logic.alt_conf01.OUT), E2 = i.S}
		k.S = bAND(k.E1, k.E2)

	logic.alt_srR01:update(j.S, k.S)

	ZH800FT		= logic.alt_srR01.Q
	ZH1500FT	= j.S
	ZHFAIL		= c.S

end








function A333_fws.tla_mct_flex()

	logic.TLAMCTorFlex01:update(JR1TLA_1A)
	logic.TLAMCTorFlex02:update(JR1TLA_1A)
	logic.TLAMCTorFlex03:update(JR1TLA_1B)
	logic.TLAMCTorFlex04:update(JR1TLA_1B)
	logic.TLAMCTorFlex05:update(JR2TLA_2A)
	logic.TLAMCTorFlex06:update(JR2TLA_2A)
	logic.TLAMCTorFlex07:update(JR2TLA_2B)
	logic.TLAMCTorFlex08:update(JR2TLA_2B)


	local a = {E1 = logic.TLAMCTorFlex01.out, E2 = JR1TLA_1A_VAL, E3 = logic.TLAMCTorFlex02.out}
		a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = JR1TLA_1A_VAL, E2 = bNOT(logic.TLAMCTorFlex01.out)}
		b.S = bAND(b.E1, b.E2)


	local c = {E1 = logic.TLAMCTorFlex03.out, E2 = JR1TLA_1B_VAL, E3 = logic.TLAMCTorFlex04.out}
		c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = JR1TLA_1B_VAL, E2 = bNOT(logic.TLAMCTorFlex03.out)}
		d.S = bAND(d.E1, d.E2)


	local e = {E1 = logic.TLAMCTorFlex05.out, E2 = JR2TLA_2A_VAL, E3 = logic.TLAMCTorFlex06.out}
		e.S = bAND3(e.E1, e.E2, e.E3)

	local f = {E1 = JR2TLA_2A_VAL, E2 = bNOT(logic.TLAMCTorFlex05.out)}
		f.S = bAND(f.E1, f.E2)


	local g = {E1 = logic.TLAMCTorFlex07.out, E2 = JR2TLA_2B_VAL, E3 = logic.TLAMCTorFlex08.out}
		g.S = bAND3(g.E1, g.E2, g.E3)

	local h = {E1 = JR2TLA_2B_VAL, E2 = bNOT(logic.TLAMCTorFlex07.out)}
		h.S = bAND(h.E1, h.E2)


	local i = {E1 = a.S, E2 = c.S}
		i.S = bOR(i.E1, i.E2)

	local j = {E1 = b.S, E2 = d.S}
		j.S = bOR(j.E1, j.E2)

	local k = {E1 = e.S, E2 = g.S}
		k.S = bOR(k.E1, k.E2)

	local l = {E1 = f.S, E2 = h.S}
		l.S = bOR(l.E1, l.E2)


	local m = {E1 = i.S, E2 = WRRT}
		m.S = bAND(m.E1, m.E2)

	local n = {E1 = j.S, E2 = WRRT}
		n.S = bAND(n.E1, n.E2)

	local o = {E1 = k.S, E2 = WRRT}
		o.S = bAND(o.E1, o.E2)

	local p = {E1 = l.S, E2 = WRRT}
		p.S = bAND(p.E1, p.E2)


	JR1TLAMCT	= m.S
	JR1SUPMCT	= n.S
	JR2TLAMCT	= o.S
	JR2SUPMCT	= p.S

end






function A333_fws.dto_installed()

	local a = {E1 = JRDTOFINST_1A, E2 = JRDTOFINST_1B, E3 = JRDTOFINST_2A, E4 = JRDTOFINST_2B}
		a.S = bOR4(a.E1, a.E2, a.E3, a.E4)

	JRDTOI	= a.S

end





function A333_fws.eng1_or_2_norun()

	logic.e1or2nr_conf01:update(JR1AIDLE_1A)
	logic.e1or2nr_conf02:update(JR1AIDLE_1B)
	logic.e1or2nr_conf03:update(JR2AIDLE_2A)
	logic.e1or2nr_conf04:update(JR2AIDLE_2B)

	local a = {E1 = WRRT, E2 = bNOT(logic.e1or2nr_conf01.OUT), E3 = bNOT(logic.e1or2nr_conf02.OUT)}
		a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = bNOT(JML1ON), E2 = JML1ON_VAL}
		b.S = bAND(b.E1, b.E2)

	local c = {E1 = WRRT, E2 = bNOT(logic.e1or2nr_conf03.OUT), E3 = bNOT(logic.e1or2nr_conf04.OUT)}
		c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = bNOT(JML2ON), E2 = JML2ON_VAL}
		d.S = bAND(d.E1, d.E2)

	local e = {E1 = a.S, E2 = b.S}
		e.S = bOR(e.E1, e.E2)

	local f = {E1 = c.S, E2 = d.S}
		f.S = bOR(f.E1, f.E2)

	JR1NORUN = e.S
	JR2NORUN = f.S

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

	local a = {E1 = JR1NORUN, E2 = JR2NORUN}
		a.S = bAND(a.E1, a.E2)

	ZR12NORUN = a.S

end








function A333_fws.eng1_or_2_run()

	local a = {E1 = JR1AIDLE_1A, E2 = JR1AIDLE_1B, E3 = JR2AIDLE_2A, E4 = JR2AIDLE_2B}
		a.S = bOR4(a.E1, a.E2, a.E3, a.E4)

	local b = {E1 = WRRT, E2 = a.S}
		b.S = bAND(b.E1, b.E2)

	logic.e1or2run_conf01:update(b.S)

	ZR1O2RUN 	= logic.e1or2run_conf01.OUT
	ZOERG		= b.S

end

function A333_fws.eng1_or_2_run_ER()
	logic.e1or2run_conf01:resetTimer()
	logic.e1or2run_conf01.lastIN = true
	logic.e1or2run_conf01.OUT = true
end







function A333_fws.dto_sel()

	local a = {E1 = JRDTOSEL_1A, E2 = JRDTOSEL_1B}
		a.S = bOR(a.E1, a.E2)

	local b = {E1 = JRDTOSEL_2A, E2 = JRDTOSEL_2B}
		b.S = bOR(b.E1, b.E2)


	local c = {E1 = a.S, E2 = WRRT}
		c.S = bAND(c.E1, c.E2)

	local d = {E1 = b.S, E2 = WRRT}
		d.S = bAND(d.E1, d.E2)

	JR1DTOSELI = c.S
	JR2DTOSELI = d.S

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
	JR2TRMDB19_2A = false								-- ENG 1 TR MODE IDLE SELECTED
	JR2TRMDB20_2A = JR1TLACL							-- ENG 1 TR MODE MAX CLIMB SELECTED
	JR1TRMDB21_1B = logic.eng1_flex_mode_selected		-- ENG 1 TR MODE FLEX TAKE OFF SELECTE

	JR2TRMDB19_2A = false								-- ENG 2 TR MODE IDLE SELECTED
	JR2TRMDB20_2A = JR2TLACL							-- ENG 2 TR MODE MAX CLIMB SELECTED
	JR2TRMDB21_2A = logic.eng2_flex_mode_selected		-- ENG 2 TR MODE FLEX TAKE OFF SELECTED
	JR2TRMDB19_2B = false								-- ENG 2 TR MODE IDLE SELECTED
	JR2TRMDB20_2B = JR2TLACL							-- ENG 2 TR MODE MAX CLIMB SELECTED
	JR2TRMDB21_2B = logic.eng2_flex_mode_selected		-- ENG 2 TR MODE FLEX TAKE OFF SELECTED

end






function A333_fws.fto_mode()

	local a = {E1 = bNOT(JR1TRMDB19_1A), E2 = bNOT(JR1TRMDB20_1A), E3 = JR1TRMDB21_1A}
		a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = bNOT(JR1TRMDB19_1B), E2 = bNOT(JR1TRMDB20_1B), E3 = JR1TRMDB21_1B}
		b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = bNOT(JR2TRMDB19_2A), E2 = bNOT(JR2TRMDB20_2A), E3 = JR2TRMDB21_2A}
		c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = bNOT(JR2TRMDB19_2B), E2 = bNOT(JR2TRMDB20_2B), E3 = JR2TRMDB21_2B}
		d.S = bAND3(d.E1, d.E2, d.E3)

	local e = {E1 = JR1TRMDB19_1A, E2 = bNOT(JR1TRMDB20_1A), E3 = JR1TRMDB21_1A}
		e.S = bAND3(e.E1, e.E2, e.E3)

	local f = {E1 = a.S, E2 = b.S}
		f.S = bOR(f.E1, f.E2)

	local g = {E1 = JR1TRMDB19_1B, E2 = bNOT(JR1TRMDB20_1B), E3 = JR1TRMDB21_1B}
		g.S = bAND3(g.E1, g.E2, g.E3)

	local h = {E1 = JR2TRMDB19_2A, E2 = bNOT(JR2TRMDB20_2A), E3 = JR2TRMDB21_2A}
		h.S = bAND3(h.E1, h.E2, h.E3)

	local i = {E1 = c.S, E2 = d.S}
		i.S = bOR(i.E1, i.E2)

	local j = {E1 = JR2TRMDB19_2B, E2 = bNOT(JR2TRMDB20_2B), E3 = JR2TRMDB21_2B}
		j.S = bAND3(j.E1, j.E2, j.E3)

	local k = {E1 = e.S, E2 = g.S}
		k.S = bOR(k.E1, k.E2)

	local l = {E1 = JR1DTOSELI, E2 = f.S}
		l.S = bOR(l.E1, l.E2)

	local m = {E1 = i.S, E2 = JR2DTOSELI}
		m.S = bOR(m.E1, m.E2)

	local n = {E1 = h.S, E2 = j.S}
		n.S = bOR(n.E1, n.E2)

	local o = {E1 = k.S, E2 = WRRT}
		o.S = bAND(o.E1, o.E2)

	local p = {E1 = l.S, E2 = WRRT}
		p.S = bAND(p.E1, p.E2)

	local q = {E1 = f.S, E2 = WRRT}
		q.S = bAND(q.E1, q.E2)

	local r = {E1 = WRRT, E2 = i.S}
		r.S = bAND(r.E1, r.E2)

	local s = {E1 = WRRT, E2 = m.S}
		s.S = bAND(s.E1, s.E2)

	local t = {E1 = WRRT, E2 = n.S}
		t.S = bAND(t.E1, t.E2)


	JR1DTOSEL	= JR1DTOSELI
	JR2DTOSEL	= JR2DTOSELI

	JR1TGMD		= o.S
	JR1FTOMD	= p.S
	JR1FXMOD	= q.S

	JR2TGMD		= t.S
	JR2FTOMD	= s.S
	JR2FXMOD	= r.S

end






function A333_fws.takeoff()

	--| THRESHOLD
	local epwr_th01 = JR1N1_1A > 95.0
	local epwr_th02 = JR1N1_1B > 95.0

	local epwr_th03 = JR2N1_2A > 95.0
	local epwr_th04 = JR2N1_2B > 95.0

	local a = {E1 = JR1N1_1A_INV, E2 = JR1N1_1A_NCD}
		a.S = bOR(a.E1, a.E2)

	local b = {E1 = JR1N1_1B_INV, E2 = JR1N1_1B_NCD}
		b.S = bOR(b.E1, b.E2)

	local c = {E1 = JR2N1_2A_INV, E2 = JR2N1_2A_NCD}
		c.S = bOR(c.E1, c.E2)

	local d = {E1 = JR2N1_2B_INV, E2 = JR2N1_2B_NCD}
		d.S = bOR(d.E1, d.E2)

	local e = {E1 = bNOT(a.S), E2 = epwr_th01}
		e.S = bAND(e.E1, e.E2)

	local f = {E1 = epwr_th02, E2 = bNOT(b.S)}
		f.S = bAND(f.E1, f.E2)

	local g = {E1 = bNOT(c.S), E2 = epwr_th03}
		g.S = bAND(g.E1, g.E2)

	local h = {E1 = epwr_th04, E2 = bNOT(d.S)}
		h.S = bAND(h.E1, h.E2)

	local i = {E1 = e.S, E2 = f.S}
		i.S = bOR(i.E1, i.E2)

	local j = {E1 = g.S, E2 = h.S}
		j.S = bOR(j.E1, j.E2)


	local k = {E1 = i.S, E2 = WRRT}
		k.S = bAND(k.E1, k.E2)

	local l = {E1 = WRRT, E2 = j.S}
		l.S = bAND(l.E1, l.E2)

	JR1TOFF = k.S
	JR2TOFF = l.S

end







function A333_fws.tla_pwr_rev()

	--| THRESHOLD
	logic.pwrRev_th01:update(JR1TLA_1A)	-- TL 1 Full Power
	logic.pwrRev_th02:update(JR1TLA_1B) -- TL 1 Full Power
	logic.pwrRev_th03:update(JR1TLA_1A)	-- TL 1 Reverse
	logic.pwrRev_th04:update(JR1TLA_1B)	-- TL 1 Reverse
	logic.pwrRev_th05:update(JR2TLA_2A)	-- TL 2 Full Power
	logic.pwrRev_th06:update(JR2TLA_2B)	-- TL 2 Full Power
	logic.pwrRev_th07:update(JR2TLA_2A)	-- TL 2 Reverse
	logic.pwrRev_th08:update(JR2TLA_2B)	-- TL 2 Reverse

	local a = {E1 = JR1TLA_1A_INV, E2 = JR1TLA_1A_NCD}
		a.S = bOR(a.E1, a.E2)

	local b = {E1 = JR1TLA_1B_INV, E2 = JR1TLA_1B_NCD}
		b.S = bOR(b.E1, b.E2)

	local c = {E1 = JR2TLA_2A_INV, E2 = JR2TLA_2A_NCD}
		c.S = bOR(c.E1, c.E2)

	local d = {E1 = JR2TLA_2B_INV, E2 = JR2TLA_2B_NCD}
		d.S = bOR(d.E1, d.E2)

	local e = {E1 = bNOT(a.S), E2 = logic.pwrRev_th03.out}
		e.S = bAND(e.E1, e.E2)

	local f = {E1 = logic.pwrRev_th04.out, E2 = bNOT(b.S)}
		f.S = bAND(f.E1, f.E2)

	local g = {E1 = bNOT(c.S), E2 = logic.pwrRev_th07.out}
		g.S = bAND(g.E1, g.E2)

	local h = {E1 = logic.pwrRev_th08.out, E2 = bNOT(d.S)}
		h.S = bAND(h.E1, h.E2)

	local i = {E1 = e.S, E2 = f.S, E3 = JR1CMDREV_1A, E4 = JR1CMDREV_1B}
		i.S = bOR4(i.E1, i.E2, i.E3, i.E4)

	local j = {E1 = g.S, E2 = h.S, E3 = JR2CMDREV_2A, E4 = JR2CMDREV_2B}
		j.S = bOR4(j.E1, j.E2, j.E3, j.E4)

 	logic.pwrRev_conf01:update(i.S)

 	logic.pwrRev_conf02:update(j.S)

	local k = {E1 = i.S, E2 = logic.pwrRev_conf01.OUT}
		k.S = bOR(k.E1, k.E2)

	local l = {E1 = i.S, E2 = WRRT}
		l.S = bAND(l.E1, l.E2)

	local m = {E1 = j.S, E2 = logic.pwrRev_conf02.OUT}
		m.S = bOR(m.E1, m.E2)

	local n = {E1 = j.S, E2 = WRRT}
		n.S = bAND(n.E1, n.E2)

	local o = {E1 = JR1TOFF, E2 = bNOT(k.S)}
		o.S = bAND(o.E1, o.E2)

	local p = {E1 = JR2TOFF, E2 = bNOT(m.S)}
		p.S = bAND(p.E1, p.E2)

	local q = {E1 = logic.pwrRev_th01.out, E2 = o.S, E3 = logic.pwrRev_th02.out}
		q.S = bOR3(q.E1, q.E1, q.E3)

	local r = {E1 = logic.pwrRev_th05.out, E2 = p.S, E3 = logic.pwrRev_th06.out}
		r.S = bOR3(r.E1, r.E2, r.E3)

	local s = {E1 = q.S, E2 = WRRT}
		s.S = bAND(s.E1, s.E2)

	local t = {E1 = WRRT, E2 = r.S}
		t.S = bAND(t.E1, t.E2)

	JR1TLFPWR	= s.S
	JR1TLREV	= l.S

	JR2TLFPWR	= t.S
	JR2TLREV	= n.S

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

	local a = {E1 = JR1TLA_1A_VAL, E2 = tlaIDLE_th01, E3 = tlaIDLE_th02}
	a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = JR1TLA_1B_VAL, E2 = tlaIDLE_th03, E3 = tlaIDLE_th04}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = JR2TLA_2A_VAL, E2 = tlaIDLE_th05, E3 = tlaIDLE_th06}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = JR2TLA_2B_VAL, E2 = tlaIDLE_th07, E3 = tlaIDLE_th08}
	d.S = bAND3(d.E1, d.E2, d.E3)

	local e = {E1 = a.S, E2 = b.S}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = c.S, E2 = d.S}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = e.S, E2 = f.S}
	g.S = bAND(g.E1, g.E2)

	JR1TLAI 	= e.S
	JR2TLAI 	= f.S
	JR12IDLE	= g.S

end







function A333_fws.tla_sup_cl()

	logic.tlaSupClThreshold01:update(JR1TLA_1A)
	logic.tlaSupClThreshold02:update(JR1TLA_1B)
	logic.tlaSupClThreshold03:update(JR2TLA_2A)
	logic.tlaSupClThreshold04:update(JR2TLA_2B)

	local a = {E1 = JR1TLA_1A_INV, E2 = JR1TLA_1A_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = JR1TLA_1B_INV, E2 = JR1TLA_1B_NCD}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = JR2TLA_2A_INV, E2 = JR2TLA_2A_NCD}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = JR2TLA_2B_INV, E2 = JR2TLA_2B_NCD}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = logic.tlaSupClThreshold01.out, E2 = bNOT(a.S)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = logic.tlaSupClThreshold02.out, E2 = bNOT(b.S)}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = logic.tlaSupClThreshold03.out, E2 = bNOT(c.S)}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = logic.tlaSupClThreshold04.out, E2 = bNOT(d.S)}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = e.S, E2 = f.S}
	i.S = bOR(i.E1, i.E2)

	local j = {E1 = g.S, E2 = h.S}
	j.S = bOR(j.E1, j.E2)

	local k = {E1 = i.S, E2 = WRRT}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = j.S, E2 = WRRT}
	l.S = bAND(l.E1, l.E2)

	JR1TLASCL	= k.S
	JR2TLASCL	= l.S

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


	local a = {E1 = tlaMCL_th01, E2 = JR1TLA_1A_VAL, E3 = tlaMCL_th02}
		a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = JR1TLA_1A_VAL, E2 = tlaMCL_th02}
		b.S = bAND(b.E1, b.E2)

	local c = {E1 = tlaMCL_th03, E2 = JR1TLA_1B_VAL, E3 = tlaMCL_th04}
		c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = JR1TLA_1B_VAL, E2 = tlaMCL_th04}
		d.S = bAND(d.E1, d.E2)

	local e = {E1 = tlaMCL_th05, E2 = JR2TLA_2A_VAL, E3 = tlaMCL_th06}
		e.S = bAND3(e.E1, e.E2, e.E3)

	local f = {E1 = JR2TLA_2A_VAL, E2 = tlaMCL_th06}
		f.S = bAND(f.E1, f.E2)

	local g = {E1 = tlaMCL_th07, E2 = JR2TLA_2B_VAL, E3 = tlaMCL_th08}
		g.S = bAND3(g.E1, g.E2, g.E3)

	local h = {E1 = JR2TLA_2B_VAL, E2 = tlaMCL_th08}
		h.S = bAND(h.E1, h.E2)

	local i = {E1 = a.S, E2 = c.S}
		i.S = bOR(i.E1, i.E2)

	local j = {E1 = b.S, E2 = d.S}
		j.S = bOR(j.E1, j.E2)

	local k = {E1 = e.S, E2 = g.S}
		k.S = bOR(k.E1, k.E2)

	local l = {E1 = f.S, E2 = h.S}
		l.S = bOR(l.E1, l.E2)

	local m = {E1 = i.S, E2 = WRRT}
		m.S = bAND(m.E1, m.E2)

	local n = {E1 = j.S, E2 = l.S, E3 = WRRT}
		n.S = bAND3(n.E1, n.E2, n.E3)

	local o = {E1 = k.S, E2 = WRRT}
		o.S = bAND(o.E1, o.E2)

	JR1TLACL	= m.S
	JR2TLACL	= o.S
	JR12MCL		= n.S

end







function A333_fws.eng1_or_2_to_pwr()

	local a = {E1 = JR1FTOMD, E2 = JR1TLAMCT}
		a.S = bAND(a.E1, a.E2)

	local b = {E1 = JR1TLFPWR, E2 = JR2TLFPWR}
		b.S = bOR(b.E1, b.E2)

	local c = {E1 = JR2FTOMD, E2 = JR2TLAMCT}
		c.S = bAND(c.E1, c.E2)

	local d = {E1 = JR1TLAMCT, E2 = JR1DTOSEL}
		d.S = bAND(d.E1, d.E2)

	local e = {E1 = JR2TLAMCT, E2 = JR2DTOSEL}
		e.S = bAND(e.E1, e.E2)

	local f = {E1 = a.S, E2 = b.S, E3 = c.S, E4 = e.S, E5 = d.S}
		f.S = bOR5(f.E1, f.E2, f.E3, f.E4, f.E5)

	logic.e1o2topwr_conf01:update(f.S)

	local g = {E1 = c.S, E2 = a.s, E3 = d.S, E4 = e.S}
		g.S = bOR4(g.E1, g.E2, g.E3, g.E4)

	local h = {E1 = logic.e1o2topwr_conf01.OUT, E2 = bNOT(ZH1500FT), E3 = JR12MCL}
		h.S = bAND3(h.E1, h.E2, h.E3)

	local i = {E1 = f.S, E2 = h.S}
		i.S = bOR(i.E1, i.E2)

	local j = {E1 = i.S, E2 = WRRT}
		j.S = bAND(j.E1, j.E2)

	local k = {E1 = WRRT, E2 = g.S}
		k.S = bAND(k.E1, k.E2)

	ZR1O2TOPWR	= 	j.S
	JRFLEX		= 	k.S

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

	local a = {E1 = NCAS_1_INV, E2 = NCAS_1_NCD}
		a.S = bOR(a.E1, a.E2)

	local b = {E1 = NCAS_2_INV, E2 = NCAS_2_NCD}
		b.S = bOR(b.E1, b.E2)

	local c = {E1 = NCAS_3_INV, E2 = NCAS_3_NCD}
		c.S = bOR(c.E1, c.E2)

	local d = {E1 = spd_th01, E2 = bNOT(a.S)}
		d.S = bAND(d.E1, d.E2)

	local e = {E1 = bNOT(a.S), E2 = spd_th02}
		e.S = bAND(e.E1, e.E2)

	local f = {E1 = spd_th03, E2 = bNOT(b.S)}
		f.S = bAND(f.E1, f.E2)

	local g = {E1 = bNOT(b.S), E2 = spd_th04}
		g.S = bAND(g.E1, g.E2)

	local h = {E1 = spd_th05, E2 = bNOT(c.S)}
		h.S = bAND(h.E1, h.E2)

	local i = {E1 = bNOT(c.S), E2 = spd_th06}
		i.S = bAND(i.E1, i.E2)

	local j = {E1 = a.S, E2 = f.S, E3 = h.S}
		j.S = bOR3(j.E1, j.E2, j.E3)

	local k = {E1 = e.S, E2 = g.S, E3 = i.S}
		k.S = bOR3(k.E1, k.E2, k.E3)

	local l = {E1 = a.S, E2 = b.S, E3 = c.S}
		l.S = bOR3(l.E1, l.E2, l.E3)

	local m = {E1 = j.S, E2 = l.S}
		m.S = bAND(m.E1, m.E2)

	local spd_mt1 = {E1 = d.S, E2 = h.S, E3 = f.S, E4 = m.S}
		spd_mt1.S = bMT(1, spd_mt1.E1, spd_mt1.E2, spd_mt1.E3, spd_mt1.E4)

	local n = {E1 = l.S, E2 = k.S}
		n.S = bAND(n.E1, n.E2)

	local spd_mt2 = {E1 = n.S, E2 = g.S, E3 = e.S, E4 = i.S}
		spd_mt2.S = bMT(1, spd_mt2.E1, spd_mt2.E2, spd_mt2.E3, spd_mt2.E4)

	local o = {E1 = NCAS_1_FT, E2 = NCAS_2_FT, E3 = NCAS_3_FT}
		o.S = bOR3(o.E1, o.E2, o.E3)

	logic.spd_mtrigF_01:update(o.S)

	logic.spd_mtrigF_02:update(o.S)

	local p = {E1 = spd_mt2.S, E2 = logic.spd_mtrigF_01.OUT}
		p.S = bOR(p.E1, p.E2)

	logic.spd_srS01:update(spd_mt1.S, p.S)

	ZACS80KT	= logic.spd_srS01.Q
	ZADCTI		= logic.spd_mtrigF_02.OUT

end







function A333_fws.def_new_ground()

	local a = {E1 = GLLGC_1, E2 = GELLGCOMPR}
		a.S = bXOR(a.E1, a.E2)

	local b = {E1 = GLLGC_1, E2 = GELLGCOMPR}
		b.S = bAND(b.E1, b.E2)

	local c = {E1 = GLLGC_2, E2 = GNLLGCOMPR}
		c.S = bAND(c.E1, c.E2)

	local d = {E1 = GLLGC_2, E2 = GNLLGCOMPR}
		d.S = bXOR(d.E1, d.E2)

	logic.ng_conf01:update(a.S)

	logic.ng_conf02:update(bNOT(a.S))

	logic.ng_conf03:update(d.S)

	logic.ng_conf04:update(bNOT(d.S))

	local e	= {E1 = b.S, E2 = c.S}
		e.S = bXOR(e.E1, e.E2)

	local f = {E1 = GLLGC_1_NCD, E2 = GLLGC_1_INV, E3 = logic.ng_conf01.OUT}
		f.S = bOR3(f.E1, f.E2, f.E3)

	local g = {E1 = GLLGC_2_NCD, E2 = GLLGC_2_INV, E3 = logic.ng_conf03.OUT}
		g.S = bOR3(g.E1, g.E2, g.E3)

	logic.ng_srS01:update(f.S, logic.ng_conf02.OUT)

	local h = {E1 = b.S, E2 = bNOT(e.S), E3 = c.S}
		h.S = bAND3(h.E1, h.E2, h.E3)

	logic.ng_srS02:update(g.S, logic.ng_conf04.OUT)

	local i = {E1 = logic.ng_srS01.Q, E2 = logic.ng_srS02.Q}
		i.S = bOR(i.E1, i.E2)

	ZNEWGND 	= h.S
	ZLG12INV	= i.S

end






function A333_fws.def_ground()

	local alt_th01 = NRADH_1 < 5.0
	local alt_th02 = NRADH_2 < 5.0

	local a = {E1 = bNOT(GNLLGCOMPR), E2 = bNOT(GELLGCOMPR)}
		a.S = bOR(a.E1, a.E2)

	logic.gr_srS01:update(alt_th01, a.S)

	logic.gr_srS02:update(alt_th02, a.S)

	local b = {E1 = logic.gr_srS01.Q, E2 = alt_th01}
		b.S = bOR(b.E1, b.E2)

	local c = {E1 = alt_th02, E2 = logic.gr_srS02.Q}
		c.S = bOR(c.E1, c.E2)

	local d = {E1 = b.S, E2 = bNOT(NRADH_1_NCD), E3 = bNOT(NRADH_1_INV)}
		d.S = bAND3(d.E1, d.E2, d.E3)

	local e = {E1 = NRADH_1_INV, E2 = NRADH_2_INV}
		e.S = bOR(e.E1, e.E2)

	local f	= {E1 = bNOT(NRADH_2_INV), E2 = bNOT(NRADH_2_NCD), E3 = c.S}
		f.S = bAND3(f.E1, f.E2, f.E3)

	local gr_mt1 = {E1 = GELLGCOMPR, E2 = GNLLGCOMPR, E3 = f.S, E4 = d.S}
		gr_mt1.S = bMT(2, gr_mt1.E1, gr_mt1.E2, gr_mt1.E3, gr_mt1.E4)

	local gr_mt2 = {E1 = GELLGCOMPR, E2 = GNLLGCOMPR, E3 = d.S, E4 = f.S}
		gr_mt2.S = bMT(1, gr_mt2.E1, gr_mt2.E2, gr_mt2.E3, gr_mt2.E4)

	local g = {E1 = NRADH_1_NCD, E2 = NRADH_2_NCD, E3 = bNOT(ZLG12INV)}
		g.S = bAND3(g.E1, g.E2, g.E3)

	local h = {E1 = gr_mt1.S, E2 = bNOT(e.S)}
		h.S = bAND(h.E1, h.E2)

	local i = {E1 = gr_mt2.S, E2 = e.S}
		i.S = bAND(i.E1, i.E2)

	local j = {E1 = h.S, E2 = i.S}
		j.S = bOR(j.E1, j.E2)

	logic.gr_mrTrigR_01:update(g.S)

	local k = {E1 = logic.gr_mrTrigR_01.OUT, E2 = ZNEWGND}
		k.S = bAND(k.E1, k.E2)

	local l = {E1 = j.S, E2 = k.S}
		l.S = bOR(l.E1, l.E2)

	logic.gr_conf01:update(l.S)

	ZGNDI 	= l.S
	ZGND 	= logic.gr_conf01.OUT

end





function A333_fws.excess_cabin_alt()

	logic.climb = false
	if simDR_vvi_pilot > 250.0 then
		logic.climb = true
	end

	logic.descend = false
	if simDR_vvi_pilot < 250.0 then
		logic.descend = true
	end

	local excessCabAlt = math.max(9550.0, simDR_cabin_altitude_actuator_ft + 1000.0)

	if ((logic.climb or logic.descend) and simDR_cabin_altitude_indicator_ft > excessCabAlt)
		or
		(not logic.climb and not logic.descend) and simDR_cabin_altitude_indicator_ft > 9550.0
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

	local a = {E1 = UE1FPBOUT, E2 = bNOT(UE1FPBOUT)}
		--a.S = bOR(a.E1, a.E2)
		a.S = UE1FPBOUT

	logic.fph_conf01:update(a.S)

	logic.fph_mTrigR_05:update(logic.fph_conf01.OUT)

	local b = {E1 = ZH800FT, E2 = bNOT(ZH800FT)}
		--b.S = bOR(b.E1, b.E2)
		b.S = ZH800FT

	logic.fph_conf02:update(b.S)

	logic.fph_pulse01:update(logic.fph_conf02.OUT)

	local c = {E1 = ZGND, E2 = logic.fph_mTrigF_02.OUT}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = ZGND, E2 = logic.fph_mTrigF_01.OUT}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = logic.fph_mTrigR_03.OUT, E2 = ZGNDI}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = ZGND, E2 = logic.fph_mTrigR_05.OUT}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = ZGND, E2 = ZR1O2TOPWR}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = c.S, E2 = f.S, E3 = d.S}
	h.S = bOR3(h.E1, h.E2, h.E3)

	local i  = {E1 = bNOT(ZH1500FT), E2 = ZR1O2TOPWR, E3 = bNOT(ZHFAIL), E4 = bNOT(e.S)}
	i.S = bAND4(i.E1, i.E2, i.E3, i.E4)

	logic.fph_mTrigR_07:update(i.S)

	local j = {E1 = bNOT(e.S), E2 = bNOT(ZHFAIL), E3 = bNOT(ZR1O2TOPWR), E4 = bNOT(ZH1500FT), E5 = bNOT(ZH800FT), E6 = bNOT(logic.fph_pulse01.OUT)}
	j.S = bAND6(j.E1, j.E2, j.E3, j.E4, j.E5, j.E6)

	logic.fph_mTrigR_08:update(j.S)

	local l = {E1 = bNOT(logic.fph_mTrigR_04.OUT), h.S, E3 = bNOT(ZGND)}
	l.S = bAND3(l.E1, l.E2, l.E3)

	local o = {E1 = l.S, E2 = ZADCTI}
	o.S = bOR(o.E1, o.E2)

	local p = {E1 = ZGND, E2 = bNOT(ZR1O2TOPWR), E3 = bNOT(ZACS80KT)}
	p.S = bAND3(p.E1, p.E2, p.E3)

	local q = {E1 = logic.fph_mTrigR_07.OUT, E2 = i.S}
	q.S = bAND(q.E1, q.E2)

	local r = {E1 = j.S, E2 = logic.fph_mTrigR_08.OUT}
	r.S = bAND(r.E1, r.E2)

	local s = {E1 = logic.fph_mTrigR_06.OUT, E2 = ZGNDI}
	s.S = bOR(s.E1, s.E2)

	local v = {E1 = s.S, E2 = bNOT(ZR1O2TOPWR), E3 = ZACS80KT}
	v.S = bAND3(v.E1, v.E2, v.E3)

	local y = {E1 = bNOT(ZACS80KT), E2 = ZR1O2RUN, E3 = g.S}
	y.S = bAND3(y.E1, y.E2, y.E3)

	local n = {E1 = y.S, E2 = v.S}
	n.S = bOR(n.E1, n.E2)

	logic.fph_srS02:update(n.S, o.S)

	local w = {E1 = ZOERG, E2 = logic.fph_srS02.Q, E3 = p.S}
	w.S = bAND3(w.E1, w.E2, w.E3)

	logic.fph_mTrigF_02:update(w.S)

	logic.fph_srR01:update(w.S, f.S)

	local k = {E1 = bNOT(w.S), E2 = ZR12NORUN, E3 = ZGNDI}
	k.S = bAND3(k.E1, k.E2, k.E3)

	local m = {E1 = logic.fph_srR01.Q, E2 = k.S}
	m.S = bAND(m.E1, m.E2)

	logic.fph_mTrigR_03:update(m.S)

	local t = {E1 = k.S, E2 = bNOT(logic.fph_mTrigR_03.OUT)}
	t.S = bAND(t.E1, t.E2)

	local u = {E1 = logic.fph_mTrigR_03.OUT, E2 = k.S}
	u.S = bAND(u.E1, u.E2)

	local x = {E1 = p.S, E2 = bNOT(logic.fph_srS02.Q), E3 = ZR1O2RUN}
	x.S = bAND3(x.E1, x.E2, x.E3)

	local z = {E1 = ZACS80KT, E2 = g.S}
	z.S = bAND(z.E1, z.E2)

	local aa = {E1 = bNOT(q.S), E2 = bNOT(e.S), E3 = bNOT(r.S)}
	aa.S = bAND3(aa.E1, aa.E2, aa.E3)

	ZPH1	= t.S
	ZPH2	= x.S
	ZPH3	= y.S
	ZPH4	= z.S
	ZPH5	= q.S
	ZPH6	= aa.S
	ZPH8	= v.S

	local bb = {E1 = r.S, E2 = bNOT(ZPH8)}
	bb.S = bAND(bb.E1, bb.E2)

	ZPH7	= bb.S
	ZPH9	= w.S
	ZPH10	= u.S

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

	A333DR_fws_grnd_flt_trans = bool2num[i.S]

end

function A333_ResetFlightPhase10()
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

	local a = {E1 = logic.fphIO_pulseF01.OUT, E2 = logic.fphIO_pulseF02.OUT, E3 = logic.fphIO_pulseF03.OUT, E4 = logic.fphIO_pulseF04.OUT, E5 = logic.fphIO_pulseF05.OUT}
	a.S = bOR5(a.E1, a.E2, a.E3, a.E4, a.E5)

	local b = {E1 = logic.fphIO_pulseF06.OUT, E2 = logic.fphIO_pulseF07.OUT, E3 = logic.fphIO_pulseF08.OUT, E4 = logic.fphIO_pulseF09.OUT, E5 = logic.fphIO_pulseF10.OUT}
	b.S = bOR5(b.E1, b.E2, b.E3, b.E4, b.E5)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	logic.fphIO_srR01:update(ZRCLUP, c.S)

	ZFPION = logic.fphIO_srR01.Q

end





function A333_fws.red_warning()

	local a = {E1 = WSTO, E2 = WVMOMMO, E3 = WVLE, E4 = NVFE1, E5 = NVFE2, E6 = NVFE4}
	a. S = bOR6(a.E1, a.E2, a.E3, a.E4, a.E5, a.E6)

	local b = {E1 = NVFE3, E2 = NVFE5, E3 = UE1FIRE, E4 = UE2FIRE, E5 = UAPUFIRE}
	b. S = bOR5(b.E1, b.E2, b.E3, b.E4, b.E5)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	WRW = c.S
	WWRW = c.S

end





function A333_fws.ap_off_voluntary()

	local a = {E1 = KAP1EC_1, E2 = KAP1EM_1}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = KAP2EC_2, E2 = KAP2EM_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = WCMWC, E2 = WFOMWC}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = c.S, E2 = bNOT(WRW)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = KID1APE, E2 = KID2APE}
	f.S = bOR(f.E1, f.E2)

	logic.apOffVolMtrig01:update(KID1APE)
	logic.apOffVolMtrig02:update(KID2APE)

	local g = {E1 = logic.apOffVolMtrig01.OUT, E2 = logic.apOffVolMtrig02.OUT}
	g.S = bOR(g.E1, g.E2)

	logic.apOffVolPulse01:update(f.S)

	local h = {E1 = e.S, E2 = logic.apOffVolPulse01.OUT}
	h.S = bOR(h.E1, h.E2)

	logic.apOffVolConf01:update(bNOT(d.S))

	local i = {E1 = logic.apOffVolConf01.OUT, E2 = h.S}
	i.S = bAND(i.E1, i.E2)

	logic.apOffVolPulse02:update(d.S)

	local j = {E1 = logic.apOffVolPulse02.OUT, E2 = g.S}
	j.S = bAND(j.E1, j.E2)

	logic.apOffVolMtrig03:update(j.S)
	logic.apOffVolMtrig09:update(i.S)
	logic.apOffVolMtrig10:update(logic.apOffVolMtrig09.OUT)

	local k = {E1 = logic.apOffVolMtrig03.OUT, E2 = bNOT(d.S), E3 = bNOT(logic.apOffVolMtrig10.OUT)}
	k.S = bAND3(k.E1, k.E2, k.E3)

	logic.apOffVolMtrig05:update(j.S)
	logic.apOffVolMtrig06:update(i.S)

	local l = {E1 = logic.apOffVolMtrig05.OUT, E2 = bNOT(d.S), E3 = bNOT(logic.apOffVolMtrig06.OUT)}
	l.S = bAND3(l.E1, l.E2, l.E3)

	logic.apOffVolMtrig07:update(j.S)
	logic.apOffVolMtrig08:update(i.S)

	local m = {E1 = logic.apOffVolMtrig07.OUT, E2 = bNOT(d.S), E3 = bNOT(logic.apOffVolMtrig08.OUT)}
	m.S = bAND3(m.E1, m.E2, m.E3)

	KAP1E = a.S
	KOAPE = d.S
	KAP2E = b.S
	KAPOA = k.S
	KAPOMW = l.S
	WAPOT = m.S

end













function A333_fws.nav_stall_warn()

	logic.stallConf01:update(WRCL)							-- false
	logic.stallPulse01:update(logic.stallConf01.OUT)
	logic.stallPulse02:update(NSTALL1)						-- sim/cockpit2/annunciators/stall_warning

	local a = {E1 = bNOT(logic.stallPulse01.OUT), E2 = NSTALL1}
	a.S = bAND(a.E1, a.E2)

	logic.stallPulse03:update(a.S)

	local b = {E1 = WEMERC, E2 = logic.stallSRRlatch01.Q}	--	WEMERC = false
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = logic.stallPulse02.OUT, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	logic.stallSRRlatch01:update(logic.stallPulse03.OUT, c.S)

	NSTALLW	= logic.stallSRRlatch01.Q

end









function A333_fws.nav_stall_warning()

	local a = {E1 = ZPH5, E2 = ZPH6, E3 = ZPH7}
	a. S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = NATEST, E2 = ZGND}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = logic.stallWarn_pulse01.OUT, E2 = NSTALLW}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = d.S, E2 = c.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = e.S, E2 = WEMERC}
	f.S = bAND(f.E1, f.E2)

	logic.stallWarn_pulse01:update(f.S)

	local g = {E1 = e.S, E2 = WWINDSDON}
	g.S = bOR(g.E1, g.E2)

	NSTALLWO	= e.S
	WBSTALL		= e.S
	WSTALL_S	= g.S
	WSTO		= g.S

	A333DR_fws_aco_stall = bool2num[e.S]

end







function A333_fws.auto_flight_low_energy()

	local a = {E1 = bNOT(KFACNOH_1), E2 = KLONRJ_1}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = bNOT(KFACNOH_2), E2 = KLONRJ_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = ZPH5, E2 = ZPH6, E3 = ZPH7}
	c.S = bOR3(c.E1, c.E2, c.E3)

	local d = {E1 = a.S, E2  = b.S}
	d.S = bOR(d.E1, d.E2)

	logic.lowEnergyMtrig01:update(d.S)
	logic.lowEnergyMtrig02:update(KSPEEDGEN)

	local e = {E1 = d.S, E2 = logic.lowEnergyMtrig01.OUT}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = c.S, E2 = e.S, E3 = bNOT(logic.lowEnergyMtrig02.OUT)}
	f.S = bAND3(f.E1, f.E2, f.E3)

	local g = {E1 = bNOT(NGPWSINHIB), E2 = f.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = f.S, E2 = logic.lowEnergyMtrig02.OUT}
	h.S = bOR(h.E1, h.E2)

	NSPDO = h.S

	A333DR_fws_aco_speed = bool2num[g.S]

end







function A333_fws.dh_dt_positive()

	local a = {E1 = NRADH_1_NCD, E2 = NRADH_1_INV}
	a.S = bOR(a.E1, a.E2)

	logic.dh_dt_pos_s01:update(a.S, NRADH_1, NRADH_2)

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

	local a = {E1 = NRADH_1_INV, E2 = NRADH_1_NCD}
	a.S = bOR(a.E1, a.E2)

	local aa = {E1 = NCBAC_1_INV, E2 = NCBAC_1_NCD}
	aa.S = bOR(aa.E1, aa.E2)

	local b = {E1 = WDH_2_INV, E2 = WDH_2_NCD}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = WDH_1_INV, E2 = WDH_1_NCD}
	c.S = bOR(c.E1, c.E2)

	logic.decHeightVal_s01:update(a.S, NRADH_2, NRADH_1)		-- Radio
	logic.decHeightVal_s02:update(aa.S, NFOBAC_2, NCBAC_1)		-- Baro

	local refHeightVal = (simDR_radio_altimeter_bug_ft_pilot > 0 and logic.decHeightVal_s01.out) or (simDR_baro_alt_bug_ft_pilot > -1000.00 and logic.decHeightVal_s02.out) or 0.0

	local d = {E1= WDH_1_VAL, E2 = bNOT(WDH_1_NCD), E3 = WDH_2_VAL, E4 = bNOT(WDH_2_NCD), E5 = logic.decHeightVal_comp01.out}
	d.S = bAND5(d.E1, d.E2, d.E3, d.E4, d.E5)

	local e = {E1 = b.S, E2 = c.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = d.S, E2 = WDH_1_NCD, E3 = WDH_1_INV}
	f.S = bOR3(f.E1, f.E2, f.E3)

	logic.decHeightVal_s03:update(f.S, WDH_1, WDH_2)

	NRHV 		= refHeightVal
	WDH2SELEC	= f.S
	NDHV		= logic.decHeightVal_s03.out
	NDINV		= e.S

end








function A333_fws.hundred_above()

	logic.hundrdAbvNum_01:update(NDHV, 105)
	logic.hundrdAbvNum_02:update(NDHV, 115)
	logic.hundrdAbvThreshold_01:update(NDHV)
	logic.hundrdAbvComp01:update(NRHV, logic.hundrdAbvNum_01.out)
	logic.hundrdAbvComp02:update(NRHV, logic.hundrdAbvNum_02.out)
	logic.hundrdAbvThreshold_02:update(NDHV)

	local a = {E1 = NRADH_1_INV, E2 = NRADH_1_NCD}
	a. S = bOR(a.E1, a.E2)

	local b = {E1 = NRADH_2_INV, E2 = NRADH_2_NCD}
	b. S = bOR(b.E1, b.E2)

	local c = {E1 = WDH100A, E2 = WDH100B}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = logic.hundrdAbvThreshold_01.out, E2 = logic.hundrdAbvComp01.out}
	d.S= bAND(d.E1, d.E2)

	local e = {E1 = bNOT(logic.hundrdAbvThreshold_01.out), E2 = logic.hundrdAbvComp02.out}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = a.S, E2 = b.S}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = d.S, E2 = e.S}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = logic.hundrdAbvThreshold_02.out, E2 = NACOINIB, E3 = NDINV, E4 = f.S}
	h.S = bOR4(h.E1, h.E2, h.E3, h.E4)

	logic.hundrdAbvConf01:update(g.S)
	logic.hundrdAbvMtrig01:update(logic.hundrdAbvConf01.OUT)
	logic.hundrdAbvSRRlatch01:update(NHUNABGEN, logic.hundrdAbvMtrig01.OUT)

	local i = {E1 = bNOT(logic.hundrdAbvSRRlatch01.Q), E2 = logic.hundrdAbvMtrig01.OUT}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = i.S, E2 = c.S, E3 = bNOT(h.S)}
	j.S = bAND3(j.E1, j.E2, j.E3)

	local k = {E1 = NHUNABGEN, E2 = j.S}
	k.S = bOR(k.E1, k.E2)

	WHACOMP 		= logic.hundrdAbvSRRlatch01.Q
	NDHHABOVE 		= k.S
	WHAGENERATED	= j.S
	WHAMTRIG 		= logic.hundrdAbvMtrig01.OUT

	A333DR_fws_aco_hndrd_abv = bool2num[j.S]

end









function A333_fws.dh_minimum()

	logic.dhNum_01:update(NDHV, 5)
	logic.dhNum_02:update(NDHV, 15)
	logic.dhThreshold01:update(NDHV)
	logic.dhComp01:update(NRHV, logic.dhNum_01.out)
	logic.dhComp02:update(NRHV, logic.dhNum_02.out)
	logic.dhThreshold02:update(NDHV)

	local a = {E1 = NRADH_1_INV, E2 = NRADH_1_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = NRADH_2_INV, E2 = NRADH_2_NCD}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = WDHA, E2 = WDHB}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = logic.dhThreshold01.out, E2 = logic.dhComp01.out}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = bNOT(logic.dhThreshold01.out), E2 = logic.dhComp02.out}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = a.S, E2 = b.S}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = d.S, E2 = e.S}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = logic.dhThreshold02.out, E2 = NACOINIB, E3 = NDINV, E4 = f.S}
	h.S = bOR4(h.E1, h.E2, h.E3, h.E4)

	logic.dhConf01:update(g.S)
	logic.dhTrig01:update(logic.dhConf01.OUT)
	logic.dhSRRlatch01:update(NMINGEN, logic.dhTrig01.OUT)

	local i = {E1 = bNOT(logic.dhSRRlatch01.Q), E2 = logic.dhTrig01.OUT}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = i.S, E2 = c.S, E3 = bNOT(h.S)}
	j.S = bAND3(j.E1, j.E2, j.E3)

	local k = {E1 = NDHHABOVE, E2 = NMINGEN, E3 = j.S}
	k.S = bOR3(k.E1, k.E2, k.E3)

	WDHCOMP 		= logic.dhSRRlatch01.Q
	WDHGEN 			= k.S
	NDHGEN 			= k.S
	WDHGENERATED	= j.S
	WDHMTRIG 		= logic.dhTrig01.OUT
	WDHINF3FT 		= logic.dhThreshold02.out

	A333DR_fws_aco_minimum = bool2num[j.S]

end








function A333_fws.n1_approach()

	logic.n1ApprThreshold01:update(JR1N1_1A)
	logic.n1ApprThreshold02:update(JR1N1_1B)
	logic.n1ApprThreshold03:update(JR2N1_2A)
	logic.n1ApprThreshold04:update(JR2N1_2B)
	logic.n1ApprThreshold05:update(JR1N1_1A)
	logic.n1ApprThreshold06:update(JR1N1_1B)
	logic.n1ApprThreshold07:update(JR2N1_2A)
	logic.n1ApprThreshold08:update(JR2N1_2B)

	local a = {E1 = JR1N1_1A_VAL, E2 = logic.n1ApprThreshold05.out}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = JR1N1_1B_VAL, E2 = logic.n1ApprThreshold06.out}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = JR2N1_2A_VAL, E2 = logic.n1ApprThreshold07.out}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = JR2N1_2B_VAL, E2 = logic.n1ApprThreshold08.out}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = JR1N1_1A_VAL, E2 = logic.n1ApprThreshold01.out}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = JR1N1_1B_VAL, E2 = logic.n1ApprThreshold02.out}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = JR2N1_2A_VAL, E2 = logic.n1ApprThreshold03.out}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = JR2N1_2B_VAL, E2 = logic.n1ApprThreshold04.out}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = a.S, E2 = b.S}
	i.S = bOR(i.E1, i.E2)

	local j = {E1 = c.S, E2 = d.S}
	j.S = bOR(j.E1, j.E2)

	local k = {E1 = e.S, E2 = f.S}
	k.S = bOR(k.E1, k.E2)

	local l = {E1 = g.S, E2 = h.S}
	l.S = bOR(l.E1, l.E2)

	local m = {E1 = i.S, E2 = JML2OFF}
	m.S = bAND(m.E1, m.E2)

	local n = {E1 = j.S, E2 = JML1OFF}
	n.S = bAND(n.E1, n.E2)

	local o = {E1 = l.S, E2 = l.S}
	o.S = bAND(o.E1, o.E2)

	local p = {E1 = m.S, E2 = n.S}
	p.S = bOR(p.E1, p.E2)

	local q = {E1 = o.S, E2 = p.S}
	q.S = bOR(q.E1, q.E2)

	JRN1AP = q.S

end








function A333_fws.rh_gear_extended()

	local a = {E1 = bNOT(GRGNOE_1), E2 = bNOT(GRGNOE_2)}
	a.S = bAND(a.E1, a.E2)

	GRGE = a.S

end






function A333_fws.lh_gear_extended()

	local a = {E1 = bNOT(GLGNOE_1), E2 = bNOT(GLGNOE_2)}
	a.S = bAND(a.E1, a.E2)

	GLGE = a.S

end





function A333_fws.gear_extended()

	local a = {E1 = bNOT(GNGNOE_1), E2 = bNOT(GNGNOE_2)}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = GLGE, E2 = a.S, E3 = GRGE}
	b.S = bOR3(b.E1, b.E2, b.E3)

	GLGEXT = b.S

end





function A333_fws.gear_not_extended()

	local a = {E1 = GLGNOE_1, E2 = GLGNOE_2 }
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = GRGNOE_1, E2 = GRGNOE_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = GNGNOE_1, E2 = GNGNOE_2}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S, E3 = c.S}
	d.S = bOR3(d.E1, d.E2, d.E3)

	GLGNE = d.S

end





function A333_fws.lh_gear_locked_up()

	local a = {E1 = bNOT(GLGNLUP_1), E2 = bNOT(GLGNLUP_2)}
	a.S = bAND(a.E1, a.E2)

	GLGLUP = a.S

end





function A333_fws.rh_gear_locked_up()

	local a = {E1 = bNOT(GRGNLUP_1), E2 = bNOT(GRGNLUP_2)}
	a.S = bAND(a.E1, a.E2)

	GRGLUP = a.S

end





function A333_fws.gear_locked_up()

	local a = {E1 = GNGNLUP_1, E2 = GNGNLUP_2}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = GLGLUP, E2 = a.S, E3 = GRGLUP}
	b.S = bAND3(b.E1, b.E2, b.E3)

	GGLUP = b.S

end





function A333_fws.gear_not_uplck_and_not_sel_dn()

	local a = {E1 = GLGNLUPNSD_1, E2 = GLGNLUPNSD_2}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = GRGNLUPNSD_1, E2 = GRGNLUPNSD_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = GNGNLUPNSD_1, E2 = GNGNLUPNSD_2}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S, E3 = c.S}
	d.S = bOR3(d.E1, d.E2, d.E3)

	GGNLUPANSD = d.S

end





function A333_fws.gear_downlocked()

	local a = {E1 = GLGDL_1, E2 = GLGDL_2}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = GRGDL_1, E2 = GRGDL_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = GNGDL_1, E2 = GNGDL_2}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S, E3 = c.S}
	d.S = bAND3(d.E1, d.E2, d.E3)

	GLGDNLKD = d.S
	A333DR_fws_landing_gear_down = bool2num[GLGDNLKD]

end





function A333_fws.gear_not_locked()

	local d = {E1 = GLLGNOLK, E2 = GRLGNOLK, E3 = GNLGNOLK}
	d.S = bOR3(d.E1, d.E2, d.E3)

	GLGNLKD = d.S

end






function A333_fws.gear_not_dnlck_and_sel_dn()

	local a = {E1 = GLGNLDSD_1, E2 = GLGNLDSD_2}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = GRGNLDSD_1, E2 = GRGNLDSD_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = GNGNLDSD_1, E2 = GNGNLDSD_2}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S, E3 = c.S}
	d.S = bOR3(d.E1, d.E2, d.E3)

	GLGNLDSD = d.S

end




function A333_fws.hyd_abnorm_lo_pr()

	local aa = {E1 = ZPH1, E2 = ZPH2, E3 = ZPH9, E4 = ZPH10}
	aa.S = bOR4(aa.E1, aa.E2, aa.E3, aa.E4)

	local a = {E1 = bNOT(JR1NORUN), E2 = bNOT(JR2NORUN)}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = JR2NORUN, E2 = bNOT(ZGND), E3 = JR1NORUN}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = bNOT(JR2NORUN), E2 = bNOT(aa.S)}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = bNOT(JR1NORUN), E2 = bNOT(aa.S)}
	d.S = bOR(d.E1, d.E2)

	logic.hydLoPrConf01:update(a.S)
	logic.hydLoPrConf02:update(b.S)
	logic.hydLoPrConf03:update(c.S)
	logic.hydLoPrConf04:update(d.S)

	local e = {E1 = logic.hydLoPrConf01.OUT, E2 = logic.hydLoPrConf02.OUT}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = HYSLP, E2 = logic.hydLoPrConf03.OUT}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = HGSLP, E2 = logic.hydLoPrConf04.OUT}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = HBSLP, E2 = e.S}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = h.S, E2 = f.S}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = h.S, E2 = g.S}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = f.S, E2 = g.S}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = j.S, E2 = i.S}
	l.S = bOR(l.E1, l.E2)

	local m = {E1 = i.S, E2 = k.S}
	m.S = bOR(m.E1, m.E2)

	local n = {E1 = j.S, E2 = k.S}
	n.S = bOR(n.E1, n.E2)

	HBSYSLP	= h.S
	WWBHLP	= h.S
	HYSYSLP	= f.S
	WWYHLP	= f.S
	HGSYSLP	= g.S
	WWGHLP	= g.S
	HBDF	= l.S
	HYDF	= m.S
	HGDF	= n.S

end






function A333_fws.hyd_not_recovered()

	local b = {E1 = HBSYSLP, E2 = HYSYSLP, E3 = HGSYSLP}
	b.S = bOR3(b.E1, b.E2, b.E3)

	local c = {E1 = HBSYSLP, E2 = HGSYSLP, E3 = bNOT(SSLTSA)}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = HYSYSLP, E2 = HGSYSLP, E3 = bNOT(SFLPSE), E4 = bNOT(NGPWSFMOF), E5 = bNOT(EEMER)}
	d.S = bAND5(d.E1, d.E2, d.E3, d.E4, d.E5)

	local hydNotRecMT01 = {E1 = HGSYSLP, E2 = HYSYSLP, E3 = HBSYSLP, E4 = b.S}
	hydNotRecMT01.S = bMT(2, hydNotRecMT01.E1, hydNotRecMT01.E2, hydNotRecMT01.E3, hydNotRecMT01.E4)

	HTHOUT		= hydNotRecMT01.S
	HGBLP		= c.S
	HGPWSFOP	= d.S

end








function A333_fws.oil_temp_advisory()

	local a = {E1 = JR1OT_INV, E2 = JR1OT_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = JR1OTAD_1_INV, E2 = JR1OTAD_1_NCD}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = JR2OT_INV, E2 = JR2OT_NCD}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = JR2OTAD_2_INV, E2 = JR2OTAD_2_NCD}
	d.S = bOR(d.E1, d.E2)

	logic.oilTempAdvSwitcg01:update(b.S, JR1OTAD_1, JR1OTAD_2)
	logic.oilTempAdvSwitcg02:update(d.S, JR2OTAD_2, JR2OTAD_1)
	logic.oilTempAdvComp01:update(JR1OT, logic.oilTempAdvSwitcg01.out)
	logic.oilTempAdvComp02:update(JR2OT, logic.oilTempAdvSwitcg02.out)

	local e = {E1 = JR1OTAD_2_INV, E2 = JR1OTAD_2_NCD}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = JR2OTAD_1_INV, E2 = JR2OTAD_1_NCD}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = b.S, E2 = e.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = d.S, E2 = f.S}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = bNOT(a.S), E2 = logic.oilTempAdvComp01.out, E3 = bNOT(g.S), E4 = WRRT}
	i.S = bAND4(i.E1, i.E2, i.E3, i.E4)

	local j = {E1 = WRRT, E2 = bNOT(c.S), E3 = logic.oilTempAdvComp02.out, E4 = bNOT(h.S)}
	j.S = bAND4(j.E1, j.E2, j.E3, j.E4)

	JR1OTAD = i.S
	JR2OTAD	= j.S

end







function A333_fws.oil_overtemp()

	local a = {E1 = JR1OT_INV, E2 = JR1OT_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = JR1OOT_1_INV, E2 = JR1OOT_1_NCD}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = JR2OT_INV, E2 = JR2OT_NCD}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = JR2OOT_2_INV, E2 = JR2OOT_2_NCD}
	d.S = bOR(d.E1, d.E2)

	logic.oilOvertempSwitch01:update(b.S, JR1OOT_1, JR1OOT_2)
	logic.oilOvertempSwitch02:update(d.S, JR2OOT_2, JR2OOT_1)
	logic.oilOvertempComp01:update(JR1OT, logic.oilOvertempSwitch01.out)
	logic.oilOvertempComp02:update(JR2OT, logic.oilOvertempSwitch02.out)

	local e = {E1 = JR1OOT_2_INV, E2 = JR1OOT_2_NCD}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = JR2OOT_1_INV, E2 = JR2OOT_1_NCD}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = b.S, E2 = e.S}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = d.S, E2 = f.S}
	h.S = bAND(h.E1, h.E2)

	local i = {E1 = bNOT(a.S), E2 = logic.oilOvertempComp01.out, E3 = bNOT(g.S), E4 = WRRT}
	i.S = bAND4(i.E1, i.E2, i.E3, i.E4)

	local j = {E1 = WRRT, E2 = bNOT(c.S), E3 = logic.oilOvertempComp02.out, E4 = bNOT(h.S)}
	j.S = bAND4(j.E1, j.E2, j.E3, j.E4)

	JR1OOT = i.S
	JR2OOT = j.S

end






function A333_fws.engines_out()

	logic.engOutpulse01:update(UE2FPBOUT)

	local a = {E1 = UE2FPBOUT, E2 = logic.engOutpulse01.OUT}
	a.S = bAND(a.E1, a.E2)

	logic.engOutConf02:update(a.S)

	local b = {E1 = bNOT(JR1AIDLE_1A), E2 = bNOT(JR1AIDLE_1B)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = bNOT(JR2AIDLE_2A), E2 = bNOT(JR2AIDLE_2B)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = b.S, E2 = c.S}
	d.S = bAND(d.E1, d.E2)

	logic.engOutConf01:update(d.S)

	local e = {E1 = JML1OFF, E2 = bNOT(JML1ON), E3 = JML1ON_VAL, E4 = JML2ON_VAL, E5 = bNOT(JML2ON), E6 = JML2OFF}
	e.S = bAND6(e.E1, e.E2, e.E3, e.E4, e.E5, e.E6)

	local f = {E1 = UE1FPBOUT, E2 = UE2FPBOUT}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = logic.engOutConf01.OUT, E2 = e.S, E3 = f.S}
	g.S = bOR3(g.E1, g.E2, g.E3)

	local h = {E1 = bNOT(ZGND), E2 = g.S, E3 = bNOT(logic.engOutConf02.OUT), E4 = WRRT}
	h.S = bAND4(h.E1, h.E2, h.E3, h.E4)

	JENGSOUTR = h.S
	A333DR_ecam_testNum[0] = bool2num[h.S]

end








function A333_fws.gen_reset()

	logic.genResetPulse01:update(EGN1PBOF)
	logic.genResetPulse02:update(EGN2PBOF)
	logic.genResetPulse03:update(EGN1PBOF)
	logic.genResetPulse04:update(EGN2PBOF)

	local a = {E1 = logic.genResetPulse01.OUT, E2 = EEMER, E3 = EBTIEPBOF}
	a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = EBTIEPBOF, E2 = EEMER, E3 = logic.genResetPulse02.OUT}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = EEMER, E2 = logic.genResetPulse03.OUT}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = EEMER, E2 = logic.genResetPulse04.OUT}
	d.S = bAND(d.E1, d.E2)

	logic.genResetSRR01:update(a.S, EEMER)
	logic.genResetSRR02:update(b.S, EEMER)
	logic.genResetSRR03:update(c.S, EEMER)
	logic.genResetSRR04:update(d.S, EEMER)

	local e = {E1 = logic.genResetSRR01.Q, E2 = logic.genResetSRR02.Q}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = logic.genResetPulse03.OUT, E2 = logic.genResetPulse04.OUT}
	f.S = bAND(f.E1, f.E2)

	EGENRESET	= bNOT(e.S)
	EGEN12R		= bNOT(f.S)

end






function A333_fws.signs_on()

	local a = {E1 = CNOSMOK, E2 = CFSBLT, E3 = XCNOPEDINS}
	a.S = bAND3(a.E1, a.E2, a.E3)

	CSIGNSONP = a.S

end





function A333_fws.rudder_trim_pos()

	logic.rudTrimThreshold01:update(KRTP_1)
	logic.rudTrimThreshold02:update(KRTP_1)
	logic.rudTrimThreshold03:update(KRTP_2)
	logic.rudTrimThreshold04:update(KRTP_2)

	local a = {E1 = KRTP_1_INV, E2 = KRTP_1_NCD, E3 = KFACNOH_1}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = KRTP_2_INV, E2 = KRTP_2_NCD, E3 = KFACNOH_2}
	b.S = bOR3(b.E1, b.E2, b.E3)

	local c = {E1 = logic.rudTrimThreshold01.out, E2 = bNOT(a.S)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = bNOT(a.S), E2 = logic.rudTrimThreshold02.out}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = logic.rudTrimThreshold03.out, E2 = bNOT(b.S)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = bNOT(b.S), E2 = logic.rudTrimThreshold04.out}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = c.S, E2 = d.S}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = e.S, E2 = f.S}
	h.S = bOR(h.E1, h.E2)

	local i = {E1 = g.S, E2 = h.S}
	i.S = bOR(i.E1, i.E2)

	SRUDTC = i.S

end





function A333_fws.elevator_trim_pos()

	logic.elevTrimThreshold01:update(STAB1POS_1)
	logic.elevTrimThreshold02:update(STAB1POS_1)
	logic.elevTrimThreshold03:update(STAB1POS_2)
	logic.elevTrimThreshold04:update(STAB1POS_2)

	local a = {E1 = STAB1POS_1_INV, E2 = STAB1POS_1_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = STAB1POS_2_INV, E2 = STAB1POS_2_NCD }
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = logic.elevTrimThreshold01.out, E2 = bNOT(a.S)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = bNOT(a.S), E2 = logic.elevTrimThreshold02.out}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = logic.elevTrimThreshold03.out, E2 = bNOT(b.S)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = bNOT(b.S), E2 = logic.elevTrimThreshold04.out}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = c.S, E2 = d.S}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = e.S, E2 = f.S}
	h.S = bOR(h.E1, h.E2)

	local i = {E1 = g.S, E2 = h.S}
	i.S = bOR(i.E1, i.E2)

	local j = {E1 = WRRT, E2 = i.S}
	j.S = bAND(j.E1, j.E2)

	SPCT1A330 = j.S
	SPCT2A330 = j.S

end





function A333_fws.one_door_not_closed()

	local a = {E1 = DLFCDNC, E2 = DRFCDNC, E3 = DLMCDNC, E4 = DRMCDNC, E5 = DLEEDNC, E6 = DREEDNC, E7 = DLACDNC, E8 = DRACDNC}
	a.S = bOR8(a.E1, a.E2, a.E3, a.E4, a.E5, a.E6, a.E7, a.E8)

	local b = {E1 = a.S, E2 = bNOT(EDC1OF)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = b.S, E2 = DAVCDNC}
	c.S = bOR(c.E1, c.E2)

	DODNC = c.S

end






function A333_fws.config_test_normal()

	local a = {E1 = bNOT(GBRKOVHT), E2 = bNOT(SRUDTNTO), E3 = bNOT(SSLTNTO), E4 = bNOT(SFLPNTO), E5 = bNOT(SPTNTO), E6 = bNOT(SSBNTO), E7 = bNOT(DODNC), E8 = bNOT(SSTTO)}
	a.S = bAND8(a.E1, a.E2, a.E3, a.E4, a.E5, a.E6, a.E7, a.E8)

	local b = {E1 = CCR1, E2 = CCR2}
	b.S = bOR(b.E1, b.E2)

	WCABR = b.S
	WCABNR = bNOT(b.S)

	logic.cfgTstNmlConf01:update(a.S)

	WTOCNORM = logic.cfgTstNmlConf01.OUT

end







function A333_fws.speed_brake_logic()

	local a = {E1 = JR1MINPWR_1A_VAL, E2 = bNOT(JR1MINPWR_1A)}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = JR1MINPWR_1B_VAL, E2 = bNOT(JR1MINPWR_1B)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = JR2MINPWR_2A_VAL, E2 = bNOT(JR2MINPWR_2A)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = JR2MINPWR_2B_VAL, E2 = bNOT(JR2MINPWR_2B)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = ZPH6, E2 = ZPH7}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = SSPBR_1, E2 = SSPBR_2}
	f.S = bOR(f.E1, f.E2)

	logic.cfgTstNmlConf03:update(f.S)

	local g = {E1 = a.S, E2 = b.S}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = c.S, E2 = d.S}
	h.S = bOR(h.E1, h.E2)

	local i = {E1 = bNOT(JR1NORUN),E2 = g.S}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = h.S, E2 = bNOT(JR2NORUN)}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = i.S, E2 = j.S}
	k.S = bOR(k.E1, k.E2)

	local l = {E1 = k.S,E2 = WRRT}
	l.S = bAND(l.E1, l.E2)

	local o = {E1 = logic.cfgTstNmlConf03.OUT, E2 = bNOT(l.S)}
	o.S = bAND(o.E1, o.E2)

	logic.cfgTstNmlConf01:update(o.S)

	local m = {E1 = e.S, E2 = logic.cfgTstNmlConf03.OUT, E3 = bNOT(logic.cfgTstNmlConf01.OUT)}
	m.S = bAND3(m.E1, m.E2, m.E3)

	local n = {E1 = bNOT(e.S), E2 = m.S}
	n.S = bOR(n.E1, n.E2)

	logic.cfgTstNmlConf02:update(m.S)

	SASPDBRK = n.S
	SSPDBRKC = logic.cfgTstNmlConf02.OUT

end







function A333_fws.cabin_ready()

	local a = {E1 = ZPH10, E2 = DODNC}
	a.S = bOR(a.E1, a.E2)

	if a.S then
		CCR1 = false
		CCR2 = false
	else
		CCR1 = true
		CCR2 = true
	end

end





function A333_fws.eng1_reverse_unstowed()

	local a = {E1 = JR1REVUNL_1A, E2 = JR1REVUNL_1B}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = JR1REVD_1A, E2 = JR1REVD_1B}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = a.S, E2 = bNOT(EDC1OF)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = c.S, E2 = b.S}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = d.S, E2 = WRRT}
	e.S = bAND(e.E1, e.E2)

	JR1RUSTWD = e.S

end







function A333_fws.eng2_reverse_unstowed()

	local a = {E1 = JR2REVUNL_2A, E2  = JR2REVUNL_2B}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = JR2REVD_2A, E2 = JR2REVD_2B}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = a.S, E2 = bNOT(EDC2OF)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = c.S, E2 = b.S}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = d.S, E2 = WRRT}
	e.S = bAND(e.E1, e.E2)

	JR2RUSTWD = e.S

end







function A333_fws.bleed_not_avail()

	local a = {E1 = BE1PRVACC_1, E2  = BE1PRVACC_2}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = BE1BPBOF_1, E2  = BE1BPBOF_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = BE2PRVACC_1, E2  = BE2PRVACC_2}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = BE2BPBOF_1, E2  = BE2BPBOF_2}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = a.S, E2 = b.S, E3 = JR1NORUN}
	e.S = bOR3(e.E1, e.E2, e.E3 )

	local f = {E1 = c.S, E2 = d.S, E3 = JR2NORUN}
	f.S = bOR3(f.E1, f.E2, f.E3 )

	local g = {E1 = e.S, E2 = f.S}
	g.S = bOR(g.E1, g.E2)

	BB1NA = e.S
	BB2NA = f.S
	BBNA = g.S

end






function A333_fws.LorR_air_bleed_avail()

	local a = {E1 = BAPUBPBOF_1_VAL, E2 = bNOT(BAPUBPBOF_1)}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = bNOT(BAPUBPBOF_2), E2 = BAPUBPBOF_2_VAL}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = BXFVFO_1, E2 = BXFVFO_2}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = QAVAIL, E2 = d.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = c.S, E2 = bNOT(BB2NA)}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = bNOT(BB1NA), E2 = e.S, E3 = f.S}
	g.S = bOR3(g.E1, g.E2, g.E3)

	local h = {E1 = bNOT(BB1NA), E2 = e.s}
	h.S = bOR(h.E1, h.E2)

	local i = {E1 = h.S, E2 = c.S}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = i.S, E2 = bNOT(BB2NA)}
	j.S = bOR(j.E1, j.E2)

	local k = {E1 = g.S, E2 = bNOT(e.S)}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = bNOT(e.S), E2 = j.S}
	l.S = bAND(l.E1, l.E2)

	AB1AVAIL = g.S
	AB1WAIAV = k.S
	AB2AVAIL = j.S
	AB2WAIAV = l.S

end







function A333_fws.ai_aft_EngShutdown_proc()

	local a = {E1 = bNOT(ZGND), E2 = IWAIPBON}
	a.S = bAND(a.E1, a.E2)

	logic.procAftEngShutDwnPulse01:update(a.S)

	local b = {E1 = JR1SD, E2 = JR2SD}
	b.S = bXOR(b.E1, b.E2)

	local c = {E1 = UE1FPBOUT, E2 = UE2FPBOUT}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = BXFVFC_1, E2 = bNOT(BXFVFC_1_INV)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = BXFVFC_2, E2 = bNOT(BXFVFC_2_INV)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = d.S, E2 = e.S}
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = logic.procAftEngShutDwnPulse01.OUT, E2 = b.S, E3 = bNOT(c.S), E4 = f.S}
	g.S = bAND4(g.E1, g.E2, g.E3, g.E4)

	logic.procAftEngShutDwnPulse02:update{ZPH1}

	local h = {E1 = bNOT(f.S), E2 = bNOT(IWAION), E3 = logic.procAftEngShutDwnPulse02.OUT}
	h.S = bOR3(h.E1, h.E2, h.E3)

	logic.procAftEngShutDwnSRR01:update(g.S, h.S)
	logic.procAftEngShutDwnConf01:update(logic.procAftEngShutDwnSRR01.Q)

	IPROCWAIESD = logic.procAftEngShutDwnConf01.OUT

end









function A333_fws.ai_vlv_closed_fault_R()

	logic.aiRvlvClsdFltConf02:update(ZPH1)
	logic.aiRvlvClsdFltConf03:update(IWAIPBON)

	local a = {E1 = bNOT(ZGND), E2 = IWAIPBON}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = ZGND, E2 = bNOT(logic.aiRvlvClsdFltConf03.OUT)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = IRWAILP, E2 = IRWAIVC}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = c.S, E2 = IWAIPBON, E3 = d.S, E4 = AB2AVAIL}
	e.S = bAND4(e.E1, e.E2, e.E3, e.E4)

	logic.aiRvlvClsdFltConf01:update(e.S)

	local f = {E1 = bNOT(IRWAIVC), E2 = AB2AVAIL, E3 = IWAION}
	f.S = bAND3(f.E1, f.E2, f.E3)

	local g = {E1 = f.S, E2 = logic.aiRvlvClsdFltConf02.OUT}
	g.S = bOR(g.E1, g.E2)

	logic.aiRvlvClsdFltsrS01:update(logic.aiRvlvClsdFltConf01.OUT, g.S)

	IRVCLSDF = logic.aiRvlvClsdFltsrS01.Q

end







function A333_fws.xbleed_vlv_locked_open()

	local a = {E1 = BXFVCAD_1, E2 = BXFVCAD_2}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = BXFVCMD_1, E2 = BXFVCMD_2}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = a.S, E2 = bNOT(EDC2OF)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = c.S, E2 = b.S}
	d.S = bOR(d.E1, d.E2)

	BXFVCD = d.S

end








function A333_fws.bleed_avoid_icing()

	logic.avoidIcingConf01:update(IXBAIC)
	logic.avoidIcingMTrig01:update(IWAION)
	logic.avoidIcingPulse01:update(ZPH1)

	local a = {E1 = BE1LOTEMP_1, E2 = BE1LOTEMP_2}
	a.S = bOR(a.E1, a.E2)

	logic.avoidIcingConf03:update(a.S)

	local b = {E1 = BE2LOTEMP_1, E2 = BE2LOTEMP_2}
	b.S = bOR(b.E1, b.E2)

	logic.avoidIcingConf04:update(b.S)

	local c = {E1 = BLWL, E = BRWL, E3 = BRPL, E4 = BLPL}
	c.S = bOR4(c.E1, c.E2, c.E3, c.E4)

	logic.avoidIcingConf02:update(c.S)

	local d = {E1 = logic.avoidIcingConf04.OUT, E2 = logic.avoidIcingConf03.OUT, E3 = bNOT(ZGND)}
	d.S = bAND3(d.E1, d.E2, d.E3)

	local e = {E1 = bNOT(ZGND), E2 = logic.avoidIcingConf03.OUT, E3 = logic.avoidIcingMTrig01.OUT}
	e.S = bAND3(e.E1, e.E2, e.E3)

	local f = {E1 = bNOT(ZGND), E2 = logic.avoidIcingMTrig01.OUT, E3 = logic.avoidIcingConf04.OUT}
	f.S = bAND3(f.E1, f.E2, f.E3)

	local g = {E1 = bNOT(logic.avoidIcingConf04.OUT), E2 = AB1WAIAV, E3 = logic.avoidIcingPulse01.OUT}
	g.S = bOR3(g.E1, g.E2, g.E3)

	logic.avoidIcingSRR02:update(f.s, g.S)

	local h = {E1 = bNOT(logic.avoidIcingConf03.OUT), E2 = AB2WAIAV, E3 = logic.avoidIcingPulse01.OUT}
	h.S = bOR3(h.E1, h.E2, h.E3)

	logic.avoidIcingSRR01:update(e.S, h.S)

	local i = {E1 = logic.avoidIcingConf01.OUT, E2 = logic.avoidIcingConf02.OUT, E3 = d.S, E4 = logic.avoidIcingSRR01.Q, E5 = logic.avoidIcingSRR02.Q}
	i.S = bOR5(i.E1, i.E2, i.E3, i.E4, i.E5)

	BBAIC = i.S

end








function A333_fws.wai_avoid_icing()

	local a = {E1 = IRVCLSDF, E2 = ILVCLSDF}
	a.S = bOR(a.E1, a.E2)

	IWAIAIC = a.S

end





function A333_fws.wai_etops_power_supply()

	local a = {E1 = EDC1OF, E2 = bNOT(WMBE)}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = WMBE, E2 = EDCBSSCOF}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = a.S, E2 = b.S}
	c.S = bOR(c.E1, c.E2)

	IWAIE = c.S

end







-- LOGIC LA00600 (FWC MONITOR)
function A333_fws.status_computed()

	ZLSTSC = false
	ZAPSTSC = false
	ZPSTSC = false
	ZISTSC = false
	ZISSTSC = false

	for _, msg in pairs(A333_sts_msg) do

		if msg.Type == 0 and msg.Video.IN == 1 then ZLSTSC = true
		elseif msg.Type == 1 and msg.Video.IN == 1 then ZAPSTSC = true
		elseif msg.Type == 2 and msg.Video.IN == 1 then ZPSTSC = true
		elseif msg.Type == 3 and msg.Video.IN == 1 then ZISTSC = true
		elseif msg.Type == 5 and msg.Video.IN == 1 then ZISSTSC = true
		end

	end

end









-- LOGIC LA00610 (STAUS AUTO-CALL IN APPROACH)
function A333_fws.status_auto_call_approach()

	local a = {E1 = ZPH6, E2 = ZPH7}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = bNOT(SS0F0_1_INV), E2 = bNOT(SS00F00_1)}
	b.S = bAND(b.E1, b.E2)

	logic.stsAutoCallPulse01:update(b.S)

	local c = {E1 = bNOT(SS0F0_2_INV), E2 = bNOT(SS00F00_2)}
	c.S = bAND(c.E1, c.E2)

	logic.stsAutoCallPulse02:update(c.S)

	local d = {E1 = ZLSTSC, E2 = ZAPSTSC, E3 = ZPSTSC, E4 = ZSTSOEBPC, E5 = ZISTSC, E6 = ZISSTSC}
	d.S = bOR6(d.E1, d.E2, d.E3, d.E4, d.E5, d.E6)

	local e = {E1 = logic.stsAutoCallPulse01.OUT, E2 = logic.stsAutoCallPulse02.OUT}
	e.S = bOR(e.E1, e.E2)

	local f = {E1 = e.S, E2 = d.S, E3 = a.S}
	f.S = bAND3(f.E1, f.E2, f.E3)

	local g = {E1 = f.S, E2 = bNOT(ZSINGDIS)}
	g.S = bAND(g.E1, g.E2)

	local h = {E1 = f.S, E2 = ZSINGDIS}
	h.S = bAND(h.E1, h.E2)

	logic.stsAutoCallSRR01:update(h.s, ZSTSPD)

	ZSTSCAPPR = g.S
	ZSTSRPSD = logic.stsAutoCallSRR01.Q

end






-- LOGIC LA00620 (STATUS REMINDERS)
function A333_fws.status_reminders()

	local a = {E1 = ZPH2, E2 = ZPH1}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = ZCCSTSC, E2 = a.S}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = ZPH1, E2 = ZMSTSC}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = ZPH10, E2 = ZMSTSC}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = ZSTSOEBPC, E2 = ZLSTSC, E3 = ZAPSTSC, E4 = ZPSTSC}
	e.S = bOR4(e.E1, e.E2, e.E3, e.E4)

	local f = {E1 = ZISTSC, E2 = ZISSTSC, E3 = b.S, E4 = d.S, E5 = c.S}
	f.S = bOR5(f.E1, f.E2, f.E3, f.E4, f.E5)

	local g = {E1 = d.S, E2 = ZSTSRPSD}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = ZCMEMD, E2 = ZLMEMD}
	h.S = bOR(h.E1, h.E2)

	local i = {E1 = e.S, E2 = f.S}
	i.S = bOR(i.E1, i.E2)

	local j = {E1 = bNOT(ZSTSPD), E2 = h.S, E3 = ZRMEMD}
	j.S = bAND3(j.E1, j.E2, j.E3)

	local k = {E1 = i.S, E2 = bNOT(g.S), E3 = j.S}
	k.S = bAND3(k.E1, k.E2, k.E3)

	local l = {E1 = j.S, E2 = i.S, E3 = g.S}
	l.S = bAND3(l.E1, l.E2, l.E3)

	local m = {E1 = k.S, E2 = l.S}
	m.S = bOR(m.E1, m.E2)

	ZSTSREMS = k.S
	ZNOSTSREM = bNOT(m.S)
	ZSTSREMP = l.Sg

	A333DR_ecam_ewd_show_sts = bool2num[ZSTSREMS]

end







-- LOGIC LA00625 (FWC CLEAR STATUS)
function A333_fws.clear_status()

	logic.clearStsConf01:update(GLGDNLKD)
	logic.clearStsPulse01:update(logic.clearStsConf01.OUT)

	local a = {E1 = logic.clearStsPulse01.OUT, E2 = bNOT(ZMSTSPD)}
	a.S = bAND(a.E1, a.E2)

	ZFCLRSTS = a.S

end





-- LOGIC LA00630 (SYSTEM PAGE CALL INHIBIT)
function A333_fws.sys_page_call_inhib()

	logic.sysPgCallInhibFT01:update(NRADH_1)
	logic.sysPgCallInhibFT02:update(NRADH_2)

	local a = {E1 = bNOT(NRADH_1_INV), E2 = NRADH_1, E3 = bNOT(NRADH_1_NCD)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	local b = {E1 = bNOT(NRADH_2_INV), E2 = NRADH_2, E3 = bNOT(NRADH_2_NCD)}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = ZLSTSC, E2 = ZAPSTSC, E3 = ZPSTSC}
	c.S = bOR3(c.E1, c.E2, c.E3)

	local d = {E1 = ZPH6, E2 = ZPH7, E3 = ZPH8, E4 = ZPH9}
	d.S = bOR4(d.E1, d.E2, d.E3, d.E4)

	local e = {E1 = a.S, E2 = b.S}
	e.S = bOR(e.E1, c.E2)

	local f = {E1 = e.S, E2 = c.S, E3 = ZSTSPD, E4 = d.S}
	f.S = bAND4(f.E1, f.E2, f.E3, f.E4)

	local g = {E1 = f.S, E2 = JR1START, E3 = JR2START}
	g.S = bOR3(g.E1, g.E2, g.E3)

	ZSYSPCI = g.S

end







function A333_fws.memo_msg_displayed()

	ZLMEMD = false
	ZCMEMD = false
	ZRMEMD = false
	for _, msg in pairs(A333_ewd_msg) do
		if msg.Zone == 0 then
			if msg.Monitor.video.OUT == 1 then
				if msg.FailType == 5 then
					ZCMEMD = true
				elseif msg.FailType == 6 then
					ZLMEMD = true
				end
			end
		elseif msg.Zone == 1 then
			if msg.Monitor.video.OUT == 1 then
				if msg.FailType == 6 then
					ZRMEMD = true
				end
			end
		end
	end

end






function A333_fws.dmc_l_alt_sel()

	local a = {E1 = KFCU1H, E2 = NBRQ20_1}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = KFCU1H, E2 = NBRQ21_1}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = bNOT(a.S), E2 = b.S}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = bNOT(b.S)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = bNOT(b.S), E2 = bNOT(a.S), E3 = KFCU1H, E4 = NBRQ21_1_VAL, E5 = bNOT(NBRQ21_1_NCD)}
	e.S = bAND5(e.E1, e.E2, e.E3, e.E4, e.E5)

	NBAROSEL1 = a.S
	NDMCLQNH = c.S
	NDMCLS = d.S
	NBAROSEL3 = b.S
	NDMCLQFE = e.S

end





function A333_fws.dmc_r_alt_sel()

	local a = {E1 = KFCU2H, E2 = NBRQ20_2}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = KFCU2H, E2 = NBRQ21_2}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = bNOT(a.S), E2 = b.S}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = bNOT(b.S)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = bNOT(b.S), E2 = bNOT(a.S), E3 = KFCU2H, E4 = NBRQ21_2_VAL, E5 = bNOT(NBRQ21_2_NCD)}
	e.S = bAND5(e.E1, e.E2, e.E3, e.E4, e.E5)

	NBAROSEL2 = a.S
	NDMCRQNH = c.S
	NDMCRS = d.S
	NBAROSEL4 = b.S
	NDMCRQFE = e.S

end






function A333_fws.baro_alti_comp()

	local a = {E1 = NALTFBK_1_INV, E2 = NALTFBK_1_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = NALTFBK_2_INV, E2 = NALTFBK_2_NCD}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = NDMCLQNH, E2 = NDMCRQNH}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = NDMCLQFE, E2 = NDMCRQFE }
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = NFOBAC_2_INV, E2 = NFOBAC_2_NCD, E3 = a.S}
	e.S = bOR3(e.E1, e.E2, e.E3)

	local f = {E1 = NCBAC_1_INV, E2 = NCBAC_1_NCD, E3 = b.S}
	f.S = bOR3(f.E1, f.E2, f.E3)

	local g = {E1 = c.S, E2 = d.S}
	g.S = bOR(g.E1, g.E2)

	logic.fo_baro_alti_comp:update(NALTFBK_1 - NFOBAC_2)

	local h = {E1 = bNOT(logic.fo_baro_alti_comp.output), E2 = bNOT(e.S)}
	h.S = bAND(h.E1, h.E2)

	logic.capt_baro_alti_comp:update(NALTFBK_2 - NCBAC_1)

	local i = {E1 = bNOT(logic.capt_baro_alti_comp.output), E2 = bNOT(f.S)}
	i.S = bAND(i.E1, i.E2)

	local j = {E1 = h.S, E2 = g.S}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = i.S, E2 = g.S}
	k.S = bAND(k.E1, k.E2)

	local l = {E1 = j.S, E2 = k.S}
	l.S = bOR(l.E1, l.E2)

	NALTBD = l.S

end







function A333_fws.std_alti_comp()

	local a = {E1 = NALTFBK_1_INV, E2 = NALTFBK_1_NCD}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = NALTFBK_2_INV, E2 = NALTFBK_2_NCD}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = NALTI_2_INV, E2 = NALTI_2_NCD, E3 = a.S}
	c.S = bOR3(c.E1, c.E2, c.E3)

	local d = {E1 = NALTI_1_INV, E2 = NALTI_1_NCD, E3 = b.S}
	d.S = bOR3(d.E1, d.E2, d.E3)

	logic.fo_std_alti_comp:update(NALTFBK_1 - NALTI_2)

	local e = {E1 = bNOT(logic.fo_std_alti_comp.output), E2 = bNOT(c.S)}
	e.S = bAND(e.E1, e.E2)

	logic.capt_std_alti_comp:update(NALTFBK_2 - NALTI_1)

	local f = {E1 = bNOT(logic.capt_std_alti_comp.output), E2 = bNOT(d.S)}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = NDMCRS, E2 = e.S, E3 = NDMCLS}
	g.S = bAND3(g.E1, g.E2, g.E3)

	local h = {E1 = NDMCRS, E2 = f.S, E3 = NDMCLS}
	h.S = bAND3(h.E1, h.E2, h.E3)

	local i = {E1 = g.S, E2 = h.S}
	i.S = bOR(i.E1, i.E2)

	NALTSTDD = i.S

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
	A333_fws.tr_mode_selected()
	A333_fws.fto_mode()
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
	A333_fws.dmc_l_alt_sel()
	A333_fws.dmc_r_alt_sel()
	A333_fws.baro_alti_comp()
	A333_fws.std_alti_comp()

end

function A333_fws_210_deferred()

	A333_fws.eng1_or_2_norun()
	A333_fws.eng1_and_2_norun()
	A333_fws.eng1_or_2_run()

end





--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")








