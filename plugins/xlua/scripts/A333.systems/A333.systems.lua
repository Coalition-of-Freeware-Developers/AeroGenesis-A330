jit.off()
--[[
*****************************************************************************************
* Program Script Name	:	A333.systems
* Author Name			:	Alex Unruh
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2021-03-18	0.01a				Start of Dev
*
*
*
*
*****************************************************************************************
*        COPYRIGHT © 2023 Alex Unruh / LAMINAR RESEARCH - ALL RIGHTS RESERVED	        *
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


local pack1_flow_target = 0
local pack2_flow_target = 0
local pack1_flow_ratio = 0
local pack2_flow_ratio = 0
local pack_flow_mode = 0
local pack1_exhaust_target = 0
local pack2_exhaust_target = 0

local tank_transfer_left = 0
local tank_transfer_right = 0

local elt_trigger = 0
local elt_annun = 0
local IR1_mode = 0
local IR2_mode = 0

local takeoff_mode = 0
local flex_mode_is_available = true
local flex_mode = 0
local max_throttle_mode = 0

local int, frac = math.modf(os.clock())
local seed = math.random(1, frac * 1000.0)
math.randomseed(seed)

local cockpit_random_fac = math.random(-1, 1)
local cabin_fwd_random_fac = math.random(-1, 3)
local cabin_mid_random_fac = math.random(-2, 4)
local cabin_aft_random_fac = math.random(-1, 3)
local cargo_random_fac = math.random(-5, 2)
local cargo_bulk_random_fac = math.random(-5, 2)

local cabin_fwd_random_fac2 = math.random(-1, 1)
local cabin_mid_random_fac2 = math.random(-1, 2)
local cabin_aft_random_fac2 = math.random(-1, 1)

local cabin_fwd_mid_random_fac2 = math.random(-1, 1)
local cabin_mid_fwd_random_fac2 = math.random(-1, 1)
local cabin_aft_mid_random_fac2 = math.random(-1, 1)

local wheel_brake_1_random_max_fac = math.random(-60, 60)
local wheel_brake_2_random_max_fac = math.random(-60, 60)
local wheel_brake_3_random_max_fac = math.random(-60, 60)
local wheel_brake_4_random_max_fac = math.random(-60, 60)
local wheel_brake_5_random_max_fac = math.random(-60, 60)
local wheel_brake_6_random_max_fac = math.random(-60, 60)
local wheel_brake_7_random_max_fac = math.random(-60, 60)
local wheel_brake_8_random_max_fac = math.random(-60, 60)

local wheel_brake_1_random_min_fac = math.random(0, 10)
local wheel_brake_2_random_min_fac = math.random(0, 10)
local wheel_brake_3_random_min_fac = math.random(0, 10)
local wheel_brake_4_random_min_fac = math.random(0, 10)
local wheel_brake_5_random_min_fac = math.random(0, 10)
local wheel_brake_6_random_min_fac = math.random(0, 10)
local wheel_brake_7_random_min_fac = math.random(0, 10)
local wheel_brake_8_random_min_fac = math.random(0, 10)

local star_mode = 0
local single_engine_status = 0

local Vmo = 330
local Mmo = 0.86
local Vfe_1 = 240
local Vfe_1f = 215
local Vfe_1_star = 205
local Vfe_2 = 196
local Vfe_2_star = 186
local Vfe_3 = 186
local Vfe_full = 180
local Vle = 250

local off_ground_timer = 0
local ground_timer = 0
local windshear_timer = 0
local ws_ahead_timer = 0

local takeoff_landing_index = 0 -- 0 = takeoff, 1 = landing

local altCaptured = 0
local gsCaptured = 0
local locCaptured = 0

local bool2num = {[true] = 1, [false] = 0}


--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_flight_time = find_dataref("sim/time/total_flight_time_sec")

simDR_startup_running = find_dataref("sim/operation/prefs/startup_running")

simDR_duct_isol_valve_left = find_dataref("sim/cockpit2/bleedair/actuators/isol_valve_left")
simDR_duct_isol_valve_right = find_dataref("sim/cockpit2/bleedair/actuators/isol_valve_right")

simDR_left_pack = find_dataref("sim/cockpit2/bleedair/actuators/pack_left")
simDR_right_pack = find_dataref("sim/cockpit2/bleedair/actuators/pack_right")
simDR_center_pack = find_dataref("sim/cockpit2/bleedair/actuators/pack_center")
simDR_apu_bleed = find_dataref("sim/cockpit2/bleedair/actuators/apu_bleed")
simDR_bleed_air1 = find_dataref("sim/cockpit2/bleedair/actuators/engine_bleed_sov[0]")
simDR_bleed_air2 = find_dataref("sim/cockpit2/bleedair/actuators/engine_bleed_sov[1]")
simDR_left_duct_avail = find_dataref("sim/cockpit2/bleedair/indicators/bleed_available_left")
simDR_right_duct_avail = find_dataref("sim/cockpit2/bleedair/indicators/bleed_available_right")

simDR_bleed_air1_fail = find_dataref("sim/operation/failures/rel_bleed_air_lft")
simDR_bleed_air2_fail = find_dataref("sim/operation/failures/rel_bleed_air_rgt")

simDR_engine1_starter_running = find_dataref("sim/flightmodel2/engines/starter_is_running[0]")
simDR_engine2_starter_running = find_dataref("sim/flightmodel2/engines/starter_is_running[1]")

simDR_engine1_igniter = find_dataref("sim/cockpit2/engine/actuators/igniter_on[0]")
simDR_engine2_igniter = find_dataref("sim/cockpit2/engine/actuators/igniter_on[1]")

simDR_equiv_airspeed = find_dataref("sim/flightmodel/position/equivalent_airspeed")

simDR_flap_deploy_ratio = find_dataref("sim/cockpit2/controls/flap_system_deploy_ratio")


-- ANTI ICE

simDR_wing_heat_left = find_dataref("sim/cockpit2/ice/ice_surface_hot_bleed_air_left_on")
simDR_wing_heat_right = find_dataref("sim/cockpit2/ice/ice_surface_hot_bleed_air_right_on")

simDR_wing_heat_fault_left = find_dataref("sim/operation/failures/rel_ice_surf_heat")
simDR_wing_heat_fault_right = find_dataref("sim/operation/failures/rel_ice_surf_heat2")

-- HYDRAULICS

simDR_green_hydraulic_pressure = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1")
simDR_yellow_hydraulic_pressure = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_2")
simDR_blue_hydraulic_pressure = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_3")

simDR_green_eng1_pump_on = find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpA[0]")
simDR_blue_eng1_pump_on = find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpC[0]")
simDR_yellow_eng2_pump_on = find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpB[1]")
simDR_green_eng2_pump_on = find_dataref("sim/cockpit2/hydraulics/actuators/engine_pumpA[1]")

simDR_green_elec_pump_on = find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump_on")
simDR_blue_elec_pump_on = find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump2_on")
simDR_yellow_elec_pump_on = find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump3_on")

simDR_green_fluid_ratio = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_fluid_ratio_1")
simDR_blue_fluid_ratio = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_fluid_ratio_3")
simDR_yellow_fluid_ratio = find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_fluid_ratio_2")

simDR_rat_on = find_dataref("sim/cockpit2/hydraulics/actuators/ram_air_turbine_on")
simDR_airspeed = find_dataref("sim/flightmodel/position/indicated_airspeed")

-- FLAPS

simDR_slat_failure = find_dataref("sim/operation/failures/rel_fc_slt")
simDR_flap_act_failure = find_dataref("sim/operation/failures/rel_flap_act")
simDR_flap1_L_failure = find_dataref("sim/operation/failures/rel_fc_L_flp")
simDR_flap1_R_failure = find_dataref("sim/operation/failures/rel_fc_R_flp")
simDR_flap2_L_failure = find_dataref("sim/operation/failures/rel_fc_L_flp2")
simDR_flap2_R_failure = find_dataref("sim/operation/failures/rel_fc_R_flp2")

simDR_flap_retract_time = find_dataref("sim/aircraft2/engine/flap_retraction_time_sec")
simDR_flap_extend_time = find_dataref("sim/aircraft2/engine/flap_extension_time_sec")

simDR_flaps_disagree = find_dataref("sim/cockpit2/controls/flap_disagree") -- 0 = agree, 1 = disagree, 2 = load relief
simDR_slats_disagree = find_dataref("sim/cockpit2/controls/slat_disagree") -- 0 = agree, 1 = disagree, 2 = alpha lock

-- GEAR

simDR_auto_brake_level = find_dataref("sim/cockpit2/switches/auto_brake_level")
simDR_nosewheel_steering = find_dataref("sim/cockpit2/controls/nosewheel_steer_on")

simDR_nose_gear_deploy = find_dataref("sim/flightmodel2/gear/deploy_ratio[0]")
simDR_Lmain_gear_deploy = find_dataref("sim/flightmodel2/gear/deploy_ratio[1]")
simDR_Rmain_gear_deploy = find_dataref("sim/flightmodel2/gear/deploy_ratio[2]")
simDR_gear_handle = find_dataref("sim/cockpit2/controls/gear_handle_request") -- 0 is up, 1 is down

-- FUEL

simDR_xfer_pump_activation_level = find_dataref("sim/cockpit2/fuel/transfer_pump_activation")
simDR_xfer_pump_deactivation_level = find_dataref("sim/cockpit2/fuel/transfer_pump_deactivation")

simDR_fuel_tank_left = find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[0]")
simDR_fuel_tank_right = find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[2]")
simDR_fuel_tank_center = find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[1]")

simDR_fuel_transfer_left_aux = find_dataref("sim/cockpit2/fuel/transfer_pump_left")            -- 0: Off, 1: Auto, 2: On/Override
simDR_fuel_transfer_right_aux = find_dataref("sim/cockpit2/fuel/transfer_pump_right")            -- 0: Off, 1: Auto, 2: On/Override

simDR_fuel_transfer_to_mode = find_dataref("sim/cockpit2/fuel/fuel_tank_transfer_to")        -- 0=none,1=left,2=center,3=right,5=aft
simDR_fuel_transfer_from_mode = find_dataref("sim/cockpit2/fuel/fuel_tank_transfer_from")        -- 0=none,1=left,2=center,3=right,5=aft

simDR_fuel_tank_sel_left = find_dataref("sim/cockpit2/fuel/fuel_tank_selector_left")        -- 0=none,1=left,2=center,3=right,4=all,5=aft
simDR_fuel_tank_sel_right = find_dataref("sim/cockpit2/fuel/fuel_tank_selector_right")    -- 0=none,1=left,2=center,3=right,4=all,5=aft

simDR_tank_level_left = find_dataref("sim/cockpit2/fuel/fuel_quantity[0]")
simDR_tank_level_center = find_dataref("sim/cockpit2/fuel/fuel_quantity[1]")
simDR_tank_level_right = find_dataref("sim/cockpit2/fuel/fuel_quantity[2]")
simDR_tank_level_aux_left = find_dataref("sim/cockpit2/fuel/fuel_quantity[3]")
simDR_tank_level_aux_right = find_dataref("sim/cockpit2/fuel/fuel_quantity[4]")
simDR_tank_level_trim = find_dataref("sim/cockpit2/fuel/fuel_quantity[5]")

simDR_tank_pressure_center = find_dataref("sim/cockpit2/fuel/tank_pump_pressure_psi[1]")
simDR_tank_pressure_left_aux = find_dataref("sim/cockpit2/fuel/tank_pump_pressure_psi[3]")
simDR_tank_pressure_right_aux = find_dataref("sim/cockpit2/fuel/tank_pump_pressure_psi[4]")
simDR_tank_pressure_trim = find_dataref("sim/cockpit2/fuel/tank_pump_pressure_psi[5]")

simDR_fuel_burned_eng1 = find_dataref("sim/cockpit2/fuel/fuel_totalizer_sum_engine_kg[0]")
simDR_fuel_burned_eng2 = find_dataref("sim/cockpit2/fuel/fuel_totalizer_sum_engine_kg[1]")
simDR_fuel_burned_total = find_dataref("sim/cockpit2/fuel/fuel_totalizer_sum_kg")

-- ELT

simDR_axial_g_load = find_dataref("sim/flightmodel/forces/g_axil")

-- ADIRS

simDR_ahars1_fail_state = find_dataref("sim/operation/failures/rel_g_arthorz")
simDR_ahars2_fail_state = find_dataref("sim/operation/failures/rel_g_arthorz_2")
simDR_adc1_fail_state = find_dataref("sim/operation/failures/rel_adc_comp")
simDR_adc2_fail_state = find_dataref("sim/operation/failures/rel_adc_comp_2")

-- DOOR TIMINGS

simDR_door1L = find_dataref("sim/flightmodel2/misc/door_cycle_time[0]")
simDR_door2L = find_dataref("sim/flightmodel2/misc/door_cycle_time[2]")
simDR_door3L = find_dataref("sim/flightmodel2/misc/door_cycle_time[4]")
simDR_door4L = find_dataref("sim/flightmodel2/misc/door_cycle_time[6]")
simDR_door1R = find_dataref("sim/flightmodel2/misc/door_cycle_time[1]")
simDR_door2R = find_dataref("sim/flightmodel2/misc/door_cycle_time[3]")
simDR_door3R = find_dataref("sim/flightmodel2/misc/door_cycle_time[5]")
simDR_door4R = find_dataref("sim/flightmodel2/misc/door_cycle_time[7]")
simDR_doorC1 = find_dataref("sim/flightmodel2/misc/door_cycle_time[8]")
simDR_doorC2 = find_dataref("sim/flightmodel2/misc/door_cycle_time[9]")
simDR_doorC3 = find_dataref("sim/flightmodel2/misc/door_cycle_time[10]")
simDR_door_cockpit = find_dataref("sim/flightmodel2/misc/door_cycle_time[11]")

-- FADEC ENGINE LIMIT

simDR_fadec_engine_limits_toga = find_dataref("sim/flightmodel/engine/ENGN_fadec_targets[0]")
simDR_fadec_engine_limits_mct_flx = find_dataref("sim/flightmodel/engine/ENGN_fadec_targets[1]")
simDR_fadec_engine_limits_clb = find_dataref("sim/flightmodel/engine/ENGN_fadec_targets[2]")

simDR_gear_on_ground = find_dataref("sim/flightmodel2/gear/on_ground[1]")

simDR_fadec_power_mode_eng1 = find_dataref("sim/flightmodel/engine/ENGN_fadec_pow_req[0]")  -- (0=out of FADEC range, 1 = climb or cruise, 2 = climb or MCT or reduced takeoff, 3 = TOGA)
simDR_fadec_power_mode_eng2 = find_dataref("sim/flightmodel/engine/ENGN_fadec_pow_req[1]")

simDR_starter_torque = find_dataref("sim/aircraft/engine/acf_starter_torque_ratio")
simDR_external_temp = find_dataref("sim/weather/aircraft/temperature_ambient_deg_c")
simDR_sealevel_baro = find_dataref("sim/weather/barometer_sealevel_inhg")
simDR_sealevel_qnh_pas = find_dataref("sim/weather/aircraft/qnh_pas")
simDR_TAT = find_dataref("sim/weather/aircraft/temperature_leadingedge_deg_c")

simDR_fuel_flow_eng1 = find_dataref("sim/cockpit2/engine/indicators/fuel_flow_kg_sec[0]")
simDR_fuel_flow_eng2 = find_dataref("sim/cockpit2/engine/indicators/fuel_flow_kg_sec[1]")

simDR_low_idle = find_dataref("sim/aircraft2/engine/low_idle_ratio")
simDR_high_idle = find_dataref("sim/aircraft2/engine/high_idle_ratio")

simDR_prop_mode0 = find_dataref("sim/cockpit2/engine/actuators/prop_mode[0]")
simDR_prop_mode1 = find_dataref("sim/cockpit2/engine/actuators/prop_mode[1]")

-- ECAM

simDR_starter_mode = find_dataref("sim/cockpit2/engine/actuators/eng_mode_selector")
simDR_eng1_N1 = find_dataref("sim/flightmodel2/engines/N1_percent[0]")
simDR_eng2_N1 = find_dataref("sim/flightmodel2/engines/N1_percent[1]")
simDR_eng1_N2 = find_dataref("sim/flightmodel2/engines/N2_percent[0]")
simDR_eng2_N2 = find_dataref("sim/flightmodel2/engines/N2_percent[1]")

simDR_throttle1_pos = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[0]")
simDR_throttle2_pos = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[1]")

simDR_throttle1_used = find_dataref("sim/flightmodel2/engines/throttle_used_ratio[0]")
simDR_throttle2_used = find_dataref("sim/flightmodel2/engines/throttle_used_ratio[1]")

simDR_engine1_starting = find_dataref("sim/flightmodel2/engines/starter_is_running[0]")
simDR_engine2_starting = find_dataref("sim/flightmodel2/engines/starter_is_running[1]")
simDR_engine1_reverse = find_dataref("sim/flightmodel2/engines/thrust_reverser_deploy_ratio[0]")
simDR_engine2_reverse = find_dataref("sim/flightmodel2/engines/thrust_reverser_deploy_ratio[1]")

simDR_flap_deg = find_dataref("sim/flightmodel2/wing/flap1_deg[0]")
simDR_slat_ratio = find_dataref("sim/flightmodel2/controls/slat2_deploy_ratio")
simDR_flap_handle_request = find_dataref("sim/cockpit2/controls/flap_handle_request_ratio")
simDR_flap_handle_ratio = find_dataref("sim/cockpit2/controls/flap_handle_deploy_ratio")
simDR_flap_config = find_dataref("sim/cockpit2/controls/flap_config")

simDR_APU_starter_switch = find_dataref("sim/cockpit2/electrical/APU_starter_switch")
simDR_APU_N1 = find_dataref("sim/cockpit2/electrical/APU_N1_percent")
simDR_APU_loss_ratio = find_dataref("sim/cockpit2/bleedair/indicators/APU_loss_from_bleed_air_ratio")
simDR_APU_EGT = find_dataref("sim/cockpit2/electrical/APU_EGT_c")

simDR_bus1_power = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
simDR_bus2_power = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
simDR_ess_bus_power = find_dataref("sim/cockpit2/electrical/bus_volts[3]")

simDR_engine1_hyd_pump_fault = find_dataref("sim/operation/failures/rel_hydpmp")
simDR_engine2_hyd_pump_fault = find_dataref("sim/operation/failures/rel_hydpmp2")

simDR_map_range = find_dataref("sim/cockpit2/EFIS/map_range_steps")

simDR_apu_fail = find_dataref("sim/operation/failures/rel_apu")
simDR_apu_fire = find_dataref("sim/operation/failures/rel_apu_fire")

simDR_gen_on = find_dataref("sim/cockpit2/electrical/generator_on")
simDR_gen1_fail = find_dataref("sim/operation/failures/rel_genera0")
simDR_gen2_fail = find_dataref("sim/operation/failures/rel_genera1")
simDR_EGT = find_dataref("sim/cockpit2/engine/indicators/EGT_deg_cel")
simDR_bus1_fail = find_dataref("sim/operation/failures/rel_esys")
simDR_bus2_fail = find_dataref("sim/operation/failures/rel_esys2")

simDR_ess_bus_fail = find_dataref("sim/operation/failures/rel_esys4")

simDR_bus_amps = find_dataref("sim/cockpit2/electrical/bus_load_amps")
simDR_battery_status = find_dataref("sim/cockpit2/electrical/battery_on")
simDR_bat1_fail = find_dataref("sim/operation/failures/rel_batter0")
simDR_bat2_fail = find_dataref("sim/operation/failures/rel_batter1")
simDR_bat3_fail = find_dataref("sim/operation/failures/rel_batter2")

simDR_bat_amps = find_dataref("sim/cockpit2/electrical/battery_amps")

simDR_apu_starter_amps = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps[2]")
simDR_apu_door = find_dataref("sim/cockpit2/electrical/APU_door")
simDR_apu_running = find_dataref("sim/cockpit2/electrical/APU_running")

-- FLIGHT CONTROLS

simDR_outer_aileron_L = find_dataref("sim/flightmodel2/wing/aileron2_deg[6]")
simDR_inner_aileron_L = find_dataref("sim/flightmodel2/wing/aileron1_deg[4]")
simDR_inner_aileron_R = find_dataref("sim/flightmodel2/wing/aileron1_deg[5]")
simDR_outer_aileron_R = find_dataref("sim/flightmodel2/wing/aileron2_deg[7]")
simDR_elevator_L = find_dataref("sim/flightmodel2/wing/elevator1_deg[8]")
simDR_elevator_R = find_dataref("sim/flightmodel2/wing/elevator1_deg[9]")

simDR_spoiler1_L = find_dataref("sim/flightmodel2/wing/speedbrake1_deg[0]")
simDR_spoiler2_L = find_dataref("sim/flightmodel2/wing/spoiler1_deg[2]")
simDR_spoiler3_L = find_dataref("sim/flightmodel2/wing/spoiler2_deg[2]")
simDR_spoiler4_5_L = find_dataref("sim/flightmodel2/wing/spoiler1_deg[4]")
simDR_spoiler6_L = find_dataref("sim/flightmodel2/wing/spoiler2_deg[4]")

simDR_spoiler1_R = find_dataref("sim/flightmodel2/wing/speedbrake1_deg[1]")
simDR_spoiler2_R = find_dataref("sim/flightmodel2/wing/spoiler1_deg[3]")
simDR_spoiler3_R = find_dataref("sim/flightmodel2/wing/spoiler2_deg[3]")
simDR_spoiler4_5_R = find_dataref("sim/flightmodel2/wing/spoiler1_deg[5]")
simDR_spoiler6_R = find_dataref("sim/flightmodel2/wing/spoiler2_deg[5]")

simDR_rudder_trim_ratio = find_dataref("sim/flightmodel2/controls/rudder_trim")

simDR_speedbrake_ratio = find_dataref("sim/flightmodel2/controls/speedbrake_ratio")

-- DOORS / OXY

simDR_door_ratio = find_dataref("sim/flightmodel2/misc/door_open_ratio")
simDR_oxygen_on = find_dataref("sim/cockpit2/oxygen/actuators/o2_valve_on")
simDR_number_plugged_in_o2 = find_dataref("sim/cockpit2/oxygen/actuators/num_plugged_in_o2")
simDR_ox_psi = find_dataref("sim/cockpit2/oxygen/indicators/o2_bottle_pressure_psi")

-- WHEEL STUFF

simDR_left_brake_fail = find_dataref("sim/operation/failures/rel_lbrakes")
simDR_right_brake_fail = find_dataref("sim/operation/failures/rel_rbrakes")
simDR_left_brake_ratio = find_dataref("sim/flightmodel2/gear/tire_part_brake[1]")
simDR_right_brake_ratio = find_dataref("sim/flightmodel2/gear/tire_part_brake[2]")
simDR_left_skid_ratio = find_dataref("sim/flightmodel2/gear/tire_skid_ratio[1]")
simDR_right_skid_ratio = find_dataref("sim/flightmodel2/gear/tire_skid_ratio[2]")

-- BRAKES

simDR_brake_temp_left = find_dataref("sim/flightmodel2/gear/brake_absorbed_rat[1]")
simDR_brake_temp_right = find_dataref("sim/flightmodel2/gear/brake_absorbed_rat[2]")

-- CAB PRESS

simDR_outflow_valve = find_dataref("sim/flightmodel2/misc/pressure_outflow_ratio")

simDR_engine1_loss = find_dataref("sim/cockpit2/bleedair/indicators/engine_loss_from_bleed_air_ratio[0]")
simDR_engine2_loss = find_dataref("sim/cockpit2/bleedair/indicators/engine_loss_from_bleed_air_ratio[1]")
simDR_apu_loss = find_dataref("sim/cockpit2/bleedair/indicators/APU_loss_from_bleed_air_ratio")

-- PFD STUFF

simDR_radio_altimeter_capt = find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
simDR_radio_altimeter_FO = find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_copilot")

simDR_AHARS_pitch_capt = find_dataref("sim/cockpit2/gauges/indicators/pitch_AHARS_deg_pilot")
simDR_AHARS_pitch_FO = find_dataref("sim/cockpit2/gauges/indicators/pitch_AHARS_deg_copilot")

simDR_vvi_capt = find_dataref("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")
simDR_vvi_FO = find_dataref("sim/cockpit2/gauges/indicators/vvi_fpm_copilot")

simDR_autopilot_vnav_alt_sel = find_dataref("sim/cockpit2/autopilot/altitude_vnav_ft")
simDR_capt_altitude = find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
simDR_fo_altitude = find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_copilot")

simDR_altv_armed = find_dataref("sim/cockpit2/autopilot/altv_armed")
simDR_altv_captured = find_dataref("sim/cockpit2/autopilot/altv_captured")

simDR_capt_AHARS_heading = find_dataref("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")
simDR_fo_AHARS_heading = find_dataref("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_copilot")
simDR_capt_track_heading = find_dataref("sim/cockpit2/gauges/indicators/ground_track_mag_pilot")
simDR_fo_track_heading = find_dataref("sim/cockpit2/gauges/indicators/ground_track_mag_copilot")
simDR_capt_track_tru_heading = find_dataref("sim/cockpit2/gauges/indicators/ground_track_true_pilot")
simDR_fo_track_tru_heading = find_dataref("sim/cockpit2/gauges/indicators/ground_track_true_copilot")

simDR_autopilot_hdg_sel = find_dataref("sim/cockpit2/autopilot/heading_dial_deg_mag_pilot")
simDR_autopilot_hdg_sel_fo = find_dataref("sim/cockpit2/autopilot/heading_dial_deg_mag_copilot")

simDR_capt_ils_heading = find_dataref("sim/cockpit2/radios/indicators/fac")
simDR_fo_ils_heading = find_dataref("sim/cockpit2/radios/indicators/fac_copilot")

simDR_capt_airspeed = find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
simDR_fo_airspeed = find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_copilot")

simDR_autopilot_ias_sel = find_dataref("sim/cockpit2/autopilot/airspeed_dial_kts")
simDR_total_weight = find_dataref("sim/flightmodel/weight/m_total")

simDR_generator1_amps = find_dataref("sim/cockpit2/electrical/generator_amps[0]")
simDR_generator2_amps = find_dataref("sim/cockpit2/electrical/generator_amps[1]")
simDR_apu_gen_on = find_dataref("sim/cockpit2/electrical/APU_generator_on")
simDR_apu_gen_amps = find_dataref("sim/cockpit2/electrical/APU_generator_amps")
simDR_gpu_amps = find_dataref("sim/cockpit/electrical/gpu_amps")
simDR_gpu_on = find_dataref("sim/cockpit/electrical/gpu_on")
simDR_ess_ties = find_dataref("sim/aircraft/electrical/essential_ties")
simDR_cross_tie = find_dataref("sim/cockpit2/electrical/cross_tie")

simDR_altitude_hold_status = find_dataref("sim/cockpit2/autopilot/altitude_hold_status")

simDR_vdef_dots_capt			= find_dataref("sim/cockpit2/radios/indicators/nav1_vdef_dots_pilot")
simDR_vdef_dots_fo				= find_dataref("sim/cockpit2/radios/indicators/nav2_vdef_dots_copilot")
simDR_hdef_dots_capt			= find_dataref("sim/cockpit2/radios/indicators/nav1_hdef_dots_pilot")
simDR_hdef_dots_fo				= find_dataref("sim/cockpit2/radios/indicators/nav2_hdef_dots_copilot")

simDR_autopilot_status_capt		= find_dataref("sim/cockpit2/autopilot/flight_director_mode")
simDR_autopilot_status_fo		= find_dataref("sim/cockpit2/autopilot/flight_director2_mode")

simDR_gpss_status				= find_dataref("sim/cockpit2/autopilot/gpss_status")	-- 0=off, 2=active
simDR_vnav_status				= find_dataref("sim/cockpit2/autopilot/vnav_status")	-- 0=off, 1=armed, 2=captured
simDR_gps1_cdi_sense			= find_dataref("sim/cockpit/radios/gps_cdi_sensitivity")
simDR_gps2_cdi_sense			= find_dataref("sim/cockpit/radios/gps2_cdi_sensitivity")

simDR_airspeed_bugs				= find_dataref("sim/cockpit2/gauges/actuators/airspeed_bugs")

simDR_alpha						= find_dataref("sim/flightmodel2/position/alpha")

simDR_fd_pitch_capt				= find_dataref("sim/cockpit2/autopilot/flight_director_pitch_deg")
simDR_fd_pitch_fo				= find_dataref("sim/cockpit2/autopilot/flight_director2_pitch_deg")

simDR_radio_alt_bug_capt		= find_dataref("sim/cockpit2/gauges/actuators/radio_altimeter_bug_ft_pilot")
simDR_radio_alt_bug_fo			= find_dataref("sim/cockpit2/gauges/actuators/radio_altimeter_bug_ft_copilot")

simDR_mda_capt					= find_dataref("sim/cockpit2/gauges/actuators/baro_altimeter_bug_ft_pilot")
simDR_mda_fo					= find_dataref("sim/cockpit2/gauges/actuators/baro_altimeter_bug_ft_copilot")

simDR_dh_lit_capt				= find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_dh_lit_pilot")
simDR_dh_lit_fo					= find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_dh_lit_copilot")

simDR_nav_horz_sig 				= find_dataref("sim/cockpit2/radios/indicators/nav_display_horizontal")
simDR_runway_status				= find_dataref("sim/cockpit2/autopilot/runway_status")
simDR_rollout_status			= find_dataref("sim/cockpit2/autopilot/rollout_status")
simDR_flare_status				= find_dataref("sim/cockpit2/autopilot/flare_status")

simDR_windshear_mode			= find_dataref("sim/cockpit2/annunciators/windshear_warning_systems") -- 0 = no warning, 1 = predictive advisory, 2 = predictive caution, 3 = predictive warning t/o, 4 = predictive warning approach, 5 = reactive warning

-- ND

simDR_nav1_ID = find_dataref("sim/cockpit2/radios/indicators/nav3_nav_id")
simDR_nav2_ID = find_dataref("sim/cockpit2/radios/indicators/nav4_nav_id")
simDR_dme1_ID = find_dataref("sim/cockpit2/radios/indicators/nav3_dme_id")
simDR_dme2_ID = find_dataref("sim/cockpit2/radios/indicators/nav4_dme_id")
simDR_adf1_ID = find_dataref("sim/cockpit2/radios/indicators/adf1_nav_id")
simDR_adf2_ID = find_dataref("sim/cockpit2/radios/indicators/adf2_nav_id")

simDR_nav1_type = find_dataref("sim/cockpit2/radios/indicators/nav_type[2]")
simDR_nav2_type = find_dataref("sim/cockpit2/radios/indicators/nav_type[3]")

simDR_gps1_dme_time = find_dataref("sim/cockpit2/radios/indicators/gps_dme_time_min")
simDR_gps2_dme_time = find_dataref("sim/cockpit2/radios/indicators/gps2_dme_time_min")

simDR_HSI_pilot = find_dataref("sim/cockpit2/radios/actuators/HSI_source_select_pilot")
simDR_HSI_copilot = find_dataref("sim/cockpit2/radios/actuators/HSI_source_select_copilot")

----- GPS RADIO STATUS

simDR_gps1_bearing			= find_dataref("sim/cockpit2/radios/indicators/gps_bearing_deg_mag")
simDR_gps1_dme_distance		= find_dataref("sim/cockpit2/radios/indicators/gps_dme_distance_nm")
simDR_gps1_dme_speed		= find_dataref("sim/cockpit2/radios/indicators/gps_dme_speed_kts")

simDR_gps2_bearing			= find_dataref("sim/cockpit2/radios/indicators/gps2_bearing_deg_mag")
simDR_gps2_dme_distance		= find_dataref("sim/cockpit2/radios/indicators/gps2_dme_distance_nm")
simDR_gps2_dme_speed		= find_dataref("sim/cockpit2/radios/indicators/gps2_dme_speed_kts")

-- AUTOPILOT FMAS

simDR_capt_fd_on = find_dataref("sim/cockpit2/autopilot/flight_director_command_bars_pilot")
simDR_fo_fd_on = find_dataref("sim/cockpit2/autopilot/flight_director_command_bars_copilot")
simDR_autopilot_1_on = find_dataref("sim/cockpit2/autopilot/servos_on")
simDR_autopilot_2_on = find_dataref("sim/cockpit2/autopilot/servos2_on")
simDR_altitude_sel = find_dataref("sim/cockpit2/autopilot/altitude_dial_ft")
simDR_altitude_hold = find_dataref("sim/cockpit2/autopilot/altitude_hold_ft")
simDR_altitude_mode = find_dataref("sim/cockpit2/autopilot/altitude_mode")
simDR_heading_mode	= find_dataref("sim/cockpit2/autopilot/heading_mode")

simDR_throttle_loc_eng1 = find_dataref("sim/flightmodel/engine/ENGN_fadec_pow_req[0]")
simDR_throttle_loc_eng2 = find_dataref("sim/flightmodel/engine/ENGN_fadec_pow_req[1]")
simDR_throttle_rat_eng1 = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[0]")
simDR_throttle_rat_eng2 = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[1]")

simDR_ias_mach_ind = find_dataref("sim/cockpit2/autopilot/airspeed_is_mach") -- 1 = mach, 0 = ias
simDR_autothrottle_mode = find_dataref("sim/cockpit2/autopilot/autothrottle_enabled")
simDR_autopilot_speed_set = find_dataref("sim/cockpit2/autopilot/airspeed_dial_kts_mach")
simDR_mach_captain_ind = find_dataref("sim/cockpit2/gauges/indicators/mach_pilot")
simDR_approach_status = find_dataref("sim/cockpit2/autopilot/approach_status")
simDR_glideslope_status = find_dataref("sim/cockpit2/autopilot/glideslope_status")
simDR_AP1_status = find_dataref("sim/cockpit2/autopilot/flight_director_mode")
simDR_AP2_status = find_dataref("sim/cockpit2/autopilot/flight_director2_mode")

simDR_flex_temp	= find_dataref("sim/flightmodel/engine/ENGN_assumed_temp")
simDR_OAT = find_dataref("sim/cockpit2/temperature/outside_air_temp_degc")
simDR_vnav_speed_window_open = find_dataref("sim/cockpit2/autopilot/vnav_speed_window_open") -- 1 = open, 0 = closed
simDR_vnav_speed_status = find_dataref("sim/cockpit2/autopilot/vnav_speed_status")
simDR_ian_mode = find_dataref("sim/cockpit2/radios/indicators/ian_mode")	-- 0 = none (MMR gets ILS or GLS), 1 = GP only, for LOC, 2 = FAC/GP for all RNAV, RNP and overlay approaches

-- ELEV FAIL

simDR_fail_elev_U = find_dataref("sim/operation/failures/rel_elv_U")
simDR_fail_elev_D = find_dataref("sim/operation/failures/rel_elv_D")

simDR_fail_fcon_elev_lft_lock = find_dataref("sim/operation/failures/rel_fcon_elev_1_lft_lock")
simDR_fail_fcon_elev_lft_mxdn = find_dataref("sim/operation/failures/rel_fcon_elev_1_lft_mxdn")
simDR_fail_fcon_elev_lft_mxup = find_dataref("sim/operation/failures/rel_fcon_elev_1_lft_mxup")
simDR_fail_fcon_elev_lft_cntr = find_dataref("sim/operation/failures/rel_fcon_elev_1_lft_cntr")
simDR_fail_fcon_elev_lft_gone = find_dataref("sim/operation/failures/rel_fcon_elev_1_lft_gone")

simDR_fail_fcon_elev_rgt_lock = find_dataref("sim/operation/failures/rel_fcon_elev_1_rgt_lock")
simDR_fail_fcon_elev_rgt_mxdn = find_dataref("sim/operation/failures/rel_fcon_elev_1_rgt_mxdn")
simDR_fail_fcon_elev_rgt_mxup = find_dataref("sim/operation/failures/rel_fcon_elev_1_rgt_mxup")
simDR_fail_fcon_elev_rgt_cntr = find_dataref("sim/operation/failures/rel_fcon_elev_1_rgt_cntr")
simDR_fail_fcon_elev_rgt_gone = find_dataref("sim/operation/failures/rel_fcon_elev_1_rgt_gone")

-- VSPEED INDICATORS

simDR_mmo_in_kias = find_dataref("sim/cockpit2/gauges/indicators/max_mach_number_in_kias")
simDR_G_force = find_dataref("sim/flightmodel/forces/g_nrml")
simDR_AOA = find_dataref("sim/cockpit2/gauges/indicators/AoA_pilot")

-- YOKE POSITIONS FOR SIDE STICK PRIORITY

simDR_capt_pitch_ratio = find_dataref("sim/cockpit2/controls/yoke_pitch_ratio")
simDR_capt_roll_ratio = find_dataref("sim/cockpit2/controls/yoke_roll_ratio")
simDR_fo_pitch_ratio = find_dataref("sim/cockpit2/controls/yoke_pitch_ratio_copilot")
simDR_fo_roll_ratio = find_dataref("sim/cockpit2/controls/yoke_roll_ratio_copilot")
simDR_priority_side	= find_dataref("sim/joystick/priority_side") -- 0 = Normal, 1 = Priority Left, 2 = Priority Right


simDR_barometer_setting_warn_pilot = find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_warn_pilot")
simDR_barometer_setting_warn_copilot = find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_warn_copilot")




--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

A333DR_press_knobs_pack_flow_pos = find_dataref("laminar/A333/pressurization/knobs/pack_flow_pos")
A333DR_knobs_bleed_isol_valve_pos = find_dataref("laminar/A333/pressurization/knobs/pack_isol_valve_pos")

A333DR_left_pump1_pos = find_dataref("laminar/A333/fuel/buttons/left1_pump_pos")
A333DR_left_pump2_pos = find_dataref("laminar/A333/fuel/buttons/left2_pump_pos")
A333DR_left_standby_pump_pos = find_dataref("laminar/A333/fuel/buttons/left_stby_pump_pos")

A333DR_right_pump1_pos = find_dataref("laminar/A333/fuel/buttons/right1_pump_pos")
A333DR_right_pump2_pos = find_dataref("laminar/A333/fuel/buttons/right2_pump_pos")
A333DR_right_standby_pump_pos = find_dataref("laminar/A333/fuel/buttons/right_stby_pump_pos")

A333DR_center_left_pump_pos = find_dataref("laminar/A333/fuel/buttons/center_left_pump_pos")
A333DR_center_right_pump_pos = find_dataref("laminar/A333/fuel/buttons/center_right_pump_pos")

A333DR_fuel_wing_crossfeed_pos = find_dataref("laminar/A333/fuel/buttons/wing_x_feed_pos")

A333DR_fuel_center_xfr_pos = find_dataref("laminar/A333/fuel/buttons/center_xfr_pos")
A333DR_fuel_trim_xfr_pos = find_dataref("laminar/A333/fuel/buttons/trim_xfr_pos")
A333DR_fuel_outer_tank_xfr_pos = find_dataref("laminar/A333/fuel/buttons/outer_tank_xfr_pos")

A333DR_trim_tank_feed_mode_pos = find_dataref("laminar/A333/fuel/switches/trim_tank_feed_pos")

-- ADIRS

A333DR_adirs_ir1_knob = find_dataref("laminar/A333/buttons/adirs/ir1_knob_pos")
A333DR_adirs_ir3_knob = find_dataref("laminar/A333/buttons/adirs/ir3_knob_pos")
A333DR_adirs_ir2_knob = find_dataref("laminar/A333/buttons/adirs/ir2_knob_pos")

A333DR_adirs_ir1_mode = find_dataref("laminar/A333/adirs/ir1_status")
A333DR_adirs_adr1_mode = find_dataref("laminar/A333/adirs/adr1_status")

A333DR_adirs_ir3_mode = find_dataref("laminar/A333/adirs/ir3_status")
A333DR_adirs_adr3_mode = find_dataref("laminar/A333/adirs/adr3_status")

A333DR_adirs_ir2_mode = find_dataref("laminar/A333/adirs/ir2_status")
A333DR_adirs_adr2_mode = find_dataref("laminar/A333/adirs/adr2_status")

A333DR_ir1_trigger = find_dataref("laminar/A333/adirs/ir1_trigger")
A333DR_ir2_trigger = find_dataref("laminar/A333/adirs/ir2_trigger")

-- FIRE

A333_apu_fire_handle_pos = find_dataref("laminar/A333/fire/switches/apu_handle")

-- ENGINE LIMITS MANAGEMENT

A333DR_epr_limit_to = find_dataref("laminar/A333/engine/epr_limit_to[2]")
A333DR_epr_limit_flex = find_dataref("laminar/A333/engine/epr_limit_flex[2]")
A333DR_epr_limit_mc = find_dataref("laminar/A333/engine/epr_limit_mc[2]")
A333DR_epr_limit_ga = find_dataref("laminar/A333/engine/epr_limit_ga[2]")


-- TEMPERATURE

A333_cockpit_temp_knob_pos = find_dataref("laminar/A333/knob/cockpit_temp")
A333_cabin_temp_knob_pos = find_dataref("laminar/A333/knob/cabin_temp")
A333_fwd_cargo_temp_knob_pos = find_dataref("laminar/A333/knob/fwd_cargo_temp")
A333_bulk_cargo_temp_knob_pos = find_dataref("laminar/A333/knob/aft_cargo_temp")
A333_cargo_cooling_mode_pos = find_dataref("laminar/A333/buttons/cargo_cond/cooling_knob_pos")
A333_switches_hot_air1_pos = find_dataref("laminar/A333/buttons/hot_air1_pos")
A333_switches_hot_air2_pos = find_dataref("laminar/A333/buttons/hot_air2_pos")
A333_cargo_cond_hot_air_pos = find_dataref("laminar/A333/buttons/cargo_cond/hot_air_pos")
A333_cabin_fan_pos = find_dataref("laminar/A333/buttons/cabin_fan_pos")

-- HYDRAULICS

A333_engine1_pump_green_pos = find_dataref("laminar/A330/buttons/hyd/eng1_pump_green_pos")
A333_engine1_pump_blue_pos = find_dataref("laminar/A330/buttons/hyd/eng1_pump_blue_pos")
A333_engine2_pump_yellow_pos = find_dataref("laminar/A330/buttons/hyd/eng2_pump_yellow_pos")
A333_engine2_pump_green_pos = find_dataref("laminar/A330/buttons/hyd/eng2_pump_green_pos")

A333_elec_pump_green_on_pos = find_dataref("laminar/A330/buttons/hyd/elec_green_on_pos")
A333_elec_pump_blue_on_pos = find_dataref("laminar/A330/buttons/hyd/elec_blue_on_pos")
A333_elec_pump_yellow_on_pos = find_dataref("laminar/A330/buttons/hyd/elec_yellow_on_pos")

A333_elec_pump_green_tog_pos = find_dataref("laminar/A330/buttons/hyd/elec_green_tog_pos")
A333_elec_pump_blue_tog_pos = find_dataref("laminar/A330/buttons/hyd/elec_blue_tog_pos")
A333_elec_pump_yellow_tog_pos = find_dataref("laminar/A330/buttons/hyd/elec_yellow_tog_pos")

A333_eng1_hyd_fire_valve_pos = find_dataref("laminar/A333/fire/hydraulic_fire_valve1_pos")
A333_eng2_hyd_fire_valve_pos = find_dataref("laminar/A333/fire/hydraulic_fire_valve2_pos")

-- FUEL

A333_left_pump1_pos = find_dataref("laminar/A333/fuel/buttons/left1_pump_pos")
A333_left_pump2_pos = find_dataref("laminar/A333/fuel/buttons/left2_pump_pos")
A333_left_standby_pump_pos = find_dataref("laminar/A333/fuel/buttons/left_stby_pump_pos")

A333_right_pump1_pos = find_dataref("laminar/A333/fuel/buttons/right1_pump_pos")
A333_right_pump2_pos = find_dataref("laminar/A333/fuel/buttons/right2_pump_pos")
A333_right_standby_pump_pos = find_dataref("laminar/A333/fuel/buttons/right_stby_pump_pos")

A333_center_left_pump_pos = find_dataref("laminar/A333/fuel/buttons/center_left_pump_pos")
A333_center_right_pump_pos = find_dataref("laminar/A333/fuel/buttons/center_right_pump_pos")

A333_fuel_wing_crossfeed_pos = find_dataref("laminar/A333/fuel/buttons/wing_x_feed_pos")

A333_fuel_center_xfr_pos = find_dataref("laminar/A333/fuel/buttons/center_xfr_pos")
A333_fuel_trim_xfr_pos = find_dataref("laminar/A333/fuel/buttons/trim_xfr_pos")
A333_fuel_outer_tank_xfr_pos = find_dataref("laminar/A333/fuel/buttons/outer_tank_xfr_pos")

A333_trim_tank_feed_mode_pos = find_dataref("laminar/A333/fuel/switches/trim_tank_feed_pos")

-- ECAM

A333_ventilation_extract_status = find_dataref("laminar/A333/status/ventilation_extract")
A333_ditching_status = find_dataref("laminar/A333/ditching_status")
A333_status_ram_air_valve = find_dataref("laminar/A333/ecam/BLEED/ram_air_status")

-- ANTI ICE

A333_wing_heat_valve_pos_left = find_dataref("laminar/A333/anti_ice/status/left_wing_valve_pos")
A333_wing_heat_valve_pos_right = find_dataref("laminar/A333/anti_ice/status/right_wing_valve_pos")

-- FLIGHT PHASE

A333_flight_phase = find_dataref("laminar/A333/data/flight_phase")

-- PFD

A333_ls_bars_capt = find_dataref("laminar/A333/status/capt_ls_bars")
A333_ls_bars_fo = find_dataref("laminar/A333/status/fo_ls_bars")





--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

A333_pack_flow1_ratio = create_dataref("laminar/A333/pressurization/pack_flow1_ratio", "number")
A333_pack_flow2_ratio = create_dataref("laminar/A333/pressurization/pack_flow2_ratio", "number")

A333_pack1_exhaust_pos = create_dataref("laminar/A330/pack1_door", "number")
A333_pack2_exhaust_pos = create_dataref("laminar/A330/pack2_door", "number")

----- ELT -------------------------------------------------------------------------------

A333_elt_switch_pos = create_dataref("laminar/A333/switches/elt", "number")
A333_elt_annun = create_dataref("laminar/A333/lights/elt", "number")

----- ADIRS -----------------------------------------------------------------------------

A333_ahars1_starting = create_dataref("laminar/A333/adirs/ir1_starting", "number")
A333_ahars2_starting = create_dataref("laminar/A333/adirs/ir2_starting", "number")

----- CONTROL SURFACE DROOP -------------------------------------------------------------

A333_inboard_ail_droop_rat			= create_dataref("laminar/A333/control_surfaces/inboard_aileron_droop_ratio", "number")
A333_outboard_ail_droop_rat			= create_dataref("laminar/A333/control_surfaces/outboard_aileron_droop_ratio", "number")
A333_left_hstab_droop_rat			= create_dataref("laminar/A333/control_surfaces/left_hstab_droop_ratio", "number")
A333_right_hstab_droop_rat			= create_dataref("laminar/A333/control_surfaces/right_hstab_droop_ratio", "number")

----- ECAM ------------------------------------------------------------------------------

A333_ECAM_engine1_display = create_dataref("laminar/A333/ecam/engine1_display", "number")
A333_ECAM_engine2_display = create_dataref("laminar/A333/ecam/engine2_display", "number")
A333_ECAM_engine_display = create_dataref("laminar/A333/ecam/engine_display", "number")
A333_ECAM_flap_display = create_dataref("laminar/A333/ecam/flap_display", "number")
A333_ECAM_slat_display = create_dataref("laminar/A333/ecam/slat_display", "number")

A333_ECAM_conf_req_ind = create_dataref("laminar/A333/ecam/conf_req_ind", "number")

A333_ECAM_flap_status = create_dataref("laminar/A333/ecam/flap_status", "number")
A333_ECAM_slat_status = create_dataref("laminar/A333/ecam/slat_status", "number")

A333_ECAM_flap_relief_flasher = create_dataref("laminar/A333/ecam/flap_relief_flash", "number")
A333_ECAM_slat_alock_flasher = create_dataref("laminar/A333/ecam/slat_alock_flash", "number")
A333_ECAM_flap_lever_sel = create_dataref("laminar/A333/ecam/flap_lever_sel", "number")

A333_EGT1_limit = create_dataref("laminar/A333/ecam/egt1_limit", "number")
A333_EGT2_limit = create_dataref("laminar/A333/ecam/egt2_limit", "number")
A333_EGT1_limit_vis = create_dataref("laminar/A333/ecam/egt1_limit_visible", "number")
A333_EGT2_limit_vis = create_dataref("laminar/A333/ecam/egt2_limit_visible", "number")

A333_ECAM_thrust_mode = create_dataref("laminar/A333/ecam/thrust_mode", "number")
A333_ECAM_thrust_limit_EPR = create_dataref("laminar/A333/ecam/thrust_limit_epr", "number")

A333_ECAM_idle_status = create_dataref("laminar/A333/ecam/idle_status", "number")
A333_ECAM_idle_flasher = create_dataref("laminar/A333/ecam/idle_flasher", "number")

A333_ECAM_IGN_mode = create_dataref("laminar/A333/ecam/ign_mode", "number")

A333_ECAM_APU_needles_vis = create_dataref("laminar/A333/ecam/apu_needle_vis", "number")
A333_ECAM_APU_GEN_status = create_dataref("laminar/A333/ecam/apu_gen_status", "number")
A333_ECAM_APU_PSI = create_dataref("laminar/A333/ecam/apu_psi", "number")
A333_ECAM_APU_volts = create_dataref("laminar/A333/ecam/apu_volts", "number")
A333_ECAM_APU_hertz = create_dataref("laminar/A333/ecam/apu_hz", "number")
A333_ECAM_APU_egt_hot_status = create_dataref("laminar/A333/ecam/apu_overheat_status", "number")

-- ELEC ECAM

	-- AC --

A333_ECAM_elec_gen1_status = create_dataref("laminar/A333/ecam/elec/gen1_status", "number")
A333_ECAM_elec_gen2_status = create_dataref("laminar/A333/ecam/elec/gen2_status", "number")
A333_ECAM_elec_apu_gen_status = create_dataref("laminar/A333/ecam/elec/apu_gen_status", "number")
A333_ECAM_gen1_volts = create_dataref("laminar/A333/ecam/gen1_volts", "number")
A333_ECAM_gen1_hertz = create_dataref("laminar/A333/ecam/gen1_hz", "number")
A333_ECAM_gen2_volts = create_dataref("laminar/A333/ecam/gen2_volts", "number")
A333_ECAM_gen2_hertz = create_dataref("laminar/A333/ecam/gen2_hz", "number")
A333_ECAM_ext_a_volts = create_dataref("laminar/A333/ecam/ext_a_volts", "number")
A333_ECAM_ext_a_hertz = create_dataref("laminar/A333/ecam/ext_a_hz", "number")
A333_ECAM_ext_b_volts = create_dataref("laminar/A333/ecam/ext_b_volts", "number")
A333_ECAM_ext_b_hertz = create_dataref("laminar/A333/ecam/ext_b_hz", "number")
A333_ECAM_idg1_temp = create_dataref("laminar/A333/ecam/elec/idg1_temp", "number")
A333_ECAM_idg2_temp = create_dataref("laminar/A333/ecam/elec/idg2_temp", "number")

A333_ECAM_syn_ac1_line = create_dataref("laminar/A333/ecam/elec/synoptic_ac1_line", "number")
A333_ECAM_syn_ac2_line = create_dataref("laminar/A333/ecam/elec/synoptic_ac2_line", "number")
A333_ECAM_crossbar1_line = create_dataref("laminar/A333/ecam/elec/synoptic_cross_bar1", "number")
A333_ECAM_crossbar2_line = create_dataref("laminar/A333/ecam/elec/synoptic_cross_bar2", "number")
A333_ECAM_crossbar3_line = create_dataref("laminar/A333/ecam/elec/synoptic_cross_bar3", "number")
A333_ECAM_apu_gen_line = create_dataref("laminar/A333/ecam/elec/apu_gen_bar", "number")
A333_ECAM_gpu_line = create_dataref("laminar/A333/ecam/elec/gpu_gen_bar", "number")

	-- DC --

A333_ECAM_elec_tr1_volts = create_dataref("laminar/A333/ecam/elec/tr1_volts", "number")
A333_ECAM_elec_tr1_amps  = create_dataref("laminar/A333/ecam/elec/tr1_amps", "number")
A333_ECAM_elec_tr2_volts = create_dataref("laminar/A333/ecam/elec/tr2_volts", "number")
A333_ECAM_elec_tr2_amps  = create_dataref("laminar/A333/ecam/elec/tr2_amps", "number")

A333_ECAM_elec_ess_tr_volts = create_dataref("laminar/A333/ecam/elec/ess_tr_volts", "number")
A333_ECAM_elec_ess_tr_amps  = create_dataref("laminar/A333/ecam/elec/ess_tr_amps", "number")
A333_ECAM_elec_apu_tr_volts = create_dataref("laminar/A333/ecam/elec/apu_tr_volts", "number")
A333_ECAM_elec_apu_tr_amps  = create_dataref("laminar/A333/ecam/elec/apu_tr_amps", "number")

A333_ECAM_elec_tr1_status = create_dataref("laminar/A333/ecam/elec/tr1_status", "number")
A333_ECAM_elec_tr2_status = create_dataref("laminar/A333/ecam/elec/tr2_status", "number")
A333_ECAM_elec_ess_tr_status = create_dataref("laminar/A333/ecam/elec/ess_tr_status", "number")
A333_ECAM_elec_apu_tr_status = create_dataref("laminar/A333/ecam/elec/apu_tr_status", "number")

A333_ECAM_elec_ess_tr_source = create_dataref("laminar/A333/ecam/elec/ess_tr_source", "number")

A333_ECAM_elec_dc_bat_bus_status = create_dataref("laminar/A333/ecam/elec/dc_bat_busbar_status", "number")
A333_ECAM_elec_dc_ess_bus_status = create_dataref("laminar/A333/ecam/elec/dc_ess_busbar_status", "number")
A333_ECAM_elec_dc1_bus_status = create_dataref("laminar/A333/ecam/elec/dc1_busbar_status", "number")
A333_ECAM_elec_dc2_bus_status = create_dataref("laminar/A333/ecam/elec/dc2_busbar_status", "number")
A333_ECAM_elec_dc_apu_bus_status = create_dataref("laminar/A333/ecam/elec/dc_apu_busbar_status", "number")

A333_ECAM_elec_dc1_dcbat_line_sts = create_dataref("laminar/A333/ecam/elec/dc1_dcbat_syn_status", "number")
A333_ECAM_elec_dc2_dcbat_line_sts = create_dataref("laminar/A333/ecam/elec/dc2_dcbat_syn_status", "number")
A333_ECAM_elec_dcbat_dcess_line_sts = create_dataref("laminar/A333/ecam/elec/dcbat_dcess_syn_status", "number")
A333_ECAM_elec_bat1_dc_bat_line_sts = create_dataref("laminar/A333/ecam/elec/bat1_dc_bat_status", "number")
A333_ECAM_elec_bat2_dc_bat_line_sts = create_dataref("laminar/A333/ecam/elec/bat2_dc_bat_status", "number")
A333_ECAM_elec_apu_bat_dc_apu_line_sts = create_dataref("laminar/A333/ecam/elec/apu_bat_dc_apu_status", "number")
A333_ECAM_elec_bat1_dc_ess_line_sts = create_dataref("laminar/A333/ecam/elec/bat1_dc_ess_status", "number")
A333_ECAM_elec_bat2_dc_ess_line_sts = create_dataref("laminar/A333/ecam/elec/bat2_dc_ess_status", "number")
A333_ECAM_apu_starter_source_count = create_dataref("laminar/A333/ecam/elec/apu_sources", "number")

-- HYDRAULICS ECAM

A333_ECAM_hyd_green_status = create_dataref("laminar/A333/ecam/hyd_green_status", "number")
A333_ECAM_hyd_blue_status = create_dataref("laminar/A333/ecam/hyd_blue_status", "number")
A333_ECAM_hyd_yellow_status = create_dataref("laminar/A333/ecam/hyd_yellow_status", "number")

A333_ECAM_hyd_green_eng1_fire_valve = create_dataref("laminar/A333/ecam/hyd_green_eng1_fire_valve_pos", "number")
A333_ECAM_hyd_blue_eng1_fire_valve = create_dataref("laminar/A333/ecam/hyd_blue_eng1_fire_valve_pos", "number")
A333_ECAM_hyd_yellow_eng2_fire_valve = create_dataref("laminar/A333/ecam/hyd_yellow_eng2_fire_valve_pos", "number")
A333_ECAM_hyd_green_eng2_fire_valve = create_dataref("laminar/A333/ecam/hyd_green_eng2_fire_valve_pos", "number")

A333_ECAM_hyd_green_eng1_pump = create_dataref("laminar/A333/ecam/hyd_green_eng1_pump_pos", "number")
A333_ECAM_hyd_blue_eng1_pump = create_dataref("laminar/A333/ecam/hyd_blue_eng1_pump_pos", "number")
A333_ECAM_hyd_yellow_eng2_pump = create_dataref("laminar/A333/ecam/hyd_yellow_eng2_pump_pos", "number")
A333_ECAM_hyd_green_eng2_pump = create_dataref("laminar/A333/ecam/hyd_green_eng2_pump_pos", "number")

A333_ECAM_hyd_elec_green_arrow = create_dataref("laminar/A333/ecam/hyd/elec_green_arrow_enum", "number")
A333_ECAM_hyd_elec_blue_arrow = create_dataref("laminar/A333/ecam/hyd/elec_blue_arrow_enum", "number")
A333_ECAM_hyd_elec_yellow_arrow = create_dataref("laminar/A333/ecam/hyd/elec_yellow_arrow_enum", "number")

A333_ECAM_hyd_elec_green_status = create_dataref("laminar/A333/ecam/hyd/elec_green_status", "number")
A333_ECAM_hyd_elec_blue_status = create_dataref("laminar/A333/ecam/hyd/elec_blue_status", "number")
A333_ECAM_hyd_elec_yellow_status = create_dataref("laminar/A333/ecam/hyd/elec_yellow_status", "number")

A333_ECAM_hyd_green1_line_fin = create_dataref("laminar/A333/ecam/hyd/green1_line_fin_status", "number")
A333_ECAM_hyd_blue_line_fin = create_dataref("laminar/A333/ecam/hyd/blue_line_fin_status", "number")
A333_ECAM_hyd_yellow_line_fin = create_dataref("laminar/A333/ecam/hyd/yellow_line_fin_status", "number")
A333_ECAM_hyd_green2_line_fin = create_dataref("laminar/A333/ecam/hyd/green2_line_fin_status", "number")

A333_ECAM_hyd_rat_arrow_enum = create_dataref("laminar/A333/ecam/hyd/rat_arrow_enum", "number")
A333_ECAM_hyd_rat_rpm = create_dataref("laminar/A333/ecam/hyd/ram_air_turbine_RPM", "number")
A333_ECAM_hyd_rat_status = create_dataref("laminar/A333/ecam/hyd/rat_status", "number")

-- FUEL ECAM

A333_ECAM_fuel_left_aux_xfer_enum = create_dataref("laminar/A333/ecam/fuel/left_aux_xfer_enum", "number")
A333_ECAM_fuel_right_aux_xfer_enum = create_dataref("laminar/A333/ecam/fuel/right_aux_xfer_enum", "number")
A333_ECAM_fuel_trim_xfer_enum = create_dataref("laminar/A333/ecam/fuel/trim_xfer_enum", "number")
A333_ECAM_fuel_ctr_L_xfer_enum = create_dataref("laminar/A333/ecam/fuel/L_ctr_xfer_enum", "number")
A333_ECAM_fuel_ctr_R_xfer_enum = create_dataref("laminar/A333/ecam/fuel/R_ctr_xfer_enum", "number")
A333_ECAM_fuel_ctr_line_xfer_enum = create_dataref("laminar/A333/ecam/fuel/line_ctr_xfr_enum", "number") -- - 0 none - 1 left from left - 2 left from both OR RIGHT - 3 all - 4 right from both OR LEFT - 5 right from right

A333_ECAM_fuel_left_pump_config = create_dataref("laminar/A333/ecam/fuel/left_pump_config", "number") -- 0 default, pump 1&2 lines on - 1 all lines on - 2 ONLY standby lines on
A333_ECAM_fuel_right_pump_config = create_dataref("laminar/A333/ecam/fuel/right_pump_config", "number") -- 0 default, pump 1&2 lines on - 1 all lines on - 2 ONLY standby lines on

A333_ECAM_fuel_totalkg_min = create_dataref("laminar/A333/ecam/fuel/total_kg_min_burn", "number")

A333_ECAM_fuel_pump_L1_enum = create_dataref("laminar/A333/ecam/fuel/pump_L1_enum", "number")
A333_ECAM_fuel_pump_L2_enum = create_dataref("laminar/A333/ecam/fuel/pump_L2_enum", "number")
A333_ECAM_fuel_pump_Lstby_enum = create_dataref("laminar/A333/ecam/fuel/pump_Lstby_enum", "number")
A333_ECAM_fuel_pump_Rstby_enum = create_dataref("laminar/A333/ecam/fuel/pump_Rstby_enum", "number")
A333_ECAM_fuel_pump_R2_enum = create_dataref("laminar/A333/ecam/fuel/pump_R2_enum", "number")
A333_ECAM_fuel_pump_R1_enum = create_dataref("laminar/A333/ecam/fuel/pump_R1_enum", "number")

A333_ECAM_fuel_pump_CL_enum = create_dataref("laminar/A333/ecam/fuel/pump_CL_enum", "number")
A333_ECAM_fuel_pump_CR_enum = create_dataref("laminar/A333/ecam/fuel/pump_CR_enum", "number")

A333_ECAM_fuel_center_xfer_any = create_dataref("laminar/A333/ecam/fuel/status_center_xfer", "number")

-- FLIGHT CONTROLS ECAM

A333_outer_L_ail	= create_dataref("laminar/A333/flight_controls/composite_outerL_ail", "number")
A333_inner_L_ail	= create_dataref("laminar/A333/flight_controls/composite_innerL_ail", "number")
A333_inner_R_ail	= create_dataref("laminar/A333/flight_controls/composite_innerR_ail", "number")
A333_outer_R_ail	= create_dataref("laminar/A333/flight_controls/composite_outerR_ail", "number")
A333_L_elev			= create_dataref("laminar/A333/flight_controls/composite_elevL", "number")
A333_R_elev			= create_dataref("laminar/A333/flight_controls/composite_elevR", "number")

A333_outer_L_ail_amber_status = create_dataref("laminar/A333/ecam/fctl_outer_ail_L_status", "number")
A333_inner_L_ail_amber_status = create_dataref("laminar/A333/ecam/fctl_inner_ail_L_status", "number")
A333_inner_R_ail_amber_status = create_dataref("laminar/A333/ecam/fctl_inner_ail_R_status", "number")
A333_outer_R_ail_amber_status = create_dataref("laminar/A333/ecam/fctl_outer_ail_R_status", "number")
A333_L_elev_amber_status = create_dataref("laminar/A333/ecam/fctl_L_elev_status", "number")
A333_R_elev_amber_status = create_dataref("laminar/A333/ecam/fctl_R_elev_status", "number")
A333_rud_amber_status = create_dataref("laminar/A333/ecam/fctl_rudder_hyd_status", "number")
A333_pitch_amber_status = create_dataref("laminar/A333/ecam/fctl_pitch_hyd_status", "number")

A333_spoiler1_L_enum = create_dataref("laminar/A333/flight_controls/spoiler1_L_enum", "number")
A333_spoiler2_L_enum = create_dataref("laminar/A333/flight_controls/spoiler2_L_enum", "number")
A333_spoiler3_L_enum = create_dataref("laminar/A333/flight_controls/spoiler3_L_enum", "number")
A333_spoiler4_L_enum = create_dataref("laminar/A333/flight_controls/spoiler4_L_enum", "number")
A333_spoiler5_L_enum = create_dataref("laminar/A333/flight_controls/spoiler5_L_enum", "number")
A333_spoiler6_L_enum = create_dataref("laminar/A333/flight_controls/spoiler6_L_enum", "number")

A333_spoiler1_R_enum = create_dataref("laminar/A333/flight_controls/spoiler1_R_enum", "number")
A333_spoiler2_R_enum = create_dataref("laminar/A333/flight_controls/spoiler2_R_enum", "number")
A333_spoiler3_R_enum = create_dataref("laminar/A333/flight_controls/spoiler3_R_enum", "number")
A333_spoiler4_R_enum = create_dataref("laminar/A333/flight_controls/spoiler4_R_enum", "number")
A333_spoiler5_R_enum = create_dataref("laminar/A333/flight_controls/spoiler5_R_enum", "number")
A333_spoiler6_R_enum = create_dataref("laminar/A333/flight_controls/spoiler6_R_enum", "number")

A333_rudder_trim_ind = create_dataref("laminar/A333/ecam/FCTL/rudder_trim_ind", "number")

-- TEMPERATURE INDICATORS ECAM

A333_cockpit_temp_ind = create_dataref("laminar/A333/ckpt_temp", "number")
A333_cabin_fwd_temp_ind = create_dataref("laminar/A333/cabin_temp_fwd", "number")
A333_cabin_mid_temp_ind = create_dataref("laminar/A333/cabin_temp_mid", "number")
A333_cabin_aft_temp_ind = create_dataref("laminar/A333/cabin_temp_aft", "number")
A333_cargo_temp_ind = create_dataref("laminar/A333/cargo_temp", "number")
A333_bulk_cargo_temp_ind = create_dataref("laminar/A333/bulk_cargo_temp", "number")

-- ECAM DOORS OXY

A333_cockpit_oxy_status = create_dataref("laminar/A333/ECAM/door/ckpt_oxy_status", "number")
A333_regul_lo_pr_status = create_dataref("laminar/A333/ECAM/door/regul_lo_pr_status", "number")

A333_slide1_status = create_dataref("laminar/A333/ECAM/doors/slide1", "number") -- -1 = off, 0 = amber, 1 = white
A333_slide2_status = create_dataref("laminar/A333/ECAM/doors/slide2", "number") -- -1 = off, 0 = amber, 1 = white
A333_slide3_status = create_dataref("laminar/A333/ECAM/doors/slide3", "number") -- -1 = off, 0 = amber, 1 = white
A333_slide4_status = create_dataref("laminar/A333/ECAM/doors/slide4", "number") -- -1 = off, 0 = amber, 1 = white
A333_slide5_status = create_dataref("laminar/A333/ECAM/doors/slide5", "number") -- -1 = off, 0 = amber, 1 = white
A333_slide6_status = create_dataref("laminar/A333/ECAM/doors/slide6", "number") -- -1 = off, 0 = amber, 1 = white
A333_slide7_status = create_dataref("laminar/A333/ECAM/doors/slide7", "number") -- -1 = off, 0 = amber, 1 = white
A333_slide8_status = create_dataref("laminar/A333/ECAM/doors/slide8", "number") -- -1 = off, 0 = amber, 1 = white

-- ECAM WHEEL

A333_lg_ctl_status = create_dataref("laminar/A333/ecam/wheel/l_g_ctl_status", "number") -- 0 = extinguished, 1 = amber indication
A333_norm_brake_status = create_dataref("laminar/A333/ecam/wheel/norm_brake_status", "number") -- 0 = extinguished, 1 = amber indication
A333_anti_skid_status = create_dataref("laminar/A333/ecam/wheel/anti_skid_status", "number") -- 0 = extinguished, 1 = amber indication

A333_wheel_brake_temp1 = create_dataref("laminar/A333/ecam/wheel/brake_temp_1", "number")
A333_wheel_brake_temp2 = create_dataref("laminar/A333/ecam/wheel/brake_temp_2", "number")
A333_wheel_brake_temp3 = create_dataref("laminar/A333/ecam/wheel/brake_temp_3", "number")
A333_wheel_brake_temp4 = create_dataref("laminar/A333/ecam/wheel/brake_temp_4", "number")
A333_wheel_brake_temp5 = create_dataref("laminar/A333/ecam/wheel/brake_temp_5", "number")
A333_wheel_brake_temp6 = create_dataref("laminar/A333/ecam/wheel/brake_temp_6", "number")
A333_wheel_brake_temp7 = create_dataref("laminar/A333/ecam/wheel/brake_temp_7", "number")
A333_wheel_brake_temp8 = create_dataref("laminar/A333/ecam/wheel/brake_temp_8", "number")

A333_wheel_brake_temp_anim_1 = create_dataref("laminar/A333/wheel/brake_temp_anim_1", "number")
A333_wheel_brake_temp_anim_2 = create_dataref("laminar/A333/wheel/brake_temp_anim_2", "number")
A333_wheel_brake_temp_anim_3 = create_dataref("laminar/A333/wheel/brake_temp_anim_3", "number")
A333_wheel_brake_temp_anim_4 = create_dataref("laminar/A333/wheel/brake_temp_anim_4", "number")
A333_wheel_brake_temp_anim_5 = create_dataref("laminar/A333/wheel/brake_temp_anim_5", "number")
A333_wheel_brake_temp_anim_6 = create_dataref("laminar/A333/wheel/brake_temp_anim_6", "number")
A333_wheel_brake_temp_anim_7 = create_dataref("laminar/A333/wheel/brake_temp_anim_7", "number")
A333_wheel_brake_temp_anim_8 = create_dataref("laminar/A333/wheel/brake_temp_anim_8", "number")

A333_wheel_brake_warn = create_dataref("laminar/A333/ecam/wheel/brake_temp_exceed", "number")

A333_wheel_brake_temp_arc1 = create_dataref("laminar/A333/ecam/wheel/brake_temp_arc_1", "number") -- 0 = white, 1 = green, 2 = amber
A333_wheel_brake_temp_arc2 = create_dataref("laminar/A333/ecam/wheel/brake_temp_arc_2", "number") -- 0 = white, 1 = green, 2 = amber
A333_wheel_brake_temp_arc3 = create_dataref("laminar/A333/ecam/wheel/brake_temp_arc_3", "number") -- 0 = white, 1 = green, 2 = amber
A333_wheel_brake_temp_arc4 = create_dataref("laminar/A333/ecam/wheel/brake_temp_arc_4", "number") -- 0 = white, 1 = green, 2 = amber
A333_wheel_brake_temp_arc5 = create_dataref("laminar/A333/ecam/wheel/brake_temp_arc_5", "number") -- 0 = white, 1 = green, 2 = amber
A333_wheel_brake_temp_arc6 = create_dataref("laminar/A333/ecam/wheel/brake_temp_arc_6", "number") -- 0 = white, 1 = green, 2 = amber
A333_wheel_brake_temp_arc7 = create_dataref("laminar/A333/ecam/wheel/brake_temp_arc_7", "number") -- 0 = white, 1 = green, 2 = amber
A333_wheel_brake_temp_arc8 = create_dataref("laminar/A333/ecam/wheel/brake_temp_arc_8", "number") -- 0 = white, 1 = green, 2 = amber

A333_wheel_brake_release_left = create_dataref("laminar/A333/ecam/wheel/brake_release_left", "number")
A333_wheel_brake_release_right = create_dataref("laminar/A333/ecam/wheel/brake_release_right", "number")

-- ECAM CAB PRESS

A333_outflow_valve_fwd = create_dataref("laminar/A333/ecam/cab_press/outflow_valve_fwd", "number")
A333_outflow_valve_aft = create_dataref("laminar/A333/ecam/cab_press/outflow_valve_aft", "number")
A333_vent_extract_valve_pos = create_dataref("laminar/A333/ecam/cab_press/vent_extract_pos", "number") -- 0 = close, 1 = partial, 2 = open

-- ECAM BLEED

A333_isol_valve_right_target = create_dataref("laminar/A333/ecam/bleed/crossbleed_target", "number")
A333_isol_valve_right_pos = create_dataref("laminar/A333/ecam/bleed/crossbleed_valve_pos", "number") -- 0 = close, 1 = transit, 2 = open
A333_user_bleed_status = create_dataref("laminar/A333/ecam/bleed/user_status", "number")
A333_pack1_flow = create_dataref("laminar/A333/ecam/bleed/pack1_flow", "number")
A333_pack2_flow = create_dataref("laminar/A333/ecam/bleed/pack2_flow", "number")
A333_pack1_flow_status = create_dataref("laminar/A333/ecam/bleed/pack1_flow_status", "number")
A333_pack2_flow_status = create_dataref("laminar/A333/ecam/bleed/pack2_flow_status", "number")

A333_pack1_valve_pos = create_dataref("laminar/A333/ecam/bleed/pack1_valve_pos", "number")
A333_pack2_valve_pos = create_dataref("laminar/A333/ecam/bleed/pack2_valve_pos", "number")

A333_pack1_CH_valve_pos = create_dataref("laminar/A333/ecam/bleed/pack1_CH", "number")
A333_pack2_CH_valve_pos = create_dataref("laminar/A333/ecam/bleed/pack2_CH", "number")

A333_precooler1_temp = create_dataref("laminar/A333/ecam/bleed/precooler1_temp", "number")
A333_precooler2_temp = create_dataref("laminar/A333/ecam/bleed/precooler2_temp", "number")

A333_pack1_compressor_outlet_temp = create_dataref("laminar/A333/ecam/bleed/pack1_compressor_outlet_temp", "number")
A333_pack2_compressor_outlet_temp = create_dataref("laminar/A333/ecam/bleed/pack2_compressor_outlet_temp", "number")

A333_pack1_outlet_temp = create_dataref("laminar/A333/ecam/bleed/pack1_outlet_temp", "number")
A333_pack2_outlet_temp = create_dataref("laminar/A333/ecam/bleed/pack2_outlet_temp", "number")

A333_precooler1_psi = create_dataref("laminar/A333/ecam/bleed/precooler1_psi", "number")
A333_precooler2_psi = create_dataref("laminar/A333/ecam/bleed/precooler2_psi", "number")

A333_left_wing_ai_valve_ind = create_dataref("laminar/A333/ecam/bleed/left_wing_antiice_valve_ind", "number")
A333_right_wing_ai_valve_ind = create_dataref("laminar/A333/ecam/bleed/right_wing_antiice_valve_ind", "number")
A333_left_wing_ai_status = create_dataref("laminar/A333/anti_ice/status/left_anti_ice_wing_status", "number")
A333_right_wing_ai_status = create_dataref("laminar/A333/anti_ice/status/right_anti_ice_wing_status", "number")

-- ECAM COND

A333_pack_lo_flow = create_dataref("laminar/A333/ecam/COND/pack_lo_flow_pulse", "number")
A333_pack_regulated = create_dataref("laminar/A333/ecam/COND/pack_reg_ind", "number")
A333_cabin_fan1_off = create_dataref("laminar/A333/ecam/COND/cabin_fan1_ind", "number")
A333_cabin_fan2_off = create_dataref("laminar/A333/ecam/COND/cabin_fan2_ind", "number")
A333_hot_air_cross_valve_pos = create_dataref("laminar/A333/ecam/COND/hot_air_x_valve", "number")
A333_hot_air_loop1_status = create_dataref("laminar/A333/ecam/COND/hot_air_loop1", "number")
A333_hot_air_loop2_status = create_dataref("laminar/A333/ecam/COND/hot_air_loop2", "number")
A333_hot_air_1_valve = create_dataref("laminar/A333/ecam/COND/hot_air_valve1", "number")
A333_hot_air_2_valve = create_dataref("laminar/A333/ecam/COND/hot_air_valve2", "number")

A333_bulk_heater_line = create_dataref("laminar/A333/ecam/COND/bulk_heat_syn", "number")
A333_cold_air_line1 = create_dataref("laminar/A333/ecam/COND/cold_air_syn1", "number")
A333_cold_air_line2 = create_dataref("laminar/A333/ecam/COND/cold_air_syn2", "number")
A333_cold_air_valve = create_dataref("laminar/A333/ecam/COND/cold_air_valve", "number")

A333_zone1_needle = create_dataref("laminar/A333/ecam/COND/zone1_needle", "number")
A333_zone2_needle = create_dataref("laminar/A333/ecam/COND/zone2_needle", "number")
A333_zone3_needle = create_dataref("laminar/A333/ecam/COND/zone3_needle", "number")
A333_zone4_needle = create_dataref("laminar/A333/ecam/COND/zone4_needle", "number")
A333_zone5_needle = create_dataref("laminar/A333/ecam/COND/zone5_needle", "number")
A333_zone6_needle = create_dataref("laminar/A333/ecam/COND/zone6_needle", "number")
A333_zone7_needle = create_dataref("laminar/A333/ecam/COND/zone7_needle", "number")
A333_bulk_needle = create_dataref("laminar/A333/ecam/COND/bulk_needle", "number")
A333_cargo_needle = create_dataref("laminar/A333/ecam/COND/cargo_needle", "number")

A333_zone1_duct_temp = create_dataref("laminar/A333/ecam/COND/zone1_duct_temp", "number")
A333_zone2_duct_temp = create_dataref("laminar/A333/ecam/COND/zone2_duct_temp", "number")
A333_zone3_duct_temp = create_dataref("laminar/A333/ecam/COND/zone3_duct_temp", "number")
A333_zone4_duct_temp = create_dataref("laminar/A333/ecam/COND/zone4_duct_temp", "number")
A333_zone5_duct_temp = create_dataref("laminar/A333/ecam/COND/zone5_duct_temp", "number")
A333_zone6_duct_temp = create_dataref("laminar/A333/ecam/COND/zone6_duct_temp", "number")
A333_zone7_duct_temp = create_dataref("laminar/A333/ecam/COND/zone7_duct_temp", "number")
A333_bulk_duct_temp = create_dataref("laminar/A333/ecam/COND/bulk_duct_temp", "number")
A333_cargo_duct_temp = create_dataref("laminar/A333/ecam/COND/cargo_duct_temp", "number")

A333_cabin_fwd_mid_temp_ind = create_dataref("laminar/A333/cabin_temp_fwd_mid", "number")
A333_cabin_mid_fwd_temp_ind = create_dataref("laminar/A333/cabin_temp_mid_fwd", "number")
A333_cabin_mid_aft_temp_ind = create_dataref("laminar/A333/cabin_temp_mid_aft", "number")

-- PFD

A333_ladder_mask_deg_capt = create_dataref("laminar/A333/PFD/ladder_mask_capt_pos_deg", "number")
A333_ladder_mask_deg_FO = create_dataref("laminar/A333/PFD/ladder_mask_fo_pos_deg", "number")

A333_tick_mark_mode_capt = create_dataref("laminar/A333/PFD/tick_mark_pitch_capt_mode", "number") -- 0 = glued to horizon, 1 = glued to ladder mask
A333_tick_mark_mode_FO = create_dataref("laminar/A333/PFD/tick_mark_pitch_fo_mode", "number")

A333_engines_running = create_dataref("laminar/A333/PFD/engines_running", "number")

A333_vvi_capt_amber = create_dataref("laminar/A333/PFD/vertical_speed_amber_capt", "number")
A333_vvi_FO_amber = create_dataref("laminar/A333/PFD/vertical_speed_amber_fo", "number")

A333_capt_autopilot_alt_mode = create_dataref("laminar/A333/PFD/capt_autopilot_alt_display_mode", "number")
A333_fo_autopilot_alt_mode = create_dataref("laminar/A333/PFD/fo_autopilot_alt_display_mode", "number")

A333_capt_autopilot_vnav_alt_mode = create_dataref("laminar/A333/PFD/capt_autopilot_vnav_alt_display_mode", "number")
A333_fo_autopilot_vnav_alt_mode = create_dataref("laminar/A333/PFD/fo_autopilot_vnav_alt_display_mode", "number")

A333_ap_heading_mode_capt = create_dataref("laminar/A333/PFD/capt_heading_mode", "number")
A333_ap_heading_mode_fo = create_dataref("laminar/A333/PFD/fo_heading_mode", "number")

A333_track_mode_capt = create_dataref("laminar/A333/PFD/capt_track_mode", "number")
A333_track_mode_fo = create_dataref("laminar/A333/PFD/fo_track_mode", "number")
A333_tru_track_mode_capt = create_dataref("laminar/A333/PFD/capt_track_true_mode", "number")
A333_tru_track_mode_fo = create_dataref("laminar/A333/PFD/fo_track_true_mode", "number")

A333_ils_mode_capt = create_dataref("laminar/A333/PFD/capt_ils_mode", "number")
A333_ils_mode_fo = create_dataref("laminar/A333/PFD/fo_ils_mode", "number")

A333_capt_autopilot_speed_mode = create_dataref("laminar/A333/PFD/capt_autopilot_speed_display_mode", "number")
A333_fo_autopilot_speed_mode = create_dataref("laminar/A333/PFD/fo_autopilot_speed_display_mode", "number")

A333_capt_green_dot_mode = create_dataref("laminar/A333/PFD/capt_green_dot_mode", "number")
A333_fo_green_dot_mode = create_dataref("laminar/A333/PFD/fo_green_dot_mode", "number")

A333_capt_Vr_mode = create_dataref("laminar/A333/PFD/capt_Vr_mode", "number")
A333_fo_Vr_mode = create_dataref("laminar/A333/PFD/fo_Vr_mode", "number")

A333_capt_V1_mode = create_dataref("laminar/A333/PFD/capt_V1_mode", "number")
A333_fo_V1_mode = create_dataref("laminar/A333/PFD/fo_V1_mode", "number")

A333_PFD_ND_has_power = create_dataref("laminar/A333/PFD/displays_powered", "number")

A333_ap_alt_ind_color = create_dataref("laminar/A333/PFD/ap_alt_ind_color", "number") -- 0 == cyan, 1 == magenta

A333_flight_dir_lat_status_capt = create_dataref("laminar/A333/PFD/flight_director_vis_lat_status_capt", "number") -- 0 = none, 1 = lat indicator
A333_flight_dir_vrt_status_capt = create_dataref("laminar/A333/PFD/flight_director_vis_vrt_status_capt", "number") -- 0 = none, 1 = vrt indicator
A333_flight_dir_bar_status_capt = create_dataref("laminar/A333/PFD/flight_director_vis_bar_status_capt", "number") -- 0 = none, 1 = bar indicator

A333_flight_dir_lat_status_fo = create_dataref("laminar/A333/PFD/flight_director_vis_lat_status_fo", "number") -- 0 = none, 1 = lat indicator
A333_flight_dir_vrt_status_fo = create_dataref("laminar/A333/PFD/flight_director_vis_vrt_status_fo", "number") -- 0 = none, 1 = vrt indicator
A333_flight_dir_bar_status_fo = create_dataref("laminar/A333/PFD/flight_director_vis_bar_status_fo", "number") -- 0 = none, 1 = bar indicator


A333_ils_flasher_capt_status = create_dataref("laminar/A333/PDF/ils_flasher_status_capt", "number") -- 0 = hide 1 = show
A333_ils_flasher_fo_status = create_dataref("laminar/A333/PDF/ils_flasher_status_fo", "number") -- 0 = hide 1 = show
A333_ils_flasher_capt = create_dataref("laminar/A333/PFD/ils_flasher_capt", "number")
A333_ils_flasher_fo = create_dataref("laminar/A333/PFD/ils_flasher_fo", "number")

A333_vdev_flasher_capt_status = create_dataref("laminar/A333/PDF/vdev_flasher_status_capt", "number") -- 0 = hide 1 = show
A333_vdev_flasher_fo_status = create_dataref("laminar/A333/PDF/vdev_flasher_status_fo", "number") -- 0 = hide 1 = show
A333_vdev_flasher_capt = create_dataref("laminar/A333/PFD/vdev_flasher_capt", "number")
A333_vdev_flasher_fo = create_dataref("laminar/A333/PFD/vdev_flasher_fo", "number")

A333_fpv_pitch_absolute_capt = create_dataref("laminar/A333/PFD/fpv_pitch_abs_capt", "number")
A333_fpv_pitch_absolute_fo = create_dataref("laminar/A333/PFD/fpv_pitch_abs_fo", "number")
A333_birdie_pitch_absolute_capt = create_dataref("laminar/A333/PFD/birdie_pitch_abs_capt", "number")
A333_birdie_pitch_absolute_fo = create_dataref("laminar/A333/PFD/birdie_pitch_abs_fo", "number")

A333_radio_altimeter_color_capt = create_dataref("laminar/A333/PFD/radio_altimeter_color_capt", "number") -- 0 = green, 1 = amber
A333_radio_altimeter_color_fo = create_dataref("laminar/A333/PFD/radio_altimeter_color_fo", "number") -- 0 = green, 1 = amber

A333_mda_altimeter_color_capt = create_dataref("laminar/A333/PFD/mda_alt_color_capt", "number") -- 0 = green, 1 = amber
A333_mda_altimeter_color_fo = create_dataref("laminar/A333/PFD/mda_alt_color_fo", "number") -- 0 = green, 1 = amber

A333_dh_flasher_capt = create_dataref("laminar/A333/PFD/DH_flasher_capt", "number")
A333_dh_flasher_fo = create_dataref("laminar/A333/PFD/DH_flasher_fo", "number")

A333_windshear_flasher = create_dataref("laminar/A333/PFD/windshear_flasher", "number")
A333_ws_ahead_flasher = create_dataref("laminar/A333/PFD/ws_ahead_flasher", "number")



-- VSPEEDS

A333_mach_ias_ratio = create_dataref("laminar/A333/calc/mach_ias_ratio", "number")
A333_vmo_mmo_ias = create_dataref("laminar/A333/PFD/airspeed_ind/vmo_mmo", "number")
A333_over_speed_ind = create_dataref("laminar/A333/PFD/airspeed_ind/over_speed", "number")
A333_next_flap_speed_ind = create_dataref("laminar/A333/PFD/airspeed_ind/next_flap_speed", "number")

A333_gear_off_ground_timer = create_dataref("laminar/A333/PFD/airspeed_ind/off_ground_timer", "number")

-- ND

A333_nd_vor1_ID_flag_capt = create_dataref("laminar/A333/nd/vor1_id_flag/capt", "number")
A333_nd_vor2_ID_flag_capt = create_dataref("laminar/A333/nd/vor2_id_flag/capt", "number")

A333_nd_adf1_ID_flag_capt = create_dataref("laminar/A333/nd/adf1_id_flag/capt", "number")
A333_nd_adf2_ID_flag_capt = create_dataref("laminar/A333/nd/adf2_id_flag/capt", "number")

A333_gps_dme_time_min = create_dataref("laminar/A333/nd/gps_dme_time_min", "number")
A333_gps_dme_time_sec = create_dataref("laminar/A333/nd/gps_dme_time_sec", "number")

A333_gps2_dme_time_min = create_dataref("laminar/A333/nd/gps2_dme_time_min", "number")
A333_gps2_dme_time_sec = create_dataref("laminar/A333/nd/gps2_dme_time_sec", "number")

A333_capt_gps_active_status = create_dataref("laminar/A333/radios/capt_gps_status", "number")
A333_fo_gps_active_status = create_dataref("laminar/A333/radios/fo_gps_status", "number")

-- FMAs

A333_AP_modes = create_dataref("laminar/A333/PFD/FMAs/autopilot_12_status", "number")
A333_FD_modes = create_dataref("laminar/A333/PFD/FMAs/flight_dir_12_status", "number")
A333_climb_descend = create_dataref("laminar/A333/PFD/FMAs/climb_descend", "number") -- -1 = descend, 1 = climb
A333_alt_star_status = create_dataref("laminar/A333/PFD/FMAs/alt_star_status", "number") -- 0 = STAR, 1 = CAPTURED
A333_gs_star_status = create_dataref("laminar/A333/PFD/FMAs/gs_star_status", "number") -- 0 = STAR, 1 = captured
A333_loc_star_status = create_dataref("laminar/A333/PFD/FMAs/loc_star_status", "number") -- 0 = STAR, 1 = CAPTURED

A333_man_toga = create_dataref("laminar/A333/PFD/FMAs/man_toga_status", "number")
A333_man_mct = create_dataref("laminar/A333/PFD/FMAs/man_mct_status", "number")
A333_man_flex = create_dataref("laminar/A333/PFD/FMAs/man_flex_status", "number")

A333_thr_mct = create_dataref("laminar/A333/PFD/FMAs/thr_mct_status", "number")
A333_thr_clb = create_dataref("laminar/A333/PFD/FMAs/thr_clb_status", "number")
A333_thr_lvr = create_dataref("laminar/A333/PFD/FMAs/thr_lvr_status", "number")

A333_lvr_assym = create_dataref("laminar/A333/PFD/FMAs/lvr_assym_status", "number")

A333_row3_speed_ias = create_dataref("laminar/A333/PFD/FMAs/speed_ias_status", "number") -- 0 = hidden, 1 = visible - only visible in IAS mode, flight phase 5 or less
A333_row3_speed_mach = create_dataref("laminar/A333/PFD/FMAs/speed_mach_status", "number") -- 0 = hidden, 1 = visible - only visible in mach mode, flight phase 6 or less, make disappear within .01 of MACH
A333_column1_2_divider = create_dataref("laminar/A333/PFD/FMAs/col1_col2_divider", "number") -- 0 = tall, 1 = short, tall when both ias and mach are 0, 1 when either is 1

A333_landing_category_enum = create_dataref("laminar/A333/PFD/FMAs/landing_cat_enum", "number") -- 0 = none, 1 = cat1, 2 = cat2, 3 = cat3 -- loc and G/S = true
A333_single_dual_mode = create_dataref("laminar/A333/PFD/FMAs/landing_single_dual", "number") -- 0 = no AP, 1 = single AP, 2 = dual AP -- loc and G/S = true

A333_alt_arm_status = create_dataref("laminar/A333/PFD/FMAs/alt_arm_status", "number") -- 0 = hide, 1 = show
A333_ga_trk_status = create_dataref("laminar/A333/PFD/FMAs/ga_trk_status", "number") -- 0 = hide, 1 = show
A333_dh_mda_status = create_dataref("laminar/A333/PFD/FMAs/dh_mda_status", "number") -- 0 = hide, 1 = show
A333_final_app_status = create_dataref("laminar/A333/PFD/FMAs/final_app_status", "number") -- 0 = hide, 1 = show

A333_set_green_dot_spd = create_dataref("laminar/A333/PFD/FMAs/set_green_dot_spd", "number") -- 0 = hide, 1 = show
A333_man_pitch_trim_only = create_dataref("laminar/A333/PFD/FMAs/man_pitch_trim_only", "number") -- 0 = hide, 1 = show

A333_lvr_clb_status = create_dataref("laminar/A333/PFD/FMAs/lvr_clb_status", "number") -- 0 = hide, 1 = show
A333_lvr_mct_status = create_dataref("laminar/A333/PFD/FMAs/lvr_mct_status", "number") -- 0 = hide, 1 = show
A333_lvr_clb_mct_flasher = create_dataref("laminar/A333/PFD/FMAs/lvr_clb_mct_flasher", "number")

-- SIDESTICK PRIORITY

A333_composite_stick_pitch = create_dataref("laminar/A333/sidestick/composite_pitch_ratio", "number")
A333_composite_stick_roll = create_dataref("laminar/A333/sidestick/composite_roll_ratio", "number")

A333_capt_priority_light = create_dataref("laminar/A333/sidestick/capt_prior_annun", "number")
A333_fo_priority_light = create_dataref("laminar/A333/sidestick/fo_prior_annun", "number")
A333_capt_priority_arrow = create_dataref("laminar/A333/sidestick/capt_arrow_annun", "number")
A333_fo_priority_arrow = create_dataref("laminar/A333/sidestick/fo_arrow_annun", "number")

A333_capt_zeroed = create_dataref("laminar/A333/sidestick/capt_zeroed", "number") -- 1 if capt stick = 0,0 within 0.5%
A333_fo_zeroed = create_dataref("laminar/A333/sidestick/fo_zeroed", "number")
A333_dual_input = create_dataref("laminar/A333/sidestick/dual_input", "number")	-- 1 if dual input



----- AI --------------------------------------------------------------------------------

A333DR_init_systems_CD = create_dataref("laminar/A333/init_CD/systems", "number")

A333DR_var_test = create_dataref("laminar/A333/var_test", "number")
A333_laminar_no_ref = create_dataref("laminar/no_ref", "number")


-- Read initial values from PlaneMaker instead of hardcoding them... this fails on new flight start - we're writing to both of these targets in the script
local LOW_IDLE_PLN_TARGET = 0.56
local HIGH_IDLE_PLN_TARGET = 1.3
local STARTER_TORQUE_PLN_VALUE = simDR_starter_torque



A333DR_baro_warning_brightness = create_dataref("laminar/A333/PFD/baro_warning_brightness", "number")



--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--

function A333_test_DRhandler() end

--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--


A333_test = create_dataref("laminar/A333/xtk_error_test", "number", A333_test_DRhandler)

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
--** 				               REPLACE X-PLANE COMMANDS                   	     **--
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

function A333_elt_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_elt_switch_pos == 1 then
			A333_elt_switch_pos = 0
		elseif A333_elt_switch_pos == 0 then
			A333_elt_switch_pos = -1
		end
	end
end

function A333_elt_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_elt_switch_pos == -1 then
			A333_elt_switch_pos = 0
			elt_trigger = 0
		elseif A333_elt_switch_pos == 0 then
			A333_elt_switch_pos = 1
			elt_trigger = 1
		end
	end
end

function A333_elt_trigger_CMDhandler(phase, duration)
	if phase == 0 then
		elt_trigger = 1
	end
end

-- AI

function A333_ai_systems_quick_start_CMDhandler(phase, duration)
	if phase == 0 then
		A333_set_systems_all_modes()
		A333_set_systems_CD()
		A333_set_systems_ER()
	end
end

--*************************************************************************************--
--** 				                 CUSTOM COMMANDS                			     **--
--*************************************************************************************--

A333CMD_elt_down = create_command("laminar/A333/switches/ELT_down", "ELT switch down", A333_elt_dn_CMDhandler)
A333CMD_elt_up = create_command("laminar/A333/switches/ELT_up", "ELT switch up", A333_elt_up_CMDhandler)
A333CMD_elt_trigger = create_command("laminar/A333/elt_trigger", "ELT trigger", A333_elt_trigger_CMDhandler)

-- AI

A333CMD_ai_systems_quick_start = create_command("laminar/A333/ai/systems_quick_start", "AI Systems", A333_ai_systems_quick_start_CMDhandler)

--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--

function ternary(condition, ifTrue, ifFalse)
	if condition then
		return ifTrue
	else
		return ifFalse
	end
end

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

	if x < in1 then
		return out1
	end
	if x > in2 then
		return out2
	end
	return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end

function A333_duct_isol_valves()

	if A333_apu_fire_handle_pos == 0 then

		if A333DR_knobs_bleed_isol_valve_pos == -1 then
			simDR_duct_isol_valve_left = 1
			A333_isol_valve_right_target = 0
		elseif A333DR_knobs_bleed_isol_valve_pos == 0 then
			if simDR_apu_bleed == 1 then
				simDR_duct_isol_valve_left = 1
				A333_isol_valve_right_target = 1
			elseif simDR_apu_bleed == 0 then
				simDR_duct_isol_valve_left = 1
				A333_isol_valve_right_target = 0
			end
		elseif A333DR_knobs_bleed_isol_valve_pos == 1 then
			simDR_duct_isol_valve_left = 1
			A333_isol_valve_right_target = 1
		end

	elseif A333_apu_fire_handle_pos == 1 then
		simDR_duct_isol_valve_left = 1
		A333_isol_valve_right_target = 0
	end

end

local bleed_mode_factor_left = 0
local bleed_mode_factor_right = 0

function A333_pack_flow()

	local bleed_mode = 0 -- 0 = two engine bleed, 1 = single engine bleed, 2 = apu bleed, 3 = bleed_air_failure, 4 = engine_any_start -- for determining auto / overrides

	if simDR_engine1_starter_running == 0 and simDR_engine2_starter_running == 0 then

		if simDR_bleed_air1_fail < 6 and simDR_bleed_air2_fail < 6 then
			if simDR_apu_bleed == 0 then
				if simDR_bleed_air1 == 1 and simDR_bleed_air2 == 1 or simDR_bleed_air1 == 0 and simDR_bleed_air2 == 0 then
					bleed_mode = 0
				elseif simDR_bleed_air1 == 1 and simDR_bleed_air2 == 0 or simDR_bleed_air1 == 0 and simDR_bleed_air2 == 1 then
					bleed_mode = 1
				end
			elseif simDR_apu_bleed == 1 then
				bleed_mode = 2
			end
		elseif simDR_bleed_air1_fail == 6 or simDR_bleed_air2_fail == 6 then
			bleed_mode = 3
		end

	elseif simDR_engine1_starter_running == 1 or simDR_engine2_starter_running == 1 then
		bleed_mode = 4
	end

	if A333DR_press_knobs_pack_flow_pos == -1 then
		if bleed_mode == 0 then
			pack1_flow_target = 0.8
			pack2_flow_target = 0.8
		elseif bleed_mode == 1 then
			pack1_flow_target = 1.25
			pack2_flow_target = 1.25
		elseif bleed_mode == 2 then
			pack1_flow_target = 1.25
			pack2_flow_target = 1.25
		elseif bleed_mode == 3 then
			pack1_flow_target = 0.8
			pack2_flow_target = 0.8
		elseif bleed_mode == 4 then
			pack1_flow_target = 0
			pack2_flow_target = 0
		end
	elseif A333DR_press_knobs_pack_flow_pos == 0 then
		if bleed_mode == 0 then
			pack1_flow_target = 1
			pack2_flow_target = 1
		elseif bleed_mode == 1 then
			pack1_flow_target = 1.25
			pack2_flow_target = 1.25
		elseif bleed_mode == 2 then
			pack1_flow_target = 1.25
			pack2_flow_target = 1.25
		elseif bleed_mode == 3 then
			pack1_flow_target = 0.8
			pack2_flow_target = 0.8
		elseif bleed_mode == 4 then
			pack1_flow_target = 0
			pack2_flow_target = 0
		end
	elseif A333DR_press_knobs_pack_flow_pos == 1 then
		if bleed_mode == 0 then
			pack1_flow_target = 1.25
			pack2_flow_target = 1.25
		elseif bleed_mode == 1 then
			pack1_flow_target = 1.25
			pack2_flow_target = 1.25
		elseif bleed_mode == 2 then
			pack1_flow_target = 1.25
			pack2_flow_target = 1.25
		elseif bleed_mode == 3 then
			pack1_flow_target = 0.8
			pack2_flow_target = 0.8
		elseif bleed_mode == 4 then
			pack1_flow_target = 0
			pack2_flow_target = 0
		end

	end

	if simDR_duct_isol_valve_right == 0 then
		if simDR_apu_bleed == 0 then
			bleed_mode_factor_left = 1
			bleed_mode_factor_right = 1
		elseif simDR_apu_bleed == 1 then
			bleed_mode_factor_left = 1.75
			bleed_mode_factor_right = 1
		end
	elseif simDR_duct_isol_valve_right == 1 then
		if simDR_apu_bleed == 0 then
			bleed_mode_factor_left = 0.5
			bleed_mode_factor_right = 0.5
		elseif simDR_apu_bleed == 1 then
			bleed_mode_factor_left = 1.75
			bleed_mode_factor_right = 1.75
		end
	end

	pack1_flow_ratio = pack1_flow_target * simDR_left_duct_avail * simDR_left_pack * bleed_mode_factor_left
	pack2_flow_ratio = pack2_flow_target * simDR_right_duct_avail * simDR_right_pack * bleed_mode_factor_right

	A333_pack_flow1_ratio = A333_set_animation_position(A333_pack_flow1_ratio, pack1_flow_ratio, 0, 15, 2)
	A333_pack_flow2_ratio = A333_set_animation_position(A333_pack_flow2_ratio, pack2_flow_ratio, 0, 15, 2)

	local airspeed_factor = A333_rescale(40, 1, 128, 0.2, simDR_equiv_airspeed)
	local pack1_flow_factor = A333_rescale(0, 0, 1.125, 1, A333_pack_flow1_ratio)
	local pack2_flow_factor = A333_rescale(0, 0, 1.125, 1, A333_pack_flow2_ratio)

	pack1_exhaust_target = simDR_left_pack * airspeed_factor * pack1_flow_factor
	pack2_exhaust_target = simDR_right_pack * airspeed_factor * pack2_flow_factor

	A333_pack1_exhaust_pos = A333_set_animation_position(A333_pack1_exhaust_pos, pack1_exhaust_target, 0, 1, 2)
	A333_pack2_exhaust_pos = A333_set_animation_position(A333_pack2_exhaust_pos, pack2_exhaust_target, 0, 1, 2)

end


-- FUEL SYSTEM

local trim_tank_level_store = 0
local center_tank_level_store = 0
local left_aux_tank_level_store = 0
local right_aux_tank_level_store = 0
local left_wing_tank_store = 0
local right_wing_tank_store = 0
local center_left_transfer_enum = 0
local center_right_transfer_enum = 0

function A333_fuel_system()

	if A333DR_left_pump1_pos >= 1 or A333DR_left_pump2_pos >= 1 or A333DR_left_standby_pump_pos >= 1 then
		simDR_fuel_tank_left = 1
	elseif A333DR_left_pump1_pos == 0 and A333DR_left_pump2_pos == 0 and A333DR_left_standby_pump_pos == 0 then
		simDR_fuel_tank_left = 0
	end

	if A333DR_right_pump1_pos >= 1 or A333DR_right_pump2_pos >= 1 or A333DR_right_standby_pump_pos >= 1 then
		simDR_fuel_tank_right = 1
	elseif A333DR_right_pump1_pos == 0 and A333DR_right_pump2_pos == 0 and A333DR_right_standby_pump_pos == 0 then
		simDR_fuel_tank_right = 0
	end

	if A333DR_center_left_pump_pos >= 1 or A333DR_center_right_pump_pos >= 1 then
		simDR_fuel_tank_center = 1
		simDR_tank_pressure_center = 40
	elseif A333DR_center_left_pump_pos == 0 and A333DR_center_right_pump_pos == 0 then
		simDR_fuel_tank_center = 0
		simDR_tank_pressure_center = 0
	end

	if A333DR_fuel_wing_crossfeed_pos == 1 then
		simDR_fuel_tank_sel_left = 4
		simDR_fuel_tank_sel_right = 4
	elseif A333DR_fuel_wing_crossfeed_pos == 0 then
		simDR_fuel_tank_sel_left = 1
		simDR_fuel_tank_sel_right = 3
	end

	if simDR_tank_pressure_center == 40 then
		-- CENTER TANK OPERATING

		if simDR_tank_level_center >= 75 then
			-- CENTER TANK HAS FUEL - allow continuous transfer
			tank_transfer_left = 1
			tank_transfer_right = 1
			simDR_xfer_pump_activation_level = 2000
			simDR_xfer_pump_deactivation_level = 0
			if A333DR_trim_tank_feed_mode_pos == -1 then
				-- TRIM FEED MODE OPEN
				simDR_tank_pressure_trim = 50 -- FORCES TRIM TANK TO EMPTY TO WING TANKS VIA PSI HEIRARCHY

				if simDR_tank_level_trim < 5 then
					simDR_xfer_pump_activation_level = 2000
				elseif simDR_tank_level_trim >= 5 then
					simDR_xfer_pump_activation_level = 0
				end

			elseif A333DR_trim_tank_feed_mode_pos >= 0 then
				-- NO CHANGE TO NORMAL IN ISOL / NORMAL AS NO FUEL IS MOVING FROM TRIM TANK
				simDR_tank_pressure_trim = 37
			end

		elseif simDR_tank_level_center < 75 then
			-- CENTER TANK APPROACHING EMPTY

			if A333DR_trim_tank_feed_mode_pos == 0 then
				-- TRIM TANK FEED AUTO (NORMAL MODE)

				if simDR_tank_level_trim > 75 then
					-- TRIM TANK HAS FUEL
					simDR_tank_pressure_trim = 37
					if simDR_tank_level_left < 4000 or simDR_tank_level_right < 4000 then
						-- IF LEVEL IS UNDER 4000kg - allow transfer
						tank_transfer_left = 2
						tank_transfer_right = 2
						simDR_xfer_pump_activation_level = 31812
					elseif simDR_tank_level_left >= 4500 and simDR_tank_level_right >= 4500 then
						-- IF LEVEL EXCEEDS 4500kg - pause transfer
						tank_transfer_left = 0
						tank_transfer_right = 0
						simDR_xfer_pump_activation_level = 0
					end
				elseif simDR_tank_level_trim < 75 then
					-- TRIM TANK IS EMPTY
					simDR_tank_pressure_trim = 0 -- TURN OFF PRESSURE SO THAT REMOVED FROM HEIRARCHY

					if simDR_tank_level_left < 3500 then
						tank_transfer_left = 2
					elseif simDR_tank_level_left >= 4000 then
						tank_transfer_left = 0
					end

					if simDR_tank_level_right < 3500 then
						tank_transfer_right = 2
					elseif simDR_tank_level_right >= 4000 then
						tank_transfer_right = 0
					end

					if tank_transfer_left == 2 or tank_transfer_right == 2 then
						simDR_xfer_pump_activation_level = 32312
					elseif tank_transfer_left == 0 and tank_transfer_right == 0 then
						simDR_xfer_pump_activation_level = 0
					end

				end

			elseif A333DR_trim_tank_feed_mode_pos == 1 then
				-- TRIM TANK FEED ISOL

				simDR_tank_pressure_trim = 0

				if simDR_tank_level_left < 3500 then
					tank_transfer_left = 2
				elseif simDR_tank_level_left >= 4000 then
					tank_transfer_left = 0
				end

				if simDR_tank_level_right < 3500 then
					tank_transfer_right = 2
				elseif simDR_tank_level_right >= 4000 then
					tank_transfer_right = 0
				end

				if tank_transfer_left == 2 or tank_transfer_right == 2 then
					simDR_xfer_pump_activation_level = 32312
				elseif tank_transfer_left == 0 and tank_transfer_right == 0 then
					simDR_xfer_pump_activation_level = 0
				end


			elseif A333DR_trim_tank_feed_mode_pos == -1 then
				-- TRIM TANK FEED OPEN

				simDR_tank_pressure_trim = 50
				if simDR_tank_level_trim < 5 then

					if simDR_tank_level_left < 3500 then
						tank_transfer_left = 2
					elseif simDR_tank_level_left >= 4000 then
						tank_transfer_left = 0
					end

					if simDR_tank_level_right < 3500 then
						tank_transfer_right = 2
					elseif simDR_tank_level_right >= 4000 then
						tank_transfer_right = 0
					end

					if tank_transfer_left == 2 or tank_transfer_right == 2 then
						simDR_xfer_pump_activation_level = 32312
					elseif tank_transfer_left == 0 and tank_transfer_right == 0 then
						simDR_xfer_pump_activation_level = 0
					end

				elseif simDR_tank_level_trim >= 5 then
					tank_transfer_left = 2
					tank_transfer_right = 2
				end
			end
		end

	elseif simDR_tank_pressure_center == 0 then
		-- CENTER TANK TURNED OFF (WITH OR WITHOUT FUEL)

		if A333DR_trim_tank_feed_mode_pos == 0 then
			-- TRIM TANK FEED AUTO

			if simDR_tank_level_trim > 75 then
				-- TRIM TANK HAS FUEL
				simDR_tank_pressure_trim = 37
				if simDR_tank_level_left < 4000 or simDR_tank_level_right < 4000 then
					tank_transfer_left = 2
					tank_transfer_right = 2
					simDR_xfer_pump_activation_level = 31812
				elseif simDR_tank_level_left >= 4500 and simDR_tank_level_right >= 4500 then
					tank_transfer_left = 0
					tank_transfer_right = 0
					simDR_xfer_pump_activation_level = 0
				end
			elseif simDR_tank_level_trim < 75 then
				-- TRIM TANK APPROACHING EMPTY
				simDR_tank_pressure_trim = 0 -- REMOVE TRIM TANK FROM HEIRARCHY

				if simDR_tank_level_left < 3500 then
					tank_transfer_left = 2
				elseif simDR_tank_level_left >= 4000 then
					tank_transfer_left = 0
				end

				if simDR_tank_level_right < 3500 then
					tank_transfer_right = 2
				elseif simDR_tank_level_right >= 4000 then
					tank_transfer_right = 0
				end

				if tank_transfer_left == 2 or tank_transfer_right == 2 then
					simDR_xfer_pump_activation_level = 32312
				elseif tank_transfer_left == 0 and tank_transfer_right == 0 then
					simDR_xfer_pump_activation_level = 0
				end

			end

		elseif A333DR_trim_tank_feed_mode_pos == 1 then
			-- TRIM TANK FEED ISOL

			simDR_tank_pressure_trim = 0 -- REMOVE TRIM TANK FROM HEIRARCHY

			if simDR_tank_level_left < 3500 then
				tank_transfer_left = 2
			elseif simDR_tank_level_left >= 4000 then
				tank_transfer_left = 0
			end

			if simDR_tank_level_right < 3500 then
				tank_transfer_right = 2
			elseif simDR_tank_level_right >= 4000 then
				tank_transfer_right = 0
			end

			if tank_transfer_left == 2 or tank_transfer_right == 2 then
				simDR_xfer_pump_activation_level = 32312
			elseif tank_transfer_left == 0 and tank_transfer_right == 0 then
				simDR_xfer_pump_activation_level = 0
			end

		elseif A333DR_trim_tank_feed_mode_pos == -1 then
			-- TRIM TANK FEED OPEN

			simDR_tank_pressure_trim = 50
			if simDR_tank_level_trim < 5 then

				if simDR_tank_level_left < 3500 then
					tank_transfer_left = 2
				elseif simDR_tank_level_left >= 4000 then
					tank_transfer_left = 0
				end

				if simDR_tank_level_right < 3500 then
					tank_transfer_right = 2
				elseif simDR_tank_level_right >= 4000 then
					tank_transfer_right = 0
				end

				if tank_transfer_left == 2 or tank_transfer_right == 2 then
					simDR_xfer_pump_activation_level = 32312
				elseif tank_transfer_left == 0 and tank_transfer_right == 0 then
					simDR_xfer_pump_activation_level = 0
				end

			elseif simDR_tank_level_trim >= 5 then
				tank_transfer_left = 2
				tank_transfer_right = 2
			end

		end

	end

	if A333DR_fuel_center_xfr_pos == 0 then
		-- OVERRIDE AUX TRANSFER

		if A333DR_fuel_outer_tank_xfr_pos == 0 then
			simDR_fuel_transfer_left_aux = tank_transfer_left
			simDR_fuel_transfer_right_aux = tank_transfer_right
			simDR_tank_pressure_left_aux = 33
			simDR_tank_pressure_right_aux = 33
		elseif A333DR_fuel_outer_tank_xfr_pos >= 1 then
			if simDR_tank_level_aux_left >= 5 then
				simDR_tank_pressure_left_aux = 50
				simDR_fuel_transfer_left_aux = 2
			elseif simDR_tank_level_aux_left < 5 then
				simDR_fuel_transfer_left_aux = tank_transfer_left
				simDR_tank_pressure_left_aux = 33
			end
			if simDR_tank_level_aux_right >= 5 then
				simDR_tank_pressure_right_aux = 50
				simDR_fuel_transfer_right_aux = 2
			elseif simDR_tank_level_aux_right < 5 then
				simDR_fuel_transfer_right_aux = tank_transfer_right
				simDR_tank_pressure_right_aux = 33
			end
		end

	elseif A333DR_fuel_center_xfr_pos >= 1 then

		if A333DR_fuel_outer_tank_xfr_pos == 0 then

			simDR_tank_pressure_left_aux = 33
			simDR_tank_pressure_right_aux = 33

			if simDR_tank_level_center >= 75 then
				simDR_tank_pressure_center = 50
				simDR_fuel_transfer_left_aux = 2
				simDR_fuel_transfer_right_aux = 2
			elseif simDR_tank_level_center < 75 then
				simDR_tank_pressure_center = 0
				simDR_fuel_transfer_left_aux = tank_transfer_left
				simDR_fuel_transfer_right_aux = tank_transfer_right
			end

		elseif A333DR_fuel_outer_tank_xfr_pos >= 1 then

			if simDR_tank_level_center >= 75 then
				simDR_tank_pressure_center = 50
				simDR_fuel_transfer_left_aux = 2
				simDR_fuel_transfer_right_aux = 2
				if simDR_tank_level_aux_left >= 5 then
					simDR_tank_pressure_left_aux = 50
				elseif simDR_tank_level_aux_left < 5 then
					simDR_tank_pressure_left_aux = 33
				end
				if simDR_tank_level_aux_right >= 5 then
					simDR_tank_pressure_right_aux = 50
				elseif simDR_tank_level_aux_right < 5 then
					simDR_tank_pressure_right_aux = 33
				end
			elseif simDR_tank_level_center < 75 then
				simDR_tank_pressure_center = 0
				if simDR_tank_level_aux_left >= 5 then
					simDR_tank_pressure_left_aux = 50
					simDR_fuel_transfer_left_aux = 2
				elseif simDR_tank_level_aux_left < 5 then
					simDR_fuel_transfer_left_aux = tank_transfer_left
					simDR_tank_pressure_left_aux = 33
				end
				if simDR_tank_level_aux_right >= 5 then
					simDR_tank_pressure_right_aux = 50
					simDR_fuel_transfer_right_aux = 2
				elseif simDR_tank_level_aux_right < 5 then
					simDR_fuel_transfer_right_aux = tank_transfer_right
					simDR_tank_pressure_right_aux = 33
				end
			end

		end

	end

	if A333DR_fuel_trim_xfr_pos == 0 then
		-- FWD FUEL TRANSFER
		simDR_fuel_transfer_from_mode = 0
	elseif A333DR_fuel_trim_xfr_pos >= 1 then
		if A333DR_trim_tank_feed_mode_pos == -1 then
			simDR_fuel_transfer_from_mode = 5
		elseif A333DR_trim_tank_feed_mode_pos == 0 then
			if simDR_tank_level_trim >= 75 then
				simDR_fuel_transfer_from_mode = 5
			elseif simDR_tank_level_trim < 75 then
				simDR_fuel_transfer_from_mode = 0
			end
		elseif A333DR_trim_tank_feed_mode_pos == 1 then
			simDR_fuel_transfer_from_mode = 0
		end
	end


	-- PUMP STATES

	if A333_left_pump1_pos == 0 then
		A333_ECAM_fuel_pump_L1_enum = 0
	elseif A333_left_pump1_pos >= 1 then
		if simDR_tank_level_left >= 150 then
			A333_ECAM_fuel_pump_L1_enum = 1
		elseif simDR_tank_level_left < 150 then
			A333_ECAM_fuel_pump_L1_enum = 2
		end
	end

	if A333_left_pump2_pos == 0 then
		A333_ECAM_fuel_pump_L2_enum = 0
	elseif A333_left_pump2_pos >= 1 then
		if simDR_tank_level_left >= 140 then
			A333_ECAM_fuel_pump_L2_enum = 1
		elseif simDR_tank_level_left < 140 then
			A333_ECAM_fuel_pump_L2_enum = 2
		end
	end

	if A333_right_pump1_pos == 0 then
		A333_ECAM_fuel_pump_R1_enum = 0
	elseif A333_right_pump1_pos >= 1 then
		if simDR_tank_level_right >= 150 then
			A333_ECAM_fuel_pump_R1_enum = 1
		elseif simDR_tank_level_right < 150 then
			A333_ECAM_fuel_pump_R1_enum = 2
		end
	end

	if A333_right_pump2_pos == 0 then
		A333_ECAM_fuel_pump_R2_enum = 0
	elseif A333_right_pump2_pos >= 1 then
		if simDR_tank_level_right >= 140 then
			A333_ECAM_fuel_pump_R2_enum = 1
		elseif simDR_tank_level_right < 140 then
			A333_ECAM_fuel_pump_R2_enum = 2
		end
	end

	if A333_left_standby_pump_pos == 0 then
		A333_ECAM_fuel_pump_Lstby_enum = 0
	elseif A333_left_standby_pump_pos >= 1 then
		if simDR_tank_level_left >= 125 then
			if A333_ECAM_fuel_pump_L1_enum == 0 and A333_ECAM_fuel_pump_L2_enum == 0 then
				A333_ECAM_fuel_pump_Lstby_enum = 1
			elseif A333_ECAM_fuel_pump_L1_enum == 1 or A333_ECAM_fuel_pump_L2_enum == 1 then
				A333_ECAM_fuel_pump_Lstby_enum = 0
			elseif A333_ECAM_fuel_pump_L1_enum == 2 and A333_ECAM_fuel_pump_L2_enum == 2 then
				A333_ECAM_fuel_pump_Lstby_enum = 1
			end
		elseif simDR_tank_level_left < 125 then
			A333_ECAM_fuel_pump_Lstby_enum = 2
		end
	end

	if A333_right_standby_pump_pos == 0 then
		A333_ECAM_fuel_pump_Rstby_enum = 0
	elseif A333_right_standby_pump_pos >= 1 then
		if simDR_tank_level_right >= 125 then
			if A333_ECAM_fuel_pump_R1_enum == 0 and A333_ECAM_fuel_pump_R2_enum == 0 then
				A333_ECAM_fuel_pump_Rstby_enum = 1
			elseif A333_ECAM_fuel_pump_R1_enum == 1 or A333_ECAM_fuel_pump_R2_enum == 1 then
				A333_ECAM_fuel_pump_Rstby_enum = 0
			elseif A333_ECAM_fuel_pump_R1_enum == 2 and A333_ECAM_fuel_pump_R2_enum == 2 then
				A333_ECAM_fuel_pump_Rstby_enum = 1
			end
		elseif simDR_tank_level_right < 125 then
			A333_ECAM_fuel_pump_Rstby_enum = 2
		end
	end

	if A333_left_standby_pump_pos == 0 then
		A333_ECAM_fuel_left_pump_config = 0
	elseif A333_left_standby_pump_pos == 1 then
		if A333_left_pump1_pos >= 1 or A333_left_pump2_pos >= 1 then
			A333_ECAM_fuel_left_pump_config = 1
		elseif A333_left_pump1_pos == 0 and A333_left_pump2_pos == 0 then
			A333_ECAM_fuel_left_pump_config = 2
		end
	end

	if A333_right_standby_pump_pos == 0 then
		A333_ECAM_fuel_right_pump_config = 0
	elseif A333_right_standby_pump_pos == 1 then
		if A333_right_pump1_pos >= 1 or A333_right_pump2_pos >= 1 then
			A333_ECAM_fuel_right_pump_config = 1
		elseif A333_right_pump1_pos == 0 and A333_right_pump2_pos == 0 then
			A333_ECAM_fuel_right_pump_config = 2
		end
	end

	-- TRANSFER STATES

	if simDR_tank_level_trim < trim_tank_level_store then
		A333_ECAM_fuel_trim_xfer_enum = 1
	elseif simDR_tank_level_trim == trim_tank_level_store then
		A333_ECAM_fuel_trim_xfer_enum = 0
	end

	if simDR_tank_level_aux_left < left_aux_tank_level_store then
		if A333_fuel_outer_tank_xfr_pos == 0 then
			A333_ECAM_fuel_left_aux_xfer_enum = 1
		elseif A333_fuel_outer_tank_xfr_pos >= 1 then
			A333_ECAM_fuel_left_aux_xfer_enum = 2
		end
	elseif simDR_tank_level_aux_left == left_aux_tank_level_store then
		A333_ECAM_fuel_left_aux_xfer_enum = 0
	end

	if simDR_tank_level_aux_right < right_aux_tank_level_store then
		if A333_fuel_outer_tank_xfr_pos == 0 then
			A333_ECAM_fuel_right_aux_xfer_enum = 1
		elseif A333_fuel_outer_tank_xfr_pos >= 1 then
			A333_ECAM_fuel_right_aux_xfer_enum = 2
		end
	elseif simDR_tank_level_aux_right == right_aux_tank_level_store then
		A333_ECAM_fuel_right_aux_xfer_enum = 0
	end

	if A333_fuel_center_xfr_pos == 0 then

		if simDR_tank_level_center < center_tank_level_store then
			if simDR_tank_level_left > left_wing_tank_store then
				center_left_transfer_enum = 1
			elseif simDR_tank_level_left <= left_wing_tank_store then
				center_left_transfer_enum = 0
			end
			if simDR_tank_level_right > right_wing_tank_store then
				center_right_transfer_enum = 1
			elseif simDR_tank_level_right <= right_wing_tank_store then
				center_right_transfer_enum = 0
			end
		elseif simDR_tank_level_center == center_tank_level_store then
			center_left_transfer_enum = 0
			center_right_transfer_enum = 0
		end

	elseif A333_fuel_center_xfr_pos >= 1 then
		if simDR_tank_level_center >= 75 then
			center_left_transfer_enum = 1
			center_right_transfer_enum = 1
		elseif simDR_tank_level_center < 75 then
			center_left_transfer_enum = 0
			center_right_transfer_enum = 0
		end
	end

	if center_left_transfer_enum == 1 or center_right_transfer_enum == 1 then
		A333_ECAM_fuel_center_xfer_any = 1
	elseif center_left_transfer_enum == 0 and center_right_transfer_enum == 0 then
		A333_ECAM_fuel_center_xfer_any = 0
	end

	if center_left_transfer_enum == 0 then
		A333_ECAM_fuel_ctr_L_xfer_enum = 0
	elseif center_left_transfer_enum == 1 then
		if A333_fuel_center_xfr_pos >= 1 then
			A333_ECAM_fuel_ctr_L_xfer_enum = 2
		elseif A333_fuel_center_xfr_pos == 0 then
			A333_ECAM_fuel_ctr_L_xfer_enum = 1
		end
	end

	if center_right_transfer_enum == 0 then
		A333_ECAM_fuel_ctr_R_xfer_enum = 0
	elseif center_right_transfer_enum == 1 then
		if A333_fuel_center_xfr_pos >= 1 then
			A333_ECAM_fuel_ctr_R_xfer_enum = 2
		elseif A333_fuel_center_xfr_pos == 0 then
			A333_ECAM_fuel_ctr_R_xfer_enum = 1
		end
	end

	--

	if A333_center_left_pump_pos == 0 then
		A333_ECAM_fuel_pump_CL_enum = 0
	elseif A333_center_left_pump_pos >= 1 then
		if A333_ECAM_fuel_center_xfer_any == 1 then
			if simDR_tank_level_center >= 250 then
				A333_ECAM_fuel_pump_CL_enum = 1
			elseif simDR_tank_level_center < 250 then
				A333_ECAM_fuel_pump_CL_enum = 2
			end
		elseif A333_ECAM_fuel_center_xfer_any == 0 then
			A333_ECAM_fuel_pump_CL_enum = 0
		end
	end

	if A333_center_right_pump_pos == 0 then
		A333_ECAM_fuel_pump_CR_enum = 0
	elseif A333_center_right_pump_pos >= 1 then
		if A333_ECAM_fuel_center_xfer_any == 1 then
			if simDR_tank_level_center >= 250 then
				A333_ECAM_fuel_pump_CR_enum = 1
			elseif simDR_tank_level_center < 250 then
				A333_ECAM_fuel_pump_CR_enum = 2
			end
		elseif A333_ECAM_fuel_center_xfer_any == 0 then
			A333_ECAM_fuel_pump_CR_enum = 0
		end
	end

	if A333_ECAM_fuel_center_xfer_any == 0 then
		A333_ECAM_fuel_ctr_line_xfer_enum = 0
	elseif A333_ECAM_fuel_center_xfer_any == 1 then
		if A333_fuel_center_xfr_pos == 0 then
			if center_left_transfer_enum == 1 and center_right_transfer_enum == 0 then

				if A333_center_right_pump_pos >= 1 then
					A333_ECAM_fuel_ctr_line_xfer_enum = 2
				elseif A333_center_right_pump_pos == 0 then
					A333_ECAM_fuel_ctr_line_xfer_enum = 1
				end

			elseif center_left_transfer_enum == 1 and center_right_transfer_enum == 1 then
				A333_ECAM_fuel_ctr_line_xfer_enum = 3

			elseif center_left_transfer_enum == 0 and center_right_transfer_enum == 1 then

				if A333_center_left_pump_pos >= 1 then
					A333_ECAM_fuel_ctr_line_xfer_enum = 4
				elseif A333_center_left_pump_pos == 0 then
					A333_ECAM_fuel_ctr_line_xfer_enum = 5
				end

			end

		elseif A333_fuel_center_xfr_pos == 1 then
			if A333_center_left_pump_pos == 0 and A333_center_right_pump_pos == 0 then
				A333_ECAM_fuel_ctr_line_xfer_enum = 0
			elseif A333_center_left_pump_pos == 1 or A333_center_right_pump_pos == 1 then
				A333_ECAM_fuel_ctr_line_xfer_enum = 3
			end
		end
	end

	trim_tank_level_store = simDR_tank_level_trim
	center_tank_level_store = simDR_tank_level_center
	left_aux_tank_level_store = simDR_tank_level_aux_left
	right_aux_tank_level_store = simDR_tank_level_aux_right
	left_wing_tank_store = simDR_tank_level_left
	right_wing_tank_store = simDR_tank_level_right


end

-- ELT

function A333_elt()


	if A333_elt_switch_pos ~= 0 then
		elt_annun = 1
	elseif A333_elt_switch_pos == 0 then
		if elt_trigger == 0 then
			elt_annun = 0
		elseif elt_trigger == 1 then
			elt_annun = 1
		end
	end

	if simDR_axial_g_load > 2.5 then
		elt_trigger = 1
	end

	A333_elt_annun = elt_annun

end

-- ADIRS


function A333_ADIRS()

	--[[ IRS modes --- OFF, STBY, NAV, ATT

	BUTTONS TURN ON/OFF computers. MODE is set via knob position. MODE NAV/ATT unfail AHARS after 60 seconds
	MODE OFF/STBY fail AHARS. NEED TO LET SIM FAILURE STILL OPERATE, so setting fail dataref has to be done
	only once using trigger dataref set via the switch and reset via the function.
	IR3 will be ignored. TODO -- find a way to cancel / reset the timers if they are interrupted

	]]--


	A333_IR1_initialize = function()
		simDR_ahars1_fail_state = 0
		A333_ahars1_starting = 0
	end

	A333_IR2_initialize = function()
		simDR_ahars2_fail_state = 0
		A333_ahars2_starting = 0
	end

	if A333DR_adirs_ir1_mode == 0 then
		IR1_mode = 0                                -- OFF
	elseif A333DR_adirs_ir1_mode == 1 then
		if A333DR_adirs_ir1_knob == 0 then
			IR1_mode = 1                            -- STBY
		elseif A333DR_adirs_ir1_knob == 1 then
			IR1_mode = 2                            -- NAV
		elseif A333DR_adirs_ir1_knob == 1 then
			IR1_mode = 3                            -- ATT
		end
	end

	if A333DR_adirs_ir2_mode == 0 then
		IR2_mode = 0
	elseif A333DR_adirs_ir2_mode == 1 then
		if A333DR_adirs_ir2_knob == 0 then
			IR2_mode = 1
		elseif A333DR_adirs_ir2_knob == 1 then
			IR2_mode = 2
		elseif A333DR_adirs_ir2_knob == 1 then
			IR2_mode = 3
		end
	end

	if A333DR_ir1_trigger == 1 then
		if IR1_mode >= 2 then
			A333_ahars1_starting = 1
			run_after_time(A333_IR1_initialize, 60.0)
		elseif IR1_mode <= 1 then
			simDR_ahars1_fail_state = 6
		end
		A333DR_ir1_trigger = 0
	elseif A333DR_ir1_trigger == 2 then
		simDR_ahars1_fail_state = 6
		if is_timer_scheduled(A333_IR1_initialize) then
			stop_timer(A333_IR1_initialize)
		end
		A333DR_ir1_trigger = 0
	elseif A333DR_ir1_trigger == 0 then
	end

	if A333DR_ir2_trigger == 1 then
		if IR2_mode >= 2 then
			A333_ahars2_starting = 1
			run_after_time(A333_IR2_initialize, 60.0)
		elseif IR2_mode <= 1 then
			simDR_ahars2_fail_state = 6
		end
		A333DR_ir2_trigger = 0
	elseif A333DR_ir2_trigger == 2 then
		simDR_ahars2_fail_state = 6
		if is_timer_scheduled(A333_IR2_initialize) then
			stop_timer(A333_IR2_initialize)
		end
		A333DR_ir2_trigger = 0
	elseif A333DR_ir2_trigger == 0 then
	end


end

function A333_anti_skid_auto_off()

	if simDR_nosewheel_steering == 0 then
		simDR_auto_brake_level = 1
	end

end


function A333_control_surface_depress_droop()

	local inbd_aileron_droop_target = 0
	local otbd_aileron_droop_target = 0
	local left_hstab_droop_target = 0
	local right_hstab_droop_target = 0

	local green_blue = simDR_green_hydraulic_pressure + simDR_blue_hydraulic_pressure
	local green_yellow = simDR_green_hydraulic_pressure + simDR_yellow_hydraulic_pressure

	local airspeed_factor2 = A333_rescale(0, 1, 45, 0, simDR_equiv_airspeed)
	local inbd_aileron_fac = A333_rescale(0, 1, 750, 0, green_blue)
	local otbd_aileron_fac = A333_rescale(0, 1, 750, 0, green_yellow)
	local left_hstab_fac = A333_rescale(0, 1, 900, 0, green_blue)
	local right_hstab_fac = A333_rescale(0, 1, 900, 0, green_yellow)

	inbd_aileron_droop_target = airspeed_factor2 * inbd_aileron_fac
	otbd_aileron_droop_target = airspeed_factor2 * otbd_aileron_fac
	left_hstab_droop_target = airspeed_factor2 * left_hstab_fac
	right_hstab_droop_target = airspeed_factor2 * right_hstab_fac

	A333_inboard_ail_droop_rat = A333_set_animation_position(A333_inboard_ail_droop_rat, inbd_aileron_droop_target, 0, 1, 0.5)
	A333_outboard_ail_droop_rat = A333_set_animation_position(A333_outboard_ail_droop_rat, otbd_aileron_droop_target, 0, 1, 0.5)
	A333_left_hstab_droop_rat = A333_set_animation_position(A333_left_hstab_droop_rat, left_hstab_droop_target, 0, 1, 0.5)
	A333_right_hstab_droop_rat = A333_set_animation_position(A333_right_hstab_droop_rat, right_hstab_droop_target, 0, 1, 0.5)

end



--[[
function A333_FADEC_limits_set()

	-- FLEX CAN ONLY BE INITIATED ON THE GROUND, ONCE YOU PULL ANY ENGINE OUT OF FLEX DETENT, YOU WILL RETURN TO MCT

    -- see A333_flex_mode()


	if simDR_gear_on_ground == 1 then
		takeoff_mode = 1
		if simDR_flex_temp > simDR_OAT then
			flex_mode = 1
		else flex_mode = 0
		end
	elseif simDR_gear_on_ground == 0 then
		if simDR_fadec_power_mode_eng1 <= 2 or simDR_fadec_power_mode_eng2 <= 2 then
			takeoff_mode = 0
		end

		--[=[ The below logic corrected in the "A333_flex_mode()" function to match the
		      FCOM as follows...
		         After takeoff :
                 The pilot can change from FLX to MCT by moving the thrust lever to TOGA or CL, then back to MCT.
                 After that, he cannot use the FLX rating.
        --]=]
		if simDR_fadec_power_mode_eng1 ~= 2 or simDR_fadec_power_mode_eng2 ~= 2 then
			flex_mode = 0
		end

	end

    --[=[ takeoff_mode was replaced with different logic, see "A333_engine_limits()"
	if takeoff_mode == 1 then
		simDR_fadec_engine_limits_toga = A333DR_epr_limit_to
	elseif takeoff_mode == 0 then
		simDR_fadec_engine_limits_toga = A333DR_epr_limit_ga
	end

	if flex_mode == 0 then
		simDR_fadec_engine_limits_mct_flx = A333DR_epr_limit_mc
	elseif flex_mode == 1 then
		simDR_fadec_engine_limits_mct_flx = A333DR_epr_limit_flex
	end

	simDR_fadec_engine_limits_clb = A333DR_epr_limit_mc * 0.97
	--]=]


    --[=[     See A333_starter_torque()
	local starter_temp_multiplier = A333_rescale(-40, 1.18, 15, 1, simDR_external_temp)
	local starter_baro_multiplier = A333_rescale(29.92, 1, 32, 1.05, simDR_sealevel_baro)       -do not use simDR_sealevel_baro (replaced)

	simDR_starter_torque = STARTER_TORQUE_PLN_VALUE * starter_temp_multiplier * starter_baro_multiplier
    --]=]


end
--]]


function A333_flex_mode()

    -- Set the flex_mode flag prior to takeoff
    if A333_flight_phase <= 4
        and
        flex_mode_is_available
        and
        ((simDR_flex_temp[0] >= 15 and simDR_flex_temp[0] <= 70)
        or
        (simDR_flex_temp[1] >= 15 and simDR_flex_temp[1] <= 70))
    then
        flex_mode = 1


    -- After takeoff, Lockout FLX Mode if either Thrust Lever is moved to CL or TOGA
    elseif A333_flight_phase > 4 then
        if flex_mode == 1
            and
            ((simDR_fadec_power_mode_eng1 == 1 or simDR_fadec_power_mode_eng1 == 3)
            or
            (simDR_fadec_power_mode_eng2 == 1 or simDR_fadec_power_mode_eng2 == 3))
        then
            flex_mode_is_available = false
            flex_mode = 0
        end
    end

    -- Reset flex available flag after landing and MCDU init
    if not flex_mode_is_available
        and
        A333_flight_phase >= 8    -- Touchdown
        and
        (simDR_flex_temp[0] == 0 or simDR_flex_temp[1] == 0)    -- MCDU init
    then
        flex_mode_is_available = true
    end

    return flex_mode

end





function A333_engine_limits()

    if A333_flight_phase <= 4 then        -- Takeoff (on ground)
        simDR_fadec_engine_limits_toga = A333DR_epr_limit_to
    elseif A333_flight_phase == 7 then    -- Go-Around (Alt 0-800 ft)
        simDR_fadec_engine_limits_toga = A333DR_epr_limit_ga
    end

    if flex_mode == 0 then
        simDR_fadec_engine_limits_mct_flx = A333DR_epr_limit_mc
    elseif flex_mode == 1 then
        simDR_fadec_engine_limits_mct_flx = A333DR_epr_limit_flex
    end

    simDR_fadec_engine_limits_clb = A333DR_epr_limit_mc * 0.97

end





function A333_starter_torque()

    local starter_temp_multiplier = A333_rescale(-40, 1.18, 15, 1, simDR_external_temp)

    local sealevel_baro_inHg = simDR_sealevel_qnh_pas * 0.0002952998                    -- 1 Pa = 0.0002952998 inHg     (simDR_sealevel_baro replaced)
    local starter_baro_multiplier = A333_rescale(29.92, 1, 32, 1.05, sealevel_baro_inHg)

    simDR_starter_torque = STARTER_TORQUE_PLN_VALUE * starter_temp_multiplier * starter_baro_multiplier

end





local idle_flasher = 0
local idle_timer = 0

function A333_ECAM()

	local flasher = 0
	local time_factor = 0
	local sim_time_factor = math.fmod(simDR_flight_time, 0.6)

	if sim_time_factor >= 0 and sim_time_factor <= 0.3 then
		flasher = 1
	end


----

	if simDR_flap_deg <= 4 then
		simDR_flap_retract_time = 106
		simDR_flap_extend_time = 106
	elseif simDR_flap_deg > 4 then
		simDR_flap_retract_time = 16
		simDR_flap_extend_time = 16
	end

----
--[[
	if simDR_starter_mode == 0 then
		if simDR_eng1_N2 > 5 then
			A333_ECAM_engine1_display = 1
		elseif simDR_eng1_N2 <= 5 then
			A333_ECAM_engine1_display = 0
		end
		if simDR_eng2_N2 > 5 then
			A333_ECAM_engine2_display = 1
		elseif simDR_eng2_N2 <= 5 then
			A333_ECAM_engine2_display = 0
		end
	elseif simDR_starter_mode ~= 0 then
		A333_ECAM_engine1_display = 1
		A333_ECAM_engine2_display = 1
	end
--]]

    if simDR_starter_mode == 0 then
        A333_ECAM_engine1_display = bool2num[simDR_eng1_N2 > 5]
        A333_ECAM_engine2_display = bool2num[simDR_eng2_N2 > 5]
    else
        A333_ECAM_engine1_display = 1
        A333_ECAM_engine2_display = 1
    end




	if simDR_flap_handle_request == 0 then
		if simDR_flap_deg == 0 then
			A333_ECAM_flap_display = 0
		elseif simDR_flap_deg ~= 0 then
			A333_ECAM_flap_display = 1
		end
		if simDR_slat_ratio == 0 then
			A333_ECAM_slat_display = 0
		elseif simDR_slat_ratio ~= 0 then
			A333_ECAM_slat_display = 1
		end
	elseif simDR_flap_handle_request ~= 0 then
		A333_ECAM_flap_display = 1
		A333_ECAM_slat_display = 1
	end

	if math.abs(simDR_flap_handle_request) < 0.1 then
		A333_ECAM_flap_lever_sel = 0
	elseif math.abs(simDR_flap_handle_request - 0.25) < 0.1 then
		A333_ECAM_flap_lever_sel = simDR_flap_config
	elseif math.abs(simDR_flap_handle_request - 0.5) < 0.1 then
		A333_ECAM_flap_lever_sel = 3
	elseif math.abs(simDR_flap_handle_request - 0.75) < 0.1 then
		A333_ECAM_flap_lever_sel = 4
	elseif math.abs(simDR_flap_handle_request - 1) < 0.1 then
		A333_ECAM_flap_lever_sel = 5
	end


	if simDR_slats_disagree == 0 and simDR_flaps_disagree == 0 then				-- THIS IS THE SCRIPT THAT DETERMINES IF THE FLAPS AND SLATS BOTH AGREE WITH THE DESIRED CONF
		A333_ECAM_conf_req_ind = 1
	elseif simDR_slats_disagree == 1 or simDR_flaps_disagree == 1 then
		A333_ECAM_conf_req_ind = 0
	end


	if simDR_green_hydraulic_pressure < 30 and simDR_blue_hydraulic_pressure < 30 then
		A333_ECAM_slat_status = 1
	elseif simDR_green_hydraulic_pressure >= 30 or simDR_blue_hydraulic_pressure >= 30 then
		if simDR_slat_failure ~= 6 then
			A333_ECAM_slat_status = 0
		elseif simDR_slat_failure == 6 then
			A333_ECAM_slat_status = 1
		end
	end

	if simDR_green_hydraulic_pressure < 30 and simDR_yellow_hydraulic_pressure < 30 then
		A333_ECAM_flap_status = 1
	elseif simDR_green_hydraulic_pressure >= 30 or simDR_blue_hydraulic_pressure >= 30 then
		if simDR_flap_act_failure ~= 6 and
			simDR_flap1_L_failure ~= 6 and
			simDR_flap1_R_failure ~= 6 and
			simDR_flap2_L_failure ~= 6 and
			simDR_flap2_R_failure ~= 6 then
			A333_ECAM_flap_status = 0
		elseif simDR_flap_act_failure == 6 or
			simDR_flap1_L_failure == 6 or
			simDR_flap1_R_failure == 6 or
			simDR_flap2_L_failure == 6 or
			simDR_flap2_R_failure == 6 then
			A333_ECAM_flap_status = 1
		end
	end

	if simDR_gear_on_ground == 1 then
		if simDR_engine1_starting == 1 then
			A333_EGT1_limit = 700
		elseif simDR_engine1_starting == 0 then
			A333_EGT1_limit = 900
		end
	elseif simDR_gear_on_ground == 0 then
		A333_EGT1_limit = 900
	end

	if simDR_gear_on_ground == 1 then
		if simDR_engine2_starting == 1 then
			A333_EGT2_limit = 700
		elseif simDR_engine2_starting == 0 then
			A333_EGT2_limit = 900
		end
	elseif simDR_gear_on_ground == 0 then
		A333_EGT2_limit = 900
	end

	if A333_ECAM_engine1_display == 1 then
		if simDR_fadec_power_mode_eng1 ~= 3 then
			if simDR_engine1_reverse < 0.001 then
				A333_EGT1_limit_vis = 1
			elseif simDR_engine1_reverse >= 0.001 then
				A333_EGT1_limit_vis = 0
			end
		elseif simDR_fadec_power_mode_eng1 == 3 then
			A333_EGT1_limit_vis = 0
		end
	elseif A333_ECAM_engine1_display == 0 then
		A333_EGT1_limit_vis = 0
	end

	if A333_ECAM_engine2_display == 1 then
		if simDR_fadec_power_mode_eng2 ~= 3 then
			if simDR_engine2_reverse < 0.001 then
				A333_EGT2_limit_vis = 1
			elseif simDR_engine2_reverse >= 0.001 then
				A333_EGT2_limit_vis = 0
			end
		elseif simDR_fadec_power_mode_eng2 == 3 then
			A333_EGT2_limit_vis = 0
		end
	elseif A333_ECAM_engine2_display == 0 then
		A333_EGT2_limit_vis = 0
	end

	if simDR_engine1_reverse < 0.01 and simDR_engine2_reverse < 0.01 then
		if A333_ECAM_engine1_display == 1 or A333_ECAM_engine2_display == 1 then
			A333_ECAM_engine_display = 1
		elseif A333_ECAM_engine1_display == 0 and A333_ECAM_engine2_display == 0 then
			A333_ECAM_engine_display = 0
		end
	elseif simDR_engine1_reverse >= 0.01 or simDR_engine2_reverse >= 0.01 then
		A333_ECAM_engine_display = 2
	end

	if simDR_eng1_N1 > 22.6 and simDR_eng2_N1 > 22.6 then
		if simDR_throttle1_used < 0.01 and simDR_throttle2_used < 0.01 then
			A333_ECAM_idle_status = 1
		elseif simDR_throttle1_used >= 0.01 or simDR_throttle2_used >= 0.01 then
			A333_ECAM_idle_status = 0
		end
	elseif simDR_eng1_N1 <= 22.6 or simDR_eng2_N1 <= 22.6 then
		A333_ECAM_idle_status = 0
	end

	if A333_ECAM_idle_status == 1 then
		idle_timer = idle_timer + SIM_PERIOD
	elseif A333_ECAM_idle_status == 0 then
		idle_timer = 0
	end

	if idle_timer <= 10 then
		time_factor = 1
	elseif idle_timer > 10 then
		time_factor = 0
	end

	idle_flasher = A333_set_animation_position(idle_flasher, flasher, 0, 1, 10)

	A333_ECAM_idle_flasher = idle_flasher * time_factor

	if simDR_starter_mode == 0 then
		A333_ECAM_IGN_mode = 0
	elseif simDR_starter_mode ~= 0 then
		A333_ECAM_IGN_mode = 1
	end

	A333_ECAM_fuel_totalkg_min = (simDR_fuel_flow_eng1 + simDR_fuel_flow_eng2) * 60

	A333_ECAM_slat_alock_flasher = A333_set_animation_position(A333_ECAM_slat_alock_flasher, flasher, 0, 1, 10)
	A333_ECAM_flap_relief_flasher = A333_set_animation_position(A333_ECAM_flap_relief_flasher, flasher, 0, 1, 10)


end

---- ECAM HYDRAULICS PAGE

local green_hyd_pressure_store = 0
local yellow_hyd_pressure_store = 0
local blue_hyd_pressure_store = 0
local RAT_RPM_target = 0

function A333_ecam_page_HYD()

	RAT_RPM_target = A333_rescale(0, 0, 330, 6500, simDR_airspeed)

	if simDR_rat_on == 0 then
		A333_ECAM_hyd_rat_rpm = 0
	elseif simDR_rat_on == 1 then
		A333_ECAM_hyd_rat_rpm = A333_set_animation_position(A333_ECAM_hyd_rat_rpm, RAT_RPM_target, 0, 6500, 0.2)
	end

	if simDR_green_hydraulic_pressure >= 1750 then
		A333_ECAM_hyd_green_status = 1
	elseif simDR_green_hydraulic_pressure < 1750 and simDR_green_hydraulic_pressure > 1450 then
		if simDR_green_hydraulic_pressure >= green_hyd_pressure_store then
			A333_ECAM_hyd_green_status = 1
		elseif simDR_green_hydraulic_pressure < green_hyd_pressure_store then
			A333_ECAM_hyd_green_status = 0
		end
	elseif simDR_green_hydraulic_pressure <= 1450 then
		A333_ECAM_hyd_green_status = 0
	end

	if simDR_yellow_hydraulic_pressure >= 1750 then
		A333_ECAM_hyd_yellow_status = 1
	elseif simDR_yellow_hydraulic_pressure < 1750 and simDR_yellow_hydraulic_pressure > 1450 then
		if simDR_yellow_hydraulic_pressure >= yellow_hyd_pressure_store then
			A333_ECAM_hyd_yellow_status = 1
		elseif simDR_yellow_hydraulic_pressure < yellow_hyd_pressure_store then
			A333_ECAM_hyd_yellow_status = 0
		end
	elseif simDR_yellow_hydraulic_pressure <= 1450 then
		A333_ECAM_hyd_yellow_status = 0
	end

	if simDR_blue_hydraulic_pressure >= 1750 then
		A333_ECAM_hyd_blue_status = 1
	elseif simDR_blue_hydraulic_pressure < 1750 and simDR_blue_hydraulic_pressure > 1450 then
		if simDR_blue_hydraulic_pressure >= blue_hyd_pressure_store then
			A333_ECAM_hyd_blue_status = 1
		elseif simDR_blue_hydraulic_pressure < blue_hyd_pressure_store then
			A333_ECAM_hyd_blue_status = 0
		end
	elseif simDR_blue_hydraulic_pressure <= 1450 then
		A333_ECAM_hyd_blue_status = 0
	end

	green_hyd_pressure_store = simDR_green_hydraulic_pressure
	yellow_hyd_pressure_store = simDR_yellow_hydraulic_pressure
	blue_hyd_pressure_store = simDR_blue_hydraulic_pressure

	--

	if A333_eng1_hyd_fire_valve_pos == 1 then
		A333_ECAM_hyd_green_eng1_fire_valve = 0
		A333_ECAM_hyd_blue_eng1_fire_valve = 0
	elseif A333_eng1_hyd_fire_valve_pos == 0 then
		if simDR_green_fluid_ratio < 0.05 then
			A333_ECAM_hyd_green_eng1_fire_valve = 1
		elseif simDR_green_fluid_ratio >= 0.05 then
			A333_ECAM_hyd_green_eng1_fire_valve = 2
		end
		if simDR_blue_fluid_ratio < 0.05 then
			A333_ECAM_hyd_blue_eng1_fire_valve = 1
		elseif simDR_blue_fluid_ratio >= 0.05 then
			A333_ECAM_hyd_blue_eng1_fire_valve = 2
		end
	end

	if A333_eng2_hyd_fire_valve_pos == 1 then
		A333_ECAM_hyd_yellow_eng2_fire_valve = 0
		A333_ECAM_hyd_green_eng2_fire_valve = 0
	elseif A333_eng2_hyd_fire_valve_pos == 0 then
		if simDR_yellow_fluid_ratio < 0.05 then
			A333_ECAM_hyd_yellow_eng2_fire_valve = 1
		elseif simDR_yellow_fluid_ratio >= 0.05 then
			A333_ECAM_hyd_yellow_eng2_fire_valve = 2
		end
		if simDR_green_fluid_ratio < 0.05 then
			A333_ECAM_hyd_green_eng2_fire_valve = 1
		elseif simDR_green_fluid_ratio >= 0.05 then
			A333_ECAM_hyd_green_eng2_fire_valve = 2
		end
	end

	if simDR_green_eng1_pump_on == 1 then
		if simDR_engine1_hyd_pump_fault ~= 6 then
			if simDR_green_hydraulic_pressure > 1450 then
				A333_ECAM_hyd_green_eng1_pump = 1
			elseif simDR_green_hydraulic_pressure <= 1450 then
				A333_ECAM_hyd_green_eng1_pump = 2
			end
		elseif simDR_engine1_hyd_pump_fault == 6 then
			A333_ECAM_hyd_green_eng1_pump = 2
		end
	elseif simDR_green_eng1_pump_on == 0 then
		A333_ECAM_hyd_green_eng1_pump = 0
	end

	if simDR_blue_eng1_pump_on == 1 then
		if simDR_engine1_hyd_pump_fault ~= 6 then
			if simDR_blue_hydraulic_pressure > 1450 then
				A333_ECAM_hyd_blue_eng1_pump = 1
			elseif simDR_blue_hydraulic_pressure <= 1450 then
				A333_ECAM_hyd_blue_eng1_pump = 2
			end
		elseif simDR_engine1_hyd_pump_fault == 6 then
			A333_ECAM_hyd_blue_eng1_pump = 2
		end
	elseif simDR_blue_eng1_pump_on == 0 then
		A333_ECAM_hyd_blue_eng1_pump = 0
	end

	if simDR_yellow_eng2_pump_on == 1 then
		if simDR_engine2_hyd_pump_fault ~= 6 then
			if simDR_yellow_hydraulic_pressure > 1450 then
				A333_ECAM_hyd_yellow_eng2_pump = 1
			elseif simDR_yellow_hydraulic_pressure <= 1450 then
				A333_ECAM_hyd_yellow_eng2_pump = 2
			end
		elseif simDR_engine2_hyd_pump_fault == 6 then
			A333_ECAM_hyd_yellow_eng2_pump = 2
		end
	elseif simDR_yellow_eng2_pump_on == 0 then
		A333_ECAM_hyd_yellow_eng2_pump = 0
	end

	if simDR_green_eng2_pump_on == 1 then
		if simDR_engine2_hyd_pump_fault ~= 6 then
			if simDR_green_hydraulic_pressure > 1450 then
				A333_ECAM_hyd_green_eng2_pump = 1
			elseif simDR_green_hydraulic_pressure <= 1450 then
				A333_ECAM_hyd_green_eng2_pump = 2
			end
		elseif simDR_engine2_hyd_pump_fault == 6 then
			A333_ECAM_hyd_green_eng2_pump = 2
		end
	elseif simDR_green_eng2_pump_on == 0 then
		A333_ECAM_hyd_green_eng2_pump = 0
	end

	if simDR_bus1_power >= 20 then
		A333_ECAM_hyd_elec_green_status = 0
	elseif simDR_bus1_power < 20 then
		A333_ECAM_hyd_elec_green_status = 1
	end

	if simDR_bus1_power >= 20 or simDR_bus2_power >= 20 then
		A333_ECAM_hyd_elec_blue_status = 0
	elseif simDR_bus1_power < 20 and simDR_bus2_power < 20 then
		A333_ECAM_hyd_elec_blue_status = 1
	end

	if simDR_bus2_power >= 20 then
		A333_ECAM_hyd_elec_yellow_status = 0
	elseif simDR_bus2_power < 20 then
		A333_ECAM_hyd_elec_yellow_status = 1
	end

	if simDR_green_elec_pump_on == 0 then
		if A333_elec_pump_green_tog_pos == 0 then
			A333_ECAM_hyd_elec_green_arrow = 0
		elseif A333_elec_pump_green_tog_pos >= 1 then
			A333_ECAM_hyd_elec_green_arrow = 1
		end
	elseif simDR_green_elec_pump_on == 1 then
		if simDR_green_hydraulic_pressure >= 1450 then
			A333_ECAM_hyd_elec_green_arrow = 2
		elseif simDR_green_hydraulic_pressure < 1450 then
			A333_ECAM_hyd_elec_green_arrow = 3
		end
	end

	if simDR_blue_elec_pump_on == 0 then
		if A333_elec_pump_blue_tog_pos == 0 then
			A333_ECAM_hyd_elec_blue_arrow = 0
		elseif A333_elec_pump_blue_tog_pos >= 1 then
			A333_ECAM_hyd_elec_blue_arrow = 1
		end
	elseif simDR_blue_elec_pump_on == 1 then
		if simDR_blue_hydraulic_pressure >= 1450 then
			A333_ECAM_hyd_elec_blue_arrow = 2
		elseif simDR_blue_hydraulic_pressure < 1450 then
			A333_ECAM_hyd_elec_blue_arrow = 3
		end
	end

	if simDR_yellow_elec_pump_on == 0 then
		if A333_elec_pump_yellow_tog_pos == 0 then
			A333_ECAM_hyd_elec_yellow_arrow = 0
		elseif A333_elec_pump_yellow_tog_pos >= 1 then
			A333_ECAM_hyd_elec_yellow_arrow = 1
		end
	elseif simDR_yellow_elec_pump_on == 1 then
		if simDR_yellow_hydraulic_pressure >= 1450 then
			A333_ECAM_hyd_elec_yellow_arrow = 2
		elseif simDR_yellow_hydraulic_pressure < 1450 then
			A333_ECAM_hyd_elec_yellow_arrow = 3
		end
	end

	if simDR_rat_on == 0 then
		A333_ECAM_hyd_rat_arrow_enum = 0
		A333_ECAM_hyd_rat_status = 1
	elseif simDR_rat_on == 1 then
		if A333_ECAM_hyd_rat_rpm >= 3000 then
			if simDR_green_fluid_ratio >= 0.05 then
				A333_ECAM_hyd_rat_arrow_enum = 1
				A333_ECAM_hyd_rat_status = 1
			elseif simDR_green_fluid_ratio < 0.05 then
				A333_ECAM_hyd_rat_arrow_enum = 2
				A333_ECAM_hyd_rat_status = 1
			end
		elseif A333_ECAM_hyd_rat_rpm < 3000 then
			A333_ECAM_hyd_rat_arrow_enum = 2
			A333_ECAM_hyd_rat_status = 0
		end
	end

	if A333_ECAM_hyd_green_eng1_pump == 1 then
		A333_ECAM_hyd_green1_line_fin = 1
	elseif A333_ECAM_hyd_green_eng1_pump ~= 1 then
		if A333_ECAM_hyd_elec_green_arrow == 2 then
			A333_ECAM_hyd_green1_line_fin = 1
		elseif A333_ECAM_hyd_elec_green_arrow ~= 2 then
			A333_ECAM_hyd_green1_line_fin = 0
		end
	end

	if A333_ECAM_hyd_blue_eng1_pump == 1 then
		A333_ECAM_hyd_blue_line_fin = 1
	elseif A333_ECAM_hyd_blue_eng1_pump ~= 1 then
		if A333_ECAM_hyd_elec_blue_arrow == 2 then
			A333_ECAM_hyd_blue_line_fin = 1
		elseif A333_ECAM_hyd_elec_blue_arrow ~= 2 then
			A333_ECAM_hyd_blue_line_fin = 0
		end
	end

	if A333_ECAM_hyd_yellow_eng2_pump == 1 then
		A333_ECAM_hyd_yellow_line_fin = 1
	elseif A333_ECAM_hyd_yellow_eng2_pump ~= 1 then
		if A333_ECAM_hyd_elec_yellow_arrow == 2 then
			A333_ECAM_hyd_yellow_line_fin = 1
		elseif A333_ECAM_hyd_elec_yellow_arrow ~= 2 then
			A333_ECAM_hyd_yellow_line_fin = 0
		end
	end

	if A333_ECAM_hyd_green_eng2_pump == 1 then
		A333_ECAM_hyd_green2_line_fin = 1
	elseif A333_ECAM_hyd_green_eng2_pump ~= 1 then
		if A333_ECAM_hyd_rat_arrow_enum == 1 then
			A333_ECAM_hyd_green2_line_fin = 1
		elseif A333_ECAM_hyd_rat_arrow_enum ~= 1 then
			A333_ECAM_hyd_green2_line_fin = 0
		end
	end

end

---- ECAM FLIGHT CONTROLS

function A333_ecam_page_FCTL()

	local otbd_aileron_max_up = -25 + (50 * A333_outboard_ail_droop_rat)
	local inbd_aileron_max_up = -25 + (50 * A333_inboard_ail_droop_rat)
	local left_elevator_max_up = -30 + (45 * A333_left_hstab_droop_rat)
	local right_elevator_max_up = -30 + (45 * A333_right_hstab_droop_rat)

	A333_outer_L_ail = A333_rescale(-25, otbd_aileron_max_up, 25, 25, simDR_outer_aileron_L)
	A333_outer_R_ail = A333_rescale(-25, otbd_aileron_max_up, 25, 25, simDR_outer_aileron_R)

	A333_inner_L_ail = A333_rescale(-25, inbd_aileron_max_up, 25, 25, simDR_inner_aileron_L)
	A333_inner_R_ail = A333_rescale(-25, inbd_aileron_max_up, 25, 25, simDR_inner_aileron_R)

	A333_L_elev = A333_rescale(-30, left_elevator_max_up, 15, 15, simDR_elevator_L)
	A333_R_elev = A333_rescale(-30, right_elevator_max_up, 15, 15, simDR_elevator_R)

	if simDR_yellow_hydraulic_pressure < 100 and simDR_green_hydraulic_pressure < 100 then
		A333_outer_L_ail_amber_status = 0
		A333_outer_R_ail_amber_status = 0
	elseif simDR_yellow_hydraulic_pressure >= 100 or simDR_green_hydraulic_pressure >= 100 then
		A333_outer_L_ail_amber_status = 1
		A333_outer_R_ail_amber_status = 1
	end

	if simDR_green_hydraulic_pressure < 100 and simDR_blue_hydraulic_pressure < 100 then
		A333_inner_L_ail_amber_status = 0
		A333_inner_R_ail_amber_status = 0
	elseif simDR_green_hydraulic_pressure >= 100 or simDR_blue_hydraulic_pressure >= 100 then
		A333_inner_L_ail_amber_status = 1
		A333_inner_R_ail_amber_status = 1
	end

	if simDR_green_hydraulic_pressure < 200 and simDR_blue_hydraulic_pressure < 200 then
		A333_L_elev_amber_status = 0
	elseif simDR_green_hydraulic_pressure >= 200 or simDR_blue_hydraulic_pressure >= 200 then
		A333_L_elev_amber_status = 1
	end

	if simDR_yellow_hydraulic_pressure < 200 and simDR_green_hydraulic_pressure < 200 then
		A333_R_elev_amber_status = 0
	elseif simDR_yellow_hydraulic_pressure >= 200 or simDR_green_hydraulic_pressure >= 200 then
		A333_R_elev_amber_status = 1
	end

	if simDR_green_hydraulic_pressure < 250 and simDR_blue_hydraulic_pressure < 250 and simDR_yellow_hydraulic_pressure < 250 then
		A333_rud_amber_status = 0
	elseif simDR_green_hydraulic_pressure >= 250 or simDR_blue_hydraulic_pressure >= 250 or simDR_yellow_hydraulic_pressure >= 250 then
		A333_rud_amber_status = 1
	end

	if simDR_blue_hydraulic_pressure < 225 and simDR_yellow_hydraulic_pressure < 225 then
		A333_pitch_amber_status = 0
	elseif simDR_blue_hydraulic_pressure >= 225 or simDR_yellow_hydraulic_pressure >= 225 then
		A333_pitch_amber_status = 1
	end

	if simDR_green_hydraulic_pressure > 100 then
		if simDR_spoiler1_L < 0.1 then
			A333_spoiler1_L_enum = 1
		elseif simDR_spoiler1_L > 0.1 then
			A333_spoiler1_L_enum = 2
		end
	elseif simDR_green_hydraulic_pressure <= 100 then
		A333_spoiler1_L_enum = 0
	end

	if simDR_blue_hydraulic_pressure > 100 then
		if simDR_spoiler2_L < 0.1 then
			A333_spoiler2_L_enum = 1
		elseif simDR_spoiler2_L > 0.1 then
			A333_spoiler2_L_enum = 2
		end
	elseif simDR_blue_hydraulic_pressure <= 100 then
		A333_spoiler2_L_enum = 0
	end

	if simDR_blue_hydraulic_pressure > 100 then
		if simDR_spoiler3_L < 0.1 then
			A333_spoiler3_L_enum = 1
		elseif simDR_spoiler3_L > 0.1 then
			A333_spoiler3_L_enum = 2
		end
	elseif simDR_blue_hydraulic_pressure <= 100 then
		A333_spoiler3_L_enum = 0
	end

	if simDR_green_hydraulic_pressure > 100 then
		if simDR_spoiler4_5_L < 0.1 then
			A333_spoiler4_L_enum = 1
			A333_spoiler5_L_enum = 1
		elseif simDR_spoiler4_5_L > 0.1 then
			A333_spoiler4_L_enum = 2
			A333_spoiler5_L_enum = 2
		end
	elseif simDR_green_hydraulic_pressure <= 100 then
		A333_spoiler4_L_enum = 0
		A333_spoiler5_L_enum = 0
	end

	if simDR_yellow_hydraulic_pressure > 100 then
		if simDR_spoiler6_L < 0.1 then
			A333_spoiler6_L_enum = 1
		elseif simDR_spoiler6_L > 0.1 then
			A333_spoiler6_L_enum = 2
		end
	elseif simDR_yellow_hydraulic_pressure <= 100 then
		A333_spoiler6_L_enum = 0
	end

	if simDR_green_hydraulic_pressure > 100 then
		if simDR_spoiler1_R < 0.1 then
			A333_spoiler1_R_enum = 1
		elseif simDR_spoiler1_R > 0.1 then
			A333_spoiler1_R_enum = 2
		end
	elseif simDR_green_hydraulic_pressure <= 100 then
		A333_spoiler1_R_enum = 0
	end

	if simDR_blue_hydraulic_pressure > 100 then
		if simDR_spoiler2_R < 0.1 then
			A333_spoiler2_R_enum = 1
		elseif simDR_spoiler2_R > 0.1 then
			A333_spoiler2_R_enum = 2
		end
	elseif simDR_blue_hydraulic_pressure <= 100 then
		A333_spoiler2_R_enum = 0
	end

	if simDR_blue_hydraulic_pressure > 100 then
		if simDR_spoiler3_R < 0.1 then
			A333_spoiler3_R_enum = 1
		elseif simDR_spoiler3_R > 0.1 then
			A333_spoiler3_R_enum = 2
		end
	elseif simDR_blue_hydraulic_pressure <= 100 then
		A333_spoiler3_R_enum = 0
	end

	if simDR_green_hydraulic_pressure > 100 then
		if simDR_spoiler4_5_R < 0.1 then
			A333_spoiler4_R_enum = 1
			A333_spoiler5_R_enum = 1
		elseif simDR_spoiler4_5_R > 0.1 then
			A333_spoiler4_R_enum = 2
			A333_spoiler5_R_enum = 2
		end
	elseif simDR_green_hydraulic_pressure <= 100 then
		A333_spoiler4_R_enum = 0
		A333_spoiler5_R_enum = 0
	end

	if simDR_yellow_hydraulic_pressure > 100 then
		if simDR_spoiler6_R < 0.1 then
			A333_spoiler6_R_enum = 1
		elseif simDR_spoiler6_R > 0.1 then
			A333_spoiler6_R_enum = 2
		end
	elseif simDR_yellow_hydraulic_pressure <= 100 then
		A333_spoiler6_R_enum = 0
	end

	A333_rudder_trim_ind = simDR_rudder_trim_ratio * A333_rescale(150, 1, 350, 0.114213198, simDR_capt_airspeed)

end


---- ECAM ELECTRICAL / APU PAGE

local apu_psi_target = 0
local volts_rand = 0
local hertz_rand = 0
local volts_rand2 = 0
local hertz_rand2 = 0
local volts_rand3 = 0
local hertz_rand3 = 0
local volts_rand4 = 0
local hertz_rand4 = 0
local calculated_EGT_lim = 0
local idg1_temp_target = 0
local idg2_temp_target = 0
local amp_target_apu = 0
local dc_ess_bat_feed = 0

function A333_ecam_page_APU()

	if simDR_APU_starter_switch >= 1 then
		A333_ECAM_APU_needles_vis = 1
	elseif simDR_APU_starter_switch == 0 then
		if simDR_APU_N1 > 5 then
			A333_ECAM_APU_needles_vis = 1
		elseif simDR_APU_N1 <= 5 then
			A333_ECAM_APU_needles_vis = 0
		end
	end

	if simDR_APU_starter_switch == 0 then
		A333_ECAM_APU_GEN_status = 1
	elseif simDR_APU_starter_switch == 1 then
		if simDR_APU_N1 < 95 then
			A333_ECAM_APU_GEN_status = 0
		elseif simDR_APU_N1 >= 95 then
			A333_ECAM_APU_GEN_status = 1
		end
	end

	apu_psi_target = A333_rescale(95, 0, 100, 42, simDR_APU_N1) - apu_psi_target * (simDR_APU_loss_ratio / 100)

	A333_ECAM_APU_PSI = A333_set_animation_position(A333_ECAM_APU_PSI, apu_psi_target, 0, 42, 0.2)

	if simDR_apu_door ~= 0 and simDR_apu_door ~= 1 then
		amp_target_apu = 8
	elseif simDR_apu_door == 0 then
		amp_target_apu = 0
	elseif simDR_apu_door == 1 then
		if simDR_apu_running == 1 then
			if simDR_APU_N1 < 56 then
				amp_target_apu = 55
			elseif simDR_APU_N1 >= 56 and simDR_APU_N1 < 95 then
				amp_target_apu = 4
			elseif simDR_APU_N1 >= 95 then
				amp_target_apu = 2
			end
		elseif simDR_apu_running == 0 then
			amp_target_apu = 2.5
		end
	end

	local volts_rand_target = math.random(-5, 5)
	local hertz_rand_target = math.random(-5, 5)

	local volts_rand2_target = math.random(-5, 5)
	local hertz_rand2_target = math.random(-5, 5)

	local volts_rand3_target = math.random(-5, 5)
	local hertz_rand3_target = math.random(-5, 5)

	local volts_rand4_target = math.random(-5, 5)
	local hertz_rand4_target = math.random(-5, 5)


	volts_rand = A333_set_animation_position(volts_rand, volts_rand_target, -5, 5, 0.4)
	hertz_rand = A333_set_animation_position(hertz_rand, hertz_rand_target, -5, 5, 0.4)

	volts_rand2 = A333_set_animation_position(volts_rand2, volts_rand2_target, -5, 5, 0.4)
	hertz_rand2 = A333_set_animation_position(hertz_rand2, hertz_rand2_target, -5, 5, 0.4)

	volts_rand3 = A333_set_animation_position(volts_rand3, volts_rand3_target, -5, 5, 0.4)
	hertz_rand3 = A333_set_animation_position(hertz_rand3, hertz_rand3_target, -5, 5, 0.4)

	volts_rand4 = A333_set_animation_position(volts_rand4, volts_rand4_target, -5, 5, 0.4)
	hertz_rand4 = A333_set_animation_position(hertz_rand4, hertz_rand4_target, -5, 5, 0.4)


	if simDR_APU_N1 < 95 then
		A333_ECAM_APU_volts = 0
		A333_ECAM_APU_hertz = 0
	elseif simDR_APU_N1 >= 95 then
		A333_ECAM_APU_volts = 115 + volts_rand
		A333_ECAM_APU_hertz = 400 + hertz_rand
	end

	if simDR_generator1_amps < 5 then
		A333_ECAM_gen1_volts = 0
		A333_ECAM_gen1_hertz = 0
	elseif simDR_generator1_amps >= 5 then
		A333_ECAM_gen1_volts = 115 + volts_rand2
		A333_ECAM_gen1_hertz = 400 + hertz_rand2
	end

	if simDR_generator2_amps < 5 then
		A333_ECAM_gen2_volts = 0
		A333_ECAM_gen2_hertz = 0
	elseif simDR_generator2_amps >= 5 then
		A333_ECAM_gen2_volts = 115 + volts_rand3
		A333_ECAM_gen2_hertz = 400 + hertz_rand3
	end

	if simDR_gpu_on == 0 then
		A333_ECAM_ext_a_volts = 0
		A333_ECAM_ext_a_hertz = 0
		A333_ECAM_ext_b_volts = 0
		A333_ECAM_ext_b_hertz = 0
	elseif simDR_gpu_on == 1 then
		A333_ECAM_ext_a_volts = 115 + volts_rand4
		A333_ECAM_ext_a_hertz = 400 + hertz_rand4
		A333_ECAM_ext_b_volts = 0
		A333_ECAM_ext_b_hertz = 0
	end


	if simDR_APU_N1 <= 10 then
		calculated_EGT_lim = 1250
	elseif simDR_APU_N1 > 10 and simDR_APU_N1 <= 15 then
		calculated_EGT_lim = A333_rescale(10, 1250, 15, 1020, simDR_APU_N1)
	elseif simDR_APU_N1 > 15 and simDR_APU_N1 <= 30 then
		calculated_EGT_lim = A333_rescale(15, 1020, 30, 950, simDR_APU_N1)
	elseif simDR_APU_N1 > 30 and simDR_APU_N1 <= 40 then
		calculated_EGT_lim = 950
	elseif simDR_APU_N1 > 40 and simDR_APU_N1 <= 70 then
		calculated_EGT_lim = A333_rescale(40, 950, 70, 720, simDR_APU_N1)
	elseif simDR_APU_N1 > 70 and simDR_APU_N1 <= 100 then
		calculated_EGT_lim = A333_rescale(70, 720, 100, 650, simDR_APU_N1)
	end

	if simDR_APU_EGT > calculated_EGT_lim then
		A333_ECAM_APU_egt_hot_status = 1
	elseif simDR_APU_EGT <= calculated_EGT_lim then
		A333_ECAM_APU_egt_hot_status = 0
	end


	if simDR_APU_starter_switch >= 1 then
		if simDR_apu_gen_amps >= 5 and simDR_apu_gen_on == 1 then
			if simDR_apu_fail ~= 6 and simDR_apu_fire ~= 6 then
				A333_ECAM_elec_apu_gen_status = 0
			elseif simDR_apu_fail == 6 or simDR_apu_fire == 6 then
				A333_ECAM_elec_apu_gen_status = 1
			end
		elseif simDR_apu_gen_amps < 5 or simDR_apu_gen_on == 0 then
			A333_ECAM_elec_apu_gen_status = 1
		end
	elseif simDR_APU_starter_switch == 0 then
		A333_ECAM_elec_apu_gen_status = 0
	end

	if simDR_gen_on[0] == 0 then
		A333_ECAM_elec_gen1_status = 0
	elseif simDR_gen_on[0] == 1 then
		if simDR_eng1_N2 >= 57 and simDR_gen1_fail ~= 6 then
			A333_ECAM_elec_gen1_status = 1
		elseif simDR_eng1_N2 < 57 or simDR_gen1_fail == 6 then
			A333_ECAM_elec_gen1_status = 0
		end
	end

	if simDR_gen_on[1] == 0 then
		A333_ECAM_elec_gen2_status = 0
	elseif simDR_gen_on[1] == 1 then
		if simDR_eng2_N2 >= 57 and simDR_gen2_fail ~= 6 then
			A333_ECAM_elec_gen2_status = 1
		elseif simDR_eng2_N2 < 57 or simDR_gen2_fail == 6 then
			A333_ECAM_elec_gen2_status = 0
		end
	end


	if simDR_gen_on[0] == 0 then
		idg1_temp_target = simDR_TAT + ( 0.05 * (simDR_EGT[0] - simDR_TAT))
	elseif simDR_gen_on[0] == 1 then
		if simDR_gen1_fail ~=6 then
			idg1_temp_target = simDR_TAT + (0.05 * (simDR_EGT[0] - simDR_TAT) + (simDR_generator1_amps / 333) * 150)
		elseif simDR_gen1_fail == 6 then
			idg1_temp_target = simDR_TAT + (0.05 * (simDR_EGT[0] - simDR_TAT))
		end
	end


	if simDR_gen_on[1] == 0 then
		idg2_temp_target = simDR_TAT + ( 0.05 * (simDR_EGT[1] - simDR_TAT))
	elseif simDR_gen_on[1] == 1 then
		if simDR_gen2_fail ~=6 then
			idg2_temp_target = simDR_TAT + (0.05 * (simDR_EGT[1] - simDR_TAT) + (simDR_generator2_amps / 333) * 150)
		elseif simDR_gen2_fail == 6 then
			idg2_temp_target = simDR_TAT + (0.05 * (simDR_EGT[1] - simDR_TAT))
		end
	end

	A333_ECAM_idg1_temp = A333_set_animation_position(A333_ECAM_idg1_temp, idg1_temp_target, -40, 250, 0.025)
	A333_ECAM_idg2_temp = A333_set_animation_position(A333_ECAM_idg2_temp, idg2_temp_target, -40, 250, 0.025)

	if simDR_cross_tie == 1 then
		if simDR_bus1_fail ~= 6 and simDR_bus2_fail ~= 6 then

			if simDR_bus1_power >= 110 or simDR_bus2_power >= 110 then
				A333_ECAM_crossbar1_line = 1
				A333_ECAM_crossbar2_line = 1
				A333_ECAM_crossbar3_line = 1
			elseif simDR_bus1_power < 110 and simDR_bus2_power < 110 then
				A333_ECAM_crossbar1_line = 0
				A333_ECAM_crossbar2_line = 0
				A333_ECAM_crossbar3_line = 0
			end

		elseif simDR_bus1_fail == 6 and simDR_bus2_fail ~= 6 then

			if simDR_apu_gen_amps >= 2.5 and simDR_apu_gen_on == 1 then
				A333_ECAM_crossbar1_line = 0
				A333_ECAM_crossbar2_line = 1
				A333_ECAM_crossbar3_line = 1
			elseif simDR_apu_gen_amps < 2.5 or simDR_apu_gen_on == 0 then
				if simDR_gpu_on == 1 and simDR_gpu_amps >= 2.5 then
					A333_ECAM_crossbar1_line = 0
					A333_ECAM_crossbar2_line = 0
					A333_ECAM_crossbar3_line = 1
				elseif simDR_gpu_on == 0 and simDR_gpu_amps < 2.5 then
					A333_ECAM_crossbar1_line = 0
					A333_ECAM_crossbar2_line = 0
					A333_ECAM_crossbar3_line = 0
				end
			end

		elseif simDR_bus1_fail ~= 6 and simDR_bus2_fail == 6 then

			if simDR_apu_gen_amps >= 2.5 and simDR_apu_gen_on == 1 and simDR_gpu_on == 0 then
				A333_ECAM_crossbar1_line = 1
				A333_ECAM_crossbar2_line = 0
				A333_ECAM_crossbar3_line = 0
			elseif simDR_gpu_on == 1 and simDR_gpu_amps >= 2.5 then
				A333_ECAM_crossbar1_line = 1
				A333_ECAM_crossbar2_line = 1
				A333_ECAM_crossbar3_line = 0
			elseif simDR_apu_gen_amps < 2.5 or simDR_apu_gen_on == 0 and simDR_gpu_on == 0 then
				A333_ECAM_crossbar1_line = 0
				A333_ECAM_crossbar2_line = 0
				A333_ECAM_crossbar3_line = 0
			end

		end

	elseif simDR_cross_tie == 0 then

		if simDR_bus1_fail ~= 6 then

			if simDR_apu_gen_amps >= 2.5 and simDR_apu_gen_on == 1 and simDR_gpu_on == 0 then
				A333_ECAM_crossbar1_line = 1
				A333_ECAM_crossbar2_line = 0
				A333_ECAM_crossbar3_line = 0
			elseif simDR_gpu_on == 1 and simDR_gpu_amps >= 2.5 then
				A333_ECAM_crossbar1_line = 1
				A333_ECAM_crossbar2_line = 1
				A333_ECAM_crossbar3_line = 0
			elseif simDR_apu_gen_amps < 2.5 or simDR_apu_gen_on == 0 and simDR_gpu_on == 0 then
				A333_ECAM_crossbar1_line = 0
				A333_ECAM_crossbar2_line = 0
				A333_ECAM_crossbar3_line = 0
			end

		elseif simDR_bus1_fail == 6 then

			A333_ECAM_crossbar1_line = 0
			A333_ECAM_crossbar2_line = 0
			A333_ECAM_crossbar3_line = 0

		end

	end

	-- APU line

	if simDR_bus1_fail ~= 6 then

		if simDR_apu_gen_amps >= 2.5 and simDR_apu_gen_on == 1 then
			if simDR_bus1_power >= 110 or simDR_bus2_power >= 110 then
				A333_ECAM_apu_gen_line = 1
			elseif simDR_bus1_power < 110 and simDR_bus2_power < 110 then
				A333_ECAM_apu_gen_line = 0
			end
		elseif simDR_apu_gen_amps < 2.5 or simDR_apu_gen_on == 0 then
			A333_ECAM_apu_gen_line = 0
		end

	elseif simDR_bus1_fail == 6 then

		if simDR_cross_tie == 0 then
			A333_ECAM_apu_gen_line = 0
		elseif simDR_cross_tie == 1 then
			if simDR_apu_gen_amps >= 2.5 and simDR_apu_gen_on == 1 then
				A333_ECAM_apu_gen_line = 1
			elseif simDR_apu_gen_amps < 2.5 or simDR_apu_gen_on == 0 then
				A333_ECAM_apu_gen_line = 0
			end
		end

	end

	-- GPU line

	if simDR_bus1_fail ~= 6 then

		if simDR_gpu_amps >= 2.5 and simDR_gpu_on == 1 then
			if simDR_bus1_power >= 110 or simDR_bus2_power >= 110 then
				A333_ECAM_gpu_line = 1
			elseif simDR_bus1_power < 110 and simDR_bus2_power < 110 then
				A333_ECAM_gpu_line = 0
			end
		elseif simDR_gpu_amps < 2.5 or simDR_gpu_on == 0 then
			A333_ECAM_gpu_line = 0
		end

	elseif simDR_bus1_fail == 6 then

		if simDR_cross_tie == 0 then
			A333_ECAM_gpu_line = 0
		elseif simDR_cross_tie == 1 then
			if simDR_gpu_amps >= 2.5 and simDR_gpu_on == 1 then
				A333_ECAM_gpu_line = 1
			elseif simDR_gpu_amps < 2.5 or simDR_gpu_on == 0 then
				A333_ECAM_gpu_line = 0
			end
		end

	end

	-- CROSSBAR lines

	if simDR_bus1_power >= 110 then
		if simDR_ess_ties == 1 or simDR_cross_tie == 1 or A333_ECAM_crossbar1_line == 1 then
			if simDR_ess_bus_fail == 6 then
				if simDR_cross_tie == 0 then
					if A333_ECAM_crossbar1_line == 1 then
						A333_ECAM_syn_ac1_line = 1
					else A333_ECAM_syn_ac1_line = 0
					end
				elseif simDR_cross_tie == 1 then
					A333_ECAM_syn_ac1_line = 1
				end
			else A333_ECAM_syn_ac1_line = 1
			end
		elseif simDR_ess_ties == 2 and simDR_cross_tie == 0 and A333_ECAM_crossbar1_line == 0 then
			A333_ECAM_syn_ac1_line = 0
		end
	elseif simDR_bus1_power < 110 then
		A333_ECAM_syn_ac1_line = 0
	end

	if simDR_bus2_power >= 110 then
		if simDR_ess_ties == 2 or simDR_cross_tie == 1 then
			if simDR_ess_bus_fail == 6 then
				if simDR_cross_tie == 0 then
					A333_ECAM_syn_ac2_line = 0
				elseif simDR_cross_tie == 1 then
					A333_ECAM_syn_ac2_line = 1
				end
			else A333_ECAM_syn_ac2_line = 1
			end
		elseif simDR_ess_ties == 1 and simDR_cross_tie == 0 then
			A333_ECAM_syn_ac2_line = 0
		end
	elseif simDR_bus2_power < 110 then
		A333_ECAM_syn_ac2_line = 0
	end


	-- DC PAGE --

	if simDR_ess_bus_power < 90 then
		A333_ECAM_elec_ess_tr_source = 2
		A333_ECAM_elec_ess_tr_status = 0
	elseif simDR_ess_bus_power >= 90 then
		A333_ECAM_elec_ess_tr_status = 1
		if simDR_ess_ties == 1 then
			A333_ECAM_elec_ess_tr_source = 0
		elseif simDR_ess_ties == 2 then
			A333_ECAM_elec_ess_tr_source = 1
		end
	end

	if simDR_bus1_power >= 90 then
		A333_ECAM_elec_tr1_status = 1
	elseif simDR_bus1_power < 90 then
		A333_ECAM_elec_tr1_status = 0
	end

	if simDR_bus2_power >= 90 then
		A333_ECAM_elec_tr2_status = 1
		A333_ECAM_elec_apu_tr_status = 1
	elseif simDR_bus2_power < 90 then
		A333_ECAM_elec_tr2_status = 0
		A333_ECAM_elec_apu_tr_status = 0
	end


	if simDR_bus1_power > 90 then
		A333_ECAM_elec_tr1_volts = (simDR_bus1_power / 4.107) + volts_rand2
	elseif simDR_bus1_power < 90 then
		A333_ECAM_elec_tr1_volts = 0
	end

	if simDR_bus2_power > 90 then
		A333_ECAM_elec_tr2_volts = (simDR_bus2_power / 4.107) + volts_rand3
		A333_ECAM_elec_apu_tr_volts = (simDR_bus2_power / 4.107) + volts_rand3
	elseif simDR_bus2_power < 90 then
		A333_ECAM_elec_tr2_volts = 0
		A333_ECAM_elec_apu_tr_volts = 0
	end

	if simDR_ess_bus_power > 90 then
		A333_ECAM_elec_ess_tr_volts = (simDR_ess_bus_power / 4.107) + volts_rand4
	elseif simDR_ess_bus_power < 90 then
		A333_ECAM_elec_ess_tr_volts = 0
	end

	if A333_ECAM_elec_apu_tr_status == 1 then
		A333_ECAM_elec_dc_apu_bus_status = 1
	elseif A333_ECAM_elec_apu_tr_status == 0 then
		if simDR_battery_status[2] == 1 and simDR_bat3_fail ~= 6 then
			A333_ECAM_elec_dc_apu_bus_status = 1
		elseif simDR_battery_status[2] == 0 or simDR_bat3_fail == 6 then
			A333_ECAM_elec_dc_apu_bus_status = 0
		end
	end

	if A333_ECAM_elec_tr1_status == 1 then
		A333_ECAM_elec_dc1_bus_status = 1
	elseif A333_ECAM_elec_tr1_status == 0 then
		if A333_ECAM_elec_tr2_status == 1 then
			A333_ECAM_elec_dc1_bus_status = 1
		elseif A333_ECAM_elec_tr2_status == 0 then
			A333_ECAM_elec_dc1_bus_status = 0
		end
	end

	if A333_ECAM_elec_tr2_status == 1 then
		A333_ECAM_elec_dc2_bus_status = 1
	elseif A333_ECAM_elec_tr2_status == 0 then
		if A333_ECAM_elec_tr1_status == 1 then
			A333_ECAM_elec_dc2_bus_status = 1
		elseif A333_ECAM_elec_tr1_status == 0 then
			A333_ECAM_elec_dc2_bus_status = 0
		end
	end

	if A333_ECAM_elec_ess_tr_status == 1 then
		A333_ECAM_elec_dc_ess_bus_status = 1
	elseif A333_ECAM_elec_ess_tr_status == 0 then

		if A333_ECAM_elec_tr1_status == 0 then
			if A333_ECAM_elec_tr2_status == 0 then
				if simDR_battery_status[0] == 1 and simDR_battery_status[1] == 1 then
					A333_ECAM_elec_dc_ess_bus_status = 1
				else A333_ECAM_elec_dc_ess_bus_status = 0
				end
			elseif A333_ECAM_elec_tr2_status == 1 then
				 A333_ECAM_elec_dc_ess_bus_status = 0
			end
		elseif A333_ECAM_elec_tr1_status == 1 then
			if A333_ECAM_elec_tr2_status == 0 then
				 A333_ECAM_elec_dc_ess_bus_status = 0
			elseif A333_ECAM_elec_tr2_status == 1 then
				 A333_ECAM_elec_dc_ess_bus_status = 1
			end
		end

	end

	if A333_ECAM_elec_dc1_bus_status == 1 or A333_ECAM_elec_dc2_bus_status == 1 then
		A333_ECAM_elec_dc_bat_bus_status = 1
	elseif A333_ECAM_elec_dc1_bus_status == 0 and A333_ECAM_elec_dc2_bus_status == 0 then
		if simDR_battery_status[0] == 1 or simDR_battery_status[1] == 1 then
			A333_ECAM_elec_dc_bat_bus_status = simDR_gear_on_ground
		elseif simDR_battery_status[0] == 0 and simDR_battery_status[1] == 0 then
			A333_ECAM_elec_dc_bat_bus_status = 0
		end
	end

	if A333_ECAM_elec_ess_tr_status == 1 then
		A333_ECAM_elec_dc1_dcbat_line_sts = 1
		A333_ECAM_elec_dc2_dcbat_line_sts = 1
		A333_ECAM_elec_dcbat_dcess_line_sts = 0
		dc_ess_bat_feed = 0
	elseif A333_ECAM_elec_ess_tr_status == 0 then
		if A333_ECAM_elec_tr1_status == 1 and A333_ECAM_elec_tr2_status == 1 then
			A333_ECAM_elec_dc1_dcbat_line_sts = 1
			A333_ECAM_elec_dc2_dcbat_line_sts = 0
			A333_ECAM_elec_dcbat_dcess_line_sts = 1
			dc_ess_bat_feed = 0
		elseif A333_ECAM_elec_tr1_status == 0 and A333_ECAM_elec_tr2_status == 1 then
			A333_ECAM_elec_dc1_dcbat_line_sts = 1
			A333_ECAM_elec_dc2_dcbat_line_sts = 1
			A333_ECAM_elec_dcbat_dcess_line_sts = 0
			dc_ess_bat_feed = 0
		elseif A333_ECAM_elec_tr1_status == 1 and A333_ECAM_elec_tr2_status == 0 then
			A333_ECAM_elec_dc1_dcbat_line_sts = 1
			A333_ECAM_elec_dc2_dcbat_line_sts = 1
			A333_ECAM_elec_dcbat_dcess_line_sts = 0
			dc_ess_bat_feed = 0
		elseif A333_ECAM_elec_tr1_status == 0 and A333_ECAM_elec_tr2_status == 0 then
			A333_ECAM_elec_dc1_dcbat_line_sts = 0
			A333_ECAM_elec_dc2_dcbat_line_sts = 0
			A333_ECAM_elec_dcbat_dcess_line_sts = 0
			dc_ess_bat_feed = 1
		end
	end

	if simDR_bat_amps[2] < -0.025 then
		A333_ECAM_elec_apu_bat_dc_apu_line_sts = 1
	elseif simDR_bat_amps[2] > 0.025 then
		A333_ECAM_elec_apu_bat_dc_apu_line_sts = 2
	elseif simDR_bat_amps[2] >= -0.025 and simDR_bat_amps[2] <= 0.025 then
		A333_ECAM_elec_apu_bat_dc_apu_line_sts = 0
	end

	if simDR_gear_on_ground == 1 then
		if simDR_bat_amps[0] < -0.025 then
			A333_ECAM_elec_bat1_dc_bat_line_sts = 1
			if dc_ess_bat_feed == 1 then
				A333_ECAM_elec_bat1_dc_ess_line_sts = 1
			else A333_ECAM_elec_bat1_dc_ess_line_sts = 0
			end
		elseif simDR_bat_amps[0] > 0.025 then
			A333_ECAM_elec_bat1_dc_bat_line_sts = 2
		elseif simDR_bat_amps[0] >= -0.025 and simDR_bat_amps[0] <= 0.025 then
			A333_ECAM_elec_bat1_dc_bat_line_sts = 0
		end
	elseif simDR_gear_on_ground == 0 then
		if simDR_bat_amps[0] < -0.025 then
			if dc_ess_bat_feed == 1 then
				A333_ECAM_elec_bat1_dc_ess_line_sts = 1
				A333_ECAM_elec_bat1_dc_bat_line_sts = 0
			else A333_ECAM_elec_bat1_dc_ess_line_sts = 0
				A333_ECAM_elec_bat1_dc_bat_line_sts = 1
			end
		elseif simDR_bat_amps[0] > 0.025 then
			A333_ECAM_elec_bat1_dc_bat_line_sts = 2
		elseif simDR_bat_amps[0] >= -0.025 and simDR_bat_amps[0] <= 0.025 then
			A333_ECAM_elec_bat1_dc_bat_line_sts = 0
		end
	end

	if simDR_gear_on_ground == 1 then
		if simDR_bat_amps[1] < -0.025 then
			A333_ECAM_elec_bat2_dc_bat_line_sts = 1
			if dc_ess_bat_feed == 1 then
				A333_ECAM_elec_bat2_dc_ess_line_sts = 1
			else A333_ECAM_elec_bat2_dc_ess_line_sts = 0
			end
		elseif simDR_bat_amps[1] > 0.025 then
			A333_ECAM_elec_bat2_dc_bat_line_sts = 2
		elseif simDR_bat_amps[1] >= -0.025 and simDR_bat_amps[1] <= 0.025 then
			A333_ECAM_elec_bat2_dc_bat_line_sts = 0
		end
	elseif simDR_gear_on_ground == 0 then
		if simDR_bat_amps[1] < -0.025 then
			if dc_ess_bat_feed == 1 then
				A333_ECAM_elec_bat2_dc_ess_line_sts = 1
				A333_ECAM_elec_bat2_dc_bat_line_sts = 0
			else A333_ECAM_elec_bat2_dc_ess_line_sts = 0
				A333_ECAM_elec_bat2_dc_bat_line_sts = 1
			end
		elseif simDR_bat_amps[1] > 0.025 then
			A333_ECAM_elec_bat2_dc_bat_line_sts = 2
		elseif simDR_bat_amps[1] >= -0.025 and simDR_bat_amps[1] <= 0.025 then
			A333_ECAM_elec_bat2_dc_bat_line_sts = 0
		end
	end

	if A333_ECAM_elec_apu_bat_dc_apu_line_sts == 2 then
		A333_ECAM_elec_apu_tr_amps = simDR_bat_amps[2] + simDR_bus_amps[2]
	elseif 	A333_ECAM_elec_apu_bat_dc_apu_line_sts ~= 2 then
		A333_ECAM_elec_apu_tr_amps = simDR_bus_amps[2]
	end

	if simDR_bus1_power > 90 then
		A333_ECAM_elec_tr1_amps = simDR_bus_amps[0]
	elseif simDR_bus1_power < 90 then
		A333_ECAM_elec_tr1_amps = 0
	end

	if simDR_bus2_power > 90 then
		A333_ECAM_elec_tr2_amps = simDR_bus_amps[1]
	elseif simDR_bus2_power < 90 then
		A333_ECAM_elec_tr2_amps = 0
	end

	if simDR_ess_bus_power > 90 then
		A333_ECAM_elec_ess_tr_amps = simDR_bus_amps[3]
	elseif simDR_ess_bus_power < 90 then
		A333_ECAM_elec_ess_tr_amps = 0
	end

	if A333_ECAM_elec_tr2_status == 1 and simDR_battery_status[2] == 1 and A333_ECAM_elec_apu_bat_dc_apu_line_sts == 1 then
		A333_ECAM_apu_starter_source_count = 2
	else A333_ECAM_apu_starter_source_count = 1
	end

	simDR_apu_starter_amps = A333_set_animation_position(simDR_apu_starter_amps, (amp_target_apu / A333_ECAM_apu_starter_source_count), 0, 60, 0.5)

end

---- TEMPERATURE

local cockpit_temperature_target = 0
local cabin_temperature_fwd_target = 0
local cabin_temperature_mid_target = 0
local cabin_temperature_aft_target = 0
local cargo_temperature_target = 0
local bulk_cargo_temperature_target = 0
local cargo_mode = 0
local bulk_rate = 0
local cargo_temp_loop = 0


function A333_interior_temps()

	-- interior temps

	local cockpit_temperature_init = simDR_TAT + A333_rescale(-30, 35, 30, 5, simDR_TAT) + cockpit_random_fac
	local cabin_temperature_fwd_init = simDR_TAT + A333_rescale(-30, 35, 30, 5, simDR_TAT) + cabin_fwd_random_fac
	local cabin_temperature_mid_init = simDR_TAT + A333_rescale(-30, 35, 30, 5, simDR_TAT) + cabin_mid_random_fac
	local cabin_temperature_aft_init = simDR_TAT + A333_rescale(-30, 35, 30, 5, simDR_TAT) + cabin_aft_random_fac
	local cargo_temperature_init = simDR_TAT + A333_rescale(-30, 25, 30, 5, simDR_TAT) + cargo_random_fac
	local bulk_cargo_temperature_init = simDR_TAT + A333_rescale(-30, 20, 30, 5, simDR_TAT) + cargo_bulk_random_fac

	local cockpit_temperature_setting = A333_rescale(-1, 18, 1, 30, A333_cockpit_temp_knob_pos)
	local cabin_temperature_setting = A333_rescale(-1, 18, 1, 30, A333_cabin_temp_knob_pos)
	local cargo_temperature_setting = A333_rescale(-1, 5, 1, 25, A333_fwd_cargo_temp_knob_pos)
	local bulk_cargo_temperature_setting = A333_rescale(-1, 5, 1, 25, A333_bulk_cargo_temp_knob_pos)

	local hot_air_factor = A333_rescale(0, 0, 1, 1, A333_switches_hot_air1_pos)

	-- fuel temps

	if A333_pack_flow1_ratio > 0.5 or A333_pack_flow2_ratio > 0.5 then
		cockpit_temperature_target = cockpit_temperature_setting
	elseif A333_pack_flow1_ratio <= 0.5 and A333_pack_flow2_ratio <= 0.5 then
		cockpit_temperature_target = cockpit_temperature_init
	end

	if A333_pack_flow1_ratio > 0.5 or A333_pack_flow2_ratio > 0.5 then
		cabin_temperature_fwd_target = cabin_temperature_setting + cabin_fwd_random_fac2
		cabin_temperature_mid_target = cabin_temperature_setting + cabin_mid_random_fac2
		cabin_temperature_aft_target = cabin_temperature_setting + cabin_aft_random_fac2
	elseif A333_pack_flow1_ratio <= 0.5 and A333_pack_flow2_ratio <= 0.5 then
		cabin_temperature_fwd_target = cabin_temperature_fwd_init
		cabin_temperature_mid_target = cabin_temperature_mid_init
		cabin_temperature_aft_target = cabin_temperature_aft_init
	end

	if A333_pack_flow1_ratio > 0.5 or A333_pack_flow2_ratio > 0.5 then
		if A333_cargo_cooling_mode_pos ~= 0 then
			if hot_air_factor == 1 then
				cargo_temperature_target = cargo_temperature_setting
				cargo_mode = 1
			elseif hot_air_factor == 0 then
				cargo_temperature_target = cargo_temperature_init
				cargo_mode = 0
			end
		elseif A333_cargo_cooling_mode_pos == 0 then
			cargo_temperature_target = cargo_temperature_init
			cargo_mode = 0
		end
	elseif A333_pack_flow1_ratio <= 0.5 and A333_pack_flow2_ratio <= 0.5 then
		cargo_temperature_target = cargo_temperature_init
		cargo_mode = 0
	end

	if A333_cargo_cond_hot_air_pos >= 1 then
		if simDR_bus2_power > 10 then
			if bulk_cargo_temperature_setting < bulk_cargo_temperature_init then
				if bulk_cargo_temperature_setting <= cargo_temp_loop then
					bulk_cargo_temperature_target = bulk_cargo_temperature_init
					bulk_rate = 0.001
				elseif bulk_cargo_temperature_setting > cargo_temp_loop then
					bulk_cargo_temperature_target = bulk_cargo_temperature_setting
					bulk_rate = 0.01
				end
			elseif bulk_cargo_temperature_setting >= bulk_cargo_temperature_init then
				bulk_cargo_temperature_target = bulk_cargo_temperature_setting
				if cargo_temp_loop >= bulk_cargo_temperature_setting then
					bulk_rate = 0.001
				elseif cargo_temp_loop < bulk_cargo_temperature_setting then
					bulk_rate = 0.01
				end
			end
		elseif simDR_bus2_power <= 10 then
			bulk_cargo_temperature_target = bulk_cargo_temperature_init
			bulk_rate = 0.001
		end
	elseif A333_cargo_cond_hot_air_pos == 0 then
		bulk_cargo_temperature_target = bulk_cargo_temperature_init
		bulk_rate = 0.001
	end

	local pack_flow = math.max(A333_pack_flow1_ratio, A333_pack_flow2_ratio)

	local pack_flow_factor = A333_rescale(0, 1, 10, 3, pack_flow)
	local cargo_flow_factor = A333_rescale(0, 1, 2, 2, A333_cargo_cooling_mode_pos)

	A333_cockpit_temp_ind = A333_set_animation_position(A333_cockpit_temp_ind, cockpit_temperature_target, -40, 50, (0.005 * pack_flow_factor))
	A333_cabin_fwd_temp_ind = A333_set_animation_position(A333_cabin_fwd_temp_ind, cabin_temperature_fwd_target, -40, 50, (0.0039 * pack_flow_factor))
	A333_cabin_mid_temp_ind = A333_set_animation_position(A333_cabin_mid_temp_ind, cabin_temperature_mid_target, -40, 50, (0.0027 * pack_flow_factor))
	A333_cabin_aft_temp_ind = A333_set_animation_position(A333_cabin_aft_temp_ind, cabin_temperature_aft_target, -40, 50, (0.0032 * pack_flow_factor))

	A333_cabin_fwd_mid_temp_ind = (0.667 * A333_cabin_fwd_temp_ind + 0.333 * A333_cabin_mid_temp_ind) + cabin_fwd_mid_random_fac2
	A333_cabin_mid_fwd_temp_ind = (0.333 * A333_cabin_fwd_temp_ind + 0.667 * A333_cabin_mid_temp_ind) + cabin_mid_fwd_random_fac2
	A333_cabin_mid_aft_temp_ind = (0.5 * A333_cabin_mid_temp_ind + 0.5 * A333_cabin_aft_temp_ind) + cabin_aft_mid_random_fac2

	if cargo_mode == 1 then
		A333_cargo_temp_ind = A333_set_animation_position(A333_cargo_temp_ind, cargo_temperature_target, -40, 50, (0.0025 * pack_flow_factor * cargo_flow_factor))
	elseif cargo_mode == 0 then
		A333_cargo_temp_ind = A333_set_animation_position(A333_cargo_temp_ind, cargo_temperature_target, -40, 50, 0.0008)
	end

	A333_bulk_cargo_temp_ind = A333_set_animation_position(A333_bulk_cargo_temp_ind, bulk_cargo_temperature_target, -40, 50, bulk_rate)

	cargo_temp_loop = A333_bulk_cargo_temp_ind

end


---- BRAKE TEMPERATURES

local wheel_brake_temp1 = 0
local wheel_brake_temp2 = 0
local wheel_brake_temp3 = 0
local wheel_brake_temp4 = 0
local wheel_brake_temp5 = 0
local wheel_brake_temp6 = 0
local wheel_brake_temp7 = 0
local wheel_brake_temp8 = 0
local compensated_TAT_left = 0
local compensated_TAT_left_target = 0
local compensated_TAT_right = 0
local compensated_TAT_right_target = 0

function A333_ecam_page_WHEELS_brake_temps()

	if simDR_Lmain_gear_deploy >= 0.1 then
		compensated_TAT_left_target = simDR_TAT
	elseif simDR_Lmain_gear_deploy < 0.1 then
		compensated_TAT_left_target = simDR_TAT + A333_rescale(-40, 50, 25, 5, simDR_TAT)
	end

	if simDR_Rmain_gear_deploy >= 0.1 then
		compensated_TAT_right_target = simDR_TAT
	elseif simDR_Rmain_gear_deploy < 0.1 then
		compensated_TAT_right_target = simDR_TAT + A333_rescale(-40, 50, 25, 5, simDR_TAT)
	end

	compensated_TAT_left = A333_set_animation_position(compensated_TAT_left, compensated_TAT_left_target, -40, 55, 0.0025)
	compensated_TAT_right = A333_set_animation_position(compensated_TAT_right, compensated_TAT_right_target, -40, 55, 0.0025)

	-- LEFT

	wheel_brake_temp1 = A333_rescale(0, compensated_TAT_left, 1.5, 1100, simDR_brake_temp_left) + A333_rescale(0, wheel_brake_1_random_min_fac, 1.5, wheel_brake_1_random_max_fac, simDR_brake_temp_left)
	A333_wheel_brake_temp1 = wheel_brake_temp1 - math.fmod(wheel_brake_temp1, 5)

	wheel_brake_temp2 = A333_rescale(0, compensated_TAT_left, 1.5, 1100, simDR_brake_temp_left) + A333_rescale(0, wheel_brake_2_random_min_fac, 1.5, wheel_brake_2_random_max_fac, simDR_brake_temp_left)
	A333_wheel_brake_temp2 = wheel_brake_temp2 - math.fmod(wheel_brake_temp2, 5)

	wheel_brake_temp5 = A333_rescale(0, compensated_TAT_left, 1.5, 1100, simDR_brake_temp_left) + A333_rescale(0, wheel_brake_5_random_min_fac, 1.5, wheel_brake_5_random_max_fac, simDR_brake_temp_left)
	A333_wheel_brake_temp5 = wheel_brake_temp5 - math.fmod(wheel_brake_temp5, 5)

	wheel_brake_temp6 = A333_rescale(0, compensated_TAT_left, 1.5, 1100, simDR_brake_temp_left) + A333_rescale(0, wheel_brake_6_random_min_fac, 1.5, wheel_brake_6_random_max_fac, simDR_brake_temp_left)
	A333_wheel_brake_temp6 = wheel_brake_temp6 - math.fmod(wheel_brake_temp6, 5)

	-- RIGHT

	wheel_brake_temp3 = A333_rescale(0, compensated_TAT_right, 1.5, 1100, simDR_brake_temp_right) + A333_rescale(0, wheel_brake_3_random_min_fac, 1.5, wheel_brake_3_random_max_fac, simDR_brake_temp_right)
	A333_wheel_brake_temp3 = wheel_brake_temp3 - math.fmod(wheel_brake_temp3, 5)

	wheel_brake_temp4 = A333_rescale(0, compensated_TAT_right, 1.5, 1100, simDR_brake_temp_right) + A333_rescale(0, wheel_brake_4_random_min_fac, 1.5, wheel_brake_4_random_max_fac, simDR_brake_temp_right)
	A333_wheel_brake_temp4 = wheel_brake_temp4 - math.fmod(wheel_brake_temp4, 5)

	wheel_brake_temp7 = A333_rescale(0, compensated_TAT_right, 1.5, 1100, simDR_brake_temp_right) + A333_rescale(0, wheel_brake_7_random_min_fac, 1.5, wheel_brake_7_random_max_fac, simDR_brake_temp_right)
	A333_wheel_brake_temp7 = wheel_brake_temp7 - math.fmod(wheel_brake_temp7, 5)

	wheel_brake_temp8 = A333_rescale(0, compensated_TAT_right, 1.5, 1100, simDR_brake_temp_right) + A333_rescale(0, wheel_brake_8_random_min_fac, 1.5, wheel_brake_8_random_max_fac, simDR_brake_temp_right)
	A333_wheel_brake_temp8 = wheel_brake_temp8 - math.fmod(wheel_brake_temp8, 5)


	A333_wheel_brake_temp_anim_1 = A333_rescale(500, 0, 1100, 1, wheel_brake_temp1)
	A333_wheel_brake_temp_anim_2 = A333_rescale(500, 0, 1100, 1, wheel_brake_temp2)
	A333_wheel_brake_temp_anim_5 = A333_rescale(500, 0, 1100, 1, wheel_brake_temp5)
	A333_wheel_brake_temp_anim_6 = A333_rescale(500, 0, 1100, 1, wheel_brake_temp6)
	
	A333_wheel_brake_temp_anim_3 = A333_rescale(500, 0, 1100, 1, wheel_brake_temp3)
	A333_wheel_brake_temp_anim_4 = A333_rescale(500, 0, 1100, 1, wheel_brake_temp4)
	A333_wheel_brake_temp_anim_7 = A333_rescale(500, 0, 1100, 1, wheel_brake_temp7)
	A333_wheel_brake_temp_anim_8 = A333_rescale(500, 0, 1100, 1, wheel_brake_temp8)


end


---- ECAM WHEELS PAGE

local gear_multiplier = 0
local gear_timer = 0
local brake_temp_max = 0

function A333_ecam_page_WHEELS()

	if simDR_left_brake_fail == 6 or simDR_right_brake_fail == 6 then
		A333_norm_brake_status = 1
	elseif simDR_left_brake_fail ~= 6 and simDR_right_brake_fail ~= 6 then
		if simDR_nosewheel_steering == 1 then
			if simDR_green_hydraulic_pressure > 500 then
				A333_norm_brake_status = 0
			elseif simDR_green_hydraulic_pressure <= 500 then
				A333_norm_brake_status = 1
			end
		elseif simDR_nosewheel_steering == 0 then
			A333_norm_brake_status = 1
		end
	end

	if simDR_nosewheel_steering == 0 then
		A333_anti_skid_status = 1
	elseif simDR_nosewheel_steering == 1 then
		if simDR_gear_on_ground == 0 then
			if simDR_eng1_N1 >= 20 or simDR_eng2_N1 >= 20 then
				if simDR_green_hydraulic_pressure < 500 and simDR_blue_hydraulic_pressure < 500 then
					A333_anti_skid_status = 1
				elseif simDR_green_hydraulic_pressure >= 500 or simDR_blue_hydraulic_pressure >= 500 then
					A333_anti_skid_status = 0
				end
			elseif simDR_eng1_N1 < 20 and simDR_eng2_N1 < 20 then
				A333_anti_skid_status = 0
			end
		elseif simDR_gear_on_ground == 1 then
			A333_anti_skid_status = 0
		end
	end

	gear_multiplier = simDR_nose_gear_deploy * simDR_Lmain_gear_deploy * simDR_Rmain_gear_deploy

	if simDR_gear_handle == gear_multiplier then
		gear_timer = 0
	elseif simDR_gear_handle ~= gear_multiplier then
		gear_timer = gear_timer + SIM_PERIOD
	end

	if gear_timer < 30 then
		A333_lg_ctl_status = 0
	elseif gear_timer >= 30 then
		A333_lg_ctl_status = 1
	end

	if simDR_gear_on_ground == 0 then

		if simDR_nosewheel_steering == 1 then

			if simDR_Lmain_gear_deploy >= 0.95 then
				if simDR_left_brake_ratio == 0 then
					A333_wheel_brake_release_left = 1
				elseif simDR_left_brake_ratio > 0 then
					A333_wheel_brake_release_left = 0
				end
			elseif simDR_Lmain_gear_deploy < 0.95 then
				A333_wheel_brake_release_left = 0
			end

			if simDR_Rmain_gear_deploy >= 0.95 then
				if simDR_right_brake_ratio == 0 then
					A333_wheel_brake_release_right = 1
				elseif simDR_right_brake_ratio > 0 then
					A333_wheel_brake_release_right = 0
				end
			elseif simDR_Rmain_gear_deploy < 0.95 then
				A333_wheel_brake_release_right = 0
			end

		elseif simDR_nosewheel_steering == 0 then
			A333_wheel_brake_release_left = 0
			A333_wheel_brake_release_right = 0
		end

	elseif simDR_gear_on_ground == 1 then

		if simDR_left_brake_ratio ~= 0 then
			if simDR_left_skid_ratio >= 0.12 then
				A333_wheel_brake_release_left = 1
			elseif simDR_left_skid_ratio < 0.12 then
				A333_wheel_brake_release_left = 0
			end
		elseif simDR_left_brake_ratio == 0 then
			A333_wheel_brake_release_left = 0
		end

		if simDR_right_brake_ratio ~= 0 then
			if simDR_left_skid_ratio >= 0.12 then
				A333_wheel_brake_release_right = 1
			elseif simDR_left_skid_ratio < 0.12 then
				A333_wheel_brake_release_right = 0
			end
		elseif simDR_right_brake_ratio == 0 then
			A333_wheel_brake_release_right = 0
		end

	end

	brake_temp_max = math.max(A333_wheel_brake_temp1, A333_wheel_brake_temp2, A333_wheel_brake_temp3, A333_wheel_brake_temp4, A333_wheel_brake_temp5, A333_wheel_brake_temp6, A333_wheel_brake_temp7, A333_wheel_brake_temp8)

	if brake_temp_max >= 300 then
		A333_wheel_brake_warn = 1
	elseif brake_temp_max < 300 then
		A333_wheel_brake_warn = 0
	end

	if A333_wheel_brake_temp1 == brake_temp_max then
		if brake_temp_max < 100 then
			A333_wheel_brake_temp_arc1 = 0
		elseif brake_temp_max >= 100 and brake_temp_max < 300 then
			A333_wheel_brake_temp_arc1 = 1
		elseif brake_temp_max >= 300 then
			A333_wheel_brake_temp_arc1 = 2
		end
	elseif A333_wheel_brake_temp1 ~= brake_temp_max then
		A333_wheel_brake_temp_arc1 = 0
	end

	if A333_wheel_brake_temp2 == brake_temp_max then
		if brake_temp_max < 100 then
			A333_wheel_brake_temp_arc2 = 0
		elseif brake_temp_max >= 100 and brake_temp_max < 300 then
			A333_wheel_brake_temp_arc2 = 1
		elseif brake_temp_max >= 300 then
			A333_wheel_brake_temp_arc2 = 2
		end
	elseif A333_wheel_brake_temp2 ~= brake_temp_max then
		A333_wheel_brake_temp_arc2 = 0
	end

	if A333_wheel_brake_temp3 == brake_temp_max then
		if brake_temp_max < 100 then
			A333_wheel_brake_temp_arc3 = 0
		elseif brake_temp_max >= 100 and brake_temp_max < 300 then
			A333_wheel_brake_temp_arc3 = 1
		elseif brake_temp_max >= 300 then
			A333_wheel_brake_temp_arc3 = 2
		end
	elseif A333_wheel_brake_temp3 ~= brake_temp_max then
		A333_wheel_brake_temp_arc3 = 0
	end

	if A333_wheel_brake_temp4 == brake_temp_max then
		if brake_temp_max < 100 then
			A333_wheel_brake_temp_arc4 = 0
		elseif brake_temp_max >= 100 and brake_temp_max < 300 then
			A333_wheel_brake_temp_arc4 = 1
		elseif brake_temp_max >= 300 then
			A333_wheel_brake_temp_arc4 = 2
		end
	elseif A333_wheel_brake_temp4 ~= brake_temp_max then
		A333_wheel_brake_temp_arc4 = 0
	end

	if A333_wheel_brake_temp5 == brake_temp_max then
		if brake_temp_max < 100 then
			A333_wheel_brake_temp_arc5 = 0
		elseif brake_temp_max >= 100 and brake_temp_max < 300 then
			A333_wheel_brake_temp_arc5 = 1
		elseif brake_temp_max >= 300 then
			A333_wheel_brake_temp_arc5 = 2
		end
	elseif A333_wheel_brake_temp5 ~= brake_temp_max then
		A333_wheel_brake_temp_arc5 = 0
	end

	if A333_wheel_brake_temp6 == brake_temp_max then
		if brake_temp_max < 100 then
			A333_wheel_brake_temp_arc6 = 0
		elseif brake_temp_max >= 100 and brake_temp_max < 300 then
			A333_wheel_brake_temp_arc6 = 1
		elseif brake_temp_max >= 300 then
			A333_wheel_brake_temp_arc6 = 2
		end
	elseif A333_wheel_brake_temp6 ~= brake_temp_max then
		A333_wheel_brake_temp_arc6 = 0
	end

	if A333_wheel_brake_temp7 == brake_temp_max then
		if brake_temp_max < 100 then
			A333_wheel_brake_temp_arc7 = 0
		elseif brake_temp_max >= 100 and brake_temp_max < 300 then
			A333_wheel_brake_temp_arc7 = 1
		elseif brake_temp_max >= 300 then
			A333_wheel_brake_temp_arc7 = 2
		end
	elseif A333_wheel_brake_temp7 ~= brake_temp_max then
		A333_wheel_brake_temp_arc7 = 0
	end

	if A333_wheel_brake_temp8 == brake_temp_max then
		if brake_temp_max < 100 then
			A333_wheel_brake_temp_arc8 = 0
		elseif brake_temp_max >= 100 and brake_temp_max < 300 then
			A333_wheel_brake_temp_arc8 = 1
		elseif brake_temp_max >= 300 then
			A333_wheel_brake_temp_arc8 = 2
		end
	elseif A333_wheel_brake_temp8 ~= brake_temp_max then
		A333_wheel_brake_temp_arc8 = 0
	end

end

---- ECAM CAB PRESS PAGE

local outflow_valve_minimum = 0
local outflow_valve_maximum = 1

function A333_ecam_page_CAB_PRESS()


	if A333_ditching_status == 1 then
		A333_vent_extract_valve_pos = 0
		outflow_valve_minimum = 0
		outflow_valve_maximum = 0
	elseif A333_ditching_status == 0 then
		outflow_valve_maximum = 1
		if A333_ventilation_extract_status == 0 then
			A333_vent_extract_valve_pos = 1
		elseif A333_ventilation_extract_status == 1 then
			if simDR_gear_on_ground == 1 then
				outflow_valve_minimum = 0
				if simDR_eng1_N1 > 5 or simDR_eng2_N1 > 5 then
					A333_vent_extract_valve_pos = 0
				elseif simDR_eng1_N1 <= 5 and simDR_eng2_N1 <= 5 then
					A333_vent_extract_valve_pos = 2
				end
			elseif simDR_gear_on_ground == 0 then
				outflow_valve_minimum = 0.05
				A333_vent_extract_valve_pos = 0
			end
		end

	end

	A333_outflow_valve_fwd = A333_set_animation_position(A333_outflow_valve_fwd, simDR_outflow_valve, outflow_valve_minimum, outflow_valve_maximum, 0.5)
	A333_outflow_valve_aft = A333_set_animation_position(A333_outflow_valve_aft, simDR_outflow_valve, outflow_valve_minimum, outflow_valve_maximum, 0.5)


end

---- ECAM BLEED PAGE

local crossbleed_valve = 0
local pack1_flow_target2 = 0
local pack2_flow_target2 = 0
local precooler_temp1_target = 0
local precooler_temp2_target = 0
local pack1_comp_target = 0
local pack2_comp_target = 0
local pack1_cool_rate = 0
local pack2_cool_rate = 0
local alt_factor = 1
local left_psi_factor = 1
local right_psi_factor = 1
local apu_loss_left = 0
local apu_loss_right = 0
local precooler1_psi_target = 0
local precooler2_psi_target = 0
local average_temperature = 0
local average_temp_setting = 0
local pack1_temp_needle = 0
local pack2_temp_needle = 0
local pack1_temp_needle_target = 0
local pack2_temp_needle_target = 0
local pack1_outlet_temp_target = 0
local pack2_outlet_temp_target = 0
local pack1_outlet_temp = 0
local pack2_outlet_temp = 0
local anti_ice_timer = 0


function A333_ecam_page_BLEED()

	crossbleed_valve = A333_set_animation_position(crossbleed_valve, A333_isol_valve_right_target, 0, 1, 4)

	if crossbleed_valve == 0 then
		A333_isol_valve_right_pos = 0
		simDR_duct_isol_valve_right = 0
	elseif crossbleed_valve == 1 then
		simDR_duct_isol_valve_right = 1
		if simDR_left_duct_avail < 0.5 and simDR_right_duct_avail < 0.5 then
			A333_isol_valve_right_pos = 3
		elseif simDR_left_duct_avail >= 0.5 or simDR_right_duct_avail >= 0.5 then
			A333_isol_valve_right_pos = 2
		end
	elseif crossbleed_valve ~= 1 and crossbleed_valve ~= 0 then
		A333_isol_valve_right_pos = 1
		simDR_duct_isol_valve_right = 0
	end

	if simDR_left_pack == 0 then
		A333_pack1_valve_pos = 0
	elseif simDR_left_pack == 1 then
		if pack1_flow_target ~= 0 then
			A333_pack1_valve_pos = 1
		elseif pack1_flow_target == 0 then
			A333_pack1_valve_pos = 0
		end
	end

	if simDR_right_pack == 0 then
		A333_pack2_valve_pos = 0
	elseif simDR_right_pack == 1 then
		if pack2_flow_target ~= 0 then
			A333_pack2_valve_pos = 1
		elseif pack2_flow_target == 0 then
			A333_pack2_valve_pos = 0
		end
	end

	if simDR_gear_on_ground == 1 then
		if simDR_left_duct_avail > 0.5 or simDR_right_duct_avail > 0.5 then
			if A333_pack1_valve_pos == 1 or A333_pack2_valve_pos == 1 then
				A333_user_bleed_status = 1
			elseif A333_pack1_valve_pos == 0 and A333_pack2_valve_pos == 0 then
				A333_user_bleed_status = 0
			end
		elseif simDR_left_duct_avail <= 0.5 and simDR_right_duct_avail <= 0.5 then
			A333_user_bleed_status = 0
		end
	elseif simDR_gear_on_ground == 0 then
		if A333_status_ram_air_valve == 0 then
			if simDR_left_duct_avail > 0.5 or simDR_right_duct_avail > 0.5 then
				if A333_pack1_valve_pos == 1 or A333_pack2_valve_pos == 1 then
					A333_user_bleed_status = 1
				elseif A333_pack1_valve_pos == 0 and A333_pack2_valve_pos == 0 then
					A333_user_bleed_status = 0
				end
			elseif simDR_left_duct_avail <= 0.5 and simDR_right_duct_avail <= 0.5 then
				A333_user_bleed_status = 0
			end
		elseif A333_status_ram_air_valve == 1 then
			A333_user_bleed_status = 1
		end
	end

	if simDR_left_pack == 0 then
		pack1_flow_target2 = 1
	elseif simDR_left_pack == 1 then
		pack1_flow_target2 = pack1_flow_target
	end

	if simDR_right_pack == 0 then
		pack2_flow_target2 = 1
	elseif simDR_right_pack == 1 then
		pack2_flow_target2 = pack2_flow_target
	end

	A333_pack1_flow = A333_set_animation_position(A333_pack1_flow, pack1_flow_target2, 0.8, 1.25, 2)
	A333_pack2_flow = A333_set_animation_position(A333_pack2_flow, pack2_flow_target2, 0.8, 1.25, 2)

	if A333_pack1_flow <= pack1_flow_target2 + 0.001 and A333_pack1_flow >= pack1_flow_target2 - 0.001 then
		A333_pack1_flow_status = 1
	elseif A333_pack1_flow > pack1_flow_target2 + 0.001 or A333_pack1_flow < pack1_flow_target2 - 0.001 then
		A333_pack1_flow_status = 0
	end

	if A333_pack2_flow <= pack2_flow_target2 + 0.001 and A333_pack2_flow >= pack2_flow_target2 - 0.001 then
		A333_pack2_flow_status = 1
	elseif A333_pack2_flow > pack2_flow_target2 + 0.001 or A333_pack2_flow < pack2_flow_target2 - 0.001 then
		A333_pack2_flow_status = 0
	end


	-- TEMPERATURES

	if simDR_capt_altitude < 10000 then
		alt_factor = A333_rescale(-1000, 1.1, 10000, 1.45, simDR_capt_altitude)
	elseif simDR_capt_altitude >= 10000 and simDR_capt_altitude < 20000 then
		alt_factor = A333_rescale(10000, 1.45, 20000, 1.88, simDR_capt_altitude)
	elseif simDR_capt_altitude >= 20000 and simDR_capt_altitude < 30000 then
		alt_factor = A333_rescale(20000, 1.88, 30000, 2.4, simDR_capt_altitude)
	elseif simDR_capt_altitude >= 30000 and simDR_capt_altitude < 35000 then
		alt_factor = A333_rescale(30000, 2.4, 35000, 2.9, simDR_capt_altitude)
	elseif simDR_capt_altitude >= 35000 then
		alt_factor = A333_rescale(35000, 2.9, 43000, 4.4, simDR_capt_altitude)
	end

	if simDR_duct_isol_valve_right == 0 then
		if simDR_apu_bleed == 0 then
			left_psi_factor = 1
			right_psi_factor = 1
			apu_loss_left = 0
			apu_loss_right = 0
		elseif simDR_apu_bleed == 1 then
			left_psi_factor = A333_rescale(0, 1.5, 45000, 0.55, simDR_capt_altitude)
			right_psi_factor = 1
			apu_loss_left = simDR_apu_loss
			apu_loss_right = 0
		end
	elseif simDR_duct_isol_valve_right == 1 then
		if simDR_apu_bleed == 0 then
			left_psi_factor = 1
			right_psi_factor = 1
			apu_loss_left = 0
			apu_loss_right = 0
		elseif simDR_apu_bleed == 1 then
			left_psi_factor = A333_rescale(0, 1.25, 45000, 0.4, simDR_capt_altitude)
			right_psi_factor = A333_rescale(0, 1.25, 45000, 0.4, simDR_capt_altitude)
			apu_loss_left = 0.5 * simDR_apu_loss
			apu_loss_right = 0.5 * simDR_apu_loss
		end
	end

	if simDR_bleed_air1 == 1 then
		precooler_temp1_target = A333_rescale(0, simDR_TAT, A333_rescale(1, 2.1, 1.5, 2.6, simDR_left_duct_avail), simDR_TAT + 250, simDR_left_duct_avail * left_psi_factor * alt_factor) - (simDR_engine1_loss * 1.33) - apu_loss_left
	elseif simDR_bleed_air1 == 0 then
		precooler_temp1_target = A333_rescale(0, simDR_TAT, 2.7, simDR_TAT + 50, simDR_left_duct_avail * left_psi_factor * alt_factor) - apu_loss_left
	end

	if simDR_bleed_air2 == 1 then
		precooler_temp2_target = A333_rescale(0, simDR_TAT, A333_rescale(1, 2.1, 1.5, 2.6, simDR_right_duct_avail), simDR_TAT + 250, simDR_right_duct_avail * right_psi_factor * alt_factor) - (simDR_engine2_loss * 1.33) - apu_loss_right
	elseif simDR_bleed_air2 == 0 then
		precooler_temp2_target = A333_rescale(0, simDR_TAT, 2.7, simDR_TAT + 50, simDR_right_duct_avail * right_psi_factor * alt_factor) - apu_loss_right
	end

	A333_precooler1_temp = A333_set_animation_position(A333_precooler1_temp, precooler_temp1_target, 0, 300, A333_rescale(0, 0.016, 1, 0.16, simDR_bleed_air1))
	A333_precooler2_temp = A333_set_animation_position(A333_precooler2_temp, precooler_temp2_target, 0, 300, A333_rescale(0, 0.015, 1, 0.15, simDR_bleed_air2))

	if A333_pack1_valve_pos == 0 then
		pack1_comp_target = simDR_TAT + 10
		pack1_cool_rate = 0.002
	elseif A333_pack1_valve_pos == 1 then
		if simDR_left_duct_avail >= 0.5 then
			if simDR_apu_bleed == 0 and simDR_bleed_air1 == 1 then
				pack1_comp_target = A333_rescale(0, 45, 250, 285, A333_precooler1_temp) - 10 - alt_factor * 7
				pack1_cool_rate = 0.05
			elseif simDR_apu_bleed == 1 and simDR_bleed_air1 == 0 then
				pack1_comp_target = A333_rescale(0, 0, 600, 285, simDR_APU_EGT) - 10 - alt_factor * 7
				pack1_cool_rate = 0.05
			end
		elseif simDR_left_duct_avail < 0.5 then
			pack1_comp_target = simDR_TAT + 5
			pack1_cool_rate = 0.01
		end
	end

	if A333_pack2_valve_pos == 0 then
		pack2_comp_target = simDR_TAT + 10
		pack2_cool_rate = 0.002
	elseif A333_pack2_valve_pos == 1 then
		if simDR_right_duct_avail >= 0.5 then
			if simDR_duct_isol_valve_right == 0 then
				pack2_comp_target = A333_rescale(0, 45, 250, 285, A333_precooler2_temp) - 10 - alt_factor * 7
				pack2_cool_rate = 0.05
			elseif simDR_duct_isol_valve_right == 1 then
				if simDR_apu_bleed == 0 and simDR_bleed_air2 == 1 then
					pack2_comp_target = A333_rescale(0, 45, 250, 285, A333_precooler2_temp) - 10 - alt_factor * 7
					pack2_cool_rate = 0.05
				elseif simDR_apu_bleed == 1 and simDR_bleed_air2 == 0 then
					pack2_comp_target = A333_rescale(0, 0, 600, 285, simDR_APU_EGT) - 10 - alt_factor * 7
					pack2_cool_rate = 0.05
				end
			end
		elseif simDR_right_duct_avail < 0.5 then
			pack2_comp_target = simDR_TAT + 5
			pack2_cool_rate = 0.01
		end
	end

	A333_pack1_compressor_outlet_temp = A333_set_animation_position(A333_pack1_compressor_outlet_temp, pack1_comp_target, -100, 300, (0.9 * pack1_cool_rate * A333_pack1_flow))
	A333_pack2_compressor_outlet_temp = A333_set_animation_position(A333_pack2_compressor_outlet_temp, pack2_comp_target, -100, 300, (0.9 * pack2_cool_rate * A333_pack2_flow))

	precooler1_psi_target = simDR_left_duct_avail * alt_factor * left_psi_factor - (0.07 * apu_loss_left) - (simDR_engine1_loss * 0.02)
	precooler2_psi_target = simDR_right_duct_avail * alt_factor * right_psi_factor - (0.07 * apu_loss_right) - (simDR_engine2_loss * 0.02)

	A333_precooler1_psi = A333_set_animation_position(A333_precooler1_psi, precooler1_psi_target, 0, 15, 1.5)
	A333_precooler2_psi = A333_set_animation_position(A333_precooler2_psi, precooler2_psi_target, 0, 15, 1.5)

	--

	local cockpit_temperature_setting = A333_rescale(-1, 18, 1, 30, A333_cockpit_temp_knob_pos)
	local cabin_temperature_setting = A333_rescale(-1, 18, 1, 30, A333_cabin_temp_knob_pos)

	average_temperature = (A333_cockpit_temp_ind + A333_cabin_fwd_temp_ind + A333_cabin_mid_temp_ind + A333_cabin_aft_temp_ind) * 0.25
	average_temp_setting = (cockpit_temperature_setting + cabin_temperature_setting) * 0.5

	if average_temperature >= average_temp_setting then

		pack1_temp_needle = A333_rescale(0, 0.5, 10, 0, (average_temperature - average_temp_setting))
		pack2_temp_needle = A333_rescale(0, 0.5, 10, 0, (average_temperature - average_temp_setting))

	elseif average_temperature < average_temp_setting then

		pack1_temp_needle = A333_rescale(0, 0.5, 10, 1, (average_temp_setting - average_temperature))
		pack2_temp_needle = A333_rescale(0, 0.5, 10, 1, (average_temp_setting - average_temperature))

	end

	if A333_pack1_valve_pos == 1 then
		pack1_temp_needle_target = pack1_temp_needle + A333_rescale(-40, 0.15, 50, -0.25, simDR_TAT)
	elseif A333_pack1_valve_pos == 0 then
		pack1_temp_needle_target = 0.5
	end

	if A333_pack2_valve_pos == 1 then
		pack2_temp_needle_target = pack2_temp_needle + A333_rescale(-40, 0.15, 50, -0.25, simDR_TAT)
	elseif A333_pack2_valve_pos == 0 then
		pack2_temp_needle_target = 0.5
	end

	A333_pack1_CH_valve_pos = A333_set_animation_position(A333_pack1_CH_valve_pos, pack1_temp_needle_target, 0, 1, 1)
	A333_pack2_CH_valve_pos = A333_set_animation_position(A333_pack2_CH_valve_pos, pack2_temp_needle_target, 0, 1, 1)

	--

	if pack1_temp_needle_target >= 0.5 then
		pack1_outlet_temp = average_temp_setting + A333_rescale(0.5, 0, 1, A333_rescale(18, 45, 30, 35, average_temp_setting), pack1_temp_needle_target)
	elseif pack1_temp_needle_target < 0.5 then
		pack1_outlet_temp = average_temp_setting + A333_rescale(0, A333_rescale(18, -12, 30, -20, average_temp_setting), 0.5, 0, pack1_temp_needle_target)
	end

	local pack1_outlet_temp_fac1 = A333_rescale(100, 0.9, 300, 1.1, A333_pack1_compressor_outlet_temp)

	if pack2_temp_needle_target >= 0.5 then
		pack2_outlet_temp = average_temp_setting + A333_rescale(0.5, 0, 1, A333_rescale(18, 45, 30, 35, average_temp_setting), pack2_temp_needle_target)
	elseif pack2_temp_needle_target < 0.5 then
		pack2_outlet_temp = average_temp_setting + A333_rescale(0, A333_rescale(18, -12, 30, -20, average_temp_setting), 0.5, 0, pack2_temp_needle_target)
	end

	local pack2_outlet_temp_fac1 = A333_rescale(100, 0.9, 300, 1.1, A333_pack2_compressor_outlet_temp)

	if A333_pack1_valve_pos == 0 then
		pack1_outlet_temp_target = simDR_TAT + 5
	elseif A333_pack1_valve_pos == 1 then
		if simDR_left_duct_avail >= 0.5 then
			pack1_outlet_temp_target = pack1_outlet_temp * pack1_outlet_temp_fac1
		elseif simDR_left_duct_avail < 0.5 then
			pack1_outlet_temp_target = simDR_TAT + 3
		end
	end

	if A333_pack2_valve_pos == 0 then
		pack2_outlet_temp_target = simDR_TAT + 5
	elseif A333_pack2_valve_pos == 1 then
		if simDR_right_duct_avail >= 0.5 then
			pack2_outlet_temp_target = pack2_outlet_temp * pack2_outlet_temp_fac1
		elseif simDR_right_duct_avail < 0.5 then
			pack2_outlet_temp_target = simDR_TAT + 3
		end
	end

	A333_pack1_outlet_temp = A333_set_animation_position(A333_pack1_outlet_temp, pack1_outlet_temp_target, -100, 300, pack1_cool_rate * A333_pack1_flow * 0.4)
	A333_pack2_outlet_temp = A333_set_animation_position(A333_pack2_outlet_temp, pack2_outlet_temp_target, -100, 300, pack2_cool_rate * A333_pack2_flow * 0.4)

	-- ANTI ICE

	if simDR_gear_on_ground == 1 then
		if simDR_wing_heat_left == 1 or simDR_wing_heat_right == 1 then
			anti_ice_timer = anti_ice_timer + SIM_PERIOD
		elseif simDR_wing_heat_left == 0 and simDR_wing_heat_right == 0 then
			anti_ice_timer = 0
		end
	elseif simDR_gear_on_ground == 0 then
		anti_ice_timer = 0
	end

	if simDR_wing_heat_fault_left == 6 then
		A333_left_wing_ai_valve_ind = 0
	elseif simDR_wing_heat_fault_left ~= 6 then
		if simDR_left_duct_avail > 7 or simDR_left_duct_avail < 0.5 then
			A333_left_wing_ai_valve_ind = 0
		elseif simDR_left_duct_avail <= 7 and simDR_left_duct_avail >= 0.5 then
			if anti_ice_timer >= 35 then
				A333_left_wing_ai_valve_ind = 0
			elseif anti_ice_timer < 35 then
				A333_left_wing_ai_valve_ind = 1
			end
		end
	end

	if A333_wing_heat_valve_pos_left == 0 then
		A333_left_wing_ai_status = -1
	elseif A333_wing_heat_valve_pos_left ~= 0 and A333_wing_heat_valve_pos_left ~= 1 then
		A333_left_wing_ai_status = 0
	elseif A333_wing_heat_valve_pos_left == 1 then
		if A333_left_wing_ai_valve_ind == 1 then
			A333_left_wing_ai_status = 1
		elseif A333_left_wing_ai_valve_ind == 0 then
			A333_left_wing_ai_status = 0
		end
	end

	if simDR_wing_heat_fault_right == 6 then
		A333_right_wing_ai_valve_ind = 0
	elseif simDR_wing_heat_fault_right ~= 6 then
		if simDR_right_duct_avail > 7 or simDR_right_duct_avail < 0.5 then
			A333_right_wing_ai_valve_ind = 0
		elseif simDR_right_duct_avail <= 7 and simDR_right_duct_avail >= 0.5 then
			if anti_ice_timer >= 35 then
				A333_right_wing_ai_valve_ind = 0
			elseif anti_ice_timer < 35 then
				A333_right_wing_ai_valve_ind = 1
			end
		end
	end

	if A333_wing_heat_valve_pos_right == 0 then
		A333_right_wing_ai_status = -1
	elseif A333_wing_heat_valve_pos_right ~= 0 and A333_wing_heat_valve_pos_right ~= 1 then
		A333_right_wing_ai_status = 0
	elseif A333_wing_heat_valve_pos_right == 1 then
		if A333_right_wing_ai_valve_ind == 1 then
			A333_right_wing_ai_status = 1
		elseif A333_right_wing_ai_valve_ind == 0 then
			A333_right_wing_ai_status = 0
		end
	end


end

---- ECAM COND PAGE

local pack_lo_flasher = 0
local buses_powered = 0
local hot_air_xfeed_pos_target = 0
local hot_air1_pressed = 0
local hot_air2_pressed = 0
local cooling_valve_pos_target = 0
local cooling_valve_pos = 0
local TOTAL_pack_status = 0
local cooling_valve_mid = 0
local bulk_temp_differential = 0
local cargo_temp_differential = 0
local zone1_differential = 0
local zone2_differential = 0
local zone3_differential = 0
local zone4_differential = 0
local zone5_differential = 0
local zone6_differential = 0
local zone7_differential = 0
local zone1_needle_target = 0
local zone2_needle_target = 0
local zone3_needle_target = 0
local zone4_needle_target = 0
local zone5_needle_target = 0
local zone6_needle_target = 0
local zone7_needle_target = 0
local cargo_temp_needle_target = 0

function A333_ecam_page_COND()

	if simDR_bus1_power >= 5 or simDR_bus1_power >= 5 then
		buses_powered = 1
	elseif simDR_bus1_power < 5 and simDR_bus1_power < 5 then
		buses_powered = 0
	end

	local flasher_pack = 1
	local time_factor2 = 0
	local sim_time_factor2 = math.fmod(simDR_flight_time, 0.8)

	if sim_time_factor2 >= 0 and sim_time_factor2 <= 0.3 then
		flasher_pack = 2
	end

	pack_lo_flasher = A333_set_animation_position(pack_lo_flasher, flasher_pack, 1, 2, 10)

	--

	if simDR_left_pack == 1 or simDR_right_pack == 1 then
		if simDR_left_duct_avail < 0.5 and simDR_right_duct_avail < 0.5 then
			A333_pack_lo_flow = pack_lo_flasher
		elseif simDR_left_duct_avail >= 0.5 or simDR_right_duct_avail >= 0.5 then
			A333_pack_lo_flow = 0
		end
	elseif simDR_left_pack == 0 and simDR_right_pack == 0 then
		A333_pack_lo_flow = 0
	end

	if A333_switches_hot_air1_pos == 0 and A333_switches_hot_air2_pos == 0 then
		A333_pack_regulated = 1
	elseif A333_switches_hot_air1_pos >= 1 or A333_switches_hot_air2_pos >= 1 then
		if buses_powered == 1 then
			A333_pack_regulated = 0
		elseif buses_powered == 0 then
			A333_pack_regulated = 1
		end
	end

	if A333_cabin_fan_pos >= 1 then
		if simDR_bus1_power >= 5 then
			A333_cabin_fan1_off = 0
		elseif simDR_bus1_power < 5 then
			A333_cabin_fan1_off = 1
		end
	elseif A333_cabin_fan_pos == 0 then
		A333_cabin_fan1_off = 1
	end

	if A333_cabin_fan_pos >= 1 then
		if simDR_bus2_power >= 5 then
			A333_cabin_fan2_off = 0
		elseif simDR_bus2_power < 5 then
			A333_cabin_fan2_off = 1
		end
	elseif A333_cabin_fan_pos == 0 then
		A333_cabin_fan2_off = 1
	end

	if A333_cargo_cond_hot_air_pos >= 1 then
		if simDR_bus2_power >= 10 then
			A333_bulk_heater_line = 1
		elseif simDR_bus2_power < 10 then
			A333_bulk_heater_line = 0
		end
	elseif A333_cargo_cond_hot_air_pos == 0 then
		A333_bulk_heater_line = 0
	end

	if A333_switches_hot_air1_pos == 0 then
		A333_hot_air_1_valve = 0
	elseif A333_switches_hot_air1_pos >= 1 then
		if simDR_bus1_power >= 10 then
			A333_hot_air_1_valve = 1
		elseif simDR_bus1_power < 10 then
			A333_hot_air_1_valve = 0
		end
	end

	if A333_switches_hot_air2_pos == 0 then
		A333_hot_air_2_valve = 0
	elseif A333_switches_hot_air2_pos >= 1 then
		if simDR_bus2_power >= 10 then
			A333_hot_air_2_valve = 1
		elseif simDR_bus2_power < 10 then
			A333_hot_air_2_valve = 0
		end
	end

	if A333_hot_air_1_valve == 1 then
		if simDR_left_duct_avail > 0.25 then
			hot_air1_pressed = 1
		elseif simDR_left_duct_avail <= 0.25 then
			hot_air1_pressed = 0
		end
	elseif A333_hot_air_1_valve == 0 then
		hot_air1_pressed = 0
	end

	if A333_hot_air_2_valve == 1 then
		if simDR_right_duct_avail > 0.25 then
			hot_air2_pressed = 1
		elseif simDR_right_duct_avail <= 0.25 then
			hot_air2_pressed = 0
		end
	elseif A333_hot_air_2_valve == 0 then
		hot_air2_pressed = 0
	end

	if hot_air1_pressed == 1 and hot_air2_pressed == 0 then
		hot_air_xfeed_pos_target = 1
	elseif hot_air1_pressed == 0 and hot_air2_pressed == 1 then
		hot_air_xfeed_pos_target = 1
	elseif hot_air1_pressed == 1 and hot_air2_pressed == 1 then
		hot_air_xfeed_pos_target = 0
	elseif hot_air1_pressed == 0 and hot_air2_pressed == 0 then
		hot_air_xfeed_pos_target = 0
	end

	A333_hot_air_cross_valve_pos = A333_set_animation_position(A333_hot_air_cross_valve_pos, hot_air_xfeed_pos_target, 0, 1, 2)

	if A333_hot_air_cross_valve_pos ~= 1 then
		A333_hot_air_loop1_status = hot_air1_pressed
		A333_hot_air_loop2_status = hot_air2_pressed
	elseif A333_hot_air_cross_valve_pos == 1 then
		A333_hot_air_loop1_status = 1
		A333_hot_air_loop2_status = 1
	end

	if A333_pack1_valve_pos == 1 and A333_pack2_valve_pos == 1 then
		A333_cold_air_line2 = 1
		TOTAL_pack_status = 2
	elseif A333_pack1_valve_pos == 1 and A333_pack2_valve_pos == 0 then
		A333_cold_air_line2 = 1
		TOTAL_pack_status = 1
	elseif A333_pack1_valve_pos == 0 and A333_pack2_valve_pos == 1 then
		A333_cold_air_line2 = 1
		TOTAL_pack_status = 1
	elseif A333_pack1_valve_pos == 0 and A333_pack2_valve_pos == 0 then
		A333_cold_air_line2 = 0
		TOTAL_pack_status = 0
	end

	if A333_cold_air_line2 == 0 then
		A333_cold_air_line1 = 0
	elseif A333_cold_air_line2 == 1 then
		if A333_cargo_cooling_mode_pos >= 1 then
			A333_cold_air_line1 = 1
		elseif A333_cargo_cooling_mode_pos == 0 then
			A333_cold_air_line1 = 0
		end
	end

	if buses_powered == 1 then
		cooling_valve_pos_target = A333_cargo_cooling_mode_pos
	elseif buses_powered == 0 then
		cooling_valve_pos_target = 0
	end

	cooling_valve_pos = A333_set_animation_position(cooling_valve_pos, cooling_valve_pos_target, 0, 2, 2)

	if cooling_valve_pos > 0.99 and cooling_valve_pos < 1.01 and cooling_valve_pos_target == 1 then
		cooling_valve_mid = 1
	elseif cooling_valve_pos <= 0.99 or cooling_valve_pos >= 1.01 then
		cooling_valve_mid = 0
	end

	if cooling_valve_pos == 0 then
		if TOTAL_pack_status == 1 then
			A333_cold_air_valve = 0
		elseif TOTAL_pack_status ~= 1 then
			A333_cold_air_valve = 1
		end
	elseif cooling_valve_pos ~= 0 and cooling_valve_pos ~= 2 and cooling_valve_mid == 0 then
		A333_cold_air_valve = 2
	elseif cooling_valve_mid == 1 then
		if TOTAL_pack_status == 1 then
			A333_cold_air_valve = 2
		elseif TOTAL_pack_status ~= 1 then
			A333_cold_air_valve = 3
		end
	elseif cooling_valve_pos == 2 then
		if TOTAL_pack_status == 1 then
			A333_cold_air_valve = 4
		elseif TOTAL_pack_status ~= 1 then
			A333_cold_air_valve = 5
		end
	end

	bulk_temp_differential = bulk_cargo_temperature_target - A333_bulk_cargo_temp_ind
	cargo_temp_differential = cargo_temperature_target - A333_cargo_temp_ind
	zone1_differential = cockpit_temperature_target - A333_cockpit_temp_ind
	zone2_differential = cabin_temperature_fwd_target - A333_cabin_fwd_temp_ind
	zone3_differential = (cabin_temperature_fwd_target * 0.667 + cabin_temperature_mid_target * 0.333) - A333_cabin_fwd_mid_temp_ind
	zone4_differential = (cabin_temperature_fwd_target * 0.333 + cabin_temperature_mid_target * 0.667) - A333_cabin_mid_fwd_temp_ind
	zone5_differential = cabin_temperature_mid_target - A333_cabin_mid_temp_ind
	zone6_differential = (cabin_temperature_mid_target * 0.5 + cabin_temperature_aft_target * 0.5) - A333_cabin_mid_aft_temp_ind
	zone7_differential = cabin_temperature_aft_target - A333_cabin_aft_temp_ind

	local ckpt_ex_lo = A333_rescale(-1, -67, 1, -40, A333_cockpit_temp_knob_pos)
	local ckpt_ex_hi = A333_rescale(-1, 63, 1, 90, A333_cockpit_temp_knob_pos)
	local cabin_ex_lo = A333_rescale(-1, -67, 1, -40, A333_cabin_temp_knob_pos)
	local cabin_ex_hi = A333_rescale(-1, 63, 1, 90, A333_cabin_temp_knob_pos)
	local cargo_ex_lo = A333_rescale(-1, -67, 1, -40, A333_fwd_cargo_temp_knob_pos)
	local cargo_ex_hi = A333_rescale(-1, 63, 1, 90, A333_fwd_cargo_temp_knob_pos)

	local cockpit_needle_extra = A333_rescale(ckpt_ex_lo, -1, ckpt_ex_hi, 1, (cockpit_temperature_target - simDR_TAT))
	local cabin_fwd_needle_extra = A333_rescale(cabin_ex_lo, -1, cabin_ex_hi, 1, (cabin_temperature_fwd_target - simDR_TAT))
	local cabin_mid_needle_extra = A333_rescale(cabin_ex_lo, -1, cabin_ex_hi, 1, (cabin_temperature_mid_target - simDR_TAT))
	local cabin_aft_needle_extra = A333_rescale(cabin_ex_lo, -1, cabin_ex_hi, 1, (cabin_temperature_aft_target - simDR_TAT))
	local cargo_needle_extra = A333_rescale(cargo_ex_lo, -1, cargo_ex_hi, 1, (cargo_temperature_target - simDR_TAT))

	A333_bulk_needle = A333_set_animation_position(A333_bulk_needle, A333_bulk_cargo_temp_knob_pos, -1, 1, 2)

	if A333_hot_air_loop1_status == 1 then
		zone2_needle_target = A333_rescale(-10, -1, 10, 1, zone2_differential) + cabin_fwd_needle_extra
		zone5_needle_target = A333_rescale(-10, -1, 10, 1, zone5_differential) + cabin_mid_needle_extra
		zone7_needle_target = A333_rescale(-10, -1, 10, 1, zone7_differential) + cabin_aft_needle_extra

		if A333_cargo_cooling_mode_pos >= 1 then
			cargo_temp_needle_target = A333_rescale(-10, -1, 10, 1, cargo_temp_differential) + cargo_needle_extra
		elseif A333_cargo_cooling_mode_pos == 0 then
			cargo_temp_needle_target = 0
		end

	elseif A333_hot_air_loop1_status == 0 then
		zone2_needle_target = 0
		zone5_needle_target = 0
		zone7_needle_target = 0
		cargo_temp_needle_target = 0
	end

	if A333_hot_air_loop2_status == 1 then
		zone1_needle_target = A333_rescale(-10, -1, 10, 1, zone1_differential) + cockpit_needle_extra
		zone3_needle_target = A333_rescale(-10, -1, 10, 1, zone3_differential) + cabin_fwd_needle_extra
		zone4_needle_target = A333_rescale(-10, -1, 10, 1, zone4_differential) + cabin_mid_needle_extra
		zone6_needle_target = A333_rescale(-10, -1, 10, 1, zone6_differential) + cabin_aft_needle_extra
	elseif A333_hot_air_loop2_status == 0 then
		zone1_needle_target = 0
		zone3_needle_target = 0
		zone4_needle_target = 0
		zone6_needle_target = 0
	end

	A333_zone1_needle = A333_set_animation_position(A333_zone1_needle, zone1_needle_target, -1, 1, 2)
	A333_zone2_needle = A333_set_animation_position(A333_zone2_needle, zone2_needle_target, -1, 1, 2)
	A333_zone3_needle = A333_set_animation_position(A333_zone3_needle, zone3_needle_target, -1, 1, 2)
	A333_zone4_needle = A333_set_animation_position(A333_zone4_needle, zone4_needle_target, -1, 1, 2)
	A333_zone5_needle = A333_set_animation_position(A333_zone5_needle, zone5_needle_target, -1, 1, 2)
	A333_zone6_needle = A333_set_animation_position(A333_zone6_needle, zone6_needle_target, -1, 1, 2)
	A333_zone7_needle = A333_set_animation_position(A333_zone7_needle, zone7_needle_target, -1, 1, 2)
	A333_cargo_needle = A333_set_animation_position(A333_cargo_needle, cargo_temp_needle_target, -1, 1, 2)

	if bulk_rate == 0.001 then
		A333_bulk_duct_temp = A333_set_animation_position(A333_bulk_duct_temp, A333_bulk_cargo_temp_ind + 3, -40, 50, bulk_rate * 10)
	elseif bulk_rate == 0.01 then
		A333_bulk_duct_temp = A333_set_animation_position(A333_bulk_duct_temp, (A333_bulk_cargo_temp_ind + A333_rescale(-1, bulk_temp_differential, 1, bulk_temp_differential * 2, A333_bulk_needle)) + 3, -40, 50, bulk_rate * 10)
	end

	local zone1_duct_temp_target = 0.1 * A333_pack2_outlet_temp + A333_rescale(-1, A333_cockpit_temp_ind - 18, 1, A333_cockpit_temp_ind + 15, A333_zone1_needle)
	local zone2_duct_temp_target = 0.1 * A333_pack1_outlet_temp + A333_rescale(-1, A333_cabin_fwd_temp_ind - 18, 1, A333_cabin_fwd_temp_ind + 15, A333_zone2_needle)
	local zone3_duct_temp_target = 0.1 * A333_pack2_outlet_temp + A333_rescale(-1, A333_cabin_fwd_mid_temp_ind - 18, 1, A333_cabin_fwd_mid_temp_ind + 15, A333_zone3_needle)
	local zone4_duct_temp_target = 0.1 * A333_pack2_outlet_temp + A333_rescale(-1, A333_cabin_mid_fwd_temp_ind - 18, 1, A333_cabin_mid_fwd_temp_ind + 15, A333_zone4_needle)
	local zone5_duct_temp_target = 0.1 * A333_pack1_outlet_temp + A333_rescale(-1, A333_cabin_mid_temp_ind - 18, 1, A333_cabin_mid_temp_ind + 15, A333_zone5_needle)
	local zone6_duct_temp_target = 0.1 * A333_pack2_outlet_temp + A333_rescale(-1, A333_cabin_mid_aft_temp_ind - 18, 1, A333_cabin_mid_aft_temp_ind + 15, A333_zone6_needle)
	local zone7_duct_temp_target = 0.1 * A333_pack1_outlet_temp + A333_rescale(-1, A333_cabin_aft_temp_ind - 18, 1, A333_cabin_aft_temp_ind + 15, A333_zone7_needle)

	local cargo_duct_temp_target = 0.1 * A333_pack1_outlet_temp + A333_rescale(-1, A333_cargo_temp_ind - 18, 1, A333_cargo_temp_ind + 15, A333_cargo_needle)

	A333_zone1_duct_temp = A333_set_animation_position(A333_zone1_duct_temp, zone1_duct_temp_target, A333_pack2_outlet_temp - 10, 99, 2)
	A333_zone2_duct_temp = A333_set_animation_position(A333_zone2_duct_temp, zone2_duct_temp_target, A333_pack1_outlet_temp - 10, 99, 2)
	A333_zone3_duct_temp = A333_set_animation_position(A333_zone3_duct_temp, zone3_duct_temp_target, A333_pack2_outlet_temp - 10, 99, 2)
	A333_zone4_duct_temp = A333_set_animation_position(A333_zone4_duct_temp, zone4_duct_temp_target, A333_pack2_outlet_temp - 10, 99, 2)
	A333_zone5_duct_temp = A333_set_animation_position(A333_zone5_duct_temp, zone5_duct_temp_target, A333_pack1_outlet_temp - 10, 99, 2)
	A333_zone6_duct_temp = A333_set_animation_position(A333_zone6_duct_temp, zone6_duct_temp_target, A333_pack2_outlet_temp - 10, 99, 2)
	A333_zone7_duct_temp = A333_set_animation_position(A333_zone7_duct_temp, zone7_duct_temp_target, A333_pack1_outlet_temp - 10, 99, 2)

	A333_cargo_duct_temp = A333_rescale(2, 2, 100, 100, A333_set_animation_position(A333_cargo_duct_temp, cargo_duct_temp_target, A333_pack1_outlet_temp - 10, 99, 2))


end

---- ECAM DOORS PAGE

local slides_armed = 0

function A333_ecam_page_DOORS()

	if simDR_oxygen_on == 0 then
		A333_cockpit_oxy_status = 0
		A333_regul_lo_pr_status = 1
	elseif simDR_oxygen_on == 1 then
		if simDR_ox_psi >= 400 then
			A333_cockpit_oxy_status = 1
		elseif simDR_ox_psi < 400 then
			A333_cockpit_oxy_status = 0
		end
		if simDR_ox_psi >= 50 then
			A333_regul_lo_pr_status = 0
		elseif simDR_ox_psi < 50 then
			A333_regul_lo_pr_status = 1
		end
	end

	if A333_flight_phase <= 1 or A333_flight_phase == 10 then
		slides_armed = 0
	elseif A333_flight_phase > 1 and A333_flight_phase < 10 then
		slides_armed = 1
	end

	if simDR_door_ratio[0] == 0 then
		if slides_armed == 0 then
			A333_slide1_status = -1
		elseif slides_armed == 1 then
			A333_slide1_status = 1
		end
	elseif simDR_door_ratio[0] ~= 0 then
		A333_slide1_status = 0
	end

	if simDR_door_ratio[1] == 0 then
		if slides_armed == 0 then
			A333_slide2_status = -1
		elseif slides_armed == 1 then
			A333_slide2_status = 1
		end
	elseif simDR_door_ratio[1] ~= 0 then
		A333_slide2_status = 0
	end

	if simDR_door_ratio[2] == 0 then
		if slides_armed == 0 then
			A333_slide3_status = -1
		elseif slides_armed == 1 then
			A333_slide3_status = 1
		end
	elseif simDR_door_ratio[2] ~= 0 then
		A333_slide3_status = 0
	end

	if simDR_door_ratio[3] == 0 then
		if slides_armed == 0 then
			A333_slide4_status = -1
		elseif slides_armed == 1 then
			A333_slide4_status = 1
		end
	elseif simDR_door_ratio[3] ~= 0 then
		A333_slide4_status = 0
	end

	if simDR_door_ratio[4] == 0 then
		if slides_armed == 0 then
			A333_slide5_status = -1
		elseif slides_armed == 1 then
			A333_slide5_status = 1
		end
	elseif simDR_door_ratio[4] ~= 0 then
		A333_slide5_status = 0
	end

	if simDR_door_ratio[5] == 0 then
		if slides_armed == 0 then
			A333_slide6_status = -1
		elseif slides_armed == 1 then
			A333_slide6_status = 1
		end
	elseif simDR_door_ratio[5] ~= 0 then
		A333_slide6_status = 0
	end

	if simDR_door_ratio[6] == 0 then
		if slides_armed == 0 then
			A333_slide7_status = -1
		elseif slides_armed == 1 then
			A333_slide7_status = 1
		end
	elseif simDR_door_ratio[6] ~= 0 then
		A333_slide7_status = 0
	end

	if simDR_door_ratio[7] == 0 then
		if slides_armed == 0 then
			A333_slide8_status = -1
		elseif slides_armed == 1 then
			A333_slide8_status = 1
		end
	elseif simDR_door_ratio[7] ~= 0 then
		A333_slide8_status = 0
	end


end

---- ENGINES


function A333_engine_power_setting_indicator()

	max_throttle_mode = math.max(simDR_fadec_power_mode_eng1, simDR_fadec_power_mode_eng2) -- 0 = NONE, 1 = CLB, 2 = MCT/FLX, 3 - TOGA

    -- A333_ECAM_thrust_mode: -- 0 = climb, 1 = MCT, 2 = FLEX, 3 = TOGA

	if simDR_gear_on_ground == 1 then

		if max_throttle_mode < 3 then

			if flex_mode == 0 then
				A333_ECAM_thrust_mode = 3
				A333_ECAM_thrust_limit_EPR = simDR_fadec_engine_limits_toga
			elseif flex_mode == 1 then
				A333_ECAM_thrust_mode = 2
				A333_ECAM_thrust_limit_EPR = simDR_fadec_engine_limits_mct_flx
			end

		elseif max_throttle_mode == 3 then
			A333_ECAM_thrust_mode = 3
			A333_ECAM_thrust_limit_EPR = simDR_fadec_engine_limits_toga
		end

	elseif simDR_gear_on_ground == 0 then
		if max_throttle_mode <= 1 then
			A333_ECAM_thrust_mode = 0
			A333_ECAM_thrust_limit_EPR = simDR_fadec_engine_limits_clb
		elseif max_throttle_mode == 2 then
			A333_ECAM_thrust_limit_EPR = simDR_fadec_engine_limits_mct_flx
			if flex_mode == 1 then
				A333_ECAM_thrust_mode = 2
			elseif flex_mode == 0 then
				A333_ECAM_thrust_mode = 1
			end
		elseif max_throttle_mode == 3 then
			A333_ECAM_thrust_mode = 3
			A333_ECAM_thrust_limit_EPR = simDR_fadec_engine_limits_toga
		end
	end


end

function A333_fuel_totalizer_reset()

	if simDR_eng1_N2 > 30 or simDR_eng2_N2 > 30 then
	elseif simDR_eng1_N2 <= 30 and simDR_eng2_N2 <= 30 then

		if A333_flight_phase == 1 then
			if simDR_engine1_starter_running == 1 or simDR_engine2_starter_running == 1 then
				simDR_fuel_burned_eng1 = 0
				simDR_fuel_burned_eng2 = 0
				simDR_fuel_burned_total = 0
			elseif simDR_engine1_starter_running == 0 and simDR_engine2_starter_running == 0 then
			end
		elseif A333_flight_phase ~= 1 then
		end

	end

end

---- ENGINE IDLE MODE ---------------------------------------------------------------------

function A333_ground_timer()

	if simDR_gear_on_ground == 1
		and simDR_prop_mode0 == 1
		and simDR_prop_mode1 == 1 then
		ground_timer = ground_timer + SIM_PERIOD
	elseif simDR_gear_on_ground == 0 then
		ground_timer = 0
	end

end

function A333_idle_mode_logic()

	local air_mode = 1

	if simDR_gear_on_ground == 0 then
		air_mode = 1
	elseif simDR_gear_on_ground == 1
		and ground_timer > 5 then
		air_mode = 0
	end


	--- ENGINE GROUND / FLIGHT IDLE ---

	if air_mode == 0 then
		simDR_low_idle = LOW_IDLE_PLN_TARGET
		simDR_high_idle = LOW_IDLE_PLN_TARGET
	elseif air_mode == 1 then
		simDR_low_idle = HIGH_IDLE_PLN_TARGET
		simDR_high_idle = HIGH_IDLE_PLN_TARGET
	end



end



----- PFD INDICATORS --------------------------------------------------------------------

function A333_FPV_calculations()

	A333_fpv_pitch_absolute_capt = simDR_AHARS_pitch_capt - simDR_alpha
	A333_fpv_pitch_absolute_fo = simDR_AHARS_pitch_FO - simDR_alpha

	A333_birdie_pitch_absolute_capt = simDR_fd_pitch_capt - simDR_alpha
	A333_birdie_pitch_absolute_fo = simDR_AHARS_pitch_FO - simDR_fd_pitch_fo + A333_fpv_pitch_absolute_fo

end

local min_weight_speeds = 0
local max_weight_speeds = 0
local flap_factor_min = 0
local flap_factor_max = 0
local climb_clean_config_flag = 0
local G_factor = 0

function A333_vspeeds()

	if off_ground_timer < 10 then
		if simDR_gear_on_ground == 0 then
			off_ground_timer = off_ground_timer + SIM_PERIOD
		elseif simDR_gear_on_ground == 1 then
			off_ground_timer = 0
		end
	elseif off_ground_timer >= 10 then
		if simDR_gear_on_ground == 0 then
			off_ground_timer = 10
		elseif simDR_gear_on_ground == 1 then
			off_ground_timer = 0
		end
	end

	A333_gear_off_ground_timer = off_ground_timer

	A333_mach_ias_ratio = simDR_mmo_in_kias / Mmo

	if simDR_mmo_in_kias > Vmo then
		A333_over_speed_ind = (Vmo + 6)

		if simDR_flap_config == 0 then
			if simDR_gear_handle == 0 then
				A333_vmo_mmo_ias = Vmo
			elseif simDR_gear_handle > 0 then
				A333_vmo_mmo_ias = Vle
			end

		elseif simDR_flap_config == 1 then
			A333_vmo_mmo_ias = Vfe_1
		elseif simDR_flap_config == 2 then
			A333_vmo_mmo_ias = Vfe_1f
		elseif simDR_flap_config == 3 then
			A333_vmo_mmo_ias = Vfe_1_star
		elseif simDR_flap_config == 4 then
			A333_vmo_mmo_ias = Vfe_2
		elseif simDR_flap_config == 5 then
			A333_vmo_mmo_ias = Vfe_2_star
		elseif simDR_flap_config == 6 then
			A333_vmo_mmo_ias = Vfe_3
		elseif simDR_flap_config == 7 then
			A333_vmo_mmo_ias = Vfe_full
		end

	elseif simDR_mmo_in_kias <= Vmo then
		A333_over_speed_ind = A333_mach_ias_ratio * (Mmo + 0.01)

		if simDR_flap_config == 0 then

			if simDR_gear_handle == 0 then
				A333_vmo_mmo_ias = simDR_mmo_in_kias
			elseif simDR_gear_handle > 0 then
				if simDR_mmo_in_kias > Vle then
					A333_vmo_mmo_ias = Vle
				elseif simDR_mmo_in_kias <= Vle then
					A333_vmo_mmo_ias = simDR_mmo_in_kias
				end
			end

		elseif simDR_flap_config == 1 then
			A333_vmo_mmo_ias = Vfe_1
		elseif simDR_flap_config == 2 then
			A333_vmo_mmo_ias = Vfe_1f
		elseif simDR_flap_config == 3 then
			A333_vmo_mmo_ias = Vfe_1_star
		elseif simDR_flap_config == 4 then
			A333_vmo_mmo_ias = Vfe_2
		elseif simDR_flap_config == 5 then
			A333_vmo_mmo_ias = Vfe_2_star
		elseif simDR_flap_config == 6 then
			A333_vmo_mmo_ias = Vfe_3
		elseif simDR_flap_config == 7 then
			A333_vmo_mmo_ias = Vfe_full
		end

	end

	if simDR_flap_handle_request == 0 then
		if simDR_airspeed >= 100 then
			A333_next_flap_speed_ind = Vfe_1
		elseif simDR_airspeed < 100 then
			A333_next_flap_speed_ind = Vfe_1f
		end
	elseif simDR_flap_handle_request > 0 and simDR_flap_handle_request <= 0.251 then
		if takeoff_landing_index == 0 then
			A333_next_flap_speed_ind = Vfe_2
		elseif takeoff_landing_index == 1 then
			A333_next_flap_speed_ind = Vfe_1_star
		end
	elseif simDR_flap_handle_request > 0.251 and simDR_flap_handle_request <= 0.501 then
		A333_next_flap_speed_ind = Vfe_3
	elseif simDR_flap_handle_request > 0.501 and simDR_flap_handle_request <= 0.751 then
		A333_next_flap_speed_ind = Vfe_full
	elseif simDR_flap_handle_request > 0.751 then
		A333_next_flap_speed_ind = 9999
	end

end



local capt_airspeed_conversion = 0
local fo_airspeed_conversion = 0

function A333_PFD_indicators()

	local ils_flasher = 0
	local sim_time_factor4 = math.fmod(simDR_flight_time, 0.65)

	if sim_time_factor4 >= 0 and sim_time_factor4 <= 0.3 then
		ils_flasher = 1
	end

	local windshear_flasher = 0
	local ws_ahead_flasher = 0
	local sim_time_factor5 = math.fmod(simDR_flight_time, 0.75)

	if sim_time_factor5 >= 0 and sim_time_factor5 <= 0.3 then
		ws_ahead_flasher = 1
		windshear_flasher = 1
	end

	if simDR_windshear_mode < 3 then
		windshear_timer = 0
		ws_ahead_timer = 0
	elseif simDR_windshear_mode == 3 or simDR_windshear_mode == 4 then
		windshear_timer = 0
		if ws_ahead_timer < 5 then
			ws_ahead_timer = ws_ahead_timer + SIM_PERIOD
		else ws_ahead_timer = 5
		end
	elseif simDR_windshear_mode == 5 then
		ws_ahead_timer = 0
		if windshear_timer < 5 then
			windshear_timer = windshear_timer + SIM_PERIOD
		else windshear_timer = 5
		end
	end

	if ws_ahead_timer < 5 then
		A333_ws_ahead_flasher = A333_set_animation_position(A333_ws_ahead_flasher, ws_ahead_flasher, 0, 1, 10)
	elseif ws_ahead_timer == 5 then
		A333_ws_ahead_flasher = 1
	end

	if windshear_timer < 5 then
		A333_windshear_flasher = A333_set_animation_position(A333_windshear_flasher, windshear_flasher, 0, 1, 10)
	elseif windshear_timer == 5 then
		A333_windshear_flasher = 1
	end


	if simDR_AHARS_pitch_capt <= 17.5 then
		A333_ladder_mask_deg_capt = A333_rescale(3, simDR_AHARS_pitch_capt, 120, 17.5, simDR_radio_altimeter_capt)
	elseif simDR_AHARS_pitch_capt > 17.5 then
		A333_ladder_mask_deg_capt = 17.5
	end

	if simDR_AHARS_pitch_FO <= 17.5 then
		A333_ladder_mask_deg_FO = A333_rescale(3, simDR_AHARS_pitch_FO, 120, 17.5, simDR_radio_altimeter_FO)
	elseif simDR_AHARS_pitch_FO > 17.5 then
		A333_ladder_mask_deg_FO = 17.5
	end

	if simDR_AHARS_pitch_capt <= A333_ladder_mask_deg_capt then
		A333_tick_mark_mode_capt = 0
	elseif simDR_AHARS_pitch_capt > A333_ladder_mask_deg_capt then
		A333_tick_mark_mode_capt = 1
	end

	if simDR_AHARS_pitch_FO <= A333_ladder_mask_deg_FO then
		A333_tick_mark_mode_FO = 0
	elseif simDR_AHARS_pitch_FO > A333_ladder_mask_deg_FO then
		A333_tick_mark_mode_FO = 1
	end

	if simDR_eng1_N1 >= 20 or simDR_eng2_N1 >= 20 then
		A333_engines_running = 1
	elseif simDR_eng1_N1 < 20 and simDR_eng2_N1 < 20 then
		A333_engines_running = 0
	end

	if simDR_radio_altimeter_capt >= 2500 then
		if simDR_vvi_capt < 6000 and simDR_vvi_capt > -6000 then
			A333_vvi_capt_amber = 0
		elseif simDR_vvi_capt >= 6000 or simDR_vvi_capt <= -6000 then
			A333_vvi_capt_amber = 1
		end
	elseif simDR_radio_altimeter_capt < 2500 and simDR_radio_altimeter_capt >= 1000 then
		if simDR_vvi_capt < 6000 and simDR_vvi_capt > -2000 then
			A333_vvi_capt_amber = 0
		elseif simDR_vvi_capt >= 6000 or simDR_vvi_capt <= -2000 then
			A333_vvi_capt_amber = 1
		end
	elseif simDR_radio_altimeter_capt < 1000 then
		if simDR_vvi_capt < 6000 and simDR_vvi_capt > -1200 then
			A333_vvi_capt_amber = 0
		elseif simDR_vvi_capt >= 6000 or simDR_vvi_capt <= -1200 then
			A333_vvi_capt_amber = 1
		end
	end

	if simDR_radio_altimeter_FO >= 2500 then
		if simDR_vvi_FO < 6000 and simDR_vvi_FO > -6000 then
			A333_vvi_FO_amber = 0
		elseif simDR_vvi_FO >= 6000 or simDR_vvi_FO <= -6000 then
			A333_vvi_FO_amber = 1
		end
	elseif simDR_radio_altimeter_FO < 2500 and simDR_radio_altimeter_FO >= 1000 then
		if simDR_vvi_FO < 6000 and simDR_vvi_FO > -2000 then
			A333_vvi_FO_amber = 0
		elseif simDR_vvi_FO >= 6000 or simDR_vvi_FO <= -2000 then
			A333_vvi_FO_amber = 1
		end
	elseif simDR_radio_altimeter_FO < 1000 then
		if simDR_vvi_FO < 6000 and simDR_vvi_FO > -1200 then
			A333_vvi_FO_amber = 0
		elseif simDR_vvi_FO >= 6000 or simDR_vvi_FO <= -1200 then
			A333_vvi_FO_amber = 1
		end
	end

	-- AUTOPILOT ALT SHOW/HIDE

	-- CYAN

	if simDR_altitude_sel >= simDR_capt_altitude - 568 and simDR_altitude_sel <= simDR_capt_altitude + 568 then
		A333_capt_autopilot_alt_mode = 0
	elseif simDR_altitude_sel > simDR_capt_altitude + 568 then
		A333_capt_autopilot_alt_mode = 1
	elseif simDR_altitude_sel < simDR_capt_altitude - 568 then
		A333_capt_autopilot_alt_mode = -1
	end

	if simDR_altitude_sel >= simDR_fo_altitude - 568 and simDR_altitude_sel <= simDR_fo_altitude + 568 then
		A333_fo_autopilot_alt_mode = 0
	elseif simDR_altitude_sel > simDR_fo_altitude + 568 then
		A333_fo_autopilot_alt_mode = 1
	elseif simDR_altitude_sel < simDR_fo_altitude - 568 then
		A333_fo_autopilot_alt_mode = -1
	end

	-- MAGENTA

	if simDR_autopilot_vnav_alt_sel >= simDR_capt_altitude - 568 and simDR_autopilot_vnav_alt_sel <= simDR_capt_altitude + 568 then
		A333_capt_autopilot_vnav_alt_mode = 0
	elseif simDR_autopilot_vnav_alt_sel > simDR_capt_altitude + 568 then
		A333_capt_autopilot_vnav_alt_mode = 1
	elseif simDR_autopilot_vnav_alt_sel < simDR_capt_altitude - 568 then
		A333_capt_autopilot_vnav_alt_mode = -1
	end

	if simDR_autopilot_vnav_alt_sel >= simDR_fo_altitude - 568 and simDR_autopilot_vnav_alt_sel <= simDR_fo_altitude + 568 then
		A333_fo_autopilot_vnav_alt_mode = 0
	elseif simDR_autopilot_vnav_alt_sel > simDR_fo_altitude + 568 then
		A333_fo_autopilot_vnav_alt_mode = 1
	elseif simDR_autopilot_vnav_alt_sel < simDR_fo_altitude - 568 then
		A333_fo_autopilot_vnav_alt_mode = -1
	end


	if simDR_altv_armed == 1 or simDR_altv_captured == 1 then
		A333_ap_alt_ind_color = 1
	elseif simDR_altv_armed == 0 and simDR_altv_captured == 0 then
		A333_ap_alt_ind_color = 0
	end


	-- ALTITUDE CONVERSION

	if simDR_capt_airspeed <= 30 then
		capt_airspeed_conversion = 30
	elseif simDR_capt_airspeed > 30 then
		capt_airspeed_conversion = simDR_capt_airspeed
	end

	if simDR_fo_airspeed <= 30 then
		fo_airspeed_conversion = 30
	elseif simDR_fo_airspeed > 30 then
		fo_airspeed_conversion = simDR_fo_airspeed
	end

	-- AUTOPILOT IAS SHOW/HIDE

	if simDR_autopilot_ias_sel >= capt_airspeed_conversion - 41.9047619048 and simDR_autopilot_ias_sel <= capt_airspeed_conversion + 41.9047619048 then
		A333_capt_autopilot_speed_mode = 0
	elseif simDR_autopilot_ias_sel > capt_airspeed_conversion + 41.9047619048 then
		A333_capt_autopilot_speed_mode = 1
	elseif simDR_autopilot_ias_sel < capt_airspeed_conversion - 41.9047619048 then
		A333_capt_autopilot_speed_mode = -1
	end

	if simDR_autopilot_ias_sel >= fo_airspeed_conversion - 41.9047619048 and simDR_autopilot_ias_sel <= fo_airspeed_conversion + 41.9047619048 then
		A333_fo_autopilot_speed_mode = 0
	elseif simDR_autopilot_ias_sel > fo_airspeed_conversion + 41.9047619048 then
		A333_fo_autopilot_speed_mode = 1
	elseif simDR_autopilot_ias_sel < fo_airspeed_conversion - 41.9047619048 then
		A333_fo_autopilot_speed_mode = -1
	end

	-- GREEN DOT SPEED SHOW/HIDE

	if simDR_airspeed_bugs[5] >= capt_airspeed_conversion - 41.9047619048 and simDR_airspeed_bugs[5] <= capt_airspeed_conversion + 41.9047619048 then
		A333_capt_green_dot_mode = 0
	elseif simDR_airspeed_bugs[5] > capt_airspeed_conversion + 41.9047619048 then
		A333_capt_green_dot_mode = 1
	elseif simDR_airspeed_bugs[5] < capt_airspeed_conversion - 41.9047619048 then
		A333_capt_green_dot_mode = -1
	end

	if simDR_airspeed_bugs[5] >= fo_airspeed_conversion - 41.9047619048 and simDR_airspeed_bugs[5] <= fo_airspeed_conversion + 41.9047619048 then
		A333_fo_green_dot_mode = 0
	elseif simDR_airspeed_bugs[5] > fo_airspeed_conversion + 41.9047619048 then
		A333_fo_green_dot_mode = 1
	elseif simDR_airspeed_bugs[5] < fo_airspeed_conversion - 41.9047619048 then
		A333_fo_green_dot_mode = -1
	end

	-- Vr SPEED SHOW/HIDE

	if simDR_airspeed_bugs[1] >= capt_airspeed_conversion - 41.9047619048 and simDR_airspeed_bugs[1] <= capt_airspeed_conversion + 41.9047619048 then
		A333_capt_Vr_mode = 0
	elseif simDR_airspeed_bugs[1] > capt_airspeed_conversion + 41.9047619048 then
		A333_capt_Vr_mode = 1
	elseif simDR_airspeed_bugs[1] < capt_airspeed_conversion - 41.9047619048 then
		A333_capt_Vr_mode = -1
	end

	if simDR_airspeed_bugs[1] >= fo_airspeed_conversion - 41.9047619048 and simDR_airspeed_bugs[1] <= fo_airspeed_conversion + 41.9047619048 then
		A333_fo_Vr_mode = 0
	elseif simDR_airspeed_bugs[1] > fo_airspeed_conversion + 41.9047619048 then
		A333_fo_Vr_mode = 1
	elseif simDR_airspeed_bugs[1] < fo_airspeed_conversion - 41.9047619048 then
		A333_fo_Vr_mode = -1
	end

	-- V1 SPEED SHOW/HIDE

	if simDR_airspeed_bugs[0] >= capt_airspeed_conversion - 41.9047619048 and simDR_airspeed_bugs[0] <= capt_airspeed_conversion + 41.9047619048 then
		A333_capt_V1_mode = 0
	elseif simDR_airspeed_bugs[0] > capt_airspeed_conversion + 41.9047619048 then
		A333_capt_V1_mode = 1
	elseif simDR_airspeed_bugs[0] < capt_airspeed_conversion - 41.9047619048 then
		A333_capt_V1_mode = -1
	end

	if simDR_airspeed_bugs[0] >= fo_airspeed_conversion - 41.9047619048 and simDR_airspeed_bugs[0] <= fo_airspeed_conversion + 41.9047619048 then
		A333_fo_V1_mode = 0
	elseif simDR_airspeed_bugs[0] > fo_airspeed_conversion + 41.9047619048 then
		A333_fo_V1_mode = 1
	elseif simDR_airspeed_bugs[0] < fo_airspeed_conversion - 41.9047619048 then
		A333_fo_V1_mode = -1
	end

	-- ILS WARNING FLASHER

	if simDR_approach_status >= 1 and simDR_ian_mode == 0 then
		if A333_ls_bars_capt == 0 then
			A333_ils_flasher_capt_status = 1
		elseif A333_ls_bars_capt == 1 then
			A333_ils_flasher_capt_status = 0
		end
		if A333_ls_bars_fo == 0 then
			A333_ils_flasher_fo_status = 1
		elseif A333_ls_bars_fo == 1 then
			A333_ils_flasher_fo_status = 0
		end
	elseif simDR_approach_status == 0 or simDR_ian_mode ~= 0 then
		A333_ils_flasher_capt_status = 0
		A333_ils_flasher_fo_status = 0
	end

	A333_ils_flasher_capt = A333_set_animation_position(A333_ils_flasher_capt, ils_flasher, 0, 1, 10)
	A333_ils_flasher_fo = A333_set_animation_position(A333_ils_flasher_fo, ils_flasher, 0, 1, 10)


	if simDR_ian_mode > 0 then
		if A333_ls_bars_capt == 1 then
			A333_vdev_flasher_capt_status = 1
		elseif A333_ls_bars_capt == 0 then
			A333_vdev_flasher_capt_status = 0
		end
		if A333_ls_bars_fo == 1 then
			A333_vdev_flasher_fo_status = 1
		elseif A333_ls_bars_fo == 0 then
			A333_vdev_flasher_fo_status = 0
		end
	elseif simDR_ian_mode == 0 then
		A333_vdev_flasher_capt_status = 0
		A333_vdev_flasher_fo_status = 0
	end

	A333_vdev_flasher_capt = A333_set_animation_position(A333_vdev_flasher_capt, ils_flasher, 0, 1, 10)
	A333_vdev_flasher_fo = A333_set_animation_position(A333_vdev_flasher_fo, ils_flasher, 0, 1, 10)


	-- DH RADIO ALTIMETER COLOR

	if simDR_radio_alt_bug_capt == -1 then
		A333_radio_altimeter_color_capt = 0
	elseif simDR_radio_alt_bug_capt == 0 then
		if simDR_radio_altimeter_capt <= 400 then
			A333_radio_altimeter_color_capt = 1
		elseif  simDR_radio_altimeter_capt > 400 then
			A333_radio_altimeter_color_capt = 0
		end
	elseif simDR_radio_alt_bug_capt > 0 then
		if simDR_radio_altimeter_capt <= (simDR_radio_alt_bug_capt + 100) then
			A333_radio_altimeter_color_capt = 1
		elseif  simDR_radio_altimeter_capt > (simDR_radio_alt_bug_capt + 100) then
			A333_radio_altimeter_color_capt = 0
		end
	end

	if simDR_radio_alt_bug_fo == -1 then
		A333_radio_altimeter_color_fo = 0
	elseif simDR_radio_alt_bug_fo == 0 then
		if simDR_radio_altimeter_FO <= 400 then
			A333_radio_altimeter_color_fo = 1
		elseif simDR_radio_altimeter_FO > 400 then
			A333_radio_altimeter_color_fo = 0
		end
	elseif simDR_radio_alt_bug_fo > 0 then
		if simDR_radio_altimeter_FO <= (simDR_radio_alt_bug_fo + 100) then
			A333_radio_altimeter_color_fo = 1
		elseif simDR_radio_altimeter_FO > (simDR_radio_alt_bug_fo + 100) then
			A333_radio_altimeter_color_fo = 0
		end
	end

	-- MDA ALT COLOR CHANGE

	if simDR_capt_altitude >= simDR_mda_capt then
		A333_mda_altimeter_color_capt = 0
	elseif simDR_capt_altitude < simDR_mda_capt then
		A333_mda_altimeter_color_capt = 1
	end

	if simDR_fo_altitude >= simDR_mda_fo then
		A333_mda_altimeter_color_fo = 0
	elseif simDR_fo_altitude < simDR_mda_fo then
		A333_mda_altimeter_color_fo = 1
	end

	-- AUTOPILOT HEADING LOCK

	simDR_autopilot_hdg_sel_fo = simDR_autopilot_hdg_sel

end

function A333_flight_directors()

	-- YAW BAR SHOW HIDE

		if simDR_radio_altimeter_capt > 30 then
			A333_flight_dir_bar_status_capt = 0
		elseif simDR_radio_altimeter_capt <= 30 then
			if simDR_nav_horz_sig[0] == 1 then
				if simDR_runway_status == 2 or simDR_flare_status == 2 or simDR_rollout_status == 2 then
					A333_flight_dir_bar_status_capt = 1
				elseif simDR_runway_status ~= 2 and simDR_flare_status ~= 2 and simDR_rollout_status ~= 2 then
					A333_flight_dir_bar_status_capt = 0
				end
			elseif simDR_nav_horz_sig[0] == 0 then
				A333_flight_dir_bar_status_capt = 0
			end
		end

		if simDR_radio_altimeter_FO > 30 then
			A333_flight_dir_bar_status_fo = 0
		elseif simDR_radio_altimeter_FO <= 30 then
			if simDR_nav_horz_sig[1] == 1 then
				if simDR_runway_status == 2 or simDR_flare_status == 2 or simDR_rollout_status == 2 then
					A333_flight_dir_bar_status_fo = 1
				elseif simDR_runway_status ~= 2 and simDR_flare_status ~= 2 and simDR_rollout_status ~= 2 then
					A333_flight_dir_bar_status_fo = 0
				end
			elseif simDR_nav_horz_sig[1] == 0 then
				A333_flight_dir_bar_status_fo = 0
			end
		end


	-- FD VERTICAL SHOW HIDE


		if simDR_gear_on_ground == 1 then
			if simDR_altitude_mode ~= 3 then

				if simDR_rollout_status == 0 then
					A333_flight_dir_vrt_status_capt = 1
					A333_flight_dir_vrt_status_fo = 1
				elseif simDR_rollout_status == 2 then
					A333_flight_dir_vrt_status_capt = 0
					A333_flight_dir_vrt_status_fo = 0
				end

			elseif simDR_altitude_mode == 3 then
				A333_flight_dir_vrt_status_capt = 0
				A333_flight_dir_vrt_status_fo = 0
			end
		elseif simDR_gear_on_ground == 0 then
			A333_flight_dir_vrt_status_capt = 1
			A333_flight_dir_vrt_status_fo = 1
		end

	-- FD HORIZONTAL SHOW HIDE

		if simDR_runway_status == 2 then
			A333_flight_dir_lat_status_capt = 0
			A333_flight_dir_lat_status_fo = 0
		elseif simDR_runway_status == 0 then
			if simDR_gear_on_ground == 1 then
				if simDR_heading_mode ~= 21 and simDR_heading_mode ~= 0 then
					A333_flight_dir_lat_status_capt = 1
					A333_flight_dir_lat_status_fo = 1
				elseif simDR_heading_mode == 21 or simDR_heading_mode == 0 then
					A333_flight_dir_lat_status_capt = 0
					A333_flight_dir_lat_status_fo = 0
				end
			elseif simDR_gear_on_ground == 0 then
				A333_flight_dir_lat_status_capt = 1
				A333_flight_dir_lat_status_fo = 1
			end
		end


end


local dh_capt_flash_timer = 0
local dh_fo_flash_timer = 0

function A333_DH_flashers()

	-- DH FLASHERS

	if simDR_dh_lit_capt == 0 then
		dh_capt_flash_timer = 0
	elseif simDR_dh_lit_capt == 1 then
		if dh_capt_flash_timer < 3 then
			dh_capt_flash_timer = dh_capt_flash_timer + SIM_PERIOD
		elseif dh_capt_flash_timer > 3 then
			dh_capt_flash_timer = 3
		end
	end

	if simDR_dh_lit_fo == 0 then
		dh_fo_flash_timer = 0
	elseif simDR_dh_lit_fo == 1 then
		if dh_fo_flash_timer < 3 then
			dh_fo_flash_timer = dh_fo_flash_timer + SIM_PERIOD
		elseif dh_fo_flash_timer > 3 then
			dh_fo_flash_timer = 3
		end
	end

	local dh_capt_flasher_target = 0
	local dh_fo_flasher_target = 0

	local dh_capt_factor = math.fmod(dh_capt_flash_timer, 0.75)
	local dh_fo_factor = math.fmod(dh_fo_flash_timer, 0.75)

	if dh_capt_factor >= 0 and dh_capt_factor <= 0.3 then
		if dh_capt_flash_timer == 0 then
			dh_capt_flasher_target = 0
		else dh_capt_flasher_target = 1
		end
	elseif dh_capt_factor > 0.3 and dh_capt_factor < 0.75 then
		dh_capt_flasher_target = 0
	end

	if dh_fo_factor >= 0 and dh_fo_factor <= 0.3 then
		if dh_fo_flash_timer == 0 then
			dh_fo_flasher_target = 0
		else dh_fo_flasher_target = 1
		end
	elseif dh_fo_factor > 0.3 and dh_fo_factor < 0.75 then
		dh_fo_flasher_target = 0
	end

	A333_dh_flasher_capt = A333_set_animation_position(A333_dh_flasher_capt, dh_capt_flasher_target, 0, 1, 10)
	A333_dh_flasher_fo = A333_set_animation_position(A333_dh_flasher_fo, dh_fo_flasher_target, 0, 1, 10)


end

function A333_display_power()

	if simDR_bus1_power >= 110 or simDR_bus2_power >= 110 or simDR_ess_bus_power >= 110 then
		A333_PFD_ND_has_power = 1
	elseif simDR_bus1_power < 110 and simDR_bus2_power < 110 and simDR_ess_bus_power < 110 then
		A333_PFD_ND_has_power = 0
	end

end

function A333_InstrumentVisibility()

	A333_ap_heading_mode_capt = SetInstrumentVisibilty(simDR_autopilot_hdg_sel, simDR_capt_AHARS_heading)
	A333_ap_heading_mode_fo = SetInstrumentVisibilty(simDR_autopilot_hdg_sel, simDR_fo_AHARS_heading)
	A333_track_mode_capt = SetInstrumentVisibilty(simDR_capt_track_heading, simDR_capt_AHARS_heading)
	A333_track_mode_fo = SetInstrumentVisibilty(simDR_fo_track_heading, simDR_fo_AHARS_heading)
	A333_ils_mode_capt = SetInstrumentVisibilty(simDR_capt_ils_heading, simDR_capt_AHARS_heading)
	A333_ils_mode_fo = SetInstrumentVisibilty(simDR_fo_ils_heading, simDR_fo_AHARS_heading)
	A333_tru_track_mode_capt = SetInstrumentVisibilty(simDR_capt_track_tru_heading, simDR_capt_AHARS_heading)
	A333_tru_track_mode_fo = SetInstrumentVisibilty(simDR_fo_track_tru_heading, simDR_fo_AHARS_heading)

end

function SetInstrumentVisibilty(instHeading, aharsHeading)
	return GetInstrumentHideShowValue(instHeading, AdjustHeadingToNeg180Range(aharsHeading))
end

function GetInstrumentHideShowValue(instHeading, aharsHdg180)
	local delta = GetHeadingDelta(instHeading, aharsHdg180)
	local bearing180PosNeg = AdjustHeadingDeltaToPosNeg180(delta)
	return SetHideShowValue(bearing180PosNeg)
end

function AdjustHeadingToNeg180Range(aharsHeading)
	return ternary(aharsHeading > 180.0 and aharsHeading < 360.0, aharsHeading - 360.0, aharsHeading)
end

function GetHeadingDelta(instHeading, aharsHdg180)
	return instHeading - aharsHdg180
end

function AdjustHeadingDeltaToPosNeg180(delta)
	return ternary(delta > 180.0, delta - 360.0, delta)
end

function SetHideShowValue(bearing)
	return ternary(bearing >= -23.75 and bearing <= 23.75, 0, SetLeftOrRight(bearing))
end

function SetLeftOrRight(bearing)
	return ternary(bearing < 0.0, -1, 1)
end



function A333_FMAs()

	local pfd_flasher = 0
	local sim_time_factor3 = math.fmod(simDR_flight_time, 0.7)

	if sim_time_factor3 >= 0 and sim_time_factor3 <= 0.3 then
		pfd_flasher = 1
	end


	-- SINGLE ENGINE STATUS

	if simDR_eng1_N2 >= 5 then
		if simDR_eng2_N2 >= 5 then
			single_engine_status = 0
		elseif simDR_eng2_N2 < 5 then
			single_engine_status = 1
		end
	elseif simDR_eng1_N2 < 5 then
		if simDR_eng2_N2 >= 5 then
			single_engine_status = 1
		elseif simDR_eng2_N2 < 5 then
			single_engine_status = 0
		end
	end

	if simDR_capt_fd_on == 0 and simDR_fo_fd_on == 0 then
		A333_FD_modes = 0
	elseif simDR_capt_fd_on == 1 and simDR_fo_fd_on == 0 then
		A333_FD_modes = 1
	elseif simDR_capt_fd_on == 0 and simDR_fo_fd_on == 1 then
		A333_FD_modes = 2
	elseif simDR_capt_fd_on == 1 and simDR_fo_fd_on == 1 then
		A333_FD_modes = 3
	end

	if simDR_autopilot_1_on == 0 and simDR_autopilot_2_on == 0 then
		A333_AP_modes = 0
	elseif simDR_autopilot_1_on == 1 and simDR_autopilot_2_on == 0 then
		A333_AP_modes = 1
	elseif simDR_autopilot_1_on == 0 and simDR_autopilot_2_on == 1 then
		A333_AP_modes = 2
	elseif simDR_autopilot_1_on == 1 and simDR_autopilot_2_on == 1 then
		A333_AP_modes = 3
	end

	if simDR_altitude_sel - simDR_capt_altitude >= 250 then
		A333_climb_descend = 1
	elseif simDR_altitude_sel - simDR_capt_altitude <= -250 then
		A333_climb_descend = -1
	end


	-- NEW LOGIC 9/26/22:
	-- THIS NEW LOGIC SETS 'ALTITUDE ACQUIRE MODE' (Dataref = A333_alt_star_status).

	-- THE LOGIC PREVENTS 'ALTITUDE ACQUIRE MODE' FROM BEING TURNED ON WHEN
	-- THE AIRCRAFT DEVIATES FROM A PREVIOUSLY 'CAPTURED' ALTITUDE UNTIL THE
	-- HOLD STATUS IS NO LONGER "CAPTURED"

	local altDelta = math.abs(simDR_altitude_hold - simDR_capt_altitude)

	if simDR_altitude_hold_status < 2 then		-- OFF OR ARMED
		altCaptured = 0

	elseif simDR_altitude_hold_status == 2 then	-- CAPTURED
		if altCaptured == 0 then
			if altDelta <= 20.0 then
				A333_alt_star_status = 0 		-- ALT or ALT CST
				altCaptured = 1
			else
				A333_alt_star_status = 1		-- ALT* or ALT CST*
			end
		end
	end




	-- VDEF STAR

	if simDR_altitude_mode == 8 then										-- TIMER KILLED, REPLACED WITH ABSOLUTE VALUE OF VNAV DOTS PILOT / COPILOT

		if simDR_autopilot_status_capt >= 1 then
			if math.abs(simDR_vdef_dots_capt) <= 0.5 then
				gsCaptured = 1
			end
		elseif simDR_autopilot_status_capt == 0 then
			if simDR_autopilot_status_fo >= 1 then
				if math.abs(simDR_vdef_dots_fo) <= 0.5 then
					gsCaptured = 1
				end
			elseif simDR_autopilot_status_fo == 0 then
				gsCaptured = 0
			end
		end

	elseif simDR_altitude_mode ~= 8 then
		gsCaptured = 0
	end

	A333_gs_star_status = gsCaptured





	-- HDEF STAR

	if simDR_heading_mode == 2 then

		if simDR_autopilot_status_capt >= 1 then
			if math.abs(simDR_hdef_dots_capt) <= 0.5 then
				locCaptured = 1
			end
		elseif simDR_autopilot_status_capt == 0 then
			if simDR_autopilot_status_fo >= 1 then
				if math.abs(simDR_hdef_dots_fo) <= 0.5 then
					locCaptured = 1
				end
			elseif simDR_autopilot_status_fo == 0 then
				locCaptured = 0
			end
		end

	elseif simDR_heading_mode ~= 2 then
		locCaptured = 0
	end

	A333_loc_star_status = locCaptured

	-- GA_TRK

	if simDR_altitude_mode == 10 and simDR_heading_mode == 18 then
		A333_ga_trk_status = 1
	elseif simDR_altitude_mode ~= 10 or simDR_heading_mode ~= 18 then
		A333_ga_trk_status = 0
	end


	-- ALT ARM CONDITIONS

	if simDR_altitude_mode == 9 or simDR_altitude_mode == 20 then
		A333_alt_arm_status = 0
	elseif simDR_altitude_mode ~= 9 and simDR_altitude_mode ~= 20 then
		A333_alt_arm_status = 1
	end

	-- DH/MDA SHOW CONDITIONS

	if A333_flight_phase == 6 or A333_flight_phase == 7 then
		A333_dh_mda_status = 1
	elseif A333_flight_phase ~= 6 and A333_flight_phase ~= 7 then
		A333_dh_mda_status = 0
	end

	-- FINAL APPROACH STATUS

	if simDR_autopilot_status_capt >= 1 then
		if simDR_gps1_cdi_sense >= 5 and simDR_ian_mode == 2 then
			if simDR_approach_status == 2 and simDR_glideslope_status == 2 then
				A333_final_app_status = 1
			else A333_final_app_status = 0
			end
		else A333_final_app_status = 0
		end
	elseif simDR_autopilot_status_capt == 0 then
		if simDR_autopilot_status_fo >= 1 then
			if simDR_gps2_cdi_sense >= 5 and simDR_ian_mode == 2 then
				if simDR_approach_status == 2 and simDR_glideslope_status == 2 then
					A333_final_app_status = 1
				else A333_final_app_status = 0
				end
			else A333_final_app_status = 0
			end
		else A333_final_app_status = 0
		end
	end


	-- LANDING CAT

	if simDR_approach_status == 2 and simDR_ian_mode == 0 then
		if simDR_AP1_status == 0 and simDR_AP2_status == 0 then
			A333_landing_category_enum = 0
			A333_single_dual_mode = 0
		elseif simDR_AP1_status == 1 and simDR_AP2_status == 0 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 0
		elseif simDR_AP1_status == 0 and simDR_AP2_status == 1 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 0
		elseif simDR_AP1_status == 1 and simDR_AP2_status == 1 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 0
		elseif simDR_AP1_status == 2 and simDR_AP2_status == 1 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 1
		elseif simDR_AP1_status == 1 and simDR_AP2_status == 2 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 1
		elseif simDR_AP1_status == 2 and simDR_AP2_status == 2 then
			A333_landing_category_enum = 3
			A333_single_dual_mode = 2
		elseif simDR_AP1_status == 2 and simDR_AP2_status == 0 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 1
		elseif simDR_AP1_status == 0 and simDR_AP2_status == 2 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 1
		end
	elseif simDR_approach_status < 2 or simDR_ian_mode > 0 then
		A333_landing_category_enum = 0
		A333_single_dual_mode = 0
	end


	-- MULTI COLUMN FMAS

	if A333_flight_phase <= 5 then
		if simDR_autothrottle_mode >= 0 then
			if simDR_ias_mach_ind == 0 then
				A333_row3_speed_ias = 1
			elseif simDR_ias_mach_ind == 1 then
				A333_row3_speed_ias = 0
			end
		elseif simDR_autothrottle_mode < 0 then
			A333_row3_speed_ias = 0
		end
	elseif A333_flight_phase > 5 then
		A333_row3_speed_ias = 0
	end

	if A333_flight_phase <= 6 then
		if simDR_autothrottle_mode >= 0 then
			if simDR_ias_mach_ind == 1 then
				if math.abs(simDR_autopilot_speed_set - simDR_mach_captain_ind) < 0.01 then
					A333_row3_speed_mach = 0
				elseif math.abs(simDR_autopilot_speed_set - simDR_mach_captain_ind) >= 0.01 then
					A333_row3_speed_mach = 1
				end
			elseif simDR_ias_mach_ind == 0 then
				A333_row3_speed_mach = 0
			end
		elseif simDR_autothrottle_mode < 0 then
			A333_row3_speed_mach = 0
		end
	elseif A333_flight_phase > 6 then
		A333_row3_speed_mach = 0
	end

	if A333_row3_speed_ias == 1 or A333_row3_speed_mach == 1 then
		A333_column1_2_divider = 1
	elseif A333_row3_speed_ias == 0 and A333_row3_speed_mach == 0 then
		A333_column1_2_divider = 0
	end

	-- SET GREEN DOT SPEED FMA

	if single_engine_status == 1 and simDR_vnav_speed_window_open == 1 then
		if simDR_airspeed_bugs[5] - simDR_autopilot_speed_set >= 10 then
			A333_set_green_dot_spd = 1
		elseif simDR_airspeed_bugs[5] - simDR_autopilot_speed_set <= -10 then
			if simDR_altitude_mode ~= 6 then
				A333_set_green_dot_spd = 1
			elseif simDR_altitude_mode == 6 then
				A333_set_green_dot_spd = 0
			end
		elseif math.abs(simDR_airspeed_bugs[5] - simDR_autopilot_speed_set) < 10 then
			A333_set_green_dot_spd = 0
		end
	elseif single_engine_status == 0 or simDR_vnav_speed_window_open == 0 then
		A333_set_green_dot_spd = 0
	end

	-- MAN PITCH TRIM ONLY FMA

	local left_elev_fail = 0
	local right_elev_fail = 0

	if simDR_fail_fcon_elev_lft_lock == 6 or
		simDR_fail_fcon_elev_lft_mxdn == 6 or
		simDR_fail_fcon_elev_lft_mxup == 6 or
		simDR_fail_fcon_elev_lft_cntr == 6 or
		simDR_fail_fcon_elev_lft_gone == 6 then
		left_elev_fail = 1
	else left_elev_fail = 0
	end

	if simDR_fail_fcon_elev_rgt_lock == 6 or
		simDR_fail_fcon_elev_rgt_mxdn == 6 or
		simDR_fail_fcon_elev_rgt_mxup == 6 or
		simDR_fail_fcon_elev_rgt_cntr == 6 or
		simDR_fail_fcon_elev_rgt_gone == 6 then
		right_elev_fail = 1
	else right_elev_fail = 0
	end

	if simDR_fail_elev_U == 6 or simDR_fail_elev_D == 6 then
		A333_man_pitch_trim_only = 1
	elseif simDR_fail_elev_U ~= 6 and simDR_fail_elev_D ~= 6 then
		if left_elev_fail == 1 and right_elev_fail == 1 then
			A333_man_pitch_trim_only = 1
		elseif left_elev_fail == 0 or right_elev_fail == 0 then
			A333_man_pitch_trim_only = 0
		end
	end



	-- AUTO THROTTLE FMAS

    --[[
    if simDR_throttle_loc_eng1 == 3 or simDR_throttle_loc_eng2 == 3 then
		A333_man_toga = 1
	elseif simDR_throttle_loc_eng1 ~= 3 and simDR_throttle_loc_eng2 ~= 3 then
		A333_man_toga = 0
	end

	if A333_man_toga == 1 then
		A333_man_mct = 0
		A333_man_flex = 0
	elseif A333_man_toga == 0 then
		if simDR_throttle_loc_eng1 == 2 or simDR_throttle_loc_eng2 == 2 then
			if flex_mode == 0 then
				A333_man_mct = 1
				A333_man_flex = 0
			elseif flex_mode == 1 then
				A333_man_mct = 0
				A333_man_flex = 1
			end
		elseif simDR_throttle_loc_eng1 ~= 2 and simDR_throttle_loc_eng2 ~= 2 then
			A333_man_mct = 0
			A333_man_flex = 0
		end
	end
	--]]


    local man_mct = 0
    local man_flex = 0
    local man_toga = 0

    if simDR_fadec_power_mode_eng1 == 3 or simDR_fadec_power_mode_eng2 == 3 then	-- toga
        man_toga = 1

    elseif simDR_fadec_power_mode_eng1 == 2 or simDR_fadec_power_mode_eng2 == 2 then	-- mct/flex
        man_mct = 1 - flex_mode
        man_flex = flex_mode

    end

    A333_man_mct = man_mct
    A333_man_flex = man_flex
    A333_man_toga = man_toga






    -- ADD MAN THR HERE -- DEFER FOR NOW

	if single_engine_status == 1 then													-- ALL OF THESE NEED TO HAVE AUTOTHROTTLE ACTIVE CONDITION
		if simDR_throttle_loc_eng1 == 2 or simDR_throttle_loc_eng2 == 2 then			-- sim/cockpit2/autopilot/autothrottle_enabled >= 1 (its set in Plane Maker)
			A333_thr_mct = 1
		elseif simDR_throttle_loc_eng1 ~= 2 and simDR_throttle_loc_eng2 ~= 2 then
			A333_thr_mct = 0
		end
	elseif single_engine_status == 0 then
		A333_thr_mct = 0
	end

	if simDR_throttle_loc_eng1 == 1 or simDR_throttle_loc_eng2 == 1 then
		if simDR_throttle_loc_eng1 <= 1 and simDR_throttle_loc_eng2 <= 1 then
			A333_thr_clb = 1
		elseif simDR_throttle_loc_eng1 > 1 or simDR_throttle_loc_eng2 > 1 then
			A333_thr_clb = 0
		end
	elseif simDR_throttle_loc_eng1 ~= 1 and simDR_throttle_loc_eng2 ~= 1 then
		A333_thr_clb = 0
	end

	if simDR_throttle_loc_eng1 == simDR_throttle_loc_eng2 then

		if simDR_throttle_loc_eng1 == 0 and simDR_throttle_loc_eng2 == 0 and simDR_throttle1_pos > 0.1 and simDR_throttle2_pos > 0.1 then
			A333_thr_lvr = 1
		else
			A333_thr_lvr = 0
		end

	elseif simDR_throttle_loc_eng1 ~= simDR_throttle_loc_eng2 then

		if simDR_throttle_loc_eng1 == 1 then
			if simDR_throttle_loc_eng2 >= 2 then
				A333_thr_lvr = 1
			elseif simDR_throttle_loc_eng2 == 0 then
				A333_thr_lvr = 0
			end
		elseif simDR_throttle_loc_eng2 == 1 then
			if simDR_throttle_loc_eng1 >= 2 then
				A333_thr_lvr = 1
			elseif simDR_throttle_loc_eng1 == 0 then
				A333_thr_lvr = 0
			end
		elseif simDR_throttle_loc_eng1 ~= 1 and simDR_throttle_loc_eng2 ~= 1 then
			A333_thr_lvr = 0
		end

	end
	if simDR_autothrottle_mode == 1 then
		A333_thr_lvr = 0
	end


	if single_engine_status == 0 and simDR_autothrottle_mode >= 1 then
		if simDR_throttle_loc_eng1 == simDR_throttle_loc_eng2 then
			A333_lvr_assym = 0
		elseif simDR_throttle_loc_eng1 ~= simDR_throttle_loc_eng2 then				-- CHECK THAT EXACTLY ONE LEVER IS IN ENGINE MODE 0 or 3

			if simDR_throttle_loc_eng1 == 0 or simDR_throttle_loc_eng1 == 3 then
				if simDR_throttle_loc_eng2 == 1 or simDR_throttle_loc_eng2 == 2 then
					A333_lvr_assym = 1
				elseif simDR_throttle_loc_eng2 == 0 or simDR_throttle_loc_eng2 == 3 then
					A333_lvr_assym = 0
				end
			elseif simDR_throttle_loc_eng1 == 1 or simDR_throttle_loc_eng1 == 2 then
				if simDR_throttle_loc_eng2 == 0 or simDR_throttle_loc_eng2 == 3 then
					A333_lvr_assym = 1
				elseif simDR_throttle_loc_eng2 == 1 or simDR_throttle_loc_eng2 == 2 then
					A333_lvr_assym = 0
				end
			end

		end
	elseif single_engine_status == 1 or simDR_autothrottle_mode < 1 then
		A333_lvr_assym = 0
	end


	-- LVR CLB/MCT

	A333_lvr_clb_mct_flasher = A333_set_animation_position(A333_lvr_clb_mct_flasher, pfd_flasher, 0, 1, 10)

	if (simDR_vnav_speed_status == 2 and simDR_autothrottle_mode > -1) or simDR_autothrottle_mode > 0 then
		if single_engine_status == 0 then
			if (simDR_throttle_loc_eng1 >= 2 and simDR_throttle_loc_eng2 >= 2) or simDR_throttle_loc_eng1 == 0 or simDR_throttle_loc_eng2 == 0 then
				A333_lvr_clb_status = 1
				A333_lvr_mct_status = 0
			else
				A333_lvr_clb_status = 0
			end
		elseif single_engine_status == 1 then
			if (simDR_throttle_loc_eng1 == 3 or simDR_throttle_loc_eng2 == 3) or simDR_throttle_loc_eng1 == 0 or simDR_throttle_loc_eng2 == 0 then
				A333_lvr_mct_status = 1
				A333_lvr_clb_status = 0
			else
				A333_lvr_mct_status = 0
			end
		end
	else
		A333_lvr_mct_status = 0
		A333_lvr_clb_status = 0
	end


end

function A333_gps_info_show()

	if simDR_gps1_bearing == 0 and
		simDR_gps1_dme_distance == 0 and
		simDR_gps1_dme_speed == 0 and
		simDR_gps1_dme_time == 0 then
		A333_capt_gps_active_status = 0
	elseif simDR_gps1_bearing > 0 or
		simDR_gps1_dme_distance > 0 or
		simDR_gps1_dme_speed > 0 or
		simDR_gps1_dme_time > 0 then
		A333_capt_gps_active_status = 1
	end

	if simDR_gps2_bearing == 0 and
		simDR_gps2_dme_distance == 0 and
		simDR_gps2_dme_speed == 0 and
		simDR_gps2_dme_time == 0 then
		A333_fo_gps_active_status = 0
	elseif simDR_gps2_bearing > 0 or
		simDR_gps2_dme_distance > 0 or
		simDR_gps2_dme_speed > 0 or
		simDR_gps2_dme_time > 0 then
		A333_fo_gps_active_status = 1
	end

end

function A333_sidestick_priority()

	if simDR_priority_side == 0 then
		A333_composite_stick_pitch = A333_rescale(-1, -1, 1, 1, (simDR_capt_pitch_ratio + simDR_fo_pitch_ratio))
		A333_composite_stick_roll = A333_rescale(-1, -1, 1, 1, (simDR_capt_roll_ratio + simDR_fo_roll_ratio))
	elseif simDR_priority_side == 1 then
		A333_composite_stick_pitch = simDR_capt_pitch_ratio
		A333_composite_stick_roll = simDR_capt_roll_ratio
	elseif simDR_priority_side == 2 then
		A333_composite_stick_pitch = simDR_fo_pitch_ratio
		A333_composite_stick_roll = simDR_fo_roll_ratio
	end


	-- SIDESTICK DUAL INPUT
	if math.abs(simDR_capt_pitch_ratio) < 0.125 and math.abs(simDR_capt_roll_ratio) < 0.1 then
		A333_capt_zeroed = 1
	elseif math.abs(simDR_capt_pitch_ratio) >= 0.125 or math.abs(simDR_capt_roll_ratio) >= 0.1 then
		A333_capt_zeroed = 0
	end

	if math.abs(simDR_fo_pitch_ratio) < 0.125 and math.abs(simDR_fo_roll_ratio) < 0.1 then
		A333_fo_zeroed = 1
	elseif math.abs(simDR_fo_pitch_ratio) >= 0.125 or math.abs(simDR_fo_roll_ratio) >= 0.1 then
		A333_fo_zeroed = 0
	end

	if A333_capt_zeroed == 0 and A333_fo_zeroed == 0 then
		if simDR_priority_side == 0 then
			A333_dual_input = 1
		else A333_dual_input = 0
		end
	else A333_dual_input = 0
	end


	-- SIDESTICK PRIORITY (RED ARROW ANNUN LIGHT)
	if simDR_priority_side == 1 then
		A333_capt_priority_arrow = 0
		A333_fo_priority_arrow = 1
	elseif simDR_priority_side == 2 then
		A333_capt_priority_arrow = 1
		A333_fo_priority_arrow = 0
	elseif simDR_priority_side == 0 then
		A333_capt_priority_arrow = 0
		A333_fo_priority_arrow = 0
	end


	-- SIDESTICK PRIORITY (CAPT/FO GREEN LIGHT)
	if simDR_priority_side == 0 then
		if A333_dual_input == 1 then
			A333_capt_priority_light = 1
			A333_fo_priority_light = 1
		elseif A333_dual_input == 0 then
			A333_capt_priority_light = 0
			A333_fo_priority_light = 0
		end
	elseif simDR_priority_side == 1 then
		A333_fo_priority_light = 0
		if A333_fo_zeroed == 0 then
			A333_capt_priority_light = 1
		elseif A333_fo_zeroed == 1 then
			A333_capt_priority_light = 0
		end
	elseif simDR_priority_side == 2 then
		A333_capt_priority_light = 0
		if A333_capt_zeroed == 0 then
			A333_fo_priority_light = 1
		elseif A333_capt_zeroed == 1 then
			A333_fo_priority_light = 0
		end
	end


end






function A333_baro_warning_brightness()

    local bright = false

    if simDR_barometer_setting_warn_pilot == 1
        or simDR_barometer_setting_warn_copilot == 1
    then
        local time = math.fmod(simDR_flight_time, 1.0)
        bright = time > 0.5 and time <= 1.0
    end
    
    A333DR_baro_warning_brightness = bool2num[bright]

end









----- ND NAV RAD FREQ ID ----------------------------------------------------------------
function A333_ND_nav_rad_ID()

	-- VOR RADIOS
	--[[A333_nd_vor1_ID_flag_capt = 1
	if string.byte(simDR_nav1_ID) and string.byte(simDR_dme1_ID) == nil then
		A333_nd_vor1_ID_flag_capt = 0
	elseif string.byte(simDR_nav1_ID) or string.byte(simDR_dme1_ID) ~= nil then
		if simDR_nav1_type ~= 4 and simDR_nav1_type ~= 1024 then
			A333_nd_vor1_ID_flag_capt = 0
		elseif simDR_nav1_type == 4 or simDR_nav1_type == 1024 then
			A333_nd_vor1_ID_flag_capt = 1
		end
	end

	A333_nd_vor2_ID_flag_capt = 1
	if string.byte(simDR_nav2_ID) and string.byte(simDR_dme2_ID) == nil then
		A333_nd_vor2_ID_flag_capt = 0
	elseif string.byte(simDR_nav2_ID) or string.byte(simDR_dme2_ID) ~= nil then
		if simDR_nav2_type ~= 4 and simDR_nav2_type ~= 1024 then
			A333_nd_vor2_ID_flag_capt = 0
		elseif simDR_nav2_type == 4 or simDR_nav2_type == 1024 then
			A333_nd_vor2_ID_flag_capt = 1
		end
	end--]]

	local vor1ID_is_valid = #simDR_nav1_ID > 0 and simDR_nav1_type == 4
	local dme1ID_is_valid = #simDR_dme1_ID > 0 and simDR_nav1_type == 1024

	local vor2ID_is_valid = #simDR_nav2_ID > 0 and simDR_nav2_type == 4
	local dme2ID_is_valid = #simDR_dme2_ID > 0 and simDR_nav2_type == 1024

	A333_nd_vor1_ID_flag_capt = bool2num[vor1ID_is_valid or dme1ID_is_valid]
	A333_nd_vor2_ID_flag_capt = bool2num[vor2ID_is_valid or dme2ID_is_valid]




	-- ADF RADIOS
	--[[A333_nd_adf1_ID_flag_capt = 1
	if string.byte(simDR_adf1_ID) == nil then
		A333_nd_adf1_ID_flag_capt = 0
	end

	A333_nd_adf2_ID_flag_capt = 1
	if string.byte(simDR_adf2_ID) == nil then
		A333_nd_adf2_ID_flag_capt = 0
	end--]]

	A333_nd_adf1_ID_flag_capt = bool2num[#simDR_adf1_ID > 0]
	A333_nd_adf2_ID_flag_capt = bool2num[#simDR_adf2_ID > 0]

end




local total_gps_seconds = 0
local total_gps2_seconds = 0
local gps_seconds = 0
local gps2_seconds = 0

function A333_ND_GPS_dme_time()

	A333_gps_dme_time_min = math.floor(simDR_gps1_dme_time)
	A333_gps2_dme_time_min = math.floor(simDR_gps2_dme_time)

	total_gps_seconds = simDR_gps1_dme_time * 60
	total_gps2_seconds = simDR_gps2_dme_time * 60

	gps_seconds = math.fmod(total_gps_seconds, 60)
	gps2_seconds = math.fmod(total_gps2_seconds, 60)

	A333_gps_dme_time_sec = math.floor(gps_seconds)
	A333_gps2_dme_time_sec = math.floor(gps2_seconds)

end

----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function A333_systems_monitor_AI()

	if A333DR_init_systems_CD == 1 then
		A333_set_systems_all_modes()
		A333_set_systems_CD()
		A333DR_init_systems_CD = 2
	end

end

----- SET STATE FOR ALL MODES -----------------------------------------------------------
function A333_set_systems_all_modes()

	A333DR_init_systems_CD = 0
	simDR_center_pack = 0
	A333_elt_switch_pos = 0
	elt_annun = 0
	simDR_number_plugged_in_o2 = 2

	simDR_door1L = 4.5
	simDR_door2L = 4.5
	simDR_door3L = 4.5
	simDR_door4L = 4.5
	simDR_door1R = 4.5
	simDR_door2R = 4.5
	simDR_door3R = 4.5
	simDR_door4R = 4.5
	simDR_doorC1 = 15
	simDR_doorC2 = 15
	simDR_doorC3 = 4
	simDR_door_cockpit = 1.5

	simDR_engine1_igniter = 0
	simDR_engine2_igniter = 0

	simDR_map_range[0] = 10
	simDR_map_range[1] = 20
	simDR_map_range[2] = 40
	simDR_map_range[3] = 80
	simDR_map_range[4] = 160
	simDR_map_range[5] = 320
	simDR_map_range[6] = 640
	simDR_map_range[7] = 0

	simDR_HSI_pilot = 0
	simDR_HSI_copilot = 1

end

----- SET STATE TO COLD & DARK ----------------------------------------------------------
function A333_set_systems_CD()


end

----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
function A333_set_systems_ER()


end

----- FLIGHT START ---------------------------------------------------------------------
function A333_flight_start_systems()

	-- ALL MODES ------------------------------------------------------------------------
	A333_set_systems_all_modes()

	A333_cockpit_temp_ind = simDR_TAT + A333_rescale(-30, 35, 30, 5, simDR_TAT) + cockpit_random_fac
	A333_cabin_fwd_temp_ind = simDR_TAT + A333_rescale(-30, 35, 30, 5, simDR_TAT) + cabin_fwd_random_fac
	A333_cabin_mid_temp_ind = simDR_TAT + A333_rescale(-30, 35, 30, 5, simDR_TAT) + cabin_mid_random_fac
	A333_cabin_aft_temp_ind = simDR_TAT + A333_rescale(-30, 35, 30, 5, simDR_TAT) + cabin_aft_random_fac
	A333_cargo_temp_ind = simDR_TAT + A333_rescale(-30, 25, 30, 5, simDR_TAT) + cargo_random_fac
	A333_bulk_cargo_temp_ind = simDR_TAT + A333_rescale(-30, 20, 30, 5, simDR_TAT) + cargo_bulk_random_fac

	A333_bulk_duct_temp = A333_bulk_cargo_temp_ind + 3

	compensated_TAT_left = simDR_TAT
	compensated_TAT_right = simDR_TAT

	A333_precooler1_temp = simDR_TAT
	A333_precooler2_temp = simDR_TAT
	A333_pack1_compressor_outlet_temp = simDR_TAT + 5
	A333_pack2_compressor_outlet_temp = simDR_TAT + 5
	A333_pack1_outlet_temp = simDR_TAT + 4
	A333_pack2_outlet_temp = simDR_TAT + 4

	A333_laminar_no_ref = 0

	-- COLD & DARK ----------------------------------------------------------------------
	if simDR_startup_running == 0 then

		A333_set_systems_CD()


		-- ENGINES RUNNING ------------------------------------------------------------------
	elseif simDR_startup_running == 1 then

		A333_set_systems_ER()

	end

end


--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

function A333_ALL_systems()

	A333_systems_monitor_AI()
	A333_duct_isol_valves()
	A333_pack_flow()
	A333_fuel_system()
	A333_elt()
	A333_ADIRS()
	A333_anti_skid_auto_off()
	A333_control_surface_depress_droop()
	--A333_FADEC_limits_set()
    A333_flex_mode()
    A333_engine_limits()
    A333_starter_torque()
	A333_ECAM()
	A333_engine_power_setting_indicator()
	A333_interior_temps()
	A333_ecam_page_APU()
	A333_ecam_page_HYD()
	A333_ecam_page_FCTL()
	A333_ecam_page_DOORS()
	A333_ecam_page_WHEELS_brake_temps()
	A333_ecam_page_WHEELS()
	A333_ecam_page_CAB_PRESS()
	A333_ecam_page_BLEED()
	A333_ecam_page_COND()
	A333_FPV_calculations()
	A333_PFD_indicators()
	A333_flight_directors()
	A333_DH_flashers()
	A333_InstrumentVisibility()
	A333_display_power()
	A333_FMAs()
	A333_ND_nav_rad_ID()
	A333_ND_GPS_dme_time()
	A333_gps_info_show()
	A333_fuel_totalizer_reset()
	A333_vspeeds()
	A333_ground_timer()
	A333_idle_mode_logic()
	A333_sidestick_priority()
    A333_baro_warning_brightness()

end

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

	A333_flight_start_systems()

end

--function flight_crash() end

--function before_physics()

function after_physics()

	A333_ALL_systems()

end

function after_replay()

	A333_ALL_systems()

end


