jit.off()
--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws110.lua
* Process: FWS Sim & Custom Datarefs
*
* Author Name :	Jim Gregory
*
* Revisions:
* -- DATE --  --- REV NO ---  --- DESCRIPTION -------------------------------------------
* 10/09/2025   AG330 v1.2.0   add ADRALGN variable for ADIRS ALIGN EWD MSG
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


--print("LOAD: A333.ecam_fws110.lua")

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



--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_startup_running					= find_dataref("sim/operation/prefs/startup_running")

simDR_position_y_agl					= find_dataref("sim/flightmodel2/position/y_agl")

simDR_bus_volts							= find_dataref("sim/cockpit2/electrical/bus_volts")
simDR_gpu_on							= find_dataref("sim/cockpit/electrical/gpu_on")

simDR_engines_running					= find_dataref("sim/flightmodel/engine/ENGN_running")
simDR_throttle_ratio					= find_dataref("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio")
simDR_indicated_airspeed				= find_dataref("sim/flightmodel/position/indicated_airspeed")
simDR_gear_on_ground					= find_dataref("sim/flightmodel2/gear/on_ground")
simDR_gear_deploy_ratio					= find_dataref("sim/flightmodel2/gear/deploy_ratio")
simDR_gear_handle_animation				= find_dataref("sim/cockpit2/controls/gear_handle_animation") 	-- 0=UP, 1=DOWN

--simDR_control_flap_ratio 				=  find_dataref("sim/cockpit2/controls/flap_ratio")
--simDR_control_flap_ratio 				=  find_dataref("sim/flightmodel2/controls/flap_handle_deploy_ratio")
simDR_control_flap_ratio 				=  find_dataref("sim/cockpit2/controls/flap_system_deploy_ratio")

simDR_tire_deflection_mtr 				=  find_dataref("sim/flightmodel2/gear/tire_vertical_deflection_mtr")

simDR_radio_alt_ht_pilot 				=  find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
simDR_radio_alt_ht_copilot				=  find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_copilot")
simDR_radio_alt_pilot_fail 				=  find_dataref("sim/operation/failures/rel_pil_radalt")
simDR_radio_alt_copilot_fail 			=  find_dataref("sim/operation/failures/rel_cop_radalt")
simDR_radio_altimeter_bug_ft_pilot 		=  find_dataref("sim/cockpit2/gauges/actuators/radio_altimeter_bug_ft_pilot")
simDR_radio_altimeter_bug_ft_copilot 	=  find_dataref("sim/cockpit2/gauges/actuators/radio_altimeter_bug_ft_copilot")

simDR_baro_alt_ft_pilot 				=  find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
simDR_baro_alt_ft_copilot 				=  find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_copilot")
simDR_baro_alt_ft_stby 					=  find_dataref("sim/cockpit2/gauges/indicators/altitude_ft_stby")
simDR_baro_alt_bug_ft_pilot 			=  find_dataref("sim/cockpit2/gauges/actuators/baro_altimeter_bug_ft_pilot")
simDR_baro_alt_bug_ft_copilot 			=  find_dataref("sim/cockpit2/gauges/actuators/baro_altimeter_bug_ft_copilot")

simDR_pressure_altitude					= find_dataref("sim/flightmodel2/position/pressure_altitude")

simDR_cabin_altitude_indicator_ft		= find_dataref("sim/cockpit2/pressurization/indicators/cabin_altitude_ft")
simDR_cabin_altitude_actuator_ft		= find_dataref("sim/cockpit2/pressurization/actuators/cabin_altitude_ft")

simDR_engine_n1_pct 					=  find_dataref("sim/flightmodel2/engines/N1_percent")

simDR_airspeed_kts_pilot 				=  find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
simDR_airspeed_kts_copilot 				=  find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_copilot")
simDR_airspeed_kts_stby 				=  find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_stby")
simDR_airspeed_fail_pilot 				=  find_dataref("sim/operation/failures/rel_ss_asi")
simDR_airspeed_fail_copilot 			=  find_dataref("sim/operation/failures/rel_cop_asi")

simDR_cas_kts_pilot 					=  find_dataref("sim/cockpit2/gauges/indicators/calibrated_airspeed_kts_pilot")
simDR_cas_kts_copilot 					=  find_dataref("sim/cockpit2/gauges/indicators/calibrated_airspeed_kts_copilot")
simDR_cas_kts_stby 						=  find_dataref("sim/cockpit2/gauges/indicators/calibrated_airspeed_kts_stby")

simDR_vvi_pilot							=  find_dataref("sim/cockpit2/gauges/indicators/vvi_fpm_pilot")

simDR_engine_fire						=  find_dataref("sim/flightmodel2/engines/is_on_fire")

simDR_apu_fail							=  find_dataref("sim/operation/failures/rel_apu")
simDR_apu_fire							=  find_dataref("sim/operation/failures/rel_apu_fire")

simDR_yoke_pitch_ratio_pilot			=  find_dataref("sim/cockpit2/controls/yoke_pitch_ratio")
simDR_yoke_roll_ratio_pilot				=  find_dataref("sim/cockpit2/controls/yoke_roll_ratio")

simDR_yoke_pitch_ratio_copilot			=  find_dataref("sim/cockpit2/controls/yoke_pitch_ratio_copilot")
simDR_yoke_roll_ratio_copilot			=  find_dataref("sim/cockpit2/controls/yoke_roll_ratio_copilot")

simDR_engine_starter_is_running			=  find_dataref("sim/flightmodel2/engines/starter_is_running")
simDR_APU_switch_mode					=  find_dataref("sim/cockpit/engine/APU_switch") 					-- 0 = off, 1 = on, 2 = start
simDR_APU_n1_pct						=  find_dataref("sim/cockpit/engine/APU_N1")

simDR_rudder1_deg						=  find_dataref("sim/flightmodel2/wing/rudder1_deg")


simDR_flap1_deg 						= find_dataref('sim/flightmodel2/wing/flap1_deg')
simDR_flap2_deg 						= find_dataref('sim/flightmodel2/wing/flap2_deg')

simDR_slat1_deploy_rat					=  find_dataref("sim/flightmodel2/controls/slat1_deploy_ratio")
simDR_slat2_deploy_rat					=  find_dataref("sim/flightmodel2/controls/slat2_deploy_ratio")

simDR_stall_warning						=  find_dataref("sim/cockpit2/annunciators/stall_warning")

simDR_ap_flight_director_mode 			=  find_dataref("sim/cockpit2/autopilot/flight_director_mode")
simDR_ap_flight_director2_mode 			=  find_dataref("sim/cockpit2/autopilot/flight_director2_mode")
simDR_ap_autothrottle_on				=  find_dataref("sim/cockpit2/autopilot/autothrottle_on")
simDR_ap_approach_status				=  find_dataref("sim/cockpit2/autopilot/approach_status") -- 1 = armed, 2 = captured
simDR_ap_servos_on 						=  find_dataref("sim/cockpit2/autopilot/servos_on")
simDR_ap_servos2_on 					=  find_dataref("sim/cockpit2/autopilot/servos2_on")

simDR_windshear_warning					=  find_dataref("sim/cockpit2/annunciators/windshear_warning")
simDR_airbus_speed_warn_thro_0 			= find_dataref('sim/flightmodel2/controls/airbus_speed_warn_thro_0')	-- ALPHA FLOOR ACTIVATION ENGINE 1
simDR_airbus_speed_warn_thro_1 			= find_dataref('sim/flightmodel2/controls/airbus_speed_warn_thro_1')	-- ALPHA FLOOR ACTIVATION ENGINE 2

simDR_battery_on						= find_dataref("sim/cockpit2/electrical/battery_on")

simDR_park_brake		 				= find_dataref("sim/cockpit2/controls/parking_brake_ratio")

simDR_flap_handle_ratio					= find_dataref("sim/cockpit2/controls/flap_handle_deploy_ratio")

simDR_gear_retract_fail_1				= find_dataref("sim/operation/failures/rel_lagear1")
simDR_gear_retract_fail_2				= find_dataref("sim/operation/failures/rel_lagear2")
simDR_gear_retract_fail_3				= find_dataref("sim/operation/failures/rel_lagear3")
simDR_gear_retract_fail_4				= find_dataref("sim/operation/failures/rel_lagear4")
simDR_gear_retract_fail_5				= find_dataref("sim/operation/failures/rel_lagear5")

simDR_engine_oil_pressure_psi			= find_dataref("sim/cockpit2/engine/indicators/oil_pressure_psi")
simDR_engine_oil_temp_degC				= find_dataref("sim/cockpit2/engine/indicators/oil_temperature_deg_C")

simDR_engine_oil_temp_c					= find_dataref("sim/flightmodel/engine/ENGN_oil_temp_c")

simDR_starter_mode						= find_dataref("sim/cockpit2/engine/actuators/eng_mode_selector")
simDR_engine1_igniter					= find_dataref("sim/cockpit2/engine/actuators/igniter_on")

simDR_pack1								= find_dataref("sim/cockpit2/bleedair/actuators/pack_left")
simDR_pack2								= find_dataref("sim/cockpit2/bleedair/actuators/pack_right")


simDR_engine_reverse_deploy_ratio		= find_dataref("sim/flightmodel2/engines/thrust_reverser_deploy_ratio")
simDR_engine1_reverse_fail				= find_dataref("sim/operation/failures/rel_revers0")
simDR_engine2_reverse_fail				= find_dataref("sim/operation/failures/rel_revers1")

simDR_fuel_left_wing					= find_dataref("sim/cockpit2/fuel/fuel_quantity[0]")			-- kgs
simDR_fuel_right_wing					= find_dataref("sim/cockpit2/fuel/fuel_quantity[2]")

simDR_elec_gen1_fail					= find_dataref("sim/operation/failures/rel_genera0")
simDR_elec_gen2_fail					= find_dataref("sim/operation/failures/rel_genera1")

simDR_generator_on						= find_dataref("sim/cockpit2/electrical/generator_on")

simDR_rat_on							= find_dataref("sim/cockpit2/hydraulics/actuators/ram_air_turbine_on")

simDR_hvac_fail							= find_dataref("sim/operation/failures/rel_HVAC")


simDR_blue_hydraulic_pressure			= find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_3")
simDR_yellow_hydraulic_pressure			= find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_2")
simDR_green_hydraulic_pressure			= find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1")

simDR_elec_hydraulic_green_on			= find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump_on")
simDR_elec_hydraulic_blue_on			= find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump2_on")
simDR_elec_hydraulic_yellow_on			= find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump3_on")

simDR_green_fluid_ratio					= find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_fluid_ratio_1")
simDR_blue_fluid_ratio					= find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_fluid_ratio_3")
simDR_yellow_fluid_ratio				= find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_fluid_ratio_2")

A333_engine1_pump_green_pos				= find_dataref("laminar/A330/buttons/hyd/eng1_pump_green_pos")
A333_engine1_pump_blue_pos				= find_dataref("laminar/A330/buttons/hyd/eng1_pump_blue_pos")
A333_engine2_pump_yellow_pos			= find_dataref("laminar/A330/buttons/hyd/eng2_pump_yellow_pos")
A333_engine2_pump_green_pos				= find_dataref("laminar/A330/buttons/hyd/eng2_pump_green_pos")

simDR_auto_brake						= find_dataref("sim/cockpit2/switches/auto_brake_level")

simDR_switch_no_smoking					= find_dataref("sim/cockpit/switches/no_smoking")
simDR_switch_seat_belt					= find_dataref("sim/cockpit2/switches/fasten_seat_belts")

simDR_brake_fan							= find_dataref("sim/cockpit2/controls/brake_fan_on")

simDR_rudder_trim_ratio 				= find_dataref("sim/flightmodel2/controls/rudder_trim")
simDR_elev_trim_ratio 					= find_dataref("sim/flightmodel2/controls/elevator_trim")
simDR_stab_deflection_deg				= find_dataref("sim/flightmodel2/controls/stabilizer_deflection_degrees")
simDR_ctrl_speed_brk_ratio				= find_dataref("sim/cockpit2/controls/speedbrake_ratio")

simDR_door_open_ratio					= find_dataref("sim/flightmodel2/misc/door_open_ratio")

simDR_engine_oil_temp_c					= find_dataref("sim/flightmodel/engine/ENGN_oil_temp_c")



simDR_flap_act_failure					= find_dataref("sim/operation/failures/rel_flap_act")
simDR_flap_1_lft_lock					= find_dataref("sim/operation/failures/rel_fcon_flap_1_lft_lock")
simDR_flap_1_rgt_lock					= find_dataref("sim/operation/failures/rel_fcon_flap_1_rgt_lock")
simDR_flap_2_lft_lock					= find_dataref("sim/operation/failures/rel_fcon_flap_2_lft_lock")
simDR_flap_2_rgt_lock					= find_dataref("sim/operation/failures/rel_fcon_flap_2_rgt_lock")

simDR_pos_y_agl 						= find_dataref("sim/flightmodel2/position/y_agl")				-- METERS, FT = * 3.28084

simDR_igniter_on 						= find_dataref("sim/cockpit2/annunciators/igniter_on")

simDR_tire_radius 						= find_dataref("sim/flightmodel2/gear/tire_radius_mtrs")					-- [10]
simDR_tire_rot_speed_rad_sec 			= find_dataref("sim/flightmodel2/gear/tire_rotation_speed_rad_sec")

simDR_throttle_jet_rev_ratio 			= find_dataref("sim/cockpit2/engine/actuators/throttle_jet_rev_ratio")
simDR_throttle_beta_rev_ratio 			= find_dataref("sim/cockpit2/engine/actuators/throttle_beta_rev_ratio")

simDR_fail_rel_ignitr0 					= find_dataref("sim/operation/failures/rel_ignitr0")
simDR_fail_rel_ignitr1 					= find_dataref("sim/operation/failures/rel_ignitr1")

simDR_tank_pump_psi						= find_dataref("sim/cockpit2/fuel/tank_pump_pressure_psi")
simDR_fuel_tank_pump_on					= find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on")

simDR_engine1_anti_ice_fail				= find_dataref("sim/operation/failures/rel_ice_inlet_heat")
simDR_engine2_anti_ice_fail				= find_dataref("sim/operation/failures/rel_ice_inlet_heat2")
simDR_engine_anti_ice 					= find_dataref("sim/cockpit/switches/anti_ice_inlet_heat_per_engine")
simDR_ice_per_engine					= find_dataref("sim/flightmodel/failures/inlet_ice_per_engine")
simDR_wing_surface_heat					= find_dataref("sim/cockpit2/ice/ice_surfce_heat_on")
simDR_wing_heat_left					= find_dataref("sim/cockpit2/ice/ice_surface_hot_bleed_air_left_on")
simDR_wing_heat_right					= find_dataref("sim/cockpit2/ice/ice_surface_hot_bleed_air_right_on")
simDR_wing_heat_fault_left				= find_dataref("sim/operation/failures/rel_ice_surf_heat")
simDR_wing_heat_fault_right				= find_dataref("sim/operation/failures/rel_ice_surf_heat2")

simDR_fail_servo_ailn					= find_dataref("sim/operation/failures/rel_servo_ailn")

simDR_fail_ail_L						= find_dataref("sim/operation/failures/rel_ail_L")
simDR_fail_ail_L1						= find_dataref("sim/operation/failures/rel_ail_L1")
simDR_fail_ail_L2						= find_dataref("sim/operation/failures/rel_ail_L2")
simDR_fail_ail_L_jam					= find_dataref("sim/operation/failures/rel_ail_L_jam")
simDR_fail_fcon_ailn_1_lft_lock			= find_dataref("sim/operation/failures/rel_fcon_ailn_1_lft_lock")
simDR_fail_fcon_ailn_2_lft_lock			= find_dataref("sim/operation/failures/rel_fcon_ailn_2_lft_lock")
simDR_fail_fcon_ailn_1_lft_mxdn			= find_dataref("sim/operation/failures/rel_fcon_ailn_1_lft_mxdn")
simDR_fail_fcon_ailn_2_lft_mxdn			= find_dataref("sim/operation/failures/rel_fcon_ailn_2_lft_mxdn")
simDR_fail_fcon_ailn_1_lft_mxup			= find_dataref("sim/operation/failures/rel_fcon_ailn_1_lft_mxup")
simDR_fail_fcon_ailn_2_lft_mxup			= find_dataref("sim/operation/failures/rel_fcon_ailn_2_lft_mxup")
simDR_fail_fcon_ailn_1_lft_cntr			= find_dataref("sim/operation/failures/rel_fcon_ailn_1_lft_cntr")
simDR_fail_fcon_ailn_2_lft_cntr			= find_dataref("sim/operation/failures/rel_fcon_ailn_2_lft_cntr")
simDR_fail_fcon_ailn_1_lft_gone			= find_dataref("sim/operation/failures/rel_fcon_ailn_1_lft_gone")
simDR_fail_fcon_ailn_2_lft_gone			= find_dataref("sim/operation/failures/rel_fcon_ailn_2_lft_gone")

simDR_fail_ail_R						= find_dataref("sim/operation/failures/rel_ail_R")
simDR_fail_ail_R1						= find_dataref("sim/operation/failures/rel_ail_R1")
simDR_fail_ail_R2						= find_dataref("sim/operation/failures/rel_ail_R2")
simDR_fail_ail_R_jam					= find_dataref("sim/operation/failures/rel_ail_R_jam")
simDR_fail_fcon_ailn_1_rgt_lock			= find_dataref("sim/operation/failures/rel_fcon_ailn_1_rgt_lock")
simDR_fail_fcon_ailn_2_rgt_lock			= find_dataref("sim/operation/failures/rel_fcon_ailn_2_rgt_lock")
simDR_fail_fcon_ailn_1_rgt_mxdn			= find_dataref("sim/operation/failures/rel_fcon_ailn_1_rgt_mxdn")
simDR_fail_fcon_ailn_2_rgt_mxdn			= find_dataref("sim/operation/failures/rel_fcon_ailn_2_rgt_mxdn")
simDR_fail_fcon_ailn_1_rgt_mxup			= find_dataref("sim/operation/failures/rel_fcon_ailn_1_rgt_mxup")
simDR_fail_fcon_ailn_2_rgt_mxup			= find_dataref("sim/operation/failures/rel_fcon_ailn_2_rgt_mxup")
simDR_fail_fcon_ailn_1_rgt_cntr			= find_dataref("sim/operation/failures/rel_fcon_ailn_1_rgt_cntr")
simDR_fail_fcon_ailn_2_rgt_cntr			= find_dataref("sim/operation/failures/rel_fcon_ailn_2_rgt_cntr")
simDR_fail_fcon_ailn_1_rgt_gone			= find_dataref("sim/operation/failures/rel_fcon_ailn_1_rgt_gone")
simDR_fail_fcon_ailn_2_rgt_gone			= find_dataref("sim/operation/failures/rel_fcon_ailn_2_rgt_gone")

simDR_ESS_bus_assign					= find_dataref("sim/aircraft/electrical/essential_ties")

simDR_fail_battery1						= find_dataref("sim/operation/failures/rel_batter0")
simDR_fail_battery2						= find_dataref("sim/operation/failures/rel_batter1")

simDR_bleedair_pack1					= find_dataref("sim/cockpit2/bleedair/actuators/pack_left")
simDR_bleedair_pack2					= find_dataref("sim/cockpit2/bleedair/actuators/pack_right")

simDR_eng1_hung_start					= find_dataref("sim/operation/failures/rel_hunsta0")
simDR_eng2_hung_start					= find_dataref("sim/operation/failures/rel_hunsta1")

simDR_plugin_master_warning				= find_dataref("sim/cockpit2/annunciators/plugin_master_warning") 		-- Write 1 to trigger master warning
simDR_plugin_master_caution				= find_dataref("sim/cockpit2/annunciators/plugin_master_caution")		-- Write 1 to trigger master caution

simDR_master_caution_anunn				= find_dataref("sim/cockpit2/annunciators/master_caution")
simDR_master_warning_anunn				= find_dataref("sim/cockpit2/annunciators/master_warning")

simDR_CONF_sel 							= find_dataref('sim/cockpit2/controls/flap_config')

simDR_priority_side						= find_dataref("sim/joystick/priority_side") -- 0 = Normal, 1 = Priority Left, 2 = Priority Right

simDR_gs_annun 							= find_dataref("sim/cockpit/warnings/annunciators/glideslope")

simDR_fms_landing_flap_config			= find_dataref("sim/cockpit2/gauges/indicators/landing_config_flap")

simDR_barometer_setting_is_std_pilot	= find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_is_std_pilot")
simDR_barometer_setting_is_std_copilot	= find_dataref("sim/cockpit2/gauges/actuators/barometer_setting_is_std_copilot")

simDR_flex_temp							= find_dataref("sim/flightmodel/engine/ENGN_assumed_temp")

simDR_engine_throttle_used_ratio		= find_dataref('sim/flightmodel2/engines/throttle_used_ratio')

simDR_company_msg						= find_dataref('sim/atc/company_msg')




--*************************************************************************************--
--** 				             FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

--clear_master_warning = find_command("sim/annunciator/clear_master_warning")
--clear_master_caution = find_command("sim/annunciator/clear_master_caution")


--*************************************************************************************--
--** 				             FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

A333_eng1_fire_handle_pos				= find_dataref("laminar/A333/fire/switches/eng1_handle")
A333_eng2_fire_handle_pos				= find_dataref("laminar/A333/fire/switches/eng2_handle")
A333_eng1_agent1_pos					= find_dataref("laminar/A333/fire/buttons/eng1_agent1_pos")
A333_eng1_agent2_pos					= find_dataref("laminar/A333/fire/buttons/eng1_agent2_pos")
A333_switches_engine1_start_pos			= find_dataref("laminar/A333/switches/engine1_start_pos")
A333_switches_engine2_start_pos			= find_dataref("laminar/A333/switches/engine2_start_pos")
A333_switches_engine1_start_lift		= find_dataref("laminar/A333/switches/engine1_start_lift")
A333_switches_engine2_start_lift		= find_dataref("laminar/A333/switches/engine2_start_lift")
A333_eng1_agent1_psi					= find_dataref("laminar/A333/fire/status/eng1_agent1_psi")
A333_eng1_agent2_psi					= find_dataref("laminar/A333/fire/status/eng1_agent2_psi")
A333_eng2_agent1_psi					= find_dataref("laminar/A333/fire/status/eng2_agent1_psi")
A333_eng2_agent2_psi					= find_dataref("laminar/A333/fire/status/eng2_agent2_psi")

A333_ecam_button_eng_pos				= find_dataref("laminar/A333/buttons/ecam/eng_pos")
A333_ecam_button_bleed_pos				= find_dataref("laminar/A333/buttons/ecam/bleed_pos")
A333_ecam_button_press_pos				= find_dataref("laminar/A333/buttons/ecam/press_pos")
A333_ecam_button_el_ac_pos				= find_dataref("laminar/A333/buttons/ecam/el_ac_pos")
A333_ecam_button_el_dc_pos				= find_dataref("laminar/A333/buttons/ecam/el_dc_pos")
A333_ecam_button_hyd_pos				= find_dataref("laminar/A333/buttons/ecam/hyd_pos")
A333_ecam_button_cbs_pos				= find_dataref("laminar/A333/buttons/ecam/cbs_pos")
A333_ecam_button_apu_pos				= find_dataref("laminar/A333/buttons/ecam/apu_pos")
A333_ecam_button_cond_pos				= find_dataref("laminar/A333/buttons/ecam/cond_pos")
A333_ecam_button_door_pos				= find_dataref("laminar/A333/buttons/ecam/door_pos")
A333_ecam_button_wheel_pos				= find_dataref("laminar/A333/buttons/ecam/wheel_pos")
A333_ecam_button_f_ctl_pos				= find_dataref("laminar/A333/buttons/ecam/f_ctl_pos")
A333_ecam_button_fuel_pos				= find_dataref("laminar/A333/buttons/ecam/fuel_pos")
A333_ecam_button_all_pos				= find_dataref("laminar/A333/buttons/ecam/all_pos")

A333_ecam_button_to_config_pos			= find_dataref("laminar/A333/buttons/ecam/to_config_pos")
A333_ecam_button_clr_capt_pos			= find_dataref("laminar/A333/buttons/ecam/clr_capt_pos")
A333_ecam_button_clr_fo_pos				= find_dataref("laminar/A333/buttons/ecam/clr_fo_pos")
A333_ecam_button_sts_pos				= find_dataref("laminar/A333/buttons/ecam/sts_pos")
A333_ecam_button_rcl_pos				= find_dataref("laminar/A333/buttons/ecam/rcl_pos")
A333_ecam_button_emer_cancel_pos		= find_dataref("laminar/A333/buttons/ecam/emer_cancel_pos")

A333DR_ecp_pushbutton_process_step 		= find_dataref("laminar/A333/ecp/pb_process_step")

A333DR_gpws_system_status 				= find_dataref("laminar/A333/buttons/gpws/system_status")
A333_gpws_GS_visual_alert				= find_dataref("laminar/A333/buttons/gpws/glideslope_status")

A333DR_fws_aco_5 = create_dataref("laminar/A333/fws/aco_5", "number")
A333DR_fws_aco_10 = create_dataref("laminar/A333/fws/aco_10", "number")
A333DR_fws_aco_20 = create_dataref("laminar/A333/fws/aco_20", "number")
A333DR_fws_aco_30 = create_dataref("laminar/A333/fws/aco_30", "number")
A333DR_fws_aco_40 = create_dataref("laminar/A333/fws/aco_40", "number")
A333DR_fws_aco_50 = create_dataref("laminar/A333/fws/aco_50", "number")
A333DR_fws_aco_100 = create_dataref("laminar/A333/fws/aco_100", "number")
A333DR_fws_aco_200 = create_dataref("laminar/A333/fws/aco_200", "number")
A333DR_fws_aco_300 = create_dataref("laminar/A333/fws/aco_300", "number")
A333DR_fws_aco_400 = create_dataref("laminar/A333/fws/aco_400", "number")
A333DR_fws_aco_500 = create_dataref("laminar/A333/fws/aco_500", "number")
A333DR_fws_aco_1000 = create_dataref("laminar/A333/fws/aco_1000", "number")
A333DR_fws_aco_2000 = create_dataref("laminar/A333/fws/aco_2000", "number")
A333DR_fws_aco_2500 = create_dataref("laminar/A333/fws/aco_2500", "number")
A333DR_fws_aco_2500B = create_dataref("laminar/A333/fws/aco_2500B", "number")
A333DR_fws_aco_10_retard = create_dataref("laminar/A333/fws/aco_10_retard", "number")
A333DR_fws_aco_20_retard= create_dataref("laminar/A333/fws/aco_20_retard", "number")
A333DR_fws_aco_retard = create_dataref("laminar/A333/fws/aco_retard", "number")
A333DR_fws_aco_stall = create_dataref("laminar/A333/fws/aco_stall", "number")
A333DR_fws_aco_windshear = create_dataref("laminar/A333/fws/aco_windshear", "number")
A333DR_fws_aco_speed = create_dataref("laminar/A333/fws/aco_speed", "number")
A333DR_fws_aco_hndrd_abv = create_dataref("laminar/A333/fws/aco_hndrd_abv", "number")
A333DR_fws_aco_minimum = create_dataref("laminar/A333/fws/aco_minimum", "number")

A333DR_fws_aco_priority_left = create_dataref("laminar/A333/fws/aco_priority_left", "number")
A333DR_fws_aco_priority_right = create_dataref("laminar/A333/fws/aco_priority_right", "number")
A333DR_fws_aco_dual_input = create_dataref("laminar/A333/fws/aco_dual_input", "number")

A333DR_fws_aco_ap_off = create_dataref("laminar/A333/fws/aco_ap_off", "number")

A333_apu_avail							= find_dataref("laminar/A333/annun/apu_avail")
A333_apu_fire_handle_pos				= find_dataref("laminar/A333/fire/switches/apu_handle")
A333_apu_agent_psi						= find_dataref("laminar/A333/fire/status/apu_agent_psi")

A333_gpws_flap_tog_pos					= find_dataref("laminar/A333/buttons/gpws/flap_toggle_pos")

A333_ECAM_hyd_green_status				= find_dataref("laminar/A333/ecam/hyd_green_status")
A333_ECAM_hyd_blue_status				= find_dataref("laminar/A333/ecam/hyd_blue_status")
A333_ECAM_hyd_yellow_status				= find_dataref("laminar/A333/ecam/hyd_yellow_status")

A333_switches_apu_bleed_pos				= find_dataref("laminar/A333/buttons/apu_bleed_pos")
A333_annun_apu_bleed_on					= find_dataref("laminar/A333/annun/apu_bleed_on")

A333_wing_anti_ice						= find_dataref("laminar/A333/buttons/wing_anti_ice")

A333_left_pump1_pos						= find_dataref("laminar/A333/fuel/buttons/left1_pump_pos")
A333_left_pump2_pos						= find_dataref("laminar/A333/fuel/buttons/left2_pump_pos")
A333_right_pump1_pos					= find_dataref("laminar/A333/fuel/buttons/right1_pump_pos")
A333_right_pump2_pos					= find_dataref("laminar/A333/fuel/buttons/right2_pump_pos")

A333_buttons_gen_apu_pos				= find_dataref("laminar/A333/buttons/gen_apu_pos")
A333_status_GPU_avail					= find_dataref("laminar/A333/status/GPU_avail")

A333_buttons_gen1_pos					= find_dataref("laminar/A333/buttons/gen1_pos")
A333_buttons_gen2_pos					= find_dataref("laminar/A333/buttons/gen2_pos")

A333_buttons_bus_tie_pos				= find_dataref("laminar/A333/buttons/bus_tie_pos")

A333_ventilation_extract_ovrd_pos		= find_dataref("laminar/A333/buttons/ventilation_extract_ovrd_pos")

A333_elec_pump_blue_tog_pos				= find_dataref("laminar/A330/buttons/hyd/elec_blue_tog_pos")
A333_elec_pump_yellow_tog_pos			= find_dataref("laminar/A330/buttons/hyd/elec_yellow_tog_pos")
A333_elec_pump_green_tog_pos			= find_dataref("laminar/A330/buttons/hyd/elec_green_tog_pos")

A333_isol_valve_right_pos				= find_dataref("laminar/A333/ecam/bleed/crossbleed_valve_pos")  -- 0 = close, 1 = transit, 2 = open

A333DR_fuel_wing_crossfeed_pos			= find_dataref("laminar/A333/fuel/buttons/wing_x_feed_pos")

A333_wheel_brake_temp1					= find_dataref("laminar/A333/ecam/wheel/brake_temp_1")
A333_wheel_brake_temp2					= find_dataref("laminar/A333/ecam/wheel/brake_temp_2")
A333_wheel_brake_temp3					= find_dataref("laminar/A333/ecam/wheel/brake_temp_3")
A333_wheel_brake_temp4					= find_dataref("laminar/A333/ecam/wheel/brake_temp_4")
A333_wheel_brake_temp5					= find_dataref("laminar/A333/ecam/wheel/brake_temp_5")
A333_wheel_brake_temp6					= find_dataref("laminar/A333/ecam/wheel/brake_temp_6")
A333_wheel_brake_temp7					= find_dataref("laminar/A333/ecam/wheel/brake_temp_7")
A333_wheel_brake_temp8					= find_dataref("laminar/A333/ecam/wheel/brake_temp_8")

A333_gpws_flap_status					= find_dataref("laminar/A333/buttons/gpws/flap_status")

A333_switches_ram_air_pos				= find_dataref("laminar/A333/buttons/ram_air_pos")

A333_strobe_switch_pos					= find_dataref("laminar/a333/switches/strobe_pos")

A333_auto_brake_low_pos					= find_dataref("laminar/A333/buttons/gear/auto_brake_low_pos")
A333_auto_brake_med_pos					= find_dataref("laminar/A333/buttons/gear/auto_brake_med_pos")
A333_auto_brake_max_pos					= find_dataref("laminar/A333/buttons/gear/auto_brake_max_pos")

A333_center_left_pump_pos				= find_dataref("laminar/A333/fuel/buttons/center_left_pump_pos")
A333_center_right_pump_pos				= find_dataref("laminar/A333/fuel/buttons/center_right_pump_pos")

A333_fuel_crossfeed_valve_pos			= find_dataref("laminar/A333/fuel/crossfeed_valve_pos")

A333_IDG1_status						= find_dataref("laminar/A333/status/elec/IDG1") -- 0 if OFF, 1 if ON
A333_IDG2_status						= find_dataref("laminar/A333/status/elec/IDG2") -- 0 if OFF, 1 if ON


A333_switches_pack1_pos					= find_dataref("laminar/A333/buttons/pack_1_pos")
A333_switches_pack2_pos					= find_dataref("laminar/A333/buttons/pack_2_pos")

A333_eng1_bleed_button_pos				= find_dataref("laminar/A333/buttons/eng_bleed_1_pos")
A333_eng2_bleed_button_pos				= find_dataref("laminar/A333/buttons/eng_bleed_2_pos")

A333_wing_heat_valve_pos_left			= find_dataref("laminar/A333/anti_ice/status/left_wing_valve_pos")
A333_wing_heat_valve_pos_right			= find_dataref("laminar/A333/anti_ice/status/right_wing_valve_pos")

A333_left_wing_ai_valve_ind				= find_dataref("laminar/A333/ecam/bleed/left_wing_antiice_valve_ind")
A333_right_wing_ai_valve_ind			= find_dataref("laminar/A333/ecam/bleed/right_wing_antiice_valve_ind")

A333_engine_anti_ice1					= find_dataref("laminar/A333/buttons/engine_anti_ice1")
A333_engine_anti_ice2					= find_dataref("laminar/A333/buttons/engine_anti_ice2")

simDR_engine1_heat						= find_dataref("sim/cockpit2/ice/cowling_thermal_anti_ice_per_engine[0]")
simDR_engine2_heat						= find_dataref("sim/cockpit2/ice/cowling_thermal_anti_ice_per_engine[1]")

A333_precooler1_psi						= find_dataref("laminar/A333/ecam/bleed/precooler1_psi")
A333_precooler2_psi						= find_dataref("laminar/A333/ecam/bleed/precooler2_psi")

A333_precooler1_temp					= find_dataref("laminar/A333/ecam/bleed/precooler1_temp")
A333_precooler2_temp					= find_dataref("laminar/A333/ecam/bleed/precooler2_temp")

A333_buttons_ACESS_FEED_pos				= find_dataref("laminar/A333/buttons/AC_ESS_FEED_pos")

A333_rat_button_pos						= find_dataref("laminar/A330/buttons/hyd/rat_deploy_pos")

A333_apu_fire_test						= find_dataref("laminar/A333/fire/apu_test_on")
A333_engine_fire_test					= find_dataref("laminar/A333/fire/engine_test_on")
A333_cargo_fire_test					= find_dataref("laminar/A333/fire/cargo_test_on")

A333_ECAM_thrust_mode					= find_dataref("laminar/A333/ecam/thrust_mode")	-- 0 = climb, 1 = MCT, 2 = FLEX, 3 = TOGA
A333_ECAM_fuel_center_xfer_any			= find_dataref("laminar/A333/ecam/fuel/status_center_xfer")

A333_audio_tcas_alert					= find_dataref("sim/cockpit2/tcas/indicators/tcas_alert")

A333_dual_input							= find_dataref("laminar/A333/sidestick/dual_input")

A333_capt_priority_pos					= find_dataref("laminar/A333/buttons/capt_priority_pos")
A333_fo_priority_pos					= find_dataref("laminar/A333/buttons/fo_priority_pos")

A333DR_fws_aco_5_playing 				= find_dataref("laminar/A333/aco_5_playing")
A333DR_fws_aco_10_playing 				= find_dataref("laminar/A333/aco_10_playing")
A333DR_fws_aco_20_playing 				= find_dataref("laminar/A333/aco_20_playing")
A333DR_fws_aco_30_playing 				= find_dataref("laminar/A333/aco_30_playing")
A333DR_fws_aco_40_playing 				= find_dataref("laminar/A333/aco_40_playing")
A333DR_fws_aco_50_playing 				= find_dataref("laminar/A333/aco_50_playing")
A333DR_fws_aco_100_playing 				= find_dataref("laminar/A333/aco_100_playing")
A333DR_fws_aco_200_playing 				= find_dataref("laminar/A333/aco_200_playing")
A333DR_fws_aco_300_playing 				= find_dataref("laminar/A333/aco_300_playing")
A333DR_fws_aco_400_playing 				= find_dataref("laminar/A333/aco_400_playing")
A333DR_fws_aco_500_playing 				= find_dataref("laminar/A333/aco_500_playing")
A333DR_fws_aco_500C_playing 			= find_dataref("laminar/A333/aco_500C_playing")
A333DR_fws_aco_1000_playing 			= find_dataref("laminar/A333/aco_1000_playing")
A333DR_fws_aco_2000_playing 			= find_dataref("laminar/A333/aco_2000_playing")
A333DR_fws_aco_2500_playing 			= find_dataref("laminar/A333/aco_2500_playing")
A333DR_fws_aco_2500B_playing 			= find_dataref("laminar/A333/aco_2500B_playing")
A333DR_fws_aco_stall_playing 			= find_dataref("laminar/A333/aco_stall_playing")
A333DR_fws_aco_windshear_playing 		= find_dataref("laminar/A333/aco_windshear_playing")
A333DR_fws_aco_speed_playing 			= find_dataref("laminar/A333/aco_speed_playing")
A333DR_fws_aco_hundred_above_playing 	= find_dataref("laminar/A333/aco_hundred_above_playing")
A333DR_fws_aco_minimum_playing 			= find_dataref("laminar/A333/aco_minimum_playing")
A333DR_fws_aco_10_retard_playing 		= find_dataref("laminar/A333/fws/aco_10_retard_playing")
A333DR_fws_aco_20_retard_playing 		= find_dataref("laminar/A333/fws/aco_20_retard_playing")
A333DR_fws_aco_retard_playing 			= find_dataref("laminar/A333/fws/aco_retard_playing")
A333DR_fws_aco_priority_left_playing 	= find_dataref("laminar/A333/aco_priority_left_playing")
A333DR_fws_aco_priority_right_playing 	= find_dataref("laminar/A333/aco_priority_right_playing")
A333DR_fws_aco_dual_input_playing 		= find_dataref("laminar/A333/aco_dual_input_playing")
A333DR_fws_aco_ap_off_playing 			= find_dataref("laminar/A333/fws/aco_ap_off_playing")

A333_buttons_idg1_discon_pos			= find_dataref("laminar/A333/buttons/IDG1_discon_pos")
A333_buttons_idg2_discon_pos			= find_dataref("laminar/A333/buttons/IDG2_discon_pos")

AG330_adirs_is_align					= find_dataref("AG330/ADIRS/isAligned")



--*************************************************************************************--
--** 				             FIND CUSTOM COMMANDS								**--
--*************************************************************************************--

A333CMD_ecam_sts_button					= find_command("laminar/A333/button/ecam/sts_mode")
A333CMD_ecam_button_clr_capt			= find_command("laminar/A333/button/ecam/clr_capt")




--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

A333DR_ecam_testNum						= create_dataref("laminar/A333/ecam/testNum", "array[50]")
A333DR_ecam_testString					= create_dataref("laminar/A333/ecam/testStr", "string")

A333DR_flight_phase						= create_dataref("laminar/A333/data/flight_phase", "number")

A333DR_ecp_sys_page_pushbutton_annun	= create_dataref("laminar/A333/ecp/annun/sys_page_pushbutton", "array[13]")
A333DR_ecp_clr_pushbutton_annun			= create_dataref("laminar/A333/ecp/annun/clr_pushbutton", "number")
A333DR_ecp_sts_pushbutton_annun			= create_dataref("laminar/A333/ecp/annun/sts_pushbutton", "number")

A333DR_fws_rcl_normal_msg_show			= create_dataref("laminar/A333/data/rcl_normal_msg_show", "number")
A333DR_fws_sts_normal_msg_show			= create_dataref("laminar/A333/data/sts_normal_msg_show", "number")




-----|  E/WD LEFT ZONE (0) MESSAGES
A333DR_ecam_ewd_gText_msg_L = {}
for i = 1, 7 do
	A333DR_ecam_ewd_gText_msg_L[i]		= create_dataref(string.format("laminar/A333/ecam/ewd_text_msg_L_%02d", i), "string")
end


-- TEXT COLOR: 0-RED, 1-AMBER, 2-GREEN, 3-WHITE, 4-CYAN, 5-MAGENTA
A333DR_ecam_ewd_gText_color_L = {}
for i = 1, 7 do
	A333DR_ecam_ewd_gText_color_L[i]	= create_dataref(string.format("laminar/A333/ecam/ewd_text_color_L_%02d", i), "number")
end


-- SPECIAL CONFIG MEMO CYAN ACTION LINES
A333DR_ecam_ewd_gText_cfgAction_L = {}
for i = 1, 6 do
	A333DR_ecam_ewd_gText_cfgAction_L[i]		= create_dataref(string.format("laminar/A333/ecam/ewd_text_cfgAction_L_%02d", i), "string")
end

A333DR_ecam_ewd_gText_cfgAction_color_L = {}
for i = 1, 6 do
	A333DR_ecam_ewd_gText_cfgAction_color_L[i]		= create_dataref(string.format("laminar/A333/ecam/ewd_text_cfgAction_color_L_%02d", i), "number")
end




-----|  E/WD RIGHT ZONE (1) MESSAGES
A333DR_ecam_ewd_gText_msg_R = {}
for i = 1, 7 do
	A333DR_ecam_ewd_gText_msg_R[i]		= create_dataref(string.format("laminar/A333/ecam/ewd_text_msg_R_%02d", i), "string")
end

-- TEXT COLOR: 0-RED, 1-AMBER, 2-GREEN, 3-WHITE, 4-CYAN, 5-MAGENTA
A333DR_ecam_ewd_gText_color_R = {}
for i = 1, 7 do
	A333DR_ecam_ewd_gText_color_R[i]	= create_dataref(string.format("laminar/A333/ecam/ewd_text_color_R_%02d", i), "number")
end



-----|  E/WD LEFT ZONE (0) ITEM GRAPHICS
A333DR_ecam_ewd_gTitle_gfxTR_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTR_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTR_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTR_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTR_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTR_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTR_L03 = {}for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTR_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTR_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTR_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTR_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTR_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTR_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTR_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTR_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTR_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTR_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTR_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTR_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTR_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTR_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gTitle_gfxBR_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBR_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBR_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBR_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBR_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBR_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBR_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBR_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBR_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBR_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBR_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBR_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBR_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBR_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBR_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBR_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBR_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBR_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBR_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBR_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBR_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gTitle_gfxLR_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLR_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLR_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLR_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLR_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLR_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLR_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLR_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLR_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLR_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLR_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLR_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLR_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLR_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLR_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLR_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLR_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLR_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLR_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLR_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLR_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gTitle_gfxRR_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRR_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRR_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRR_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRR_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRR_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRR_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRR_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRR_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRR_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRR_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRR_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRR_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRR_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRR_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRR_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRR_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRR_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRR_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRR_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRR_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gTitle_gfxTA_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTA_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTA_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTA_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTA_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTA_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTA_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTA_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTA_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTA_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTA_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTA_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTA_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTA_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTA_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTA_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTA_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTA_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTA_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTA_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTA_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gTitle_gfxBA_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBA_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBA_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBA_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBA_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBA_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBA_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBA_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBA_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBA_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBA_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBA_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBA_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBA_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBA_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBA_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBA_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBA_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBA_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBA_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBA_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gTitle_gfxLA_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLA_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLA_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLA_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLA_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLA_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLA_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLA_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLA_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLA_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLA_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLA_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLA_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLA_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLA_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLA_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLA_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLA_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLA_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLA_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLA_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gTitle_gfxRA_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRA_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRA_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRA_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRA_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRA_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRA_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRA_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRA_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRA_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRA_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRA_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRA_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRA_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRA_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRA_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRA_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRA_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRA_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRA_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRA_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gTitle_gfxTG_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTG_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTG_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTG_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTG_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTG_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTG_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTG_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTG_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTG_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTG_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTG_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTG_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTG_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTG_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTG_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTG_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTG_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxTG_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxTG_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxTG_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gTitle_gfxBG_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBG_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBG_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBG_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBG_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBG_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBG_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBG_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBG_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBG_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBG_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBG_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBG_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBG_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBG_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBG_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBG_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBG_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxBG_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxBG_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxBG_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gTitle_gfxLG_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLG_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLG_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLG_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLG_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLG_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLG_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLG_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLG_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLG_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLG_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLG_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLG_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLG_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLG_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLG_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLG_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLG_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxLG_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxLG_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxLG_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gTitle_gfxRG_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRG_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRG_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRG_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRG_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRG_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRG_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRG_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRG_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRG_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRG_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRG_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRG_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRG_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRG_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRG_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRG_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRG_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gTitle_gfxRG_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gTitle_gfxRG_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_title_gfxRG_L07_%02d", i), "number")
end







-----|  E/WD LEFT ZONE (0) WARNING GRAPHICS
A333DR_ecam_ewd_gWarn_gfxTR_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTR_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTR_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTR_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTR_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTR_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTR_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTR_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTR_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTR_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTR_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTR_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTR_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTR_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTR_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTR_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTR_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTR_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTR_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTR_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTR_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gWarn_gfxBR_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBR_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBR_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBR_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBR_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBR_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBR_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBR_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBR_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBR_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBR_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBR_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBR_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBR_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBR_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBR_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBR_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBR_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBR_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBR_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBR_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gWarn_gfxLR_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLR_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLR_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLR_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLR_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLR_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLR_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLR_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLR_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLR_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLR_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLR_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLR_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLR_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLR_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLR_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLR_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLR_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLR_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLR_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLR_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gWarn_gfxRR_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRR_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRR_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRR_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRR_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRR_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRR_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRR_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRR_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRR_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRR_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRR_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRR_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRR_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRR_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRR_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRR_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRR_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRR_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRR_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRR_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gWarn_gfxTA_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTA_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTA_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTA_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTA_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTA_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTA_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTA_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTA_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTA_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTA_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTA_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTA_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTA_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTA_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTA_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTA_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTA_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTA_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTA_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTA_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gWarn_gfxBA_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBA_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBA_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBA_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBA_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBA_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBA_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBA_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBA_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBA_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBA_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBA_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBA_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBA_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBA_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBA_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBA_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBA_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBA_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBA_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBA_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gWarn_gfxLA_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLA_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLA_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLA_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLA_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLA_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLA_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLA_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLA_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLA_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLA_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLA_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLA_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLA_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLA_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLA_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLA_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLA_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLA_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLA_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLA_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gWarn_gfxRA_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRA_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRA_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRA_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRA_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRA_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRA_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRA_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRA_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRA_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRA_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRA_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRA_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRA_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRA_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRA_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRA_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRA_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRA_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRA_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRA_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gWarn_gfxTG_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTG_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTG_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTG_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTG_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTG_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTG_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTG_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTG_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTG_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTG_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTG_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTG_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTG_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTG_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTG_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTG_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTG_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxTG_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxTG_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxTG_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gWarn_gfxBG_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBG_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBG_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBG_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBG_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBG_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBG_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBG_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBG_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBG_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBG_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBG_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBG_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBG_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBG_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBG_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBG_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBG_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxBG_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxBG_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxBG_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gWarn_gfxLG_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLG_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLG_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLG_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLG_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLG_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLG_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLG_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLG_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLG_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLG_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLG_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLG_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLG_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLG_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLG_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLG_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLG_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxLG_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxLG_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxLG_L07_%02d", i), "number")
end



A333DR_ecam_ewd_gWarn_gfxRG_L01 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRG_L01[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRG_L01_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRG_L02 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRG_L02[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRG_L02_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRG_L03 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRG_L03[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRG_L03_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRG_L04 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRG_L04[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRG_L04_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRG_L05 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRG_L05[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRG_L05_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRG_L06 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRG_L06[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRG_L06_%02d", i), "number")
end

A333DR_ecam_ewd_gWarn_gfxRG_L07 = {}
for i = 1, 24 do
	A333DR_ecam_ewd_gWarn_gfxRG_L07[i] = create_dataref(string.format("laminar/A333/ecam/ewd_warn_gfxRG_L07_%02d", i), "number")
end













-----|  SD STATUS LEFT ZONE (0) MESSAGES
A333DR_ecam_sd_gText_msg_L = {}
for i = 1, 18 do
	A333DR_ecam_sd_gText_msg_L[i]		= create_dataref(string.format("laminar/A333/ecam/sd_text_msg_L_%02d", i), "string")
end


-- TEXT COLOR: 0-RED, 1-AMBER, 2-GREEN, 3-WHITE, 4-CYAN, 5-MAGENTA
A333DR_ecam_sd_gText_color_L = {}
for i = 1, 18 do
	A333DR_ecam_sd_gText_color_L[i]	= create_dataref(string.format("laminar/A333/ecam/sd_text_color_L_%02d", i), "number")
end


A333DR_ecam_sd_gText_msg_L2 = {}
for i = 1, 18 do
	A333DR_ecam_sd_gText_msg_L2[i]		= create_dataref(string.format("laminar/A333/ecam/sd_text_msg_L2_%02d", i), "string")
end


-- TEXT COLOR: 0-RED, 1-AMBER, 2-GREEN, 3-WHITE, 4-CYAN, 5-MAGENTA
A333DR_ecam_sd_gText_color_L2 = {}
for i = 1, 18 do
	A333DR_ecam_sd_gText_color_L2[i]	= create_dataref(string.format("laminar/A333/ecam/sd_text_color_L2_%02d", i), "number")
end




A333DR_ecam_sd_gfxBW_L01 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L01[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L01_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L02 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L02[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L02_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L03 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L03[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L03_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L04 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L04[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L04_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L05 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L05[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L05_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L06 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L06[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L06_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L07 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L07[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L07_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L08 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L08[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L08_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L09 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L09[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L09_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L10 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L10[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L10_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L11 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L11[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L11_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L12 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L12[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L12_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L13 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L13[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L13_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L14 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L14[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L14_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L15 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L15[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L15_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L16 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L16[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L16_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L17 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L17[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L17_%02d", i), "number")
end

A333DR_ecam_sd_gfxBW_L18 = {}
for i = 1, 24 do
	A333DR_ecam_sd_gfxBW_L18[i] = create_dataref(string.format("laminar/A333/ecam/sd_gfxBW_L18_%02d", i), "number")
end









-----|  SD RIGHT ZONE(1) MESSAGES
A333DR_ecam_sd_gText_msg_R = {}
for i = 1, 18 do
	A333DR_ecam_sd_gText_msg_R[i]		= create_dataref(string.format("laminar/A333/ecam/sd_text_msg_R_%02d", i), "string")
end




-- TEXT COLOR: 0-RED, 1-AMBER, 2-GREEN, 3-WHITE, 4-CYAN, 5-MAGENTA
A333DR_ecam_sd_gText_color_R = {}
for i = 1, 18 do
	A333DR_ecam_sd_gText_color_R[i]		= create_dataref(string.format("laminar/A333/ecam/sd_text_color_R_%02d", i), "number")
end



A333DR_ecam_sd2_gfxBW_L01 = {}
for i = 1, 12 do
	A333DR_ecam_sd2_gfxBW_L01[i] = create_dataref(string.format("laminar/A333/ecam/sd2_gfxBW_L01_%02d", i), "number")
end








A333DR_ecam_sys_page					= create_dataref("laminar/A333/enums/ecam/sys_page", "number")
--[[
	0	- NONE
	1 	- ENGINE
	2	- BLEED
	3	- CAB PRESS
	4	- ELEC AC
	5	- ELEC DC
	6 	- HYD
	7	- C/B
	8	- APU
	9	- COND
	10	- DOOR/OXY
	11	- WHEEL
	12	- F/CTL
	13	- FUEL
	14	- CRUISE
	15 	- STATUS
--]]


A333DR_ecam_ewd_show_sts					= create_dataref("laminar/A333/ecam/annun/ewd_show_sts", "number")
A333DR_ecam_ewd_show_overflow_arrow			= create_dataref("laminar/A333/ecam/annun/ewd_show_msg_overflow", "number")
A333DR_ecam_sd_show_overflow_arrow			= create_dataref("laminar/A333/ecam/annun/sd_show_msg_overflow", "number")

A333DR_pack1_fault = create_dataref("laminar/A333/data/pack1_fault", "number")
A333DR_pack2_fault = create_dataref("laminar/A333/data/pack2_fault", "number")

A333DR_fws_apu_avail = create_dataref("laminar/A333/fws_data/apu_avail", "number")

A333_hyd_elec_blue_pump_fault = create_dataref("laminar/A333/hyd/elec_blue_pump_fault","number")
A333_hyd_elec_green_pump_fault = create_dataref("laminar/A333/hyd/elec_green_pump_fault","number")
A333_hyd_elec_yellow_pump_fault = create_dataref("laminar/A333/hyd/elec_yellow_pump_fault","number")
A333_hyd_eng1_blue_pump_fault = create_dataref("laminar/A333/hyd/eng1_blue_pump_fault","number")
A333_hyd_eng1_green_pump_fault = create_dataref("laminar/A333/hyd/eng1_green_pump_fault","number")
A333_hyd_eng2_green_pump_fault = create_dataref("laminar/A333/hyd/eng2_green_pump_fault","number")
A333_hyd_eng2_yellow_pump_fault = create_dataref("laminar/A333/hyd/eng2_yellow_pump_fault","number")

A333_capt_master_warn_pb_pos = create_dataref("laminar/A333/buttons/capt_master_warn_pos", "number")
A333_capt_master_caut_pb_pos = create_dataref("laminar/A333/buttons/capt_master_caut_pos", "number")
A333_fo_master_warn_pb_pos = create_dataref("laminar/A333/buttons/fo_master_warn_pos", "number")
A333_fo_master_caut_pb_pos = create_dataref("laminar/A333/buttons/fo_master_caut_pos", "number")


A333DR_fws_aural_alert_crc = create_dataref("laminar/A333/sound/chime_cont", "number")
A333DR_fws_aural_alert_sc = create_dataref("laminar/A333/sound/chime", "number")
A333DR_fws_aural_alert_cc = create_dataref("laminar/A333/sound/cavalry_charge", "number")
A333DR_fws_aural_alert_ccc = create_dataref("laminar/A333/sound/cavalry_charge_cont", "number")
A333DR_fws_aural_alert_tc = create_dataref("laminar/A333/sound/triple_click", "number")
A333DR_fws_aural_alert_ckt = create_dataref("laminar/A333/sound/cricket", "number")
A333DR_fws_aural_alert_ib = create_dataref("laminar/A333/sound/int_ buzzer", "number")
A333DR_fws_aural_alert_b = create_dataref("laminar/A333/sound/buzzer", "number")
A333DR_fws_aural_alert_c = create_dataref("laminar/A333/sound/c_chord", "number")

A333DR_audio_attenuation = create_dataref("laminar/A333/sound/audio_attenuation", "number")

A333DR_fws_landing_gear_down = create_dataref("laminar/A333/fws/landing_gear_down", "number")



--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				            CUSTOM COMMAND HANDLERS            				     **--
--*************************************************************************************--

function A333_fo_master_warn_pb_CMDhandler(phase, duration)
	if phase == 0 then
		A333_fo_master_warn_pb_pos = 1
		WFOMWC = true
		simCMD_master_warn_canx:once()
	elseif phase == 2 then
		A333_fo_master_warn_pb_pos = 0
		WFOMWC = false
	end
end

function A333_fo_master_caut_pb_CMDhandler(phase, duration)
	if phase == 0 then
		A333_fo_master_caut_pb_pos = 1
		WFOMCC = true
		simCMD_master_caut_canx:once()
	elseif phase == 2 then
		A333_fo_master_caut_pb_pos = 0
		WFOMCC = false
	end
end



--*************************************************************************************--
--** 				             CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--

A333CMD_fo_master_warn_pb = create_command("laminar/A333/buttons/fo_mast_warn_push", "F/O MASTER WARNING", A333_fo_master_warn_pb_CMDhandler)
A333CMD_fo_master_caut_pb = create_command("laminar/A333/buttons/fo_mast_caut_push", "F/O MASTER CAUTION", A333_fo_master_caut_pb_CMDhandler)



--*************************************************************************************--
--** 				          X-PLANE WRAP COMMAND HANDLERS              	    	 **--
--*************************************************************************************--

function A333_master_warn_canx_pb_beforeCMDhandler(phase, duration)  end
function A333_master_warn_canx_pb_afterCMDhandler(phase, duration)
	if phase == 0 then
		if A333_fo_master_warn_pb_pos == 0 then
			A333_capt_master_warn_pb_pos = 1
			WCMWC = true
		end
	elseif phase == 2 then
		A333_capt_master_warn_pb_pos = 0
		WCMWC = false
	end
end



function A333_master_caut_canx_pb_beforeCMDhandler(phase, duration)  end
function A333_master_caut_canx_pb_afterCMDhandler(phase, duration)
	if phase == 0 then
		if A333_fo_master_caut_pb_pos == 0 then
			A333_capt_master_caut_pb_pos = 1
			WCMCC = true
		end
	elseif phase == 2 then
		A333_capt_master_caut_pb_pos = 0
		WCMCC = false
	end
end








--*************************************************************************************--
--** 				              WRAP X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--

simCMD_master_warn_canx	= wrap_command("sim/annunciator/clear_master_warning", A333_master_warn_canx_pb_beforeCMDhandler, A333_master_warn_canx_pb_afterCMDhandler)
simCMD_master_caut_canx	= wrap_command("sim/annunciator/clear_master_caution", A333_master_caut_canx_pb_beforeCMDhandler, A333_master_caut_canx_pb_afterCMDhandler)



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







--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







