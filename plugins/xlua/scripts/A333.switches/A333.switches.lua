--[[
*****************************************************************************************
* Program Script Name	:	A333.switches
* Author Name			:	Alex Unruh
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2021-03-18	0.01a				Start of Dev
*   2025-07-24  0.02a               Adjusted Cold&Dark State
*
*
*
*****************************************************************************************
*       					 COPYRIGHT © 2021, 2022, 2025
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
local lcl_SIM_PERIOD = 0


--*************************************************************************************--
--** 					               switches_quick_start                    		 **--
--*************************************************************************************--
local NUM_BTN_SW_COVERS = 40
local NUM_GUARD_COVERS = 11

local UNLOCKED = 0
local LOCKED = 1

local NONE = 0
local ROUTINE = 1
local EMERGENCY = 2

local OPEN = 1
local CLOSED = 0



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--

local seq = 0

--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local m = math

local int, frac = m.modf(os.clock())
local seed = m.random(1, frac*1000.0)
m.randomseed(seed)

local bool2num = {[true] = 1, [false] = 0}



local A333_button_switch_cover_position_target = {}
for i = 0, NUM_BTN_SW_COVERS-1 do
	A333_button_switch_cover_position_target[i] = 0
end

local A333_close_button_cover = {}
local A333_button_switch_cover_CMDhandler = {}


local A333_guard_cover_pos_target = {}
for i = 0, NUM_GUARD_COVERS-1 do
	A333_guard_cover_pos_target[i] = 0
end

local park_brake_switch_pos_target = 0

local A333_guard_cover_CMDhandler = {}

local seatbelt_auto_status = 0
local smoking_auto_status = 0

local engine1_starter_cutoff_sentinel = 0
local engine2_starter_cutoff_sentinel = 0
local engine1_starter_lift_flag = 0
local engine2_starter_lift_flag = 0

local A333_rudder_trim_sel_dial_position_target = 0

local window_heat1_target = 75
local window_heat2_target = 75
local window_heat3_target = 75
local window_heat4_target = 75

local AC_ESS_feed_pos = 0
local bus_tie_pos = 0

local left_pump1_pos = 0
local left_pump2_pos = 0
local left_standby_pump_pos = 0

local right_pump1_pos = 0
local right_pump2_pos = 0
local right_standby_pump_pos = 0

local center_left_pump_pos = 0
local center_right_pump_pos = 0

local fuel_wing_crossfeed_pos = 0

local fuel_center_xfr_pos = 0
local fuel_trim_xfr_pos = 0
local fuel_outer_tank_xfr_pos = 0

local RAT_pos = 0

local green_leak_measure_sw_stat = 0
local yellow_leak_measure_sw_stat = 0
local blue_leak_measure_sw_stat = 0

local pax_oxy_reset_pos = 0

local fcc_prim1 = 0
local fcc_prim2 = 0
local fcc_prim3 = 0
local fcc_sec1 = 0
local fcc_sec2 = 0

local pax_sys_pos = 0
local pax_satcom_pos = 0
local pax_IFEC_pos = 0

local cargo_fwd_isol_valve_pos = 0
local cargo_bulk_isol_valve_pos = 0
local cargo_hot_air_pos = 0

local evac_command_pos = 0

local phase1_gate = 0

local terr_on_capt_pos = 0
local terr_on_fo_pos = 0
local true_north_pos = 0

local flight_rcdr_mode_store = 0
local flight_rcdr_mode_timer = 0

local engine_start_1_flag = 0
local engine_start_2_flag = 0

local audio_panel_capt_volume_0_init = 1.0 -- m.random()
local audio_panel_capt_volume_1_init = m.random()
local audio_panel_capt_volume_7_init = m.random()
local audio_panel_capt_volume_8_init = m.random()
local audio_panel_capt_volume_9_init = m.random()
local audio_panel_capt_volume_10_init = m.random()
local audio_panel_capt_volume_11_init = m.random()
local audio_panel_capt_volume_12_init = m.random()

local audio_panel_fo_volume_0_init = m.random()
local audio_panel_fo_volume_1_init = m.random()
local audio_panel_fo_volume_7_init = m.random()
local audio_panel_fo_volume_8_init = m.random()
local audio_panel_fo_volume_9_init = m.random()
local audio_panel_fo_volume_10_init = m.random()
local audio_panel_fo_volume_11_init = m.random()
local audio_panel_fo_volume_12_init = m.random()

local brake_fan_request = 0

local standby_align_flag = 0

local annun_flag = 0
local LE_temp_factor = 0

local GCS_timer_init = 0
local GCS_timer = 0

local capt_baro_mem = 0
local fo_baro_mem = 0

local apu_start_request = 0

local yellow_leak_measurement_open_cargo = 0

local chime_timer = 0

local switch_start_pos = {

	elec_ess_feed = 0,
	elec_bus_tie = 0,
	elec_ext_A = 0,
	elec_batt1 = 0,
	elec_batt2 = 0,
	elec_apu_bat = 0,
	land_rcvry = 0,

    evac_command = 0,

	eng1_bleed = 0,
	eng2_bleed = 0,

	generator1 = 0,
	generator2 = 0,

	apu_master = 0,
	apu_gen = 0,

    emer_gen_man_on = 0,

	hot_air1 = 0,
	hot_air2 = 0,
	ram_air = 0,
	pack1 = 0,
	pack2 = 0,
	apu_bleed = 0,
	
	ir1 = 0,
	ir2 = 0,
	ir3 = 0,
	adr1 = 0,
	adr2 = 0,
	adr3 = 0,
	ir1_knob = 0,
	ir2_knob = 0,
	ir3_knob = 0,

    wing_anti_ice = 0,
}

local cdls = {
    has_power = false,
    was_previously_powered = false,
    keypad_sel_counter = 0,
    keypad_hash_sel_counter = 0,
    access_request_type = NONE,
    emergency_access_inhibited = false,
    buzzer_inhibited = false,
    keypad_inhibited = false,
    set_unlock = true,
    door_was_open = false
}




--*************************************************************************************--
--** 				               X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
simDR_flight_time                   = find_dataref("sim/time/total_flight_time_sec")


simDR_startup_running               = find_dataref("sim/operation/prefs/startup_running")

simDR_gear_on_ground				= find_dataref("sim/flightmodel2/gear/on_ground[1]")

simDR_EFIS_map_mode					= find_dataref("sim/cockpit2/EFIS/map_mode")
simDR_EFIS_map_HSI_mode				= find_dataref("sim/cockpit2/EFIS/map_mode_is_HSI")
simDR_EFIS_map_mode_fo				= find_dataref("sim/cockpit2/EFIS/map_mode_copilot")
simDR_EFIS_map_HSI_mode_fo			= find_dataref("sim/cockpit2/EFIS/map_mode_is_HSI_copilot")

simDR_EFIS_airport_on_capt			= find_dataref("sim/cockpit2/EFIS/EFIS_airport_on")
simDR_EFIS_fix_on_capt				= find_dataref("sim/cockpit2/EFIS/EFIS_fix_on")
simDR_EFIS_vor_on_capt				= find_dataref("sim/cockpit2/EFIS/EFIS_vor_on")
simDR_EFIS_ndb_on_capt				= find_dataref("sim/cockpit2/EFIS/EFIS_ndb_on")
simDR_EFIS_cstr_on_capt				= find_dataref("sim/cockpit2/EFIS/EFIS_data_on")

simDR_EFIS_airport_on_fo			= find_dataref("sim/cockpit2/EFIS/EFIS_airport_on_copilot")
simDR_EFIS_fix_on_fo				= find_dataref("sim/cockpit2/EFIS/EFIS_fix_on_copilot")
simDR_EFIS_vor_on_fo				= find_dataref("sim/cockpit2/EFIS/EFIS_vor_on_copilot")
simDR_EFIS_ndb_on_fo				= find_dataref("sim/cockpit2/EFIS/EFIS_ndb_on_copilot")
simDR_EFIS_cstr_on_fo				= find_dataref("sim/cockpit2/EFIS/EFIS_data_on_copilot")

simDR_EFIS_tcas_on_capt				= find_dataref("sim/cockpit2/EFIS/EFIS_tcas_on")
simDR_EFIS_tcas_on_fo				= find_dataref("sim/cockpit2/EFIS/EFIS_tcas_on_copilot")

simDR_transponder_modes				= find_dataref("sim/cockpit2/radios/actuators/transponder_mode")

simDR_EFIS_map_range_capt			= find_dataref("sim/cockpit2/EFIS/map_range_nm")
simDR_EFIS_map_range_fo				= find_dataref("sim/cockpit2/EFIS/map_range_nm_copilot")

simDR_terr_on_nd_capt				= find_dataref("sim/cockpit2/EFIS/EFIS_terrain_on")
simDR_terr_on_nd_fo					= find_dataref("sim/cockpit2/EFIS/EFIS_terrain_on_copilot")

simDR_tru_north_capt				= find_dataref("sim/cockpit2/EFIS/true_north")
simDR_tru_north_fo					= find_dataref("sim/cockpit2/EFIS/true_north_copilot")

simDR_weather_on_capt				= find_dataref("sim/cockpit2/EFIS/EFIS_weather_on")
simDR_weather_on_fo					= find_dataref("sim/cockpit2/EFIS/EFIS_weather_on_copilot")
simDR_weather_mode_capt				= find_dataref("sim/cockpit2/EFIS/EFIS_weather_mode")
simDR_weather_mode_fo				= find_dataref("sim/cockpit2/EFIS/EFIS_weather_mode_copilot")

simDR_weather_gain_capt				= find_dataref("sim/cockpit2/EFIS/EFIS_weather_gain")
simDR_weather_gain_fo				= find_dataref("sim/cockpit2/EFIS/EFIS_weather_gain_copilot")

simDR_weather_gcs_capt				= find_dataref("sim/cockpit2/EFIS/EFIS_weather_gcs")
simDR_weather_gcs_fo				= find_dataref("sim/cockpit2/EFIS/EFIS_weather_gcs_copilot")

simDR_weather_pws_capt				= find_dataref("sim/cockpit2/EFIS/EFIS_weather_pws")
simDR_weather_windshear_warn		= find_dataref("sim/cockpit2/annunciators/windshear_warning_systems")

simDR_weather_multiscan_capt		= find_dataref("sim/cockpit2/EFIS/EFIS_weather_multiscan")
simDR_weather_multiscan_fo			= find_dataref("sim/cockpit2/EFIS/EFIS_weather_multiscan_copilot")

simDR_weather_sector_brg			= find_dataref("sim/cockpit2/EFIS/EFIS_weather_sector_brg")
simDR_weather_sector_width			= find_dataref("sim/cockpit2/EFIS/EFIS_weather_sector_width")
simDR_weather_antenna_limit			= find_dataref("sim/cockpit2/EFIS/EFIS_weather_antenna_limit")
simDR_weather_sweeps_sec			= find_dataref("sim/cockpit2/EFIS/EFIS_weather_sweeps_per_sec")

simDR_seatbelt_signs				= find_dataref("sim/cockpit2/switches/fasten_seat_belts")
simDR_smoking_signs					= find_dataref("sim/cockpit2/switches/no_smoking")

simDR_flaps_status					= find_dataref("sim/cockpit2/controls/flap_system_deploy_ratio")

simDR_gear_status1					= find_dataref("sim/flightmodel2/gear/deploy_ratio[0]")
simDR_gear_status2					= find_dataref("sim/flightmodel2/gear/deploy_ratio[1]")
simDR_gear_status3					= find_dataref("sim/flightmodel2/gear/deploy_ratio[2]")

simDR_apu_switch					= find_dataref("sim/cockpit2/electrical/APU_starter_switch")

simDR_engine1_running				= find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[0]")
simDR_engine2_running				= find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[1]")

simDR_eng1_fuel_pump_tog			= find_dataref("sim/cockpit2/engine/actuators/fuel_pump_on[0]")
simDR_eng2_fuel_pump_tog			= find_dataref("sim/cockpit2/engine/actuators/fuel_pump_on[1]")

simDR_idle_mode						= find_dataref("sim/cockpit2/engine/actuators/idle_speed")
simDR_eng_N2						= find_dataref("sim/flightmodel2/engines/N2_percent")

simDR_window_heat1					= find_dataref("sim/cockpit2/ice/ice_window_heat_on_window[0]")
simDR_window_heat2					= find_dataref("sim/cockpit2/ice/ice_window_heat_on_window[1]")
simDR_window_heat3					= find_dataref("sim/cockpit2/ice/ice_window_heat_on_window[2]")
simDR_window_heat4					= find_dataref("sim/cockpit2/ice/ice_window_heat_on_window[3]")

simDR_window_heat_on1				= find_dataref("sim/cockpit2/ice/ice_window_heat_running[0]")
simDR_window_heat_on2				= find_dataref("sim/cockpit2/ice/ice_window_heat_running[1]")
simDR_window_heat_on3				= find_dataref("sim/cockpit2/ice/ice_window_heat_running[2]")
simDR_window_heat_on4				= find_dataref("sim/cockpit2/ice/ice_window_heat_running[3]")

simDR_pitot_heat_pilot				= find_dataref("sim/cockpit2/ice/ice_pitot_heat_on_pilot")
simDR_pitot_heat_copilot			= find_dataref("sim/cockpit2/ice/ice_pitot_heat_on_copilot")
simDR_pitot_heat_stby				= find_dataref("sim/cockpit2/ice/ice_pitot_heat_on_standby")
simDR_AOA_heat_pilot				= find_dataref("sim/cockpit2/ice/ice_AOA_heat_on")
simDR_AOA_heat_copilot				= find_dataref("sim/cockpit2/ice/ice_AOA_heat_on_copilot")
simDR_AOA_heat_stby					= find_dataref("sim/cockpit2/ice/ice_AOA_heat_on_stby")
simDR_TAT_heat_pilot				= find_dataref("sim/cockpit2/ice/ice_TAT_heat_on")
simDR_TAT_heat_copilot				= find_dataref("sim/cockpit2/ice/ice_TAT_heat_on_copilot")
simDR_TAT_heat_stby					= find_dataref("sim/cockpit2/ice/ice_TAT_heat_on_stby")
simDR_static_heat_pilot				= find_dataref("sim/cockpit2/ice/ice_static_heat_on_pilot")
simDR_static_heat_copilot			= find_dataref("sim/cockpit2/ice/ice_static_heat_on_copilot")
simDR_static_heat_standby			= find_dataref("sim/cockpit2/ice/ice_static_heat_on_standby")
simDR_ice_detect					= find_dataref("sim/cockpit2/ice/ice_detect_on")

simDR_wing_heat_left				= find_dataref("sim/cockpit2/ice/ice_surface_hot_bleed_air_left_on")
simDR_wing_heat_right				= find_dataref("sim/cockpit2/ice/ice_surface_hot_bleed_air_right_on")
simDR_engine1_heat					= find_dataref("sim/cockpit2/ice/cowling_thermal_anti_ice_per_engine[0]")
simDR_engine2_heat					= find_dataref("sim/cockpit2/ice/cowling_thermal_anti_ice_per_engine[1]")

simDR_battery1						= find_dataref("sim/cockpit2/electrical/battery_on[0]")
simDR_battery2						= find_dataref("sim/cockpit2/electrical/battery_on[1]")
simDR_apu_batt_volts				= find_dataref("sim/cockpit2/electrical/battery_voltage_actual_volts[5]")

simDR_gen1_amps						= find_dataref("sim/cockpit2/electrical/generator_amps[0]")
simDR_gen2_amps						= find_dataref("sim/cockpit2/electrical/generator_amps[1]")
simDR_apu_gen_amps					= find_dataref("sim/cockpit2/electrical/APU_generator_amps")

simDR_generator1					= find_dataref("sim/cockpit2/electrical/generator_on[0]")
simDR_generator2					= find_dataref("sim/cockpit2/electrical/generator_on[1]")
simDR_APU_generator					= find_dataref("sim/cockpit2/electrical/APU_generator_on")
simDR_APU_running					= find_dataref("sim/cockpit2/electrical/APU_running")


--simDR_gpu_volts					= find_dataref("sim/cockpit2/electrical/GPU_generator_volts")

simDR_ext_power_a_on				= find_dataref("sim/cockpit2/electrical/GPU_generator_on")

simDR_eng1_bleed_sov				= find_dataref("sim/cockpit2/bleedair/actuators/engine_bleed_sov[0]")
simDR_eng2_bleed_sov				= find_dataref("sim/cockpit2/bleedair/actuators/engine_bleed_sov[1]")
simDR_apu_bleed						= find_dataref("sim/cockpit2/bleedair/actuators/apu_bleed")
simDR_apu_N1						= find_dataref("sim/cockpit2/electrical/APU_N1_percent")
simDR_pack1							= find_dataref("sim/cockpit2/bleedair/actuators/pack_left")
simDR_pack2							= find_dataref("sim/cockpit2/bleedair/actuators/pack_right")
simDR_isol_valve_right				= find_dataref("sim/cockpit2/bleedair/actuators/isol_valve_right")

simDR_engine1_starter_running		= find_dataref("sim/flightmodel2/engines/starter_is_running[0]")
simDR_engine2_starter_running		= find_dataref("sim/flightmodel2/engines/starter_is_running[1]")

simDR_engine1_fire					= find_dataref("sim/cockpit2/annunciators/engine_fires[0]")
simDR_engine2_fire					= find_dataref("sim/cockpit2/annunciators/engine_fires[1]")
simDR_auto_brake					= find_dataref("sim/cockpit2/switches/auto_brake_level")
simDR_auto_brake_decel_low			= find_dataref("sim/aircraft/specialcontrols/acf_autofbrk_decels[1]")
simDR_auto_brake_decel_med			= find_dataref("sim/aircraft/specialcontrols/acf_autofbrk_decels[2]")
simDR_auto_brake_decel_max			= find_dataref("sim/aircraft/specialcontrols/acf_autofbrk_decels[3]")
simDR_brake_fan						= find_dataref("sim/cockpit2/controls/brake_fan_on")

simDR_engine1_hyd_green				= find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpA[0]")
simDR_engine1_hyd_yellow			= find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpB[0]") -- doesn't exist, but needs to be set to 0
simDR_engine1_hyd_blue				= find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpC[0]")

simDR_engine2_hyd_green				= find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpA[1]")
simDR_engine2_hyd_yellow			= find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpB[1]")
simDR_engine2_hyd_blue				= find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpC[1]") -- doesn't exist, but needs to be set to 0

simDR_elec_hyd_green				= find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump_on")
simDR_elec_hyd_yellow				= find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump3_on")
simDR_elec_hyd_blue					= find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump2_on")
simDR_yellow_hydraulic_pressure		= find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_2")

simDR_equiv_airspeed				= find_dataref("sim/flightmodel/position/equivalent_airspeed")

simDR_ram_air_turbine				= find_dataref("sim/cockpit2/hydraulics/actuators/ram_air_turbine_on")
simDR_crew_oxy						= find_dataref("sim/cockpit2/oxygen/actuators/o2_valve_on")
simDR_pax_oxy_fail					= find_dataref("sim/operation/failures/rel_pass_o2_on")

simDR_ahars1_fail_state				= find_dataref("sim/operation/failures/rel_g_arthorz")
simDR_ahars2_fail_state				= find_dataref("sim/operation/failures/rel_g_arthorz_2")
simDR_adc1_fail_state				= find_dataref("sim/operation/failures/rel_adc_comp")
simDR_adc2_fail_state				= find_dataref("sim/operation/failures/rel_adc_comp_2")

simDR_cabin_fan_mode				= find_dataref("sim/cockpit2/pressurization/actuators/fan_setting")
simDR_cabin_alt_alert				= find_dataref("sim/cockpit2/annunciators/cabin_altitude_12500")

simDR_yaw_damper					= find_dataref("sim/cockpit2/switches/yaw_damper_on")

simDR_door_open 				    = find_dataref("sim/cockpit2/switches/door_open")
simDR_door_open_ratio               = find_dataref("sim/flightmodel2/misc/door_open_ratio") -- cargo doors are 8 and 9

simDR_capt_wiper					= find_dataref("sim/cockpit2/switches/wiper_speed_switch[0]")
simDR_fo_wiper						= find_dataref("sim/cockpit2/switches/wiper_speed_switch[1]")

simDR_fd_command_bars_capt			= find_dataref("sim/cockpit2/autopilot/flight_director_command_bars_pilot")
simDR_fd_command_bars_fo			= find_dataref("sim/cockpit2/autopilot/flight_director_command_bars_copilot")

-- BAROMETER
simDR_captain_barometer				= find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_pilot")
simDR_first_officer_barometer		= find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_copilot")
simDR_captain_baro_is_std			= find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_is_std_pilot")
simDR_first_officer_baro_is_std		= find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_is_std_copilot")
simDR_standby_barometer				= find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_in_hg_stby")

-- AUDIO VOLUME
simDR_capt_com1_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_com1")
simDR_capt_com2_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_com2")
simDR_capt_LS_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav1")
simDR_capt_nav1_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav3")
simDR_capt_nav2_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav4")
simDR_capt_adf1_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_adf1")
simDR_capt_adf2_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_adf2")
simDR_capt_marker_volume			= find_dataref("sim/cockpit2/radios/actuators/audio_volume_mark")

simDR_fo_com1_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_com1_copilot")
simDR_fo_com2_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_com2_copilot")
simDR_fo_LS_volume					= find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav2_copilot")
simDR_fo_nav1_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav3_copilot")
simDR_fo_nav2_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav4_copilot")
simDR_fo_adf1_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_adf1_copilot")
simDR_fo_adf2_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_adf2_copilot")
simDR_fo_marker_volume				= find_dataref("sim/cockpit2/radios/actuators/audio_volume_mark_copilot")

-- LIGHTING LEVELS
simDR_instrument_brightness			= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio")
simDR_generic_brightness			= find_dataref("sim/cockpit2/switches/generic_lights_switch")
simDR_landing_light_brightness		= find_dataref("sim/cockpit2/switches/landing_lights_switch")

simDR_fail_bus0						= find_dataref("sim/operation/failures/rel_bus0_other_bus")
simDR_fail_bus1						= find_dataref("sim/operation/failures/rel_bus1_other_bus")
simDR_fail_elec1					= find_dataref("sim/operation/failures/rel_esys")
simDR_fail_elec2					= find_dataref("sim/operation/failures/rel_esys2")
simDR_fail_apu						= find_dataref("sim/operation/failures/rel_apu")

simDR_sun_pitch						= find_dataref("sim/graphics/scenery/sun_pitch_degrees")

simDR_temp_LE						= find_dataref("sim/cockpit2/temperature/outside_air_LE_temp_degc")

simDR_pressure_altitude				= find_dataref("sim/flightmodel2/position/pressure_altitude")
simDR_vvi_pilot						=  find_dataref("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")

simDR_elec_cross_tie 				= find_dataref("sim/cockpit2/electrical/cross_tie")

simDR_standby_horizon_roll			= find_dataref("sim/cockpit2/gauges/indicators/roll_electric_deg_pilot")
simDR_standby_horizon_pitch_accel	= find_dataref("sim/flightmodel/position/Q_dot")
simDR_standby_horizon_vel_accel		= find_dataref("sim/flightmodel2/misc/gforce_axil")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--
A333DR_audio_panel_capt_volume_0	= find_dataref("laminar/A333/audio/capt/volume_pos_0")
A333DR_audio_panel_capt_volume_1	= find_dataref("laminar/A333/audio/capt/volume_pos_1")
A333DR_audio_panel_capt_volume_7	= find_dataref("laminar/A333/audio/capt/volume_pos_7")
A333DR_audio_panel_capt_volume_8	= find_dataref("laminar/A333/audio/capt/volume_pos_8")
A333DR_audio_panel_capt_volume_9	= find_dataref("laminar/A333/audio/capt/volume_pos_9")
A333DR_audio_panel_capt_volume_10	= find_dataref("laminar/A333/audio/capt/volume_pos_10")
A333DR_audio_panel_capt_volume_11	= find_dataref("laminar/A333/audio/capt/volume_pos_11")
A333DR_audio_panel_capt_volume_12	= find_dataref("laminar/A333/audio/capt/volume_pos_12")

A333DR_audio_panel_fo_volume_0		= find_dataref("laminar/A333/audio/fo/volume_pos_0")
A333DR_audio_panel_fo_volume_1		= find_dataref("laminar/A333/audio/fo/volume_pos_1")
A333DR_audio_panel_fo_volume_7		= find_dataref("laminar/A333/audio/fo/volume_pos_7")
A333DR_audio_panel_fo_volume_8		= find_dataref("laminar/A333/audio/fo/volume_pos_8")
A333DR_audio_panel_fo_volume_9		= find_dataref("laminar/A333/audio/fo/volume_pos_9")
A333DR_audio_panel_fo_volume_10		= find_dataref("laminar/A333/audio/fo/volume_pos_10")
A333DR_audio_panel_fo_volume_11		= find_dataref("laminar/A333/audio/fo/volume_pos_11")
A333DR_audio_panel_fo_volume_12		= find_dataref("laminar/A333/audio/fo/volume_pos_12")

A333DR_audio_panel_capt_voice_status	= find_dataref("laminar/A333/audio/capt_voice_status")
A333DR_audio_panel_fo_voice_status		= find_dataref("laminar/A333/audio/fo_voice_status")

A333DR_forward_flood_rheo			= find_dataref("laminar/a333/rheostats/flood_brightness")

A333DR_emer_exit_lt_switch_pos		= find_dataref("laminar/a333/switches/emer_exit_lt_pos")
A333DR_strobe_switch_pos			= find_dataref("laminar/a333/switches/strobe_pos")
A333DR_nav_light_switch_pos			= find_dataref("laminar/a333/switches/nav_pos")

A333DR_eng_mode_selector_pos		= find_dataref("sim/cockpit2/engine/actuators/eng_mode_selector")

A333_ann_light_switch_pos			= find_dataref("laminar/a333/switches/ann_light_pos")

A333_eng1_fire_handle_pos			= find_dataref("laminar/A333/fire/switches/eng1_handle")
A333_eng2_fire_handle_pos			= find_dataref("laminar/A333/fire/switches/eng2_handle")
A333_apu_fire_handle_pos			= find_dataref("laminar/A333/fire/switches/apu_handle")

-- FLIGHT PHASE
A333_flight_phase 					= find_dataref("laminar/A333/data/flight_phase")
A333_rad_alt						= find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")

A333_adirs_ir_align_fast_mode_override 	= find_dataref("laminar/A333/adirs/align_mode_override")

A333DR_dc_min_volts 				= find_dataref("laminar/A333/elec/dc_min_volts")

A333_MCDU1_bright_setting			= find_dataref("laminar/a333/MCDU1/bright_setting")
A333_MCDU2_bright_setting			= find_dataref("laminar/a333/MCDU2/bright_setting")
A333_MCDU3_bright_setting			= find_dataref("laminar/a333/MCDU3/bright_setting")

A333DR_dc_bat_bus_volts 			= find_dataref("laminar/A333/elec/dc_bat_bus_volts")

A333DR_yellow_trigger_cargo			= find_dataref("laminar/A333/hyd/yellow_elec_cargo_trigger")

A333DR_ac_bus1_has_power 			= find_dataref("laminar/A333/elec/ac_bus1_has_power")
A333DR_dc_bus1_has_power 			= find_dataref("laminar/A333/elec/dc_bus1_has_power")
A333DR_dc_bus2_has_power 			= find_dataref("laminar/A333/elec/dc_bus2_has_power")
A333DR_dc_ess_bus_has_power 		= find_dataref("laminar/A333/elec/dc_ess_bus_has_power")

A333DR_status_gpu_avail 			= find_dataref("laminar/A333/status/GPU_avail") -- yellow

-- FDs

A333_capt_FD_bars_bypass			= find_dataref("laminar/A333/autopilot/capt_FD_bars_bypass") -- TEMPORARY FD ISSUE FIX
A333_fo_FD_bars_bypass				= find_dataref("laminar/A333/autopilot/fo_FD_bars_bypass") -- TEMPORARY FD ISSUE FIX

-- ADIRS

A333DR_adiru1_adr_status = find_dataref("laminar/A333/adiru1/adr_status")
A333DR_adiru1_att_status = find_dataref("laminar/A333/adiru1/att_status")
A333DR_adiru1_hdg_status = find_dataref("laminar/A333/adiru1/hdg_status")
A333DR_adiru1_lrn_status = find_dataref("laminar/A333/adiru1/lrn_status")

A333DR_adiru2_adr_status = find_dataref("laminar/A333/adiru2/adr_status")
A333DR_adiru2_att_status = find_dataref("laminar/A333/adiru2/att_status")
A333DR_adiru2_hdg_status = find_dataref("laminar/A333/adiru2/hdg_status")
A333DR_adiru2_lrn_status = find_dataref("laminar/A333/adiru2/lrn_status")

--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
----- BUTTON SWITCH COVER(S) ------------------------------------------------------------
A333_button_switch_cover_position	= create_dataref("laminar/A333/button_switch/cover_position", "array[" .. tostring(NUM_BTN_SW_COVERS) .. "]")
A333_guard_cover_pos				= create_dataref("laminar/A333/button_switch/guard_cover_pos", "array[" .. tostring(NUM_GUARD_COVERS) .. "]")


----- EFIS CONTROLS ---------------------------------------------------------------------
A333_EFIS_mode_knob_captain			= create_dataref("laminar/A333/knobs/EFIS_mode_pos_capt", "number")
A333_EFIS_mode_knob_fo				= create_dataref("laminar/A333/knobs/EFIS_mode_pos_fo", "number")
A333_ECAM_on_EFIS_captain			= create_dataref("laminar/A333/ECAM_on_EFIS_capt", "number")
A333_ECAM_on_EFIS_fo				= create_dataref("laminar/A333/ECAM_on_EFIS_fo", "number")

A333_draw_capt_map					= create_dataref("laminar/A333/ND/draw_map_mode_capt", "number") -- 0 = no map, 1 = heading ONLY, 2 = DRAW ALL
A333_draw_fo_map					= create_dataref("laminar/A333/ND/draw_map_mode_fo", "number") -- 0 = no map, 1 = heading ONLY, 2 = DRAW ALL

A333_EFIS_CSTR_capt					= create_dataref("laminar/A333/buttons/EFIS_CSTR_captain_pos", "number")
A333_EFIS_WPT_capt					= create_dataref("laminar/A333/buttons/EFIS_WPT_captain_pos", "number")
A333_EFIS_VOR_capt					= create_dataref("laminar/A333/buttons/EFIS_VOR_captain_pos", "number")
A333_EFIS_NDB_capt					= create_dataref("laminar/A333/buttons/EFIS_NDB_captain_pos", "number")
A333_EFIS_ARPT_capt					= create_dataref("laminar/A333/buttons/EFIS_ARPT_captain_pos", "number")

A333_EFIS_CSTR_fo					= create_dataref("laminar/A333/buttons/EFIS_CSTR_fo_pos", "number")
A333_EFIS_WPT_fo					= create_dataref("laminar/A333/buttons/EFIS_WPT_fo_pos", "number")
A333_EFIS_VOR_fo					= create_dataref("laminar/A333/buttons/EFIS_VOR_fo_pos", "number")
A333_EFIS_NDB_fo					= create_dataref("laminar/A333/buttons/EFIS_NDB_fo_pos", "number")
A333_EFIS_ARPT_fo					= create_dataref("laminar/A333/buttons/EFIS_ARPT_fo_pos", "number")

A333_terr_on_nd_capt				= create_dataref("laminar/A333/buttons/EFIS_terr_on_nd_capt", "number")
A333_terr_on_nd_fo					= create_dataref("laminar/A333/buttons/EFIS_terr_on_nd_fo", "number")

A333_tru_north_pos					= create_dataref("laminar/A333/buttons/EFIS_true_north_ref_pos", "number")

A333_weather_radar_switch_pos		= create_dataref("laminar/A333/switches/weather_radar_pos", "number")
A333_weather_radar_mode_pos			= create_dataref("laminar/A333/switches/weather_radar_mode", "number")
A333_weather_radar_mode_anim		= create_dataref("laminar/A333/switches/weather_radar_mode_anim_pos", "number")

A333_pfd_nd_swap_capt_pos			= create_dataref("laminar/A333/buttons/pfd_nd_swap_capt_pos", "number")
A333_pfd_nd_swap_fo_pos				= create_dataref("laminar/A333/buttons/pfd_nd_swap_fo_pos", "number")

A333_pfd_nd_capt_swap_status		= create_dataref("laminar/A333/buttons/pfd_nd_swap_capt_status", "number")
A333_pfd_nd_fo_swap_status			= create_dataref("laminar/A333/buttons/pfd_nd_swap_fo_status", "number")

A333_capt_flight_director_pos		= create_dataref("laminar/A333/buttons/capt_fd_pos", "number")
A333_fo_flight_director_pos			= create_dataref("laminar/A333/buttons/fo_fd_pos", "number")
A333_capt_ils_bars_pos				= create_dataref("laminar/A333/buttons/capt_ls_pos", "number")
A333_fo_ils_bars_pos				= create_dataref("laminar/A333/buttons/fo_ls_pos", "number")

A333_capt_ls_bars_status			= create_dataref("laminar/A333/status/capt_ls_bars", "number")
A333_fo_ls_bars_status				= create_dataref("laminar/A333/status/fo_ls_bars", "number")

----- FADEC GROUND POWER ----------------------------------------------------------------

A333_eng1_fadec_ground_pwr_pos		= create_dataref("laminar/A333/buttons/eng1_FADEC_ground_pwr_pos", "number")
A333_eng2_fadec_ground_pwr_pos		= create_dataref("laminar/A333/buttons/eng2_FADEC_ground_pwr_pos", "number")
A333_eng1_fadec_ground_pwr_cntr		= create_dataref("laminar/A333/buttons/eng1_FADEC_ground_pwr_cntr", "number")
A333_eng2_fadec_ground_pwr_cntr		= create_dataref("laminar/A333/buttons/eng2_FADEC_ground_pwr_cntr", "number")

----- SMOKING / SEATBELTS ---------------------------------------------------------------
A333_switches_seatbelts				= create_dataref("laminar/A333/switches/fasten_seatbelts", "number")
A333_switches_no_smoking			= create_dataref("laminar/A333/switches/no_smoking", "number")

----- APU -------------------------------------------------------------------------------
A333_buttons_APU_master				= create_dataref("laminar/A333/buttons/APU_master", "number")
A333_buttons_APU_start				= create_dataref("laminar/A333/buttons/APU_start", "number")

----- ANTI ICE --------------------------------------------------------------------------
A333_buttons_probe_window_ice		= create_dataref("laminar/A333/buttons/window_probe_ice", "number")
A333_probe_window_heat_monitor		= create_dataref("laminar/A333/monitors/probe_window_heat", "number")
A333_engine_anti_ice1				= create_dataref("laminar/A333/buttons/engine_anti_ice1", "number")
A333_engine_anti_ice2				= create_dataref("laminar/A333/buttons/engine_anti_ice2", "number")
A333_wing_anti_ice					= create_dataref("laminar/A333/buttons/wing_anti_ice", "number")
A333_buttons_wing_anti_ice_ctct_on_off 	= create_dataref("laminar/A333/buttons/wing_anti_ice_ctct_on_off", "number")

A333_window1_rate					= create_dataref("laminar/A333/anti_ice/window_rate1", "number")
A333_window2_rate					= create_dataref("laminar/A333/anti_ice/window_rate2", "number")
A333_window3_rate					= create_dataref("laminar/A333/anti_ice/window_rate3", "number")
A333_window4_rate					= create_dataref("laminar/A333/anti_ice/window_rate4", "number")

---- RUDDER TRIM ------------------------------------------------------------------------
A333DR_rudder_trim_sel_dial_pos		= create_dataref("laminar/A333/flt_ctrls/rudder_trim/sel_dial_pos", "number")
A333DR_rudder_trim_reset_pos		= create_dataref("laminar/A333/buttons/rudder_trim_reset", "number")

---- DOOR -------------------------------------------------------------------------------
A333DR_cockpit_door_lock_switch_pos		    = create_dataref("laminar/A333/switches/cockpit_door_lock_pos", "number")   -- -1=Down (LOCK), 0=Center (NORM), 1=Up (UNLOCK)
A333DR_cockpit_door_lock_mode			    = create_dataref("laminar/A333/status/cockpit_door_lock_mode", "number")
A333DR_cockpit_door_manip_hide_status       = create_dataref("laminar/A333/status/cockpit_door_manip_hide", "number")
A333DR_cockpit_door_on_flash                = create_dataref("laminar/A333/status/cockpit_door_on_flash", "number")
A333DR_cockpit_door_access_request_buzzer   = create_dataref("laminar/A333/audio/door_access_request_buzzer", "number")
A333DR_cockpit_door_keypad_green_led        = create_dataref("laminar/A333/status/cockpit_door_keypad_green_led", "number")
A333DR_cockpit_door_keypad_red_led          = create_dataref("laminar/A333/status/cockpit_door_keypad_red_led", "number")
A333DR_cockpit_door_keypad_white_led        = create_dataref("laminar/A333/status/cockpit_door_keypad_white_led", "number")

---- ELECTRICAL -------------------------------------------------------------------------
A333_switches_battery_sel			= create_dataref("laminar/A333/switches/battery_display_pos", "number")
A333_buttons_battery1_pos			= create_dataref("laminar/A333/buttons/battery1_pos", "number")
A333_buttons_battery1_ctct_on_off 	= create_dataref("laminar/A333/buttons/batt1_ctct_on_off", "number")
A333_buttons_battery2_pos			= create_dataref("laminar/A333/buttons/battery2_pos", "number")
A333_buttons_apu_battery_pos		= create_dataref("laminar/A333/buttons/APU_batt_pos", "number")
A333_buttons_battery2_ctct_on_off 	= create_dataref("laminar/A333/buttons/batt2_ctct_on_off", "number")

A333_buttons_gen1_pos				= create_dataref("laminar/A333/buttons/gen1_pos", "number")
A333_buttons_gen1_ctct_on_off		= create_dataref("laminar/A333/buttons/gen1_ctct_on_off", "number")
A333_buttons_gen2_pos				= create_dataref("laminar/A333/buttons/gen2_pos", "number")
A333_buttons_gen2_ctct_on_off		= create_dataref("laminar/A333/buttons/gen2_ctct_on_off", "number")
A333_buttons_gen_apu_pos			= create_dataref("laminar/A333/buttons/gen_apu_pos", "number")
A333_buttons_apu_gen_ctct_on_off	= create_dataref("laminar/A333/buttons/gen_apu_state", "number")
A333_buttons_ess_feed_ctct_on_off	= create_dataref("laminar/A333/buttons/ess_feed_ctct_state", "number")

A333_buttons_apu_bat_ctct_on_off	= create_dataref("laminar/A333/buttons/apu_battery_ctct_on_off", "number")
A333_buttons_apu_master_ctct_on_off	= create_dataref("laminar/A333/buttons/apu_master_ctct_on_off", "number")
A333_buttons_apu_start_ctct_on_off	= create_dataref("laminar/A333/buttons/apu_start_ctct_on_off", "number")

A333_buttons_idg1_discon_pos		= create_dataref("laminar/A333/buttons/IDG1_discon_pos", "number")
A333_buttons_idg2_discon_pos		= create_dataref("laminar/A333/buttons/IDG2_discon_pos", "number")

A333_IDG1_status					= create_dataref("laminar/A333/status/elec/IDG1", "number")
A333_IDG2_status					= create_dataref("laminar/A333/status/elec/IDG2", "number")

A333_buttons_bus_tie_pos			= create_dataref("laminar/A333/buttons/bus_tie_pos", "number")
A333_buttons_bus_tie_ctct_on_off	= create_dataref("laminar/A333/buttons/bus_tie_ctct_state", "number")

A333_buttons_galley_pos				= create_dataref("laminar/A333/buttons/galley_pos", "number")
A333_buttons_commercial_pos			= create_dataref("laminar/A333/buttons/commercial_pos", "number")
A333_buttons_ACESS_FEED_pos			= create_dataref("laminar/A333/buttons/AC_ESS_FEED_pos", "number")
A333_buttons_extA_pos	    		= create_dataref("laminar/A333/buttons/ext_power_A_pos", "number")
A333_buttons_extB_pos				= create_dataref("laminar/A333/buttons/ext_power_B_pos", "number")
A333_buttons_extA_ctct_on_off		= create_dataref("laminar/A333/buttons/ext_power_A_ctct_on_off", "number")
A333_buttons_extB_ctct_on_off		= create_dataref("laminar/A333/buttons/ext_power_B_ctct_on_off", "number")

A333_commercial_status				= create_dataref("laminar/A333/status/commercial", "number")
A333_galley_status					= create_dataref("laminar/A333/status/galley", "number")

A333_buttons_land_rcvry_pos 		= create_dataref("laminar/A333/buttons/land_rcvry_pos", "number")
A333_buttons_land_rcvry_ctct_on_off = create_dataref("laminar/A333/buttons/land_rcvry_ctct_on_off", "number")

A333_emer_gen_test_button_pos 		= create_dataref("laminar/A333/elec/emer_gen_test_button_pos", "number")
A333_emer_gen_man_on_button_pos 	= create_dataref("laminar/A333/elec/emer_gen_man_on_button_pos", "number")
A333_buttons_emer_gen_man_on_ctct_on_off = create_dataref("laminar/A333/buttons/emer_gen_man_on_ctct_on_off", "number")


---- BLEED AIR --------------------------------------------------------------------------
A333_switches_pack1_pos				= create_dataref("laminar/A333/buttons/pack_1_pos", "number")
A333_switches_pack2_pos				= create_dataref("laminar/A333/buttons/pack_2_pos", "number")
A333_switches_eng1_bleed_pos		= create_dataref("laminar/A333/buttons/eng_bleed_1_pos", "number")
A333_switches_eng2_bleed_pos		= create_dataref("laminar/A333/buttons/eng_bleed_2_pos", "number")
A333_switches_apu_bleed_pos			= create_dataref("laminar/A333/buttons/apu_bleed_pos", "number")
A333_knobs_pack_flow_pos			= create_dataref("laminar/A333/pressurization/knobs/pack_flow_pos", "number")
A333_knobs_bleed_isol_valve_pos		= create_dataref("laminar/A333/pressurization/knobs/pack_isol_valve_pos", "number")
A333_switches_ram_air_pos			= create_dataref("laminar/A333/buttons/ram_air_pos", "number")
A333_status_ram_air_valve			= create_dataref("laminar/A333/ecam/BLEED/ram_air_status", "number")
A333_switches_hot_air1_pos			= create_dataref("laminar/A333/buttons/hot_air1_pos", "number")
A333_switches_hot_air2_pos			= create_dataref("laminar/A333/buttons/hot_air2_pos", "number")

A333_pack1_switch_ctct_on_off		= create_dataref("laminar/A333/switch_memory/pack1_on_off", "number")
A333_pack2_switch_ctct_on_off		= create_dataref("laminar/A333/switch_memory/pack2_on_off", "number")
A333_eng1_bleed_switch_ctct_on_off	= create_dataref("laminar/A333/switch_memory/eng1_bleed_on_off", "number")
A333_eng2_bleed_switch_ctct_on_off	= create_dataref("laminar/A333/switch_memory/eng2_bleed_on_off", "number")
A333_apu_bleed_switch_ctct_on_off	= create_dataref("laminar/A333/switch_memory/apu_bleed_on_off", "number")



---- FUEL -------------------------------------------------------------------------------
A333_left_pump1_pos					= create_dataref("laminar/A333/fuel/buttons/left1_pump_pos", "number")
A333_left_pump2_pos					= create_dataref("laminar/A333/fuel/buttons/left2_pump_pos", "number")
A333_left_standby_pump_pos			= create_dataref("laminar/A333/fuel/buttons/left_stby_pump_pos", "number")

A333_right_pump1_pos				= create_dataref("laminar/A333/fuel/buttons/right1_pump_pos", "number")
A333_right_pump2_pos				= create_dataref("laminar/A333/fuel/buttons/right2_pump_pos", "number")
A333_right_standby_pump_pos			= create_dataref("laminar/A333/fuel/buttons/right_stby_pump_pos", "number")

A333_center_left_pump_pos			= create_dataref("laminar/A333/fuel/buttons/center_left_pump_pos", "number")
A333_center_right_pump_pos			= create_dataref("laminar/A333/fuel/buttons/center_right_pump_pos", "number")

A333_fuel_wing_crossfeed_pos		= create_dataref("laminar/A333/fuel/buttons/wing_x_feed_pos", "number")

A333_fuel_center_xfr_pos			= create_dataref("laminar/A333/fuel/buttons/center_xfr_pos", "number")
A333_fuel_trim_xfr_pos				= create_dataref("laminar/A333/fuel/buttons/trim_xfr_pos", "number")
A333_fuel_outer_tank_xfr_pos		= create_dataref("laminar/A333/fuel/buttons/outer_tank_xfr_pos", "number")

A333_trim_tank_feed_mode_pos		= create_dataref("laminar/A333/fuel/switches/trim_tank_feed_pos", "number")

---- HYDRAULICS -------------------------------------------------------------------------
A333_engine1_pump_green_pos			= create_dataref("laminar/A330/buttons/hyd/eng1_pump_green_pos", "number")
A333_engine1_pump_blue_pos			= create_dataref("laminar/A330/buttons/hyd/eng1_pump_blue_pos", "number")
A333_engine2_pump_yellow_pos		= create_dataref("laminar/A330/buttons/hyd/eng2_pump_yellow_pos", "number")
A333_engine2_pump_green_pos			= create_dataref("laminar/A330/buttons/hyd/eng2_pump_green_pos", "number")

A333_elec_pump_green_on_pos			= create_dataref("laminar/A330/buttons/hyd/elec_green_on_pos", "number")
A333_elec_pump_blue_on_pos			= create_dataref("laminar/A330/buttons/hyd/elec_blue_on_pos", "number")
A333_elec_pump_yellow_on_pos		= create_dataref("laminar/A330/buttons/hyd/elec_yellow_on_pos", "number")

A333_elec_pump_green_tog_pos		= create_dataref("laminar/A330/buttons/hyd/elec_green_tog_pos", "number") -- allows pump to turn ON when engaged -- ALWAYS OFF otherwise
A333_elec_pump_blue_tog_pos			= create_dataref("laminar/A330/buttons/hyd/elec_blue_tog_pos", "number") -- allows pump to turn ON when engaged -- ALWAYS OFF otherwise
A333_elec_pump_yellow_tog_pos		= create_dataref("laminar/A330/buttons/hyd/elec_yellow_tog_pos", "number") -- allows pump to turn ON when engaged -- ALWAYS OFF otherwise

A333_elec_pump_green_contactor		= create_dataref("laminar/A333/hyd/elec_green_contactor", "number") -- 1 = AUTO, 0 = OFF
A333_elec_pump_blue_contactor		= create_dataref("laminar/A333/hyd/elec_blue_contactor", "number") -- 1 = STBY, 0 = OFF
A333_elec_pump_yellow_contactor		= create_dataref("laminar/A333/hyd/elec_yellow_contactor", "number") -- 1 = AUTO, 0 = OFF

A333_elec_pump_green_override_on	= create_dataref("laminar/A333/hyd/elec_green_override_on", "number")
A333_elec_pump_blue_override_on		= create_dataref("laminar/A333/hyd/elec_blue_override_on", "number")
A333_elec_pump_yellow_override_on	= create_dataref("laminar/A333/hyd/elec_yellow_override_on", "number")

--A333_ram_air_turbine_pos			= create_dataref("laminar/A330/buttons/hyd/rat_deploy_pos", "number")
A333_rat_man_on_button_pos		    = create_dataref("laminar/A330/buttons/hyd/rat_man_on_button_pos", "number")
A333_buttons_rat_man_on_ctct_on_off   = create_dataref("laminar/A333/buttons/rat_man_on_ctct_on_off", "number")

A333_green_leak_measure_pos			= create_dataref("laminar/A333/buttons/hyd/leak_measurement_g_pos", "number")
A333_blue_leak_measure_pos			= create_dataref("laminar/A333/buttons/hyd/leak_measurement_b_pos", "number")
A333_yellow_leak_measure_pos		= create_dataref("laminar/A333/buttons/hyd/leak_measurement_y_pos", "number")

A333_green_leak_measure_status		= create_dataref("laminar/A333/hyd/leak_measurement_g_status", "number") -- 0 = valve open, 1 = valve closed (OFF) - takes into account 100kt cutout
A333_blue_leak_measure_status		= create_dataref("laminar/A333/hyd/leak_measurement_b_status", "number") -- 0 = valve open, 1 = valve closed (OFF) - takes into account 100kt cutout
A333_yellow_leak_measure_status		= create_dataref("laminar/A333/hyd/leak_measurement_y_status", "number") -- 0 = valve open, 1 = valve closed (OFF) - takes into account 100kt cutout + cargo door

---- GPWS -------------------------------------------------------------------------------
A333_gpws_terr_tog_pos				= create_dataref("laminar/A333/buttons/gpws/terrain_toggle_pos", "number")
A333_gpws_sys_tog_pos				= create_dataref("laminar/A333/buttons/gpws/system_toggle_pos", "number")
A333_gpws_GS_tog_pos				= create_dataref("laminar/A333/buttons/gpws/glideslope_toggle_pos", "number")
A333_gpws_flap_tog_pos				= create_dataref("laminar/A333/buttons/gpws/flap_toggle_pos", "number")

A333_gpws_terr_status				= create_dataref("laminar/A333/buttons/gpws/terrain_status", "number") -- status of the switch contactor
A333_gpws_sys_status				= create_dataref("laminar/A333/buttons/gpws/system_status", "number") -- status of the switch contactor
A333_gpws_GS_status					= create_dataref("laminar/A333/buttons/gpws/glideslope_status", "number") -- status of the switch contactor
A333_gpws_flap_status				= create_dataref("laminar/A333/buttons/gpws/flap_status", "number") -- status of the switch contactor

A333_gpws_gs_canx_capt_pos			= create_dataref("laminar/A333/buttons/gpws/gs_canx_capt_pos", "number")
A333_gpws_gs_canx_fo_pos			= create_dataref("laminar/A333/buttons/gpws/gs_canx_fo_pos", "number")


---- CALL BUTTONS -----------------------------------------------------------------------
A333_call_mech_pos					= create_dataref("laminar/A333/buttons/call/mech_pos", "number")
A333_call_flt_rest_pos				= create_dataref("laminar/A333/buttons/call/flt_rest_pos", "number")
A333_call_cab_rest_pos				= create_dataref("laminar/A333/buttons/call/cab_rest_pos", "number")
A333_call_all_pos					= create_dataref("laminar/A333/buttons/call/all_pos", "number")
A333_call_purs_pos					= create_dataref("laminar/A333/buttons/call/purs_pos", "number")
A333_call_fwd_pos					= create_dataref("laminar/A333/buttons/call/fwd_pos", "number")
A333_call_mid_pos					= create_dataref("laminar/A333/buttons/call/mid_pos", "number")
A333_call_exit_pos					= create_dataref("laminar/A333/buttons/call/exit_pos", "number")
A333_call_aft_pos					= create_dataref("laminar/A333/buttons/call/aft_pos", "number")
A333_call_emergency_tog_pos			= create_dataref("laminar/A333/buttons/call/emergency_pos", "number")
A333_call_emergency_status			= create_dataref("laminar/A333/status/call/emergency", "number")

A333_sound_call_purs_trigger		= create_dataref("laminar/A333/sound/call/purs_trigger", "number") -- 1 = normal call, 2 = emergency call
A333_sound_call_fwd_trigger			= create_dataref("laminar/A333/sound/call/fwd_trigger", "number") -- 1 = normal call, 2 = emergency call
A333_sound_call_mid_trigger			= create_dataref("laminar/A333/sound/call/mid_trigger", "number") -- 1 = normal call, 2 = emergency call
A333_sound_call_exit_trigger		= create_dataref("laminar/A333/sound/call/exit_trigger", "number") -- 1 = normal call, 2 = emergency call
A333_sound_call_aft_trigger			= create_dataref("laminar/A333/sound/call/aft_trigger", "number") -- 1 = normal call, 2 = emergency call

---- MISC -------------------------------------------------------------------------------
A333_rain_repellent_capt_pos		= create_dataref("laminar/A333/buttons/misc/rain_repellent_capt_pos", "number")
A333_rain_repellent_fo_pos			= create_dataref("laminar/A333/buttons/misc/rain_repellent_fo_pos", "number")

A333_foot_warmer_capt_pos			= create_dataref("laminar/A333/switches/misc/capt_foot_warmer_pos", "number")
A333_foot_warmer_fo_pos				= create_dataref("laminar/A333/switches/misc/fo_foot_warmer_pos", "number")

A333_crew_oxy_pos					= create_dataref("laminar/A333/buttons/oxy/crew_valve_pos", "number")
A333_pax_oxy_pos					= create_dataref("laminar/A333/buttons/oxy/pax_masks_pos", "number")
A333_pax_oxy_reset_pos				= create_dataref("laminar/A333/buttons/oxy/pax_oxy_maint_reset_pos", "number")

A333_flight_recorder_ground_pos		= create_dataref("laminar/A333/buttons/rcdr/ground_control_pos", "number")
A333_flight_recorder_mode_on		= create_dataref("laminar/A333/buttons/rcdr/active_mode", "number") -- 0 - off, 1 - on, 2 - auto
A333_cvr_erase_pos					= create_dataref("laminar/A333/buttons/cvr_erase_pos", "number")
A333_cvr_test_pos					= create_dataref("laminar/A333/buttons/cvr_test_pos", "number")

A333_pax_sys_pos					= create_dataref("laminar/A333/buttons/pax_sys_pos", "number")
A333_pax_satcom_pos					= create_dataref("laminar/A333/buttons/pax_satcom_pos", "number")
A333_pax_IFEC_pos					= create_dataref("laminar/A333/buttons/pax_IFEC_pos", "number")
A333_IFEC_status					= create_dataref("laminar/A333/status/IFEC", "number")

A333_cargo_cond_fwd_isol_valve_pos	= create_dataref("laminar/A333/buttons/cargo_cond/fwd_isol_valve_pos", "number")
A333_cargo_cond_bulk_isol_valve_pos	= create_dataref("laminar/A333/buttons/cargo_cond/bulk_isol_valve_pos", "number")
A333_cargo_cond_hot_air_pos			= create_dataref("laminar/A333/buttons/cargo_cond/hot_air_pos", "number")
A333_cargo_cond_cooling_knob_pos	= create_dataref("laminar/A333/buttons/cargo_cond/cooling_knob_pos", "number")

A333_cabin_fan_pos					= create_dataref("laminar/A333/buttons/cabin_fan_pos", "number")

A333_ditching_pos					= create_dataref("laminar/A333/buttons/ditching_pos", "number")
A333_ditching_status				= create_dataref("laminar/A333/ditching_status", "number")
A333_ventilation_extract_ovrd_pos	= create_dataref("laminar/A333/buttons/ventilation_extract_ovrd_pos", "number")
A333_ventilation_extract_status		= create_dataref("laminar/A333/status/ventilation_extract", "number")

A333_crew_supply_status				= create_dataref("laminar/A333/status/crew_oxy_supply", "number")


---- EVAC -------------------------------------------------------------------------------
A333_evac_command_pos				= create_dataref("laminar/A333/buttons/evac_command_pos", "number")
A333_buttons_evac_cmd_ctct_on_off   = create_dataref("laminar/A333/buttons/evac_cmd_ctct_on_off", "number")
A333_evac_horn_off_pos				= create_dataref("laminar/A333/buttons/evac_horn_off_pos", "number")
A333_evac_capt_purs_pos				= create_dataref("laminar/A333/switches/evac_capt_purs_pos", "number")

A333_evac_horn_on					= create_dataref("laminar/A333/sounds/evac_horn_on", "number")

---- GEAR -------------------------------------------------------------------------------
A333_gear_gravity_extension_pos		= create_dataref("laminar/A333/switches/gear/grav_extension_pos", "number")

A333_auto_brake_low_pos				= create_dataref("laminar/A333/buttons/gear/auto_brake_low_pos", "number")
A333_auto_brake_med_pos				= create_dataref("laminar/A333/buttons/gear/auto_brake_med_pos", "number")
A333_auto_brake_max_pos				= create_dataref("laminar/A333/buttons/gear/auto_brake_max_pos", "number")

A333_brake_fan_pos					= create_dataref("laminar/A333/buttons/gear/brake_fans_pos", "number")

---- ADIRS ------------------------------------------------------------------------------
A333_adirs_ir1_button_pos			= create_dataref("laminar/A333/buttons/adirs/ir1_pos", "number")
A333_adirs_ir3_button_pos			= create_dataref("laminar/A333/buttons/adirs/ir3_pos", "number")
A333_adirs_ir2_button_pos			= create_dataref("laminar/A333/buttons/adirs/ir2_pos", "number")

A333_adirs_adr1_button_pos			= create_dataref("laminar/A333/buttons/adirs/adr1_pos", "number")
A333_adirs_adr3_button_pos			= create_dataref("laminar/A333/buttons/adirs/adr3_pos", "number")
A333_adirs_adr2_button_pos			= create_dataref("laminar/A333/buttons/adirs/adr2_pos", "number")

A333_adirs_ir1_knob					= create_dataref("laminar/A333/buttons/adirs/ir1_knob_pos", "number")
A333_adirs_ir3_knob					= create_dataref("laminar/A333/buttons/adirs/ir3_knob_pos", "number")
A333_adirs_ir2_knob					= create_dataref("laminar/A333/buttons/adirs/ir2_knob_pos", "number")

A333_adirs_ir1_mode					= create_dataref("laminar/A333/adirs/ir1_status", "number")
A333_adirs_adr1_mode				= create_dataref("laminar/A333/adirs/adr1_status", "number")

A333_adirs_ir3_mode					= create_dataref("laminar/A333/adirs/ir3_status", "number")
A333_adirs_adr3_mode				= create_dataref("laminar/A333/adirs/adr3_status", "number")

A333_adirs_ir2_mode					= create_dataref("laminar/A333/adirs/ir2_status", "number")
A333_adirs_adr2_mode				= create_dataref("laminar/A333/adirs/adr2_status", "number")


---- FLIGHT CONTROL COMPUTERS -----------------------------------------------------------
A333_turb_damp_pos					= create_dataref("laminar/A333/buttons/fcc_turb_damp_pos", "number")
A333_prim1_pos						= create_dataref("laminar/A333/buttons/fcc_prim1_pos", "number")
A333_prim2_pos						= create_dataref("laminar/A333/buttons/fcc_prim2_pos", "number")
A333_prim3_pos						= create_dataref("laminar/A333/buttons/fcc_prim3_pos", "number")
A333_sec1_pos						= create_dataref("laminar/A333/buttons/fcc_sec1_pos", "number")
A333_sec2_pos						= create_dataref("laminar/A333/buttons/fcc_sec2_pos", "number")

A333_prim1_status					= create_dataref("laminar/A333/fcc/prim1_status", "number")
A333_prim2_status					= create_dataref("laminar/A333/fcc/prim2_status", "number")
A333_prim3_status					= create_dataref("laminar/A333/fcc/prim3_status", "number")
A333_sec1_status					= create_dataref("laminar/A333/fcc/sec1_status", "number")
A333_sec2_status					= create_dataref("laminar/A333/fcc/sec2_status", "number")

---- ECAM BUTTONS -----------------------------------------------------------------------
A333_ecam_button_eng_pos			= create_dataref("laminar/A333/buttons/ecam/eng_pos", "number")
A333_ecam_button_bleed_pos			= create_dataref("laminar/A333/buttons/ecam/bleed_pos", "number")
A333_ecam_button_press_pos			= create_dataref("laminar/A333/buttons/ecam/press_pos", "number")
A333_ecam_button_el_ac_pos			= create_dataref("laminar/A333/buttons/ecam/el_ac_pos", "number")
A333_ecam_button_el_dc_pos			= create_dataref("laminar/A333/buttons/ecam/el_dc_pos", "number")
A333_ecam_button_hyd_pos			= create_dataref("laminar/A333/buttons/ecam/hyd_pos", "number")
A333_ecam_button_cbs_pos			= create_dataref("laminar/A333/buttons/ecam/cbs_pos", "number")
A333_ecam_button_apu_pos			= create_dataref("laminar/A333/buttons/ecam/apu_pos", "number")
A333_ecam_button_cond_pos			= create_dataref("laminar/A333/buttons/ecam/cond_pos", "number")
A333_ecam_button_door_pos			= create_dataref("laminar/A333/buttons/ecam/door_pos", "number")
A333_ecam_button_wheel_pos			= create_dataref("laminar/A333/buttons/ecam/wheel_pos", "number")
A333_ecam_button_f_ctl_pos			= create_dataref("laminar/A333/buttons/ecam/f_ctl_pos", "number")
A333_ecam_button_fuel_pos			= create_dataref("laminar/A333/buttons/ecam/fuel_pos", "number")
A333_ecam_button_all_pos			= create_dataref("laminar/A333/buttons/ecam/all_pos", "number")

A333_ecam_button_to_config_pos		= create_dataref("laminar/A333/buttons/ecam/to_config_pos", "number")
A333_ecam_button_clr_capt_pos		= create_dataref("laminar/A333/buttons/ecam/clr_capt_pos", "number")
A333_ecam_button_clr_fo_pos			= create_dataref("laminar/A333/buttons/ecam/clr_fo_pos", "number")
A333_ecam_button_sts_pos			= create_dataref("laminar/A333/buttons/ecam/sts_pos", "number")
A333_ecam_button_rcl_pos			= create_dataref("laminar/A333/buttons/ecam/rcl_pos", "number")
A333_ecam_button_emer_cancel_pos	= create_dataref("laminar/A333/buttons/ecam/emer_cancel_pos", "number")

A333DR_ecp_pushbutton_process_step = create_dataref("laminar/A333/ecp/pb_process_step", "array[21]")

A333_switches_park_brake_pos		= create_dataref("laminar/A333/switches/park_brake_pos", "number")
A333_switches_park_brake_lift		= create_dataref("laminar/A333/switches/park_brake_lift", "number")

---- BAROMETER --------------------------------------------------------------------------
A333_capt_baro_knob_pos				= create_dataref("laminar/A333/barometer/capt_knob_pos", "number")
A333_fo_baro_knob_pos				= create_dataref("laminar/A333/barometer/fo_knob_pos", "number")
A333_capt_baro_inHg_hPa_pos			= create_dataref("laminar/A333/barometer/capt_inHg_hPa_pos", "number")
A333_fo_baro_inHg_hPa_pos			= create_dataref("laminar/A333/barometer/fo_inHg_hPa_pos", "number")
A333_capt_pull_std_pos				= create_dataref("laminar/A333/barometer/capt_pull_std_pos", "number")
A333_fo_pull_std_pos				= create_dataref("laminar/A333/barometer/fo_pull_std_pos", "number")

---- STANDBY INSTRUMENT -----------------------------------------------------------------

A333_standby_baro_knob_pos			= create_dataref("laminar/A333/barometer/standby_knob_pos", "number")
A333_standby_std_button_pos			= create_dataref("laminar/A333/buttons/standby/baro_std_pos", "number")
A333_standby_std_state				= create_dataref("laminar/A333/status/standby/baro_standard", "number")
A333_standby_ls_button_pos			= create_dataref("laminar/A333/buttons/standby/ls_pos", "number")
A333_standby_ls_state				= create_dataref("laminar/A333/status/standby/ls_state", "number")

A333_standby_bugs_button_pos		= create_dataref("laminar/A333/buttons/standby/bugs_pos", "number")
A333_standby_bugs_state				= create_dataref("laminar/A333/status/standby/bugs_state", "number") -- this doesn't do anything for now
A333_standby_rst_button_pos			= create_dataref("laminar/A333/buttons/standby/rst_pos", "number")
A333_standby_rst_state				= create_dataref("laminar/A333/status/standby/rst_state", "number") -- are we in align? 0 = no, 1 = ATT 10s, 2 = ATT : RST
A333_standby_rst_timer				= create_dataref("laminar/A333/timers/standby/att_reset_timer", "number")
A333_standby_rst_align_timer		= create_dataref("laminar/A333/timers/standby/att_reset_align_timer", "number")

---- AI ---------------------------------------------------------------------------------
A333DR_init_switches_CD           	= create_dataref("laminar/A333/init_CD/switches", "number")

A333_test							= create_dataref("laminar/A333/test/sentinel", "number")



--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--
function A333_captain_visor_pos_DRhandler() end
function A333_center_visor_pos_DRhandler() end
function A333_fo_visor_pos_DRhandler() end

function A333_cockpit_temp_knob_pos_DRhandler() end
function A333_cabin_temp_knob_pos_DRhandler() end
function A333_fwd_cargo_temp_knob_pos_DRhandler() end
function A333_bulk_cargo_temp_knob_pos_DRhandler() end

function A333_switches_engine1_start_pos_DRhandler()
	engine1_starter_lift_flag = 1
end
function A333_switches_engine2_start_pos_DRhandler()
	engine2_starter_lift_flag = 1
end
function A333_switches_engine1_start_lift_DRhandler() end
function A333_switches_engine2_start_lift_DRhandler() end

function A333_handles_flap_lift_pos_DRhandler() end

function A333_test_displays_DRhandler() end

--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--
A333_captain_visor_position		= create_dataref("laminar/a333/misc/capt_visor", "number", A333_captain_visor_pos_DRhandler)
A333_center_visor_position		= create_dataref("laminar/a333/misc/center_visor", "number", A333_center_visor_pos_DRhandler)
A333_fo_visor_position			= create_dataref("laminar/a333/misc/fo_visor", "number", A333_fo_visor_pos_DRhandler)

A333_cockpit_temp_knob_pos		= create_dataref("laminar/A333/knob/cockpit_temp", "number", A333_cockpit_temp_knob_pos_DRhandler)
A333_cabin_temp_knob_pos		= create_dataref("laminar/A333/knob/cabin_temp", "number", A333_cabin_temp_knob_pos_DRhandler)
A333_fwd_cargo_temp_knob_pos	= create_dataref("laminar/A333/knob/fwd_cargo_temp", "number", A333_fwd_cargo_temp_knob_pos_DRhandler)
A333_bulk_cargo_temp_knob_pos	= create_dataref("laminar/A333/knob/aft_cargo_temp", "number", A333_bulk_cargo_temp_knob_pos_DRhandler)

---- ENGINE START -----------------------------------------------------------------------
A333_switches_engine1_start_pos		= create_dataref("laminar/A333/switches/engine1_start_pos", "number", A333_switches_engine1_start_pos_DRhandler)
A333_switches_engine2_start_pos		= create_dataref("laminar/A333/switches/engine2_start_pos", "number", A333_switches_engine2_start_pos_DRhandler)
A333_switches_engine1_start_lift	= create_dataref("laminar/A333/switches/engine1_start_lift", "number", A333_switches_engine1_start_lift_DRhandler)
A333_switches_engine2_start_lift	= create_dataref("laminar/A333/switches/engine2_start_lift", "number", A333_switches_engine2_start_lift_DRhandler)

--- FLAP / SPEEDBRAKE -------------------------------------------------------------------
A333_handles_flap_lift				= create_dataref("laminar/A333/controls/flap_lift_pos", "number", A333_handles_flap_lift_pos_DRhandler)

--- TEST ---

A333_displays_test					= create_dataref("laminar/test_displays", "number", A333_test_displays_DRhandler) -- replaces temporarily laminar/A333/display/apu_page_on_ewd

--*************************************************************************************--
--** 				              FIND CUSTOM COMMANDS                   	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--
function A333_EFIS_capt_WPT_beforeCMDhandler(phase, duration) end
function A333_EFIS_capt_WPT_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_EFIS_WPT_capt = 1
		simDR_EFIS_cstr_on_capt = 0
		simDR_EFIS_airport_on_capt = 0
		simDR_EFIS_vor_on_capt = 0
		simDR_EFIS_ndb_on_capt = 0
	elseif phase == 2 then
		A333_EFIS_WPT_capt = 0
	end
end



function A333_EFIS_fo_WPT_beforeCMDhandler(phase, duration) end
function A333_EFIS_fo_WPT_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_EFIS_WPT_fo = 1
		simDR_EFIS_cstr_on_fo = 0
		simDR_EFIS_airport_on_fo = 0
		simDR_EFIS_vor_on_fo = 0
		simDR_EFIS_ndb_on_fo = 0
	elseif phase == 2 then
		A333_EFIS_WPT_fo = 0
	end
end



function A333_EFIS_capt_VOR_beforeCMDhandler(phase, duration) end
function A333_EFIS_capt_VOR_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_EFIS_VOR_capt = 1
		simDR_EFIS_cstr_on_capt = 0
		simDR_EFIS_airport_on_capt = 0
		simDR_EFIS_fix_on_capt = 0
		simDR_EFIS_ndb_on_capt = 0
	elseif phase == 2 then
		A333_EFIS_VOR_capt = 0
	end
end



function A333_EFIS_fo_VOR_beforeCMDhandler(phase, duration) end
function A333_EFIS_fo_VOR_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_EFIS_VOR_fo = 1
		simDR_EFIS_cstr_on_fo = 0
		simDR_EFIS_airport_on_fo = 0
		simDR_EFIS_fix_on_fo = 0
		simDR_EFIS_ndb_on_fo = 0
	elseif phase == 2 then
		A333_EFIS_VOR_fo = 0
	end
end



function A333_EFIS_capt_NDB_beforeCMDhandler(phase, duration) end
function A333_EFIS_capt_NDB_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_EFIS_NDB_capt = 1
		simDR_EFIS_cstr_on_capt = 0
		simDR_EFIS_airport_on_capt = 0
		simDR_EFIS_vor_on_capt = 0
		simDR_EFIS_fix_on_capt = 0
	elseif phase == 2 then
		A333_EFIS_NDB_capt = 0
	end
end



function A333_EFIS_fo_NDB_beforeCMDhandler(phase, duration) end
function A333_EFIS_fo_NDB_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_EFIS_NDB_fo = 1
		simDR_EFIS_cstr_on_fo = 0
		simDR_EFIS_airport_on_fo = 0
		simDR_EFIS_vor_on_fo = 0
		simDR_EFIS_fix_on_fo = 0
	elseif phase == 2 then
		A333_EFIS_NDB_fo = 0
	end
end



function A333_EFIS_capt_ARPT_beforeCMDhandler(phase, duration) end
function A333_EFIS_capt_ARPT_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_EFIS_ARPT_capt = 1
		simDR_EFIS_cstr_on_capt = 0
		simDR_EFIS_fix_on_capt = 0
		simDR_EFIS_vor_on_capt = 0
		simDR_EFIS_ndb_on_capt = 0
	elseif phase == 2 then
		A333_EFIS_ARPT_capt = 0
	end
end



function A333_EFIS_fo_ARPT_beforeCMDhandler(phase, duration) end
function A333_EFIS_fo_ARPT_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_EFIS_ARPT_fo = 1
		simDR_EFIS_cstr_on_fo = 0
		simDR_EFIS_fix_on_fo = 0
		simDR_EFIS_vor_on_fo = 0
		simDR_EFIS_ndb_on_fo = 0
	elseif phase == 2 then
		A333_EFIS_ARPT_fo = 0
	end
end


function A333_EFIS_capt_TERR_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_terr_on_nd_capt == 0 then
			A333_terr_on_nd_capt = 1.2
			terr_on_capt_pos = 1
		elseif A333_terr_on_nd_capt == 1 then
			A333_terr_on_nd_capt = 1.2
			terr_on_capt_pos = 0
		end
	elseif phase == 2 then
		if terr_on_capt_pos == 1 then
			A333_terr_on_nd_capt = 1
		elseif terr_on_capt_pos == 0 then
			A333_terr_on_nd_capt = 0
		end
	end
end



function A333_EFIS_fo_TERR_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_terr_on_nd_fo == 0 then
			A333_terr_on_nd_fo = 1.2
			terr_on_fo_pos = 1
		elseif A333_terr_on_nd_fo == 1 then
			A333_terr_on_nd_fo = 1.2
			terr_on_fo_pos = 0
		end
	elseif phase == 2 then
		if terr_on_fo_pos == 1 then
			A333_terr_on_nd_fo = 1
		elseif terr_on_fo_pos == 0 then
			A333_terr_on_nd_fo = 0
		end
	end
end



function A333_apu_master_off_CMDhandler(phase, duration)
	if phase == 0 then
		A333_buttons_APU_master = 0
		A333_buttons_apu_master_ctct_on_off = 0
	end
end




function A333_apu_master_on_CMDhandler(phase, duration)
	if phase == 0 then
		A333_buttons_APU_master = 1
		A333_buttons_apu_master_ctct_on_off = 1
	end
end





function A333_inlet_heat_tog1_beforeCMDhandler(phase, duration) end
function A333_inlet_heat_tog1_afterCMDhandler(phase, duration)
	if phase == 0 then
		if A333_engine_anti_ice1 == 0 then
			A333_engine_anti_ice1 = 1.2
			simDR_engine1_heat = 1
			simCMD_hi_lo_idle_tog1:once()
		elseif A333_engine_anti_ice1 == 1 then
			A333_engine_anti_ice1 = 1.2
			simDR_engine1_heat = 0
			simCMD_hi_lo_idle_tog1:once()
		end
	elseif phase == 2 then
		if simDR_engine1_heat == 1 then
			A333_engine_anti_ice1 = 1
		elseif simDR_engine1_heat == 0 then
			A333_engine_anti_ice1 = 0
		end
	end
end




function A333_inlet_heat_tog2_beforeCMDhandler(phase, duration) end
function A333_inlet_heat_tog2_afterCMDhandler(phase, duration)
	if phase == 0 then
		if A333_engine_anti_ice2 == 0 then
			A333_engine_anti_ice2 = 1.2
			simDR_engine2_heat = 1
			simCMD_hi_lo_idle_tog2:once()
		elseif A333_engine_anti_ice2 == 1 then
			A333_engine_anti_ice2 = 1.2
			simDR_engine2_heat = 0
			simCMD_hi_lo_idle_tog2:once()
		end
	elseif phase == 2 then
		if simDR_engine2_heat == 1 then
			A333_engine_anti_ice2 = 1
		elseif simDR_engine2_heat == 0 then
			A333_engine_anti_ice2 = 0
		end
	end
end


function A333_wing_heat_tog_beforeCMDhandler(phase, duration) end
function A333_wing_heat_tog_afterCMDhandler(phase, duration)
	if phase == 0 then
        switch_start_pos.wing_anti_ice = A333_wing_anti_ice
        A333_wing_anti_ice = 1.2
        if switch_start_pos.wing_anti_ice == 0 then
            A333_buttons_wing_anti_ice_ctct_on_off = 1
            simDR_wing_heat_left = 1
            simDR_wing_heat_right = 1
        end
	elseif phase == 2 then
        A333_wing_anti_ice = 1 - switch_start_pos.wing_anti_ice
        if switch_start_pos.wing_anti_ice == 1 then A333_buttons_wing_anti_ice_ctct_on_off = 0
            simDR_wing_heat_left = 0
            simDR_wing_heat_right = 0
        end
	end
end




function A333_engine1_start_wrap_beforeCMDhandler(phase, duration) end
function A333_engine1_start_wrap_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_switches_engine1_start_pos = 1
		A333_switches_engine1_start_lift = 0
	elseif phase == 2 then
	end
end




function A333_engine2_start_wrap_beforeCMDhandler(phase, duration) end
function A333_engine2_start_wrap_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_switches_engine2_start_pos = 1
		A333_switches_engine2_start_lift = 0
	elseif phase == 2 then
	end
end



function A333_engine1_cutoff_wrap_beforeCMDhandler(phase, duration) end
function A333_engine1_cutoff_wrap_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_switches_engine1_start_pos = 0
		A333_switches_engine1_start_lift = 0
	elseif phase == 2 then
	end
end




function A333_engine2_cutoff_wrap_beforeCMDhandler(phase, duration) end
function A333_engine2_cutoff_wrap_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_switches_engine2_start_pos = 0
		A333_switches_engine2_start_lift = 0
	elseif phase == 2 then
	end
end




function A333_brakes_hold_beforeCMDhandler(phase, duration) end			-- THIS COMMAND IS HERE FOR USER CONVENIENCE
function A333_brakes_hold_afterCMDhandler(phase, duration)				-- a user pressing the B key on the keyboard gets the brakes release
	if phase == 0 then
		if park_brake_switch_pos_target == 0 then
		elseif park_brake_switch_pos_target == 1 then
			park_brake_switch_pos_target = 0
		end
	end
end

function A333_brakes_toggle_beforeCMDhandler(phase, duration) end		-- THIS COMMAND IS HERE FOR USER CONVENIENCE
function A333_brakes_toggle_afterCMDhandler(phase, duration)			-- a user pressing the V key on the keyboard toggles the parking brake handle as expected
	if phase == 0 then
		if park_brake_switch_pos_target == 0 then
			park_brake_switch_pos_target = 1
		elseif park_brake_switch_pos_target == 1 then
			park_brake_switch_pos_target = 0
		end
	end
end



-- RUDDER TRIM
function sim_rudder_trim_left_beforeCMDhandler(phase, duration) end
function sim_rudder_trim_left_afterCMDhandler(phase, duration)
    if phase == 0 then
        A333_rudder_trim_sel_dial_position_target = -1
    elseif phase == 2 then
        A333_rudder_trim_sel_dial_position_target = 0
    end
end



function sim_rudder_trim_right_beforeCMDhandler(phase, duration) end
function sim_rudder_trim_right_afterCMDhandler(phase, duration)
    if phase == 0 then
        A333_rudder_trim_sel_dial_position_target = 1
    elseif phase == 2 then
        A333_rudder_trim_sel_dial_position_target = 0
    end
end




function sim_rudder_trim_reset_beforeCMDhandler(phase, duration) end
function sim_rudder_trim_reset_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333DR_rudder_trim_reset_pos = 1
	elseif phase == 2 then
		A333DR_rudder_trim_reset_pos = 0
	end
end




-- BATTERIES
--[[
function sim_battery1_toggle_beforeCMDhandler(phase, duration) end
function sim_battery1_toggle_afterCMDhandler(phase, duration)
	if phase == 0 then
		if A333_buttons_battery1_pos == 0 then
			A333_buttons_battery1_pos = 1.2
			simDR_battery1 = 1
		elseif A333_buttons_battery1_pos == 1 then
			A333_buttons_battery1_pos = 1.2
			simDR_battery1 = 0
		end
	elseif phase == 2 then
		if simDR_battery1 == 1 then
			A333_buttons_battery1_pos = 1
		elseif simDR_battery1 == 0 then
			A333_buttons_battery1_pos = 0
		end
	end
end
--]]

function sim_battery1_toggle_CMDhandler(phase, duration)	-- 7PB1
	if phase == 0 then
		switch_start_pos.elec_batt1 = A333_buttons_battery1_pos
		A333_buttons_battery1_pos = 1.2
		if switch_start_pos.elec_batt1 == 0 then A333_buttons_battery1_ctct_on_off = 1 end
	elseif phase == 2 then
		A333_buttons_battery1_pos = 1 - switch_start_pos.elec_batt1
		if switch_start_pos.elec_batt1 == 1 then A333_buttons_battery1_ctct_on_off = 0 end
	end
end

--[[
function sim_battery2_toggle_beforeCMDhandler(phase, duration) end
function sim_battery2_toggle_afterCMDhandler(phase, duration)
	if phase == 0 then
		if A333_buttons_battery2_pos == 0 then
			A333_buttons_battery2_pos = 1.2
			simDR_battery2 = 1
		elseif A333_buttons_battery2_pos == 1 then
			A333_buttons_battery2_pos = 1.2
			simDR_battery2 = 0
		end
	elseif phase == 2 then
		if simDR_battery2 == 1 then
			A333_buttons_battery2_pos = 1
		elseif simDR_battery2 == 0 then
			A333_buttons_battery2_pos = 0
		end
	end
end
--]]
function sim_battery2_toggle_CMDhandler(phase, duration)	-- 7PB2
	if phase == 0 then
		switch_start_pos.elec_batt2 = A333_buttons_battery2_pos
		A333_buttons_battery2_pos = 1.2
		if switch_start_pos.elec_batt2 == 0 then A333_buttons_battery2_ctct_on_off = 1 end
	elseif phase == 2 then
		A333_buttons_battery2_pos = 1 - switch_start_pos.elec_batt2
		if switch_start_pos.elec_batt2 == 1 then A333_buttons_battery2_ctct_on_off = 0 end
	end
end






-- GENERATORS
function sim_generator1_on_CMDhandler(phase, duration)
	if A333_buttons_gen1_pos == 0 then
		A333_buttons_gen1_pos = 1
		A333_buttons_gen1_ctct_on_off = 1
	end
end





function sim_generator1_off_CMDhandler(phase, duration)
	if A333_buttons_gen1_pos == 1 then
		A333_buttons_gen1_pos = 0
		A333_buttons_gen1_ctct_on_off = 0
	end
end






function sim_generator1_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.generator1 = A333_buttons_gen1_pos
		A333_buttons_gen1_pos = 1.2
		if switch_start_pos.generator1 == 0 then A333_buttons_gen1_ctct_on_off = 1 end
	elseif phase == 2 then
		A333_buttons_gen1_pos = 1 - switch_start_pos.generator1
		if switch_start_pos.generator1 == 1 then A333_buttons_gen1_ctct_on_off = 0 end
	end
end





function sim_generator2_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.generator2 = A333_buttons_gen2_pos
		A333_buttons_gen2_pos = 1.2
		if switch_start_pos.generator2 == 0 then A333_buttons_gen2_ctct_on_off = 1 end
	elseif phase == 2 then
		A333_buttons_gen2_pos = 1 - switch_start_pos.generator2
		if switch_start_pos.generator2 == 1 then A333_buttons_gen2_ctct_on_off = 0 end
	end
end





function sim_bus_tie_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.elec_bus_tie = A333_buttons_bus_tie_pos
		A333_buttons_bus_tie_pos = 1.2
		if switch_start_pos.elec_bus_tie == 0 then A333_buttons_bus_tie_ctct_on_off = 1 end
	elseif phase == 2 then
		A333_buttons_bus_tie_pos = 1 - switch_start_pos.elec_bus_tie
		if switch_start_pos.elec_bus_tie == 1 then A333_buttons_bus_tie_ctct_on_off = 0 end
	end
end










function sim_pack1_toggle_beforeCMDhandler(phase, duration) end
function sim_pack1_toggle_afterCMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.pack1 = A333_switches_pack1_pos
		A333_switches_pack1_pos = 1.2
		if switch_start_pos.pack1 == 0 then
			simDR_pack1 = 1
			A333_pack1_switch_ctct_on_off = 1
		end
	elseif phase == 2 then
		A333_switches_pack1_pos = 1 - switch_start_pos.pack1
		if switch_start_pos.pack1 == 1 then
			simDR_pack1 = 0
			A333_pack1_switch_ctct_on_off = 0
		end
	end
end




function sim_pack2_toggle_beforeCMDhandler(phase, duration) end
function sim_pack2_toggle_afterCMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.pack2 = A333_switches_pack2_pos
		A333_switches_pack2_pos = 1.2
		if switch_start_pos.pack2 == 0 then
			simDR_pack2 = 1
			A333_pack2_switch_ctct_on_off = 1
		end
	elseif phase == 2 then
		A333_switches_pack2_pos = 1 - switch_start_pos.pack2
		if switch_start_pos.pack2 == 1 then
			simDR_pack2 = 0
			A333_pack2_switch_ctct_on_off = 0
		end
	end
end




function sim_eng1_bleed_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.eng1_bleed = A333_switches_eng1_bleed_pos
		A333_switches_eng1_bleed_pos = 1.2
		if switch_start_pos.eng1_bleed == 0 then A333_eng1_bleed_switch_ctct_on_off = 1 end
	elseif phase == 2 then
		A333_switches_eng1_bleed_pos = 1 - switch_start_pos.eng1_bleed
		if switch_start_pos.eng1_bleed == 1 then A333_eng1_bleed_switch_ctct_on_off = 0 end
	end
end




function sim_eng2_bleed_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.eng2_bleed = A333_switches_eng2_bleed_pos
		A333_switches_eng2_bleed_pos = 1.2
		if switch_start_pos.eng2_bleed == 0 then A333_eng2_bleed_switch_ctct_on_off = 1 end
	elseif phase == 2 then
		A333_switches_eng2_bleed_pos = 1 - switch_start_pos.eng2_bleed
		if switch_start_pos.eng2_bleed == 1 then A333_eng2_bleed_switch_ctct_on_off = 0 end
	end
end




function sim_apu_bleed_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.apu_bleed = A333_switches_apu_bleed_pos
		A333_switches_apu_bleed_pos = 1.2
		if switch_start_pos.apu_bleed == 0 then A333_apu_bleed_switch_ctct_on_off = 1 end
	elseif phase == 2 then
		A333_switches_apu_bleed_pos = 1 - switch_start_pos.apu_bleed
		if switch_start_pos.apu_bleed == 1 then
			A333_apu_bleed_switch_ctct_on_off = 0
		end
	end
end






-- HYDRAULICS
function sim_hyd_eng1_green_tog_beforeCMDhandler(phase, duration) end
function sim_hyd_eng1_green_tog_afterCMDhandler(phase, duration)
	if phase == 0 then
		if A333_engine1_pump_green_pos == 0 then
			A333_engine1_pump_green_pos = 1.2
			simDR_engine1_hyd_green = 1
		elseif A333_engine1_pump_green_pos == 1 then
			A333_engine1_pump_green_pos = 1.2
			simDR_engine1_hyd_green = 0
		end
	elseif phase == 2 then
		if simDR_engine1_hyd_green == 1 then
			A333_engine1_pump_green_pos = 1
		elseif simDR_engine1_hyd_green == 0 then
			A333_engine1_pump_green_pos = 0
		end
	end
end




function sim_hyd_eng1_blue_tog_beforeCMDhandler(phase, duration) end
function sim_hyd_eng1_blue_tog_afterCMDhandler(phase, duration)
	if phase == 0 then
		if A333_engine1_pump_blue_pos == 0 then
			A333_engine1_pump_blue_pos = 1.2
			simDR_engine1_hyd_blue = 1
		elseif A333_engine1_pump_blue_pos == 1 then
			A333_engine1_pump_blue_pos = 1.2
			simDR_engine1_hyd_blue = 0
		end
	elseif phase == 2 then
		if simDR_engine1_hyd_blue == 1 then
			A333_engine1_pump_blue_pos = 1
		elseif simDR_engine1_hyd_blue == 0 then
			A333_engine1_pump_blue_pos = 0
		end
	end
end




function sim_hyd_eng2_yellow_tog_beforeCMDhandler(phase, duration) end
function sim_hyd_eng2_yellow_tog_afterCMDhandler(phase, duration)
	if phase == 0 then
		if A333_engine2_pump_yellow_pos == 0 then
			A333_engine2_pump_yellow_pos = 1.2
			simDR_engine2_hyd_yellow = 1
		elseif A333_engine2_pump_yellow_pos == 1 then
			A333_engine2_pump_yellow_pos = 1.2
			simDR_engine2_hyd_yellow = 0
		end
	elseif phase == 2 then
		if simDR_engine2_hyd_yellow == 1 then
			A333_engine2_pump_yellow_pos = 1
		elseif simDR_engine2_hyd_yellow == 0 then
			A333_engine2_pump_yellow_pos = 0
		end
	end
end




function sim_hyd_eng2_green_tog_beforeCMDhandler(phase, duration) end
function sim_hyd_eng2_green_tog_afterCMDhandler(phase, duration)
	if phase == 0 then
		if A333_engine2_pump_green_pos == 0 then
			A333_engine2_pump_green_pos = 1.2
			simDR_engine2_hyd_green = 1
		elseif A333_engine2_pump_green_pos == 1 then
			A333_engine2_pump_green_pos = 1.2
			simDR_engine2_hyd_green = 0
		end
	elseif phase == 2 then
		if simDR_engine2_hyd_green == 1 then
			A333_engine2_pump_green_pos = 1
		elseif simDR_engine2_hyd_green == 0 then
			A333_engine2_pump_green_pos = 0
		end
	end
end









-- AUTO BRAKES
function sim_auto_brake_low_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_auto_brake ~= 3 then
			simDR_auto_brake = 3
			A333_auto_brake_low_pos = 1
			simDR_auto_brake_decel_low = 0.183378			-- manual calls for 5.9ft/s2 - this is that in g
		elseif simDR_auto_brake == 3 then
			simDR_auto_brake = 1
			A333_auto_brake_low_pos = 1
		end
	elseif phase == 2 then
		A333_auto_brake_low_pos = 0
	end
end




function sim_auto_brake_med_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_auto_brake ~= 4 then
			simDR_auto_brake = 4
			A333_auto_brake_med_pos = 1
			simDR_auto_brake_decel_med = 0.304593	-- manual calls for 9.8ft/s2 - this is that in g
		elseif simDR_auto_brake == 4 then
			simDR_auto_brake = 1
			A333_auto_brake_med_pos = 1
		end
	elseif phase == 2 then
		A333_auto_brake_med_pos = 0
	end
end




function sim_auto_brake_max_CMDhandler(phase, duration)
	if phase == 0 then
	
		if simDR_gear_on_ground == 1 then
	
			if simDR_auto_brake ~= 0 then
				simDR_auto_brake = 0
				A333_auto_brake_max_pos = 1
			elseif simDR_auto_brake == 0 then
				simDR_auto_brake = 1
				A333_auto_brake_max_pos = 1
			end

		elseif simDR_gear_on_ground == 0 then
		
			if simDR_auto_brake ~= 5 then
				simDR_auto_brake = 5
				A333_auto_brake_max_pos = 1
				simDR_auto_brake_decel_max = 0.5	-- manual lists a decel rate to show decel light, does not give MAX decel rate
			elseif simDR_auto_brake == 5 then
				simDR_auto_brake = 1
				A333_auto_brake_max_pos = 1
			end
			
		end

	elseif phase == 2 then
		A333_auto_brake_max_pos = 0
	end
end


-- OXYGEN


function sim_pax_oxy_dropbeforeCMDhandler(phase, duration) end
function sim_pax_oxy_dropafterCMDhandler(phase, duration)
	if phase == 0 then
		A333_pax_oxy_pos = 1
	elseif phase == 2 then
		A333_pax_oxy_pos = 0
	end
end




function simCMD_yaw_damper_beforeCMDhandler(phase, duration) end
function simCMD_yaw_damper_afterCMDhandler(phase, duration)
	if phase == 0 then
		if A333_turb_damp_pos == 0 then
			A333_turb_damp_pos = 1.2
			simDR_yaw_damper = 1
		elseif A333_turb_damp_pos == 1 then
			A333_turb_damp_pos = 1.2
			simDR_yaw_damper = 0
		end
	elseif phase == 2 then
		if simDR_yaw_damper == 1 then
			A333_turb_damp_pos = 1
		elseif simDR_yaw_damper == 0 then
			A333_turb_damp_pos = 0
		end
	end
end




-- BAROMETER
A333_phase1_gate = function()
	phase1_gate = 1
end

function simCMD_capt_baro_up_CMDhandler(phase, duration)
	if phase == 0 then
		A333_capt_baro_knob_pos = A333_capt_baro_knob_pos + 0.01

		if simDR_captain_baro_is_std == 0 then
			if A333_capt_baro_inHg_hPa_pos == 0 then
				simDR_captain_barometer = simDR_captain_barometer + 0.01
			else simDR_captain_barometer = simDR_captain_barometer + 0.02953
			end
		else
		end

		run_after_time(A333_phase1_gate, 0.5)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_capt_baro_knob_pos = A333_capt_baro_knob_pos + 0.01

			if simDR_captain_baro_is_std == 0 then
				if A333_capt_baro_inHg_hPa_pos == 0 then
					simDR_captain_barometer = simDR_captain_barometer + 0.01
				else simDR_captain_barometer = simDR_captain_barometer + 0.02953
				end
			else
			end

		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end




function simCMD_capt_baro_dn_CMDhandler(phase, duration)
	if phase == 0 then
		A333_capt_baro_knob_pos = A333_capt_baro_knob_pos - 0.01

		if simDR_captain_baro_is_std == 0 then
			if A333_capt_baro_inHg_hPa_pos == 0 then
				simDR_captain_barometer = simDR_captain_barometer - 0.01
			else simDR_captain_barometer = simDR_captain_barometer - 0.02953
			end
		else
		end

		run_after_time(A333_phase1_gate, 0.5)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_capt_baro_knob_pos = A333_capt_baro_knob_pos - 0.01

			if simDR_captain_baro_is_std == 0 then
				if A333_capt_baro_inHg_hPa_pos == 0 then
					simDR_captain_barometer = simDR_captain_barometer - 0.01
				else simDR_captain_barometer = simDR_captain_barometer - 0.02953
				end
			else
			end

		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end




function simCMD_fo_baro_up_CMDhandler(phase, duration)
	if phase == 0 then
		A333_fo_baro_knob_pos = A333_fo_baro_knob_pos + 0.01

		if simDR_first_officer_baro_is_std == 0 then
			if A333_fo_baro_inHg_hPa_pos == 0 then
				simDR_first_officer_barometer = simDR_first_officer_barometer + 0.01
			else simDR_first_officer_barometer = simDR_first_officer_barometer + 0.02953
			end
		else
		end

		run_after_time(A333_phase1_gate, 0.5)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_fo_baro_knob_pos = A333_fo_baro_knob_pos + 0.01

			if simDR_first_officer_baro_is_std == 0 then
				if A333_fo_baro_inHg_hPa_pos == 0 then
					simDR_first_officer_barometer = simDR_first_officer_barometer + 0.01
				else simDR_first_officer_barometer = simDR_first_officer_barometer + 0.02953
				end
			else
			end

		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end




function simCMD_fo_baro_dn_CMDhandler(phase, duration)
	if phase == 0 then
		A333_fo_baro_knob_pos = A333_fo_baro_knob_pos - 0.01

		if simDR_first_officer_baro_is_std == 0 then
			if A333_fo_baro_inHg_hPa_pos == 0 then
				simDR_first_officer_barometer = simDR_first_officer_barometer - 0.01
			else simDR_first_officer_barometer = simDR_first_officer_barometer - 0.02953
			end
		else
		end

		run_after_time(A333_phase1_gate, 0.5)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_fo_baro_knob_pos = A333_fo_baro_knob_pos - 0.01

			if simDR_first_officer_baro_is_std == 0 then
				if A333_fo_baro_inHg_hPa_pos == 0 then
					simDR_first_officer_barometer = simDR_first_officer_barometer - 0.01
				else simDR_first_officer_barometer = simDR_first_officer_barometer - 0.02953
				end
			else
			end

		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end




function simCMD_standby_baro_up_CMDhandler(phase, duration)
	if phase == 0 then
		A333_standby_baro_knob_pos = A333_standby_baro_knob_pos + 0.01

		if A333_standby_std_state == 0 then
			simDR_standby_barometer = simDR_standby_barometer + 0.01
		end

		run_after_time(A333_phase1_gate, 0.5)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_standby_baro_knob_pos = A333_standby_baro_knob_pos + 0.01

			if A333_standby_std_state == 0 then
				simDR_standby_barometer = simDR_standby_barometer + 0.01
			end

		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end




function simCMD_standby_baro_dn_CMDhandler(phase, duration)
	if phase == 0 then
		A333_standby_baro_knob_pos = A333_standby_baro_knob_pos - 0.01

		if A333_standby_std_state == 0 then
			simDR_standby_barometer = simDR_standby_barometer - 0.01
		end

		run_after_time(A333_phase1_gate, 0.5)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_standby_baro_knob_pos = A333_standby_baro_knob_pos - 0.01

			if A333_standby_std_state == 0 then
				simDR_standby_barometer = simDR_standby_barometer - 0.01
			end

		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end



function simCMD_capt_wiper_up_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_capt_wiper == 0 then
			simDR_capt_wiper = 2
		elseif simDR_capt_wiper == 2 then
			simDR_capt_wiper = 3
		end
	end
end




function simCMD_capt_wiper_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_capt_wiper == 3 then
			simDR_capt_wiper = 2
		elseif simDR_capt_wiper == 2 then
			simDR_capt_wiper = 0
		end
	end
end




function simCMD_fo_wiper_up_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_fo_wiper == 0 then
			simDR_fo_wiper = 2
		elseif simDR_fo_wiper == 2 then
			simDR_fo_wiper = 3
		end
	end
end




function simCMD_fo_wiper_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_fo_wiper == 3 then
			simDR_fo_wiper = 2
		elseif simDR_fo_wiper == 2 then
			simDR_fo_wiper = 0
		end
	end
end




function simCMD_EFIS_wxr_gcs_off_CMDhandler(phase, duration)
	if phase == 0 then
		simDR_weather_gcs_capt = 0
		GCS_timer_init = 0
		GCS_timer = 0
	elseif phase == 2 then
		GCS_timer_init = 1
	end
end




function A333_capt_baro_tog_beforeCMDhandler(phase, duration) end
function A333_capt_baro_tog_afterCMDhandler(phase, duration)
     if phase == 0 then
         if simDR_captain_baro_is_std == 0 then
 		    A333_capt_pull_std_pos = -1
 		else
 		    A333_capt_pull_std_pos = 1
 		end
     elseif phase == 2 then
 		A333_capt_pull_std_pos = 0
     end
end




function A333_fo_baro_tog_beforeCMDhandler(phase, duration) end
function A333_fo_baro_tog_afterCMDhandler(phase, duration)
     if phase == 0 then
         if simDR_first_officer_baro_is_std == 0 then
 		    A333_fo_pull_std_pos = -1
 		else
 		    A333_fo_pull_std_pos = 1
 		end
     elseif phase == 2 then
 		A333_fo_pull_std_pos = 0
     end
end


function sim_fdir1_bars_tog_CMDhandler(phase, duration) -- TEMPORARY FIX FOR FD ISSUE

	if phase == 0 then
		A333_capt_flight_director_pos = 1
		
		if A333_capt_FD_bars_bypass == 0 then
			A333_capt_FD_bars_bypass = 1
		else A333_capt_FD_bars_bypass = 0
		end
		
	elseif phase == 2 then
		A333_capt_flight_director_pos = 0
	end

end

--[[
function sim_fdir1_bars_tog_CMDhandler(phase, duration)

	if phase == 0 then
		A333_capt_flight_director_pos = 1
		
		if simDR_fd_command_bars_capt == 0 then
			simCMD_fdir1_bars_on:once()
		else simCMD_fdir1_bars_off:once()
		end
		
	elseif phase == 2 then
		A333_capt_flight_director_pos = 0
	end

end

function sim_fdir2_bars_tog_CMDhandler(phase, duration)

	if phase == 0 then
		A333_fo_flight_director_pos = 1
		
		if simDR_fd_command_bars_fo == 0 then
			simCMD_fdir2_bars_on:once()
		else simCMD_fdir2_bars_off:once()
		end
		
	elseif phase == 2 then
		A333_fo_flight_director_pos = 0
	end

end

]]--

function sim_fdir2_bars_tog_CMDhandler(phase, duration)

	if phase == 0 then
		A333_fo_flight_director_pos = 1
		
		if A333_fo_FD_bars_bypass == 0 then
			A333_fo_FD_bars_bypass = 1
		else A333_fo_FD_bars_bypass = 0
		end
		
	elseif phase == 2 then
		A333_fo_flight_director_pos = 0
	end

end


--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	         **--
--*************************************************************************************--
simCMD_engine1_start		= find_command("sim/starters/engage_starter_1")
simCMD_engine2_start		= find_command("sim/starters/engage_starter_2")
simCMD_engine1_cutoff		= find_command("sim/starters/shut_down_1")
simCMD_engine2_cutoff		= find_command("sim/starters/shut_down_2")

simCMD_elec_hyd_green		= find_command("sim/flight_controls/hydraulic_acmp_on")
simCMD_elec_hyd_blue		= find_command("sim/flight_controls/hydraulic_acmp2_on")
simCMD_elec_hyd_yellow		= find_command("sim/flight_controls/hydraulic_acmp3_on")

simCMD_elec_hyd_green_off	= find_command("sim/flight_controls/hydraulic_acmp_off")
simCMD_elec_hyd_blue_off	= find_command("sim/flight_controls/hydraulic_acmp2_off")
simCMD_elec_hyd_yellow_off	= find_command("sim/flight_controls/hydraulic_acmp3_off")

simCMD_ldg_gear_emer_on		= find_command("sim/flight_controls/landing_gear_emer_on")
simCMD_ldg_gear_emer_off	= find_command("sim/flight_controls/landing_gear_emer_off")

simCMD_park_brake_on		= find_command("sim/flight_controls/park_brake_set")
simCMD_park_brake_off		= find_command("sim/flight_controls/park_brake_release")

simCMD_gpu_on				= find_command("sim/electrical/GPU_on")
simCMD_gpu_off				= find_command("sim/electrical/GPU_off")

simCMD_fdir1_bars_on		= find_command("sim/autopilot/fdir_command_bars_on")
simCMD_fdir1_bars_off		= find_command("sim/autopilot/fdir_command_bars_off")
simCMD_fdir2_bars_on		= find_command("sim/autopilot/fdir2_command_bars_on")
simCMD_fdir2_bars_off		= find_command("sim/autopilot/fdir2_command_bars_off")

simCMD_hi_lo_idle_tog1		= find_command("sim/engines/idle_hi_lo_toggle_1")
simCMD_hi_lo_idle_tog2		= find_command("sim/engines/idle_hi_lo_toggle_2")

--*************************************************************************************--
--** 				               REPLACE X-PLANE COMMANDS                   	     **--
--*************************************************************************************--
-- AUTO BRAKES
simCMD_auto_brakes_low		= replace_command("sim/flight_controls/brakes_1_auto", sim_auto_brake_low_CMDhandler)
simCMD_auto_brakes_med		= replace_command("sim/flight_controls/brakes_2_auto", sim_auto_brake_med_CMDhandler)
simCMD_auto_brakes_max		= replace_command("sim/flight_controls/brakes_rto_auto", sim_auto_brake_max_CMDhandler)

-- BAROMETER
simCMD_capt_baro_up			= replace_command("sim/instruments/barometer_up", simCMD_capt_baro_up_CMDhandler)
simCMD_capt_baro_dn			= replace_command("sim/instruments/barometer_down", simCMD_capt_baro_dn_CMDhandler)
simCMD_fo_baro_up			= replace_command("sim/instruments/barometer_copilot_up", simCMD_fo_baro_up_CMDhandler)
simCMD_fo_baro_dn			= replace_command("sim/instruments/barometer_copilot_down", simCMD_fo_baro_dn_CMDhandler)
simCMD_standby_baro_up		= replace_command("sim/instruments/barometer_stby_up", simCMD_standby_baro_up_CMDhandler)
simCMD_standby_baro_dn		= replace_command("sim/instruments/barometer_stby_down", simCMD_standby_baro_dn_CMDhandler)

-- TERR ON MFD
simCMD_EFIS_capt_TERR		= replace_command("sim/instruments/EFIS_terr", A333_EFIS_capt_TERR_CMDhandler)
simCMD_EFIS_fo_TERR			= replace_command("sim/instruments/EFIS_copilot_terr", A333_EFIS_fo_TERR_CMDhandler)

-- WIPERS
simCMD_capt_wiper_up		= replace_command("sim/systems/wipers_up", simCMD_capt_wiper_up_CMDhandler)
simCMD_capt_wiper_dn		= replace_command("sim/systems/wipers_dn", simCMD_capt_wiper_dn_CMDhandler)

simCMD_fo_wiper_up			= replace_command("sim/systems/wipers2_up", simCMD_fo_wiper_up_CMDhandler)
simCMD_fo_wiper_dn			= replace_command("sim/systems/wipers2_dn", simCMD_fo_wiper_dn_CMDhandler)

-- BLEED
simCMD_apu_bleed_toggle		= replace_command("sim/bleed_air/apu_toggle", sim_apu_bleed_toggle_CMDhandler)
simCMD_eng1_bleed_toggle	= replace_command("sim/bleed_air/engine_1_toggle", sim_eng1_bleed_toggle_CMDhandler)
simCMD_eng2_bleed_toggle	= replace_command("sim/bleed_air/engine_2_toggle", sim_eng2_bleed_toggle_CMDhandler)

-- WX RADAR
simCMD_GCS_OFF				= replace_command("sim/instruments/EFIS_wxr_gcs_off", simCMD_EFIS_wxr_gcs_off_CMDhandler)

-- APU
simCMD_apu_master_off		= replace_command("sim/electrical/APU_off", A333_apu_master_off_CMDhandler)
simCMD_apu_master_on		= replace_command("sim/electrical/APU_on", A333_apu_master_on_CMDhandler)

-- ELEC
simCMD_generator1_on		= replace_command("sim/electrical/generator_1_on", sim_generator1_on_CMDhandler)
simCMD_generator1_off		= replace_command("sim/electrical/generator_1_off", sim_generator1_off_CMDhandler)
simCMD_generator1_toggle	= replace_command("sim/electrical/generator_1_toggle", sim_generator1_toggle_CMDhandler)
simCMD_generator2_toggle	= replace_command("sim/electrical/generator_2_toggle", sim_generator2_toggle_CMDhandler)
simCMD_battery1_toggle		= replace_command("sim/electrical/battery_1_toggle", sim_battery1_toggle_CMDhandler)
simCMD_battery2_toggle		= replace_command("sim/electrical/battery_2_toggle", sim_battery2_toggle_CMDhandler)
simCMD_bus_tie				= replace_command("sim/electrical/cross_tie_toggle", sim_bus_tie_CMDhandler)

-- FD

simCMD_fdir1_bars_toggle	= replace_command("sim/autopilot/fdir_command_bars_toggle", sim_fdir1_bars_tog_CMDhandler)
simCMD_fdir2_bars_toggle	= replace_command("sim/autopilot/fdir2_command_bars_toggle", sim_fdir2_bars_tog_CMDhandler)

--*************************************************************************************--
--** 				               WRAP X-PLANE COMMANDS                   	     	 **--
--*************************************************************************************--
simCMD_EFIS_capt_WPT        = wrap_command("sim/instruments/EFIS_fix", A333_EFIS_capt_WPT_beforeCMDhandler, A333_EFIS_capt_WPT_afterCMDhandler)
simCMD_EFIS_fo_WPT      	= wrap_command("sim/instruments/EFIS_copilot_fix", A333_EFIS_fo_WPT_beforeCMDhandler, A333_EFIS_fo_WPT_afterCMDhandler)

simCMD_EFIS_capt_VOR        = wrap_command("sim/instruments/EFIS_vor", A333_EFIS_capt_VOR_beforeCMDhandler, A333_EFIS_capt_VOR_afterCMDhandler)
simCMD_EFIS_fo_VOR	    	= wrap_command("sim/instruments/EFIS_copilot_vor", A333_EFIS_fo_VOR_beforeCMDhandler, A333_EFIS_fo_VOR_afterCMDhandler)

simCMD_EFIS_capt_NDB        = wrap_command("sim/instruments/EFIS_ndb", A333_EFIS_capt_NDB_beforeCMDhandler, A333_EFIS_capt_NDB_afterCMDhandler)
simCMD_EFIS_fo_NDB	     	= wrap_command("sim/instruments/EFIS_copilot_ndb", A333_EFIS_fo_NDB_beforeCMDhandler, A333_EFIS_fo_NDB_afterCMDhandler)

simCMD_EFIS_capt_ARPT       = wrap_command("sim/instruments/EFIS_apt", A333_EFIS_capt_ARPT_beforeCMDhandler, A333_EFIS_capt_ARPT_afterCMDhandler)
simCMD_EFIS_fo_ARPT	    	= wrap_command("sim/instruments/EFIS_copilot_apt", A333_EFIS_fo_ARPT_beforeCMDhandler, A333_EFIS_fo_ARPT_afterCMDhandler)

simCMD_inlet_heat1_tog		= wrap_command("sim/ice/inlet_heat0_tog", A333_inlet_heat_tog1_beforeCMDhandler, A333_inlet_heat_tog1_afterCMDhandler)
simCMD_inlet_heat2_tog		= wrap_command("sim/ice/inlet_heat1_tog", A333_inlet_heat_tog2_beforeCMDhandler, A333_inlet_heat_tog2_afterCMDhandler)
simCMD_wing_heat_tog		= wrap_command("sim/ice/wing_heat_tog", A333_wing_heat_tog_beforeCMDhandler, A333_wing_heat_tog_afterCMDhandler)

simCMD_engine1_start_wrap	= wrap_command("sim/starters/engage_starter_1", A333_engine1_start_wrap_beforeCMDhandler, A333_engine1_start_wrap_afterCMDhandler)
simCMD_engine2_start_wrap	= wrap_command("sim/starters/engage_starter_2", A333_engine2_start_wrap_beforeCMDhandler, A333_engine2_start_wrap_afterCMDhandler)
simCMD_engine1_cutoff_wrap	= wrap_command("sim/starters/shut_down_1", A333_engine1_cutoff_wrap_beforeCMDhandler, A333_engine1_cutoff_wrap_afterCMDhandler)
simCMD_engine2_cutoff_wrap	= wrap_command("sim/starters/shut_down_2", A333_engine2_cutoff_wrap_beforeCMDhandler, A333_engine2_cutoff_wrap_afterCMDhandler)

simCMD_brakes_hold			= wrap_command("sim/flight_controls/brakes_regular", A333_brakes_hold_beforeCMDhandler, A333_brakes_hold_afterCMDhandler)			-- 'B' on the keyboard since 12.2
simCMD_brakes_toggle		= wrap_command("sim/flight_controls/brakes_toggle_max", A333_brakes_toggle_beforeCMDhandler, A333_brakes_toggle_afterCMDhandler)	-- 'V' on the keyboard since forever

simCMD_capt_baro_std_tog	= wrap_command("sim/instruments/barometer_std", A333_capt_baro_tog_beforeCMDhandler, A333_capt_baro_tog_afterCMDhandler) -- not used in model, added for usabilty
simCMD_fo_baro_std_tog		= wrap_command("sim/instruments/barometer_copilot_std", A333_fo_baro_tog_beforeCMDhandler, A333_fo_baro_tog_afterCMDhandler) -- not used in model, added for usabilty)

-- RUDDER TRIM
simCMD_rudder_trim_left     = wrap_command("sim/flight_controls/rudder_trim_left", sim_rudder_trim_left_beforeCMDhandler, sim_rudder_trim_left_afterCMDhandler)
simCMD_rudder_trim_right    = wrap_command("sim/flight_controls/rudder_trim_right", sim_rudder_trim_right_beforeCMDhandler, sim_rudder_trim_right_afterCMDhandler)
simCMD_rudder_trim_reset	= wrap_command("sim/flight_controls/rudder_trim_center", sim_rudder_trim_reset_beforeCMDhandler, sim_rudder_trim_reset_afterCMDhandler)



-- BLEED AIR
simCMD_pack1_toggle			= wrap_command("sim/bleed_air/pack_left_toggle", sim_pack1_toggle_beforeCMDhandler, sim_pack1_toggle_afterCMDhandler)
simCMD_pack2_toggle			= wrap_command("sim/bleed_air/pack_right_toggle", sim_pack2_toggle_beforeCMDhandler, sim_pack2_toggle_afterCMDhandler)

-- HYDRAULICS
simCMD_hyd_eng1_green_tog	= wrap_command("sim/flight_controls/hydraulic_eng1A_tog", sim_hyd_eng1_green_tog_beforeCMDhandler, sim_hyd_eng1_green_tog_afterCMDhandler)
simCMD_hyd_eng1_blue_tog	= wrap_command("sim/flight_controls/hydraulic_eng1C_tog", sim_hyd_eng1_blue_tog_beforeCMDhandler, sim_hyd_eng1_blue_tog_afterCMDhandler)
simCMD_hyd_eng2_yellow_tog	= wrap_command("sim/flight_controls/hydraulic_eng2B_tog", sim_hyd_eng2_yellow_tog_beforeCMDhandler, sim_hyd_eng2_yellow_tog_afterCMDhandler)
simCMD_hyd_eng2_green_tog	= wrap_command("sim/flight_controls/hydraulic_eng2A_tog", sim_hyd_eng2_green_tog_beforeCMDhandler, sim_hyd_eng2_green_tog_afterCMDhandler)

-- OXYGEN
simCMD_pax_oxy_drop			= wrap_command("sim/oxy/passenger_o2_on", sim_pax_oxy_dropbeforeCMDhandler, sim_pax_oxy_dropafterCMDhandler)

-- FLIGHT CONTROL COMPUTERS
simCMD_yaw_damper_tog		= wrap_command("sim/systems/yaw_damper_toggle", simCMD_yaw_damper_beforeCMDhandler, simCMD_yaw_damper_afterCMDhandler)


--*************************************************************************************--
--** 				               FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--

----- BUTTON SWITCH COVER(S) ------------------------------------------------------------
for i = 0, NUM_BTN_SW_COVERS-1 do

    -- CREATE THE CLOSE COVER FUNCTIONS
    A333_close_button_cover[i] = function()
        A333_button_switch_cover_position_target[i] = 0.0
    end


    -- CREATE THE COVER HANDLER FUNCTIONS
    A333_button_switch_cover_CMDhandler[i] = function(phase, duration)

        if phase == 0 then
            if A333_button_switch_cover_position_target[i] == 0.0 then
                A333_button_switch_cover_position_target[i] = 1.0
                if is_timer_scheduled(A333_close_button_cover[i]) then
                    stop_timer(A333_close_button_cover[i])
                end
                run_after_time(A333_close_button_cover[i], 1.25)
            elseif A333_button_switch_cover_position_target[i] == 1.0 then
                A333_button_switch_cover_position_target[i] = 0.0
                if is_timer_scheduled(A333_close_button_cover[i]) then
                    stop_timer(A333_close_button_cover[i])
                end
            end
        end
    end

end


for i = 0, NUM_GUARD_COVERS-1 do

    -- CREATE THE COVER HANDLER FUNCTIONS
	A333_guard_cover_CMDhandler[i] = function(phase, duration)

        if phase == 0 then
            if A333_guard_cover_pos_target[i] == 0.0 then
                A333_guard_cover_pos_target[i] = 1.0
            elseif A333_guard_cover_pos_target[i] == 1.0 then
                A333_guard_cover_pos_target[i] = 0.0
            end
        end
    end

end




function A333_capt_EFIS_knob_left_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_EFIS_mode_knob_captain == 5 then
			A333_EFIS_mode_knob_captain = 4
		elseif A333_EFIS_mode_knob_captain == 4 then
			A333_EFIS_mode_knob_captain = 3
		elseif A333_EFIS_mode_knob_captain == 3 then
			A333_EFIS_mode_knob_captain = 2
		elseif A333_EFIS_mode_knob_captain == 2 then
			A333_EFIS_mode_knob_captain = 1
		elseif A333_EFIS_mode_knob_captain == 1 then
			A333_EFIS_mode_knob_captain = 0
		end
	end
end




function A333_capt_EFIS_knob_right_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_EFIS_mode_knob_captain == 0 then
			A333_EFIS_mode_knob_captain = 1
		elseif A333_EFIS_mode_knob_captain == 1 then
			A333_EFIS_mode_knob_captain = 2
		elseif A333_EFIS_mode_knob_captain == 2 then
			A333_EFIS_mode_knob_captain = 3
		elseif A333_EFIS_mode_knob_captain == 3 then
			A333_EFIS_mode_knob_captain = 4
		elseif A333_EFIS_mode_knob_captain == 4 then
			A333_EFIS_mode_knob_captain = 5
		end
	end
end




function A333_fo_EFIS_knob_left_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_EFIS_mode_knob_fo == 5 then
			A333_EFIS_mode_knob_fo = 4
		elseif A333_EFIS_mode_knob_fo == 4 then
			A333_EFIS_mode_knob_fo = 3
		elseif A333_EFIS_mode_knob_fo == 3 then
			A333_EFIS_mode_knob_fo = 2
		elseif A333_EFIS_mode_knob_fo == 2 then
			A333_EFIS_mode_knob_fo = 1
		elseif A333_EFIS_mode_knob_fo == 1 then
			A333_EFIS_mode_knob_fo = 0
		end
	end
end




function A333_fo_EFIS_knob_right_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_EFIS_mode_knob_fo == 0 then
			A333_EFIS_mode_knob_fo = 1
		elseif A333_EFIS_mode_knob_fo == 1 then
			A333_EFIS_mode_knob_fo = 2
		elseif A333_EFIS_mode_knob_fo == 2 then
			A333_EFIS_mode_knob_fo = 3
		elseif A333_EFIS_mode_knob_fo == 3 then
			A333_EFIS_mode_knob_fo = 4
		elseif A333_EFIS_mode_knob_fo == 4 then
			A333_EFIS_mode_knob_fo = 5
		end
	end
end




function A333_capt_EFIS_CSTR_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_EFIS_cstr_on_capt == 0 then
			A333_EFIS_CSTR_capt = 1
			simDR_EFIS_cstr_on_capt = 1
			simDR_EFIS_airport_on_capt = 0
			simDR_EFIS_fix_on_capt = 0
			simDR_EFIS_vor_on_capt = 0
			simDR_EFIS_ndb_on_capt = 0
		elseif simDR_EFIS_cstr_on_capt == 1 then
			A333_EFIS_CSTR_capt = 1
			simDR_EFIS_cstr_on_capt = 0
		end
	elseif phase == 2 then
		A333_EFIS_CSTR_capt = 0
	end
end




function A333_fo_EFIS_CSTR_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_EFIS_cstr_on_fo == 0 then
			A333_EFIS_CSTR_fo = 1
			simDR_EFIS_cstr_on_fo = 1
			simDR_EFIS_airport_on_fo = 0
			simDR_EFIS_fix_on_fo = 0
			simDR_EFIS_vor_on_fo = 0
			simDR_EFIS_ndb_on_fo = 0
		elseif simDR_EFIS_cstr_on_fo == 1 then
			A333_EFIS_CSTR_fo = 1
			simDR_EFIS_cstr_on_fo = 0
		end
	elseif phase == 2 then
		A333_EFIS_CSTR_fo = 0
	end
end




function A333_EFIS_tru_north_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_tru_north_pos == 0 then
			A333_tru_north_pos = 1.2
			true_north_pos = 1
		elseif A333_tru_north_pos == 1 then
			A333_tru_north_pos = 1.2
			true_north_pos = 0
		end
	elseif phase == 2 then
		if true_north_pos == 1 then
			A333_tru_north_pos = 1
			simDR_tru_north_capt = 1
			simDR_tru_north_fo = 1
		elseif true_north_pos == 0 then
			A333_tru_north_pos = 0
			simDR_tru_north_capt = 0
			simDR_tru_north_fo = 0
		end
	end
end




function A333_seatbelt_signs_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_switches_seatbelts == 0 then
			A333_switches_seatbelts = 1
		elseif A333_switches_seatbelts == 1 then
			A333_switches_seatbelts = 2
		end
	end
end




function A333_seatbelt_signs_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_switches_seatbelts == 2 then
			A333_switches_seatbelts = 1
		elseif A333_switches_seatbelts == 1 then
			A333_switches_seatbelts = 0
		end
	end
end




function A333_smoking_signs_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_switches_no_smoking == 0 then
			A333_switches_no_smoking = 1
		elseif A333_switches_no_smoking == 1 then
			A333_switches_no_smoking = 2
		end
	end
end




function A333_smoking_signs_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_switches_no_smoking == 2 then
			A333_switches_no_smoking = 1
		elseif A333_switches_no_smoking == 1 then
			A333_switches_no_smoking = 0
		end
	end
end




function A333_apu_master_sw_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.apu_master = A333_buttons_APU_master
		A333_buttons_APU_master = 1.2
		if switch_start_pos.apu_master == 0 then A333_buttons_apu_master_ctct_on_off = 1 end
	elseif phase == 2 then
		A333_buttons_APU_master = 1 - switch_start_pos.apu_master
		if switch_start_pos.apu_master == 1 then A333_buttons_apu_master_ctct_on_off = 0 end
	end
end




function A333_apu_start_sw_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		A333_buttons_APU_start = 1													-- Set the button animation
		A333_buttons_apu_start_ctct_on_off = 1										-- Set the switch contactor to "ON"
	elseif phase == 2 then
		A333_buttons_APU_start = 0													-- Set the button animation
		A333_buttons_apu_start_ctct_on_off = 0
	end
end

-- For User Hardware Assignment of APU Start Command...
function sim_apu_start_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_apu_switch == 0 then												-- Master Switch is "OFF"
			A333CMD_apu_master_sw_toggle:once()										-- Turn on Master Switch
			A333CMD_apu_start_sw_push:once()										-- Press Start Switch
			apu_start_request = 1													-- For A333_apu_starter_monitor()
		end
	end
end
simCMD_apu_start = replace_command("sim/electrical/APU_start", sim_apu_start_CMDhandler)




function A333_probe_window_heat_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_buttons_probe_window_ice == 0 then
			A333_buttons_probe_window_ice = 1.2
			A333_probe_window_heat_monitor = 1
		elseif A333_buttons_probe_window_ice == 1 then
			A333_buttons_probe_window_ice = 1.2
			A333_probe_window_heat_monitor = 0
		end
	elseif phase == 2 then
		if A333_probe_window_heat_monitor == 1 then
			A333_buttons_probe_window_ice = 1
		elseif A333_probe_window_heat_monitor == 0 then
			A333_buttons_probe_window_ice = 0
		end
	end
end




function A333_weather_radar_left_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_weather_radar_switch_pos == 1 then
			A333_weather_radar_switch_pos = 0
		elseif A333_weather_radar_switch_pos == 0 then
			A333_weather_radar_switch_pos = -1
		end
	end
end




function A333_weather_radar_right_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_weather_radar_switch_pos == -1 then
			A333_weather_radar_switch_pos = 0
		elseif A333_weather_radar_switch_pos == 0 then
			A333_weather_radar_switch_pos = 1
		end
	end
end




function A333_pfd_nd_capt_swapCMDhandler(phase, duration)
	if phase == 0 then
		A333_pfd_nd_swap_capt_pos = 1
		if A333_pfd_nd_capt_swap_status == 0 then
			A333_pfd_nd_capt_swap_status = 1
		elseif A333_pfd_nd_capt_swap_status == 1 then
			A333_pfd_nd_capt_swap_status = 0
		end
	elseif phase == 2 then
		A333_pfd_nd_swap_capt_pos = 0
	end
end




function A333_pfd_nd_fo_swapCMDhandler(phase, duration)
	if phase == 0 then
		A333_pfd_nd_swap_fo_pos = 1
		if A333_pfd_nd_fo_swap_status == 0 then
			A333_pfd_nd_fo_swap_status = 1
		elseif A333_pfd_nd_fo_swap_status == 1 then
			A333_pfd_nd_fo_swap_status = 0
		end
	elseif phase == 2 then
		A333_pfd_nd_swap_fo_pos = 0
	end
end






--[ COCKPIT DOOR ] -----------------------------------------------------------------------------------------------------
local function A333_cdls_power()
    cdls.has_power = A333DR_dc_bus1_has_power == 1 or A333DR_dc_bus2_has_power == 1
end




local function cp_door_keypad_reset()
    cdls.keypad_sel_counter = 0
    cdls.keypad_hash_sel_counter = 0
    cdls.access_request_type = NONE
    cdls.keypad_inhibited = false
end




local function cp_door_get_inhibitions()
    return cdls.emergency_access_inhibited == true
        and cdls.door_buzzer_inhibited == true
        and cdls.keypad_inhibited == true
end




local function cp_door_set_inhibitions()
    cdls.emergency_access_inhibited = true
    cdls.door_buzzer_inhibited = true
    cdls.keypad_inhibited = true
end




local function cp_door_release_inhibitions()
    cdls.emergency_access_inhibited = false
    cdls.door_buzzer_inhibited = false
    cdls.keypad_inhibited = false
end




local function A333_cockpit_door_keypad_CMDhandler(phase, duration)

    if phase == 0 then

        if cdls.has_power then

            if not cdls.keypad_inhibited then                     -- Prevents keypad entry while processing "ROUTINE" or "EMERGENCY" or if mode=LOCKED

                A333DR_cockpit_door_keypad_white_led = 1
                cdls.keypad_sel_counter = cdls.keypad_sel_counter + 1

                ---- TRACK TIME SINCE LAST ENTRY, RESET IF > 10 SECONDS -------------------------------------------
                if is_timer_scheduled(cp_door_keypad_reset) then stop_timer(cp_door_keypad_reset) end
                if not is_timer_scheduled(cp_door_keypad_reset) then run_after_time(cp_door_keypad_reset, 10.0) end
                ---------------------------------------------------------------------------------------------------

            end

        end

    elseif phase == 2 then

        if cdls.has_power then
            A333DR_cockpit_door_keypad_white_led = 0
        end

    end

end




local function A333_cockpit_door_keypad_hash_CMDhandler(phase, duration)

    if phase == 0 then

        if cdls.has_power then

            if not cdls.keypad_inhibited then                     -- Prevents keypad entry while processing "ROUTINE" or "EMERGENCY" or if mode=LOCKED

                A333DR_cockpit_door_keypad_white_led = 1
                cdls.keypad_hash_sel_counter = cdls.keypad_hash_sel_counter + 1

                ---- TRACK TIME SINCE LAST ENTRY, RESET IF > 10 SECONDS -------------------------------------------
                if is_timer_scheduled(cp_door_keypad_reset) then stop_timer(cp_door_keypad_reset) end
                if not is_timer_scheduled(cp_door_keypad_reset) then run_after_time(cp_door_keypad_reset, 10.0) end
                ---------------------------------------------------------------------------------------------------

                if cdls.keypad_hash_sel_counter == 1 then        -- Selecting "#" triggers processing

                    if cdls.keypad_sel_counter == 0 then
                        cdls.access_request_type = ROUTINE
                        if is_timer_scheduled(cp_door_keypad_reset) then stop_timer(cp_door_keypad_reset) end
                        cdls.keypad_inhibited = true

                    elseif cdls.keypad_sel_counter == 4 then
                        cdls.access_request_type = EMERGENCY
                        if is_timer_scheduled(cp_door_keypad_reset) then stop_timer(cp_door_keypad_reset) end
                        cdls.keypad_inhibited = true

                    else
                        cp_door_keypad_reset()

                    end
                    cdls.keypad_sel_counter = 0
                    cdls.keypad_hash_sel_counter = 0

                end

            end

        end

    elseif phase == 2 then
        A333DR_cockpit_door_keypad_white_led = 0

    end

end




local function cp_door_access_canx_unlock()
    A333CMD_cockpit_door_lock_switch_up:stop()
end




local function cp_door_access_auto_unlock_start()
    A333CMD_cockpit_door_lock_switch_up:start()     -- Auto-Unlock substitute for IRL pilot action
    run_after_time(cp_door_access_canx_unlock, 5.0)
end




local function cp_door_canx_auto_unlock()

    if is_timer_scheduled(cp_door_access_auto_unlock_start) then
        stop_timer(cp_door_access_auto_unlock_start) end

    if is_timer_scheduled(cp_door_access_canx_unlock) then
        stop_timer(cp_door_access_canx_unlock)
        A333CMD_cockpit_door_lock_switch_up:stop()
    end
end




local function cp_door_lock_system_reset()
    A333DR_cockpit_door_access_request_buzzer = 0
    cp_door_keypad_reset()
    cp_door_release_inhibitions()
    cdls.access_request_type = NONE
end




local function A333_cockpit_door_lock_switch_up_CMDhandler(phase, duration)

    if phase == 0 then
        cp_door_canx_auto_unlock()
        A333DR_cockpit_door_lock_switch_pos = 1                     -- UNLOCK
        A333DR_cockpit_door_access_request_buzzer = 0

    elseif phase == 1 then
        if cdls.has_power then
            if duration > 1 then
                if cdls.set_unlock then
                    cp_door_lock_system_reset()
                    A333DR_cockpit_door_lock_mode = UNLOCKED
                    cdls.set_unlock = false
                end
            end
        end

    elseif phase == 2 then
        A333DR_cockpit_door_lock_switch_pos = 0                     -- NORM [SPRING-TO-CENTER]
        if cdls.has_power and simDR_door_open_ratio[11] < 1 then
            A333DR_cockpit_door_lock_mode = LOCKED
        end
        cdls.set_unlock = true
    end

end




local function A333_cockpit_door_lock_switch_dn_CMDhandler(phase, duration)

    if phase == 0 then
        cp_door_canx_auto_unlock()
        A333DR_cockpit_door_lock_switch_pos = -1                    -- LOCK
        A333DR_cockpit_door_access_request_buzzer = 0

    elseif phase == 1 then
        if cdls.has_power and simDR_door_open_ratio[11] < 1 then
            A333DR_cockpit_door_lock_mode = LOCKED
            A333DR_cockpit_door_access_request_buzzer = 0
            cp_door_set_inhibitions()
            if not is_timer_scheduled(cp_door_release_inhibitions) then run_after_time(cp_door_release_inhibitions, 300) end
        end

    elseif phase == 2 then
        A333DR_cockpit_door_lock_switch_pos = 0                     -- NORM [SPRING-TO-CENTER]
    end

end




local function A333_cockpit_door_lock_manip_show()
    A333DR_cockpit_door_manip_hide_status = (simDR_door_open_ratio[11] <= 0 and (A333DR_cockpit_door_lock_mode == LOCKED)) and 1 or 0
end




local function cp_door_locking_system_init()
    cp_door_lock_system_reset()
    if simDR_door_open_ratio[11] == 0 then
        A333DR_cockpit_door_lock_mode = LOCKED
    else
        A333DR_cockpit_door_lock_mode = UNLOCKED
    end
    A333DR_cockpit_door_keypad_white_led = 0
    A333DR_cockpit_door_keypad_green_led = 0
    A333DR_cockpit_door_keypad_red_led = 0
end




local function cp_door_buzzer_routine()
    A333DR_cockpit_door_access_request_buzzer = 0
end




local function A333_cockpit_door_locking_system()

    if simDR_door_open_ratio[11] > 0 then
        cdls.door_was_open = true
    end

    if cdls.has_power then

        if cdls.was_previously_powered == false then cp_door_locking_system_init() end

        -- ACCESS REQUEST BUZZER
        if not cdls.door_buzzer_inhibited then

            if cdls.access_request_type == ROUTINE then
                A333DR_cockpit_door_access_request_buzzer = 1
                if not(is_timer_scheduled(cp_door_buzzer_routine)) then
                    run_after_time(cp_door_buzzer_routine, 5.0)
                end


            elseif cdls.access_request_type == EMERGENCY then
                A333DR_cockpit_door_access_request_buzzer = 1
            end

        end


        if cdls.access_request_type == ROUTINE then
            if not(is_timer_scheduled(cp_door_access_auto_unlock_start)) then
                run_after_time(cp_door_access_auto_unlock_start, 3.0)
            end
            cdls.access_request_type = NONE


        elseif cdls.access_request_type == EMERGENCY then
            if not cdls.emergency_access_inhibited then
                if not(is_timer_scheduled(cp_door_access_auto_unlock_start)) then
                    run_after_time(cp_door_access_auto_unlock_start, 30.0)
                end
            end
            cdls.access_request_type = NONE

        end


        if simDR_door_open_ratio[11] == 0 and cdls.door_was_open and A333DR_cockpit_door_lock_switch_pos == 0 then
            A333DR_cockpit_door_lock_mode = LOCKED
            cdls.door_was_open = false
        end


    else
        A333DR_cockpit_door_lock_mode = UNLOCKED
        A333DR_cockpit_door_access_request_buzzer = 0

    end

    cdls.was_previously_powered = cdls.has_power

    A333_cockpit_door_lock_manip_show()

end




local function A333_cockpit_door_keypad_led()

    local sim_time_factor = m.fmod(simDR_flight_time, 0.59)
    local flasher = (sim_time_factor >= 0 and sim_time_factor <= 0.295) and 1 or 0
    local green_led = 0

    A333DR_cockpit_door_keypad_red_led = cdls.has_power
        and (simDR_door_open_ratio[11] == 0 and A333DR_cockpit_door_lock_mode == LOCKED)
        and 1 or 0

    if cdls.has_power then
        if A333DR_cockpit_door_access_request_buzzer == 1 then
            green_led = flasher
        elseif A333DR_cockpit_door_lock_mode == UNLOCKED then
            green_led = 1
        end
    end
    A333DR_cockpit_door_keypad_green_led = green_led
end


--[ END (COCKPIT DOOR) ] -----------------------------------------------------------------------------------------------











function A333_apu_battery_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.elec_apu_bat = A333_buttons_apu_battery_pos
		A333_buttons_apu_battery_pos = 1.2
		if switch_start_pos.elec_apu_bat == 0 then A333_buttons_apu_bat_ctct_on_off = 1 end
	elseif phase == 2 then
		A333_buttons_apu_battery_pos = 1 - switch_start_pos.elec_apu_bat
		if switch_start_pos.elec_apu_bat == 1 then A333_buttons_apu_bat_ctct_on_off = 0 end
	end
end




-- BATTERY SELECT
function A333_batt_sel_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_switches_battery_sel == 0 then
			A333_switches_battery_sel = 1
		elseif A333_switches_battery_sel == 1 then
			A333_switches_battery_sel = 2
		end
	end
end




function A333_batt_sel_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_switches_battery_sel == 2 then
			A333_switches_battery_sel = 1
		elseif A333_switches_battery_sel == 1 then
			A333_switches_battery_sel = 0
		end
	end
end



-- TODO: check and make sure that during APU shutdown, we can still control the APU gen 'actuator'
-- TODO: to ensure that we don't have button / state disparagement. It is self correcting, but after a button push.
function A333_apu_gen_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.apu_gen = A333_buttons_gen_apu_pos
		A333_buttons_gen_apu_pos = 1.2
		if switch_start_pos.apu_gen == 0 then A333_buttons_apu_gen_ctct_on_off = 1 end
	elseif phase == 2 then
		A333_buttons_gen_apu_pos = 1 - switch_start_pos.apu_gen
		if switch_start_pos.apu_gen == 1 then A333_buttons_apu_gen_ctct_on_off = 0 end
	end
end






-- IDG DISCONNECT
function A333_idg1_disconnect_CMDhandler(phase, duration)
	if phase == 0 then
		A333_buttons_idg1_discon_pos = 1
	elseif phase == 2 then
		A333_buttons_idg1_discon_pos = 0
		A333_IDG1_status = 0
	end
end




function A333_idg2_disconnect_CMDhandler(phase, duration)
	if phase == 0 then
		A333_buttons_idg2_discon_pos = 1
	elseif phase == 2 then
		A333_buttons_idg2_discon_pos = 0
		A333_IDG2_status = 0
	end
end




function A333_ext_powerA_toggle_CMDhandler(phase, duration)

		if phase == 0 then
			A333_buttons_extA_pos = 1													-- Set the button animation
			A333_buttons_extA_ctct_on_off = 1 - A333_buttons_extA_ctct_on_off			-- Set the switch contactor (toggle)
		elseif phase == 2 then
			A333_buttons_extA_pos = 0													-- Set the button animation
		end


--[[ ==== OLD ====   	See A33.electrical for gpu on/off logic
	if phase == 0 then
		A333_buttons_extA_pos = 1
		if simDR_ext_power_a_on == 0 then
			if A333_status_GPU_avail == 1 then
				simCMD_gpu_on:once()
			end
		elseif simDR_ext_power_a_on == 1 then
			simCMD_gpu_off:once()
		end
	elseif phase == 2 then
		A333_buttons_extA_pos = 0
	end

--]]


end




function A333_ext_powerB_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		A333_buttons_extB_pos = 1
		A333_buttons_extB_ctct_on_off = 1 - A333_buttons_extB_ctct_on_off
	elseif phase == 2 then
		A333_buttons_extB_pos = 0
	end
end




function A333_ac_ess_feed_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.elec_ess_feed = A333_buttons_ACESS_FEED_pos
		A333_buttons_ACESS_FEED_pos = 1.2
		if switch_start_pos.elec_ess_feed == 0 then A333_buttons_ess_feed_ctct_on_off = 1 end
	elseif phase == 2 then
		A333_buttons_ACESS_FEED_pos = 1 - switch_start_pos.elec_ess_feed
		if switch_start_pos.elec_ess_feed == 1 then A333_buttons_ess_feed_ctct_on_off = 0 end
	end
end




function A333_galley_pwr_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_buttons_galley_pos == 0 then
			A333_buttons_galley_pos = 1.2
			A333_galley_status = 1
		elseif A333_buttons_galley_pos == 1 then
			A333_buttons_galley_pos = 1.2
			A333_galley_status = 0
		end
	elseif phase == 2 then
		if A333_galley_status == 1 then
			A333_buttons_galley_pos = 1
		elseif A333_galley_status == 0 then
			A333_buttons_galley_pos = 0
		end
	end
end




function A333_commercial_pwr_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_buttons_commercial_pos == 0 then
			A333_buttons_commercial_pos = 1.2
			A333_commercial_status = 1
		elseif A333_buttons_commercial_pos == 1 then
			A333_buttons_commercial_pos = 1.2
			A333_commercial_status = 0
		end
	elseif phase == 2 then
		if A333_commercial_status == 1 then
			A333_buttons_commercial_pos = 1
		elseif A333_commercial_status == 0 then
			A333_buttons_commercial_pos = 0
		end
	end
end




function A333_pack_flow_knob_left_CMDhandler(phase, duration)
	if phase == 0 then
		A333_knobs_pack_flow_pos = m.max(-1, A333_knobs_pack_flow_pos - 1)
	end
end




function A333_pack_flow_knob_right_CMDhandler(phase, duration)
	if phase == 0 then
		A333_knobs_pack_flow_pos = m.min(1, A333_knobs_pack_flow_pos + 1)
	end
end




function A333_isol_valve_knob_left_CMDhandler(phase, duration)
	if phase == 0 then
		A333_knobs_bleed_isol_valve_pos = m.max(-1, A333_knobs_bleed_isol_valve_pos - 1)
	end
end




function A333_isol_valve_knob_right_CMDhandler(phase, duration)
	if phase == 0 then
		A333_knobs_bleed_isol_valve_pos = m.min(1, A333_knobs_bleed_isol_valve_pos + 1)
	end
end




function A333_hot_air1_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.hot_air1 = A333_switches_hot_air1_pos
		A333_switches_hot_air1_pos = 1.2
	elseif phase == 2 then
		A333_switches_hot_air1_pos = 1 - switch_start_pos.hot_air1
	end
end




function A333_hot_air2_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.hot_air2 = A333_switches_hot_air2_pos
		A333_switches_hot_air2_pos = 1.2
	elseif phase == 2 then
		A333_switches_hot_air2_pos = 1 - switch_start_pos.hot_air2
	end
end




function A333_ram_air_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.ram_air = A333_switches_ram_air_pos
		A333_switches_ram_air_pos = 1.2
		if switch_start_pos.ram_air == 0 then A333_status_ram_air_valve = 1 end
	elseif phase == 2 then
		A333_switches_ram_air_pos = 1 - switch_start_pos.ram_air
		if switch_start_pos.ram_air == 1 then A333_status_ram_air_valve = 0 end
	end
end





-- FUEL
function A333_left_fuel_pump1_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_left_pump1_pos == 0 then
			A333_left_pump1_pos = 1.2
			left_pump1_pos = 1
		elseif A333_left_pump1_pos == 1 then
			A333_left_pump1_pos = 1.2
			left_pump1_pos = 0
		end
	elseif phase == 2 then
		if left_pump1_pos == 1 then
			A333_left_pump1_pos = 1
		elseif left_pump1_pos == 0 then
			A333_left_pump1_pos = 0
		end
	end
end


function A333_left_fuel_pump2_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_left_pump2_pos == 0 then
			A333_left_pump2_pos = 1.2
			left_pump2_pos = 1
		elseif A333_left_pump2_pos == 1 then
			A333_left_pump2_pos = 1.2
			left_pump2_pos = 0
		end
	elseif phase == 2 then
		if left_pump2_pos == 1 then
			A333_left_pump2_pos = 1
		elseif left_pump2_pos == 0 then
			A333_left_pump2_pos = 0
		end
	end
end


function A333_left_stby_fuel_pump_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_left_standby_pump_pos == 0 then
			A333_left_standby_pump_pos = 1.2
			left_standby_pump_pos = 1
		elseif A333_left_standby_pump_pos == 1 then
			A333_left_standby_pump_pos = 1.2
			left_standby_pump_pos = 0
		end
	elseif phase == 2 then
		if left_standby_pump_pos == 1 then
			A333_left_standby_pump_pos = 1
		elseif left_standby_pump_pos == 0 then
			A333_left_standby_pump_pos = 0
		end
	end
end


function A333_right_fuel_pump1_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_right_pump1_pos == 0 then
			A333_right_pump1_pos = 1.2
			right_pump1_pos = 1
		elseif A333_right_pump1_pos == 1 then
			A333_right_pump1_pos = 1.2
			right_pump1_pos = 0
		end
	elseif phase == 2 then
		if right_pump1_pos == 1 then
			A333_right_pump1_pos = 1
		elseif right_pump1_pos == 0 then
			A333_right_pump1_pos = 0
		end
	end
end


function A333_right_fuel_pump2_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_right_pump2_pos == 0 then
			A333_right_pump2_pos = 1.2
			right_pump2_pos = 1
		elseif A333_right_pump2_pos == 1 then
			A333_right_pump2_pos = 1.2
			right_pump2_pos = 0
		end
	elseif phase == 2 then
		if right_pump2_pos == 1 then
			A333_right_pump2_pos = 1
		elseif right_pump2_pos == 0 then
			A333_right_pump2_pos = 0
		end
	end
end


function A333_right_stby_fuel_pump_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_right_standby_pump_pos == 0 then
			A333_right_standby_pump_pos = 1.2
			right_standby_pump_pos = 1
		elseif A333_right_standby_pump_pos == 1 then
			A333_right_standby_pump_pos = 1.2
			right_standby_pump_pos = 0
		end
	elseif phase == 2 then
		if right_standby_pump_pos == 1 then
			A333_right_standby_pump_pos = 1
		elseif right_standby_pump_pos == 0 then
			A333_right_standby_pump_pos = 0
		end
	end
end


function A333_center_left_fuel_pump_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_center_left_pump_pos == 0 then
			A333_center_left_pump_pos = 1.2
			center_left_pump_pos = 1
		elseif A333_center_left_pump_pos == 1 then
			A333_center_left_pump_pos = 1.2
			center_left_pump_pos = 0
		end
	elseif phase == 2 then
		if center_left_pump_pos == 1 then
			A333_center_left_pump_pos = 1
		elseif center_left_pump_pos == 0 then
			A333_center_left_pump_pos = 0
		end
	end
end


function A333_center_right_fuel_pump_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_center_right_pump_pos == 0 then
			A333_center_right_pump_pos = 1.2
			center_right_pump_pos = 1
		elseif A333_center_right_pump_pos == 1 then
			A333_center_right_pump_pos = 1.2
			center_right_pump_pos = 0
		end
	elseif phase == 2 then
		if center_right_pump_pos == 1 then
			A333_center_right_pump_pos = 1
		elseif center_right_pump_pos == 0 then
			A333_center_right_pump_pos = 0
		end
	end
end


function A333_wing_x_feed_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_fuel_wing_crossfeed_pos == 0 then
			A333_fuel_wing_crossfeed_pos = 1.2
			fuel_wing_crossfeed_pos = 1
		elseif A333_fuel_wing_crossfeed_pos == 1 then
			A333_fuel_wing_crossfeed_pos = 1.2
			fuel_wing_crossfeed_pos = 0
		end
	elseif phase == 2 then
		if fuel_wing_crossfeed_pos == 1 then
			A333_fuel_wing_crossfeed_pos = 1
		elseif fuel_wing_crossfeed_pos == 0 then
			A333_fuel_wing_crossfeed_pos = 0
		end
	end
end


function A333_center_tank_xfr_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_fuel_center_xfr_pos == 0 then
			A333_fuel_center_xfr_pos = 1.2
			fuel_center_xfr_pos = 1
		elseif A333_fuel_center_xfr_pos == 1 then
			A333_fuel_center_xfr_pos = 1.2
			fuel_center_xfr_pos = 0
		end
	elseif phase == 2 then
		if fuel_center_xfr_pos == 1 then
			A333_fuel_center_xfr_pos = 1
		elseif fuel_center_xfr_pos == 0 then
			A333_fuel_center_xfr_pos = 0
		end
	end
end


function A333_trim_tank_xfr_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_fuel_trim_xfr_pos == 0 then
			A333_fuel_trim_xfr_pos = 1.2
			fuel_trim_xfr_pos = 1
		elseif A333_fuel_trim_xfr_pos == 1 then
			A333_fuel_trim_xfr_pos = 1.2
			fuel_trim_xfr_pos = 0
		end
	elseif phase == 2 then
		if fuel_trim_xfr_pos == 1 then
			A333_fuel_trim_xfr_pos = 1
		elseif fuel_trim_xfr_pos == 0 then
			A333_fuel_trim_xfr_pos = 0
		end
	end
end


function A333_outer_tank_xfr_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_fuel_outer_tank_xfr_pos == 0 then
			A333_fuel_outer_tank_xfr_pos = 1.2
			fuel_outer_tank_xfr_pos = 1
		elseif A333_fuel_outer_tank_xfr_pos == 1 then
			A333_fuel_outer_tank_xfr_pos = 1.2
			fuel_outer_tank_xfr_pos = 0
		end
	elseif phase == 2 then
		if fuel_outer_tank_xfr_pos == 1 then
			A333_fuel_outer_tank_xfr_pos = 1
		elseif fuel_outer_tank_xfr_pos == 0 then
			A333_fuel_outer_tank_xfr_pos = 0
		end
	end
end


function A333_trim_tank_feed_mode_upCMDhandler(phase, duration)
	if phase == 0 then
		if A333_guard_cover_pos[6] == 1 then
			if A333_trim_tank_feed_mode_pos == -1 then
				A333_trim_tank_feed_mode_pos = 0
			elseif A333_trim_tank_feed_mode_pos == 0 then
				A333_trim_tank_feed_mode_pos = 1
			end
		elseif A333_guard_cover_pos[6] == 0 then
			A333_trim_tank_feed_mode_pos = 0
		end
	end
end


function A333_trim_tank_feed_mode_dnCMDhandler(phase, duration)
	if phase == 0 then
		if A333_guard_cover_pos[6] == 1 then
			if A333_trim_tank_feed_mode_pos == 1 then
				A333_trim_tank_feed_mode_pos = 0
			elseif A333_trim_tank_feed_mode_pos == 0 then
				A333_trim_tank_feed_mode_pos = -1
			end
		elseif A333_guard_cover_pos[6] == 0 then
			A333_trim_tank_feed_mode_pos = 0
		end
	end
end





-- HYDRAULICS
function A333_hyd_rat_man_on_CMDhandler(phase, duration)
    if phase == 0 then
        A333_rat_man_on_button_pos = 1
        A333_buttons_rat_man_on_ctct_on_off = 1 - A333_buttons_rat_man_on_ctct_on_off
    elseif phase == 2 then
        A333_rat_man_on_button_pos = 0
    end
end




function A333_green_elec_hyd_pump_onCMDhandler(phase, duration)
	if phase == 0 then
		A333_elec_pump_green_on_pos = 1
		if A333_elec_pump_green_tog_pos >= 1 then
			if A333_elec_pump_green_override_on == 0 then
				if A333DR_dc_bus1_has_power == 1 then
					A333_elec_pump_green_override_on = 1
				end
			else A333_elec_pump_green_override_on = 0
			end
		elseif A333_elec_pump_green_tog_pos == 0 then
		end
	elseif phase == 2 then
		A333_elec_pump_green_on_pos = 0
	end
end


function A333_blue_elec_hyd_pump_onCMDhandler(phase, duration)
	if phase == 0 then
		A333_elec_pump_blue_on_pos = 1
		if A333_elec_pump_blue_tog_pos >= 1 then
			if A333_elec_pump_blue_override_on == 0 then
				if A333DR_dc_bus2_has_power == 1 then
					A333_elec_pump_blue_override_on = 1
				end
			else A333_elec_pump_blue_override_on = 0
			end
		elseif A333_elec_pump_blue_tog_pos == 0 then
		end
	elseif phase == 2 then
		A333_elec_pump_blue_on_pos = 0
	end
end


function A333_yellow_elec_hyd_pump_onCMDhandler(phase, duration)
	if phase == 0 then
		A333_elec_pump_yellow_on_pos = 1
		if A333_elec_pump_yellow_tog_pos >= 1 then
			if A333_elec_pump_yellow_override_on == 0 then
				if A333DR_dc_bus2_has_power == 1 or A333DR_status_gpu_avail == 1 then
					A333_elec_pump_yellow_override_on = 1
				end
			else A333_elec_pump_yellow_override_on = 0
			end
		elseif A333_elec_pump_yellow_tog_pos == 0 then
		end
	elseif phase == 2 then
		A333_elec_pump_yellow_on_pos = 0
	end
end


function A333_green_elec_hyd_pump_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_elec_pump_green_tog_pos == 0 then
			A333_elec_pump_green_tog_pos = 1.2
			A333_elec_pump_green_contactor = 1
		elseif A333_elec_pump_green_tog_pos == 1 then
			A333_elec_pump_green_tog_pos = 1.2
			A333_elec_pump_green_contactor = 0
			A333_elec_pump_green_override_on = 0
		end
	elseif phase == 2 then
		if A333_elec_pump_green_contactor == 1 then
			A333_elec_pump_green_tog_pos = 1
		elseif A333_elec_pump_green_contactor == 0 then
			A333_elec_pump_green_tog_pos = 0
		end
	end
end


function A333_blue_elec_hyd_pump_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_elec_pump_blue_tog_pos == 0 then
			A333_elec_pump_blue_tog_pos = 1.2
			A333_elec_pump_blue_contactor = 1
		elseif A333_elec_pump_blue_tog_pos == 1 then
			A333_elec_pump_blue_tog_pos = 1.2
			A333_elec_pump_blue_contactor = 0
			A333_elec_pump_blue_override_on = 0
		end
	elseif phase == 2 then
		if A333_elec_pump_blue_contactor == 1 then
			A333_elec_pump_blue_tog_pos = 1
		elseif A333_elec_pump_blue_contactor == 0 then
			A333_elec_pump_blue_tog_pos = 0
		end
	end
end


function A333_yellow_elec_hyd_pump_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_elec_pump_yellow_tog_pos == 0 then
			A333_elec_pump_yellow_tog_pos = 1.2
			A333_elec_pump_yellow_contactor = 1
		elseif A333_elec_pump_yellow_tog_pos == 1 then
			A333_elec_pump_yellow_tog_pos = 1.2
			A333_elec_pump_yellow_contactor = 0
			A333_elec_pump_yellow_override_on = 0
		end
	elseif phase == 2 then
		if A333_elec_pump_yellow_contactor == 1 then
			A333_elec_pump_yellow_tog_pos = 1
		elseif A333_elec_pump_yellow_contactor == 0 then
			A333_elec_pump_yellow_tog_pos = 0
		end
	end
end


function A333_green_leak_measure_off_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_green_leak_measure_pos == 0 then
			A333_green_leak_measure_pos = 1.2
			green_leak_measure_sw_stat = 1
		elseif A333_green_leak_measure_pos == 1 then
			A333_green_leak_measure_pos = 1.2
			green_leak_measure_sw_stat = 0
		end
	elseif phase == 2 then
		if green_leak_measure_sw_stat == 1 then
			A333_green_leak_measure_pos = 1
		elseif green_leak_measure_sw_stat == 0 then
			A333_green_leak_measure_pos = 0
		end
	end
end


function A333_blue_leak_measure_off_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_blue_leak_measure_pos == 0 then
			A333_blue_leak_measure_pos = 1.2
			blue_leak_measure_sw_stat = 1
		elseif A333_blue_leak_measure_pos == 1 then
			A333_blue_leak_measure_pos = 1.2
			blue_leak_measure_sw_stat = 0
		end
	elseif phase == 2 then
		if blue_leak_measure_sw_stat == 1 then
			A333_blue_leak_measure_pos = 1
		elseif blue_leak_measure_sw_stat == 0 then
			A333_blue_leak_measure_pos = 0
		end
	end
end


function A333_yellow_leak_measure_off_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_yellow_leak_measure_pos == 0 then
			A333_yellow_leak_measure_pos = 1.2
			yellow_leak_measure_sw_stat = 1
		elseif A333_yellow_leak_measure_pos == 1 then
			A333_yellow_leak_measure_pos = 1.2
			yellow_leak_measure_sw_stat = 0
		end
	elseif phase == 2 then
		if yellow_leak_measure_sw_stat == 1 then
			A333_yellow_leak_measure_pos = 1
		elseif yellow_leak_measure_sw_stat == 0 then
			A333_yellow_leak_measure_pos = 0
		end
	end
end


-- GPWS
function A333_gpws_terr_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_gpws_terr_tog_pos == 0 then
			A333_gpws_terr_tog_pos = 1.2
			A333_gpws_terr_status = 1
		elseif A333_gpws_terr_tog_pos == 1 then
			A333_gpws_terr_tog_pos = 1.2
			A333_gpws_terr_status = 0
		end
	elseif phase == 2 then
		if A333_gpws_terr_status == 1 then
			A333_gpws_terr_tog_pos = 1
		elseif A333_gpws_terr_status == 0 then
			A333_gpws_terr_tog_pos = 0
		end
	end
end





function A333_land_rcvry_button_CMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.land_rcvry = A333_buttons_land_rcvry_pos
		A333_buttons_land_rcvry_pos = 1.2
		if switch_start_pos.land_rcvry == 0 then A333_buttons_land_rcvry_ctct_on_off = 1 end
	elseif phase == 2 then
		A333_buttons_land_rcvry_pos = 1 - switch_start_pos.land_rcvry
		if switch_start_pos.land_rcvry == 1 then A333_buttons_land_rcvry_ctct_on_off = 0 end
	end
end




function A333_gpws_sys_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_gpws_sys_tog_pos == 0 then
			A333_gpws_sys_tog_pos = 1.2
			A333_gpws_sys_status = 1
		elseif A333_gpws_sys_tog_pos == 1 then
			A333_gpws_sys_tog_pos = 1.2
			A333_gpws_sys_status = 0
		end
	elseif phase == 2 then
		if A333_gpws_sys_status == 1 then
			A333_gpws_sys_tog_pos = 1
		elseif A333_gpws_sys_status == 0 then
			A333_gpws_sys_tog_pos = 0
		end
	end
end




function A333_gpws_GS_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_gpws_GS_tog_pos == 0 then
			A333_gpws_GS_tog_pos = 1.2
			A333_gpws_GS_status = 1
		elseif A333_gpws_GS_tog_pos == 1 then
			A333_gpws_GS_tog_pos = 1.2
			A333_gpws_GS_status = 0
		end
	elseif phase == 2 then
		if A333_gpws_GS_status == 1 then
			A333_gpws_GS_tog_pos = 1
		elseif A333_gpws_GS_status == 0 then
			A333_gpws_GS_tog_pos = 0
		end
	end
end




function A333_gpws_flap_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_gpws_flap_tog_pos == 0 then
			A333_gpws_flap_tog_pos = 1.2
			A333_gpws_flap_status = 1
		elseif A333_gpws_flap_tog_pos == 1 then
			A333_gpws_flap_tog_pos = 1.2
			A333_gpws_flap_status = 0
		end
	elseif phase == 2 then
		if A333_gpws_flap_status == 1 then
			A333_gpws_flap_tog_pos = 1
		elseif A333_gpws_flap_status == 0 then
			A333_gpws_flap_tog_pos = 0
		end
	end
end




function A333_gpws_gs_canx_capt_CMDhandler(phase, duration)
	if phase == 0 then
		A333_gpws_gs_canx_capt_pos = 1.0
	elseif phase == 2 then
		A333_gpws_gs_canx_capt_pos = 0.0
	end
end




function A333_gpws_gs_canx_fo_CMDhandler(phase, duration)
	if phase == 0 then
		A333_gpws_gs_canx_fo_pos = 1.0
	elseif phase == 2 then
		A333_gpws_gs_canx_fo_pos = 0.0
	end
end





-- CALL PUSH BUTTONS
function A333_call_mech_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_call_mech_pos = 1
	elseif phase == 2 then
		A333_call_mech_pos = 0
	end
end




function A333_call_flight_rest_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_call_flt_rest_pos = 1
	elseif phase == 2 then
		A333_call_flt_rest_pos = 0
	end
end




function A333_call_cabin_rest_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_call_cab_rest_pos = 1
	elseif phase == 2 then
		A333_call_cab_rest_pos = 0
	end
end


function A333_call_ALL_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_call_all_pos = 1

		A333_sound_call_purs_trigger = 1 * A333DR_dc_ess_bus_has_power
		A333_sound_call_fwd_trigger = 1 * A333DR_dc_ess_bus_has_power
		A333_sound_call_mid_trigger = 1 * A333DR_dc_ess_bus_has_power
		A333_sound_call_exit_trigger = 1 * A333DR_dc_ess_bus_has_power
		A333_sound_call_aft_trigger = 1 * A333DR_dc_ess_bus_has_power

		run_after_time(A333_phase1_gate, 0.1)

	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
	
		A333_sound_call_purs_trigger = 0
		A333_sound_call_fwd_trigger = 0
		A333_sound_call_mid_trigger = 0
		A333_sound_call_exit_trigger = 0
		A333_sound_call_aft_trigger = 0

		end

	elseif phase == 2 then
		A333_call_all_pos = 0	
		
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
		
		A333_sound_call_purs_trigger = 0
		A333_sound_call_fwd_trigger = 0
		A333_sound_call_mid_trigger = 0
		A333_sound_call_exit_trigger = 0
		A333_sound_call_aft_trigger = 0
			
	end
end


function A333_call_purser_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_call_purs_pos = 1
		A333_sound_call_purs_trigger = 1 * A333DR_dc_ess_bus_has_power
		run_after_time(A333_phase1_gate, 0.1)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
		A333_sound_call_purs_trigger = 0
		end
	elseif phase == 2 then
		A333_call_purs_pos = 0
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
		A333_sound_call_purs_trigger = 0
	end
end


function A333_call_fwd_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_call_fwd_pos = 1
		A333_sound_call_fwd_trigger = 1 * A333DR_dc_ess_bus_has_power
		run_after_time(A333_phase1_gate, 0.1)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
		A333_sound_call_fwd_trigger = 0
		end
	elseif phase == 2 then
		A333_call_fwd_pos = 0
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
		A333_sound_call_fwd_trigger = 0
	end
end


function A333_call_mid_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_call_mid_pos = 1
		A333_sound_call_mid_trigger = 1 * A333DR_dc_ess_bus_has_power
		run_after_time(A333_phase1_gate, 0.1)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
		A333_sound_call_mid_trigger = 0
		end
	elseif phase == 2 then
		A333_call_mid_pos = 0
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
		A333_sound_call_mid_trigger = 0
	end
end


function A333_call_exit_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_call_exit_pos = 1
		A333_sound_call_exit_trigger = 1 * A333DR_dc_ess_bus_has_power
		run_after_time(A333_phase1_gate, 0.1)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
		A333_sound_call_exit_trigger = 0
		end
	elseif phase == 2 then
		A333_call_exit_pos = 0
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
		A333_sound_call_exit_trigger = 0
	end
end


function A333_call_aft_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_call_aft_pos = 1
		A333_sound_call_aft_trigger = 1 * A333DR_dc_ess_bus_has_power
		run_after_time(A333_phase1_gate, 0.1)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
		A333_sound_call_aft_trigger = 0
		end
	elseif phase == 2 then
		A333_call_aft_pos = 0
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
		A333_sound_call_aft_trigger = 0
	end
end


function A333_call_emergency_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_call_emergency_tog_pos == 0 then
			A333_call_emergency_tog_pos = 1.2
			A333_call_emergency_status = 1
		elseif A333_call_emergency_tog_pos == 1 then
			A333_call_emergency_tog_pos = 1.2
			A333_call_emergency_status = 0
		end
	elseif phase == 2 then
		if A333_call_emergency_status == 1 then
			A333_call_emergency_tog_pos = 1
		elseif A333_call_emergency_status == 0 then
			A333_call_emergency_tog_pos = 0
		end
	end
end



-- MISC
function A333_rain_repellent_capt_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_rain_repellent_capt_pos = 1
	elseif phase == 2 then
		A333_rain_repellent_capt_pos = 0
	end
end




function A333_rain_repellent_fo_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_rain_repellent_fo_pos = 1
	elseif phase == 2 then
		A333_rain_repellent_fo_pos = 0
	end
end




function A333_foot_warmer_capt_upCMDhandler(phase, duration)
	if phase == 0 then
		if A333_foot_warmer_capt_pos == 0 then
			A333_foot_warmer_capt_pos = 1
		end
	end
end




function A333_foot_warmer_capt_dnCMDhandler(phase, duration)
	if phase == 0 then
		if A333_foot_warmer_capt_pos == 1 then
			A333_foot_warmer_capt_pos = 0
		end
	end
end




function A333_foot_warmer_fo_upCMDhandler(phase, duration)
	if phase == 0 then
		if A333_foot_warmer_fo_pos == 0 then
			A333_foot_warmer_fo_pos = 1
		end
	end
end




function A333_foot_warmer_fo_dnCMDhandler(phase, duration)
	if phase == 0 then
		if A333_foot_warmer_fo_pos == 1 then
			A333_foot_warmer_fo_pos = 0
		end
	end
end




function A333_oxy_reset_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_pax_oxy_reset_pos == 0 then
			A333_pax_oxy_reset_pos = 1.2
			pax_oxy_reset_pos = 1
			simDR_pax_oxy_fail = 0
		elseif A333_pax_oxy_reset_pos == 1 then
			A333_pax_oxy_reset_pos = 1.2
			pax_oxy_reset_pos = 0
		end
	elseif phase == 2 then
		if pax_oxy_reset_pos == 1 then
			A333_pax_oxy_reset_pos = 1
		elseif pax_oxy_reset_pos == 0 then
			A333_pax_oxy_reset_pos = 0
		end
	end
end




function A333_pax_sys_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_pax_sys_pos == 0 then
			A333_pax_sys_pos = 1.2
			pax_sys_pos = 1
		elseif A333_pax_sys_pos == 1 then
			A333_pax_sys_pos = 1.2
			pax_sys_pos = 0
		end
	elseif phase == 2 then
		if pax_sys_pos == 1 then
			A333_pax_sys_pos = 1
		elseif pax_sys_pos == 0 then
			A333_pax_sys_pos = 0
		end
	end
end




function A333_pax_satcom_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_pax_satcom_pos == 0 then
			A333_pax_satcom_pos = 1.2
			pax_satcom_pos = 1
		elseif A333_pax_satcom_pos == 1 then
			A333_pax_satcom_pos = 1.2
			pax_satcom_pos = 0
		end
	elseif phase == 2 then
		if pax_satcom_pos == 1 then
			A333_pax_satcom_pos = 1
		elseif pax_satcom_pos == 0 then
			A333_pax_satcom_pos = 0
		end
	end
end




function A333_pax_IFEC_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_pax_IFEC_pos == 0 then
			A333_pax_IFEC_pos = 1.2
			pax_IFEC_pos = 1
		elseif A333_pax_IFEC_pos == 1 then
			A333_pax_IFEC_pos = 1.2
			pax_IFEC_pos = 0
		end
	elseif phase == 2 then
		if pax_IFEC_pos == 1 then
			A333_pax_IFEC_pos = 1
		elseif pax_IFEC_pos == 0 then
			A333_pax_IFEC_pos = 0
		end
	end
end




function A333_cabin_fan_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_cabin_fan_pos == 0 then
			A333_cabin_fan_pos = 1.2
			simDR_cabin_fan_mode = 2
		elseif A333_cabin_fan_pos == 1 then
			A333_cabin_fan_pos = 1.2
			simDR_cabin_fan_mode = 0
		end
	elseif phase == 2 then
		if simDR_cabin_fan_mode == 2 then
			A333_cabin_fan_pos = 1
		elseif simDR_cabin_fan_mode == 0 then
			A333_cabin_fan_pos = 0
		end
	end
end





-- AIR CONDITIONING CARGO
function A333_cargo_cond_fwd_isol_valve_posCMDhandler(phase, duration)
	if phase == 0 then
		if A333_cargo_cond_fwd_isol_valve_pos == 0 then
			A333_cargo_cond_fwd_isol_valve_pos = 1.2
			cargo_fwd_isol_valve_pos = 1
		elseif A333_cargo_cond_fwd_isol_valve_pos == 1 then
			A333_cargo_cond_fwd_isol_valve_pos = 1.2
			cargo_fwd_isol_valve_pos = 0
		end
	elseif phase == 2 then
		if cargo_fwd_isol_valve_pos == 1 then
			A333_cargo_cond_fwd_isol_valve_pos = 1
		elseif cargo_fwd_isol_valve_pos == 0 then
			A333_cargo_cond_fwd_isol_valve_pos = 0
		end
	end
end




function A333_cargo_cond_bulk_isol_valve_posCMDhandler(phase, duration)
	if phase == 0 then
		if A333_cargo_cond_bulk_isol_valve_pos == 0 then
			A333_cargo_cond_bulk_isol_valve_pos = 1.2
			cargo_bulk_isol_valve_pos = 1
		elseif A333_cargo_cond_bulk_isol_valve_pos == 1 then
			A333_cargo_cond_bulk_isol_valve_pos = 1.2
			cargo_bulk_isol_valve_pos = 0
		end
	elseif phase == 2 then
		if cargo_bulk_isol_valve_pos == 1 then
			A333_cargo_cond_bulk_isol_valve_pos = 1
		elseif cargo_bulk_isol_valve_pos == 0 then
			A333_cargo_cond_bulk_isol_valve_pos = 0
		end
	end
end




function A333_cargo_cond_hot_air_posCMDhandler(phase, duration)
	if phase == 0 then
		if A333_cargo_cond_hot_air_pos == 0 then
			A333_cargo_cond_hot_air_pos = 1.2
			cargo_hot_air_pos = 1
		elseif A333_cargo_cond_hot_air_pos == 1 then
			A333_cargo_cond_hot_air_pos = 1.2
			cargo_hot_air_pos = 0
		end
	elseif phase == 2 then
		if cargo_hot_air_pos == 1 then
			A333_cargo_cond_hot_air_pos = 1
		elseif cargo_hot_air_pos == 0 then
			A333_cargo_cond_hot_air_pos = 0
		end
	end
end




function A333_cargo_cond_cooling_knob_leftCMDhandler(phase, duration)
	if phase == 0 then
		if A333_cargo_cond_cooling_knob_pos == 2 then
			A333_cargo_cond_cooling_knob_pos = 1
		elseif A333_cargo_cond_cooling_knob_pos == 1 then
			A333_cargo_cond_cooling_knob_pos = 0
		end
	end
end

function A333_cargo_cond_cooling_knob_rightCMDhandler(phase, duration)
	if phase == 0 then
		if A333_cargo_cond_cooling_knob_pos == 0 then
			A333_cargo_cond_cooling_knob_pos = 1
		elseif A333_cargo_cond_cooling_knob_pos == 1 then
			A333_cargo_cond_cooling_knob_pos = 2
		end
	end
end




-- CVR
function A333_rcdr_cvr_erase_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_cvr_erase_pos = 1
	elseif phase == 2 then
		A333_cvr_erase_pos = 0
	end
end

function A333_rcdr_cvr_test_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_cvr_test_pos = 1
	elseif phase == 2 then
		A333_cvr_test_pos = 0
	end
end




function A333_rcdr_ground_control_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_flight_recorder_ground_pos = 1
		A333_flight_recorder_mode_on = 1
		flight_rcdr_mode_store = 1
	elseif phase == 2 then
		A333_flight_recorder_ground_pos = 0
	end
end




-- GEAR
function A333_ldg_grav_extn_upCMDhandler(phase, duration)
	if phase == 0 then
		if A333_gear_gravity_extension_pos == -1 then
			A333_gear_gravity_extension_pos = 0
		elseif A333_gear_gravity_extension_pos == 0 then
			A333_gear_gravity_extension_pos = 1
			simCMD_ldg_gear_emer_off:once()
		end
	end
end

function A333_ldg_grav_extn_dnCMDhandler(phase, duration)
	if phase == 0 then
		if A333_gear_gravity_extension_pos == 1 then
			A333_gear_gravity_extension_pos = 0
		elseif A333_gear_gravity_extension_pos == 0 then
			A333_gear_gravity_extension_pos = -1
			simCMD_ldg_gear_emer_on:once()
		end
	end
end




function A333_gear_brake_fan_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_brake_fan_pos == 0 then
			A333_brake_fan_pos = 1.2
			brake_fan_request = 1
		elseif A333_brake_fan_pos == 1 then
			A333_brake_fan_pos = 1.2
			brake_fan_request = 0
		end
	elseif phase == 2 then
		if brake_fan_request == 1 then
			A333_brake_fan_pos = 1
		elseif brake_fan_request == 0 then
			A333_brake_fan_pos = 0
		end
	end
end




function A333_adirs_ir1_toggleCMDhandler(phase, duration)
	if phase == 0 then
		A333_adirs_ir1_button_pos = 1.2
		A333_adirs_ir1_mode = 1 - A333_adirs_ir1_mode
	elseif phase == 2 then
		A333_adirs_ir1_button_pos = 0
	end
end




function A333_adirs_ir2_toggleCMDhandler(phase, duration)
	if phase == 0 then

		A333_adirs_ir2_button_pos = 1.2
		A333_adirs_ir2_mode = 1 - A333_adirs_ir2_mode
	elseif phase == 2 then
		A333_adirs_ir2_button_pos = 0
	end
end




function A333_adirs_ir3_toggleCMDhandler(phase, duration)
	if phase == 0 then
		A333_adirs_ir3_button_pos = 1.2
		A333_adirs_ir3_mode = 1 - A333_adirs_ir3_mode
	elseif phase == 2 then
		A333_adirs_ir3_button_pos = 0
	end
end




function A333_adirs_adr1_toggleCMDhandler(phase, duration)
	if phase == 0 then
		A333_adirs_adr1_button_pos = 1.2
		A333_adirs_adr1_mode = 1 - A333_adirs_adr1_mode
	elseif phase == 2 then
		A333_adirs_adr1_button_pos = 0
	end
end




function A333_adirs_adr2_toggleCMDhandler(phase, duration)
	if phase == 0 then
		A333_adirs_adr2_button_pos = 1.2
		A333_adirs_adr2_mode = 1 - A333_adirs_adr2_mode
	elseif phase == 2 then
		A333_adirs_adr2_button_pos = 0
	end
end




function A333_adirs_adr3_toggleCMDhandler(phase, duration)
	if phase == 0 then
		A333_adirs_adr3_button_pos = 1.2
		A333_adirs_adr3_mode = 1 - A333_adirs_adr3_mode
	elseif phase == 2 then
		A333_adirs_adr3_button_pos = 0
	end
end




function A333_adirs_ir1_knob_leftCMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.ir1_knob = A333_adirs_ir1_knob
		A333_adirs_ir1_knob = m.max(0, A333_adirs_ir1_knob-1)
		if switch_start_pos.ir1_knob == 1 and A333_adirs_ir1_knob == 0 then
			A333_adirs_ir_align_fast_mode_override[0] = 1
		end
	end
end

function A333_adirs_ir1_knob_rightCMDhandler(phase, duration)
	if phase == 0 then
		A333_adirs_ir1_knob = m.min(2, A333_adirs_ir1_knob+1)
	end
end




function A333_adirs_ir2_knob_leftCMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.ir2_knob = A333_adirs_ir2_knob
		A333_adirs_ir2_knob = m.max(0, A333_adirs_ir2_knob-1)
		if switch_start_pos.ir2_knob == 1 and A333_adirs_ir2_knob == 0 then
			A333_adirs_ir_align_fast_mode_override[1] = 1
		end
	end
end

function A333_adirs_ir2_knob_rightCMDhandler(phase, duration)
	if phase == 0 then
		A333_adirs_ir2_knob = m.min(2, A333_adirs_ir2_knob+1)
	end
end



function A333_adirs_ir3_knob_leftCMDhandler(phase, duration)
	if phase == 0 then
		switch_start_pos.ir3_knob = A333_adirs_ir3_knob
		A333_adirs_ir3_knob = m.max(0, A333_adirs_ir3_knob-1)
		if switch_start_pos.ir3_knob == 1 and A333_adirs_ir3_knob == 0 then
			A333_adirs_ir_align_fast_mode_override[2] = 1
		end
	end
end

function A333_adirs_ir3_knob_rightCMDhandler(phase, duration)
	if phase == 0 then
		A333_adirs_ir3_knob = m.min(2, A333_adirs_ir3_knob+1)
	end

end







-- FLIGHT CONTROL COMPUTERS
function A333_fcc_prim1_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_prim1_pos == 0 then
			A333_prim1_pos = 1.2
			fcc_prim1 = 1
		elseif A333_prim1_pos == 1 then
			A333_prim1_pos = 1.2
			fcc_prim1 = 0
		end
	elseif phase == 2 then
		if fcc_prim1 == 1 then
			A333_prim1_pos = 1
		elseif fcc_prim1 == 0 then
			A333_prim1_pos = 0
		end
	end
end




function A333_fcc_prim2_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_prim2_pos == 0 then
			A333_prim2_pos = 1.2
			fcc_prim2 = 1
		elseif A333_prim2_pos == 1 then
			A333_prim2_pos = 1.2
			fcc_prim2 = 0
		end
	elseif phase == 2 then
		if fcc_prim2 == 1 then
			A333_prim2_pos = 1
		elseif fcc_prim2 == 0 then
			A333_prim2_pos = 0
		end
	end
end




function A333_fcc_prim3_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_prim3_pos == 0 then
			A333_prim3_pos = 1.2
			fcc_prim3 = 1
		elseif A333_prim3_pos == 1 then
			A333_prim3_pos = 1.2
			fcc_prim3 = 0
		end
	elseif phase == 2 then
		if fcc_prim3 == 1 then
			A333_prim3_pos = 1
		elseif fcc_prim3 == 0 then
			A333_prim3_pos = 0
		end
	end
end




function A333_fcc_sec1_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_sec1_pos == 0 then
			A333_sec1_pos = 1.2
			fcc_sec1 = 1
		elseif A333_sec1_pos == 1 then
			A333_sec1_pos = 1.2
			fcc_sec1 = 0
		end
	elseif phase == 2 then
		if fcc_sec1 == 1 then
			A333_sec1_pos = 1
		elseif fcc_sec1 == 0 then
			A333_sec1_pos = 0
		end
	end
end




function A333_fcc_sec2_toggleCMDhandler(phase, duration)
	if phase == 0 then
		if A333_sec2_pos == 0 then
			A333_sec2_pos = 1.2
			fcc_sec2 = 1
		elseif A333_sec2_pos == 1 then
			A333_sec2_pos = 1.2
			fcc_sec2 = 0
		end
	elseif phase == 2 then
		if fcc_sec2 == 1 then
			A333_sec2_pos = 1
		elseif fcc_sec2 == 0 then
			A333_sec2_pos = 0
		end
	end
end




-- ECAM CONTROL PANEL
function A333_ecam_button_eng_CMDhandler(phase, duration)
	if phase == 0 then
        A333_ecam_button_eng_pos = 1
            if A333DR_ecp_pushbutton_process_step[1] == 0 then
                A333DR_ecp_pushbutton_process_step[1] = 1
            end
	elseif phase == 2 then
		A333_ecam_button_eng_pos = 0
	end
end




function A333_ecam_button_bleed_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_bleed_pos = 1
        if A333DR_ecp_pushbutton_process_step[2] == 0 then
            A333DR_ecp_pushbutton_process_step[2] = 1
        end
	elseif phase == 2 then
		A333_ecam_button_bleed_pos = 0
	end
end




function A333_ecam_button_press_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_press_pos = 1
        if A333DR_ecp_pushbutton_process_step[3] == 0 then
            A333DR_ecp_pushbutton_process_step[3] = 1
        end
	elseif phase == 2 then
		A333_ecam_button_press_pos = 0
	end
end




function A333_ecam_button_el_ac_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_el_ac_pos = 1
        if A333DR_ecp_pushbutton_process_step[4] == 0 then
            A333DR_ecp_pushbutton_process_step[4] = 1
        end
	elseif phase == 2 then
		A333_ecam_button_el_ac_pos = 0
	end
end




function A333_ecam_button_el_dc_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_el_dc_pos = 1
        if A333DR_ecp_pushbutton_process_step[5] == 0 then
            A333DR_ecp_pushbutton_process_step[5] = 1
        end
	elseif phase == 2 then
		A333_ecam_button_el_dc_pos = 0
	end
end




function A333_ecam_button_hyd_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_hyd_pos = 1
        if A333DR_ecp_pushbutton_process_step[6] == 0 then
            A333DR_ecp_pushbutton_process_step[6] = 1
        end
	elseif phase == 2 then
		A333_ecam_button_hyd_pos = 0
	end
end




function A333_ecam_button_cbs_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_cbs_pos = 1
        if A333DR_ecp_pushbutton_process_step[7] == 0 then
            A333DR_ecp_pushbutton_process_step[7] = 1
        end
	elseif phase == 2 then
		A333_ecam_button_cbs_pos = 0
	end
end




function A333_ecam_button_apu_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_apu_pos = 1
        if A333DR_ecp_pushbutton_process_step[8] == 0 then
            A333DR_ecp_pushbutton_process_step[8] = 1
        end
	elseif phase == 2 then
		A333_ecam_button_apu_pos = 0
	end
end




function A333_ecam_button_cond_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_cond_pos = 1
        if A333DR_ecp_pushbutton_process_step[9] == 0 then
            A333DR_ecp_pushbutton_process_step[9] = 1
        end
	elseif phase == 2 then
		A333_ecam_button_cond_pos = 0
	end
end




function A333_ecam_button_door_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_door_pos = 1
        if A333DR_ecp_pushbutton_process_step[10] == 0 then
            A333DR_ecp_pushbutton_process_step[10] = 1
        end
	elseif phase == 2 then
		A333_ecam_button_door_pos = 0
	end
end




function A333_ecam_button_wheel_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_wheel_pos = 1
        if A333DR_ecp_pushbutton_process_step[11] == 0 then
            A333DR_ecp_pushbutton_process_step[11] = 1
        end
	elseif phase == 2 then
		A333_ecam_button_wheel_pos = 0
	end
end




function A333_ecam_button_f_ctl_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_f_ctl_pos = 1
        if A333DR_ecp_pushbutton_process_step[12] == 0 then
            A333DR_ecp_pushbutton_process_step[12] = 1
        end
	elseif phase == 2 then
		A333_ecam_button_f_ctl_pos = 0
	end
end




function A333_ecam_button_fuel_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_fuel_pos = 1
        if A333DR_ecp_pushbutton_process_step[13] == 0 then
            A333DR_ecp_pushbutton_process_step[13] = 1
        end
	elseif phase == 2 then
		A333_ecam_button_fuel_pos = 0
	end
end




function A333_ecam_button_all_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_all_pos = 1
        A333DR_ecp_pushbutton_process_step[14] = 0.5
	elseif phase == 2 then
		A333_ecam_button_all_pos = 0
        A333DR_ecp_pushbutton_process_step[14] = 0
	end
end




function A333_ecam_button_to_config_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_to_config_pos = 1
	elseif phase == 2 then
		A333_ecam_button_to_config_pos = 0
	end
end




function A333_ecam_button_clr_capt_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_clr_capt_pos = 1
		if A333DR_ecp_pushbutton_process_step[17] == 0 then
			A333DR_ecp_pushbutton_process_step[17] = 1
		end
	elseif phase == 2 then
		A333_ecam_button_clr_capt_pos = 0
	end
end




function A333_ecam_button_clr_fo_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_clr_fo_pos = 1
		if A333DR_ecp_pushbutton_process_step[20] == 0 then
			A333DR_ecp_pushbutton_process_step[20] = 1
		end
	elseif phase == 2 then
		A333_ecam_button_clr_fo_pos = 0
	end
end




function A333_ecam_button_sts_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_sts_pos = 1
        if A333DR_ecp_pushbutton_process_step[15] == 0 then
            A333DR_ecp_pushbutton_process_step[15] = 1
        end
	elseif phase == 2 then
		A333_ecam_button_sts_pos = 0
        A333DR_ecp_pushbutton_process_step[15] = 0
	end
end




function A333_ecam_button_rcl_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_button_rcl_pos = 1
		if A333DR_ecp_pushbutton_process_step[19] == 0 then
			A333DR_ecp_pushbutton_process_step[19] = 1
		end
	elseif phase == 2 then
		A333_ecam_button_rcl_pos = 0
	end
end




function A333_ecam_button_emer_cancel_CMDhandler(phase, duration)		-- TODO: NOT IMPLEMENTED
	if phase == 0 then
		A333_ecam_button_emer_cancel_pos = 1
	elseif phase == 2 then
		A333_ecam_button_emer_cancel_pos = 0
	end
end




-- EVAC
function A333_evac_command_togCMDhandler(phase, duration)
    if phase == 0 then
        switch_start_pos.evac_command = A333_evac_command_pos
        A333_evac_command_pos = 1.2
        if switch_start_pos.evac_command == 0 then
            A333_buttons_evac_cmd_ctct_on_off = 1
            A333_evac_horn_on = 1
        end
    elseif phase == 2 then
        A333_evac_command_pos = 1 - switch_start_pos.evac_command
        if switch_start_pos.evac_command == 1 then A333_buttons_evac_cmd_ctct_on_off = 0 end
    end
end








function A333_evac_horn_off_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_evac_horn_off_pos = 1
		A333_evac_horn_on = 0
	elseif phase == 2 then
		A333_evac_horn_off_pos = 0
	end
end




function A333_evac_capt_purs_upCMDhandler(phase, duration)
	if phase == 0 then
		if A333_evac_capt_purs_pos == 0 then
			A333_evac_capt_purs_pos = 1
		end
	end
end




function A333_evac_capt_purs_dnCMDhandler(phase, duration)
	if phase == 0 then
		if A333_evac_capt_purs_pos == 1 then
			A333_evac_capt_purs_pos = 0
		end
	end
end




function A333_emer_elec_gen_test_CMDhandler(phase, duration)
    if phase == 0 then
        A333_emer_gen_test_button_pos = 1
    elseif phase == 2 then
        A333_emer_gen_test_button_pos = 0
    end
end




function A333_emer_gen_man_on_CMDhandler(phase, duration)
    if phase == 0 then
        switch_start_pos.emer_gen_man_on = A333_emer_gen_man_on_button_pos
        A333_emer_gen_man_on_button_pos = 1.2
        if switch_start_pos.emer_gen_man_on == 0 then
            A333_buttons_emer_gen_man_on_ctct_on_off = 1
        end
    elseif phase == 2 then
        A333_emer_gen_man_on_button_pos = 1 - switch_start_pos.emer_gen_man_on
        if switch_start_pos.emer_gen_man_on == 1 then A333_buttons_emer_gen_man_on_ctct_on_off = 0 end
    end
end





function A333_ditching_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_ditching_pos == 0 then
			A333_ditching_pos = 1.2
			A333_ditching_status = 1
		elseif A333_ditching_pos == 1 then
			A333_ditching_pos = 1.2
			A333_ditching_status = 0
		end
	elseif phase == 2 then
		if A333_ditching_status == 1 then
			A333_ditching_pos = 1
		elseif A333_ditching_status == 0 then
			A333_ditching_pos = 0
		end
	end
end




function A333_ventilation_extract_ovrd_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_ventilation_extract_ovrd_pos == 0 then
			A333_ventilation_extract_ovrd_pos = 1.2
			A333_ventilation_extract_status = 1
		elseif A333_ventilation_extract_ovrd_pos == 1 then
			A333_ventilation_extract_ovrd_pos = 1.2
			A333_ventilation_extract_status = 0
		end
	elseif phase == 2 then
		if A333_ventilation_extract_status == 1 then
			A333_ventilation_extract_ovrd_pos = 1
		elseif A333_ventilation_extract_status == 0 then
			A333_ventilation_extract_ovrd_pos = 0
		end
	end
end




-- BAROMETER
function A333_pull_std_capt_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_capt_pull_std_pos = -1
		if simDR_captain_baro_is_std == 1 then
			simDR_captain_barometer = capt_baro_mem
		end
		simDR_captain_baro_is_std = 0
	elseif phase == 2 then
		A333_capt_pull_std_pos = 0
	end
end




function A333_pull_std_capt_pullCMDhandler(phase, duration)
	if phase == 0 then
		A333_capt_pull_std_pos = 1
		if simDR_captain_baro_is_std == 0 then
			capt_baro_mem = simDR_captain_barometer
		end
		simDR_captain_baro_is_std = 1
	elseif phase == 2 then
		A333_capt_pull_std_pos = 0
	end
end




function A333_pull_std_fo_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_fo_pull_std_pos = -1
		if simDR_first_officer_baro_is_std == 1 then
			simDR_first_officer_barometer = fo_baro_mem
		end
		simDR_first_officer_baro_is_std = 0
	elseif phase == 2 then
		A333_fo_pull_std_pos = 0
	end
end




function A333_pull_std_fo_pullCMDhandler(phase, duration)
	if phase == 0 then
		A333_fo_pull_std_pos = 1
		if simDR_first_officer_baro_is_std == 0 then
			fo_baro_mem = simDR_first_officer_barometer
		end
		simDR_first_officer_baro_is_std = 1
	elseif phase == 2 then
		A333_fo_pull_std_pos = 0
	end
end




function A333_capt_inHg_CMDhandler(phase, duration)
	if phase == 0 then
		A333_capt_baro_inHg_hPa_pos = 0
	end
end

function A333_capt_hPa_CMDhandler(phase, duration)
	if phase == 0 then
		A333_capt_baro_inHg_hPa_pos = 1
	end
end




function A333_capt_inHg_hPa_CMDhandler(phase, duration)
    if phase == 0 then
        if A333_capt_baro_inHg_hPa_pos == 0 then
            A333_capt_baro_inHg_hPa_pos = 1
        else
            A333_capt_baro_inHg_hPa_pos = 0
        end
    end
end




function A333_fo_inHg_CMDhandler(phase, duration)
	if phase == 0 then
		A333_fo_baro_inHg_hPa_pos = 0
	end
end




function A333_fo_hPa_CMDhandler(phase, duration)
	if phase == 0 then
		A333_fo_baro_inHg_hPa_pos = 1
	end
end




function A333_fo_inHg_hPa_CMDhandler(phase, duration)
    if phase == 0 then
        if A333_fo_baro_inHg_hPa_pos == 0 then
            A333_fo_baro_inHg_hPa_pos = 1
        else
            A333_fo_baro_inHg_hPa_pos = 0
        end
    end
end




function A333_capt_ils_bars_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_capt_ils_bars_pos = 1
		if A333_capt_ls_bars_status == 0 then
			A333_capt_ls_bars_status = 1
		elseif A333_capt_ls_bars_status == 1 then
			A333_capt_ls_bars_status = 0
		end
	elseif phase == 2 then
		A333_capt_ils_bars_pos = 0
	end
end




function A333_fo_ils_bars_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_fo_ils_bars_pos = 1
		if A333_fo_ls_bars_status == 0 then
			A333_fo_ls_bars_status = 1
		elseif A333_fo_ls_bars_status == 1 then
			A333_fo_ls_bars_status = 0
		end
	elseif phase == 2 then
		A333_fo_ils_bars_pos = 0
	end
end
















-- THREE POSITION LIGHTING SWITCHES
function A333_capt_console_light_up_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_generic_brightness[10] == 0 then
			simDR_generic_brightness[10] = 0.5
		elseif simDR_generic_brightness[10] == 0.5 then
			simDR_generic_brightness[10] = 1
		end
	end
end




function A333_capt_console_light_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_generic_brightness[10] == 1 then
			simDR_generic_brightness[10] = 0.5
		elseif simDR_generic_brightness[10] == 0.5 then
			simDR_generic_brightness[10] = 0
		end
	end
end




function A333_fo_console_light_up_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_generic_brightness[13] == 0 then
			simDR_generic_brightness[13] = 0.5
		elseif simDR_generic_brightness[13] == 0.5 then
			simDR_generic_brightness[13] = 1
		end
	end
end




function A333_fo_console_light_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_generic_brightness[13] == 1 then
			simDR_generic_brightness[13] = 0.5
		elseif simDR_generic_brightness[13] == 0.5 then
			simDR_generic_brightness[13] = 0
		end
	end
end




function A333_taxi_light_up_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_landing_light_brightness[1] == 0 then
			simDR_landing_light_brightness[1] = 0.5
		elseif simDR_landing_light_brightness[1] == 0.5 then
			simDR_landing_light_brightness[1] = 1
		end
	end
end





function A333_taxi_light_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_landing_light_brightness[1] == 1 then
			simDR_landing_light_brightness[1] = 0.5
		elseif simDR_landing_light_brightness[1] == 0.5 then
			simDR_landing_light_brightness[1] = 0
		end
	end
end




function A333_taxi_light_off_CMDhandler(phase, duration)
	if phase == 0 then
    	simDR_landing_light_brightness[1] = 0
	end
end




function A333_taxi_light_taxi_CMDhandler(phase, duration)
	if phase == 0 then
    	simDR_landing_light_brightness[1] = 0.5
	end
end




function A333_taxi_light_to_CMDhandler(phase, duration)
	if phase == 0 then
    	simDR_landing_light_brightness[1] = 1
	end
end




-- ENGINE MODE SELECTOR
function A333_eng_mode_left_CMDhandler(phase, duration)
	if phase == 0 then
		if A333DR_eng_mode_selector_pos == 1 then
			A333DR_eng_mode_selector_pos = 0
		elseif A333DR_eng_mode_selector_pos == 0 then
			A333DR_eng_mode_selector_pos = -1
		end
	end
end




function A333_eng_mode_right_CMDhandler(phase, duration)
	if phase == 0 then
		if A333DR_eng_mode_selector_pos == -1 then
			A333DR_eng_mode_selector_pos = 0
		elseif A333DR_eng_mode_selector_pos == 0 then
			A333DR_eng_mode_selector_pos = 1
		end
	end
end




-- PARKING BRAKE
function A333_parking_brake_left_CMDhandler(phase, duration)
	if phase == 0 then
		park_brake_switch_pos_target = 0
	end
end

function A333_parking_brake_right_CMDhandler(phase, duration)
	if phase == 0 then
		park_brake_switch_pos_target = 1
	end
end




-- AI
function A333_ai_switches_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	A333_set_switches_all_modes()
	  	A333_set_switches_CD()
	  	A333_set_switches_ER()
	end
end




function A333_weather_radar_mode_left_CMDhander(phase, duration)
	if phase == 0 then
		if A333_weather_radar_mode_pos == 3 then
			A333_weather_radar_mode_pos = 2
		elseif A333_weather_radar_mode_pos == 2 then
			A333_weather_radar_mode_pos = 1
		elseif A333_weather_radar_mode_pos == 1 then
			A333_weather_radar_mode_pos = 0
		end
	end
end




function A333_weather_radar_mode_right_CMDhander(phase, duration)
	if phase == 0 then
		if A333_weather_radar_mode_pos == 0 then
			A333_weather_radar_mode_pos = 1
		elseif A333_weather_radar_mode_pos == 1 then
			A333_weather_radar_mode_pos = 2
		elseif A333_weather_radar_mode_pos == 2 then
			A333_weather_radar_mode_pos = 3
		end
	end
end


function A333_crew_supply_togCMDhandler(phase, duration)
	if phase == 0 then
		if A333_crew_oxy_pos == 0 then
			A333_crew_oxy_pos = 1.2
			A333_crew_supply_status = 1
		elseif A333_crew_oxy_pos == 1 then
			A333_crew_oxy_pos = 1.2
			A333_crew_supply_status = 0
		end
	elseif phase == 2 then
		if A333_crew_supply_status == 1 then
			A333_crew_oxy_pos = 1
		elseif A333_crew_supply_status == 0 then
			A333_crew_oxy_pos = 0
		end
	end
end


function A333_eng1_fadec_ground_pwr_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_eng1_fadec_ground_pwr_pos == 0 then
			A333_eng1_fadec_ground_pwr_pos = 1.2
			A333_eng1_fadec_ground_pwr_cntr = 1
		elseif A333_eng1_fadec_ground_pwr_pos == 1 then
			A333_eng1_fadec_ground_pwr_pos = 1.2
			A333_eng1_fadec_ground_pwr_cntr = 0
		end
	elseif phase == 2 then
		if A333_eng1_fadec_ground_pwr_cntr == 1 then
			A333_eng1_fadec_ground_pwr_pos = 1
		elseif A333_eng1_fadec_ground_pwr_cntr == 0 then
			A333_eng1_fadec_ground_pwr_pos = 0
		end
	end
end

function A333_eng2_fadec_ground_pwr_toggle_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_eng2_fadec_ground_pwr_pos == 0 then
			A333_eng2_fadec_ground_pwr_pos = 1.2
			A333_eng2_fadec_ground_pwr_cntr = 1
		elseif A333_eng2_fadec_ground_pwr_pos == 1 then
			A333_eng2_fadec_ground_pwr_pos = 1.2
			A333_eng2_fadec_ground_pwr_cntr = 0
		end
	elseif phase == 2 then
		if A333_eng2_fadec_ground_pwr_cntr == 1 then
			A333_eng2_fadec_ground_pwr_pos = 1
		elseif A333_eng2_fadec_ground_pwr_cntr == 0 then
			A333_eng2_fadec_ground_pwr_pos = 0
		end
	end
end

function A333_stdby_std_tog_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_standby_std_button_pos == 0 then
			A333_standby_std_button_pos = 1
			if A333_standby_std_state == 0 then
				A333_standby_std_state = 1
			else A333_standby_std_state = 0
			end
		end
	elseif phase == 2 then
		A333_standby_std_button_pos = 0
	end
end

function A333_stdby_ls_tog_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_standby_ls_button_pos == 0 then
			A333_standby_ls_button_pos = 1
			if A333_standby_ls_state == 0 then
				A333_standby_ls_state = 1
			else A333_standby_ls_state = 0
			end
		end
	elseif phase == 2 then
		A333_standby_ls_button_pos = 0
	end
end

function A333_stdby_bugs_tog_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_standby_bugs_button_pos == 0 then
			A333_standby_bugs_button_pos = 1
			if A333_standby_bugs_state == 0 then
				A333_standby_bugs_state = 1
			else A333_standby_bugs_state = 0
			end
		end
	elseif phase == 2 then
		A333_standby_bugs_button_pos = 0
	end
end

function A333_stdby_rst_tog_CMDhandler(phase, duration)
	if phase == 0 then
		A333_standby_rst_button_pos = 1
	elseif phase == 1 then
		A333_standby_rst_timer = A333_standby_rst_timer + lcl_SIM_PERIOD
	elseif phase == 2 then
		A333_standby_rst_button_pos = 0
		A333_standby_rst_timer = 0
	end
end


--*************************************************************************************--
--** 				                 CUSTOM COMMANDS                			     **--
--*************************************************************************************--

----- BUTTON SWITCH COVERS --------------------------------------------------------------
A333CMD_button_switch_cover = {}
for i = 0, NUM_BTN_SW_COVERS-1 do
    A333CMD_button_switch_cover[i] = create_command("laminar/A333/button_switch_cover" .. string.format("%02d", i), "Button Switch Cover" .. string.format("%02d", i), A333_button_switch_cover_CMDhandler[i])
end



A333CMD_guard_cover = {}
for i = 0, NUM_GUARD_COVERS-1 do
	A333CMD_guard_cover[i] = create_command("laminar/A333/guard_cover" .. string.format("%02d", i), "Guard Cover" .. string.format("%02d", i), A333_guard_cover_CMDhandler[i])
end



----- EFIS -----
A333CMD_capt_efis_knob_mode_left		= create_command("laminar/A333/knobs/capt_EFIS_knob_left", "Captain EFIS Mode Knob Left", A333_capt_EFIS_knob_left_CMDhandler)
A333CMD_capt_efis_knob_mode_right		= create_command("laminar/A333/knobs/capt_EFIS_knob_right", "Captain EFIS Mode Knob Right", A333_capt_EFIS_knob_right_CMDhandler)

A333CMD_fo_efis_knob_mode_left			= create_command("laminar/A333/knobs/fo_EFIS_knob_left", "F/O EFIS Mode Knob Left", A333_fo_EFIS_knob_left_CMDhandler)
A333CMD_fo_efis_knob_mode_right			= create_command("laminar/A333/knobs/fo_EFIS_knob_right", "F/O EFIS Mode Knob Right", A333_fo_EFIS_knob_right_CMDhandler)

A333CMD_capt_efis_CSTR					= create_command("laminar/A333/buttons/capt_EFIS_CSTR", "Captain EFIS Constraint Button", A333_capt_EFIS_CSTR_CMDhandler)
A333CMD_fo_efis_CSTR					= create_command("laminar/A333/buttons/fo_EFIS_CSTR", "F/O EFIS Constraint Button", A333_fo_EFIS_CSTR_CMDhandler)

A333CMD_efis_tru_north					= create_command("laminar/A333/buttons/EFIS_tru_north", "True North Reference Button", A333_EFIS_tru_north_CMDhandler)

A333CMD_weather_radar_left				= create_command("laminar/A333/switches/weather_radar_left", "Weather Radar Left Switch", A333_weather_radar_left_CMDhandler)
A333CMD_weather_radar_right				= create_command("laminar/A333/switches/weather_radar_right", "Weather Radar Right Switch", A333_weather_radar_right_CMDhandler)

A333CMD_pfd_nd_capt_swap				= create_command("laminar/A333/buttons/pfd_nd_capt_swap", "PFD/ND Swap Captain Side", A333_pfd_nd_capt_swapCMDhandler)
A333CMD_pfd_nd_fo_swap					= create_command("laminar/A333/buttons/pfd_nd_fo_swap", "PFD/ND Swap F/O Side", A333_pfd_nd_fo_swapCMDhandler)

A333CMD_capt_ils_bars_push				= create_command("laminar/A333/buttons/capt_ils_bars_push", "Captain LS Bars Toggle", A333_capt_ils_bars_pushCMDhandler)
A333CMD_fo_ils_bars_push				= create_command("laminar/A333/buttons/fo_ils_bars_push", "F/O LS Bars Toggle", A333_fo_ils_bars_pushCMDhandler)

A333CMD_weather_radar_mode_left			= create_command("laminar/A333/switches/weather_radar_mode_left", "Weather Radar Mode Left", A333_weather_radar_mode_left_CMDhander)
A333CMD_weather_radar_mode_right		= create_command("laminar/A333/switches/weather_radar_mode_right", "Weather Radar Mode Right", A333_weather_radar_mode_right_CMDhander)

----- SMOKING/SEATBELTS -----
A333CMD_seatbelt_signs_up				= create_command("laminar/A333/switches/seatbelt_signs_up", "Seatbelt Signs Switch Up", A333_seatbelt_signs_up_CMDhandler)
A333CMD_seatbelt_signs_dn				= create_command("laminar/A333/switches/seatbelt_signs_dn", "Seatbelt Signs Switch Down", A333_seatbelt_signs_dn_CMDhandler)

A333CMD_smoking_signs_up				= create_command("laminar/A333/switches/smoking_signs_up", "No Smoking Signs Switch Up", A333_smoking_signs_up_CMDhandler)
A333CMD_smoking_signs_dn				= create_command("laminar/A333/switches/smoking_signs_dn", "No Smoking Signs Switch Down", A333_smoking_signs_dn_CMDhandler)

----- APU -----
A333CMD_apu_master_sw_toggle			= create_command("laminar/A333/buttons/APU_master", "APU Master Switch", A333_apu_master_sw_toggle_CMDhandler)
A333CMD_apu_start_sw_push				= create_command("laminar/A333/buttons/APU_start", "APU Starter Switch", A333_apu_start_sw_toggle_CMDhandler)

----- ANTI ICE -----
A333CMD_probe_window_heat_toggle		= create_command("laminar/A333/buttons/probe_window_heat_toggle", "Probe/Window Heat Switch", A333_probe_window_heat_toggle_CMDhandler)

----- DOOR LOCK -----
--A333CMD_cockpit_door_lock_up			= create_command("laminar/A333/switches/cockpit_door_lock_up", "Cockpit Door Lock Up", A333_cockpit_door_lock_up_CMDhandler)
--A333CMD_cockpit_door_lock_dn			= create_command("laminar/A333/switches/cockpit_door_lock_dn", "Cockpit Door Lock Down", A333_cockpit_door_lock_dn_CMDhandler)
--A333CMD_cockpit_door_lock_switch_up		= create_command("laminar/A333/switches/cockpit_door_lock_up", "Cockpit Door Lock Switch Up", A333_cockpit_door_lock_switch_up_CMDhandler)
--A333CMD_cockpit_door_lock_switch_dn		= create_command("laminar/A333/switches/cockpit_door_lock_dn", "Cockpit Door Lock Switch Down", A333_cockpit_door_lock_switch_dn_CMDhandler)
--A333CMD_cockpit_door_keypad				= create_command("laminar/A333/buttons/cockpit_door_keypad", "COCKPIT DOOR KEYPAD", A333_cockpit_door_keypad_CMDhandler)

----- DOOR LOCK -----
--A333CMD_cockpit_door_lock_up			= create_command("laminar/A333/switches/cockpit_door_lock_up", "Cockpit Door Lock Up", A333_cockpit_door_lock_up_CMDhandler)
--A333CMD_cockpit_door_lock_dn			= create_command("laminar/A333/switches/cockpit_door_lock_dn", "Cockpit Door Lock Down", A333_cockpit_door_lock_dn_CMDhandler)
A333CMD_cockpit_door_lock_switch_up		= create_command("laminar/A333/switches/cockpit_door_lock_up", "Cockpit Door Lock Switch Up", A333_cockpit_door_lock_switch_up_CMDhandler)
A333CMD_cockpit_door_lock_switch_dn		= create_command("laminar/A333/switches/cockpit_door_lock_dn", "Cockpit Door Lock Switch Down", A333_cockpit_door_lock_switch_dn_CMDhandler)
A333CMD_cockpit_door_keypad				= create_command("laminar/A333/buttons/cockpit_door_keypad", "COCKPIT DOOR KEYPAD", A333_cockpit_door_keypad_CMDhandler)
A333CMD_cockpit_door_keypad_hash		= create_command("laminar/A333/buttons/cockpit_door_keypad_hash", "COCKPIT DOOR KEYPAD HASH", A333_cockpit_door_keypad_hash_CMDhandler)


----- APU GENS BATTS IDG ELEC -----
A333CMD_apu_battery_toggle				= create_command("laminar/A333/buttons/APU_batt_toggle", "APU Battery Toggle", A333_apu_battery_toggle_CMDhandler)
A333CMD_battery_select_up				= create_command("laminar/A333/switches/battery_display_up", "Battery Display Select Up", A333_batt_sel_up_CMDhandler)
A333CMD_battery_select_dn				= create_command("laminar/A333/switches/battery_display_dn", "Battery Display Select Down", A333_batt_sel_dn_CMDhandler)
A333CMD_apu_generator_toggle			= create_command("laminar/A333/buttons/APU_gen_toggle", "APU Generator Toggle", A333_apu_gen_toggle_CMDhandler)

A333CMD_idg_disconnect1_toggle			= create_command("laminar/A333/buttons/IDG1_disconnect", "IDG1 Disconnect", A333_idg1_disconnect_CMDhandler)
A333CMD_idg_disconnect2_toggle			= create_command("laminar/A333/buttons/IDG2_disconnect", "IDG2 Disconnect", A333_idg2_disconnect_CMDhandler)

A333CMD_ext_powerA_toggle				= create_command("laminar/A333/buttons/external_powerA_toggle", "External Power A", A333_ext_powerA_toggle_CMDhandler)
A333CMD_ext_powerB_toggle				= create_command("laminar/A333/buttons/external_powerB_toggle", "External Power B", A333_ext_powerB_toggle_CMDhandler)
A333CMD_AC_ESS_feed_toggle				= create_command("laminar/A333/buttons/ACESSFeed_toggle", "AC ESS Feed", A333_ac_ess_feed_toggle_CMDhandler)
A333CMD_galley_pwr_toggle				= create_command("laminar/A333/buttons/galley_toggle", "Galley Power", A333_galley_pwr_toggle_CMDhandler)
A333CMD_commercial_pwr_toggle			= create_command("laminar/A333/buttons/commercial_toggle", "Commercial Power", A333_commercial_pwr_toggle_CMDhandler)

----- PRESSURIZATION / AIR -----
A333CMD_pack_flow_knob_left				= create_command("laminar/A333/knobs/press_press_flow_left", "Pack Flow Knob Left", A333_pack_flow_knob_left_CMDhandler)
A333CMD_pack_flow_knob_right			= create_command("laminar/A333/knobs/press_press_flow_right", "Pack Flow Knob Right", A333_pack_flow_knob_right_CMDhandler)

A333CMD_isol_valve_knob_left			= create_command("laminar/A333/knobs/press_isol_valve_left", "Bleed Duct Isolation Valve Knob Left", A333_isol_valve_knob_left_CMDhandler)
A333CMD_isol_valve_knob_right			= create_command("laminar/A333/knobs/press_isol_valve_right", "Bleed Duct Isolation Valve Knob Left", A333_isol_valve_knob_right_CMDhandler)

A333CMD_hot_air1_toggle					= create_command("laminar/A333/switches/hot_air1_toggle", "Hot Air 1 Toggle", A333_hot_air1_toggle_CMDhandler)
A333CMD_hot_air2_toggle					= create_command("laminar/A333/switches/hot_air2_toggle", "Hot Air 2 Toggle", A333_hot_air2_toggle_CMDhandler)
A333CMD_ram_air_toggle					= create_command("laminar/A333/switches/ram_air_toggle", "Emergency Ram Air Toggle", A333_ram_air_toggle_CMDhandler)

----- FUEL SYSTEM -----
A333CMD_left_fuel_pump1_toggle			= create_command("laminar/A333/switches/left1_pump_toggle", "Left 1 Fuel Pump", A333_left_fuel_pump1_toggleCMDhandler)
A333CMD_left_fuel_pump2_toggle			= create_command("laminar/A333/switches/left2_pump_toggle", "Left 2 Fuel Pump", A333_left_fuel_pump2_toggleCMDhandler)
A333CMD_left_stby_fuel_pump_toggle		= create_command("laminar/A333/switches/left_stby_pump_toggle", "Left Standby Fuel Pump", A333_left_stby_fuel_pump_toggleCMDhandler)

A333CMD_right_fuel_pump1_toggle			= create_command("laminar/A333/switches/right1_pump_toggle", "Right 1 Fuel Pump", A333_right_fuel_pump1_toggleCMDhandler)
A333CMD_right_fuel_pump2_toggle			= create_command("laminar/A333/switches/right2_pump_toggle", "Right 2 Fuel Pump", A333_right_fuel_pump2_toggleCMDhandler)
A333CMD_right_stby_fuel_pump_toggle		= create_command("laminar/A333/switches/right_stby_pump_toggle", "Right Standby Fuel Pump", A333_right_stby_fuel_pump_toggleCMDhandler)

A333CMD_center_left_fuel_pump_toggle	= create_command("laminar/A333/switches/center_left_pump_toggle", "Left Center Fuel Pump", A333_center_left_fuel_pump_toggleCMDhandler)
A333CMD_center_right_fuel_pump_toggle	= create_command("laminar/A333/switches/center_right_pump_toggle", "Right Center Fuel Pump", A333_center_right_fuel_pump_toggleCMDhandler)

A333CMD_wing_x_feed_toggle				= create_command("laminar/A333/switches/wing_x_feed_toggle", "Wing X Feed", A333_wing_x_feed_toggleCMDhandler)

A333CMD_center_tank_xfr_toggle			= create_command("laminar/A333/switches/center_xfr_toggle", "Center XFR Pump", A333_center_tank_xfr_toggleCMDhandler)
A333CMD_trim_tank_xfr_toggle			= create_command("laminar/A333/switches/trim_xfr_toggle", "Trim XFR FWD Pump", A333_trim_tank_xfr_toggleCMDhandler)
A333CMD_outer_tank_xfr_toggle			= create_command("laminar/A333/switches/outer_tank_xfr_toggle", "Outer Tank XFR Pump", A333_outer_tank_xfr_toggleCMDhandler)

A333CMD_trim_tank_feed_mode_up			= create_command("laminar/A333/switches/trim_tank_feed_up", "Trim Tank Feed Mode Up", A333_trim_tank_feed_mode_upCMDhandler)
A333CMD_trim_tank_feed_mode_dn			= create_command("laminar/A333/switches/trim_tank_feed_dn", "Trim Tank Feed Mode Down", A333_trim_tank_feed_mode_dnCMDhandler)

----- HYDRAULICS -----
A333CMD_hyd_rat_man_on			        = create_command("laminar/A330/buttons/hyd/rat_man_on", "Hydraulic RAT Manual On", A333_hyd_rat_man_on_CMDhandler)

A333CMD_elec_green_on					= create_command("laminar/A330/buttons/hyd/elec_green_on", "Green Electric Hydraulic Pump ON", A333_green_elec_hyd_pump_onCMDhandler)
A333CMD_elec_blue_on					= create_command("laminar/A330/buttons/hyd/elec_blue_on", "Blue Electric Hydraulic Pump ON", A333_blue_elec_hyd_pump_onCMDhandler)
A333CMD_elec_yellow_on					= create_command("laminar/A330/buttons/hyd/elec_yellow_on", "Yellow Electric Hydraulic Pump ON", A333_yellow_elec_hyd_pump_onCMDhandler)

A333CMD_elec_green_off_tog				= create_command("laminar/A330/buttons/hyd/elec_green_toggle", "Green Electric Hydraulic Pump OFF/AUTO", A333_green_elec_hyd_pump_togCMDhandler)
A333CMD_elec_blue_off_tog				= create_command("laminar/A330/buttons/hyd/elec_blue_toggle", "Blue Electric Hydraulic Pump OFF/AUTO", A333_blue_elec_hyd_pump_togCMDhandler)
A333CMD_elec_yellow_off_tog				= create_command("laminar/A330/buttons/hyd/elec_yellow_toggle", "Yellow Electric Hydraulic Pump OFF/AUTO", A333_yellow_elec_hyd_pump_togCMDhandler)

A333CMD_leak_measure_g_tog				= create_command("laminar/A333/buttons/hyd/leak_measurement_g", "Green Leak Measurement Valve ON/OFF", A333_green_leak_measure_off_togCMDhandler)
A333CMD_leak_measure_b_tog				= create_command("laminar/A333/buttons/hyd/leak_measurement_b", "Blue Leak Measurement Valve ON/OFF", A333_blue_leak_measure_off_togCMDhandler)
A333CMD_leak_measure_y_tog				= create_command("laminar/A333/buttons/hyd/leak_measurement_y", "Yellow Leak Measurement Valve ON/OFF", A333_yellow_leak_measure_off_togCMDhandler)

-- GPWS SYSTEMS
A333CMD_gpws_terr_tog					= create_command("laminar/A333/buttons/gpws/terr_toggle", "Terrain Awareness Display ON/OFF", A333_gpws_terr_toggleCMDhandler)
A333CMD_gpws_system_tog					= create_command("laminar/A333/buttons/gpws/sys_toggle","GPWS System ON/OFF", A333_gpws_sys_toggleCMDhandler)
A333CMD_gpws_GS_mode_tog				= create_command("laminar/A333/buttons/gpws/gs_mode_toggle", "GPWS Glide Slope Mode ON/OFF", A333_gpws_GS_toggleCMDhandler)
A333CMD_gpws_flap_mode_tog				= create_command("laminar/A333/buttons/gpws/flap_mode_toggle", "GPWS Flap Mode ON/OFF", A333_gpws_flap_toggleCMDhandler)

A333CMD_gpws_gs_canx_capt				= create_command("laminar/A333/buttons/gpws/gs_canx_capt", "GPWS G/S Cancel - Capt", A333_gpws_gs_canx_capt_CMDhandler)
A333CMD_gpws_gs_canx_fo					= create_command("laminar/A333/buttons/gpws/gs_canx_fo", "GPWS G/S Cancel - F/O", A333_gpws_gs_canx_fo_CMDhandler)

-- CALL BUTTONS
A333CMD_call_mech						= create_command("laminar/A333/buttons/call/mech_push", "Mechanical Call", A333_call_mech_pushCMDhandler)
A333CMD_call_flt_rest					= create_command("laminar/A333/buttons/call/flt_rest_push", "Flight Rest Call", A333_call_flight_rest_pushCMDhandler)
A333CMD_call_cab_rest					= create_command("laminar/A333/buttons/call/cab_rest_push", "Cabin Rest Call", A333_call_cabin_rest_pushCMDhandler)
A333CMD_call_all						= create_command("laminar/A333/buttons/call/all_push", "ALL Call", A333_call_ALL_pushCMDhandler)
A333CMD_call_purs						= create_command("laminar/A333/buttons/call/purs_push", "Purser Call", A333_call_purser_pushCMDhandler)
A333CMD_call_fwd						= create_command("laminar/A333/buttons/call/fwd_push", "FWD Station Call", A333_call_fwd_pushCMDhandler)
A333CMD_call_mid						= create_command("laminar/A333/buttons/call/mid_push", "MID Station Call", A333_call_mid_pushCMDhandler)
A333CMD_call_exit						= create_command("laminar/A333/buttons/call/exit_push", "Exit Station Call", A333_call_exit_pushCMDhandler)
A333CMD_call_aft						= create_command("laminar/A333/buttons/call/aft_push", "AFT Station Call", A333_call_aft_pushCMDhandler)
A333CMD_call_emergency_tog				= create_command("laminar/A333/buttons/call/emergency_toggle", "Emergency Call", A333_call_emergency_toggleCMDhandler)

-- MISC
A333CMD_rain_repellent_capt				= create_command("laminar/A333/buttons/misc/rain_repellent_capt", "Captain Rain Repellent, DEACTIVATED", A333_rain_repellent_capt_pushCMDhandler)
A333CMD_rain_repellent_fo				= create_command("laminar/A333/buttons/misc/rain_repellent_fo", "F/O Rain Repellent, DEACTIVATED", A333_rain_repellent_fo_pushCMDhandler)

A333CMD_foot_warmer_capt_up				= create_command("laminar/A333/switches/misc/capt_foot_warmer_up", "Captain Foot Warmer ON", A333_foot_warmer_capt_upCMDhandler)
A333CMD_foot_warmer_capt_dn				= create_command("laminar/A333/switches/misc/capt_foot_warmer_dn", "Captain Foot Warmer OFF", A333_foot_warmer_capt_dnCMDhandler)

A333CMD_foot_warmer_fo_up				= create_command("laminar/A333/switches/misc/fo_foot_warmer_up", "F/O Foot Warmer ON", A333_foot_warmer_fo_upCMDhandler)
A333CMD_foot_warmer_fo_dn				= create_command("laminar/A333/switches/misc/fo_foot_warmer_dn", "F/O Foot Warmer OFF", A333_foot_warmer_fo_dnCMDhandler)

A333CMD_flight_recorder_push			= create_command("laminar/A333/buttons/rcdr/ground_control_push", "Flight Recorders Ground ON", A333_rcdr_ground_control_pushCMDhandler)
A333CMD_cvr_erase_push					= create_command("laminar/A333/buttons/rcdr/cvr_erase_push", "Cockpit Voice Recorder Erase", A333_rcdr_cvr_erase_pushCMDhandler)
A333CMD_cvr_test_push					= create_command("laminar/A333/buttons/rcdr/cvr_test_push", "Cockpit Voice Recorder Test", A333_rcdr_cvr_test_pushCMDhandler)

A333CMD_oxy_reset_tog					= create_command("laminar/A333/buttons/oxygen/pax_reset_toggle", "Oxygen TMR Reset", A333_oxy_reset_togCMDhandler)

A333CMD_pax_sys_tog						= create_command("laminar/A333/buttons/pax_sys_toggle", "Passenger Electrical System ON/OFF", A333_pax_sys_togCMDhandler)
A333CMD_pax_satcom_tog					= create_command("laminar/A333/buttons/pax_satcom_toggle", "Passenger SATCOM System ON/OFF", A333_pax_satcom_togCMDhandler)
A333CMD_pax_IFEC_tog					= create_command("laminar/A333/buttons/pax_IFEC_toggle", "Passenger In Flight Entertainment System ON/OFF", A333_pax_IFEC_togCMDhandler)

A333CMD_cargo_cond_fwd_isol_valve_tog	= create_command("laminar/A333/buttons/cargo_cond/fwd_isol_valve_tog", "Cargo Air Con FWD Isol Valve ON/OFF", A333_cargo_cond_fwd_isol_valve_posCMDhandler)
A333CMD_cargo_cond_bulk_isol_valve_tog	= create_command("laminar/A333/buttons/cargo_cond/bulk_isol_valve_tog", "Cargo Air Con AFT Isol Valve ON/OFF", A333_cargo_cond_bulk_isol_valve_posCMDhandler)
A333CMD_cargo_cond_hot_air_tog			= create_command("laminar/A333/buttons/cargo_cond/hot_air_tog", "Cargo Air Con Hot Air ON/OFF", A333_cargo_cond_hot_air_posCMDhandler)
A333CMD_cargo_cond_cooling_knob_left	= create_command("laminar/A333/buttons/cargo_cond/cooling_knob_left", "Cargo Air Con Cooling Knob Left", A333_cargo_cond_cooling_knob_leftCMDhandler)
A333CMD_cargo_cond_cooling_knob_right	= create_command("laminar/A333/buttons/cargo_cond/cooling_knob_right", "Cargo Air Con Cooling Knob Right", A333_cargo_cond_cooling_knob_rightCMDhandler)

A333CMD_cabin_fan_tog					= create_command("laminar/A333/buttons/cabin_fan_tog", "Cabin Fans ON/OFF", A333_cabin_fan_togCMDhandler)

A333CMD_ditching_tog					= create_command("laminar/A333/buttons/ditching_tog", "DITCHING ON/OFF", A333_ditching_togCMDhandler)

A333CMD_ventilation_extract_ovrd_tog	= create_command("laminar/A333/buttons/ventilation_extract_ovrd_tog", "Ventilation Extract AUTO/OVRD", A333_ventilation_extract_ovrd_togCMDhandler)



-- EVAC
A333CMD_evac_command_tog				= create_command("laminar/A333/buttons/evac_command_tog", "EVACUATION COMMAND", A333_evac_command_togCMDhandler)
A333CMD_evac_horn_off_push				= create_command("laminar/A333/buttons/evac_horn_off_push", "EVACUATION HORN OFF", A333_evac_horn_off_pushCMDhandler)
A333CMD_evac_capt_purs_up				= create_command("laminar/A333/buttons/evac_capt_purs_up", "EVAC Captain & Purser Priority", A333_evac_capt_purs_upCMDhandler)
A333CMD_evac_capt_purs_dn				= create_command("laminar/A333/buttons/evac_capt_purs_dn", "EVAC Captain Priority", A333_evac_capt_purs_dnCMDhandler)

-- GEAR
A333CMD_ldg_grav_extn_dn				= create_command("laminar/A333/switches/gear/gravity_extension_down", "Landing Gear Gravity Extension Down", A333_ldg_grav_extn_dnCMDhandler)
A333CMD_ldg_grav_extn_up				= create_command("laminar/A333/switches/gear/gravity_extension_up", "Landing Gear Gravity Extension Up", A333_ldg_grav_extn_upCMDhandler)
A333CMD_gear_brake_fan_tog				= create_command("laminar/A333/buttons/gear/brake_fan_tog", "Brake Fan ON/OFF", A333_gear_brake_fan_togCMDhandler)

-- ADIRS
A333CMD_adirs_ir1_tog					= create_command("laminar/A333/buttons/adirs/ir1_toggle", "IR1 Toggle", A333_adirs_ir1_toggleCMDhandler)
A333CMD_adirs_ir3_tog					= create_command("laminar/A333/buttons/adirs/ir3_toggle", "IR3 Toggle", A333_adirs_ir3_toggleCMDhandler)
A333CMD_adirs_ir2_tog					= create_command("laminar/A333/buttons/adirs/ir2_toggle", "IR2 Toggle", A333_adirs_ir2_toggleCMDhandler)

A333CMD_adirs_adr1_tog					= create_command("laminar/A333/buttons/adirs/adr1_toggle", "ADR1 Toggle", A333_adirs_adr1_toggleCMDhandler)
A333CMD_adirs_adr3_tog					= create_command("laminar/A333/buttons/adirs/adr3_toggle", "ADR3 Toggle", A333_adirs_adr3_toggleCMDhandler)
A333CMD_adirs_adr2_tog					= create_command("laminar/A333/buttons/adirs/adr2_toggle", "ADR2 Toggle", A333_adirs_adr2_toggleCMDhandler)

A333CMD_ir1_knob_left					= create_command("laminar/A333/knobs/adirs/ir1_knob_left", "IR Knob 1 Left", A333_adirs_ir1_knob_leftCMDhandler)
A333CMD_ir3_knob_left					= create_command("laminar/A333/knobs/adirs/ir3_knob_left", "IR Knob 3 Left", A333_adirs_ir3_knob_leftCMDhandler)
A333CMD_ir2_knob_left					= create_command("laminar/A333/knobs/adirs/ir2_knob_left", "IR Knob 2 Left", A333_adirs_ir2_knob_leftCMDhandler)

A333CMD_ir1_knob_right					= create_command("laminar/A333/knobs/adirs/ir1_knob_right", "IR Knob 1 Right", A333_adirs_ir1_knob_rightCMDhandler)
A333CMD_ir3_knob_right					= create_command("laminar/A333/knobs/adirs/ir3_knob_right", "IR Knob 3 Right", A333_adirs_ir3_knob_rightCMDhandler)
A333CMD_ir2_knob_right					= create_command("laminar/A333/knobs/adirs/ir2_knob_right", "IR Knob 2 Right", A333_adirs_ir2_knob_rightCMDhandler)

-- FLIGHT CONTROL COMPUTERS
A333CMD_fcc_prim1_tog					= create_command("laminar/A333/buttons/fcc/prim1_toggle", "Primary 1 ON/OFF", A333_fcc_prim1_toggleCMDhandler)
A333CMD_fcc_prim2_tog					= create_command("laminar/A333/buttons/fcc/prim2_toggle", "Primary 2 ON/OFF", A333_fcc_prim2_toggleCMDhandler)
A333CMD_fcc_prim3_tog					= create_command("laminar/A333/buttons/fcc/prim3_toggle", "Primary 3 ON/OFF", A333_fcc_prim3_toggleCMDhandler)
A333CMD_fcc_sec1_tog					= create_command("laminar/A333/buttons/fcc/sec1_toggle", "Secondary 1 ON/OFF", A333_fcc_sec1_toggleCMDhandler)
A333CMD_fcc_sec2_tog					= create_command("laminar/A333/buttons/fcc/sec2_toggle", "Secondary 2 ON/OFF", A333_fcc_sec2_toggleCMDhandler)

-- ECAM MODE BUTTONS
A333CMD_ecam_button_eng					= create_command("laminar/A333/button/ecam/eng_mode", "ECAM Engine Screen", A333_ecam_button_eng_CMDhandler)
A333CMD_ecam_button_bleed				= create_command("laminar/A333/button/ecam/bleed_mode", "ECAM Bleed Air Screen", A333_ecam_button_bleed_CMDhandler)
A333CMD_ecam_button_press				= create_command("laminar/A333/button/ecam/press_mode", "ECAM Pressurization Screen", A333_ecam_button_press_CMDhandler)
A333CMD_ecam_button_el_ac				= create_command("laminar/A333/button/ecam/el_ac_mode", "ECAM Electrical AC Screen", A333_ecam_button_el_ac_CMDhandler)
A333CMD_ecam_button_el_dc				= create_command("laminar/A333/button/ecam/el_dc_mode", "ECAM Electrical DC Screen", A333_ecam_button_el_dc_CMDhandler)
A333CMD_ecam_button_hyd					= create_command("laminar/A333/button/ecam/hyd_mode", "ECAM Hydraulics Screen", A333_ecam_button_hyd_CMDhandler)
A333CMD_ecam_button_cbs					= create_command("laminar/A333/button/ecam/cbs_mode", "ECAM Circuit Breakers Screen", A333_ecam_button_cbs_CMDhandler)
A333CMD_ecam_button_apu					= create_command("laminar/A333/button/ecam/apu_mode", "ECAM APU Screen", A333_ecam_button_apu_CMDhandler)
A333CMD_ecam_button_cond				= create_command("laminar/A333/button/ecam/cond_mode", "ECAM Air Conditioning Screen", A333_ecam_button_cond_CMDhandler)
A333CMD_ecam_button_door				= create_command("laminar/A333/button/ecam/door_mode", "ECAM Doors Screen", A333_ecam_button_door_CMDhandler)
A333CMD_ecam_button_wheel				= create_command("laminar/A333/button/ecam/wheel_mode", "ECAM Wheels Screen", A333_ecam_button_wheel_CMDhandler)
A333CMD_ecam_button_f_ctl				= create_command("laminar/A333/button/ecam/f_ctl_mode", "ECAM Flight Controls Screen", A333_ecam_button_f_ctl_CMDhandler)
A333CMD_ecam_button_fuel				= create_command("laminar/A333/button/ecam/fuel_mode", "ECAM Fuel Screen", A333_ecam_button_fuel_CMDhandler)
A333CMD_ecam_button_all					= create_command("laminar/A333/button/ecam/all_mode", "ECAM Cycle ALL", A333_ecam_button_all_CMDhandler)

A333CMD_ecam_button_to_config			= create_command("laminar/A333/button/ecam/to_config_test", "ECAM Takeoff Config Test", A333_ecam_button_to_config_CMDhandler)
A333CMD_ecam_button_clr_capt			= create_command("laminar/A333/button/ecam/clr_capt", "ECAM Clear - Captain", A333_ecam_button_clr_capt_CMDhandler)
A333CMD_ecam_button_clr_fo				= create_command("laminar/A333/button/ecam/clr_fo", "ECAM Clear - F/O", A333_ecam_button_clr_fo_CMDhandler)
A333CMD_ecam_button_sts					= create_command("laminar/A333/button/ecam/sts_mode", "ECAM Status", A333_ecam_button_sts_CMDhandler)
A333CMD_ecam_button_rcl					= create_command("laminar/A333/button/ecam/rcl_mode", "ECAM Recall", A333_ecam_button_rcl_CMDhandler)
A333CMD_ecam_button_emer_cancel			= create_command("laminar/A333/button/ecam/emer_cancel", "ECAM Emergency Cancel", A333_ecam_button_emer_cancel_CMDhandler)

-- BAROMETERS
A333CMD_pull_std_capt_push				= create_command("laminar/A333/push/baro/capt_std", "Captain Baro STANDARD PUSH", A333_pull_std_capt_pushCMDhandler)
A333CMD_pull_std_fo_push				= create_command("laminar/A333/push/baro/fo_std", "F/O Baro STANDARD PUSH", A333_pull_std_fo_pushCMDhandler)
A333CMD_pull_std_capt_pull				= create_command("laminar/A333/pull/baro/capt_std", "Captain Baro STANDARD PULL", A333_pull_std_capt_pullCMDhandler)
A333CMD_pull_std_fo_pull				= create_command("laminar/A333/pull/baro/fo_std", "F/O Baro STANDARD PULL", A333_pull_std_fo_pullCMDhandler)

A333CMD_capt_inHg						= create_command("laminar/A333/knob/baro/capt_inHg", "Captain Baro in Hg", A333_capt_inHg_CMDhandler)
A333CMD_capt_hPa						= create_command("laminar/A333/knob/baro/capt_hPa", "Captain Baro hPa", A333_capt_hPa_CMDhandler)
A333CMD_capt_inHg_hPa_toggle            = create_command("laminar/A333/knob/baro/capt_inHg_hPa_toggle", "Captain Toggle Baro Between inHg / hPa", A333_capt_inHg_hPa_CMDhandler )

A333CMD_fo_inHg							= create_command("laminar/A333/knob/baro/fo_inHg", "F/O Baro in Hg", A333_fo_inHg_CMDhandler)
A333CMD_fo_hPa							= create_command("laminar/A333/knob/baro/fo_hPa", "F/O Baro hPa", A333_fo_hPa_CMDhandler)
A333CMD_fo_inHg_hPa_toggle              = create_command("laminar/A333/knob/baro/fo_inHg_hPa_toggle", "F/O Toggle Baro Between inHg / hPa", A333_fo_inHg_hPa_CMDhandler)

-- THREE POSITION LIGHT SWITCHES
A333CMD_capt_console_light_up			= create_command("laminar/A333/switch/lighting/capt_console_light_up", "Captain Console Light UP", A333_capt_console_light_up_CMDhandler)
A333CMD_capt_console_light_dn			= create_command("laminar/A333/switch/lighting/capt_console_light_dn", "Captain Console Light DOWN", A333_capt_console_light_dn_CMDhandler)
A333CMD_fo_console_light_up				= create_command("laminar/A333/switch/lighting/fo_console_light_up", "First Officer Console Light UP", A333_fo_console_light_up_CMDhandler)
A333CMD_fo_console_light_dn				= create_command("laminar/A333/switch/lighting/fo_console_light_dn", "First Officer Console Light DOWN", A333_fo_console_light_dn_CMDhandler)

A333CMD_taxi_light_up					= create_command("laminar/A333/switch/lighting/taxi_light_up", "Taxi Light UP", A333_taxi_light_up_CMDhandler)
A333CMD_taxi_light_dn					= create_command("laminar/A333/switch/lighting/taxi_light_dn", "Taxi Light DOWN", A333_taxi_light_dn_CMDhandler)

A333CMD_taxi_light_off                  = create_command("laminar/A333/switch/lighting/taxi_light_off", "Taxi Light OFF", A333_taxi_light_off_CMDhandler)
A333CMD_taxi_light_taxi                 = create_command("laminar/A333/switch/lighting/taxi_light_taxi", "Taxi Light TAXI", A333_taxi_light_taxi_CMDhandler)
A333CMD_taxi_light_to                   = create_command("laminar/A333/switch/lighting/taxi_light_to", "Taxi Light TO", A333_taxi_light_to_CMDhandler)

-- ENG MODE SELECTOR
A333CMD_eng_mode_left					= create_command("laminar/A333/switch/eng_mode_left", "Engine Mode Knob Left", A333_eng_mode_left_CMDhandler)
A333CMD_eng_mode_right					= create_command("laminar/A333/switch/eng_mode_right", "Engine Mode Knob Right", A333_eng_mode_right_CMDhandler)

-- PARKING BRAKE
A333CMD_parking_brake_left				= create_command("laminar/A333/switch/parking_brake_left", "Parking Brake OFF", A333_parking_brake_left_CMDhandler)
A333CMD_parking_brake_right				= create_command("laminar/A333/switch/parking_brake_right", "Parking Brake ON", A333_parking_brake_right_CMDhandler)


-- EMER ELEC
A333_land_rcvry_button					= create_command("laminar/A333/button/land_rcvry", "Land Recovery ON/OFF", A333_land_rcvry_button_CMDhandler)

A333_emer_elec_gen_test				    = create_command("laminar/A333/button/emer_elec_gen_test", "Emer Elec Generator Test", A333_emer_elec_gen_test_CMDhandler)
A333_emer_gen_man_on				    = create_command("laminar/A333/button/emer_gen_man_on", "Emer Elec Generator Manual On", A333_emer_gen_man_on_CMDhandler)


-- AI
A333CMD_ai_switches_quick_start			= create_command("laminar/A333/ai/switches_quick_start", "AI Switches", A333_ai_switches_quick_start_CMDhandler)

-- OXYGEN

A333CMD_crew_oxy_tog					= create_command("laminar/A333/crew_supply_toggle", "Crew Supply", A333_crew_supply_togCMDhandler)

-- GROUND FADEC

A333CMD_eng1_fadec_ground_pwr_tog		= create_command("laminar/A333/buttons/eng1_FADEC_ground_pwr_toggle", "ENGINE 1 FADEC Ground Power", A333_eng1_fadec_ground_pwr_toggle_CMDhandler)
A333CMD_eng2_fadec_ground_pwr_tog		= create_command("laminar/A333/buttons/eng2_FADEC_ground_pwr_toggle", "ENGINE 2 FADEC Ground Power", A333_eng2_fadec_ground_pwr_toggle_CMDhandler)

-- STANDBY

A333CMD_standby_standard_tog			= create_command("laminar/A333/buttons/standby_standard_toggle", "Standby Instrument BARO STD Toggle", A333_stdby_std_tog_CMDhandler)
A333CMD_standby_ls_tog					= create_command("laminar/A333/buttons/standby_ls_toggle", "Standby Instrument LS Toggle", A333_stdby_ls_tog_CMDhandler)
A333CMD_standby_bugs_tog				= create_command("laminar/A333/buttons/standby_bugs_toggle", "Standby Instrument Bugs Toggle", A333_stdby_bugs_tog_CMDhandler)
A333CMD_standby_rst_tog					= create_command("laminar/A333/buttons/standby_rst_toggle", "Standby Instrument ATT Reset Toggle", A333_stdby_rst_tog_CMDhandler)

--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--

----- ANIMATION UTILITY -----------------------------------------------------------------
local function A333_set_animation_position(current_value, target, min, max, speed)

    local fps_factor = m.min(1.0, speed * lcl_SIM_PERIOD)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
       return min
    else
        return current_value + ((target - current_value) * fps_factor)
    end

end




----- RESCALE ---------------------------------------------------------------------------
local function rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end




----- BUTTON SWITCH COVER POSITION ANIMATION --------------------------------------------
local function A333_button_switch_cover_animation()

	local lcl_button_switch_cover_position = A333_button_switch_cover_position

    for i = 0, NUM_BTN_SW_COVERS-1 do
        lcl_button_switch_cover_position[i] = A333_set_animation_position(lcl_button_switch_cover_position[i], A333_button_switch_cover_position_target[i], 0.0, 1.0, 20.0)
    end

end




local function A333_guard_cover_animation()

	local lcl_guard_cover_pos = A333_guard_cover_pos

	for i = 0, NUM_GUARD_COVERS-1 do
		lcl_guard_cover_pos[i] = A333_set_animation_position(lcl_guard_cover_pos[i], A333_guard_cover_pos_target[i], 0.0, 1.0, 20.0)
	end

end



local function A333_knobs_switches()

	local guard_cover_pos = A333_guard_cover_pos
	local park_brake_switch_pos = A333_switches_park_brake_pos
	local park_brake_switch_lift = A333_switches_park_brake_lift
	local flaps_status = simDR_flaps_status
	local gear_deploy_ratio_nose = simDR_gear_status1
	local gear_deploy_ratio_L = simDR_gear_status2
	local gear_deploy_ratio_R = simDR_gear_status3
	local cabin_alt_alert = simDR_cabin_alt_alert
	local seatbelts_switch_pos = A333_switches_seatbelts
	local seatbelt_signs = simDR_seatbelt_signs
	local no_smoking_switch_pos = A333_switches_no_smoking
	local smoking_signs = simDR_smoking_signs
	local probe_window_heat_button_pos = A333_probe_window_heat_monitor
	local gear_on_ground = simDR_gear_on_ground
	local engine1_running = simDR_engine1_running
	local engine2_running = simDR_engine2_running

	---- GUARD COVER LOCKS ----
	if guard_cover_pos[6] < 0.9 then
		A333_trim_tank_feed_mode_pos = 0
	end

	if guard_cover_pos[10] < 0.9 then
		A333_gear_gravity_extension_pos = 0
	end

	--------------------------------------------------------------------------------------------------------------------

	---- PARKING BRAKE ----

	local brakeswitch_diff = A333_switches_park_brake_pos-park_brake_switch_pos_target
	park_brake_switch_pos = A333_set_animation_position(park_brake_switch_pos, park_brake_switch_pos_target, 0, 1, 5)
	if brakeswitch_diff > 0.05 and park_brake_switch_pos-park_brake_switch_pos_target <= 0.05 then
		simCMD_park_brake_off:once()
	elseif brakeswitch_diff < -0.05 and park_brake_switch_pos-park_brake_switch_pos_target >= -0.05 then
		simCMD_park_brake_on:once()
	end

	A333_switches_park_brake_pos = park_brake_switch_pos


	if park_brake_switch_pos < 0.1 then
		park_brake_switch_lift = rescale(0, 0, 0.1, 0.005, park_brake_switch_pos)
	elseif park_brake_switch_pos >= 0.1 and park_brake_switch_pos < 0.9 then
		park_brake_switch_lift = rescale(0.1, 0.005, 0.9, 0.005, park_brake_switch_pos)
	elseif park_brake_switch_pos >= 0.9 then
		park_brake_switch_lift = rescale(0.9, 0.005, 1, 0, park_brake_switch_pos)
	end
	A333_switches_park_brake_lift = park_brake_switch_lift



	---- SMOKING / SEATBELTS ----
	if flaps_status > 0 or gear_deploy_ratio_L > 0 or gear_deploy_ratio_R > 0 then
		seatbelt_auto_status = 1
	elseif flaps_status == 0 and gear_deploy_ratio_L == 0 and gear_deploy_ratio_R == 0 then
		seatbelt_auto_status = 0
	end

	if gear_deploy_ratio_nose > 0 or gear_deploy_ratio_L > 0 or gear_deploy_ratio_R > 0 then
		smoking_auto_status = 1
	elseif gear_deploy_ratio_nose == 0 and gear_deploy_ratio_L == 0 and gear_deploy_ratio_R == 0 then
		smoking_auto_status = 0
	end


	if cabin_alt_alert == 0 then

		if seatbelts_switch_pos == 0 then
			seatbelt_signs = 0
		elseif seatbelts_switch_pos == 1 then
			seatbelt_signs = seatbelt_auto_status
		elseif seatbelts_switch_pos == 2 then
			seatbelt_signs = 1
		end

		if no_smoking_switch_pos == 0 then
			smoking_signs = 0
		elseif no_smoking_switch_pos == 1 then
			smoking_signs = smoking_auto_status
		elseif no_smoking_switch_pos == 2 then
			smoking_signs = 1
		end

	elseif cabin_alt_alert == 1 then
		seatbelt_signs = 1
		smoking_signs = 1
	end
	simDR_seatbelt_signs = seatbelt_signs
	simDR_smoking_signs = smoking_signs


	---- CABIN SYSTEMS ----

	-- IFEC
	A333_IFEC_status = (A333_commercial_status == 1 and pax_IFEC_pos) or 0



	-- GALLEYS




	---- ANTI ICE ---
	local probe_window_heat_on = probe_window_heat_button_pos == 1
	local on_ground = gear_on_ground == 1
	local on_ground_and_any_engine_running = gear_on_ground == 1 and (engine1_running == 1 or engine2_running == 1)
	local probe_window_heat_auto = (not probe_window_heat_on and (not on_ground or on_ground_and_any_engine_running))
	local anti_ice_heat = bool2num[probe_window_heat_on or probe_window_heat_auto]	-- 0-off, 1=on

	simDR_window_heat1 = anti_ice_heat
	simDR_window_heat2 = anti_ice_heat
	simDR_window_heat3 = anti_ice_heat
	simDR_window_heat4 = anti_ice_heat
	simDR_pitot_heat_pilot = anti_ice_heat
	simDR_pitot_heat_copilot = anti_ice_heat
	simDR_pitot_heat_stby = anti_ice_heat
	simDR_AOA_heat_pilot = anti_ice_heat
	simDR_AOA_heat_copilot = anti_ice_heat
	simDR_AOA_heat_stby = anti_ice_heat
	simDR_TAT_heat_pilot = anti_ice_heat
	simDR_TAT_heat_copilot = anti_ice_heat
	simDR_TAT_heat_stby = anti_ice_heat
	simDR_static_heat_pilot = anti_ice_heat
	simDR_static_heat_copilot = anti_ice_heat
	simDR_static_heat_standby = anti_ice_heat
	simDR_ice_detect = anti_ice_heat


end




local function A333_rudder_trim_dial_animation()

    A333DR_rudder_trim_sel_dial_pos = A333_set_animation_position(A333DR_rudder_trim_sel_dial_pos, A333_rudder_trim_sel_dial_position_target, -1.0, 1.0, 10.0)

end




local function A333_window_heat_ramp()

	local gear_on_ground = gear_on_ground

	if gear_on_ground == 1 then
		window_heat1_target = 75
		window_heat2_target = 75

	elseif gear_on_ground == 0 then
		window_heat1_target = 40
		window_heat2_target = 40

	end

	LE_temp_factor = rescale(-40, 1.4, -10, 1, simDR_temp_LE)

	A333_window3_rate = 90 * LE_temp_factor
	A333_window4_rate = 90 * LE_temp_factor
	A333_window1_rate = A333_set_animation_position(A333_window1_rate, window_heat1_target, 40, 75, 0.1) * LE_temp_factor
	A333_window2_rate = A333_set_animation_position(A333_window2_rate, window_heat2_target, 40, 75, 0.1) * LE_temp_factor

end


local function A333_engine_starter_cutoff_sentinel()

	local engine1_start_switch_pos = A333_switches_engine1_start_pos
	local engine1_start_switch_lift_pos = A333_switches_engine1_start_lift
	local engine2_start_switch_pos = A333_switches_engine2_start_pos
	local engine2_start_switch_lift_pos = A333_switches_engine2_start_lift

	if engine1_starter_cutoff_sentinel == 0 then
		if engine1_start_switch_pos == 1 and engine1_start_switch_lift_pos == 0 then
			simCMD_engine1_start:once()
			engine_start_1_flag = 1
			simDR_eng1_fuel_pump_tog = 1
			engine1_starter_cutoff_sentinel = 1
		end
	end

	if engine1_starter_cutoff_sentinel == 1 then
		if engine1_start_switch_pos == 0 and engine1_start_switch_lift_pos == 0 then
			simCMD_engine1_cutoff:once()
			simDR_eng1_fuel_pump_tog = 0
			engine1_starter_cutoff_sentinel = 0
		end
	end

	if engine2_starter_cutoff_sentinel == 0 then
		if engine2_start_switch_pos == 1 and engine2_start_switch_lift_pos == 0 then
			simCMD_engine2_start:once()
			engine_start_2_flag = 1
			simDR_eng2_fuel_pump_tog = 1
			engine2_starter_cutoff_sentinel = 1
		end
	end

	if engine2_starter_cutoff_sentinel == 1 then
		if engine2_start_switch_pos == 0 and engine2_start_switch_lift_pos == 0 then
			simCMD_engine2_cutoff:once()
			simDR_eng2_fuel_pump_tog = 0
			engine2_starter_cutoff_sentinel = 0
		end
	end


	if engine1_starter_lift_flag == 0 then

		if engine1_start_switch_lift_pos < 0.0035 then
			if engine1_start_switch_pos ~= 0 and engine1_start_switch_pos ~= 1 then
				if engine1_start_switch_pos < 0.5 then
					engine1_start_switch_pos = 0
					engine1_start_switch_lift_pos = 0
				elseif engine1_start_switch_pos >= 0.5 then
					engine1_start_switch_pos = 1
					engine1_start_switch_lift_pos = 0
				end
			end
		end

	elseif engine1_starter_lift_flag == 1 then
		engine1_starter_lift_flag = 0
	end
	A333_switches_engine1_start_pos = engine1_start_switch_pos
	A333_switches_engine1_start_lift = engine1_start_switch_lift_pos




	if engine2_starter_lift_flag == 0 then

		if engine2_start_switch_pos ~= 0 and engine2_start_switch_pos ~= 1 then
			if engine2_start_switch_lift_pos < 0.0035 then
				if engine2_start_switch_pos < 0.5 then
					engine2_start_switch_pos = 0
					engine2_start_switch_lift_pos = 0
				elseif engine2_start_switch_pos >= 0.5 then
					engine2_start_switch_pos = 1
					engine2_start_switch_lift_pos = 0
				end
			end
		end

	elseif engine2_starter_lift_flag == 1 then
		engine2_starter_lift_flag = 0
	end
	A333_switches_engine2_start_pos = engine2_start_switch_pos
	A333_switches_engine2_start_lift = engine2_start_switch_lift_pos

end





local function A333_ditching_mode()

	if A333_ditching_status == 1 then
		simDR_pack1 = 0
		simDR_pack2 = 0
	end

end




-- BAROMETERS
local function A333_baro_memory()

--	simDR_captain_barometer = (simDR_captain_baro_is_std == 1 and 29.92) or A333_capt_baro_knob_pos
--	simDR_first_officer_barometer = (simDR_first_officer_baro_is_std == 1 and 29.92) or A333_fo_baro_knob_pos
	simDR_standby_barometer = (A333_standby_std_state == 1 and 29.92) or A333_standby_baro_knob_pos

end

-- ATT RST

local function A333_att_rst()

	if A333_standby_rst_timer >= 2 then
		standby_align_flag = 0
		A333_standby_rst_state = 1
		A333_standby_rst_align_timer = 0
	end
	
	if A333_standby_rst_state == 1 then
		A333_standby_rst_align_timer = A333_standby_rst_align_timer + lcl_SIM_PERIOD
	end

	if A333_standby_rst_state == 1 then
		if m.abs(simDR_standby_horizon_roll) > 0.5 or m.abs(simDR_standby_horizon_pitch_accel) > 0.5 or m.abs(simDR_standby_horizon_vel_accel) > 0.05 or m.abs(simDR_vvi_pilot) > 125 then
			standby_align_flag = 1
		end
	end
				
	if A333_standby_rst_align_timer >= 10 then
		if standby_align_flag == 0 then
			A333_standby_rst_state = 0
		else A333_standby_rst_state = 2
		end
		A333_standby_rst_align_timer = 0
	end
	
end


--[[

-----------------------------------------------------------------------------------------------------------
XPD-12981:

Austin: as per reality, a330 needs to be able to turn OFF the wxr radar to turn ON the terrain-warning-map!

drgluck07@gmail.com: In a real A330, the TERR_ON_ND button turns off the weather radar on the given ND and
turns on the terrain (and vice versa)

Austin: this guy makes a PLUGIN to draw the terrain, so we do NOT need to go to the trouble to draw the
terrain if we dont have time… but we SHOULD support the 'TERR_ON_ND' to at least turn OFF the radar!

that MINISCULE amount of work from US will add realism and let the plugin author do his terrain
collision plugin as well.

and, of course, with that switch functioning, we can drop in our own terrain collision later,
if we feel like it.

-----------------------------------------------------------------------------------------------------------
SIX DIFFERENT DISPLAYS ARE AVAILABLE (FIVE MODES TO DISPLAY NAVIGATION INFORMATION AND ONE TO
DISPLAY ENGINE PRIMARY PARAMETERS).
-----------------------------------------------------------------------------------------------------------
THE NAVIGATION DISPLAY (ND) CAN SHOW A WEATHER RADAR IMAGE IN ALL MODES EXCEPT PLAN.

WHEN THE RADAR IS OPERATING, AND WHEN THE ND IS NOT IN PLAN MODE, THE ND DISPLAYS THE WEATHER RADAR
PICTURE.
-----------------------------------------------------------------------------------------------------------
• EGPWS TERRAIN PICTURE:
THE ND PRESENTS THE EGPWS TERRAIN PICTURE, WHEN THE TERR-ON-ND SWITCH IS SET TO ON, AND THE ND IS NOT
IN PLAN OR ENG (ENGINE: STANDBY PAGE) MODE.

THE TERRAIN PICTURE REPLACES THE WEATHER RADAR IMAGE. TERRAIN DATA IS DISPLAYED INDEPENDENTLY OF THE
AIRCRAFT RELATIVE ALTITUDE. THE TERRAIN APPEARS IN DIFFERENT COLORS AND DENSITIES, DEPENDING ON THE
AIRCRAFT'S ALTITUDE RELATIVE TO THE TERRAIN.
-----------------------------------------------------------------------------------------------------------
In case all ECAM DMC channels fail, each pilot may display the engine standby page on their respective ND.

In case of all DMC ECAM channel failure the engine primary parameters can be displayed on each ND using
the ND selector on the EFIS control panel.
_______________________________________________________________________________________________________________________________________________________________________________________________________________________________________
--|AIRBUS|---------------						sim/cockpit2/EFIS/map_mode(_copilot)		sim/cockpit2/EFIS/map_mode_is_HSI(_copilot)		sim/cockpit2/EFIS/EFIS_terrain_on(_copilot)		sim/cockpit2/EFIS/EFIS_weather_on(_copilot)
laminar/A333/knobs/EFIS_mode_pos_capt(_fo)
_______________________________________________________________________________________________________________________________________________________________________________________________________________________________________
- (1) ROSE LS									0=approach									1												1												1 (0 WHEN TERR-ON-ND)
- (2) ROSE VOR									1=vor										1												1												1 (0 WHEN TERR-ON-ND)
- (3) ROSE NAV									3=nav										1												1												1 (0 WHEN TERR-ON-ND)
- (4) ARC										2=map										0												1												1 (0 WHEN TERR-ON-ND)
- (5) PLAN										4=plan										0												0												0
- (6) ENG (standby page)						---								   			---												0												0
_______________________________________________________________________________________________________________________________________________________________________________________________________________________________________


-----------------------------------------------------------------------------------------------------------
TERR PB SW  (laminar/A333/buttons/gpws/terrain_status (OVERHEAD) / CMD = laminar/A333/buttons/gpws/terr_toggle")
-----------
OFF: INHIBITS THE TERRAIN AWARENESS DISPLAY (TAD) MODE AND TERRAIN CLEARANCE FLOOR (TCF) MODE, BUT DOES NOT
AFFECT THE BASIC GPWS MODE 1 TO 5.
FAULT LIGHT: THIS AMBER LIGHT COMES ON, ALONG WITH AN ECAM CAUTION, IF THE TAD OR TCF MODE FAILS. THE
BASIC GPWS MODE 1 TO MODE 5 ARE STILL OPERATIVE IF THE SYS PUSH BUTTON SWITCH LIGHTS OFF OR FAULT ARE NOT ILLUMINATED.
-----------------------------------------------------------------------------------------------------------

--]]


local function A333_EFIS_mode()

	local EFIS_mode_knob_captain = A333_EFIS_mode_knob_captain
	local EFIS_map_mode = simDR_EFIS_map_mode
	local EFIS_map_HSI_mode = simDR_EFIS_map_HSI_mode
	local ECAM_on_EFIS_captain = A333_ECAM_on_EFIS_captain
	local EFIS_draw_map_capt = A333_draw_capt_map

	if EFIS_mode_knob_captain == 0 then					-- ROSE LS
		EFIS_map_mode = 0
		EFIS_map_HSI_mode = 1
		ECAM_on_EFIS_captain = 0

	elseif EFIS_mode_knob_captain == 1 then				-- ROSE VOR
		EFIS_map_mode = 1
		EFIS_map_HSI_mode = 1
		ECAM_on_EFIS_captain = 0

	elseif EFIS_mode_knob_captain == 2 then				-- ROSE NAV
		EFIS_map_mode = 3
		EFIS_map_HSI_mode = 1
		ECAM_on_EFIS_captain = 0

	elseif EFIS_mode_knob_captain == 3 then				-- ARC (NAV)
		EFIS_map_mode = 2
		EFIS_map_HSI_mode = 0
		ECAM_on_EFIS_captain = 0

	elseif EFIS_mode_knob_captain == 4 then				-- PLAN
		EFIS_map_mode = 4
		EFIS_map_HSI_mode = 0
		ECAM_on_EFIS_captain = 0

	elseif EFIS_mode_knob_captain == 5 then				-- ENG
		ECAM_on_EFIS_captain = 1

	end

	local EFIS_mode_knob_fo = A333_EFIS_mode_knob_fo
	local EFIS_map_mode_fo = simDR_EFIS_map_mode_fo
	local EFIS_map_HSI_mode_fo = simDR_EFIS_map_HSI_mode_fo
	local ECAM_on_EFIS_fo = A333_ECAM_on_EFIS_fo
	local EFIS_draw_map_fo = A333_draw_fo_map

	if EFIS_mode_knob_fo == 0 then							-- ROSE LS
		EFIS_map_mode_fo = 0
		EFIS_map_HSI_mode_fo = 1
		ECAM_on_EFIS_fo = 0
	elseif EFIS_mode_knob_fo == 1 then						-- ROSE VOR
		EFIS_map_mode_fo = 1
		EFIS_map_HSI_mode_fo = 1
		ECAM_on_EFIS_fo = 0
	elseif EFIS_mode_knob_fo == 2 then						-- ROSE NAV
		EFIS_map_mode_fo = 3
		EFIS_map_HSI_mode_fo = 1
		ECAM_on_EFIS_fo = 0
	elseif EFIS_mode_knob_fo == 3 then						-- ARC (NAV)
		EFIS_map_mode_fo = 2
		EFIS_map_HSI_mode_fo = 0
		ECAM_on_EFIS_fo = 0
	elseif EFIS_mode_knob_fo == 4 then						-- PLAN
		EFIS_map_mode_fo = 4
		EFIS_map_HSI_mode_fo = 0
		ECAM_on_EFIS_fo = 0
	elseif EFIS_mode_knob_fo == 5 then						-- ENG
		ECAM_on_EFIS_fo = 1
	end
	
	if EFIS_mode_knob_captain <= 1 then
		if A333DR_adiru1_att_status == 1 then
			if A333DR_adiru1_hdg_status == 1 then
				EFIS_draw_map_capt = 2
			else EFIS_draw_map_capt = 0
			end
		else EFIS_draw_map_capt = 0
		end
	elseif EFIS_mode_knob_captain == 2 or EFIS_mode_knob_captain == 3 then
		if A333DR_adiru1_att_status == 1 then
			if A333DR_adiru1_hdg_status == 1 then
				if A333DR_adiru1_lrn_status == 1 then
					EFIS_draw_map_capt = 2
				else EFIS_draw_map_capt = 1
				end
			else EFIS_draw_map_capt = 0
			end
		else EFIS_draw_map_capt = 0
		end
	elseif EFIS_mode_knob_captain == 4 then
		EFIS_draw_map_capt = 2
	end


	if EFIS_mode_knob_fo <= 1 then
		if A333DR_adiru2_att_status == 1 then
			if A333DR_adiru2_hdg_status == 1 then
				EFIS_draw_map_fo = 2
			else EFIS_draw_map_fo = 0
			end
		else EFIS_draw_map_fo = 0
		end
	elseif EFIS_mode_knob_fo == 2 or EFIS_mode_knob_fo == 3 then
		if A333DR_adiru2_att_status == 1 then
			if A333DR_adiru2_hdg_status == 1 then
				if A333DR_adiru2_lrn_status == 1 then
					EFIS_draw_map_fo = 2
				else EFIS_draw_map_fo = 1
				end
			else EFIS_draw_map_fo = 0
			end
		else EFIS_draw_map_fo = 0
		end
	elseif EFIS_mode_knob_fo == 4 then
		EFIS_draw_map_fo = 2
	end

	A333_draw_capt_map = EFIS_draw_map_capt
	simDR_EFIS_map_HSI_mode = EFIS_map_HSI_mode
	A333_ECAM_on_EFIS_captain = ECAM_on_EFIS_captain

	A333_draw_fo_map = EFIS_draw_map_fo
	simDR_EFIS_map_HSI_mode_fo = EFIS_map_HSI_mode_fo
	A333_ECAM_on_EFIS_fo = ECAM_on_EFIS_fo

	simDR_EFIS_map_mode = EFIS_map_mode
	simDR_EFIS_map_mode_fo = EFIS_map_mode_fo

end




local function A333_terr_on_nd()

	-- REVISION FOR XPD-12981
	-- THE 'GPWS TERR' BUTTON ONLY INHIBITS THE TAD MODE AND TCF MODE.
	-- IT DOES NOT AFFECT BASIC GPWS MODES 1 THRU 5.
	-- IT DOES NOT CONTROL THE TERRAIN 'PICTURE' ON THE ND
	-- THE TERRAIN "PICTURE" ON THE ND IS ONLY CONTROLLED BY THE 'TERR ON ND' BUTTON

	simDR_terr_on_nd_capt = A333_terr_on_nd_capt * bool2num[simDR_EFIS_map_mode <= 3] * bool2num[A333DR_adiru1_lrn_status == 1] * bool2num[A333DR_ac_bus1_has_power == 1]
	simDR_terr_on_nd_fo = A333_terr_on_nd_fo * bool2num[simDR_EFIS_map_mode_fo <= 3] * bool2num[A333DR_adiru2_lrn_status == 1] * bool2num[A333DR_ac_bus1_has_power == 1]

end




local function A333_EFIS_wxr_radar()

	-- REVISION FOR XPD-12981
	-- THE WEATHER RADAR CAN ONLY DISPLAYED WHEN THE 'TERR ON ND' BUTTON IS 'OFF'

	local weather_radar_switch_pos = A333_weather_radar_switch_pos
	local weather_windshear_warn = simDR_weather_windshear_warn

	local terr_on_nd_capt_off = 1 - simDR_terr_on_nd_capt
	local weather_on_capt = (m.abs(weather_radar_switch_pos) + weather_windshear_warn)* terr_on_nd_capt_off * bool2num[simDR_EFIS_map_mode <= 3]

	local terr_on_nd_fo_off = 1 - simDR_terr_on_nd_fo
	local weather_on_fo = (m.abs(weather_radar_switch_pos) + weather_windshear_warn) * terr_on_nd_fo_off * bool2num[simDR_EFIS_map_mode_fo <= 3]



	local weather_mode_capt = simDR_weather_mode_capt
	local weather_radar_mode_pos = A333_weather_radar_mode_pos

	if weather_on_capt == 0 then
		weather_mode_capt = 0
		simDR_weather_on_capt = 0
	else
		simDR_weather_on_capt = 1
		if weather_radar_mode_pos == 0 then
			weather_mode_capt = 2
		elseif weather_radar_mode_pos == 1 then
			weather_mode_capt = 3
		elseif weather_radar_mode_pos == 2 then
			weather_mode_capt = 5
		elseif weather_radar_mode_pos == 3 then
			weather_mode_capt = 4
		end
	end
	simDR_weather_mode_capt = weather_mode_capt



	local weather_mode_fo = simDR_weather_mode_fo

	if weather_on_fo == 0 then
		weather_mode_fo = 0
		simDR_weather_on_fo = 0
	else
		simDR_weather_on_fo = 1
		if A333_weather_radar_mode_pos == 0 then
			weather_mode_fo = 2
		elseif A333_weather_radar_mode_pos == 1 then
			weather_mode_fo = 3
		elseif A333_weather_radar_mode_pos == 2 then
			weather_mode_fo = 5
		elseif A333_weather_radar_mode_pos == 3 then
			weather_mode_fo = 4
		end
	end
	simDR_weather_mode_fo = weather_mode_fo


	A333_weather_radar_mode_anim = A333_set_animation_position(A333_weather_radar_mode_anim, A333_weather_radar_mode_pos, 0, 3, 12)


	if GCS_timer_init == 1 then
		GCS_timer = GCS_timer + lcl_SIM_PERIOD
		if GCS_timer >= 5 then
			simDR_weather_gcs_capt = 1
			GCS_timer_init = 0
		end
	end

	simDR_weather_gain_fo = simDR_weather_gain_capt
	simDR_weather_multiscan_fo = simDR_weather_multiscan_capt
	simDR_weather_gcs_fo = simDR_weather_gcs_capt



	local flight_phase = A333_flight_phase
	local PWS_active = bool2num[flight_phase >= 3 and flight_phase <= 8]
	local weather_sector_width = simDR_weather_sector_width
	local weather_sweeps_sec = simDR_weather_sweeps_sec

	if simDR_weather_pws_capt == 1 then
		if A333_rad_alt < 2300 and PWS_active == 1 then
			weather_sector_width = 60
			weather_sweeps_sec = 1.5
		else weather_sector_width = 90
			weather_sweeps_sec = 1
		end
	else weather_sector_width = 90
		weather_sweeps_sec = 1
	end
	simDR_weather_sector_width = weather_sector_width
	simDR_weather_sweeps_sec = weather_sweeps_sec

end




-- FLIGHT RECORDERS GROUND ON
local function A333_flight_recorders()

	local gear_on_ground = simDR_gear_on_ground

	if gear_on_ground == 0 then
		A333_flight_recorder_mode_on = 2

	elseif gear_on_ground == 1 then

		local engine1_running = simDR_engine1_running
		local engine2_running = simDR_engine2_running
		local flight_recorder_mode_on = A333_flight_recorder_mode_on

		if engine1_running == 1 or engine1_running == 1 then
			flight_recorder_mode_on = 2

		elseif engine2_running == 0 and engine2_running == 0 then

			if flight_rcdr_mode_timer < 300 then
				if flight_rcdr_mode_store == 0 then
					flight_recorder_mode_on = 0
				elseif flight_rcdr_mode_store == 1 then
					flight_recorder_mode_on = 1
					flight_rcdr_mode_timer = flight_rcdr_mode_timer + lcl_SIM_PERIOD
				end
			elseif flight_rcdr_mode_timer >= 300 then
				flight_recorder_mode_on = 0
				flight_rcdr_mode_store = 0
				flight_rcdr_mode_timer = 0
			end

		end
		A333_flight_recorder_mode_on = flight_recorder_mode_on

	end

end







local function A333_audio_sel_volume()

	local audio_panel_capt_voice_status = A333DR_audio_panel_capt_voice_status

	simDR_capt_com1_volume = A333DR_audio_panel_capt_volume_0
	simDR_capt_com2_volume = A333DR_audio_panel_capt_volume_1
	simDR_capt_LS_volume = (audio_panel_capt_voice_status == 0 and A333DR_audio_panel_capt_volume_7) or 0
	simDR_capt_nav1_volume = (audio_panel_capt_voice_status == 0 and A333DR_audio_panel_capt_volume_9) or 0
	simDR_capt_nav2_volume = (audio_panel_capt_voice_status == 0 and A333DR_audio_panel_capt_volume_10) or 0
	simDR_capt_adf1_volume = (audio_panel_capt_voice_status == 0 and A333DR_audio_panel_capt_volume_11) or 0
	simDR_capt_adf2_volume = (audio_panel_capt_voice_status == 0 and A333DR_audio_panel_capt_volume_12) or 0
	simDR_capt_marker_volume = A333DR_audio_panel_capt_volume_8



	local audio_panel_fo_voice_status = A333DR_audio_panel_fo_voice_status

	simDR_fo_com1_volume 	= A333DR_audio_panel_fo_volume_0
	simDR_fo_com2_volume 	= A333DR_audio_panel_fo_volume_1
	simDR_fo_LS_volume 		= (audio_panel_fo_voice_status == 0 and A333DR_audio_panel_fo_volume_7) or 0
	simDR_fo_nav1_volume 	= (audio_panel_fo_voice_status == 0 and A333DR_audio_panel_fo_volume_9) or 0
	simDR_fo_nav2_volume 	= (audio_panel_fo_voice_status == 0 and A333DR_audio_panel_fo_volume_10) or 0
	simDR_fo_adf1_volume 	= (audio_panel_fo_voice_status == 0 and A333DR_audio_panel_fo_volume_11) or 0
	simDR_fo_adf2_volume 	= (audio_panel_fo_voice_status == 0 and A333DR_audio_panel_fo_volume_12) or 0
	simDR_fo_marker_volume 	= A333DR_audio_panel_fo_volume_8

end




local function A333_apu_bleed()

	--[[
	The climb and descent restrictions (25,000 ft climb, 23,000 ft descent) are operational —
	they ensure that you can establish cabin pressurisation via engine bleeds or meet
	procedures before committing bleed from APU. Those restrict when you can turn it on
	during the vertical profile.
	However, once you're in level cruise, the hard structural maximum for bleed from
	the APU is at 22,500ft — above that it's not available at all
	--]]

	local vvi = simDR_vvi_pilot
	local climbing = vvi > 250.0
	local descending = vvi < -250
	local altitude = simDR_pressure_altitude

	simDR_apu_bleed = (A333_buttons_APU_master >= 1.0
		and A333_switches_apu_bleed_pos >= 1.0
		and simDR_apu_N1 >= 95.0
		and
		((not(climbing or descending) and altitude < 22500.0)
		or
		((climbing and altitude < 25000.0) or (descending and altitude < 23000.0))))
		and 1 or 0

end




-- AUTO BLEED MANAGEMENT
local function A333_engine_bleed_sov_mgmt()

	local apu_bleed_switch = A333_apu_bleed_switch_ctct_on_off
	local apu_bleed_valve_pos = simDR_apu_bleed

	simDR_eng1_bleed_sov = (simDR_engine1_starter_running == 1
		or (apu_bleed_valve_pos == 1 and apu_bleed_switch == 1)
		or simDR_engine1_fire == 1
		or A333_eng1_fire_handle_pos == 1
		or A333_eng1_bleed_switch_ctct_on_off == 0)
		--or upstream pressure < 8.0 -- not modeled
		and 0 or 1

	simDR_eng2_bleed_sov = (simDR_engine2_starter_running == 1
		or (apu_bleed_valve_pos == 1 and apu_bleed_switch == 1 and simDR_isol_valve_right == 1)
		or simDR_engine2_fire == 1
		or A333_eng2_fire_handle_pos == 1
		or A333_eng2_bleed_switch_ctct_on_off == 0)
		--or upstream pressure < 8.0 -- not modeled
		and 0 or 1


end




--local pause = true
local function A333_apu_master_monitor()

	if A333_buttons_apu_master_ctct_on_off == 0 then
		if simDR_apu_switch > 0 then simDR_apu_switch = 0 end

	elseif A333_buttons_apu_master_ctct_on_off == 1 then
		if A333DR_dc_bat_bus_volts >= A333DR_dc_min_volts then-- Only turn the APU Master to "ON" if sufficient Main battery power for APU ECB
			if simDR_apu_switch == 0 then
				simDR_apu_switch = 1
			end
		end
	end

end




local function A333_apu_starter_monitor()

	if simDR_apu_switch == 1							-- Master is "ON"
		and (A333_buttons_apu_start_ctct_on_off == 1 or apu_start_request == 1)	-- Start button was pushed or apu start command was envoked
		and simDR_apu_batt_volts > A333DR_dc_min_volts
		and simDR_apu_N1 < 50.0
		and simDR_APU_running == 0
	then
		simDR_apu_switch = 2							-- Run the starter
		apu_start_request = 0
	end


	if simDR_apu_switch == 2
		and simDR_apu_N1 >= 50.0
	then
		simDR_apu_switch = 1							-- Starter was running, turn it off
	end

end





local function A333_brake_fan_mgmt()
	if simDR_gear_status2 ~= 1 and simDR_gear_status3 ~= 1 then
		if simDR_brake_fan == 1 then
			simDR_brake_fan = 0
		end
	elseif simDR_gear_status2 == 1 or simDR_gear_status3 == 1 then
		if simDR_brake_fan ~= brake_fan_request then
			simDR_brake_fan = brake_fan_request
		end
	end
end




local function A333_annunciator_brightness_set()

	if annun_flag == 1 then
		A333_ann_light_switch_pos = (simDR_sun_pitch > -1.5 and 1) or 0
		annun_flag = 0
	end

end


local function A333_leak_measurement_switches()
	
	if A333DR_yellow_trigger_cargo == 1 then
		yellow_leak_measurement_open_cargo = 1
	end
	
	if yellow_leak_measurement_open_cargo == 1 and simDR_elec_hyd_yellow == 0 and simDR_yellow_hydraulic_pressure < 5 then
		yellow_leak_measurement_open_cargo = 0
	end

	A333_green_leak_measure_status = ((green_leak_measure_sw_stat == 1 and simDR_equiv_airspeed < 100) and 1) or 0
	A333_blue_leak_measure_status = ((blue_leak_measure_sw_stat == 1 and simDR_equiv_airspeed < 100) and 1) or 0
	A333_yellow_leak_measure_status = (((yellow_leak_measure_sw_stat == 1 or yellow_leak_measurement_open_cargo == 1) and simDR_equiv_airspeed < 100) and 1) or 0

end


local function A333_flight_control_computer_power()

	A333_prim1_status = ((fcc_prim1 == 1 and A333DR_dc_ess_bus_has_power == 1) and 1) or 0
	A333_prim2_status = ((fcc_prim2 == 1 and A333DR_dc_bus2_has_power == 1) and 1) or 0
	A333_prim3_status = ((fcc_prim3 == 1 and (A333DR_dc_bus2_has_power == 1 or A333DR_dc_bus1_has_power == 1)) and 1) or 0
	A333_sec1_status = ((fcc_sec1 == 1 and A333DR_dc_ess_bus_has_power == 1) and 1) or 0
	A333_sec2_status = ((fcc_sec2 == 1 and(A333DR_dc_bus2_has_power == 1 or A333DR_dc_ess_bus_has_power == 1)) and 1) or 0

end


local function A333_tcas_on_map()

	local xponder_mode = simDR_transponder_modes

	simDR_EFIS_tcas_on_capt = ((simDR_EFIS_map_range_capt <= 40) and (xponder_mode >= 2)) and 1 or 0
	simDR_EFIS_tcas_on_fo = ((simDR_EFIS_map_range_fo <= 40) and (xponder_mode >= 2)) and 1 or 0

end

local function A333_emergency_call_sequence()

	if A333_call_emergency_status == 1 then
		if A333DR_dc_ess_bus_has_power == 1 then
			chime_timer = chime_timer + SIM_PERIOD
		end
	else chime_timer = 0
	end			
		
	if chime_timer > 0.1 and chime_timer < 0.2 then
		A333_sound_call_purs_trigger = 1
		A333_sound_call_fwd_trigger = 1
		A333_sound_call_mid_trigger = 1
		A333_sound_call_exit_trigger = 1
		A333_sound_call_aft_trigger = 1
	elseif chime_timer > 2.25 and chime_timer < 2.35 then
		A333_sound_call_purs_trigger = 1
		A333_sound_call_fwd_trigger = 1
		A333_sound_call_mid_trigger = 1
		A333_sound_call_exit_trigger = 1
		A333_sound_call_aft_trigger = 1
	elseif chime_timer > 4.4 and chime_timer < 4.5 then
		A333_sound_call_purs_trigger = 1
		A333_sound_call_fwd_trigger = 1
		A333_sound_call_mid_trigger = 1
		A333_sound_call_exit_trigger = 1
		A333_sound_call_aft_trigger = 1
	else
		A333_sound_call_purs_trigger = 0
		A333_sound_call_fwd_trigger = 0
		A333_sound_call_mid_trigger = 0
		A333_sound_call_exit_trigger = 0
		A333_sound_call_aft_trigger = 0
	end

end

local function A333_idle_reset_on_start()

	if engine_start_1_flag == 1 and simDR_engine1_running == 1 and simDR_eng_N2[0] > 55 then
		if simDR_engine1_heat == 0 then
			if simDR_idle_mode[0] == 1 then
				simCMD_hi_lo_idle_tog1:once()
				engine_start_1_flag = 0
			end
		elseif simDR_engine1_heat == 1 then
			if simDR_idle_mode[0] == 1 then
				engine_start_1_flag = 0
			end
		end
	end

	if engine_start_2_flag == 1 and simDR_engine2_running == 1 and simDR_eng_N2[1] > 55 then
		if simDR_engine2_heat == 0 then
			if simDR_idle_mode[1] == 1 then
				simCMD_hi_lo_idle_tog2:once()
				engine_start_2_flag = 0
			end
		elseif simDR_engine2_heat == 1 then
			if simDR_idle_mode[1] == 1 then
				engine_start_2_flag = 0
			end
		end
	end

end


----- SET STATE FOR ALL MODES -----------------------------------------------------------
local function A333_set_switches_all_modes()

	A333_guard_cover_pos_target[3] = 0
	A333_guard_cover_pos_target[8] = 0
	A333_guard_cover_pos_target[9] = 0

	A333DR_init_switches_CD = 0

	A333_buttons_ACESS_FEED_pos = 1
	A333_buttons_ess_feed_ctct_on_off = 1

	A333_buttons_apu_master_ctct_on_off = 0

	A333_capt_baro_knob_pos = simDR_captain_barometer
	A333_fo_baro_knob_pos = simDR_first_officer_barometer

	simDR_EFIS_airport_on_capt = 0
	simDR_EFIS_fix_on_capt = 0
	simDR_EFIS_vor_on_capt = 0
	simDR_EFIS_ndb_on_capt = 0
	simDR_EFIS_cstr_on_capt = 0

	simDR_EFIS_airport_on_fo = 0
	simDR_EFIS_fix_on_fo = 0
	simDR_EFIS_vor_on_fo = 0
	simDR_EFIS_ndb_on_fo = 0
	simDR_EFIS_cstr_on_fo = 0
	
	simDR_apu_switch = 0
	simDR_apu_bleed = 0
	A333_buttons_APU_master = 0
	A333_switches_apu_bleed_pos	= 0

	simDR_terr_on_nd_capt = 0
	simDR_terr_on_nd_fo = 0

	if A333_rad_alt > 100.0 then	-- FLight Start in-air
		park_brake_switch_pos_target = 0
		simCMD_park_brake_off:once()
		A333_switches_park_brake_pos = 0
	else
		park_brake_switch_pos_target = 1
		simCMD_park_brake_on:once()
		A333_switches_park_brake_pos = 1
	end

	simDR_engine1_hyd_green = 1
	simDR_engine1_hyd_blue = 1
	simDR_engine2_hyd_yellow = 1
	simDR_engine2_hyd_green = 1

	A333_engine1_pump_green_pos = 1
	A333_engine1_pump_blue_pos = 1
	A333_engine2_pump_yellow_pos = 1
	A333_engine2_pump_green_pos = 1

	A333_elec_pump_green_tog_pos = 1
	A333_elec_pump_blue_tog_pos = 1
	A333_elec_pump_yellow_tog_pos = 1

	A333_elec_pump_green_contactor = 1
	A333_elec_pump_yellow_contactor = 1
	A333_elec_pump_blue_contactor = 1

	simDR_elec_hyd_green = 0
	simDR_elec_hyd_blue = 0
	simDR_elec_hyd_yellow = 0

	simDR_engine1_hyd_yellow = 0
	simDR_engine2_hyd_blue = 0

	flight_rcdr_mode_store = 0
	flight_rcdr_mode_timer = 0

	A333_IDG1_status = 1
	A333_IDG2_status = 1

	A333_prim1_pos = 1
	A333_prim2_pos = 1
	A333_prim3_pos = 1
	A333_sec1_pos = 1
	A333_sec2_pos = 1

	fcc_prim1 = 1
	fcc_prim2 = 1
	fcc_prim3 = 1
	fcc_sec1 = 1
	fcc_sec2 = 1	
	
	A333DR_audio_panel_capt_volume_0 = 0.5 + (0.25 * audio_panel_capt_volume_0_init)
	A333DR_audio_panel_capt_volume_1 = 0.5 + (0.25 * audio_panel_capt_volume_1_init)
	A333DR_audio_panel_capt_volume_7 = 0.5 + (0.25 * audio_panel_capt_volume_7_init)
	A333DR_audio_panel_capt_volume_8 = 0.5 + (0.25 * audio_panel_capt_volume_8_init)
	A333DR_audio_panel_capt_volume_9 = 0.5 + (0.25 * audio_panel_capt_volume_9_init)
	A333DR_audio_panel_capt_volume_10 = 0.5 + (0.25 * audio_panel_capt_volume_10_init)
	A333DR_audio_panel_capt_volume_11 = 0.5 + (0.25 * audio_panel_capt_volume_11_init)
	A333DR_audio_panel_capt_volume_12 = 0.5 + (0.25 * audio_panel_capt_volume_12_init)

	A333DR_audio_panel_fo_volume_0 = 0.5 + (0.25 * audio_panel_fo_volume_0_init)
	A333DR_audio_panel_fo_volume_1 = 0.5 + (0.25 * audio_panel_fo_volume_1_init)
	A333DR_audio_panel_fo_volume_7 = 0.5 + (0.25 * audio_panel_fo_volume_7_init)
	A333DR_audio_panel_fo_volume_8 = 0.5 + (0.25 * audio_panel_fo_volume_8_init)
	A333DR_audio_panel_fo_volume_9 = 0.5 + (0.25 * audio_panel_fo_volume_9_init)
	A333DR_audio_panel_fo_volume_10 = 0.5 + (0.25 * audio_panel_fo_volume_10_init)
	A333DR_audio_panel_fo_volume_11	= 0.5 + (0.25 * audio_panel_fo_volume_11_init)
	A333DR_audio_panel_fo_volume_12 = 0.5 + (0.25 * audio_panel_fo_volume_12_init)

	A333DR_forward_flood_rheo = 0
	simDR_generic_brightness[15] = 0
	--simDR_ext_power_a_on = 0

	simDR_instrument_brightness[0] = 1
	simDR_instrument_brightness[1] = 1
	simDR_instrument_brightness[2] = 1
	simDR_instrument_brightness[3] = 1
	simDR_instrument_brightness[4] = 1
	simDR_instrument_brightness[5] = 1
	simDR_instrument_brightness[6] = 1
	simDR_instrument_brightness[7] = 1
	simDR_instrument_brightness[8] = 1
	simDR_instrument_brightness[9] = 1
	simDR_instrument_brightness[10] = 1
	simDR_instrument_brightness[11] = 1
	simDR_instrument_brightness[18] = 1
	simDR_instrument_brightness[19] = 1

	A333_MCDU1_bright_setting = 1
	A333_MCDU2_bright_setting = 1
	A333_MCDU3_bright_setting = 1

	run_after_time(function()
		annun_flag = 1
	end, 0.25)

	A333_window1_rate = 75
	A333_window2_rate = 75

	simDR_weather_gcs_capt = 1
	simDR_weather_gcs_fo = 1
	simDR_weather_multiscan_capt = 1
	simDR_weather_multiscan_fo = 1

	simDR_weather_sector_brg			= 0
	simDR_weather_sector_width			= 90
	simDR_weather_antenna_limit			= 90
	
	if simDR_captain_barometer < 22 then
		simDR_captain_barometer = 29.92
	end

	if simDR_first_officer_barometer < 22 then
		simDR_first_officer_barometer = 29.92
	end

	A333_standby_baro_knob_pos = simDR_standby_barometer

	A333_EFIS_mode_knob_captain = 3
	A333_EFIS_mode_knob_fo = 3

	simDR_engine1_heat = 0				-- ensures that engine anti ice is never ON on flight start
	simDR_engine2_heat = 0

	if simDR_idle_mode[0] == 1 then		-- ensures that idle speed is set to LOW (engine anti ice OFF)
		simCMD_hi_lo_idle_tog1:once()
	end
	
	if simDR_idle_mode[1] == 1 then		-- ensures that idle speed is set to LOW (engine anti ice OFF)
		simCMD_hi_lo_idle_tog2:once()
	end

end




----- SET STATE TO COLD & DARK ----------------------------------------------------------
local function A333_set_switches_CD()

    simDR_door_open[11] = OPEN              -- Cockpit door
    A333DR_cockpit_door_lock_mode = UNLOCKED

	A333_buttons_gen_apu_pos = 1
	A333_buttons_apu_gen_ctct_on_off = 1


	A333_switches_engine1_start_pos = 0
	A333_switches_engine2_start_pos = 0
	A333_buttons_battery1_pos = 0
	A333_buttons_battery2_pos = 0
	A333_buttons_battery1_ctct_on_off = 0
	A333_buttons_battery2_ctct_on_off = 0
	A333_buttons_apu_battery_pos = 0

	A333_buttons_gen1_pos = 1
	A333_buttons_gen1_ctct_on_off = 1
	A333_buttons_gen2_pos = 1
	A333_buttons_gen2_ctct_on_off = 1

	A333_buttons_bus_tie_pos = 1
	A333_buttons_bus_tie_ctct_on_off = 1
	bus_tie_pos = 1

	simDR_fd_command_bars_capt = 1
	simDR_fd_command_bars_fo = 1

	A333_switches_eng1_bleed_pos = 1
	A333_eng1_bleed_switch_ctct_on_off = 1
	simDR_eng1_bleed_sov = 0
	A333_switches_eng2_bleed_pos = 1
	A333_eng2_bleed_switch_ctct_on_off = 1
	simDR_eng2_bleed_sov = 0

	A333_flight_recorder_mode_on = 0

	A333_adirs_adr1_button_pos = 1
	simDR_adc1_fail_state = 0
	A333_adirs_adr3_button_pos = 1
	A333_adirs_adr2_button_pos = 1
	simDR_adc2_fail_state = 0

	A333_adirs_ir1_button_pos = 1
	simDR_ahars1_fail_state = 6
	A333_adirs_ir3_button_pos = 1
	A333_adirs_ir2_button_pos = 1
	simDR_ahars2_fail_state = 6

	A333_adirs_ir1_mode = 1
	A333_adirs_adr1_mode = 1
	A333_adirs_ir3_mode = 1
	A333_adirs_adr3_mode = 1
	A333_adirs_ir2_mode = 1
	A333_adirs_adr2_mode = 1

	A333_adirs_ir1_knob = 0
	A333_adirs_ir_align_fast_mode_override[0] = 0
	A333_adirs_ir3_knob = 0
	A333_adirs_ir_align_fast_mode_override[2] = 0
	A333_adirs_ir2_knob = 0
	A333_adirs_ir_align_fast_mode_override[1] = 0

	simDR_yaw_damper = 1
	A333_turb_damp_pos = 1

	simDR_instrument_brightness[13] = 0
	simDR_instrument_brightness[14] = 0

	A333_pax_sys_pos = 1
	A333_buttons_galley_pos = 1
	A333_buttons_commercial_pos = 1
	A333_pax_satcom_pos = 1
	A333_pax_IFEC_pos = 1

	A333_crew_oxy_pos = 0
	A333_crew_supply_status = 0

	A333_gpws_terr_tog_pos = 1
	A333_gpws_sys_tog_pos = 1
	A333_gpws_GS_tog_pos = 1
	A333_gpws_flap_tog_pos = 1

	A333_gpws_terr_status = 1
	A333_gpws_sys_status = 1
	A333_gpws_GS_status = 1
	A333_gpws_flap_status = 1

	A333_switches_seatbelts	= 0
	A333_switches_no_smoking = 2
	A333_call_emergency_tog_pos = 0

	A333_left_pump1_pos	= 0
	A333_left_pump2_pos	= 0
	A333_left_standby_pump_pos = 0

	A333_right_pump1_pos = 0
	A333_right_pump2_pos = 0
	A333_right_standby_pump_pos = 0

	A333_center_left_pump_pos = 0
	A333_center_right_pump_pos = 0

	A333_switches_hot_air1_pos = 1
	A333_switches_pack1_pos = 1
	A333_pack1_switch_ctct_on_off = 1
	simDR_pack1 = 1

	A333_switches_hot_air2_pos = 1
	A333_switches_pack2_pos = 1
	A333_pack2_switch_ctct_on_off = 1
	simDR_pack2 = 1

	A333_buttons_galley_pos = 1
	A333_galley_status = 1
	A333_buttons_commercial_pos = 1
	A333_commercial_status = 1

	A333_pax_sys_pos = 1
	A333_pax_satcom_pos = 1
	A333_pax_IFEC_pos = 1

	pax_sys_pos = 1
	pax_satcom_pos = 1
	pax_IFEC_pos = 1

	A333_cabin_fan_pos = 1
	simDR_cabin_fan_mode = 1
	A333_ventilation_extract_ovrd_pos = 1
	A333_ventilation_extract_status = 1

	A333DR_emer_exit_lt_switch_pos = 0
	A333DR_strobe_switch_pos = 1
	A333DR_nav_light_switch_pos = 0

	A333_cargo_cond_fwd_isol_valve_pos = 1
	A333_cargo_cond_bulk_isol_valve_pos = 1
	A333_cargo_cond_hot_air_pos = 1
	A333_cargo_cond_cooling_knob_pos = 1
	cargo_fwd_isol_valve_pos = 1
	cargo_bulk_isol_valve_pos = 1
	cargo_hot_air_pos = 1

	simDR_weather_pws_capt = 0

end



----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
local function A333_set_switches_ER()

    simDR_door_open[11] = CLOSED            -- Cockpit door
    A333DR_cockpit_door_lock_mode = LOCKED

	A333_buttons_gen_apu_pos = 1
	A333_buttons_apu_gen_ctct_on_off = 1

	A333_switches_engine1_start_pos = 1
	A333_switches_engine2_start_pos = 1
	A333_buttons_battery1_pos = 1
	A333_buttons_battery1_ctct_on_off = 1
	A333_buttons_battery2_pos = 1
	A333_buttons_battery2_ctct_on_off = 1
	A333_buttons_apu_battery_pos = 1
	A333_buttons_apu_bat_ctct_on_off = 1
	--simDR_generator1 = 1
	--simDR_generator2 = 1
	A333_buttons_gen1_pos = 1
	A333_buttons_gen1_ctct_on_off = 1
	A333_buttons_gen2_pos = 1
	A333_buttons_gen2_ctct_on_off = 1
	A333_buttons_bus_tie_pos = 1
	A333_buttons_bus_tie_ctct_on_off = 1
	bus_tie_pos = 1
	A333_switches_eng1_bleed_pos = 1
	A333_eng1_bleed_switch_ctct_on_off = 1
	simDR_eng1_bleed_sov = 1
	A333_switches_eng2_bleed_pos = 1
	A333_eng2_bleed_switch_ctct_on_off = 1
	simDR_eng2_bleed_sov = 1

	A333_left_pump1_pos = 1
	A333_left_pump2_pos = 1
	A333_left_standby_pump_pos = 1

	A333_right_pump1_pos = 1
	A333_right_pump2_pos = 1
	A333_right_standby_pump_pos = 1

	A333_center_left_pump_pos = 1
	A333_center_right_pump_pos = 1
	A333_flight_recorder_mode_on = 2

	A333_adirs_adr1_button_pos = 1
	simDR_adc1_fail_state = 0
	A333_adirs_adr3_button_pos = 1
	A333_adirs_adr2_button_pos = 1
	simDR_adc2_fail_state = 0

	A333_adirs_ir1_button_pos = 1
	simDR_ahars1_fail_state = 0
	A333_adirs_ir3_button_pos = 1
	A333_adirs_ir2_button_pos = 1
	simDR_ahars2_fail_state = 0

	A333_adirs_ir1_mode = 1
	A333_adirs_adr1_mode = 1
	A333_adirs_ir3_mode = 1
	A333_adirs_adr3_mode = 1
	A333_adirs_ir2_mode = 1
	A333_adirs_adr2_mode = 1

	A333_adirs_ir1_knob = 1
	A333_adirs_ir_align_fast_mode_override[0] = 0
	A333_adirs_ir3_knob = 1
	A333_adirs_ir_align_fast_mode_override[2] = 0
	A333_adirs_ir2_knob = 1
	A333_adirs_ir_align_fast_mode_override[1] = 0

	simDR_yaw_damper = 1
	A333_turb_damp_pos = 1

	simDR_instrument_brightness[13] = 0.008
	simDR_instrument_brightness[14] = 0.008

	A333_crew_oxy_pos = 1
	A333_crew_supply_status = 1
	
	A333_gpws_terr_tog_pos = 1
	A333_gpws_sys_tog_pos = 1
	A333_gpws_GS_tog_pos = 1
	A333_gpws_flap_tog_pos = 1

	A333_gpws_terr_status = 1
	A333_gpws_sys_status = 1
	A333_gpws_GS_status = 1
	A333_gpws_flap_status = 1

	A333_switches_seatbelts	= 2
	A333_switches_no_smoking = 2
	A333_call_emergency_tog_pos = 0

	A333_left_pump1_pos	= 1
	A333_left_pump2_pos	= 1
	A333_left_standby_pump_pos = 1

	A333_right_pump1_pos = 1
	A333_right_pump2_pos = 1
	A333_right_standby_pump_pos = 1

	A333_center_left_pump_pos = 1
	A333_center_right_pump_pos = 1

	A333_switches_hot_air1_pos = 1
	A333_switches_pack1_pos = 1
	A333_pack1_switch_ctct_on_off = 1
	simDR_pack1 = 1

	A333_switches_hot_air2_pos = 1
	A333_switches_pack2_pos = 1
	A333_pack2_switch_ctct_on_off = 1
	simDR_pack2 = 1

	A333_buttons_galley_pos = 1
	A333_galley_status = 1
	A333_buttons_commercial_pos = 1
	A333_commercial_status = 1

	A333_pax_sys_pos = 1
	A333_pax_satcom_pos = 1
	A333_pax_IFEC_pos = 1

	pax_sys_pos = 1
	pax_satcom_pos = 1
	pax_IFEC_pos = 1

	A333_cabin_fan_pos = 1
	simDR_cabin_fan_mode = 2
	A333_ventilation_extract_ovrd_pos = 1
	A333_ventilation_extract_status = 1

	A333DR_emer_exit_lt_switch_pos = 1
	A333DR_strobe_switch_pos = 1
	A333DR_nav_light_switch_pos = 1

	A333_cargo_cond_fwd_isol_valve_pos = 1
	A333_cargo_cond_bulk_isol_valve_pos = 1
	A333_cargo_cond_hot_air_pos = 1
	A333_cargo_cond_cooling_knob_pos = 1
	cargo_fwd_isol_valve_pos = 1
	cargo_bulk_isol_valve_pos = 1
	cargo_hot_air_pos = 1
	
	simDR_weather_pws_capt = 1

end


----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
local function A333_switches_monitor_AI()

    if A333DR_init_switches_CD == 1 then
        A333_set_switches_all_modes()
        A333_set_switches_CD()
        A333DR_init_switches_CD = 2
    end

end



----- FLIGHT START ---------------------------------------------------------------------
local function A333_flight_start_switches()

    -- ALL MODES ------------------------------------------------------------------------
    A333_set_switches_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then
        A333_set_switches_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then
		A333_set_switches_ER()

    end

end




local function A333_ALL_switches()

	lcl_SIM_PERIOD = SIM_PERIOD

	A333_button_switch_cover_animation()
	A333_guard_cover_animation()
	A333_knobs_switches()
	A333_rudder_trim_dial_animation()
	A333_engine_starter_cutoff_sentinel()
	A333_window_heat_ramp()
	A333_switches_monitor_AI()
	A333_ditching_mode()
	--A333_EFIS_mode()
	A333_terr_on_nd()
	A333_EFIS_wxr_radar()
	A333_flight_recorders()
	A333_audio_sel_volume()
	A333_apu_master_monitor()
	A333_apu_starter_monitor()
	A333_apu_bleed()
	A333_engine_bleed_sov_mgmt()
	A333_brake_fan_mgmt()
	A333_annunciator_brightness_set()
	A333_leak_measurement_switches()
	A333_flight_control_computer_power()
	A333_tcas_on_map()
	A333_att_rst()

    A333_cdls_power()
    A333_cockpit_door_locking_system()
    A333_cockpit_door_keypad_led()
	A333_emergency_call_sequence()
	A333_idle_reset_on_start()
	
end



--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--
--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

	A333_flight_start_switches()

end

--function flight_crash() end

function before_physics()

	A333_EFIS_mode()
	A333_baro_memory()

end

function after_physics()

	A333_ALL_switches()

end

function after_replay()

	A333_ALL_switches()
	A333_EFIS_mode()
	A333_baro_memory()

end



