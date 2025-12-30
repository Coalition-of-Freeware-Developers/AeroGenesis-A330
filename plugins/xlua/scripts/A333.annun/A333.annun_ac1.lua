--[[
*****************************************************************************************
* Program Script Name	:	A333.annun_ac1.lua
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
local lcl_SIM_PERIOD = 0

local annun_engine1_anti_ice_on = 0
local annun_engine2_anti_ice_on = 0
local annun_engine1_anti_ice_fault = 0
local annun_engine2_anti_ice_fault = 0
local annun_transponder_fail = 0
local annun_ELT = 0
local annun_cabin_fans_off = 0
local annun_adirs_adr1_off = 0
local annun_adirs_adr2_off = 0
local annun_adirs_adr3_off = 0
local annun_adirs_ir1_off = 0
local annun_adirs_ir2_off = 0
local annun_adirs_ir3_off = 0
local annun_adirs_adr1_fault = 0
local annun_adirs_adr2_fault = 0
local annun_adirs_adr3_fault = 0
local annun_adirs_ir1_fault = 0
local annun_adirs_ir2_fault = 0
local annun_adirs_ir3_fault = 0
local annun_auto_brake_lo_on = 0
local annun_auto_brake_med_on = 0
local annun_auto_brake_max_on = 0
local annun_auto_brake_lo_decel = 0
local annun_auto_brake_med_decel = 0
local annun_auto_brake_max_decel = 0
local annun_GPWS_warn = 0
local annun_GS_warn = 0
local annun_capt_flight_director_on = 0
local annun_fo_flight_director_on = 0
local annun_captain_ls_bars_on = 0
local annun_fo_ls_bars_on = 0
local annun_atc_comm = 0
local annun_gpws_flap_mode_off = 0
local annun_gpws_g_s_mode_off = 0
local annun_gpws_sys_off = 0
local annun_hyd_elec_green_pump_fault = 0
local annun_hyd_elec_green_pump_off = 0
local annun_hyd_elec_green_pump_on = 0
local annun_hyd_eng1_green_pump_fault = 0
local annun_hyd_eng1_green_pump_off = 0
local annun_hyd_eng2_green_pump_fault = 0
local annun_hyd_eng2_green_pump_off = 0
local annun_eng1_bleed_fault = 0
local annun_eng1_bleed_off = 0
local annun_hot_air1_off = 0
local annun_hot_air2_off = 0
local annun_fuel_pump_ctr_tank_R_fault = 0
local annun_fuel_pump_ctr_tank_R_off = 0
local annun_fuel_pump_R_stby_fault = 0
local annun_fuel_pump_R_stby_off = 0
local annun_fuel_pump_L_stby_fault = 0
local annun_fuel_pump_L_stby_off = 0
local annun_fuel_ctr_tank_xfr_fault = 0
local annun_fuel_ctr_tank_xfr_man = 0
local annun_cargo_fwd_agent_smoke = 0
local annun_cargo_aft_agent_smoke = 0
local annun_cargo_aft_agent_squib = 0
local annun_cargo_fwd_agent_squib = 0
local annun_cargo_disch_btl1 = 0
local annun_cargo_disch_btl2 = 0

local lcl = {
    annun_cargo_fwd_agent_smoke = 0,
    annun_cargo_aft_agent_smoke = 0,
    annun_cargo_aft_agent_squib = 0,
    annun_cargo_fwd_agent_squib = 0,
    annun_cargo_disch_btl1 = 0,
    annun_cargo_disch_btl2 = 0,

    engine1_heat_valve_pos = 0,
    engine2_heat_valve_pos = 0,
    atc_comm = 0,

    annun_rtp_C_offside_tuning = 0,
    annun_rtp_C_vhf_1 = 0,
    annun_rtp_C_vhf_2 = 0,
    annun_rtp_C_vhf_3 = 0,
    annun_rtp_C_hf_1 = 0,
    annun_rtp_C_am = 0,
    annun_rtp_C_hf_2 = 0,
    annun_rtp_C_no_op = 0,
    audio_panel_obs_call_light_vhf1 = 0,
    audio_panel_obs_call_light_vhf2 = 0,
    audio_panel_obs_call_light_att = 0,
    audio_panel_obs_call_light_gen = 0,

    annun_audio_panel_obs_mic1 = 0,
    annun_audio_panel_obs_mic2 = 0,
    annun_audio_panel_obs_mic3 = 0,
    annun_audio_panel_obs_mic4 = 0,
    annun_audio_panel_obs_mic5 = 0,
    annun_audio_panel_obs_mic6 = 0,
    annun_audio_panel_obs_mic7 = 0,
    annun_audio_panel_obs_mic8 = 0,
    annun_audio_panel_obs_mic9 = 0,
    annun_audio_panel_obs_mic10 = 0,
    annun_audio_panel_obs_voice = 0,

    annun_audio_panel_obs_listen = {},

    annun_capt_priority_light = 0,
    annun_capt_priority_arrow_light = 0,

    annun_hot_air1_fault = 0,
    annun_hot_air2_fault = 0,

    annun_nose_wheel_towing_fault = 0,

    annun_GPWS_sys_fault = 0,
    annun_GS_terr_fault = 0,

    annun_mcdu1_fail_fm = 0,
    annun_mcdu1_mcdu_menu = 0,
    annun_mcdu1_fm1 = 0,
    annun_mcdu1_fm2 = 0,
    annun_mcdu1_ind = 0,
    annun_mcdu1_rdy = 0,
    annun_mcdu1_line = 0,

    annun_mcdu3_fail_fm = 0,
    annun_mcdu3_mcdu_menu = 0,
    annun_mcdu3_fm1 = 0,
    annun_mcdu3_fm2 = 0,
    annun_mcdu3_ind = 0,
    annun_mcdu3_rdy = 0,
    annun_mcdu3_line = 0,

    annun_printer_paper_alarm = 0,
    annun_printer_test = 0,
    annun_printer_slew = 0,
    annun_printer_off = 0

}

for i = 0, 16-1 do
    lcl.annun_audio_panel_obs_listen[i] = 0
end



--*************************************************************************************--
--** 				            LOCAL UTILITY FUNCTIONS          			    	 **--
--*************************************************************************************--
--local bool2num = {[true] = 1, [false] = 0}
--local animate = animate
local m = math


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
local function CPDLC_incoming_DRhandler() end


--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--
A333DR_CPDLC_incoming		= create_dataref("laminar/A333/CPDLC_incoming", "number", CPDLC_incoming_DRhandler)


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
local function A333_annun_ac1_cache_globals()

    lcl_SIM_PERIOD = SIM_PERIOD

    --annun_light_switch_dim_or_brt = A333DR_ann_light_switch_pos <= 1
    --annun_ac1_brightness = A333DR_annun_brightness_ac1
    --annun_ac1_2_brightness = A333DR_annun_brightness_ac1_2
    --annun_light_switch_test = 1 * A333DR_dc_bus2_has_power

end



local function A333_atc_comm_timeout()
    lcl.atc_comm = 0
end

local function A333_CPDLC_com_annun_target()

    if A333DR_CPDLC_incoming == 1 then
        lcl.atc_comm = 1
        A333DR_CPDLC_incoming = 0
    elseif A333DR_CPDLC_incoming == 0 then
        if lcl.atc_comm == 1 then
            if not is_timer_scheduled(A333_atc_comm_timeout) then
                run_after_time(A333_atc_comm_timeout, 5.0)
            end
        end
    end

end





local function A333_annun_ac1_processing()

    --lcl_SIM_PERIOD = SIM_PERIOD

    local NUM_OBS_LISTENING_LIGHTS = 16

	local bool2num = {[true] = 1, [false] = 0}
    local animate = animate

    local annun_light_switch_dim_or_brt = A333DR_ann_light_switch_pos <= 1
    local annun_light_switch_test = A333DR_dc_bus2_has_power
    local annun_ac1_brightness = A333DR_annun_brightness_ac1
    local annun_ac1_2_brightness = A333DR_annun_brightness_ac1_2
    local sim_time_factor = m.fmod(simDR_flight_time, 0.6)
    local call_flasher = (sim_time_factor >= 0 and sim_time_factor <= 0.3) and 1 or 0
    local sim_time_factor3 = m.fmod(simDR_flight_time, 0.61)
    local flasher3 = (sim_time_factor3 >= 0 and sim_time_factor3 <= 0.305) and 1 or 0
    local sim_time_factor4 = m.fmod(simDR_flight_time, 0.57)
    local flasher4 = (sim_time_factor4 >= 0 and sim_time_factor4 <= 0.28) and 1 or 0

    local engine_thermal_anti_ice_switch = simDR_engine_thermal_anti_ice
    local auto_brake_level = simDR_auto_brake
    local gear_on_ground = simDR_gear_on_ground[1] == 1
    local acceleration = simDR_acceleration
    local engine_hyd_green_pump_actuator = simDR_engine_hyd_green_pump_actuator     --indexed
    local engine_is_burning_fuel = simDR_engine_is_burning_fuel
    local elec_hyd_green_pump_actuator = simDR_elec_hydraulic_green_pump_actuator
    local elec_pump_green_contactor = A333DR_elec_pump_green_contactor
    local engine1_is_running = engine_is_burning_fuel[0] == 1
    local engine2_is_running = engine_is_burning_fuel[1] == 1
    local engine1_hyd_green_pump_on = engine_hyd_green_pump_actuator[0] == 1
    local engine2_hyd_green_pump_on = engine_hyd_green_pump_actuator[1] == 1
    local hyd_green_pressure = simDR_green_pressure
    local center_right_fuel_pump_button_pos = A333DR_center_right_pump_pos
    local fuel_status_center_xfer = A333_ECAM_fuel_center_xfer_any
    local fuel_tank_qty = simDR_fuel_qty
    local right_fuel_standby_pump_button_pos = A333DR_right_standby_pump_pos
    local left_fuel_standby_pump_button_pos = A333DR_left_standby_pump_pos
    local center_fuel_xfr_button_pos = A333DR_fuel_center_xfr_pos
    local cargo_fire_test_timer = A333DR_cargo_fire_test_timer
    local cargo_fire_test_button_pos = A333DR_cargo_fire_test_pos
    local rtp_C_is_on = A333DR_rtp_C_off_status == 0
    local audio_panel_obs_listen_annun_target = {}
    local audio_panel_obs_listen_status = A333DR_audio_panel_obs_listen_status
    local capt_priority_status = A333DR_capt_priority_status


    -- SET ANNUNCIATOR STATUS (0/1)
    local engine1_anti_ice_annun_on_target = annun_light_switch_dim_or_brt and engine_thermal_anti_ice_switch[0] or annun_light_switch_test
    local engine2_anti_ice_annun_on_target = annun_light_switch_dim_or_brt and engine_thermal_anti_ice_switch[1] or annun_light_switch_test

    local engine1_heat_valve_pos_target = engine_thermal_anti_ice_switch[0] == 1 and bool2num[simDR_engine1_anti_ice_fail < 6] or 0
    local engine2_heat_valve_pos_target = engine_thermal_anti_ice_switch[1] == 1 and bool2num[simDR_engine2_anti_ice_fail < 6] or 0
    lcl.engine1_heat_valve_pos = animate(lcl.engine1_heat_valve_pos, engine1_heat_valve_pos_target, 6)
    lcl.engine2_heat_valve_pos = animate(lcl.engine2_heat_valve_pos, engine2_heat_valve_pos_target, 6)
    local engine1_anti_ice_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[lcl.engine1_heat_valve_pos ~= engine_thermal_anti_ice_switch[0]] or annun_light_switch_test
    local engine2_anti_ice_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[lcl.engine2_heat_valve_pos ~= engine_thermal_anti_ice_switch[1]] or annun_light_switch_test

    local transponder_fail_annun_target = annun_light_switch_dim_or_brt and bool2num[simDR_transponder_failure == 6] or annun_light_switch_test
    local ELT_annun_target = annun_light_switch_dim_or_brt and A333DR_elt_status or annun_light_switch_test
    local cabin_fans_off_annun_target = annun_light_switch_dim_or_brt and (1 - A333DR_cabin_fan_pos) or annun_light_switch_test
    local adirs_adr1_off_annun_target = annun_light_switch_dim_or_brt and (1 - A333DR_adirs_adr1_mode) or annun_light_switch_test
    local adirs_adr2_off_annun_target = annun_light_switch_dim_or_brt and (1 - A333DR_adirs_adr2_mode) or annun_light_switch_test
    local adirs_adr3_off_annun_target = annun_light_switch_dim_or_brt and (1 - A333DR_adirs_adr3_mode) or annun_light_switch_test
    local adirs_ir1_off_annun_target = annun_light_switch_dim_or_brt and (1 - A333DR_adirs_ir1_mode) or annun_light_switch_test
    local adirs_ir2_off_annun_target = annun_light_switch_dim_or_brt and (1 - A333DR_adirs_ir2_mode) or annun_light_switch_test
    local adirs_ir3_off_annun_target = annun_light_switch_dim_or_brt and (1 - A333DR_adirs_ir3_mode) or annun_light_switch_test
    local adirs_adr1_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local adirs_adr2_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local adirs_adr3_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local adirs_ir1_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local adirs_ir2_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local adirs_ir3_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local auto_brake_lo_on_annun_target = annun_light_switch_dim_or_brt and bool2num[auto_brake_level == 3] or annun_light_switch_test
    local auto_brake_med_on_annun_target = annun_light_switch_dim_or_brt and bool2num[auto_brake_level == 4] or annun_light_switch_test
    local auto_brake_max_on_annun_target = annun_light_switch_dim_or_brt and bool2num[auto_brake_level == 0 or auto_brake_level == 5] or annun_light_switch_test
    local auto_brake_lo_decel_annun_target = annun_light_switch_dim_or_brt and bool2num[gear_on_ground and auto_brake_level == 3 and acceleration <= -2.8] or annun_light_switch_test
    local auto_brake_med_decel_annun_target = annun_light_switch_dim_or_brt and bool2num[gear_on_ground and auto_brake_level == 4 and acceleration <= -4.64] or annun_light_switch_test
    local auto_brake_max_decel_annun_target = annun_light_switch_dim_or_brt and bool2num[gear_on_ground and (auto_brake_level == 0 or auto_brake_level == 5) and acceleration <= -5.15] or annun_light_switch_test
    local GPWS_warn_annun_target = annun_light_switch_dim_or_brt and simDR_gpws_annun or annun_light_switch_test
    local GS_warn_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_gpws_mode5 > 0] or annun_light_switch_test
    local capt_flight_director_on_annun_target = annun_light_switch_dim_or_brt and simDR_flight_director_capt or annun_light_switch_test
    local fo_flight_director_on_annun_target = annun_light_switch_dim_or_brt and simDR_flight_director_fo or annun_light_switch_test
    local captain_ls_bars_on_annun_target = annun_light_switch_dim_or_brt and A333DR_capt_ls_bars_status or annun_light_switch_test
    local fo_ls_bars_on_annun_target = annun_light_switch_dim_or_brt and A333DR_fo_ls_bars_status or annun_light_switch_test
    local atc_comm_annun_target = annun_light_switch_dim_or_brt and lcl.atc_comm or annun_light_switch_test
    local gpws_flap_mode_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_gpws_flap_status == 0] or annun_light_switch_test
    local gpws_g_s_mode_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_gpws_GS_status == 0] or annun_light_switch_test
    local gpws_sys_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_gpws_sys_status == 0] or annun_light_switch_test

    local hyd_elec_green_pump_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[simDR_elec_hyd_green_fault == 6] or annun_light_switch_test
    local hyd_elec_green_pump_off_annun_target = annun_light_switch_dim_or_brt and bool2num[elec_pump_green_contactor == 0] or annun_light_switch_test
    local hyd_elec_green_pump_on_annun_target = annun_light_switch_dim_or_brt and bool2num[elec_hyd_green_pump_actuator == 1] or annun_light_switch_test

    local hyd_eng1_green_pump_fault_annun_target = annun_light_switch_dim_or_brt
        and bool2num[((simDR_engine1_hyd_pump_fault == 6) or (engine1_hyd_green_pump_on and ((engine1_is_running or (not gear_on_ground)) and hyd_green_pressure < 2000)))]
        or annun_light_switch_test

    local hyd_eng1_green_pump_off_annun_target = annun_light_switch_dim_or_brt and bool2num[not engine1_hyd_green_pump_on] or annun_light_switch_test

    local hyd_eng2_green_pump_fault_annun_target = annun_light_switch_dim_or_brt
        and bool2num[((simDR_engine2_hyd_pump_fault == 6) or (engine2_hyd_green_pump_on and ((engine2_is_running == 1 or (not gear_on_ground)) and hyd_green_pressure < 2000)))]
        or annun_light_switch_test

    local hyd_eng2_green_pump_off_annun_target = annun_light_switch_dim_or_brt and bool2num[not engine2_hyd_green_pump_on] or annun_light_switch_test

    local eng1_bleed_fault_annun_target = annun_light_switch_dim_or_brt
        and bool2num[(simDR_engine_bleed_sov_status[0] > 0 and (simDR_engine_starter_running[0] == 1 or (A333DR_apu_bleed_switch_ctct_on_off == 1 and simDR_apu_running == 1)))
        or simDR_engine_bleed1_fail == 6]
        or annun_light_switch_test

    local eng1_bleed_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_eng1_bleed_switch_ctct_on_off == 0] or annun_light_switch_test
    local hot_air1_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_switches_hot_air1_pos == 0] or annun_light_switch_test
    local hot_air2_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_switches_hot_air2_pos == 0] or annun_light_switch_test
    local fuel_pump_ctr_tank_R_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[center_right_fuel_pump_button_pos >= 1 and fuel_status_center_xfer == 1 and fuel_tank_qty[1] < 250] or annun_light_switch_test
    local fuel_pump_ctr_tank_R_off_annun_target = annun_light_switch_dim_or_brt and bool2num[center_right_fuel_pump_button_pos == 0] or annun_light_switch_test
    local fuel_pump_R_stby_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[right_fuel_standby_pump_button_pos >= 1 and fuel_tank_qty[2] < 125] or annun_light_switch_test
    local fuel_pump_R_stby_off_annun_target = annun_light_switch_dim_or_brt and bool2num[right_fuel_standby_pump_button_pos == 0] or annun_light_switch_test
    local fuel_pump_L_stby_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[left_fuel_standby_pump_button_pos >= 1 and fuel_tank_qty[0] < 125] or annun_light_switch_test
    local fuel_pump_L_stby_off_annun_target = annun_light_switch_dim_or_brt and bool2num[left_fuel_standby_pump_button_pos == 0] or annun_light_switch_test
    local fuel_ctr_tank_xfr_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[center_fuel_xfr_button_pos == 1 and fuel_tank_qty[1] < 150] or annun_light_switch_test
    local fuel_ctr_tank_xfr_man_annun_target = annun_light_switch_dim_or_brt and bool2num[center_fuel_xfr_button_pos == 1] or annun_light_switch_test
    local cargo_fwd_agent_smoke_annun_target = annun_light_switch_dim_or_brt and bool2num[cargo_fire_test_timer > 4] or annun_light_switch_test
    local cargo_aft_agent_smoke_annun_target = annun_light_switch_dim_or_brt and bool2num[cargo_fire_test_timer > 4] or annun_light_switch_test
    local cargo_aft_agent_squib_annun_target = annun_light_switch_dim_or_brt and bool2num[cargo_fire_test_timer > 0 and cargo_fire_test_timer < 6] or annun_light_switch_test
    local cargo_fwd_agent_squib_annun_target = annun_light_switch_dim_or_brt and bool2num[cargo_fire_test_timer > 0 and cargo_fire_test_timer < 6] or annun_light_switch_test
    local cargo_disch_btl1_annun_target = annun_light_switch_dim_or_brt and cargo_fire_test_button_pos or annun_light_switch_test or annun_light_switch_test
    local cargo_disch_btl2_annun_target = annun_light_switch_dim_or_brt and cargo_fire_test_button_pos or annun_light_switch_test or annun_light_switch_test
    local rtp_C_offside_tuning_annun_target = annun_light_switch_dim_or_brt and (rtp_C_is_on and A333DR_rtp_C_offside_tuning_status or 0) or annun_light_switch_test
    local rtp_C_vhf_1_annun_target = annun_light_switch_dim_or_brt and (rtp_C_is_on and A333DR_rtp_C_vhf_1_status or 0) or annun_light_switch_test
    local rtp_C_vhf_2_annun_target = annun_light_switch_dim_or_brt and (rtp_C_is_on and A333DR_rtp_C_vhf_2_status or 0) or annun_light_switch_test
    local rtp_C_vhf_3_annun_target = annun_light_switch_dim_or_brt and (rtp_C_is_on and A333DR_rtp_C_vhf_3_status or 0) or annun_light_switch_test
    local rtp_C_hf_1_annun_target = annun_light_switch_dim_or_brt and (rtp_C_is_on and A333DR_rtp_C_hf_1_status or 0) or annun_light_switch_test
    local rtp_C_am_annun_target = annun_light_switch_dim_or_brt and (rtp_C_is_on and A333DR_rtp_C_hf_2_status or 0) or annun_light_switch_test
    local rtp_C_hf_2_annun_target = annun_light_switch_dim_or_brt and (rtp_C_is_on and A333DR_rtp_C_am_status or 0) or annun_light_switch_test
    local rtp_C_no_op_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test

    local audio_panel_obs_mic1_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_obs_mic1_status or annun_light_switch_test
  
    local audio_panel_obs_mic2_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_obs_mic2_status or annun_light_switch_test
    local audio_panel_obs_mic3_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_obs_mic3_status or annun_light_switch_test
    local audio_panel_obs_mic4_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_obs_mic4_status or annun_light_switch_test
    local audio_panel_obs_mic5_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_obs_mic5_status or annun_light_switch_test
    local audio_panel_obs_mic6_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_obs_mic6_status or annun_light_switch_test
    local audio_panel_obs_mic7_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_obs_mic7_status or annun_light_switch_test
    local audio_panel_obs_mic8_annun_target = annun_light_switch_dim_or_brt and (A333DR_audio_panel_obs_mic8_status * flasher3) or annun_light_switch_test
    local audio_panel_obs_mic9_annun_target = annun_light_switch_dim_or_brt and (A333DR_audio_panel_obs_mic9_status * flasher3) or annun_light_switch_test
    local audio_panel_obs_mic10_annun_target = annun_light_switch_dim_or_brt and  A333DR_audio_panel_obs_mic10_status or annun_light_switch_test
    local audio_panel_obs_voice_annun_target = annun_light_switch_dim_or_brt and  A333DR_audio_panel_obs_voice_status or annun_light_switch_test

    local audio_panel_obs_call_light_vhf1_target = annun_light_switch_dim_or_brt and (call_flasher * A333DR_obs_com1_activated) or annun_light_switch_test
    local audio_panel_obs_call_light_vhf2_target = annun_light_switch_dim_or_brt and (call_flasher * A333DR_obs_com2_activated) or annun_light_switch_test
    local audio_panel_obs_call_light_att_target = annun_light_switch_dim_or_brt and (call_flasher * A333DR_obs_att_activated) or annun_light_switch_test
    local audio_panel_obs_call_light_gen_target = annun_light_switch_dim_or_brt and (call_flasher * A333DR_obs_gen_activated) or annun_light_switch_test

    for i = 0, NUM_OBS_LISTENING_LIGHTS-1 do
        audio_panel_obs_listen_annun_target[i] = annun_light_switch_dim_or_brt and audio_panel_obs_listen_status[i] or annun_light_switch_test
    end

    local capt_priority_light_annun_target = annun_light_switch_dim_or_brt
        and (A333DR_dual_input == 1 and (capt_priority_status * flasher4) or capt_priority_status)
        or annun_light_switch_test

    local capt_priority_arrow_light_annun_target = annun_light_switch_dim_or_brt and A333DR_capt_arrow_status or annun_light_switch_test
    local hot_air1_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local hot_air2_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local nose_wheel_towing_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local GPWS_sys_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_gpws_sys_state == 1] or annun_light_switch_test
    local GS_terr_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_gpws_terr_state == 1] or annun_light_switch_test

    local mcdu1_fail_fm_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu1_mcdu_menu_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu1_fm1_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu1_fm2_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu1_ind_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu1_rdy_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu1_line_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test

    local mcdu3_fail_fm_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu3_mcdu_menu_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu3_fm1_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu3_fm2_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu3_ind_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu3_rdy_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu3_line_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test

    local printer_paper_alarm_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test


    -- SET ANNUNCIATOR FADE IN/OUT
    annun_engine1_anti_ice_on = animate(annun_engine1_anti_ice_on, engine1_anti_ice_annun_on_target, 13)
    annun_engine2_anti_ice_on = animate(annun_engine2_anti_ice_on, engine2_anti_ice_annun_on_target, 13)
    annun_engine1_anti_ice_fault = animate(annun_engine1_anti_ice_fault, engine1_anti_ice_fault_annun_target, 13)
    annun_engine2_anti_ice_fault = animate(annun_engine2_anti_ice_fault, engine2_anti_ice_fault_annun_target, 13)
    annun_transponder_fail = animate(annun_transponder_fail, transponder_fail_annun_target, 13)
    annun_ELT = animate(annun_ELT, ELT_annun_target, 25)
    annun_cabin_fans_off = animate(annun_cabin_fans_off, cabin_fans_off_annun_target, 13)
    annun_adirs_adr1_off = animate(annun_adirs_adr1_off, adirs_adr1_off_annun_target, 13)
    annun_adirs_adr2_off = animate(annun_adirs_adr2_off, adirs_adr2_off_annun_target, 13)
    annun_adirs_adr3_off = animate(annun_adirs_adr3_off, adirs_adr3_off_annun_target, 13)
    annun_adirs_ir1_off = animate(annun_adirs_ir1_off, adirs_ir1_off_annun_target, 13)
    annun_adirs_ir2_off = animate(annun_adirs_ir2_off, adirs_ir2_off_annun_target, 13)
    annun_adirs_ir3_off = animate(annun_adirs_ir3_off, adirs_ir3_off_annun_target, 13)
    annun_adirs_adr1_fault = animate(annun_adirs_adr1_fault, adirs_adr1_fault_annun_target, 13)
    annun_adirs_adr2_fault = animate(annun_adirs_adr2_fault, adirs_adr2_fault_annun_target, 13)
    annun_adirs_adr3_fault = animate(annun_adirs_adr3_fault, adirs_adr3_fault_annun_target, 13)
    annun_adirs_ir1_fault = animate(annun_adirs_ir1_fault, adirs_ir1_fault_annun_target, 13)
    annun_adirs_ir2_fault = animate(annun_adirs_ir2_fault, adirs_ir2_fault_annun_target, 13)
    annun_adirs_ir3_fault = animate(annun_adirs_ir3_fault, adirs_ir3_fault_annun_target, 13)
    annun_auto_brake_lo_on = animate(annun_auto_brake_lo_on, auto_brake_lo_on_annun_target, 13)
    annun_auto_brake_med_on = animate(annun_auto_brake_med_on, auto_brake_med_on_annun_target, 13)
    annun_auto_brake_max_on = animate(annun_auto_brake_max_on, auto_brake_max_on_annun_target, 13)
    annun_auto_brake_lo_decel = animate(annun_auto_brake_lo_decel, auto_brake_lo_decel_annun_target, 13)
    annun_auto_brake_med_decel = animate(annun_auto_brake_med_decel, auto_brake_med_decel_annun_target, 13)
    annun_auto_brake_max_decel = animate(annun_auto_brake_max_decel, auto_brake_max_decel_annun_target, 13)
    annun_GPWS_warn = animate(annun_GPWS_warn, GPWS_warn_annun_target, 13)
    annun_GS_warn = animate(annun_GS_warn, GS_warn_annun_target, 13)
    annun_capt_flight_director_on = animate(annun_capt_flight_director_on, capt_flight_director_on_annun_target, 13)
    annun_fo_flight_director_on = animate(annun_fo_flight_director_on, fo_flight_director_on_annun_target, 13)
    annun_captain_ls_bars_on = animate(annun_captain_ls_bars_on, captain_ls_bars_on_annun_target, 13)
    annun_fo_ls_bars_on = animate(annun_fo_ls_bars_on, fo_ls_bars_on_annun_target, 13)
    annun_atc_comm = animate(annun_atc_comm, atc_comm_annun_target, 13)
    annun_gpws_flap_mode_off = animate(annun_gpws_flap_mode_off, gpws_flap_mode_off_annun_target, 13)
    annun_gpws_g_s_mode_off = animate(annun_gpws_g_s_mode_off, gpws_g_s_mode_off_annun_target, 13)
    annun_gpws_sys_off = animate(annun_gpws_sys_off, gpws_sys_off_annun_target, 13)
    annun_hyd_elec_green_pump_fault = animate(annun_hyd_elec_green_pump_fault, hyd_elec_green_pump_fault_annun_target, 13)
    annun_hyd_elec_green_pump_off = animate(annun_hyd_elec_green_pump_off, hyd_elec_green_pump_off_annun_target, 13)
    annun_hyd_elec_green_pump_on = animate(annun_hyd_elec_green_pump_on, hyd_elec_green_pump_on_annun_target, 13)
    annun_hyd_eng1_green_pump_fault = animate(annun_hyd_eng1_green_pump_fault, hyd_eng1_green_pump_fault_annun_target, 13)
    annun_hyd_eng1_green_pump_off = animate(annun_hyd_eng1_green_pump_off, hyd_eng1_green_pump_off_annun_target, 13)
    annun_hyd_eng2_green_pump_fault = animate(annun_hyd_eng2_green_pump_fault, hyd_eng2_green_pump_fault_annun_target, 13)
    annun_hyd_eng2_green_pump_off = animate(annun_hyd_eng2_green_pump_off, hyd_eng2_green_pump_off_annun_target, 13)
    annun_eng1_bleed_fault = animate(annun_eng1_bleed_fault, eng1_bleed_fault_annun_target, 13)
    annun_eng1_bleed_off = animate(annun_eng1_bleed_off, eng1_bleed_off_annun_target, 13)
    annun_hot_air1_off = animate(annun_hot_air1_off, hot_air1_off_annun_target, 13)
    annun_hot_air2_off = animate(annun_hot_air2_off, hot_air2_off_annun_target, 13)
    annun_fuel_pump_ctr_tank_R_fault = animate(annun_fuel_pump_ctr_tank_R_fault, fuel_pump_ctr_tank_R_fault_annun_target, 13)
    annun_fuel_pump_ctr_tank_R_off = animate(annun_fuel_pump_ctr_tank_R_off, fuel_pump_ctr_tank_R_off_annun_target, 13)
    annun_fuel_pump_R_stby_fault = animate(annun_fuel_pump_R_stby_fault, fuel_pump_R_stby_fault_annun_target, 13)
    annun_fuel_pump_R_stby_off = animate(annun_fuel_pump_R_stby_off, fuel_pump_R_stby_off_annun_target, 13)
    annun_fuel_pump_L_stby_fault = animate(annun_fuel_pump_L_stby_fault, fuel_pump_L_stby_fault_annun_target, 13)
    annun_fuel_pump_L_stby_off = animate(annun_fuel_pump_L_stby_off, fuel_pump_L_stby_off_annun_target, 13)
    annun_fuel_ctr_tank_xfr_fault = animate(annun_fuel_ctr_tank_xfr_fault, fuel_ctr_tank_xfr_fault_annun_target, 13)
    annun_fuel_ctr_tank_xfr_man = animate(annun_fuel_ctr_tank_xfr_man, fuel_ctr_tank_xfr_man_annun_target, 13)
    lcl.annun_cargo_fwd_agent_smoke = animate(lcl.annun_cargo_fwd_agent_smoke, cargo_fwd_agent_smoke_annun_target, 13)
    lcl.annun_cargo_aft_agent_smoke = animate(lcl.annun_cargo_aft_agent_smoke, cargo_aft_agent_smoke_annun_target, 13)
    lcl.annun_cargo_aft_agent_squib = animate(lcl.annun_cargo_aft_agent_squib, cargo_aft_agent_squib_annun_target, 13)
    lcl.annun_cargo_fwd_agent_squib = animate(lcl.annun_cargo_fwd_agent_squib, cargo_fwd_agent_squib_annun_target, 13)
    lcl.annun_cargo_disch_btl1 = animate(lcl.annun_cargo_disch_btl1, cargo_disch_btl1_annun_target, 13)
    lcl.annun_cargo_disch_btl2 = animate(lcl.annun_cargo_disch_btl2, cargo_disch_btl2_annun_target, 13)
    lcl.annun_rtp_C_offside_tuning = animate(lcl.annun_rtp_C_offside_tuning, rtp_C_offside_tuning_annun_target, 13)
    lcl.annun_rtp_C_vhf_1 = animate(lcl.annun_rtp_C_vhf_1, rtp_C_vhf_1_annun_target, 13)
    lcl.annun_rtp_C_vhf_2 = animate(lcl.annun_rtp_C_vhf_2, rtp_C_vhf_2_annun_target, 13)
    lcl.annun_rtp_C_vhf_3 = animate(lcl.annun_rtp_C_vhf_3, rtp_C_vhf_3_annun_target, 13)
    lcl.annun_rtp_C_hf_1 = animate(lcl.annun_rtp_C_hf_1, rtp_C_hf_1_annun_target, 13)
    lcl.annun_rtp_C_am = animate(lcl.annun_rtp_C_am, rtp_C_am_annun_target, 13)
    lcl.annun_rtp_C_hf_2 = animate(lcl.annun_rtp_C_hf_2, rtp_C_hf_2_annun_target, 13)
    lcl.annun_rtp_C_no_op = animate(lcl.annun_rtp_C_no_op, rtp_C_no_op_annun_target, 13)
    lcl.annun_audio_panel_obs_mic1 = animate(lcl.annun_audio_panel_obs_mic1, audio_panel_obs_mic1_annun_target, 13)
    lcl.annun_audio_panel_obs_mic2 = animate(lcl.annun_audio_panel_obs_mic2, audio_panel_obs_mic2_annun_target, 13)
    lcl.annun_audio_panel_obs_mic3 = animate(lcl.annun_audio_panel_obs_mic3, audio_panel_obs_mic3_annun_target, 13)
    lcl.annun_audio_panel_obs_mic4 = animate(lcl.annun_audio_panel_obs_mic4, audio_panel_obs_mic4_annun_target, 13)
    lcl.annun_audio_panel_obs_mic5 = animate(lcl.annun_audio_panel_obs_mic5, audio_panel_obs_mic5_annun_target, 13)
    lcl.annun_audio_panel_obs_mic6 = animate(lcl.annun_audio_panel_obs_mic6, audio_panel_obs_mic6_annun_target, 13)
    lcl.annun_audio_panel_obs_mic7 = animate(lcl.annun_audio_panel_obs_mic7, audio_panel_obs_mic7_annun_target, 13)
    lcl.annun_audio_panel_obs_mic8 = animate(lcl.annun_audio_panel_obs_mic8, audio_panel_obs_mic8_annun_target, 13)
    lcl.annun_audio_panel_obs_mic9 = animate(lcl.annun_audio_panel_obs_mic9, audio_panel_obs_mic9_annun_target, 13)
    lcl.annun_audio_panel_obs_mic10 = animate(lcl.annun_audio_panel_obs_mic10, audio_panel_obs_mic10_annun_target, 13)
    lcl.annun_audio_panel_obs_voice = animate(lcl.annun_audio_panel_obs_voice, audio_panel_obs_voice_annun_target, 13)
    lcl.audio_panel_obs_call_light_vhf1 = animate(lcl.audio_panel_obs_call_light_vhf1, audio_panel_obs_call_light_vhf1_target, 13)
    lcl.audio_panel_obs_call_light_vhf2 = animate(lcl.audio_panel_obs_call_light_vhf2, audio_panel_obs_call_light_vhf2_target, 13)
	lcl.audio_panel_obs_call_light_att = animate(lcl.audio_panel_obs_call_light_att, audio_panel_obs_call_light_att_target, 13) 
    lcl.audio_panel_obs_call_light_gen = animate(lcl.audio_panel_obs_call_light_gen, audio_panel_obs_call_light_gen_target, 13)

    for i = 0, NUM_OBS_LISTENING_LIGHTS-1 do
        lcl.annun_audio_panel_obs_listen[i] = animate(lcl.annun_audio_panel_obs_listen[i], audio_panel_obs_listen_annun_target[i], 13)
    end

    lcl.annun_capt_priority_light = animate(lcl.annun_capt_priority_light, capt_priority_light_annun_target, 13)
    lcl.annun_capt_priority_arrow_light = animate(lcl.annun_capt_priority_arrow_light, capt_priority_arrow_light_annun_target, 13)
    lcl.annun_hot_air1_fault = animate(lcl.annun_hot_air1_fault, hot_air1_fault_annun_target, 13)
    lcl.annun_hot_air2_fault = animate(lcl.annun_hot_air2_fault, hot_air2_fault_annun_target, 13)
    lcl.annun_nose_wheel_towing_fault = animate(lcl.annun_nose_wheel_towing_fault, nose_wheel_towing_fault_annun_target, 13)
    lcl.annun_GPWS_sys_fault = animate(lcl.annun_GPWS_sys_fault, GPWS_sys_fault_annun_target, 13)
    lcl.annun_GS_terr_fault = animate(lcl.annun_GS_terr_fault, GS_terr_fault_annun_target, 13)
    lcl.annun_mcdu1_fail_fm = animate(lcl.annun_mcdu1_fail_fm, mcdu1_fail_fm_annun_target, 13)
    lcl.annun_mcdu1_mcdu_menu = animate(lcl.annun_mcdu1_mcdu_menu, mcdu1_mcdu_menu_annun_target, 13)
    lcl.annun_mcdu1_fm1 = animate(lcl.annun_mcdu1_fm1, mcdu1_fm1_annun_target, 13)
    lcl.annun_mcdu1_fm2 = animate(lcl.annun_mcdu1_fm2, mcdu1_fm2_annun_target, 13)
    lcl.annun_mcdu1_ind = animate(lcl.annun_mcdu1_ind, mcdu1_ind_annun_target, 13)
    lcl.annun_mcdu1_rdy = animate(lcl.annun_mcdu1_rdy, mcdu1_rdy_annun_target, 13)
    lcl.annun_mcdu1_line = animate(lcl.annun_mcdu1_line, mcdu1_line_annun_target, 13)
    lcl.annun_mcdu3_fail_fm = animate(lcl.annun_mcdu3_fail_fm, mcdu3_fail_fm_annun_target, 13)
    lcl.annun_mcdu3_mcdu_menu = animate(lcl.annun_mcdu3_mcdu_menu, mcdu3_mcdu_menu_annun_target, 13)
    lcl.annun_mcdu3_fm1 = animate(lcl.annun_mcdu3_fm1, mcdu3_fm1_annun_target, 13)
    lcl.annun_mcdu3_fm2 = animate(lcl.annun_mcdu3_fm2, mcdu3_fm2_annun_target, 13)
    lcl.annun_mcdu3_ind = animate(lcl.annun_mcdu3_ind, mcdu3_ind_annun_target, 13)
    lcl.annun_mcdu3_rdy = animate(lcl.annun_mcdu3_rdy, mcdu3_rdy_annun_target, 13)
    lcl.annun_mcdu3_line = animate(lcl.annun_mcdu3_line, mcdu3_line_annun_target, 13)
    lcl.annun_printer_paper_alarm = animate(lcl.annun_printer_paper_alarm, printer_paper_alarm_annun_target, 13)


    -- SET ANNUNCIATOR BRIGHTNESS AND ASSIGN TO DATAREF
    A333DR_annun_engine1_anti_ice_on = annun_engine1_anti_ice_on * annun_ac1_brightness
    A333DR_annun_engine2_anti_ice_on = annun_engine2_anti_ice_on * annun_ac1_brightness
    A333DR_annun_engine1_anti_ice_fault = annun_engine1_anti_ice_fault * annun_ac1_brightness
    A333DR_annun_engine2_anti_ice_fault = annun_engine2_anti_ice_fault * annun_ac1_brightness
    A333DR_annun_elt = annun_ELT -- * annun_ac1_brightness
	A333DR_annun_elt_no_anim = ELT_annun_target
    A333DR_annun_ventilation_cab_fans_off = annun_cabin_fans_off * annun_ac1_brightness
    A333DR_annun_adirs_adr1_off = annun_adirs_adr1_off * annun_ac1_brightness
    A333DR_annun_adirs_adr2_off = annun_adirs_adr2_off * annun_ac1_brightness
    A333DR_annun_adirs_adr3_off = annun_adirs_adr3_off * annun_ac1_brightness
    A333DR_annun_adirs_ir1_off = annun_adirs_ir1_off * annun_ac1_brightness
    A333DR_annun_adirs_ir2_off = annun_adirs_ir2_off * annun_ac1_brightness
    A333DR_annun_adirs_ir3_off = annun_adirs_ir3_off * annun_ac1_brightness
    A333DR_annun_adirs_adr1_fault = annun_adirs_adr1_fault * annun_ac1_brightness
    A333DR_annun_adirs_adr2_fault = annun_adirs_adr2_fault * annun_ac1_brightness
    A333DR_annun_adirs_adr3_fault = annun_adirs_adr3_fault * annun_ac1_brightness
    A333DR_annun_adirs_ir1_fault = annun_adirs_ir1_fault * annun_ac1_brightness
    A333DR_annun_adirs_ir2_fault = annun_adirs_ir2_fault * annun_ac1_brightness
    A333DR_annun_adirs_ir3_fault = annun_adirs_ir3_fault * annun_ac1_brightness
    A333DR_annun_auto_brake_lo_on = annun_auto_brake_lo_on * annun_ac1_brightness
    A333DR_annun_auto_brake_med_on = annun_auto_brake_med_on * annun_ac1_brightness
    A333DR_annun_auto_brake_max_on = annun_auto_brake_max_on * annun_ac1_brightness
    A333DR_annun_auto_brake_lo_decel = annun_auto_brake_lo_decel * annun_ac1_brightness
    A333DR_annun_auto_brake_med_decel = annun_auto_brake_med_decel * annun_ac1_brightness
    A333DR_annun_auto_brake_max_decel = annun_auto_brake_max_decel * annun_ac1_brightness
    A333DR_annun_capt_flight_director_on = annun_capt_flight_director_on * annun_ac1_brightness
    A333DR_annun_fo_flight_director_on = annun_fo_flight_director_on * annun_ac1_brightness
    A333DR_annun_captain_ls_bars_on = annun_captain_ls_bars_on * annun_ac1_brightness
    A333DR_annun_fo_ls_bars_on = annun_fo_ls_bars_on * annun_ac1_brightness
    A333DR_annun_atc_comm = annun_atc_comm * annun_ac1_brightness
    A333DR_annun_gpws_flap_mode_off = annun_gpws_flap_mode_off * annun_ac1_brightness
    A333DR_annun_gpws_g_s_mode_off = annun_gpws_g_s_mode_off * annun_ac1_brightness
    A333DR_annun_gpws_sys_off = annun_gpws_sys_off * annun_ac1_brightness
    A333DR_annun_hyd_elec_green_pump_fault = annun_hyd_elec_green_pump_fault * annun_ac1_brightness
    A333DR_annun_hyd_elec_green_pump_off = annun_hyd_elec_green_pump_off * annun_ac1_brightness
    A333DR_annun_hyd_elec_green_pump_on = annun_hyd_elec_green_pump_on * annun_ac1_brightness
    A333DR_annun_hyd_eng1_green_pump_fault = annun_hyd_eng1_green_pump_fault * annun_ac1_brightness
    A333DR_annun_hyd_eng1_green_pump_off = annun_hyd_eng1_green_pump_off * annun_ac1_brightness
    A333DR_annun_hyd_eng2_green_pump_fault = annun_hyd_eng2_green_pump_fault * annun_ac1_brightness
    A333DR_annun_hyd_eng2_green_pump_off = annun_hyd_eng2_green_pump_off * annun_ac1_brightness
    A333DR_annun_eng1_bleed_fault = annun_eng1_bleed_fault * annun_ac1_brightness
    A333DR_annun_eng1_bleed_off = annun_eng1_bleed_off * annun_ac1_brightness
    A333DR_annun_hot_air1_off = annun_hot_air1_off * annun_ac1_brightness
    A333DR_annun_hot_air2_off = annun_hot_air2_off * annun_ac1_brightness
    A333DR_annun_hot_air1_fault = lcl.annun_hot_air1_fault * annun_ac1_brightness
    A333DR_annun_hot_air2_fault = lcl.annun_hot_air2_fault * annun_ac1_brightness
    A333DR_annun_fuel_pump_ctr_tank_R_fault = annun_fuel_pump_ctr_tank_R_fault * annun_ac1_brightness
    A333DR_annun_fuel_pump_ctr_tank_R_off = annun_fuel_pump_ctr_tank_R_off * annun_ac1_brightness
    A333DR_annun_fuel_pump_R_stby_fault = annun_fuel_pump_R_stby_fault * annun_ac1_brightness
    A333DR_annun_fuel_pump_R_stby_off = annun_fuel_pump_R_stby_off * annun_ac1_brightness
    A333DR_annun_fuel_pump_L_stby_fault = annun_fuel_pump_L_stby_fault * annun_ac1_brightness
    A333DR_annun_fuel_pump_L_stby_off = annun_fuel_pump_L_stby_off * annun_ac1_brightness
    A333DR_annun_fuel_ctr_tank_xfr_fault = annun_fuel_ctr_tank_xfr_fault * annun_ac1_brightness
    A333DR_annun_fuel_ctr_tank_xfr_man = annun_fuel_ctr_tank_xfr_man * annun_ac1_brightness
    A333DR_annun_cargo_aft_agent_squib = lcl.annun_cargo_aft_agent_squib * annun_ac1_brightness
    A333DR_annun_cargo_fwd_agent_squib = lcl.annun_cargo_fwd_agent_squib * annun_ac1_brightness
    A333DR_annun_cargo_disch_btl1 = lcl.annun_cargo_disch_btl1 * annun_ac1_brightness
    A333DR_annun_cargo_disch_btl2 = lcl.annun_cargo_disch_btl2 * annun_ac1_brightness
    A333DR_audio_panel_obs_mic1_annun = lcl.annun_audio_panel_obs_mic1 * annun_ac1_brightness
    A333DR_audio_panel_obs_mic2_annun = lcl.annun_audio_panel_obs_mic2 * annun_ac1_brightness
    A333DR_audio_panel_obs_mic3_annun = lcl.annun_audio_panel_obs_mic3 * annun_ac1_brightness
    A333DR_audio_panel_obs_mic4_annun = lcl.annun_audio_panel_obs_mic4 * annun_ac1_brightness
    A333DR_audio_panel_obs_mic5_annun = lcl.annun_audio_panel_obs_mic5 * annun_ac1_brightness
    A333DR_audio_panel_obs_mic6_annun = lcl.annun_audio_panel_obs_mic6 * annun_ac1_brightness
    A333DR_audio_panel_obs_mic7_annun = lcl.annun_audio_panel_obs_mic7 * annun_ac1_brightness
    A333DR_audio_panel_obs_mic8_annun = lcl.annun_audio_panel_obs_mic8 * annun_ac1_brightness
    A333DR_audio_panel_obs_mic9_annun = lcl.annun_audio_panel_obs_mic9 * annun_ac1_brightness
    A333DR_audio_panel_obs_mic10_annun = lcl.annun_audio_panel_obs_mic10 * annun_ac1_brightness
    A333DR_audio_panel_obs_voice_annun = lcl.annun_audio_panel_obs_voice * annun_ac1_brightness
    A333DR_audio_panel_obs_call_light_vhf1 = lcl.audio_panel_obs_call_light_vhf1 * annun_ac1_brightness
    A333DR_audio_panel_obs_call_light_vhf2 = lcl.audio_panel_obs_call_light_vhf2 * annun_ac1_brightness
	A333DR_audio_panel_obs_call_light_att = lcl.audio_panel_obs_call_light_att * annun_ac1_brightness 
    A333DR_audio_panel_obs_call_light_gen = lcl.audio_panel_obs_call_light_gen * annun_ac1_brightness
    A333DR_annun_nose_wheel_towing_fault = lcl.annun_nose_wheel_towing_fault * annun_ac1_brightness
    A333DR_annun_gpws_sys_fault = lcl.annun_GPWS_sys_fault * annun_ac1_brightness
    A333DR_annun_gpws_terr_fault = lcl.annun_GS_terr_fault * annun_ac1_brightness
    A333DR_annun_mcdu1_fail_fm = lcl.annun_mcdu1_fail_fm * annun_ac1_brightness
    A333DR_annun_mcdu1_mcdu_menu = lcl.annun_mcdu1_mcdu_menu * annun_ac1_brightness
    A333DR_annun_mcdu1_fm1 = lcl.annun_mcdu1_fm1 * annun_ac1_brightness
    A333DR_annun_mcdu1_fm2 = lcl.annun_mcdu1_fm2 * annun_ac1_brightness
    A333DR_annun_mcdu1_ind = lcl.annun_mcdu1_ind * annun_ac1_brightness
    A333DR_annun_mcdu1_rdy = lcl.annun_mcdu1_rdy * annun_ac1_brightness
    A333DR_annun_mcdu1_line = lcl.annun_mcdu1_line * annun_ac1_brightness
    A333DR_annun_mcdu3_fail_fm = lcl.annun_mcdu3_fail_fm * annun_ac1_brightness
    A333DR_annun_mcdu3_mcdu_menu = lcl.annun_mcdu3_mcdu_menu * annun_ac1_brightness
    A333DR_annun_mcdu3_fm1 = lcl.annun_mcdu3_fm1 * annun_ac1_brightness
    A333DR_annun_mcdu3_fm2 = lcl.annun_mcdu3_fm2 * annun_ac1_brightness
    A333DR_annun_mcdu3_ind = lcl.annun_mcdu3_ind * annun_ac1_brightness
    A333DR_annun_mcdu3_rdy = lcl.annun_mcdu3_rdy * annun_ac1_brightness
    A333DR_annun_mcdu3_line = lcl.annun_mcdu3_line * annun_ac1_brightness
    A333DR_annun_printer_paper_alarm = lcl.annun_printer_paper_alarm * annun_ac1_brightness


    A333DR_annun_transponder_fail = annun_transponder_fail * annun_ac1_2_brightness
    A333DR_annun_GPWS_warn = annun_GPWS_warn * annun_ac1_2_brightness
    A333DR_annun_GS_warn = annun_GS_warn * annun_ac1_2_brightness
    A333DR_annun_cargo_fwd_agent_smoke = lcl.annun_cargo_fwd_agent_smoke * annun_ac1_2_brightness
    A333DR_annun_cargo_aft_agent_smoke = lcl.annun_cargo_aft_agent_smoke * annun_ac1_2_brightness
    A333DR_annun_rtp_C_offside_tuning = lcl.annun_rtp_C_offside_tuning * annun_ac1_2_brightness
    A333DR_annun_rtp_C_vhf_1 = lcl.annun_rtp_C_vhf_1 * annun_ac1_2_brightness
    A333DR_annun_rtp_C_vhf_2 = lcl.annun_rtp_C_vhf_2 * annun_ac1_2_brightness
    A333DR_annun_rtp_C_vhf_3 = lcl.annun_rtp_C_vhf_3 * annun_ac1_2_brightness
    A333DR_annun_rtp_C_hf_1 = lcl.annun_rtp_C_hf_1 * annun_ac1_2_brightness
    A333DR_annun_rtp_C_am = lcl.annun_rtp_C_am * annun_ac1_2_brightness
    A333DR_annun_rtp_C_hf_2 = lcl.annun_rtp_C_hf_2 * annun_ac1_2_brightness
    A333DR_annun_rtp_C_no_op = lcl.annun_rtp_C_no_op * annun_ac1_2_brightness

    local br = {}
    for i = 0, NUM_OBS_LISTENING_LIGHTS-1 do
        br[i] = lcl.annun_audio_panel_obs_listen[i] * annun_ac1_2_brightness
    end
    A333DR_audio_panel_obs_listen_annun = br

    A333DR_capt_priority_light_annun = lcl.annun_capt_priority_light * annun_ac1_2_brightness
    A333DR_capt_priority_arrow_light_annun = lcl.annun_capt_priority_arrow_light * annun_ac1_2_brightness

end








local function A333_fws_hyd_pump_fault()

    A333DR_hyd_elec_green_pump_fault = annun_hyd_elec_green_pump_fault
    A333DR_hyd_eng1_green_pump_fault = annun_hyd_eng1_green_pump_fault
    A333DR_hyd_eng2_green_pump_fault = annun_hyd_eng2_green_pump_fault

end



--*************************************************************************************--
--** 				                     PROCESSING             	    			 **--
--*************************************************************************************--

--===| INIT ALL |========================================================================
function A333_annun_ac1_init_all()



end




--===| INIT ER |=========================================================================
function A333_annun_ac1_init_ER()



end




--===| INIT CD |=========================================================================
function A333_annun_ac1_init_CD()



end




--===| DEFERRED INITIALIZATION |=========================================================
function A333_annun_ac1_deferred_init()




end



--===| DEFERRED PROCESSING |=============================================================
function A333_annun_ac1_deferred_processing()



end




--=== AIRCRAFT LOAD =====================================================================
function A333_annun_ac1_aircraft_load()



end



--=== FLIGHT START ======================================================================
function A333_annun_ac1_flight_start()



end



--=== BEFORE PHYSICS ====================================================================
function A333_annun_ac1_before_physics()



end



--=== AFTER PHYSICS =====================================================================
function A333_annun_ac1_after_physics()

    A333_annun_ac1_cache_globals()
    A333_annun_ac1_processing()
    A333_fws_hyd_pump_fault()

end




--=== FLIGHT CRASH ======================================================================
function A333_annun_ac1_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_annun_ac1_aircraft_unload()



end




--=== AIRCRAFT UNLOAD ===================================================================
function A333_annun_ac1_after_replay()

    A333_annun_ac1_cache_globals()
    A333_annun_ac1_processing()
    A333_fws_hyd_pump_fault()

end



--*************************************************************************************--
--** 				                 SUB-SCRIPT LOADING            	     			 **--
--*************************************************************************************--



