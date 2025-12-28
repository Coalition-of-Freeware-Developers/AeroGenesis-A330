--[[
*****************************************************************************************
* Program Script Name	:	A333.annun__data.lua
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
local NUM_CAPT_LISTENING_LIGHTS = 16
local NUM_FO_LISTENING_LIGHTS = 16
local NUM_OBS_LISTENING_LIGHTS = 16


--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local lcl_SIM_PERIOD = 0
local m = math





--*************************************************************************************--
--** 				            LOCAL UTILITY FUNCTIONS          			    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
simDR_flight_time = find_dataref("sim/time/total_flight_time_sec")

simDR_inst_brightness_switch_ratio_15 = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[15]")
simDR_inst_brightness_switch_ratio_16 = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[16]")

simDR_inst_brightness_ratio_15 = find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_manual[15]")
simDR_inst_brightness_ratio_16 = find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_manual[16]")

simDR_apu_fire = find_dataref("sim/operation/failures/rel_apu_fire")
simDR_apu_fail = find_dataref("sim/operation/failures/rel_apu")
simDR_apu_running = find_dataref("sim/cockpit2/electrical/APU_running")
simDR_apu_N1 = find_dataref("sim/cockpit2/electrical/APU_N1_percent")

simDR_EFIS_airport_on_capt = find_dataref("sim/cockpit2/EFIS/EFIS_airport_on")
simDR_EFIS_fix_on_capt = find_dataref("sim/cockpit2/EFIS/EFIS_fix_on")
simDR_EFIS_vor_on_capt = find_dataref("sim/cockpit2/EFIS/EFIS_vor_on")
simDR_EFIS_ndb_on_capt = find_dataref("sim/cockpit2/EFIS/EFIS_ndb_on")
simDR_EFIS_CSTR_capt_on = find_dataref("sim/cockpit2/EFIS/EFIS_data_on")
simDR_EFIS_airport_on_fo = find_dataref("sim/cockpit2/EFIS/EFIS_airport_on_copilot")
simDR_EFIS_fix_on_fo = find_dataref("sim/cockpit2/EFIS/EFIS_fix_on_copilot")
simDR_EFIS_vor_on_fo = find_dataref("sim/cockpit2/EFIS/EFIS_vor_on_copilot")
simDR_EFIS_ndb_on_fo = find_dataref("sim/cockpit2/EFIS/EFIS_ndb_on_copilot")
simDR_EFIS_CSTR_fo_on = find_dataref("sim/cockpit2/EFIS/EFIS_data_on_copilot")
simDR_terr_on_nd_capt = find_dataref("sim/cockpit2/EFIS/EFIS_terrain_on")
simDR_terr_on_nd_fo = find_dataref("sim/cockpit2/EFIS/EFIS_terrain_on_copilot")

simDR_engine_thermal_anti_ice = find_dataref("sim/cockpit2/ice/cowling_thermal_anti_ice_per_engine")
simDR_engine1_anti_ice_fail = find_dataref("sim/operation/failures/rel_ice_inlet_heat")
simDR_engine2_anti_ice_fail = find_dataref("sim/operation/failures/rel_ice_inlet_heat2")
simDR_wing_heat_left = find_dataref("sim/cockpit2/ice/ice_surface_hot_bleed_air_left_on")
simDR_wing_heat_right = find_dataref("sim/cockpit2/ice/ice_surface_hot_bleed_air_right_on")
simDR_wing_heat_left_fail = find_dataref("sim/operation/failures/rel_ice_surf_heat")
simDR_wing_heat_right_fail = find_dataref("sim/operation/failures/rel_ice_surf_heat2")
simDR_engine_fire_annun = find_dataref("sim/cockpit2/annunciators/engine_fires")
simDR_engine1_starter_fail = find_dataref("sim/operation/failures/rel_startr0")
simDR_engine2_starter_fail = find_dataref("sim/operation/failures/rel_startr1")
simDR_door_open_ratio = find_dataref("sim/flightmodel2/misc/door_open_ratio")
simDR_auto_brake = find_dataref("sim/cockpit2/switches/auto_brake_level")
simDR_gear_on_ground = find_dataref("sim/flightmodel2/gear/on_ground")
simDR_acceleration = find_dataref("sim/cockpit2/gauges/indicators/airspeed_acceleration_kts_sec_pilot")
simDR_brake_fan = find_dataref("sim/cockpit2/controls/brake_fan_on")
simDR_gear_deploy_ratio = find_dataref("sim/flightmodel2/gear/deploy_ratio")
simDR_master_caution_anunn = find_dataref("sim/cockpit2/annunciators/master_caution")
simDR_master_warning_anunn = find_dataref("sim/cockpit2/annunciators/master_warning")
simDR_gpws_annun = find_dataref("sim/cockpit2/annunciators/GPWS")
--simDR_flight_director_capt = find_dataref("sim/cockpit2/autopilot/flight_director_command_bars_pilot")
simDR_flight_director_capt = find_dataref("laminar/A333/autopilot/capt_FD_bars_bypass") -- TEMPORARY FIX
--simDR_flight_director_fo = find_dataref("sim/cockpit2/autopilot/flight_director_command_bars_copilot")
simDR_flight_director_fo = find_dataref("laminar/A333/autopilot/fo_FD_bars_bypass")
simDR_pax_oxy_fail = find_dataref("sim/operation/failures/rel_pass_o2_on")
simDR_engine_hyd_green_pump_actuator = find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpA")
simDR_engine_hyd_yellow_pump_actuator = find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpB")
simDR_engine_hyd_blue_pump_actuator = find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpC")
simDR_green_pressure = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1")
simDR_yellow_pressure = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_2")
simDR_blue_pressure	= find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_3")
simDR_engine_is_burning_fuel = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel")
simDR_engine1_hyd_pump_fault = find_dataref("sim/operation/failures/rel_hydpmp")
simDR_engine2_hyd_pump_fault = find_dataref("sim/operation/failures/rel_hydpmp2")
simDR_elec_hyd_green_fault = find_dataref("sim/operation/failures/rel_hydpmp_ele")
simDR_elec_hyd_blue_fault = find_dataref("sim/operation/failures/rel_hydpmp_el2")
simDR_elec_hyd_yellow_fault = find_dataref("sim/operation/failures/rel_hydpmp_el3")
simDR_elec_hydraulic_green_pump_actuator = find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump_on")
simDR_elec_hydraulic_blue_pump_actuator = find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump2_on")
simDR_elec_hydraulic_yellow_pump_actuator = find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump3_on")
simDR_bat1_failure = find_dataref("sim/operation/failures/rel_batter0")
simDR_bat2_failure = find_dataref("sim/operation/failures/rel_batter1")
simDR_autothrottle_on = find_dataref("sim/cockpit2/autopilot/autothrottle_arm")
simDR_autopilot1_on = find_dataref("sim/cockpit2/autopilot/servos_on")
simDR_autopilot2_on = find_dataref("sim/cockpit2/autopilot/servos2_on")
simDR_altitude_hold_status = find_dataref("sim/cockpit2/autopilot/altitude_hold_status") -- 1 = armed, 2 = cap
simDR_approach_status = find_dataref("sim/cockpit2/autopilot/approach_status") -- 1 = armed, 2 = captured
simDR_loc_status = find_dataref("sim/cockpit2/autopilot/nav_status") -- 1 = armed, 2 = captured
simDR_engine_bleed_sov_status = find_dataref("sim/cockpit2/bleedair/actuators/engine_bleed_sov")
simDR_engine_starter_running = find_dataref("sim/flightmodel2/engines/starter_is_running")
simDR_engine_bleed1_fail = find_dataref("sim/operation/failures/rel_bleed_air_lft")
simDR_engine_bleed2_fail = find_dataref("sim/operation/failures/rel_bleed_air_rgt")
simDR_apu_bleed_fail = find_dataref("sim/operation/failures/rel_APU_press")
simDR_bleed_air_avail_right = find_dataref("sim/cockpit2/bleedair/indicators/bleed_available_right")
simDR_bleed_air_avail_left = find_dataref("sim/cockpit2/bleedair/indicators/bleed_available_left")
simDR_altitude = find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
simDR_belts_on = find_dataref("sim/cockpit2/switches/fasten_seat_belts")
simDR_fuel_qty = find_dataref("sim/cockpit2/fuel/fuel_quantity")
simDR_smoke_in_cockpit = find_dataref("sim/operation/failures/rel_smoke_cpit")
simDR_north_ref	= find_dataref("sim/cockpit2/EFIS/true_north") -- 0 = mag, 1 = tru
simDR_alts_captured	= find_dataref("sim/cockpit2/autopilot/alts_captured")
simDR_altv_captured	= find_dataref("sim/cockpit2/autopilot/altv_captured")
simDR_transponder_failure = find_dataref("sim/operation/failures/rel_xpndr")


--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--
A333DR_ann_light_switch_pos = find_dataref("laminar/a333/switches/ann_light_pos")

A333DR_extA_ground_service_bus_has_power = find_dataref("laminar/A333/elec/extA_ground_service_bus_has_power")
A333DR_ac_bus1_has_power = find_dataref("laminar/A333/elec/ac_bus1_has_power")
A333DR_ac_bus2_has_power = find_dataref("laminar/A333/elec/ac_bus2_has_power")
A333DR_ac_ess_bus_has_power = find_dataref("laminar/A333/elec/ac_ess_bus_has_power")
A333DR_ac_ess_shed_bus_has_power = find_dataref("laminar/A333/elec/ac_ess_shed_bus_has_power")
A333DR_ac_ess_grnd_bus_has_power = find_dataref("laminar/A333/elec/ac_ess_grnd_bus_has_power")
A333DR_ac_land_rcvry_bus_has_power = find_dataref("laminar/A333/elec/ac_land_rcvry_bus_has_power")
A333DR_dc_bus2_has_power = find_dataref("laminar/A333/elec/dc_bus2_has_power")
A333DR_dc_bat_bus_has_power = find_dataref("laminar/A333/elec/dc_bat_bus_has_power")
A333DR_dc_apu_bat_hot_bus_has_power = find_dataref("laminar/A333/elec/dc_apu_bat_hot_bus_has_power")

--A333DR_toilet_occupied = create_dataref("laminar/A333/toilet/occupied", "number")
--A333DR_toilet_period = create_dataref("laminar/A333/toilet/period", "number")
--A333DR_toilet_waitbetween = create_dataref("laminar/A333/toilet/wait_between", "number")
--A333DR_toilet_random_period = create_dataref("laminar/A333/toilet/period_random", "number")
--A333DR_toilet_random_wait = create_dataref("laminar/A333/toilet/wait_between_random", "number")

A333DR_apu_fire_test = find_dataref("laminar/A333/fire/apu_test_on")
A333DR_engine_fire_test = find_dataref("laminar/A333/fire/engine_test_on")
A333DR_cargo_fire_test_timer = find_dataref("laminar/A333/fire/timer/cargo_test")
A333DR_hyd_elec_blue_pump_fault = find_dataref("laminar/A333/hyd/elec_blue_pump_fault","number")
A333DR_hyd_elec_green_pump_fault = find_dataref("laminar/A333/hyd/elec_green_pump_fault","number")
A333DR_hyd_elec_yellow_pump_fault = find_dataref("laminar/A333/hyd/elec_yellow_pump_fault","number")
A333DR_hyd_eng1_blue_pump_fault = find_dataref("laminar/A333/hyd/eng1_blue_pump_fault","number")
A333DR_hyd_eng1_green_pump_fault = find_dataref("laminar/A333/hyd/eng1_green_pump_fault","number")
A333DR_hyd_eng2_green_pump_fault = find_dataref("laminar/A333/hyd/eng2_green_pump_fault","number")
A333DR_hyd_eng2_yellow_pump_fault = find_dataref("laminar/A333/hyd/eng2_yellow_pump_fault","number")
A333DR_buttons_apu_gen_ctct_on_off = find_dataref("laminar/A333/buttons/gen_apu_state")
A333DR_emer_exit_lt_switch_pos = find_dataref("laminar/a333/switches/emer_exit_lt_pos")
A333DR_buttons_APU_master = find_dataref("laminar/A333/buttons/APU_master")
A333DR_apu_bat_line_contactor = find_dataref("laminar/A333/elec/apu_bat_line_cntor")
A333DR_apu_fault = find_dataref("laminar/A333/elec/apu_fault")
A333DR_buttons_wing_anti_ice_ctct_on_off = find_dataref("laminar/A333/buttons/wing_anti_ice_ctct_on_off")
A333DR_cockpit_door_lock_switch_pos = find_dataref("laminar/A333/switches/cockpit_door_lock_pos")
--A333DR_door_locked_status = find_dataref("laminar/A333/status/cockpit_door_locked")
A333DR_cockpit_door_lock_mode = find_dataref("laminar/A333/status/cockpit_door_lock_mode", "number")
A333DR_cockpit_door_on_flash = find_dataref("laminar/A333/status/cockpit_door_on_flash", "number")
A333DR_elt_status = find_dataref("laminar/A333/lights/elt")
A333DR_cabin_fan_pos = find_dataref("laminar/A333/buttons/cabin_fan_pos")
A333DR_ventilation_extract_ovrd_pos	= find_dataref("laminar/A333/buttons/ventilation_extract_ovrd_pos")
A333DR_adirs_adr1_mode = find_dataref("laminar/A333/adirs/adr1_status")
A333DR_adirs_adr2_mode = find_dataref("laminar/A333/adirs/adr2_status")
A333DR_adirs_adr3_mode = find_dataref("laminar/A333/adirs/adr3_status")
A333DR_adirs_ir1_mode = find_dataref("laminar/A333/adirs/ir1_status")
A333DR_adirs_ir2_mode = find_dataref("laminar/A333/adirs/ir2_status")
A333DR_adirs_ir3_mode = find_dataref("laminar/A333/adirs/ir3_status")
A333DR_adirs_on_bat_status = find_dataref("laminar/A333/adirs/on_bat_status")
A333DR_wheel_brake_warn = find_dataref("laminar/A333/ecam/wheel/brake_temp_exceed")
A333DR_ecp_sys_page_pushbutton_annun = find_dataref("laminar/A333/ecp/annun/sys_page_pushbutton")
A333DR_ecp_clr_pushbutton_annun = find_dataref("laminar/A333/ecp/annun/clr_pushbutton")
A333DR_ecp_sts_pushbutton_annun = find_dataref("laminar/A333/ecp/annun/sts_pushbutton")
A333DR_gpws_mode5 = find_dataref('laminar/A333/gpws/mode5')
A333DR_capt_ls_bars_status = find_dataref("laminar/A333/status/capt_ls_bars")
A333DR_fo_ls_bars_status = find_dataref("laminar/A333/status/fo_ls_bars")
A333DR_pax_oxy_reset_pos = find_dataref("laminar/A333/buttons/oxy/pax_oxy_maint_reset_pos")
A333DR_gpws_sys_status = find_dataref("laminar/A333/buttons/gpws/system_status")
A333DR_gpws_GS_status = find_dataref("laminar/A333/buttons/gpws/glideslope_status")
A333DR_gpws_flap_status = find_dataref("laminar/A333/buttons/gpws/flap_status")
A333DR_gpws_terr_status = find_dataref("laminar/A333/buttons/gpws/terrain_status")
A333DR_gpws_sys_state = find_dataref("laminar/A333/gpws/system_state", "number") -- 0 = off, 1 = powered/no valid GPS, 2 = ready
A333DR_gpws_terr_state = find_dataref("laminar/A333/gpws/terr_state", "number") -- 0 = off, 1 = powered/no valid GPS, 2 = ready
A333DR_buttons_land_rcvry_ctct_open_closed = find_dataref("laminar/A333/buttons/land_rcvry_ctct_on_off")
A333DR_flight_recorder_mode_on = find_dataref("laminar/A333/buttons/rcdr/active_mode")
A333DR_evac_command_pos = find_dataref("laminar/A333/buttons/evac_command_pos")
A333DR_buttons_evac_cmd_ctct_on_off = find_dataref("laminar/A333/buttons/evac_cmd_ctct_on_off")
A333DR_call_emergency_tog_pos = find_dataref("laminar/A333/buttons/call/emergency_pos")
A333DR_ditching_status = find_dataref("laminar/A333/ditching_status")
A333DR_elec_hyd_pump_green_tog_pos = find_dataref("laminar/A330/buttons/hyd/elec_green_tog_pos")
A333DR_elec_hyd_pump_blue_tog_pos = find_dataref("laminar/A330/buttons/hyd/elec_blue_tog_pos")
A333DR_elec_hyd_pump_yellow_tog_pos	= find_dataref("laminar/A330/buttons/hyd/elec_yellow_tog_pos")
A333DR_buttons_battery1_ctct_on_off = find_dataref("laminar/A333/buttons/batt1_ctct_on_off")
A333DR_buttons_battery2_ctct_on_off = find_dataref("laminar/A333/buttons/batt2_ctct_on_off")
A333DR_extA_line_contactor = find_dataref("laminar/A333/elec/extA_line_cntor")
A333DR_extB_line_contactor = find_dataref("laminar/A333/elec/extB_line_cntor")
A333DR_buttons_extB_ctct_on_off = find_dataref("laminar/A333/buttons/ext_power_B_ctct_on_off")
A333DR_buttons_ACESS_FEED_pos = find_dataref("laminar/A333/buttons/AC_ESS_FEED_pos")
A333DR_buttons_bus_tie_ctct_on_off = find_dataref("laminar/A333/buttons/bus_tie_ctct_state")
A333DR_buttons_gen1_ctct_on_off = find_dataref("laminar/A333/buttons/gen1_ctct_on_off")
A333DR_buttons_gen2_ctct_on_off = find_dataref("laminar/A333/buttons/gen2_ctct_on_off")
A333DR_IDG1_status = find_dataref("laminar/A333/status/elec/IDG1")
A333DR_IDG2_status = find_dataref("laminar/A333/status/elec/IDG2")
A333DR_fws_eng_gen1_fault = find_dataref("laminar/A333/fws/eng_gen1_fault")
A333DR_fws_eng_gen2_fault = find_dataref("laminar/A333/fws/eng_gen2_fault")
A333DR_buttons_galley_pos = find_dataref("laminar/A333/buttons/galley_pos")
A333DR_status_GPU_avail = find_dataref("laminar/A333/status/GPU_avail")
A333DR_status_GPU2_avail = find_dataref("laminar/A333/status/GPU2_avail")
A333DR_buttons_commercial_pos = find_dataref("laminar/A333/buttons/commercial_pos")
A333DR_buttons_apu_bat_ctct_on_off = find_dataref("laminar/A333/buttons/apu_battery_ctct_on_off")
A333DR_apu_bleed_switch_ctct_on_off = find_dataref("laminar/A333/switch_memory/apu_bleed_on_off")
A333DR_eng1_bleed_switch_ctct_on_off = find_dataref("laminar/A333/switch_memory/eng1_bleed_on_off")
A333DR_switches_hot_air1_pos = find_dataref("laminar/A333/buttons/hot_air1_pos")
A333DR_switches_hot_air2_pos = find_dataref("laminar/A333/buttons/hot_air2_pos")
A333DR_eng2_bleed_switch_ctct_on_off = find_dataref("laminar/A333/switch_memory/eng2_bleed_on_off")
A333DR_pack1_switch_ctct_on_off	= find_dataref("laminar/A333/switch_memory/pack1_on_off", "number")
A333DR_pack2_switch_ctct_on_off = find_dataref("laminar/A333/switch_memory/pack2_on_off", "number")
A333DR_switches_ram_air_pos	= find_dataref("laminar/A333/buttons/ram_air_pos")
A333DR_center_right_pump_pos = find_dataref("laminar/A333/fuel/buttons/center_right_pump_pos")
A333DR_ECAM_fuel_center_xfer_any = find_dataref("laminar/A333/ecam/fuel/status_center_xfer")
A333DR_right_standby_pump_pos = find_dataref("laminar/A333/fuel/buttons/right_stby_pump_pos")
A333DR_left_standby_pump_pos = find_dataref("laminar/A333/fuel/buttons/left_stby_pump_pos")
A333DR_fuel_wing_crossfeed_pos = find_dataref("laminar/A333/fuel/buttons/wing_x_feed_pos")
A333DR_center_left_pump_pos = find_dataref("laminar/A333/fuel/buttons/center_left_pump_pos")
A333DR_fuel_outer_tank_xfr_pos = find_dataref("laminar/A333/fuel/buttons/outer_tank_xfr_pos")
A333DR_left_pump1_pos = find_dataref("laminar/A333/fuel/buttons/left1_pump_pos")
A333DR_left_pump2_pos = find_dataref("laminar/A333/fuel/buttons/left2_pump_pos")
A333DR_right_pump1_pos = find_dataref("laminar/A333/fuel/buttons/right1_pump_pos")
A333DR_right_pump2_pos = find_dataref("laminar/A333/fuel/buttons/right2_pump_pos")
A333DR_fuel_trim_xfr_pos = find_dataref("laminar/A333/fuel/buttons/trim_xfr_pos")
A333DR_fuel_center_xfr_pos = find_dataref("laminar/A333/fuel/buttons/center_xfr_pos")
A333DR_cargo_fire_test_pos = find_dataref("laminar/A333/fire/buttons/cargo_test_pos")
A333DR_eng1_fire_handle_pos = find_dataref("laminar/A333/fire/switches/eng1_handle")
A333DR_eng2_fire_handle_pos = find_dataref("laminar/A333/fire/switches/eng2_handle")
A333DR_apu_fire_handle_pos = find_dataref("laminar/A333/fire/switches/apu_handle")
A333DR_eng1_agent1_psi = find_dataref("laminar/A333/fire/status/eng1_agent1_psi")
A333DR_eng1_agent2_psi = find_dataref("laminar/A333/fire/status/eng1_agent2_psi")
A333DR_eng2_agent1_psi = find_dataref("laminar/A333/fire/status/eng2_agent1_psi")
A333DR_eng2_agent2_psi = find_dataref("laminar/A333/fire/status/eng2_agent2_psi")
A333DR_apu_agent_psi = find_dataref("laminar/A333/fire/status/apu_agent_psi")

A333DR_com1_receive = find_dataref("laminar/A333/selcal/com1_receive")
A333DR_com2_receive = find_dataref("laminar/A333/selcal/com2_receive")
A333DR_com1_acknowledge = find_dataref("laminar/A333/selcal/com1_acknowledge")
A333DR_com2_acknowledge = find_dataref("laminar/A333/selcal/com2_acknowledge")

A333DR_rtp_L_offside_tuning_status = find_dataref("laminar/A333/comm/rtp_L/offside_tuning_status")
A333DR_rtp_L_off_status = find_dataref("laminar/A333/comm/rtp_L/off_status")
A333DR_rtp_L_vhf_1_status = find_dataref("laminar/A333/comm/rtp_L/vhf_1_status")
A333DR_rtp_L_vhf_2_status = find_dataref("laminar/A333/comm/rtp_L/vhf_2_status")
A333DR_rtp_L_vhf_3_status = find_dataref("laminar/A333/comm/rtp_L/vhf_3_status")
A333DR_rtp_L_hf_1_status = find_dataref("laminar/A333/comm/rtp_L/hf_1_status")
A333DR_rtp_L_hf_2_status = find_dataref("laminar/A333/comm/rtp_L/hf_2_status")
A333DR_rtp_L_am_status = find_dataref("laminar/A333/comm/rtp_L/am_status")

A333DR_rtp_R_offside_tuning_status = find_dataref("laminar/A333/comm/rtp_R/offside_tuning_status")
A333DR_rtp_R_off_status = find_dataref("laminar/A333/comm/rtp_R/off_status")
A333DR_rtp_R_vhf_1_status = find_dataref("laminar/A333/comm/rtp_R/vhf_1_status")
A333DR_rtp_R_vhf_2_status = find_dataref("laminar/A333/comm/rtp_R/vhf_2_status")
A333DR_rtp_R_vhf_3_status = find_dataref("laminar/A333/comm/rtp_R/vhf_3_status")
A333DR_rtp_R_hf_1_status = find_dataref("laminar/A333/comm/rtp_R/hf_1_status")
A333DR_rtp_R_hf_2_status = find_dataref("laminar/A333/comm/rtp_R/hf_2_status")
A333DR_rtp_R_am_status = find_dataref("laminar/A333/comm/rtp_R/am_status")

A333DR_rtp_C_offside_tuning_status = find_dataref("laminar/A333/comm/rtp_C/offside_tuning_status")
A333DR_rtp_C_off_status = find_dataref("laminar/A333/comm/rtp_C/off_status")
A333DR_rtp_C_vhf_1_status = find_dataref("laminar/A333/comm/rtp_C/vhf_1_status")
A333DR_rtp_C_vhf_2_status = find_dataref("laminar/A333/comm/rtp_C/vhf_2_status")
A333DR_rtp_C_vhf_3_status = find_dataref("laminar/A333/comm/rtp_C/vhf_3_status")
A333DR_rtp_C_hf_1_status = find_dataref("laminar/A333/comm/rtp_C/hf_1_status")
A333DR_rtp_C_hf_2_status = find_dataref("laminar/A333/comm/rtp_C/hf_2_status")
A333DR_rtp_C_am_status = find_dataref("laminar/A333/comm/rtp_C/am_status")

A333DR_capt_com1_activated = find_dataref("laminar/A333/selcal/capt_com1_activated")
A333DR_capt_com2_activated = find_dataref("laminar/A333/selcal/capt_com2_activated")
A333DR_capt_att_activated = find_dataref("laminar/A333/selcal/capt_att_activated")
A333DR_capt_gen_activated = find_dataref("laminar/A333/selcal/capt_gen_activated")
A333DR_fo_com1_activated = find_dataref("laminar/A333/selcal/fo_com1_activated")
A333DR_fo_com2_activated = find_dataref("laminar/A333/selcal/fo_com2_activated")
A333DR_fo_att_activated = find_dataref("laminar/A333/selcal/fo_att_activated")
A333DR_fo_gen_activated = find_dataref("laminar/A333/selcal/fo_gen_activated")
A333DR_obs_com1_activated = find_dataref("laminar/A333/selcal/obs_com1_activated")
A333DR_obs_com2_activated = find_dataref("laminar/A333/selcal/obs_com2_activated")
A333DR_obs_att_activated = find_dataref("laminar/A333/selcal/obs_att_activated")
A333DR_obs_gen_activated = find_dataref("laminar/A333/selcal/obs_gen_activated")

A333DR_audio_panel_capt_mic1_status = find_dataref("laminar/A333/audio/capt/mic_status1")
A333DR_audio_panel_capt_mic2_status = find_dataref("laminar/A333/audio/capt/mic_status2")
A333DR_audio_panel_capt_mic3_status = find_dataref("laminar/A333/audio/capt/mic_status3")
A333DR_audio_panel_capt_mic4_status = find_dataref("laminar/A333/audio/capt/mic_status4")
A333DR_audio_panel_capt_mic5_status = find_dataref("laminar/A333/audio/capt/mic_status5")
A333DR_audio_panel_capt_mic6_status = find_dataref("laminar/A333/audio/capt/mic_status6")
A333DR_audio_panel_capt_mic7_status = find_dataref("laminar/A333/audio/capt/mic_status7")
A333DR_audio_panel_capt_mic8_status = find_dataref("laminar/A333/audio/capt/mic_status8")
A333DR_audio_panel_capt_mic9_status = find_dataref("laminar/A333/audio/capt/mic_status9")
A333DR_audio_panel_capt_mic10_status = find_dataref("laminar/A333/audio/capt/mic_status10")
A333DR_audio_panel_capt_voice_status = find_dataref("laminar/A333/audio/capt_voice_status")

A333DR_audio_panel_fo_mic1_status = find_dataref("laminar/A333/audio/fo/mic_status1")
A333DR_audio_panel_fo_mic2_status = find_dataref("laminar/A333/audio/fo/mic_status2")
A333DR_audio_panel_fo_mic3_status = find_dataref("laminar/A333/audio/fo/mic_status3")
A333DR_audio_panel_fo_mic4_status = find_dataref("laminar/A333/audio/fo/mic_status4")
A333DR_audio_panel_fo_mic5_status = find_dataref("laminar/A333/audio/fo/mic_status5")
A333DR_audio_panel_fo_mic6_status = find_dataref("laminar/A333/audio/fo/mic_status6")
A333DR_audio_panel_fo_mic7_status = find_dataref("laminar/A333/audio/fo/mic_status7")
A333DR_audio_panel_fo_mic8_status = find_dataref("laminar/A333/audio/fo/mic_status8")
A333DR_audio_panel_fo_mic9_status = find_dataref("laminar/A333/audio/fo/mic_status9")
A333DR_audio_panel_fo_mic10_status = find_dataref("laminar/A333/audio/fo/mic_status10")
A333DR_audio_panel_fo_voice_status = find_dataref("laminar/A333/audio/fo_voice_status")

A333DR_audio_panel_obs_mic1_status = find_dataref("laminar/A333/audio/obs/mic_status1")
A333DR_audio_panel_obs_mic2_status = find_dataref("laminar/A333/audio/obs/mic_status2")
A333DR_audio_panel_obs_mic3_status = find_dataref("laminar/A333/audio/obs/mic_status3")
A333DR_audio_panel_obs_mic4_status = find_dataref("laminar/A333/audio/obs/mic_status4")
A333DR_audio_panel_obs_mic5_status = find_dataref("laminar/A333/audio/obs/mic_status5")
A333DR_audio_panel_obs_mic6_status = find_dataref("laminar/A333/audio/obs/mic_status6")
A333DR_audio_panel_obs_mic7_status = find_dataref("laminar/A333/audio/obs/mic_status7")
A333DR_audio_panel_obs_mic8_status = find_dataref("laminar/A333/audio/obs/mic_status8")
A333DR_audio_panel_obs_mic9_status = find_dataref("laminar/A333/audio/obs/mic_status9")
A333DR_audio_panel_obs_mic10_status = find_dataref("laminar/A333/audio/obs/mic_status10")
A333DR_audio_panel_obs_voice_status = find_dataref("laminar/A333/audio/obs_voice_status")
A333DR_audio_panel_capt_listen_status = find_dataref("laminar/A333/audio/capt/listen_status")
A333DR_audio_panel_fo_listen_status = find_dataref("laminar/A333/audio/fo/listen_status")
A333DR_audio_panel_obs_listen_status = find_dataref("laminar/A333/audio/obs/listen_status")
A333DR_capt_priority_status = find_dataref("laminar/A333/sidestick/capt_prior_annun")
A333DR_fo_priority_status = find_dataref("laminar/A333/sidestick/fo_prior_annun")
A333DR_capt_arrow_status = find_dataref("laminar/A333/sidestick/capt_arrow_annun")
A333DR_fo_arrow_status = find_dataref("laminar/A333/sidestick/fo_arrow_annun")
A333DR_dual_input = find_dataref("laminar/A333/sidestick/dual_input") -- 1 = dual input, used to determine FLASHER status of CAPT/FO lights
A333DR_probe_window_heat_monitor = find_dataref("laminar/A333/monitors/probe_window_heat")

A333DR_green_leak_measure_status = find_dataref("laminar/A333/hyd/leak_measurement_g_status")
A333DR_blue_leak_measure_status = find_dataref("laminar/A333/hyd/leak_measurement_b_status")
A333DR_yellow_leak_measure_status = find_dataref("laminar/A333/hyd/leak_measurement_y_status")
A333DR_elec_pump_green_contactor = find_dataref("laminar/A333/hyd/elec_green_contactor") -- 1 = AUTO, 0 = OFF
A333DR_elec_pump_blue_contactor = find_dataref("laminar/A333/hyd/elec_blue_contactor") -- 1 = STBY, 0 = OFF
A333DR_elec_pump_yellow_contactor = find_dataref("laminar/A333/hyd/elec_yellow_contactor") -- 1 = AUTO, 0 = OFF

A333DR_prim1_pos = find_dataref("laminar/A333/buttons/fcc_prim1_pos")
A333DR_prim2_pos = find_dataref("laminar/A333/buttons/fcc_prim2_pos")
A333DR_prim3_pos = find_dataref("laminar/A333/buttons/fcc_prim3_pos")
A333DR_sec1_pos = find_dataref("laminar/A333/buttons/fcc_sec1_pos")
A333DR_sec2_pos = find_dataref("laminar/A333/buttons/fcc_sec2_pos")
A333DR_turb_damp_pos = find_dataref("laminar/A333/buttons/fcc_turb_damp_pos")

A333DR_pax_sys_pos = find_dataref("laminar/A333/buttons/pax_sys_pos", "number")
A333DR_pax_satcom_pos = find_dataref("laminar/A333/buttons/pax_satcom_pos", "number")
A333DR_pax_IFEC_pos = find_dataref("laminar/A333/buttons/pax_IFEC_pos", "number")

A333DR_cargo_cond_fwd_isol_valve_pos = find_dataref("laminar/A333/buttons/cargo_cond/fwd_isol_valve_pos", "number")
A333DR_cargo_cond_bulk_isol_valve_pos = find_dataref("laminar/A333/buttons/cargo_cond/bulk_isol_valve_pos", "number")
A333DR_cargo_cond_hot_air_pos = find_dataref("laminar/A333/buttons/cargo_cond/hot_air_pos", "number")

A333DR_crew_supply_status = find_dataref("laminar/A333/status/crew_oxy_supply")

A333DR_eng1_fadec_ground_powered	= find_dataref("laminar/A333/fadec/eng1_fadec_ground_powered")
A333DR_eng2_fadec_ground_powered	= find_dataref("laminar/A333/fadec/eng2_fadec_ground_powered")

--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
A333DR_wing_heat_valve_pos_left = create_dataref("laminar/A333/anti_ice/status/left_wing_valve_pos", "number")
A333DR_wing_heat_valve_pos_right = create_dataref("laminar/A333/anti_ice/status/right_wing_valve_pos", "number")

A333DR_fuel_crossfeed_valve_pos = create_dataref("laminar/A333/fuel/crossfeed_valve_pos", "number")

A333DR_annun_brightness_exta_grd_srvc = create_dataref("laminar/A333/annun/brightness_exta_grd_srvc", "number")
A333DR_annun_brightness_ac1 = create_dataref("laminar/A333/annun/brightness_ac1", "number")
A333DR_annun_brightness_ac1_2 = create_dataref("laminar/A333/annun/brightness_ac1_2", "number")
A333DR_annun_brightness_ac2 = create_dataref("laminar/A333/annun/brightness_ac2", "number")
A333DR_annun_brightness_ac2_2 = create_dataref("laminar/A333/annun/brightness_ac2_2", "number")
A333DR_annun_brightness_ac_ess = create_dataref("laminar/A333/annun/brightness_ac_ess", "number")
A333DR_annun_brightness_ac_ess_2 = create_dataref("laminar/A333/annun/brightness_ac_ess_2", "number")
A333DR_annun_brightness_ac_ess_shed = create_dataref("laminar/A333/annun/brightness_ac_ess_shed", "number")
A333DR_annun_brightness_ac_ess_shed_2 = create_dataref("laminar/A333/annun/brightness_ac_ess_shed2", "number")
A333DR_annun_brightness_ac_ess_grnd = create_dataref("laminar/A333/annun/brightness_ac_ess_grnd", "number")
A333DR_annun_brightness_ac_ess_grnd_2 = create_dataref("laminar/A333/annun/brightness_ac_ess_grnd2", "number")
A333DR_annun_brightness_ac_ess_land_rcvry = create_dataref("laminar/A333/annun/brightness_ac_ess_land_rcvry", "number")
A333DR_annun_brightness_ac_ess_land_rcvry_2 = create_dataref("laminar/A333/annun/brightness_ac_ess_land_rcvry2", "number")
A333DR_annun_brightness_ac_ess_or_ac_ess_shed = create_dataref("laminar/A333/annun/brightness_ac_ess_or_ac_ess_shed", "number")
A333DR_annun_brightness_ac_ess_or_ac_ess_shed2 = create_dataref("laminar/A333/annun/brightness_ac_ess_or_ac_ess_shed2", "number")
A333DR_annun_brightness_ac1_or_ac_ess_shed = create_dataref("laminar/A333/annun/brightness_ac1_or_ac_ess_shed", "number")
A333DR_annun_brightness_ac1_or_ac_ess_or_ac_ess_shed = create_dataref("laminar/A333/annun/brightness_ac1_or_ac_ess_or_ac_ess_shed", "number")
A333DR_annun_brightness_ac1_or_ac_ess_or_ac_ess_shed2 = create_dataref("laminar/A333/annun/brightness_ac1_or_ac_ess_or_ac_ess_shed2", "number")
A333DR_annun_brightness_ac2_or_ac_ess_or_ac_ess_shed = create_dataref("laminar/A333/annun/brightness_ac2_or_ac_ess_or_ac_ess_shed", "number")
A333DR_annun_brightness_ac2_or_ac_ess_or_ac_ess_shed2 = create_dataref("laminar/A333/annun/brightness_ac2_or_ac_ess_or_ac_ess_shed2", "number")
A333DR_annun_brightness_ac2_or_ac_ess_shed = create_dataref("laminar/A333/annun/brightness_ac2_or_ac_ess_shed", "number")
A333DR_annun_brightness_ac2_or_ac_ess_shed2 = create_dataref("laminar/A333/annun/brightness_ac2_or_ac_ess_shed2", "number")
A333DR_annun_brightness_ac_ess_grnd_or_ac_ess = create_dataref("laminar/A333/annun/brightness_ess_grnd_or_ac_ess", "number")
A333DR_annun_brightness_dc_bat = create_dataref("laminar/A333/annun/brightness_brightness_dc_bat", "number")
A333DR_annun_brightness_dc_apu_bat = create_dataref("laminar/A333/annun/brightness_dc_apu_bat", "number")



-- AC1
A333DR_annun_engine1_anti_ice_on = create_dataref("laminar/A333/annun/engine1_anti_ice", "number")
A333DR_annun_engine2_anti_ice_on = create_dataref("laminar/A333/annun/engine2_anti_ice", "number")
A333DR_annun_engine1_anti_ice_fault = create_dataref("laminar/A333/annun/engine1_anti_ice_fault", "number")
A333DR_annun_engine2_anti_ice_fault = create_dataref("laminar/A333/annun/engine2_anti_ice_fault", "number")
A333DR_annun_transponder_fail = create_dataref("laminar/A333/annun/transponder_fail", "number")
A333DR_annun_elt = create_dataref("laminar/A333/annun/ELT_active", "number")
A333DR_annun_elt_no_anim = create_dataref("laminar/A333/annun/ELT_active_no_anim", "number")
A333DR_annun_ventilation_cab_fans_off = create_dataref("laminar/A333/annun/ventilation/cab_fans_off","number")
A333DR_annun_adirs_adr1_off = create_dataref("laminar/A333/annun/adirs/adr1_off","number")
A333DR_annun_adirs_adr2_off = create_dataref("laminar/A333/annun/adirs/adr2_off","number")
A333DR_annun_adirs_adr3_off = create_dataref("laminar/A333/annun/adirs/adr3_off","number")
A333DR_annun_adirs_ir1_off = create_dataref("laminar/A333/annun/adirs/ir1_off","number")
A333DR_annun_adirs_ir2_off = create_dataref("laminar/A333/annun/adirs/ir2_off","number")
A333DR_annun_adirs_ir3_off = create_dataref("laminar/A333/annun/adirs/ir3_off","number")
A333DR_annun_adirs_adr1_fault = create_dataref("laminar/A333/annun/adirs/adr1_fault","number")
A333DR_annun_adirs_adr2_fault = create_dataref("laminar/A333/annun/adirs/adr2_fault","number")
A333DR_annun_adirs_adr3_fault = create_dataref("laminar/A333/annun/adirs/adr3_fault","number")
A333DR_annun_adirs_ir1_fault = create_dataref("laminar/A333/annun/adirs/ir1_fault","number")
A333DR_annun_adirs_ir2_fault = create_dataref("laminar/A333/annun/adirs/ir2_fault","number")
A333DR_annun_adirs_ir3_fault = create_dataref("laminar/A333/annun/adirs/ir3_fault","number")
A333DR_annun_auto_brake_lo_on = create_dataref("laminar/A333/annun/auto_brake/lo_on","number")
A333DR_annun_auto_brake_med_on = create_dataref("laminar/A333/annun/auto_brake/med_on","number")
A333DR_annun_auto_brake_max_on = create_dataref("laminar/A333/annun/auto_brake/max_on","number")
A333DR_annun_auto_brake_lo_decel = create_dataref("laminar/A333/annun/auto_brake/lo_decel","number")
A333DR_annun_auto_brake_med_decel = create_dataref("laminar/A333/annun/auto_brake/med_decel","number")
A333DR_annun_auto_brake_max_decel = create_dataref("laminar/A333/annun/auto_brake/max_decel","number")
A333DR_annun_capt_flight_director_on = create_dataref("laminar/A333/annun/capt_flight_director_on","number")
A333DR_annun_captain_ls_bars_on = create_dataref("laminar/A333/annun/captain_ls_bars_on","number")
A333DR_annun_fo_flight_director_on = create_dataref("laminar/A333/annun/fo_flight_director_on","number")
A333DR_annun_fo_ls_bars_on = create_dataref("laminar/A333/annun/fo_ls_bars_on","number")
A333DR_annun_atc_comm = create_dataref("laminar/A333/annun/atc_comm","number")
A333DR_annun_gpws_flap_mode_off = create_dataref("laminar/A333/annun/gpws/flap_mode_off","number")
A333DR_annun_gpws_g_s_mode_off = create_dataref("laminar/A333/annun/gpws/g_s_mode_off","number")
A333DR_annun_gpws_sys_off = create_dataref("laminar/A333/annun/gpws/sys_off","number")
A333DR_annun_gpws_sys_fault = create_dataref("laminar/A333/annun/gpws_sys_fault","number")
A333DR_annun_hyd_elec_green_pump_fault = create_dataref("laminar/A333/annun/hyd/elec_green_fault","number")
A333DR_annun_hyd_elec_green_pump_off = create_dataref("laminar/A333/annun/hyd/elec_green_off","number")
A333DR_annun_hyd_elec_green_pump_on = create_dataref("laminar/A333/annun/hyd/elec_green_on","number")
A333DR_annun_hyd_eng1_green_pump_fault = create_dataref("laminar/A333/annun/hyd/eng1_green_fault","number")
A333DR_annun_hyd_eng1_green_pump_off = create_dataref("laminar/A333/annun/hyd/eng1_green_off","number")
A333DR_annun_hyd_eng2_green_pump_fault = create_dataref("laminar/A333/annun/hyd/eng2_green_fault","number")
A333DR_annun_hyd_eng2_green_pump_off = create_dataref("laminar/A333/annun/hyd/eng2_green_off","number")
A333DR_annun_eng1_bleed_fault = create_dataref("laminar/A333/annun/eng1_bleed_fault","number")
A333DR_annun_eng1_bleed_off = create_dataref("laminar/A333/annun/eng1_bleed_off","number")
A333DR_annun_hot_air1_off = create_dataref("laminar/A333/annun/hot_air1_off","number")
A333DR_annun_hot_air2_off = create_dataref("laminar/A333/annun/hot_air2_off","number")
A333DR_annun_hot_air1_fault = create_dataref("laminar/A333/annun/hot_air1_fault","number")
A333DR_annun_hot_air2_fault = create_dataref("laminar/A333/annun/hot_air2_fault","number")
A333DR_annun_fuel_pump_ctr_tank_R_fault	 = create_dataref("laminar/A333/annun/fuel/ctr_tank_R_fault","number")
A333DR_annun_fuel_pump_ctr_tank_R_off = create_dataref("laminar/A333/annun/fuel/ctr_tank_R_off","number")
A333DR_annun_fuel_pump_R_stby_fault = create_dataref("laminar/A333/annun/fuel/R_stby_fault","number")
A333DR_annun_fuel_pump_R_stby_off = create_dataref("laminar/A333/annun/fuel/R_stby_off","number")
A333DR_annun_fuel_pump_L_stby_fault = create_dataref("laminar/A333/annun/fuel/L_stby_fault","number")
A333DR_annun_fuel_pump_L_stby_off = create_dataref("laminar/A333/annun/fuel/L_stby_off","number")
A333DR_annun_fuel_ctr_tank_xfr_fault = create_dataref("laminar/A333/annun/fuel/ctr_tank_xfr_fault","number")
A333DR_annun_fuel_ctr_tank_xfr_man = create_dataref("laminar/A333/annun/fuel/ctr_tank_xfr_man","number")
A333DR_annun_cargo_fwd_agent_smoke = create_dataref("laminar/A333/annun/cargo/fwd_agent_smoke","number")
A333DR_annun_cargo_aft_agent_smoke = create_dataref("laminar/A333/annun/cargo/aft_agent_smoke","number")
A333DR_annun_cargo_aft_agent_squib = create_dataref("laminar/A333/annun/cargo/aft_agent_squib","number")
A333DR_annun_cargo_fwd_agent_squib = create_dataref("laminar/A333/annun/cargo/fwd_agent_squib","number")
A333DR_annun_cargo_disch_btl1 = create_dataref("laminar/A333/annun/cargo/disch_btl1","number")
A333DR_annun_cargo_disch_btl2 = create_dataref("laminar/A333/annun/cargo/disch_btl2","number")
A333DR_annun_rtp_C_offside_tuning = create_dataref("laminar/A333/annun/comm/rtp_C/offside_tuning_active","number")
A333DR_annun_rtp_C_vhf_1 = create_dataref("laminar/A333/annun/comm/rtp_C/vhf_1_active","number")
A333DR_annun_rtp_C_vhf_2 = create_dataref("laminar/A333/annun/comm/rtp_C/vhf_2_active","number")
A333DR_annun_rtp_C_vhf_3 = create_dataref("laminar/A333/annun/comm/rtp_C/vhf_3_active","number")
A333DR_annun_rtp_C_hf_1 = create_dataref("laminar/A333/annun/comm/rtp_C/hf_1_active","number")
A333DR_annun_rtp_C_am = create_dataref("laminar/A333/annun/comm/rtp_C/am_active","number")
A333DR_annun_rtp_C_hf_2 = create_dataref("laminar/A333/annun/comm/rtp_C/hf_2_active","number")
A333DR_annun_rtp_C_no_op = create_dataref("laminar/A333/annun/comm/rtp_C/no_op","number")
A333DR_audio_panel_obs_mic1_annun = create_dataref("laminar/A333/audio/obs/mic_annun1", "number")
A333DR_audio_panel_obs_mic2_annun = create_dataref("laminar/A333/audio/obs/mic_annun2", "number")
A333DR_audio_panel_obs_mic3_annun = create_dataref("laminar/A333/audio/obs/mic_annun3", "number")
A333DR_audio_panel_obs_mic4_annun = create_dataref("laminar/A333/audio/obs/mic_annun4", "number")
A333DR_audio_panel_obs_mic5_annun = create_dataref("laminar/A333/audio/obs/mic_annun5", "number")
A333DR_audio_panel_obs_mic6_annun = create_dataref("laminar/A333/audio/obs/mic_annun6", "number")
A333DR_audio_panel_obs_mic7_annun = create_dataref("laminar/A333/audio/obs/mic_annun7", "number")
A333DR_audio_panel_obs_mic8_annun = create_dataref("laminar/A333/audio/obs/mic_annun8", "number")
A333DR_audio_panel_obs_mic9_annun = create_dataref("laminar/A333/audio/obs/mic_annun9", "number")
A333DR_audio_panel_obs_mic10_annun = create_dataref("laminar/A333/audio/obs/mic_annun10", "number")
A333DR_audio_panel_obs_voice_annun = create_dataref("laminar/A333/audio/obs_voice_annun", "number")
A333DR_audio_panel_obs_call_light_vhf1 = create_dataref("laminar/A333/audio/obs_call_light_vhf1", "number")
A333DR_audio_panel_obs_call_light_vhf2 = create_dataref("laminar/A333/audio/obs_call_light_vhf2", "number")
A333DR_audio_panel_obs_call_light_att = create_dataref("laminar/A333/audio/obs_call_light_att", "number")
A333DR_audio_panel_obs_call_light_gen = create_dataref("laminar/A333/audio/obs_call_light_gen", "number")
A333DR_audio_panel_obs_listen_annun = create_dataref("laminar/A333/audio/obs_listening_annun", "array[" .. tostring(NUM_OBS_LISTENING_LIGHTS) .. "]")
A333DR_capt_priority_light_annun = create_dataref("laminar/A333/annun/capt_sidestick_prior", "number")
A333DR_capt_priority_arrow_light_annun = create_dataref("laminar/A333/annun/capt_sidestick_prior_arrow", "number")
A333DR_annun_nose_wheel_towing_fault = create_dataref("laminar/A333/annun/nose_wheel_towing_fault", "number")
A333DR_annun_mcdu1_fail_fm = create_dataref("laminar/A333/annun/mcdu1_fail_fm", "number")
A333DR_annun_mcdu1_mcdu_menu = create_dataref("laminar/A333/annun/mcdu1_mcdu_menu", "number")
A333DR_annun_mcdu1_fm1 = create_dataref("laminar/A333/annun/mcdu1_fm1", "number")
A333DR_annun_mcdu1_fm2 = create_dataref("laminar/A333/annun/mcdu1_fm2", "number")
A333DR_annun_mcdu1_ind = create_dataref("laminar/A333/annun/mcdu1_ind", "number")
A333DR_annun_mcdu1_rdy = create_dataref("laminar/A333/annun/mcdu1_rdy", "number")
A333DR_annun_mcdu1_line = create_dataref("laminar/A333/annun/mcdu1_line", "number")
A333DR_annun_mcdu3_fail_fm = create_dataref("laminar/A333/annun/mcdu3_fail_fm", "number")
A333DR_annun_mcdu3_mcdu_menu = create_dataref("laminar/A333/annun/mcdu3_mcdu_menu", "number")
A333DR_annun_mcdu3_fm1 = create_dataref("laminar/A333/annun/mcdu3_fm1", "number")
A333DR_annun_mcdu3_fm2 = create_dataref("laminar/A333/annun/mcdu3_fm2", "number")
A333DR_annun_mcdu3_ind = create_dataref("laminar/A333/annun/mcdu3_ind", "number")
A333DR_annun_mcdu3_rdy = create_dataref("laminar/A333/annun/mcdu3_rdy", "number")
A333DR_annun_mcdu3_line = create_dataref("laminar/A333/annun/mcdu3_line", "number")
A333DR_annun_printer_paper_alarm = create_dataref("laminar/A333/annun/printer_paper_alarm", "number")

-- AC1 or AC ESS or AC ESS SHED
A333DR_annun_fire_apu_handle = create_dataref("laminar/A333/annun/fire/apu_handle", "number")

-- AC2
A333DR_annun_cockpit_door_open = create_dataref("laminar/A333/annun/cockpit_door_open", "number")
A333DR_annun_cockpit_door_fault = create_dataref("laminar/A333/annun/cockpit_door_fault", "number")
A333DR_annun_cockpit_door_video_off = create_dataref("laminar/A333/annun/cockpit_door_video_off", "number")
A333DR_annun_cockpit_door_ctl_strike_top = create_dataref("laminar/A333/annun/cockpit_door_ctl_strike_top", "number")
A333DR_annun_cockpit_door_ctl_strike_mid = create_dataref("laminar/A333/annun/cockpit_door_ctl_strike_mid", "number")
A333DR_annun_cockpit_door_ctl_strike_btm = create_dataref("laminar/A333/annun/cockpit_door_ctl_strike_btm", "number")
A333DR_annun_cockpit_door_ctl_channel1 = create_dataref("laminar/A333/annun/cockpit_door_ctl_channel1", "number")
A333DR_annun_cockpit_door_ctl_channel2 = create_dataref("laminar/A333/annun/cockpit_door_ctl_channel2", "number")
A333DR_annun_cockpit_door_ctl_strike_top_backup = create_dataref("laminar/A333/annun/cockpit_door_ctl_strike_top_backup", "number")
A333DR_annun_cockpit_door_ctl_strike_mid_backup = create_dataref("laminar/A333/annun/cockpit_door_ctl_strike_mid_backup", "number")
A333DR_annun_cockpit_door_ctl_strike_btm_backup = create_dataref("laminar/A333/annun/cockpit_door_ctl_strike_btm_backup", "number")
A333DR_annun_cockpit_door_ctl_channel1_backup = create_dataref("laminar/A333/annun/cockpit_door_ctl_channel1_backup", "number")
A333DR_annun_cockpit_door_ctl_channel2_backup = create_dataref("laminar/A333/annun/cockpit_door_ctl_channel2_backup", "number")
A333DR_annun_cockpit_door_sw_ovrd_arm = create_dataref("laminar/A333/annun/cockpit_door_sw_ovrd_arm", "number")
A333DR_annun_cockpit_door_sw_ovrd_fault = create_dataref("laminar/A333/annun/cockpit_door_sw_ovrd_fault", "number")
A333DR_annun_flt_ctl_prim2_off = create_dataref("laminar/A333/annun/flt_ctl/prim2_off","number")
A333DR_annun_flt_ctl_prim3_off = create_dataref("laminar/A333/annun/flt_ctl/prim3_off","number")
A333DR_annun_flt_ctl_sec2_off = create_dataref("laminar/A333/annun/flt_ctl/sec2_off","number")
A333DR_annun_adirs_on_bat = create_dataref("laminar/A333/annun/adirs/on_bat","number")
A333DR_annun_landing_gear_brake_fan_hot = create_dataref("laminar/A333/annun/landing_gear/brake_fan_hot","number")
A333DR_annun_landing_gear_brake_fan_on = create_dataref("laminar/A333/annun/landing_gear/brake_fan_on","number")
A333DR_annun_ecp_eng = create_dataref("laminar/A333/annun/ecam_mode_eng","number") -- 0
A333DR_annun_ecp_bleed = create_dataref("laminar/A333/annun/ecam_mode_bleed","number") -- 1
A333DR_annun_ecp_press = create_dataref("laminar/A333/annun/ecam_mode_press","number") -- 2
A333DR_annun_ecp_el_ac = create_dataref("laminar/A333/annun/ecam_mode_el_ac","number") -- 3
A333DR_annun_ecp_el_dc = create_dataref("laminar/A333/annun/ecam_mode_el_dc","number") -- 4
A333DR_annun_ecp_hyd = create_dataref("laminar/A333/annun/ecam_mode_hyd","number") -- 5
A333DR_annun_ecp_c_b = create_dataref("laminar/A333/annun/ecam_mode_c_b","number") -- 6
A333DR_annun_ecp_apu = create_dataref("laminar/A333/annun/ecam_mode_apu","number") -- 7
A333DR_annun_ecp_cond = create_dataref("laminar/A333/annun/ecam_mode_cond","number") -- 8
A333DR_annun_ecp_door = create_dataref("laminar/A333/annun/ecam_mode_door","number") -- 9
A333DR_annun_ecp_wheel = create_dataref("laminar/A333/annun/ecam_mode_wheel","number") -- 10
A333DR_annun_ecp_f_ctl = create_dataref("laminar/A333/annun/ecam_mode_f_ctl","number") -- 11
A333DR_annun_ecp_fuel = create_dataref("laminar/A333/annun/ecam_mode_fuel","number") -- 12
A333DR_annun_ecp_clr = create_dataref("laminar/A333/annun/ecp_clr","number")
A333DR_annun_ecp_sts = create_dataref("laminar/A333/annun/ecp_sts","number")
A333DR_annun_master_caution = create_dataref("laminar/A333/annun/master_caution","number")
A333DR_annun_master_warning = create_dataref("laminar/A333/annun/master_warning","number")
A333DR_annun_GPWS_warn = create_dataref("laminar/A333/annun/GPWS_warn","number")
A333DR_annun_GS_warn = create_dataref("laminar/A333/annun/GS_warn","number")
A333DR_annun_rcdr_gnd_ctl_on = create_dataref("laminar/A333/annun/rcdr/gnd_ctl_on","number")
A333DR_annun_hyd_elec_yellow_pump_fault = create_dataref("laminar/A333/annun/hyd/elec_yellow_fault","number")
A333DR_annun_hyd_elec_yellow_pump_off = create_dataref("laminar/A333/annun/hyd/elec_yellow_off","number")
A333DR_annun_hyd_elec_yellow_pump_on = create_dataref("laminar/A333/annun/hyd/elec_yellow_on","number")
A333DR_annun_hyd_eng2_yellow_pump_fault = create_dataref("laminar/A333/annun/hyd/eng2_yellow_fault","number")
A333DR_annun_hyd_eng2_yellow_pump_off = create_dataref("laminar/A333/annun/hyd/eng2_yellow_off","number")
A333DR_annun_elec_ext_a_on = create_dataref("laminar/A333/annun/elec/ext_a_on","number")
A333DR_annun_elec_ext_b_auto = create_dataref("laminar/A333/annun/elec/ext_b_auto","number")
A333DR_annun_elec_ac_ess_feed_altn = create_dataref("laminar/A333/annun/elec/ac_ess_feed_altn","number")
A333DR_annun_elec_ac_ess_feed_fault = create_dataref("laminar/A333/annun/elec/ac_ess_feed_fault","number")
A333DR_annun_eng2_bleed_fault = create_dataref("laminar/A333/annun/eng2_bleed_fault","number")
A333DR_annun_eng2_bleed_off = create_dataref("laminar/A333/annun/eng2_bleed_off","number")
A333DR_annun_pack2_fault = create_dataref("laminar/A333/annun/pack2_fault","number")
A333DR_annun_pack2_off = create_dataref("laminar/A333/annun/pack2_off","number")
A333DR_annun_misc_toilet_occpd = create_dataref("laminar/A333/annun/misc/toilet_occpd","number")
A333DR_annun_fuel_pump_ctr_tank_L_fault = create_dataref("laminar/A333/annun/fuel/ctr_tank_L_fault","number")
A333DR_annun_fuel_pump_ctr_tank_L_off = create_dataref("laminar/A333/annun/fuel/ctr_tank_L_off","number")
A333DR_annun_fuel_pump_L2_fault = create_dataref("laminar/A333/annun/fuel/L2_fault","number")
A333DR_annun_fuel_pump_L2_off = create_dataref("laminar/A333/annun/fuel/L2_off","number")
A333DR_annun_fuel_pump_R2_fault = create_dataref("laminar/A333/annun/fuel/R2_fault","number")
A333DR_annun_fuel_pump_R2_off = create_dataref("laminar/A333/annun/fuel/R2_off","number")
A333DR_annun_fuel_outr_tk_xfr_fault = create_dataref("laminar/A333/annun/fuel/outr_tk_xfr_fault","number")
A333DR_annun_fuel_outr_tk_xfr_on = create_dataref("laminar/A333/annun/fuel/outr_tk_xfr_on","number")
A333DR_annun_rtp_R_offside_tuning = create_dataref("laminar/A333/annun/comm/rtp_R/offside_tuning_active","number")
A333DR_annun_rtp_R_vhf_1 = create_dataref("laminar/A333/annun/comm/rtp_R/vhf_1_active","number")
A333DR_annun_rtp_R_vhf_2 = create_dataref("laminar/A333/annun/comm/rtp_R/vhf_2_active","number")
A333DR_annun_rtp_R_vhf_3 = create_dataref("laminar/A333/annun/comm/rtp_R/vhf_3_active","number")
A333DR_annun_rtp_R_hf_1 = create_dataref("laminar/A333/annun/comm/rtp_R/hf_1_active","number")
A333DR_annun_rtp_R_am = create_dataref("laminar/A333/annun/comm/rtp_R/am_active","number")
A333DR_annun_rtp_R_hf_2	 = create_dataref("laminar/A333/annun/comm/rtp_R/hf_2_active","number")
A333DR_annun_rtp_R_no_op = create_dataref("laminar/A333/annun/comm/rtp_R/no_op","number")
A333DR_audio_panel_fo_mic1_annun = create_dataref("laminar/A333/audio/fo/mic_annun1", "number")
A333DR_audio_panel_fo_mic2_annun = create_dataref("laminar/A333/audio/fo/mic_annun2", "number")
A333DR_audio_panel_fo_mic3_annun = create_dataref("laminar/A333/audio/fo/mic_annun3", "number")
A333DR_audio_panel_fo_mic4_annun = create_dataref("laminar/A333/audio/fo/mic_annun4", "number")
A333DR_audio_panel_fo_mic5_annun = create_dataref("laminar/A333/audio/fo/mic_annun5", "number")
A333DR_audio_panel_fo_mic6_annun = create_dataref("laminar/A333/audio/fo/mic_annun6", "number")
A333DR_audio_panel_fo_mic7_annun = create_dataref("laminar/A333/audio/fo/mic_annun7", "number")
A333DR_audio_panel_fo_mic8_annun = create_dataref("laminar/A333/audio/fo/mic_annun8", "number")
A333DR_audio_panel_fo_mic9_annun = create_dataref("laminar/A333/audio/fo/mic_annun9", "number")
A333DR_audio_panel_fo_mic10_annun = create_dataref("laminar/A333/audio/fo/mic_annun10", "number")
A333DR_audio_panel_fo_voice_annun = create_dataref("laminar/A333/audio/fo_voice_annun", "number")
A333DR_audio_panel_fo_call_light_vhf1 = create_dataref("laminar/A333/audio/fo_call_light_vhf1", "number")
A333DR_audio_panel_fo_call_light_vhf2 = create_dataref("laminar/A333/audio/fo_call_light_vhf2", "number")
A333DR_audio_panel_fo_call_light_att = create_dataref("laminar/A333/audio/fo_call_light_att", "number")
A333DR_audio_panel_fo_call_light_gen = create_dataref("laminar/A333/audio/fo_call_light_gen", "number")
A333DR_audio_panel_fo_listen_annun = create_dataref("laminar/A333/audio/fo_listening_annun", "array[" .. tostring(NUM_FO_LISTENING_LIGHTS) .. "]")
A333DR_fo_priority_light_annun = create_dataref("laminar/A333/annun/fo_sidestick_prior", "number")
A333DR_fo_priority_arrow_light_annun = create_dataref("laminar/A333/annun/fo_sidestick_prior_arrow", "number")
A333DR_annun_flt_ctl_sec2_fault = create_dataref("laminar/A333/annun/flt_ctl/sec2_fault","number")
A333DR_annun_flt_ctl_sec3_fault = create_dataref("laminar/A333/annun/flt_ctl/sec3_fault","number")
A333DR_annun_flt_ctl_prim2_fault = create_dataref("laminar/A333/annun/flt_ctl/prim2_fault","number")
A333DR_annun_flt_ctl_prim3_fault = create_dataref("laminar/A333/annun/flt_ctl/prim3_fault","number")
A333DR_annun_window_probe_heat = create_dataref("laminar/A333/annun/window_probe_on", "number")
A333DR_annun_fuel_inr_tk_on_L = create_dataref("laminar/A333/annun/fuel/inr_tk_on_L", "number")
A333DR_annun_fuel_inr_tk_shut_L = create_dataref("laminar/A333/annun/fuel/inr_tk_shut_L", "number")
A333DR_annun_fuel_inr_tk_on_R = create_dataref("laminar/A333/annun/fuel/inr_tk_on_R", "number")
A333DR_annun_fuel_inr_tk_shut_R = create_dataref("laminar/A333/annun/fuel/inr_tk_shut_R", "number")
A333DR_annun_eng1_fadec_grnd_power_on = create_dataref("laminar/A333/annun/fadec/eng1_grnd_power_on", "number")
A333DR_annun_eng2_fadec_grnd_power_on = create_dataref("laminar/A333/annun/fadec/eng2_grnd_power_on", "number")
A333DR_annun_hyd_leak_msrmnt_g_off = create_dataref("laminar/A333/annun/hydr/leak_msrmnt_g_off", "number")
A333DR_annun_hyd_leak_msrmnt_b_off = create_dataref("laminar/A333/annun/hydr/leak_msrmnt_b_off", "number")
A333DR_annun_hyd_leak_msrmnt_y_off = create_dataref("laminar/A333/annun/hydr/leak_msrmnt_y_off", "number")
A333DR_annun_mcdu2_fail_fm = create_dataref("laminar/A333/annun/mcdu2_fail_fm", "number")
A333DR_annun_mcdu2_mcdu_menu = create_dataref("laminar/A333/annun/mcdu2_mcdu_menu", "number")
A333DR_annun_mcdu2_fm1 = create_dataref("laminar/A333/annun/mcdu2_fm1", "number")
A333DR_annun_mcdu2_fm2 = create_dataref("laminar/A333/annun/mcdu2_fm2", "number")
A333DR_annun_mcdu2_ind = create_dataref("laminar/A333/annun/mcdu2_ind", "number")
A333DR_annun_mcdu2_rdy = create_dataref("laminar/A333/annun/mcdu2_rdy", "number")
A333DR_annun_mcdu2_line = create_dataref("laminar/A333/annun/mcdu2_line", "number")

-- AC2 or ESS SHED
A333DR_annun_auto_land = create_dataref("laminar/A333/annun/auto_land","number")

-- AC1 or AC ESS or AC ESS SHED
A333DR_annun_fire_eng1_handle = create_dataref("laminar/A333/annun/fire/eng1_handle", "number")
A333DR_annun_fire_eng2_handle = create_dataref("laminar/A333/annun/fire/eng2_handle", "number")

-- AC ESS
A333DR_annun_emer_exit_off = create_dataref("laminar/A333/annun/emer_exit_off", "number")
A333DR_annun_EFIS_apt_capt = create_dataref("laminar/A333/annun/EFIS_capt_arpt", "number")
A333DR_annun_EFIS_vor_capt = create_dataref("laminar/A333/annun/EFIS_capt_vor", "number")
A333DR_annun_EFIS_fix_capt = create_dataref("laminar/A333/annun/EFIS_capt_fix", "number")
A333DR_annun_EFIS_ndb_capt = create_dataref("laminar/A333/annun/EFIS_capt_ndb", "number")
A333DR_annun_EFIS_cstr_capt = create_dataref("laminar/A333/annun/EFIS_capt_cstr", "number")
A333DR_annun_EFIS_apt_fo = create_dataref("laminar/A333/annun/EFIS_fo_arpt", "number")
A333DR_annun_EFIS_vor_fo = create_dataref("laminar/A333/annun/EFIS_fo_vor", "number")
A333DR_annun_EFIS_fix_fo = create_dataref("laminar/A333/annun/EFIS_fo_fix", "number")
A333DR_annun_EFIS_ndb_fo = create_dataref("laminar/A333/annun/EFIS_fo_ndb", "number")
A333DR_annun_EFIS_cstr_fo = create_dataref("laminar/A333/annun/EFIS_fo_cstr", "number")
A333DR_annun_EFIS_terr_capt = create_dataref("laminar/A333/annun/terr_on_nd_capt", "number")
A333DR_annun_EFIS_terr_fo = create_dataref("laminar/A333/annun/terr_on_nd_fo", "number")
A333DR_annun_apu_master_fault = create_dataref("laminar/A333/annun/apu_fault", "number")
A333DR_annun_apu_master_on = create_dataref("laminar/A333/annun/apu_master_on", "number")
A333DR_annun_apu_start_on = create_dataref("laminar/A333/annun/apu_start_on", "number")
A333DR_annun_apu_avail = create_dataref("laminar/A333/annun/apu_avail", "number")
A333DR_annun_flt_ctl_prim1_off = create_dataref("laminar/A333/annun/flt_ctl/prim1_off","number")
A333DR_annun_oxygen_pax_sys_on = create_dataref("laminar/A333/annun/oxygen/pax_sys_on","number")
A333DR_annun_land_recovery_on = create_dataref("laminar/A333/annun/elec/A333_land_recovery_on","number")
A333DR_annun_service_interphone_on = create_dataref("laminar/A333/annun/comm/service_interphone_on","number")
A333DR_annun_pax_ifec_fault = create_dataref("laminar/A333/annun/comm/pax_ifec_fault","number")
A333DR_annun_pax_ifec_off = create_dataref("laminar/A333/annun/pax/ifec_off","number")

-- AC ESS SHED
A333DR_annun_elec_apu_gen_fault = create_dataref("laminar/A333/annun/elec/apu_gen_fault","number")
A333DR_annun_wing_anti_ice_fault = create_dataref("laminar/A333/annun/wing_anti_ice_fault", "number")
A333DR_annun_wing_anti_ice_on = create_dataref("laminar/A333/annun/wing_anti_ice", "number")
A333DR_annun_flt_ctl_turb_damp_off = create_dataref("laminar/A333/annun/flt_ctl/turb_damp_off","number")
A333DR_annun_flt_ctl_sec1_off = create_dataref("laminar/A333/annun/flt_ctl/sec1_off","number")
A333DR_annun_cargo_fwd_isol_valves_off = create_dataref("laminar/A333/annun/cargo/fwd_isol_valves_off","number")
A333DR_annun_cargo_bulk_isol_valves_off = create_dataref("laminar/A333/annun/cargo/bulk_isol_valves_off","number")
A333DR_annun_cargo_bulk_hot_air = create_dataref("laminar/A333/annun/cargo/bulk_hot_air","number")
A333DR_annun_cargo_bulk_hot_air_fault = create_dataref("laminar/A333/annun/cargo/bulk_hot_air_fault","number")
A333DR_annun_cargo_fwd_isol_vlv_fault = create_dataref("laminar/A333/annun/cargo/fwd_isol_vlv_fault","number")
A333DR_annun_cargo_bulk_isol_vlv_fault = create_dataref("laminar/A333/annun/cargo/bulk_isol_vlv_fault","number")
A333DR_annun_landing_gear_nose_green = create_dataref("laminar/A333/annun/landing_gear/nose_green","number")
A333DR_annun_landing_gear_left_green = create_dataref("laminar/A333/annun/landing_gear/left_green","number")
A333DR_annun_landing_gear_right_green = create_dataref("laminar/A333/annun/landing_gear/right_green","number")
A333DR_annun_landing_gear_nose_unlk = create_dataref("laminar/A333/annun/landing_gear/nose_unlk","number")
A333DR_annun_landing_gear_left_unlk = create_dataref("laminar/A333/annun/landing_gear/left_unlk","number")
A333DR_annun_landing_gear_right_unlk = create_dataref("laminar/A333/annun/landing_gear/right_unlk","number")
A333DR_annun_oxygen_crew_supply_off = create_dataref("laminar/A333/annun/oxygen/crew_supply_off","number")
A333DR_annun_oxygen_tmr_reset_on = create_dataref("laminar/A333/annun/oxygen/tmr_reset_on","number")
A333DR_annun_oxygen_tmr_reset_fault = create_dataref("laminar/A333/annun/oxygen/tmr_reset_fault","number")
A333DR_annun_gpws_terr_off = create_dataref("laminar/A333/annun/gpws/terr_off","number")
A333DR_annun_gpws_terr_fault = create_dataref("laminar/A333/annun/gpws_terr_fault","number")
A333DR_annun_evac_command_on = create_dataref("laminar/A333/annun/evac/command_on","number")
A333DR_annun_evac_command_evac = create_dataref("laminar/A333/annun/evac/command_evac","number")
A333DR_annun_calls_emer_call = create_dataref("laminar/A333/annun/calls/emer_call","number")
A333DR_annun_calls_emer_on = create_dataref("laminar/A333/annun/calls/emer_on","number")
A333DR_annun_ditching_on = create_dataref("laminar/A333/annun/ditching_on","number")
A333DR_annun_hyd_elec_blue_pump_fault = create_dataref("laminar/A333/annun/hyd/elec_blue_fault","number")
A333DR_annun_hyd_elec_blue_pump_off = create_dataref("laminar/A333/annun/hyd/elec_blue_off","number")
A333DR_annun_hyd_elec_blue_pump_on = create_dataref("laminar/A333/annun/hyd/elec_blue_on","number")
A333DR_annun_hyd_eng1_blue_pump_fault = create_dataref("laminar/A333/annun/hyd/eng1_blue_fault","number")
A333DR_annun_hyd_eng1_blue_pump_off = create_dataref("laminar/A333/annun/hyd/eng1_blue_off","number")
A333DR_annun_elec_bus_tie_off = create_dataref("laminar/A333/annun/elec/bus_tie_off","number")
A333DR_annun_elec_gen1_off_reset = create_dataref("laminar/A333/annun/elec/gen1_off_reset","number")
A333DR_annun_elec_gen2_off_reset = create_dataref("laminar/A333/annun/elec/gen2_off_reset","number")
A333DR_annun_elec_idg1_off = create_dataref("laminar/A333/annun/elec/idg1_off","number")
A333DR_annun_elec_idg2_off = create_dataref("laminar/A333/annun/elec/idg2_off","number")
A333DR_annun_elec_galley_off = create_dataref("laminar/A333/annun/elec/galley_off","number")
A333DR_annun_elec_galley_fault = create_dataref("laminar/A333/annun/elec/galley_fault","number")
A333DR_annun_autopilot_a_thr_mode = create_dataref("laminar/A333/annun/autopilot/a_thr_mode","number")
A333DR_annun_autopilot_alt_mode = create_dataref("laminar/A333/annun/autopilot/alt_mode","number")
A333DR_annun_autopilot_ap1_mode = create_dataref("laminar/A333/annun/autopilot/ap1_mode","number")
A333DR_annun_autopilot_ap2_mode = create_dataref("laminar/A333/annun/autopilot/ap2_mode","number")
A333DR_annun_autopilot_appr_mode = create_dataref("laminar/A333/annun/autopilot/appr_mode","number")
A333DR_annun_autopilot_loc_mode = create_dataref("laminar/A333/annun/autopilot/loc_mode","number")
A333DR_annun_apu_bleed_on = create_dataref("laminar/A333/annun/apu_bleed_on","number")
A333DR_annun_apu_bleed_fault = create_dataref("laminar/A333/annun/apu_bleed_fault","number")
A333DR_annun_ram_air_on	= create_dataref("laminar/A333/annun/ram_air_on","number")
A333DR_annun_fuel_pump_L1_fault = create_dataref("laminar/A333/annun/fuel/L1_fault","number")
A333DR_annun_fuel_pump_L1_off = create_dataref("laminar/A333/annun/fuel/L1_off","number")
A333DR_annun_fuel_pump_R1_fault = create_dataref("laminar/A333/annun/fuel/R1_fault","number")
A333DR_annun_fuel_pump_R1_off = create_dataref("laminar/A333/annun/fuel/R1_off","number")
A333DR_annun_fuel_wing_x_feed_on = create_dataref("laminar/A333/annun/fuel/wing_x_feed_on","number")
A333DR_annun_fuel_wing_x_feed_open = create_dataref("laminar/A333/annun/fuel/wing_x_feed_open","number")
A333DR_annun_fuel_t_tank_mode_fault	= create_dataref("laminar/A333/annun/fuel/t_tank_mode_fault","number")
A333DR_annun_fuel_t_tank_mode_fwd = create_dataref("laminar/A333/annun/fuel/t_tank_mode_fwd","number")
A333DR_annun_true_north = create_dataref("laminar/A333/annun/north_ref", "number")
A333DR_annun_elec_emer_gen_fault = create_dataref("laminar/A333/annun/elec/emer_gen_fault", "number")
A333DR_annun_air_ovht_cnd_fans_reset_fault = create_dataref("laminar/A333/annun/cond/air_ovht_fans_reset_fault", "number")
A333DR_annun_pax_satcom_off = create_dataref("laminar/A333/annun/pax/satcom_off","number")
A333DR_annun_pax_system_off = create_dataref("laminar/A333/annun/pax/system_off","number")

-- AC ESS or AC ESS SHED
A333DR_annun_elec_apu_gen_off_R = create_dataref("laminar/A333/annun/elec/apu_gen_off_reset","number")
A333DR_annun_engine1_fire = create_dataref("laminar/A333/annun/engine1_fire", "number")
A333DR_annun_engine2_fire = create_dataref("laminar/A333/annun/engine2_fire", "number")
A333DR_annun_engine1_starter_fault = create_dataref("laminar/A333/annun/engine1_starter_fault", "number")
A333DR_annun_engine2_starter_fault = create_dataref("laminar/A333/annun/engine2_starter_fault", "number")
A333DR_annun_ventilation_extract_ovrd = create_dataref("laminar/A333/annun/ventilation/extract_ovrd","number")
A333DR_annun_ventilation_extract_fault = create_dataref("laminar/A333/annun/ventilation_extract_fault","number")
A333DR_annun_elec_bat1_fault = create_dataref("laminar/A333/annun/elec/bat1_fault","number")
A333DR_annun_elec_bat2_fault = create_dataref("laminar/A333/annun/elec/bat2_fault","number")
A333DR_annun_elec_apu_bat_fault = create_dataref("laminar/A333/annun/elec/apu_bat_fault","number")
A333DR_annun_elec_gen1_fault = create_dataref("laminar/A333/annun/elec/gen1_fault","number")
A333DR_annun_elec_gen2_fault = create_dataref("laminar/A333/annun/elec/gen2_fault","number")
A333DR_annun_elec_idg1_fault = create_dataref("laminar/A333/annun/elec/idg1_fault","number")
A333DR_annun_elec_idg2_fault = create_dataref("laminar/A333/annun/elec/idg2_fault","number")
A333DR_annun_elec_ext_a_avail = create_dataref("laminar/A333/annun/elec/ext_a_avail","number")
A333DR_annun_elec_ext_b_avail = create_dataref("laminar/A333/annun/elec/ext_b_avail","number")
A333DR_annun_elec_commercial_off = create_dataref("laminar/A333/annun/elec/commercial_off","number")
A333DR_annun_pack1_fault = create_dataref("laminar/A333/annun/pack1_fault","number")
A333DR_annun_pack1_off = create_dataref("laminar/A333/annun/pack1_off","number")
A333DR_annun_ventilation_avionics_smoke = create_dataref("laminar/A333/annun/ventilation/avionics_smoke","number")
A333DR_annun_fire_apu_disch = create_dataref("laminar/A333/annun/fire/apu_disch","number")
A333DR_annun_fire_apu_squib = create_dataref("laminar/A333/annun/fire/apu_squib","number")
A333DR_annun_fire_eng1_agent1_disch = create_dataref("laminar/A333/annun/fire/eng1_agent1_disch","number")
A333DR_annun_fire_eng1_agent1_squib = create_dataref("laminar/A333/annun/fire/eng1_agent1_squib","number")
A333DR_annun_fire_eng1_agent2_disch = create_dataref("laminar/A333/annun/fire/eng1_agent2_disch","number")
A333DR_annun_fire_eng1_agent2_squib = create_dataref("laminar/A333/annun/fire/eng1_agent2_squib","number")
A333DR_annun_fire_eng2_agent1_disch = create_dataref("laminar/A333/annun/fire/eng2_agent1_disch","number")
A333DR_annun_fire_eng2_agent1_squib = create_dataref("laminar/A333/annun/fire/eng2_agent1_squib","number")
A333DR_annun_fire_eng2_agent2_disch = create_dataref("laminar/A333/annun/fire/eng2_agent2_disch","number")
A333DR_annun_fire_eng2_agent2_squib = create_dataref("laminar/A333/annun/fire/eng2_agent2_squib","number")
A333DR_annun_rtp_L_offside_tuning = create_dataref("laminar/A333/annun/comm/rtp_L/offside_tuning_active","number")
A333DR_annun_rtp_L_vhf_1 = create_dataref("laminar/A333/annun/comm/rtp_L/vhf_1_active","number")
A333DR_annun_rtp_L_vhf_2 = create_dataref("laminar/A333/annun/comm/rtp_L/vhf_2_active","number")
A333DR_annun_rtp_L_vhf_3 = create_dataref("laminar/A333/annun/comm/rtp_L/vhf_3_active","number")
A333DR_annun_rtp_L_hf_1 = create_dataref("laminar/A333/annun/comm/rtp_L/hf_1_active","number")
A333DR_annun_rtp_L_hf_2 = create_dataref("laminar/A333/annun/comm/rtp_L/am_active","number")
A333DR_annun_rtp_L_am = create_dataref("laminar/A333/annun/comm/rtp_L/hf_2_active","number")
A333DR_annun_rtp_L_no_op = create_dataref("laminar/A333/annun/comm/rtp_L/no_op","number")
A333DR_audio_panel_capt_mic1_annun = create_dataref("laminar/A333/audio/capt/mic_annun1", "number")
A333DR_audio_panel_capt_mic2_annun = create_dataref("laminar/A333/audio/capt/mic_annun2", "number")
A333DR_audio_panel_capt_mic3_annun = create_dataref("laminar/A333/audio/capt/mic_annun3", "number")
A333DR_audio_panel_capt_mic4_annun = create_dataref("laminar/A333/audio/capt/mic_annun4", "number")
A333DR_audio_panel_capt_mic5_annun = create_dataref("laminar/A333/audio/capt/mic_annun5", "number")
A333DR_audio_panel_capt_mic6_annun = create_dataref("laminar/A333/audio/capt/mic_annun6", "number")
A333DR_audio_panel_capt_mic7_annun = create_dataref("laminar/A333/audio/capt/mic_annun7", "number")
A333DR_audio_panel_capt_mic8_annun = create_dataref("laminar/A333/audio/capt/mic_annun8", "number")
A333DR_audio_panel_capt_mic9_annun = create_dataref("laminar/A333/audio/capt/mic_annun9", "number")
A333DR_audio_panel_capt_mic10_annun = create_dataref("laminar/A333/audio/capt/mic_annun10", "number")
A333DR_audio_panel_capt_voice_annun = create_dataref("laminar/A333/audio/capt_voice_annun", "number")
A333DR_audio_panel_capt_call_light_vhf1 = create_dataref("laminar/A333/audio/capt_call_light_vhf1", "number")
A333DR_audio_panel_capt_call_light_vhf2 = create_dataref("laminar/A333/audio/capt_call_light_vhf2", "number")
A333DR_audio_panel_capt_call_light_att = create_dataref("laminar/A333/audio/capt_call_light_att", "number")
A333DR_audio_panel_capt_call_light_gen = create_dataref("laminar/A333/audio/capt_call_light_gen", "number")
A333DR_audio_panel_capt_listen_annun = create_dataref("laminar/A333/audio/capt_listening_annun", "array[" .. tostring(NUM_CAPT_LISTENING_LIGHTS) .. "]")
A333DR_annun_flt_ctl_sec1_fault = create_dataref("laminar/A333/annun/flt_ctl/sec1_fault","number")
A333DR_annun_flt_ctl_prim1_fault = create_dataref("laminar/A333/annun/flt_ctl/prim1_fault","number")
A333DR_annun_press_mode_sel_man = create_dataref("laminar/A333/annun/press/mode_sel_man","number")
A333DR_annun_press_mode_sel_fault = create_dataref("laminar/A333/annun/press/mode_sel_fault","number")
A333DR_annun_eng1_man_start_on = create_dataref("laminar/A333/annun/pplt/eng1_man_start_on","number")
A333DR_annun_eng2_man_start_on = create_dataref("laminar/A333/annun/pplt/eng2_man_start_on","number")
A333DR_annun_eng1_n1_mode_on = create_dataref("laminar/A333/annun/pplt/eng1_n1_mode_on","number")
A333DR_annun_eng2_n1_mode_on = create_dataref("laminar/A333/annun/pplt/eng2_n1_mode_on","number")

-- DC BAT
A333DR_annun_elec_bat1_off = create_dataref("laminar/A333/annun/elec/bat1_off","number")
A333DR_annun_elec_bat2_off = create_dataref("laminar/A333/annun/elec/bat2_off","number")
A333DR_annun_elec_apu_bat_off = create_dataref("laminar/A333/annun/elec/apu_bat_off","number")



A333_non_specified_annun = create_dataref("laminar/A333/annun/inactive_unspecified", "number")
A333_non_specified_annun2 = create_dataref("laminar/A333/annun/inactive_unspecified2", "number")


-- UNKOWN TODO







A333DR_init_annun_CD = create_dataref("laminar/A333/init_CD/annun", "number")


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
local function A333_annun_data_cache_globals()

    lcl_SIM_PERIOD = SIM_PERIOD

end




function animate(current_value, target, speed)

    local fps_factor = m.min(1.0, speed * SIM_PERIOD)
    local delta = m.abs(current_value - target)

    if delta < 0.000001 then
        return target
    else
        return current_value + ((target - current_value) * fps_factor)
    end

end




local function A333_annun_set_sim_brightness_switches()

    local annun_light_switch_pos = A333DR_ann_light_switch_pos
    local brightness_ratio_switch_15_target = (annun_light_switch_pos == 0 and 0.0075) or 1
    local brightness_ratio_switch_16_target = (annun_light_switch_pos == 0 and 0.02) or 1
    local animate = animate

    simDR_inst_brightness_switch_ratio_15 = animate(simDR_inst_brightness_switch_ratio_15, brightness_ratio_switch_15_target, 13)
    simDR_inst_brightness_switch_ratio_16 = animate(simDR_inst_brightness_switch_ratio_16, brightness_ratio_switch_16_target, 13)

end




local function A333_set_annun_brightness_datarefs()

    local sim_inst_brightness_ratio_15 = simDR_inst_brightness_ratio_15
    local sim_inst_brightness_ratio_16 = simDR_inst_brightness_ratio_16

    local extA_grd_srvc_bus_has_power = A333DR_extA_ground_service_bus_has_power
    local ac_bus1_has_power = A333DR_ac_bus1_has_power
    local ac_bus2_has_power = A333DR_ac_bus2_has_power
    local ac_ess_bus_has_power = A333DR_ac_ess_bus_has_power
    local ac_ess_shed_bus_has_power = A333DR_ac_ess_shed_bus_has_power
    local ac_ess_grnd_bus_has_power = A333DR_ac_ess_grnd_bus_has_power
    local ac_ess_land_rcvry_bus_has_power = A333DR_ac_land_rcvry_bus_has_power
    local dc_bat_bus_power = A333DR_dc_bat_bus_has_power
    local dc_apu_bat_hot_bus_power = A333DR_dc_apu_bat_hot_bus_has_power

    A333DR_annun_brightness_exta_grd_srvc = simDR_inst_brightness_switch_ratio_15 * extA_grd_srvc_bus_has_power
    A333DR_annun_brightness_ac1 = sim_inst_brightness_ratio_15 * ac_bus1_has_power                                  -- 1XP/101XP (AC1)
    A333DR_annun_brightness_ac1_2 = sim_inst_brightness_ratio_16 * ac_bus1_has_power
    A333DR_annun_brightness_ac2 = sim_inst_brightness_ratio_15 * ac_bus2_has_power                                  -- 2XP/202XP (AC2)
    A333DR_annun_brightness_ac2_2 = sim_inst_brightness_ratio_16 * ac_bus2_has_power
    A333DR_annun_brightness_ac_ess = sim_inst_brightness_ratio_15 * ac_ess_bus_has_power                            -- 9XP/901XP (AC ESS)
    A333DR_annun_brightness_ac_ess_2 = sim_inst_brightness_ratio_16 * ac_ess_bus_has_power
    A333DR_annun_brightness_ac_ess_shed = sim_inst_brightness_ratio_15 * ac_ess_shed_bus_has_power                  -- 401XP (AC ESS SHED)
    A333DR_annun_brightness_ac_ess_shed_2 = sim_inst_brightness_ratio_16 * ac_ess_shed_bus_has_power
    A333DR_annun_brightness_ac_ess_grnd = sim_inst_brightness_ratio_15 * ac_ess_grnd_bus_has_power                  -- 905XP (AC ESS GRND)
    A333DR_annun_brightness_ac_ess_grnd_2 = sim_inst_brightness_ratio_16 * ac_ess_grnd_bus_has_power
    A333DR_annun_brightness_ac_ess_land_rcvry = sim_inst_brightness_ratio_15 * ac_ess_land_rcvry_bus_has_power      -- 903XP (AC ESS LAND RCVRY)
    A333DR_annun_brightness_ac_ess_land_rcvry_2 = sim_inst_brightness_ratio_16 * ac_ess_land_rcvry_bus_has_power
    A333DR_annun_brightness_ac_ess_or_ac_ess_shed = m.max(A333DR_annun_brightness_ac_ess, A333DR_annun_brightness_ac_ess_shed)
    A333DR_annun_brightness_ac_ess_or_ac_ess_shed_2 = m.max(A333DR_annun_brightness_ac_ess_2, A333DR_annun_brightness_ac_ess_shed_2)
    A333DR_annun_brightness_ac1_or_ac_ess_shed = m.max(A333DR_annun_brightness_ac1, A333DR_annun_brightness_ac_ess_shed)
    A333DR_annun_brightness_ac1_or_ac_ess_or_ac_ess_shed = m.max(A333DR_annun_brightness_ac1, A333DR_annun_brightness_ac_ess, A333DR_annun_brightness_ac_ess_shed)
    A333DR_annun_brightness_ac1_or_ac_ess_or_ac_ess_shed_2 = m.max(A333DR_annun_brightness_ac1_2, A333DR_annun_brightness_ac_ess_2, A333DR_annun_brightness_ac_ess_shed_2)
    A333DR_annun_brightness_ac2_or_ac_ess_or_ac_ess_shed = m.max(A333DR_annun_brightness_ac2, A333DR_annun_brightness_ac_ess, A333DR_annun_brightness_ac_ess_shed)
    A333DR_annun_brightness_ac2_or_ac_ess_or_ac_ess_shed_2 = m.max(A333DR_annun_brightness_ac2_2, A333DR_annun_brightness_ac_ess_2, A333DR_annun_brightness_ac_ess_shed_2)
    A333DR_annun_brightness_ac2_or_ac_ess_shed = m.max(A333DR_annun_brightness_ac2, A333DR_annun_brightness_ac_ess_shed)
    A333DR_annun_brightness_ac2_or_ac_ess_shed_2 = m.max(A333DR_annun_brightness_ac2_2, A333DR_annun_brightness_ac_ess_shed_2)
    A333DR_annun_brightness_ac_ess_grnd_or_exta_grd = m.max(A333DR_annun_brightness_ac_ess, A333DR_annun_brightness_exta_grd_srvc)
    A333DR_annun_brightness_ac_ess_or_ac_ess = m.max(A333DR_annun_brightness_ac_ess_grnd, A333DR_annun_brightness_ac_ess)
    A333DR_annun_brightness_dc_bat = sim_inst_brightness_ratio_15 * dc_bat_bus_power
    A333DR_annun_brightness_dc_apu_bat = sim_inst_brightness_ratio_15 * dc_apu_bat_hot_bus_power

end



--*************************************************************************************--
--** 				                     PROCESSING             	    			 **--
--*************************************************************************************--

--===| INIT ALL |========================================================================
function A333_annun_data_init_all()



end




--===| INIT ER |=========================================================================
function A333_annun_data_init_ER()



end




--===| INIT CD |=========================================================================
function A333_annun_data_init_CD()



end




--===| DEFERRED INITIALIZATION |=========================================================
function A333_annun_data_deferred_init()




end



--===| DEFERRED PROCESSING |=============================================================
function A333_annun_data_deferred_processing()



end




--=== AIRCRAFT LOAD =====================================================================
function A333_annun_data_aircraft_load()



end



--=== FLIGHT START ======================================================================
function A333_annun_data_flight_start()



end



--=== BEFORE PHYSICS ====================================================================
function A333_annun_data_before_physics()



end



--=== AFTER PHYSICS =====================================================================
function A333_annun_data_after_physics()

    A333_annun_data_cache_globals()
    A333_annun_set_sim_brightness_switches()
    A333_set_annun_brightness_datarefs()

    A333_non_specified_annun = 1
    A333_non_specified_annun2 = 1

end




--=== FLIGHT CRASH ======================================================================
function A333_annun_data_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_annun_data_aircraft_unload()



end




--=== AIRCRAFT UNLOAD ===================================================================
function A333_annun_data_after_replay()

    A333_annun_data_cache_globals()
    A333_annun_set_sim_brightness_switches()
    A333_set_annun_brightness_datarefs()

    A333_non_specified_annun = 1
    A333_non_specified_annun2 = 1

end



--*************************************************************************************--
--** 				                 SUB-SCRIPT LOADING            	     			 **--
--*************************************************************************************--



