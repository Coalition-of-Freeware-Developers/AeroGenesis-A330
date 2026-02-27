--[[
*****************************************************************************************
* Program Script Name	:	A333.lighting
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

-- Shadow SIM_PERIOD locally to avoid expensive namespace lookups
local lcl_SIM_PERIOD = 0

--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local m = math

local integ_listen				= 0
local integ_glare_listen		= 0
local pedestal_flood_listen		= 0
local sun_factor				= 0
local phase_factor				= 0
local galley_phase_factor		= 0

local time_off1 = m.random(4, 20)
local time_on1 = m.random(2, 16)
local time_on_timer1 = 0
local time_off_timer1 = 0
local light1_on = 0

local time_off2 = m.random(4, 20)
local time_on2 = m.random(2, 16)
local time_on_timer2 = 0
local time_off_timer2 = 0
local light2_on = 0

local time_off3 = m.random(4, 20)
local time_on3 = m.random(2, 16)
local time_on_timer3 = 0
local time_off_timer3 = 0
local light3_on = 0

local time_off4 = m.random(4, 20)
local time_on4 = m.random(2, 16)
local time_on_timer4 = 0
local time_off_timer4 = 0
local light4_on = 0

local time_off5 = m.random(4, 20)
local time_on5 = m.random(2, 16)
local time_on_timer5 = 0
local time_off_timer5 = 0
local light5_on = 0

local time_off6 = m.random(4, 20)
local time_on6 = m.random(2, 16)
local time_on_timer6 = 0
local time_off_timer6 = 0
local light6_on = 0

local descent_flag = 0

local galley_power = 0
local galley_lighting_power = 0
local cabin_light_power = 0
local cabin_light_dynamic_power = 0
local IFE_system_power = 0
local seatbelt_light_power = 0
local smoking_light_power = 0
local exit_light_power = 0

local ife_startup_timer = 0
local ife_status = 0

--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
simDR_flight_time				= find_dataref("sim/time/total_running_time_sec")

simDR_beacon_strobe_ovrd		= find_dataref("sim/flightmodel2/lights/override_beacons_and_strobes")
simDR_strobe1					= find_dataref("sim/flightmodel2/lights/strobe_brightness_ratio[0]")
simDR_strobe2					= find_dataref("sim/flightmodel2/lights/strobe_brightness_ratio[1]")
simDR_beacon					= find_dataref("sim/flightmodel2/lights/beacon_brightness_ratio[0]")

simDR_beacon_on					= find_dataref("sim/cockpit2/switches/beacon_on")
simDR_strobe_on					= find_dataref("sim/cockpit2/switches/strobe_lights_on")
simDR_rwy_turn_off_lights_on    = find_dataref("sim/cockpit2/switches/generic_lights_switch[0]")
simDR_nav_lights_on				= find_dataref("sim/cockpit2/switches/navigation_lights_on")
simDR_logo_lights				= find_dataref("sim/cockpit2/switches/generic_lights_switch[2]")

simDR_bus1_volts				= find_dataref("sim/cockpit2/electrical/bus_volts[0]")
simDR_bus2_volts				= find_dataref("sim/cockpit2/electrical/bus_volts[1]")

simDR_gear_on_ground			= find_dataref("sim/flightmodel2/gear/on_ground[1]")

simDR_flap_deploy_ratio			= find_dataref("sim/cockpit2/controls/flap_system_deploy_ratio")


simDR_landing_light1			= find_dataref("sim/cockpit2/switches/landing_lights_switch[0]")
simDR_landing_light3			= find_dataref("sim/cockpit2/switches/landing_lights_switch[2]")

simDR_dome_left					= find_dataref("sim/cockpit2/switches/generic_lights_switch[4]")
simDR_dome_right				= find_dataref("sim/cockpit2/switches/generic_lights_switch[5]")
simDR_instrument_flood			= find_dataref("sim/cockpit2/switches/generic_lights_switch[14]")

simDR_transponder_fail_spill	= find_dataref("sim/cockpit2/switches/generic_lights_switch[19]")
simDR_generic_spill				= find_dataref("sim/cockpit2/switches/generic_lights_switch[20]")
simDR_door_green_spill			= find_dataref("sim/cockpit2/switches/generic_lights_switch[21]")
simDR_door_red_spill			= find_dataref("sim/cockpit2/switches/generic_lights_switch[22]")
simDR_door_white_spill			= find_dataref("sim/cockpit2/switches/generic_lights_switch[77]")

simDR_seatbelt_signs			= find_dataref("sim/cockpit2/switches/fasten_seat_belts")
simDR_smoking_signs				= find_dataref("sim/cockpit2/switches/no_smoking")

simDR_cabin_lighting			= find_dataref("sim/cockpit2/switches/generic_lights_switch[23]")
simDR_galley_screen_brightness	= find_dataref("sim/cockpit2/switches/generic_lights_switch[24]")
simDR_seatbelt_lighting			= find_dataref("sim/cockpit2/switches/generic_lights_switch[25]")
simDR_smoking_lighting			= find_dataref("sim/cockpit2/switches/generic_lights_switch[26]")
simDR_ife_screen_brightness		= find_dataref("sim/cockpit2/switches/generic_lights_switch[27]")
simDR_exit_signs				= find_dataref("sim/cockpit2/switches/generic_lights_switch[28]")
simDR_cabin_lighting_static		= find_dataref("sim/cockpit2/switches/generic_lights_switch[29]")
simDR_cabin_lighting_galley		= find_dataref("sim/cockpit2/switches/generic_lights_switch[30]")

simDR_cabin_reading_1			= find_dataref("sim/cockpit2/switches/generic_lights_switch[31]")
simDR_cabin_reading_2			= find_dataref("sim/cockpit2/switches/generic_lights_switch[32]")
simDR_cabin_reading_3			= find_dataref("sim/cockpit2/switches/generic_lights_switch[33]")
simDR_cabin_reading_4			= find_dataref("sim/cockpit2/switches/generic_lights_switch[34]")
simDR_cabin_reading_5			= find_dataref("sim/cockpit2/switches/generic_lights_switch[35]")
simDR_cabin_reading_6			= find_dataref("sim/cockpit2/switches/generic_lights_switch[36]")

simDR_generator_amps			= find_dataref("sim/cockpit2/electrical/generator_amps")
simDR_apu_gen_amps				= find_dataref("sim/cockpit2/electrical/APU_generator_amps")
simDR_battery_on				= find_dataref("sim/cockpit2/electrical/battery_on")
simDR_external_pwr_on			= find_dataref("sim/cockpit2/annunciators/external_power_on")

simDR_FMS1_brightness			= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[6]")
simDR_FMS2_brightness			= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[7]")
simDR_FMS3_brightness			= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[8]")
simDR_standby_brightness		= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[9]")

simDR_acars1_brightness			= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[18]")
simDR_acars2_brightness			= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[19]")

simDR_integ_brightness			= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[13]")
simDR_integ_glare_brightness	= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[14]")
simDR_pedestal_flood			= find_dataref("sim/cockpit2/switches/generic_lights_switch[15]")

simDR_sun_pitch					= find_dataref("sim/graphics/scenery/sun_pitch_degrees")
simDR_altitude					= find_dataref("sim/flightmodel2/position/pressure_altitude")
simDR_abs_radio_alt				= find_dataref("sim/flightmodel2/position/y_agl")

simDR_display_C_PFD				= find_dataref("sim/cockpit2/switches/generic_lights_switch[37]")
simDR_display_C_MFD				= find_dataref("sim/cockpit2/switches/generic_lights_switch[38]")
simDR_display_ECAM1				= find_dataref("sim/cockpit2/switches/generic_lights_switch[39]")
simDR_display_ECAM2				= find_dataref("sim/cockpit2/switches/generic_lights_switch[42]")
simDR_display_F_MFD				= find_dataref("sim/cockpit2/switches/generic_lights_switch[40]")
simDR_display_F_PFD				= find_dataref("sim/cockpit2/switches/generic_lights_switch[41]")
simDR_display_STBY				= find_dataref("sim/cockpit2/switches/generic_lights_switch[43]")

simDR_annun_bright				= find_dataref("sim/cockpit2/switches/generic_lights_switch")

simDR_display_C_PFD_bright		= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[0]")
simDR_display_C_MFD_bright		= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[1]")
simDR_display_ECAM1_bright		= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[2]")
simDR_display_ECAM2_bright		= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[3]")
simDR_display_F_MFD_bright		= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[4]")
simDR_display_F_PFD_bright		= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[5]")
simDR_display_STBY_bright		= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[9]")
simDR_display_AP_panel_bright	= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[10]")

simDR_integ_bright				= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[13]")
simDR_integ_mcp_bright			= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_auto[14]")

simDR_condensation_lighting		= find_dataref("sim/flightmodel2/misc/plugin_particle_light_leak")
simDR_wing_lighting_brightness	= find_dataref("sim/flightmodel2/lights/generic_lights_brightness_ratio[1]")



--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--
A333DR_trans_fail_annun			= find_dataref("laminar/A333/annun/transponder_fail")
A333DR_unspecified_annun		= find_dataref("laminar/A333/annun/inactive_unspecified2")
A333DR_door_status_annun		= find_dataref("laminar/A333/status/cockpit_door_manip_hide")

A333DR_door_green_LED			= find_dataref("laminar/A333/status/cockpit_door_keypad_green_led")
A333DR_door_red_LED				= find_dataref("laminar/A333/status/cockpit_door_keypad_red_led")
A333DR_door_white_LED			= find_dataref("laminar/A333/status/cockpit_door_keypad_white_led")

A333DR_IFEC_status				= find_dataref("laminar/A333/status/IFEC")
A333DR_commercial_status		= find_dataref("laminar/A333/status/commercial")
A333DR_galley_status			= find_dataref("laminar/A333/status/galley")
A333DR_flight_phase 			= find_dataref("laminar/A333/data/flight_phase")

A333DR_capt_cstr_annun			= find_dataref("laminar/A333/annun/EFIS_capt_cstr")
A333DR_capt_fix_annun			= find_dataref("laminar/A333/annun/EFIS_capt_fix")
A333DR_capt_vor_annun			= find_dataref("laminar/A333/annun/EFIS_capt_vor")
A333DR_capt_ndb_annun			= find_dataref("laminar/A333/annun/EFIS_capt_ndb")
A333DR_capt_arpt_annun			= find_dataref("laminar/A333/annun/EFIS_capt_arpt")

A333DR_fo_cstr_annun			= find_dataref("laminar/A333/annun/EFIS_fo_cstr")
A333DR_fo_fix_annun				= find_dataref("laminar/A333/annun/EFIS_fo_fix")
A333DR_fo_vor_annun				= find_dataref("laminar/A333/annun/EFIS_fo_vor")
A333DR_fo_ndb_annun				= find_dataref("laminar/A333/annun/EFIS_fo_ndb")
A333DR_fo_arpt_annun			= find_dataref("laminar/A333/annun/EFIS_fo_arpt")

A333DR_nose_green_annun			= find_dataref("laminar/A333/annun/landing_gear/nose_green")
A333DR_l_main_green_annun		= find_dataref("laminar/A333/annun/landing_gear/left_green")
A333DR_r_main_green_annun		= find_dataref("laminar/A333/annun/landing_gear/right_green")

A333DR_nose_red_annun			= find_dataref("laminar/A333/annun/landing_gear/nose_unlk")
A333DR_l_main_red_annun			= find_dataref("laminar/A333/annun/landing_gear/left_unlk")
A333DR_r_main_red_annun			= find_dataref("laminar/A333/annun/landing_gear/right_unlk")

A333DR_brake_fan_hot_annun		= find_dataref("laminar/A333/annun/landing_gear/brake_fan_hot")
A333DR_brake_fan_on_annun		= find_dataref("laminar/A333/annun/landing_gear/brake_fan_on")

A333DR_decel_lo_annun			= find_dataref("laminar/A333/annun/auto_brake/lo_decel")
A333DR_decel_med_annun			= find_dataref("laminar/A333/annun/auto_brake/med_decel")
A333DR_decel_max_annun			= find_dataref("laminar/A333/annun/auto_brake/max_decel")
A333DR_brake_lo_on_annun		= find_dataref("laminar/A333/annun/auto_brake/lo_on")
A333DR_brake_med_on_annun		= find_dataref("laminar/A333/annun/auto_brake/med_on")
A333DR_brake_max_on_annun		= find_dataref("laminar/A333/annun/auto_brake/max_on")

A333DR_mast_warn_annun			= find_dataref("laminar/A333/annun/master_warning")
A333DR_mast_caut_annun			= find_dataref("laminar/A333/annun/master_warning")
A333DR_auto_land_annun			= find_dataref("laminar/A333/annun/auto_land")
A333DR_atc_comm_annun			= find_dataref("laminar/A333/annun/atc_comm")

A333DR_gpws_annun				= find_dataref("laminar/A333/annun/GPWS_warn")
A333DR_gs_annun					= find_dataref("laminar/A333/annun/GS_warn")

A333_pfd1_display_state 		= find_dataref("laminar/A333/pfd1/display_state")
A333_pfd2_display_state 		= find_dataref("laminar/A333/pfd2/display_state")
A333_nd1_display_state 			= find_dataref("laminar/A333/nd1/display_state")
A333_nd2_display_state 			= find_dataref("laminar/A333/nd2/display_state")
A333_ewd_display_state 			= find_dataref("laminar/A333/ewd/display_state")
A333_sd_display_state 			= find_dataref("laminar/A333/sd/display_state")
A333_standby_display_state 		= find_dataref("laminar/A333/standby/display_state")

A333DR_ac_bus1_has_power 		= find_dataref("laminar/A333/elec/ac_bus1_has_power")
A333DR_ac_bus2_has_power 		= find_dataref("laminar/A333/elec/ac_bus2_has_power")
A333DR_ac_ess_bus_has_power		= find_dataref("laminar/A333/elec/ac_ess_bus_has_power")
A333DR_extA_gsb_has_power		= find_dataref("laminar/A333/elec/extA_ground_service_bus_has_power")

A333DR_ac_bus1_volts 			= find_dataref("laminar/A333/elec/ac_bus1_volts")
A333DR_ac_bus2_volts 			= find_dataref("laminar/A333/elec/ac_bus2_volts")

A333DR_ac_ess_shed_bus_has_power = find_dataref("laminar/A333/elec/ac_ess_shed_bus_has_power")
A333DR_ac_ess_grnd_bus_has_power = find_dataref("laminar/A333/elec/ac_ess_grnd_bus_has_power")

A333DR_dc_ess_bus_has_power		= find_dataref("laminar/A333/elec/dc_ess_bus_has_power")

A333DR_annun_cockpit_door_ctl_strike_top = find_dataref("laminar/A333/annun/cockpit_door_ctl_strike_top")
A333DR_annun_cockpit_door_ctl_strike_mid = find_dataref("laminar/A333/annun/cockpit_door_ctl_strike_mid")
A333DR_annun_cockpit_door_ctl_strike_btm = find_dataref("laminar/A333/annun/cockpit_door_ctl_strike_btm")
A333DR_annun_cockpit_door_ctl_channel1 = find_dataref("laminar/A333/annun/cockpit_door_ctl_channel1")
A333DR_annun_cockpit_door_ctl_channel2 = find_dataref("laminar/A333/annun/cockpit_door_ctl_channel2")
A333DR_annun_cockpit_door_ctl_strike_top_backup = find_dataref("laminar/A333/annun/cockpit_door_ctl_strike_top_backup")
A333DR_annun_cockpit_door_ctl_strike_mid_backup = find_dataref("laminar/A333/annun/cockpit_door_ctl_strike_mid_backup")
A333DR_annun_cockpit_door_ctl_strike_btm_backup = find_dataref("laminar/A333/annun/cockpit_door_ctl_strike_btm_backup")
A333DR_annun_cockpit_door_ctl_channel1_backup = find_dataref("laminar/A333/annun/cockpit_door_ctl_channel1_backup")
A333DR_annun_cockpit_door_ctl_channel2_backup = find_dataref("laminar/A333/annun/cockpit_door_ctl_channel2_backup")

--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
A333_wing_strobe_brightness		= create_dataref("laminar/A333/lights/wing_strobes_brightness", "number")
A333_strobe_switch_pos			= create_dataref("laminar/a333/switches/strobe_pos", "number")
A333_nav_light_switch_pos		= create_dataref("laminar/a333/switches/nav_pos", "number")

A333_dome_light_1_pos			= create_dataref("laminar/a333/switches/dome_1_pos", "number")
A333_dome_light_2_pos			= create_dataref("laminar/a333/switches/dome_2_pos", "number")
A333_dome_brightness_pos		= create_dataref("laminar/a333/switches/dome_brightness", "number")

A333_ann_light_switch_pos		= create_dataref("laminar/a333/switches/ann_light_pos", "number")
A333_emer_exit_lt_switch_pos	= create_dataref("laminar/a333/switches/emer_exit_lt_pos", "number")

A333_MCDU1_bright_setting		= create_dataref("laminar/a333/MCDU1/bright_setting", "number")
A333_MCDU2_bright_setting		= create_dataref("laminar/a333/MCDU2/bright_setting", "number")
A333_MCDU3_bright_setting		= create_dataref("laminar/a333/MCDU3/bright_setting", "number")

A333DR_lighting_power_ac1		= create_dataref("laminar/A333/plugin_power/lighting_ac1", "number")
A333DR_lighting_power_ac2		= create_dataref("laminar/A333/plugin_power/lighting_ac2", "number")
A333DR_lighting_power_ac_ess	= create_dataref("laminar/A333/plugin_power/lighting_ac_ess", "number")

--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--
function A333_flood_light_brightness_DRhandler() end

function A333_ped_flood_light_brightness_DRhandler()

	simDR_pedestal_flood = A333_ped_flood_light_brightness ^ 3
	pedestal_flood_listen = simDR_pedestal_flood

end

function A333_integ_light_brightness_DRhandler()

	simDR_integ_brightness = A333_integ_light_brightness ^ 3
	integ_listen = simDR_integ_brightness

end

function A333_integ_glare_brightness_DRhandler()

	simDR_integ_glare_brightness = A333_integ_glare_brightness ^ 3
	pedestal_flood_listen = simDR_integ_glare_brightness

end



--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--
A333_flood_light_brightness		= create_dataref("laminar/a333/rheostats/flood_brightness", "number", A333_flood_light_brightness_DRhandler)
A333_ped_flood_light_brightness	= create_dataref("laminar/a333/rheostats/ped_flood_brightness", "number", A333_ped_flood_light_brightness_DRhandler)
A333_integ_light_brightness		= create_dataref("laminar/a333/rheostats/integ_light_brightness", "number", A333_integ_light_brightness_DRhandler)
A333_integ_glare_brightness		= create_dataref("laminar/a333/rheostats/integ_glare_brightness", "number", A333_integ_glare_brightness_DRhandler)



--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                 X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				              CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--
function A333_strobe_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_strobe_switch_pos == 0 then
			A333_strobe_switch_pos = 1
		elseif A333_strobe_switch_pos == 1 then
			A333_strobe_switch_pos = 2
		end
	end
end

function A333_strobe_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_strobe_switch_pos == 2 then
			A333_strobe_switch_pos = 1
		elseif A333_strobe_switch_pos == 1 then
			A333_strobe_switch_pos = 0
		end
	end
end

function A333_strobe_switch_off_CMDhandler(phase, duration)
	if phase == 0 then
		A333_strobe_switch_pos = 0
	end
end

function A333_strobe_switch_auto_CMDhandler(phase, duration)
	if phase == 0 then
		A333_strobe_switch_pos = 1
	end
end

function A333_strobe_switch_on_CMDhandler(phase, duration)
	if phase == 0 then
		A333_strobe_switch_pos = 2
	end
end

function A333_rwy_turn_off_switch_on_CMDhandler(phase, duration)
    if phase == 0 then
        simDR_rwy_turn_off_lights_on = 1
    end
end

function A333_rwy_turn_off_switch_off_CMDhandler(phase, duration)
    if phase == 0 then
        simDR_rwy_turn_off_lights_on = 0
    end
end

function A333_nav_light_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_nav_light_switch_pos == 0 then
			A333_nav_light_switch_pos = 1
		elseif A333_nav_light_switch_pos == 1 then
			A333_nav_light_switch_pos = 2
		end
	end
end

function A333_nav_light_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_nav_light_switch_pos == 2 then
			A333_nav_light_switch_pos = 1
		elseif A333_nav_light_switch_pos == 1 then
			A333_nav_light_switch_pos = 0
		end
	end
end

function A333_dome_1_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_dome_light_1_pos == 0 then
			A333_dome_light_1_pos = 1
		end
	end
end

function A333_dome_1_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_dome_light_1_pos == 1 then
			A333_dome_light_1_pos = 0
		end
	end
end

function A333_dome_2_switch_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_dome_light_2_pos == 0 then
			A333_dome_light_2_pos = 1
		end
	end
end

function A333_dome_2_switch_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_dome_light_2_pos == 1 then
			A333_dome_light_2_pos = 0
		end
	end
end

function A333_dome_bright_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_dome_brightness_pos == 0 then
			A333_dome_brightness_pos = 1
		elseif A333_dome_brightness_pos == 1 then
			A333_dome_brightness_pos = 2
		end
	end
end

function A333_dome_bright_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_dome_brightness_pos == 2 then
			A333_dome_brightness_pos = 1
		elseif A333_dome_brightness_pos == 1 then
			A333_dome_brightness_pos = 0
		end
	end
end

function A333_ann_lt_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_ann_light_switch_pos == 0 then
			A333_ann_light_switch_pos = 1
		elseif A333_ann_light_switch_pos == 1 then
			A333_ann_light_switch_pos = 2
		end
	end
end

function A333_ann_lt_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_ann_light_switch_pos == 2 then
			A333_ann_light_switch_pos = 1
		elseif A333_ann_light_switch_pos == 1 then
			A333_ann_light_switch_pos = 0
		end
	end
end

function A333_emer_exit_lt_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_emer_exit_lt_switch_pos == 0 then
			A333_emer_exit_lt_switch_pos = 1
		elseif A333_emer_exit_lt_switch_pos == 1 then
			A333_emer_exit_lt_switch_pos = 2
		end
	end
end

function A333_emer_exit_lt_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_emer_exit_lt_switch_pos == 2 then
			A333_emer_exit_lt_switch_pos = 1
		elseif A333_emer_exit_lt_switch_pos == 1 then
			A333_emer_exit_lt_switch_pos = 0
		end
	end
end

--

function A333_fms1_brightness_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_MCDU1_bright_setting < 0.9 then
			A333_MCDU1_bright_setting = A333_MCDU1_bright_setting + 0.1
		elseif A333_MCDU1_bright_setting >= 0.9 then
			A333_MCDU1_bright_setting = 1
		end
	end
end

function A333_fms1_brightness_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_MCDU1_bright_setting > 0.1 then
			A333_MCDU1_bright_setting = A333_MCDU1_bright_setting - 0.1
		elseif A333_MCDU1_bright_setting <= 0.1 then
			A333_MCDU1_bright_setting = 0
		end
	end
end

--

function A333_fms2_brightness_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_MCDU2_bright_setting < 0.9 then
			A333_MCDU2_bright_setting = A333_MCDU2_bright_setting + 0.1
		elseif A333_MCDU2_bright_setting >= 0.9 then
			A333_MCDU2_bright_setting = 1
		end
	end
end

function A333_fms2_brightness_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_MCDU2_bright_setting > 0.1 then
			A333_MCDU2_bright_setting = A333_MCDU2_bright_setting - 0.1
		elseif A333_MCDU2_bright_setting <= 0.1 then
			A333_MCDU2_bright_setting = 0
		end
	end
end

--

function A333_fms3_brightness_up_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_MCDU3_bright_setting < 0.9 then
			A333_MCDU3_bright_setting = A333_MCDU3_bright_setting + 0.1
		elseif A333_MCDU3_bright_setting >= 0.9 then
			A333_MCDU3_bright_setting = 1
		end
	end
end

function A333_fms3_brightness_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_MCDU3_bright_setting > 0.1 then
			A333_MCDU3_bright_setting = A333_MCDU3_bright_setting - 0.1
		elseif A333_MCDU3_bright_setting <= 0.1 then
			A333_MCDU3_bright_setting = 0
		end
	end
end

--


function A333_standby_brightness_up_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_standby_brightness < 0.9 then
			simDR_standby_brightness = simDR_standby_brightness + 0.1
		elseif simDR_standby_brightness >= 0.9 then
			simDR_standby_brightness = 1
		end
	end
end

function A333_standby_brightness_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_standby_brightness > 0.2 then
			simDR_standby_brightness = simDR_standby_brightness - 0.1
		elseif simDR_standby_brightness <= 0.2 then
			simDR_standby_brightness = 0.1
		end
	end
end

function A333_acars1_brightness_up_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_acars1_brightness < 0.9 then
			simDR_acars1_brightness = simDR_acars1_brightness + 0.1
		elseif simDR_acars1_brightness >= 0.9 then
			simDR_acars1_brightness = 1
		end
	end
end

function A333_acars1_brightness_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_acars1_brightness > 0.2 then
			simDR_acars1_brightness = simDR_acars1_brightness - 0.1
		elseif simDR_acars1_brightness <= 0.2 then
			simDR_acars1_brightness = 0.1
		end
	end
end

function A333_acars2_brightness_up_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_acars2_brightness < 0.9 then
			simDR_acars2_brightness = simDR_acars2_brightness + 0.1
		elseif simDR_acars2_brightness >= 0.9 then
			simDR_acars2_brightness = 1
		end
	end
end

function A333_acars2_brightness_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_acars2_brightness > 0.2 then
			simDR_acars2_brightness = simDR_acars2_brightness - 0.1
		elseif simDR_acars2_brightness <= 0.2 then
			simDR_acars2_brightness = 0.1
		end
	end
end

--*************************************************************************************--
--** 				                 CUSTOM COMMANDS                			     **--
--*************************************************************************************--
A333CMD_strobe_switch_up		= create_command("laminar/A333/toggle_switch/strobe_pos_up", "Strobe Lights Up", A333_strobe_switch_up_CMDhandler)
A333CMD_strobe_switch_dn		= create_command("laminar/A333/toggle_switch/strobe_pos_dn", "Strobe Lights Down", A333_strobe_switch_dn_CMDhandler)

A333CMD_strobe_switch_off		= create_command("laminar/A333/toggle_switch/strobe_pos_off", "Strobe Lights Off", A333_strobe_switch_off_CMDhandler)
A333CMD_strobe_switch_auto		= create_command("laminar/A333/toggle_switch/strobe_pos_auto", "Strobe Lights Auto", A333_strobe_switch_auto_CMDhandler)
A333CMD_strobe_switch_on		= create_command("laminar/A333/toggle_switch/strobe_pos_on", "Strobe Lights On", A333_strobe_switch_on_CMDhandler)

A333CMD_rwy_turn_off_switch_on  = create_command("laminar/A333/toggle_switch/rwy_turn_off_on", "RWY Turn-Off Lights On", A333_rwy_turn_off_switch_on_CMDhandler)
A333CMD_rwy_turn_off_switch_off = create_command("laminar/A333/toggle_switch/rwy_turn_off_off", "RWY Turn-Off Lights Off", A333_rwy_turn_off_switch_off_CMDhandler)

A333CMD_nav_light_switch_up		= create_command("laminar/A333/toggle_switch/nav_light_pos_up", "NAV Lights Up", A333_nav_light_switch_up_CMDhandler)
A333CMD_nav_light_switch_dn		= create_command("laminar/A333/toggle_switch/nav_light_pos_dn", "NAV Lights Down", A333_nav_light_switch_dn_CMDhandler)

A333CMD_dome_1_switch_up		= create_command("laminar/A333/toggle_switch/dome_1_pos_up", "Dome Switch Up", A333_dome_1_switch_up_CMDhandler)
A333CMD_dome_1_switch_dn		= create_command("laminar/A333/toggle_switch/dome_1_pos_dn", "Dome Switch Down", A333_dome_1_switch_dn_CMDhandler)

A333CMD_dome_2_switch_up		= create_command("laminar/A333/toggle_switch/dome_2_pos_up", "Dome Switch Up", A333_dome_2_switch_up_CMDhandler)
A333CMD_dome_2_switch_dn		= create_command("laminar/A333/toggle_switch/dome_2_pos_dn", "Dome Switch Down", A333_dome_2_switch_dn_CMDhandler)

A333CMD_dome_bright_switch_up	= create_command("laminar/A333/toggle_switch/dome_bright_up", "Dome Brightness Up", A333_dome_bright_up_CMDhandler)
A333CMD_dome_bright_switch_dn	= create_command("laminar/A333/toggle_switch/dome_bright_dn", "Dome Brightness Down", A333_dome_bright_dn_CMDhandler)

A333CMD_ann_lt_switch_up		= create_command("laminar/A333/toggle_switch/ann_lt_up", "Annunciator Light Switch Up", A333_ann_lt_up_CMDhandler)
A333CMD_ann_lt_switch_dn		= create_command("laminar/A333/toggle_switch/ann_lt_dn", "Annunciator Light Switch Down", A333_ann_lt_dn_CMDhandler)

A333CMD_emer_exit_lt_switch_up	= create_command("laminar/A333/toggle_switch/emer_exit_lt_up", "Emergency Exit Light Switch Up", A333_emer_exit_lt_up_CMDhandler)
A333CMD_emer_exit_lt_switch_dn	= create_command("laminar/A333/toggle_switch/emer_exit_lt_dn", "Emergency Exit Light Switch Down", A333_emer_exit_lt_dn_CMDhandler)

A333CMD_fms1_brightness_up		= create_command("laminar/A333/buttons/fms1_brightness_up", "MCDU 1 Brightness Increase", A333_fms1_brightness_up_CMDhandler)
A333CMD_fms1_brightness_dn		= create_command("laminar/A333/buttons/fms1_brightness_dn", "MCDU 1 Brightness Derease", A333_fms1_brightness_dn_CMDhandler)
A333CMD_fms2_brightness_up		= create_command("laminar/A333/buttons/fms2_brightness_up", "MCDU 2 Brightness Increase", A333_fms2_brightness_up_CMDhandler)
A333CMD_fms2_brightness_dn		= create_command("laminar/A333/buttons/fms2_brightness_dn", "MCDU 2 Brightness Decrease", A333_fms2_brightness_dn_CMDhandler)
A333CMD_fms3_brightness_up		= create_command("laminar/A333/buttons/fms3_brightness_up", "MCDU 3 Brightness Increase", A333_fms3_brightness_up_CMDhandler)
A333CMD_fms3_brightness_dn		= create_command("laminar/A333/buttons/fms3_brightness_dn", "MCDU 3 Brightness Decrease", A333_fms3_brightness_dn_CMDhandler)

A333CMD_standby_brightness_up	= create_command("laminar/A333/buttons/standby_brightness_up", "Standby Brightness Increase", A333_standby_brightness_up_CMDhandler)
A333CMD_standby_brightness_dn	= create_command("laminar/A333/buttons/standby_brightness_dn", "Standby Brightness Decrease", A333_standby_brightness_dn_CMDhandler)

A333CMD_acars1_brightness_up	= create_command("laminar/A333/buttons/acars1_brightness_up", "ACARS 1 Brightness Increase", A333_acars1_brightness_up_CMDhandler)
A333CMD_acars1_brightness_dn	= create_command("laminar/A333/buttons/acars1_brightness_dn", "ACARS 1 Brightness Decrease", A333_acars1_brightness_dn_CMDhandler)

A333CMD_acars2_brightness_up	= create_command("laminar/A333/buttons/acars2_brightness_up", "ACARS 2 Brightness Increase", A333_acars2_brightness_up_CMDhandler)
A333CMD_acars2_brightness_dn	= create_command("laminar/A333/buttons/acars2_brightness_dn", "ACARS 2 Brightness Decrease", A333_acars2_brightness_dn_CMDhandler)

--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--

----- RESCALE ---------------------------------------------------------------------------
local function rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end




----- LIGHT RHEO ATTENUATION -----------------------------------------------------------
local function light_rheo_log_atten(listen, xp_bright, knob_pos, power_factor)

	if listen ~= xp_bright then
		knob_pos = xp_bright ^ (1/power_factor)
		listen = xp_bright
	end

	return knob_pos

end




local function A333_lights_rheo_listen()

	A333_ped_flood_light_brightness = light_rheo_log_atten(pedestal_flood_listen, simDR_pedestal_flood, A333_ped_flood_light_brightness, 3)
	A333_integ_light_brightness 	= light_rheo_log_atten(integ_listen, simDR_integ_brightness, A333_integ_light_brightness, 3)
	A333_integ_glare_brightness 	= light_rheo_log_atten(pedestal_flood_listen, simDR_integ_glare_brightness, A333_integ_glare_brightness, 3)

end




local function A333_dome_lighting()

	local sim_battery_on = simDR_battery_on
	local sim_generator_amps = simDR_generator_amps
	local sim_gear_on_ground = simDR_gear_on_ground
	local dome_light_1_pos = A333_dome_light_1_pos
	local dome_light_2_pos = A333_dome_light_2_pos
	local dome_brightness_pos = A333_dome_brightness_pos

	local any_bat_on = sim_battery_on[0] == 1 or sim_battery_on[1] == 1
	local any_elec_on = sim_generator_amps[0] > 0.1 or sim_generator_amps[1] > 0.1 or simDR_apu_gen_amps > 0.1 or simDR_external_pwr_on == 1
	local on_bat_only = any_bat_on and not any_elec_on
	local right_dome_bat_ground_on = on_bat_only and sim_gear_on_ground

	local right_dome_on = ((right_dome_bat_ground_on
		or (not right_dome_bat_ground_on and ((dome_light_1_pos == 0 and dome_light_2_pos == 1) or (dome_light_1_pos == 1 and dome_light_2_pos == 0))))
		and 1) or 0

	local left_dome_on = (((dome_light_1_pos == 0 and dome_light_2_pos == 1) or (dome_light_1_pos == 1 and dome_light_2_pos == 0)) and 1) or 0

	local dome_brightness_factor = (dome_brightness_pos == 1 and 1) or 0.25


	simDR_instrument_flood = (dome_brightness_pos == 2 and 1) or (A333_flood_light_brightness ^ 3)
	simDR_dome_left = (dome_brightness_pos == 2 and 1) or (left_dome_on * dome_brightness_factor)
	simDR_dome_right = (dome_brightness_pos == 2 and 1) or (right_dome_on * dome_brightness_factor)

end




local function A333_extra_cockpit_spills()

	local annun_bright_switch = simDR_annun_bright

	simDR_transponder_fail_spill = A333DR_trans_fail_annun
	simDR_generic_spill = A333DR_unspecified_annun

	simDR_door_green_spill = A333DR_door_green_LED
	simDR_door_red_spill = A333DR_door_red_LED
	simDR_door_white_spill = A333DR_door_white_LED

	simDR_display_STBY = ((A333_standby_display_state == 0 or A333DR_dc_ess_bus_has_power == 0) and 0) or simDR_display_STBY_bright

	simDR_display_C_PFD = ((A333_pfd1_display_state == 0 or A333DR_ac_ess_bus_has_power == 0) and 0) or simDR_display_C_PFD_bright
	simDR_display_C_MFD = ((A333_nd1_display_state == 0 or A333DR_ac_ess_shed_bus_has_power == 0) and 0) or simDR_display_C_MFD_bright
	simDR_display_ECAM1 = ((A333_ewd_display_state == 0 or A333DR_ac_ess_bus_has_power == 0) and 0) or simDR_display_ECAM1_bright
	simDR_display_ECAM2 = ((A333_sd_display_state == 0 or A333DR_ac_bus1_has_power == 0) and 0) or simDR_display_ECAM2_bright
	simDR_display_F_MFD = ((A333_nd2_display_state == 0 or A333DR_ac_bus2_has_power == 0) and 0) or simDR_display_F_MFD_bright
	simDR_display_F_PFD = ((A333_pfd2_display_state == 0 or A333DR_ac_bus2_has_power == 0) and 0) or simDR_display_F_PFD_bright

	annun_bright_switch[44] = A333DR_capt_cstr_annun ^ 0.5
	annun_bright_switch[45] = A333DR_capt_fix_annun ^ 0.5
	annun_bright_switch[46] = A333DR_capt_vor_annun ^ 0.5
	annun_bright_switch[47] = A333DR_capt_ndb_annun ^ 0.5
	annun_bright_switch[48] = A333DR_capt_arpt_annun ^ 0.5
	
	annun_bright_switch[49] = A333DR_fo_arpt_annun ^ 0.5
	annun_bright_switch[50] = A333DR_fo_ndb_annun ^ 0.5
	annun_bright_switch[51] = A333DR_fo_vor_annun ^ 0.5
	annun_bright_switch[52] = A333DR_fo_fix_annun ^ 0.5
	annun_bright_switch[53] = A333DR_fo_cstr_annun ^ 0.5

	annun_bright_switch[54] = A333DR_nose_green_annun ^ 0.5
	annun_bright_switch[55] = A333DR_l_main_green_annun ^ 0.5
	annun_bright_switch[56] = A333DR_r_main_green_annun ^ 0.5
	annun_bright_switch[57] = A333DR_nose_red_annun ^ 0.5
	annun_bright_switch[58] = A333DR_l_main_red_annun ^ 0.5
	annun_bright_switch[59] = A333DR_r_main_red_annun ^ 0.5

	annun_bright_switch[60] = A333DR_brake_fan_hot_annun ^ 0.5
	annun_bright_switch[61] = A333DR_brake_fan_on_annun ^ 0.5

	annun_bright_switch[62] = A333DR_decel_lo_annun ^ 0.5
	annun_bright_switch[63] = A333DR_decel_med_annun ^ 0.5
	annun_bright_switch[64] = A333DR_decel_max_annun ^ 0.5
	annun_bright_switch[65] = A333DR_brake_lo_on_annun ^ 0.5
	annun_bright_switch[66] = A333DR_brake_med_on_annun ^ 0.5
	annun_bright_switch[67] = A333DR_brake_max_on_annun ^ 0.5
	
	annun_bright_switch[68] = A333DR_mast_warn_annun ^ 0.5
	annun_bright_switch[69] = A333DR_mast_caut_annun ^ 0.5
	annun_bright_switch[70] = A333DR_auto_land_annun ^ 0.5
	annun_bright_switch[71] = A333DR_atc_comm_annun ^ 0.5
	
	annun_bright_switch[72] = A333DR_gpws_annun ^ 0.5
	annun_bright_switch[73] = A333DR_gs_annun ^ 0.5
	
	annun_bright_switch[74] = ((A333DR_ac_ess_bus_has_power == 1) and simDR_display_AP_panel_bright) or 0
	
	annun_bright_switch[75] = simDR_integ_bright ^ 0.5
	annun_bright_switch[76] = simDR_integ_mcp_bright ^ 0.5

	annun_bright_switch[78] = A333DR_annun_cockpit_door_ctl_strike_top
	annun_bright_switch[79] = A333DR_annun_cockpit_door_ctl_strike_mid
	annun_bright_switch[80] = A333DR_annun_cockpit_door_ctl_strike_btm
	annun_bright_switch[81] = A333DR_annun_cockpit_door_ctl_channel1
	annun_bright_switch[82] = A333DR_annun_cockpit_door_ctl_channel2
	annun_bright_switch[83] = A333DR_annun_cockpit_door_ctl_strike_top_backup
	annun_bright_switch[84] = A333DR_annun_cockpit_door_ctl_strike_mid_backup
	annun_bright_switch[85] = A333DR_annun_cockpit_door_ctl_strike_btm_backup
	annun_bright_switch[86] = A333DR_annun_cockpit_door_ctl_channel1_backup
	annun_bright_switch[87] = A333DR_annun_cockpit_door_ctl_channel2_backup

end




local function A333_cabin_lights()

	local flight_phase = A333DR_flight_phase
	local sun_pitch = simDR_sun_pitch
	local abs_radio_alt = simDR_abs_radio_alt
	local altitude = simDR_altitude
	local ac1_ac2_balance = 0 -- 0 = all on ac2, 1 = all on ac1, 0.5 = equal split
	local ac2_ac1_balance = 0 -- 0 = all on ac1, 1 = all on ac2, 0.5 = equal split

	if flight_phase <= 5 then
		descent_flag = 0
	end

	if flight_phase == 6 and altitude > 18000 then
		descent_flag = 1
	end
	
	if flight_phase >= 7 and flight_phase <= 9 then
		descent_flag = 1
	end
	
	if flight_phase == 10 then
		descent_flag = 0
	end
	

	sun_factor = rescale(-2, 0.05, -1, 1, sun_pitch)
	sun_factor2 = rescale(-2, 0.2, -1, 1, sun_pitch)
	

	local seatbelt_signs = simDR_seatbelt_signs
	local smoking_signs = simDR_smoking_signs
	local exit_signs = simDR_exit_signs
	local emer_exit_lt_switch_pos = A333_emer_exit_lt_switch_pos

	local ac_ess_bus_has_pwr = A333DR_ac_ess_bus_has_power
	local ac_bus1_has_pwr = A333DR_ac_bus1_has_power
	local ac_bus2_has_pwr = A333DR_ac_bus2_has_power

	local commercial_status = ((A333DR_commercial_status == 1 and (A333DR_ac_bus1_has_power == 1 or A333DR_ac_bus2_has_power == 1)) and 1) or 0

	simDR_seatbelt_lighting = seatbelt_signs * sun_factor2 * ac_ess_bus_has_pwr
	simDR_smoking_lighting = smoking_signs * sun_factor2 * ac_ess_bus_has_pwr

	if A333DR_IFEC_status == 1 and ac_bus2_has_pwr == 1 and A333DR_commercial_status == 1 then
		if ife_startup_timer < 30 then
			ife_startup_timer = ife_startup_timer + lcl_SIM_PERIOD
			ife_status = 0
			IFE_system_power = 10
		else ife_startup_timer = 30
			ife_status = 1
			IFE_system_power = 45
		end
	else ife_startup_timer = 0
			ife_status = 0
			IFE_system_power = 0
	end

	simDR_ife_screen_brightness = ife_status * sun_factor

	if emer_exit_lt_switch_pos == 0 then
		exit_signs = smoking_signs * sun_factor2 * ac_ess_bus_has_pwr
	elseif emer_exit_lt_switch_pos == 1 then								--- TODO, ADD ARM CONDITIONS
		exit_signs = smoking_signs * sun_factor2 * ac_ess_bus_has_pwr
	elseif emer_exit_lt_switch_pos == 2 then
		exit_signs = sun_factor2 * ac_ess_bus_has_pwr
	end
	simDR_exit_signs = exit_signs

	seatbelt_light_power = rescale(0, 0, 1, 2.5, (simDR_seatbelt_lighting ^ 0.5))
	smoking_light_power = rescale(0, 0, 1, 2.5, (simDR_smoking_lighting ^ 0.5))
	exit_light_power = rescale(0, 0, 1, 1.5, (exit_signs ^ 0.5))



	if flight_phase <= 1 or flight_phase == 10 then

		if sun_pitch > 0 then
			phase_factor = 1
			galley_phase_factor = 1

		elseif sun_pitch <= 0 and sun_pitch > -2 then
			phase_factor = 0.7
			galley_phase_factor = 0.6

		elseif sun_pitch <= -2 then
			phase_factor = 0.4
			galley_phase_factor = 0.2
		end

	else
		if sun_pitch > 0 then

			if abs_radio_alt <= 3000 then
				phase_factor = 0.0
				galley_phase_factor = 0.6

			elseif abs_radio_alt > 3000 then
				phase_factor = 0.5
				galley_phase_factor = 1
			end

		elseif sun_pitch <= 0 and sun_pitch > -2 then

			if abs_radio_alt <= 3000 then
				phase_factor = 0.0
				galley_phase_factor = 0.2

			elseif abs_radio_alt > 3000 then
				phase_factor = 0.15
				galley_phase_factor = 0.6
			end

		elseif sun_pitch <= -2 then

			if altitude < 18000 then

				if descent_flag == 0 then
					if abs_radio_alt <= 3000 then
						phase_factor = 0.0
						galley_phase_factor = 0.03
					elseif abs_radio_alt > 3000 then
						phase_factor = 0.01
						galley_phase_factor = 0.1
					end

				elseif descent_flag == 1 then
					if abs_radio_alt < 3000 and abs_radio_alt > 1250 then -- lights to 'full' for final cabin check prior to night landing - turn lights OFF for landing
						phase_factor = 0.4
						galley_phase_factor = 0.2
					elseif abs_radio_alt <= 1250 then
						phase_factor = 0.0
						galley_phase_factor = 0.0
					end
				end

			elseif altitude >= 18000 then
				phase_factor = rescale(31000, 0.01, 33000, 0, altitude)
				galley_phase_factor = rescale(31000, 0.1, 33000, 0.03, altitude)
			end
		end

	end

	simDR_galley_screen_brightness = (commercial_status == 1 and A333DR_galley_status * sun_factor) or 0
	simDR_cabin_lighting = (commercial_status == 1 and phase_factor) or 0
	simDR_cabin_lighting_galley = (commercial_status == 1 and galley_phase_factor) or 0
	simDR_cabin_lighting_static = (commercial_status == 1 and 1) or 0

	galley_power = ((commercial_status == 1 and A333DR_galley_status == 1) and 20) or 0
	galley_lighting_power = rescale(0, 0, 1, 3, (simDR_cabin_lighting_galley ^ 0.5))
	cabin_light_power = rescale(0, 0, 1, 5, simDR_cabin_lighting_static)
	cabin_light_dynamic_power = rescale(0, 0, 1, 7.5, (simDR_cabin_lighting ^ 0.5))

	if A333DR_ac_bus1_has_power == A333DR_ac_bus2_has_power then
		ac1_ac2_balance = 0.5
		ac2_ac1_balance = 0.5
	elseif A333DR_ac_bus1_has_power == 0 and A333DR_ac_bus2_has_power == 1 then
		ac1_ac2_balance = 0
		ac2_ac1_balance = 1
	elseif A333DR_ac_bus1_has_power == 1 and A333DR_ac_bus2_has_power == 0 then
		ac1_ac2_balance = 1
		ac2_ac1_balance = 0
	end

	A333DR_lighting_power_ac_ess = seatbelt_light_power + smoking_light_power + exit_light_power
	A333DR_lighting_power_ac1 = (galley_power + galley_lighting_power + cabin_light_power + cabin_light_dynamic_power) * ac1_ac2_balance
	A333DR_lighting_power_ac2 = ((galley_power + galley_lighting_power + cabin_light_power + cabin_light_dynamic_power) * ac2_ac1_balance) + IFE_system_power

end




local function A333_cabin_reading_lights()

	local commercial_status = ((A333DR_commercial_status == 1 and (A333DR_ac_bus1_has_power == 1 or A333DR_ac_bus2_has_power == 1)) and 1) or 0


	if time_off_timer1 > time_off1 then
		time_off_timer1 = 0
		light1_on = 1
		time_off1 = m.random(4, 20)
	elseif time_off_timer1 <= time_off1 then
		time_off_timer1 = time_off_timer1 + lcl_SIM_PERIOD/60
	end

	if time_on_timer1 > time_on1 then
		time_on_timer1 = 0
		light1_on = 0
		time_on1 = m.random(2, 16)
	elseif time_on_timer1 <= time_on1 then
		if light1_on == 1 then
			time_on_timer1 = time_on_timer1 + lcl_SIM_PERIOD/60
		elseif light1_on == 0 then
			time_on_timer1 = 0
		end
	end

---

	if time_off_timer2 > time_off2 then
		time_off_timer2 = 0
		light2_on = 1
		time_off2 = m.random(4, 20)
	elseif time_off_timer2 <= time_off2 then
		time_off_timer2 = time_off_timer2 + lcl_SIM_PERIOD/60
	end

	if time_on_timer2 > time_on2 then
		time_on_timer2 = 0
		light2_on = 0
		time_on2 = m.random(2, 16)
	elseif time_on_timer2 <= time_on2 then
		if light2_on == 1 then
			time_on_timer2 = time_on_timer2 + lcl_SIM_PERIOD/60
		elseif light2_on == 0 then
			time_on_timer2 = 0
		end
	end

---

	if time_off_timer3 > time_off3 then
		time_off_timer3 = 0
		light3_on = 1
		time_off3 = m.random(4, 20)
	elseif time_off_timer3 <= time_off3 then
		time_off_timer3 = time_off_timer3 + lcl_SIM_PERIOD/60
	end

	if time_on_timer3 > time_on3 then
		time_on_timer3 = 0
		light3_on = 0
		time_on3 = m.random(2, 16)
	elseif time_on_timer3 <= time_on3 then
		if light3_on == 1 then
			time_on_timer3 = time_on_timer3 + lcl_SIM_PERIOD/60
		elseif light3_on == 0 then
			time_on_timer3 = 0
		end
	end

---

	if time_off_timer4 > time_off4 then
		time_off_timer4 = 0
		light4_on = 1
		time_off4 = m.random(4, 20)
	elseif time_off_timer4 <= time_off4 then
		time_off_timer4 = time_off_timer4 + lcl_SIM_PERIOD/60
	end

	if time_on_timer4 > time_on4 then
		time_on_timer4 = 0
		light4_on = 0
		time_on4 = m.random(2, 16)
	elseif time_on_timer4 <= time_on4 then
		if light4_on == 1 then
			time_on_timer4 = time_on_timer4 + lcl_SIM_PERIOD/60
		elseif light4_on == 0 then
			time_on_timer4 = 0
		end
	end

---

	if time_off_timer5 > time_off5 then
		time_off_timer5 = 0
		light5_on = 1
		time_off5 = m.random(4, 20)
	elseif time_off_timer5 <= time_off5 then
		time_off_timer5 = time_off_timer5 + lcl_SIM_PERIOD/60
	end

	if time_on_timer5 > time_on5 then
		time_on_timer5 = 0
		light5_on = 0
		time_on5 = m.random(2, 16)
	elseif time_on_timer5 <= time_on5 then
		if light5_on == 1 then
			time_on_timer5 = time_on_timer5 + lcl_SIM_PERIOD/60
		elseif light5_on == 0 then
			time_on_timer5 = 0
		end
	end

---

	if time_off_timer6 > time_off6 then
		time_off_timer6 = 0
		light6_on = 1
		time_off6 = m.random(4, 20)
	elseif time_off_timer6 <= time_off6 then
		time_off_timer6 = time_off_timer6 + lcl_SIM_PERIOD/60
	end

	if time_on_timer6 > time_on6 then
		time_on_timer6 = 0
		light6_on = 0
		time_on6 = m.random(2, 16)
	elseif time_on_timer6 <= time_on6 then
		if light6_on == 1 then
			time_on_timer6 = time_on_timer6 + lcl_SIM_PERIOD/60
		elseif light6_on == 0 then
			time_on_timer6 = 0
		end

	end


	simDR_cabin_reading_1 = (commercial_status == 1 and light1_on) or 0
	simDR_cabin_reading_2 = (commercial_status == 1 and light2_on) or 0
	simDR_cabin_reading_3 = (commercial_status == 1 and light3_on) or 0
	simDR_cabin_reading_4 = (commercial_status == 1 and light4_on) or 0
	simDR_cabin_reading_5 = (commercial_status == 1 and light5_on) or 0
	simDR_cabin_reading_6 = (commercial_status == 1 and light6_on) or 0


end

local function A333_MCDU_brightness_manager()

	simDR_FMS1_brightness = (A333DR_ac_ess_shed_bus_has_power == 1 and A333_MCDU1_bright_setting) or 0
	simDR_FMS2_brightness = (A333DR_ac_bus2_has_power == 1 and A333_MCDU2_bright_setting) or 0
	simDR_FMS3_brightness = (A333DR_ac_ess_grnd_bus_has_power == 1 and A333_MCDU3_bright_setting) or 0	

end


local function A333_beacons_strobes()

	local nav_light_switch_pos = A333_nav_light_switch_pos
	local gear_on_ground = simDR_gear_on_ground
	local flap_deploy_ratio = simDR_flap_deploy_ratio

	simDR_nav_lights_on = ((nav_light_switch_pos == 1 or nav_light_switch_pos == 2) and 1) or 0
	simDR_logo_lights = (((nav_light_switch_pos == 1  or nav_light_switch_pos == 2) and ((gear_on_ground == 1) or (gear_on_ground == 0 and flap_deploy_ratio >= 0.5))) and 1) or 0



	local strobe_switch_pos = A333_strobe_switch_pos
	local strobe_on = simDR_strobe_on
	local sim_time_factor = m.fmod(simDR_flight_time, 1.1)
	local strobe1 = ((sim_time_factor >= 0 and sim_time_factor <= 0.05) and 1) or 0
	local strobe2 = ((sim_time_factor >= 0.2 and sim_time_factor <= 0.25) and 1) or 0
	local beacon = ((sim_time_factor >= 0.6 and sim_time_factor <= 0.65) and 1) or 0
	local bus1_volts = simDR_bus1_volts
	local bus2_volts = simDR_bus2_volts
	local bus1_status = (A333DR_ac_bus1_has_power == 1) and 1 or rescale(4, 0, 20, 1, bus1_volts)
	local bus2_status = (A333DR_ac_bus2_has_power == 1) and 1 or rescale(4, 0, 20, 1, bus2_volts)

	simDR_beacon_strobe_ovrd = 1
	simDR_strobe_on = (((strobe_switch_pos == 1 and gear_on_ground == 0) or strobe_switch_pos == 2) and 1) or 0
	simDR_strobe1 = strobe1 * strobe_on * bus2_status
	simDR_strobe2 = strobe2 * strobe_on * bus2_status
	simDR_beacon = beacon * simDR_beacon_on * bus1_status

	A333_wing_strobe_brightness = simDR_strobe1 + simDR_strobe2
	simDR_landing_light3 = simDR_landing_light1

	simDR_condensation_lighting	= simDR_wing_lighting_brightness
	
end




--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--
local function A333_ALL_lighting()

	lcl_SIM_PERIOD = SIM_PERIOD

	A333_lights_rheo_listen()
	A333_beacons_strobes()
	A333_dome_lighting()
	A333_extra_cockpit_spills()
	A333_cabin_lights()
	A333_cabin_reading_lights()
	A333_MCDU_brightness_manager()

end

--function aircraft_load() end

--function aircraft_unload() end

--function flight_start() end

--function flight_crash() end

--function before_physics()

function after_physics()

	A333_ALL_lighting()

end

function after_replay()

	A333_ALL_lighting()

end



