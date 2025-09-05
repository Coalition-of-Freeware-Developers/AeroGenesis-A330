jit.off()
--[[
*****************************************************************************************
* Program Script Name	:	A333.annunciators
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

local engine1_heat_valve_pos = 0
local engine2_heat_valve_pos = 0
local engine1_heat_valve_pos_target = 0
local engine2_heat_valve_pos_target = 0
local wing_heat_valve_pos_left_target = 0
local wing_heat_valve_pos_right_target = 0

--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_annun_brightness			= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_manual[15]")
simDR_annun_brightness_switch	= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[15]")
simDR_annun_brightness2			= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_manual[16]")
simDR_annun_brightness2_switch	= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[16]")

simDR_EFIS_airport_on_capt		= find_dataref("sim/cockpit2/EFIS/EFIS_airport_on")
simDR_EFIS_fix_on_capt			= find_dataref("sim/cockpit2/EFIS/EFIS_fix_on")
simDR_EFIS_vor_on_capt			= find_dataref("sim/cockpit2/EFIS/EFIS_vor_on")
simDR_EFIS_ndb_on_capt			= find_dataref("sim/cockpit2/EFIS/EFIS_ndb_on")
simDR_EFIS_CSTR_capt_on			= find_dataref("sim/cockpit2/EFIS/EFIS_data_on")

simDR_EFIS_airport_on_fo		= find_dataref("sim/cockpit2/EFIS/EFIS_airport_on_copilot")
simDR_EFIS_fix_on_fo			= find_dataref("sim/cockpit2/EFIS/EFIS_fix_on_copilot")
simDR_EFIS_vor_on_fo			= find_dataref("sim/cockpit2/EFIS/EFIS_vor_on_copilot")
simDR_EFIS_ndb_on_fo			= find_dataref("sim/cockpit2/EFIS/EFIS_ndb_on_copilot")
simDR_EFIS_CSTR_fo_on			= find_dataref("sim/cockpit2/EFIS/EFIS_data_on_copilot")

simDR_terr_on_nd_capt			= find_dataref("sim/cockpit2/EFIS/EFIS_terrain_on")
simDR_terr_on_nd_fo				= find_dataref("sim/cockpit2/EFIS/EFIS_terrain_on_copilot")

simDR_apu_mode					= find_dataref("sim/cockpit2/electrical/APU_starter_switch")
simDR_apu_N1					= find_dataref("sim/cockpit2/electrical/APU_N1_percent")
simDR_apu_fail					= find_dataref("sim/operation/failures/rel_apu")
simDR_apu_running				= find_dataref("sim/cockpit2/electrical/APU_running")

simDR_engine1_heat				= find_dataref("sim/cockpit2/ice/cowling_thermal_anti_ice_per_engine[0]")
simDR_engine2_heat				= find_dataref("sim/cockpit2/ice/cowling_thermal_anti_ice_per_engine[1]")
simDR_engine1_anti_ice_fail		= find_dataref("sim/operation/failures/rel_ice_inlet_heat")
simDR_engine2_anti_ice_fail		= find_dataref("sim/operation/failures/rel_ice_inlet_heat2")

simDR_wing_heat_left			= find_dataref("sim/cockpit2/ice/ice_surface_hot_bleed_air_left_on")
simDR_wing_heat_right			= find_dataref("sim/cockpit2/ice/ice_surface_hot_bleed_air_right_on")

simDR_wing_heat_fault_left		= find_dataref("sim/operation/failures/rel_ice_surf_heat")
simDR_wing_heat_fault_right		= find_dataref("sim/operation/failures/rel_ice_surf_heat2")

simDR_engine1_fire_annun		= find_dataref("sim/cockpit2/annunciators/engine_fires[0]")
simDR_engine2_fire_annun		= find_dataref("sim/cockpit2/annunciators/engine_fires[1]")

simDR_engine1_starter_fault		= find_dataref("sim/operation/failures/rel_startr0")
simDR_engine2_starter_fault		= find_dataref("sim/operation/failures/rel_startr1")

simDR_transponder_failure		= find_dataref("sim/operation/failures/rel_xpndr")

simDR_ahars1_fail_state			= find_dataref("sim/operation/failures/rel_g_arthorz")
simDR_ahars2_fail_state			= find_dataref("sim/operation/failures/rel_g_arthorz_2")
simDR_adc1_fail_state			= find_dataref("sim/operation/failures/rel_adc_comp")
simDR_adc2_fail_state			= find_dataref("sim/operation/failures/rel_adc_comp_2")

simDR_battery1					= find_dataref("sim/cockpit2/electrical/battery_on[0]")
simDR_battery2					= find_dataref("sim/cockpit2/electrical/battery_on[1]")
simDR_gen1_amps					= find_dataref("sim/cockpit2/electrical/generator_amps[0]")
simDR_gen2_amps					= find_dataref("sim/cockpit2/electrical/generator_amps[1]")
simDR_apu_gen_amps				= find_dataref("sim/cockpit2/electrical/APU_generator_amps")
simDR_bus1_volts				= find_dataref("sim/cockpit2/electrical/bus_volts[0]")
simDR_bus2_volts				= find_dataref("sim/cockpit2/electrical/bus_volts[1]")

simDR_acceleration				= find_dataref("sim/cockpit2/gauges/indicators/airspeed_acceleration_kts_sec_pilot")
simDR_auto_brake				= find_dataref("sim/cockpit2/switches/auto_brake_level")

simDR_brake_temp_left			= find_dataref("sim/flightmodel2/gear/brake_absorbed_rat[1]")
simDR_brake_temp_right			= find_dataref("sim/flightmodel2/gear/brake_absorbed_rat[2]")
simDR_gear_on_ground			= find_dataref("sim/flightmodel2/gear/on_ground[1]")
simDR_brake_fan					= find_dataref("sim/cockpit2/controls/brake_fan_on")

simDR_cockpit_door				= find_dataref("sim/flightmodel2/misc/door_open_ratio[11]")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

A333_ann_light_switch_pos			= find_dataref("laminar/a333/switches/ann_light_pos")
A333_emer_exit_lt_switch_pos		= find_dataref("laminar/a333/switches/emer_exit_lt_pos")

A333_probe_window_heat_monitor		= find_dataref("laminar/A333/monitors/probe_window_heat")

A333_cockpit_door_lock_pos			= find_dataref("laminar/A333/switches/cockpit_door_lock_pos")

A333DR_elt_annun					= find_dataref("laminar/A333/lights/elt")

A333_pax_sys_pos					= find_dataref("laminar/A333/buttons/pax_sys_pos")
A333_pax_satcom_pos					= find_dataref("laminar/A333/buttons/pax_satcom_pos")
A333_pax_IFEC_pos					= find_dataref("laminar/A333/buttons/pax_IFEC_pos")

A333_turb_damper					= find_dataref("sim/cockpit2/switches/yaw_damper_on")
A333_prim1_pos						= find_dataref("laminar/A333/buttons/fcc_prim1_pos")
A333_prim2_pos						= find_dataref("laminar/A333/buttons/fcc_prim2_pos")
A333_prim3_pos						= find_dataref("laminar/A333/buttons/fcc_prim3_pos")
A333_sec1_pos						= find_dataref("laminar/A333/buttons/fcc_sec1_pos")
A333_sec2_pos						= find_dataref("laminar/A333/buttons/fcc_sec2_pos")

A333_cargo_cond_fwd_isol_valve_pos	= find_dataref("laminar/A333/buttons/cargo_cond/fwd_isol_valve_pos")
A333_cargo_cond_bulk_isol_valve_pos	= find_dataref("laminar/A333/buttons/cargo_cond/bulk_isol_valve_pos")
A333_cargo_cond_hot_air_pos			= find_dataref("laminar/A333/buttons/cargo_cond/hot_air_pos")

A333_ventilation_extract_ovrd_pos	= find_dataref("laminar/A333/buttons/ventilation_extract_ovrd_pos")
A333_cabin_fan_pos					= find_dataref("laminar/A333/buttons/cabin_fan_pos")

A333_adirs_ir1_mode					= find_dataref("laminar/A333/adirs/ir1_status")
A333_adirs_adr1_mode				= find_dataref("laminar/A333/adirs/adr1_status")
A333_adirs_ir3_mode					= find_dataref("laminar/A333/adirs/ir3_status")
A333_adirs_adr3_mode				= find_dataref("laminar/A333/adirs/adr3_status")
A333_adirs_ir2_mode					= find_dataref("laminar/A333/adirs/ir2_status")
A333_adirs_adr2_mode				= find_dataref("laminar/A333/adirs/adr2_status")

A333_ahars1_starting				= find_dataref("laminar/A333/adirs/ir1_starting")
A333_ahars2_starting				= find_dataref("laminar/A333/adirs/ir2_starting")

A333DR_adirs_ir1_knob				= find_dataref("laminar/A333/buttons/adirs/ir1_knob_pos")
A333DR_adirs_ir3_knob				= find_dataref("laminar/A333/buttons/adirs/ir3_knob_pos")
A333DR_adirs_ir2_knob				= find_dataref("laminar/A333/buttons/adirs/ir2_knob_pos")

-- GEAR

A333_nose_gear_down					= find_dataref("sim/flightmodel2/gear/deploy_ratio[0]")
A333_main_left_gear_down			= find_dataref("sim/flightmodel2/gear/deploy_ratio[1]")
A333_main_right_gear_down			= find_dataref("sim/flightmodel2/gear/deploy_ratio[2]")

A333_wheel_brake_warn				= find_dataref("laminar/A333/ecam/wheel/brake_temp_exceed")

-- ECAM

A333_ecam_button_clr_capt_pos		= find_dataref("laminar/A333/buttons/ecam/clr_capt_pos")
A333_ecam_button_clr_fo_pos			= find_dataref("laminar/A333/buttons/ecam/clr_fo_pos")

A333_annun_cargo_aft_agent_smoke	= find_dataref("laminar/A333/annun/cargo/aft_agent_smoke")

A333DR_ecp_sys_page_pushbutton_annun	= find_dataref("laminar/A333/ecp/annun/sys_page_pushbutton")
A333DR_ecp_clr_pushbutton_annun			= find_dataref("laminar/A333/ecp/annun/clr_pushbutton")
A333DR_ecp_sts_pushbutton_annun			= find_dataref("laminar/A333/ecp/annun/sts_pushbutton")

A333DR_fws_apu_avail				= find_dataref("laminar/A333/fws_data/apu_avail")


--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

A333_emer_exit_off_annun			= create_dataref("laminar/A333/annun/emer_exit_off", "number")

A333_EFIS_apt_capt_annun 			= create_dataref("laminar/A333/annun/EFIS_capt_arpt", "number")
A333_EFIS_vor_capt_annun 			= create_dataref("laminar/A333/annun/EFIS_capt_vor", "number")
A333_EFIS_fix_capt_annun 			= create_dataref("laminar/A333/annun/EFIS_capt_fix", "number")
A333_EFIS_ndb_capt_annun 			= create_dataref("laminar/A333/annun/EFIS_capt_ndb", "number")
A333_EFIS_cstr_capt_annun 			= create_dataref("laminar/A333/annun/EFIS_capt_cstr", "number")

A333_EFIS_apt_fo_annun 				= create_dataref("laminar/A333/annun/EFIS_fo_arpt", "number")
A333_EFIS_vor_fo_annun 				= create_dataref("laminar/A333/annun/EFIS_fo_vor", "number")
A333_EFIS_fix_fo_annun 				= create_dataref("laminar/A333/annun/EFIS_fo_fix", "number")
A333_EFIS_ndb_fo_annun 				= create_dataref("laminar/A333/annun/EFIS_fo_ndb", "number")
A333_EFIS_cstr_fo_annun 			= create_dataref("laminar/A333/annun/EFIS_fo_cstr", "number")

A333_EFIS_terr_capt_annun			= create_dataref("laminar/A333/annun/terr_on_nd_capt", "number")
A333_EFIS_terr_fo_annun				= create_dataref("laminar/A333/annun/terr_on_nd_fo", "number")

A333_apu_fault_annun				= create_dataref("laminar/A333/annun/apu_fault", "number")
A333_apu_master_on_annun			= create_dataref("laminar/A333/annun/apu_master_on", "number")
A333_apu_start_on_annun				= create_dataref("laminar/A333/annun/apu_start_on", "number")
A333_apu_avail_annun				= create_dataref("laminar/A333/annun/apu_avail", "number")

A333_window_probe_heat_annun		= create_dataref("laminar/A333/annun/window_probe_on", "number")
A333_engine1_anti_ice_annun			= create_dataref("laminar/A333/annun/engine1_anti_ice", "number")
A333_engine2_anti_ice_annun			= create_dataref("laminar/A333/annun/engine2_anti_ice", "number")
A333_engine1_ai_fault_annun			= create_dataref("laminar/A333/annun/engine1_anti_ice_fault", "number")
A333_engine2_ai_fault_annun			= create_dataref("laminar/A333/annun/engine2_anti_ice_fault", "number")
A333_wing_anti_ice_annun			= create_dataref("laminar/A333/annun/wing_anti_ice", "number")
A333_wing_anti_ice_fault_annun		= create_dataref("laminar/A333/annun/wing_anti_ice_fault", "number")

A333_wing_heat_valve_pos_left		= create_dataref("laminar/A333/anti_ice/status/left_wing_valve_pos", "number")
A333_wing_heat_valve_pos_right		= create_dataref("laminar/A333/anti_ice/status/right_wing_valve_pos", "number")

A333_engine1_fire_annun				= create_dataref("laminar/A333/annun/engine1_fire", "number")
A333_engine2_fire_annun				= create_dataref("laminar/A333/annun/engine2_fire", "number")
A333_engine1_starter_fault			= create_dataref("laminar/A333/annun/engine1_starter_fault", "number")
A333_engine2_starter_fault			= create_dataref("laminar/A333/annun/engine2_starter_fault", "number")

A333_cockpit_door_open_annun		= create_dataref("laminar/A333/annun/cockpit_door_open", "number")
A333_cockpit_door_fault_annun		= create_dataref("laminar/A333/annun/cockpit_door_fault", "number")

A333_transponder_fail_annun			= create_dataref("laminar/A333/annun/transponder_fail", "number")

A333_elt_on_annun					= create_dataref("laminar/A333/annun/ELT_active", "number")

A333_non_specified_annun			= create_dataref("laminar/A333/annun/inactive_unspecified", "number")
A333_non_specified_annun2			= create_dataref("laminar/A333/annun/inactive_unspecified2", "number")

-- annuns defined by python script

A333_annun_pax_IFEC_off					= create_dataref("laminar/A333/annun/pax/IFEC_off","number")
A333_annun_pax_satcom_off				= create_dataref("laminar/A333/annun/pax/satcom_off","number")
A333_annun_pax_system_off				= create_dataref("laminar/A333/annun/pax/system_off","number")

A333_annun_flt_ctl_prim1_off			= create_dataref("laminar/A333/annun/flt_ctl/prim1_off","number")
A333_annun_flt_ctl_prim2_off			= create_dataref("laminar/A333/annun/flt_ctl/prim2_off","number")
A333_annun_flt_ctl_prim3_off			= create_dataref("laminar/A333/annun/flt_ctl/prim3_off","number")
A333_annun_flt_ctl_sec1_off				= create_dataref("laminar/A333/annun/flt_ctl/sec1_off","number")
A333_annun_flt_ctl_sec2_off				= create_dataref("laminar/A333/annun/flt_ctl/sec2_off","number")
A333_annun_flt_ctl_turb_damp_off		= create_dataref("laminar/A333/annun/flt_ctl/turb_damp_off","number")

A333_annun_cargo_bulk_hot_air			= create_dataref("laminar/A333/annun/cargo/bulk_hot_air","number")
A333_annun_cargo_bulk_isol_valves_off	= create_dataref("laminar/A333/annun/cargo/bulk_isol_valves_off","number")
A333_annun_cargo_fwd_isol_valves_off	= create_dataref("laminar/A333/annun/cargo/fwd_isol_valves_off","number")

A333_annun_ventilation_cab_fans_off		= create_dataref("laminar/A333/annun/ventilation/cab_fans_off","number")
A333_annun_ventilation_extract_ovrd		= create_dataref("laminar/A333/annun/ventilation/extract_ovrd","number")

-- ADIRS

A333_annun_adirs_adr1_off				= create_dataref("laminar/A333/annun/adirs/adr1_off","number")
A333_annun_adirs_adr2_off				= create_dataref("laminar/A333/annun/adirs/adr2_off","number")
A333_annun_adirs_adr3_off				= create_dataref("laminar/A333/annun/adirs/adr3_off","number")
A333_annun_adirs_ir1_off				= create_dataref("laminar/A333/annun/adirs/ir1_off","number")
A333_annun_adirs_ir2_off				= create_dataref("laminar/A333/annun/adirs/ir2_off","number")
A333_annun_adirs_ir3_off				= create_dataref("laminar/A333/annun/adirs/ir3_off","number")

A333_annun_adirs_adr1_fault				= create_dataref("laminar/A333/annun/adirs/adr1_fault","number")
A333_annun_adirs_adr2_fault				= create_dataref("laminar/A333/annun/adirs/adr2_fault","number")
A333_annun_adirs_ir1_fault				= create_dataref("laminar/A333/annun/adirs/ir1_fault","number")
A333_annun_adirs_ir2_fault				= create_dataref("laminar/A333/annun/adirs/ir2_fault","number")

A333_annun_adirs_on_bat					= create_dataref("laminar/A333/annun/adirs/on_bat","number")

-- GEAR

A333_annun_auto_brake_lo_on				= create_dataref("laminar/A333/annun/auto_brake/lo_on","number")
A333_annun_auto_brake_med_on			= create_dataref("laminar/A333/annun/auto_brake/med_on","number")
A333_annun_auto_brake_max_on			= create_dataref("laminar/A333/annun/auto_brake/max_on","number")
A333_annun_auto_brake_lo_decel			= create_dataref("laminar/A333/annun/auto_brake/lo_decel","number")
A333_annun_auto_brake_med_decel			= create_dataref("laminar/A333/annun/auto_brake/med_decel","number")
A333_annun_auto_brake_max_decel			= create_dataref("laminar/A333/annun/auto_brake/max_decel","number")

A333_annun_landing_gear_brake_fan_hot	= create_dataref("laminar/A333/annun/landing_gear/brake_fan_hot","number")
A333_annun_landing_gear_brake_fan_on 	= create_dataref("laminar/A333/annun/landing_gear/brake_fan_on","number")
A333_annun_landing_gear_left_green		= create_dataref("laminar/A333/annun/landing_gear/left_green","number")
A333_annun_landing_gear_left_unlk		= create_dataref("laminar/A333/annun/landing_gear/left_unlk","number")
A333_annun_landing_gear_nose_green		= create_dataref("laminar/A333/annun/landing_gear/nose_green","number")
A333_annun_landing_gear_nose_unlk		= create_dataref("laminar/A333/annun/landing_gear/nose_unlk","number")
A333_annun_landing_gear_right_green		= create_dataref("laminar/A333/annun/landing_gear/right_green","number")
A333_annun_landing_gear_right_unlk		= create_dataref("laminar/A333/annun/landing_gear/right_unlk","number")

-- ECP CONTROL PANEL PUSHBUTTON ANNUNCIATORS

A333_annun_ecam_mode_eng				= create_dataref("laminar/A333/annun/ecam_mode_eng","number") -- 0
A333_annun_ecam_mode_bleed				= create_dataref("laminar/A333/annun/ecam_mode_bleed","number") -- 1
A333_annun_ecam_mode_press				= create_dataref("laminar/A333/annun/ecam_mode_press","number") -- 2
A333_annun_ecam_mode_el_ac				= create_dataref("laminar/A333/annun/ecam_mode_el_ac","number") -- 3
A333_annun_ecam_mode_el_dc				= create_dataref("laminar/A333/annun/ecam_mode_el_dc","number") -- 4
A333_annun_ecam_mode_hyd				= create_dataref("laminar/A333/annun/ecam_mode_hyd","number") -- 5
A333_annun_ecam_mode_c_b				= create_dataref("laminar/A333/annun/ecam_mode_c_b","number") -- 6

A333_annun_ecam_mode_apu				= create_dataref("laminar/A333/annun/ecam_mode_apu","number") -- 7
A333_annun_ecam_mode_cond				= create_dataref("laminar/A333/annun/ecam_mode_cond","number") -- 8
A333_annun_ecam_mode_door				= create_dataref("laminar/A333/annun/ecam_mode_door","number") -- 9
A333_annun_ecam_mode_wheel				= create_dataref("laminar/A333/annun/ecam_mode_wheel","number") -- 10
A333_annun_ecam_mode_f_ctl				= create_dataref("laminar/A333/annun/ecam_mode_f_ctl","number") -- 11
A333_annun_ecam_mode_fuel				= create_dataref("laminar/A333/annun/ecam_mode_fuel","number") -- 12

A333_annun_ecp_clr						= create_dataref("laminar/A333/annun/ecp_clr","number")
A333_annun_ecp_sts						= create_dataref("laminar/A333/annun/ecp_sts","number")




--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--


--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--


--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                 X-PLANE COMMANDS                   	    	 **--
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

local annun_brightness_switch_target = 0
local annun_brightness_switch_target2 = 0

local emer_exit_off = 0
local emer_exit_off_target = 0

local EFIS_capt_apt_annun = 0
local EFIS_capt_vor_annun = 0
local EFIS_capt_fix_annun = 0
local EFIS_capt_ndb_annun = 0
local EFIS_capt_cstr_annun = 0

local EFIS_fo_apt_annun = 0
local EFIS_fo_vor_annun = 0
local EFIS_fo_fix_annun = 0
local EFIS_fo_ndb_annun = 0
local EFIS_fo_cstr_annun = 0

local EFIS_capt_apt_annun_target = 0
local EFIS_capt_vor_annun_target = 0
local EFIS_capt_fix_annun_target = 0
local EFIS_capt_ndb_annun_target = 0
local EFIS_capt_cstr_annun_target = 0

local EFIS_fo_apt_annun_target = 0
local EFIS_fo_vor_annun_target = 0
local EFIS_fo_fix_annun_target = 0
local EFIS_fo_ndb_annun_target = 0
local EFIS_fo_cstr_annun_target = 0

local EFIS_terr_capt_annun = 0
local EFIS_terr_fo_annun = 0
local EFIS_terr_capt_annun_target = 0
local EFIS_terr_fo_annun_target = 0

local apu_fault_annun = 0
local apu_master_on_annun = 0
local apu_start_on_annun = 0
local apu_avail_annun = 0

local apu_fault_annun_target = 0
local apu_master_on_annun_target = 0
local apu_start_on_annun_target = 0
local apu_avail_annun_target = 0

local window_probe_on_annun = 0
local window_probe_on_annun_target = 0

local engine1_anti_ice_annun = 0
local engine1_anti_ice_annun_target = 0
local engine2_anti_ice_annun = 0
local engine2_anti_ice_annun_target = 0

local engine1_anti_ice_fault_annun = 0
local engine1_anti_ice_fault_annun_target = 0
local engine2_anti_ice_fault_annun = 0
local engine2_anti_ice_fault_annun_target = 0

local wing_anti_ice_annun = 0
local wing_anti_ice_annun_target = 0
local wing_anti_ice_fault_annun = 0
local wing_anti_ice_fault_annun_target = 0
local wing_anti_ice_fault_left_annun_target = 0
local wing_anti_ice_fault_right_annun_target = 0

local engine1_fire_annun = 0
local engine2_fire_annun = 0
local engine1_fire_annun_target = 0
local engine2_fire_annun_target = 0

local engine1_starter_fault_annun = 0
local engine2_starter_fault_annun = 0
local engine1_starter_fault_annun_target = 0
local engine2_starter_fault_annun_target = 0

local cockpit_door_open_annun = 0
local cockpit_door_open_annun_target = 0
local cockpit_door_fault_annun = 0
local cockpit_door_fault_annun_target = 0

local cockpit_door_fault_blink = 0

local transponder_fail = 0
local transponder_fail_target = 0

local ELT_annun = 0
local ELT_annun_target = 0

local pax_IFEC_off = 0
local pax_satcom_off = 0
local pax_system_off = 0
local pax_IFEC_off_target = 0
local pax_satcom_off_target = 0
local pax_system_off_target = 0

local turb_damper_off = 0
local prim1_off = 0
local prim2_off = 0
local prim3_off = 0
local sec1_off = 0
local sec2_off = 0

local turb_damper_off_target = 0
local prim1_off_target = 0
local prim2_off_target = 0
local prim3_off_target = 0
local sec1_off_target = 0
local sec2_off_target = 0

local cargo_bulk_hot_air = 0
local cargo_bulk_isol_valves_off = 0
local cargo_fwd_isol_valves_off = 0
local cargo_bulk_hot_air_target = 0
local cargo_bulk_isol_valves_off_target = 0
local cargo_fwd_isol_valves_off_target = 0

local unspecified_annun = 0
local unspecified_annun_target = 0
local unspecified_annun2 = 0
local unspecified_annun2_target = 0

local avionics_bay_smoke_annun = 0
local cabin_fans_off_annun = 0
local vent_extract_ovrd_annun = 0
local avionics_bay_smoke_annun_target = 0
local cabin_fans_off_annun_target = 0
local vent_extract_ovrd_annun_target = 0

local adirs_adr1_off_annun = 0
local adirs_adr2_off_annun = 0
local adirs_adr3_off_annun = 0
local adirs_ir1_off_annun = 0
local adirs_ir2_off_annun = 0
local adirs_ir3_off_annun = 0

local adirs_adr1_off_annun_target = 0
local adirs_adr2_off_annun_target = 0
local adirs_adr3_off_annun_target = 0
local adirs_ir1_off_annun_target = 0
local adirs_ir2_off_annun_target = 0
local adirs_ir3_off_annun_target = 0

local adirs_adr1_fault = 0
local adirs_adr2_fault = 0
local adirs_ir1_fault = 0
local adirs_ir2_fault = 0

local adirs_adr1_fault_target = 0
local adirs_adr2_fault_target = 0
local adirs_ir1_fault_target = 0
local adirs_ir2_fault_target = 0

local adirs_on_bat_annun = 0
local adirs_on_bat_annun_target = 0

local annun_auto_brake_lo_on = 0
local annun_auto_brake_med_on = 0
local annun_auto_brake_max_on = 0
local annun_auto_brake_lo_decel = 0
local annun_auto_brake_med_decel = 0
local annun_auto_brake_max_decel = 0

local annun_auto_brake_lo_on_target = 0
local annun_auto_brake_med_on_target = 0
local annun_auto_brake_max_on_target = 0
local annun_auto_brake_lo_decel_target = 0
local annun_auto_brake_med_decel_target = 0
local annun_auto_brake_max_decel_target = 0

local annun_landing_gear_brake_fan_hot = 0
local annun_landing_gear_brake_fan_on = 0
local annun_landing_gear_nose_green = 0
local annun_landing_gear_left_green = 0
local annun_landing_gear_right_green = 0
local annun_landing_gear_nose_unlk = 0
local annun_landing_gear_left_unlk = 0
local annun_landing_gear_right_unlk = 0

local annun_landing_gear_brake_fan_hot_target = 0
local annun_landing_gear_brake_fan_on_target = 0
local annun_landing_gear_nose_green_target = 0
local annun_landing_gear_left_green_target = 0
local annun_landing_gear_right_green_target = 0
local annun_landing_gear_nose_unlk_target = 0
local annun_landing_gear_left_unlk_target = 0
local annun_landing_gear_right_unlk_target = 0

local systemPagePushbuttonAnnunciatorTarget = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
local ecpCLRpushButtonAnnunciatorTarget = 0
local ecpSTSpushButtonAnnunciatorTarget = 0

-- ANNUNCIATOR FUNCTIONS

function A333_annunciators()

-- annunciator brightness / test switch --

	if A333_ann_light_switch_pos == 0 then
		annun_brightness_switch_target = 0.0075
		annun_brightness_switch_target2 = 0.02
	elseif A333_ann_light_switch_pos >= 1 then
		annun_brightness_switch_target = 1
		annun_brightness_switch_target2 = 1
	end

	simDR_annun_brightness_switch = A333_set_animation_position(simDR_annun_brightness_switch, annun_brightness_switch_target, 0, 1, 13)
	simDR_annun_brightness2_switch = A333_set_animation_position(simDR_annun_brightness2_switch, annun_brightness_switch_target2, 0, 1, 13)

-- annunciator conditions --

	if A333_ann_light_switch_pos <= 1 then

		if A333_emer_exit_lt_switch_pos == 0 then
			emer_exit_off_target = 1
		elseif A333_emer_exit_lt_switch_pos >= 1 then
			emer_exit_off_target = 0
		end

-- EFIS

		EFIS_capt_apt_annun_target = simDR_EFIS_airport_on_capt
		EFIS_capt_vor_annun_target = simDR_EFIS_vor_on_capt
		EFIS_capt_fix_annun_target = simDR_EFIS_fix_on_capt
		EFIS_capt_ndb_annun_target = simDR_EFIS_ndb_on_capt
		EFIS_capt_cstr_annun_target = simDR_EFIS_CSTR_capt_on

		EFIS_fo_apt_annun_target = simDR_EFIS_airport_on_fo
		EFIS_fo_vor_annun_target = simDR_EFIS_vor_on_fo
		EFIS_fo_fix_annun_target = simDR_EFIS_fix_on_fo
		EFIS_fo_ndb_annun_target = simDR_EFIS_ndb_on_fo
		EFIS_fo_cstr_annun_target = simDR_EFIS_CSTR_fo_on

		EFIS_terr_capt_annun_target = simDR_terr_on_nd_capt
		EFIS_terr_fo_annun_target = simDR_terr_on_nd_fo

-- APU

		if simDR_apu_fail == 6 then
			apu_fault_annun_target = 1
		elseif simDR_apu_fail < 6 then
			apu_fault_annun_target = 0
		end

		if simDR_apu_mode >= 1 then
			apu_master_on_annun_target = 1
		elseif simDR_apu_mode < 1 then
			apu_master_on_annun_target = 0
		end

		if simDR_apu_running == 0 then
			apu_start_on_annun_target = 0
			apu_avail_annun_target = 0
		elseif simDR_apu_running == 1 then
			if simDR_apu_N1 <= 95 then
				apu_start_on_annun_target = 1
				apu_avail_annun_target = 0
			elseif simDR_apu_N1 > 95 then
				apu_avail_annun_target = 1
				apu_start_on_annun_target = 0
			end
		end

-- ANTI ICE

		window_probe_on_annun_target = A333_probe_window_heat_monitor

		engine1_anti_ice_annun_target = simDR_engine1_heat
		engine2_anti_ice_annun_target = simDR_engine2_heat

		if simDR_wing_heat_left == 1 or simDR_wing_heat_right == 1 then
			wing_anti_ice_annun_target = 1
		elseif simDR_wing_heat_left == 0 and simDR_wing_heat_right == 0 then
			wing_anti_ice_annun_target = 0
		end

		if simDR_engine1_heat == 0 then
			engine1_heat_valve_pos_target = 0
		elseif simDR_engine1_heat == 1 then
			engine1_heat_valve_pos_target = 1
		end

		if simDR_engine2_heat == 0 then
			engine2_heat_valve_pos_target = 0
		elseif simDR_engine2_heat == 1 then
			engine2_heat_valve_pos_target = 1
		end

		if simDR_wing_heat_left == 0 then
			wing_heat_valve_pos_left_target = 0
		elseif simDR_wing_heat_left == 1 then
			wing_heat_valve_pos_left_target = 1
		end

		if simDR_wing_heat_right == 0 then
			wing_heat_valve_pos_right_target = 0
		elseif simDR_wing_heat_right == 1 then
			wing_heat_valve_pos_right_target = 1
		end

		engine1_heat_valve_pos = A333_set_animation_position(engine1_heat_valve_pos, engine1_heat_valve_pos_target, 0, 1, 6)
		engine2_heat_valve_pos = A333_set_animation_position(engine2_heat_valve_pos, engine2_heat_valve_pos_target, 0, 1, 6)

		A333_wing_heat_valve_pos_left = A333_set_animation_position(A333_wing_heat_valve_pos_left, wing_heat_valve_pos_left_target, 0, 1, 4)
		A333_wing_heat_valve_pos_right = A333_set_animation_position(A333_wing_heat_valve_pos_right, wing_heat_valve_pos_right_target, 0, 1, 4)

	if simDR_engine1_anti_ice_fail ~= 6 then
		if engine1_heat_valve_pos ~= 0 and engine1_heat_valve_pos ~= 1 then
			engine1_anti_ice_fault_annun_target = 1
		elseif engine1_heat_valve_pos == 1 or engine1_heat_valve_pos == 0 then
			engine1_anti_ice_fault_annun_target = 0
		end
	elseif simDR_engine1_anti_ice_fail == 6 then
		engine1_anti_ice_fault_annun_target = 1
	end

	if simDR_engine2_anti_ice_fail ~= 6 then
		if engine2_heat_valve_pos ~= 0 and engine2_heat_valve_pos ~= 1 then
			engine2_anti_ice_fault_annun_target = 1
		elseif engine2_heat_valve_pos == 1 or engine2_heat_valve_pos == 0 then
			engine2_anti_ice_fault_annun_target = 0
		end
	elseif simDR_engine2_anti_ice_fail == 6 then
		engine2_anti_ice_fault_annun_target = 1
	end

	if A333_wing_heat_valve_pos_left ~= 0 and A333_wing_heat_valve_pos_left ~= 1 then
		wing_anti_ice_fault_left_annun_target = 1
	elseif A333_wing_heat_valve_pos_left == 1 or A333_wing_heat_valve_pos_left == 0 then
		wing_anti_ice_fault_left_annun_target = 0
	end

	if A333_wing_heat_valve_pos_right ~= 0 and A333_wing_heat_valve_pos_right ~= 1 then
		wing_anti_ice_fault_right_annun_target = 1
	elseif A333_wing_heat_valve_pos_right == 1 or A333_wing_heat_valve_pos_right == 0 then
		wing_anti_ice_fault_right_annun_target = 0
	end

	if simDR_wing_heat_fault_left ~= 6 and simDR_wing_heat_fault_right ~= 6 then

		if wing_anti_ice_fault_left_annun_target == 0 and wing_anti_ice_fault_right_annun_target == 0 then
			wing_anti_ice_fault_annun_target = 0
		elseif wing_anti_ice_fault_left_annun_target == 1 or wing_anti_ice_fault_right_annun_target == 1 then
			wing_anti_ice_fault_annun_target = 1
		end

	elseif simDR_wing_heat_fault_left == 6 or simDR_wing_heat_fault_right == 6 then
		wing_anti_ice_fault_annun_target = 1
	end

-- ANNUN TEST

	elseif A333_ann_light_switch_pos == 2 then

		emer_exit_off_target = 1

		EFIS_capt_apt_annun_target = 1
		EFIS_capt_vor_annun_target = 1
		EFIS_capt_fix_annun_target = 1
		EFIS_capt_ndb_annun_target = 1
		EFIS_capt_cstr_annun_target = 1

		EFIS_fo_apt_annun_target = 1
		EFIS_fo_vor_annun_target = 1
		EFIS_fo_fix_annun_target = 1
		EFIS_fo_ndb_annun_target = 1
		EFIS_fo_cstr_annun_target = 1

		EFIS_terr_capt_annun_target = 1
		EFIS_terr_fo_annun_target = 1

		apu_fault_annun_target = 1
		apu_master_on_annun_target = 1
		apu_start_on_annun_target = 1
		apu_avail_annun_target = 1

		window_probe_on_annun_target = 1
		engine1_anti_ice_annun_target = 1
		engine2_anti_ice_annun_target = 1
		engine1_anti_ice_fault_annun_target = 1
		engine2_anti_ice_fault_annun_target = 1
		wing_anti_ice_annun_target = 1
		wing_anti_ice_fault_annun_target = 1

	end



-- annunciator fade in --

	emer_exit_off = A333_set_animation_position(emer_exit_off, emer_exit_off_target, 0, 1, 13)

	EFIS_capt_apt_annun = A333_set_animation_position(EFIS_capt_apt_annun, EFIS_capt_apt_annun_target, 0, 1, 13)
	EFIS_capt_vor_annun = A333_set_animation_position(EFIS_capt_vor_annun, EFIS_capt_vor_annun_target, 0, 1, 13)
	EFIS_capt_fix_annun = A333_set_animation_position(EFIS_capt_fix_annun, EFIS_capt_fix_annun_target, 0, 1, 13)
	EFIS_capt_ndb_annun = A333_set_animation_position(EFIS_capt_ndb_annun, EFIS_capt_ndb_annun_target, 0, 1, 13)
	EFIS_capt_cstr_annun = A333_set_animation_position(EFIS_capt_cstr_annun, EFIS_capt_cstr_annun_target, 0, 1, 13)

	EFIS_fo_apt_annun = A333_set_animation_position(EFIS_fo_apt_annun, EFIS_fo_apt_annun_target, 0, 1, 13)
	EFIS_fo_vor_annun = A333_set_animation_position(EFIS_fo_vor_annun, EFIS_fo_vor_annun_target, 0, 1, 13)
	EFIS_fo_fix_annun = A333_set_animation_position(EFIS_fo_fix_annun, EFIS_fo_fix_annun_target, 0, 1, 13)
	EFIS_fo_ndb_annun = A333_set_animation_position(EFIS_fo_ndb_annun, EFIS_fo_ndb_annun_target, 0, 1, 13)
	EFIS_fo_cstr_annun = A333_set_animation_position(EFIS_fo_cstr_annun, EFIS_fo_cstr_annun_target, 0, 1, 13)

	EFIS_terr_capt_annun = A333_set_animation_position(EFIS_terr_capt_annun, EFIS_terr_capt_annun_target, 0, 1, 13)
	EFIS_terr_fo_annun = A333_set_animation_position(EFIS_terr_fo_annun, EFIS_terr_fo_annun_target, 0, 1, 13)

	apu_fault_annun = A333_set_animation_position(apu_fault_annun, apu_fault_annun_target, 0, 1, 13)
	apu_master_on_annun = A333_set_animation_position(apu_master_on_annun, apu_master_on_annun_target, 0, 1, 13)
	apu_start_on_annun = A333_set_animation_position(apu_start_on_annun, apu_start_on_annun_target, 0, 1, 13)
	apu_avail_annun = A333_set_animation_position(apu_avail_annun, apu_avail_annun_target, 0, 1, 13)

	window_probe_on_annun = A333_set_animation_position(window_probe_on_annun, window_probe_on_annun_target, 0, 1, 13)
	engine1_anti_ice_annun = A333_set_animation_position(engine1_anti_ice_annun, engine1_anti_ice_annun_target, 0, 1, 13)
	engine2_anti_ice_annun = A333_set_animation_position(engine2_anti_ice_annun, engine2_anti_ice_annun_target, 0, 1, 13)
	engine1_anti_ice_fault_annun = A333_set_animation_position(engine1_anti_ice_fault_annun, engine1_anti_ice_fault_annun_target, 0, 1, 13)
	engine2_anti_ice_fault_annun = A333_set_animation_position(engine2_anti_ice_fault_annun, engine2_anti_ice_fault_annun_target, 0, 1, 13)
	wing_anti_ice_annun = A333_set_animation_position(wing_anti_ice_annun, wing_anti_ice_annun_target, 0, 1, 13)
	wing_anti_ice_fault_annun = A333_set_animation_position(wing_anti_ice_fault_annun, wing_anti_ice_fault_annun_target, 0, 1, 13)

-- annunciator brightness --

	A333_emer_exit_off_annun = emer_exit_off * simDR_annun_brightness

	A333_EFIS_apt_capt_annun = EFIS_capt_apt_annun * simDR_annun_brightness
	A333_EFIS_vor_capt_annun = EFIS_capt_vor_annun * simDR_annun_brightness
	A333_EFIS_fix_capt_annun = EFIS_capt_fix_annun * simDR_annun_brightness
	A333_EFIS_ndb_capt_annun = EFIS_capt_ndb_annun * simDR_annun_brightness
	A333_EFIS_cstr_capt_annun = EFIS_capt_cstr_annun * simDR_annun_brightness

	A333_EFIS_apt_fo_annun = EFIS_fo_apt_annun * simDR_annun_brightness
	A333_EFIS_vor_fo_annun = EFIS_fo_vor_annun * simDR_annun_brightness
	A333_EFIS_fix_fo_annun = EFIS_fo_fix_annun * simDR_annun_brightness
	A333_EFIS_ndb_fo_annun = EFIS_fo_ndb_annun * simDR_annun_brightness
	A333_EFIS_cstr_fo_annun = EFIS_fo_cstr_annun * simDR_annun_brightness

	A333_EFIS_terr_capt_annun = EFIS_terr_capt_annun * simDR_annun_brightness
	A333_EFIS_terr_fo_annun = EFIS_terr_fo_annun * simDR_annun_brightness

	A333_apu_fault_annun = apu_fault_annun * simDR_annun_brightness
	A333_apu_master_on_annun = apu_master_on_annun * simDR_annun_brightness
	A333_apu_start_on_annun = apu_start_on_annun * simDR_annun_brightness
	A333_apu_avail_annun = apu_avail_annun * simDR_annun_brightness

	A333_window_probe_heat_annun = window_probe_on_annun * simDR_annun_brightness
	A333_engine1_anti_ice_annun = engine1_anti_ice_annun * simDR_annun_brightness
	A333_engine2_anti_ice_annun = engine2_anti_ice_annun * simDR_annun_brightness
	A333_engine1_ai_fault_annun = engine1_anti_ice_fault_annun * simDR_annun_brightness
	A333_engine2_ai_fault_annun = engine2_anti_ice_fault_annun * simDR_annun_brightness
	A333_wing_anti_ice_annun = wing_anti_ice_annun * simDR_annun_brightness
	A333_wing_anti_ice_fault_annun = wing_anti_ice_fault_annun * simDR_annun_brightness


end

function A333_annunciators2()

	if A333_ann_light_switch_pos <= 1 then

		unspecified_annun_target = 0
		unspecified_annun2_target = 0

-- ENGINE FIRE

		engine1_fire_annun_target = simDR_engine1_fire_annun
		engine2_fire_annun_target = simDR_engine2_fire_annun

-- ENGINE STARTER FAULT

		if simDR_engine1_starter_fault == 6 then
			engine1_starter_fault_annun_target = 1
		elseif simDR_engine1_starter_fault ~= 6 then
			engine1_starter_fault_annun_target = 0
		end

		if simDR_engine2_starter_fault == 6 then
			engine2_starter_fault_annun_target = 1
		elseif simDR_engine2_starter_fault ~= 6 then
			engine2_starter_fault_annun_target = 0
		end

-- COCKPIT DOOR LOCK


		if simDR_cockpit_door == 0 then
			if A333_cockpit_door_lock_pos == 1 then			-- need to wire up the door status when the door is set. If DOOR is open, the light stays ON.
				cockpit_door_open_annun_target = 1
			elseif A333_cockpit_door_lock_pos ~= 1 then
				cockpit_door_open_annun_target = 0
			end
		elseif simDR_cockpit_door > 0 then
			cockpit_door_open_annun_target = 1
		end

		cockpit_door_fault_blink = A333_set_animation_position(cockpit_door_fault_blink, A333_cockpit_door_lock_pos, 0, 1, 20)


		if A333_cockpit_door_lock_pos == 1 then
			if cockpit_door_fault_blink ~= 0 and cockpit_door_fault_blink ~= 1 then
				cockpit_door_fault_annun_target = 1
			elseif cockpit_door_fault_blink == 0 or cockpit_door_fault_blink == 1 then
				cockpit_door_fault_annun_target = 0
			end
		elseif A333_cockpit_door_lock_pos ~= 1 then
			cockpit_door_fault_annun_target = 0
		end

-- transponder fail

		if simDR_transponder_failure == 6 then
			transponder_fail_target = 1
		elseif simDR_transponder_failure ~= 6 then
			transponder_fail_target = 0
		end

-- ELT

		ELT_annun_target = A333DR_elt_annun

-- PAX SYSTEMS

		if A333_pax_sys_pos == 0 then
			pax_system_off_target = 1
		elseif A333_pax_sys_pos >= 1 then
			pax_system_off_target = 0
		end

		if A333_pax_satcom_pos == 0 then
			pax_satcom_off_target = 1
		elseif A333_pax_satcom_pos >= 1 then
			pax_satcom_off_target = 0
		end

		if A333_pax_IFEC_pos == 0 then
			pax_IFEC_off_target = 1
		elseif A333_pax_IFEC_pos >= 1 then
			pax_IFEC_off_target = 0
		end

-- FLIGHT CONTROL COMPUTERS

		if A333_turb_damper == 0 then
			turb_damper_off_target = 1
		elseif A333_turb_damper == 1 then
			turb_damper_off_target = 0
		end

		if A333_prim1_pos == 0 then
			prim1_off_target = 1
		elseif A333_prim1_pos >= 1 then
			prim1_off_target = 0
		end

		if A333_prim2_pos == 0 then
			prim2_off_target = 1
		elseif A333_prim2_pos >= 1 then
			prim2_off_target = 0
		end

		if A333_prim3_pos == 0 then
			prim3_off_target = 1
		elseif A333_prim3_pos >= 1 then
			prim3_off_target = 0
		end

		if A333_sec1_pos == 0 then
			sec1_off_target = 1
		elseif A333_sec1_pos >= 1 then
			sec1_off_target = 0
		end

		if A333_sec2_pos == 0 then
			sec2_off_target = 1
		elseif A333_sec2_pos >= 1 then
			sec2_off_target = 0
		end

-- CARGO

		if A333_cargo_cond_fwd_isol_valve_pos == 0 then
			cargo_fwd_isol_valves_off_target = 1
		elseif A333_cargo_cond_fwd_isol_valve_pos == 1 then
			cargo_fwd_isol_valves_off_target = 0
		end

		if A333_cargo_cond_bulk_isol_valve_pos == 0 then
			cargo_bulk_isol_valves_off_target = 1
		elseif A333_cargo_cond_bulk_isol_valve_pos == 1 then
			cargo_bulk_isol_valves_off_target = 0
		end

		if A333_cargo_cond_hot_air_pos == 0 then
			cargo_bulk_hot_air_target = 1
		elseif A333_cargo_cond_hot_air_pos >= 1 then
			cargo_bulk_hot_air_target = 0
		end

-- VENTILATION


		if A333_cabin_fan_pos == 0 then
			cabin_fans_off_annun_target = 1
		elseif A333_cabin_fan_pos >= 1 then
			cabin_fans_off_annun_target = 0
		end

		if A333_ventilation_extract_ovrd_pos == 0 then
			vent_extract_ovrd_annun_target = 1
		elseif A333_ventilation_extract_ovrd_pos >= 1 then
			vent_extract_ovrd_annun_target = 0
		end


	elseif A333_ann_light_switch_pos == 2 then


		unspecified_annun_target = 1
		unspecified_annun2_target = 1

		engine1_starter_fault_annun_target = 1
		engine2_starter_fault_annun_target = 1
		cockpit_door_open_annun_target = 1
		cockpit_door_fault_annun_target = 1
		transponder_fail_target = 1

		ELT_annun_target = 1
		pax_IFEC_off_target = 1
		pax_satcom_off_target = 1
		pax_system_off_target = 1
		turb_damper_off_target = 1

		prim1_off_target = 1
		prim2_off_target = 1
		prim3_off_target = 1
		sec1_off_target = 1
		sec2_off_target = 1

		cargo_bulk_hot_air_target = 1
		cargo_bulk_isol_valves_off_target = 1
		cargo_fwd_isol_valves_off_target = 1
		cabin_fans_off_annun_target = 1
		vent_extract_ovrd_annun_target = 1

		engine1_fire_annun_target = 1
		engine2_fire_annun_target = 1

	end


-- annunciator fade in --

	engine1_starter_fault_annun = A333_set_animation_position(engine1_starter_fault_annun, engine1_starter_fault_annun_target, 0, 1, 13)
	engine2_starter_fault_annun = A333_set_animation_position(engine2_starter_fault_annun, engine2_starter_fault_annun_target, 0, 1, 13)
	cockpit_door_open_annun = A333_set_animation_position(cockpit_door_open_annun, cockpit_door_open_annun_target, 0, 1, 13)
	cockpit_door_fault_annun = A333_set_animation_position(cockpit_door_fault_annun, cockpit_door_fault_annun_target, 0, 1, 13)
	transponder_fail = A333_set_animation_position(transponder_fail, transponder_fail_target, 0, 1, 20)
	ELT_annun = A333_set_animation_position(ELT_annun, ELT_annun_target, 0, 1, 20)

	pax_IFEC_off = A333_set_animation_position(pax_IFEC_off, pax_IFEC_off_target, 0, 1, 13)
	pax_satcom_off = A333_set_animation_position(pax_satcom_off, pax_satcom_off_target, 0, 1, 13)
	pax_system_off = A333_set_animation_position(pax_system_off, pax_system_off_target, 0, 1, 13)

	turb_damper_off = A333_set_animation_position(turb_damper_off, turb_damper_off_target, 0, 1, 13)
	prim1_off = A333_set_animation_position(prim1_off, prim1_off_target, 0, 1, 13)
	prim2_off = A333_set_animation_position(prim2_off, prim2_off_target, 0, 1, 13)
	prim3_off = A333_set_animation_position(prim3_off, prim3_off_target, 0, 1, 13)
	sec1_off = A333_set_animation_position(sec1_off, sec1_off_target, 0, 1, 13)
	sec2_off = A333_set_animation_position(sec2_off, sec2_off_target, 0, 1, 13)

	cargo_bulk_hot_air = A333_set_animation_position(cargo_bulk_hot_air, cargo_bulk_hot_air_target, 0, 1, 13)
	cargo_bulk_isol_valves_off = A333_set_animation_position(cargo_bulk_isol_valves_off, cargo_bulk_isol_valves_off_target, 0, 1, 13)
	cargo_fwd_isol_valves_off = A333_set_animation_position(cargo_fwd_isol_valves_off, cargo_fwd_isol_valves_off_target, 0, 1, 13)
	unspecified_annun = A333_set_animation_position(unspecified_annun, unspecified_annun_target, 0, 1, 13)
	unspecified_annun2 = A333_set_animation_position(unspecified_annun2, unspecified_annun2_target, 0, 1, 20)
	cabin_fans_off_annun = A333_set_animation_position(cabin_fans_off_annun, cabin_fans_off_annun_target, 0, 1, 13)
	vent_extract_ovrd_annun = A333_set_animation_position(vent_extract_ovrd_annun, vent_extract_ovrd_annun_target, 0, 1, 13)

	engine1_fire_annun = A333_set_animation_position(engine1_fire_annun, engine1_fire_annun_target, 0, 1, 13)
	engine2_fire_annun = A333_set_animation_position(engine2_fire_annun, engine2_fire_annun_target, 0, 1, 13)

-- annunciator brightness --

	A333_engine1_starter_fault = engine1_starter_fault_annun * simDR_annun_brightness
	A333_engine2_starter_fault = engine2_starter_fault_annun * simDR_annun_brightness
	A333_cockpit_door_open_annun = cockpit_door_open_annun * simDR_annun_brightness
	A333_cockpit_door_fault_annun = cockpit_door_fault_annun * simDR_annun_brightness
	A333_transponder_fail_annun = transponder_fail * simDR_annun_brightness2
	A333_elt_on_annun = ELT_annun

	A333_annun_pax_IFEC_off = pax_IFEC_off * simDR_annun_brightness
	A333_annun_pax_satcom_off = pax_satcom_off * simDR_annun_brightness
	A333_annun_pax_system_off = pax_system_off * simDR_annun_brightness

	A333_annun_flt_ctl_turb_damp_off = turb_damper_off * simDR_annun_brightness
	A333_annun_flt_ctl_prim1_off = prim1_off * simDR_annun_brightness
	A333_annun_flt_ctl_prim2_off = prim2_off * simDR_annun_brightness
	A333_annun_flt_ctl_prim3_off = prim3_off * simDR_annun_brightness
	A333_annun_flt_ctl_sec1_off = sec1_off * simDR_annun_brightness
	A333_annun_flt_ctl_sec2_off = sec2_off * simDR_annun_brightness

	A333_annun_cargo_bulk_hot_air = cargo_bulk_hot_air * simDR_annun_brightness
	A333_annun_cargo_bulk_isol_valves_off = cargo_bulk_isol_valves_off * simDR_annun_brightness
	A333_annun_cargo_fwd_isol_valves_off = cargo_fwd_isol_valves_off * simDR_annun_brightness
	A333_non_specified_annun = unspecified_annun * simDR_annun_brightness
	A333_non_specified_annun2 = unspecified_annun2 * simDR_annun_brightness
	A333_annun_ventilation_cab_fans_off = cabin_fans_off_annun * simDR_annun_brightness
	A333_annun_ventilation_extract_ovrd = vent_extract_ovrd_annun * simDR_annun_brightness

	A333_engine1_fire_annun = engine1_fire_annun * simDR_annun_brightness
	A333_engine2_fire_annun = engine2_fire_annun * simDR_annun_brightness

end

function A333_annunciators_ADIRS()

	if A333_ann_light_switch_pos <= 1 then

		if A333_adirs_adr1_mode == 0 then
			adirs_adr1_off_annun_target = 1
		elseif A333_adirs_adr1_mode == 1 then
			adirs_adr1_off_annun_target = 0
		end

		if A333_adirs_adr2_mode == 0 then
			adirs_adr2_off_annun_target = 1
		elseif A333_adirs_adr2_mode == 1 then
			adirs_adr2_off_annun_target = 0
		end

		if A333_adirs_adr3_mode == 0 then
			adirs_adr3_off_annun_target = 1
		elseif A333_adirs_adr3_mode == 1 then
			adirs_adr3_off_annun_target = 0
		end

		if A333_adirs_ir1_mode == 0 then
			adirs_ir1_off_annun_target = 1
		elseif A333_adirs_ir1_mode == 1 then
			adirs_ir1_off_annun_target = 0
		end

		if A333_adirs_ir2_mode == 0 then
			adirs_ir2_off_annun_target = 1
		elseif A333_adirs_ir2_mode == 1 then
			adirs_ir2_off_annun_target = 0
		end

		if A333_adirs_ir3_mode == 0 then
			adirs_ir3_off_annun_target = 1
		elseif A333_adirs_ir3_mode == 1 then
			adirs_ir3_off_annun_target = 0
		end

	-- ADR FAULTS --

		if A333_adirs_adr1_mode == 1 then
			if simDR_adc1_fail_state == 6 then
				adirs_adr1_fault_target = 1
			elseif simDR_adc1_fail_state <=5 then
				adirs_adr1_fault_target = 0
			end
		elseif A333_adirs_adr1_mode == 0 then
			adirs_adr1_fault_target = 0
		end

		if A333_adirs_adr2_mode == 1 then
			if simDR_adc2_fail_state == 6 then
				adirs_adr2_fault_target = 1
			elseif simDR_adc2_fail_state <= 5 then
				adirs_adr2_fault_target = 0
			end
		elseif A333_adirs_adr2_mode == 0 then
			adirs_adr2_fault_target = 0
		end

	-- IR FAULTS --

		if A333_adirs_ir1_mode == 1 then
			if A333_ahars1_starting == 0 then
				if simDR_ahars1_fail_state == 6 then
					adirs_ir1_fault_target = 1
				elseif simDR_ahars1_fail_state <= 5 then
					adirs_ir1_fault_target = 0
				end
			elseif A333_ahars1_starting == 1 then
				adirs_ir1_fault_target = 0
			end
		elseif A333_adirs_ir1_mode == 0 then
			adirs_ir1_fault_target = 0
		end

		if A333_adirs_ir2_mode == 1 then
			if A333_ahars2_starting == 0 then
				if simDR_ahars2_fail_state == 6 then
					adirs_ir2_fault_target = 1
				elseif simDR_ahars2_fail_state <= 5 then
					adirs_ir2_fault_target = 0
				end
			elseif A333_ahars2_starting == 1 then
				adirs_ir2_fault_target = 0
			end
		elseif A333_adirs_ir2_mode == 0 then
			adirs_ir2_fault_target = 0
		end

	-- ON BAT ANNUN --
		



		if (A333_adirs_ir1_mode == 1 and A333DR_adirs_ir1_knob >= 1) or (A333_adirs_ir2_mode == 1 and A333DR_adirs_ir2_knob >= 1) or (A333_adirs_ir3_mode == 1 and A333DR_adirs_ir3_knob >= 1) then
			if simDR_battery1 == 1 or simDR_battery2 == 1 then
				if simDR_gen1_amps == 0 and simDR_gen2_amps == 0 and simDR_apu_gen_amps == 0 then
					adirs_on_bat_annun_target = 1
				elseif simDR_gen1_amps > 0 or simDR_gen2_amps > 0 or simDR_apu_gen_amps > 0 then
					adirs_on_bat_annun_target = 0
				end
			elseif simDR_battery1 == 0 and simDR_battery2 == 0 then
				adirs_on_bat_annun_target = 0
			end
		elseif (A333_adirs_ir1_mode == 0 or A333DR_adirs_ir1_knob == 0) and (A333_adirs_ir2_mode == 0 or A333DR_adirs_ir2_knob == 0) and (A333_adirs_ir3_mode == 0 or A333DR_adirs_ir3_knob == 0) then
			adirs_on_bat_annun_target = 0
		end

	elseif A333_ann_light_switch_pos == 2 then

		adirs_adr1_off_annun_target = 1
		adirs_adr2_off_annun_target = 1
		adirs_adr3_off_annun_target = 1
		adirs_ir1_off_annun_target = 1
		adirs_ir2_off_annun_target = 1
		adirs_ir3_off_annun_target = 1

		adirs_adr1_fault_target = 1
		adirs_adr2_fault_target = 1
		adirs_ir1_fault_target = 1
		adirs_ir2_fault_target = 1

		adirs_on_bat_annun_target = 1

	end


-- annunciator fade in --

	adirs_adr1_off_annun = A333_set_animation_position(adirs_adr1_off_annun, adirs_adr1_off_annun_target, 0, 1, 13)
	adirs_adr2_off_annun = A333_set_animation_position(adirs_adr2_off_annun, adirs_adr2_off_annun_target, 0, 1, 13)
	adirs_adr3_off_annun = A333_set_animation_position(adirs_adr3_off_annun, adirs_adr3_off_annun_target, 0, 1, 13)
	adirs_ir1_off_annun = A333_set_animation_position(adirs_ir1_off_annun, adirs_ir1_off_annun_target, 0, 1, 13)
	adirs_ir2_off_annun = A333_set_animation_position(adirs_ir2_off_annun, adirs_ir2_off_annun_target, 0, 1, 13)
	adirs_ir3_off_annun = A333_set_animation_position(adirs_ir3_off_annun, adirs_ir3_off_annun_target, 0, 1, 13)

	adirs_adr1_fault = A333_set_animation_position(adirs_adr1_fault, adirs_adr1_fault_target, 0, 1, 13)
	adirs_adr2_fault = A333_set_animation_position(adirs_adr2_fault, adirs_adr2_fault_target, 0, 1, 13)
	adirs_ir1_fault = A333_set_animation_position(adirs_ir1_fault, adirs_ir1_fault_target, 0, 1, 13)
	adirs_ir2_fault = A333_set_animation_position(adirs_ir2_fault, adirs_ir2_fault_target, 0, 1, 13)
	adirs_on_bat_annun = A333_set_animation_position(adirs_on_bat_annun, adirs_on_bat_annun_target, 0, 1, 13)

-- annunciator brightness --

	A333_annun_adirs_adr1_off = adirs_adr1_off_annun * simDR_annun_brightness
	A333_annun_adirs_adr2_off = adirs_adr2_off_annun * simDR_annun_brightness
	A333_annun_adirs_adr3_off = adirs_adr3_off_annun * simDR_annun_brightness
	A333_annun_adirs_ir1_off = adirs_ir1_off_annun * simDR_annun_brightness
	A333_annun_adirs_ir2_off = adirs_ir2_off_annun * simDR_annun_brightness
	A333_annun_adirs_ir3_off = adirs_ir3_off_annun * simDR_annun_brightness

	A333_annun_adirs_adr1_fault = adirs_adr1_fault * simDR_annun_brightness
	A333_annun_adirs_adr2_fault = adirs_adr2_fault * simDR_annun_brightness
	A333_annun_adirs_ir1_fault = adirs_ir1_fault * simDR_annun_brightness
	A333_annun_adirs_ir2_fault = adirs_ir2_fault * simDR_annun_brightness
	A333_annun_adirs_on_bat = adirs_on_bat_annun * simDR_annun_brightness

end

function A333_annunciators_GEAR()

	if A333_ann_light_switch_pos <= 1 then

		if simDR_auto_brake == 4 then
			annun_auto_brake_lo_on_target = 1
		elseif simDR_auto_brake ~= 4 then
			annun_auto_brake_lo_on_target = 0
		end

		if simDR_auto_brake == 5 then
			annun_auto_brake_med_on_target = 1
		elseif simDR_auto_brake ~= 5 then
			annun_auto_brake_med_on_target = 0
		end

		if simDR_auto_brake == 0 then
			annun_auto_brake_max_on_target = 1
		elseif simDR_auto_brake ~= 0 then
			annun_auto_brake_max_on_target = 0
		end

		if simDR_gear_on_ground == 1 then
			if simDR_auto_brake == 4 then
				if simDR_acceleration <= -2.8 then
					annun_auto_brake_lo_decel_target = 1
				elseif simDR_acceleration > -2.8 then
					annun_auto_brake_lo_decel_target = 0
				end
			elseif simDR_auto_brake ~= 4 then
				annun_auto_brake_lo_decel_target = 0
			end
		elseif simDR_gear_on_ground == 0 then
			annun_auto_brake_lo_decel_target = 0
		end

		if simDR_gear_on_ground == 1 then
			if simDR_auto_brake == 5 then
				if simDR_acceleration <= -4.64 then
					annun_auto_brake_med_decel_target = 1
				elseif simDR_acceleration > -4.64 then
					annun_auto_brake_med_decel_target = 0
				end
			elseif simDR_auto_brake ~= 5 then
				annun_auto_brake_med_decel_target = 0
			end
		elseif simDR_gear_on_ground == 0 then
			annun_auto_brake_med_decel_target = 0
		end

		if simDR_gear_on_ground == 1 then
			if simDR_auto_brake == 0 then
				if simDR_acceleration <= -5.15 then
					annun_auto_brake_max_decel_target = 1
				elseif simDR_acceleration > -5.15 then
					annun_auto_brake_max_decel_target = 0
				end
			elseif simDR_auto_brake ~= 0 then
				annun_auto_brake_max_decel_target = 0
			end
		elseif simDR_gear_on_ground == 0 then
			annun_auto_brake_max_decel_target = 0
		end

		annun_landing_gear_brake_fan_hot_target = A333_wheel_brake_warn

		annun_landing_gear_brake_fan_on_target = simDR_brake_fan


		if A333_nose_gear_down == 1 then
			annun_landing_gear_nose_green_target = 1
		elseif A333_nose_gear_down ~= 1 then
			annun_landing_gear_nose_green_target = 0
		end

		if A333_main_left_gear_down == 1 then
			annun_landing_gear_left_green_target = 1
		elseif A333_main_left_gear_down ~= 1 then
			annun_landing_gear_left_green_target = 0
		end

		if A333_main_right_gear_down == 1 then
			annun_landing_gear_right_green_target = 1
		elseif A333_main_right_gear_down ~= 1 then
			annun_landing_gear_right_green_target = 0
		end

		if A333_nose_gear_down ~= 0 and A333_nose_gear_down ~= 1 then
			annun_landing_gear_nose_unlk_target = 1
		elseif A333_nose_gear_down == 0 or A333_nose_gear_down == 1 then
			annun_landing_gear_nose_unlk_target = 0
		end

		if A333_main_left_gear_down ~= 0 and A333_main_left_gear_down ~= 1 then
			annun_landing_gear_left_unlk_target = 1
		elseif A333_main_left_gear_down == 0 or A333_main_left_gear_down == 1 then
			annun_landing_gear_left_unlk_target = 0
		end

		if A333_main_right_gear_down ~= 0 and A333_main_right_gear_down ~= 1 then
			annun_landing_gear_right_unlk_target = 1
		elseif A333_main_right_gear_down == 0 or A333_main_right_gear_down == 1 then
			annun_landing_gear_right_unlk_target = 0
		end

	elseif A333_ann_light_switch_pos == 2 then

		annun_auto_brake_lo_on_target = 1
		annun_auto_brake_med_on_target = 1
		annun_auto_brake_max_on_target = 1
		annun_auto_brake_lo_decel_target = 1
		annun_auto_brake_med_decel_target = 1
		annun_auto_brake_max_decel_target = 1

		annun_landing_gear_brake_fan_hot_target = 1
		annun_landing_gear_brake_fan_on_target = 1
		annun_landing_gear_nose_green_target = 1
		annun_landing_gear_left_green_target = 1
		annun_landing_gear_right_green_target = 1
		annun_landing_gear_nose_unlk_target = 1
		annun_landing_gear_left_unlk_target = 1
		annun_landing_gear_right_unlk_target = 1

	end

-- annunciator fade in --

	annun_auto_brake_lo_on = A333_set_animation_position(annun_auto_brake_lo_on, annun_auto_brake_lo_on_target, 0, 1, 13)
	annun_auto_brake_med_on = A333_set_animation_position(annun_auto_brake_med_on, annun_auto_brake_med_on_target, 0, 1, 13)
	annun_auto_brake_max_on = A333_set_animation_position(annun_auto_brake_max_on, annun_auto_brake_max_on_target, 0, 1, 13)
	annun_auto_brake_lo_decel = A333_set_animation_position(annun_auto_brake_lo_decel, annun_auto_brake_lo_decel_target, 0, 1, 13)
	annun_auto_brake_med_decel = A333_set_animation_position(annun_auto_brake_med_decel, annun_auto_brake_med_decel_target, 0, 1, 13)
	annun_auto_brake_max_decel = A333_set_animation_position(annun_auto_brake_max_decel, annun_auto_brake_max_decel_target, 0, 1, 13)

	annun_landing_gear_brake_fan_hot = A333_set_animation_position(annun_landing_gear_brake_fan_hot, annun_landing_gear_brake_fan_hot_target, 0, 1, 13)
	annun_landing_gear_brake_fan_on = A333_set_animation_position(annun_landing_gear_brake_fan_on, annun_landing_gear_brake_fan_on_target, 0, 1, 13)

	annun_landing_gear_nose_green = A333_set_animation_position(annun_landing_gear_nose_green, annun_landing_gear_nose_green_target, 0, 1, 13)
	annun_landing_gear_left_green = A333_set_animation_position(annun_landing_gear_left_green, annun_landing_gear_left_green_target, 0, 1, 13)
	annun_landing_gear_right_green = A333_set_animation_position(annun_landing_gear_right_green, annun_landing_gear_right_green_target, 0, 1, 13)
	annun_landing_gear_nose_unlk = A333_set_animation_position(annun_landing_gear_nose_unlk, annun_landing_gear_nose_unlk_target, 0, 1, 13)
	annun_landing_gear_left_unlk = A333_set_animation_position(annun_landing_gear_left_unlk, annun_landing_gear_left_unlk_target, 0, 1, 13)
	annun_landing_gear_right_unlk = A333_set_animation_position(annun_landing_gear_right_unlk, annun_landing_gear_right_unlk_target, 0, 1, 13)

-- annunciator brightness --

	A333_annun_auto_brake_lo_on = annun_auto_brake_lo_on * simDR_annun_brightness
	A333_annun_auto_brake_med_on = annun_auto_brake_med_on * simDR_annun_brightness
	A333_annun_auto_brake_max_on = annun_auto_brake_max_on * simDR_annun_brightness

	A333_annun_auto_brake_lo_decel = annun_auto_brake_lo_decel * simDR_annun_brightness
	A333_annun_auto_brake_med_decel = annun_auto_brake_med_decel * simDR_annun_brightness
	A333_annun_auto_brake_max_decel = annun_auto_brake_max_decel * simDR_annun_brightness

	A333_annun_landing_gear_brake_fan_hot = annun_landing_gear_brake_fan_hot * simDR_annun_brightness
	A333_annun_landing_gear_brake_fan_on = annun_landing_gear_brake_fan_on * simDR_annun_brightness

	A333_annun_landing_gear_nose_green = annun_landing_gear_nose_green * simDR_annun_brightness
	A333_annun_landing_gear_left_green = annun_landing_gear_left_green * simDR_annun_brightness
	A333_annun_landing_gear_right_green = annun_landing_gear_right_green * simDR_annun_brightness

	A333_annun_landing_gear_nose_unlk = annun_landing_gear_nose_unlk * simDR_annun_brightness
	A333_annun_landing_gear_left_unlk = annun_landing_gear_left_unlk * simDR_annun_brightness
	A333_annun_landing_gear_right_unlk = annun_landing_gear_right_unlk * simDR_annun_brightness

end


function A333_SetEcpSystemPagePushbuttonAnnunciator()

	A333_InitSystemPagePushbuttonAnnunciatorTarget()

	for i = 1, 13 do
		if A333_ann_light_switch_pos < 2 then									-- DIM/BRIGHT ACTIVE ANNUNCIATOR
			if A333DR_ecp_sys_page_pushbutton_annun[i-1] == 1 then
				systemPagePushbuttonAnnunciatorTarget[i] = simDR_annun_brightness
			end
		elseif A333_ann_light_switch_pos == 2 then								-- TEST: ALL BRIGHT
			systemPagePushbuttonAnnunciatorTarget[i] = simDR_annun_brightness
		end
	end

	A333_ecp_SetSystemPageAnnunciatorDatarefs()

end

function A333_InitSystemPagePushbuttonAnnunciatorTarget()
	for i = 1, 13 do
		systemPagePushbuttonAnnunciatorTarget[i] = 0.0
	end
end

function A333_ecp_SetSystemPageAnnunciatorDatarefs()

	A333_annun_ecam_mode_eng = A333_set_animation_position(A333_annun_ecam_mode_eng, systemPagePushbuttonAnnunciatorTarget[1], 0, 1, 18)
	A333_annun_ecam_mode_bleed = A333_set_animation_position(A333_annun_ecam_mode_bleed, systemPagePushbuttonAnnunciatorTarget[2], 0, 1, 18)
	A333_annun_ecam_mode_press = A333_set_animation_position(A333_annun_ecam_mode_press, systemPagePushbuttonAnnunciatorTarget[3], 0, 1, 18)
	A333_annun_ecam_mode_el_ac = A333_set_animation_position(A333_annun_ecam_mode_el_ac, systemPagePushbuttonAnnunciatorTarget[4], 0, 1, 18)
	A333_annun_ecam_mode_el_dc = A333_set_animation_position(A333_annun_ecam_mode_el_dc, systemPagePushbuttonAnnunciatorTarget[5], 0, 1, 18)
	A333_annun_ecam_mode_hyd = A333_set_animation_position(A333_annun_ecam_mode_hyd, systemPagePushbuttonAnnunciatorTarget[6], 0, 1, 18)
	A333_annun_ecam_mode_c_b = A333_set_animation_position(A333_annun_ecam_mode_c_b, systemPagePushbuttonAnnunciatorTarget[7], 0, 1, 18)
	A333_annun_ecam_mode_apu = A333_set_animation_position(A333_annun_ecam_mode_apu, systemPagePushbuttonAnnunciatorTarget[8], 0, 1, 18)
	A333_annun_ecam_mode_cond = A333_set_animation_position(A333_annun_ecam_mode_cond, systemPagePushbuttonAnnunciatorTarget[9], 0, 1, 18)
	A333_annun_ecam_mode_door = A333_set_animation_position(A333_annun_ecam_mode_door, systemPagePushbuttonAnnunciatorTarget[10], 0, 1, 18)
	A333_annun_ecam_mode_wheel = A333_set_animation_position(A333_annun_ecam_mode_wheel, systemPagePushbuttonAnnunciatorTarget[11], 0, 1, 18)
	A333_annun_ecam_mode_f_ctl = A333_set_animation_position(A333_annun_ecam_mode_f_ctl, systemPagePushbuttonAnnunciatorTarget[12], 0, 1, 18)
	A333_annun_ecam_mode_fuel = A333_set_animation_position(A333_annun_ecam_mode_fuel, systemPagePushbuttonAnnunciatorTarget[13], 0, 1, 18)
end




function A333_ecp_SetEcpModePushbuttonAnnunciator()

	-- INIT
	ecpCLRpushButtonAnnunciatorTarget = 0
	ecpSTSpushButtonAnnunciatorTarget = 0

	-- DIM/BRIGHT ACTIVE ANNUNCIATOR
	if A333_ann_light_switch_pos < 2 then
		if A333DR_ecp_clr_pushbutton_annun == 1 then ecpCLRpushButtonAnnunciatorTarget = simDR_annun_brightness end
		if A333DR_ecp_sts_pushbutton_annun == 1 then ecpSTSpushButtonAnnunciatorTarget = simDR_annun_brightness end

	-- TEST: ALL BRIGHT
	elseif A333_ann_light_switch_pos == 2 then
		ecpCLRpushButtonAnnunciatorTarget = simDR_annun_brightness
		ecpSTSpushButtonAnnunciatorTarget = simDR_annun_brightness
	end

	A333_ecp_SetModeAnnunciatorDatarefs()


end

function A333_ecp_SetModeAnnunciatorDatarefs()
	A333_annun_ecp_clr = A333_set_animation_position(A333_annun_ecp_clr, ecpCLRpushButtonAnnunciatorTarget, 0, 1, 18)
	A333_annun_ecp_sts = A333_set_animation_position(A333_annun_ecp_sts, ecpSTSpushButtonAnnunciatorTarget, 0, 1, 18)
end





--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

function A333_ALL_annunciators()

	A333_annunciators()
	A333_annunciators2()
	A333_annunciators_ADIRS()
	A333_annunciators_GEAR()
	A333_SetEcpSystemPagePushbuttonAnnunciator()
	A333_ecp_SetEcpModePushbuttonAnnunciator()

end

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

	annun_oxygen_tmr_reset_fault_target = 0

end

--function flight_crash() end

--function before_physics()

function after_physics()

	A333_ALL_annunciators()
	A333DR_fws_apu_avail = apu_avail_annun_target

end

function after_replay()

	A333_ALL_annunciators()

end



