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
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--
-- Read initial values from PlaneMaker instead of hardcoding them... this fails on new flight start - we're writing to both of these targets in the script
local LOW_IDLE_PLN_TARGET = 0.56
local HIGH_IDLE_PLN_TARGET = 1.3
local STARTER_TORQUE_PLN_VALUE = 0



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local m = math
local bool2num = {[true] = 1, [false] = 0}




_, frac = m.modf(os.clock())
seed = m.random(1, frac * 1000.0)
m.randomseed(seed)

local lcl = {
    
	fadec1_pwr_ac2 = 0,
	fadec1_pwr_ess = 0,
	fadec2_pwr_ac2 = 0,
	fadec2_pwr_ess = 0,
    fadec1_ground_timer = 0,
    fadec2_ground_timer = 0,
    
    bleed_mode_factor_left = 0,
    bleed_mode_factor_right = 0,
    
    pack1_flow_target = 0,
    pack2_flow_target = 0,
    pack1_flow_ratio = 0,
    pack2_flow_ratio = 0,
    --pack_flow_mode = 0,
    pack1_exhaust_target = 0,
    pack2_exhaust_target = 0,
    
    trim_tank_fuel_qty = 0,
    center_tank_fuel_qty = 0,
    left_aux_tank_fuel_qty = 0,
    right_aux_tank_fuel_qty = 0,
    left_wing_tank_fuel_qty = 0,
    right_wing_tank_fuel_qty = 0,
    
    center_left_transfer_enum = 0,
    center_right_transfer_enum = 0,
    tank_transfer_left = 0,
    tank_transfer_right = 0,
    
    elt_trigger = 0,
    elt_annun = 0,
    elt_sweep = 0,
	elt_timer_trigger = 0,
	elt_timer = 0,
	elt_sequence_timer = 0,
	elt_sequence_timer_shutdown = 0,
    IR1_mode = 0,
    IR2_mode = 0,
    
    idle_flasher = 0,
    idle_timer = 0,
  	eng1_avail_flasher = 0,
	eng1_avail_timer = 0,
	eng2_avail_flasher = 0,
	eng2_avail_timer = 0,
  
  	tcas_flasher = 0,
  	tcas_timer = 0,
    
    --takeoff_mode = 0,
    flex_mode_is_available = true,
    flex_mode = 0,
    max_throttle_mode = 0,
    
    apu_psi_target = 0,
    volts_rand = 0,
    hertz_rand = 0,
    volts_rand2 = 0,
    hertz_rand2 = 0,
    volts_rand3 = 0,
    hertz_rand3 = 0,
    volts_rand4 = 0,
    hertz_rand4 = 0,
    volts_rand5 = 0,
    hertz_rand5 = 0,
    volts_rand6 = 0,
    hertz_rand6 = 0,
    calculated_EGT_lim = 0,
    idg1_temp_target = 0,
    idg2_temp_target = 0,
    dc_ess_bat_feed = 0,
    
    wheel_brake_temp1 = 0,
    wheel_brake_temp2 = 0,
    wheel_brake_temp3 = 0,
    wheel_brake_temp4 = 0,
    wheel_brake_temp5 = 0,
    wheel_brake_temp6 = 0,
    wheel_brake_temp7 = 0,
    wheel_brake_temp8 = 0,
    compensated_TAT_left = 0,
    compensated_TAT_left_target = 0,
    compensated_TAT_right = 0,
    compensated_TAT_right_target = 0,
    
    green_hyd_pressure_store = 0,
    yellow_hyd_pressure_store = 0,
    blue_hyd_pressure_store = 0,
    RAT_RPM_target = 0,
    
    cockpit_temperature_target = 0,
    cabin_temperature_fwd_target = 0,
    cabin_temperature_mid_target = 0,
    cabin_temperature_aft_target = 0,
    cargo_temperature_target = 0,
    bulk_cargo_temperature_target = 0,
    cargo_mode = 0,
    bulk_rate = 0,
    cargo_temp_loop = 0,
    
    gear_multiplier = 0,
    gear_timer = 0,
    brake_temp_max = 0,

    outflow_valve_minimum = 0,
    outflow_valve_maximum = 1,
    
    crossbleed_valve_pos = 0,
    pack1_flow_target2 = 0,
    pack2_flow_target2 = 0,
    precooler_temp1_target = 0,
    precooler_temp2_target = 0,
    pack1_comp_target = 0,
    pack2_comp_target = 0,
    pack1_cool_rate = 0,
    pack2_cool_rate = 0,
    alt_factor = 1,
    left_psi_factor = 1,
    right_psi_factor = 1,
    apu_loss_left = 0,
    apu_loss_right = 0,
    precooler1_psi_target = 0,
    precooler2_psi_target = 0,
    average_temperature = 0,
    average_temp_setting = 0,
    pack1_temp_needle = 0,
    pack2_temp_needle = 0,
    pack1_temp_needle_target = 0,
    pack2_temp_needle_target = 0,
    pack1_outlet_temp_target = 0,
    pack2_outlet_temp_target = 0,
    pack1_outlet_temp = 0,
    pack2_outlet_temp = 0,
    anti_ice_timer = 0,
    
    pack_lo_flasher = 0,
    buses_powered = 0,
    hot_air_xfeed_pos_target = 0,
    hot_air1_pressed = 0,
    hot_air2_pressed = 0,
    cooling_valve_pos_target = 0,
    cooling_valve_pos = 0,
    TOTAL_pack_status = 0,
    cooling_valve_mid = 0,
    bulk_temp_differential = 0,
    cargo_temp_differential = 0,
    zone1_differential = 0,
    zone2_differential = 0,
    zone3_differential = 0,
    zone4_differential = 0,
    zone5_differential = 0,
    zone6_differential = 0,
    zone7_differential = 0,
    zone1_needle_target = 0,
    zone2_needle_target = 0,
    zone3_needle_target = 0,
    zone4_needle_target = 0,
    zone5_needle_target = 0,
    zone6_needle_target = 0,
    zone7_needle_target = 0,
    cargo_temp_needle_target = 0,
    
    slides_armed = 0,
    
    capt_airspeed_conversion = 0,
    fo_airspeed_conversion = 0,
    
    dh_capt_flash_timer = 0,
    dh_fo_flash_timer = 0,
    
    total_gps_seconds = 0,
    total_gps2_seconds = 0,
    gps_seconds = 0,
    gps2_seconds = 0,

    cockpit_random_fac = m.random(-1, 1),
    cabin_fwd_random_fac = m.random(-1, 3),
    cabin_mid_random_fac = m.random(-2, 4),
    cabin_aft_random_fac = m.random(-1, 3),
    cargo_random_fac = m.random(-5, 2),
    cargo_bulk_random_fac = m.random(-5, 2),

    cabin_fwd_random_fac2 = m.random(-1, 1),
    cabin_mid_random_fac2 = m.random(-1, 2),
    cabin_aft_random_fac2 = m.random(-1, 1),
    
    cabin_fwd_mid_random_fac2 = m.random(-1, 1),
    cabin_mid_fwd_random_fac2 = m.random(-1, 1),
    cabin_aft_mid_random_fac2 = m.random(-1, 1),
    
    wheel_brake_1_random_max_fac = m.random(-60, 60),
    wheel_brake_2_random_max_fac = m.random(-60, 60),
    wheel_brake_3_random_max_fac = m.random(-60, 60),
    wheel_brake_4_random_max_fac = m.random(-60, 60),
    wheel_brake_5_random_max_fac = m.random(-60, 60),
    wheel_brake_6_random_max_fac = m.random(-60, 60),
    wheel_brake_7_random_max_fac = m.random(-60, 60),
    wheel_brake_8_random_max_fac = m.random(-60, 60),
    
    wheel_brake_1_random_min_fac = m.random(0, 10),
    wheel_brake_2_random_min_fac = m.random(0, 10),
    wheel_brake_3_random_min_fac = m.random(0, 10),
    wheel_brake_4_random_min_fac = m.random(0, 10),
    wheel_brake_5_random_min_fac = m.random(0, 10),
    wheel_brake_6_random_min_fac = m.random(0, 10),
    wheel_brake_7_random_min_fac = m.random(0, 10),
    wheel_brake_8_random_min_fac = m.random(0, 10),

	gear_handle_flag = 0,
	toe_brake_override_flag = 0,

    --star_mode = 0,
    single_engine_status = 0,

    Vmo = 330,
    Mmo = 0.86,
    Vfe_1 = 240,
    Vfe_1f = 215,
    Vfe_1_star = 205,
    Vfe_2 = 196,
    Vfe_2_star = 186,
    Vfe_3 = 186,
    Vfe_full = 180,
    Vle = 250,
    
    off_ground_timer = 0,
    ground_timer = 0,
    windshear_timer = 0,
    ws_ahead_timer = 0,
    capt_FD_timer = 0,
    fo_FD_timer = 0,
    
    takeoff_landing_index = 0, -- 0 = takeoff, 1 = landing
    
    altCaptured = 0,
    gsCaptured = 0,
    locCaptured = 0,
 
 	anti_ice_multiplier = 1,
	anti_ice_multiplier_g = 1,
    anti_ice_multiplier_lo = 1,
	anti_ice_multiplier_g_lo = 1
    
}



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

simDR_engine_starter_running = find_dataref("sim/flightmodel2/engines/starter_is_running")
simDR_engine1_starter_running = find_dataref("sim/flightmodel2/engines/starter_is_running[0]")
simDR_engine2_starter_running = find_dataref("sim/flightmodel2/engines/starter_is_running[1]")

simDR_engine1_igniter = find_dataref("sim/cockpit2/engine/actuators/igniter_on[0]")
simDR_engine2_igniter = find_dataref("sim/cockpit2/engine/actuators/igniter_on[1]")

simDR_engine1_running = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[0]")
simDR_engine2_running = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[1]")

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

simDR_gear_deploy = find_dataref("sim/flightmodel2/gear/deploy_ratio")
simDR_nose_gear_deploy = find_dataref("sim/flightmodel2/gear/deploy_ratio[0]")
simDR_Lmain_gear_deploy = find_dataref("sim/flightmodel2/gear/deploy_ratio[1]")
simDR_Rmain_gear_deploy = find_dataref("sim/flightmodel2/gear/deploy_ratio[2]")
simDR_gear_handle = find_dataref("sim/cockpit2/controls/gear_handle_request") -- 0 is up, 1 is down

simDR_reverser_lockout = find_dataref("sim/cockpit2/engine/actuators/reverse_lockout")

simDR_left_brake = find_dataref("sim/cockpit2/controls/left_brake_ratio")
simDR_right_brake = find_dataref("sim/cockpit2/controls/right_brake_ratio")
simDR_gear_override = find_dataref("sim/operation/override/override_toe_brakes")

-- FUEL
simDR_fuel_xfer_pump_activation_level = find_dataref("sim/cockpit2/fuel/transfer_pump_activation")
simDR_fuel_xfer_pump_deactivation_level = find_dataref("sim/cockpit2/fuel/transfer_pump_deactivation")

simDR_fuel_left_wing_tank_pump_on = find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[0]")
simDR_fuel_right_wing_tank_pump_on = find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[2]")
simDR_fuel_center_tank_pump_on = find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on[1]")

simDR_fuel_transfer_pump_left_aux = find_dataref("sim/cockpit2/fuel/transfer_pump_left")            -- 0: Off, 1: Auto, 2: On/Override
simDR_fuel_transfer_pump_right_aux = find_dataref("sim/cockpit2/fuel/transfer_pump_right")            -- 0: Off, 1: Auto, 2: On/Override

simDR_fuel_transfer_to_mode = find_dataref("sim/cockpit2/fuel/fuel_tank_transfer_to")        -- 0=none,1=left,2=center,3=right,5=aft
simDR_fuel_transfer_from_mode = find_dataref("sim/cockpit2/fuel/fuel_tank_transfer_from")        -- 0=none,1=left,2=center,3=right,5=aft

simDR_fuel_tank_sel_left = find_dataref("sim/cockpit2/fuel/fuel_tank_selector_left")        -- 0=none,1=left,2=center,3=right,4=all,5=aft
simDR_fuel_tank_sel_right = find_dataref("sim/cockpit2/fuel/fuel_tank_selector_right")    -- 0=none,1=left,2=center,3=right,4=all,5=aft

simDR_fuel_tank_qty = find_dataref("sim/cockpit2/fuel/fuel_quantity")
simDR_fuel_left_wing_tank_qty = find_dataref("sim/cockpit2/fuel/fuel_quantity[0]")
simDR_fuel_center_tank_qty = find_dataref("sim/cockpit2/fuel/fuel_quantity[1]")
simDR_fuel_right_wing_tank_qty = find_dataref("sim/cockpit2/fuel/fuel_quantity[2]")
simDR_fuel_left_wing_aux_tank_qty = find_dataref("sim/cockpit2/fuel/fuel_quantity[3]")
simDR_fuel_right_wing_aux_tank_qty = find_dataref("sim/cockpit2/fuel/fuel_quantity[4]")
simDR_fuel_trim_tank_qty = find_dataref("sim/cockpit2/fuel/fuel_quantity[5]")

simDR_fuel_pressure_center_tank = find_dataref("sim/cockpit2/fuel/tank_pump_pressure_psi[1]")
simDR_fuel_pressure_left_aux_tank = find_dataref("sim/cockpit2/fuel/tank_pump_pressure_psi[3]")
simDR_fuel_pressure_right_aux_tank = find_dataref("sim/cockpit2/fuel/tank_pump_pressure_psi[4]")
simDR_fuel_pressure_trim_tank = find_dataref("sim/cockpit2/fuel/tank_pump_pressure_psi[5]")

simDR_fuel_burned_eng = find_dataref("sim/cockpit2/fuel/fuel_totalizer_sum_engine_kg")
simDR_fuel_burned_total = find_dataref("sim/cockpit2/fuel/fuel_totalizer_sum_kg")

-- ELT
simDR_axial_g_load = find_dataref("sim/flightmodel2/misc/gforce_axil")
simDR_normal_g_load = find_dataref("sim/flightmodel2/misc/gforce_normal")

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
simDR_gear_on_ground_r = find_dataref("sim/flightmodel2/gear/on_ground[2]")

simDR_fadec_power_mode_eng = find_dataref("sim/flightmodel/engine/ENGN_fadec_pow_req")  -- (0=out of FADEC range, 1 = climb or cruise, 2 = climb or MCT or reduced takeoff, 3 = TOGA)
simDR_fadec_power_mode_eng1 = find_dataref("sim/flightmodel/engine/ENGN_fadec_pow_req[0]")  -- (0=out of FADEC range, 1 = climb or cruise, 2 = climb or MCT or reduced takeoff, 3 = TOGA)
simDR_fadec_power_mode_eng2 = find_dataref("sim/flightmodel/engine/ENGN_fadec_pow_req[1]")

simDR_fadec_power = find_dataref("sim/cockpit2/engine/actuators/fadec_on")
simDR_fadec1_fail = find_dataref("sim/operation/failures/rel_fadec_0")
simDR_fadec2_fail = find_dataref("sim/operation/failures/rel_fadec_1")

simDR_starter_torque = find_dataref("sim/aircraft/engine/acf_starter_torque_ratio")
simDR_external_temp = find_dataref("sim/weather/aircraft/temperature_ambient_deg_c")
simDR_sealevel_baro = find_dataref("sim/weather/barometer_sealevel_inhg")
simDR_sealevel_qnh_pas = find_dataref("sim/weather/aircraft/qnh_pas")
simDR_TAT = find_dataref("sim/weather/aircraft/temperature_leadingedge_deg_c")

simDR_eng_fuel_flow = find_dataref("sim/cockpit2/engine/indicators/fuel_flow_kg_sec")
simDR_fuel_flow_eng1 = find_dataref("sim/cockpit2/engine/indicators/fuel_flow_kg_sec[0]")
simDR_fuel_flow_eng2 = find_dataref("sim/cockpit2/engine/indicators/fuel_flow_kg_sec[1]")

simDR_low_idle = find_dataref("sim/aircraft2/engine/low_idle_ratio")
simDR_high_idle = find_dataref("sim/aircraft2/engine/high_idle_ratio")

simDR_prop_mode = find_dataref("sim/cockpit2/engine/actuators/prop_mode")
simDR_prop_mode0 = find_dataref("sim/cockpit2/engine/actuators/prop_mode[0]")
simDR_prop_mode1 = find_dataref("sim/cockpit2/engine/actuators/prop_mode[1]")

simDR_idle_mode = find_dataref("sim/cockpit2/engine/actuators/idle_speed")

-- ECAM
simDR_starter_mode = find_dataref("sim/cockpit2/engine/actuators/eng_mode_selector")  -- 0 = Norm, -1 = Crank, 1 = Ign/Start
simDR_eng_N1 = find_dataref("sim/flightmodel2/engines/N1_percent")
simDR_eng1_N1 = find_dataref("sim/flightmodel2/engines/N1_percent[0]")
simDR_eng2_N1 = find_dataref("sim/flightmodel2/engines/N1_percent[1]")
simDR_eng_N2 = find_dataref("sim/flightmodel2/engines/N2_percent")
simDR_eng1_N2 = find_dataref("sim/flightmodel2/engines/N2_percent[0]")
simDR_eng2_N2 = find_dataref("sim/flightmodel2/engines/N2_percent[1]")

simDR_throttle1_pos = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[0]")
simDR_throttle2_pos = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[1]")

simDR_FADEC_EPR = find_dataref("sim/flightmodel2/engines/EPR_FADEC")

simDR_throttle_used = find_dataref("sim/flightmodel2/engines/throttle_used_ratio")
simDR_throttle1_used = find_dataref("sim/flightmodel2/engines/throttle_used_ratio[0]")
simDR_throttle2_used = find_dataref("sim/flightmodel2/engines/throttle_used_ratio[1]")

simDR_engine_starting = find_dataref("sim/flightmodel2/engines/starter_is_running")
simDR_engine1_starting = find_dataref("sim/flightmodel2/engines/starter_is_running[0]")
simDR_engine2_starting = find_dataref("sim/flightmodel2/engines/starter_is_running[1]")
simDR_engine_reverse = find_dataref("sim/flightmodel2/engines/thrust_reverser_deploy_ratio")
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

simDR_bus1_power = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
simDR_bus2_power = find_dataref("sim/cockpit2/electrical/bus_volts[2]")
simDR_bus3_power = find_dataref("sim/cockpit2/electrical/bus_volts[5]") -- APU Battery
simDR_ess_bus_power = find_dataref("sim/cockpit2/electrical/bus_volts[3]")

simDR_engine1_hyd_pump_fault = find_dataref("sim/operation/failures/rel_hydpmp")
simDR_engine2_hyd_pump_fault = find_dataref("sim/operation/failures/rel_hydpmp2")

simDR_map_range = find_dataref("sim/cockpit2/EFIS/map_range_steps")

simDR_apu_fail = find_dataref("sim/operation/failures/rel_apu")
simDR_apu_fire = find_dataref("sim/operation/failures/rel_apu_fire")


simDR_gen_on = find_dataref("sim/cockpit2/electrical/generator_on")
simDR_gen1_on = find_dataref("sim/cockpit2/electrical/generator_on[0]")
simDR_gen2_on = find_dataref("sim/cockpit2/electrical/generator_on[1]")
simDR_gen1_fail = find_dataref("sim/operation/failures/rel_genera0")
simDR_gen2_fail = find_dataref("sim/operation/failures/rel_genera1")
simDR_gen1_volts = find_dataref("sim/cockpit2/electrical/generator_volts[0]")
simDR_gen2_volts = find_dataref("sim/cockpit2/electrical/generator_volts[1]")
simDR_gen1_hi_voltage = find_dataref("sim/operation/failures/rel_gen0_hi")
simDR_gen1_lo_voltage = find_dataref("sim/operation/failures/rel_gen0_lo")
simDR_gen2_hi_voltage = find_dataref("sim/operation/failures/rel_gen1_hi")
simDR_gen2_lo_voltage = find_dataref("sim/operation/failures/rel_gen1_lo")
simDR_EGT = find_dataref("sim/cockpit2/engine/indicators/EGT_deg_cel")
simDR_bus1_fail = find_dataref("sim/operation/failures/rel_esys2")
simDR_bus2_fail = find_dataref("sim/operation/failures/rel_esys3")

simDR_ess_bus_fail = find_dataref("sim/operation/failures/rel_esys4")

simDR_bus_amps = find_dataref("sim/cockpit2/electrical/bus_load_amps")
simDR_battery_status = find_dataref("sim/cockpit2/electrical/battery_on")
simDR_bat1_fail = find_dataref("sim/operation/failures/rel_batter0")
simDR_bat2_fail = find_dataref("sim/operation/failures/rel_batter1")
simDR_bat3_fail = find_dataref("sim/operation/failures/rel_batter2")

simDR_bat_amps = find_dataref("sim/cockpit2/electrical/battery_amps")

simDR_RAT_gen_on = find_dataref("sim/cockpit2/electrical/RAT_generator_on")
simDR_RAT_gen_volts = find_dataref("sim/cockpit2/electrical/RAT_generator_volts")

simDR_gforce_normal = find_dataref("sim/flightmodel2/misc/gforce_normal")

-- FLIGHT CONTROLS
simDR_outer_aileron_L = find_dataref("sim/flightmodel2/wing/aileron2_deg[6]")
simDR_inner_aileron_L = find_dataref("sim/flightmodel2/wing/aileron1_deg[4]")
simDR_inner_aileron_R = find_dataref("sim/flightmodel2/wing/aileron1_deg[5]")
simDR_outer_aileron_R = find_dataref("sim/flightmodel2/wing/aileron2_deg[7]")
simDR_elevator_L = find_dataref("sim/flightmodel2/wing/elevator1_deg[8]")
simDR_elevator_R = find_dataref("sim/flightmodel2/wing/elevator1_deg[9]")

simDR_spoiler1_L = find_dataref("sim/flightmodel2/wing/speedbrake1_deg[0]") -- green
simDR_spoiler2_L = find_dataref("sim/flightmodel2/wing/spoiler1_deg[2]") -- blue
simDR_spoiler3_L = find_dataref("sim/flightmodel2/wing/spoiler2_deg[2]") -- blue
simDR_spoiler4_5_L = find_dataref("sim/flightmodel2/wing/spoiler1_deg[4]") -- green
simDR_spoiler6_L = find_dataref("sim/flightmodel2/wing/spoiler2_deg[4]") -- yellow

simDR_spoiler1_R = find_dataref("sim/flightmodel2/wing/speedbrake1_deg[1]") -- green
simDR_spoiler2_R = find_dataref("sim/flightmodel2/wing/spoiler1_deg[3]") -- blue
simDR_spoiler3_R = find_dataref("sim/flightmodel2/wing/spoiler2_deg[3]") -- blue
simDR_spoiler4_5_R = find_dataref("sim/flightmodel2/wing/spoiler1_deg[5]") -- green
simDR_spoiler6_R = find_dataref("sim/flightmodel2/wing/spoiler2_deg[5]") -- yellow

simDR_rudder_trim_ratio = find_dataref("sim/flightmodel2/controls/rudder_trim")

simDR_speedbrake_ratio = find_dataref("sim/flightmodel2/controls/speedbrake_ratio")

-- FLIGHT CONTROL FAILURES -- SET WITH LEAK MEASUREMENT TO INHIBIT CONTROL SURFACE MOVEMENT

simDR_speedbrake1_left_lock = find_dataref("sim/operation/failures/rel_fcon_sbrk_1_lft_lock") -- green
simDR_speedbrake1_right_lock = find_dataref("sim/operation/failures/rel_fcon_sbrk_1_rgt_lock") -- green

simDR_spoiler1_left_lock = find_dataref("sim/operation/failures/rel_fcon_rspo_1_lft_lock") -- blue, green
simDR_spoiler1_right_lock = find_dataref("sim/operation/failures/rel_fcon_rspo_1_rgt_lock") -- blue, green

simDR_spoiler2_left_lock = find_dataref("sim/operation/failures/rel_fcon_rspo_2_lft_lock") -- blue, yellow
simDR_spoiler2_right_lock = find_dataref("sim/operation/failures/rel_fcon_rspo_2_rgt_lock") -- blue, yellow

simDR_aileron1_left_lock = find_dataref("sim/operation/failures/rel_fcon_ailn_1_lft_lock") -- inboard, green, blue
simDR_aileron1_right_lock = find_dataref("sim/operation/failures/rel_fcon_ailn_1_rgt_lock") -- inboard, green, blue
simDR_elevator_left_lock = find_dataref("sim/operation/failures/rel_fcon_elev_1_lft_lock") -- green, blue

simDR_aileron2_left_lock = find_dataref("sim/operation/failures/rel_fcon_ailn_2_lft_lock") -- outboard, green, yellow
simDR_aileron2_right_lock = find_dataref("sim/operation/failures/rel_fcon_ailn_2_rgt_lock") -- outboard, green, yellow
simDR_elevator_right_lock = find_dataref("sim/operation/failures/rel_fcon_elev_1_rgt_lock") -- green, yellow

simDR_rudder_lock = find_dataref("sim/operation/failures/rel_fcon_rudd_1_ctr_lock") -- green, yellow, blue
simDR_flaps_lock = find_dataref("sim/operation/failures/rel_flap_act") -- yellow, green
simDR_slats_lock = find_dataref("sim/operation/failures/rel_fc_slt") -- green, blue

-- DOORS / OXY
simDR_door_ratio = find_dataref("sim/flightmodel2/misc/door_open_ratio")
simDR_oxygen_on = find_dataref("sim/cockpit2/oxygen/actuators/o2_valve_on")
simDR_number_plugged_in_o2 = find_dataref("sim/cockpit2/oxygen/actuators/num_plugged_in_o2")
simDR_ox_psi = find_dataref("sim/cockpit2/oxygen/indicators/o2_bottle_pressure_psi")
simDR_ox_demand_setting = find_dataref("sim/cockpit2/oxygen/actuators/demand_flow_setting")
simDR_cabin_alt	= find_dataref("sim/cockpit2/pressurization/indicators/cabin_altitude_ft")
simDR_dump_pressure = find_dataref("sim/cockpit2/pressurization/actuators/dump_all_on")

-- WHEEL STUFF
simDR_left_brake_fail = find_dataref("sim/operation/failures/rel_lbrakes")
simDR_right_brake_fail = find_dataref("sim/operation/failures/rel_rbrakes")
simDR_left_brake_ratio = find_dataref("sim/flightmodel2/gear/tire_part_brake[1]")
simDR_right_brake_ratio = find_dataref("sim/flightmodel2/gear/tire_part_brake[2]")
simDR_left_skid_ratio = find_dataref("sim/flightmodel2/gear/tire_skid_ratio[1]")
simDR_right_skid_ratio = find_dataref("sim/flightmodel2/gear/tire_skid_ratio[2]")

simDR_left_main_gear_fail = find_dataref("sim/operation/failures/rel_lagear2")
simDR_right_main_gear_fail = find_dataref("sim/operation/failures/rel_lagear3")
simDR_gear_system_fail = find_dataref("sim/operation/failures/rel_gear_act")

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

simDR_generator_amps = find_dataref("sim/cockpit2/electrical/generator_amps")
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

simDR_landing_alt_capt			= find_dataref("sim/cockpit2/radios/indicators/landing_alt_pilot")
simDR_landing_alt_fo			= find_dataref("sim/cockpit2/radios/indicators/landing_alt_copilot")

simDR_fms_vert_msg_capt			= find_dataref("sim/cockpit2/radios/indicators/fms_vertical_msg_pilot")
simDR_fms_vert_msg_fo			= find_dataref("sim/cockpit2/radios/indicators/fms_vertical_msg_copilot")

-- ND
simDR_nav1_ID = find_dataref("sim/cockpit2/radios/indicators/nav3_nav_id")
simDR_nav2_ID = find_dataref("sim/cockpit2/radios/indicators/nav4_nav_id")
simDR_dme1_ID = find_dataref("sim/cockpit2/radios/indicators/nav3_dme_id")
simDR_dme2_ID = find_dataref("sim/cockpit2/radios/indicators/nav4_dme_id")
simDR_adf1_ID = find_dataref("sim/cockpit2/radios/indicators/adf1_nav_id")
simDR_adf2_ID = find_dataref("sim/cockpit2/radios/indicators/adf2_nav_id")

simDR_nav_type = find_dataref("sim/cockpit2/radios/indicators/nav_type")
simDR_nav1_type = find_dataref("sim/cockpit2/radios/indicators/nav_type[2]")
simDR_nav2_type = find_dataref("sim/cockpit2/radios/indicators/nav_type[3]")

simDR_gps1_dme_time = find_dataref("sim/cockpit2/radios/indicators/gps_dme_time_min")
simDR_gps2_dme_time = find_dataref("sim/cockpit2/radios/indicators/gps2_dme_time_min")

simDR_HSI_pilot = find_dataref("sim/cockpit2/radios/actuators/HSI_source_select_pilot")
simDR_HSI_copilot = find_dataref("sim/cockpit2/radios/actuators/HSI_source_select_copilot")

simDR_tcas_fail = find_dataref("sim/operation/failures/rel_xpndr")

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

simDR_throttle_loc_eng = find_dataref("sim/flightmodel/engine/ENGN_fadec_pow_req")
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

simDR_gps_cdi_sens = find_dataref("sim/cockpit/radios/gps_cdi_sensitivity")
simDR_nav_status = find_dataref("sim/cockpit2/autopilot/nav_status")

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

simDR_plugin_bus_amps = find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps")

simDR_zulu_time_sec	= find_dataref("sim/time/zulu_time_sec")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

A333DR_press_knobs_pack_flow_pos = find_dataref("laminar/A333/pressurization/knobs/pack_flow_pos")
A333DR_knobs_bleed_isol_valve_pos = find_dataref("laminar/A333/pressurization/knobs/pack_isol_valve_pos")

A333DR_fuel_left_pump1_button_pos = find_dataref("laminar/A333/fuel/buttons/left1_pump_pos")
A333DR_fuel_left_pump2_button_pos = find_dataref("laminar/A333/fuel/buttons/left2_pump_pos")
A333DR_fuel_left_stby_pump_button_pos = find_dataref("laminar/A333/fuel/buttons/left_stby_pump_pos")

A333DR_fuel_right_pump1_button_pos = find_dataref("laminar/A333/fuel/buttons/right1_pump_pos")
A333DR_fuel_right_pump2_button_pos = find_dataref("laminar/A333/fuel/buttons/right2_pump_pos")
A333DR_fuel_right_stby_pump_button_pos = find_dataref("laminar/A333/fuel/buttons/right_stby_pump_pos")

A333DR_fuel_center_left_pump_button_pos = find_dataref("laminar/A333/fuel/buttons/center_left_pump_pos")
A333DR_fuel_center_right_pump_button_pos = find_dataref("laminar/A333/fuel/buttons/center_right_pump_pos")

A333DR_fuel_crossfeed_button_pos = find_dataref("laminar/A333/fuel/buttons/wing_x_feed_pos")

A333DR_fuel_center_xfr_button_pos = find_dataref("laminar/A333/fuel/buttons/center_xfr_pos")
A333DR_fuel_trim_xfr_button_pos = find_dataref("laminar/A333/fuel/buttons/trim_xfr_pos")
A333DR_fuel_outer_tank_xfr_button_pos = find_dataref("laminar/A333/fuel/buttons/outer_tank_xfr_pos")

A333DR_fuel_trim_tank_feed_mode_switch_pos = find_dataref("laminar/A333/fuel/switches/trim_tank_feed_pos")

-- FIRE
A333_apu_fire_handle_pos = find_dataref("laminar/A333/fire/switches/apu_handle")
A333_eng1_fire_handle_pos = find_dataref("laminar/A333/fire/switches/eng1_handle")
A333_eng2_fire_handle_pos = find_dataref("laminar/A333/fire/switches/eng2_handle")

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

A333_green_leak_measure_status = find_dataref("laminar/A333/hyd/leak_measurement_g_status") -- 0 = valve open, 1 = valve closed (OFF)
A333_blue_leak_measure_status = find_dataref("laminar/A333/hyd/leak_measurement_b_status") -- 0 = valve open, 1 = valve closed (OFF)
A333_yellow_leak_measure_status = find_dataref("laminar/A333/hyd/leak_measurement_y_status") -- 0 = valve open, 1 = valve closed (OFF)

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

A333_buttons_gen1_pos = find_dataref("laminar/A333/buttons/gen1_pos")
A333_buttons_gen2_pos = find_dataref("laminar/A333/buttons/gen2_pos")

A333_buttons_gen1_ctct_on_off = find_dataref("laminar/A333/buttons/gen1_ctct_on_off")
A333_buttons_gen2_ctct_on_off = find_dataref("laminar/A333/buttons/gen2_ctct_on_off")

A333DR_adiru1_adr_status = find_dataref("laminar/A333/adiru1/adr_status")
A333DR_adiru1_att_status = find_dataref("laminar/A333/adiru1/att_status")
A333DR_adiru1_hdg_status = find_dataref("laminar/A333/adiru1/hdg_status")
A333DR_adiru1_lrn_status = find_dataref("laminar/A333/adiru1/lrn_status")

A333DR_adiru2_adr_status = find_dataref("laminar/A333/adiru2/adr_status")
A333DR_adiru2_att_status = find_dataref("laminar/A333/adiru2/att_status")
A333DR_adiru2_hdg_status = find_dataref("laminar/A333/adiru2/hdg_status")
A333DR_adiru2_lrn_status = find_dataref("laminar/A333/adiru2/lrn_status")

A333_capt_FD_bars_bypass = find_dataref("laminar/A333/autopilot/capt_FD_bars_bypass")
A333_fo_FD_bars_bypass = find_dataref("laminar/A333/autopilot/fo_FD_bars_bypass")

A333_capt_FD_flag = find_dataref("laminar/A333/autopilot/capt_FD_flag")
A333_fo_FD_flag = find_dataref("laminar/A333/autopilot/fo_FD_flag")

-- ELEC
A333DR_ac_bus1_has_power 			= find_dataref("laminar/A333/elec/ac_bus1_has_power")
A333DR_ac_bus2_has_power 			= find_dataref("laminar/A333/elec/ac_bus2_has_power")
A333DR_ac_ess_bus_has_power			= find_dataref("laminar/A333/elec/ac_ess_bus_has_power")
A333DR_dc_bat1_hot_bus_has_power 	= find_dataref("laminar/A333/elec/dc_hot_bus1_has_power")
A333DR_dc_bat2_hot_bus_has_power 	= find_dataref("laminar/A333/elec/dc_hot_bus2_has_power")

A333DR_dc_bus1_has_power 			= find_dataref("laminar/A333/elec/dc_bus1_has_power")
A333DR_dc_bus2_has_power 			= find_dataref("laminar/A333/elec/dc_bus2_has_power")
A333DR_dc_bat_bus_has_power 		= find_dataref("laminar/A333/elec/dc_bat_bus_has_power")
A333DR_dc_apu_bat_bus_has_power		= find_dataref("laminar/A333/elec/dc_apu_bat_bus_has_power")
A333DR_dc_ess_bus_has_power 		= find_dataref("laminar/A333/elec/dc_ess_bus_has_power")
A333DR_status_gpu_avail 			= find_dataref("laminar/A333/status/GPU_avail")

A333DR_ac_min_volts 				= find_dataref("laminar/A333/elec/ac_min_volts")
A333DR_dc_min_volts 				= find_dataref("laminar/A333/elec/dc_min_volts")

A333DR_tr1_volts					= find_dataref("laminar/A333/elec/tr1_volts")
A333DR_tr2_volts					= find_dataref("laminar/A333/elec/tr2_volts")
A333DR_ess_tr_volts					= find_dataref("laminar/A333/elec/ess_tr_volts")
A333DR_apu_tr_volts					= find_dataref("laminar/A333/elec/apu_tr_volts")

A333_buttons_battery1_ctct_on_off 	= find_dataref("laminar/A333/buttons/batt1_ctct_on_off")
A333_buttons_battery2_ctct_on_off 	= find_dataref("laminar/A333/buttons/batt2_ctct_on_off")
A333_buttons_apu_bat_ctct_on_off	= find_dataref("laminar/A333/buttons/apu_battery_ctct_on_off")

A333_batteries_only_supply			= find_dataref("laminar/A333/elec/batteries_only_supply")
A333_sys_isol_contactor				= find_dataref("laminar/A333/elec/sys_isol_contactor")
A333_ac1_bus_tie_contactor			= find_dataref("laminar/A333/elec/ac1_bus_tie_contactor")
A333_ac2_bus_tie_contactor			= find_dataref("laminar/A333/elec/ac2_bus_tie_contactor")

A333DR_elec_ac_ess_source 			= find_dataref("laminar/A333/elec/ac_ess_source")
A333DR_dc_bat_bus_volts				= find_dataref("laminar/A333/elec/dc_bat_bus_volts")

A333_IDG1_status					= find_dataref("laminar/A333/status/elec/IDG1") -- 0 = disc, 1 = connected
A333_IDG2_status					= find_dataref("laminar/A333/status/elec/IDG2")

A333DR_bat1_is_charging				= find_dataref("laminar/A333/elec/bat1_is_charging")
A333DR_bat2_is_charging				= find_dataref("laminar/A333/elec/bat2_is_charging")
A333DR_apu_bat_is_charging			= find_dataref("laminar/A333/elec/apu_bat_is_charging")

A333DR_dc_bat1_ess_tie_contactor	= find_dataref("laminar/A333/elec/dc_bat1_ess_tie_contactor")
A333DR_dc_bat2_ess_tie_contactor	= find_dataref("laminar/A333/elec/dc_bat2_ess_tie_contactor")

A333DR_bat1_line_contactor			= find_dataref("laminar/A333/elec/bat1_line_cntor")
A333DR_bat2_line_contactor			= find_dataref("laminar/A333/elec/bat2_line_cntor")
A333DR_apu_bat_line_contactor		= find_dataref("laminar/A333/elec/apu_bat_line_cntor")
A333DR_extA_grd_service_bus_pwr		= find_dataref("laminar/A333/elec/extA_ground_service_bus_has_power")

A333_crew_supply_status				= find_dataref("laminar/A333/status/crew_oxy_supply")

A333DR_lighting_power_ac1			= find_dataref("laminar/A333/plugin_power/lighting_ac1")
A333DR_lighting_power_ac2			= find_dataref("laminar/A333/plugin_power/lighting_ac2")
A333DR_lighting_power_ac_ess		= find_dataref("laminar/A333/plugin_power/lighting_ac_ess")
A333DR_hydraulic_power_ac1			= find_dataref("laminar/A333/plugin_power/hydraulic_ac1")
A333DR_hydraulic_power_ac2			= find_dataref("laminar/A333/plugin_power/hydraulic_ac2")


-- FADEC
A333_eng1_fadec_ground_pwr_cntr		= find_dataref("laminar/A333/buttons/eng1_FADEC_ground_pwr_cntr")
A333_eng2_fadec_ground_pwr_cntr		= find_dataref("laminar/A333/buttons/eng2_FADEC_ground_pwr_cntr")

-- RAT
A333DR_hyd_rat_prop_rpm				= find_dataref('laminar/A333/hyd/rat_prop_rpm')

-- GPWS

A333_gpws_terr_status				= find_dataref("laminar/A333/buttons/gpws/terrain_status") -- status of the switch contactor
A333_gpws_sys_status				= find_dataref("laminar/A333/buttons/gpws/system_status") -- status of the switch contactor


--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
A333_pack_flow1_ratio = create_dataref("laminar/A333/pressurization/pack_flow1_ratio", "number")
A333_pack_flow2_ratio = create_dataref("laminar/A333/pressurization/pack_flow2_ratio", "number")

A333_pack1_exhaust_pos = create_dataref("laminar/A330/pack1_door", "number")
A333_pack2_exhaust_pos = create_dataref("laminar/A330/pack2_door", "number")

----- FADEC POWER -----------------------------------------------------------------------

A333DR_fadec_power_ac_ess			= create_dataref("laminar/A333/plugin_power/fadec_ac_ess", "number")
A333DR_fadec_power_ac2				= create_dataref("laminar/A333/plugin_power/fadec_ac2", "number")
A333DR_eng1_fadec_ground_powered	= create_dataref("laminar/A333/fadec/eng1_fadec_ground_powered", "number")
A333DR_eng2_fadec_ground_powered	= create_dataref("laminar/A333/fadec/eng2_fadec_ground_powered", "number")

----- ELT -------------------------------------------------------------------------------
A333_elt_switch_pos = create_dataref("laminar/A333/switches/elt", "number")
A333_elt_annun = create_dataref("laminar/A333/lights/elt", "number")
A333_elt_tone = create_dataref("laminar/A333/sound/elt_on", "number")
A333_elt_sweep = create_dataref("laminar/A333/sound/elt_sweep", "number")

----- GPWS ------------------------------------------------------------------------------

A333_gpws_sys_state	= create_dataref("laminar/A333/gpws/system_state", "number") -- 0 = alarts off, 1 = powered/no valid GPS/fault, 2 = ready
A333_gpws_terr_state = create_dataref("laminar/A333/gpws/terr_state", "number") -- 0 = alerts off, 1 = powered/no valid GPS/fault, 2 = ready

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

A333_ECAM_eng1_avail_status = create_dataref("laminar/A333/ecam/eng1_avail_status", "number")
A333_ECAM_eng1_avail_flasher = create_dataref("laminar/A333/ecam/eng1_avail_flasher", "number")

A333_ECAM_eng2_avail_status = create_dataref("laminar/A333/ecam/eng2_avail_status", "number")
A333_ECAM_eng2_avail_flasher = create_dataref("laminar/A333/ecam/eng2_avail_flasher", "number")

A333_ECAM_IGN_mode = create_dataref("laminar/A333/ecam/ign_mode", "number")

A333_ECAM_APU_needles_vis = create_dataref("laminar/A333/ecam/apu_needle_vis", "number")
A333_ECAM_APU_GEN_status = create_dataref("laminar/A333/ecam/apu_gen_status", "number")
A333_ECAM_APU_PSI = create_dataref("laminar/A333/ecam/apu_psi", "number")
A333_ECAM_APU_volts = create_dataref("laminar/A333/ecam/apu_volts", "number")
A333_ECAM_APU_hertz = create_dataref("laminar/A333/ecam/apu_hz", "number")
A333_ECAM_APU_egt_hot_status = create_dataref("laminar/A333/ecam/apu_overheat_status", "number")

A333_ECAM_engine_donut1 = create_dataref("laminar/A333/ecam/throttle_pos_donut_eng1", "number")
A333_ECAM_engine_donut2 = create_dataref("laminar/A333/ecam/throttle_pos_donut_eng2", "number")

-- ECAM COMMON

A333_ECAM_g_load_state = create_dataref("laminar/A333/ecam/g_load_state", "number") -- 0 = no show, 1 = out of g-limits, 2 = on 5 second time out
A333_ECAM_g_load_timer = create_dataref("laminar/A333/ecam/g_load_timer", "number")
A333_ECAM_g_load_timer2 = create_dataref("laminar/A333/ecam/g_load_timer2", "number")

-- ELEC ECAM

-- AC --
A333_ECAM_elec_gen1_label_status = create_dataref("laminar/A333/ecam/elec/gen1_status", "number")
A333_ECAM_elec_gen2_label_status = create_dataref("laminar/A333/ecam/elec/gen2_status", "number")
A333_ECAM_elec_apu_gen_status = create_dataref("laminar/A333/ecam/elec/apu_gen_status", "number")
A333_ECAM_gen1_volts = create_dataref("laminar/A333/ecam/gen1_volts", "number")   -- ONLY USED FOR ECAM DISPLAY
A333_ECAM_gen1_hertz = create_dataref("laminar/A333/ecam/gen1_hz", "number")
A333_ECAM_gen2_volts = create_dataref("laminar/A333/ecam/gen2_volts", "number")   -- ONLY USED FOR ECAM DISPLAY
A333_ECAM_gen2_hertz = create_dataref("laminar/A333/ecam/gen2_hz", "number")
A333_ECAM_ext_a_volts = create_dataref("laminar/A333/ecam/ext_a_volts", "number")
A333_ECAM_ext_a_hertz = create_dataref("laminar/A333/ecam/ext_a_hz", "number")
A333_ECAM_ext_b_volts = create_dataref("laminar/A333/ecam/ext_b_volts", "number")
A333_ECAM_ext_b_hertz = create_dataref("laminar/A333/ecam/ext_b_hz", "number")
A333_ECAM_idg1_temp = create_dataref("laminar/A333/ecam/elec/idg1_temp", "number")
A333_ECAM_idg2_temp = create_dataref("laminar/A333/ecam/elec/idg2_temp", "number")
A333_ECAM_crossbar1_line = create_dataref("laminar/A333/ecam/elec/synoptic_cross_bar1", "number")
A333_ECAM_crossbar2_line = create_dataref("laminar/A333/ecam/elec/synoptic_cross_bar2", "number")
A333_ECAM_crossbar3_line = create_dataref("laminar/A333/ecam/elec/synoptic_cross_bar3", "number")
A333_ECAM_apu_gen_line = create_dataref("laminar/A333/ecam/elec/apu_gen_bar", "number")
A333_ECAM_gpu_line = create_dataref("laminar/A333/ecam/elec/gpu_gen_bar", "number")

A333_ECAM_emer_gen_status = create_dataref("laminar/A333/ecam/elec/emer_gen_status", "number")
A333_ECAM_emer_gen_volts = create_dataref("laminar/A333/ecam/elec/emer_gen_volts", "number")
A333_ECAM_emer_gen_hertz = create_dataref("laminar/A333/ecam/elec/emer_gen_hz", "number")

A333_ECAM_stat_inv_status = create_dataref("laminar/A333/ecam/elec/stat_inv_status", "number")
A333_ECAM_stat_inv_volts = create_dataref("laminar/A333/ecam/elec/stat_inv_volts", "number")
A333_ECAM_stat_inv_hertz = create_dataref("laminar/A333/ecam/elec/stat_inv_hz", "number")

-- DC --
A333_ECAM_elec_tr1_volts_display = create_dataref("laminar/A333/ecam/elec/tr1_volts", "number")
A333_ECAM_elec_tr2_volts_display = create_dataref("laminar/A333/ecam/elec/tr2_volts", "number")
A333_ECAM_elec_ess_tr_volts_display = create_dataref("laminar/A333/ecam/elec/ess_tr_volts", "number")
A333_ECAM_elec_apu_tr_volts_display = create_dataref("laminar/A333/ecam/elec/apu_tr_volts", "number")

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
A333_ECAM_hyd_green2_line_fin_eng1 = create_dataref("laminar/A333/ecam/hyd/green2_line_fin_status_eng1", "number")
A333_ECAM_hyd_green2_line_fin_eng2 = create_dataref("laminar/A333/ecam/hyd/green2_line_fin_status_eng2", "number")

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

A333_green_status = create_dataref("laminar/A333/flight_controls/green_status", "number") -- hydraulic loop 1
A333_blue_status = create_dataref("laminar/A333/flight_controls/blue_status", "number") -- hydraulic loop 3
A333_yellow_status = create_dataref("laminar/A333/flight_controls/yellow_status", "number") -- hydraulic loop 2

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

A333_eng1_HP_valve_pos = create_dataref("laminar/A333/ecam/bleed/eng1_hp_bleed_valve_pos", "number")
A333_eng2_HP_valve_pos = create_dataref("laminar/A333/ecam/bleed/eng2_hp_bleed_valve_pos", "number")

A333_precooler1_temp_status = create_dataref("laminar/A333/ecam/bleed/precooler1_temp_status", "number") -- 0 = amber, 1 = green
A333_precooler2_temp_status = create_dataref("laminar/A333/ecam/bleed/precooler2_temp_status", "number")

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

A333_capt_FD_flasher = create_dataref("laminar/A333/PFD/capt_FD_flag_flasher", "number")
A333_fo_FD_flasher = create_dataref("laminar/A333/PFD/fo_FD_flag_flasher", "number")

A333_landing_alt_capt_calibrated1 = create_dataref("laminar/A333/PFD/landing_alt_capt_cal1", "number")
A333_landing_alt_fo_calibrated1 = create_dataref("laminar/A333/PFD/landing_alt_fo_cal1", "number")
A333_landing_alt_capt_calibrated2 = create_dataref("laminar/A333/PFD/landing_alt_capt_cal2", "number")
A333_landing_alt_fo_calibrated2 = create_dataref("laminar/A333/PFD/landing_alt_fo_cal2", "number")

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

A333_gps_eta_time_hour = create_dataref("laminar/A333/nd/gps_eta_time_hour", "number")
A333_gps_eta_time_min = create_dataref("laminar/A333/nd/gps_eta_time_min", "number")

A333_gps_dme_time_min = create_dataref("laminar/A333/nd/gps_dme_time_min", "number")
A333_gps_dme_time_sec = create_dataref("laminar/A333/nd/gps_dme_time_sec", "number")

A333_gps2_eta_time_hour = create_dataref("laminar/A333/nd/gps2_eta_time_hour", "number")
A333_gps2_eta_time_min = create_dataref("laminar/A333/nd/gps2_eta_time_min", "number")

A333_gps2_dme_time_min = create_dataref("laminar/A333/nd/gps2_dme_time_min", "number")
A333_gps2_dme_time_sec = create_dataref("laminar/A333/nd/gps2_dme_time_sec", "number")

A333_capt_gps_active_status = create_dataref("laminar/A333/radios/capt_gps_status", "number")
A333_fo_gps_active_status = create_dataref("laminar/A333/radios/fo_gps_status", "number")

A333_TCAS_flasher = create_dataref("laminar/A333/ND/TCAS_flasher", "number")

A333_range_ring_flag_capt = create_dataref("laminar/A333/ND/range_ring_flag_capt", "number") -- 0 = show flag, 1 = hide flag
A333_range_ring_flag_fo = create_dataref("laminar/A333/ND/range_ring_flag_fo", "number") -- 0 = show flag, 1 = hide flag

-- FMAs
A333_AP_modes = create_dataref("laminar/A333/PFD/FMAs/autopilot_12_status", "number")
A333_FD_modes = create_dataref("laminar/A333/PFD/FMAs/flight_dir_12_status", "number")
A333_climb_descend = create_dataref("laminar/A333/PFD/FMAs/climb_descend", "number") -- 0 = no climb or descend, -1 = descend, 1 = climb
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
A333_column2_3_divider_capt = create_dataref("laminar/A333/PFD/FMAs/col2_col3_divider_capt", "number") -- 0 = tall, 1 = short
A333_column2_3_divider_fo = create_dataref("laminar/A333/PFD/FMAs/col2_col3_divider_fo", "number") -- 0 = tall, 1 = short

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

A333_nav_loc_arm_status = create_dataref("laminar/A333/PFD/FMAs/nav_loc_arm_status", "number") -- 0 = hide, 1 = nav, 2 = loc, 3 = nav loc
A333_alt_crz_heading_mode = create_dataref("laminar/A333/PFD/FMAs/alt_crz_heading_status", "number")

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


A333DR_baro_warning_brightness = create_dataref("laminar/A333/PFD/baro_warning_brightness", "number")
A333DR_baro_warning_brightness_fo = create_dataref("laminar/A333/PFD/baro_warning_brightness_fo", "number")

A333DR_var_test = create_dataref("laminar/A333/var_test", "number")
A333_laminar_no_ref = create_dataref("laminar/no_ref", "number")

----- AI --------------------------------------------------------------------------------
A333DR_init_systems_CD = create_dataref("laminar/A333/init_CD/systems", "number")



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

function A333_gear_up_beforeCMDhandler(phase, duration) end
function A333_gear_up_afterCMDhandler(phase, duration)
     if phase == 0 then
     	if simDR_gear_on_ground == 0 and simDR_gear_on_ground_r == 0 then
     		lcl.gear_handle_flag = 1
     	end
     end
end

function A333_gear_toggle_beforeCMDhandler(phase, duration) end
function A333_gear_toggle_afterCMDhandler(phase, duration)
     if phase == 0 then
		if simDR_gear_handle == 0 then
     		if simDR_gear_on_ground == 0 and simDR_gear_on_ground_r == 0 then
     			lcl.gear_handle_flag = 1
     		end
     	else lcl.gear_handle_flag = 2
     	end
	end
end

function A333_gear_down_beforeCMDhandler(phase, duration) end
function A333_gear_down_afterCMDhandler(phase, duration)
     if phase == 0 then
     	lcl.gear_handle_flag = 2
     end
end

--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	         **--
--*************************************************************************************--


--*************************************************************************************--
--** 				               REPLACE X-PLANE COMMANDS                   	     **--
--*************************************************************************************--


--*************************************************************************************--
--** 				               WRAP X-PLANE COMMANDS                   	     	 **--
--*************************************************************************************--

simCMD_gear_toggle		= wrap_command("sim/flight_controls/landing_gear_toggle", A333_gear_toggle_beforeCMDhandler, A333_gear_toggle_afterCMDhandler)
simCMD_gear_up			= wrap_command("sim/flight_controls/landing_gear_up", A333_gear_up_beforeCMDhandler, A333_gear_up_afterCMDhandler)
simCMD_gear_down		= wrap_command("sim/flight_controls/landing_gear_down", A333_gear_down_beforeCMDhandler, A333_gear_down_afterCMDhandler)

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
			if lcl.elt_trigger == 0 then
				lcl.elt_timer_trigger = 1
			end
		end
	elseif phase == 2 then
		if A333_elt_switch_pos == -1 then
		A333_elt_switch_pos = 0
		if lcl.elt_trigger == 1 then
			lcl.elt_trigger = 2
		elseif lcl.elt_trigger == 3 then
		else lcl.elt_trigger = 0
		end
		 lcl.elt_timer_trigger = 0
		end
	end
end




function A333_elt_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_elt_switch_pos == 0 then
			A333_elt_switch_pos = 1
			lcl.elt_trigger = 1
		end
	end
end




function A333_elt_trigger_CMDhandler(phase, duration)
	if phase == 0 then
		lcl.elt_trigger = 1
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

--A333CMD_crew_supply_toggle = create_command("laminar/A333/switches/crew_supply_toggle", "CREW SUPPLY", A333_crew_oxy_toggle_CMDhandler)

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

	if x < in1 then
		return out1
	end
	if x > in2 then
		return out2
	end
	return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end




local function A333_duct_isol_valves()

    local knobs_bleed_isol_valve_pos = A333DR_knobs_bleed_isol_valve_pos
    local crossbleed_valve_target = (((knobs_bleed_isol_valve_pos == 0 and simDR_apu_bleed == 1) 
        or 
        (knobs_bleed_isol_valve_pos == 1))
        and 1) or 0
        
    lcl.crossbleed_valve_pos = A333_set_animation_position(lcl.crossbleed_valve_pos, crossbleed_valve_target, 0, 1, 4)

    simDR_duct_isol_valve_left = 1
    simDR_duct_isol_valve_right = (lcl.crossbleed_valve_pos < 1 and 0) or 1

end




local function A333_pack_flow()

	local starter_mode = simDR_starter_mode -- 0 = Norm, -1 = Crank, 1 = Ign/Start

    local bleed_air1_fail = simDR_bleed_air1_fail
    local bleed_air2_fail = simDR_bleed_air2_fail
    local apu_bleed = simDR_apu_bleed
    local bleed_air1 = simDR_bleed_air1
    local bleed_air2 = simDR_bleed_air2
    local press_knobs_pack_flow_pos = A333DR_press_knobs_pack_flow_pos
    local duct_isol_valve_right = simDR_duct_isol_valve_right
    local left_pack = simDR_left_pack
    local right_pack = simDR_right_pack
    local pack_flow1_ratio = A333_pack_flow1_ratio
    local pack_flow2_ratio = A333_pack_flow2_ratio

    local both_bleed_air_sys_not_failed = bleed_air1_fail < 6 and bleed_air2_fail < 6
    local any_bleed_air_sys_failed = bleed_air1_fail == 6 or bleed_air2_fail == 6
    local bleed_air1_on = bleed_air1 == 1
    local bleed_air1_off = bleed_air1 == 0
    local bleed_air2_on = bleed_air2 == 1
    local bleed_air2_off = bleed_air2 == 0
    local bleed_air1and2_on = bleed_air1_on and bleed_air2_on
    local bleed_air1and2_off = bleed_air1_off and bleed_air2_off
    local one_bleed_air_on = (bleed_air1_on and bleed_air2_off) or (bleed_air2_on and bleed_air1_off)
    local apu_bleed_on = apu_bleed == 1
    local apu_bleed_off = not(apu_bleed_on)
	local bleed_mode = 0 -- 0 = two engine bleed, 1 = single engine bleed, 2 = apu bleed, 3 = bleed_air_failure, 4 = IGN/START OR CRANK mode -- for determining auto / overrides

	local engine_bleeds_open_enum = (bleed_air1and2_on and 2) or (one_bleed_air_on and 1.25)

    if starter_mode == 0 then
        if both_bleed_air_sys_not_failed then
            if apu_bleed_off then
                if bleed_air1and2_on or bleed_air1and2_off then
                    bleed_mode = 0
                elseif one_bleed_air_on then
                    bleed_mode = 1
                end
            elseif apu_bleed_on then
                bleed_mode = 2
            end
        elseif any_bleed_air_sys_failed then
            bleed_mode = 3
        end
    elseif starter_mode ~= 0 then
        bleed_mode = 4
    end


	if press_knobs_pack_flow_pos == -1 then
		if bleed_mode == 0 then
			lcl.pack1_flow_target = 0.8
			lcl.pack2_flow_target = 0.8
		elseif bleed_mode == 1 then
			lcl.pack1_flow_target = 1.25
			lcl.pack2_flow_target = 1.25
		elseif bleed_mode == 2 then
			lcl.pack1_flow_target = 1.25
			lcl.pack2_flow_target = 1.25
		elseif bleed_mode == 3 then
			lcl.pack1_flow_target = 0.8
			lcl.pack2_flow_target = 0.8
		elseif bleed_mode == 4 then
			lcl.pack1_flow_target = 0
			lcl.pack2_flow_target = 0
		end

	elseif press_knobs_pack_flow_pos == 0 then
		if bleed_mode == 0 then
			lcl.pack1_flow_target = 1
			lcl.pack2_flow_target = 1
		elseif bleed_mode == 1 then
			lcl.pack1_flow_target = 1.25
			lcl.pack2_flow_target = 1.25
		elseif bleed_mode == 2 then
			lcl.pack1_flow_target = 1.25
			lcl.pack2_flow_target = 1.25
		elseif bleed_mode == 3 then
			lcl.pack1_flow_target = 0.8
			lcl.pack2_flow_target = 0.8
		elseif bleed_mode == 4 then
			lcl.pack1_flow_target = 0
			lcl.pack2_flow_target = 0
		end

	elseif press_knobs_pack_flow_pos == 1 then
		if bleed_mode == 0 then
			lcl.pack1_flow_target = 1.25
			lcl.pack2_flow_target = 1.25
		elseif bleed_mode == 1 then
			lcl.pack1_flow_target = 1.25
			lcl.pack2_flow_target = 1.25
		elseif bleed_mode == 2 then
			lcl.pack1_flow_target = 1.25
			lcl.pack2_flow_target = 1.25
		elseif bleed_mode == 3 then
			lcl.pack1_flow_target = 0.8
			lcl.pack2_flow_target = 0.8
		elseif bleed_mode == 4 then
			lcl.pack1_flow_target = 0
			lcl.pack2_flow_target = 0
		end

	end

	if duct_isol_valve_right == 0 then
		if apu_bleed == 0 then
			lcl.bleed_mode_factor_left = 1
			lcl.bleed_mode_factor_right = 0.99
		elseif apu_bleed == 1 then
			lcl.bleed_mode_factor_left = 0.63
			lcl.bleed_mode_factor_right = 1
		end
	elseif duct_isol_valve_right == 1 then
		if apu_bleed == 0 then
			lcl.bleed_mode_factor_left = 0.51 * engine_bleeds_open_enum
			lcl.bleed_mode_factor_right = 0.5 * engine_bleeds_open_enum
		elseif apu_bleed == 1 then
			lcl.bleed_mode_factor_left = 0.63
			lcl.bleed_mode_factor_right = 0.61
		end
	end

	lcl.pack1_flow_ratio = lcl.pack1_flow_target * simDR_left_duct_avail * left_pack * lcl.bleed_mode_factor_left
	lcl.pack2_flow_ratio = lcl.pack2_flow_target * simDR_right_duct_avail * right_pack * lcl.bleed_mode_factor_right

    pack_flow1_ratio = A333_set_animation_position(pack_flow1_ratio, lcl.pack1_flow_ratio, 0, 15, 2)
	pack_flow2_ratio = A333_set_animation_position(pack_flow2_ratio, lcl.pack2_flow_ratio, 0, 15, 2)

    A333_pack_flow1_ratio = pack_flow1_ratio
    A333_pack_flow2_ratio = pack_flow2_ratio

	local airspeed_factor = rescale(40, 1, 128, 0.2, simDR_equiv_airspeed)
	local pack1_flow_factor = rescale(0, 0, 1.125, 1, pack_flow1_ratio)
	local pack2_flow_factor = rescale(0, 0, 1.125, 1, pack_flow2_ratio)

	lcl.pack1_exhaust_target = left_pack * airspeed_factor * pack1_flow_factor
	lcl.pack2_exhaust_target = right_pack * airspeed_factor * pack2_flow_factor

	A333_pack1_exhaust_pos = A333_set_animation_position(A333_pack1_exhaust_pos, lcl.pack1_exhaust_target, 0, 1, 2)
	A333_pack2_exhaust_pos = A333_set_animation_position(A333_pack2_exhaust_pos, lcl.pack2_exhaust_target, 0, 1, 2)

end




-- FUEL SYSTEM
local function A333_fuel_system()   -- TODO:  consider refactor to multiple functions ??
    
    local fuel_center_left_pump_button_pos = A333DR_fuel_center_left_pump_button_pos
    local fuel_center_right_pump_button_pos = A333DR_fuel_center_right_pump_button_pos
    local fuel_crossfeed_button_pos = A333DR_fuel_crossfeed_button_pos
    local center_tank_fuel_pressure = simDR_fuel_pressure_center_tank
    local center_tank_fuel_qty = simDR_fuel_center_tank_qty
    local fuel_xfer_pump_activation_level = simDR_fuel_xfer_pump_activation_level
    local fuel_trim_tank_feed_mode_switch_pos = A333DR_fuel_trim_tank_feed_mode_switch_pos
    local trim_tank_fuel_pressure = simDR_fuel_pressure_trim_tank
    local trim_tank_fuel_qty = simDR_fuel_trim_tank_qty
    local left_wing_tank_fuel_qty = simDR_fuel_left_wing_tank_qty
    local right_wing_tank_fuel_qty = simDR_fuel_right_wing_tank_qty
    local ctr_tank_fuel_xfr_button_pos = A333DR_fuel_center_xfr_button_pos
    local outer_tank_fuel_xfr_button_pos = A333DR_fuel_outer_tank_xfr_button_pos
    local left_aux_fuel_transfer_pump = simDR_fuel_transfer_pump_left_aux
    local right_aux_fuel_transfer_pump = simDR_fuel_transfer_pump_right_aux
    local left_aux_tank_fuel_pressure = simDR_fuel_pressure_left_aux_tank
    local right_aux_tank_fuel_pressure = simDR_fuel_pressure_right_aux_tank
    local left_wing_aux_tank_fuel_qty = simDR_fuel_left_wing_aux_tank_qty
    local right_wing_aux_tank_fuel_qty = simDR_fuel_right_wing_aux_tank_qty
    local trim_fuel_txfr_button_pos = A333DR_fuel_trim_xfr_button_pos
    local fuel_transfer_from_mode = simDR_fuel_transfer_from_mode
    local fuel_left_pump1_pos = A333_left_pump1_pos
    local ECAM_fuel_pump_L1_enum = A333_ECAM_fuel_pump_L1_enum
    local fuel_left_pump2_pos = A333_left_pump2_pos
    local ECAM_fuel_pump_L2_enum = A333_ECAM_fuel_pump_L2_enum
    local fuel_right_pump1_pos = A333_right_pump1_pos
    local ECAM_fuel_pump_R1_enum = A333_ECAM_fuel_pump_R1_enum
    local fuel_right_pump2_pos = A333_right_pump2_pos
    local ECAM_fuel_pump_R2_enum = A333_ECAM_fuel_pump_R2_enum
    local fuel_left_standby_pump_pos = A333_left_standby_pump_pos
    local ECAM_fuel_pump_Lstby_enum = A333_ECAM_fuel_pump_Lstby_enum
    local fuel_right_standby_pump_pos = A333_right_standby_pump_pos
    local ECAM_fuel_pump_Rstby_enum = A333_ECAM_fuel_pump_Rstby_enum
    local ECAM_fuel_left_pump_config = A333_ECAM_fuel_left_pump_config
    local ECAM_fuel_right_pump_config = A333_ECAM_fuel_right_pump_config
    local ECAM_fuel_trim_xfer_enum = A333_ECAM_fuel_trim_xfer_enum
    local fuel_outer_tank_xfr_pos = A333_fuel_outer_tank_xfr_pos
    local ECAM_fuel_left_aux_xfer_enum = A333_ECAM_fuel_left_aux_xfer_enum
    local ECAM_fuel_right_aux_xfer_enum = A333_ECAM_fuel_right_aux_xfer_enum
    local fuel_center_xfr_button_pos = A333_fuel_center_xfr_pos
    local ECAM_fuel_center_xfer_any = A333_ECAM_fuel_center_xfer_any
    local ECAM_fuel_ctr_L_xfer_enum = A333_ECAM_fuel_ctr_L_xfer_enum
    local ECAM_fuel_ctr_R_xfer_enum = A333_ECAM_fuel_ctr_R_xfer_enum
    local fuel_center_left_pump_pos = A333_center_left_pump_pos
    local ECAM_fuel_pump_CL_enum = A333_ECAM_fuel_pump_CL_enum
    local fuel_center_right_pump_pos = A333_center_right_pump_pos
    local ECAM_fuel_pump_CR_enum = A333_ECAM_fuel_pump_CR_enum
    local ECAM_fuel_ctr_line_xfer_enum = A333_ECAM_fuel_ctr_line_xfer_enum


    simDR_fuel_left_wing_tank_pump_on = ((A333DR_fuel_left_pump1_button_pos >= 1 or A333DR_fuel_left_pump2_button_pos >= 1 or A333DR_fuel_left_stby_pump_button_pos >= 1) and 1) or 0
    simDR_fuel_right_wing_tank_pump_on = ((A333DR_fuel_right_pump1_button_pos >= 1 or A333DR_fuel_right_pump2_button_pos >= 1 or A333DR_fuel_right_stby_pump_button_pos >= 1) and 1) or 0
    simDR_fuel_center_tank_pump_on = ((fuel_center_left_pump_button_pos >= 1 or fuel_center_right_pump_button_pos >= 1) and 1) or 0

    center_tank_fuel_pressure = ((fuel_center_left_pump_button_pos >= 1 or fuel_center_right_pump_button_pos >= 1) and 40) or 0
    
    simDR_fuel_tank_sel_left = (fuel_crossfeed_button_pos == 1 and 4) or 1
    simDR_fuel_tank_sel_right = (fuel_crossfeed_button_pos == 1 and 4) or 3


	if center_tank_fuel_pressure == 40 then                                     -- CENTER TANK OPERATING
        
		if center_tank_fuel_qty >= 75 then                                      -- CENTER TANK HAS FUEL - allow continuous transfer
			
			lcl.tank_transfer_left = 1
			lcl.tank_transfer_right = 1
            fuel_xfer_pump_activation_level = 2000
			simDR_fuel_xfer_pump_deactivation_level = 0                         -- ???? never used elsewhere
			if fuel_trim_tank_feed_mode_switch_pos == -1 then            -- TRIM FEED MODE OPEN
				trim_tank_fuel_pressure = 50                              -- FORCES TRIM TANK TO EMPTY TO WING TANKS VIA PSI HEIRARCHY

				if trim_tank_fuel_qty < 5 then
                    fuel_xfer_pump_activation_level = 2000
				elseif trim_tank_fuel_qty >= 5 then
                    fuel_xfer_pump_activation_level = 0
				end

			elseif fuel_trim_tank_feed_mode_switch_pos >= 0 then         -- NO CHANGE TO NORMAL IN ISOL / NORMAL AS NO FUEL IS MOVING FROM TRIM TANK
				trim_tank_fuel_pressure = 37
			end

            
		elseif center_tank_fuel_qty < 75 then                                   -- CENTER TANK APPROACHING EMPTY
            
			if fuel_trim_tank_feed_mode_switch_pos == 0 then             -- TRIM TANK FEED AUTO (NORMAL MODE)
                
				if trim_tank_fuel_qty > 75 then
                    
					trim_tank_fuel_pressure = 37
                    
					if left_wing_tank_fuel_qty < 4000 or right_wing_tank_fuel_qty < 4000 then
						-- IF LEVEL IS UNDER 4000kg - allow transfer
						lcl.tank_transfer_left = 2
						lcl.tank_transfer_right = 2
						fuel_xfer_pump_activation_level = 31812
                        
					elseif left_wing_tank_fuel_qty >= 4500 and right_wing_tank_fuel_qty >= 4500 then
						-- IF LEVEL EXCEEDS 4500kg - pause transfer
						lcl.tank_transfer_left = 0
						lcl.tank_transfer_right = 0
						fuel_xfer_pump_activation_level = 0
                        
					end
                    
				elseif trim_tank_fuel_qty < 75 then              -- TRIM TANK IS EMPTY
					
					trim_tank_fuel_pressure = 0                    -- TURN OFF PRESSURE SO THAT REMOVED FROM HEIRARCHY

					if left_wing_tank_fuel_qty < 3500 then
						lcl.tank_transfer_left = 2
					elseif left_wing_tank_fuel_qty >= 4000 then
						lcl.tank_transfer_left = 0
					end

					if right_wing_tank_fuel_qty < 3500 then
						lcl.tank_transfer_right = 2
					elseif right_wing_tank_fuel_qty >= 4000 then
						lcl.tank_transfer_right = 0
					end

					if lcl.tank_transfer_left == 2 or lcl.tank_transfer_right == 2 then
						fuel_xfer_pump_activation_level = 32312
					elseif lcl.tank_transfer_left == 0 and lcl.tank_transfer_right == 0 then
						fuel_xfer_pump_activation_level = 0
					end

				end

                
			elseif fuel_trim_tank_feed_mode_switch_pos == 1 then        -- TRIM TANK FEED ISOL

				trim_tank_fuel_pressure = 0

				if left_wing_tank_fuel_qty < 3500 then
					lcl.tank_transfer_left = 2
				elseif left_wing_tank_fuel_qty >= 4000 then
					lcl.tank_transfer_left = 0
				end

				if right_wing_tank_fuel_qty < 3500 then
					lcl.tank_transfer_right = 2
				elseif right_wing_tank_fuel_qty >= 4000 then
					lcl.tank_transfer_right = 0
				end

				if lcl.tank_transfer_left == 2 or lcl.tank_transfer_right == 2 then
					fuel_xfer_pump_activation_level = 32312
				elseif lcl.tank_transfer_left == 0 and lcl.tank_transfer_right == 0 then
					fuel_xfer_pump_activation_level = 0
				end


			elseif fuel_trim_tank_feed_mode_switch_pos == -1 then        -- TRIM TANK FEED OPEN

				trim_tank_fuel_pressure = 50
				if trim_tank_fuel_qty < 5 then

					if left_wing_tank_fuel_qty < 3500 then
						lcl.tank_transfer_left = 2
					elseif left_wing_tank_fuel_qty >= 4000 then
						lcl.tank_transfer_left = 0
					end

					if right_wing_tank_fuel_qty < 3500 then
						lcl.tank_transfer_right = 2
					elseif right_wing_tank_fuel_qty >= 4000 then
						lcl.tank_transfer_right = 0
					end

					if lcl.tank_transfer_left == 2 or lcl.tank_transfer_right == 2 then
						fuel_xfer_pump_activation_level = 32312
					elseif lcl.tank_transfer_left == 0 and lcl.tank_transfer_right == 0 then
						fuel_xfer_pump_activation_level = 0
					end

				elseif trim_tank_fuel_qty >= 5 then
					lcl.tank_transfer_left = 2
					lcl.tank_transfer_right = 2
				end
			end
		end

	elseif center_tank_fuel_pressure == 0 then                     -- CENTER TANK TURNED OFF (WITH OR WITHOUT FUEL)

		if fuel_trim_tank_feed_mode_switch_pos == 0 then                 -- TRIM TANK FEED AUTO

			if trim_tank_fuel_qty > 75 then                      -- TRIM TANK HAS FUEL
                
				trim_tank_fuel_pressure = 37
                
				if left_wing_tank_fuel_qty < 4000 or right_wing_tank_fuel_qty < 4000 then
					lcl.tank_transfer_left = 2
					lcl.tank_transfer_right = 2
					fuel_xfer_pump_activation_level = 31812
                    
				elseif left_wing_tank_fuel_qty >= 4500 and right_wing_tank_fuel_qty >= 4500 then
					lcl.tank_transfer_left = 0
					lcl.tank_transfer_right = 0
					fuel_xfer_pump_activation_level = 0
                    
				end
                
                
			elseif trim_tank_fuel_qty < 75 then                  -- TRIM TANK APPROACHING EMPTY
                
				trim_tank_fuel_pressure = 0                        -- REMOVE TRIM TANK FROM HEIRARCHY

				if left_wing_tank_fuel_qty < 3500 then
					lcl.tank_transfer_left = 2
				elseif left_wing_tank_fuel_qty >= 4000 then
					lcl.tank_transfer_left = 0
				end

				if right_wing_tank_fuel_qty < 3500 then
					lcl.tank_transfer_right = 2
				elseif right_wing_tank_fuel_qty >= 4000 then
					lcl.tank_transfer_right = 0
				end

				if lcl.tank_transfer_left == 2 or lcl.tank_transfer_right == 2 then
					fuel_xfer_pump_activation_level = 32312
				elseif lcl.tank_transfer_left == 0 and lcl.tank_transfer_right == 0 then
					fuel_xfer_pump_activation_level = 0
				end

			end

		elseif fuel_trim_tank_feed_mode_switch_pos == 1 then             -- TRIM TANK FEED ISOL

			trim_tank_fuel_pressure = 0                            -- REMOVE TRIM TANK FROM HEIRARCHY

			if left_wing_tank_fuel_qty < 3500 then
				lcl.tank_transfer_left = 2
			elseif left_wing_tank_fuel_qty >= 4000 then
				lcl.tank_transfer_left = 0
			end

			if right_wing_tank_fuel_qty < 3500 then
				lcl.tank_transfer_right = 2
			elseif right_wing_tank_fuel_qty >= 4000 then
				lcl.tank_transfer_right = 0
			end

			if lcl.tank_transfer_left == 2 or lcl.tank_transfer_right == 2 then
				fuel_xfer_pump_activation_level = 32312
			elseif lcl.tank_transfer_left == 0 and lcl.tank_transfer_right == 0 then
				fuel_xfer_pump_activation_level = 0
			end

		elseif fuel_trim_tank_feed_mode_switch_pos == -1 then            -- TRIM TANK FEED OPEN

			trim_tank_fuel_pressure = 50
			if trim_tank_fuel_qty < 5 then

				if left_wing_tank_fuel_qty < 3500 then
					lcl.tank_transfer_left = 2
				elseif left_wing_tank_fuel_qty >= 4000 then
					lcl.tank_transfer_left = 0
				end

				if right_wing_tank_fuel_qty < 3500 then
					lcl.tank_transfer_right = 2
				elseif right_wing_tank_fuel_qty >= 4000 then
					lcl.tank_transfer_right = 0
				end

				if lcl.tank_transfer_left == 2 or lcl.tank_transfer_right == 2 then
					fuel_xfer_pump_activation_level = 32312
				elseif lcl.tank_transfer_left == 0 and lcl.tank_transfer_right == 0 then
					fuel_xfer_pump_activation_level = 0
				end

			elseif trim_tank_fuel_qty >= 5 then
				lcl.tank_transfer_left = 2
				lcl.tank_transfer_right = 2
			end

		end

	end

	if ctr_tank_fuel_xfr_button_pos == 0 then                         -- OVERRIDE AUX TRANSFER
        
		if outer_tank_fuel_xfr_button_pos == 0 then
			left_aux_fuel_transfer_pump = lcl.tank_transfer_left
			right_aux_fuel_transfer_pump = lcl.tank_transfer_right
			left_aux_tank_fuel_pressure = 33
			right_aux_tank_fuel_pressure = 33
            
		elseif outer_tank_fuel_xfr_button_pos >= 1 then
            
			if left_wing_aux_tank_fuel_qty >= 5 then
				left_aux_tank_fuel_pressure = 50
				left_aux_fuel_transfer_pump = 2
			elseif left_wing_aux_tank_fuel_qty < 5 then
				left_aux_fuel_transfer_pump = lcl.tank_transfer_left
				left_aux_tank_fuel_pressure = 33
			end
            
			if right_wing_aux_tank_fuel_qty >= 5 then
				right_aux_tank_fuel_pressure = 50
				right_aux_fuel_transfer_pump = 2
			elseif right_wing_aux_tank_fuel_qty < 5 then
				right_aux_fuel_transfer_pump = lcl.tank_transfer_right
				right_aux_tank_fuel_pressure = 33
			end
            
		end

	elseif ctr_tank_fuel_xfr_button_pos >= 1 then

		if outer_tank_fuel_xfr_button_pos == 0 then

			left_aux_tank_fuel_pressure = 33
			right_aux_tank_fuel_pressure = 33

			if center_tank_fuel_qty >= 75 then
				center_tank_fuel_pressure = 50
				left_aux_fuel_transfer_pump = 2
				right_aux_fuel_transfer_pump = 2
                
			elseif center_tank_fuel_qty < 75 then
				center_tank_fuel_pressure = 0
				left_aux_fuel_transfer_pump = lcl.tank_transfer_left
				right_aux_fuel_transfer_pump = lcl.tank_transfer_right
                
			end

		elseif outer_tank_fuel_xfr_button_pos >= 1 then

			if center_tank_fuel_qty >= 75 then
                
				center_tank_fuel_pressure = 50
				left_aux_fuel_transfer_pump = 2
				right_aux_fuel_transfer_pump = 2
                
				if left_wing_aux_tank_fuel_qty >= 5 then
					left_aux_tank_fuel_pressure = 50
				elseif left_wing_aux_tank_fuel_qty < 5 then
					left_aux_tank_fuel_pressure = 33
				end
                
				if right_wing_aux_tank_fuel_qty >= 5 then
					right_aux_tank_fuel_pressure = 50
				elseif right_wing_aux_tank_fuel_qty < 5 then
					right_aux_tank_fuel_pressure = 33
				end
                
			elseif center_tank_fuel_qty < 75 then
                
				center_tank_fuel_pressure = 0
                
				if left_wing_aux_tank_fuel_qty >= 5 then
					left_aux_tank_fuel_pressure = 50
					left_aux_fuel_transfer_pump = 2
				elseif left_wing_aux_tank_fuel_qty < 5 then
					left_aux_fuel_transfer_pump = lcl.tank_transfer_left
					left_aux_tank_fuel_pressure = 33
				end
                
				if right_wing_aux_tank_fuel_qty >= 5 then
					right_aux_tank_fuel_pressure = 50
					right_aux_fuel_transfer_pump = 2
				elseif right_wing_aux_tank_fuel_qty < 5 then
					right_aux_fuel_transfer_pump = lcl.tank_transfer_right
					right_aux_tank_fuel_pressure = 33
				end
                
			end

		end

	end

	if trim_fuel_txfr_button_pos == 0 then -- FWD FUEL TRANSFER
        fuel_transfer_from_mode = 0
        
	elseif trim_fuel_txfr_button_pos >= 1 then
        
		if fuel_trim_tank_feed_mode_switch_pos == -1 then
            fuel_transfer_from_mode = 5
            
		elseif fuel_trim_tank_feed_mode_switch_pos == 0 then
			if trim_tank_fuel_qty >= 75 then
                fuel_transfer_from_mode = 5
			elseif trim_tank_fuel_qty < 75 then
                fuel_transfer_from_mode = 0
			end
            
		elseif fuel_trim_tank_feed_mode_switch_pos == 1 then
            fuel_transfer_from_mode = 0
		end
        
	end


	-- PUMP STATES
	if fuel_left_pump1_pos == 0 then
        ECAM_fuel_pump_L1_enum = 0
	elseif fuel_left_pump1_pos >= 1 then
		if left_wing_tank_fuel_qty >= 150 then
            ECAM_fuel_pump_L1_enum = 1
		elseif left_wing_tank_fuel_qty < 150 then
            ECAM_fuel_pump_L1_enum = 2
		end
	end
    
	if fuel_left_pump2_pos == 0 then
        ECAM_fuel_pump_L2_enum = 0
	elseif fuel_left_pump2_pos >= 1 then
		if left_wing_tank_fuel_qty >= 140 then
            ECAM_fuel_pump_L2_enum = 1
		elseif left_wing_tank_fuel_qty < 140 then
            ECAM_fuel_pump_L2_enum = 2
		end
	end

	if fuel_right_pump1_pos == 0 then
        ECAM_fuel_pump_R1_enum = 0
	elseif fuel_right_pump1_pos >= 1 then
		if right_wing_tank_fuel_qty >= 150 then
            ECAM_fuel_pump_R1_enum = 1
		elseif right_wing_tank_fuel_qty < 150 then
            ECAM_fuel_pump_R1_enum = 2
		end
	end

	if fuel_right_pump2_pos == 0 then
        ECAM_fuel_pump_R2_enum = 0
	elseif fuel_right_pump2_pos >= 1 then
		if right_wing_tank_fuel_qty >= 140 then
            ECAM_fuel_pump_R2_enum = 1
		elseif right_wing_tank_fuel_qty < 140 then
            ECAM_fuel_pump_R2_enum = 2
		end
	end

	if fuel_left_standby_pump_pos == 0 then
        ECAM_fuel_pump_Lstby_enum = 0
	elseif fuel_left_standby_pump_pos >= 1 then
		if left_wing_tank_fuel_qty >= 125 then
			if ECAM_fuel_pump_L1_enum == 0 and ECAM_fuel_pump_L2_enum == 0 then
                ECAM_fuel_pump_Lstby_enum = 1
			elseif ECAM_fuel_pump_L1_enum == 1 or ECAM_fuel_pump_L2_enum == 1 then
                ECAM_fuel_pump_Lstby_enum = 0
			elseif ECAM_fuel_pump_L1_enum == 2 and ECAM_fuel_pump_L2_enum == 2 then
                ECAM_fuel_pump_Lstby_enum = 1
			end
		elseif left_wing_tank_fuel_qty < 125 then
            ECAM_fuel_pump_Lstby_enum = 2
		end
	end

	if fuel_right_standby_pump_pos == 0 then
        ECAM_fuel_pump_Rstby_enum = 0
	elseif fuel_right_standby_pump_pos >= 1 then
		if right_wing_tank_fuel_qty >= 125 then
			if ECAM_fuel_pump_R1_enum == 0 and ECAM_fuel_pump_R2_enum == 0 then
                ECAM_fuel_pump_Rstby_enum = 1
			elseif ECAM_fuel_pump_R1_enum == 1 or ECAM_fuel_pump_R2_enum == 1 then
                ECAM_fuel_pump_Rstby_enum = 0
			elseif ECAM_fuel_pump_R1_enum == 2 and ECAM_fuel_pump_R2_enum == 2 then
                ECAM_fuel_pump_Rstby_enum = 1
			end
		elseif right_wing_tank_fuel_qty < 125 then
            ECAM_fuel_pump_Rstby_enum = 2
		end
	end

	if fuel_left_standby_pump_pos == 0 then
        ECAM_fuel_left_pump_config = 0
	elseif fuel_left_standby_pump_pos == 1 then
		if fuel_left_pump1_pos >= 1 or fuel_left_pump2_pos >= 1 then
            ECAM_fuel_left_pump_config = 1
		elseif fuel_left_pump1_pos == 0 and fuel_left_pump2_pos == 0 then
            ECAM_fuel_left_pump_config = 2
		end
	end

	if fuel_right_standby_pump_pos == 0 then
        ECAM_fuel_right_pump_config = 0
	elseif fuel_right_standby_pump_pos == 1 then
		if fuel_right_pump1_pos >= 1 or fuel_right_pump2_pos >= 1 then
            ECAM_fuel_right_pump_config = 1
		elseif fuel_right_pump1_pos == 0 and fuel_right_pump2_pos == 0 then
            ECAM_fuel_right_pump_config = 2
		end
	end

    
	-- TRANSFER STATES
	if trim_tank_fuel_qty < lcl.trim_tank_fuel_qty then
        ECAM_fuel_trim_xfer_enum = 1
	elseif trim_tank_fuel_qty == lcl.trim_tank_fuel_qty then
        ECAM_fuel_trim_xfer_enum = 0
	end

	if left_wing_aux_tank_fuel_qty < lcl.left_aux_tank_fuel_qty then
		if fuel_outer_tank_xfr_pos == 0 then
            ECAM_fuel_left_aux_xfer_enum = 1
		elseif fuel_outer_tank_xfr_pos >= 1 then
            ECAM_fuel_left_aux_xfer_enum = 2
		end
	elseif left_wing_aux_tank_fuel_qty == lcl.left_aux_tank_fuel_qty then
        ECAM_fuel_left_aux_xfer_enum = 0
	end

	if right_wing_aux_tank_fuel_qty < lcl.right_aux_tank_fuel_qty then
		if fuel_outer_tank_xfr_pos == 0 then
            ECAM_fuel_right_aux_xfer_enum = 1
		elseif fuel_outer_tank_xfr_pos >= 1 then
            ECAM_fuel_right_aux_xfer_enum = 2
		end
	elseif right_wing_aux_tank_fuel_qty == lcl.right_aux_tank_fuel_qty then
        ECAM_fuel_right_aux_xfer_enum = 0
	end

	if fuel_center_xfr_button_pos == 0 then

		if center_tank_fuel_qty < lcl.center_tank_fuel_qty then
            
			if left_wing_tank_fuel_qty > lcl.left_wing_tank_fuel_qty then
				lcl.center_left_transfer_enum = 1
			elseif left_wing_tank_fuel_qty <= lcl.left_wing_tank_fuel_qty then
				lcl.center_left_transfer_enum = 0
			end
            
			if right_wing_tank_fuel_qty > lcl.right_wing_tank_fuel_qty then
				lcl.center_right_transfer_enum = 1
			elseif right_wing_tank_fuel_qty <= lcl.right_wing_tank_fuel_qty then
				lcl.center_right_transfer_enum = 0
			end
            
		elseif center_tank_fuel_qty == lcl.center_tank_fuel_qty then
			lcl.center_left_transfer_enum = 0
			lcl.center_right_transfer_enum = 0
            
		end

	elseif fuel_center_xfr_button_pos >= 1 then
        
		if center_tank_fuel_qty >= 75 then
			lcl.center_left_transfer_enum = 1
			lcl.center_right_transfer_enum = 1
		elseif center_tank_fuel_qty < 75 then
			lcl.center_left_transfer_enum = 0
			lcl.center_right_transfer_enum = 0
		end
        
	end

	if lcl.center_left_transfer_enum == 1 or lcl.center_right_transfer_enum == 1 then
        ECAM_fuel_center_xfer_any = 1
	elseif lcl.center_left_transfer_enum == 0 and lcl.center_right_transfer_enum == 0 then
        ECAM_fuel_center_xfer_any = 0
	end

	if lcl.center_left_transfer_enum == 0 then
        ECAM_fuel_ctr_L_xfer_enum = 0
	elseif lcl.center_left_transfer_enum == 1 then
		if fuel_center_xfr_button_pos >= 1 then
            ECAM_fuel_ctr_L_xfer_enum = 2
		elseif fuel_center_xfr_button_pos == 0 then
            ECAM_fuel_ctr_L_xfer_enum = 1
		end
	end

	if lcl.center_right_transfer_enum == 0 then
        ECAM_fuel_ctr_R_xfer_enum = 0
	elseif lcl.center_right_transfer_enum == 1 then
		if fuel_center_xfr_button_pos >= 1 then
            ECAM_fuel_ctr_R_xfer_enum = 2
		elseif fuel_center_xfr_button_pos == 0 then
            ECAM_fuel_ctr_R_xfer_enum = 1
		end
	end
    

	if fuel_center_left_pump_pos == 0 then
        ECAM_fuel_pump_CL_enum = 0
	elseif fuel_center_left_pump_pos >= 1 then
		if ECAM_fuel_center_xfer_any == 1 then
			if center_tank_fuel_qty >= 250 then
                ECAM_fuel_pump_CL_enum = 1
			elseif center_tank_fuel_qty < 250 then
                ECAM_fuel_pump_CL_enum = 2
			end
		elseif ECAM_fuel_center_xfer_any == 0 then
            ECAM_fuel_pump_CL_enum = 0
		end
	end

	if fuel_center_right_pump_pos == 0 then
        ECAM_fuel_pump_CR_enum = 0
	elseif fuel_center_right_pump_pos >= 1 then
		if ECAM_fuel_center_xfer_any == 1 then
			if center_tank_fuel_qty >= 250 then
                ECAM_fuel_pump_CR_enum = 1
			elseif center_tank_fuel_qty < 250 then
                ECAM_fuel_pump_CR_enum = 2
			end
		elseif ECAM_fuel_center_xfer_any == 0 then
            ECAM_fuel_pump_CR_enum = 0
		end
	end

	if ECAM_fuel_center_xfer_any == 0 then
        ECAM_fuel_ctr_line_xfer_enum = 0
        
	elseif ECAM_fuel_center_xfer_any == 1 then
		if fuel_center_xfr_button_pos == 0 then
            
			if lcl.center_left_transfer_enum == 1 and lcl.center_right_transfer_enum == 0 then

				if fuel_center_right_pump_pos >= 1 then
                    ECAM_fuel_ctr_line_xfer_enum = 2
				elseif fuel_center_right_pump_pos == 0 then
                    ECAM_fuel_ctr_line_xfer_enum = 1
				end

			elseif lcl.center_left_transfer_enum == 1 and lcl.center_right_transfer_enum == 1 then
                ECAM_fuel_ctr_line_xfer_enum = 3

			elseif lcl.center_left_transfer_enum == 0 and lcl.center_right_transfer_enum == 1 then

				if fuel_center_left_pump_pos >= 1 then
                    ECAM_fuel_ctr_line_xfer_enum = 4
				elseif fuel_center_left_pump_pos == 0 then
                    ECAM_fuel_ctr_line_xfer_enum = 5
				end

			end

		elseif fuel_center_xfr_button_pos == 1 then
            
			if fuel_center_left_pump_pos == 0 and fuel_center_right_pump_pos == 0 then
                ECAM_fuel_ctr_line_xfer_enum = 0
			elseif fuel_center_left_pump_pos == 1 or fuel_center_right_pump_pos == 1 then
                ECAM_fuel_ctr_line_xfer_enum = 3
			end
            
		end
	end


    simDR_fuel_pressure_center_tank = center_tank_fuel_pressure
    simDR_fuel_pressure_trim_tank = trim_tank_fuel_pressure
    simDR_fuel_pressure_left_aux_tank = left_aux_tank_fuel_pressure
    simDR_fuel_pressure_right_aux_tank = right_aux_tank_fuel_pressure

    simDR_fuel_xfer_pump_activation_level = fuel_xfer_pump_activation_level
    simDR_fuel_transfer_pump_left_aux = left_aux_fuel_transfer_pump
    simDR_fuel_transfer_pump_right_aux = right_aux_fuel_transfer_pump

    simDR_fuel_transfer_from_mode = fuel_transfer_from_mode

    A333_ECAM_fuel_pump_L1_enum = ECAM_fuel_pump_L1_enum
    A333_ECAM_fuel_pump_L2_enum = ECAM_fuel_pump_L2_enum
    A333_ECAM_fuel_pump_R1_enum = ECAM_fuel_pump_R1_enum
    A333_ECAM_fuel_pump_R2_enum = ECAM_fuel_pump_R2_enum
    A333_ECAM_fuel_pump_Lstby_enum = ECAM_fuel_pump_Lstby_enum
    A333_ECAM_fuel_pump_Rstby_enum = ECAM_fuel_pump_Rstby_enum
    A333_ECAM_fuel_left_pump_config = ECAM_fuel_left_pump_config
    A333_ECAM_fuel_right_pump_config = ECAM_fuel_right_pump_config
    A333_ECAM_fuel_trim_xfer_enum = ECAM_fuel_trim_xfer_enum
    A333_ECAM_fuel_left_aux_xfer_enum = ECAM_fuel_left_aux_xfer_enum
    A333_ECAM_fuel_right_aux_xfer_enum = ECAM_fuel_right_aux_xfer_enum
    A333_ECAM_fuel_ctr_L_xfer_enum = ECAM_fuel_ctr_L_xfer_enum
    A333_ECAM_fuel_ctr_R_xfer_enum = ECAM_fuel_ctr_R_xfer_enum
    A333_ECAM_fuel_pump_CL_enum = ECAM_fuel_pump_CL_enum
    A333_ECAM_fuel_pump_CR_enum = ECAM_fuel_pump_CR_enum
    A333_ECAM_fuel_ctr_line_xfer_enum = ECAM_fuel_ctr_line_xfer_enum

	lcl.trim_tank_fuel_qty = trim_tank_fuel_qty
	lcl.center_tank_fuel_qty = center_tank_fuel_qty
	lcl.left_aux_tank_fuel_qty = left_wing_aux_tank_fuel_qty
	lcl.right_aux_tank_fuel_qty = right_aux_tank_fuel_pressure
	lcl.left_wing_tank_fuel_qty = left_wing_tank_fuel_qty
	lcl.right_wing_tank_fuel_qty = right_wing_tank_fuel_qty

end




-- ELT
local function A333_elt()

    local elt_switch_pos = A333_elt_switch_pos

	lcl.elt_timer = (lcl.elt_timer_trigger == 1 and (lcl.elt_timer + lcl_SIM_PERIOD)) or 0

	if lcl.elt_timer > 2 then
		lcl.elt_trigger = 3
	end

	lcl.elt_sequence_timer = ((lcl.elt_trigger == 1 or lcl.elt_trigger == 3) and (lcl.elt_sequence_timer + lcl_SIM_PERIOD)) or 0

	lcl.elt_sequence_timer_shutdown = (lcl.elt_trigger == 2 and (lcl.elt_sequence_timer_shutdown + lcl_SIM_PERIOD)) or 0

	if lcl.elt_trigger == 1 then -- ON
		if lcl.elt_sequence_timer < 0.3 then
			lcl.elt_annun = 0
			lcl.elt_sweep = 0
		elseif lcl.elt_sequence_timer >= 0.3 and lcl.elt_sequence_timer < 0.56 then
			lcl.elt_annun = 1
			lcl.elt_sweep = 0
		elseif lcl.elt_sequence_timer >= 0.56 and lcl.elt_sequence_timer < 0.81 then
			lcl.elt_annun = 0
			lcl.elt_sweep = 0
		elseif lcl.elt_sequence_timer >= 0.81 and lcl.elt_sequence_timer < 1.0 then
			lcl.elt_annun = 1
			lcl.elt_sweep = 0
		elseif lcl.elt_sequence_timer >= 1.0 and lcl.elt_sequence_timer < 1.59 then
			lcl.elt_annun = 0
			lcl.elt_sweep = 0
		elseif lcl.elt_sequence_timer >= 1.59 and lcl.elt_sequence_timer < 1.91 then
			lcl.elt_annun = 1
			lcl.elt_sweep = 0
		elseif lcl.elt_sequence_timer >= 1.91 and lcl.elt_sequence_timer < 3.38 then
			lcl.elt_annun = 0
			lcl.elt_sweep = 0
		elseif lcl.elt_sequence_timer >= 3.38 and lcl.elt_sequence_timer < 4.38 then
			lcl.elt_annun = 0
			lcl.elt_sweep = 1
		elseif lcl.elt_sequence_timer >= 4.38 and lcl.elt_sequence_timer < 8.5 then
			lcl.elt_annun = 0
			lcl.elt_sweep = 0
		elseif lcl.elt_sequence_timer >= 8.5 then
			lcl.elt_annun = 1
			lcl.elt_sweep = 0
		end
	elseif lcl.elt_trigger == 2 then -- RESET
			lcl.elt_sweep = 0
		if lcl.elt_sequence_timer_shutdown < 1.0 then
			lcl.elt_annun = 1
		elseif lcl.elt_sequence_timer_shutdown >= 1.0 and lcl.elt_sequence_timer_shutdown < 1.44 then
			lcl.elt_annun = 0
		elseif lcl.elt_sequence_timer_shutdown >= 1.44 and lcl.elt_sequence_timer_shutdown < 1.68 then
			lcl.elt_annun = 1
		elseif lcl.elt_sequence_timer_shutdown >= 1.68 and lcl.elt_sequence_timer_shutdown < 1.94 then
			lcl.elt_annun = 0
		elseif lcl.elt_sequence_timer_shutdown >= 1.94 and lcl.elt_sequence_timer_shutdown < 2.2 then
			lcl.elt_annun = 1
		elseif lcl.elt_sequence_timer_shutdown >= 2.2 then
			lcl.elt_annun = 0
		end
	elseif lcl.elt_trigger == 3 then -- TEST MODE
		if lcl.elt_sequence_timer < 4 then
			lcl.elt_annun = 1
			lcl.elt_sweep = 0
		elseif lcl.elt_sequence_timer >= 4 and lcl.elt_sequence_timer < 5 then
			lcl.elt_annun = 1
			lcl.elt_sweep = 1
		elseif lcl.elt_sequence_timer >= 5 and lcl.elt_sequence_timer < 10 then
			lcl.elt_annun = 0
			lcl.elt_sweep = 0
		elseif lcl.elt_sequence_timer >= 10 and lcl.elt_sequence_timer < 11 then
			lcl.elt_annun = 1
			lcl.elt_sweep = 0
		elseif lcl.elt_sequence_timer >= 11 then
			lcl.elt_annun = 0
			lcl.elt_sweep = 0
			lcl.elt_trigger = 0
		end
	else light_on = 0
		lcl.elt_sweep = 0
	end
			
 	if simDR_axial_g_load > 2.5 or simDR_normal_g_load > 5 then
 		lcl.elt_trigger = 1
 	end

	if lcl.elt_trigger == 2 then
		if lcl.elt_sequence_timer_shutdown >= 2.20 then
			lcl.elt_trigger = 0
		end
	end

	A333_elt_annun = lcl.elt_annun
	A333_elt_tone = lcl.elt_annun
	A333_elt_sweep = lcl.elt_sweep

	A333DR_var_test = lcl.elt_trigger

end




local function A333_anti_skid_auto_off()

	if simDR_nosewheel_steering == 0 then
		simDR_auto_brake_level = 1
	end

end




local function A333_control_surface_depress_droop()

    local green_hydraulic_pressure = ((A333_green_leak_measure_status == 0) and simDR_green_hydraulic_pressure) or 0
	local yellow_hydraulic_pressure = ((A333_yellow_leak_measure_status == 0) and simDR_yellow_hydraulic_pressure) or 0
	local blue_hydraulic_pressure = ((A333_blue_leak_measure_status == 0) and simDR_blue_hydraulic_pressure) or 0

	local green_blue = green_hydraulic_pressure + blue_hydraulic_pressure
	local green_yellow = green_hydraulic_pressure + yellow_hydraulic_pressure

	local airspeed_factor2 = rescale(10, 1, 45, 0, simDR_equiv_airspeed)
	local inbd_aileron_fac = rescale(10, 1, 750, 0, green_blue)
	local otbd_aileron_fac = rescale(10, 1, 750, 0, green_yellow)
	local left_hstab_fac = rescale(10, 1, 900, 0, green_blue)
	local right_hstab_fac = rescale(10, 1, 900, 0, green_yellow)

	local inbd_aileron_droop_target = airspeed_factor2 * inbd_aileron_fac
	local otbd_aileron_droop_target = airspeed_factor2 * otbd_aileron_fac
	local left_hstab_droop_target = airspeed_factor2 * left_hstab_fac
	local right_hstab_droop_target = airspeed_factor2 * right_hstab_fac

	A333_inboard_ail_droop_rat = A333_set_animation_position(A333_inboard_ail_droop_rat, inbd_aileron_droop_target, 0, 1, 0.5)
	A333_outboard_ail_droop_rat = A333_set_animation_position(A333_outboard_ail_droop_rat, otbd_aileron_droop_target, 0, 1, 0.5)
	A333_left_hstab_droop_rat = A333_set_animation_position(A333_left_hstab_droop_rat, left_hstab_droop_target, 0, 1, 0.5)
	A333_right_hstab_droop_rat = A333_set_animation_position(A333_right_hstab_droop_rat, right_hstab_droop_target, 0, 1, 0.5)

end

--[[
local function A333_FADEC_limits_set()

	-- FLEX CAN ONLY BE INITIATED ON THE GROUND, ONCE YOU PULL ANY ENGINE OUT OF FLEX DETENT, YOU WILL RETURN TO MCT

    -- see A333_flex_mode()


	if simDR_gear_on_ground == 1 then
		takeoff_mode = 1
		if simDR_flex_temp > simDR_OAT then
			lcl.flex_mode = 1
		else lcl.flex_mode = 0
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
			lcl.flex_mode = 0
		end

	end

    --[=[ takeoff_mode was replaced with different logic, see "A333_engine_limits()"
	if takeoff_mode == 1 then
		simDR_fadec_engine_limits_toga = A333DR_epr_limit_to
	elseif takeoff_mode == 0 then
		simDR_fadec_engine_limits_toga = A333DR_epr_limit_ga
	end

	if lcl.flex_mode == 0 then
		simDR_fadec_engine_limits_mct_flx = A333DR_epr_limit_mc
	elseif lcl.flex_mode == 1 then
		simDR_fadec_engine_limits_mct_flx = A333DR_epr_limit_flex
	end

	simDR_fadec_engine_limits_clb = A333DR_epr_limit_mc * 0.97
	--]=]


    --[=[     See A333_starter_torque()
	local starter_temp_multiplier = rescale(-40, 1.18, 15, 1, simDR_external_temp)
	local starter_baro_multiplier = rescale(29.92, 1, 32, 1.05, simDR_sealevel_baro)       -do not use simDR_sealevel_baro (replaced)

	simDR_starter_torque = STARTER_TORQUE_PLN_VALUE * starter_temp_multiplier * starter_baro_multiplier
    --]=]


end
--]]




local function A333_flex_mode()

    local flight_phase = A333_flight_phase
    local flex_temp = simDR_flex_temp
    local fadec_power_mode_eng1 = simDR_fadec_power_mode_eng1
    local fadec_power_mode_eng2 = simDR_fadec_power_mode_eng2

    -- Set the flex_mode flag prior to takeoff
    if flight_phase <= 4
        and
        lcl.flex_mode_is_available
        and
        ((flex_temp[0] >= 15 and flex_temp[0] <= 70)
        or
        (flex_temp[1] >= 15 and flex_temp[1] <= 70))
    then
        lcl.flex_mode = 1


    -- After takeoff, Lockout FLX Mode if either Thrust Lever is moved to CL or TOGA
    elseif flight_phase > 4 then
        if lcl.flex_mode == 1
            and
            ((fadec_power_mode_eng1 == 1 or fadec_power_mode_eng1 == 3)
            or
            (fadec_power_mode_eng2 == 1 or fadec_power_mode_eng2 == 3))
        then
            lcl.flex_mode_is_available = false
            lcl.flex_mode = 0
        end
    end

    -- Reset flex available flag after landing and MCDU init
    if not lcl.flex_mode_is_available
        and
        flight_phase >= 8    -- Touchdown
        and
        (flex_temp[0] == 0 or flex_temp[1] == 0)    -- MCDU init
    then
        lcl.flex_mode_is_available = true
    end

    return lcl.flex_mode

end




local function A333_engine_limits()

    local flight_phase = A333_flight_phase

    if flight_phase <= 4 then        -- Takeoff (on ground)
        simDR_fadec_engine_limits_toga = A333DR_epr_limit_to
    elseif flight_phase == 7 then    -- Go-Around (Alt 0-800 ft)
        simDR_fadec_engine_limits_toga = A333DR_epr_limit_ga
    end

    if lcl.flex_mode == 0 then
        simDR_fadec_engine_limits_mct_flx = A333DR_epr_limit_mc
    elseif lcl.flex_mode == 1 then
        simDR_fadec_engine_limits_mct_flx = A333DR_epr_limit_flex
    end

    simDR_fadec_engine_limits_clb = A333DR_epr_limit_mc * 0.97

end




local function A333_starter_torque()

    local starter_temp_multiplier = rescale(-40, 1.18, 15, 1, simDR_external_temp)

    local sealevel_baro_inHg = simDR_sealevel_qnh_pas * 0.0002952998                    -- 1 Pa = 0.0002952998 inHg     (simDR_sealevel_baro replaced)
    local starter_baro_multiplier = rescale(29.92, 1, 32, 1.05, sealevel_baro_inHg)

    simDR_starter_torque = STARTER_TORQUE_PLN_VALUE * starter_temp_multiplier * starter_baro_multiplier

end




local function A333_ECAM()

    local flap_deg = simDR_flap_deg
    local starter_mode = simDR_starter_mode
    local flap_handle_request = simDR_flap_handle_request
    local green_hydraulic_pressure = simDR_green_hydraulic_pressure
    local blue_hydraulic_pressure = simDR_blue_hydraulic_pressure
    local gear_on_ground = simDR_gear_on_ground
    local fadec_power_mode_eng = simDR_fadec_power_mode_eng
    local engine_reverse = simDR_engine_reverse
    local eng_N1 = simDR_eng_N1
    local eng_N2 = simDR_eng_N2
    local simDR_throttle_used = simDR_throttle_used
    local eng_fuel_flow = simDR_eng_fuel_flow
    local engine_starting = simDR_engine_starting
	local fadec1 = simDR_fadec_power[0]
	local fadec2 = simDR_fadec_power[1]
	local ac_ess = A333DR_ac_ess_bus_has_power
	local ac_bus2 = A333DR_ac_bus2_has_power
	local fadec1_grd_cntr = A333_eng1_fadec_ground_pwr_cntr
	local fadec2_grd_cntr = A333_eng2_fadec_ground_pwr_cntr
	local fadec1_grd = A333DR_eng1_fadec_ground_powered
	local fadec2_grd = A333DR_eng2_fadec_ground_powered
	local fadec1_not_fail = bool2num[simDR_fadec1_fail <= 5]
	local fadec2_not_fail = bool2num[simDR_fadec2_fail <= 5]				
	local engine1_on = simDR_engine1_running
	local engine2_on = simDR_engine2_running
	local ECAM_engine1_display = A333_ECAM_engine1_display
    local ECAM_engine2_display = A333_ECAM_engine2_display
 
    local ECAM_idle_status = A333_ECAM_idle_status
	local time_factor = 0

	local ECAM_eng1_avail_status = A333_ECAM_eng1_avail_status
	local ECAM_eng2_avail_status = A333_ECAM_eng2_avail_status
	local time_factor_eng1_avail = 0
	local time_factor_eng2_avail = 0
	local eng1_avail = 0
	local eng2_avail = 0


	local sim_time_factor = m.fmod(simDR_flight_time, 0.6)
    local flasher = ((sim_time_factor >= 0 and sim_time_factor <= 0.3) and 1) or 0


	if fadec1_grd_cntr == 1 and (ac_ess == 1 or ac_bus2 == 1) and eng_N2[0] <= 8 then
		fadec1_ground_timer = fadec1_ground_timer + lcl_SIM_PERIOD
	else fadec1_ground_timer = 0
	end

	if fadec2_grd_cntr == 1 and (ac_ess == 1 or ac_bus2 == 1) and eng_N2[1] <= 8 then
		fadec2_ground_timer = fadec2_ground_timer + lcl_SIM_PERIOD
	else fadec2_ground_timer = 0
	end

 	fadec1_grd = ((fadec1_ground_timer > 2 and fadec1_ground_timer < 300) and 1) or 0
 	fadec2_grd = ((fadec2_ground_timer > 2 and fadec2_ground_timer < 300) and 1) or 0

	if starter_mode == 0 then
		if eng_N2[0] > 8 then
			fadec1 = 1
		else fadec1 = fadec1_grd * ac_ess * ac_bus2
		end
		if eng_N2[1] > 8 then
			fadec2 = 1
		else fadec2 = fadec2_grd * ac_ess * ac_bus2
		end
	else fadec1 = 1
		fadec2 = 1
	end

	if fadec1 == 1 and eng_N2[0] <= 8 then
		if fadec1_not_fail == 1 then
			lcl.fadec1_pwr_ess = 6
			lcl.fadec1_pwr_ac2 = 6
		else lcl.fadec1_pwr_ess = 0.5
			lcl.fadec1_pwr_ac2 = 0.5
		end
	else lcl.fadec1_pwr_ess = 0
		lcl.fadec1_pwr_ac2 = 0
	end

	if fadec2 == 1 and eng_N2[1] <= 8 then
		if fadec2_not_fail == 1 then
			lcl.fadec2_pwr_ess = 6
			lcl.fadec2_pwr_ac2 = 6
		else lcl.fadec2_pwr_ess = 0.5
			lcl.fadec2_pwr_ac2 = 0.5
		end
	else lcl.fadec2_pwr_ess = 0
		lcl.fadec2_pwr_ac2 = 0
	end

				
	A333DR_fadec_power_ac_ess = lcl.fadec1_pwr_ess + lcl.fadec2_pwr_ess
	A333DR_fadec_power_ac2 = lcl.fadec1_pwr_ac2 + lcl.fadec2_pwr_ac2

	simDR_flap_retract_time = (flap_deg <= 4 and 106) or 16
    simDR_flap_extend_time = (flap_deg <= 4 and 106) or 16

    ECAM_engine1_display = (fadec1 == 0 and bool2num[eng_N2[0] > 8]) or 1
    ECAM_engine2_display = (fadec2 == 0 and bool2num[eng_N2[1] > 8]) or 1

    A333_ECAM_flap_display = (((flap_handle_request ~= 0) or (flap_handle_request == 0 and flap_deg ~= 0)) and 1) or 0
    A333_ECAM_slat_display = (((flap_handle_request ~= 0) or (flap_handle_request == 0 and simDR_slat_ratio ~= 0)) and 1) or 0

	if m.abs(flap_handle_request) < 0.1 then
		A333_ECAM_flap_lever_sel = 0
	elseif m.abs(flap_handle_request - 0.25) < 0.1 then
		A333_ECAM_flap_lever_sel = simDR_flap_config
	elseif m.abs(flap_handle_request - 0.5) < 0.1 then
		A333_ECAM_flap_lever_sel = 3
	elseif m.abs(flap_handle_request - 0.75) < 0.1 then
		A333_ECAM_flap_lever_sel = 4
	elseif m.abs(flap_handle_request - 1) < 0.1 then
		A333_ECAM_flap_lever_sel = 5
	end

	A333_ECAM_conf_req_ind = ((simDR_slats_disagree == 0 and simDR_flaps_disagree == 0) and 1) or 0

    A333_ECAM_slat_status = (((green_hydraulic_pressure < 30 or blue_hydraulic_pressure < 30)
        or ((green_hydraulic_pressure >= 30 or blue_hydraulic_pressure >= 30) and simDR_slat_failure == 6)) and 1) or 0

    A333_ECAM_flap_status = (((green_hydraulic_pressure < 30 or blue_hydraulic_pressure < 30)
        or
        ((green_hydraulic_pressure >= 30 or blue_hydraulic_pressure >= 30)
        and
        (simDR_flap_act_failure == 6 or simDR_flap1_L_failure == 6 or simDR_flap1_R_failure == 6 or simDR_flap2_L_failure == 6 or simDR_flap2_R_failure == 6)))
        and 1) or 0

    A333_EGT1_limit = ((not(gear_on_ground) or (gear_on_ground and engine_starting[0] == 0)) and 900) or 700
    A333_EGT2_limit = ((not(gear_on_ground) or (gear_on_ground and engine_starting[1] == 0)) and 900) or 700

    A333_EGT1_limit_vis = ((ECAM_engine1_display == 1 and fadec_power_mode_eng[0] ~= 3 and engine_reverse[0] < 0.001) and 1) or 0
    A333_EGT1_limit_vis = ((ECAM_engine2_display == 1 and fadec_power_mode_eng[1] ~= 3 and engine_reverse[1] < 0.001) and 1) or 0

    A333_ECAM_engine_display = ((((engine_reverse[0] < 0.01 and engine_reverse[1] < 0.01) and (ECAM_engine1_display == 1 or ECAM_engine2_display == 1)) and 1)
        or ((engine_reverse[0] >= 0.01 or engine_reverse[1] >= 0.01) and 2))
        or 0

    ECAM_idle_status = (((eng_N1[0] > 22.6 and eng_N1[1] > 22.6) and (simDR_throttle_used[0] < 0.01 and simDR_throttle_used[1] < 0.01)) and 1) or 0

    lcl.idle_timer = (ECAM_idle_status == 1 and (lcl.idle_timer + lcl_SIM_PERIOD)) or 0
    time_factor = (lcl.idle_timer <= 9 and 1) or 0

	lcl.idle_flasher = A333_set_animation_position(lcl.idle_flasher, flasher, 0, 1, 10)
	A333_ECAM_idle_flasher = lcl.idle_flasher * time_factor

-- ENGINE AVAIL

	eng1_avail = ((eng_N1[0] > 22.6 and engine1_on == 1) and 1) or 0
	eng2_avail = ((eng_N1[1] > 22.6 and engine2_on == 1) and 1) or 0

	lcl.eng1_avail_timer = (eng1_avail == 1 and (lcl.eng1_avail_timer + lcl_SIM_PERIOD)) or 0

	lcl.eng1_avail_flasher = A333_set_animation_position(lcl.eng1_avail_flasher, flasher, 0, 1, 10)
	A333_ECAM_eng1_avail_flasher = m.max(lcl.eng1_avail_flasher, gear_on_ground)

	ECAM_eng1_avail_status = ((eng1_avail == 1 and lcl.eng1_avail_timer <= 9) and 1) or 0

	lcl.eng2_avail_timer = (eng2_avail == 1 and (lcl.eng2_avail_timer + lcl_SIM_PERIOD)) or 0

	lcl.eng2_avail_flasher = A333_set_animation_position(lcl.eng2_avail_flasher, flasher, 0, 1, 10)
	A333_ECAM_eng2_avail_flasher = m.max(lcl.eng2_avail_flasher, gear_on_ground)

	ECAM_eng2_avail_status = ((eng2_avail == 1 and lcl.eng2_avail_timer <= 9) and 1) or 0

-- OTHER ECAM INDICATIONS

    A333_ECAM_IGN_mode = (simDR_starter_mode ~= 0 and 1) or 0
	A333_ECAM_fuel_totalkg_min = (eng_fuel_flow[0] + eng_fuel_flow[1]) * 60

	A333_ECAM_slat_alock_flasher = A333_set_animation_position(A333_ECAM_slat_alock_flasher, flasher, 0, 1, 10)
	A333_ECAM_flap_relief_flasher = A333_set_animation_position(A333_ECAM_flap_relief_flasher, flasher, 0, 1, 10)

    A333_ECAM_engine1_display = ECAM_engine1_display
    A333_ECAM_engine2_display = ECAM_engine2_display

    A333_ECAM_idle_status = ECAM_idle_status
	A333_ECAM_eng1_avail_status = ECAM_eng1_avail_status
	A333_ECAM_eng2_avail_status = ECAM_eng2_avail_status

	simDR_fadec_power[0] = fadec1
	simDR_fadec_power[1] = fadec2

	A333DR_eng1_fadec_ground_powered = fadec1_grd
	A333DR_eng2_fadec_ground_powered = fadec2_grd

end




---- ECAM HYDRAULICS PAGE
local function A333_ecam_page_HYD()     -- TODO:  consider refactor to multiple functions ??

    local eng1_hyd_fire_valve_pos = A333_eng1_hyd_fire_valve_pos
    local eng2_hyd_fire_valve_pos = A333_eng2_hyd_fire_valve_pos
    local green_hydraulic_pressure = simDR_green_hydraulic_pressure
    local yellow_hydraulic_pressure = simDR_yellow_hydraulic_pressure
    local blue_hydraulic_pressure = simDR_blue_hydraulic_pressure
    local green_hyd_fluid_ratio = simDR_green_fluid_ratio
    local blue_hyd_fluid_ratio = simDR_blue_fluid_ratio
    local yellow_hyd_fluid_ratio = simDR_yellow_fluid_ratio
    local green_eng1_pump_on = simDR_green_eng1_pump_on
    local engine1_hyd_pump_fault = simDR_engine1_hyd_pump_fault
    local engine2_hyd_pump_fault = simDR_engine2_hyd_pump_fault
    local blue_eng1_pump_on = simDR_blue_eng1_pump_on
    local yellow_eng2_pump_on = simDR_yellow_eng2_pump_on
    local green_eng2_pump_on = simDR_green_eng2_pump_on
    local ECAM_hyd_rat_rpm = A333_ECAM_hyd_rat_rpm
    local ECAM_hyd_green_eng1_pump = A333_ECAM_hyd_green_eng1_pump
    local ECAM_hyd_blue_eng1_pump = A333_ECAM_hyd_blue_eng1_pump
    local ECAM_hyd_yellow_eng2_pump = A333_ECAM_hyd_yellow_eng2_pump
    local ECAM_hyd_green_eng2_pump = A333_ECAM_hyd_green_eng2_pump
    local ECAM_hyd_elec_green_arrow = A333_ECAM_hyd_elec_green_arrow
    local ECAM_hyd_elec_blue_arrow = A333_ECAM_hyd_elec_blue_arrow
    local ECAM_hyd_elec_yellow_arrow = A333_ECAM_hyd_elec_yellow_arrow
    local green_elec_pump_on = simDR_green_elec_pump_on
    local elec_pump_green_tog_pos = A333_elec_pump_green_tog_pos
    local blue_elec_pump_on = simDR_blue_elec_pump_on
    local elec_pump_blue_tog_pos = A333_elec_pump_blue_tog_pos
    local yellow_elec_pump_on = simDR_yellow_elec_pump_on
    local elec_pump_yellow_tog_pos = A333_elec_pump_yellow_tog_pos
    local ECAM_hyd_rat_arrow_enum = A333_ECAM_hyd_rat_arrow_enum
    local rat_on = simDR_rat_on
	local eng1_N2 = simDR_eng1_N2
	local eng2_N2 = simDR_eng2_N2

	local green_leak_measure_status = A333_green_leak_measure_status -- 0 = valve open, 1 = valve closed (OFF)
	local yellow_leak_measure_status = A333_yellow_leak_measure_status -- 0 = valve open, 1 = valve closed (OFF)
	local blue_leak_measure_status = A333_blue_leak_measure_status -- 0 = valve open, 1 = valve closed (OFF)

	lcl.RAT_RPM_target = rescale(0, 0, 330, 6500, simDR_airspeed)
    ECAM_hyd_rat_rpm = (simDR_rat_on == 1 and A333_set_animation_position(ECAM_hyd_rat_rpm, lcl.RAT_RPM_target, 0, 6500, 0.2)) or 0
    -- A333DR_hyd_rat_prop_rpm (max 5401 + math.randon)

    A333_ECAM_hyd_green_status = (((green_hydraulic_pressure >= 1750 and green_leak_measure_status == 0)
        or ((green_hydraulic_pressure < 1750 and green_hydraulic_pressure > 1450 and green_leak_measure_status == 0) and (green_hydraulic_pressure >= lcl.green_hyd_pressure_store)))
        and 1) or 0

    A333_ECAM_hyd_yellow_status = (((yellow_hydraulic_pressure >= 1750 and yellow_leak_measure_status == 0)
        or ((yellow_hydraulic_pressure < 1750 and yellow_hydraulic_pressure > 1450 and yellow_leak_measure_status == 0) and (yellow_hydraulic_pressure >= lcl.yellow_hyd_pressure_store)))
        and 1) or 0

    A333_ECAM_hyd_blue_status = (((blue_hydraulic_pressure >= 1750 and blue_leak_measure_status == 0)
        or ((blue_hydraulic_pressure < 1750 and blue_hydraulic_pressure > 1450 and blue_leak_measure_status == 0) and (blue_hydraulic_pressure >= lcl.yellow_hyd_pressure_store)))
        and 1) or 0

	lcl.green_hyd_pressure_store = simDR_green_hydraulic_pressure
	lcl.yellow_hyd_pressure_store = simDR_yellow_hydraulic_pressure
	lcl.blue_hyd_pressure_store = simDR_blue_hydraulic_pressure




    A333_ECAM_hyd_green_eng1_fire_valve = (((eng1_hyd_fire_valve_pos == 0 and green_hyd_fluid_ratio < 0.05) and 1)
        or ((eng1_hyd_fire_valve_pos == 0 and green_hyd_fluid_ratio >= 0.05) and 2))
        or 0

    A333_ECAM_hyd_blue_eng1_fire_valve = (((eng1_hyd_fire_valve_pos == 0 and blue_hyd_fluid_ratio < 0.05) and 1)
        or ((eng1_hyd_fire_valve_pos == 0 and blue_hyd_fluid_ratio >= 0.05) and 2))
        or 0

    A333_ECAM_hyd_yellow_eng2_fire_valve = (((eng2_hyd_fire_valve_pos == 0 and yellow_hyd_fluid_ratio < 0.05) and 1)
    or ((eng2_hyd_fire_valve_pos == 0 and yellow_hyd_fluid_ratio >= 0.05) and 2))
    or 0

    A333_ECAM_hyd_green_eng2_fire_valve = (((eng2_hyd_fire_valve_pos == 0 and green_hyd_fluid_ratio < 0.05) and 1)
        or ((eng2_hyd_fire_valve_pos == 0 and green_hyd_fluid_ratio >= 0.05) and 2))
        or 0




    ECAM_hyd_green_eng1_pump = (green_eng1_pump_on == 0 and 0)
        or ((green_eng1_pump_on == 1 and (engine1_hyd_pump_fault ~= 6 and green_hydraulic_pressure > 1450 and eng1_N2 >= 25.1)) and 1)
        or ((green_eng1_pump_on == 1 and ((engine1_hyd_pump_fault == 6) or (engine1_hyd_pump_fault ~= 6 and green_hydraulic_pressure <= 1450) or (engine1_hyd_pump_fault ~= 6 and green_hydraulic_pressure > 1450 and eng1_N2 < 25.1))) and 2)

    ECAM_hyd_blue_eng1_pump = (blue_eng1_pump_on == 0 and 0)
        or ((blue_eng1_pump_on == 1 and (engine1_hyd_pump_fault ~= 6 and blue_hydraulic_pressure > 1450 and eng1_N2 >= 25.1)) and 1)
        or ((blue_eng1_pump_on == 1 and ((engine1_hyd_pump_fault == 6) or (engine1_hyd_pump_fault ~= 6 and blue_hydraulic_pressure <= 1450) or (engine1_hyd_pump_fault ~= 6 and blue_hydraulic_pressure > 1450 and eng1_N2 < 25.1))) and 2)

    ECAM_hyd_yellow_eng2_pump = (yellow_eng2_pump_on == 0 and 0)
        or ((yellow_eng2_pump_on == 1 and (engine2_hyd_pump_fault ~= 6 and yellow_hydraulic_pressure > 1450 and eng2_N2 >= 25.1)) and 1)
        or ((yellow_eng2_pump_on == 1 and ((engine2_hyd_pump_fault == 6) or (engine2_hyd_pump_fault ~= 6 and yellow_hydraulic_pressure <= 1450) or (engine2_hyd_pump_fault ~= 6 and yellow_hydraulic_pressure > 1450 and eng2_N2 < 25.1))) and 2)

    ECAM_hyd_green_eng2_pump = (green_eng2_pump_on == 0 and 0)
        or ((green_eng2_pump_on == 1 and (engine2_hyd_pump_fault ~= 6 and green_hydraulic_pressure > 1450 and eng2_N2 >= 25.1)) and 1)
        or ((green_eng2_pump_on == 1 and ((engine2_hyd_pump_fault == 6) or (engine2_hyd_pump_fault ~= 6 and green_hydraulic_pressure <= 1450) or (engine2_hyd_pump_fault ~= 6 and green_hydraulic_pressure > 1450 and eng2_N2 < 25.1))) and 2)


    A333_ECAM_hyd_elec_green_status = ((A333DR_ac_bus1_has_power == 1 and A333DR_dc_bus1_has_power == 1) and 0) or 1
    A333_ECAM_hyd_elec_blue_status = ((A333DR_ac_bus2_has_power == 1 and A333DR_dc_bus1_has_power == 1) and 0) or 1
    A333_ECAM_hyd_elec_yellow_status = (((A333DR_ac_bus1_has_power == 1 or A333DR_extA_grd_service_bus_pwr == 1) and (A333DR_dc_bus2_has_power == 1 or A333DR_tr2_volts > A333DR_dc_min_volts or A333DR_status_gpu_avail == 1)) and 0) or 1


    ECAM_hyd_elec_green_arrow = ((green_elec_pump_on == 0 and elec_pump_green_tog_pos == 0) and 0)
        or ((green_elec_pump_on == 0 and elec_pump_green_tog_pos >= 1) and 1)
        or ((green_elec_pump_on == 1 and green_hydraulic_pressure >= 1450) and 2)
        or ((green_elec_pump_on == 1 and green_hydraulic_pressure < 1450) and 3)

    ECAM_hyd_elec_blue_arrow = ((blue_elec_pump_on == 0 and elec_pump_blue_tog_pos == 0) and 0)
        or ((blue_elec_pump_on == 0 and elec_pump_blue_tog_pos >= 1) and 1)
        or ((blue_elec_pump_on == 1 and blue_hydraulic_pressure >= 1450) and 2)
        or ((blue_elec_pump_on == 1 and blue_hydraulic_pressure < 1450) and 3)

    ECAM_hyd_elec_yellow_arrow = ((yellow_elec_pump_on == 0 and elec_pump_yellow_tog_pos == 0) and 0)
        or ((yellow_elec_pump_on == 0 and elec_pump_yellow_tog_pos >= 1) and 1)
        or ((yellow_elec_pump_on == 1 and yellow_hydraulic_pressure >= 1450) and 2)
        or ((yellow_elec_pump_on == 1 and yellow_hydraulic_pressure < 1450) and 3)


	ECAM_hyd_rat_arrow_enum = (rat_on == 0 and 0)
		or ((rat_on == 1 and ECAM_hyd_rat_rpm >= 3000 and green_hyd_fluid_ratio >= 0.05) and 1)
		or ((rat_on == 1 and ((ECAM_hyd_rat_rpm < 3000) or (ECAM_hyd_rat_rpm >= 3000 and green_hyd_fluid_ratio < 0.05))) and 2)



	A333_ECAM_hyd_rat_status = (((rat_on == 1 and ECAM_hyd_rat_rpm < 3000) and 0)
        or ((rat_on == 0 or (rat_on == 1  and ECAM_hyd_rat_rpm >= 3000)) and 1))



    A333_ECAM_hyd_green1_line_fin = ((ECAM_hyd_green_eng1_pump ~= 1 and ECAM_hyd_elec_green_arrow ~= 2) and 0)
        or (((ECAM_hyd_green_eng1_pump == 1) or (ECAM_hyd_green_eng1_pump ~= 1 and ECAM_hyd_elec_green_arrow == 2)) and 1)

    A333_ECAM_hyd_blue_line_fin = ((ECAM_hyd_blue_eng1_pump ~= 1 and ECAM_hyd_elec_blue_arrow ~= 2) and 0)
        or (((ECAM_hyd_blue_eng1_pump == 1) or (ECAM_hyd_blue_eng1_pump ~= 1 and ECAM_hyd_elec_blue_arrow == 2)) and 1)

    A333_ECAM_hyd_yellow_line_fin = ((ECAM_hyd_yellow_eng2_pump ~= 1 and ECAM_hyd_elec_yellow_arrow ~= 2) and 0)
        or (((ECAM_hyd_yellow_eng2_pump == 1) or (ECAM_hyd_yellow_eng2_pump ~= 1 and ECAM_hyd_elec_yellow_arrow == 2)) and 1)

    A333_ECAM_hyd_green2_line_fin_eng2 = ((ECAM_hyd_green_eng2_pump ~= 1 and ECAM_hyd_rat_arrow_enum ~= 1) and 0)
        or (((ECAM_hyd_green_eng2_pump == 1) or (ECAM_hyd_green_eng2_pump ~= 1 and ECAM_hyd_rat_arrow_enum == 1)) and 1)

	A333_ECAM_hyd_green2_line_fin_eng1 = ((A333_ECAM_hyd_green1_line_fin == 1 or A333_ECAM_hyd_green2_line_fin_eng2 == 1) and 1) or 0

    A333_ECAM_hyd_elec_green_arrow = ECAM_hyd_elec_green_arrow
    A333_ECAM_hyd_elec_blue_arrow = ECAM_hyd_elec_blue_arrow
    A333_ECAM_hyd_elec_yellow_arrow = ECAM_hyd_elec_yellow_arrow
    A333_ECAM_hyd_rat_arrow_enum = ECAM_hyd_rat_arrow_enum
    A333_ECAM_hyd_rat_rpm = ECAM_hyd_rat_rpm
    A333_ECAM_hyd_green_eng1_pump = ECAM_hyd_green_eng1_pump
    A333_ECAM_hyd_blue_eng1_pump = ECAM_hyd_blue_eng1_pump
    A333_ECAM_hyd_yellow_eng2_pump = ECAM_hyd_yellow_eng2_pump
    A333_ECAM_hyd_green_eng2_pump = ECAM_hyd_green_eng2_pump

end




---- ECAM FLIGHT CONTROLS
local function A333_ecam_page_FCTL()

	local otbd_aileron_max_up = -25 + (50 * A333_outboard_ail_droop_rat)
	local inbd_aileron_max_up = -25 + (50 * A333_inboard_ail_droop_rat)
	local left_elevator_max_up = -30 + (45 * A333_left_hstab_droop_rat)
	local right_elevator_max_up = -30 + (45 * A333_right_hstab_droop_rat)

    local yellow_hydraulic_pressure = simDR_yellow_hydraulic_pressure
    local green_hydraulic_pressure = simDR_green_hydraulic_pressure
    local blue_hydraulic_pressure = simDR_blue_hydraulic_pressure

	local green_leak_measurement_stat = A333_green_leak_measure_status -- 0 = valve open, 1 = valve closed (OFF)
	local blue_leak_measurement_stat = A333_blue_leak_measure_status -- 0 = valve open, 1 = valve closed (OFF)
	local yellow_leak_measurement_stat = A333_yellow_leak_measure_status -- 0 = valve open, 1 = valve closed (OFF)

    local spoiler1_L = simDR_spoiler1_L
    local spoiler2_L = simDR_spoiler2_L
    local spoiler3_L = simDR_spoiler3_L
    local spoiler4_5_L = simDR_spoiler4_5_L
    local spoiler6_L = simDR_spoiler6_L
    local spoiler1_R = simDR_spoiler1_R
    local spoiler2_R = simDR_spoiler2_R
    local spoiler3_R = simDR_spoiler3_R
    local spoiler4_5_R = simDR_spoiler4_5_R
    local spoiler6_R = simDR_spoiler6_R

	A333_outer_L_ail = rescale(-25, otbd_aileron_max_up, 25, 25, simDR_outer_aileron_L)
	A333_outer_R_ail = rescale(-25, otbd_aileron_max_up, 25, 25, simDR_outer_aileron_R)

	A333_inner_L_ail = rescale(-25, inbd_aileron_max_up, 25, 25, simDR_inner_aileron_L)
	A333_inner_R_ail = rescale(-25, inbd_aileron_max_up, 25, 25, simDR_inner_aileron_R)

	A333_L_elev = rescale(-30, left_elevator_max_up, 15, 15, simDR_elevator_L)
	A333_R_elev = rescale(-30, right_elevator_max_up, 15, 15, simDR_elevator_R)

    A333_outer_L_ail_amber_status = (((yellow_hydraulic_pressure >= 100 and yellow_leak_measurement_stat == 0) or (green_hydraulic_pressure >= 100 and green_leak_measurement_stat == 0)) and 1) or 0
    A333_outer_R_ail_amber_status = (((yellow_hydraulic_pressure >= 100 and yellow_leak_measurement_stat == 0) or (green_hydraulic_pressure >= 100 and green_leak_measurement_stat == 0)) and 1) or 0
    
    A333_inner_L_ail_amber_status = (((green_hydraulic_pressure >= 100 and green_leak_measurement_stat == 0) or (blue_hydraulic_pressure >= 100 and blue_leak_measurement_stat == 0)) and 1) or 0
    A333_inner_R_ail_amber_status = (((green_hydraulic_pressure >= 100 and green_leak_measurement_stat == 0) or (blue_hydraulic_pressure >= 100 and blue_leak_measurement_stat == 0)) and 1) or 0

    A333_L_elev_amber_status = (((green_hydraulic_pressure >= 200 and green_leak_measurement_stat == 0) or (blue_hydraulic_pressure >= 200 and blue_leak_measurement_stat == 0)) and 1) or 0
    A333_R_elev_amber_status = (((yellow_hydraulic_pressure >= 200 and yellow_leak_measurement_stat == 0) or (green_hydraulic_pressure >= 200 and green_leak_measurement_stat == 0)) and 1) or 0

    A333_rud_amber_status = (((green_hydraulic_pressure >= 250 and green_leak_measurement_stat == 0) or (blue_hydraulic_pressure >= 250 and blue_leak_measurement_stat == 0) or (yellow_hydraulic_pressure >= 250 and yellow_leak_measurement_stat == 0)) and 1) or 0

    A333_pitch_amber_status = (((blue_hydraulic_pressure >= 225 and blue_leak_measurement_stat == 0) or (yellow_hydraulic_pressure >= 225 and yellow_leak_measurement_stat == 0)) and 1) or 0

    A333_spoiler1_L_enum = ((green_leak_measurement_stat == 1 or green_hydraulic_pressure <= 100) and 0)
        or (green_hydraulic_pressure > 100 and ((spoiler1_L < 0.1 and 1) or (spoiler1_L >= 0.1 and 2)))

    A333_spoiler2_L_enum = ((blue_leak_measurement_stat == 1 or blue_hydraulic_pressure <= 100) and 0)
        or (blue_hydraulic_pressure > 100 and ((spoiler2_L < 0.1 and 1) or (spoiler2_L >= 0.1 and 2)))

    A333_spoiler3_L_enum = ((blue_leak_measurement_stat == 1 or blue_hydraulic_pressure <= 100) and 0)
        or (blue_hydraulic_pressure > 100 and ((spoiler3_L < 0.1 and 1) or (spoiler3_L >= 0.1 and 2)))

    A333_spoiler4_L_enum = ((green_leak_measurement_stat == 1 or green_hydraulic_pressure <= 100) and 0)
        or (green_hydraulic_pressure > 100 and ((spoiler4_5_L < 0.1 and 1) or (spoiler4_5_L >= 0.1 and 2)))

    A333_spoiler5_L_enum = ((green_leak_measurement_stat == 1 or green_hydraulic_pressure <= 100) and 0)
        or (green_hydraulic_pressure > 100 and ((spoiler4_5_L < 0.1 and 1) or (spoiler4_5_L >= 0.1 and 2)))

    A333_spoiler6_L_enum = ((yellow_leak_measurement_stat == 1 or yellow_hydraulic_pressure <= 100) and 0)
        or (yellow_hydraulic_pressure > 100 and ((spoiler6_L < 0.1 and 1) or (spoiler6_L >= 0.1 and 2)))

    A333_spoiler1_R_enum = ((green_leak_measurement_stat == 1 or green_hydraulic_pressure <= 100) and 0)
        or (green_hydraulic_pressure > 100 and ((spoiler1_R < 0.1 and 1) or (spoiler1_R >= 0.1 and 2)))

    A333_spoiler2_R_enum = ((blue_leak_measurement_stat == 1 or blue_hydraulic_pressure <= 100) and 0)
        or (blue_hydraulic_pressure > 100 and ((spoiler2_R < 0.1 and 1) or (spoiler2_R >= 0.1 and 2)))

    A333_spoiler3_R_enum = ((blue_leak_measurement_stat == 1 or blue_hydraulic_pressure <= 100) and 0)
        or (blue_hydraulic_pressure > 100 and ((spoiler3_R < 0.1 and 1) or (spoiler3_R >= 0.1 and 2)))

    A333_spoiler4_R_enum = ((green_leak_measurement_stat == 1 or green_hydraulic_pressure <= 100) and 0)
        or (green_hydraulic_pressure > 100 and ((spoiler4_5_R < 0.1 and 1) or (spoiler4_5_R >= 0.1 and 2)))

    A333_spoiler5_R_enum = ((green_leak_measurement_stat == 1 or green_hydraulic_pressure <= 100) and 0)
        or (green_hydraulic_pressure > 100 and ((spoiler4_5_R < 0.1 and 1) or (spoiler4_5_R >= 0.1 and 2)))

    A333_spoiler6_R_enum = ((yellow_leak_measurement_stat == 1 or yellow_hydraulic_pressure <= 100) and 0)
        or (yellow_hydraulic_pressure > 100 and ((spoiler6_R < 0.1 and 1) or (spoiler6_R >= 0.1 and 2)))


    A333_rudder_trim_ind = simDR_rudder_trim_ratio * rescale(150, 1, 350, 0.114213198, simDR_capt_airspeed)

	A333_green_status = ((green_hydraulic_pressure >= 1450 and green_leak_measurement_stat == 0) and 1) or 0
	A333_blue_status = ((blue_hydraulic_pressure >= 1450 and blue_leak_measurement_stat == 0) and 1) or 0
	A333_yellow_status = ((yellow_hydraulic_pressure >= 1450 and yellow_leak_measurement_stat == 0) and 1) or 0

end

---- FLIGHT CONTROL LOCKOUT WITH LEAK MEASUREMENT TEST - this doesn't work perfectly... not enough granularity with the spoiler failures

local function A333_leak_measurement_lockout()

	local green_leak_measurement_stat = A333_green_leak_measure_status -- 0 = valve open, 1 = valve closed (OFF)
	local blue_leak_measurement_stat = A333_blue_leak_measure_status -- 0 = valve open, 1 = valve closed (OFF)
	local yellow_leak_measurement_stat = A333_yellow_leak_measure_status -- 0 = valve open, 1 = valve closed (OFF)

	local yellow_hydraulic_pressure = simDR_yellow_hydraulic_pressure
    local green_hydraulic_pressure = simDR_green_hydraulic_pressure
    local blue_hydraulic_pressure = simDR_blue_hydraulic_pressure

	simDR_speedbrake1_left_lock = (green_leak_measurement_stat == 1) and 6 or 0
	simDR_speedbrake1_right_lock = (green_leak_measurement_stat == 1) and 6 or 0

	simDR_spoiler1_left_lock = ((green_leak_measurement_stat == 1) or (blue_leak_measurement_stat == 1)) and 6 or 0
	simDR_spoiler1_right_lock = ((green_leak_measurement_stat == 1) or (blue_leak_measurement_stat == 1)) and 6 or 0

	simDR_spoiler2_left_lock = ((blue_leak_measurement_stat == 1) or (yellow_leak_measurement_stat == 1)) and 6 or 0
	simDR_spoiler2_right_lock = ((blue_leak_measurement_stat == 1) or (yellow_leak_measurement_stat == 1)) and 6 or 0

	if blue_hydraulic_pressure > 100 and green_hydraulic_pressure > 100 and (blue_leak_measurement_stat == 1 and green_leak_measurement_stat == 1) then
		simDR_aileron1_left_lock = 6
		simDR_aileron1_right_lock = 6
		simDR_slats_lock = 6
	elseif blue_hydraulic_pressure < 100 and green_hydraulic_pressure > 100 and green_leak_measurement_stat == 1 then
		simDR_aileron1_left_lock = 6
		simDR_aileron1_right_lock = 6
		simDR_slats_lock = 6
	elseif blue_hydraulic_pressure > 100 and green_hydraulic_pressure < 100 and blue_leak_measurement_stat == 1 then
		simDR_aileron1_left_lock = 6
		simDR_aileron1_right_lock = 6
		simDR_slats_lock = 6
	else simDR_aileron1_left_lock = 0
		simDR_aileron1_right_lock = 0
		simDR_slats_lock = 0
	end

	if yellow_hydraulic_pressure > 100 and green_hydraulic_pressure > 100 and (yellow_leak_measurement_stat == 1 and green_leak_measurement_stat == 1) then
		simDR_aileron2_left_lock = 6
		simDR_aileron2_right_lock = 6
		simDR_flaps_lock = 6
	elseif yellow_hydraulic_pressure < 100 and green_hydraulic_pressure > 100 and green_leak_measurement_stat == 1 then
		simDR_aileron2_left_lock = 6
		simDR_aileron2_right_lock = 6
		simDR_flaps_lock = 6
	elseif yellow_hydraulic_pressure > 100 and green_hydraulic_pressure < 100 and yellow_leak_measurement_stat == 1 then
		simDR_aileron2_left_lock = 6
		simDR_aileron2_right_lock = 6
		simDR_flaps_lock = 6
	else simDR_aileron2_left_lock = 0
		simDR_aileron2_right_lock = 0
		simDR_flaps_lock = 0
	end

	if blue_hydraulic_pressure > 200 and green_hydraulic_pressure > 200 and (blue_leak_measurement_stat == 1 and green_leak_measurement_stat == 1) then
		simDR_elevator_left_lock = 6
	elseif blue_hydraulic_pressure < 200 and green_hydraulic_pressure > 200 and green_leak_measurement_stat == 1 then
		simDR_elevator_left_lock = 6
	elseif blue_hydraulic_pressure > 200 and green_hydraulic_pressure < 200 and blue_leak_measurement_stat == 1 then
		simDR_elevator_left_lock = 6
	else simDR_elevator_left_lock = 0
	end
	
	if yellow_hydraulic_pressure > 100 and green_hydraulic_pressure > 100 and (yellow_leak_measurement_stat == 1 and green_leak_measurement_stat == 1) then
		simDR_elevator_right_lock = 6
	elseif yellow_hydraulic_pressure < 100 and green_hydraulic_pressure > 100 and green_leak_measurement_stat == 1 then
		simDR_elevator_right_lock = 6
	elseif yellow_hydraulic_pressure > 100 and green_hydraulic_pressure < 100 and yellow_leak_measurement_stat == 1 then
		simDR_elevator_right_lock = 6
	else simDR_elevator_right_lock = 0
	end

	if blue_hydraulic_pressure > 250 and green_hydraulic_pressure > 250 and yellow_hydraulic_pressure > 250 and (blue_leak_measurement_stat == 1 and green_leak_measurement_stat == 1 and yellow_leak_measurement_stat == 1) then
		simDR_rudder_lock = 6
	elseif blue_hydraulic_pressure > 250 and green_hydraulic_pressure > 250 and yellow_hydraulic_pressure < 250 and (blue_leak_measurement_stat == 1 and green_leak_measurement_stat == 1) then
		simDR_rudder_lock = 6
	elseif blue_hydraulic_pressure > 250 and green_hydraulic_pressure < 250 and yellow_hydraulic_pressure > 250 and (blue_leak_measurement_stat == 1 and yellow_leak_measurement_stat == 1) then
		simDR_rudder_lock = 6
	elseif blue_hydraulic_pressure < 250 and green_hydraulic_pressure > 250 and yellow_hydraulic_pressure > 250 and (green_leak_measurement_stat == 1 and yellow_leak_measurement_stat == 1) then
		simDR_rudder_lock = 6
	elseif blue_hydraulic_pressure > 250 and green_hydraulic_pressure < 250 and yellow_hydraulic_pressure < 250 and blue_leak_measurement_stat == 1 then
		simDR_rudder_lock = 6	
	elseif blue_hydraulic_pressure < 250 and green_hydraulic_pressure > 250 and yellow_hydraulic_pressure < 250 and green_leak_measurement_stat == 1 then
		simDR_rudder_lock = 6
	elseif blue_hydraulic_pressure < 250 and green_hydraulic_pressure < 250 and yellow_hydraulic_pressure > 250 and yellow_leak_measurement_stat == 1 then
		simDR_rudder_lock = 6
	else simDR_rudder_lock = 0
	end
	
end


---- ECAM ELECTRICAL / APU PAGE
local function A333_ecam_page_APU()         -- TODO:  consider refactor to multiple functions ??

	local ac_min_volts = A333DR_ac_min_volts
	local dc_min_volts = A333DR_dc_min_volts

    local APU_starter_switch = simDR_APU_starter_switch
    local APU_N1 = simDR_APU_N1
    local apu_gen_amps = simDR_apu_gen_amps
    local apu_gen_on = simDR_apu_gen_on
    local TAT = simDR_TAT
    local EGT = simDR_EGT
    local generator_amps = simDR_generator_amps
    local gpu_on = simDR_gpu_on
    local gen_on = simDR_gen_on
    local gpu_amps = simDR_gpu_amps
    local eng_N2 = simDR_eng_N2
 	local gen1_volts = simDR_gen1_volts
 	local gen2_volts = simDR_gen2_volts 	
 	local gen1_volts_ECAM = A333_ECAM_gen1_volts
  	local gen2_volts_ECAM = A333_ECAM_gen2_volts		
    local gen1_fail = simDR_gen1_fail
    local gen2_fail = simDR_gen2_fail
	local IDG1_status = A333_IDG1_status
	local IDG2_status = A333_IDG2_status
    local bus1_fail = simDR_bus1_fail
    local bus2_fail = simDR_bus2_fail
    local bus1_power = simDR_bus1_power
    local bus2_power = simDR_bus2_power
    local ess_ties = simDR_ess_ties
    local ess_bus_fail = simDR_ess_bus_fail
    local ess_bus_power = simDR_ess_bus_power
    local battery_status = simDR_battery_status
    local bat3_fail = simDR_bat3_fail
    local gear_on_ground = simDR_gear_on_ground
    local bat_amps = simDR_bat_amps
    local bus_amps = simDR_bus_amps
    local gen1_ctct_on_off = A333_buttons_gen1_ctct_on_off
    local gen2_ctct_on_off = A333_buttons_gen2_ctct_on_off
	local batteries_only_supply = A333_batteries_only_supply

	local ac_bus1_has_power = A333DR_ac_bus1_has_power
	local ac_bus2_has_power = A333DR_ac_bus2_has_power
	local ac_ess_bus_has_power = A333DR_ac_ess_bus_has_power

    local volts_rand_target = m.random(-5, 5)
    local hertz_rand_target = m.random(-5, 5)

    local volts_rand2_target = m.random(-4, 4)
    local hertz_rand2_target = m.random(-5, 5)

    local volts_rand3_target = m.random(-4, 4)
    local hertz_rand3_target = m.random(-5, 5)

    local volts_rand4_target = m.random(-5, 5)
    local hertz_rand4_target = m.random(-5, 5)

	local volts_rand5_target = m.random(-5, 5)
	local hertz_rand5_target = m.random(-5, 5)

	local volts_rand6_target = m.random(-5, 5)
	local hertz_rand6_target = m.random(-5, 5)

    local ECAM_crossbar1_line = A333_ECAM_crossbar1_line
    local ECAM_crossbar2_line = A333_ECAM_crossbar2_line
    local ECAM_crossbar3_line = A333_ECAM_crossbar3_line
    local ECAM_apu_gen_line = A333_ECAM_apu_gen_line
    local ECAM_gpu_line = A333_ECAM_gpu_line
    local ECAM_elec_ess_tr_status = A333_ECAM_elec_ess_tr_status
    local ECAM_elec_tr1_status = A333_ECAM_elec_tr1_status
    local ECAM_elec_tr2_status = A333_ECAM_elec_tr2_status
    local ECAM_elec_apu_tr_status = A333_ECAM_elec_apu_tr_status

	local tr1_volts = A333DR_tr1_volts
	local tr2_volts = A333DR_tr2_volts
	local apu_tr_volts = A333DR_apu_tr_volts
	local ess_tr_volts = A333DR_ess_tr_volts

	local batt1_ctct = A333_buttons_battery1_ctct_on_off
	local batt2_ctct = A333_buttons_battery2_ctct_on_off
	local batt_apu_ctct = A333_buttons_apu_bat_ctct_on_off
	local sys_isol_contactor = A333_sys_isol_contactor
	local ac1_bus_tie_contactor = A333_ac1_bus_tie_contactor
	local ac2_bus_tie_contactor = A333_ac2_bus_tie_contactor

	local stat_inv_status = A333_ECAM_stat_inv_status
	local emer_gen_status = A333_ECAM_emer_gen_status
	local elec_ac_ess_source = A333DR_elec_ac_ess_source

	local green_pressure = simDR_green_hydraulic_pressure

    A333_ECAM_APU_needles_vis = (((APU_starter_switch >= 1)
        or (APU_starter_switch == 0 and APU_N1 > 5)) and 1)
        or 0

    A333_ECAM_APU_GEN_status = (((APU_starter_switch == 0)
        or (APU_starter_switch == 1 and APU_N1 >= 95)) and 1)
        or 0

	lcl.apu_psi_target = rescale(95, 0, 100, 42, simDR_APU_N1) - lcl.apu_psi_target * (simDR_APU_loss_ratio / 100)
	A333_ECAM_APU_PSI = A333_set_animation_position(A333_ECAM_APU_PSI, lcl.apu_psi_target, 0, 42, 0.2)


	lcl.volts_rand = A333_set_animation_position(lcl.volts_rand, volts_rand_target, -2, 2, 0.4)
	lcl.hertz_rand = A333_set_animation_position(lcl.hertz_rand, hertz_rand_target, -5, 5, 0.4)

	lcl.volts_rand2 = A333_set_animation_position(lcl.volts_rand2, volts_rand2_target, (-0.85 * simDR_engine1_running), (0.85 * simDR_engine1_running), 0.4)
	lcl.hertz_rand2 = A333_set_animation_position(lcl.hertz_rand2, hertz_rand2_target, (-5 * simDR_engine1_running), (5 * simDR_engine1_running), 0.4)

	lcl.volts_rand3 = A333_set_animation_position(lcl.volts_rand3, volts_rand3_target, (-0.85 * simDR_engine2_running), (0.85 * simDR_engine2_running), 0.4)
	lcl.hertz_rand3 = A333_set_animation_position(lcl.hertz_rand3, hertz_rand3_target, (-5 * simDR_engine2_running), (5 * simDR_engine2_running), 0.4)

	lcl.volts_rand4 = A333_set_animation_position(lcl.volts_rand4, volts_rand4_target, -2, 2, 0.4)
	lcl.hertz_rand4 = A333_set_animation_position(lcl.hertz_rand4, hertz_rand4_target, -5, 5, 0.4)

	lcl.volts_rand5 = A333_set_animation_position(lcl.volts_rand5, volts_rand5_target, -2, 2, 0.4)
	lcl.hertz_rand5 = A333_set_animation_position(lcl.hertz_rand5, hertz_rand5_target, -5, 5, 0.4)
	
	lcl.volts_rand6 = A333_set_animation_position(lcl.volts_rand6, volts_rand6_target, -2, 2, 0.4)
	lcl.hertz_rand6 = A333_set_animation_position(lcl.hertz_rand6, hertz_rand6_target, -5, 5, 0.4)

    A333_ECAM_APU_volts = ((APU_N1 < 95) and 0) or (115 + lcl.volts_rand)
    A333_ECAM_APU_hertz = ((APU_N1 < 95) and 0) or (400 + lcl.hertz_rand)

	if IDG1_status == 1 then
		gen1_volts_ECAM = simDR_gen1_volts + (lcl.volts_rand2 * (simDR_gen1_volts / 115))
	elseif IDG1_status == 0 then
		gen1_volts_ECAM = A333_set_animation_position(gen1_volts_ECAM, 0, 0, 115, 0.2)
	end

	if IDG2_status == 1 then
		gen2_volts_ECAM = simDR_gen2_volts + (lcl.volts_rand3 * (simDR_gen2_volts / 115))
	elseif IDG2_status == 0 then
		gen2_volts_ECAM = A333_set_animation_position(gen2_volts_ECAM, 0, 0, 115, 0.2)
	end

    A333_ECAM_gen1_hertz = rescale(28.75, 0, 115.0, 400 + lcl.hertz_rand2, gen1_volts_ECAM)
    A333_ECAM_gen2_hertz = rescale(28.75, 0, 115.0, 400 + lcl.hertz_rand3, gen2_volts_ECAM)


--[[ -- GENERATOR DISCONNECT DEBUGGING

	if A333_ECAM_gen1_hertz < 395.25 then
		print("Gen1 Hertz OUT OF RANGE: " .. tostring(A333_ECAM_gen1_hertz))
		print("Gen1 VOLTS: " .. tostring(gen1_volts_ECAM))
		print("Gen1 Hz_rand_value: " .. tostring(lcl.hertz_rand2))
		print("Gen1 Volts_rand_value: " .. tostring(lcl.volts_rand2))
		print("Gen1 STATUS: " .. tostring(simDR_gen1_on))
	end

	if A333_ECAM_gen2_hertz < 395.25 then
		print("Gen2 Hertz OUT OF RANGE: " .. tostring(A333_ECAM_gen2_hertz))
		print("Gen2 VOLTS: " .. tostring(gen2_volts_ECAM))
		print("Gen2 Hz_rand_value: " .. tostring(lcl.hertz_rand3))
		print("Gen2 Volts_rand_value: " .. tostring(lcl.volts_rand3))
		print("Gen2 STATUS: " .. tostring(simDR_gen2_on))
	end

]]--

    A333_ECAM_ext_a_volts = ((gpu_on == 0) and 0) or (115 + lcl.volts_rand4)
    A333_ECAM_ext_a_hertz = ((gpu_on == 0) and 0) or (400 + lcl.hertz_rand4)
    A333_ECAM_ext_b_volts = 0
    A333_ECAM_ext_b_hertz = 0


    lcl.calculated_EGT_lim = (APU_N1 <= 10 and 1250)
        or ((APU_N1 > 10 and APU_N1 <= 15) and rescale(10, 1250, 15, 1020, APU_N1))
        or ((APU_N1 > 15 and APU_N1 <= 30) and rescale(15, 1020, 30, 950, APU_N1))
        or ((APU_N1 > 30 and APU_N1 <= 40) and 950)
        or ((APU_N1 > 40 and APU_N1 <= 70) and rescale(40, 950, 70, 720, APU_N1))
        or (APU_N1 > 70 and rescale(70, 720, 100, 650, APU_N1))


    A333_ECAM_APU_egt_hot_status = ((simDR_APU_EGT > lcl.calculated_EGT_lim) and 1) or 0

    A333_ECAM_elec_apu_gen_status = (((APU_starter_switch >= 1)
            and ((apu_gen_amps >= 5 and apu_gen_on == 1 and (simDR_apu_fail == 6 or simDR_apu_fire == 6))
            or (apu_gen_amps < 5 or apu_gen_on == 0)))
            and 1) or 0

    A333_ECAM_elec_gen1_label_status = (gen1_ctct_on_off == 1 and eng_N2[0] >= 57 and gen1_fail < 6 and IDG1_status == 1)
        and 1 or 0

    A333_ECAM_elec_gen2_label_status = (gen2_ctct_on_off == 1 and eng_N2[1] >= 57 and gen2_fail < 6 and IDG2_status == 1)
        and 1 or 0

	if gen_on[0] == 0 then
		lcl.idg1_temp_target = TAT + ( 0.05 * (EGT[0] - TAT))
	elseif gen_on[0] == 1 then
		if IDG1_status == 1 then
			lcl.idg1_temp_target = TAT + (0.05 * (EGT[0] - TAT) + (generator_amps[0] / 333) * 150)
		elseif IDG1_status == 0 then
			lcl.idg1_temp_target = TAT + (0.05 * (EGT[0] - TAT))
		end
	end

    if gen_on[1] == 0 then
            lcl.idg2_temp_target = TAT + ( 0.05 * (EGT[1] - TAT))
	elseif gen_on[1] == 1 then
		if IDG2_status == 1 then
			lcl.idg2_temp_target = TAT + (0.05 * (EGT[1] - TAT) + (generator_amps[1] / 333) * 150)
		elseif IDG2_status == 0 then
			lcl.idg2_temp_target = TAT + (0.05 * (EGT[1] - TAT))
		end
	end

	A333_ECAM_idg1_temp = A333_set_animation_position(A333_ECAM_idg1_temp, lcl.idg1_temp_target, -40, 250, 0.025)
	A333_ECAM_idg2_temp = A333_set_animation_position(A333_ECAM_idg2_temp, lcl.idg2_temp_target, -40, 250, 0.025)

	ECAM_crossbar1_line = ac1_bus_tie_contactor
	ECAM_crossbar3_line = ac2_bus_tie_contactor

	if sys_isol_contactor == 1 then
		ECAM_crossbar2_line = 1
	elseif sys_isol_contactor == 0 then

		if ac1_bus_tie_contactor == 1 and ac2_bus_tie_contactor == 0 then
			if gpu_on == 1 then
				ECAM_crossbar2_line = 1
			elseif gpu_on == 0 then
				ECAM_crossbar2_line = 0
			end
		elseif ac1_bus_tie_contactor == 0 and ac2_bus_tie_contactor == 1 then
			if apu_gen_amps >= 2.5 and apu_gen_on == 1 then
				ECAM_crossbar2_line = 1
			elseif apu_gen_amps < 2.5 or apu_gen_on == 0 then
				ECAM_crossbar2_line = 0
			end
		elseif ac1_bus_tie_contactor == 1 and ac2_bus_tie_contactor == 1 then
			ECAM_crossbar2_line = 0
		elseif ac1_bus_tie_contactor == 0 and ac2_bus_tie_contactor == 0 then
			ECAM_crossbar2_line = 0
		end

	end


    -- APU line
	if bus1_fail ~= 6 then

		if apu_gen_on == 1 then
			if ac_bus1_has_power == 1 or ac_bus2_has_power == 1 then
                ECAM_apu_gen_line = 1
			elseif ac_bus1_has_power == 0 and ac_bus2_has_power == 0 then
                ECAM_apu_gen_line = 0
			end
		elseif apu_gen_on == 0 then
            ECAM_apu_gen_line = 0
		end

	elseif bus1_fail == 6 then

		if sys_isol_contactor == 0 then
            ECAM_apu_gen_line = 0
		elseif sys_isol_contactor == 1 then
            ECAM_apu_gen_line = apu_gen_on
		end

	end

	-- GPU line
	if bus1_fail ~= 6 then

		if gpu_amps >= 2.5 and gpu_on == 1 then
			if ac_bus1_has_power == 1 or ac_bus2_has_power == 1 then
                ECAM_gpu_line = 1
			elseif ac_bus1_has_power == 0 and ac_bus2_has_power == 0 then
                ECAM_gpu_line = 0
			end
		elseif gpu_amps < 2.5 or gpu_on == 0 then
            ECAM_gpu_line = 0
		end

	elseif bus1_fail == 6 then

		if sys_isol_contactor == 0 then
            ECAM_gpu_line = 0
		elseif sys_isol_contactor == 1 then
			if gpu_amps >= 2.5 and gpu_on == 1 then
                ECAM_gpu_line = 1
			elseif gpu_amps < 2.5 or gpu_on == 0 then
                ECAM_gpu_line = 0
			end
		end

	end

	-- STAT INV BOX / EMER GEN BOX

	stat_inv_status = ((elec_ac_ess_source == 4 and batteries_only_supply == 1) and 1) or 0
	
	A333_ECAM_stat_inv_volts = ((stat_inv_status == 0) and 0) or ((A333DR_dc_bat_bus_volts * 4.29104) + lcl.volts_rand5)
    A333_ECAM_stat_inv_hertz = ((stat_inv_status == 0) and 0) or (400 + lcl.hertz_rand5)
	
	emer_gen_status = ((elec_ac_ess_source == 3 and simDR_RAT_gen_on == 1) and 1) or 0
	
	A333_ECAM_emer_gen_volts = ((emer_gen_status == 0) and 0) or (simDR_RAT_gen_volts + lcl.volts_rand6)



    A333_ECAM_emer_gen_hertz = ((emer_gen_status == 0) and 0) or (rescale(900,0,1450,400, green_pressure) + lcl.hertz_rand6)	
    -- NOTE:  The Emergency Generator is driven by a hydaulic motor, not directly by the RAT.  And, it can be turned on
    -- even if the RAT is not deployed.  So, Hz should be based on hydraulic pressure, with a hard cutoff of 1450 psi
    -- being the point at which the emergency generator will no longer produce any power, > 1450 == full electrical power.



	-- DC PAGE --

	ECAM_elec_tr1_status = (tr1_volts >= dc_min_volts and 1) or 0
	ECAM_elec_tr2_status = (tr2_volts >= dc_min_volts and 1) or 0
	
	ECAM_elec_apu_tr_status = (apu_tr_volts >= dc_min_volts and 1) or 0
	
	ECAM_elec_ess_tr_status = (ess_tr_volts >= dc_min_volts and 1) or 0

	A333_ECAM_elec_tr1_volts_display = (tr1_volts > 1 and tr1_volts + lcl.volts_rand2) or tr1_volts
	A333_ECAM_elec_tr2_volts_display = (tr2_volts > 1 and tr2_volts + lcl.volts_rand3) or tr2_volts
	A333_ECAM_elec_apu_tr_volts_display = (apu_tr_volts > 1 and apu_tr_volts + lcl.volts_rand3) or apu_tr_volts
	A333_ECAM_elec_ess_tr_volts_display = (ess_tr_volts > 1 and ess_tr_volts + lcl.volts_rand4) or ess_tr_volts

	A333_ECAM_elec_dc_apu_bus_status = A333DR_dc_apu_bat_bus_has_power

    A333_ECAM_elec_dc1_dcbat_line_sts = ((ECAM_elec_ess_tr_status == 0 and (ECAM_elec_tr1_status == 0 and ECAM_elec_tr2_status == 0)) and 0) or 1

    A333_ECAM_elec_dc2_dcbat_line_sts = ((ECAM_elec_ess_tr_status == 0
        and ((ECAM_elec_tr1_status == 1 and ECAM_elec_tr2_status == 1) or (ECAM_elec_tr1_status == 0 and ECAM_elec_tr2_status == 0))) and 0) or 1

    A333_ECAM_elec_dcbat_dcess_line_sts = ((ECAM_elec_ess_tr_status == 0 and (ECAM_elec_tr1_status == 1 and ECAM_elec_tr2_status == 1)) and 1) or 0

	lcl.dc_ess_bat_feed = ((A333DR_dc_ess_bus_has_power == 1 and batteries_only_supply == 1) and 1) or 0


	if A333DR_bat1_line_contactor == 1 then
		if A333DR_bat1_is_charging == 0 then
			A333_ECAM_elec_bat1_dc_bat_line_sts = 1
		else A333_ECAM_elec_bat1_dc_bat_line_sts = 2
		end
	else A333_ECAM_elec_bat1_dc_bat_line_sts = 0
	end
	
	if A333DR_bat2_line_contactor == 1 then
		if A333DR_bat2_is_charging == 0 then
			A333_ECAM_elec_bat2_dc_bat_line_sts = 1
		else A333_ECAM_elec_bat2_dc_bat_line_sts = 2
		end
	else A333_ECAM_elec_bat2_dc_bat_line_sts = 0
	end

	if A333DR_apu_bat_line_contactor == 1 then
		if A333DR_apu_bat_is_charging == 0 then
			A333_ECAM_elec_apu_bat_dc_apu_line_sts = 1
		else A333_ECAM_elec_apu_bat_dc_apu_line_sts = 2
		end
	else A333_ECAM_elec_apu_bat_dc_apu_line_sts = 0
	end

    A333_ECAM_crossbar1_line = ECAM_crossbar1_line
    A333_ECAM_crossbar2_line = ECAM_crossbar2_line
    A333_ECAM_crossbar3_line = ECAM_crossbar3_line
    A333_ECAM_apu_gen_line = ECAM_apu_gen_line
    A333_ECAM_gpu_line = ECAM_gpu_line
    A333_ECAM_elec_ess_tr_status = ECAM_elec_ess_tr_status
    A333_ECAM_elec_tr1_status = ECAM_elec_tr1_status
    A333_ECAM_elec_tr2_status = ECAM_elec_tr2_status
	A333_ECAM_elec_apu_tr_status = ECAM_elec_apu_tr_status
	A333_ECAM_stat_inv_status = stat_inv_status
	A333_ECAM_emer_gen_status = emer_gen_status
	A333_ECAM_gen1_volts = gen1_volts_ECAM
	A333_ECAM_gen2_volts = gen2_volts_ECAM

end


---- TEMPERATURE
local function A333_interior_temps()

    local TAT = simDR_TAT
    local pack_flow1_ratio = A333_pack_flow1_ratio
    local pack_flow2_ratio = A333_pack_flow2_ratio
    local pack_flow = m.max(pack_flow1_ratio, pack_flow2_ratio)
    local pack_flow_factor = rescale(0, 1, 10, 3, pack_flow)
    local cargo_cooling_mode_button_pos = A333_cargo_cooling_mode_pos
    local cargo_flow_factor = rescale(0, 1, 2, 2, cargo_cooling_mode_button_pos)
    local cargo_cond_hot_air_button_pos = A333_cargo_cond_hot_air_pos
    local bus2_power = simDR_bus2_power

	-- interior temps
	local cockpit_temperature_init = TAT + rescale(-30, 35, 30, 5, TAT) + lcl.cockpit_random_fac
	local cabin_temperature_fwd_init = TAT + rescale(-30, 35, 30, 5, TAT) + lcl.cabin_fwd_random_fac
	local cabin_temperature_mid_init = TAT + rescale(-30, 35, 30, 5, TAT) + lcl.cabin_mid_random_fac
	local cabin_temperature_aft_init = TAT + rescale(-30, 35, 30, 5, TAT) + lcl.cabin_aft_random_fac
	local cargo_temperature_init = TAT + rescale(-30, 25, 30, 5, TAT) + lcl.cargo_random_fac
	local bulk_cargo_temperature_init = TAT + rescale(-30, 20, 30, 5, TAT) + lcl.cargo_bulk_random_fac

	local cockpit_temperature_setting = rescale(-1, 18, 1, 30, A333_cockpit_temp_knob_pos)
	local cabin_temperature_setting = rescale(-1, 18, 1, 30, A333_cabin_temp_knob_pos)
	local cargo_temperature_setting = rescale(-1, 5, 1, 25, A333_fwd_cargo_temp_knob_pos)
	local bulk_cargo_temperature_setting = rescale(-1, 5, 1, 25, A333_bulk_cargo_temp_knob_pos)

	local hot_air_factor = rescale(0, 0, 1, 1, A333_switches_hot_air1_pos)

    local cabin_fwd_temp_ind = A333_cabin_fwd_temp_ind
    local cabin_mid_temp_ind = A333_cabin_mid_temp_ind
    local cabin_aft_temp_ind = A333_cabin_aft_temp_ind

    local cargo_temp_ind = A333_bulk_cargo_temp_ind


    lcl.cockpit_temperature_target = ((pack_flow1_ratio > 0.5 or pack_flow2_ratio > 0.5) and cockpit_temperature_setting) or cockpit_temperature_init

    lcl.cabin_temperature_fwd_target = ((pack_flow1_ratio > 0.5 or pack_flow2_ratio > 0.5) and (cabin_temperature_setting + lcl.cabin_fwd_random_fac2)) or cabin_temperature_fwd_init
    lcl.cabin_temperature_mid_target = ((pack_flow1_ratio > 0.5 or pack_flow2_ratio > 0.5) and (cabin_temperature_setting + lcl.cabin_mid_random_fac2)) or cabin_temperature_mid_init
    lcl.cabin_temperature_aft_target = ((pack_flow1_ratio > 0.5 or pack_flow2_ratio > 0.5) and (cabin_temperature_setting + lcl.cabin_aft_random_fac2)) or cabin_temperature_aft_init

    lcl.cargo_temperature_target = (((pack_flow1_ratio > 0.5 or pack_flow2_ratio > 0.5) and cargo_cooling_mode_button_pos ~= 0 and hot_air_factor == 1) and cargo_temperature_setting) or cargo_temperature_init
    lcl.cargo_mode = (((pack_flow1_ratio > 0.5 or pack_flow2_ratio > 0.5) and cargo_cooling_mode_button_pos ~= 0 and hot_air_factor == 1) and 1) or 0

    if cargo_cond_hot_air_button_pos >= 1 then
		if bus2_power > 10 then
			if bulk_cargo_temperature_setting < bulk_cargo_temperature_init then
				if bulk_cargo_temperature_setting <= lcl.cargo_temp_loop then
					lcl.bulk_cargo_temperature_target = bulk_cargo_temperature_init
					lcl.bulk_rate = 0.001
				elseif bulk_cargo_temperature_setting > lcl.cargo_temp_loop then
					lcl.bulk_cargo_temperature_target = bulk_cargo_temperature_setting
					lcl.bulk_rate = 0.01
				end
			elseif bulk_cargo_temperature_setting >= bulk_cargo_temperature_init then
				lcl.bulk_cargo_temperature_target = bulk_cargo_temperature_setting
				if lcl.cargo_temp_loop >= bulk_cargo_temperature_setting then
					lcl.bulk_rate = 0.001
				elseif lcl.cargo_temp_loop < bulk_cargo_temperature_setting then
					lcl.bulk_rate = 0.01
				end
			end
		elseif bus2_power <= 10 then
			lcl.bulk_cargo_temperature_target = bulk_cargo_temperature_init
			lcl.bulk_rate = 0.001
		end
	elseif cargo_cond_hot_air_button_pos == 0 then
		lcl.bulk_cargo_temperature_target = bulk_cargo_temperature_init
		lcl.bulk_rate = 0.001
	end


    A333_cockpit_temp_ind = A333_set_animation_position(A333_cockpit_temp_ind, lcl.cockpit_temperature_target, -40, 50, (0.005 * pack_flow_factor))
    cabin_fwd_temp_ind = A333_set_animation_position(cabin_fwd_temp_ind, lcl.cabin_temperature_fwd_target, -40, 50, (0.0039 * pack_flow_factor))
    cabin_mid_temp_ind = A333_set_animation_position(cabin_mid_temp_ind, lcl.cabin_temperature_mid_target, -40, 50, (0.0027 * pack_flow_factor))
    cabin_aft_temp_ind = A333_set_animation_position(cabin_aft_temp_ind, lcl.cabin_temperature_aft_target, -40, 50, (0.0032 * pack_flow_factor))

	A333_cabin_fwd_mid_temp_ind = (0.667 * cabin_fwd_temp_ind + 0.333 * cabin_mid_temp_ind) + lcl.cabin_fwd_mid_random_fac2
	A333_cabin_mid_fwd_temp_ind = (0.333 * cabin_fwd_temp_ind + 0.667 * cabin_mid_temp_ind) + lcl.cabin_mid_fwd_random_fac2
	A333_cabin_mid_aft_temp_ind = (0.5 * cabin_mid_temp_ind + 0.5 * cabin_aft_temp_ind) + lcl.cabin_aft_mid_random_fac2

    A333_cargo_temp_ind = ((lcl.cargo_mode == 1 and A333_set_animation_position(A333_cargo_temp_ind, lcl.cargo_temperature_target, -40, 50, (0.0025 * pack_flow_factor * cargo_flow_factor)))
        or A333_set_animation_position(A333_cargo_temp_ind, lcl.cargo_temperature_target, -40, 50, 0.0008))

    cargo_temp_ind = A333_set_animation_position(cargo_temp_ind, lcl.bulk_cargo_temperature_target, -40, 50, lcl.bulk_rate)

	lcl.cargo_temp_loop = cargo_temp_ind

    A333_cabin_fwd_temp_ind = cabin_fwd_temp_ind
    A333_cabin_mid_temp_ind = cabin_mid_temp_ind
    A333_cabin_aft_temp_ind = cabin_aft_temp_ind
    A333_bulk_cargo_temp_ind = cargo_temp_ind

end




---- BRAKE TEMPERATURES
local function A333_ecam_page_WHEELS_brake_temps()

    local gear_deploy = simDR_gear_deploy
    local TAT = simDR_TAT
    local brake_temp_left = simDR_brake_temp_left
    local brake_temp_right = simDR_brake_temp_right

    lcl.compensated_TAT_left_target = (gear_deploy[1] < 0.1 and (TAT + rescale(-40, 50, 25, 5, TAT))) or TAT
    lcl.compensated_TAT_left_target = (gear_deploy[1] < 0.1 and (TAT + rescale(-40, 50, 25, 5, TAT))) or TAT

	lcl.compensated_TAT_left = A333_set_animation_position(lcl.compensated_TAT_left, lcl.compensated_TAT_left_target, -40, 55, 0.0025)
	lcl.compensated_TAT_right = A333_set_animation_position(lcl.compensated_TAT_right, lcl.compensated_TAT_right_target, -40, 55, 0.0025)


	-- LEFT
	lcl.wheel_brake_temp1 = rescale(0, lcl.compensated_TAT_left, 1.5, 1100, brake_temp_left) + rescale(0, lcl.wheel_brake_1_random_min_fac, 1.5, lcl.wheel_brake_1_random_max_fac, brake_temp_left)
	A333_wheel_brake_temp1 = lcl.wheel_brake_temp1 - m.fmod(lcl.wheel_brake_temp1, 5)

	lcl.wheel_brake_temp2 = rescale(0, lcl.compensated_TAT_left, 1.5, 1100, brake_temp_left) + rescale(0, lcl.wheel_brake_2_random_min_fac, 1.5, lcl.wheel_brake_2_random_max_fac, brake_temp_left)
	A333_wheel_brake_temp2 = lcl.wheel_brake_temp2 - m.fmod(lcl.wheel_brake_temp2, 5)

	lcl.wheel_brake_temp5 = rescale(0, lcl.compensated_TAT_left, 1.5, 1100, brake_temp_left) + rescale(0, lcl.wheel_brake_5_random_min_fac, 1.5, lcl.wheel_brake_5_random_max_fac, brake_temp_left)
	A333_wheel_brake_temp5 = lcl.wheel_brake_temp5 - m.fmod(lcl.wheel_brake_temp5, 5)

	lcl.wheel_brake_temp6 = rescale(0, lcl.compensated_TAT_left, 1.5, 1100, brake_temp_left) + rescale(0, lcl.wheel_brake_6_random_min_fac, 1.5, lcl.wheel_brake_6_random_max_fac, brake_temp_left)
	A333_wheel_brake_temp6 = lcl.wheel_brake_temp6 - m.fmod(lcl.wheel_brake_temp6, 5)


	-- RIGHT
	lcl.wheel_brake_temp3 = rescale(0, lcl.compensated_TAT_right, 1.5, 1100, brake_temp_right) + rescale(0, lcl.wheel_brake_3_random_min_fac, 1.5, lcl.wheel_brake_3_random_max_fac, brake_temp_right)
	A333_wheel_brake_temp3 = lcl.wheel_brake_temp3 - m.fmod(lcl.wheel_brake_temp3, 5)

	lcl.wheel_brake_temp4 = rescale(0, lcl.compensated_TAT_right, 1.5, 1100, brake_temp_right) + rescale(0, lcl.wheel_brake_4_random_min_fac, 1.5, lcl.wheel_brake_4_random_max_fac, brake_temp_right)
	A333_wheel_brake_temp4 = lcl.wheel_brake_temp4 - m.fmod(lcl.wheel_brake_temp4, 5)

	lcl.wheel_brake_temp7 = rescale(0, lcl.compensated_TAT_right, 1.5, 1100, brake_temp_right) + rescale(0, lcl.wheel_brake_7_random_min_fac, 1.5, lcl.wheel_brake_7_random_max_fac, brake_temp_right)
	A333_wheel_brake_temp7 = lcl.wheel_brake_temp7 - m.fmod(lcl.wheel_brake_temp7, 5)

	lcl.wheel_brake_temp8 = rescale(0, lcl.compensated_TAT_right, 1.5, 1100, brake_temp_right) + rescale(0, lcl.wheel_brake_8_random_min_fac, 1.5, lcl.wheel_brake_8_random_max_fac, brake_temp_right)
	A333_wheel_brake_temp8 = lcl.wheel_brake_temp8 - m.fmod(lcl.wheel_brake_temp8, 5)


	A333_wheel_brake_temp_anim_1 = rescale(500, 0, 1100, 1, lcl.wheel_brake_temp1)
	A333_wheel_brake_temp_anim_2 = rescale(500, 0, 1100, 1, lcl.wheel_brake_temp2)
	A333_wheel_brake_temp_anim_5 = rescale(500, 0, 1100, 1, lcl.wheel_brake_temp5)
	A333_wheel_brake_temp_anim_6 = rescale(500, 0, 1100, 1, lcl.wheel_brake_temp6)
	
	A333_wheel_brake_temp_anim_3 = rescale(500, 0, 1100, 1, lcl.wheel_brake_temp3)
	A333_wheel_brake_temp_anim_4 = rescale(500, 0, 1100, 1, lcl.wheel_brake_temp4)
	A333_wheel_brake_temp_anim_7 = rescale(500, 0, 1100, 1, lcl.wheel_brake_temp7)
	A333_wheel_brake_temp_anim_8 = rescale(500, 0, 1100, 1, lcl.wheel_brake_temp8)

end

---- BRAKE TAP

local function A333_brake_tap()

	local left_main_deploy = simDR_Lmain_gear_deploy
	local right_main_deploy = simDR_Rmain_gear_deploy
						
	if simDR_gear_on_ground == 0 and simDR_gear_on_ground_r == 0 and lcl.gear_handle_flag == 1 then
		if (simDR_left_main_gear_fail == 6 and simDR_right_main_gear_fail == 6) or simDR_gear_system_fail == 6 then
			lcl.gear_handle_flag = 2
		end

		if m.min(left_main_deploy, right_main_deploy) < 0.98 then
			lcl.toe_brake_override_flag = 1
		end
	end
					
	if lcl.toe_brake_override_flag == 1 then
		simDR_gear_override = 1
		
		if left_main_deploy >= 0.96 then
			simDR_left_brake = rescale(0.96, 0.05, 0.98, 0.0, left_main_deploy)
		elseif left_main_deploy < 0.96 then
			simDR_left_brake = rescale(0.90, 0.0, 0.96, 0.05, left_main_deploy)
		end

		if right_main_deploy >= 0.94 then
			simDR_right_brake = rescale(0.94, 0.05, 0.98, 0.0, right_main_deploy)
		elseif right_main_deploy < 0.94 then
			simDR_right_brake = rescale(0.90, 0.0, 0.94, 0.05, right_main_deploy)
		end

		if m.min(left_main_deploy, right_main_deploy) < 0.75 or 
			(simDR_left_main_gear_fail == 6 and simDR_right_main_gear_fail == 6) or
			simDR_gear_system_fail == 6 or
			simDR_gear_on_ground == 1 or
			simDR_gear_on_ground_r == 1
		then
			lcl.gear_handle_flag = 2
		end
	end
	
	if lcl.gear_handle_flag == 2 then
		lcl.toe_brake_override_flag = 0
		simDR_gear_override = 0
		lcl.gear_handle_flag = 0
	end

end


---- ECAM WHEELS PAGE
local function A333_ecam_page_WHEELS()

    local left_brake_fail = simDR_left_brake_fail
    local right_brake_fail = simDR_right_brake_fail
    local nosewheel_steering = simDR_nosewheel_steering
    local green_hydraulic_pressure = simDR_green_hydraulic_pressure
    local anti_skid_status = A333_anti_skid_status
    local gear_on_ground = simDR_gear_on_ground
    local eng_N1 = simDR_eng_N1
    local blue_hydraulic_pressure = simDR_blue_hydraulic_pressure
    local gear_deploy = simDR_gear_deploy
    local gear_handle = simDR_gear_handle
    local left_brake_ratio = simDR_left_brake_ratio
    local right_brake_ratio = simDR_right_brake_ratio
    local left_skid_ratio = simDR_left_skid_ratio
    local wheel_brake_temp1 = A333_wheel_brake_temp1
    local wheel_brake_temp2 = A333_wheel_brake_temp2
    local wheel_brake_temp3 = A333_wheel_brake_temp3
    local wheel_brake_temp4 = A333_wheel_brake_temp4
    local wheel_brake_temp5 = A333_wheel_brake_temp5
    local wheel_brake_temp6 = A333_wheel_brake_temp6
    local wheel_brake_temp7 = A333_wheel_brake_temp7
    local wheel_brake_temp8 = A333_wheel_brake_temp8
    local wheel_brake_warn = A333_wheel_brake_warn

	local norm_brake_status = A333_norm_brake_status
    local wheel_brake_release_left = A333_wheel_brake_release_left
    local wheel_brake_release_right = A333_wheel_brake_release_right
    local wheel_brake_temp_arc1 = A333_wheel_brake_temp_arc1
    local wheel_brake_temp_arc2 = A333_wheel_brake_temp_arc2
    local wheel_brake_temp_arc3 = A333_wheel_brake_temp_arc3
    local wheel_brake_temp_arc4 = A333_wheel_brake_temp_arc4
    local wheel_brake_temp_arc5 = A333_wheel_brake_temp_arc5
    local wheel_brake_temp_arc6 = A333_wheel_brake_temp_arc6
    local wheel_brake_temp_arc7 = A333_wheel_brake_temp_arc7
    local wheel_brake_temp_arc8 = A333_wheel_brake_temp_arc8

	if left_brake_fail == 6 or right_brake_fail == 6 then
        norm_brake_status = 1
	elseif left_brake_fail ~= 6 and right_brake_fail ~= 6 then
		if nosewheel_steering == 1 then
			if green_hydraulic_pressure > 500 then
                norm_brake_status = 0
			elseif green_hydraulic_pressure <= 500 then
                norm_brake_status = 1
			end
		elseif nosewheel_steering == 0 then
            norm_brake_status = 1
		end
	end

	if nosewheel_steering == 0 then
        anti_skid_status = 1
	elseif nosewheel_steering == 1 then
		if gear_on_ground == 0 then
			if eng_N1[0] >= 20 or eng_N1[1] >= 20 then
				if green_hydraulic_pressure < 500 and blue_hydraulic_pressure < 500 then
                    anti_skid_status = 1
				elseif green_hydraulic_pressure >= 500 or blue_hydraulic_pressure >= 500 then
                    anti_skid_status = 0
				end
			elseif eng_N1[0] < 20 and eng_N1[1] < 20 then
                anti_skid_status = 0
			end
		elseif gear_on_ground == 1 then
            anti_skid_status = 0
		end
	end

	lcl.gear_multiplier = gear_deploy[0] * gear_deploy[1] * gear_deploy[2]

	if gear_handle == lcl.gear_multiplier then
		lcl.gear_timer = 0
	elseif gear_handle ~= lcl.gear_multiplier then
		lcl.gear_timer = lcl.gear_timer + lcl_SIM_PERIOD
	end

    A333_lg_ctl_status = (lcl.gear_timer < 30 and 0) or 1

	if gear_on_ground == 0 then

		if nosewheel_steering == 1 then

			if gear_deploy[1] >= 0.95 then
				if left_brake_ratio == 0 then
                    wheel_brake_release_left = 1
				elseif left_brake_ratio > 0 then
                    wheel_brake_release_left = 0
				end
			elseif gear_deploy[1] < 0.95 then
                wheel_brake_release_left = 0
			end

			if gear_deploy[1] >= 0.95 then
				if right_brake_ratio == 0 then
                    wheel_brake_release_right = 1
				elseif right_brake_ratio > 0 then
                    wheel_brake_release_right = 0
				end
			elseif gear_deploy[1] < 0.95 then
                wheel_brake_release_right = 0
			end

		elseif nosewheel_steering == 0 then
            wheel_brake_release_left = 0
            wheel_brake_release_right = 0
		end

	elseif gear_on_ground == 1 then

		if left_brake_ratio ~= 0 then
			if left_skid_ratio >= 0.12 then
                wheel_brake_release_left = 1
			elseif left_skid_ratio < 0.12 then
                wheel_brake_release_left = 0
			end
		elseif left_brake_ratio == 0 then
            wheel_brake_release_left = 0
		end

		if right_brake_ratio ~= 0 then
			if left_skid_ratio >= 0.12 then
                wheel_brake_release_right = 1
			elseif left_skid_ratio < 0.12 then
                wheel_brake_release_right = 0
			end
		elseif right_brake_ratio == 0 then
            wheel_brake_release_right = 0
		end

	end

	lcl.brake_temp_max = m.max(wheel_brake_temp1, wheel_brake_temp2, wheel_brake_temp3, wheel_brake_temp4, wheel_brake_temp5, wheel_brake_temp6, wheel_brake_temp7, wheel_brake_temp8)

    A333_wheel_brake_warn = (lcl.brake_temp_max >= 300 and 1) or 0

	if wheel_brake_temp1 == lcl.brake_temp_max then
		if lcl.brake_temp_max < 100 then
            wheel_brake_temp_arc1 = 0
		elseif lcl.brake_temp_max >= 100 and lcl.brake_temp_max < 300 then
            wheel_brake_temp_arc1 = 1
		elseif lcl.brake_temp_max >= 300 then
            wheel_brake_temp_arc1 = 2
		end
	elseif wheel_brake_temp1 ~= lcl.brake_temp_max then
        wheel_brake_temp_arc1 = 0
	end

	if wheel_brake_temp2 == lcl.brake_temp_max then
		if lcl.brake_temp_max < 100 then
            wheel_brake_temp_arc2 = 0
		elseif lcl.brake_temp_max >= 100 and lcl.brake_temp_max < 300 then
            wheel_brake_temp_arc2 = 1
		elseif lcl.brake_temp_max >= 300 then
            wheel_brake_temp_arc2 = 2
		end
	elseif wheel_brake_temp2 ~= lcl.brake_temp_max then
        wheel_brake_temp_arc2 = 0
	end

	if wheel_brake_temp3 == lcl.brake_temp_max then
		if lcl.brake_temp_max < 100 then
            wheel_brake_temp_arc3 = 0
		elseif lcl.brake_temp_max >= 100 and lcl.brake_temp_max < 300 then
            wheel_brake_temp_arc3 = 1
		elseif lcl.brake_temp_max >= 300 then
            wheel_brake_temp_arc3 = 2
		end
	elseif wheel_brake_temp3 ~= lcl.brake_temp_max then
        wheel_brake_temp_arc3 = 0
	end

	if wheel_brake_temp4 == lcl.brake_temp_max then
		if lcl.brake_temp_max < 100 then
            wheel_brake_temp_arc4 = 0
		elseif lcl.brake_temp_max >= 100 and lcl.brake_temp_max < 300 then
            wheel_brake_temp_arc4 = 1
		elseif lcl.brake_temp_max >= 300 then
            wheel_brake_temp_arc4 = 2
		end
	elseif wheel_brake_temp4 ~= lcl.brake_temp_max then
        wheel_brake_temp_arc4 = 0
	end

	if wheel_brake_temp5 == lcl.brake_temp_max then
		if lcl.brake_temp_max < 100 then
            wheel_brake_temp_arc5 = 0
		elseif lcl.brake_temp_max >= 100 and lcl.brake_temp_max < 300 then
            wheel_brake_temp_arc5 = 1
		elseif lcl.brake_temp_max >= 300 then
            wheel_brake_temp_arc5 = 2
		end
	elseif wheel_brake_temp5 ~= lcl.brake_temp_max then
        wheel_brake_temp_arc5 = 0
	end

	if wheel_brake_temp6 == lcl.brake_temp_max then
		if lcl.brake_temp_max < 100 then
            wheel_brake_temp_arc6 = 0
		elseif lcl.brake_temp_max >= 100 and lcl.brake_temp_max < 300 then
            wheel_brake_temp_arc6 = 1
		elseif lcl.brake_temp_max >= 300 then
            wheel_brake_temp_arc6 = 2
		end
	elseif wheel_brake_temp6 ~= lcl.brake_temp_max then
        wheel_brake_temp_arc6 = 0
	end

	if wheel_brake_temp7 == lcl.brake_temp_max then
		if lcl.brake_temp_max < 100 then
            wheel_brake_temp_arc7 = 0
		elseif lcl.brake_temp_max >= 100 and lcl.brake_temp_max < 300 then
            wheel_brake_temp_arc7 = 1
		elseif lcl.brake_temp_max >= 300 then
            wheel_brake_temp_arc7 = 2
		end
	elseif wheel_brake_temp7 ~= lcl.brake_temp_max then
        wheel_brake_temp_arc7 = 0
	end

	if wheel_brake_temp8 == lcl.brake_temp_max then
		if lcl.brake_temp_max < 100 then
            wheel_brake_temp_arc8 = 0
		elseif lcl.brake_temp_max >= 100 and lcl.brake_temp_max < 300 then
            wheel_brake_temp_arc8 = 1
		elseif lcl.brake_temp_max >= 300 then
            wheel_brake_temp_arc8 = 2
		end
	elseif wheel_brake_temp8 ~= lcl.brake_temp_max then
        wheel_brake_temp_arc8 = 0
	end

    A333_norm_brake_status = norm_brake_status
    A333_wheel_brake_release_left = wheel_brake_release_left
    A333_wheel_brake_release_right = wheel_brake_release_right
    A333_wheel_brake_temp_arc1 = wheel_brake_temp_arc1
    A333_wheel_brake_temp_arc2 = wheel_brake_temp_arc2
    A333_wheel_brake_temp_arc3 = wheel_brake_temp_arc3
    A333_wheel_brake_temp_arc4 = wheel_brake_temp_arc4
    A333_wheel_brake_temp_arc5 = wheel_brake_temp_arc5
    A333_wheel_brake_temp_arc6 = wheel_brake_temp_arc6
    A333_wheel_brake_temp_arc7 = wheel_brake_temp_arc7
    A333_wheel_brake_temp_arc8 = wheel_brake_temp_arc8

end




---- ECAM CAB PRESS PAGE
local function A333_ecam_page_CAB_PRESS()

    local ditching_status = A333_ditching_status
    local gear_on_ground = simDR_gear_on_ground
    local eng_N1 = simDR_eng_N1

    local vent_extract_valve_pos = A333_vent_extract_valve_pos
    local ventilation_extract_status = A333_ventilation_extract_status


	if ditching_status == 1 then
        vent_extract_valve_pos = 0
		lcl.outflow_valve_minimum = 0
		lcl.outflow_valve_maximum = 0
	elseif ditching_status == 0 then
		lcl.outflow_valve_maximum = 1
		if ventilation_extract_status == 0 then
            vent_extract_valve_pos = 1
		elseif ventilation_extract_status == 1 then
			if gear_on_ground == 1 then
				lcl.outflow_valve_minimum = 0
				if eng_N1[0] > 5 or eng_N1[1] > 5 then
                    vent_extract_valve_pos = 0
				elseif eng_N1[0] <= 5 and eng_N1[1] <= 5 then
                    vent_extract_valve_pos = 2
				end
			elseif gear_on_ground == 0 then
				lcl.outflow_valve_minimum = 0.05
                vent_extract_valve_pos = 0
			end
		end
	end


	A333_outflow_valve_fwd = A333_set_animation_position(A333_outflow_valve_fwd, simDR_outflow_valve, lcl.outflow_valve_minimum, lcl.outflow_valve_maximum, 0.5)
	A333_outflow_valve_aft = A333_set_animation_position(A333_outflow_valve_aft, simDR_outflow_valve, lcl.outflow_valve_minimum, lcl.outflow_valve_maximum, 0.5)

    A333_vent_extract_valve_pos = vent_extract_valve_pos


end

local precooler1a_timer = 0
local precooler2a_timer = 0
local precooler1b_timer = 0
local precooler2b_timer = 0
local precooler1c_timer = 0
local precooler2c_timer = 0

---- ECAM BLEED PAGE
local function A333_ecam_page_BLEED()   -- TODO:  consider refactor to multiple functions ??

    local left_duct_avail = simDR_left_duct_avail
    local right_duct_avail = simDR_right_duct_avail
    local left_pack = simDR_left_pack
    local right_pack = simDR_right_pack
    local gear_on_ground = simDR_gear_on_ground
    local status_ram_air_valve = A333_status_ram_air_valve
    local capt_altitude = simDR_capt_altitude
    local apu_bleed = simDR_apu_bleed
    local apu_loss = simDR_apu_loss
    local bleed_air1 = simDR_bleed_air1
    local bleed_air2 = simDR_bleed_air2
    local TAT = simDR_TAT
    local engine1_loss = simDR_engine1_loss
    local engine2_loss = simDR_engine2_loss
    local cockpit_temp_knob_pos = A333_cockpit_temp_knob_pos
    local cabin_temp_knob_pos = A333_cabin_temp_knob_pos
    local APU_EGT = simDR_APU_EGT
    local wing_heat_left = simDR_wing_heat_left
    local wing_heat_right = simDR_wing_heat_right
    local wing_heat_fault_left = simDR_wing_heat_fault_left
    local wing_heat_fault_right = simDR_wing_heat_fault_right
    local wing_heat_valve_pos_left = A333_wing_heat_valve_pos_left
    local wing_heat_valve_pos_right = A333_wing_heat_valve_pos_right
    local isol_valve_right_pos = A333_isol_valve_right_pos
    local duct_isol_valve_right = simDR_duct_isol_valve_right
    local pack1_valve_pos = A333_pack1_valve_pos
    local pack2_valve_pos = A333_pack2_valve_pos
    local user_bleed_status = A333_user_bleed_status
    local pack1_flow = A333_pack1_flow
    local pack2_flow = A333_pack2_flow
    local pack1_flow_status = A333_pack1_flow_status
    local pack2_flow_status = A333_pack2_flow_status
    local precooler1_temp = A333_precooler1_temp
    local precooler2_temp = A333_precooler2_temp
    local pack1_compressor_outlet_temp = A333_pack1_compressor_outlet_temp
    local pack2_compressor_outlet_temp = A333_pack2_compressor_outlet_temp
    local left_wing_ai_valve_ind = A333_left_wing_ai_valve_ind
    local right_wing_ai_valve_ind = A333_right_wing_ai_valve_ind
    local left_wing_ai_status = A333_left_wing_ai_status
    local right_wing_ai_status = A333_right_wing_ai_status


	if lcl.crossbleed_valve_pos == 0 then
        isol_valve_right_pos = 0
	elseif lcl.crossbleed_valve_pos == 1 then
		if left_duct_avail < 0.5 and right_duct_avail < 0.5 then
            isol_valve_right_pos = 3
		elseif left_duct_avail >= 0.5 or right_duct_avail >= 0.5 then
            isol_valve_right_pos = 2
		end
	else
        isol_valve_right_pos = 1
	end


    pack1_valve_pos = ((left_pack == 1 and lcl.pack1_flow_target ~= 0) and 1) or 0
    pack2_valve_pos = ((right_pack == 1 and lcl.pack2_flow_target ~= 0) and 1) or 0

    if gear_on_ground == 1 then
		if left_duct_avail > 0.5 or right_duct_avail > 0.5 then
			if pack1_valve_pos == 1 or pack2_valve_pos == 1 then
                user_bleed_status = 1
			elseif pack1_valve_pos == 0 and pack2_valve_pos == 0 then
                user_bleed_status = 0
			end
		elseif left_duct_avail <= 0.5 and right_duct_avail <= 0.5 then
            user_bleed_status = 0
		end
	elseif gear_on_ground == 0 then
		if status_ram_air_valve == 0 then
			if left_duct_avail > 0.5 or right_duct_avail > 0.5 then
				if pack1_valve_pos == 1 or pack2_valve_pos == 1 then
                    user_bleed_status = 1
				elseif pack1_valve_pos == 0 and pack2_valve_pos == 0 then
                    user_bleed_status = 0
				end
			elseif left_duct_avail <= 0.5 and right_duct_avail <= 0.5 then
                user_bleed_status = 0
			end
		elseif status_ram_air_valve == 1 then
            user_bleed_status = 1
		end
	end


    lcl.pack1_flow_target2 = (left_pack == 1 and lcl.pack1_flow_target) or 1
    lcl.pack2_flow_target2 = (right_pack == 1 and lcl.pack2_flow_target) or 1

    pack1_flow = A333_set_animation_position(pack1_flow, lcl.pack1_flow_target2, 0.8, 1.25, 2)
    pack2_flow = A333_set_animation_position(pack2_flow, lcl.pack2_flow_target2, 0.8, 1.25, 2)

    pack1_flow_status = (((pack1_flow > lcl.pack1_flow_target2 + 0.001 or pack1_flow < lcl.pack1_flow_target2 - 0.001) and 0)
        or ((pack1_flow <= lcl.pack1_flow_target2 + 0.001 and pack1_flow >= lcl.pack1_flow_target2 - 0.001) and 1))

    pack2_flow_status = (((pack2_flow > lcl.pack2_flow_target2 + 0.001 or pack2_flow < lcl.pack2_flow_target2 - 0.001) and 0)
        or ((pack2_flow <= lcl.pack2_flow_target2 + 0.001 and pack2_flow >= lcl.pack2_flow_target2 - 0.001) and 1))


    -- TEMPERATURES
	if capt_altitude < 10000 then
		lcl.alt_factor = rescale(-1000, 1.1, 10000, 1.45, capt_altitude)
	elseif capt_altitude >= 10000 and capt_altitude < 20000 then
		lcl.alt_factor = rescale(10000, 1.45, 20000, 1.85, capt_altitude)
	elseif capt_altitude >= 20000 and capt_altitude < 30000 then
		lcl.alt_factor = rescale(20000, 1.85, 30000, 2.15, capt_altitude)
	elseif capt_altitude >= 30000 and capt_altitude < 35000 then
		lcl.alt_factor = rescale(30000, 2.15, 35000, 2.45, capt_altitude)
	elseif capt_altitude >= 35000 then
		lcl.alt_factor = rescale(35000, 2.45, 43000, 2.95, capt_altitude)
	end

	if duct_isol_valve_right == 0 then
		if apu_bleed == 0 then
			lcl.left_psi_factor = 1
			lcl.right_psi_factor = 1
			lcl.apu_loss_left = 0
			lcl.apu_loss_right = 0
		elseif apu_bleed == 1 then
			lcl.left_psi_factor = rescale(0, 1.5, 45000, 0.55, capt_altitude)
			lcl.right_psi_factor = 1
			lcl.apu_loss_left = apu_loss
			lcl.apu_loss_right = 0
		end
	elseif duct_isol_valve_right == 1 then
		if apu_bleed == 0 then
			lcl.left_psi_factor = 1
			lcl.right_psi_factor = 1
			lcl.apu_loss_left = 0
			lcl.apu_loss_right = 0
		elseif apu_bleed == 1 then
			lcl.left_psi_factor = rescale(0, 1.25, 45000, 0.4, capt_altitude)
			lcl.right_psi_factor = rescale(0, 1.25, 45000, 0.4, capt_altitude)
			lcl.apu_loss_left = 0.5 * apu_loss
			lcl.apu_loss_right = 0.5 * apu_loss
		end
	end

	if bleed_air1 == 1 then
		lcl.precooler_temp1_target = rescale(0, TAT, rescale(1, 2.1, 1.5, 2.6, left_duct_avail), TAT + 250, left_duct_avail * lcl.left_psi_factor * lcl.alt_factor) - (engine1_loss * 1.33) - lcl.apu_loss_left + (rescale(0, 12, 41000, 21, capt_altitude) * A333_eng1_HP_valve_pos)
		A333_eng1_HP_valve_pos = ((simDR_eng1_N2 < 77.4 and simDR_engine1_running == 1 and simDR_eng1_N2 > 57.6) and 1) or 0
	elseif bleed_air1 == 0 then
		lcl.precooler_temp1_target = rescale(0, TAT, 2.7, TAT + 50, left_duct_avail * lcl.left_psi_factor * lcl.alt_factor) - lcl.apu_loss_left
		A333_eng1_HP_valve_pos = 0
	end

	if bleed_air2 == 1 then
		lcl.precooler_temp2_target = rescale(0, TAT, rescale(1, 2.1, 1.5, 2.6, right_duct_avail), TAT + 245, right_duct_avail * lcl.right_psi_factor * lcl.alt_factor) - (engine2_loss * 1.33) - lcl.apu_loss_right + (rescale(0, 9, 41000, 23, capt_altitude) * A333_eng2_HP_valve_pos)
		A333_eng2_HP_valve_pos = ((simDR_eng2_N2 < 78.2 and simDR_engine2_running == 1 and simDR_eng2_N2 > 58) and 1) or 0
	elseif bleed_air2 == 0 then
		lcl.precooler_temp2_target = rescale(0, TAT, 2.7, TAT + 50, right_duct_avail * lcl.right_psi_factor * lcl.alt_factor) - lcl.apu_loss_right
		A333_eng2_HP_valve_pos = 0
	end

    precooler1_temp = A333_set_animation_position(precooler1_temp, lcl.precooler_temp1_target, 0, 300, rescale(0, 0.016, 1, 0.16, bleed_air1))
    precooler2_temp = A333_set_animation_position(precooler2_temp, lcl.precooler_temp2_target, 0, 300, rescale(0, 0.015, 1, 0.15, bleed_air2))


	if precooler1_temp > 257 then
		precooler1a_timer = precooler1a_timer + lcl_SIM_PERIOD
	else precooler1a_timer = 0
	end

	if precooler2_temp > 257 then
		precooler2a_timer = precooler2a_timer + lcl_SIM_PERIOD
	else precooler2a_timer = 0
	end

	if precooler1_temp > 270 then
		precooler1b_timer = precooler1b_timer + lcl_SIM_PERIOD
	else precooler1b_timer = 0
	end

	if precooler2_temp > 270 then
		precooler2b_timer = precooler2b_timer + lcl_SIM_PERIOD
	else precooler2b_timer = 0
	end

	if precooler1_temp > 290 then
		precooler1c_timer = precooler1c_timer + lcl_SIM_PERIOD
	else precooler1c_timer = 0
	end

	if precooler2_temp > 290 then
		precooler2c_timer = precooler2c_timer + lcl_SIM_PERIOD
	else precooler2c_timer = 0
	end


	if precooler1_temp < 150 then
		A333_precooler1_temp_status = gear_on_ground
	elseif precooler1_temp >= 150 then
		if precooler1a_timer > 55 or precooler1b_timer > 15 or precooler1c_timer > 5 then
			A333_precooler1_temp_status = 0
		else A333_precooler1_temp_status = 1
		end
	end

	if precooler2_temp < 150 then
		A333_precooler2_temp_status = gear_on_ground
	elseif precooler2_temp >= 150 then
		if precooler2a_timer > 55 or precooler2b_timer > 15 or precooler2c_timer > 5 then
			A333_precooler2_temp_status = 0
		else A333_precooler2_temp_status = 1
		end
	end

	if pack1_valve_pos == 0 then
		lcl.pack1_comp_target = TAT + 10
		lcl.pack1_cool_rate = 0.002
	elseif pack1_valve_pos == 1 then
		if left_duct_avail >= 0.5 then
			if apu_bleed == 0 and bleed_air1 == 1 then
				lcl.pack1_comp_target = rescale(0, 45, 250, 285, precooler1_temp) - 10 - lcl.alt_factor * 7
				lcl.pack1_cool_rate = 0.05
			elseif apu_bleed == 1 and bleed_air1 == 0 then
				lcl.pack1_comp_target = rescale(0, 0, 600, 285, APU_EGT) - 10 - lcl.alt_factor * 7
				lcl.pack1_cool_rate = 0.05
			end
		elseif left_duct_avail < 0.5 then
			lcl.pack1_comp_target = TAT + 5
			lcl.pack1_cool_rate = 0.01
		end
	end

	if pack2_valve_pos == 0 then
		lcl.pack2_comp_target = TAT + 10
		lcl.pack2_cool_rate = 0.002
	elseif pack2_valve_pos == 1 then
		if right_duct_avail >= 0.5 then
			if duct_isol_valve_right == 0 then
				lcl.pack2_comp_target = rescale(0, 45, 250, 285, precooler2_temp) - 10 - lcl.alt_factor * 7
				lcl.pack2_cool_rate = 0.05
			elseif duct_isol_valve_right == 1 then
				if apu_bleed == 0 and bleed_air2 == 1 then
					lcl.pack2_comp_target = rescale(0, 45, 250, 285, precooler2_temp) - 10 - lcl.alt_factor * 7
					lcl.pack2_cool_rate = 0.05
				elseif apu_bleed == 1 and bleed_air2 == 0 then
					lcl.pack2_comp_target = rescale(0, 0, 600, 285, APU_EGT) - 10 - lcl.alt_factor * 7
					lcl.pack2_cool_rate = 0.05
				end
			end
		elseif right_duct_avail < 0.5 then
			lcl.pack2_comp_target = TAT + 5
			lcl.pack2_cool_rate = 0.01
		end
	end

    pack1_compressor_outlet_temp = A333_set_animation_position(pack1_compressor_outlet_temp, lcl.pack1_comp_target, -100, 300, (0.9 * lcl.pack1_cool_rate * pack1_flow))
    pack2_compressor_outlet_temp = A333_set_animation_position(pack2_compressor_outlet_temp, lcl.pack2_comp_target, -100, 300, (0.9 * lcl.pack2_cool_rate * pack2_flow))

	lcl.precooler1_psi_target = (left_duct_avail * (lcl.alt_factor * rescale(0, 1, 38000, 0.75, capt_altitude)) * lcl.left_psi_factor - (0.07 * lcl.apu_loss_left) - (engine1_loss * 0.02)) + (A333_eng1_HP_valve_pos * rescale(63, 0.43, 78, 0.3, simDR_eng1_N2))
	lcl.precooler2_psi_target = (right_duct_avail * (lcl.alt_factor * rescale(0, 1, 38000, 0.73, capt_altitude)) * lcl.right_psi_factor - (0.07 * lcl.apu_loss_right) - (engine2_loss * 0.02)) + (A333_eng2_HP_valve_pos * rescale(57, 0.47, 76, 0.2, simDR_eng2_N2))

	A333_precooler1_psi = A333_set_animation_position(A333_precooler1_psi, lcl.precooler1_psi_target, 0, 15, 1.5)
	A333_precooler2_psi = A333_set_animation_position(A333_precooler2_psi, lcl.precooler2_psi_target, 0, 15, 1.2)

	--

	local cockpit_temperature_setting = rescale(-1, 18, 1, 30, cockpit_temp_knob_pos)
	local cabin_temperature_setting = rescale(-1, 18, 1, 30, cabin_temp_knob_pos)

	lcl.average_temperature = (A333_cockpit_temp_ind + A333_cabin_fwd_temp_ind + A333_cabin_mid_temp_ind + A333_cabin_aft_temp_ind) * 0.25
	lcl.average_temp_setting = (cockpit_temperature_setting + cabin_temperature_setting) * 0.5

	if lcl.average_temperature >= lcl.average_temp_setting then

		lcl.pack1_temp_needle = rescale(0, 0.5, 10, 0, (lcl.average_temperature - lcl.average_temp_setting))
		lcl.pack2_temp_needle = rescale(0, 0.5, 10, 0, (lcl.average_temperature - lcl.average_temp_setting))

	elseif lcl.average_temperature < lcl.average_temp_setting then

		lcl.pack1_temp_needle = rescale(0, 0.5, 10, 1, (lcl.average_temp_setting - lcl.average_temperature))
		lcl.pack2_temp_needle = rescale(0, 0.5, 10, 1, (lcl.average_temp_setting - lcl.average_temperature))

	end

    lcl.pack1_temp_needle_target = (pack1_valve_pos == 0 and 0.5) or (lcl.pack1_temp_needle + rescale(-40, 0.15, 50, -0.25, TAT))
    lcl.pack2_temp_needle_target = (pack2_valve_pos == 0 and 0.5) or (lcl.pack2_temp_needle + rescale(-40, 0.15, 50, -0.25, TAT))


    A333_pack1_CH_valve_pos = A333_set_animation_position(A333_pack1_CH_valve_pos, lcl.pack1_temp_needle_target, 0, 1, 1)
	A333_pack2_CH_valve_pos = A333_set_animation_position(A333_pack2_CH_valve_pos, lcl.pack2_temp_needle_target, 0, 1, 1)


	if lcl.pack1_temp_needle_target >= 0.5 then
		lcl.pack1_outlet_temp = lcl.average_temp_setting + rescale(0.5, 0, 1, rescale(18, 45, 30, 35, lcl.average_temp_setting), lcl.pack1_temp_needle_target) - 30
	elseif lcl.pack1_temp_needle_target < 0.5 then
		lcl.pack1_outlet_temp = lcl.average_temp_setting + rescale(0, rescale(18, -12, 30, -20, lcl.average_temp_setting), 0.5, 0, lcl.pack1_temp_needle_target) - 30
	end

	local pack1_outlet_temp_fac1 = rescale(100, 0.9, 300, 1.1, pack1_compressor_outlet_temp)

	if lcl.pack2_temp_needle_target >= 0.5 then
		lcl.pack2_outlet_temp = lcl.average_temp_setting + rescale(0.5, 0, 1, rescale(18, 45, 30, 35, lcl.average_temp_setting), lcl.pack2_temp_needle_target) - 30
	elseif lcl.pack2_temp_needle_target < 0.5 then
		lcl.pack2_outlet_temp = lcl.average_temp_setting + rescale(0, rescale(18, -12, 30, -20, lcl.average_temp_setting), 0.5, 0, lcl.pack2_temp_needle_target) - 30
	end

	local pack2_outlet_temp_fac1 = rescale(100, 0.9, 300, 1.1, pack2_compressor_outlet_temp)

	if pack1_valve_pos == 0 then
		lcl.pack1_outlet_temp_target = TAT + 5
	elseif pack1_valve_pos == 1 then
		if left_duct_avail >= 0.5 then
			lcl.pack1_outlet_temp_target = lcl.pack1_outlet_temp * pack1_outlet_temp_fac1
		elseif left_duct_avail < 0.5 then
			lcl.pack1_outlet_temp_target = TAT + 3
		end
	end

	if pack2_valve_pos == 0 then
		lcl.pack2_outlet_temp_target = TAT + 5
	elseif pack2_valve_pos == 1 then
		if right_duct_avail >= 0.5 then
			lcl.pack2_outlet_temp_target = lcl.pack2_outlet_temp * pack2_outlet_temp_fac1
		elseif right_duct_avail < 0.5 then
			lcl.pack2_outlet_temp_target = TAT + 3
		end
	end

	A333_pack1_outlet_temp = A333_set_animation_position(A333_pack1_outlet_temp, lcl.pack1_outlet_temp_target, -100, 300, lcl.pack1_cool_rate * pack1_flow * 0.4)
	A333_pack2_outlet_temp = A333_set_animation_position(A333_pack2_outlet_temp, lcl.pack2_outlet_temp_target, -100, 300, lcl.pack2_cool_rate * pack2_flow * 0.4)

	

	-- ANTI ICE
	if gear_on_ground == 1 then
		if wing_heat_left == 1 or wing_heat_right == 1 then
			lcl.anti_ice_timer = lcl.anti_ice_timer + lcl_SIM_PERIOD
		elseif wing_heat_left == 0 and wing_heat_right == 0 then
			lcl.anti_ice_timer = 0
		end
	elseif gear_on_ground == 0 then
		lcl.anti_ice_timer = 0
	end


	if wing_heat_fault_left == 6 then
        left_wing_ai_valve_ind = 0
	elseif wing_heat_fault_left ~= 6 then
		if left_duct_avail > 7 or left_duct_avail < 0.5 then
            left_wing_ai_valve_ind = 0
		elseif left_duct_avail <= 7 and left_duct_avail >= 0.5 then
			if lcl.anti_ice_timer >= 35 then
                left_wing_ai_valve_ind = 0
			elseif lcl.anti_ice_timer < 35 then
                left_wing_ai_valve_ind = 1
			end
		end
	end

	if wing_heat_valve_pos_left == 0 then
        left_wing_ai_status = -1
	elseif wing_heat_valve_pos_left ~= 0 and wing_heat_valve_pos_left ~= 1 then
        left_wing_ai_status = 0
	elseif wing_heat_valve_pos_left == 1 then
		if left_wing_ai_valve_ind == 1 then
            left_wing_ai_status = 1
		elseif left_wing_ai_valve_ind == 0 then
            left_wing_ai_status = 0
		end
	end

	if wing_heat_fault_right == 6 then
        right_wing_ai_valve_ind = 0
	elseif wing_heat_fault_right ~= 6 then
		if right_duct_avail > 7 or right_duct_avail < 0.5 then
            right_wing_ai_valve_ind = 0
		elseif right_duct_avail <= 7 and right_duct_avail >= 0.5 then
			if lcl.anti_ice_timer >= 35 then
                right_wing_ai_valve_ind = 0
			elseif lcl.anti_ice_timer < 35 then
                right_wing_ai_valve_ind = 1
			end
		end
	end

	if wing_heat_valve_pos_right == 0 then
        right_wing_ai_status = -1
	elseif wing_heat_valve_pos_right ~= 0 and wing_heat_valve_pos_right ~= 1 then
        right_wing_ai_status = 0
	elseif wing_heat_valve_pos_right == 1 then
		if right_wing_ai_valve_ind == 1 then
            right_wing_ai_status = 1
		elseif right_wing_ai_valve_ind == 0 then
            right_wing_ai_status = 0
		end
	end


    A333_isol_valve_right_pos = isol_valve_right_pos
    A333_pack1_valve_pos  = pack1_valve_pos
    A333_pack2_valve_pos = pack2_valve_pos
    A333_user_bleed_status = user_bleed_status
    A333_pack1_flow = pack1_flow
    A333_pack2_flow = pack2_flow
    A333_pack1_flow_status = pack1_flow_status
    A333_pack2_flow_status = pack2_flow_status
    A333_precooler1_temp = precooler1_temp
    A333_precooler2_temp = precooler2_temp
    A333_pack1_compressor_outlet_temp = pack1_compressor_outlet_temp
    A333_pack2_compressor_outlet_temp = pack2_compressor_outlet_temp
    A333_left_wing_ai_valve_ind = left_wing_ai_valve_ind
    A333_right_wing_ai_valve_ind = right_wing_ai_valve_ind
    A333_left_wing_ai_status = left_wing_ai_status
    A333_right_wing_ai_status = right_wing_ai_status

end




---- ECAM COND PAGE
local function A333_ecam_page_COND()

    local sim_time_factor2 = m.fmod(simDR_flight_time, 0.8)
    local flasher_pack = ((sim_time_factor2 >= 0 and sim_time_factor2 <= 0.3) and 2) or 1
    local bus1_power = simDR_bus1_power
    local bus2_power = simDR_bus2_power
    local left_duct_avail = simDR_left_duct_avail
    local right_duct_avail = simDR_right_duct_avail
    local TAT = simDR_TAT

    local switches_hot_air1_pos = A333_switches_hot_air1_pos
    local switches_hot_air2_pos = A333_switches_hot_air2_pos
    local cabin_fan_pos = A333_cabin_fan_pos
    local cargo_cooling_mode_pos = A333_cargo_cooling_mode_pos
    local bulk_cargo_temp_ind = A333_bulk_cargo_temp_ind
    local cargo_temp_ind = A333_cargo_temp_ind
    local cockpit_temp_ind = A333_cockpit_temp_ind
    local cabin_fwd_temp_ind = A333_cabin_fwd_temp_ind
    local cabin_fwd_mid_temp_ind = A333_cabin_fwd_mid_temp_ind
    local cabin_mid_fwd_temp_ind = A333_cabin_mid_fwd_temp_ind
    local cabin_mid_temp_ind = A333_cabin_mid_temp_ind
    local cabin_mid_aft_temp_ind = A333_cabin_mid_aft_temp_ind
    local cabin_aft_temp_ind = A333_cabin_aft_temp_ind
    local cockpit_temp_knob_pos = A333_cockpit_temp_knob_pos
    local cabin_temp_knob_pos = A333_cabin_temp_knob_pos
    local fwd_cargo_temp_knob_pos = A333_fwd_cargo_temp_knob_pos
    local bulk_cargo_temp_knob_pos = A333_bulk_cargo_temp_knob_pos
    local pack2_outlet_temp = A333_pack2_outlet_temp
    local pack1_outlet_temp = A333_pack1_outlet_temp

    local hot_air_cross_valve_pos = A333_hot_air_cross_valve_pos
    local pack1_valve_pos = A333_pack1_valve_pos
    local cold_air_valve = A333_cold_air_valve
    local zone1_needle = A333_zone1_needle
    local zone2_needle = A333_zone2_needle
    local zone3_needle = A333_zone3_needle
    local zone4_needle = A333_zone4_needle
    local zone5_needle = A333_zone5_needle
    local zone6_needle = A333_zone6_needle
    local zone7_needle = A333_zone7_needle
    local cargo_needle = A333_cargo_needle


    lcl.pack_lo_flasher = A333_set_animation_position(lcl.pack_lo_flasher, flasher_pack, 1, 2, 10)
    lcl.buses_powered = ((bus1_power >= 5 or bus2_power >= 5) and 1) or 0

    A333_pack_lo_flow = (((simDR_left_pack == 1 or simDR_right_pack == 1)
        and (left_duct_avail < 0.5 and right_duct_avail < 0.5))
        and lcl.pack_lo_flasher) or 0

    A333_pack_regulated = (((switches_hot_air1_pos == 0 and switches_hot_air2_pos == 0)
        or ((switches_hot_air1_pos >= 1 or switches_hot_air2_pos >= 1) and lcl.buses_powered == 0))
        and 1) or 0

    A333_cabin_fan1_off = (((cabin_fan_pos == 0) or ((cabin_fan_pos >= 1) and (bus1_power < 5))) and 1) or 0
    A333_cabin_fan2_off = (((cabin_fan_pos == 0) or ((cabin_fan_pos >= 1) and (bus2_power < 5))) and 1) or 0

    A333_bulk_heater_line = ((A333_cargo_cond_hot_air_pos >= 1 and bus2_power >= 10) and 1) or 0


    A333_hot_air_1_valve = ((switches_hot_air1_pos >= 1 and bus1_power >= 10) and 1) or 0
    A333_hot_air_2_valve = ((switches_hot_air2_pos >= 1 and bus2_power >= 10) and 1) or 0

    lcl.hot_air1_pressed = ((A333_hot_air_1_valve == 1 and left_duct_avail > 0.25) and 1) or 0
    lcl.hot_air2_pressed = ((A333_hot_air_2_valve == 1 and right_duct_avail > 0.25) and 1) or 0

    lcl.hot_air_xfeed_pos_target = (((lcl.hot_air1_pressed == 1 and lcl.hot_air2_pressed == 0)
        or (lcl.hot_air1_pressed == 0 and lcl.hot_air2_pressed == 1))
        and 1) or 0

    hot_air_cross_valve_pos = A333_set_animation_position(hot_air_cross_valve_pos, lcl.hot_air_xfeed_pos_target, 0, 1, 2)

    A333_hot_air_loop1_status = ((hot_air_cross_valve_pos == 1) and 1) or lcl.hot_air1_pressed
    A333_hot_air_loop2_status = ((hot_air_cross_valve_pos == 1) and 1) or lcl.hot_air2_pressed

    A333_cold_air_line2 = ((pack1_valve_pos == 0 and right_duct_avail == 0) and 0) or 1
    A333_cold_air_line1 = ((A333_cold_air_line2 == 1 and cargo_cooling_mode_pos >= 1) and 1) or 0

    if pack1_valve_pos == 1 and right_duct_avail == 1 then
		lcl.TOTAL_pack_status = 2
	elseif pack1_valve_pos == 1 and right_duct_avail == 0 then
		lcl.TOTAL_pack_status = 1
	elseif pack1_valve_pos == 0 and right_duct_avail == 1 then
		lcl.TOTAL_pack_status = 1
	elseif pack1_valve_pos == 0 and right_duct_avail == 0 then
		lcl.TOTAL_pack_status = 0
	end

    lcl.cooling_valve_pos_target = (lcl.buses_powered == 1 and cargo_cooling_mode_pos) or 0
    lcl.cooling_valve_pos = A333_set_animation_position(lcl.cooling_valve_pos, lcl.cooling_valve_pos_target, 0, 2, 2)
    lcl.cooling_valve_mid = ((lcl.cooling_valve_pos > 0.99 and lcl.cooling_valve_pos < 1.01 and lcl.cooling_valve_pos_target == 1) and 1) or 0



    if lcl.cooling_valve_pos == 0 then
		if lcl.TOTAL_pack_status == 1 then
            cold_air_valve = 0
		elseif lcl.TOTAL_pack_status ~= 1 then
            cold_air_valve = 1
		end
	elseif lcl.cooling_valve_pos ~= 0 and lcl.cooling_valve_pos ~= 2 and lcl.cooling_valve_mid == 0 then
        cold_air_valve = 2
	elseif lcl.cooling_valve_mid == 1 then
		if lcl.TOTAL_pack_status == 1 then
            cold_air_valve = 2
		elseif lcl.TOTAL_pack_status ~= 1 then
            cold_air_valve = 3
		end
	elseif lcl.cooling_valve_pos == 2 then
		if lcl.TOTAL_pack_status == 1 then
            cold_air_valve = 4
		elseif lcl.TOTAL_pack_status ~= 1 then
            cold_air_valve = 5
		end
	end

	lcl.bulk_temp_differential = lcl.bulk_cargo_temperature_target - bulk_cargo_temp_ind
	lcl.cargo_temp_differential = lcl.cargo_temperature_target - cargo_temp_ind
	lcl.zone1_differential = lcl.cockpit_temperature_target - cockpit_temp_ind
	lcl.zone2_differential = lcl.cabin_temperature_fwd_target - cabin_fwd_temp_ind
	lcl.zone3_differential = (lcl.cabin_temperature_fwd_target * 0.667 + lcl.cabin_temperature_mid_target * 0.333) - cabin_fwd_mid_temp_ind
	lcl.zone4_differential = (lcl.cabin_temperature_fwd_target * 0.333 + lcl.cabin_temperature_mid_target * 0.667) - cabin_mid_fwd_temp_ind
	lcl.zone5_differential = lcl.cabin_temperature_mid_target - cabin_mid_temp_ind
	lcl.zone6_differential = (lcl.cabin_temperature_mid_target * 0.5 + lcl.cabin_temperature_aft_target * 0.5) - cabin_mid_aft_temp_ind
	lcl.zone7_differential = lcl.cabin_temperature_aft_target - cabin_aft_temp_ind

	local ckpt_ex_lo = rescale(-1, -67, 1, -40, cockpit_temp_knob_pos)
	local ckpt_ex_hi = rescale(-1, 63, 1, 90, cockpit_temp_knob_pos)
	local cabin_ex_lo = rescale(-1, -67, 1, -40, cabin_temp_knob_pos)
	local cabin_ex_hi = rescale(-1, 63, 1, 90, cabin_temp_knob_pos)
	local cargo_ex_lo = rescale(-1, -67, 1, -40, fwd_cargo_temp_knob_pos)
	local cargo_ex_hi = rescale(-1, 63, 1, 90, fwd_cargo_temp_knob_pos)

	local cockpit_needle_extra = rescale(ckpt_ex_lo, -1, ckpt_ex_hi, 1, (lcl.cockpit_temperature_target - TAT))
	local cabin_fwd_needle_extra = rescale(cabin_ex_lo, -1, cabin_ex_hi, 1, (lcl.cabin_temperature_fwd_target - TAT))
	local cabin_mid_needle_extra = rescale(cabin_ex_lo, -1, cabin_ex_hi, 1, (lcl.cabin_temperature_mid_target - TAT))
	local cabin_aft_needle_extra = rescale(cabin_ex_lo, -1, cabin_ex_hi, 1, (lcl.cabin_temperature_aft_target - TAT))
	local cargo_needle_extra = rescale(cargo_ex_lo, -1, cargo_ex_hi, 1, (lcl.cargo_temperature_target - TAT))

	A333_bulk_needle = A333_set_animation_position(A333_bulk_needle, bulk_cargo_temp_knob_pos, -1, 1, 2)


    lcl.zone2_needle_target = 0
    lcl.zone5_needle_target = 0
    lcl.zone7_needle_target = 0
    lcl.cargo_temp_needle_target = 0

	if A333_hot_air_loop1_status == 1 then
		lcl.zone2_needle_target = rescale(-10, -1, 10, 1, lcl.zone2_differential) + cabin_fwd_needle_extra
		lcl.zone5_needle_target = rescale(-10, -1, 10, 1, lcl.zone5_differential) + cabin_mid_needle_extra
		lcl.zone7_needle_target = rescale(-10, -1, 10, 1, lcl.zone7_differential) + cabin_aft_needle_extra

		if cargo_cooling_mode_pos >= 1 then
			lcl.cargo_temp_needle_target = rescale(-10, -1, 10, 1, lcl.cargo_temp_differential) + cargo_needle_extra
		elseif cargo_cooling_mode_pos == 0 then
			lcl.cargo_temp_needle_target = 0
		end

	end


    lcl.zone1_needle_target = 0
    lcl.zone3_needle_target = 0
    lcl.zone4_needle_target = 0
    lcl.zone6_needle_target = 0

	if A333_hot_air_loop2_status == 1 then
		lcl.zone1_needle_target = rescale(-10, -1, 10, 1, lcl.zone1_differential) + cockpit_needle_extra
		lcl.zone3_needle_target = rescale(-10, -1, 10, 1, lcl.zone3_differential) + cabin_fwd_needle_extra
		lcl.zone4_needle_target = rescale(-10, -1, 10, 1, lcl.zone4_differential) + cabin_mid_needle_extra
		lcl.zone6_needle_target = rescale(-10, -1, 10, 1, lcl.zone6_differential) + cabin_aft_needle_extra
	end

    zone1_needle = A333_set_animation_position(zone1_needle, lcl.zone1_needle_target, -1, 1, 2)
    zone2_needle = A333_set_animation_position(zone2_needle, lcl.zone2_needle_target, -1, 1, 2)
    zone3_needle = A333_set_animation_position(zone3_needle, lcl.zone3_needle_target, -1, 1, 2)
    zone4_needle = A333_set_animation_position(zone4_needle, lcl.zone4_needle_target, -1, 1, 2)
	zone5_needle = A333_set_animation_position(zone5_needle, lcl.zone5_needle_target, -1, 1, 2)
	zone6_needle = A333_set_animation_position(zone6_needle, lcl.zone6_needle_target, -1, 1, 2)
	zone7_needle = A333_set_animation_position(zone7_needle, lcl.zone7_needle_target, -1, 1, 2)
	cargo_needle = A333_set_animation_position(cargo_needle, lcl.cargo_temp_needle_target, -1, 1, 2)

	if lcl.bulk_rate == 0.001 then
		A333_bulk_duct_temp = A333_set_animation_position(A333_bulk_duct_temp, bulk_cargo_temp_ind + 3, -40, 50, lcl.bulk_rate * 10)
	elseif lcl.bulk_rate == 0.01 then
		A333_bulk_duct_temp = A333_set_animation_position(A333_bulk_duct_temp, (bulk_cargo_temp_ind + rescale(-1, lcl.bulk_temp_differential, 1, lcl.bulk_temp_differential * 2, A333_bulk_needle)) + 3, -40, 50, lcl.bulk_rate * 10)
	end

	local zone1_duct_temp_target = 0.1 * pack2_outlet_temp + rescale(-1, cockpit_temp_ind - 18, 1, cockpit_temp_ind + 15, zone1_needle)
	local zone2_duct_temp_target = 0.1 * pack1_outlet_temp + rescale(-1, cabin_fwd_temp_ind - 18, 1, cabin_fwd_temp_ind + 15, zone2_needle)
	local zone3_duct_temp_target = 0.1 * pack2_outlet_temp + rescale(-1, cabin_fwd_mid_temp_ind - 18, 1, cabin_fwd_mid_temp_ind + 15, zone3_needle)
	local zone4_duct_temp_target = 0.1 * pack2_outlet_temp + rescale(-1, cabin_mid_fwd_temp_ind - 18, 1, cabin_mid_fwd_temp_ind + 15, zone4_needle)
	local zone5_duct_temp_target = 0.1 * pack1_outlet_temp + rescale(-1, cabin_mid_temp_ind - 18, 1, cabin_mid_temp_ind + 15, zone5_needle)
	local zone6_duct_temp_target = 0.1 * pack2_outlet_temp + rescale(-1, cabin_mid_aft_temp_ind - 18, 1, cabin_mid_aft_temp_ind + 15, zone6_needle)
	local zone7_duct_temp_target = 0.1 * pack1_outlet_temp + rescale(-1, cabin_aft_temp_ind - 18, 1, cabin_aft_temp_ind + 15, zone7_needle)
	local cargo_duct_temp_target = 0.1 * pack1_outlet_temp + rescale(-1, cargo_temp_ind - 18, 1, cargo_temp_ind + 15, cargo_needle)

	A333_zone1_duct_temp = A333_set_animation_position(A333_zone1_duct_temp, zone1_duct_temp_target, pack2_outlet_temp - 10, 99, 2)
	A333_zone2_duct_temp = A333_set_animation_position(A333_zone2_duct_temp, zone2_duct_temp_target, pack1_outlet_temp - 10, 99, 2)
	A333_zone3_duct_temp = A333_set_animation_position(A333_zone3_duct_temp, zone3_duct_temp_target, pack2_outlet_temp - 10, 99, 2)
	A333_zone4_duct_temp = A333_set_animation_position(A333_zone4_duct_temp, zone4_duct_temp_target, pack2_outlet_temp - 10, 99, 2)
	A333_zone5_duct_temp = A333_set_animation_position(A333_zone5_duct_temp, zone5_duct_temp_target, pack1_outlet_temp - 10, 99, 2)
	A333_zone6_duct_temp = A333_set_animation_position(A333_zone6_duct_temp, zone6_duct_temp_target, pack2_outlet_temp - 10, 99, 2)
	A333_zone7_duct_temp = A333_set_animation_position(A333_zone7_duct_temp, zone7_duct_temp_target, pack1_outlet_temp - 10, 99, 2)
	A333_cargo_duct_temp = rescale(2, 2, 100, 100, A333_set_animation_position(A333_cargo_duct_temp, cargo_duct_temp_target, pack1_outlet_temp - 10, 99, 2))

    A333_hot_air_cross_valve_pos = hot_air_cross_valve_pos
    A333_pack1_valve_pos = pack1_valve_pos
    A333_cold_air_valve = cold_air_valve
    A333_zone1_needle = zone1_needle
    A333_zone2_needle = zone2_needle
    A333_zone3_needle = zone3_needle
    A333_zone4_needle = zone4_needle
    A333_zone5_needle = zone5_needle
    A333_zone6_needle = zone6_needle
    A333_zone7_needle = zone7_needle
    A333_cargo_needle = cargo_needle


end




---- ECAM DOORS PAGE
local function A333_ecam_page_DOORS()

    local oxygen_on = A333_crew_supply_status
    local ox_psi = simDR_ox_psi
    local door_ratio = simDR_door_ratio
    local flight_phase = A333_flight_phase
 	local cabin_alt = simDR_cabin_alt
    local oxy_demand = simDR_ox_demand_setting
    
    A333_cockpit_oxy_status = ((oxygen_on == 1 and ox_psi >= 400) and 1) or 0
    A333_regul_lo_pr_status = (((oxygen_on == 0) or (oxygen_on == 1 and ox_psi < 50)) and 1) or 0

	if oxygen_on == 1 then
		if cabin_alt >= 15000 then
			oxy_demand = 7
		else oxy_demand = 6
		end
	elseif oxygen_on == 0 then
		oxy_demand = 0
	end
   
    lcl.slides_armed = ((flight_phase > 1 and flight_phase < 10) and 1) or 0

    A333_slide1_status = ((door_ratio[0] == 0 and lcl.slides_armed == 0) and -1)
        or ((door_ratio[0] == 0 and lcl.slides_armed == 1) and 1)
        or 0

    A333_slide2_status = ((door_ratio[1] == 0 and lcl.slides_armed == 0) and -1)
        or ((door_ratio[1] == 0 and lcl.slides_armed == 1) and 1)
        or 0

    A333_slide3_status = ((door_ratio[2] == 0 and lcl.slides_armed == 0) and -1)
        or ((door_ratio[2] == 0 and lcl.slides_armed == 1) and 1)
        or 0

    A333_slide4_status = ((door_ratio[3] == 0 and lcl.slides_armed == 0) and -1)
        or ((door_ratio[3] == 0 and lcl.slides_armed == 1) and 1)
        or 0

    A333_slide5_status = ((door_ratio[4] == 0 and lcl.slides_armed == 0) and -1)
        or ((door_ratio[4] == 0 and lcl.slides_armed == 1) and 1)
        or 0

    A333_slide6_status = ((door_ratio[5] == 0 and lcl.slides_armed == 0) and -1)
        or ((door_ratio[5] == 0 and lcl.slides_armed == 1) and 1)
        or 0

    A333_slide7_status = ((door_ratio[6] == 0 and lcl.slides_armed == 0) and -1)
        or ((door_ratio[6] == 0 and lcl.slides_armed == 1) and 1)
        or 0

    A333_slide8_status = ((door_ratio[7] == 0 and lcl.slides_armed == 0) and -1)
        or ((door_ratio[7] == 0 and lcl.slides_armed == 1) and 1)
        or 0
 
	simDR_ox_demand_setting = oxy_demand
    
end

---- DOOR INDUCED DEPRESSURIZATION

local function A333_depress_open_doors()

	for i = 0, 10 do
	
	if simDR_door_ratio[i] > 0.05 then
		simDR_dump_pressure = 1
	end

	end

	if simDR_door_ratio[0] == 0 and
		simDR_door_ratio[1] == 0 and
		simDR_door_ratio[2] == 0 and
		simDR_door_ratio[3] == 0 and
		simDR_door_ratio[4] == 0 and
		simDR_door_ratio[5] == 0 and
		simDR_door_ratio[6] == 0 and
		simDR_door_ratio[7] == 0 and
		simDR_door_ratio[8] == 0 and
		simDR_door_ratio[9] == 0 and
		simDR_door_ratio[10] == 0 then
		simDR_dump_pressure = 0
	end

end


---- ENGINES
local function A333_engine_power_setting_indicator()

    local gear_on_ground = simDR_gear_on_ground

	lcl.max_throttle_mode = m.max(simDR_fadec_power_mode_eng1, simDR_fadec_power_mode_eng2) -- 0 = NONE, 1 = CLB, 2 = MCT/FLX, 3 - TOGA

    -- A333_ECAM_thrust_mode: -- 0 = climb, 1 = MCT, 2 = FLEX, 3 = TOGA

	if gear_on_ground == 1 then

		if lcl.max_throttle_mode < 3 then

			if lcl.flex_mode == 0 then
				A333_ECAM_thrust_mode = 3
				A333_ECAM_thrust_limit_EPR = simDR_fadec_engine_limits_toga
			elseif lcl.flex_mode == 1 then
				A333_ECAM_thrust_mode = 2
				A333_ECAM_thrust_limit_EPR = simDR_fadec_engine_limits_mct_flx
			end
		elseif lcl.max_throttle_mode == 3 then
			A333_ECAM_thrust_mode = 3
			A333_ECAM_thrust_limit_EPR = simDR_fadec_engine_limits_toga
		end

	elseif gear_on_ground == 0 then

		if lcl.max_throttle_mode <= 1 then
			A333_ECAM_thrust_mode = 0
			A333_ECAM_thrust_limit_EPR = simDR_fadec_engine_limits_clb
		elseif lcl.max_throttle_mode == 2 then
			A333_ECAM_thrust_limit_EPR = simDR_fadec_engine_limits_mct_flx
			if lcl.flex_mode == 1 then
				A333_ECAM_thrust_mode = 2
			elseif lcl.flex_mode == 0 then
				A333_ECAM_thrust_mode = 1
			end
		elseif lcl.max_throttle_mode == 3 then
			A333_ECAM_thrust_mode = 3
			A333_ECAM_thrust_limit_EPR = simDR_fadec_engine_limits_toga
		end
	end


end




local function A333_fuel_totalizer_reset()

    local eng_N2 = simDR_eng_N2
    local engine_starter_running = simDR_engine_starter_running
    local fuel_burned_eng = simDR_fuel_burned_eng

	if eng_N2[0] <= 30 and eng_N2[1] <= 30 then

		if A333_flight_phase == 1 then
			if engine_starter_running[0] == 1 or engine_starter_running[1] == 1 then
                fuel_burned_eng[0] = 0
                fuel_burned_eng[1] = 0
				simDR_fuel_burned_total = 0
			end
		end

	end

end

local function A333_throttle_pos_ind()


	if simDR_FADEC_EPR[0] == 0 then
		A333_ECAM_engine_donut1 = 1
	else A333_ECAM_engine_donut1 = simDR_FADEC_EPR[0]
	end
	
	if simDR_FADEC_EPR[1] == 0 then
		A333_ECAM_engine_donut2 = 1
	else A333_ECAM_engine_donut2 = simDR_FADEC_EPR[1]
	end	

end


---- ENGINE IDLE MODE ---------------------------------------------------------------------
local function A333_ground_timer()

    local gear_on_ground = simDR_gear_on_ground
    local prop_mode = simDR_prop_mode

	if gear_on_ground == 1
		and prop_mode[0] == 1
		and prop_mode[1] == 1
    then
		lcl.ground_timer = lcl.ground_timer + lcl_SIM_PERIOD

	elseif gear_on_ground == 0 then
		lcl.ground_timer = 0
	end

end




local function A333_idle_mode_logic()

    local gear_on_ground = simDR_gear_on_ground
	local air_mode = 1
	local wing_heat = ((simDR_wing_heat_left == 1 or simDR_wing_heat_right == 1) and 1) or 0

	if wing_heat == 0 then
		lcl.anti_ice_multiplier_lo = 1
		lcl.anti_ice_multiplier_g_lo = 1
		lcl.anti_ice_multiplier = 1.29
		lcl.anti_ice_multiplier_g = 1.48
	elseif wing_heat == 1 then
		lcl.anti_ice_multiplier_lo = 1.29
		lcl.anti_ice_multiplier_g_lo = 1.48
		lcl.anti_ice_multiplier = 1.42
		lcl.anti_ice_multiplier_g = 1.69
	end

	if gear_on_ground == 0 then
		air_mode = 1
	elseif gear_on_ground == 1
		and lcl.ground_timer > 5 then
		air_mode = 0
	end

	--- ENGINE GROUND / FLIGHT IDLE ---
    simDR_low_idle = (air_mode == 0 and LOW_IDLE_PLN_TARGET * lcl.anti_ice_multiplier_g_lo) or (HIGH_IDLE_PLN_TARGET * lcl.anti_ice_multiplier_lo) -- set engines to LOW idle all other times -- THIS IS DONE IN SWITCHES.lua
    simDR_high_idle = (air_mode == 0 and LOW_IDLE_PLN_TARGET * lcl.anti_ice_multiplier_g) or (HIGH_IDLE_PLN_TARGET * lcl.anti_ice_multiplier) -- set engines to HIGH idle with engine Anti Ice -- THIS IS DONE IN SWITCHES.lua

end




----- PFD INDICATORS --------------------------------------------------------------------
local function A333_FPV_calculations()

    local alpha = simDR_alpha

	A333_fpv_pitch_absolute_capt = simDR_AHARS_pitch_capt - alpha
	A333_fpv_pitch_absolute_fo = simDR_AHARS_pitch_FO - alpha

	A333_birdie_pitch_absolute_capt = simDR_fd_pitch_capt - alpha
	A333_birdie_pitch_absolute_fo = simDR_AHARS_pitch_FO - simDR_fd_pitch_fo + A333_fpv_pitch_absolute_fo

end




local function A333_vspeeds()

    local gear_on_ground = simDR_gear_on_ground
    local mmo_in_kias = simDR_mmo_in_kias
    local flap_config = simDR_flap_config
    local gear_handle = simDR_gear_handle
    local flap_handle_request = simDR_flap_handle_request
    local airspeed = simDR_airspeed

    local over_speed_ind = A333_over_speed_ind
    local vmo_mmo_ias = A333_vmo_mmo_ias
    local mach_ias_ratio = A333_mach_ias_ratio
    local next_flap_speed_ind = A333_next_flap_speed_ind

	if lcl.off_ground_timer < 10 then
		if gear_on_ground == 0 then
			lcl.off_ground_timer = lcl.off_ground_timer + lcl_SIM_PERIOD
		elseif gear_on_ground == 1 then
			lcl.off_ground_timer = 0
		end
	elseif lcl.off_ground_timer >= 10 then
		if gear_on_ground == 0 then
			lcl.off_ground_timer = 10
		elseif gear_on_ground == 1 then
			lcl.off_ground_timer = 0
		end
	end

	A333_gear_off_ground_timer = lcl.off_ground_timer

    mach_ias_ratio = mmo_in_kias / lcl.Mmo

	if mmo_in_kias > lcl.Vmo then
        over_speed_ind = (lcl.Vmo + 6)

		if flap_config == 0 then
			if gear_handle == 0 then
                vmo_mmo_ias = lcl.Vmo
			elseif gear_handle > 0 then
                vmo_mmo_ias = lcl.Vle
			end

		elseif flap_config == 1 then
            vmo_mmo_ias = lcl.Vfe_1
		elseif flap_config == 2 then
            vmo_mmo_ias = lcl.Vfe_1f
		elseif flap_config == 3 then
            vmo_mmo_ias = lcl.Vfe_1_star
		elseif flap_config == 4 then
            vmo_mmo_ias = lcl.Vfe_2
		elseif flap_config == 5 then
            vmo_mmo_ias = lcl.Vfe_2_star
		elseif flap_config == 6 then
            vmo_mmo_ias = lcl.Vfe_3
		elseif flap_config == 7 then
            vmo_mmo_ias = lcl.Vfe_full
		end

	elseif mmo_in_kias <= lcl.Vmo then
        over_speed_ind = mach_ias_ratio * (lcl.Mmo + 0.01)

		if flap_config == 0 then

			if gear_handle == 0 then
                vmo_mmo_ias = mmo_in_kias
			elseif gear_handle > 0 then
				if mmo_in_kias > lcl.Vle then
                    vmo_mmo_ias = lcl.Vle
				elseif mmo_in_kias <= lcl.Vle then
                    vmo_mmo_ias = mmo_in_kias
				end
			end

		elseif flap_config == 1 then
            vmo_mmo_ias = lcl.Vfe_1
		elseif flap_config == 2 then
            vmo_mmo_ias = lcl.Vfe_1f
		elseif flap_config == 3 then
            vmo_mmo_ias = lcl.Vfe_1_star
		elseif flap_config == 4 then
            vmo_mmo_ias = lcl.Vfe_2
		elseif flap_config == 5 then
            vmo_mmo_ias = lcl.Vfe_2_star
		elseif flap_config == 6 then
            vmo_mmo_ias = lcl.Vfe_3
		elseif flap_config == 7 then
            vmo_mmo_ias = lcl.Vfe_full
		end

	end

	if flap_handle_request == 0 then
		if airspeed >= 100 then
            next_flap_speed_ind = lcl.Vfe_1
		elseif airspeed < 100 then
            next_flap_speed_ind = lcl.Vfe_1f
		end
	elseif flap_handle_request > 0 and flap_handle_request <= 0.251 then
		if lcl.takeoff_landing_index == 0 then
            next_flap_speed_ind = lcl.Vfe_2
		elseif lcl.takeoff_landing_index == 1 then
            next_flap_speed_ind = lcl.Vfe_1_star
		end
	elseif flap_handle_request > 0.251 and flap_handle_request <= 0.501 then
        next_flap_speed_ind = lcl.Vfe_3
	elseif flap_handle_request > 0.501 and flap_handle_request <= 0.751 then
        next_flap_speed_ind = lcl.Vfe_full
	elseif flap_handle_request > 0.751 then
        next_flap_speed_ind = 9999
	end

    A333_over_speed_ind = over_speed_ind
    A333_vmo_mmo_ias = vmo_mmo_ias
    A333_mach_ias_ratio = mach_ias_ratio
    A333_next_flap_speed_ind = next_flap_speed_ind

end




local function A333_PFD_indicators()   -- TODO:  consider refactor to multiple functions ??

	local sim_time_factor4 = m.fmod(simDR_flight_time, 0.65)
    local ils_flasher = ((sim_time_factor4 >= 0 and sim_time_factor4 <= 0.3) and 1) or 0

	local sim_time_factor5 = m.fmod(simDR_flight_time, 0.75)
    local ws_ahead_flasher = ((sim_time_factor5 >= 0 and sim_time_factor5 <= 0.3) and 1) or 0
    local windshear_flasher = ws_ahead_flasher

	local sim_time_factor6 = m.fmod(simDR_flight_time, 0.70)
	local captFD_flasher = ((sim_time_factor6 >= 0 and sim_time_factor6 <= 0.3) and 1) or 0
	local foFD_flasher = ((sim_time_factor6 >= 0.1 and sim_time_factor6 <= 0.4) and 1) or 0

    local AHARS_pitch_capt = simDR_AHARS_pitch_capt
    local eng_N1 = simDR_eng_N1
    local radio_altimeter_capt = simDR_radio_altimeter_capt
    local vvi_capt = simDR_vvi_capt
    local radio_altimeter_FO = simDR_radio_altimeter_FO
    local AHARS_pitch_FO = simDR_AHARS_pitch_FO
    local vvi_FO = simDR_vvi_FO
    local altitude_sel = simDR_altitude_sel
    local capt_altitude = simDR_capt_altitude
    local fo_altitude = simDR_fo_altitude
    local autopilot_vnav_alt_sel = simDR_autopilot_vnav_alt_sel
    local altv_armed = simDR_altv_armed
    local altv_captured = simDR_altv_captured
    local capt_airspeed = simDR_capt_airspeed
    local fo_airspeed = simDR_fo_airspeed
    local autopilot_ias_sel = simDR_autopilot_ias_sel
    local airspeed_bugs = simDR_airspeed_bugs
    local approach_status = simDR_approach_status
    local ian_mode = simDR_ian_mode
    local ls_bars_capt = A333_ls_bars_capt
    local ls_bars_fo = A333_ls_bars_fo
    local radio_alt_bug_capt = simDR_radio_alt_bug_capt
    local radio_alt_bug_fo = simDR_radio_alt_bug_fo
    local mda_capt = simDR_mda_capt
    local mda_fo = simDR_mda_fo

    local windshear_mode = simDR_windshear_mode
    local ladder_mask_deg_capt = A333_ladder_mask_deg_capt
    local ladder_mask_deg_FO = A333_ladder_mask_deg_FO

	if windshear_mode < 3 then
		lcl.windshear_timer = 0
		lcl.ws_ahead_timer = 0
	elseif windshear_mode == 3 or windshear_mode == 4 then
		lcl.windshear_timer = 0
		if lcl.ws_ahead_timer < 5 then
			lcl.ws_ahead_timer = lcl.ws_ahead_timer + lcl_SIM_PERIOD
		else
            lcl.ws_ahead_timer = 5
		end
	elseif windshear_mode == 5 then
		lcl.ws_ahead_timer = 0
		if lcl.windshear_timer < 5 then
			lcl.windshear_timer = lcl.windshear_timer + lcl_SIM_PERIOD
		else
            lcl.windshear_timer = 5
		end
	end

	if A333_capt_FD_flag == 1 then
		lcl.capt_FD_timer = lcl.capt_FD_timer + lcl_SIM_PERIOD
	else lcl.capt_FD_timer = 0
	end

	if A333_fo_FD_flag == 1 then
		lcl.fo_FD_timer = lcl.fo_FD_timer + lcl_SIM_PERIOD
	else lcl.fo_FD_timer = 0
	end

    A333_ws_ahead_flasher = ((lcl.ws_ahead_timer < 5) and A333_set_animation_position(A333_ws_ahead_flasher, ws_ahead_flasher, 0, 1, 10)) or 1
    A333_windshear_flasher = ((lcl.windshear_timer < 5) and A333_set_animation_position(A333_windshear_flasher, windshear_flasher, 0, 1, 10)) or 1

	A333_capt_FD_flasher = ((lcl.capt_FD_timer < 10) and A333_set_animation_position(A333_capt_FD_flasher, captFD_flasher, 0, 1, 10)) or 1
	A333_fo_FD_flasher = ((lcl.fo_FD_timer < 10) and A333_set_animation_position(A333_fo_FD_flasher, foFD_flasher, 0, 1, 10)) or 1

	ladder_mask_deg_capt = ((AHARS_pitch_capt <= 17.5) and rescale(3, AHARS_pitch_capt, 120, 17.5, radio_altimeter_capt)) or 17.5
    ladder_mask_deg_FO = ((AHARS_pitch_FO <= 17.5) and rescale(3, AHARS_pitch_FO, 120, 17.5, radio_altimeter_FO)) or 17.5

    A333_tick_mark_mode_capt = ((AHARS_pitch_capt <= ladder_mask_deg_capt) and 0) or 1
    A333_tick_mark_mode_FO = ((AHARS_pitch_FO <= ladder_mask_deg_FO) and 0) or 1

    A333_engines_running = ((eng_N1[0] >= 20 or eng_N1[1] >= 20) and 1) or 0

	if radio_altimeter_capt >= 2500 then
		if vvi_capt < 6000 and vvi_capt > -6000 then
			A333_vvi_capt_amber = 0
		elseif vvi_capt >= 6000 or vvi_capt <= -6000 then
			A333_vvi_capt_amber = 1
		end
	elseif radio_altimeter_capt < 2500 and radio_altimeter_capt >= 1000 then
		if vvi_capt < 6000 and vvi_capt > -2000 then
			A333_vvi_capt_amber = 0
		elseif vvi_capt >= 6000 or vvi_capt <= -2000 then
			A333_vvi_capt_amber = 1
		end
	elseif radio_altimeter_capt < 1000 then
		if vvi_capt < 6000 and vvi_capt > -1200 then
			A333_vvi_capt_amber = 0
		elseif vvi_capt >= 6000 or vvi_capt <= -1200 then
			A333_vvi_capt_amber = 1
		end
	end

	if radio_altimeter_FO >= 2500 then
		if vvi_FO < 6000 and vvi_FO > -6000 then
			A333_vvi_FO_amber = 0
		elseif vvi_FO >= 6000 or vvi_FO <= -6000 then
			A333_vvi_FO_amber = 1
		end
	elseif radio_altimeter_FO < 2500 and radio_altimeter_FO >= 1000 then
		if vvi_FO < 6000 and vvi_FO > -2000 then
			A333_vvi_FO_amber = 0
		elseif vvi_FO >= 6000 or vvi_FO <= -2000 then
			A333_vvi_FO_amber = 1
		end
	elseif radio_altimeter_FO < 1000 then
		if vvi_FO < 6000 and vvi_FO > -1200 then
			A333_vvi_FO_amber = 0
		elseif vvi_FO >= 6000 or vvi_FO <= -1200 then
			A333_vvi_FO_amber = 1
		end
	end

	-- AUTOPILOT ALT SHOW/HIDE
	-- CYAN
	if altitude_sel >= capt_altitude - 568 and altitude_sel <= capt_altitude + 568 then
		A333_capt_autopilot_alt_mode = 0
	elseif altitude_sel > capt_altitude + 568 then
		A333_capt_autopilot_alt_mode = 1
	elseif altitude_sel < capt_altitude - 568 then
		A333_capt_autopilot_alt_mode = -1
	end

	if altitude_sel >= fo_altitude - 568 and altitude_sel <= fo_altitude + 568 then
		A333_fo_autopilot_alt_mode = 0
	elseif altitude_sel > fo_altitude + 568 then
		A333_fo_autopilot_alt_mode = 1
	elseif altitude_sel < fo_altitude - 568 then
		A333_fo_autopilot_alt_mode = -1
	end
	-- MAGENTA

	if autopilot_vnav_alt_sel >= capt_altitude - 568 and autopilot_vnav_alt_sel <= capt_altitude + 568 then
		A333_capt_autopilot_vnav_alt_mode = 0
	elseif autopilot_vnav_alt_sel > capt_altitude + 568 then
		A333_capt_autopilot_vnav_alt_mode = 1
	elseif autopilot_vnav_alt_sel < capt_altitude - 568 then
		A333_capt_autopilot_vnav_alt_mode = -1
	end

	if autopilot_vnav_alt_sel >= fo_altitude - 568 and autopilot_vnav_alt_sel <= fo_altitude + 568 then
		A333_fo_autopilot_vnav_alt_mode = 0
	elseif autopilot_vnav_alt_sel > fo_altitude + 568 then
		A333_fo_autopilot_vnav_alt_mode = 1
	elseif autopilot_vnav_alt_sel < fo_altitude - 568 then
		A333_fo_autopilot_vnav_alt_mode = -1
	end

    A333_ap_alt_ind_color = ((altv_armed == 1 or altv_captured == 1) and 1) or 0


	-- ALTITUDE CONVERSION
    lcl.capt_airspeed_conversion = (capt_airspeed <= 30 and 30) or capt_airspeed
    lcl.fo_airspeed_conversion = (fo_airspeed <= 30 and 30) or fo_airspeed

	-- AUTOPILOT IAS SHOW/HIDE
	if autopilot_ias_sel >= lcl.capt_airspeed_conversion - 41.9047619048 and autopilot_ias_sel <= lcl.capt_airspeed_conversion + 41.9047619048 then
		A333_capt_autopilot_speed_mode = 0
	elseif autopilot_ias_sel > lcl.capt_airspeed_conversion + 41.9047619048 then
		A333_capt_autopilot_speed_mode = 1
	elseif autopilot_ias_sel < lcl.capt_airspeed_conversion - 41.9047619048 then
		A333_capt_autopilot_speed_mode = -1
	end

	if autopilot_ias_sel >= lcl.fo_airspeed_conversion - 41.9047619048 and autopilot_ias_sel <= lcl.fo_airspeed_conversion + 41.9047619048 then
		A333_fo_autopilot_speed_mode = 0
	elseif autopilot_ias_sel > lcl.fo_airspeed_conversion + 41.9047619048 then
		A333_fo_autopilot_speed_mode = 1
	elseif autopilot_ias_sel < lcl.fo_airspeed_conversion - 41.9047619048 then
		A333_fo_autopilot_speed_mode = -1
	end

	-- GREEN DOT SPEED SHOW/HIDE
	if airspeed_bugs[5] >= lcl.capt_airspeed_conversion - 41.9047619048 and airspeed_bugs[5] <= lcl.capt_airspeed_conversion + 41.9047619048 then
		A333_capt_green_dot_mode = 0
	elseif airspeed_bugs[5] > lcl.capt_airspeed_conversion + 41.9047619048 then
		A333_capt_green_dot_mode = 1
	elseif airspeed_bugs[5] < lcl.capt_airspeed_conversion - 41.9047619048 then
		A333_capt_green_dot_mode = -1
	end

	if airspeed_bugs[5] >= lcl.fo_airspeed_conversion - 41.9047619048 and airspeed_bugs[5] <= lcl.fo_airspeed_conversion + 41.9047619048 then
		A333_fo_green_dot_mode = 0
	elseif airspeed_bugs[5] > lcl.fo_airspeed_conversion + 41.9047619048 then
		A333_fo_green_dot_mode = 1
	elseif airspeed_bugs[5] < lcl.fo_airspeed_conversion - 41.9047619048 then
		A333_fo_green_dot_mode = -1
	end

	-- Vr SPEED SHOW/HIDE
	if airspeed_bugs[1] >= lcl.capt_airspeed_conversion - 41.9047619048 and airspeed_bugs[1] <= lcl.capt_airspeed_conversion + 41.9047619048 then
		A333_capt_Vr_mode = 0
	elseif airspeed_bugs[1] > lcl.capt_airspeed_conversion + 41.9047619048 then
		A333_capt_Vr_mode = 1
	elseif airspeed_bugs[1] < lcl.capt_airspeed_conversion - 41.9047619048 then
		A333_capt_Vr_mode = -1
	end

	if airspeed_bugs[1] >= lcl.fo_airspeed_conversion - 41.9047619048 and airspeed_bugs[1] <= lcl.fo_airspeed_conversion + 41.9047619048 then
		A333_fo_Vr_mode = 0
	elseif airspeed_bugs[1] > lcl.fo_airspeed_conversion + 41.9047619048 then
		A333_fo_Vr_mode = 1
	elseif airspeed_bugs[1] < lcl.fo_airspeed_conversion - 41.9047619048 then
		A333_fo_Vr_mode = -1
	end

	-- V1 SPEED SHOW/HIDE
	if airspeed_bugs[0] >= lcl.capt_airspeed_conversion - 41.9047619048 and airspeed_bugs[0] <= lcl.capt_airspeed_conversion + 41.9047619048 then
		A333_capt_V1_mode = 0
	elseif airspeed_bugs[0] > lcl.capt_airspeed_conversion + 41.9047619048 then
		A333_capt_V1_mode = 1
	elseif airspeed_bugs[0] < lcl.capt_airspeed_conversion - 41.9047619048 then
		A333_capt_V1_mode = -1
	end

	if airspeed_bugs[0] >= lcl.fo_airspeed_conversion - 41.9047619048 and airspeed_bugs[0] <= lcl.fo_airspeed_conversion + 41.9047619048 then
		A333_fo_V1_mode = 0
	elseif airspeed_bugs[0] > lcl.fo_airspeed_conversion + 41.9047619048 then
		A333_fo_V1_mode = 1
	elseif airspeed_bugs[0] < lcl.fo_airspeed_conversion - 41.9047619048 then
		A333_fo_V1_mode = -1
	end

	-- ILS WARNING FLASHER
	if approach_status >= 1 and ian_mode == 0 then
		if ls_bars_capt == 0 then
			A333_ils_flasher_capt_status = 1
		elseif ls_bars_capt == 1 then
			A333_ils_flasher_capt_status = 0
		end
		if ls_bars_fo == 0 then
			A333_ils_flasher_fo_status = 1
		elseif ls_bars_fo == 1 then
			A333_ils_flasher_fo_status = 0
		end
	elseif approach_status == 0 or ian_mode ~= 0 then
		A333_ils_flasher_capt_status = 0
		A333_ils_flasher_fo_status = 0
	end

	A333_ils_flasher_capt = A333_set_animation_position(A333_ils_flasher_capt, ils_flasher, 0, 1, 10)
	A333_ils_flasher_fo = A333_set_animation_position(A333_ils_flasher_fo, ils_flasher, 0, 1, 10)


	if ian_mode > 0 then
		if ls_bars_capt == 1 then
			A333_vdev_flasher_capt_status = 1
		elseif ls_bars_capt == 0 then
			A333_vdev_flasher_capt_status = 0
		end
		if ls_bars_fo == 1 then
			A333_vdev_flasher_fo_status = 1
		elseif ls_bars_fo == 0 then
			A333_vdev_flasher_fo_status = 0
		end
	elseif ian_mode == 0 then
		A333_vdev_flasher_capt_status = 0
		A333_vdev_flasher_fo_status = 0
	end

	A333_vdev_flasher_capt = A333_set_animation_position(A333_vdev_flasher_capt, ils_flasher, 0, 1, 10)
	A333_vdev_flasher_fo = A333_set_animation_position(A333_vdev_flasher_fo, ils_flasher, 0, 1, 10)


	-- DH RADIO ALTIMETER COLOR
	if radio_alt_bug_capt == -1 then
		A333_radio_altimeter_color_capt = 0
	elseif radio_alt_bug_capt == 0 then
		if radio_altimeter_capt <= 400 then
			A333_radio_altimeter_color_capt = 1
		elseif  radio_altimeter_capt > 400 then
			A333_radio_altimeter_color_capt = 0
		end
	elseif radio_alt_bug_capt > 0 then
		if radio_altimeter_capt <= (radio_alt_bug_capt + 100) then
			A333_radio_altimeter_color_capt = 1
		elseif  radio_altimeter_capt > (radio_alt_bug_capt + 100) then
			A333_radio_altimeter_color_capt = 0
		end
	end

	if radio_alt_bug_fo == -1 then
		A333_radio_altimeter_color_fo = 0
	elseif radio_alt_bug_fo == 0 then
		if radio_altimeter_FO <= 400 then
			A333_radio_altimeter_color_fo = 1
		elseif radio_altimeter_FO > 400 then
			A333_radio_altimeter_color_fo = 0
		end
	elseif radio_alt_bug_fo > 0 then
		if radio_altimeter_FO <= (radio_alt_bug_fo + 100) then
			A333_radio_altimeter_color_fo = 1
		elseif radio_altimeter_FO > (radio_alt_bug_fo + 100) then
			A333_radio_altimeter_color_fo = 0
		end
	end


	-- MDA ALT COLOR CHANGE
    A333_mda_altimeter_color_capt = (capt_altitude >= mda_capt and 0) or 1
    A333_mda_altimeter_color_fo = (fo_altitude >= mda_fo and 0) or 1


	-- AUTOPILOT HEADING LOCK
	simDR_autopilot_hdg_sel_fo = simDR_autopilot_hdg_sel
    simDR_windshear_mode = windshear_mode
    A333_ladder_mask_deg_capt = ladder_mask_deg_capt
	A333_ladder_mask_deg_FO = ladder_mask_deg_FO

end


local function A333_landing_alt()

	local cal1 = 563.5593220339
	local cal2 = 55.08474576271
	local landing_alt_capt = simDR_landing_alt_capt
	local landing_alt_capt_calibrated1 = A333_landing_alt_capt_calibrated1
	local landing_alt_capt_calibrated2 = A333_landing_alt_capt_calibrated2
	local capt_altitude = simDR_capt_altitude
	
	local landing_alt_fo = simDR_landing_alt_fo
	local landing_alt_fo_calibrated1 = A333_landing_alt_fo_calibrated1
	local landing_alt_fo_calibrated2 = A333_landing_alt_fo_calibrated2
	local fo_altitude = simDR_fo_altitude

	if landing_alt_capt <= capt_altitude + cal1 then
		landing_alt_capt_calibrated1 = landing_alt_capt
	else landing_alt_capt_calibrated1 = landing_alt_capt + capt_altitude + cal1
	end

	if landing_alt_capt <= capt_altitude + cal2 then
		landing_alt_capt_calibrated2 = landing_alt_capt
	else landing_alt_capt_calibrated2 = landing_alt_capt + capt_altitude + cal2
	end

	if landing_alt_fo <= fo_altitude + cal1 then
		landing_alt_fo_calibrated1 = landing_alt_fo
	else landing_alt_fo_calibrated1 = landing_alt_fo + fo_altitude + cal1
	end

	if landing_alt_fo <= fo_altitude + cal2 then
		landing_alt_fo_calibrated2 = landing_alt_fo
	else landing_alt_fo_calibrated2 = landing_alt_fo + fo_altitude + cal2
	end

	A333_landing_alt_capt_calibrated1 = landing_alt_capt_calibrated1
	A333_landing_alt_capt_calibrated2 = landing_alt_capt_calibrated2
	A333_landing_alt_fo_calibrated1 = landing_alt_fo_calibrated1 
	A333_landing_alt_fo_calibrated2 = landing_alt_fo_calibrated2

end

local function A333_flight_directors()

    local nav_horz_sig = simDR_nav_horz_sig
    local runway_status = simDR_runway_status
    local flare_status = simDR_flare_status
    local rollout_status = simDR_rollout_status
    local gear_on_ground = simDR_gear_on_ground
    local altitude_mode = simDR_altitude_mode
    local heading_mode = simDR_heading_mode
    local airspeed_bugs = simDR_airspeed_bugs

    local flight_dir_vrt_status_capt = A333_flight_dir_vrt_status_capt
    local flight_dir_vrt_status_fo = A333_flight_dir_vrt_status_fo
    local flight_dir_lat_status_capt = A333_flight_dir_lat_status_capt
    local flight_dir_lat_status_fo = A333_flight_dir_lat_status_fo


    -- YAW BAR SHOW HIDE
    A333_flight_dir_bar_status_capt = (((simDR_radio_altimeter_capt <= 30)
        and (nav_horz_sig[0] == 1)
        and (runway_status == 2 or flare_status == 2 or rollout_status == 2))
        and 1) or 0

    A333_flight_dir_bar_status_fo = (((simDR_radio_altimeter_FO <= 30)
        and (nav_horz_sig[1] == 1)
        and (runway_status == 2 or flare_status == 2 or rollout_status == 2))
        and 1) or 0


    -- FD VERTICAL SHOW HIDE
    if gear_on_ground == 1 then
        if altitude_mode ~= 3 then

            if rollout_status == 0 then
                flight_dir_vrt_status_capt = 1
                flight_dir_vrt_status_fo = 1
            elseif rollout_status == 2 then
                flight_dir_vrt_status_capt = 0
                flight_dir_vrt_status_fo = 0
            end

        elseif altitude_mode == 3 then
            flight_dir_vrt_status_capt = 0
            flight_dir_vrt_status_fo = 0
        end
    elseif gear_on_ground == 0 then
        flight_dir_vrt_status_capt = 1
        flight_dir_vrt_status_fo = 1
    end


    -- FD HORIZONTAL SHOW HIDE
    if runway_status == 2 then
        flight_dir_lat_status_capt = 0
        flight_dir_lat_status_fo = 0
    elseif runway_status == 0 then
        if gear_on_ground == 1 then
            if heading_mode ~= 21 and heading_mode ~= 0 then
                flight_dir_lat_status_capt = 1
                flight_dir_lat_status_fo = 1
            elseif heading_mode == 21 or heading_mode == 0 then
                flight_dir_lat_status_capt = 0
                flight_dir_lat_status_fo = 0
            end
        elseif gear_on_ground == 0 then
            flight_dir_lat_status_capt = 1
            flight_dir_lat_status_fo = 1
        end
    end

    A333_flight_dir_vrt_status_capt = flight_dir_vrt_status_capt
    A333_flight_dir_vrt_status_fo = flight_dir_vrt_status_fo
    A333_flight_dir_lat_status_capt = flight_dir_lat_status_capt
    A333_flight_dir_lat_status_fo = flight_dir_lat_status_fo

end




local function A333_DH_flashers()

	-- DH FLASHERS
    local dh_lit_capt = simDR_dh_lit_capt
    local dh_lit_fo = simDR_dh_lit_fo

	if dh_lit_capt == 0 then
		lcl.dh_capt_flash_timer = 0
	elseif dh_lit_capt == 1 then
		if lcl.dh_capt_flash_timer < 3 then
			lcl.dh_capt_flash_timer = lcl.dh_capt_flash_timer + lcl_SIM_PERIOD
		elseif lcl.dh_capt_flash_timer > 3 then
			lcl.dh_capt_flash_timer = 3
		end
	end

	if dh_lit_fo == 0 then
		lcl.dh_fo_flash_timer = 0
	elseif dh_lit_fo == 1 then
		if lcl.dh_fo_flash_timer < 3 then
			lcl.dh_fo_flash_timer = lcl.dh_fo_flash_timer + lcl_SIM_PERIOD
		elseif lcl.dh_fo_flash_timer > 3 then
			lcl.dh_fo_flash_timer = 3
		end
	end



	local dh_capt_flasher_target = 0
	local dh_fo_flasher_target = 0

	local dh_capt_factor = m.fmod(lcl.dh_capt_flash_timer, 0.75)
	local dh_fo_factor = m.fmod(lcl.dh_fo_flash_timer, 0.75)

	if dh_capt_factor >= 0 and dh_capt_factor <= 0.3 then
		if lcl.dh_capt_flash_timer == 0 then
			dh_capt_flasher_target = 0
		else
            dh_capt_flasher_target = 1
		end
	elseif dh_capt_factor > 0.3 and dh_capt_factor < 0.75 then
		dh_capt_flasher_target = 0
	end


	if dh_fo_factor >= 0 and dh_fo_factor <= 0.3 then
		if lcl.dh_fo_flash_timer == 0 then
			dh_fo_flasher_target = 0
		else
            dh_fo_flasher_target = 1
		end
	elseif dh_fo_factor > 0.3 and dh_fo_factor < 0.75 then
		dh_fo_flasher_target = 0
	end

	A333_dh_flasher_capt = A333_set_animation_position(A333_dh_flasher_capt, dh_capt_flasher_target, 0, 1, 10)
	A333_dh_flasher_fo = A333_set_animation_position(A333_dh_flasher_fo, dh_fo_flasher_target, 0, 1, 10)


end




local function GetHeadingDelta(instHeading, aharsHdg180)
    return instHeading - aharsHdg180
end




local function AdjustHeadingDeltaToPosNeg180(delta)
    return ((delta > 180.0) and (delta - 360.0)) or delta
end




local function SetLeftOrRight(bearing)
    return ((bearing < 0.0) and -1) or 1
end




local function SetHideShowValue(bearing)
    return (((bearing >= -23.75) and (bearing <= 23.75)) and 0) or SetLeftOrRight(bearing)
end




local function GetInstrumentHideShowValue(instHeading, aharsHdg180)
    local delta = GetHeadingDelta(instHeading, aharsHdg180)
    local bearing180PosNeg = AdjustHeadingDeltaToPosNeg180(delta)
    return SetHideShowValue(bearing180PosNeg)
end




local function AdjustHeadingToNeg180Range(aharsHeading)
    return ((aharsHeading > 180.0 and aharsHeading < 360.0) and (aharsHeading - 360.0)) or aharsHeading
end




local function SetInstrumentVisibilty(instHeading, aharsHeading)
    return GetInstrumentHideShowValue(instHeading, AdjustHeadingToNeg180Range(aharsHeading))
end




local function A333_InstrumentVisibility()

	A333_ap_heading_mode_capt = SetInstrumentVisibilty(simDR_autopilot_hdg_sel, simDR_capt_AHARS_heading)
	A333_ap_heading_mode_fo = SetInstrumentVisibilty(simDR_autopilot_hdg_sel, simDR_fo_AHARS_heading)
	A333_track_mode_capt = SetInstrumentVisibilty(simDR_capt_track_heading, simDR_capt_AHARS_heading)
	A333_track_mode_fo = SetInstrumentVisibilty(simDR_fo_track_heading, simDR_fo_AHARS_heading)
	A333_ils_mode_capt = SetInstrumentVisibilty(simDR_capt_ils_heading, simDR_capt_AHARS_heading)
	A333_ils_mode_fo = SetInstrumentVisibilty(simDR_fo_ils_heading, simDR_fo_AHARS_heading)
	A333_tru_track_mode_capt = SetInstrumentVisibilty(simDR_capt_track_tru_heading, simDR_capt_AHARS_heading)
	A333_tru_track_mode_fo = SetInstrumentVisibilty(simDR_fo_track_tru_heading, simDR_fo_AHARS_heading)

end




local function A333_FMAs()

	local sim_time_factor3 = m.fmod(simDR_flight_time, 0.7)
    local pfd_flasher = ((sim_time_factor3 >= 0 and sim_time_factor3 <= 0.3) and 1) or 0
    local eng_N2 = simDR_eng_N2

--  local capt_fd_on = A333_capt_FD_bars_bypass -- simDR_capt_fd_on -- TEMPORARY FIX
--  local fo_fd_on = A333_fo_FD_bars_bypass -- simDR_fo_fd_on
	
	local capt_fd_on = simDR_capt_fd_on
    local fo_fd_on = simDR_fo_fd_on
    local autopilot_1_on = simDR_autopilot_1_on
    local autopilot_2_on = simDR_autopilot_2_on
    local capt_altitude = simDR_capt_altitude
    local altitude_hold = simDR_altitude_hold
    local altitude_hold_status = simDR_altitude_hold_status
    local altitude_mode = simDR_altitude_mode
    local autopilot_status_capt = simDR_autopilot_status_capt
    local autopilot_status_fo = simDR_autopilot_status_fo
    local heading_mode = simDR_heading_mode
    local ian_mode = simDR_ian_mode
    local approach_status = simDR_approach_status
    local glideslope_status = simDR_glideslope_status
    local AP1_status = simDR_AP1_status
    local AP2_status = simDR_AP2_status
    local airspeed_bugs = simDR_airspeed_bugs
    local autothrottle_mode = simDR_autothrottle_mode
    local ias_mach_ind = simDR_ias_mach_ind
    local autopilot_speed_set = simDR_autopilot_speed_set
    local mach_captain_ind = simDR_mach_captain_ind
    local vnav_speed_window_open = simDR_vnav_speed_window_open
    local fail_elev_U = simDR_fail_elev_U
    local fail_elev_D = simDR_fail_elev_D
    local fadec_power_mode = simDR_fadec_power_mode_eng
    local throttle_loc_eng = simDR_throttle_loc_eng

    local flight_phase = A333_flight_phase
    local man_pitch_trim_only = A333_man_pitch_trim_only
	local set_green_dot_spd = A333_set_green_dot_spd

    local FD_modes = A333_FD_modes
    local AP_modes = A333_AP_modes
    local row3_speed_ias = A333_row3_speed_ias
    local row3_speed_mach = A333_row3_speed_mach
	local nav_loc_arm_stat = A333_nav_loc_arm_status

    -- SINGLE ENGINE STATUS
    lcl.single_engine_status = (((eng_N2[0] >= 5 and eng_N2[1] < 5) or (eng_N2[0] < 5 and eng_N2[1] >= 5)) and 1) or 0

	if capt_fd_on == 0 and fo_fd_on == 0 then
        FD_modes = 0
	elseif capt_fd_on == 1 and fo_fd_on == 0 then
        FD_modes = 1
	elseif capt_fd_on == 0 and fo_fd_on == 1 then
        FD_modes = 2
	elseif capt_fd_on == 1 and fo_fd_on == 1 then
        FD_modes = 3
	end

	if autopilot_1_on == 0 and autopilot_2_on == 0 then
        AP_modes = 0
	elseif autopilot_1_on == 1 and autopilot_2_on == 0 then
        AP_modes = 1
	elseif autopilot_1_on == 0 and autopilot_2_on == 1 then
        AP_modes = 2
	elseif autopilot_1_on == 1 and autopilot_2_on == 1 then
        AP_modes = 3
	end



    local alt_sel_alt_delta = simDR_altitude_sel - capt_altitude
    A333_climb_descend = ((alt_sel_alt_delta >= 250) and 1) or ((alt_sel_alt_delta <= -250) and -1) or 0


	-- NEW LOGIC 9/26/22:
	-- THIS NEW LOGIC SETS 'ALTITUDE ACQUIRE MODE' (Dataref = A333_alt_star_status).

	-- THE LOGIC PREVENTS 'ALTITUDE ACQUIRE MODE' FROM BEING TURNED ON WHEN
	-- THE AIRCRAFT DEVIATES FROM A PREVIOUSLY 'CAPTURED' ALTITUDE UNTIL THE
	-- HOLD STATUS IS NO LONGER "CAPTURED"

	local altDelta = m.abs(altitude_hold - capt_altitude)

	if altitude_hold_status < 2 then		-- OFF OR ARMED
		lcl.altCaptured = 0

	elseif altitude_hold_status == 2 then	-- CAPTURED
		if lcl.altCaptured == 0 then
			if altDelta <= 20.0 then
				A333_alt_star_status = 0 		-- ALT or ALT CST
				lcl.altCaptured = 1
			else
				A333_alt_star_status = 1		-- ALT* or ALT CST*
			end
		end
	end




	-- VDEF STAR

	if altitude_mode == 8 then										-- TIMER KILLED, REPLACED WITH ABSOLUTE VALUE OF VNAV DOTS PILOT / COPILOT

		if autopilot_status_capt >= 1 then
			if m.abs(simDR_vdef_dots_capt) <= 0.5 then
				lcl.gsCaptured = 1
			end
		elseif autopilot_status_capt == 0 then
			if autopilot_status_fo >= 1 then
				if m.abs(simDR_vdef_dots_fo) <= 0.5 then
					lcl.gsCaptured = 1
				end
			elseif autopilot_status_fo == 0 then
				lcl.gsCaptured = 0
			end
		end

	elseif altitude_mode ~= 8 then
		lcl.gsCaptured = 0
	end

	A333_gs_star_status = lcl.gsCaptured



	-- HDEF STAR
	if heading_mode == 2 then

		if autopilot_status_capt >= 1 then
			if m.abs(simDR_hdef_dots_capt) <= 0.5 then
				lcl.locCaptured = 1
			end
		elseif autopilot_status_capt == 0 then
			if autopilot_status_fo >= 1 then
				if m.abs(simDR_hdef_dots_fo) <= 0.5 then
					lcl.locCaptured = 1
				end
			elseif autopilot_status_fo == 0 then
				lcl.locCaptured = 0
			end
		end

	elseif heading_mode ~= 2 then
		lcl.locCaptured = 0
	end

	A333_loc_star_status = lcl.locCaptured

	-- GA_TRK
    A333_ga_trk_status = ((altitude_mode == 10 and heading_mode == 18) and 1) or 0

    -- ALT ARM CONDITIONS
    A333_alt_arm_status = ((altitude_mode ~= 9 and altitude_mode ~= 20) and 1) or 0

    -- DH/MDA SHOW CONDITIONS
    A333_dh_mda_status = ((flight_phase == 6 or flight_phase == 7) and 1) or 0

    -- FINAL APPROACH STATUS
    A333_final_app_status = (((autopilot_status_capt >= 1 and simDR_gps1_cdi_sense >= 5 and ian_mode == 2 and approach_status == 2 and glideslope_status == 2)
    or (autopilot_status_capt == 0 and autopilot_status_fo >= 1 and simDR_gps2_cdi_sense >= 5 and ian_mode == 2 and approach_status == 2 and glideslope_status == 2))
    and 1) or 0

	-- LANDING CAT
	if approach_status == 2 and ian_mode == 0 then
		if AP1_status == 0 and AP2_status == 0 then
			A333_landing_category_enum = 0
			A333_single_dual_mode = 0
		elseif AP1_status == 1 and AP2_status == 0 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 0
		elseif AP1_status == 0 and AP2_status == 1 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 0
		elseif AP1_status == 1 and AP2_status == 1 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 0
		elseif AP1_status == 2 and AP2_status == 1 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 1
		elseif AP1_status == 1 and AP2_status == 2 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 1
		elseif AP1_status == 2 and AP2_status == 2 then
			A333_landing_category_enum = 3
			A333_single_dual_mode = 2
		elseif AP1_status == 2 and AP2_status == 0 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 1
		elseif AP1_status == 0 and AP2_status == 2 then
			A333_landing_category_enum = 1
			A333_single_dual_mode = 1
		end
	elseif approach_status < 2 or ian_mode > 0 then
		A333_landing_category_enum = 0
		A333_single_dual_mode = 0
	end


	-- MULTI COLUMN FMAS
	if flight_phase <= 5 then
		if autothrottle_mode >= 0 then
			if ias_mach_ind == 0 then
                row3_speed_ias = 1
			elseif ias_mach_ind == 1 then
                row3_speed_ias = 0
			end
		elseif autothrottle_mode < 0 then
            row3_speed_ias = 0
		end
	elseif flight_phase > 5 then
        row3_speed_ias = 0
	end

	if flight_phase <= 6 then
		if autothrottle_mode >= 0 then
			if ias_mach_ind == 1 then
				if m.abs(autopilot_speed_set - mach_captain_ind) < 0.01 then
                    row3_speed_mach = 0
				elseif m.abs(autopilot_speed_set - mach_captain_ind) >= 0.01 then
                    row3_speed_mach = 1
				end
			elseif ias_mach_ind == 0 then
                row3_speed_mach = 0
			end
		elseif autothrottle_mode < 0 then
            row3_speed_mach = 0
		end
	elseif flight_phase > 6 then
        row3_speed_mach = 0
	end

	if row3_speed_ias == 1 or row3_speed_mach == 1 then
		A333_column1_2_divider = 1
	elseif row3_speed_ias == 0 and row3_speed_mach == 0 then
		A333_column1_2_divider = 0
	end

	-- SET GREEN DOT SPEED FMA

	if lcl.single_engine_status == 1 and vnav_speed_window_open == 1 then
		if airspeed_bugs[5] - autopilot_speed_set >= 10 then
			A333_set_green_dot_spd = 1
		elseif airspeed_bugs[5] - autopilot_speed_set <= -10 then
			if altitude_mode ~= 6 then
				A333_set_green_dot_spd = 1
			elseif altitude_mode == 6 then
				A333_set_green_dot_spd = 0
			end
		elseif m.abs(airspeed_bugs[5] - autopilot_speed_set) < 10 then
			A333_set_green_dot_spd = 0
		end
	elseif lcl.single_engine_status == 0 or vnav_speed_window_open == 0 then
		A333_set_green_dot_spd = 0
	end

	-- MAN PITCH TRIM ONLY FMA
	local left_elev_fail = 0
	local right_elev_fail = 0

    if simDR_fail_fcon_elev_lft_lock == 6 or
        simDR_fail_fcon_elev_lft_mxdn == 6 or
        simDR_fail_fcon_elev_lft_mxup == 6 or
        simDR_fail_fcon_elev_lft_cntr == 6 or
        simDR_fail_fcon_elev_lft_gone == 6
    then

        left_elev_fail = 1
    else
        left_elev_fail = 0
    end

	if simDR_fail_fcon_elev_rgt_lock == 6 or
		simDR_fail_fcon_elev_rgt_mxdn == 6 or
		simDR_fail_fcon_elev_rgt_mxup == 6 or
		simDR_fail_fcon_elev_rgt_cntr == 6 or
		simDR_fail_fcon_elev_rgt_gone == 6
    then
		right_elev_fail = 1
	else right_elev_fail = 0
	end

	if fail_elev_U == 6 or fail_elev_D == 6 then
        man_pitch_trim_only = 1
	elseif fail_elev_U ~= 6 and fail_elev_D ~= 6 then
		if left_elev_fail == 1 and right_elev_fail == 1 then
            man_pitch_trim_only = 1
		elseif left_elev_fail == 0 or right_elev_fail == 0 then
            man_pitch_trim_only = 0
		end
	end

	A333_man_pitch_trim_only = man_pitch_trim_only

	if man_pitch_trim_only == 1 or set_green_dot_spd == 1 or simDR_fms_vert_msg_capt >= 1 then
		A333_column2_3_divider_capt = 1
	else A333_column2_3_divider_capt = 0
	end

	if man_pitch_trim_only == 1 or set_green_dot_spd == 1 or simDR_fms_vert_msg_fo >= 1 then
		A333_column2_3_divider_fo = 1
	else A333_column2_3_divider_fo = 0
	end

	-- AUTO THROTTLE FMAS
    A333_man_toga = ((fadec_power_mode[0] == 3 or fadec_power_mode[1] == 3) and 1) or 0
    A333_man_mct = ((fadec_power_mode[0] == 2 or fadec_power_mode[1] == 2) and (1 - lcl.flex_mode)) or 0
    A333_man_flex = ((fadec_power_mode[0] == 2 or fadec_power_mode[1] == 2) and (lcl.flex_mode)) or 0


    -- ADD MAN THR HERE -- DEFER FOR NOW
	if lcl.single_engine_status == 1 then													-- ALL OF THESE NEED TO HAVE AUTOTHROTTLE ACTIVE CONDITION
		if throttle_loc_eng[0] == 2 or throttle_loc_eng[1] == 2 then			-- sim/cockpit2/autopilot/autothrottle_enabled >= 1 (its set in Plane Maker)
			A333_thr_mct = 1
		elseif throttle_loc_eng[0] ~= 2 and throttle_loc_eng[1] ~= 2 then
			A333_thr_mct = 0
		end
	elseif lcl.single_engine_status == 0 then
		A333_thr_mct = 0
	end

	if throttle_loc_eng[0] == 1 or throttle_loc_eng[1] == 1 then
		if throttle_loc_eng[0] <= 1 and throttle_loc_eng[1] <= 1 then
			A333_thr_clb = 1
		elseif throttle_loc_eng[0] > 1 or throttle_loc_eng[1] > 1 then
			A333_thr_clb = 0
		end
	elseif throttle_loc_eng[0] ~= 1 and throttle_loc_eng[1] ~= 1 then
		A333_thr_clb = 0
	end

	if throttle_loc_eng[0] == throttle_loc_eng[1] then

		if throttle_loc_eng[0] == 0 and throttle_loc_eng[1] == 0 and simDR_throttle1_pos > 0.1 and simDR_throttle2_pos > 0.1 then
			A333_thr_lvr = 1
		else
			A333_thr_lvr = 0
		end

	elseif throttle_loc_eng[0] ~= throttle_loc_eng[1] then

		if throttle_loc_eng[0] == 1 then
			if throttle_loc_eng[1] >= 2 then
				A333_thr_lvr = 1
			elseif throttle_loc_eng[1] == 0 then
				A333_thr_lvr = 0
			end
		elseif throttle_loc_eng[1] == 1 then
			if throttle_loc_eng[0] >= 2 then
				A333_thr_lvr = 1
			elseif throttle_loc_eng[0] == 0 then
				A333_thr_lvr = 0
			end
		elseif throttle_loc_eng[0] ~= 1 and throttle_loc_eng[1] ~= 1 then
			A333_thr_lvr = 0
		end

	end
	if autothrottle_mode == 1 then
		A333_thr_lvr = 0
	end


	if lcl.single_engine_status == 0 and autothrottle_mode >= 1 then
		if throttle_loc_eng[0] == throttle_loc_eng[1] then
			A333_lvr_assym = 0
		elseif throttle_loc_eng[0] ~= throttle_loc_eng[1] then				-- CHECK THAT EXACTLY ONE LEVER IS IN ENGINE MODE 0 or 3

			if throttle_loc_eng[0] == 0 or throttle_loc_eng[0] == 3 then
				if throttle_loc_eng[1] == 1 or throttle_loc_eng[1] == 2 then
					A333_lvr_assym = 1
				elseif throttle_loc_eng[1] == 0 or throttle_loc_eng[1] == 3 then
					A333_lvr_assym = 0
				end
			elseif throttle_loc_eng[0] == 1 or throttle_loc_eng[0] == 2 then
				if throttle_loc_eng[1] == 0 or throttle_loc_eng[1] == 3 then
					A333_lvr_assym = 1
				elseif throttle_loc_eng[1] == 1 or throttle_loc_eng[1] == 2 then
					A333_lvr_assym = 0
				end
			end

		end
	elseif lcl.single_engine_status == 1 or autothrottle_mode < 1 then
		A333_lvr_assym = 0
	end


	-- LVR CLB/MCT

	A333_lvr_clb_mct_flasher = A333_set_animation_position(A333_lvr_clb_mct_flasher, pfd_flasher, 0, 1, 10)

	if (simDR_vnav_speed_status == 2 and autothrottle_mode > -1) or autothrottle_mode > 0 then
		if lcl.single_engine_status == 0 then
			if (throttle_loc_eng[0] >= 2 and throttle_loc_eng[1] >= 2) or throttle_loc_eng[0] == 0 or throttle_loc_eng[1] == 0 then
				A333_lvr_clb_status = 1
				A333_lvr_mct_status = 0
			else
				A333_lvr_clb_status = 0
			end
		elseif lcl.single_engine_status == 1 then
			if (throttle_loc_eng[0] == 3 or throttle_loc_eng[1] == 3) or throttle_loc_eng[0] == 0 or throttle_loc_eng[1] == 0 then
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

    A333_FD_modes = FD_modes
    A333_AP_modes = AP_modes
    A333_row3_speed_ias = row3_speed_ias
    A333_row3_speed_mach = row3_speed_mach

	-- NAV LOC ARMED

	if simDR_gpss_status ~= 1 and simDR_nav_status ~= 1 then
		nav_loc_arm_stat = 0
	elseif simDR_gpss_status == 1 and simDR_nav_status ~= 1 then
		if simDR_gps_cdi_sens <= 4 then
			nav_loc_arm_stat = 1
		else nav_loc_arm_stat = 0
		end
	elseif simDR_gpss_status == 0 and simDR_nav_status == 1 then
		nav_loc_arm_stat = 2
	elseif simDR_gpss_status == 1 and simDR_nav_status == 1 then
		if simDR_gps_cdi_sens <= 4 then
			nav_loc_arm_stat = 3
		else nav_loc_arm_stat = 2
		end
	end


	A333_nav_loc_arm_status = nav_loc_arm_stat

	if heading_mode == 13 or heading_mode == 1 then
		A333_alt_crz_heading_mode = 1
	else A333_alt_crz_heading_mode = 0
	end

end


local function A333_reverse_lockout()

	local lockout1 = simDR_reverser_lockout[0]
	local lockout2 = simDR_reverser_lockout[1]

	if simDR_gear_on_ground == 1 or simDR_gear_on_ground_r == 1 then

		if simDR_eng_N2[0] >= 50 then
			lockout1 = 0
		else lockout1 = 2
		end

		if simDR_eng_N2[1] >= 50 then
			lockout2 = 0
		else lockout2 = 2
		end

	else
		lockout1 = 2
		lockout2 = 2
	end

	simDR_reverser_lockout[0] = lockout1
	simDR_reverser_lockout[1] = lockout2

end


local function A333_gps_info_show()

    A333_capt_gps_active_status = ((simDR_gps1_bearing > 0 or simDR_gps1_dme_distance > 0 or simDR_gps1_dme_speed > 0 or simDR_gps1_dme_time > 0) and 1) or 0
    A333_fo_gps_active_status = ((simDR_gps2_bearing > 0 or simDR_gps2_dme_distance > 0 or simDR_gps2_dme_speed > 0 or simDR_gps2_dme_time > 0) and 1) or 0

end




local function A333_sidestick_priority()

    local priority_side = simDR_priority_side

    local capt_pitch_ratio = simDR_capt_pitch_ratio
    local capt_roll_ratio = simDR_capt_roll_ratio
    local fo_pitch_ratio = simDR_fo_pitch_ratio
    local fo_roll_ratio = simDR_fo_roll_ratio

    local capt_zeroed = A333_capt_zeroed
    local fo_zeroed = A333_fo_zeroed
    local dual_input = A333_dual_input

    if priority_side == 0 then
		A333_composite_stick_pitch = rescale(-1, -1, 1, 1, (capt_pitch_ratio + fo_pitch_ratio))
		A333_composite_stick_roll = rescale(-1, -1, 1, 1, (capt_roll_ratio + fo_roll_ratio))
	elseif priority_side == 1 then
		A333_composite_stick_pitch = capt_pitch_ratio
		A333_composite_stick_roll = capt_roll_ratio
	elseif priority_side == 2 then
		A333_composite_stick_pitch = fo_pitch_ratio
		A333_composite_stick_roll = fo_roll_ratio
	end


	-- SIDESTICK DUAL INPUT
	if m.abs(capt_pitch_ratio) < 0.125 and m.abs(capt_roll_ratio) < 0.1 then
        capt_zeroed = 1
	elseif m.abs(capt_pitch_ratio) >= 0.125 or m.abs(capt_roll_ratio) >= 0.1 then
        capt_zeroed = 0
	end

	if m.abs(fo_pitch_ratio) < 0.125 and m.abs(fo_roll_ratio) < 0.1 then
        fo_zeroed = 1
	elseif m.abs(fo_pitch_ratio) >= 0.125 or m.abs(fo_roll_ratio) >= 0.1 then
        fo_zeroed = 0
	end

	if capt_zeroed == 0 and fo_zeroed == 0 then
		if priority_side == 0 then
            dual_input = 1
		else
            dual_input = 0
		end
	else
        dual_input = 0
	end


	-- SIDESTICK PRIORITY (RED ARROW ANNUN LIGHT)
	if priority_side == 1 then
		A333_capt_priority_arrow = 0
		A333_fo_priority_arrow = 1
	elseif priority_side == 2 then
		A333_capt_priority_arrow = 1
		A333_fo_priority_arrow = 0
	elseif priority_side == 0 then
		A333_capt_priority_arrow = 0
		A333_fo_priority_arrow = 0
	end


	-- SIDESTICK PRIORITY (CAPT/FO GREEN LIGHT)
	if priority_side == 0 then
		if dual_input == 1 then
			A333_capt_priority_light = 1
			A333_fo_priority_light = 1
		elseif dual_input == 0 then
			A333_capt_priority_light = 0
			A333_fo_priority_light = 0
		end
	elseif priority_side == 1 then
		A333_fo_priority_light = 0
		if fo_zeroed == 0 then
			A333_capt_priority_light = 1
		elseif fo_zeroed == 1 then
			A333_capt_priority_light = 0
		end
	elseif priority_side == 2 then
		A333_capt_priority_light = 0
		if capt_zeroed == 0 then
			A333_fo_priority_light = 1
		elseif capt_zeroed == 1 then
			A333_fo_priority_light = 0
		end
	end

    A333_capt_zeroed = capt_zeroed
    A333_dual_input = dual_input

end



local function A333_baro_warning_brightness()

    local time = m.fmod(simDR_flight_time, 1.0)
    local barometer_setting_warn_pilot = simDR_barometer_setting_warn_pilot
	local barometer_setting_warn_copilot = simDR_barometer_setting_warn_copilot

    local bright = ((barometer_setting_warn_pilot == 1 or barometer_setting_warn_pilot == 1)
        and (time > 0.5 and time <= 1.0))
        
	local bright_fo = ((barometer_setting_warn_copilot == 1 or barometer_setting_warn_copilot == 1)
        and (time > 0.5 and time <= 1.0))

    A333DR_baro_warning_brightness = bool2num[bright]
	A333DR_baro_warning_brightness_fo = bool2num[bright_fo]

end




----- ND NAV RAD FREQ ID ----------------------------------------------------------------
local function A333_ND_nav_rad_ID()

    local nav_type = simDR_nav_type

	-- VOR RADIOS
	local vor1ID_is_valid = #simDR_nav1_ID > 0 and nav_type[2] == 4
	local dme1ID_is_valid = #simDR_dme1_ID > 0 and nav_type[2] == 1024

	local vor2ID_is_valid = #simDR_nav2_ID > 0 and nav_type[3] == 4
	local dme2ID_is_valid = #simDR_dme2_ID > 0 and nav_type[3] == 1024

	A333_nd_vor1_ID_flag_capt = bool2num[vor1ID_is_valid or dme1ID_is_valid]
	A333_nd_vor2_ID_flag_capt = bool2num[vor2ID_is_valid or dme2ID_is_valid]


	-- ADF RADIOS
	A333_nd_adf1_ID_flag_capt = bool2num[#simDR_adf1_ID > 0]
	A333_nd_adf2_ID_flag_capt = bool2num[#simDR_adf2_ID > 0]

end


local function A333_TCAS_flasher_ND()

	local sim_time_factor = m.fmod(simDR_flight_time, 0.6)
    local flasher = ((sim_time_factor >= 0.1 and sim_time_factor <= 0.4) and 1) or 0

    lcl.tcas_timer = (simDR_tcas_fail == 6 and (lcl.tcas_timer + lcl_SIM_PERIOD)) or 0

	local flasher2 = (((lcl.tcas_timer <= 9 and lcl.tcas_timer ~= 0) and flasher) or 1)

	lcl.tcas_flasher = A333_set_animation_position(lcl.tcas_flasher, flasher2, 0, 1, 10)
	A333_TCAS_flasher = lcl.tcas_flasher

end

local function A333_map_range_ring_hide()

	if A333DR_adiru1_hdg_status == 1 then
		A333_range_ring_flag_capt = A333DR_adiru1_lrn_status
	elseif A333DR_adiru1_hdg_status == 0 then
		A333_range_ring_flag_capt = 0
	end

	if A333DR_adiru2_hdg_status == 1 then
		A333_range_ring_flag_fo = A333DR_adiru2_lrn_status
	elseif A333DR_adiru2_hdg_status == 0 then
		A333_range_ring_flag_fo = 0
	end

end

local function A333_GPWS_fault_lights()

	local lrn_avail = ((A333DR_adiru1_lrn_status == 1 or A333DR_adiru2_lrn_status == 1) and 2) or 1

	A333_gpws_sys_state = A333DR_ac_bus1_has_power * A333_gpws_sys_status * lrn_avail			-- 0 = alerts off, 1 = powered/no valid GPS, 2 = ready
	A333_gpws_terr_state = A333DR_ac_bus1_has_power * A333_gpws_terr_status * lrn_avail

end

local function A333_g_load()



	if A333_flight_phase >= 3 then

		if simDR_gforce_normal >= 1.4 or simDR_gforce_normal <= 0.7 then
			A333_ECAM_g_load_timer = A333_ECAM_g_load_timer + lcl_SIM_PERIOD
		else A333_ECAM_g_load_timer = 0
		end
	
		if A333_ECAM_g_load_timer >= 2 then
			A333_ECAM_g_load_state = 1
		end
	
		if A333_ECAM_g_load_state == 1 and A333_ECAM_g_load_timer == 0 then
			A333_ECAM_g_load_state = 2
		end
	
		if A333_ECAM_g_load_state == 2 then
			A333_ECAM_g_load_timer2 = A333_ECAM_g_load_timer2 + lcl_SIM_PERIOD
		end
	
		if A333_ECAM_g_load_timer2 > 5 then
			A333_ECAM_g_load_state = 0
			A333_ECAM_g_load_timer2 = 0
		end

	else A333_ECAM_g_load_state = 0
	end

end

local function A333_bus_load_injection()

	simDR_plugin_bus_amps[1] = A333DR_lighting_power_ac1 + A333DR_hydraulic_power_ac1
	simDR_plugin_bus_amps[2] = A333DR_lighting_power_ac2 + A333DR_hydraulic_power_ac2 + A333DR_fadec_power_ac2
	simDR_plugin_bus_amps[3] = A333DR_lighting_power_ac_ess + A333DR_fadec_power_ac_ess

end


----- SET STATE FOR ALL MODES -----------------------------------------------------------
local function A333_set_systems_all_modes()

	A333DR_init_systems_CD = 0
	simDR_center_pack = 0
	A333_elt_switch_pos = 0
	lcl.elt_annun = 0
	simDR_number_plugged_in_o2 = 2

	simDR_door1L = 4.5
	simDR_door2L = 4.5
	simDR_door3L = 4.5
	simDR_door4L = 4.5
	simDR_door1R = 4.5
	simDR_door2R = 4.5
	simDR_door3R = 4.5
	simDR_door4R = 4.5
	simDR_doorC1 = 45 -- default hand pump time, get's bounced to 15 when the elec pump is on
	simDR_doorC2 = 45 -- default hand pump time, get's bounced to 15 when the elec pump is on
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
local function A333_set_systems_CD()


end




----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
local function A333_set_systems_ER()

	lcl.idle_timer = 10
	lcl.eng1_avail_timer = 10
	lcl.eng2_avail_timer = 10

end




----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
local function A333_systems_monitor_AI()

    if A333DR_init_systems_CD == 1 then
        A333_set_systems_all_modes()
        A333_set_systems_CD()
        A333DR_init_systems_CD = 2
    end

end




----- FLIGHT START ---------------------------------------------------------------------
local function A333_flight_start_systems()

    STARTER_TORQUE_PLN_VALUE = simDR_starter_torque


	-- ALL MODES ------------------------------------------------------------------------
	A333_set_systems_all_modes()

	A333_cockpit_temp_ind = simDR_TAT + rescale(-30, 35, 30, 5, simDR_TAT) + lcl.cockpit_random_fac
	A333_cabin_fwd_temp_ind = simDR_TAT + rescale(-30, 35, 30, 5, simDR_TAT) + lcl.cabin_fwd_random_fac
	A333_cabin_mid_temp_ind = simDR_TAT + rescale(-30, 35, 30, 5, simDR_TAT) + lcl.cabin_mid_random_fac
	A333_cabin_aft_temp_ind = simDR_TAT + rescale(-30, 35, 30, 5, simDR_TAT) + lcl.cabin_aft_random_fac
	A333_cargo_temp_ind = simDR_TAT + rescale(-30, 25, 30, 5, simDR_TAT) + lcl.cargo_random_fac
	A333_bulk_cargo_temp_ind = simDR_TAT + rescale(-30, 20, 30, 5, simDR_TAT) + lcl.cargo_bulk_random_fac

	A333_bulk_duct_temp = A333_bulk_cargo_temp_ind + 3

	lcl.compensated_TAT_left = simDR_TAT
	lcl.compensated_TAT_right = simDR_TAT

	A333_precooler1_temp = simDR_TAT
	A333_precooler2_temp = simDR_TAT
	A333_pack1_compressor_outlet_temp = simDR_TAT + 5
	A333_pack2_compressor_outlet_temp = simDR_TAT + 5
	A333_pack1_outlet_temp = simDR_TAT + 4
	A333_pack2_outlet_temp = simDR_TAT + 4

	A333_laminar_no_ref = 0
	A333_ECAM_gen1_hertz = 400
	A333_ECAM_gen2_hertz = 400

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
local function A333_ALL_systems()

    lcl_SIM_PERIOD = SIM_PERIOD

    A333_systems_monitor_AI()
    --A333_generator_line_contactor()
	A333_duct_isol_valves()
	A333_pack_flow()
	A333_fuel_system()
	A333_elt()
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
	A333_brake_tap()
	A333_ecam_page_CAB_PRESS()
	A333_ecam_page_BLEED()
	A333_ecam_page_COND()
	A333_FPV_calculations()
	A333_flight_directors()
	A333_DH_flashers()
	A333_InstrumentVisibility()
	A333_ND_nav_rad_ID()
	A333_gps_info_show()
	A333_fuel_totalizer_reset()
	A333_throttle_pos_ind()
	A333_vspeeds()
	A333_ground_timer()
	A333_idle_mode_logic()
	A333_sidestick_priority()
    A333_baro_warning_brightness()
	A333_landing_alt()
	A333_depress_open_doors()
	A333_leak_measurement_lockout()
	A333_reverse_lockout()
	A333_bus_load_injection()
	A333_TCAS_flasher_ND()
	A333_GPWS_fault_lights()
	A333_g_load()
	
end

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

	A333_flight_start_systems()

end

--function flight_crash() end

function before_physics()

	A333_map_range_ring_hide()
	A333_FMAs()
	A333_PFD_indicators()

end

function after_physics()

	A333_ALL_systems()

end

function after_replay()

	A333_ALL_systems()
	A333_map_range_ring_hide()
	A333_FMAs()
	A333_PFD_indicators()
	
end