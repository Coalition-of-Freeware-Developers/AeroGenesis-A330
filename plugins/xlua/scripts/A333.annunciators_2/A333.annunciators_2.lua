--[[
*****************************************************************************************
* Program Script Name	:	A333.annunciators_2
* Author Name			:	Alex Unruh
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2021-06-09	0.01a				Start of Dev
*
*
*
*
*****************************************************************************************
*        COPYRIGHT © 2021, 2022 Alex Unruh / LAMINAR RESEARCH - ALL RIGHTS RESERVED	    *
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

local bool2num = {[true] = 1, [false] = 0}



--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_flight_time				= find_dataref("sim/time/total_flight_time_sec")

simDR_annun_brightness_switch	= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[15]")
simDR_annun_brightness			= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_manual[15]")
simDR_annun_brightness2			= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_manual[16]")

simDR_bus1_volts				= find_dataref("sim/cockpit2/electrical/bus_volts[0]")
simDR_bus2_volts				= find_dataref("sim/cockpit2/electrical/bus_volts[1]")

simDR_master_caution_anunn		= find_dataref("sim/cockpit2/annunciators/master_caution")
simDR_master_warning_anunn		= find_dataref("sim/cockpit2/annunciators/master_warning")

simDR_crew_oxy					= find_dataref("sim/cockpit2/oxygen/actuators/o2_valve_on")
simDR_pax_oxy_fail				= find_dataref("sim/operation/failures/rel_pass_o2_on")

simDR_gpws_warn_annun			= find_dataref("sim/cockpit2/annunciators/GPWS")

simDR_nav1_vert_signal			= find_dataref("sim/cockpit2/radios/indicators/nav1_display_vertical")
simDR_gs_flag					= find_dataref("sim/cockpit2/radios/indicators/nav1_flag_glideslope")
simDR_nav1_vdef_dots			= find_dataref("sim/cockpit2/radios/indicators/nav1_vdef_dots_pilot")
simDR_aircraft_on_ground		= find_dataref("sim/flightmodel/failures/onground_all")

simDR_flight_director_capt		= find_dataref("sim/cockpit2/autopilot/flight_director_command_bars_pilot")
simDR_flight_director_fo		= find_dataref("sim/cockpit2/autopilot/flight_director_command_bars_copilot")

simDR_cargo_door_open			= find_dataref("sim/flightmodel2/misc/door_open_ratio[9]")

-- HYDRAULICS

simDR_elec_hydraulic_green_on	= find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump_on")
simDR_elec_hydraulic_blue_on	= find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump2_on")
simDR_elec_hydraulic_yellow_on	= find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump3_on")

simDR_elec_hyd_green_fault		= find_dataref("sim/operation/failures/rel_hydpmp_ele")
simDR_elec_hyd_blue_fault		= find_dataref("sim/operation/failures/rel_hydpmp_el2")
simDR_elec_hyd_yellow_fault		= find_dataref("sim/operation/failures/rel_hydpmp_el3")

simDR_engine1_hyd_pump_fault	= find_dataref("sim/operation/failures/rel_hydpmp")
simDR_engine2_hyd_pump_fault	= find_dataref("sim/operation/failures/rel_hydpmp2")

simDR_engine1_hyd_green			= find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpA[0]")
simDR_engine1_hyd_blue			= find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpC[0]")
simDR_engine2_hyd_green			= find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpA[1]")
simDR_engine2_hyd_yellow		= find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpB[1]")

simDR_green_pressure			= find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1")
simDR_blue_pressure				= find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_3")
simDR_yellow_pressure			= find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_2")

simDR_engine1_running			= find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[0]")
simDR_engine2_running			= find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[1]")
simDR_gear_on_ground			= find_dataref("sim/flightmodel2/gear/on_ground[1]")

-- ELEC

simDR_battery1						= find_dataref("sim/cockpit2/electrical/battery_on[0]")
simDR_battery2						= find_dataref("sim/cockpit2/electrical/battery_on[1]")
simDR_battery_apu					= find_dataref("sim/cockpit2/electrical/battery_on[2]")

simDR_bat1_failure					= find_dataref("sim/operation/failures/rel_batter0")
simDR_bat2_failure					= find_dataref("sim/operation/failures/rel_batter1")
simDR_bat_apu_failure				= find_dataref("sim/operation/failures/rel_batter2")

simDR_generator1					= find_dataref("sim/cockpit2/electrical/generator_on[0]")
simDR_generator2					= find_dataref("sim/cockpit2/electrical/generator_on[1]")
simDR_APU_generator					= find_dataref("sim/cockpit2/electrical/APU_generator_on")
simDR_IDG1_disconnect				= find_dataref("sim/operation/failures/rel_genera0")
simDR_IDG2_disconnect				= find_dataref("sim/operation/failures/rel_genera1")
simDR_bus_tie						= find_dataref("sim/cockpit2/electrical/cross_tie")
simDR_ESS_bus_assign				= find_dataref("sim/aircraft/electrical/essential_ties")

simDR_gen1_amps						= find_dataref("sim/cockpit2/electrical/generator_amps[0]")
simDR_gen2_amps						= find_dataref("sim/cockpit2/electrical/generator_amps[1]")
simDR_apu_gen_amps					= find_dataref("sim/cockpit2/electrical/APU_generator_amps")
simDR_apu_n1						= find_dataref("sim/cockpit2/electrical/APU_N1_percent")

simDR_gen1_failure					= find_dataref("sim/operation/failures/rel_genera0")
simDR_gen2_failure					= find_dataref("sim/operation/failures/rel_genera1")

simDR_gen1_volt_lo					= find_dataref("sim/operation/failures/rel_gen0_lo")
simDR_gen1_volt_hi					= find_dataref("sim/operation/failures/rel_gen0_hi")
simDR_gen2_volt_lo					= find_dataref("sim/operation/failures/rel_gen1_lo")
simDR_gen2_volt_hi					= find_dataref("sim/operation/failures/rel_gen1_hi")

simDR_ess_bus_fault					= find_dataref("sim/operation/failures/rel_esys4")

simDR_ext_a_status					= find_dataref("sim/cockpit/electrical/gpu_on")

simDR_aircraft_groundspeed			= find_dataref("sim/flightmodel/position/groundspeed")

-- AUTOPILOT

simDR_autothrottle_on				= find_dataref("sim/cockpit2/autopilot/autothrottle_arm")
simDR_autopilot1_on					= find_dataref("sim/cockpit2/autopilot/servos_on")
simDR_autopilot2_on					= find_dataref("sim/cockpit2/autopilot/servos2_on")
simDR_altitude_hold_status			= find_dataref("sim/cockpit2/autopilot/altitude_hold_status") -- 1 = armed, 2 = captured
simDR_approach_status				= find_dataref("sim/cockpit2/autopilot/approach_status") -- 1 = armed, 2 = captured
simDR_loc_status					= find_dataref("sim/cockpit2/autopilot/nav_status") -- 1 = armed, 2 = captured

simDR_alts_captured					= find_dataref("sim/cockpit2/autopilot/alts_captured")
simDR_altv_captured					= find_dataref("sim/cockpit2/autopilot/altv_captured")

-- AIR

simDR_engine_bleed1_status			= find_dataref("sim/cockpit2/bleedair/actuators/engine_bleed_sov[0]")
simDR_engine_bleed2_status			= find_dataref("sim/cockpit2/bleedair/actuators/engine_bleed_sov[1]")
simDR_apu_bleed_status				= find_dataref("sim/cockpit2/bleedair/actuators/apu_bleed")

simDR_engine_bleed1_fail			= find_dataref("sim/operation/failures/rel_bleed_air_lft")
simDR_engine_bleed2_fail			= find_dataref("sim/operation/failures/rel_bleed_air_rgt")
simDR_apu_bleed_fail				= find_dataref("sim/operation/failures/rel_APU_press")

simDR_pack_left_on					= find_dataref("sim/cockpit2/bleedair/actuators/pack_left")
simDR_pack_right_on					= find_dataref("sim/cockpit2/bleedair/actuators/pack_right")
simDR_bleed_air_avail_left			= find_dataref("sim/cockpit2/bleedair/indicators/bleed_available_left")
simDR_bleed_air_avail_right			= find_dataref("sim/cockpit2/bleedair/indicators/bleed_available_right")

simDR_altitude						= find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
simDR_belts_on						= find_dataref("sim/cockpit2/switches/fasten_seat_belts")
simDR_FADEC1_off					= find_dataref("sim/cockpit2/engine/actuators/fadec_on[0]")
simDR_FADEC2_off					= find_dataref("sim/cockpit2/engine/actuators/fadec_on[1]")
simDR_eng1_fuel_pump_off			= find_dataref("sim/cockpit2/engine/actuators/fuel_pump_on[0]")
simDR_eng2_fuel_pump_off			= find_dataref("sim/cockpit2/engine/actuators/fuel_pump_on[1]")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

A333_ann_light_switch_pos			= find_dataref("laminar/a333/switches/ann_light_pos")

-- FIRE

A333_apu_fire_test					= find_dataref("laminar/A333/fire/apu_test_on")
A333_engine_fire_test				= find_dataref("laminar/A333/fire/engine_test_on")
A333_cargo_fire_test				= find_dataref("laminar/A333/fire/cargo_test_on")

-- OXY

A333_pax_oxy_reset_pos				= find_dataref("laminar/A333/buttons/oxy/pax_oxy_maint_reset_pos")

-- MCP

A333_capt_ls_bars_status			= find_dataref("laminar/A333/status/capt_ls_bars")
A333_fo_ls_bars_status				= find_dataref("laminar/A333/status/fo_ls_bars")

-- GPWS

A333_gpws_terr_status				= find_dataref("laminar/A333/buttons/gpws/terrain_status")
A333_gpws_sys_status				= find_dataref("laminar/A333/buttons/gpws/system_status")
A333_gpws_GS_status					= find_dataref("laminar/A333/buttons/gpws/glideslope_status")
A333_gpws_flap_status				= find_dataref("laminar/A333/buttons/gpws/flap_status")

A333_flight_recorder_mode_on		= find_dataref("laminar/A333/buttons/rcdr/active_mode")

-- HYDRAULICS

A333_elec_pump_green_tog_pos		= find_dataref("laminar/A330/buttons/hyd/elec_green_tog_pos")
A333_elec_pump_blue_tog_pos			= find_dataref("laminar/A330/buttons/hyd/elec_blue_tog_pos")
A333_elec_pump_yellow_tog_pos		= find_dataref("laminar/A330/buttons/hyd/elec_yellow_tog_pos")

-- ELECTRICAL

A333_IDG1_status					= find_dataref("laminar/A333/status/elec/IDG1") -- 0 if OFF, 1 if ON
A333_IDG2_status					= find_dataref("laminar/A333/status/elec/IDG2") -- 0 if OFF, 1 if ON

A333_buttons_ACESS_FEED_pos			= find_dataref("laminar/A333/buttons/AC_ESS_FEED_pos")
A333_buttons_galley_pos				= find_dataref("laminar/A333/buttons/galley_pos")
A333_buttons_commercial_pos			= find_dataref("laminar/A333/buttons/commercial_pos")

A333_status_GPU_avail				= find_dataref("laminar/A333/status/GPU_avail")

A333_buttons_state_apu_gen			= find_dataref("laminar/A333/buttons/gen_apu_state")

-- MISC

A333_evac_command_pos				= find_dataref("laminar/A333/buttons/evac_command_pos")
A333_call_emergency_tog_pos			= find_dataref("laminar/A333/buttons/call/emergency_pos")
A333_ditching_status				= find_dataref("laminar/A333/ditching_status")

-- AIR

A333_switches_ram_air_pos			= find_dataref("laminar/A333/buttons/ram_air_pos")
A333_switches_hot_air1_pos			= find_dataref("laminar/A333/buttons/hot_air1_pos")
A333_switches_hot_air2_pos			= find_dataref("laminar/A333/buttons/hot_air2_pos")

A333_eng1_bleed_memory				= find_dataref("laminar/A333/switch_memory/eng1_bleed_on_off")
A333_eng2_bleed_memory				= find_dataref("laminar/A333/switch_memory/eng2_bleed_on_off")

-- FIRE

A333_eng1_agent1_psi				= find_dataref("laminar/A333/fire/status/eng1_agent1_psi")
A333_eng1_agent2_psi				= find_dataref("laminar/A333/fire/status/eng1_agent2_psi")
A333_eng2_agent1_psi				= find_dataref("laminar/A333/fire/status/eng2_agent1_psi")
A333_eng2_agent2_psi				= find_dataref("laminar/A333/fire/status/eng2_agent2_psi")
A333_apu_agent_psi					= find_dataref("laminar/A333/fire/status/apu_agent_psi")


A333DR_pack1_fault					= find_dataref("laminar/A333/data/pack1_fault", "number")
A333DR_pack2_fault					= find_dataref("laminar/A333/data/pack2_fault", "number")

A333_hyd_elec_blue_pump_fault 		= find_dataref("laminar/A333/hyd/elec_blue_pump_fault","number")
A333_hyd_elec_green_pump_fault 		= find_dataref("laminar/A333/hyd/elec_green_pump_fault","number")
A333_hyd_elec_yellow_pump_fault 	= find_dataref("laminar/A333/hyd/elec_yellow_pump_fault","number")
A333_hyd_eng1_blue_pump_fault 		= find_dataref("laminar/A333/hyd/eng1_blue_pump_fault","number")
A333_hyd_eng1_green_pump_fault 		= find_dataref("laminar/A333/hyd/eng1_green_pump_fault","number")
A333_hyd_eng2_green_pump_fault 		= find_dataref("laminar/A333/hyd/eng2_green_pump_fault","number")
A333_hyd_eng2_yellow_pump_fault 	= find_dataref("laminar/A333/hyd/eng2_yellow_pump_fault","number")


A333_buttons_bus_tie_pos			= find_dataref("laminar/A333/buttons/bus_tie_pos")

A333DR_gpws_mode5 					= find_dataref('laminar/A333/gpws/mode5')




--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

A333_annun_master_caution				= create_dataref("laminar/A333/annun/master_caution","number")
A333_annun_master_warning				= create_dataref("laminar/A333/annun/master_warning","number")

A333_annun_oxygen_crew_supply_off		= create_dataref("laminar/A333/annun/oxygen/crew_supply_off","number")
A333_annun_oxygen_pax_sys_on			= create_dataref("laminar/A333/annun/oxygen/pax_sys_on","number")
A333_annun_oxygen_tmr_reset_fault		= create_dataref("laminar/A333/annun/oxygen/tmr_reset_fault","number")
A333_annun_oxygen_tmr_reset_on			= create_dataref("laminar/A333/annun/oxygen/tmr_reset_on","number")

A333_tmr_reset_fault					= create_dataref("laminar/A333/status/oxygen/tmr_rst_fault", "number")

A333_annun_atc_comm						= create_dataref("laminar/A333/annun/atc_comm","number")
A333_annun_GPWS_warn					= create_dataref("laminar/A333/annun/GPWS_warn","number")
A333_annun_GS_warn						= create_dataref("laminar/A333/annun/GS_warn","number")

A333_annun_capt_flight_director_on		= create_dataref("laminar/A333/annun/capt_flight_director_on","number")
A333_annun_captain_ls_bars_on			= create_dataref("laminar/A333/annun/captain_ls_bars_on","number")
A333_annun_fo_flight_director_on		= create_dataref("laminar/A333/annun/fo_flight_director_on","number")
A333_annun_fo_ls_bars_on				= create_dataref("laminar/A333/annun/fo_ls_bars_on","number")

A333_annun_misc_leak_measure_y_off		= create_dataref("laminar/A333/annun/misc/leak_measure_y_off","number")

A333_annun_gpws_flap_mode_off			= create_dataref("laminar/A333/annun/gpws/flap_mode_off","number")
A333_annun_gpws_g_s_mode_off			= create_dataref("laminar/A333/annun/gpws/g_s_mode_off","number")
A333_annun_gpws_sys_off					= create_dataref("laminar/A333/annun/gpws/sys_off","number")
A333_annun_gpws_terr_off				= create_dataref("laminar/A333/annun/gpws/terr_off","number")

A333_annun_rcdr_gnd_ctl_on				= create_dataref("laminar/A333/annun/rcdr/gnd_ctl_on","number")
A333_annun_evac_command_evac			= create_dataref("laminar/A333/annun/evac/command_evac","number")
A333_annun_evac_command_on				= create_dataref("laminar/A333/annun/evac/command_on","number")
A333_annun_calls_emer_call				= create_dataref("laminar/A333/annun/calls/emer_call","number")
A333_annun_calls_emer_on				= create_dataref("laminar/A333/annun/calls/emer_on","number")
A333_annun_ditching_on					= create_dataref("laminar/A333/annun/ditching_on","number")
A333_annun_auto_land					= create_dataref("laminar/A333/annun/auto_land","number")

A333_annun_misc_toilet_occpd			= create_dataref("laminar/A333/annun/misc/toilet_occpd","number")

-- HYDRAULICS

A333_annun_hyd_elec_blue_fault			= create_dataref("laminar/A333/annun/hyd/elec_blue_fault","number")
A333_annun_hyd_elec_blue_off			= create_dataref("laminar/A333/annun/hyd/elec_blue_off","number")
A333_annun_hyd_elec_blue_on				= create_dataref("laminar/A333/annun/hyd/elec_blue_on","number")
A333_annun_hyd_elec_green_fault			= create_dataref("laminar/A333/annun/hyd/elec_green_fault","number")
A333_annun_hyd_elec_green_off			= create_dataref("laminar/A333/annun/hyd/elec_green_off","number")
A333_annun_hyd_elec_green_on			= create_dataref("laminar/A333/annun/hyd/elec_green_on","number")
A333_annun_hyd_elec_yellow_fault		= create_dataref("laminar/A333/annun/hyd/elec_yellow_fault","number")
A333_annun_hyd_elec_yellow_off			= create_dataref("laminar/A333/annun/hyd/elec_yellow_off","number")
A333_annun_hyd_elec_yellow_on			= create_dataref("laminar/A333/annun/hyd/elec_yellow_on","number")
A333_annun_hyd_eng1_blue_fault			= create_dataref("laminar/A333/annun/hyd/eng1_blue_fault","number")
A333_annun_hyd_eng1_blue_off			= create_dataref("laminar/A333/annun/hyd/eng1_blue_off","number")
A333_annun_hyd_eng1_green_fault			= create_dataref("laminar/A333/annun/hyd/eng1_green_fault","number")
A333_annun_hyd_eng1_green_off			= create_dataref("laminar/A333/annun/hyd/eng1_green_off","number")
A333_annun_hyd_eng2_green_fault			= create_dataref("laminar/A333/annun/hyd/eng2_green_fault","number")
A333_annun_hyd_eng2_green_off			= create_dataref("laminar/A333/annun/hyd/eng2_green_off","number")
A333_annun_hyd_eng2_yellow_fault		= create_dataref("laminar/A333/annun/hyd/eng2_yellow_fault","number")
A333_annun_hyd_eng2_yellow_off			= create_dataref("laminar/A333/annun/hyd/eng2_yellow_off","number")

-- AUTOPILOT ANNUNS

A333_annun_autopilot_a_thr_mode			= create_dataref("laminar/A333/annun/autopilot/a_thr_mode","number")
A333_annun_autopilot_alt_mode			= create_dataref("laminar/A333/annun/autopilot/alt_mode","number")
A333_annun_autopilot_ap1_mode			= create_dataref("laminar/A333/annun/autopilot/ap1_mode","number")
A333_annun_autopilot_ap2_mode			= create_dataref("laminar/A333/annun/autopilot/ap2_mode","number")
A333_annun_autopilot_appr_mode			= create_dataref("laminar/A333/annun/autopilot/appr_mode","number")
A333_annun_autopilot_loc_mode			= create_dataref("laminar/A333/annun/autopilot/loc_mode","number")

-- ELECTRICAL

A333_annun_elec_bat1_fault				= create_dataref("laminar/A333/annun/elec/bat1_fault","number")
A333_annun_elec_bat1_off				= create_dataref("laminar/A333/annun/elec/bat1_off","number")
A333_annun_elec_bat2_fault				= create_dataref("laminar/A333/annun/elec/bat2_fault","number")
A333_annun_elec_bat2_off				= create_dataref("laminar/A333/annun/elec/bat2_off","number")
A333_annun_elec_apu_bat_fault			= create_dataref("laminar/A333/annun/elec/apu_bat_fault","number")
A333_annun_elec_apu_bat_off				= create_dataref("laminar/A333/annun/elec/apu_bat_off","number")

A333_annun_elec_gen1_fault				= create_dataref("laminar/A333/annun/elec/gen1_fault","number")
A333_annun_elec_gen1_off_reset			= create_dataref("laminar/A333/annun/elec/gen1_off_reset","number")
A333_annun_elec_gen2_fault				= create_dataref("laminar/A333/annun/elec/gen2_fault","number")
A333_annun_elec_gen2_off_reset			= create_dataref("laminar/A333/annun/elec/gen2_off_reset","number")
A333_annun_elec_apu_gen_fault			= create_dataref("laminar/A333/annun/elec/apu_gen_fault","number")
A333_annun_elec_apu_gen_off_reset		= create_dataref("laminar/A333/annun/elec/apu_gen_off_reset","number")

A333_annun_elec_idg1_fault				= create_dataref("laminar/A333/annun/elec/idg1_fault","number")
A333_annun_elec_idg1_off				= create_dataref("laminar/A333/annun/elec/idg1_off","number")
A333_annun_elec_idg2_fault				= create_dataref("laminar/A333/annun/elec/idg2_fault","number")
A333_annun_elec_idg2_off				= create_dataref("laminar/A333/annun/elec/idg2_off","number")

A333_annun_elec_bus_tie_off				= create_dataref("laminar/A333/annun/elec/bus_tie_off","number")
A333_annun_elec_ac_ess_feed_altn		= create_dataref("laminar/A333/annun/elec/ac_ess_feed_altn","number")
A333_annun_elec_ac_ess_feed_fault		= create_dataref("laminar/A333/annun/elec/ac_ess_feed_fault","number")

A333_annun_elec_commercial_off			= create_dataref("laminar/A333/annun/elec/commercial_off","number")
A333_annun_elec_galley_off				= create_dataref("laminar/A333/annun/elec/galley_off","number")

A333_annun_elec_ext_a_avail				= create_dataref("laminar/A333/annun/elec/ext_a_avail","number")
A333_annun_elec_ext_a_on				= create_dataref("laminar/A333/annun/elec/ext_a_on","number")
A333_annun_elec_ext_b_auto				= create_dataref("laminar/A333/annun/elec/ext_b_auto","number")
A333_annun_elec_ext_b_avail				= create_dataref("laminar/A333/annun/elec/ext_b_avail","number")

-- AIR

A333_annun_apu_bleed_on					= create_dataref("laminar/A333/annun/apu_bleed_on","number")
A333_annun_apu_bleed_fault				= create_dataref("laminar/A333/annun/apu_bleed_fault","number")
A333_annun_eng1_bleed_fault				= create_dataref("laminar/A333/annun/eng1_bleed_fault","number")
A333_annun_eng1_bleed_off				= create_dataref("laminar/A333/annun/eng1_bleed_off","number")
A333_annun_eng2_bleed_fault				= create_dataref("laminar/A333/annun/eng2_bleed_fault","number")
A333_annun_eng2_bleed_off				= create_dataref("laminar/A333/annun/eng2_bleed_off","number")
A333_annun_pack1_fault					= create_dataref("laminar/A333/annun/pack1_fault","number")
A333_annun_pack1_off					= create_dataref("laminar/A333/annun/pack1_off","number")
A333_annun_pack2_fault					= create_dataref("laminar/A333/annun/pack2_fault","number")
A333_annun_pack2_off					= create_dataref("laminar/A333/annun/pack2_off","number")
A333_annun_ram_air_on					= create_dataref("laminar/A333/annun/ram_air_on","number")
A333_annun_hot_air1_off					= create_dataref("laminar/A333/annun/hot_air1_off","number")
A333_annun_hot_air2_off					= create_dataref("laminar/A333/annun/hot_air2_off","number")

-- TIMERS

A333_toilet_occupied					= create_dataref("laminar/A333/toilet/occupied", "number")
A333_toilet_period						= create_dataref("laminar/A333/toilet/period", "number")
A333_toilet_waitbetween					= create_dataref("laminar/A333/toilet/wait_between", "number")
A333_toilet_random_period				= create_dataref("laminar/A333/toilet/period_random", "number")
A333_toilet_random_wait					= create_dataref("laminar/A333/toilet/wait_between_random", "number")



--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--

function CPDLC_incoming_DRhandler() end

--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--

A333DR_CPDLC_incoming			= create_dataref("laminar/A333/CPDLC_incoming", "number", CPDLC_incoming_DRhandler)

--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--

function fix_all_systems_beforeCMDhandler(phase, duration) end
function fix_all_systems_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_tmr_reset_fault = 0
		A333_IDG1_status = 1
		A333_IDG2_status = 1
		A333_eng1_agent1_psi = 300
		A333_eng1_agent2_psi = 300
		A333_eng2_agent1_psi = 300
		A333_eng2_agent2_psi = 300
		A333_apu_agent_psi = 300

		simDR_FADEC1_off = 1
		simDR_FADEC2_off = 1
		simDR_eng1_fuel_pump_off = 1
		simDR_eng2_fuel_pump_off = 1

	end
end

--*************************************************************************************--
--** 				                 X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_fix_all_systems				= wrap_command("sim/operation/fix_all_systems", fix_all_systems_beforeCMDhandler, fix_all_systems_afterCMDhandler)

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

----- ANIMATION UTILITY -----------------------------------------------------------------
function A333_set_animation_position(current_value, target, min, max, speed)

    local fps_factor = math.min(1.0, speed * SIM_PERIOD)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
       return min
    else
        return current_value + ((target - current_value) * fps_factor)
    end

end

----- RESCALE ---------------------------------------------------------------------------
function A333_rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end




local annun_master_caution = 0
local annun_master_caution_target = 0
local annun_master_warning = 0
local annun_master_warning_target = 0

local annun_oxygen_crew_supply_off = 0
local annun_oxygen_pax_sys_on = 0
local annun_oxygen_crew_supply_off_target = 0
local annun_oxygen_pax_sys_on_target = 0

local annun_oxygen_tmr_reset_on = 0
local annun_oxygen_tmr_reset_fault = 0
local annun_oxygen_tmr_reset_on_target = 0
local annun_oxygen_tmr_reset_fault_target = 0

local oxy_reset_timer

local annun_atc_comm = 0
local annun_atc_comm_target = 0
local annun_GPWS_warn = 0
local annun_GPWS_warn_target = 0
local annun_GS_warn = 0
local annun_GS_warn_target = 0

local annun_capt_flight_director_on = 0
local annun_fo_flight_director_on = 0
local annun_capt_flight_director_on_target = 0
local annun_fo_flight_director_on_target = 0

local annun_captain_ls_bars_on = 0
local annun_fo_ls_bars_on = 0
local annun_captain_ls_bars_on_target = 0
local annun_fo_ls_bars_on_target = 0

local annun_misc_leak_measure_y_off = 0
local annun_misc_leak_measure_y_off_target = 0

local annun_gpws_flap_mode_off = 0
local annun_gpws_g_s_mode_off = 0
local annun_gpws_sys_off = 0
local annun_gpws_terr_off = 0

local annun_gpws_flap_mode_off_target = 0
local annun_gpws_g_s_mode_off_target = 0
local annun_gpws_sys_off_target = 0
local annun_gpws_terr_off_target = 0

local annun_rcdr_gnd_ctl_on = 0
local annun_evac_command_evac = 0
local annun_evac_command_on = 0
local annun_calls_emer_call = 0
local annun_calls_emer_on = 0
local annun_ditching_on = 0

local annun_rcdr_gnd_ctl_on_target = 0
local annun_evac_command_evac_target = 0
local annun_evac_command_on_target = 0
local annun_calls_emer_call_target = 0
local annun_calls_emer_on_target = 0
local annun_ditching_on_target = 0

local annun_hyd_elec_green_fault = 0
local annun_hyd_elec_green_off = 0
local annun_hyd_elec_green_on = 0

local annun_hyd_elec_blue_fault = 0
local annun_hyd_elec_blue_off = 0
local annun_hyd_elec_blue_on = 0

local annun_hyd_elec_yellow_fault = 0
local annun_hyd_elec_yellow_off = 0
local annun_hyd_elec_yellow_on = 0

local annun_hyd_elec_green_fault_target = 0
local annun_hyd_elec_green_off_target = 0
local annun_hyd_elec_green_on_target = 0

local annun_hyd_elec_blue_fault_target = 0
local annun_hyd_elec_blue_off_target = 0
local annun_hyd_elec_blue_on_target = 0

local annun_hyd_elec_yellow_fault_target = 0
local annun_hyd_elec_yellow_off_target = 0
local annun_hyd_elec_yellow_on_target = 0

local annun_hyd_eng1_green_fault = 0
local annun_hyd_eng1_green_off = 0
local annun_hyd_eng1_blue_fault = 0
local annun_hyd_eng1_blue_off = 0

local annun_hyd_eng2_yellow_fault = 0
local annun_hyd_eng2_yellow_off = 0
local annun_hyd_eng2_green_fault = 0
local annun_hyd_eng2_green_off = 0

local annun_hyd_eng1_green_fault_target = 0
local annun_hyd_eng1_green_off_target = 0
local annun_hyd_eng1_blue_fault_target = 0
local annun_hyd_eng1_blue_off_target = 0

local annun_hyd_eng2_yellow_fault_target = 0
local annun_hyd_eng2_yellow_off_target = 0
local annun_hyd_eng2_green_fault_target = 0
local annun_hyd_eng2_green_off_target = 0

-- ELECTRICAL

local annun_elec_bat1_off = 0
local annun_elec_bat2_off = 0
local annun_elec_apu_bat_off = 0
local annun_elec_bat1_fault = 0
local annun_elec_bat2_fault = 0
local annun_elec_apu_bat_fault = 0

local annun_elec_idg1_off = 0
local annun_elec_idg2_off = 0
local annun_elec_idg1_fault = 0
local annun_elec_idg2_fault = 0

local annun_elec_gen1_off_reset = 0
local annun_elec_gen2_off_reset = 0
local annun_elec_apu_gen_off_reset = 0

local annun_elec_bus_tie_off = 0
local annun_elec_ac_ess_feed_altn = 0
local annun_elec_ac_ess_feed_fault = 0

local annun_elec_commercial_off = 0
local annun_elec_galley_off = 0

local annun_elec_gen1_fault = 0
local annun_elec_gen2_fault = 0
local annun_elec_apu_gen_fault = 0

local annun_elec_ext_a_avail = 0
local annun_elec_ext_a_on = 0
local annun_elec_ext_b_auto = 0
local annun_elec_ext_b_avail = 0

local annun_elec_bat1_off_target = 0
local annun_elec_bat2_off_target = 0
local annun_elec_apu_bat_off_target = 0
local annun_elec_bat1_fault_target = 0
local annun_elec_bat2_fault_target = 0
local annun_elec_apu_bat_fault_target = 0

local annun_elec_idg1_off_target = 0
local annun_elec_idg2_off_target = 0
local annun_elec_idg1_fault_target = 0
local annun_elec_idg2_fault_target = 0

local annun_elec_gen1_off_reset_target = 0
local annun_elec_gen2_off_reset_target = 0
local annun_elec_apu_gen_off_reset_target = 0

local annun_elec_bus_tie_off_target = 0
local annun_elec_ac_ess_feed_altn_target = 0
local annun_elec_ac_ess_feed_fault_target = 0

local annun_elec_commercial_off_target = 0
local annun_elec_galley_off_target = 0

local annun_elec_gen1_fault_target = 0
local annun_elec_gen2_fault_target = 0
local annun_elec_apu_gen_fault_target = 0

local annun_elec_ext_a_avail_target = 0
local annun_elec_ext_a_on_target = 0
local annun_elec_ext_b_auto_target = 0
local annun_elec_ext_b_avail_target = 0

-- AUTOPILOT

local annun_autopilot_a_thr_mode = 0
local annun_autopilot_alt_mode = 0
local annun_autopilot_ap1_mode = 0
local annun_autopilot_ap2_mode = 0
local annun_autopilot_appr_mode = 0
local annun_autopilot_loc_mode = 0

local annun_autopilot_a_thr_mode_target = 0
local annun_autopilot_alt_mode_target = 0
local annun_autopilot_ap1_mode_target = 0
local annun_autopilot_ap2_mode_target = 0
local annun_autopilot_appr_mode_target = 0
local annun_autopilot_loc_mode_target = 0

local annun_auto_land = 0
local annun_auto_land_target = 0

local annun_apu_bleed_on = 0
local annun_apu_bleed_fault = 0
local annun_eng1_bleed_fault = 0
local annun_eng1_bleed_off = 0
local annun_eng2_bleed_fault = 0
local annun_eng2_bleed_off = 0
local annun_pack1_fault = 0
local annun_pack1_off = 0
local annun_pack2_fault = 0
local annun_pack2_off = 0
local annun_ram_air_on = 0
local annun_hot_air1_off = 0
local annun_hot_air2_off = 0

local annun_apu_bleed_on_target = 0
local annun_apu_bleed_fault_target = 0
local annun_eng1_bleed_fault_target = 0
local annun_eng1_bleed_off_target = 0
local annun_eng2_bleed_fault_target = 0
local annun_eng2_bleed_off_target = 0
local annun_pack1_fault_target = 0
local annun_pack1_off_target = 0
local annun_pack2_fault_target = 0
local annun_pack2_off_target = 0
local annun_ram_air_on_target = 0
local annun_hot_air1_off_target = 0
local annun_hot_air2_off_target = 0

local annun_misc_toilet_occpd = 0
local annun_misc_toilet_occpd_target = 0

local time_between_occupied = math.random(4, 18)
local time_occupied = math.random(3)
local occupied_timer = 0
local time_between_timer = 0
local occupied_running = 0

-- ANNUNCIATOR FUNCTIONS

function A333_annunciators3()

local flasher = 0
local flasher2 = 0
local mwFlasher = 0
local sim_time_factor = math.fmod(simDR_flight_time, 0.6)
local sim_time_factor2 = math.fmod(simDR_flight_time, 0.59)
local sim_time_factor3 = math.fmod(simDR_flight_time, 0.50)

	if sim_time_factor >= 0 and sim_time_factor <= 0.3 then
		flasher = 1
	end

	if sim_time_factor2 >= 0 and sim_time_factor2 <= 0.295 then
		flasher2 = 1
	end

	if sim_time_factor3 >= 0 and sim_time_factor3 <= 0.25 then
		mwFlasher = 1
	end

	function A333_atc_comm_off()
		annun_atc_comm_target = 0
	end



	if A333_ann_light_switch_pos <= 1 then

		annun_master_caution_target = simDR_master_caution_anunn
		annun_GPWS_warn_target = simDR_gpws_warn_annun
		annun_GS_warn_target = bool2num[A333DR_gpws_mode5 > 0]

		annun_capt_flight_director_on_target = simDR_flight_director_capt
		annun_fo_flight_director_on_target = simDR_flight_director_fo
		annun_captain_ls_bars_on_target = A333_capt_ls_bars_status
		annun_fo_ls_bars_on_target = A333_fo_ls_bars_status

		--[[
		if simDR_master_warning_anunn == 1 then
			annun_master_warning_target = 1
		elseif simDR_master_warning_anunn == 0 then
			if A333_apu_fire_test == 1 or A333_engine_fire_test == 1 or A333_cargo_fire_test == 1 then		-- TODO <<<<<< CARGO
				annun_master_warning_target = 1
			elseif A333_apu_fire_test == 0 and A333_engine_fire_test == 0 and A333_cargo_fire_test == 0 then
				annun_master_warning_target = 0
			end
		end--]]

		if simDR_master_warning_anunn >= 1 then
			annun_master_warning_target = flasher2
		elseif simDR_master_warning_anunn == 0 then
			annun_master_warning_target = 0
		end

		if simDR_crew_oxy == 0 then
			annun_oxygen_crew_supply_off_target = 1
		elseif simDR_crew_oxy == 1 then
			annun_oxygen_crew_supply_off_target = 0
		end

		if simDR_pax_oxy_fail == 6 then
			annun_oxygen_pax_sys_on_target = 1
		elseif simDR_pax_oxy_fail ~= 6 then
			annun_oxygen_pax_sys_on_target = 0
		end

		if A333_pax_oxy_reset_pos >= 1 then
			annun_oxygen_tmr_reset_on_target = 1
		elseif A333_pax_oxy_reset_pos == 0 then
			annun_oxygen_tmr_reset_on_target = 0
		end

		if A333_pax_oxy_reset_pos >= 1 then
			oxy_reset_timer = oxy_reset_timer + SIM_PERIOD
		elseif A333_pax_oxy_reset_pos == 0 then
			oxy_reset_timer = 0
		end

		if oxy_reset_timer > 30 then
			A333_tmr_reset_fault = 1
		end

		annun_oxygen_tmr_reset_fault_target = A333_tmr_reset_fault

		if A333DR_CPDLC_incoming == 1 then
			annun_atc_comm_target = 1
			A333DR_CPDLC_incoming = 0
		elseif A333DR_CPDLC_incoming == 0 then
			if annun_atc_comm_target == 1 then
				run_after_time(A333_atc_comm_off, 5)
			end
		end

		if simDR_cargo_door_open > 0 then
			annun_misc_leak_measure_y_off_target = 1
		elseif simDR_cargo_door_open == 0 then
			annun_misc_leak_measure_y_off_target = 0
		end

		if A333_gpws_flap_status == 0 then
			annun_gpws_flap_mode_off_target = 1
		elseif A333_gpws_flap_status == 1 then
			annun_gpws_flap_mode_off_target = 0
		end

		if A333_gpws_GS_status == 0 then
			annun_gpws_g_s_mode_off_target = 1
		elseif A333_gpws_GS_status == 1 then
			annun_gpws_g_s_mode_off_target = 0
		end

		if A333_gpws_sys_status == 0 then
			annun_gpws_sys_off_target = 1
		elseif A333_gpws_sys_status == 1 then
			annun_gpws_sys_off_target = 0
		end

		if A333_gpws_terr_status == 0 then
			annun_gpws_terr_off_target = 1
		elseif A333_gpws_terr_status == 1 then
			annun_gpws_terr_off_target = 0
		end

		if A333_flight_recorder_mode_on == 1 then
			annun_rcdr_gnd_ctl_on_target = 1
		elseif A333_flight_recorder_mode_on ~= 1 then
			annun_rcdr_gnd_ctl_on_target = 0
		end

		if A333_evac_command_pos >= 1 then
			annun_evac_command_on_target = 1
			annun_evac_command_evac_target = flasher
		elseif A333_evac_command_pos == 0 then
			annun_evac_command_on_target = 0
			annun_evac_command_evac_target = 0
		end

		if A333_call_emergency_tog_pos >= 1 then
			annun_calls_emer_call_target = flasher2
			annun_calls_emer_on_target = flasher2
		elseif A333_call_emergency_tog_pos == 0 then
			annun_calls_emer_call_target = 0
			annun_calls_emer_on_target = 0
		end

		annun_ditching_on_target = A333_ditching_status

	elseif A333_ann_light_switch_pos == 2 then

		annun_master_caution_target = 1
		annun_master_warning_target = 1
		annun_oxygen_crew_supply_off_target = 1
		annun_oxygen_pax_sys_on_target = 1
		annun_oxygen_tmr_reset_on_target = 1
		annun_oxygen_tmr_reset_fault_target = 1
		annun_atc_comm_target = 1
		annun_GPWS_warn_target = 1
		annun_GS_warn_target = 1

		annun_capt_flight_director_on_target = 1
		annun_fo_flight_director_on_target = 1
		annun_captain_ls_bars_on_target = 1
		annun_fo_ls_bars_on_target = 1
		annun_misc_leak_measure_y_off_target = 1

		annun_gpws_flap_mode_off_target = 1
		annun_gpws_g_s_mode_off_target = 1
		annun_gpws_sys_off_target = 1
		annun_gpws_terr_off_target = 1

		annun_rcdr_gnd_ctl_on_target = 1
		annun_evac_command_evac_target = 1
		annun_evac_command_on_target = 1
		annun_calls_emer_call_target = 1
		annun_calls_emer_on_target = 1
		annun_ditching_on_target = 1

	end

-- annunciator fade in --

	annun_master_caution = A333_set_animation_position(annun_master_caution, annun_master_caution_target, 0, 1, 13)
	annun_master_warning = A333_set_animation_position(annun_master_warning, annun_master_warning_target, 0, 1, 13)
	annun_oxygen_crew_supply_off = A333_set_animation_position(annun_oxygen_crew_supply_off, annun_oxygen_crew_supply_off_target, 0, 1, 13)
	annun_oxygen_pax_sys_on = A333_set_animation_position(annun_oxygen_pax_sys_on, annun_oxygen_pax_sys_on_target, 0, 1, 13)
	annun_oxygen_tmr_reset_on = A333_set_animation_position(annun_oxygen_tmr_reset_on, annun_oxygen_tmr_reset_on_target, 0, 1, 13)
	annun_oxygen_tmr_reset_fault = A333_set_animation_position(annun_oxygen_tmr_reset_fault, annun_oxygen_tmr_reset_fault_target, 0, 1, 13)
	annun_atc_comm = A333_set_animation_position(annun_atc_comm, annun_atc_comm_target, 0, 1, 13)
	annun_GPWS_warn = A333_set_animation_position(annun_GPWS_warn, annun_GPWS_warn_target, 0, 1, 13)
	annun_GS_warn = A333_set_animation_position(annun_GS_warn, annun_GS_warn_target, 0, 1, 13)

	annun_capt_flight_director_on = A333_set_animation_position(annun_capt_flight_director_on, annun_capt_flight_director_on_target, 0, 1, 13)
	annun_fo_flight_director_on = A333_set_animation_position(annun_fo_flight_director_on, annun_fo_flight_director_on_target, 0, 1, 13)
	annun_captain_ls_bars_on = A333_set_animation_position(annun_captain_ls_bars_on, annun_captain_ls_bars_on_target, 0, 1, 13)
	annun_fo_ls_bars_on = A333_set_animation_position(annun_fo_ls_bars_on, annun_fo_ls_bars_on_target, 0, 1, 13)
	annun_misc_leak_measure_y_off = A333_set_animation_position(annun_misc_leak_measure_y_off, annun_misc_leak_measure_y_off_target, 0, 1, 13)

	annun_gpws_flap_mode_off = A333_set_animation_position(annun_gpws_flap_mode_off, annun_gpws_flap_mode_off_target, 0, 1, 13)
	annun_gpws_g_s_mode_off = A333_set_animation_position(annun_gpws_g_s_mode_off, annun_gpws_g_s_mode_off_target, 0, 1, 13)
	annun_gpws_sys_off = A333_set_animation_position(annun_gpws_sys_off, annun_gpws_sys_off_target, 0, 1, 13)
	annun_gpws_terr_off = A333_set_animation_position(annun_gpws_terr_off, annun_gpws_terr_off_target, 0, 1, 13)

	annun_rcdr_gnd_ctl_on = A333_set_animation_position(annun_rcdr_gnd_ctl_on, annun_rcdr_gnd_ctl_on_target, 0, 1, 13)
	annun_evac_command_evac = A333_set_animation_position(annun_evac_command_evac, annun_evac_command_evac_target, 0, 1, 13)
	annun_evac_command_on = A333_set_animation_position(annun_evac_command_on, annun_evac_command_on_target, 0, 1, 13)
	annun_calls_emer_call = A333_set_animation_position(annun_calls_emer_call, annun_calls_emer_call_target, 0, 1, 13)
	annun_calls_emer_on = A333_set_animation_position(annun_calls_emer_on, annun_calls_emer_on_target, 0, 1, 13)
	annun_ditching_on = A333_set_animation_position(annun_ditching_on, annun_ditching_on_target, 0, 1, 13)

-- annunciator brightness --

	A333_annun_master_caution = annun_master_caution * simDR_annun_brightness2
	A333_annun_master_warning = annun_master_warning * simDR_annun_brightness2
	A333_annun_oxygen_crew_supply_off = annun_oxygen_crew_supply_off * simDR_annun_brightness
	A333_annun_oxygen_pax_sys_on = annun_oxygen_pax_sys_on * simDR_annun_brightness
	A333_annun_oxygen_tmr_reset_on = annun_oxygen_tmr_reset_on * simDR_annun_brightness
	A333_annun_oxygen_tmr_reset_fault = annun_oxygen_tmr_reset_fault * simDR_annun_brightness
	A333_annun_atc_comm = annun_atc_comm * simDR_annun_brightness
	A333_annun_GPWS_warn = annun_GPWS_warn * simDR_annun_brightness2
	A333_annun_GS_warn = annun_GS_warn * simDR_annun_brightness2

	A333_annun_capt_flight_director_on = annun_capt_flight_director_on * simDR_annun_brightness
	A333_annun_fo_flight_director_on = annun_fo_flight_director_on * simDR_annun_brightness
	A333_annun_captain_ls_bars_on = annun_captain_ls_bars_on * simDR_annun_brightness
	A333_annun_fo_ls_bars_on = annun_fo_ls_bars_on * simDR_annun_brightness
	A333_annun_misc_leak_measure_y_off = annun_misc_leak_measure_y_off * simDR_annun_brightness

	A333_annun_gpws_flap_mode_off = annun_gpws_flap_mode_off * simDR_annun_brightness
	A333_annun_gpws_g_s_mode_off = annun_gpws_g_s_mode_off * simDR_annun_brightness
	A333_annun_gpws_sys_off	= annun_gpws_sys_off * simDR_annun_brightness
	A333_annun_gpws_terr_off = annun_gpws_terr_off * simDR_annun_brightness

	A333_annun_rcdr_gnd_ctl_on = annun_rcdr_gnd_ctl_on * simDR_annun_brightness
	A333_annun_evac_command_evac = annun_evac_command_evac * simDR_annun_brightness
	A333_annun_evac_command_on = annun_evac_command_on * simDR_annun_brightness
	A333_annun_calls_emer_call = annun_calls_emer_call * simDR_annun_brightness
	A333_annun_calls_emer_on = annun_calls_emer_on * simDR_annun_brightness
	A333_annun_ditching_on = annun_ditching_on * simDR_annun_brightness

end

function A333_annunciators_HYD()

	if A333_ann_light_switch_pos <= 1 then

		-- ELECTRIC PUMP STATUS LIGHTS

		annun_hyd_elec_green_on_target = simDR_elec_hydraulic_green_on
		annun_hyd_elec_blue_on_target = simDR_elec_hydraulic_blue_on
		annun_hyd_elec_yellow_on_target = simDR_elec_hydraulic_yellow_on

		if A333_elec_pump_green_tog_pos == 0 then
			annun_hyd_elec_green_off_target = 1
		elseif A333_elec_pump_green_tog_pos >= 1 then
			annun_hyd_elec_green_off_target = 0
		end

		if A333_elec_pump_blue_tog_pos == 0 then
			annun_hyd_elec_blue_off_target = 1
		elseif A333_elec_pump_blue_tog_pos >= 1 then
			annun_hyd_elec_blue_off_target = 0
		end

		if A333_elec_pump_yellow_tog_pos == 0 then
			annun_hyd_elec_yellow_off_target = 1
		elseif A333_elec_pump_yellow_tog_pos >= 1 then
			annun_hyd_elec_yellow_off_target = 0
		end

		-- ELEC PUMP FAULTS

		if simDR_elec_hyd_green_fault == 6 then
			annun_hyd_elec_green_fault_target = 1
		elseif simDR_elec_hyd_green_fault ~= 6 then
			annun_hyd_elec_green_fault_target = 0
		end

		if simDR_elec_hyd_blue_fault == 6 then
			annun_hyd_elec_blue_fault_target = 1
		elseif simDR_elec_hyd_blue_fault ~= 6 then
			annun_hyd_elec_blue_fault_target = 0
		end

		if simDR_elec_hyd_yellow_fault == 6 then
			annun_hyd_elec_yellow_fault_target = 1
		elseif simDR_elec_hyd_yellow_fault ~= 6 then
			annun_hyd_elec_yellow_fault_target = 0
		end

		-- ENGINE PUMPS OFF

		if simDR_engine1_hyd_green == 0 then
			annun_hyd_eng1_green_off_target = 1
		elseif simDR_engine1_hyd_green >= 1 then
			annun_hyd_eng1_green_off_target = 0
		end

		if simDR_engine1_hyd_blue == 0 then
			annun_hyd_eng1_blue_off_target = 1
		elseif simDR_engine1_hyd_blue >= 1 then
			annun_hyd_eng1_blue_off_target = 0
		end

		if simDR_engine2_hyd_yellow == 0 then
			annun_hyd_eng2_yellow_off_target = 1
		elseif simDR_engine2_hyd_yellow >= 1 then
			annun_hyd_eng2_yellow_off_target = 0
		end

		if simDR_engine2_hyd_green == 0 then
			annun_hyd_eng2_green_off_target = 1
		elseif simDR_engine2_hyd_green >= 1 then
			annun_hyd_eng2_green_off_target = 0
		end

		-- ENGINE PUMP FAULTS

		if simDR_engine1_hyd_green == 0 then
			annun_hyd_eng1_green_fault_target = 0
		elseif simDR_engine1_hyd_green == 1 then

			if simDR_engine1_hyd_pump_fault ~= 6 then

				if simDR_engine1_running == 0 and simDR_gear_on_ground == 1 then
					annun_hyd_eng1_green_fault_target = 0
				elseif simDR_engine1_running == 1 or simDR_gear_on_ground == 0 then
					if simDR_green_pressure < 2000 then
						annun_hyd_eng1_green_fault_target = 1
					elseif simDR_green_pressure >= 2000 then
						annun_hyd_eng1_green_fault_target = 0
					end
				end

			elseif simDR_engine1_hyd_pump_fault == 6 then
				annun_hyd_eng1_green_fault_target = 1
			end

		end

		if simDR_engine1_hyd_blue == 0 then
			annun_hyd_eng1_blue_fault_target = 0
		elseif simDR_engine1_hyd_blue == 1 then

			if simDR_engine1_hyd_pump_fault ~= 6 then

				if simDR_engine1_running == 0 and simDR_gear_on_ground == 1 then
					annun_hyd_eng1_blue_fault_target = 0
				elseif simDR_engine1_running == 1 or simDR_gear_on_ground == 0 then
					if simDR_blue_pressure < 2000 then
						annun_hyd_eng1_blue_fault_target = 1
					elseif simDR_blue_pressure >= 2000 then
						annun_hyd_eng1_blue_fault_target = 0
					end
				end

			elseif simDR_engine1_hyd_pump_fault == 6 then
				annun_hyd_eng1_blue_fault_target = 1
			end

		end

		if simDR_engine2_hyd_yellow == 0 then
			annun_hyd_eng2_yellow_fault_target = 0
		elseif simDR_engine2_hyd_yellow == 1 then

			if simDR_engine2_hyd_pump_fault ~= 6 then

				if simDR_engine2_running == 0 and simDR_gear_on_ground == 1 then
					annun_hyd_eng2_yellow_fault_target = 0
				elseif simDR_engine2_running == 1 or simDR_gear_on_ground == 0 then
					if simDR_yellow_pressure < 2000 then
						annun_hyd_eng2_yellow_fault_target = 1
					elseif simDR_yellow_pressure >= 2000 then
						annun_hyd_eng2_yellow_fault_target = 0
					end
				end

			elseif simDR_engine2_hyd_pump_fault == 6 then
				annun_hyd_eng2_yellow_fault_target = 1
			end

		end

		if simDR_engine2_hyd_green == 0 then
			annun_hyd_eng2_green_fault_target = 0
		elseif simDR_engine2_hyd_green == 1 then

			if simDR_engine2_hyd_pump_fault ~= 6 then

				if simDR_engine2_running == 0 and simDR_gear_on_ground == 1 then
					annun_hyd_eng2_green_fault_target = 0
				elseif simDR_engine2_running == 1 or simDR_gear_on_ground == 0 then
					if simDR_green_pressure < 2000 then
						annun_hyd_eng2_green_fault_target = 1
					elseif simDR_green_pressure >= 2000 then
						annun_hyd_eng2_green_fault_target = 0
					end
				end

			elseif simDR_engine2_hyd_pump_fault == 6 then
				annun_hyd_eng2_green_fault_target = 1
			end

		end


	elseif A333_ann_light_switch_pos == 2 then

		annun_hyd_elec_green_fault_target = 1
		annun_hyd_elec_green_off_target = 1
		annun_hyd_elec_green_on_target = 1

		annun_hyd_elec_blue_fault_target = 1
		annun_hyd_elec_blue_off_target = 1
		annun_hyd_elec_blue_on_target = 1

		annun_hyd_elec_yellow_fault_target = 1
		annun_hyd_elec_yellow_off_target = 1
		annun_hyd_elec_yellow_on_target = 1

		annun_hyd_eng1_green_fault_target = 1
		annun_hyd_eng1_green_off_target = 1
		annun_hyd_eng1_blue_fault_target = 1
		annun_hyd_eng1_blue_off_target = 1

		annun_hyd_eng2_yellow_fault_target = 1
		annun_hyd_eng2_yellow_off_target = 1
		annun_hyd_eng2_green_fault_target = 1
		annun_hyd_eng2_green_off_target = 1


	end

-- annunciator fade in --

	annun_hyd_elec_green_fault = A333_set_animation_position(annun_hyd_elec_green_fault, annun_hyd_elec_green_fault_target, 0, 1, 13)
	annun_hyd_elec_green_off = A333_set_animation_position(annun_hyd_elec_green_off, annun_hyd_elec_green_off_target, 0, 1, 13)
	annun_hyd_elec_green_on = A333_set_animation_position(annun_hyd_elec_green_on, annun_hyd_elec_green_on_target, 0, 1, 13)

	annun_hyd_elec_blue_fault = A333_set_animation_position(annun_hyd_elec_blue_fault, annun_hyd_elec_blue_fault_target, 0, 1, 13)
	annun_hyd_elec_blue_off = A333_set_animation_position(annun_hyd_elec_blue_off, annun_hyd_elec_blue_off_target, 0, 1, 13)
	annun_hyd_elec_blue_on = A333_set_animation_position(annun_hyd_elec_blue_on, annun_hyd_elec_blue_on_target, 0, 1, 13)

	annun_hyd_elec_yellow_fault = A333_set_animation_position(annun_hyd_elec_yellow_fault, annun_hyd_elec_yellow_fault_target, 0, 1, 13)
	annun_hyd_elec_yellow_off = A333_set_animation_position(annun_hyd_elec_yellow_off, annun_hyd_elec_yellow_off_target, 0, 1, 13)
	annun_hyd_elec_yellow_on = A333_set_animation_position(annun_hyd_elec_yellow_on, annun_hyd_elec_yellow_on_target, 0, 1, 13)

	annun_hyd_eng1_green_fault = A333_set_animation_position(annun_hyd_eng1_green_fault, annun_hyd_eng1_green_fault_target, 0, 1, 13)
	annun_hyd_eng1_green_off = A333_set_animation_position(annun_hyd_eng1_green_off, annun_hyd_eng1_green_off_target, 0, 1, 13)
	annun_hyd_eng1_blue_fault = A333_set_animation_position(annun_hyd_eng1_blue_fault, annun_hyd_eng1_blue_fault_target, 0, 1, 13)
	annun_hyd_eng1_blue_off = A333_set_animation_position(annun_hyd_eng1_blue_off, annun_hyd_eng1_blue_off_target, 0, 1, 13)

	annun_hyd_eng2_yellow_fault = A333_set_animation_position(annun_hyd_eng2_yellow_fault, annun_hyd_eng2_yellow_fault_target, 0, 1, 13)
	annun_hyd_eng2_yellow_off = A333_set_animation_position(annun_hyd_eng2_yellow_off, annun_hyd_eng2_yellow_off_target, 0, 1, 13)
	annun_hyd_eng2_green_fault = A333_set_animation_position(annun_hyd_eng2_green_fault, annun_hyd_eng2_green_fault_target, 0, 1, 13)
	annun_hyd_eng2_green_off = A333_set_animation_position(annun_hyd_eng2_green_off, annun_hyd_eng2_green_off_target, 0, 1, 13)


-- annunciator brightness --

	A333_annun_hyd_elec_green_fault = annun_hyd_elec_green_fault * simDR_annun_brightness
	A333_annun_hyd_elec_green_off = annun_hyd_elec_green_off * simDR_annun_brightness
	A333_annun_hyd_elec_green_on = annun_hyd_elec_green_on * simDR_annun_brightness

	A333_annun_hyd_elec_blue_fault = annun_hyd_elec_blue_fault * simDR_annun_brightness
	A333_annun_hyd_elec_blue_off = annun_hyd_elec_blue_off * simDR_annun_brightness
	A333_annun_hyd_elec_blue_on = annun_hyd_elec_blue_on * simDR_annun_brightness

	A333_annun_hyd_elec_yellow_fault = annun_hyd_elec_yellow_fault * simDR_annun_brightness
	A333_annun_hyd_elec_yellow_off = annun_hyd_elec_yellow_off * simDR_annun_brightness
	A333_annun_hyd_elec_yellow_on = annun_hyd_elec_yellow_on * simDR_annun_brightness

	A333_annun_hyd_eng1_green_fault = annun_hyd_eng1_green_fault * simDR_annun_brightness
	A333_annun_hyd_eng1_green_off = annun_hyd_eng1_green_off * simDR_annun_brightness
	A333_annun_hyd_eng1_blue_fault = annun_hyd_eng1_blue_fault * simDR_annun_brightness
	A333_annun_hyd_eng1_blue_off = annun_hyd_eng1_blue_off * simDR_annun_brightness

	A333_annun_hyd_eng2_yellow_fault = annun_hyd_eng2_yellow_fault * simDR_annun_brightness
	A333_annun_hyd_eng2_yellow_off = annun_hyd_eng2_yellow_off * simDR_annun_brightness
	A333_annun_hyd_eng2_green_fault = annun_hyd_eng2_green_fault * simDR_annun_brightness
	A333_annun_hyd_eng2_green_off = annun_hyd_eng2_green_off * simDR_annun_brightness

end

function A333_annunciators_ELEC()

	if A333_ann_light_switch_pos <= 1 then

		if simDR_battery1 == 0 then
			annun_elec_bat1_off_target = 1
		elseif simDR_battery1 == 1 then
			annun_elec_bat1_off_target = 0
		end

		if simDR_battery2 == 0 then
			annun_elec_bat2_off_target = 1
		elseif simDR_battery2 == 1 then
			annun_elec_bat2_off_target = 0
		end

		if simDR_battery_apu == 0 then
			annun_elec_apu_bat_off_target = 1
		elseif simDR_battery_apu == 1 then
			annun_elec_apu_bat_off_target = 0
		end

		if simDR_bat1_failure == 6 then
			annun_elec_bat1_fault_target = 1
		elseif simDR_bat1_failure ~= 6 then
			annun_elec_bat1_fault_target = 0
		end

		if simDR_bat2_failure == 6 then
			annun_elec_bat2_fault_target = 1
		elseif simDR_bat2_failure ~= 6 then
			annun_elec_bat2_fault_target = 0
		end

		if simDR_bat_apu_failure == 6 then
			annun_elec_apu_bat_fault_target = 1
		elseif simDR_bat_apu_failure ~= 6 then
			annun_elec_apu_bat_fault_target = 0
		end

		if A333_IDG1_status == 0 then
			annun_elec_idg1_off_target = 1
		elseif A333_IDG1_status == 1 then
			annun_elec_idg1_off_target = 0
		end

		if A333_IDG2_status == 0 then
			annun_elec_idg2_off_target = 1
		elseif A333_IDG2_status == 1 then
			annun_elec_idg2_off_target = 0
		end

		if A333_IDG1_status == 1 then
			if simDR_gen1_failure == 6 then
				annun_elec_idg1_fault_target = 1
			elseif simDR_gen1_failure ~= 6 then
				annun_elec_idg1_fault_target = 0
			end
		elseif A333_IDG1_status == 0 then
			annun_elec_idg1_fault_target = 0
		end

		if A333_IDG2_status == 1 then
			if simDR_gen2_failure == 6 then
				annun_elec_idg2_fault_target = 1
			elseif simDR_gen2_failure ~= 6 then
				annun_elec_idg2_fault_target = 0
			end
		elseif A333_IDG2_status == 0 then
			annun_elec_idg2_fault_target = 0
		end

		if simDR_generator1 == 1 then
			annun_elec_gen1_off_reset_target = 0
		elseif simDR_generator1 == 0 then
			annun_elec_gen1_off_reset_target = 1
		end

		if simDR_generator2 == 1 then
			annun_elec_gen2_off_reset_target = 0
		elseif simDR_generator2 == 0 then
			annun_elec_gen2_off_reset_target = 1
		end

		if A333_buttons_state_apu_gen == 1 then
			annun_elec_apu_gen_off_reset_target = 0
		elseif A333_buttons_state_apu_gen == 0 then
			annun_elec_apu_gen_off_reset_target = 1
		end


		annun_elec_bus_tie_off_target = bool2num[A333_buttons_bus_tie_pos == 0.0]


		if A333_buttons_ACESS_FEED_pos == 0 then
			annun_elec_ac_ess_feed_altn_target = 0
		elseif A333_buttons_ACESS_FEED_pos >= 1 then
			annun_elec_ac_ess_feed_altn_target = 1
		end

		if simDR_ess_bus_fault == 6 then
			annun_elec_ac_ess_feed_fault_target = 1
		elseif simDR_ess_bus_fault ~= 6 then
			annun_elec_ac_ess_feed_fault_target = 0
		end

		if A333_buttons_galley_pos == 0 then
			annun_elec_galley_off_target = 1
		elseif A333_buttons_galley_pos >= 1 then
			annun_elec_galley_off_target = 0
		end

		if A333_buttons_commercial_pos == 0 then
			annun_elec_commercial_off_target = 1
		elseif A333_buttons_commercial_pos >= 1 then
			annun_elec_commercial_off_target = 0
		end

		if simDR_generator1 == 1 then
			if simDR_gen1_volt_lo == 6 or simDR_gen1_volt_hi == 6 then
				annun_elec_gen1_fault_target = 1
			elseif 	simDR_gen1_volt_lo ~= 6 and simDR_gen1_volt_hi ~= 6 then
				if simDR_gen1_amps < 10 then
					annun_elec_gen1_fault_target = 1
				elseif simDR_gen1_amps >= 10 then
					annun_elec_gen1_fault_target = 0
				end
			end
		elseif simDR_generator1 == 0 then
			if simDR_gen1_volt_lo == 6 or simDR_gen1_volt_hi == 6 then
				annun_elec_gen1_fault_target = 1
			elseif simDR_gen1_volt_lo ~= 6 and simDR_gen1_volt_hi ~= 6 then
				annun_elec_gen1_fault_target = 0
			end
		end

		if simDR_generator2 == 1 then
			if simDR_gen2_volt_lo == 6 or simDR_gen2_volt_hi == 6 then
				annun_elec_gen2_fault_target = 1
			elseif 	simDR_gen2_volt_lo ~= 6 and simDR_gen2_volt_hi ~= 6 then
				if simDR_gen2_amps < 10 then
					annun_elec_gen2_fault_target = 1
				elseif simDR_gen2_amps >= 10 then
					annun_elec_gen2_fault_target = 0
				end
			end
		elseif simDR_generator2 == 0 then
			if simDR_gen2_volt_lo == 6 or simDR_gen2_volt_hi == 6 then
				annun_elec_gen2_fault_target = 1
			elseif simDR_gen2_volt_lo ~= 6 and simDR_gen2_volt_hi ~= 6 then
				annun_elec_gen2_fault_target = 0
			end
		end

		if simDR_APU_generator == 0 then
			annun_elec_apu_gen_fault_target = 0
		elseif simDR_APU_generator == 1 then
			if simDR_apu_n1 < 14 then
				annun_elec_apu_gen_fault_target = 0
			elseif simDR_apu_n1 >= 14 then
				if simDR_apu_gen_amps < 5 then
					annun_elec_apu_gen_fault_target = 1
				elseif simDR_apu_gen_amps >= 5 then
					annun_elec_apu_gen_fault_target = 0
				end
			end
		end

		annun_elec_ext_a_on_target = simDR_ext_a_status

		if simDR_ext_a_status == 0 then
			annun_elec_ext_a_avail_target = A333_status_GPU_avail
		elseif simDR_ext_a_status == 1 then
			annun_elec_ext_a_avail_target = 0
		end

		annun_elec_ext_b_auto_target = 0
		annun_elec_ext_b_avail_target = 0

	elseif A333_ann_light_switch_pos == 2 then

		annun_elec_bat1_off_target = 1
		annun_elec_bat2_off_target = 1
		annun_elec_apu_bat_off_target = 1
		annun_elec_bat1_fault_target = 1
		annun_elec_bat2_fault_target = 1
		annun_elec_apu_bat_fault_target = 1

		annun_elec_idg1_off_target = 1
		annun_elec_idg2_off_target = 1
		annun_elec_idg1_fault_target = 1
		annun_elec_idg2_fault_target = 1

		annun_elec_gen1_off_reset_target = 1
		annun_elec_gen2_off_reset_target = 1
		annun_elec_apu_gen_off_reset_target = 1

		annun_elec_bus_tie_off_target = 1
		annun_elec_ac_ess_feed_altn_target = 1
		annun_elec_ac_ess_feed_fault_target = 1

		annun_elec_commercial_off_target = 1
		annun_elec_galley_off_target = 1

		annun_elec_gen1_fault_target = 1
		annun_elec_gen2_fault_target = 1
		annun_elec_apu_gen_fault_target = 1

		annun_elec_ext_a_avail_target = 1
		annun_elec_ext_a_on_target = 1
		annun_elec_ext_b_auto_target = 1
		annun_elec_ext_b_avail_target = 1

	end

-- annunciator fade in --

	annun_elec_bat1_off = A333_set_animation_position(annun_elec_bat1_off, annun_elec_bat1_off_target, 0, 1, 13)
	annun_elec_bat2_off = A333_set_animation_position(annun_elec_bat2_off, annun_elec_bat2_off_target, 0, 1, 13)
	annun_elec_apu_bat_off = A333_set_animation_position(annun_elec_apu_bat_off, annun_elec_apu_bat_off_target, 0, 1, 13)

	annun_elec_bat1_fault = A333_set_animation_position(annun_elec_bat1_fault, annun_elec_bat1_fault_target, 0, 1, 13)
	annun_elec_bat2_fault = A333_set_animation_position(annun_elec_bat2_fault, annun_elec_bat2_fault_target, 0, 1, 13)
	annun_elec_apu_bat_fault = A333_set_animation_position(annun_elec_apu_bat_fault, annun_elec_apu_bat_fault_target, 0, 1, 13)

	annun_elec_idg1_off = A333_set_animation_position(annun_elec_idg1_off, annun_elec_idg1_off_target, 0, 1, 13)
	annun_elec_idg2_off = A333_set_animation_position(annun_elec_idg2_off, annun_elec_idg2_off_target, 0, 1, 13)
	annun_elec_idg1_fault = A333_set_animation_position(annun_elec_idg1_fault, annun_elec_idg1_fault_target, 0, 1, 13)
	annun_elec_idg2_fault = A333_set_animation_position(annun_elec_idg2_fault, annun_elec_idg2_fault_target, 0, 1, 13)

	annun_elec_gen1_off_reset = A333_set_animation_position(annun_elec_gen1_off_reset, annun_elec_gen1_off_reset_target, 0, 1, 13)
	annun_elec_gen2_off_reset = A333_set_animation_position(annun_elec_gen2_off_reset, annun_elec_gen2_off_reset_target, 0, 1, 13)
	annun_elec_apu_gen_off_reset = A333_set_animation_position(annun_elec_apu_gen_off_reset, annun_elec_apu_gen_off_reset_target, 0, 1, 13)

	annun_elec_bus_tie_off = A333_set_animation_position(annun_elec_bus_tie_off, annun_elec_bus_tie_off_target, 0, 1, 13)
	annun_elec_ac_ess_feed_altn = A333_set_animation_position(annun_elec_ac_ess_feed_altn, annun_elec_ac_ess_feed_altn_target, 0, 1, 13)
	annun_elec_ac_ess_feed_fault = A333_set_animation_position(annun_elec_ac_ess_feed_fault, annun_elec_ac_ess_feed_fault_target, 0, 1, 13)

	annun_elec_commercial_off = A333_set_animation_position(annun_elec_commercial_off, annun_elec_commercial_off_target, 0, 1, 13)
	annun_elec_galley_off = A333_set_animation_position(annun_elec_galley_off, annun_elec_galley_off_target, 0, 1, 13)

	annun_elec_gen1_fault = A333_set_animation_position(annun_elec_gen1_fault, annun_elec_gen1_fault_target, 0, 1, 13)
	annun_elec_gen2_fault = A333_set_animation_position(annun_elec_gen2_fault, annun_elec_gen2_fault_target, 0, 1, 13)
	annun_elec_apu_gen_fault = A333_set_animation_position(annun_elec_apu_gen_fault, annun_elec_apu_gen_fault_target, 0, 1, 13)

	annun_elec_ext_a_avail = A333_set_animation_position(annun_elec_ext_a_avail, annun_elec_ext_a_avail_target, 0, 1, 13)
	annun_elec_ext_a_on = A333_set_animation_position(annun_elec_ext_a_on, annun_elec_ext_a_on_target, 0, 1, 13)
	annun_elec_ext_b_auto = A333_set_animation_position(annun_elec_ext_b_auto, annun_elec_ext_b_auto_target, 0, 1, 13)
	annun_elec_ext_b_avail = A333_set_animation_position(annun_elec_ext_b_avail, annun_elec_ext_b_avail_target, 0, 1, 13)

-- annunciator brightness --

	A333_annun_elec_bat1_off = annun_elec_bat1_off * simDR_annun_brightness
	A333_annun_elec_bat2_off = annun_elec_bat2_off * simDR_annun_brightness
	A333_annun_elec_apu_bat_off = annun_elec_apu_bat_off * simDR_annun_brightness

	A333_annun_elec_bat1_fault = annun_elec_bat1_fault * simDR_annun_brightness
	A333_annun_elec_bat2_fault = annun_elec_bat2_fault * simDR_annun_brightness
	A333_annun_elec_apu_bat_fault = annun_elec_apu_bat_fault * simDR_annun_brightness

	A333_annun_elec_idg1_off = annun_elec_idg1_off * simDR_annun_brightness
	A333_annun_elec_idg2_off = annun_elec_idg2_off * simDR_annun_brightness
	A333_annun_elec_idg1_fault = annun_elec_idg1_fault * simDR_annun_brightness
	A333_annun_elec_idg2_fault = annun_elec_idg2_fault * simDR_annun_brightness

	A333_annun_elec_gen1_off_reset = annun_elec_gen1_off_reset * simDR_annun_brightness
	A333_annun_elec_gen2_off_reset = annun_elec_gen2_off_reset * simDR_annun_brightness
	A333_annun_elec_apu_gen_off_reset = annun_elec_apu_gen_off_reset * simDR_annun_brightness

	A333_annun_elec_bus_tie_off = annun_elec_bus_tie_off * simDR_annun_brightness
	A333_annun_elec_ac_ess_feed_altn = annun_elec_ac_ess_feed_altn * simDR_annun_brightness
	A333_annun_elec_ac_ess_feed_fault = annun_elec_ac_ess_feed_fault * simDR_annun_brightness

	A333_annun_elec_commercial_off = annun_elec_commercial_off * simDR_annun_brightness
	A333_annun_elec_galley_off = annun_elec_galley_off * simDR_annun_brightness

	A333_annun_elec_gen1_fault = annun_elec_gen1_fault * simDR_annun_brightness
	A333_annun_elec_gen2_fault = annun_elec_gen2_fault * simDR_annun_brightness
	A333_annun_elec_apu_gen_fault = annun_elec_apu_gen_fault * simDR_annun_brightness


	-- Allows the GPU AVAIL annunciator to light up without aircraft power
	if simDR_annun_brightness <= 0.0 then
		A333_annun_elec_ext_a_avail = annun_elec_ext_a_avail * simDR_annun_brightness_switch
	else
		A333_annun_elec_ext_a_avail = annun_elec_ext_a_avail * simDR_annun_brightness
	end


	A333_annun_elec_ext_a_on = annun_elec_ext_a_on * simDR_annun_brightness
	A333_annun_elec_ext_b_auto = annun_elec_ext_b_auto * simDR_annun_brightness
	A333_annun_elec_ext_b_avail = annun_elec_ext_b_avail * simDR_annun_brightness

end

function A333_annunciators_AP()

	if A333_ann_light_switch_pos <= 1 then

		annun_autopilot_a_thr_mode_target = simDR_autothrottle_on
		annun_autopilot_ap1_mode_target = simDR_autopilot1_on
		annun_autopilot_ap2_mode_target = simDR_autopilot2_on

		if simDR_altitude_hold_status == 2 and simDR_alts_captured == 0 and simDR_altv_captured == 0 then
			annun_autopilot_alt_mode_target = 1
		elseif simDR_altitude_hold_status == 0 or simDR_alts_captured == 1 or simDR_altv_captured == 1 then
			annun_autopilot_alt_mode_target = 0
		end

		if simDR_approach_status >= 1 then
			annun_autopilot_appr_mode_target = 1
		elseif simDR_approach_status == 0 then
			annun_autopilot_appr_mode_target = 0
		end

		if simDR_loc_status >= 1 then
			annun_autopilot_loc_mode_target = 1
		elseif simDR_loc_status == 0 then
			annun_autopilot_loc_mode_target = 0
		end

		annun_auto_land_target = 0 -- TODO

	elseif A333_ann_light_switch_pos == 2 then

		annun_autopilot_a_thr_mode_target = 1
		annun_autopilot_alt_mode_target = 1
		annun_autopilot_ap1_mode_target = 1
		annun_autopilot_ap2_mode_target = 1
		annun_autopilot_appr_mode_target = 1
		annun_autopilot_loc_mode_target = 1
		annun_auto_land_target = 1

	end

-- annunciator fade in --

	annun_autopilot_a_thr_mode = A333_set_animation_position(annun_autopilot_a_thr_mode, annun_autopilot_a_thr_mode_target, 0, 1, 13)
	annun_autopilot_alt_mode = A333_set_animation_position(annun_autopilot_alt_mode, annun_autopilot_alt_mode_target, 0, 1, 13)
	annun_autopilot_ap1_mode = A333_set_animation_position(annun_autopilot_ap1_mode, annun_autopilot_ap1_mode_target, 0, 1, 13)
	annun_autopilot_ap2_mode = A333_set_animation_position(annun_autopilot_ap2_mode, annun_autopilot_ap2_mode_target, 0, 1, 13)
	annun_autopilot_appr_mode = A333_set_animation_position(annun_autopilot_appr_mode, annun_autopilot_appr_mode_target, 0, 1, 13)
	annun_autopilot_loc_mode = A333_set_animation_position(annun_autopilot_loc_mode, annun_autopilot_loc_mode_target, 0, 1, 13)
	annun_auto_land = A333_set_animation_position(annun_auto_land, annun_auto_land_target, 0, 1, 13)

-- annunciator brightness --

	A333_annun_autopilot_a_thr_mode = annun_autopilot_a_thr_mode * simDR_annun_brightness
	A333_annun_autopilot_alt_mode = annun_autopilot_alt_mode * simDR_annun_brightness
	A333_annun_autopilot_ap1_mode = annun_autopilot_ap1_mode * simDR_annun_brightness
	A333_annun_autopilot_ap2_mode = annun_autopilot_ap2_mode * simDR_annun_brightness
	A333_annun_autopilot_appr_mode = annun_autopilot_appr_mode * simDR_annun_brightness
	A333_annun_autopilot_loc_mode = annun_autopilot_loc_mode * simDR_annun_brightness
	A333_annun_auto_land = annun_auto_land * simDR_annun_brightness

end

function A333_annunciators_AIR()

	if A333_ann_light_switch_pos <= 1 then

		if simDR_apu_bleed_status == 0 then
			annun_apu_bleed_on_target = 0
		elseif simDR_apu_bleed_status == 1 then
			if simDR_apu_n1 < 95 then
				annun_apu_bleed_on_target = 0
			elseif simDR_apu_n1 >= 95 then
				annun_apu_bleed_on_target = 1
			end
		end

		if A333_eng1_bleed_memory == 0 then
			annun_eng1_bleed_off_target = 1
		elseif A333_eng1_bleed_memory == 1 then
			annun_eng1_bleed_off_target = 0
		end

		if A333_eng2_bleed_memory == 0 then
			annun_eng2_bleed_off_target = 1
		elseif A333_eng2_bleed_memory == 1 then
			annun_eng2_bleed_off_target = 0
		end

		if simDR_apu_bleed_fail == 6 then
			annun_apu_bleed_fault_target = 1
		elseif simDR_apu_bleed_fail ~= 6 then
			annun_apu_bleed_fault_target = 0
		end

		if simDR_engine_bleed1_fail == 6 then
			annun_eng1_bleed_fault_target = 1
		elseif simDR_engine_bleed1_fail ~= 6 then
			if A333_eng1_bleed_memory == simDR_engine_bleed1_status then
				annun_eng1_bleed_fault_target = 0
			elseif A333_eng1_bleed_memory ~= simDR_engine_bleed1_status then
				annun_eng1_bleed_fault_target = 1
			end
		end

		if simDR_engine_bleed2_fail == 6 then
			annun_eng2_bleed_fault_target = 1
		elseif simDR_engine_bleed2_fail ~= 6 then
			if A333_eng2_bleed_memory == simDR_engine_bleed2_status then
				annun_eng2_bleed_fault_target = 0
			elseif A333_eng2_bleed_memory ~= simDR_engine_bleed2_status then
				annun_eng2_bleed_fault_target = 1
			end
		end

		if simDR_pack_left_on == 1 then
			annun_pack1_off_target = 0
			if simDR_bleed_air_avail_left <= 0.5 then
				annun_pack1_fault_target = 1
			elseif simDR_bleed_air_avail_left > 0.5 then
				annun_pack1_fault_target = 0
			end
		elseif simDR_pack_left_on == 0 then
			annun_pack1_off_target = 1
			annun_pack1_fault_target = 0
		end

		if simDR_pack_right_on == 1 then
			annun_pack2_off_target = 0
			if simDR_bleed_air_avail_right <= 0.5 then
				annun_pack2_fault_target = 1
			elseif simDR_bleed_air_avail_right > 0.5 then
				annun_pack2_fault_target = 0
			end
		elseif simDR_pack_right_on == 0 then
			annun_pack2_off_target = 1
			annun_pack2_fault_target = 0
		end

		if A333_switches_ram_air_pos == 0 then
			annun_ram_air_on_target = 0
		elseif A333_switches_ram_air_pos >= 1 then
			annun_ram_air_on_target = 1
		end

		if A333_switches_hot_air1_pos >= 1 then
			annun_hot_air1_off_target = 0
		elseif A333_switches_hot_air1_pos == 0 then
			annun_hot_air1_off_target = 1
		end

		if A333_switches_hot_air2_pos >= 1 then
			annun_hot_air2_off_target = 0
		elseif A333_switches_hot_air2_pos == 0 then
			annun_hot_air2_off_target = 1
		end


	elseif A333_ann_light_switch_pos == 2 then

		annun_apu_bleed_on_target = 1
		annun_apu_bleed_fault_target = 1
		annun_eng1_bleed_fault_target = 1
		annun_eng1_bleed_off_target = 1
		annun_eng2_bleed_fault_target = 1
		annun_eng2_bleed_off_target = 1

		annun_pack1_fault_target = 1
		annun_pack1_off_target = 1
		annun_pack2_fault_target = 1
		annun_pack2_off_target = 1

		annun_ram_air_on_target = 1
		annun_hot_air1_off_target = 1
		annun_hot_air2_off_target = 1

	end

-- annunciator fade in --

	annun_apu_bleed_on = A333_set_animation_position(annun_apu_bleed_on, annun_apu_bleed_on_target, 0, 1, 13)
	annun_apu_bleed_fault = A333_set_animation_position(annun_apu_bleed_fault, annun_apu_bleed_fault_target, 0, 1, 13)
	annun_eng1_bleed_fault = A333_set_animation_position(annun_eng1_bleed_fault, annun_eng1_bleed_fault_target, 0, 1, 13)
	annun_eng1_bleed_off = A333_set_animation_position(annun_eng1_bleed_off, annun_eng1_bleed_off_target, 0, 1, 13)
	annun_eng2_bleed_fault = A333_set_animation_position(annun_eng2_bleed_fault, annun_eng2_bleed_fault_target, 0, 1, 13)
	annun_eng2_bleed_off = A333_set_animation_position(annun_eng2_bleed_off, annun_eng2_bleed_off_target, 0, 1, 13)

	annun_pack1_fault = A333_set_animation_position(annun_pack1_fault, annun_pack1_fault_target, 0, 1, 13)
	annun_pack1_off = A333_set_animation_position(annun_pack1_off, annun_pack1_off_target, 0, 1, 13)
	annun_pack2_fault = A333_set_animation_position(annun_pack2_fault, annun_pack2_fault_target, 0, 1, 13)
	annun_pack2_off = A333_set_animation_position(annun_pack2_off, annun_pack2_off_target, 0, 1, 13)

	annun_ram_air_on = A333_set_animation_position(annun_ram_air_on, annun_ram_air_on_target, 0, 1, 13)
	annun_hot_air1_off = A333_set_animation_position(annun_hot_air1_off, annun_hot_air1_off_target, 0, 1, 13)
	annun_hot_air2_off = A333_set_animation_position(annun_hot_air2_off, annun_hot_air2_off_target, 0, 1, 13)

-- annunciator brightness --

	A333_annun_apu_bleed_on = annun_apu_bleed_on * simDR_annun_brightness
	A333_annun_apu_bleed_fault = annun_apu_bleed_fault * simDR_annun_brightness
	A333_annun_eng1_bleed_fault = annun_eng1_bleed_fault * simDR_annun_brightness
	A333_annun_eng1_bleed_off = annun_eng1_bleed_off * simDR_annun_brightness
	A333_annun_eng2_bleed_fault = annun_eng2_bleed_fault * simDR_annun_brightness
	A333_annun_eng2_bleed_off = annun_eng2_bleed_off * simDR_annun_brightness

	A333_annun_pack1_fault = annun_pack1_fault * simDR_annun_brightness
	A333_annun_pack1_off = annun_pack1_off * simDR_annun_brightness
	A333_annun_pack2_fault = annun_pack2_fault * simDR_annun_brightness
	A333_annun_pack2_off = annun_pack2_off * simDR_annun_brightness

	A333_annun_ram_air_on = annun_ram_air_on * simDR_annun_brightness
	A333_annun_hot_air1_off = annun_hot_air1_off * simDR_annun_brightness
	A333_annun_hot_air2_off = annun_hot_air2_off * simDR_annun_brightness

	-- ECAM WARNING
	A333DR_pack1_fault = bool2num[annun_pack1_fault > 0.5]
	A333DR_pack2_fault = bool2num[annun_pack2_fault > 0.5]

end

function A333_annunciators_TOILET()


	if A333_ann_light_switch_pos <= 1 then

		if time_between_timer > time_between_occupied then
			time_between_timer = 0
			occupied_running = 1
			time_between_occupied = math.random(4, 18)
		elseif time_between_timer <= time_between_occupied then
			time_between_timer = time_between_timer + SIM_PERIOD/60
		end

		if occupied_timer > time_occupied then
			occupied_timer = 0
			occupied_running = 0
			time_occupied = math.random(3)
		elseif occupied_timer <= time_occupied then
			if occupied_running == 1 then
				occupied_timer = occupied_timer + SIM_PERIOD/60
			elseif occupied_running == 0 then
				occupied_timer = 0
			end
		end

		if simDR_aircraft_on_ground == 1 then
			if simDR_engine1_running == 1 or simDR_engine2_running == 1 then
				annun_misc_toilet_occpd_target = 0
			elseif simDR_engine1_running == 0 and simDR_engine2_running == 0 then
				annun_misc_toilet_occpd_target = occupied_running
			end
		elseif simDR_aircraft_on_ground == 0 then
			if simDR_altitude < 10000 then
				annun_misc_toilet_occpd_target = 0
			elseif simDR_altitude >= 10000 then
				if simDR_belts_on == 1 then
					annun_misc_toilet_occpd_target = 0
				elseif simDR_belts_on == 0 then
					annun_misc_toilet_occpd_target = occupied_running
				end
			end
		end

	elseif A333_ann_light_switch_pos == 2 then

		annun_misc_toilet_occpd_target = 1

	end

-- annunciator fade in --

	annun_misc_toilet_occpd = A333_set_animation_position(annun_misc_toilet_occpd, annun_misc_toilet_occpd_target, 0, 1, 13)

-- annunciator brightness --

	A333_annun_misc_toilet_occpd = annun_misc_toilet_occpd * simDR_annun_brightness

	A333_toilet_occupied = occupied_running
	A333_toilet_period = occupied_timer
	A333_toilet_waitbetween	= time_between_timer
	A333_toilet_random_period = time_occupied
	A333_toilet_random_wait = time_between_occupied


end





function A333_fws_hyd_pump_fault()

	A333_hyd_elec_blue_pump_fault = annun_hyd_elec_blue_fault_target
	A333_hyd_elec_green_pump_fault = annun_hyd_elec_green_fault_target
	A333_hyd_elec_yellow_pump_fault = annun_hyd_elec_yellow_fault_target
	A333_hyd_eng1_blue_pump_fault = annun_hyd_eng1_blue_fault_target
	A333_hyd_eng1_green_pump_fault = annun_hyd_eng1_green_fault_target
	A333_hyd_eng2_green_pump_fault = annun_hyd_eng2_green_fault_target
	A333_hyd_eng2_yellow_pump_fault = annun_hyd_eng2_yellow_fault_target

end








--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

function A333_ALL_annunciators_2()

	A333_annunciators3()
	A333_annunciators_HYD()
	A333_annunciators_ELEC()
	A333_annunciators_AP()
	A333_annunciators_AIR()
	A333_annunciators_TOILET()

end

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

	A333_tmr_reset_fault = 0

end

--function flight_crash() end

--function before_physics()

function after_physics()

	A333_fws_hyd_pump_fault()
	A333_ALL_annunciators_2()


end

function after_replay()

	A333_ALL_annunciators_2()

end
