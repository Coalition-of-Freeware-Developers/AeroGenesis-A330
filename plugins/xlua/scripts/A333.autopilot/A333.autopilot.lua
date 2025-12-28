--[[
*****************************************************************************************
* Program Script Name	:	A333.autopilot
* Author Name			:	Alex Unruh
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2021-06-16	0.01a				Start of Dev
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



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local vvi_fpa_timer_running = 0
local vvi_fpa_timer_count = 0
local hdg_timer_running = 0
local hdg_timer_count = 0
local single_engine_status = 0

local ap_power_flag_capt = 0
local ap_power_flag_fo = 0
local fd_self_test_capt = 0
local fd_self_test_fo = 0

--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
simDR_startup_running               = find_dataref("sim/operation/prefs/startup_running")

simDR_gear_on_ground				= find_dataref("sim/flightmodel2/gear/on_ground[1]")

-- AUTOPILOT --
simDR_alt_step_size					= find_dataref("sim/aircraft/autopilot/alt_step_ft")
simDR_autothrottle_mode				= find_dataref("sim/cockpit2/autopilot/autothrottle_enabled")

simDR_capt_hsi						= find_dataref("sim/cockpit2/radios/actuators/HSI_source_select_pilot")
simDR_fo_hsi						= find_dataref("sim/cockpit2/radios/actuators/HSI_source_select_copilot")

simDR_speed_window_open				= find_dataref("sim/cockpit2/autopilot/vnav_speed_window_open")

simDR_gpss_status					= find_dataref("sim/cockpit2/autopilot/gpss_status")
simDR_heading_mode					= find_dataref("sim/cockpit2/autopilot/heading_mode")
simDR_vertical_mode					= find_dataref("sim/cockpit2/autopilot/altitude_mode") -- 4 or 19 for modes visible

simDR_fms_vnav						= find_dataref("sim/cockpit2/autopilot/fms_vnav")

simDR_trk_fpa_mode					= find_dataref("sim/cockpit2/autopilot/trk_fpa")
simDR_hdg_setting					= find_dataref("sim/cockpit2/autopilot/heading_dial_deg_mag_pilot")
simDR_vvi_setting					= find_dataref("sim/cockpit2/autopilot/vvi_dial_fpm")
simDR_fpa_setting					= find_dataref("sim/cockpit2/autopilot/fpa")
simDR_vvi_status					= find_dataref("sim/cockpit2/autopilot/vvi_status")
simDR_fpa_status					= find_dataref("sim/cockpit2/autopilot/fpa_status")
simDR_current_heading				= find_dataref("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")

simDR_fadec_mode_eng1				= find_dataref("sim/flightmodel/engine/ENGN_fadec_pow_req[0]")
simDR_fadec_mode_eng2				= find_dataref("sim/flightmodel/engine/ENGN_fadec_pow_req[1]")
simDR_eng1_N2						= find_dataref("sim/flightmodel2/engines/N2_percent[0]")
simDR_eng2_N2						= find_dataref("sim/flightmodel2/engines/N2_percent[1]")

simDR_asi_dial						= find_dataref("sim/cockpit2/autopilot/airspeed_dial_kts")
simDR_alt_dial						= find_dataref("sim/cockpit2/autopilot/altitude_dial_ft")
simDR_autopilot_has_pwr				= find_dataref("sim/cockpit2/autopilot/autopilot_has_power")

simDR_fd_bars_capt					= find_dataref("sim/cockpit2/autopilot/flight_director_command_bars_pilot")
simDR_fd_bars_fo					= find_dataref("sim/cockpit2/autopilot/flight_director_command_bars_copilot")

simDR_AHARS1_gyro					= find_dataref("sim/cockpit/gyros/gyr_spin[0]")
simDR_AHARS2_gyro					= find_dataref("sim/cockpit/gyros/gyr_spin[1]")
simDR_master_flight_director		= find_dataref("sim/cockpit2/autopilot/master_flight_director")

simDR_autopilot_failure				= find_dataref("sim/operation/failures/rel_otto")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--
--A333_alt_star_flag					= find_dataref("laminar/A333/AP_flags/alt_star") -- 0 = no capture mode, 1 = capture mode triggered  -- SEE NEW LOGIC IN A333.systems

A333DR_batteries_only_supply_on_ground = find_dataref("laminar/A333/elec/batteries_only_supply_on_ground")
A333DR_ac_ess_bus_has_power = find_dataref("laminar/A333/elec/ac_ess_bus_has_power")
A333DR_ac_ess_shed_bus_has_power = find_dataref("laminar/A333/elec/ac_ess_shed_bus_has_power")
A333DR_ac_bus2_has_power = find_dataref("laminar/A333/elec/ac_bus2_has_power")
A333DR_ac_bus1_has_power = find_dataref("laminar/A333/elec/ac_bus1_has_power")

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
A333_spd_mach_pos					= create_dataref("laminar/A333/autopilot/spd_mach_pos", "number")
A333_hdgtrk_vsfpa_pos				= create_dataref("laminar/A333/autopilot/hdgtrk_vsfpa_pos", "number")
A333_metric_alt_pos					= create_dataref("laminar/A333/autopilot/metric_alt_pos", "number")
A333_alt_step_knob_pos				= create_dataref("laminar/A333/autopilot/alt_step_knob_pos", "number")
A333_ap1_pos						= create_dataref("laminar/A333/autopilot/ap1_pos", "number")
A333_ap2_pos						= create_dataref("laminar/A333/autopilot/ap2_pos", "number")
A333_athrottle_pos					= create_dataref("laminar/A333/autopilot/athrottle_pos", "number")
A333_loc_pos						= create_dataref("laminar/A333/autopilot/loc_pos", "number")
A333_alt_pos						= create_dataref("laminar/A333/autopilot/alt_pos", "number")
A333_appr_pos						= create_dataref("laminar/A333/autopilot/appr_pos", "number")

A333_a_thr_discon_thr1_pos			= create_dataref("laminar/A333/autopilot/a_thr_thr1_discon_pos", "number")
A333_a_thr_discon_thr2_pos			= create_dataref("laminar/A333/autopilot/a_thr_thr2_discon_pos", "number")
A333_capt_priority_pos				= create_dataref("laminar/A333/buttons/capt_priority_pos", "number")
A333_fo_priority_pos				= create_dataref("laminar/A333/buttons/fo_priority_pos", "number")

A333_speed_knob_pos					= create_dataref("laminar/A333/autopilot/knobs/speed_pos", "number")
A333_heading_knob_pos				= create_dataref("laminar/A333/autopilot/knobs/heading_pos", "number")
A333_altitude_knob_pos				= create_dataref("laminar/A333/autopilot/knobs/altitude_pos", "number")
A333_vertical_knob_pos				= create_dataref("laminar/A333/autopilot/knobs/vertical_pos", "number")

A333_speed_push_pos					= create_dataref("laminar/A333/autopilot/knobs/speed_push_pos", "number")
A333_heading_push_pos				= create_dataref("laminar/A333/autopilot/knobs/heading_push_pos", "number")
A333_altitude_push_pos				= create_dataref("laminar/A333/autopilot/knobs/altitude_push_pos", "number")
A333_vertical_push_pos				= create_dataref("laminar/A333/autopilot/knobs/vertical_push_pos", "number")

A333_metric_alt_mode				= create_dataref("laminar/A333/autopilot/metric_mode", "number")

A333_VVI_window_open				= create_dataref("laminar/A333/autopilot/vvi_fpa_window_open", "number")
A333_hdg_window_open				= create_dataref("laminar/A333/autopilot/hdg_window_open", "number")

A333_capt_FD_bars_bypass			= create_dataref("laminar/A333/autopilot/capt_FD_bars_bypass", "number") -- TEMPORARY FIX
A333_fo_FD_bars_bypass				= create_dataref("laminar/A333/autopilot/fo_FD_bars_bypass", "number") -- TEMPORARY FIX

A333_capt_FD_timer					= create_dataref("laminar/A333/autopilot/capt_FD_bars_timer", "number")
A333_fo_FD_timer					= create_dataref("laminar/A333/autopilot/fo_FD_bars_timer", "number")

A333_capt_fd_has_power				= create_dataref("laminar/A333/autopilot/capt_FD_has_power", "number")
A333_fo_fd_has_power				= create_dataref("laminar/A333/autopilot/fo_FD_has_power", "number")

A333_capt_FD_flag					= create_dataref("laminar/A333/autopilot/capt_FD_flag", "number")
A333_fo_FD_flag						= create_dataref("laminar/A333/autopilot/fo_FD_flag", "number")
A333_FD_hide_PFD					= create_dataref("laminar/A333/autopilot/FD_pfd_hide", "number")

A333_adiru1_flag					= create_dataref("laminar/A333/adiru1/flag", "number")
A333_adiru2_flag					= create_dataref("laminar/A333/adiru2/flag", "number")

---- AI ---------------------------------------------------------------------------------

A333DR_init_autopilot_CD           	= create_dataref("laminar/A333/init_CD/autopilot", "number")


A333_fd_state_capt = create_dataref("laminar/A333/autopilot/fd_state_capt", "number")
A333_fd_state_fo = create_dataref("laminar/A333/autopilot/fd_state_fo", "number")

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
function A333_trkfpa_toggle_beforeCMDhandler(phase, duration) end
function A333_spd_mach_toggle_beforeCMDhandler(phase, duration) end
function A333_ap1_toggle_beforeCMDhandler(phase, duration) end
function A333_ap2_toggle_beforeCMDhandler(phase, duration) end
function A333_loc_toggle_beforeCMDhandler(phase, duration) end
function A333_appr_toggle_beforeCMDhandler(phase, duration) end
function A333_alt_toggle_beforeCMDhandler(phase, duration) end

function A333_capt_priority_push_beforeCMDhandler(phase, duration) end
function A333_fo_priority_push_beforeCMDhandler(phase, duration) end

function A333_trkfpa_toggle_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_hdgtrk_vsfpa_pos = 1
	elseif phase == 2 then
		A333_hdgtrk_vsfpa_pos = 0
	end
end

function A333_spd_mach_toggle_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_spd_mach_pos = 1
	elseif phase == 2 then
		A333_spd_mach_pos = 0
	end
end

function A333_ap1_toggle_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_ap1_pos = 1
	elseif phase == 2 then
		A333_ap1_pos = 0
	end
end

function A333_ap2_toggle_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_ap2_pos = 1
	elseif phase == 2 then
		A333_ap2_pos = 0
	end
end

function A333_loc_toggle_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_loc_pos = 1
	elseif phase == 2 then
		A333_loc_pos = 0
	end
end

function A333_appr_toggle_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_appr_pos = 1
		-- A333_alt_star_flag = 0 -- SEE NEW LOGIC IN A333.systems
	elseif phase == 2 then
		A333_appr_pos = 0
	end
end

function A333_alt_toggle_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_alt_pos = 1
		--A333_alt_star_flag = 0 -- SEE NEW LOGIC IN A333.systems
	elseif phase == 2 then
		A333_alt_pos = 0
	end
end

function A333_capt_priority_push_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_capt_priority_pos = 1
	elseif phase == 2 then
		A333_capt_priority_pos = 0
	end
end

function A333_fo_priority_push_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_fo_priority_pos = 1
	elseif phase == 2 then
		A333_fo_priority_pos = 0
	end
end

	A333_phase1_gate = function()
		phase1_gate = 1
		end

function simCMD_speed_up_beforeCMDhandler(phase, duration) end
function simCMD_speed_up_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_speed_knob_pos = A333_speed_knob_pos + 1
		run_after_time(A333_phase1_gate, 0.5)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_speed_knob_pos = A333_speed_knob_pos + 1
		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end

function simCMD_speed_dn_beforeCMDhandler(phase, duration) end
function simCMD_speed_dn_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_speed_knob_pos = A333_speed_knob_pos - 1
		run_after_time(A333_phase1_gate, 0.5)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_speed_knob_pos = A333_speed_knob_pos - 1
		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end

function simCMD_heading_up_beforeCMDhandler(phase, duration) end
function simCMD_heading_up_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_heading_knob_pos = A333_heading_knob_pos + 1
		run_after_time(A333_phase1_gate, 0.5)
		if simDR_gpss_status >= 1 then
			hdg_timer_running = 1
			hdg_timer_count = 0
		end
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_heading_knob_pos = A333_heading_knob_pos + 1
		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end

function simCMD_heading_dn_beforeCMDhandler(phase, duration) end
function simCMD_heading_dn_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_heading_knob_pos = A333_heading_knob_pos - 1
		run_after_time(A333_phase1_gate, 0.5)
		if simDR_gpss_status >= 1 then
			hdg_timer_running = 1
			hdg_timer_count = 0
		end
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_heading_knob_pos = A333_heading_knob_pos - 1
		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end

function simCMD_altitude_up_beforeCMDhandler(phase, duration) end
function simCMD_altitude_up_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_altitude_knob_pos = A333_altitude_knob_pos + 1
		run_after_time(A333_phase1_gate, 0.5)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_altitude_knob_pos = A333_altitude_knob_pos + 1
		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end

function simCMD_altitude_dn_beforeCMDhandler(phase, duration) end
function simCMD_altitude_dn_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_altitude_knob_pos = A333_altitude_knob_pos - 1
		run_after_time(A333_phase1_gate, 0.5)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_altitude_knob_pos = A333_altitude_knob_pos - 1
		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end

function simCMD_vertical_up_beforeCMDhandler(phase, duration) end
function simCMD_vertical_up_afterCMDhandler(phase, duration)
	if phase == 0 then
		if simDR_vertical_mode ~= 4 and simDR_vertical_mode ~= 19 then
			vvi_fpa_timer_running = 1
		end
		A333_vertical_knob_pos = A333_vertical_knob_pos + 1
		run_after_time(A333_phase1_gate, 0.5)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_vertical_knob_pos = A333_vertical_knob_pos + 1
		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end

function simCMD_vertical_dn_beforeCMDhandler(phase, duration) end
function simCMD_vertical_dn_afterCMDhandler(phase, duration)
	if phase == 0 then
		if simDR_vertical_mode ~= 4 and simDR_vertical_mode ~= 19 then
			vvi_fpa_timer_running = 1
		end
		A333_vertical_knob_pos = A333_vertical_knob_pos - 1
		run_after_time(A333_phase1_gate, 0.5)
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_vertical_knob_pos = A333_vertical_knob_pos - 1
		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end

--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	         **--
--*************************************************************************************--
simCMD_autothrottle_arm				= find_command("sim/autopilot/autothrottle_arm")
simCMD_autothrottle_hard_off		= find_command("sim/autopilot/autothrottle_hard_off")

simCMD_selected_speed_on			= find_command("sim/autopilot/autothrottle_on")
simCMD_spd_intervention				= find_command("sim/autopilot/spd_intv")

simCMD_gpss_on						= find_command("sim/autopilot/gpss")
simCMD_heading_sync					= find_command("sim/autopilot/heading_sync")
simCMD_heading						= find_command("sim/autopilot/heading")

simCMD_level_change					= find_command("sim/autopilot/level_change")
simCMD_fms_mode						= find_command("sim/autopilot/FMS")
simCMD_alt_intervention				= find_command("sim/autopilot/alt_intv")

simCMD_alt_vs						= find_command("sim/autopilot/alt_vs")
simCMD_fpa							= find_command("sim/autopilot/fpa")

simCMD_toga							= find_command("sim/autopilot/take_off_go_around")


--*************************************************************************************--
--** 				               REPLACE X-PLANE COMMANDS                   	     **--
--*************************************************************************************--


--*************************************************************************************--
--** 				               WRAP X-PLANE COMMANDS                   	     	 **--
--*************************************************************************************--
simCMD_speed_up						= wrap_command("sim/autopilot/airspeed_up", simCMD_speed_up_beforeCMDhandler, simCMD_speed_up_afterCMDhandler)
simCMD_speed_dn						= wrap_command("sim/autopilot/airspeed_down", simCMD_speed_dn_beforeCMDhandler, simCMD_speed_dn_afterCMDhandler)
simCMD_heading_up					= wrap_command("sim/autopilot/heading_up", simCMD_heading_up_beforeCMDhandler, simCMD_heading_up_afterCMDhandler)
simCMD_heading_dn					= wrap_command("sim/autopilot/heading_down", simCMD_heading_dn_beforeCMDhandler, simCMD_heading_dn_afterCMDhandler)
simCMD_altitude_up					= wrap_command("sim/autopilot/altitude_up", simCMD_altitude_up_beforeCMDhandler, simCMD_altitude_up_afterCMDhandler)
simCMD_altitude_dn					= wrap_command("sim/autopilot/altitude_down", simCMD_altitude_dn_beforeCMDhandler, simCMD_altitude_dn_afterCMDhandler)
simCMD_vvi_up						= wrap_command("sim/autopilot/vertical_speed_up", simCMD_vertical_up_beforeCMDhandler, simCMD_vertical_up_afterCMDhandler)
simCMD_vvi_dn						= wrap_command("sim/autopilot/vertical_speed_down", simCMD_vertical_dn_beforeCMDhandler, simCMD_vertical_dn_afterCMDhandler)

simCMD_trkfpa_toggle				= wrap_command("sim/autopilot/trkfpa", A333_trkfpa_toggle_beforeCMDhandler, A333_trkfpa_toggle_afterCMDhandler)
simCMD_spd_mach_toggle				= wrap_command("sim/autopilot/knots_mach_toggle", A333_spd_mach_toggle_beforeCMDhandler, A333_spd_mach_toggle_afterCMDhandler)
simCMD_ap1_toggle					= wrap_command("sim/autopilot/servos_toggle", A333_ap1_toggle_beforeCMDhandler, A333_ap1_toggle_afterCMDhandler)
simCMD_ap2_toggle					= wrap_command("sim/autopilot/servos2_toggle", A333_ap2_toggle_beforeCMDhandler, A333_ap2_toggle_afterCMDhandler)
simCMD_loc_toggle					= wrap_command("sim/autopilot/NAV", A333_loc_toggle_beforeCMDhandler, A333_loc_toggle_afterCMDhandler)
simCMD_appr_toggle					= wrap_command("sim/autopilot/approach", A333_appr_toggle_beforeCMDhandler, A333_appr_toggle_afterCMDhandler)
simCMD_alt_toggle					= wrap_command("sim/autopilot/altitude_hold", A333_alt_toggle_beforeCMDhandler, A333_alt_toggle_afterCMDhandler)

simCMD_capt_priority_push			= wrap_command("sim/autopilot/priority_pb_left", A333_capt_priority_push_beforeCMDhandler, A333_capt_priority_push_afterCMDhandler)
simCMD_fo_priority_push				= wrap_command("sim/autopilot/priority_pb_right", A333_fo_priority_push_beforeCMDhandler, A333_fo_priority_push_afterCMDhandler)


--*************************************************************************************--
--** 				               FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--


--*************************************************************************************--
--** 				              CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--
function A333_metric_alt_toggleCMDhandler(phase, duration)
	if phase == 0 then
		A333_metric_alt_pos = 1
		if A333_metric_alt_mode == 0 then
			A333_metric_alt_mode = 1
		elseif A333_metric_alt_mode == 1 then
			A333_metric_alt_mode = 0
		end
	elseif phase == 2 then
		A333_metric_alt_pos = 0
	end
end

function A333_altitude_step_leftCMDhandler(phase, duration)
	if phase == 0 then
		A333_alt_step_knob_pos = 0
		simDR_alt_step_size = 100
	end
end

function A333_altitude_step_rightCMDhandler(phase, duration)
	if phase == 0 then
		A333_alt_step_knob_pos = 1
		simDR_alt_step_size = 1000
	end
end

function A333_altitude_step_toggleCMDhandler(phase, duration)
    if phase == 0 then
        if A333_alt_step_knob_pos == 0 then
 		    A333_alt_step_knob_pos = 1
 		    simDR_alt_step_size = 1000
        else
		    A333_alt_step_knob_pos = 0
		    simDR_alt_step_size = 100
        end
    end
end

function A333_auto_throttle_toggleCMDhandler(phase, duration)
	if phase == 0 then
		A333_athrottle_pos = 1
		if simDR_autothrottle_mode < 0 then
			simCMD_autothrottle_arm:once()
		elseif simDR_autothrottle_mode >= 0 then
			simCMD_autothrottle_hard_off:once()
		end
	elseif phase == 2 then
		A333_athrottle_pos = 0
	end
end

function A333_a_thr_off_eng1_pushCMDhandler(phase, duration)
	if phase == 0 then
		simCMD_autothrottle_hard_off:once()
		A333_a_thr_discon_thr1_pos = 1
	elseif phase == 2 then
		A333_a_thr_discon_thr1_pos = 0
	end
end

function A333_a_thr_off_eng2_pushCMDhandler(phase, duration)
	if phase == 0 then
		simCMD_autothrottle_hard_off:once()
		A333_a_thr_discon_thr2_pos = 1
	elseif phase == 2 then
		A333_a_thr_discon_thr2_pos = 0
	end
end

function A333_speed_knob_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_speed_push_pos = -1
		if simDR_speed_window_open == 1 then
			simCMD_spd_intervention:once()
		end
	elseif phase == 2 then
		A333_speed_push_pos = 0
	end
end

function A333_speed_knob_pullCMDhandler(phase, duration)
	if phase == 0 then
		A333_speed_push_pos = 1
		if simDR_speed_window_open == 0 then
			simCMD_spd_intervention:once()
		end
		if simDR_autothrottle_mode == 0 then
			simCMD_selected_speed_on:once()
		end
	elseif phase == 2 then
		A333_speed_push_pos = 0
	end
end

function A333_heading_knob_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_heading_push_pos = -1
		if simDR_gpss_status == 0 then
			simCMD_gpss_on:once()
		end
	elseif phase == 2 then
		A333_heading_push_pos = 0
	end
end

function A333_heading_knob_pullCMDhandler(phase, duration)
	if phase == 0 then
		A333_heading_push_pos = 1
		if simDR_heading_mode ~= 1 and simDR_heading_mode ~= 18 then
			simCMD_heading:once()
		elseif simDR_heading_mode == 1 or simDR_heading_mode == 18 then
			simCMD_heading_sync:once()
		end
	elseif phase == 2 then
		A333_heading_push_pos = 0
		hdg_timer_running = 0
		hdg_timer_count = 0
	end
end

function A333_altitude_knob_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_altitude_push_pos = -1
		if simDR_fms_vnav == 0 then
			simCMD_fms_mode:once()
			--A333_alt_star_flag = 0 -- SEE NEW LOGIC IN A333.systems
		elseif simDR_fms_vnav == 1 then
			simCMD_alt_intervention:once()
		end
	elseif phase == 2 then
		A333_altitude_push_pos = 0
	end
end

function A333_altitude_knob_pullCMDhandler(phase, duration)
	if phase == 0 then
		A333_altitude_push_pos = 1
		simCMD_level_change:once()
		--A333_alt_star_flag = 0 -- SEE NEW LOGIC IN A333.systems
	elseif phase == 2 then
		A333_altitude_push_pos = 0
	end
end

function A333_vertical_knob_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_vertical_push_pos = -1
		--A333_alt_star_flag = 0 -- SEE NEW LOGIC IN A333.systems
		if simDR_trk_fpa_mode == 0 then
			if simDR_vvi_status == 0 then
				simCMD_alt_vs:once()
				simDR_vvi_setting = 0
				simDR_fpa_setting = 0
			elseif simDR_vvi_status == 2 then
				simDR_vvi_setting = 0
				simDR_fpa_setting = 0
			end
		elseif simDR_trk_fpa_mode == 1 then
			if simDR_fpa_status == 0 then
				simCMD_fpa:once()
				simDR_vvi_setting = 0
				simDR_fpa_setting = 0
			elseif simDR_fpa_status == 1 then
				simDR_vvi_setting = 0
				simDR_fpa_setting = 0
			end
		end
	elseif phase == 2 then
		A333_vertical_push_pos = 0
		vvi_fpa_timer_running = 0
		vvi_fpa_timer_count = 0
	end
end

function A333_vertical_knob_pullCMDhandler(phase, duration)
	if phase == 0 then
		A333_vertical_push_pos = 1
		--A333_alt_star_flag = 0 -- SEE NEW LOGIC IN A333.systems
		if simDR_trk_fpa_mode == 0 then
			if simDR_vvi_status == 0 then
				simCMD_alt_vs:once()
			end
		elseif simDR_trk_fpa_mode == 1 then
			if simDR_fpa_status == 0 then
				simCMD_fpa:once()
			end
		end
	elseif phase == 2 then
		A333_vertical_push_pos = 0
		vvi_fpa_timer_running = 0
		vvi_fpa_timer_count = 0
	end
end

function A333_fpa_increase_CMDhandler(phase, duration)
	if phase == 0 then
		vvi_fpa_timer_running = 1
		A333_vertical_knob_pos = A333_vertical_knob_pos + 1
		if simDR_fpa_setting < 9.9 then
			simDR_fpa_setting = simDR_fpa_setting + 0.1
			run_after_time(A333_phase1_gate, 0.5)
		elseif simDR_fpa_setting >= 9.9 then
			simDR_fpa_setting = 9.9
			run_after_time(A333_phase1_gate, 0.5)
		end
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_vertical_knob_pos = A333_vertical_knob_pos + 1
			if simDR_fpa_setting < 9.9 then
				simDR_fpa_setting = simDR_fpa_setting + 0.1
				run_after_time(A333_phase1_gate, 0.5)
			elseif simDR_fpa_setting >= 9.9 then
				simDR_fpa_setting = 9.9
				run_after_time(A333_phase1_gate, 0.5)
			end
		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end

function A333_fpa_decrease_CMDhandler(phase, duration)
	if phase == 0 then
		vvi_fpa_timer_running = 1
		A333_vertical_knob_pos = A333_vertical_knob_pos - 1
		if simDR_fpa_setting > -15 then
			simDR_fpa_setting = simDR_fpa_setting - 0.1
			run_after_time(A333_phase1_gate, 0.5)
		elseif simDR_fpa_setting <= -9.9 then
			simDR_fpa_setting = -9.9
			run_after_time(A333_phase1_gate, 0.5)
		end
	elseif phase == 1 then
		if phase1_gate == 0 then
		elseif phase1_gate == 1 then
			A333_vertical_knob_pos = A333_vertical_knob_pos - 1
			if simDR_fpa_setting > -15 then
				simDR_fpa_setting = simDR_fpa_setting - 0.1
				run_after_time(A333_phase1_gate, 0.5)
			elseif simDR_fpa_setting <= -9.9 then
				simDR_fpa_setting = -9.9
				run_after_time(A333_phase1_gate, 0.5)
			end
		end
	elseif phase == 2 then
		phase1_gate = 0
		stop_timer(A333_phase1_gate)
	end
end


-- AI
function A333_ai_autopilot_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	A333_set_autopilot_all_modes()
	  	A333_set_autopilot_CD()
	  	A333_set_autopilot_ER()
	end
end


--*************************************************************************************--
--** 				                 CUSTOM COMMANDS                			     **--
--*************************************************************************************--
A333CMD_metric_alt_toggle			= create_command("laminar/A333/autopilot/metric_alt_push", "Metric Altitude Toggle", A333_metric_alt_toggleCMDhandler)

A333CMD_altitude_step_left			= create_command("laminar/A333/autopilot/alt_step_left", "Altitude Step 100 FT", A333_altitude_step_leftCMDhandler)
A333CMD_altitude_step_right			= create_command("laminar/A333/autopilot/alt_step_right", "Altitude Step 1000 FT", A333_altitude_step_rightCMDhandler)
A333CMD_altitude_step_toggle        = create_command("laminar/A333/autopilot/alt_step_toggle", "Altitude Step Toggle Between 100/1000 FT", A333_altitude_step_toggleCMDhandler)

A333CMD_auto_throttle_toggle		= create_command("laminar/A333/autopilot/a_thr_toggle", "A/THR Toggle", A333_auto_throttle_toggleCMDhandler)

A333CMD_a_thr_off_eng1_lever		= create_command("laminar/A333/autopilot/a_thr_off_eng1", "A/THR OFF Throttle 1", A333_a_thr_off_eng1_pushCMDhandler)
A333CMD_a_thr_off_eng2_lever		= create_command("laminar/A333/autopilot/a_thr_off_eng2", "A/THR OFF Throttle 2", A333_a_thr_off_eng2_pushCMDhandler)

A333CMD_speed_knob_push				= create_command("laminar/A333/autopilot/speed_knob_push", "Managed Speed PUSH", A333_speed_knob_pushCMDhandler)
A333CMD_speed_knob_pull				= create_command("laminar/A333/autopilot/speed_knob_pull", "Selected Speed PULL", A333_speed_knob_pullCMDhandler)

A333CMD_heading_knob_push			= create_command("laminar/A333/autopilot/heading_knob_push", "Managed Heading PUSH", A333_heading_knob_pushCMDhandler)
A333CMD_heading_knob_pull			= create_command("laminar/A333/autopilot/heading_knob_pull", "Selected Heading PULL", A333_heading_knob_pullCMDhandler)

A333CMD_altitude_knob_push			= create_command("laminar/A333/autopilot/altitude_knob_push", "Managed Altitude PUSH", A333_altitude_knob_pushCMDhandler)
A333CMD_altitude_knob_pull			= create_command("laminar/A333/autopilot/altitude_knob_pull", "Selected Altitude PULL", A333_altitude_knob_pullCMDhandler)

A333CMD_vertical_knob_push			= create_command("laminar/A333/autopilot/vertical_knob_push", "Level Off PUSH", A333_vertical_knob_pushCMDhandler)
A333CMD_vertical_knob_pull			= create_command("laminar/A333/autopilot/vertical_knob_pull", "Selected Vertical Profile PULL", A333_vertical_knob_pullCMDhandler)

A333CMD_fpa_increase				= create_command("laminar/A333/autopilot/fpa_increase", "FPA Increase", A333_fpa_increase_CMDhandler)
A333CMD_fpa_decrease				= create_command("laminar/A333/autopilot/fpa_decrease", "FPA Decrease", A333_fpa_decrease_CMDhandler)


-- AI
A333CMD_ai_autopilot_quick_start	= create_command("laminar/A333/ai/autopilot_quick_start", "AI Autopilot", A333_ai_autopilot_quick_start_CMDhandler)


--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--

---- EXTRA AUTOPILOT FUNCTIONS

local function A333_autopilot()

	local ap_vertical_mode = simDR_vertical_mode
	local ap_gpss_status = simDR_gpss_status
	local ap_hdg_window_open = A333_hdg_window_open
	local VVI_window_open = A333_VVI_window_open

	if ap_vertical_mode == 4 or ap_vertical_mode == 19 then
		vvi_fpa_timer_running = 0
		vvi_fpa_timer_count = 0
	end

	if vvi_fpa_timer_running == 0 then
		vvi_fpa_timer_count = 0
	elseif vvi_fpa_timer_running == 1 then
		vvi_fpa_timer_count = vvi_fpa_timer_count + lcl_SIM_PERIOD
	end

	if vvi_fpa_timer_count >= 45 then
		vvi_fpa_timer_running = 0
		vvi_fpa_timer_count = 0
		simDR_vvi_setting = 0
		simDR_fpa_setting = 0
	end

	if vvi_fpa_timer_running == 0 then
		if ap_vertical_mode == 4 or ap_vertical_mode == 19 then
			VVI_window_open = 1
		elseif ap_vertical_mode ~= 4 and ap_vertical_mode ~= 19 then
			VVI_window_open = 0
		end
	elseif vvi_fpa_timer_running == 1 then
		VVI_window_open = 1
	end

	if hdg_timer_running == 0 then
		hdg_timer_count = 0
	elseif hdg_timer_running == 1 then
		hdg_timer_count = hdg_timer_count + lcl_SIM_PERIOD
	end


	if hdg_timer_count >= 15 then
		hdg_timer_running = 0
		hdg_timer_count = 0
	end

	if ap_gpss_status == 0 then
		ap_hdg_window_open = 1
	elseif ap_gpss_status >= 1 then
		if hdg_timer_running == 0 then
			ap_hdg_window_open = 0
		elseif hdg_timer_running == 1 then
			ap_hdg_window_open = 1
		end
	end

	if ap_hdg_window_open == 0 then
		simDR_hdg_setting = simDR_current_heading
	end

	simDR_vertical_mode = ap_vertical_mode
	simDR_gpss_status = ap_gpss_status
	A333_hdg_window_open = ap_hdg_window_open
	A333_VVI_window_open = VVI_window_open


end




local function A333_autothrust()

	local eng1_N2 = simDR_eng1_N2
	local eng2_N2 = simDR_eng2_N2
	local gear_on_ground = simDR_gear_on_ground
	local fadec_mode_eng1 = simDR_fadec_mode_eng1
	local fadec_mode_eng2 = simDR_fadec_mode_eng2
	local autothrottle_mode = simDR_autothrottle_mode

	if eng1_N2 >= 5 then
		if eng2_N2 >= 5 then
			single_engine_status = 0
		elseif eng2_N2 < 5 then
			single_engine_status = 1
		end
	elseif eng1_N2 < 5 then
		if eng2_N2 >= 5 then
			single_engine_status = 1
		elseif eng2_N2 < 5 then
			single_engine_status = 0
		end
	end



	if gear_on_ground == 1 then
		if single_engine_status == 0 then
			if fadec_mode_eng1 >= 2 and fadec_mode_eng2 >= 2 then
				if autothrottle_mode ~= 0 then
					autothrottle_mode	= 0
				end
			end
		elseif single_engine_status == 1 then
		end
	elseif gear_on_ground == 0 then
		if single_engine_status == 0 then
			if fadec_mode_eng1 >= 2 and fadec_mode_eng2 >= 2 then
				if autothrottle_mode ~= 0 then
					autothrottle_mode	= 0
				end
			end
		elseif single_engine_status == 1 then
			if fadec_mode_eng1 == 3 or fadec_mode_eng2 == 3 then
				if autothrottle_mode ~= 0 then
					autothrottle_mode	= 0
				end
			end
		end
	end

	simDR_autothrottle_mode = autothrottle_mode

end

local function A333_autopilot_settings_init()

	if simDR_autopilot_has_pwr == 0 then
		simDR_alt_dial = 100
		simDR_asi_dial = 100
		simDR_hdg_setting = 0
	end

end


local function A333_FD_power()


	A333_capt_fd_has_power = ((simDR_autopilot_has_pwr == 1 and A333DR_ac_bus1_has_power == 1 and simDR_autopilot_failure ~= 6) and 1) or 0
	A333_fo_fd_has_power = ((simDR_autopilot_has_pwr == 1 and A333DR_ac_bus1_has_power == 1 and simDR_autopilot_failure ~= 6) and 1) or 0

--	A333_capt_fd_has_power = ((simDR_autopilot_has_pwr == 1 and ((A333DR_ac_ess_bus_has_power == 1 and simDR_gear_on_ground == 0) or (A333DR_ac_ess_shed_bus_has_power == 1 and simDR_gear_on_ground == 1))) and 1) or 0
--	A333_fo_fd_has_power = ((simDR_autopilot_has_pwr == 1 and A333DR_ac_bus2_has_power == 1) and 1) or 0

end


local function A333_FD_capt_init()

	-- theory of operation, FD turns on with power to the FMGC. Runs a self test when AC1 power is available and the FD lights turn off after the self test.
	-- If the self test is uninterrupted, a flag is set and allows the FD switch to be turned on / off at will. If the self test is interrupted, the next time the FD is on, it'll run the test again and turn OFF.
	-- A flag will be flown on the PFD if the FD is turned on manually during alignment. This flag is flown until the ADIRS is aligned. At this point, autopilot armed modes and the FD will be allowed to be shown on the FMA


	if A333_capt_fd_has_power == 0 then
		A333_capt_FD_bars_bypass = 0
		A333_capt_FD_timer = 0
		fd_self_test_capt = 0
		ap_power_flag_capt = 1
	end

	if ap_power_flag_capt == 1 then
		if A333_capt_fd_has_power == 1 then
			A333_capt_FD_bars_bypass = 1
			ap_power_flag_capt = 2
		end

	elseif ap_power_flag_capt == 2 then										-- SELF TEST MODE
		
		if A333_capt_FD_bars_bypass == 1 then
		
			if simDR_AHARS1_gyro < 0.95 then
			
				if fd_self_test_capt == 0 then
					A333_capt_FD_timer = A333_capt_FD_timer + lcl_SIM_PERIOD
				elseif fd_self_test_capt == 1 then
					ap_power_flag_capt = 5
				end
					
			elseif simDR_AHARS1_gyro > 0.95 then
				fd_self_test_capt = 1
				A333_capt_FD_timer = 0
				simDR_fd_bars_capt = A333_capt_FD_bars_bypass
				ap_power_flag_capt = 4
			end
		
			if A333_capt_FD_timer > 15 then
				A333_capt_FD_bars_bypass = 0
				fd_self_test_capt = 1
				A333_capt_FD_timer = 0
				ap_power_flag_capt = 3
			end

		elseif A333_capt_FD_bars_bypass == 0 then
			A333_capt_FD_timer = 0
		end

	elseif ap_power_flag_capt == 3 then
		if A333_capt_FD_bars_bypass == 1 then
			ap_power_flag_capt = 2
		end
		
	elseif ap_power_flag_capt == 4 then
		simDR_fd_bars_capt = A333_capt_FD_bars_bypass
		
		if simDR_AHARS1_gyro < 0.95 then
			A333_capt_FD_bars_bypass = 0
			ap_power_flag_capt = 2
		end

	elseif ap_power_flag_capt == 5 then
		if A333_capt_FD_bars_bypass == 0 or simDR_AHARS1_gyro > 0.95 then
			ap_power_flag_capt = 2
		end
		
	end
	
	A333_fd_state_capt = ap_power_flag_capt

end

local function A333_FD_fo_init()

	if A333_fo_fd_has_power == 0 then
		A333_fo_FD_bars_bypass = 0
		A333_fo_FD_timer = 0
		fd_self_test_fo = 0
		ap_power_flag_fo = 1
	end

	if ap_power_flag_fo == 1 then
		if A333_fo_fd_has_power == 1 then
			A333_fo_FD_bars_bypass = 1
			ap_power_flag_fo = 2
		end

	elseif ap_power_flag_fo == 2 then										-- SELF TEST MODE
		
		if A333_fo_FD_bars_bypass == 1 then
		
			if simDR_AHARS2_gyro < 0.95 then
			
				if fd_self_test_fo == 0 then
					A333_fo_FD_timer = A333_fo_FD_timer + lcl_SIM_PERIOD
				elseif fd_self_test_fo == 1 then
					ap_power_flag_fo = 5
				end
					
			elseif simDR_AHARS2_gyro > 0.95 then
				fd_self_test_fo = 1
				A333_fo_FD_timer = 0
				simDR_fd_bars_fo = A333_fo_FD_bars_bypass
				ap_power_flag_fo = 4
			end
		
			if A333_fo_FD_timer > 15 then
				A333_fo_FD_bars_bypass = 0
				fd_self_test_fo = 1
				A333_fo_FD_timer = 0
				ap_power_flag_fo = 3
			end

		elseif A333_fo_FD_bars_bypass == 0 then
			A333_fo_FD_timer = 0
		end

	elseif ap_power_flag_fo == 3 then
		if A333_fo_FD_bars_bypass == 1 then
			ap_power_flag_fo = 2
		end
		
	elseif ap_power_flag_fo == 4 then
		simDR_fd_bars_fo = A333_fo_FD_bars_bypass
		
		if simDR_AHARS2_gyro < 0.95 then
			A333_fo_FD_bars_bypass = 0
			ap_power_flag_fo = 2
		end

	elseif ap_power_flag_fo == 5 then
		if A333_fo_FD_bars_bypass == 0 or simDR_AHARS2_gyro > 0.95 then
			ap_power_flag_fo = 2
		end
		
	end

	A333_fd_state_fo = ap_power_flag_fo

end


local function A333_FD_PFD_flags()

	if A333DR_adiru1_adr_status == 1 and A333DR_adiru1_att_status == 1 and A333DR_adiru1_hdg_status == 1 and A333DR_adiru1_lrn_status == 1 then A333_adiru1_flag = 1 -- has achieved complete alignment
	end
	if A333DR_adiru1_adr_status == 0 and A333DR_adiru1_att_status == 0 and A333DR_adiru1_hdg_status == 0 and A333DR_adiru1_lrn_status == 0 then A333_adiru1_flag = 0 -- not achieved complete alignment
	end

	if A333DR_adiru2_adr_status == 1 and A333DR_adiru2_att_status == 1 and A333DR_adiru2_hdg_status == 1 and A333DR_adiru2_lrn_status == 1 then A333_adiru2_flag = 1 -- has achieved complete alignment
	end
	if A333DR_adiru2_adr_status == 0 and A333DR_adiru2_att_status == 0 and A333DR_adiru2_hdg_status == 0 and A333DR_adiru2_lrn_status == 0 then A333_adiru2_flag = 0 -- not achieved complete alignment
	end
	
	A333_capt_FD_flag = (((A333_capt_FD_bars_bypass == 1 and A333DR_adiru1_att_status == 1 and A333DR_adiru1_lrn_status == 0 and A333_adiru1_flag == 0) or simDR_autopilot_failure == 6) and 1) or 0
	A333_fo_FD_flag = (((A333_fo_FD_bars_bypass == 1 and A333DR_adiru2_att_status == 1 and A333DR_adiru2_lrn_status == 0 and A333_adiru2_flag == 0) or simDR_autopilot_failure == 6) and 1) or 0		

	A333_FD_hide_PFD = (((A333_capt_FD_flag == 1 or A333_fo_FD_flag == 1) and (A333_adiru1_flag == 0 and A333_adiru2_flag == 0)) and 1) or 0

end


--[[

A333_capt_FD_bars_bypass
A333_fo_FD_bars_bypass

A333DR_adiru1_adr_status = find_dataref("laminar/A333/adiru1/adr_status")
A333DR_adiru1_att_status = find_dataref("laminar/A333/adiru1/att_status")
A333DR_adiru1_hdg_status = find_dataref("laminar/A333/adiru1/hdg_status")
A333DR_adiru1_lrn_status = find_dataref("laminar/A333/adiru1/lrn_status")

A333DR_adiru2_adr_status = find_dataref("laminar/A333/adiru2/adr_status")
A333DR_adiru2_att_status = find_dataref("laminar/A333/adiru2/att_status")
A333DR_adiru2_hdg_status = find_dataref("laminar/A333/adiru2/hdg_status")
A333DR_adiru2_lrn_status = find_dataref("laminar/A333/adiru2/lrn_status")
A333_capt_FD_flag					= create_dataref("laminar/A333/autopilot/capt_FD_flag", "number")
A333_fo_FD_flag						= create_dataref("laminar/A333/autopilot/fo_FD_flag", "number")

local function A333_FD_init() -- TEMPORARY FIX UNTIL WE GET THE FD ISSUE SORTED


	if simDR_autopilot_has_pwr == 0 then
		A333_capt_FD_bars_bypass = 0
		A333_fo_FD_bars_bypass = 0
		ap_power_flag = 1
	end
	
	if ap_power_flag == 1 then
	
		if simDR_autopilot_has_pwr == 1 then
			simDR_fd_bars_fo = 1
			A333_capt_FD_bars_bypass = 1
			A333_fo_FD_bars_bypass = 1
			ap_power_flag = 2
		end

	elseif ap_power_flag == 2 then

		if simDR_AHARS1_gyro > 0.95 then
			simDR_fd_bars_capt = A333_capt_FD_bars_bypass
			ap_power_flag = 3
		end

		if simDR_AHARS2_gyro > 0.95 then
			simDR_fd_bars_fo = A333_fo_FD_bars_bypass
			ap_power_flag = 4
		end

	elseif ap_power_flag == 3 then

		simDR_fd_bars_capt = A333_capt_FD_bars_bypass

		if simDR_AHARS2_gyro > 0.95 then
			simDR_fd_bars_fo = A333_fo_FD_bars_bypass
			ap_power_flag = 5
		end		

	elseif ap_power_flag == 4 then

		simDR_fd_bars_fo = A333_fo_FD_bars_bypass

		if simDR_AHARS1_gyro > 0.95 then
			simDR_fd_bars_capt = A333_capt_FD_bars_bypass
			ap_power_flag = 5
		end		

	elseif ap_power_flag == 5 then
	
		simDR_fd_bars_capt = A333_capt_FD_bars_bypass
		simDR_fd_bars_fo = A333_fo_FD_bars_bypass

		if simDR_AHARS1_gyro < 0.95 and simDR_AHARS2_gyro < 0.95 then
			ap_power_flag = 2
		elseif simDR_AHARS1_gyro > 0.95 and simDR_AHARS2_gyro < 0.95 then
			ap_power_flag = 4
		elseif simDR_AHARS1_gyro < 0.95 and simDR_AHARS2_gyro > 0.95 then
			ap_power_flag = 3
		end

	end

end
]]--


----- SET STATE FOR ALL MODES -----------------------------------------------------------
local function A333_set_autopilot_all_modes()

	simDR_capt_hsi = 0
	simDR_fo_hsi = 1

end




----- SET STATE TO COLD & DARK ----------------------------------------------------------
local function A333_set_autopilot_CD() end




----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
local function A333_set_autopilot_ER()

	ap_power_flag_capt = 4
	ap_power_flag_fo = 4
	fd_self_test_capt = 1
	fd_self_test_fo = 1
	A333_capt_FD_bars_bypass = 1
	A333_fo_FD_bars_bypass = 1

end




----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
local function A333_autopilot_monitor_AI()

    if A333DR_init_autopilot_CD == 1 then
        A333_set_autopilot_all_modes()
        A333_set_autopilot_CD()
        A333DR_init_autopilot_CD = 2
    end

end






----- FLIGHT START ---------------------------------------------------------------------
local function A333_flight_start_autopilot()

    -- ALL MODES ------------------------------------------------------------------------
    A333_set_autopilot_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        A333_set_autopilot_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		A333_set_autopilot_ER()

    end

end



--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

	A333_flight_start_autopilot()

end

--function flight_crash() end

--function before_physics()

function after_physics()

	lcl_SIM_PERIOD = SIM_PERIOD
	
	A333_autopilot_settings_init()
	A333_autopilot_monitor_AI()
	A333_autopilot()
	A333_autothrust()
	A333_FD_power()
	A333_FD_capt_init()
	A333_FD_fo_init()
	A333_FD_PFD_flags()

end

function after_replay()

	A333_autopilot_settings_init()
	A333_autopilot_monitor_AI()
	A333_autopilot()
	A333_autothrust()
	A333_FD_power()
	A333_FD_capt_init()
	A333_FD_fo_init()
	A333_FD_PFD_flags()

end



