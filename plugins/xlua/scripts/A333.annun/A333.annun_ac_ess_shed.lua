--[[
*****************************************************************************************
* Program Script Name	:	A333.annun_ac_ess_shed.lua
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

local annun_light_switch_dim_or_brt = false
local annun_ac_ess_shed_brightness = 0
local annun_ac_ess_shed2_brightness = 0
local annun_light_switch_test = 0

local wing_heat_valve_pos_left = 0
local wing_heat_valve_pos_right = 0
local wing_heat_valve_pos_right = 0
local oxygen_tmr_reset_timer = 0

local fuel_crossfeed_valve_pos = 0

local annun_apu_gen_fault = 0
local annun_wing_anti_ice_fault = 0
local annun_wing_anti_ice_on = 0
local annun_turb_damper_off = 0
local annun_sec1_off = 0
local annun_cargo_fwd_isol_valves_off = 0
local annun_cargo_bulk_isol_valves_off = 0
local annun_cargo_bulk_hot_air = 0
local annun_landing_gear_nose_green = 0
local annun_landing_gear_left_green = 0
local annun_landing_gear_right_green = 0
local annun_landing_gear_nose_unlk = 0
local annun_landing_gear_left_unlk = 0
local annun_landing_gear_right_unlk = 0
local annun_oxygen_tmr_reset_on = 0
local annun_oxygen_tmr_reset_fault = 0
local annun_oxygen_crew_supply_off = 0
local annun_gpws_terr_off = 0
local annun_evac_command_on = 0
local annun_evac_command_evac = 0
local annun_calls_emer_call = 0
local annun_calls_emer_on = 0
local annun_ditching_on = 0
local annun_hyd_elec_blue_pump_fault = 0
local annun_hyd_elec_blue_pump_off = 0
local annun_hyd_elec_blue_pump_on = 0
local annun_hyd_eng1_blue_pump_fault = 0
local annun_hyd_eng1_blue_pump_off = 0
local annun_elec_gen1_off_reset = 0
local annun_elec_gen2_off_reset = 0
local annun_elec_idg1_off = 0
local annun_elec_idg2_off = 0
local annun_elec_galley_off = 0
local annun_autopilot_a_thr_mode = 0
local annun_autopilot_alt_mode = 0
local annun_autopilot_ap1_mode = 0
local annun_autopilot_ap2_mode = 0
local annun_autopilot_appr_mode = 0
local annun_autopilot_loc_mode = 0
local annun_fuel_pump_L1_fault = 0
local annun_fuel_pump_L1_off = 0
local annun_fuel_pump_R1_fault = 0
local annun_fuel_pump_R1_off = 0
local annun_fuel_wing_x_feed_on = 0
local annun_fuel_wing_x_feed_open = 0
local annun_fuel_t_tank_mode_fault = 0
local annun_fuel_t_tank_mode_fwd = 0
local annun_true_north = 0
local annun_cargo_bulk_hot_air_fault = 0
local annun_cargo_fwd_isol_vlv_fault = 0
local annun_cargo_bulk_isol_vlv_fault = 0
local annun_elec_galley_fault = 0
local annun_air_ovht_cnd_fans_reset_fault = 0

local lcl = {
    annun_cockpit_door_ctl_strike_top_backup = 0,
    annun_cockpit_door_ctl_strike_mid_backup = 0,
    annun_cockpit_door_ctl_strike_btm_backup = 0,
    annun_cockpit_door_ctl_channel1_backup = 0,
    annun_cockpit_door_ctl_channel2_backup = 0,
    annun_cockpit_door_sw_ovrd_arm = 0,
    annun_cockpit_door_sw_ovrd_fault = 0,
    annun_pax_satcom_off = 0,
    annun_pax_system_off = 0
}


--*************************************************************************************--
--** 				            LOCAL UTILITY FUNCTIONS          			    	 **--
--*************************************************************************************--



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
local function A333_annun_ac_ess_shed_cache_globals()


end



local function A333_oxy_timer_reset_fault()
    oxygen_tmr_reset_timer = A333DR_pax_oxy_reset_pos >= 1 and (oxygen_tmr_reset_timer + lcl_SIM_PERIOD) or 0
    return (oxygen_tmr_reset_timer > 30) and 1 or 0
end




local function A333_annun_ac_ess_shed_processing()

    --local lcl_SIM_PERIOD = SIM_PERIOD

    local m = math
    local bool2num = {[true] = 1, [false] = 0}
    local animate = animate

    local annun_light_switch_dim_or_brt = A333DR_ann_light_switch_pos <= 1
    local annun_ac_ess_shed_brightness = A333DR_annun_brightness_ac_ess_shed
    local annun_ac_ess_shed2_brightness = A333DR_annun_brightness_ac_ess_shed_2
    local annun_light_switch_test = A333DR_dc_bus2_has_power

    local wing_anti_ice_switch_on = A333DR_buttons_wing_anti_ice_ctct_on_off == 1
    local wing_anti_ice_left_fail = simDR_wing_heat_left_fail == 6
    local wing_anti_ice_right_fail = simDR_wing_heat_right_fail == 6
    local gear_deploy_ratio = simDR_gear_deploy_ratio
    local sim_time_factor = m.fmod(simDR_flight_time, 0.6)
    local sim_time_factor2 = m.fmod(simDR_flight_time, 0.59)
    local flasher = (sim_time_factor >= 0 and sim_time_factor <= 0.3) and 1 or 0
    local flasher2 = (sim_time_factor2 >= 0 and sim_time_factor2 <= 0.295) and 1 or 0
    local evac_cmd_ctct = A333DR_buttons_evac_cmd_ctct_on_off
    local call_emergency_tog_pos = A333DR_call_emergency_tog_pos
    local gear_on_ground = simDR_gear_on_ground[1] == 1
    local engine_is_burning_fuel = simDR_engine_is_burning_fuel
    local engine1_is_running = engine_is_burning_fuel[0] == 1
    local elec_hyd_blue_pump_actuator = simDR_elec_hydraulic_blue_pump_actuator
	local elec_pump_blue_contactor = A333DR_elec_pump_blue_contactor
    local engine1_hyd_blue_pump_on = simDR_engine_hyd_blue_pump_actuator[0] == 1
    local left_fuel_pump1_button_pos = A333DR_left_pump1_pos
    local right_fuel_pump1_button_pos = A333DR_right_pump1_pos
    local fuel_wing_crossfeed_button_pos = A333DR_fuel_wing_crossfeed_pos
    local trim_fuel_xfr_button_pos = A333DR_fuel_trim_xfr_pos
    local fuel_tank_qty = simDR_fuel_qty


    -- SET ANNUNCIATOR STATUS (0/1)
    local annun_apu_gen_fault_target = annun_light_switch_dim_or_brt and A333DR_apu_fault or annun_light_switch_test

    local wing_heat_valve_pos_left_target = bool2num[wing_anti_ice_switch_on and (not wing_anti_ice_left_fail)]
    local wing_heat_valve_pos_right_target = bool2num[wing_anti_ice_switch_on and (not wing_anti_ice_right_fail)]
    wing_heat_valve_pos_left = animate(wing_heat_valve_pos_left, wing_heat_valve_pos_left_target, 6)
    wing_heat_valve_pos_right = animate(wing_heat_valve_pos_right, wing_heat_valve_pos_right_target, 6)
    local wing_anti_ice_fault_annun_target = annun_light_switch_dim_or_brt and
        bool2num[((wing_anti_ice_switch_on and (wing_heat_valve_pos_left < 1.0 or wing_heat_valve_pos_right < 1.0 or simDR_wing_heat_left == 0 or simDR_wing_heat_right == 0))
        or
        ((not wing_anti_ice_switch_on) and (wing_heat_valve_pos_left > 0.0 or wing_heat_valve_pos_right < 0.0 or simDR_wing_heat_left == 1 or simDR_wing_heat_right == 1))
        or
        (wing_anti_ice_left_fail or wing_anti_ice_right_fail))]
        or annun_light_switch_test

    local wing_anti_ice_on_annun_target = annun_light_switch_dim_or_brt and bool2num[wing_anti_ice_switch_on] or annun_light_switch_test
    local turb_damper_off_annun_target = annun_light_switch_dim_or_brt and ((A333DR_turb_damp_pos == 0 and 1) or 0) or annun_light_switch_test
    local sec1_off_annun_target = annun_light_switch_dim_or_brt and ((A333DR_sec1_pos == 0 and 1) or 0) or annun_light_switch_test
    local cargo_fwd_isol_valves_off_annun_target = annun_light_switch_dim_or_brt and ((A333DR_cargo_cond_fwd_isol_valve_pos == 0 and 1) or 0) or annun_light_switch_test
    local cargo_bulk_isol_valves_off_annun_target = annun_light_switch_dim_or_brt and ((A333DR_cargo_cond_bulk_isol_valve_pos == 0 and 1) or 0) or annun_light_switch_test
    local cargo_bulk_hot_air_annun_target = annun_light_switch_dim_or_brt and ((A333DR_cargo_cond_hot_air_pos == 0 and 1) or 0) or annun_light_switch_test
    local landing_gear_nose_green = annun_light_switch_dim_or_brt and ((gear_deploy_ratio[0] == 1 and 1) or 0) or annun_light_switch_test
    local landing_gear_left_green = annun_light_switch_dim_or_brt and ((gear_deploy_ratio[1] == 1 and 1) or 0) or annun_light_switch_test
    local landing_gear_right_green = annun_light_switch_dim_or_brt and ((gear_deploy_ratio[2] == 1 and 1) or 0) or annun_light_switch_test
    local landing_gear_nose_unlk = annun_light_switch_dim_or_brt and ((gear_deploy_ratio[0] ~= 0 and gear_deploy_ratio[0] ~= 1 and 1) or 0) or annun_light_switch_test
    local landing_gear_left_unlk = annun_light_switch_dim_or_brt and ((gear_deploy_ratio[1] ~= 0 and gear_deploy_ratio[1] ~= 1 and 1) or 0) or annun_light_switch_test
    local landing_gear_right_unlk = annun_light_switch_dim_or_brt and ((gear_deploy_ratio[2] ~= 0 and gear_deploy_ratio[2] ~= 1 and 1) or 0) or annun_light_switch_test
    local oxygen_crew_supply_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_crew_supply_status == 0] or annun_light_switch_test
    local oxygen_tmr_reset_on_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_pax_oxy_reset_pos >= 1] or annun_light_switch_test
    local oxygen_tmr_reset_fault_annun_target = annun_light_switch_dim_or_brt and A333_oxy_timer_reset_fault() or annun_light_switch_test
    local gpws_terr_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_gpws_terr_status == 0] or annun_light_switch_test
    local evac_command_on_annun_target = annun_light_switch_dim_or_brt and evac_cmd_ctct or annun_light_switch_test
    local evac_command_evac_annun_target = annun_light_switch_dim_or_brt and (((evac_cmd_ctct == 1) and flasher) or 0) or annun_light_switch_test
    local calls_emer_call_annun_target = annun_light_switch_dim_or_brt and (((call_emergency_tog_pos >= 1) and flasher2) or 0) or annun_light_switch_test
    local calls_emer_on_annun_target = annun_light_switch_dim_or_brt and (((call_emergency_tog_pos >= 1) and flasher2) or 0) or annun_light_switch_test
    local ditching_on_annun_target = annun_light_switch_dim_or_brt and A333DR_ditching_status or annun_light_switch_test
    local hyd_elec_blue_pump_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[simDR_elec_hyd_blue_fault == 6] or annun_light_switch_test
    local hyd_elec_blue_pump_off_annun_target = annun_light_switch_dim_or_brt and bool2num[elec_pump_blue_contactor == 0] or annun_light_switch_test
    local hyd_elec_blue_pump_on_annun_target = annun_light_switch_dim_or_brt and bool2num[elec_hyd_blue_pump_actuator == 1] or annun_light_switch_test

    local hyd_eng1_blue_pump_fault_annun_target = annun_light_switch_dim_or_brt
        and bool2num[((simDR_engine1_hyd_pump_fault == 6) or (engine1_hyd_blue_pump_on and ((engine1_is_running == 1 or (not gear_on_ground)) and simDR_blue_pressure < 2000)))]
        or annun_light_switch_test

    local hyd_eng1_blue_pump_off_annun_target = annun_light_switch_dim_or_brt and bool2num[not engine1_hyd_blue_pump_on] or annun_light_switch_test

    local elec_gen1_off_reset_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_buttons_gen1_ctct_on_off == 0] or annun_light_switch_test
    local elec_gen2_off_reset_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_buttons_gen2_ctct_on_off == 0] or annun_light_switch_test
    local elec_idg1_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_IDG1_status == 0] or annun_light_switch_test
    local elec_idg2_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_IDG2_status == 0] or annun_light_switch_test
    local elec_galley_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_buttons_galley_pos == 0] or annun_light_switch_test
    local autopilot_a_thr_mode = annun_light_switch_dim_or_brt and simDR_autothrottle_on or annun_light_switch_test
    local autopilot_alt_mode = annun_light_switch_dim_or_brt and bool2num[simDR_altitude_hold_status == 2 and simDR_alts_captured == 0 and simDR_altv_captured] or annun_light_switch_test
    local autopilot_ap1_mode = annun_light_switch_dim_or_brt and simDR_autopilot1_on or annun_light_switch_test
    local autopilot_ap2_mode = annun_light_switch_dim_or_brt and simDR_autopilot2_on or annun_light_switch_test
    local autopilot_appr_mode = annun_light_switch_dim_or_brt and bool2num[simDR_approach_status >= 1] or annun_light_switch_test
    local autopilot_loc_mode = annun_light_switch_dim_or_brt and bool2num[simDR_loc_status >= 1] or annun_light_switch_test
    local fuel_pump_L1_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[left_fuel_pump1_button_pos >= 1 and fuel_tank_qty[0] < 150] or annun_light_switch_test
    local fuel_pump_L1_off_annun_target = annun_light_switch_dim_or_brt and bool2num[left_fuel_pump1_button_pos == 0] or annun_light_switch_test
    local fuel_pump_R1_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[right_fuel_pump1_button_pos >= 1 and fuel_tank_qty[2] < 150] or annun_light_switch_test
    local fuel_pump_R1_off_annun_target = annun_light_switch_dim_or_brt and bool2num[right_fuel_pump1_button_pos == 0] or annun_light_switch_test
    local fuel_wing_x_feed_on_annun_target = annun_light_switch_dim_or_brt and bool2num[fuel_wing_crossfeed_button_pos >= 1] or annun_light_switch_test

    fuel_crossfeed_valve_pos = animate(fuel_crossfeed_valve_pos, fuel_wing_x_feed_on_annun_target, 3)
    A333DR_fuel_crossfeed_valve_pos = fuel_crossfeed_valve_pos

    local fuel_wing_x_feed_open_annun_target = annun_light_switch_dim_or_brt and bool2num[fuel_crossfeed_valve_pos == 1] or annun_light_switch_test
    local fuel_t_tank_mode_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[trim_fuel_xfr_button_pos == 1 and fuel_tank_qty[5] < 100] or annun_light_switch_test
    local fuel_t_tank_mode_fwd_annun_target = annun_light_switch_dim_or_brt and bool2num[trim_fuel_xfr_button_pos == 1] or annun_light_switch_test
    local true_north_annun_target = annun_light_switch_dim_or_brt and simDR_north_ref or annun_light_switch_test
    local cargo_bulk_hot_air_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cargo_fwd_isol_vlv_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cargo_bulk_isol_vlv_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local elec_galley_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local annun_air_ovht_cnd_fans_reset_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cockpit_door_ctl_strike_top_backup_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cockpit_door_ctl_strike_mid_backup_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cockpit_door_ctl_strike_btm_backup_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cockpit_door_ctl_channel1_backup_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cockpit_door_ctl_channel2_backup_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cockpit_door_sw_ovrd_arm_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cockpit_door_sw_ovrd_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local pax_system_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_pax_sys_pos == 0] or annun_light_switch_test
    local pax_satcom_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_pax_satcom_pos == 0] or annun_light_switch_test


    -- SET ANNUNCIATOR FADE IN/OUT
    annun_apu_gen_fault = animate(annun_apu_gen_fault, annun_apu_gen_fault_target, 13)
    annun_wing_anti_ice_fault = animate(annun_wing_anti_ice_fault, wing_anti_ice_fault_annun_target, 13)
    annun_wing_anti_ice_on = animate(annun_wing_anti_ice_on, wing_anti_ice_on_annun_target, 13)
    annun_turb_damper_off = animate(annun_turb_damper_off, turb_damper_off_annun_target, 13)
    annun_sec1_off = animate(annun_sec1_off, sec1_off_annun_target, 13)
    annun_cargo_fwd_isol_valves_off = animate(annun_cargo_fwd_isol_valves_off, cargo_fwd_isol_valves_off_annun_target, 13)
    annun_cargo_bulk_isol_valves_off = animate(annun_cargo_bulk_isol_valves_off, cargo_bulk_isol_valves_off_annun_target, 13)
    annun_cargo_bulk_hot_air = animate(annun_cargo_bulk_hot_air, cargo_bulk_hot_air_annun_target, 13)
    annun_landing_gear_nose_green = animate(annun_landing_gear_nose_green, landing_gear_nose_green, 13)
    annun_landing_gear_left_green = animate(annun_landing_gear_left_green, landing_gear_left_green, 13)
    annun_landing_gear_right_green = animate(annun_landing_gear_right_green, landing_gear_right_green, 13)
    annun_landing_gear_nose_unlk = animate(annun_landing_gear_nose_unlk, landing_gear_nose_unlk, 13)
    annun_landing_gear_left_unlk = animate(annun_landing_gear_left_unlk, landing_gear_left_unlk, 13)
    annun_landing_gear_right_unlk = animate(annun_landing_gear_right_unlk, landing_gear_right_unlk, 13)
    annun_oxygen_crew_supply_off = animate(annun_oxygen_crew_supply_off, oxygen_crew_supply_off_annun_target, 13)
    annun_oxygen_tmr_reset_on = animate(annun_oxygen_tmr_reset_on, oxygen_tmr_reset_on_annun_target, 13)
    annun_oxygen_tmr_reset_fault = animate(annun_oxygen_tmr_reset_fault, oxygen_tmr_reset_fault_annun_target, 13)
    annun_gpws_terr_off = animate(annun_gpws_terr_off, gpws_terr_off_annun_target, 13)
    annun_evac_command_on = animate(annun_evac_command_on, evac_command_on_annun_target, 13)
    annun_evac_command_evac = animate(annun_evac_command_evac, evac_command_evac_annun_target, 13)
    annun_calls_emer_call = animate(annun_calls_emer_call, calls_emer_call_annun_target, 13)
    annun_calls_emer_on = animate(annun_calls_emer_on, calls_emer_on_annun_target, 13)
    annun_ditching_on = animate(annun_ditching_on, ditching_on_annun_target, 13)
    annun_hyd_elec_blue_pump_fault = animate(annun_hyd_elec_blue_pump_fault, hyd_elec_blue_pump_fault_annun_target, 13)
    annun_hyd_elec_blue_pump_off = animate(annun_hyd_elec_blue_pump_off, hyd_elec_blue_pump_off_annun_target, 13)
    annun_hyd_elec_blue_pump_on = animate(annun_hyd_elec_blue_pump_on, hyd_elec_blue_pump_on_annun_target, 13)
    annun_hyd_eng1_blue_pump_fault = animate(annun_hyd_eng1_blue_pump_fault, hyd_eng1_blue_pump_fault_annun_target, 13)
    annun_hyd_eng1_blue_pump_off = animate(annun_hyd_eng1_blue_pump_off, hyd_eng1_blue_pump_off_annun_target, 13)
    annun_elec_gen1_off_reset = animate(annun_elec_gen1_off_reset, elec_gen1_off_reset_annun_target, 13)
    annun_elec_gen2_off_reset = animate(annun_elec_gen2_off_reset, elec_gen2_off_reset_annun_target, 13)
    annun_elec_idg1_off = animate(annun_elec_idg1_off, elec_idg1_off_annun_target, 13)
    annun_elec_idg2_off = animate(annun_elec_idg2_off, elec_idg2_off_annun_target, 13)
    annun_elec_galley_off = animate(annun_elec_galley_off, elec_galley_off_annun_target, 13)
    annun_autopilot_a_thr_mode = animate(annun_autopilot_a_thr_mode, autopilot_a_thr_mode, 13)
    annun_autopilot_alt_mode = animate(annun_autopilot_alt_mode, autopilot_alt_mode, 13)
    annun_autopilot_ap1_mode = animate(annun_autopilot_ap1_mode, autopilot_ap1_mode, 13)
    annun_autopilot_ap2_mode = animate(annun_autopilot_ap2_mode, autopilot_ap2_mode, 13)
    annun_autopilot_appr_mode = animate(annun_autopilot_appr_mode, autopilot_appr_mode, 13)
    annun_autopilot_loc_mode = animate(annun_autopilot_loc_mode, autopilot_loc_mode, 13)
    annun_fuel_pump_L1_fault = animate(annun_fuel_pump_L1_fault, fuel_pump_L1_fault_annun_target, 13)
    annun_fuel_pump_L1_off = animate(annun_fuel_pump_L1_off, fuel_pump_L1_off_annun_target, 13)
    annun_fuel_pump_R1_fault = animate(annun_fuel_pump_R1_fault, fuel_pump_R1_fault_annun_target, 13)
    annun_fuel_pump_R1_off = animate(annun_fuel_pump_R1_off, fuel_pump_R1_off_annun_target, 13)
    annun_fuel_wing_x_feed_on = animate(annun_fuel_wing_x_feed_on, fuel_wing_x_feed_on_annun_target, 13)
    annun_fuel_wing_x_feed_open = animate(annun_fuel_wing_x_feed_open, fuel_wing_x_feed_open_annun_target, 13)
    annun_fuel_t_tank_mode_fault = animate(annun_fuel_t_tank_mode_fault, fuel_t_tank_mode_fault_annun_target, 13)
    annun_fuel_t_tank_mode_fwd = animate(annun_fuel_t_tank_mode_fwd, fuel_t_tank_mode_fwd_annun_target, 13)
    annun_true_north = animate(annun_true_north, true_north_annun_target, 13)
    annun_cargo_bulk_hot_air_fault = animate(annun_cargo_bulk_hot_air_fault, cargo_bulk_hot_air_fault_annun_target, 13)
    annun_cargo_fwd_isol_vlv_fault = animate(annun_cargo_fwd_isol_vlv_fault, cargo_fwd_isol_vlv_fault_annun_target, 13)
    annun_cargo_bulk_isol_vlv_fault = animate(annun_cargo_bulk_isol_vlv_fault, cargo_bulk_isol_vlv_fault_annun_target, 13)
    annun_elec_galley_fault = animate(annun_elec_galley_fault, elec_galley_fault_annun_target, 13)
    annun_air_ovht_cnd_fans_reset_fault = animate(annun_air_ovht_cnd_fans_reset_fault, annun_air_ovht_cnd_fans_reset_fault_annun_target, 13)
    lcl.annun_cockpit_door_ctl_strike_top_backup = animate(lcl.annun_cockpit_door_ctl_strike_top_backup, cockpit_door_ctl_strike_top_backup_annun_target, 13)
    lcl.annun_cockpit_door_ctl_strike_mid_backup = animate(lcl.annun_cockpit_door_ctl_strike_mid_backup, cockpit_door_ctl_strike_mid_backup_annun_target, 13)
    lcl.annun_cockpit_door_ctl_strike_btm_backup = animate(lcl.annun_cockpit_door_ctl_strike_btm_backup, cockpit_door_ctl_strike_btm_backup_annun_target, 13)
    lcl.annun_cockpit_door_ctl_channel1_backup = animate(lcl.annun_cockpit_door_ctl_channel1_backup, cockpit_door_ctl_channel1_backup_annun_target, 13)
    lcl.annun_cockpit_door_ctl_channel2_backup = animate(lcl.annun_cockpit_door_ctl_channel2_backup, cockpit_door_ctl_channel2_backup_annun_target, 13)
    lcl.annun_cockpit_door_sw_ovrd_arm = animate(lcl.annun_cockpit_door_sw_ovrd_arm, cockpit_door_sw_ovrd_arm_annun_target, 13)
    lcl.annun_cockpit_door_sw_ovrd_fault = animate(lcl.annun_cockpit_door_sw_ovrd_fault, cockpit_door_sw_ovrd_fault_annun_target, 13)
    lcl.annun_pax_satcom_off = animate(lcl.annun_pax_satcom_off, pax_satcom_off_annun_target, 13)
    lcl.annun_pax_system_off = animate(lcl.annun_pax_system_off, pax_system_off_annun_target, 13)


    -- SET ANNUNCIATOR BRIGHTNESS AND ASSIGN TO DATAREF
    A333DR_annun_elec_apu_gen_fault = annun_apu_gen_fault * annun_ac_ess_shed_brightness
    A333DR_annun_wing_anti_ice_fault = annun_wing_anti_ice_fault * annun_ac_ess_shed_brightness
    A333DR_annun_wing_anti_ice_on = annun_wing_anti_ice_on * annun_ac_ess_shed_brightness
    A333DR_annun_flt_ctl_turb_damp_off = annun_turb_damper_off * annun_ac_ess_shed_brightness
    A333DR_annun_flt_ctl_sec1_off = annun_sec1_off * annun_ac_ess_shed_brightness
    A333DR_annun_cargo_fwd_isol_valves_off = annun_cargo_fwd_isol_valves_off * annun_ac_ess_shed_brightness
    A333DR_annun_cargo_bulk_isol_valves_off = annun_cargo_bulk_isol_valves_off * annun_ac_ess_shed_brightness
    A333DR_annun_cargo_bulk_hot_air = annun_cargo_bulk_hot_air * annun_ac_ess_shed_brightness
    A333DR_annun_cargo_bulk_hot_air_fault = annun_cargo_bulk_hot_air_fault * annun_ac_ess_shed_brightness
    A333DR_annun_landing_gear_nose_green = annun_landing_gear_nose_green * annun_ac_ess_shed_brightness
    A333DR_annun_landing_gear_left_green = annun_landing_gear_left_green * annun_ac_ess_shed_brightness
    A333DR_annun_landing_gear_right_green = annun_landing_gear_right_green * annun_ac_ess_shed_brightness
    A333DR_annun_landing_gear_nose_unlk = annun_landing_gear_nose_unlk * annun_ac_ess_shed_brightness
    A333DR_annun_landing_gear_left_unlk = annun_landing_gear_left_unlk * annun_ac_ess_shed_brightness
    A333DR_annun_landing_gear_right_unlk = annun_landing_gear_right_unlk * annun_ac_ess_shed_brightness
    A333DR_annun_oxygen_crew_supply_off = annun_oxygen_crew_supply_off * annun_ac_ess_shed_brightness
    A333DR_annun_oxygen_tmr_reset_on = annun_oxygen_tmr_reset_on * annun_ac_ess_shed_brightness
    A333DR_annun_oxygen_tmr_reset_fault = annun_oxygen_tmr_reset_fault * annun_ac_ess_shed_brightness
    A333DR_annun_gpws_terr_off = annun_gpws_terr_off * annun_ac_ess_shed_brightness
    A333DR_annun_evac_command_on = annun_evac_command_on * annun_ac_ess_shed_brightness
    A333DR_annun_evac_command_evac = annun_evac_command_evac * annun_ac_ess_shed_brightness
    A333DR_annun_calls_emer_call = annun_calls_emer_call * annun_ac_ess_shed_brightness
    A333DR_annun_calls_emer_on = annun_calls_emer_on * annun_ac_ess_shed_brightness
    A333DR_annun_ditching_on = annun_ditching_on * annun_ac_ess_shed_brightness
    A333DR_annun_hyd_elec_blue_pump_fault = annun_hyd_elec_blue_pump_fault * annun_ac_ess_shed_brightness
    A333DR_annun_hyd_elec_blue_pump_off = annun_hyd_elec_blue_pump_off * annun_ac_ess_shed_brightness
    A333DR_annun_hyd_elec_blue_pump_on = annun_hyd_elec_blue_pump_on * annun_ac_ess_shed_brightness
    A333DR_annun_hyd_eng1_blue_pump_fault = annun_hyd_eng1_blue_pump_fault * annun_ac_ess_shed_brightness
    A333DR_annun_hyd_eng1_blue_pump_off = annun_hyd_eng1_blue_pump_off * annun_ac_ess_shed_brightness
    A333DR_annun_elec_gen1_off_reset = annun_elec_gen1_off_reset * annun_ac_ess_shed_brightness
    A333DR_annun_elec_gen2_off_reset = annun_elec_gen2_off_reset * annun_ac_ess_shed_brightness
    A333DR_annun_elec_idg1_off = annun_elec_idg1_off * annun_ac_ess_shed_brightness
    A333DR_annun_elec_idg2_off = annun_elec_idg2_off * annun_ac_ess_shed_brightness
    A333DR_annun_elec_galley_off = annun_elec_galley_off * annun_ac_ess_shed_brightness
    A333DR_annun_autopilot_a_thr_mode = annun_autopilot_a_thr_mode * annun_ac_ess_shed_brightness
    A333DR_annun_autopilot_alt_mode = annun_autopilot_alt_mode * annun_ac_ess_shed_brightness
    A333DR_annun_autopilot_ap1_mode = annun_autopilot_ap1_mode * annun_ac_ess_shed_brightness
    A333DR_annun_autopilot_ap2_mode = annun_autopilot_ap2_mode * annun_ac_ess_shed_brightness
    A333DR_annun_autopilot_appr_mode = annun_autopilot_appr_mode * annun_ac_ess_shed_brightness
    A333DR_annun_autopilot_loc_mode = annun_autopilot_loc_mode * annun_ac_ess_shed_brightness
    A333DR_annun_fuel_pump_L1_fault = annun_fuel_pump_L1_fault * annun_ac_ess_shed_brightness
    A333DR_annun_fuel_pump_L1_off = annun_fuel_pump_L1_off * annun_ac_ess_shed_brightness
    A333DR_annun_fuel_pump_R1_fault = annun_fuel_pump_R1_fault * annun_ac_ess_shed_brightness
    A333DR_annun_fuel_pump_R1_off = annun_fuel_pump_R1_off * annun_ac_ess_shed_brightness
    A333DR_annun_fuel_wing_x_feed_on = annun_fuel_wing_x_feed_on * annun_ac_ess_shed_brightness
    A333DR_annun_fuel_wing_x_feed_open = annun_fuel_wing_x_feed_open * annun_ac_ess_shed_brightness
    A333DR_annun_fuel_t_tank_mode_fault = annun_fuel_t_tank_mode_fault * annun_ac_ess_shed_brightness
    A333DR_annun_fuel_t_tank_mode_fwd = annun_fuel_t_tank_mode_fwd * annun_ac_ess_shed_brightness
    A333DR_annun_true_north = annun_true_north * annun_ac_ess_shed_brightness
    A333DR_annun_cargo_fwd_isol_vlv_fault = annun_cargo_fwd_isol_vlv_fault  * annun_ac_ess_shed_brightness
    A333DR_annun_cargo_bulk_isol_vlv_fault = annun_cargo_bulk_isol_vlv_fault * annun_ac_ess_shed_brightness
    A333DR_annun_elec_galley_fault = annun_elec_galley_fault * annun_ac_ess_shed_brightness
    A333DR_annun_air_ovht_cnd_fans_reset_fault = annun_air_ovht_cnd_fans_reset_fault * annun_ac_ess_shed_brightness
    A333DR_annun_cockpit_door_ctl_strike_top_backup = lcl.annun_cockpit_door_ctl_strike_top_backup * annun_ac_ess_shed_brightness
    A333DR_annun_cockpit_door_ctl_strike_mid_backup = lcl.annun_cockpit_door_ctl_strike_mid_backup * annun_ac_ess_shed_brightness
    A333DR_annun_cockpit_door_ctl_strike_btm_backup = lcl.annun_cockpit_door_ctl_strike_btm_backup * annun_ac_ess_shed_brightness
    A333DR_annun_cockpit_door_ctl_channel1_backup = lcl.annun_cockpit_door_ctl_channel1_backup * annun_ac_ess_shed_brightness
    A333DR_annun_cockpit_door_ctl_channel2_backup = lcl.annun_cockpit_door_ctl_channel2_backup * annun_ac_ess_shed_brightness
    A333DR_annun_cockpit_door_sw_ovrd_arm = lcl.annun_cockpit_door_sw_ovrd_arm * annun_ac_ess_shed_brightness
    A333DR_annun_cockpit_door_sw_ovrd_fault = lcl.annun_cockpit_door_sw_ovrd_fault * annun_ac_ess_shed_brightness
    A333DR_annun_pax_satcom_off = lcl.annun_pax_satcom_off * annun_ac_ess_shed_brightness
    A333DR_annun_pax_system_off = lcl.annun_pax_system_off * annun_ac_ess_shed_brightness

    -- SET NON-ANNUNCIATOR DATAREFS
    A333DR_wing_heat_valve_pos_left = wing_heat_valve_pos_left
    A333DR_wing_heat_valve_pos_right = wing_heat_valve_pos_right

end




local function A333_fws_hyd_pump_fault()

    A333DR_hyd_elec_blue_pump_fault = annun_hyd_elec_blue_pump_fault
    A333DR_hyd_eng1_blue_pump_fault = annun_hyd_eng1_blue_pump_fault

end



--*************************************************************************************--
--** 				                     PROCESSING             	    			 **--
--*************************************************************************************--

--===| INIT ALL |========================================================================
function A333_annun_ac_ess_shed_init_all()



end




--===| INIT ER |=========================================================================
function A333_annun_ac_ess_shed_init_ER()



end




--===| INIT CD |=========================================================================
function A333_annun_ac_ess_shed_init_CD()



end




--===| DEFERRED INITIALIZATION |=========================================================
function A333_annun_ac_ess_shed_deferred_init()




end



--===| DEFERRED PROCESSING |=============================================================
function A333_annun_ac_ess_shed_deferred_processing()



end




--=== AIRCRAFT LOAD =====================================================================
function A333_annun_ac_ess_shed_aircraft_load()



end



--=== FLIGHT START ======================================================================
function A333_annun_ac_ess_shed_flight_start()

    annun_apu_gen_fault_target = 0

end



--=== BEFORE PHYSICS ====================================================================
function A333_annun_ac_ess_shed_before_physics()



end



--=== AFTER PHYSICS =====================================================================
function A333_annun_ac_ess_shed_after_physics()

    A333_annun_ac_ess_shed_cache_globals()
    A333_annun_ac_ess_shed_processing()
    A333_fws_hyd_pump_fault()

end




--=== FLIGHT CRASH ======================================================================
function A333_annun_ac_ess_shed_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_annun_ac_ess_shed_aircraft_unload()



end




--=== AIRCRAFT UNLOAD ===================================================================
function A333_annun_ac_ess_shed_after_replay()

    A333_annun_ac_ess_shed_cache_globals()
    A333_annun_ac_ess_shed_processing()
    A333_fws_hyd_pump_fault()

end



--*************************************************************************************--
--** 				                 SUB-SCRIPT LOADING            	     			 **--
--*************************************************************************************--



