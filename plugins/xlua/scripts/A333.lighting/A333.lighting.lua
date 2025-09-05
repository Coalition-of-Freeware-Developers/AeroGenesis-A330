jit.off()
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
*        COPYRIGHT © 2021 Alex Unruh / LAMINAR RESEARCH - ALL RIGHTS RESERVED	        *
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

local integ_listen				= 0
local integ_glare_listen		= 0
local pedestal_flood_listen		= 0
local sun_factor				= 0
local phase_factor				= 0
local galley_phase_factor		= 0

local time_off1 = math.random(4, 20)
local time_on1 = math.random(2, 16)
local time_on_timer1 = 0
local time_off_timer1 = 0
local light1_on = 0

local time_off2 = math.random(4, 20)
local time_on2 = math.random(2, 16)
local time_on_timer2 = 0
local time_off_timer2 = 0
local light2_on = 0

local time_off3 = math.random(4, 20)
local time_on3 = math.random(2, 16)
local time_on_timer3 = 0
local time_off_timer3 = 0
local light3_on = 0

local time_off4 = math.random(4, 20)
local time_on4 = math.random(2, 16)
local time_on_timer4 = 0
local time_off_timer4 = 0
local light4_on = 0

local time_off5 = math.random(4, 20)
local time_on5 = math.random(2, 16)
local time_on_timer5 = 0
local time_off_timer5 = 0
local light5_on = 0

local time_off6 = math.random(4, 20)
local time_on6 = math.random(2, 16)
local time_on_timer6 = 0
local time_off_timer6 = 0
local light6_on = 0

local descent_flag = 0

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
simDR_door_open_spill			= find_dataref("sim/cockpit2/switches/generic_lights_switch[21]")
simDR_door_closed_spill			= find_dataref("sim/cockpit2/switches/generic_lights_switch[22]")

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

simDR_generator_amps1			= find_dataref("sim/cockpit2/electrical/generator_amps[0]")
simDR_generator_amps2			= find_dataref("sim/cockpit2/electrical/generator_amps[1]")
simDR_apu_gen_amps				= find_dataref("sim/cockpit2/electrical/APU_generator_amps")
simDR_battery1_on				= find_dataref("sim/cockpit2/electrical/battery_on[0])")
simDR_battery2_on				= find_dataref("sim/cockpit2/electrical/battery_on[1])")
simDR_external_pwr_on			= find_dataref("sim/cockpit2/annunciators/external_power_on")

simDR_FMS1_brightness			= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[6]")
simDR_FMS2_brightness			= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[7]")
simDR_standby_brightness		= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[9]")

simDR_integ_brightness			= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[13]")
simDR_integ_glare_brightness	= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[14]")
simDR_pedestal_flood			= find_dataref("sim/cockpit2/switches/generic_lights_switch[15]")

simDR_sun_pitch					= find_dataref("sim/graphics/scenery/sun_pitch_degrees")
simDR_altitude					= find_dataref("sim/flightmodel2/position/pressure_altitude")
simDR_abs_radio_alt				= find_dataref("sim/flightmodel2/position/y_agl")

simDR_display_C_PFD				= find_dataref("sim/cockpit2/switches/generic_lights_switch[37]")
simDR_display_C_MFD				= find_dataref("sim/cockpit2/switches/generic_lights_switch[38]")
simDR_display_ECAM1				= find_dataref("sim/cockpit2/switches/generic_lights_switch[39]")
simDR_display_ECAM2				= find_dataref("sim/cockpit2/switches/generic_lights_switch[40]")
simDR_display_F_MFD				= find_dataref("sim/cockpit2/switches/generic_lights_switch[41]")
simDR_display_F_PFD				= find_dataref("sim/cockpit2/switches/generic_lights_switch[42]")
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

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

A333DR_trans_fail_annun			= find_dataref("laminar/A333/annun/transponder_fail")
A333DR_unspecified_annun		= find_dataref("laminar/A333/annun/inactive_unspecified2")
A333DR_door_status_annun		= find_dataref("laminar/A333/status/cockpit_door_manip_hide")

A333DR_IFEC_status				= find_dataref("laminar/A333/status/IFEC")
A333DR_commercial_status		= find_dataref("laminar/A333/status/commercial")
A333DR_galley_status			= find_dataref("laminar/A333/status/galley")
A333DR_flight_phase 			= find_dataref("laminar/A333/data/flight_phase")

A333DR_displays_powered			= find_dataref("laminar/A333/PFD/displays_powered")

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

-- STROBE LIGHTS - off, auto, on ... 0,1,2

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
		if simDR_FMS1_brightness < 0.9 then
			simDR_FMS1_brightness = simDR_FMS1_brightness + 0.1
		elseif simDR_FMS1_brightness >= 0.9 then
			simDR_FMS1_brightness = 1
		end
	end
end

function A333_fms1_brightness_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_FMS1_brightness > 0.1 then
			simDR_FMS1_brightness = simDR_FMS1_brightness - 0.1
		elseif simDR_FMS1_brightness <= 0.1 then
			simDR_FMS1_brightness = 0
		end
	end
end

--

function A333_fms2_brightness_up_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_FMS2_brightness < 0.9 then
			simDR_FMS2_brightness = simDR_FMS2_brightness + 0.1
		elseif simDR_FMS2_brightness >= 0.9 then
			simDR_FMS2_brightness = 1
		end
	end
end

function A333_fms2_brightness_dn_CMDhandler(phase, duration)
	if phase == 0 then
		if simDR_FMS2_brightness > 0.1 then
			simDR_FMS2_brightness = simDR_FMS2_brightness - 0.1
		elseif simDR_FMS2_brightness <= 0.1 then
			simDR_FMS2_brightness = 0
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
		if simDR_standby_brightness > 0.1 then
			simDR_standby_brightness = simDR_standby_brightness - 0.1
		elseif simDR_standby_brightness <= 0.1 then
			simDR_standby_brightness = 0
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

A333CMD_rwy_turn_off_switch_on  = create_command("laminar/A333/toggle_switch/rwy_turn_off_on", "RWY Turn Off Lights On", A333_rwy_turn_off_switch_on_CMDhandler)
A333CMD_rwy_turn_off_switch_off = create_command("laminar/A333/toggle_switch/rwy_turn_off_off", "TRY Turn Off Lights Off", A333_rwy_turn_off_switch_off_CMDhandler)

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

A333CMD_fms1_brightness_up		= create_command("laminar/A333/buttons/fms1_brightness_up", "FMS 1 Brightness Increase", A333_fms1_brightness_up_CMDhandler)
A333CMD_fms1_brightness_dn		= create_command("laminar/A333/buttons/fms1_brightness_dn", "FMS 1 Brightness Derease", A333_fms1_brightness_dn_CMDhandler)
A333CMD_fms2_brightness_up		= create_command("laminar/A333/buttons/fms2_brightness_up", "FMS 2 Brightness Increase", A333_fms2_brightness_up_CMDhandler)
A333CMD_fms2_brightness_dn		= create_command("laminar/A333/buttons/fms2_brightness_dn", "FMS 2 Brightness Decrease", A333_fms2_brightness_dn_CMDhandler)

A333CMD_standby_brightness_up	= create_command("laminar/A333/buttons/standby_brightness_up", "Standby Brightness Increase", A333_standby_brightness_up_CMDhandler)
A333CMD_standby_brightness_dn	= create_command("laminar/A333/buttons/standby_brightness_dn", "Standby Brightness Decrease", A333_standby_brightness_dn_CMDhandler)


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

----- LIGHT RHEO ATTENUATION -----------------------------------------------------------

function A333_light_rheo_log_atten(listen, xp_bright, knob_pos, power_factor)

	if listen ~= xp_bright then
		knob_pos = xp_bright ^ (1/power_factor)
		listen = xp_bright
	end

	return knob_pos

end

function A333_lights_rheo_listen()

	A333_ped_flood_light_brightness = A333_light_rheo_log_atten(pedestal_flood_listen, simDR_pedestal_flood, A333_ped_flood_light_brightness, 3)
	A333_integ_light_brightness 	= A333_light_rheo_log_atten(integ_listen, simDR_integ_brightness, A333_integ_light_brightness, 3)
	A333_integ_glare_brightness 	= A333_light_rheo_log_atten(pedestal_flood_listen, simDR_integ_glare_brightness, A333_integ_glare_brightness, 3)

end


function A333_dome_lighting()

	local on_bat_only = 0
	local any_bat_on = 0
	local any_elec_on = 0
	local right_dome_bat_ground_on = 0

	local dome_brightness_factor = 0
	local left_dome_on = 0
	local right_dome_on = 0

	if simDR_battery1_on == 1 or simDR_battery2_on == 1 then
		any_bat_on = 1
	elseif simDR_battery1_on == 0 and simDR_battery2_on == 0 then
		any_bat_on = 0
	end

	if simDR_generator_amps1 > 0.1 or simDR_generator_amps2 > 0.1 or simDR_apu_gen_amps > 0.1 or simDR_external_pwr_on == 1 then
		any_elec_on = 1
	elseif simDR_generator_amps1 == 0 and simDR_generator_amps2 == 0 and simDR_apu_gen_amps == 0 and simDR_external_pwr_on == 0 then
		any_elec_on = 0
	end

	if any_bat_on == 1 then
		if any_elec_on == 0 then
			on_bat_only = 1
		elseif any_elec_on == 1 then
			on_bat_only = 0
		end
	elseif any_bat_on == 0 then
		on_bat_only = 0
	end

	if on_bat_only == 1 and simDR_gear_on_ground == 1 then
		right_dome_bat_ground_on = 1
	else right_dome_bat_ground_on = 0
	end

	if right_dome_bat_ground_on == 1 then
		right_dome_on = 1
	elseif right_dome_bat_ground_on == 0 then
		if A333_dome_light_1_pos == 0 then
			if A333_dome_light_2_pos == 0 then
				right_dome_on = 0
			elseif A333_dome_light_2_pos == 1 then
				right_dome_on = 1
			end
		elseif A333_dome_light_1_pos == 1 then
			if A333_dome_light_2_pos == 0 then
				right_dome_on = 1
			elseif A333_dome_light_2_pos == 1 then
				right_dome_on = 0
			end
		end
	end


	if A333_dome_light_1_pos == 0 then
		if A333_dome_light_2_pos == 0 then
			left_dome_on = 0
		elseif A333_dome_light_2_pos == 1 then
			left_dome_on = 1
		end
	elseif A333_dome_light_1_pos == 1 then
		if A333_dome_light_2_pos == 0 then
			left_dome_on = 1
		elseif A333_dome_light_2_pos == 1 then
			left_dome_on = 0
		end
	end


	if A333_dome_brightness_pos == 0 then
		dome_brightness_factor = 0.25
	elseif A333_dome_brightness_pos == 1 then
		dome_brightness_factor = 1
	end

	if A333_dome_brightness_pos <= 1 then
		simDR_instrument_flood = A333_flood_light_brightness ^ 3
		simDR_dome_left = left_dome_on * dome_brightness_factor
		simDR_dome_right = right_dome_on * dome_brightness_factor
	elseif A333_dome_brightness_pos == 2 then
		simDR_instrument_flood = 1
		simDR_dome_left = 1
		simDR_dome_right = 1
	end


end

function A333_extra_cockpit_spills()

	simDR_transponder_fail_spill = A333DR_trans_fail_annun
	simDR_generic_spill = A333DR_unspecified_annun

	if A333DR_door_status_annun == 0 then
		simDR_door_open_spill = 1
		simDR_door_closed_spill = 0
	 elseif A333DR_door_status_annun == 1 then
		simDR_door_open_spill = 0
		simDR_door_closed_spill = 1
	end

	if A333DR_displays_powered == 0 then -- TODO, BUS SPECIFIC SHOW HIDES
		simDR_display_C_PFD = 0
		simDR_display_C_MFD = 0
		simDR_display_F_MFD = 0
		simDR_display_F_PFD = 0
	else
		simDR_display_C_PFD = simDR_display_C_PFD_bright
		simDR_display_C_MFD = simDR_display_C_MFD_bright
		simDR_display_F_MFD = simDR_display_F_MFD_bright
		simDR_display_F_PFD = simDR_display_F_PFD_bright
	end

	simDR_display_ECAM1 = simDR_display_ECAM1_bright
	simDR_display_ECAM2 = simDR_display_ECAM2_bright
	simDR_display_STBY = simDR_display_STBY_bright

	simDR_annun_bright[44] = A333DR_capt_cstr_annun
	simDR_annun_bright[45] = A333DR_capt_fix_annun
	simDR_annun_bright[46] = A333DR_capt_vor_annun
	simDR_annun_bright[47] = A333DR_capt_ndb_annun
	simDR_annun_bright[48] = A333DR_capt_arpt_annun
	
	simDR_annun_bright[49] = A333DR_fo_arpt_annun
	simDR_annun_bright[50] = A333DR_fo_ndb_annun
	simDR_annun_bright[51] = A333DR_fo_vor_annun
	simDR_annun_bright[52] = A333DR_fo_fix_annun
	simDR_annun_bright[53] = A333DR_fo_cstr_annun

	simDR_annun_bright[54] = A333DR_nose_green_annun ^ 0.5
	simDR_annun_bright[55] = A333DR_l_main_green_annun ^ 0.5
	simDR_annun_bright[56] = A333DR_r_main_green_annun ^ 0.5
	simDR_annun_bright[57] = A333DR_nose_red_annun ^ 0.5
	simDR_annun_bright[58] = A333DR_l_main_red_annun ^ 0.5
	simDR_annun_bright[59] = A333DR_r_main_red_annun ^ 0.5

	simDR_annun_bright[60] = A333DR_brake_fan_hot_annun ^ 0.5
	simDR_annun_bright[61] = A333DR_brake_fan_on_annun ^ 0.5

	simDR_annun_bright[62] = A333DR_decel_lo_annun ^ 0.5
	simDR_annun_bright[63] = A333DR_decel_med_annun ^ 0.5
	simDR_annun_bright[64] = A333DR_decel_max_annun ^ 0.5
	simDR_annun_bright[65] = A333DR_brake_lo_on_annun ^ 0.5
	simDR_annun_bright[66] = A333DR_brake_med_on_annun ^ 0.5
	simDR_annun_bright[67] = A333DR_brake_max_on_annun ^ 0.5
	
	simDR_annun_bright[68] = A333DR_mast_warn_annun ^ 0.5
	simDR_annun_bright[69] = A333DR_mast_caut_annun ^ 0.5
	simDR_annun_bright[70] = A333DR_auto_land_annun ^ 0.5
	simDR_annun_bright[71] = A333DR_atc_comm_annun ^ 0.5
	
	simDR_annun_bright[72] = A333DR_gpws_annun ^ 0.5
	simDR_annun_bright[73] = A333DR_gs_annun ^ 0.5
	
	simDR_annun_bright[74] = simDR_display_AP_panel_bright
	
	simDR_annun_bright[75] = simDR_integ_bright ^ 0.5
	simDR_annun_bright[76] = simDR_integ_mcp_bright ^ 0.5

end

function A333_cabin_lights()


	if A333DR_flight_phase <= 5 then
		descent_flag = 0
	end

	if A333DR_flight_phase == 6 and simDR_altitude > 18000 then
		descent_flag = 1
	end
	
	if A333DR_flight_phase >= 7 and A333DR_flight_phase <= 9 then
		descent_flag = 1
	end
	
	if A333DR_flight_phase == 10 then
		descent_flag = 0
	end
	
	
	sun_factor = A333_rescale(-2, 0.05, -1, 1, simDR_sun_pitch)
	sun_factor2 = A333_rescale(-2, 0.2, -1, 1, simDR_sun_pitch)
	

	simDR_seatbelt_lighting = simDR_seatbelt_signs * sun_factor2
	simDR_smoking_lighting = simDR_smoking_signs * sun_factor2
	simDR_ife_screen_brightness = A333DR_IFEC_status * sun_factor

	if A333_emer_exit_lt_switch_pos == 0 then
		simDR_exit_signs = simDR_smoking_signs * sun_factor2
	elseif A333_emer_exit_lt_switch_pos == 1 then				--- TODO, ADD ARM CONDITIONS
		simDR_exit_signs = simDR_smoking_signs * sun_factor2
	elseif A333_emer_exit_lt_switch_pos == 2 then
		simDR_exit_signs = sun_factor2
	end

	if A333DR_commercial_status == 0 then
		simDR_galley_screen_brightness = 0
		simDR_cabin_lighting = 0
		simDR_cabin_lighting_static = 0
		simDR_cabin_lighting_galley = 0
	elseif A333DR_commercial_status == 1 then
		simDR_galley_screen_brightness = A333DR_galley_status * sun_factor
		simDR_cabin_lighting = phase_factor
		simDR_cabin_lighting_galley = galley_phase_factor
		simDR_cabin_lighting_static = 1
	end


	if A333DR_flight_phase <= 1 or A333DR_flight_phase == 10 then
		if simDR_sun_pitch > 0 then
			phase_factor = 1
			galley_phase_factor = 1
		elseif simDR_sun_pitch <= 0 and simDR_sun_pitch > -2 then
			phase_factor = 0.7
			galley_phase_factor = 0.6
		elseif simDR_sun_pitch <= -2 then
			phase_factor = 0.4
			galley_phase_factor = 0.2
		end
	else
	
		if simDR_sun_pitch > 0 then
		
			if simDR_abs_radio_alt <= 3000 then
				phase_factor = 0.0
				galley_phase_factor = 0.6
			elseif simDR_abs_radio_alt > 3000 then
				phase_factor = 0.5
				galley_phase_factor = 1
			end
			
		elseif simDR_sun_pitch <= 0 and simDR_sun_pitch > -2 then
		
			if simDR_abs_radio_alt <= 3000 then
				phase_factor = 0.0
				galley_phase_factor = 0.2
			elseif simDR_abs_radio_alt > 3000 then
				phase_factor = 0.15
				galley_phase_factor = 0.6
			end
		
		elseif simDR_sun_pitch <= -2 then

			if simDR_altitude < 18000 then
				if descent_flag == 0 then
				
					if simDR_abs_radio_alt <= 3000 then
						phase_factor = 0.0
						galley_phase_factor = 0.03
					elseif simDR_abs_radio_alt > 3000 then
						phase_factor = 0.01
						galley_phase_factor = 0.1
					end

				elseif descent_flag == 1 then
					
					if simDR_abs_radio_alt < 3000 and simDR_abs_radio_alt > 1250 then -- lights to 'full' for final cabin check prior to night landing - turn lights OFF for landing
						phase_factor = 0.4
						galley_phase_factor = 0.2
					elseif simDR_abs_radio_alt <= 1250 then
						phase_factor = 0.0
						galley_phase_factor = 0.0
					
					end
				end
			elseif simDR_altitude >= 18000 then
				phase_factor = A333_rescale(31000, 0.01, 33000, 0, simDR_altitude)
				galley_phase_factor = A333_rescale(31000, 0.1, 33000, 0.03, simDR_altitude)
			end
		end

	end


end

function A333_cabin_reading_lights()


		if time_off_timer1 > time_off1 then
			time_off_timer1 = 0
			light1_on = 1
			time_off1 = math.random(4, 20)
		elseif time_off_timer1 <= time_off1 then
			time_off_timer1 = time_off_timer1 + SIM_PERIOD/60
		end

		if time_on_timer1 > time_on1 then
			time_on_timer1 = 0
			light1_on = 0
			time_on1 = math.random(2, 16)
		elseif time_on_timer1 <= time_on1 then
			if light1_on == 1 then
				time_on_timer1 = time_on_timer1 + SIM_PERIOD/60
			elseif light1_on == 0 then
				time_on_timer1 = 0
			end
		end

	---

		if time_off_timer2 > time_off2 then
			time_off_timer2 = 0
			light2_on = 1
			time_off2 = math.random(4, 20)
		elseif time_off_timer2 <= time_off2 then
			time_off_timer2 = time_off_timer2 + SIM_PERIOD/60
		end

		if time_on_timer2 > time_on2 then
			time_on_timer2 = 0
			light2_on = 0
			time_on2 = math.random(2, 16)
		elseif time_on_timer2 <= time_on2 then
			if light2_on == 1 then
				time_on_timer2 = time_on_timer2 + SIM_PERIOD/60
			elseif light2_on == 0 then
				time_on_timer2 = 0
			end
		end

	---

		if time_off_timer3 > time_off3 then
			time_off_timer3 = 0
			light3_on = 1
			time_off3 = math.random(4, 20)
		elseif time_off_timer3 <= time_off3 then
			time_off_timer3 = time_off_timer3 + SIM_PERIOD/60
		end

		if time_on_timer3 > time_on3 then
			time_on_timer3 = 0
			light3_on = 0
			time_on3 = math.random(2, 16)
		elseif time_on_timer3 <= time_on3 then
			if light3_on == 1 then
				time_on_timer3 = time_on_timer3 + SIM_PERIOD/60
			elseif light3_on == 0 then
				time_on_timer3 = 0
			end
		end
		
	---
	
		if time_off_timer4 > time_off4 then
			time_off_timer4 = 0
			light4_on = 1
			time_off4 = math.random(4, 20)
		elseif time_off_timer4 <= time_off4 then
			time_off_timer4 = time_off_timer4 + SIM_PERIOD/60
		end

		if time_on_timer4 > time_on4 then
			time_on_timer4 = 0
			light4_on = 0
			time_on4 = math.random(2, 16)
		elseif time_on_timer4 <= time_on4 then
			if light4_on == 1 then
				time_on_timer4 = time_on_timer4 + SIM_PERIOD/60
			elseif light4_on == 0 then
				time_on_timer4 = 0
			end
		end
		
	---

		if time_off_timer5 > time_off5 then
			time_off_timer5 = 0
			light5_on = 1
			time_off5 = math.random(4, 20)
		elseif time_off_timer5 <= time_off5 then
			time_off_timer5 = time_off_timer5 + SIM_PERIOD/60
		end

		if time_on_timer5 > time_on5 then
			time_on_timer5 = 0
			light5_on = 0
			time_on5 = math.random(2, 16)
		elseif time_on_timer5 <= time_on5 then
			if light5_on == 1 then
				time_on_timer5 = time_on_timer5 + SIM_PERIOD/60
			elseif light5_on == 0 then
				time_on_timer5 = 0
			end
		end
		
	---

		if time_off_timer6 > time_off6 then
			time_off_timer6 = 0
			light6_on = 1
			time_off6 = math.random(4, 20)
		elseif time_off_timer6 <= time_off6 then
			time_off_timer6 = time_off_timer6 + SIM_PERIOD/60
		end

		if time_on_timer6 > time_on6 then
			time_on_timer6 = 0
			light6_on = 0
			time_on6 = math.random(2, 16)
		elseif time_on_timer6 <= time_on6 then
			if light6_on == 1 then
				time_on_timer6 = time_on_timer6 + SIM_PERIOD/60
			elseif light6_on == 0 then
				time_on_timer6 = 0
			end
		end
		
	---

	if A333DR_commercial_status == 0 then
	
		simDR_cabin_reading_1 = 0
		simDR_cabin_reading_2 = 0
		simDR_cabin_reading_3 = 0
		simDR_cabin_reading_4 = 0
		simDR_cabin_reading_5 = 0
		simDR_cabin_reading_6 = 0
		
	elseif A333DR_commercial_status == 1 then

		simDR_cabin_reading_1 = light1_on
		simDR_cabin_reading_2 = light2_on
		simDR_cabin_reading_3 = light3_on
		simDR_cabin_reading_4 = light4_on
		simDR_cabin_reading_5 = light5_on
		simDR_cabin_reading_6 = light6_on
		
	end

end


function A333_beacons_strobes()

	local bus1_status = 0
	local bus2_status = 0


	if A333_strobe_switch_pos == 0 then
		simDR_strobe_on = 0
	elseif A333_strobe_switch_pos == 1 then
		if simDR_gear_on_ground == 1 then
			simDR_strobe_on = 0
		elseif simDR_gear_on_ground == 0 then
			simDR_strobe_on = 1
		end
	elseif A333_strobe_switch_pos == 2 then
		simDR_strobe_on = 1
	end

	if A333_nav_light_switch_pos == 0 then
		simDR_nav_lights_on = 0
		simDR_logo_lights = 0
	elseif A333_nav_light_switch_pos == 1 then
		simDR_nav_lights_on = 1					-- set to nav index 1
		if simDR_gear_on_ground == 1 then
			simDR_logo_lights = 1
		elseif simDR_gear_on_ground == 0 then
			if simDR_flap_deploy_ratio >= 0.5 then
				simDR_logo_lights = 1
			elseif simDR_flap_deploy_ratio < 0.5 then
				simDR_logo_lights = 0
			end
		end
	elseif A333_nav_light_switch_pos == 2 then
		simDR_nav_lights_on = 1					-- set to nav index 2
		if simDR_gear_on_ground == 1 then
			simDR_logo_lights = 1
		elseif simDR_gear_on_ground == 0 then
			if simDR_flap_deploy_ratio >= 0.5 then
				simDR_logo_lights = 1
			elseif simDR_flap_deploy_ratio < 0.5 then
				simDR_logo_lights = 0
			end
		end
	end

	if simDR_bus1_volts > 20 then
		bus1_status = 1
	elseif simDR_bus1_volts <= 20 then
		bus1_status = A333_rescale(4, 0, 20, 1, simDR_bus1_volts)
	end
	
	if simDR_bus2_volts > 20 then
		bus2_status = 1
	elseif simDR_bus2_volts <= 20 then
		bus2_status = A333_rescale(4, 0, 20, 1, simDR_bus2_volts)
	end

	simDR_beacon_strobe_ovrd = 1

	local strobe1 = 0
	local strobe2 = 0
	local beacon = 0
	local sim_time_factor = math.fmod(simDR_flight_time, 1.1)

	if sim_time_factor >= 0 and sim_time_factor <= 0.05 then
		strobe1 = 1
	elseif sim_time_factor >= 0.2 and sim_time_factor <= 0.25 then
		strobe2 = 1
	elseif sim_time_factor >= 0.6 and sim_time_factor <= 0.65 then
		beacon = 1
	end

	simDR_strobe1 = strobe1 * simDR_strobe_on * bus2_status
	simDR_strobe2 = strobe2 * simDR_strobe_on * bus2_status
	simDR_beacon = beacon * simDR_beacon_on * bus1_status

	A333_wing_strobe_brightness = simDR_strobe1 + simDR_strobe2

	simDR_landing_light3 = simDR_landing_light1



end




--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

function A333_ALL_lighting()

	A333_lights_rheo_listen()
	A333_beacons_strobes()
	A333_dome_lighting()
	A333_extra_cockpit_spills()
	A333_cabin_lights()
	A333_cabin_reading_lights()

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



