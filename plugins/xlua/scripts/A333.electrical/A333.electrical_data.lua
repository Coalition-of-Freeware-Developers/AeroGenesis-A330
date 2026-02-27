--[[
*****************************************************************************************
* Program Script Name	:	A333.systems
* Author Name			:	Jim Gregory
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2025-08-11	0.01				Start of Dev
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
local OPEN = 0
local CLOSED = 1

local OFF = 0
local ON = 1




--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local sim_period = 0
local m = math

local num2bool = {[0] = false, [1] = true}
local bool2num = {[true] = 1, [false] = 0}

local ac_dc_transform = 0
local dc_ac_inversion = 0
local ac_min_volts = 0
local dc_min_volts = 0
local on_ground = false
local elec_emer_config = false
local elec_emer_config_level1 = false
local elec_emer_config_level2 = false
local battery_only_supply_on_ground = false
local battery_only_supply_in_flight = false
local batteries_only_supply = false




--*************************************************************************************--
--** 				            LOCAL UTILITY FUNCTIONS          			    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
simDR_override_getting_elec_ADG = find_dataref("sim/operation/override/getting_elec_ADG")	-- Override ADG auto-extension, for specfiying the behavior of the air-driven generator (ram-air turbine supplying electrical power)

simDR_elec_bus_tie_selective = find_dataref("sim/aircraft/electrical/bus_tie_selective")
simDR_elec_cross_tie = find_dataref("sim/cockpit2/electrical/cross_tie")
simDR_elec_ac_ess_ties = find_dataref("sim/aircraft/electrical/essential_ties")

simDR_acf_nom_bat_volt = find_dataref("sim/aircraft/electrical/acf_nom_bat_volt")
simDR_acf_nom_gen_volt = find_dataref("sim/aircraft/electrical/acf_nom_gen_volt")

simDR_elec_batt_on = find_dataref("sim/cockpit2/electrical/battery_on")
simDR_elec_bat1_on = find_dataref("sim/cockpit2/electrical/battery_on[0]")
simDR_elec_bat2_on = find_dataref("sim/cockpit2/electrical/battery_on[1]")
simDR_elec_bat3_on = find_dataref("sim/cockpit2/electrical/battery_on[2]")
simDR_elec_bat_volts = find_dataref("sim/cockpit2/electrical/battery_voltage_actual_volts")
simDR_elec_bat1_volts = find_dataref("sim/cockpit2/electrical/battery_voltage_actual_volts[0]")
simDR_elec_bat2_volts = find_dataref("sim/cockpit2/electrical/battery_voltage_actual_volts[1]")
simDR_elec_bat3_volts = find_dataref("sim/cockpit2/electrical/battery_voltage_actual_volts[2]")
simDR_elec_bat_amps = find_dataref("sim/cockpit2/electrical/battery_amps")
simDR_elec_bat1_amps = find_dataref("sim/cockpit2/electrical/battery_amps[0]")
simDR_elec_bat2_amps = find_dataref("sim/cockpit2/electrical/battery_amps[1]")
simDR_elec_bat3_amps = find_dataref("sim/cockpit2/electrical/battery_amps[2]")

simDR_elec_gen_on = find_dataref("sim/cockpit2/electrical/generator_on")
simDR_elec_gen1_on = find_dataref("sim/cockpit2/electrical/generator_on[0]")
simDR_elec_gen2_on = find_dataref("sim/cockpit2/electrical/generator_on[1]")
simDR_elec_gen_volts = find_dataref("sim/cockpit2/electrical/generator_volts")
simDR_elec_gen1_volts = find_dataref("sim/cockpit2/electrical/generator_volts[0]")
simDR_elec_gen2_volts = find_dataref("sim/cockpit2/electrical/generator_volts[1]")
simDR_elec_gen_amps = find_dataref("sim/cockpit2/electrical/generator_amps")
simDR_elec_gen1_amps = find_dataref("sim/cockpit2/electrical/generator_amps[0]")
simDR_elec_gen2_amps = find_dataref("sim/cockpit2/electrical/generator_amps[1]")

simDR_elec_apu_gen_on = find_dataref("sim/cockpit2/electrical/APU_generator_on")
simDR_elec_apu_running = find_dataref("sim/cockpit2/electrical/APU_running")
simDR_elec_apu_N1 = find_dataref("sim/cockpit2/electrical/APU_N1_percent")
simDR_elec_apu_gen_volts = find_dataref("sim/cockpit2/electrical/APU_generator_volts")
simDR_elec_apu_gen_amps = find_dataref("sim/cockpit2/electrical/APU_generator_amps")
simDR_elec_apu_switch = find_dataref("sim/cockpit2/electrical/APU_starter_switch")
simDR_elec_apu_door = find_dataref("sim/cockpit2/electrical/APU_door")

simDR_plugin_bus_amps = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps")

simDR_elec_gpu_gen_on = find_dataref("sim/cockpit2/electrical/GPU_generator_on")
--simDR_elec_gpu2_gen_on = find_dataref("sim/cockpit2/electrical/GPU2_generator_on")        -- NOT REAL, DO NOT USE
simDR_elec_gpu_gen_volts = find_dataref("sim/cockpit2/electrical/GPU_generator_volts")
--simDR_elec_gpu2_gen_volts = find_dataref("sim/cockpit2/electrical/GPU2_generator_volts")  -- NOT REAL, DO NOT USE
simDR_elec_gpu_gen_amps = find_dataref("sim/cockpit2/electrical/GPU_generator_amps")

simDR_elec_emer_gen_on = find_dataref("sim/cockpit2/electrical/RAT_generator_on")
simDR_elec_emer_gen_volts = find_dataref("sim/cockpit2/electrical/RAT_generator_volts")
simDR_elec_emer_gen_amps = find_dataref("sim/cockpit2/electrical/RAT_generator_amps")

simDR_elec_bus_volts = find_dataref("sim/cockpit2/electrical/bus_volts")
simDR_elec_bus0_volts = find_dataref("sim/cockpit2/electrical/bus_volts[0]")    -- APU/GPU BUS
simDR_elec_bus1_volts = find_dataref("sim/cockpit2/electrical/bus_volts[1]")    -- AC BUS 1
simDR_elec_bus2_volts = find_dataref("sim/cockpit2/electrical/bus_volts[2]")    -- AC BUS 2
simDR_elec_bus3_volts = find_dataref("sim/cockpit2/electrical/bus_volts[3]")    -- AC ESS BUS
simDR_elec_bus4_volts = find_dataref("sim/cockpit2/electrical/bus_volts[4]")    -- DC BATTERY BUS
simDR_elec_bus5_volts = find_dataref("sim/cockpit2/electrical/bus_volts[5]")    -- DC APU BATTERY BUS

simDR_elec_plugin_bus_amps = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps")
simDR_elec_plugin_bus0_amps = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[0]")
simDR_elec_plugin_bus1_amps = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[1]")
simDR_elec_plugin_bus2_amps = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[2]")
simDR_elec_plugin_bus3_amps = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[3]")
simDR_elec_plugin_bus4_amps = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[3]")
simDR_elec_plugin_bus5_amps = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[3]")

simDR_elec_bus_amps = find_dataref("sim/cockpit2/electrical/bus_load_amps")
simDR_elec_bus0_amps = find_dataref("sim/cockpit2/electrical/bus_load_amps[0]")
simDR_elec_bus1_amps = find_dataref("sim/cockpit2/electrical/bus_load_amps[1]")
simDR_elec_bus2_amps = find_dataref("sim/cockpit2/electrical/bus_load_amps[2]")
simDR_elec_bus3_amps = find_dataref("sim/cockpit2/electrical/bus_load_amps[3]")
simDR_elec_bus4_amps = find_dataref("sim/cockpit2/electrical/bus_load_amps[4]")
simDR_elec_bus5_amps = find_dataref("sim/cockpit2/electrical/bus_load_amps[5]")

simDR_engine1_fire = find_dataref("sim/cockpit2/annunciators/engine_fires[0]")
simDR_engine2_fire = find_dataref("sim/cockpit2/annunciators/engine_fires[1]")

simDR_gen1_hi_voltage = find_dataref("sim/operation/failures/rel_gen0_hi")
simDR_gen1_lo_voltage = find_dataref("sim/operation/failures/rel_gen0_lo")
simDR_gen2_hi_voltage = find_dataref("sim/operation/failures/rel_gen1_hi")
simDR_gen2_lo_voltage = find_dataref("sim/operation/failures/rel_gen1_lo")

simDR_gen1_fail = find_dataref("sim/operation/failures/rel_genera0")
simDR_gen2_fail = find_dataref("sim/operation/failures/rel_genera1")

simDR_gear_on_ground = find_dataref("sim/flightmodel2/gear/on_ground[1]")

simDR_ind_airspeed = find_dataref("sim/flightmodel/position/indicated_airspeed")

simDR_nose_gear_deploy_status = find_dataref("sim/flightmodel2/gear/deploy_ratio[0]")
simDR_left_gear_deploy_status = find_dataref("sim/flightmodel2/gear/deploy_ratio[1]")
simDR_right_gear_deploy_status = find_dataref("sim/flightmodel2/gear/deploy_ratio[2]")

simDR_bus0_failure = find_dataref("sim/operation/failures/rel_esys")
simDR_bus1_failure = find_dataref("sim/operation/failures/rel_esys2")
simDR_bus2_failure = find_dataref("sim/operation/failures/rel_esys3")
simDR_bus3_failure = find_dataref("sim/operation/failures/rel_esys4")
simDR_bus4_failure = find_dataref("sim/operation/failures/rel_esys5")
simDR_bus5_failure = find_dataref("sim/operation/failures/rel_esys6")

simDR_plugin_bus_amps = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps")

simDR_slat1_deploy_ratio =  find_dataref("sim/flightmodel2/controls/slat1_deploy_ratio")
simDR_slat2_deploy_ratio =  find_dataref("sim/flightmodel2/controls/slat2_deploy_ratio")

simDR_green_hydraulic_pressure = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1")

simDR_RAT_extended = find_dataref("sim/cockpit2/electrical/RAT_generator_extended")



--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--
A333_bus_tie_button_ctct_open_closed = find_dataref("laminar/A333/buttons/bus_tie_ctct_state")
A333_bat1_button_ctct_open_closed = find_dataref("laminar/A333/buttons/batt1_ctct_on_off")
A333_bat2_button_ctct_open_closed = find_dataref("laminar/A333/buttons/batt2_ctct_on_off")
A333_gen1_button_ctct_open_closed = find_dataref("laminar/A333/buttons/gen1_ctct_on_off")
A333_gen2_button_ctct_open_closed = find_dataref("laminar/A333/buttons/gen2_ctct_on_off")
A333_apu_bat_button_ctct_open_closed = find_dataref("laminar/A333/buttons/apu_battery_ctct_on_off")
A333_apu_gen_button_ctct_open_closed = find_dataref("laminar/A333/buttons/gen_apu_state")
A333_extA_button_ctct_open_closed = find_dataref("laminar/A333/buttons/ext_power_A_ctct_on_off")
A333_extB_button_ctct_open_closed = find_dataref("laminar/A333/buttons/ext_power_B_ctct_on_off")
A333_buttons_land_rcvry_ctct_open_closed = find_dataref("laminar/A333/buttons/land_rcvry_ctct_on_off")
A333_buttons_apu_master_ctct_open_closed = find_dataref("laminar/A333/buttons/apu_master_ctct_on_off")
A333_buttons_ess_feed_ctct_on_off = find_dataref("laminar/A333/buttons/ess_feed_ctct_state")


A333_gen1_hertz = find_dataref("laminar/A333/ecam/gen1_hz")
A333_gen2_hertz = find_dataref("laminar/A333/ecam/gen2_hz")

A333_eng1_fire_handle_pos = find_dataref("laminar/A333/fire/switches/eng1_handle")
A333_eng2_fire_handle_pos = find_dataref("laminar/A333/fire/switches/eng2_handle")
A333_apu_fire_handle_pos = find_dataref("laminar/A333/fire/switches/apu_handle")

A333DR_elec_emer_config = find_dataref("laminar/A333/elec/emer_config")

A333DR_trent700_n3_eng1 = find_dataref("laminar/A333/trent700/n3_eng1")
A333DR_trent700_n3_eng2 = find_dataref("laminar/A333/trent700/n3_eng2")

A333DR_fws_eng_gen1_fault = find_dataref("laminar/A333/fws/eng_gen1_fault")
A333DR_fws_eng_gen2_fault = find_dataref("laminar/A333/fws/eng_gen2_fault")

A333DR_IDG1_status = find_dataref("laminar/A333/status/elec/IDG1")
A333DR_IDG2_status = find_dataref("laminar/A333/status/elec/IDG2")

A333DR_emer_gen_test_button_pos = find_dataref("laminar/A333/elec/emer_gen_test_button_pos")
A333DR_emer_gen_man_on_button_pos = find_dataref("laminar/A333/elec/emer_gen_man_on_button_pos")

A333DR_elec_loss_of_bus_ac1 = find_dataref("laminar/A333/elec/loss_of_bus_ac1")
A333DR_elec_loss_of_bus_ac2 = find_dataref("laminar/A333/elec/loss_of_bus_ac2")

A333DR_hyd_rat_actuator_deploy_angle_deg = find_dataref('laminar/A333/hyd/rat_actuator_deploy_angle_deg')
A333DR_hyd_rat_actuator_deploy_angle_target_deg = find_dataref('laminar/A333/hyd/rat_actuator_deploy_angle_target_deg')





--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
A333DR_ac_min_volts = create_dataref("laminar/A333/elec/ac_min_volts", "number")
A333DR_dc_min_volts = create_dataref("laminar/A333/elec/dc_min_volts", "number")
A333DR_batteries_only_supply_on_ground = create_dataref("laminar/A333/elec/batteries_only_supply_on_ground", "number")
A333DR_batteries_only_supply_in_flight = create_dataref("laminar/A333/elec/batteries_only_supply_in_flight", "number")
A333DR_batteries_only_supply = create_dataref("laminar/A333/elec/batteries_only_supply", "number")
A333DR_gear_on_ground = create_dataref("laminar/A333/gear/on_ground", "number")

A333DR_bat1_line_contactor = create_dataref("laminar/A333/elec/bat1_line_cntor", "number")
A333DR_bat2_line_contactor = create_dataref("laminar/A333/elec/bat2_line_cntor", "number")
A333DR_apu_bat_line_contactor = create_dataref("laminar/A333/elec/apu_bat_line_cntor", "number")

A333DR_gen1_line_contactor = create_dataref("laminar/A333/elec/gen1_line_cntor", "number")
A333DR_gen2_line_contactor = create_dataref("laminar/A333/elec/gen2_line_cntor", "number")

A333DR_extA_line_contactor = create_dataref("laminar/A333/elec/extA_line_cntor", "number")
A333DR_extB_line_contactor = create_dataref("laminar/A333/elec/extB_line_cntor", "number")
A333DR_apu_gen_line_contactor = create_dataref("laminar/A333/elec/apu_gen_line_cntor", "number")

A330DR_elec_sys_isol_contactor = create_dataref("laminar/A333/elec/sys_isol_contactor", "number")
A330DR_elec_ac1_bus_tie_contactor = create_dataref("laminar/A333/elec/ac1_bus_tie_contactor", "number")
A330DR_elec_ac2_bus_tie_contactor = create_dataref("laminar/A333/elec/ac2_bus_tie_contactor", "number")

A333DR_emer_gen_line_contactor = create_dataref("laminar/A333/elec/emer_gen_line_cntor", "number")

A333DR_ess_feed_line_contactor1 = create_dataref("laminar/A333/elec/ess_feed_line_contactor1", "number")
A333DR_ess_feed_line_contactor2 = create_dataref("laminar/A333/elec/ess_feed_line_contactor2", "number")

A333DR_tr1_line_contactor = create_dataref("laminar/A333/elec/tr1_line_contactor", "number")
A333DR_tr2_line_contactor = create_dataref("laminar/A333/elec/tr2_line_contactor", "number")
A333DR_ess_tr_line_contactor = create_dataref("laminar/A333/elec/ess_tr_line_contactor", "number")
A333DR_apu_tr_line_contactor = create_dataref("laminar/A333/elec/apu_tr_line_contactor", "number")

A333DR_dc1_tie_contactor = create_dataref("laminar/A333/elec/dc1_tie_contactor", "number")
A333DR_dc2_tie_contactor = create_dataref("laminar/A333/elec/dc2_tie_contactor", "number")
A333DR_dc_ess_tie_contactor = create_dataref("laminar/A333/elec/dc_ess_tie_contactor", "number")
A333DR_dc_bat1_ess_tie_contactor = create_dataref("laminar/A333/elec/dc_bat1_ess_tie_contactor", "number")
A333DR_dc_bat2_ess_tie_contactor = create_dataref("laminar/A333/elec/dc_bat2_ess_tie_contactor", "number")

A333DR_ac_ess_shed_switch = create_dataref("laminar/A333/elec/ac_ess_shed_switch", "number")
A333DR_ac_ess_switch = create_dataref("laminar/A333/elec/ac_ess_switch", "number")
A333DR_ac_ess_ground_switch = create_dataref("laminar/A333/elec/ac_ess_ground_switch", "number")
A333DR_ac_ess_land_rcvry_switch = create_dataref("laminar/A333/elec/ac_ess_land_rcvry_switch", "number")

A333DR_dc_ess_shed_switch = create_dataref("laminar/A333/elec/dc_ess_shed_switch", "number")
A333DR_dc_ess_shed_land_rcvry_switch = create_dataref("laminar/A333/elec/dc_ess_shed_land_rcvry_switch", "number")
A333DR_dc_ess_land_rcvry_switch = create_dataref("laminar/A333/elec/dc_ess_land_rcvry_switch", "number")


A333DR_status_gpu_on = create_dataref("laminar/A333/status/GPU_on", "number")
A333DR_status_gpu_avail = create_dataref("laminar/A333/status/GPU_avail", "number")
A333DR_status_gpu2_avail = create_dataref("laminar/A333/status/GPU2_avail", "number")

A333DR_extA_ground_service_bus_volts = create_dataref("laminar/A333/elec/extA_ground_service_bus_volts", "number")
A333DR_elec_emer_gen_fault = create_dataref("laminar/A333/elec/emer_gen_fault", "number")
A333DR_ac_bus1_volts = create_dataref("laminar/A333/elec/ac_bus1_volts", "number")
A333DR_ac_bus2_volts = create_dataref("laminar/A333/elec/ac_bus2_volts", "number")
A333DR_ac_ess_bus_volts = create_dataref("laminar/A333/elec/ac_ess_bus_volts", "number")
A333DR_ac_ess_shed_bus_volts = create_dataref("laminar/A333/elec/ac_ess_shed_bus_volts", "number")
A333DR_ac_ess_grnd_bus_volts = create_dataref("laminar/A333/elec/ac_ess_grnd_bus_volts", "number")
A333DR_ac_land_rcvry_bus_volts = create_dataref("laminar/A333/elec/ac_land_rcvry_bus_volts", "number")

A333DR_dc_bat1_hot_bus_volts = create_dataref("laminar/A333/elec/dc_hot_bus1_volts", "number")
A333DR_dc_bat2_hot_bus_volts = create_dataref("laminar/A333/elec/dc_hot_bus2_volts", "number")
A333DR_dc_bat_bus_volts = create_dataref("laminar/A333/elec/dc_bat_bus_volts", "number")
A333DR_dc_apu_bat_bus_volts = create_dataref("laminar/A333/elec/dc_apu_bat_bus_volts", "number")
A333DR_dc_apu_bat_hot_bus_volts = create_dataref("laminar/A333/elec/dc_apu_bat_hot_bus_volts", "number")
A333DR_dc_bus1_volts = create_dataref("laminar/A333/elec/dc_bus1_volts", "number")
A333DR_dc_bus2_volts = create_dataref("laminar/A333/elec/dc_bus2_volts", "number")
A333DR_dc_ess_bus_volts = create_dataref("laminar/A333/elec/dc_ess_bus_volts", "number")
A333DR_dc_ess_shed_bus_volts = create_dataref("laminar/A333/elec/dc_ess_shed_bus_volts", "number")
A333DR_dc_land_rcvry_bus_volts = create_dataref("laminar/A333/elec/dc_land_rcvry_bus_volts", "number")
A333DR_dc_shed_land_rcvry_bus_volts = create_dataref("laminar/A333/elec/dc_shed_land_rcvry_bus_volts", "number")

A333DR_extA_ground_service_bus_amps = create_dataref("laminar/A333/elec/extA_ground_service_bus_amps", "number")
A333DR_ac_bus1_amps = create_dataref("laminar/A333/elec/ac_bus1_amps", "number")
A333DR_ac_bus2_amps = create_dataref("laminar/A333/elec/ac_bus2_amps", "number")
A333DR_ac_ess_bus_amps = create_dataref("laminar/A333/elec/ac_ess_bus_amps", "number")
A333DR_ac_ess_shed_bus_amps = create_dataref("laminar/A333/elec/ac_ess_shed_bus_amps", "number")
A333DR_ac_ess_grnd_bus_amps = create_dataref("laminar/A333/elec/ac_ess_grnd_bus_amps", "number")
A333DR_ac_land_rcvry_bus_amps = create_dataref("laminar/A333/elec/ac_land_rcvry_bus_amps", "number")

A333DR_dc_hot_bus1_amps = create_dataref("laminar/A333/elec/dc_hot_bus1_amps", "number")
A333DR_dc_hot_bus2_amps = create_dataref("laminar/A333/elec/dc_hot_bus2_amps", "number")
A333DR_dc_bat_bus_amps = create_dataref("laminar/A333/elec/dc_bat_bus_amps", "number")
A333DR_dc_apu_bat_bus_amps = create_dataref("laminar/A333/elec/dc_apu_bat_bus_amps", "number")
A333DR_dc_apu_bat_hot_bus_amps = create_dataref("laminar/A333/elec/dc_apu_bat_hot_bus_amps", "number")
A333DR_dc_bus1_amps = create_dataref("laminar/A333/elec/dc_bus1_amps", "number")
A333DR_dc_bus2_amps = create_dataref("laminar/A333/elec/dc_bus2_amps", "number")
A333DR_dc_ess_bus_amps = create_dataref("laminar/A333/elec/dc_ess_bus_amps", "number")
A333DR_dc_ess_shed_bus_amps = create_dataref("laminar/A333/elec/dc_ess_shed_bus_amps", "number")
A333DR_dc_land_rcvry_bus_amps = create_dataref("laminar/A333/elec/dc_land_rcvry_bus_amps", "number")
A333DR_dc_shed_land_rcvry_bus_amps = create_dataref("laminar/A333/elec/dc_shed_land_rcvry_bus_amps", "number")

A333DR_tr1_volts = create_dataref("laminar/A333/elec/tr1_volts", "number")
A333DR_tr2_volts = create_dataref("laminar/A333/elec/tr2_volts", "number")
A333DR_ess_tr_volts = create_dataref("laminar/A333/elec/ess_tr_volts", "number")
A333DR_apu_tr_volts = create_dataref("laminar/A333/elec/apu_tr_volts", "number")

A333DR_tr1_amps = create_dataref("laminar/A333/elec/tr1_amps", "number")
A333DR_tr2_amps = create_dataref("laminar/A333/elec/tr2_amps", "number")
A333DR_ess_tr_amps = create_dataref("laminar/A333/elec/ess_tr_amps", "number")
A333DR_apu_tr_amps = create_dataref("laminar/A333/elec/apu_tr_amps", "number")

A333DR_extA_ground_service_bus_has_power = create_dataref("laminar/A333/elec/extA_ground_service_bus_has_power", "number")
A333DR_ac_bus1_has_power = create_dataref("laminar/A333/elec/ac_bus1_has_power", "number")
A333DR_ac_bus2_has_power = create_dataref("laminar/A333/elec/ac_bus2_has_power", "number")
A333DR_ac_ess_bus_has_power = create_dataref("laminar/A333/elec/ac_ess_bus_has_power", "number")
A333DR_ac_ess_shed_bus_has_power = create_dataref("laminar/A333/elec/ac_ess_shed_bus_has_power", "number")
A333DR_ac_ess_grnd_bus_has_power = create_dataref("laminar/A333/elec/ac_ess_grnd_bus_has_power", "number")
A333DR_ac_land_rcvry_bus_has_power = create_dataref("laminar/A333/elec/ac_land_rcvry_bus_has_power", "number")

A333DR_dc_bat1_hot_bus_has_power = create_dataref("laminar/A333/elec/dc_hot_bus1_has_power", "number")
A333DR_dc_bat2_hot_bus_has_power = create_dataref("laminar/A333/elec/dc_hot_bus2_has_power", "number")
A333DR_dc_bat_bus_has_power = create_dataref("laminar/A333/elec/dc_bat_bus_has_power", "number")
A333DR_dc_apu_bat_bus_has_power = create_dataref("laminar/A333/elec/dc_apu_bat_bus_has_power", "number")
A333DR_dc_apu_bat_hot_bus_has_power = create_dataref("laminar/A333/elec/dc_apu_bat_hot_bus_has_power", "number")
A333DR_dc_bus1_has_power = create_dataref("laminar/A333/elec/dc_bus1_has_power", "number")
A333DR_dc_bus2_has_power = create_dataref("laminar/A333/elec/dc_bus2_has_power", "number")
A333DR_dc_ess_bus_has_power = create_dataref("laminar/A333/elec/dc_ess_bus_has_power", "number")
A333DR_dc_ess_shed_bus_has_power = create_dataref("laminar/A333/elec/dc_ess_shed_bus_has_power", "number")
A333DR_dc_land_rcvry_bus_has_power = create_dataref("laminar/A333/elec/dc_land_rcvry_bus_has_power", "number")
A333DR_dc_shed_land_rcvry_bus_has_power = create_dataref("laminar/A333/elec/dc_shed_land_rcvry_bus_has_power", "number")

A333DR_bat1_is_charging = create_dataref("laminar/A333/elec/bat1_is_charging", "number")
A333DR_bat2_is_charging = create_dataref("laminar/A333/elec/bat2_is_charging", "number")
A333DR_apu_bat_is_charging = create_dataref("laminar/A333/elec/apu_bat_is_charging", "number")

A333DR_elec_ac_ess_source = create_dataref("laminar/A333/elec/ac_ess_source", "number")
A333DR_elec_ac_ess_tr_source = create_dataref("laminar/A333/elec/ac_ess_tr_source", "number")

A330DR_elec_dc_tie_status = create_dataref("laminar/A333/elec/dc_tie_status", "number")

A330DR_elec_sim_bus_tied = create_dataref("laminar/A333/elec/sim_bus_tied", "array[6]")

A333DR_elec_emer_config_level1 = create_dataref("laminar/A333/elec/emer_config_level1", "number")
A333DR_elec_emer_config_level2 = create_dataref("laminar/A333/elec/emer_config_level2", "number")

A333DR_elec_ac_dc_transform_factor = create_dataref("laminar/A333/elec/ac_dc_transform_factor", "number")
A333DR_elec_dc_ac_inversion_factor = create_dataref("laminar/A333/elec/dc_ac_transform_factor", "number")



--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--


--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--
A333DR_init_elec_CD = create_dataref("laminar/A333/init_CD/elec", "number")



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
function animate(current_value, target, speed)

    local fps_factor = m.min(1.0, speed * SIM_PERIOD)
    local delta = m.abs(current_value - target)

    if delta < 0.000001 then
        return target
    else
        return current_value + ((target - current_value) * fps_factor)
    end

end




function rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end



--[[

The A330 has two levels of emergency electrical configurations. They are:

1.) A fault in the main electrical buses of the aircraft (AC BUS 1 and AC BUS 2).
In this case, even if the engines and their generators are running the aircraft
electrical system cannot be supplied. In this situation, the green hydraulic
system's EDP powers the emergency electrical generator. This is the first level.

2.) The aircraft falls into level two when there is a dual engine failure situation.
So, there are no working generators to supply the aircraft electrics. Here, the
RAT extends automatically. The RAT then runs the green hydraulic system which
in turn runs the emergency generator.

--]]
local function A333_elec_data_cache_globals()

    sim_period = SIM_PERIOD

    ac_dc_transform = simDR_acf_nom_bat_volt / simDR_acf_nom_gen_volt
    dc_ac_inversion = simDR_acf_nom_gen_volt / simDR_acf_nom_bat_volt

    dc_min_volts = 23
    ac_min_volts = (simDR_acf_nom_bat_volt > 0) and (simDR_acf_nom_gen_volt * (dc_min_volts/simDR_acf_nom_bat_volt)) or 0  -- = 102.98 @115v nom gen v
    on_ground = simDR_gear_on_ground == 1
    elec_emer_config = A333DR_elec_emer_config == 1
    elec_emer_config_level1 = elec_emer_config and (A333DR_elec_loss_of_bus_ac1 == 1) and (A333DR_elec_loss_of_bus_ac2 == 1)
    elec_emer_config_level2 = elec_emer_config and (A333DR_trent700_n3_eng1 < 50.0) and (A333DR_trent700_n3_eng2 < 50.0)

    battery_only_supply_on_ground = on_ground
        and bcl1.battery_button_contactor_state == 1
        and bcl2.battery_button_contactor_state == 1
        and simDR_ind_airspeed < 50
        and tr1_contactor.pos == OPEN
        and tr2_contactor.pos == OPEN
        and ess_tr_contactor.pos == OPEN

    battery_only_supply_in_flight = not on_ground
        and bcl1.battery_button_contactor_state == 1
        and bcl2.battery_button_contactor_state == 1
        and tr1_contactor.pos == OPEN
        and tr2_contactor.pos == OPEN
        and ess_tr_contactor.pos == OPEN

    batteries_only_supply = battery_only_supply_on_ground or battery_only_supply_in_flight

end




local function A333_elec_data_update_datarefs()

    A333DR_elec_ac_dc_transform_factor = ac_dc_transform
    A333DR_elec_dc_ac_inversion_factor = dc_ac_inversion
    A333DR_ac_min_volts = ac_min_volts
    A333DR_dc_min_volts = dc_min_volts
    A333DR_gear_on_ground = on_ground and 1 or 0
    A333DR_elec_emer_config_level1 = elec_emer_config_level1 and 1 or 0
    A333DR_elec_emer_config_level2 = elec_emer_config_level2 and 1 or 0
    A333DR_batteries_only_supply_on_ground = battery_only_supply_on_ground and 1 or 0
    A333DR_batteries_only_supply_in_flight = battery_only_supply_in_flight and 1 or 0
    A333DR_batteries_only_supply = batteries_only_supply and 1 or 0


end




--*************************************************************************************--
--** 				                     PROCESSING             	    			 **--
--*************************************************************************************--

--===| INIT ALL |========================================================================
function A333_elec_data_init_all()



end




--===| INIT ER |=========================================================================
function A333_elec_data_init_ER()



end




--===| INIT CD |=========================================================================
function A333_elec_data_init_CD()



end




--===| DEFERRED INITIALIZATION |=========================================================
function A333_elec_data_deferred_init()




end



--===| DEFERRED PROCESSING |=============================================================
function A333_elec_data_deferred_processing()



end




--=== AIRCRAFT LOAD =====================================================================
function A333_elec_data_aircraft_load()



end



--=== FLIGHT START ======================================================================
function A333_elec_data_flight_start()



end



--=== BEFORE PHYSICS ====================================================================
function A333_elec_data_before_physics()



end



--=== AFTER PHYSICS =====================================================================
function A333_elec_data_after_physics()

    A333_elec_data_cache_globals()
    A333_elec_data_update_datarefs()

end




--=== FLIGHT CRASH ======================================================================
function A333_elec_data_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_elec_data_aircraft_unload()



end




--=== AIRCRAFT UNLOAD ===================================================================
function A333_elec_data_after_replay()

    A333_elec_data_cache_globals()
    A333_elec_data_update_datarefs()

end



--*************************************************************************************--
--** 				                 SUB-SCRIPT LOADING            	     			 **--
--*************************************************************************************--



