--[[
*****************************************************************************************
* Program Script Name	:	A333.annun_ac_ess.lua
* Author Name			:	Jim Gregory
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2025-08-29	0.01				Start of Dev
*
*
*
*
*****************************************************************************************
*       						   COPYRIGHT © 2025
*					 	   L A M I N A R   R E S E A R C H
*								  ALL RIGHTS RESERVED
*****************************************************************************************
--]]


--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--[[

SIM_PERIOD - this contains the duration of the current frame in seconds (so it is alway a
fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you’d do fuel = fuel + 3 * SIM_PERIOD.

IN_REPLAY - evaluates to 0 if replay is off, 1 if replay mode is on

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

local annun_emer_exit_sign = 0
local annun_efis_capt_apt = 0
local annun_efis_capt_vor = 0
local annun_efis_capt_fix = 0
local annun_efis_capt_ndb = 0
local annun_efis_capt_cstr = 0
local annun_efis_fo_apt = 0
local annun_efis_fo_vor = 0
local annun_efis_fo_fix = 0
local annun_efis_fo_ndb = 0
local annun_efis_fo_cstr = 0
local annun_efis_terr_capt = 0
local annun_efis_terr_fo = 0
local annun_apu_master_fault = 0
local annun_apu_master_on = 0
local annun_apu_start_on = 0
local annun_apu_avail = 0
local annun_apu_gen_off_R = 0
local annun_engine1_fire =20
local annun_engine2_fire = 0
local annun_engine1_starter_fault = 0
local annun_engine2_starter_fault = 0
local annun_prim1_off = 0
local annun_vent_extract_ovrd = 0
local annun_oxygen_pax_sys_on = 0
local annun_land_recovery_on = 0
local annun_elec_bat1_fault = 0
local annun_elec_bat2_fault = 0
local annun_elec_apu_bat_fault = 0
local annun_elec_bus_tie_off = 0
local annun_elec_gen1_fault = 0
local annun_elec_gen2_fault = 0
local annun_elec_idg1_fault = 0
local annun_elec_idg2_fault = 0
local annun_elec_ext_a_avail = 0
local annun_elec_ext_b_avail = 0
local annun_elec_commercial_off = 0
local annun_fire_apu_handle = 0
local annun_fire_eng1_handle = 0
local annun_fire_eng2_handle = 0
local annun_ventilation_avionics_smoke = 0
local annun_fire_apu_disch = 0
local annun_fire_apu_squib = 0
local annun_fire_eng1_agent1_disch = 0
local annun_fire_eng1_agent1_squib = 0
local annun_fire_eng1_agent2_disch = 0
local annun_fire_eng1_agent2_squib = 0
local annun_fire_eng2_agent1_disch = 0
local annun_fire_eng2_agent1_squib = 0
local annun_fire_eng2_agent2_disch = 0
local annun_fire_eng2_agent2_squib = 0
local annun_rtp_L_offside_tuning = 0
local annun_rtp_L_vhf_1 = 0
local annun_rtp_L_vhf_2 = 0
local annun_rtp_L_vhf_3 = 0
local annun_rtp_L_hf_1 = 0
local annun_rtp_L_hf_2 = 0
local annun_rtp_L_am = 0
local annun_rtp_L_no_op = 0

local lcl = {
    idg1_fault_init = 1,
    idg2_fault_init = 1,

    annun_audio_panel_capt_mic1 = 0,
    annun_audio_panel_capt_mic2 = 0,
    annun_audio_panel_capt_mic3 = 0,
    annun_audio_panel_capt_mic4 = 0,
    annun_audio_panel_capt_mic5 = 0,
    annun_audio_panel_capt_mic6 = 0,
    annun_audio_panel_capt_mic7 = 0,
    annun_audio_panel_capt_mic8 = 0,
    annun_audio_panel_capt_mic9 = 0,
    annun_audio_panel_capt_mic10 = 0,
    annun_audio_panel_capt_voice = 0,

    audio_panel_capt_call_light_vhf1 = 0,
    audio_panel_capt_call_light_vhf2 = 0,
	audio_panel_capt_call_light_att = 0,
    audio_panel_capt_call_light_gen = 0,

    annun_audio_panel_capt_listen = {},

    annun_flt_ctl_sec1_fault = 0,
    annun_flt_ctl_prim1_fault = 0,

    annun_ventilation_extract_fault = 0,

    annun_elec_emer_gen_fault = 0,

    annun_service_interphone_on = 0,

    annun_press_mode_sel_man = 0,
    annun_press_mode_sel_fault = 0,

    annun_pax_ifec_fault = 0,
    annun_pax_ifec_off = 0,

    annun_eng1_man_start_on = 0,
    annun_eng2_man_start_on = 0,
    annun_eng1_n1_mode_on = 0,
    annun_eng2_n1_mode_on = 0

}

for i = 0, 16-1 do
    lcl.annun_audio_panel_capt_listen[i] = 0
end



--*************************************************************************************--
--** 				            LOCAL UTILITY FUNCTIONS          			    	 **--
--*************************************************************************************--
--local bool2num = {[true] = 1, [false] = 0}
--local animate = animate


--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
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
--** 				              FIND CUSTOM COMMANDS                   	    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	         **--
--*************************************************************************************--


--*************************************************************************************--
--** 				             REPLACE X-PLANE COMMANDS                   	     **--
--*************************************************************************************--


--*************************************************************************************--
--** 				               WRAP X-PLANE COMMANDS                   	     	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				               FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--


--*************************************************************************************--
--** 				              CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                 CUSTOM COMMANDS                			     **--
--*************************************************************************************--


--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--
local function A333_annun_ac_ess_cache_globals()


end




local function A333_annun_ac_ess_processing()

    --local lcl_SIM_PERIOD = SIM_PERIOD

    local NUM_CAPT_LISTENING_LIGHTS = 16

    local animate = animate
    local bool2num = {[true] = 1, [false] = 0}
    local m = math

    local annun_light_switch_dim_or_brt = A333DR_ann_light_switch_pos <= 1
    local annun_ac_ess_brightness = A333DR_annun_brightness_ac_ess
    local annun_ac_ess2_brightness = A333DR_annun_brightness_ac_ess_2
    local annun_ac_ess_or_ac_ess_shed_brightness = A333DR_annun_brightness_ac_ess_or_ac_ess_shed
    local annun_ac_ess_or_ac_ess_shed_brightness2 = A333DR_annun_brightness_ac_ess_or_ac_ess_shed_2
    local annun_ac1_or_ac_ess_or_ac_ess_shed_brightness = A333DR_annun_brightness_ac1_or_ac_ess_or_ac_ess_shed
    local annun_ac2_or_ac_ess_or_ac_ess_shed_brightness = A333DR_annun_brightness_ac2_or_ac_ess_or_ac_ess_shed
    local annun_ac2_or_ac_ess_or_ac_ess_shed_brightness2 = A333DR_annun_brightness_ac2_or_ac_ess_or_ac_ess_shed_2
    local annun_brightness_ac_ess_grnd_or_ac_ess = A333DR_annun_brightness_ac_ess_grnd_or_ac_ess
    local annun_brightness_ac_ess_or_exta_grd = A333DR_annun_brightness_ac_ess_grnd_or_exta_grd
    local annun_light_switch_test = A333DR_dc_bus2_has_power
    local sim_time_factor = m.fmod(simDR_flight_time, 0.6)
    local flasher = (sim_time_factor >= 0 and sim_time_factor <= 0.3) and 1 or 0

    local apu_running = simDR_apu_running
    local apu_N1 = simDR_apu_N1
    local engine_fire = simDR_engine_fire_annun
    local apu_fire = simDR_apu_fire
    local apu_fire_test = A333DR_apu_fire_test
    local engine_fire_test = A333DR_engine_fire_test
    local cargo_fire_test_timer = A333DR_cargo_fire_test_timer
    local eng1_fire_handle_pos = A333DR_eng1_fire_handle_pos
    local eng2_fire_handle_pos = A333DR_eng2_fire_handle_pos
    local apu_fire_handle_pos = A333DR_apu_fire_handle_pos
    local eng1_agent1_psi = A333DR_eng1_agent1_psi
    local eng1_agent2_psi = A333DR_eng1_agent2_psi
    local eng2_agent1_psi = A333DR_eng2_agent1_psi
    local eng2_agent2_psi = A333DR_eng2_agent2_psi
    local apu_agent_psi = A333DR_apu_agent_psi
    local smoke_in_cockpit = simDR_smoke_in_cockpit
    local rtp_L_is_on = A333DR_rtp_L_off_status == 0
    local audio_panel_capt_listen_annun_target = {}
    local audio_panel_capt_listen_status = A333DR_audio_panel_capt_listen_status

    if A333_IDG1_status == 0 then
        lcl.idg1_fault_init = animate(lcl.idg1_fault_init, 0, 15)
    end

    if A333_IDG2_status == 0 then
        lcl.idg2_fault_init = animate(lcl.idg2_fault_init, 0, 15)
    end


    -- SET ANNUNCIATOR STATUS (0/1)
    local emer_exit_sign_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_emer_exit_lt_switch_pos == 0] or annun_light_switch_test
    local efis_capt_apt_annun_target = annun_light_switch_dim_or_brt and simDR_EFIS_airport_on_capt or annun_light_switch_test
    local efis_capt_vor_annun_target = annun_light_switch_dim_or_brt and simDR_EFIS_vor_on_capt or annun_light_switch_test
    local efis_capt_fix_annun_target = annun_light_switch_dim_or_brt and simDR_EFIS_fix_on_capt or annun_light_switch_test
    local efis_capt_ndb_annun_target = annun_light_switch_dim_or_brt and simDR_EFIS_ndb_on_capt or annun_light_switch_test
    local efis_capt_cstr_annun_target = annun_light_switch_dim_or_brt and simDR_EFIS_CSTR_capt_on or annun_light_switch_test
    local efis_fo_apt_annun_target = annun_light_switch_dim_or_brt and simDR_EFIS_airport_on_fo or annun_light_switch_test
    local efis_fo_vor_annun_target = annun_light_switch_dim_or_brt and simDR_EFIS_vor_on_fo or annun_light_switch_test
    local efis_fo_fix_annun_target = annun_light_switch_dim_or_brt and simDR_EFIS_fix_on_fo or annun_light_switch_test
    local efis_fo_ndb_annun_target = annun_light_switch_dim_or_brt and simDR_EFIS_ndb_on_fo or annun_light_switch_test
    local efis_fo_cstr_annun_target = annun_light_switch_dim_or_brt and simDR_EFIS_CSTR_fo_on or annun_light_switch_test
    local efis_terr_capt_annun_target = annun_light_switch_dim_or_brt and simDR_terr_on_nd_capt or annun_light_switch_test
    local efis_terr_fo_annun_target = annun_light_switch_dim_or_brt and simDR_terr_on_nd_fo or annun_light_switch_test
    local apu_master_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[simDR_apu_fail == 6] or annun_light_switch_test
    local apu_master_on_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_buttons_APU_master >= 1] or annun_light_switch_test
    local apu_start_on_annun_target = annun_light_switch_dim_or_brt and bool2num[(apu_running == 1) and (apu_N1 <= 95)] or annun_light_switch_test
    local apu_avail_annun_target = annun_light_switch_dim_or_brt and bool2num[(apu_running == 1) and (apu_N1 > 95)] or annun_light_switch_test
    local apu_gen_off_R_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_buttons_apu_gen_ctct_on_off == 0] or annun_light_switch_test
    local engine1_fire_annun_target = annun_light_switch_dim_or_brt and engine_fire[0] or annun_light_switch_test
    local engine2_fire_annun_target = annun_light_switch_dim_or_brt and engine_fire[1] or annun_light_switch_test
    local engine1_starter_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[simDR_engine1_starter_fail == 6] or annun_light_switch_test
    local engine2_starter_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[simDR_engine2_starter_fail == 6] or annun_light_switch_test
    local prim1_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_prim1_pos == 0] or annun_light_switch_test
    local vent_extract_ovrd_annun_target = annun_light_switch_dim_or_brt and (1 - A333DR_ventilation_extract_ovrd_pos) or annun_light_switch_test
    local oxygen_pax_sys_on_annun_target = annun_light_switch_dim_or_brt and bool2num[simDR_pax_oxy_fail == 6] or annun_light_switch_test
    local land_recovery_on_annun_target = annun_light_switch_dim_or_brt and A333DR_buttons_land_rcvry_ctct_open_closed or annun_light_switch_test
    local elec_bat1_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[simDR_bat1_failure == 6] or annun_light_switch_test
    local elec_bat2_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[simDR_bat2_failure == 6] or annun_light_switch_test
    local elec_apu_bat_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[simDR_bat_apu_failure == 6] or annun_light_switch_test
    local elec_bus_tie_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_buttons_bus_tie_ctct_on_off == 0] or annun_light_switch_test
    local elec_gen1_fault_annun_target = annun_light_switch_dim_or_brt and A333DR_fws_eng_gen1_fault or annun_light_switch_test
    local elec_gen2_fault_annun_target = annun_light_switch_dim_or_brt and A333DR_fws_eng_gen2_fault or annun_light_switch_test
    local elec_idg1_fault_annun_target = annun_light_switch_dim_or_brt and (((A333DR_IDG1_status == 1) and 0) or lcl.idg1_fault_init) or annun_light_switch_test
    local elec_idg2_fault_annun_target = annun_light_switch_dim_or_brt and (((A333DR_IDG2_status == 1) and 0) or lcl.idg2_fault_init) or annun_light_switch_test
    local elec_ext_a_avail_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_extA_line_contactor == 0 and A333DR_status_GPU_avail == 1] or annun_light_switch_test
    local elec_ext_b_avail_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_extB_line_contactor == 0 and A333DR_status_GPU2_avail == 1] or annun_light_switch_test
    local elec_commercial_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_buttons_commercial_pos == 0] or annun_light_switch_test
    local fire_apu_handle_annun_target = annun_light_switch_dim_or_brt and bool2num[apu_fire_test == 1 or (apu_fire_test == 0 and apu_fire == 6)] or annun_light_switch_test
    local fire_eng1_handle_annun_target = annun_light_switch_dim_or_brt and engine_fire[0] or annun_light_switch_test
    local fire_eng2_handle_annun_target = annun_light_switch_dim_or_brt and engine_fire[1] or annun_light_switch_test
    local ventilation_avionics_smoke_annun_target = annun_light_switch_dim_or_brt and bool2num[smoke_in_cockpit == 6 or (smoke_in_cockpit <= 5 and cargo_fire_test_timer > 4.5)] or annun_light_switch_test

    local fire_apu_disch_annun_target = annun_light_switch_dim_or_brt
        and bool2num[apu_fire_test == 1
        or (apu_fire_test == 0 and apu_agent_psi < 300)]
        or annun_light_switch_test

    local fire_apu_squib_annun_target = annun_light_switch_dim_or_brt
        and bool2num[(apu_fire_test == 1 and apu_agent_psi > 0) or (apu_fire_test == 0 and apu_fire_handle_pos == 1 and apu_agent_psi > 0)]
        or annun_light_switch_test

    local fire_eng1_agent1_disch_annun_target = annun_light_switch_dim_or_brt
        and bool2num[engine_fire_test == 1 or (engine_fire_test == 0 and eng1_agent1_psi < 300)]
        or annun_light_switch_test

    local fire_eng1_agent1_squib_annun_target = annun_light_switch_dim_or_brt
        and bool2num[(engine_fire_test == 1 and eng1_agent1_psi > 0) or (engine_fire_test == 0 and eng1_fire_handle_pos == 1 and eng1_agent1_psi > 0)]
        or annun_light_switch_test

    local fire_eng1_agent2_disch_annun_target = annun_light_switch_dim_or_brt
        and bool2num[engine_fire_test == 1 or (engine_fire_test == 0 and eng1_agent2_psi < 300)]
        or annun_light_switch_test

    local fire_eng1_agent2_squib_annun_target = annun_light_switch_dim_or_brt
        and bool2num[(engine_fire_test == 1 and eng1_agent2_psi > 0) or (engine_fire_test == 0 and eng1_fire_handle_pos == 1 and eng1_agent2_psi > 0)]
        or annun_light_switch_test

    local fire_eng2_agent1_disch_annun_target = annun_light_switch_dim_or_brt
        and bool2num[engine_fire_test == 1 or (engine_fire_test == 0 and eng2_agent1_psi < 300)]
        or annun_light_switch_test

    local fire_eng2_agent1_squib_annun_target = annun_light_switch_dim_or_brt
        and bool2num[(engine_fire_test == 1 and eng2_agent1_psi > 0) or (engine_fire_test == 0 and eng2_fire_handle_pos == 1 and eng2_agent1_psi > 0)]
        or annun_light_switch_test

    local fire_eng2_agent2_disch_annun_target = annun_light_switch_dim_or_brt
        and bool2num[engine_fire_test == 1 or (engine_fire_test == 0 and eng2_agent2_psi < 300)]
        or annun_light_switch_test

    local fire_eng2_agent2_squib_annun_target = annun_light_switch_dim_or_brt
        and bool2num[(engine_fire_test == 1 and eng2_agent2_psi > 0) or (engine_fire_test == 0 and eng2_fire_handle_pos == 1 and eng2_agent2_psi > 0)]
        or annun_light_switch_test

    local rtp_L_offside_tuning_annun_target = annun_light_switch_dim_or_brt and (rtp_L_is_on and A333DR_rtp_L_offside_tuning_status or 0) or annun_light_switch_test
    local rtp_L_vhf_1_annun_target = annun_light_switch_dim_or_brt and (rtp_L_is_on and A333DR_rtp_L_vhf_1_status or 0) or annun_light_switch_test
    local rtp_L_vhf_2_annun_target = annun_light_switch_dim_or_brt and (rtp_L_is_on and A333DR_rtp_L_vhf_2_status or 0) or annun_light_switch_test
    local rtp_L_vhf_3_annun_target = annun_light_switch_dim_or_brt and (rtp_L_is_on and A333DR_rtp_L_vhf_3_status or 0) or annun_light_switch_test
    local rtp_L_hf_1_annun_target = annun_light_switch_dim_or_brt and (rtp_L_is_on and A333DR_rtp_L_hf_1_status or 0) or annun_light_switch_test
    local rtp_L_hf_2_annun_target = annun_light_switch_dim_or_brt and (rtp_L_is_on and A333DR_rtp_L_hf_2_status or 0) or annun_light_switch_test
    local rtp_L_am_annun_target = annun_light_switch_dim_or_brt and (rtp_L_is_on and A333DR_rtp_L_am_status or 0) or annun_light_switch_test
    local rtp_L_no_op_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local audio_panel_capt_mic1_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_capt_mic1_status  or annun_light_switch_test
    local audio_panel_capt_mic2_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_capt_mic2_status  or annun_light_switch_test
    local audio_panel_capt_mic3_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_capt_mic3_status  or annun_light_switch_test
    local audio_panel_capt_mic4_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_capt_mic4_status  or annun_light_switch_test
    local audio_panel_capt_mic5_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_capt_mic5_status  or annun_light_switch_test
    local audio_panel_capt_mic6_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_capt_mic6_status  or annun_light_switch_test
    local audio_panel_capt_mic7_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_capt_mic7_status  or annun_light_switch_test
    local audio_panel_capt_mic8_annun_target = annun_light_switch_dim_or_brt and (A333DR_audio_panel_capt_mic8_status * flasher) or annun_light_switch_test
    local audio_panel_capt_mic9_annun_target = annun_light_switch_dim_or_brt and (A333DR_audio_panel_capt_mic9_status * flasher) or annun_light_switch_test
    local audio_panel_capt_mic10_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_capt_mic10_status or annun_light_switch_test
    local audio_panel_capt_voice_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_capt_voice_status or annun_light_switch_test
    local audio_panel_capt_call_light_vhf1_target = annun_light_switch_dim_or_brt and (flasher * A333DR_capt_com1_activated) or annun_light_switch_test
    local audio_panel_capt_call_light_vhf2_target = annun_light_switch_dim_or_brt and (flasher * A333DR_capt_com2_activated) or annun_light_switch_test
    local audio_panel_capt_call_light_att_target = annun_light_switch_dim_or_brt and (flasher * A333DR_capt_att_activated) or annun_light_switch_test
    local audio_panel_capt_call_light_gen_target = annun_light_switch_dim_or_brt and (flasher * A333DR_capt_gen_activated) or annun_light_switch_test


    for i = 0, NUM_CAPT_LISTENING_LIGHTS-1 do
        audio_panel_capt_listen_annun_target[i] = annun_light_switch_dim_or_brt and audio_panel_capt_listen_status[i] or annun_light_switch_test

    end

    local flt_ctl_sec1_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local flt_ctl_prim1_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local ventilation_extract_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local elec_emer_gen_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local service_interphone_on_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local press_mode_sel_man_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local press_mode_sel_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local pax_ifec_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local annun_pax_ifec_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_pax_IFEC_pos == 0] or annun_light_switch_test
    local eng1_man_start_on_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local eng2_man_start_on_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local eng1_n1_mode_on_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local eng2_n1_mode_on_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test


    -- SET ANNUNCIATOR FADE IN/OUT
    annun_emer_exit_sign = animate(annun_emer_exit_sign, emer_exit_sign_annun_target, 13)
    annun_efis_capt_apt = animate(annun_efis_capt_apt, efis_capt_apt_annun_target, 13)
    annun_efis_capt_vor = animate(annun_efis_capt_vor, efis_capt_vor_annun_target, 13)
    annun_efis_capt_fix = animate(annun_efis_capt_fix, efis_capt_fix_annun_target, 13)
    annun_efis_capt_ndb = animate(annun_efis_capt_ndb, efis_capt_ndb_annun_target, 13)
    annun_efis_capt_cstr = animate(annun_efis_capt_cstr, efis_capt_cstr_annun_target, 13)
    annun_efis_fo_apt = animate(annun_efis_fo_apt, efis_fo_apt_annun_target, 13)
    annun_efis_fo_vor = animate(annun_efis_fo_vor, efis_fo_vor_annun_target, 13)
    annun_efis_fo_fix = animate(annun_efis_fo_fix, efis_fo_fix_annun_target, 13)
    annun_efis_fo_ndb = animate(annun_efis_fo_ndb, efis_fo_ndb_annun_target, 13)
    annun_efis_fo_cstr = animate(annun_efis_fo_cstr, efis_fo_cstr_annun_target, 13)
    annun_efis_terr_capt = animate(annun_efis_terr_capt, efis_terr_capt_annun_target, 13)
    annun_efis_terr_fo = animate(annun_efis_terr_fo, efis_terr_fo_annun_target, 13)
    annun_apu_master_fault = animate(annun_apu_master_fault, apu_master_fault_annun_target, 13)
    annun_apu_master_on = animate(annun_apu_master_on, apu_master_on_annun_target, 13)
    annun_apu_start_on = animate(annun_apu_start_on, apu_start_on_annun_target, 13)
    annun_apu_avail = animate(annun_apu_avail, apu_avail_annun_target, 13)
    annun_apu_gen_off_R = animate(annun_apu_gen_off_R, apu_gen_off_R_annun_target, 13)
    annun_engine1_fire = animate(annun_engine1_fire, engine1_fire_annun_target, 13)
    annun_engine2_fire = animate(annun_engine2_fire, engine2_fire_annun_target, 13)
    annun_engine1_starter_fault = animate(annun_engine1_starter_fault, engine1_starter_fault_annun_target, 13)
    annun_engine2_starter_fault = animate(engine2_starter_fault_annun_target, engine1_starter_fault_annun_target, 13)
    annun_prim1_off = animate(annun_prim1_off, prim1_off_annun_target, 13)
    annun_vent_extract_ovrd = animate(annun_vent_extract_ovrd, vent_extract_ovrd_annun_target, 13)
    annun_oxygen_pax_sys_on = animate(annun_oxygen_pax_sys_on, oxygen_pax_sys_on_annun_target, 13)
    annun_land_recovery_on = animate(annun_land_recovery_on, land_recovery_on_annun_target, 13)
    annun_elec_bat1_fault = animate(annun_elec_bat1_fault, elec_bat1_fault_annun_target, 13)
    annun_elec_bat2_fault = animate(annun_elec_bat2_fault, elec_bat2_fault_annun_target, 13)
    annun_elec_apu_bat_fault = animate(annun_elec_apu_bat_fault, elec_apu_bat_fault_annun_target, 13)
    annun_elec_bus_tie_off = animate(annun_elec_bus_tie_off, elec_bus_tie_off_annun_target, 13)
    annun_elec_gen1_fault = animate(annun_elec_gen1_fault, elec_gen1_fault_annun_target, 13)
    annun_elec_gen2_fault = animate(annun_elec_gen2_fault, elec_gen2_fault_annun_target, 13)
    annun_elec_idg1_fault = animate(annun_elec_idg1_fault, elec_idg1_fault_annun_target, 13)
    annun_elec_idg2_fault = animate(annun_elec_idg2_fault, elec_idg2_fault_annun_target, 13)
    annun_elec_ext_a_avail = animate(annun_elec_ext_a_avail, elec_ext_a_avail_annun_target, 13)
    annun_elec_ext_b_avail = animate(annun_elec_ext_b_avail, elec_ext_b_avail_annun_target, 13)
    annun_elec_commercial_off = animate(annun_elec_commercial_off, elec_commercial_off_annun_target, 13)
    annun_fire_apu_handle = animate(annun_fire_apu_handle, fire_apu_handle_annun_target, 13)
    annun_fire_eng1_handle = animate(annun_fire_eng1_handle, fire_eng1_handle_annun_target, 13)
    annun_fire_eng2_handle = animate(annun_fire_eng2_handle, fire_eng2_handle_annun_target, 13)
    annun_ventilation_avionics_smoke = animate(annun_ventilation_avionics_smoke, ventilation_avionics_smoke_annun_target, 13)
    annun_fire_apu_disch = animate(annun_fire_apu_disch, fire_apu_disch_annun_target, 13)
    annun_fire_apu_squib = animate(annun_fire_apu_squib, fire_apu_squib_annun_target, 13)
    annun_fire_eng1_agent1_disch = animate(annun_fire_eng1_agent1_disch, fire_eng1_agent1_disch_annun_target, 13)
    annun_fire_eng1_agent1_squib = animate(annun_fire_eng1_agent1_squib, fire_eng1_agent1_squib_annun_target, 13)
    annun_fire_eng1_agent2_disch = animate(annun_fire_eng1_agent2_disch, fire_eng1_agent2_disch_annun_target, 13)
    annun_fire_eng1_agent2_squib = animate(annun_fire_eng1_agent2_squib, fire_eng1_agent2_squib_annun_target, 13)
    annun_fire_eng2_agent1_disch = animate(annun_fire_eng2_agent1_disch, fire_eng2_agent1_disch_annun_target, 13)
    annun_fire_eng2_agent1_squib = animate(annun_fire_eng2_agent1_squib, fire_eng2_agent1_squib_annun_target, 13)
    annun_fire_eng2_agent2_disch = animate(annun_fire_eng2_agent2_disch, fire_eng2_agent2_disch_annun_target, 13)
    annun_fire_eng2_agent2_squib = animate(annun_fire_eng2_agent2_squib, fire_eng2_agent2_squib_annun_target, 13)
    annun_rtp_L_offside_tuning = animate(annun_rtp_L_offside_tuning, rtp_L_offside_tuning_annun_target, 13)
    annun_rtp_L_vhf_1 = animate(annun_rtp_L_vhf_1, rtp_L_vhf_1_annun_target, 13)
    annun_rtp_L_vhf_2 = animate(annun_rtp_L_vhf_2, rtp_L_vhf_2_annun_target, 13)
    annun_rtp_L_vhf_3 = animate(annun_rtp_L_vhf_3, rtp_L_vhf_3_annun_target, 13)
    annun_rtp_L_hf_1 = animate(annun_rtp_L_hf_1, rtp_L_hf_1_annun_target, 13)
    annun_rtp_L_hf_2 = animate(annun_rtp_L_hf_2, rtp_L_hf_2_annun_target, 13)
    annun_rtp_L_am = animate(annun_rtp_L_am, rtp_L_am_annun_target, 13)
    annun_rtp_L_no_op = animate(annun_rtp_L_no_op, rtp_L_no_op_annun_target, 13)

    lcl.annun_audio_panel_capt_mic1 = animate(lcl.annun_audio_panel_capt_mic1, audio_panel_capt_mic1_annun_target, 13)
    lcl.annun_audio_panel_capt_mic2 = animate(lcl.annun_audio_panel_capt_mic2, audio_panel_capt_mic2_annun_target, 13)
    lcl.annun_audio_panel_capt_mic3 = animate(lcl.annun_audio_panel_capt_mic3, audio_panel_capt_mic3_annun_target, 13)
    lcl.annun_audio_panel_capt_mic4 = animate(lcl.annun_audio_panel_capt_mic4, audio_panel_capt_mic4_annun_target, 13)
    lcl.annun_audio_panel_capt_mic5 = animate(lcl.annun_audio_panel_capt_mic5, audio_panel_capt_mic5_annun_target, 13)
    lcl.annun_audio_panel_capt_mic6 = animate(lcl.annun_audio_panel_capt_mic6, audio_panel_capt_mic6_annun_target, 13)
    lcl.annun_audio_panel_capt_mic7 = animate(lcl.annun_audio_panel_capt_mic7, audio_panel_capt_mic7_annun_target, 13)
    lcl.annun_audio_panel_capt_mic8 = animate(lcl.annun_audio_panel_capt_mic8, audio_panel_capt_mic8_annun_target, 13)
    lcl.annun_audio_panel_capt_mic9 = animate(lcl.annun_audio_panel_capt_mic9, audio_panel_capt_mic9_annun_target, 13)
    lcl.annun_audio_panel_capt_mic10 = animate(lcl.annun_audio_panel_capt_mic10, audio_panel_capt_mic10_annun_target, 13)
    lcl.annun_audio_panel_capt_voice = animate(lcl.annun_audio_panel_capt_voice, audio_panel_capt_voice_annun_target, 13)
    
    lcl.audio_panel_capt_call_light_vhf1 = animate(lcl.audio_panel_capt_call_light_vhf1, audio_panel_capt_call_light_vhf1_target, 13)
    lcl.audio_panel_capt_call_light_vhf2 = animate(lcl.audio_panel_capt_call_light_vhf2, audio_panel_capt_call_light_vhf2_target, 13)
	lcl.audio_panel_capt_call_light_att = animate(lcl.audio_panel_capt_call_light_att, audio_panel_capt_call_light_att_target , 13)
    lcl.audio_panel_capt_call_light_gen = animate(lcl.audio_panel_capt_call_light_gen, audio_panel_capt_call_light_gen_target , 13)

    for i = 0, NUM_CAPT_LISTENING_LIGHTS-1 do
        lcl.annun_audio_panel_capt_listen[i] = animate(lcl.annun_audio_panel_capt_listen[i], audio_panel_capt_listen_annun_target[i], 13)
    end

    lcl.annun_flt_ctl_sec1_fault = animate(lcl.annun_flt_ctl_sec1_fault, flt_ctl_sec1_fault_annun_target,  13)
    lcl.annun_flt_ctl_prim1_fault = animate(lcl.annun_flt_ctl_prim1_fault, flt_ctl_prim1_fault_annun_target, 13)
    lcl.annun_ventilation_extract_fault = animate(lcl.annun_ventilation_extract_fault, ventilation_extract_fault_annun_target, 13)
    lcl.annun_elec_emer_gen_fault = animate(lcl.annun_elec_emer_gen_fault, elec_emer_gen_fault_annun_target, 13)
    lcl.annun_service_interphone_on = animate(lcl.annun_service_interphone_on, service_interphone_on_annun_target, 13)
    lcl.annun_press_mode_sel_man = animate(lcl.annun_press_mode_sel_man, press_mode_sel_man_annun_target    , 13)
    lcl.annun_press_mode_sel_fault = animate(lcl.annun_press_mode_sel_fault, press_mode_sel_fault_annun_target    , 13)
    lcl.annun_pax_ifec_fault = animate(lcl.annun_pax_ifec_fault, pax_ifec_fault_annun_target, 13)
    lcl.annun_pax_ifec_off = animate(lcl.annun_pax_ifec_off, annun_pax_ifec_off_annun_target, 13)
    lcl.annun_eng1_man_start_on = animate(lcl.annun_eng1_man_start_on, eng1_man_start_on_annun_target, 13)
    lcl.annun_eng2_man_start_on = animate(lcl.annun_eng2_man_start_on, eng2_man_start_on_annun_target, 13)
    lcl.annun_eng1_n1_mode_on = animate(lcl.annun_eng1_n1_mode_on, eng1_n1_mode_on_annun_target, 13)
    lcl.annun_eng2_n1_mode_on = animate(lcl.annun_eng2_n1_mode_on, eng2_n1_mode_on_annun_target, 13)


    -- SET ANNUNCIATOR BRIGHTNESS AND ASSIGN TO DATAREF (AC ESS)
    A333DR_annun_emer_exit_off = annun_emer_exit_sign * annun_ac_ess_brightness
    A333DR_annun_EFIS_apt_capt = annun_efis_capt_apt * annun_ac_ess_brightness
    A333DR_annun_EFIS_vor_capt = annun_efis_capt_vor * annun_ac_ess_brightness
    A333DR_annun_EFIS_fix_capt = annun_efis_capt_fix * annun_ac_ess_brightness
    A333DR_annun_EFIS_ndb_capt = annun_efis_capt_ndb * annun_ac_ess_brightness
    A333DR_annun_EFIS_cstr_capt = annun_efis_capt_cstr * annun_ac_ess_brightness
    A333DR_annun_EFIS_apt_fo = annun_efis_fo_apt * annun_ac_ess_brightness
    A333DR_annun_EFIS_vor_fo = annun_efis_fo_vor * annun_ac_ess_brightness
    A333DR_annun_EFIS_fix_fo = annun_efis_fo_fix * annun_ac_ess_brightness
    A333DR_annun_EFIS_ndb_fo = annun_efis_fo_ndb * annun_ac_ess_brightness
    A333DR_annun_EFIS_cstr_fo = annun_efis_fo_cstr * annun_ac_ess_brightness
    A333DR_annun_EFIS_terr_capt = annun_efis_terr_capt * annun_ac_ess_brightness
    A333DR_annun_EFIS_terr_fo = annun_efis_terr_fo * annun_ac_ess_brightness
    A333DR_annun_apu_master_fault = annun_apu_master_fault * annun_ac_ess_brightness
    A333DR_annun_apu_master_on = annun_apu_master_on * annun_ac_ess_brightness
    A333DR_annun_apu_start_on = annun_apu_start_on * annun_ac_ess_brightness
    A333DR_annun_apu_avail = annun_apu_avail * annun_ac_ess_brightness
    A333DR_annun_flt_ctl_prim1_off = annun_prim1_off * annun_ac_ess_brightness
    A333DR_annun_oxygen_pax_sys_on = annun_oxygen_pax_sys_on * annun_ac_ess_brightness
    A333DR_annun_elec_emer_gen_fault = lcl.annun_elec_emer_gen_fault * annun_ac_ess_brightness
    A333DR_annun_service_interphone_on = lcl.annun_service_interphone_on * annun_ac_ess_brightness
    A333DR_annun_pax_ifec_fault = lcl.annun_pax_ifec_fault * annun_ac_ess_brightness
    A333DR_annun_pax_ifec_off = lcl.annun_pax_ifec_off * annun_ac_ess_brightness

    -- SET ANNUNCIATOR BRIGHTNESS AND ASSIGN TO DATAREF (AC ESS or AC ESS SHED)
    A333DR_annun_elec_apu_gen_off_R = annun_apu_gen_off_R * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_engine1_fire = annun_engine1_fire * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_engine2_fire = annun_engine2_fire * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_engine1_starter_fault = annun_engine1_starter_fault * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_engine2_starter_fault = annun_engine2_starter_fault * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_ventilation_extract_ovrd = annun_vent_extract_ovrd * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_land_recovery_on = annun_land_recovery_on * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_elec_bat1_fault = annun_elec_bat1_fault * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_elec_bat2_fault = annun_elec_bat2_fault * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_elec_apu_bat_fault = annun_elec_apu_bat_fault * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_elec_gen1_fault = annun_elec_gen1_fault * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_elec_gen2_fault = annun_elec_gen2_fault * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_elec_idg1_fault = annun_elec_idg1_fault * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_elec_idg2_fault = annun_elec_idg2_fault * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_elec_commercial_off = annun_elec_commercial_off * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_fire_apu_disch = annun_fire_apu_disch * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_fire_apu_squib = annun_fire_apu_squib * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_fire_eng1_agent1_disch = annun_fire_eng1_agent1_disch * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_fire_eng1_agent1_squib = annun_fire_eng1_agent1_squib * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_fire_eng1_agent2_disch = annun_fire_eng1_agent2_disch * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_fire_eng1_agent2_squib = annun_fire_eng1_agent2_squib * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_fire_eng2_agent1_disch = annun_fire_eng2_agent1_disch * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_fire_eng2_agent1_squib = annun_fire_eng2_agent1_squib * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_fire_eng2_agent2_disch = annun_fire_eng2_agent2_disch * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_fire_eng2_agent2_squib = annun_fire_eng2_agent2_squib * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_rtp_L_offside_tuning = annun_rtp_L_offside_tuning * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_flt_ctl_sec1_fault = lcl.annun_flt_ctl_sec1_fault * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_flt_ctl_prim1_fault = lcl.annun_flt_ctl_prim1_fault * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_ventilation_extract_fault = lcl.annun_ventilation_extract_fault * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_press_mode_sel_man = lcl.annun_press_mode_sel_man * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_press_mode_sel_fault = lcl.annun_press_mode_sel_fault * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_eng1_man_start_on = lcl.annun_eng1_man_start_on * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_eng2_man_start_on = lcl.annun_eng2_man_start_on * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_eng1_n1_mode_on = lcl.annun_eng1_n1_mode_on * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_annun_eng2_n1_mode_on = lcl.annun_eng2_n1_mode_on * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_mic1_annun = lcl.annun_audio_panel_capt_mic1 * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_mic2_annun = lcl.annun_audio_panel_capt_mic2 * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_mic3_annun = lcl.annun_audio_panel_capt_mic3 * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_mic4_annun = lcl.annun_audio_panel_capt_mic4 * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_mic5_annun = lcl.annun_audio_panel_capt_mic5 * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_mic6_annun = lcl.annun_audio_panel_capt_mic6 * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_mic7_annun = lcl.annun_audio_panel_capt_mic7 * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_mic8_annun = lcl.annun_audio_panel_capt_mic8 * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_mic9_annun = lcl.annun_audio_panel_capt_mic9 * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_mic10_annun = lcl.annun_audio_panel_capt_mic10 * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_voice_annun = lcl.annun_audio_panel_capt_voice * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_call_light_vhf1 = lcl.audio_panel_capt_call_light_vhf1 * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_call_light_vhf2 = lcl.audio_panel_capt_call_light_vhf2 * annun_ac_ess_or_ac_ess_shed_brightness
 	A333DR_audio_panel_capt_call_light_att = lcl.audio_panel_capt_call_light_att * annun_ac_ess_or_ac_ess_shed_brightness
    A333DR_audio_panel_capt_call_light_gen = lcl.audio_panel_capt_call_light_gen * annun_ac_ess_or_ac_ess_shed_brightness




    -- SET ANNUNCIATOR BRIGHTNESS AND ASSIGN TO DATAREF (AC ESS or AC ESS SHED2)
    A333DR_annun_ventilation_avionics_smoke = annun_ventilation_avionics_smoke * annun_ac_ess_or_ac_ess_shed_brightness2
    A333DR_annun_rtp_L_vhf_1 = annun_rtp_L_vhf_1 * annun_ac_ess_or_ac_ess_shed_brightness2
    A333DR_annun_rtp_L_vhf_2 = annun_rtp_L_vhf_2 * annun_ac_ess_or_ac_ess_shed_brightness2
    A333DR_annun_rtp_L_vhf_3 = annun_rtp_L_vhf_3 * annun_ac_ess_or_ac_ess_shed_brightness2
    A333DR_annun_rtp_L_hf_1 = annun_rtp_L_hf_1 * annun_ac_ess_or_ac_ess_shed_brightness2
    A333DR_annun_rtp_L_hf_2 = annun_rtp_L_hf_2 * annun_ac_ess_or_ac_ess_shed_brightness2
    A333DR_annun_rtp_L_am = annun_rtp_L_am * annun_ac_ess_or_ac_ess_shed_brightness2
    A333DR_annun_rtp_L_no_op = annun_rtp_L_no_op * annun_ac_ess_or_ac_ess_shed_brightness2

    local br = {}
    for i = 0, NUM_CAPT_LISTENING_LIGHTS-1 do
        br[i] = lcl.annun_audio_panel_capt_listen[i] * annun_ac_ess_or_ac_ess_shed_brightness2
    end
    A333DR_audio_panel_capt_listen_annun = br


    -- SET ANNUNCIATOR BRIGHTNESS AND ASSIGN TO DATAREF (AC2 or AC ESS or AC ESS SHED)
    A333DR_annun_elec_bus_tie_off = annun_elec_bus_tie_off * annun_ac2_or_ac_ess_or_ac_ess_shed_brightness


    -- -- SET ANNUNCIATOR BRIGHTNESS AND ASSIGN TO DATAREF (AC ESS or EXTA GROUND SERVICES BUS)
    A333DR_annun_elec_ext_a_avail = annun_elec_ext_a_avail * annun_brightness_ac_ess_or_exta_grd
    A333DR_annun_elec_ext_b_avail = annun_elec_ext_b_avail * annun_brightness_ac_ess_or_exta_grd


    -- SET ANNUNCIATOR BRIGHTNESS AND ASSIGN TO DATAREF (AC1 or AC ESS or AC ESS SHED 2)
    A333DR_annun_fire_apu_handle = annun_fire_apu_handle * annun_ac2_or_ac_ess_or_ac_ess_shed_brightness2
    A333DR_annun_fire_eng1_handle = annun_fire_eng1_handle * annun_ac2_or_ac_ess_or_ac_ess_shed_brightness2
    A333DR_annun_fire_eng2_handle = annun_fire_eng2_handle * annun_ac2_or_ac_ess_or_ac_ess_shed_brightness2

end



--*************************************************************************************--
--** 				                     PROCESSING             	    			 **--
--*************************************************************************************--

--===| INIT ALL |========================================================================
function A333_annun_ac_ess_init_all()



end




--===| INIT ER |=========================================================================
function A333_annun_ac_ess_init_ER()



end




--===| INIT CD |=========================================================================
function A333_annun_ac_ess_init_CD()



end




--===| DEFERRED INITIALIZATION |=========================================================
function A333_annun_ac_ess_deferred_init()




end



--===| DEFERRED PROCESSING |=============================================================
function A333_annun_ac_ess_deferred_processing()



end




--=== AIRCRAFT LOAD =====================================================================
function A333_annun_ac_ess_aircraft_load()



end



--=== FLIGHT START ======================================================================
function A333_annun_ac_ess_flight_start()



end



--=== BEFORE PHYSICS ====================================================================
function A333_annun_ac_ess_before_physics()



end



--=== AFTER PHYSICS =====================================================================
function A333_annun_ac_ess_after_physics()

    A333_annun_ac_ess_cache_globals()
    A333_annun_ac_ess_processing()

end




--=== FLIGHT CRASH ======================================================================
function A333_annun_ac_ess_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_annun_ac_ess_aircraft_unload()



end




--=== AIRCRAFT UNLOAD ===================================================================
function A333_annun_ac_ess_after_replay()

    A333_annun_ac_ess_cache_globals()
    A333_annun_ac_ess_processing()

end



--*************************************************************************************--
--** 				                 SUB-SCRIPT LOADING            	     			 **--
--*************************************************************************************--



