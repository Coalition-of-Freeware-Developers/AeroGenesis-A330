--[[
*****************************************************************************************
* Program Script Name	:	A333.Z.autostart
*
* Author Name			:	Alex Unruh, Jim Gregory
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*
*
*
*
*
*****************************************************************************************
*        COPYRIGHT © 2021, 2022 ALEX UNRUH / LAMINAR RESEARCH - ALL RIGHTS RESERVED
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

local autoboard = {
    step = -1,
    phase = {},
    sequence_timeout = false,
    in_progress = 0
}

local autostart = {
    step = -1,
    phase = {},
    sequence_timeout = false,
    in_progress = 0
}

local throttle1_target = 0
local throttle2_target = 0

--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_startup_running               	= find_dataref("sim/operation/prefs/startup_running")
simDR_autoboard_in_progress         	= find_dataref("sim/flightmodel2/misc/auto_board_in_progress")
simDR_autostart_in_progress         	= find_dataref("sim/flightmodel2/misc/auto_start_in_progress")

--

simDR_parking_brake_level				= find_dataref("sim/cockpit2/controls/parking_brake_ratio")
simDR_throttle_pos						= find_dataref("sim/cockpit2/engine/actuators/throttle_ratio")
simDR_engine_master						= find_dataref("sim/cockpit2/engine/actuators/eng_master")
simDR_battery_status					= find_dataref("sim/cockpit2/electrical/battery_on")

simDR_instrument_brightness				= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio")
simDR_generic_brightness				= find_dataref("sim/flightmodel2/lights/generic_lights_brightness_ratio")

simDR_gear_handle_pos					= find_dataref("sim/cockpit2/controls/gear_handle_animation")
simDR_flap_handle_pos					= find_dataref("sim/cockpit2/controls/flap_handle_request_ratio")
simDR_speedbrake_handle_pos				= find_dataref("sim/cockpit2/controls/speedbrake_ratio")

simDR_beacon_light_on					= find_dataref("sim/cockpit2/switches/beacon_on")

simDR_apu_mode							= find_dataref("sim/cockpit2/electrical/APU_starter_switch")
simDR_apu_gen							= find_dataref("sim/cockpit2/electrical/APU_generator_on")
simDR_apu_bleed							= find_dataref("sim/cockpit2/bleedair/actuators/apu_bleed")
simDR_apu_N1							= find_dataref("sim/cockpit2/electrical/APU_N1_percent")

simDR_fuel_tank_pump					= find_dataref("sim/cockpit2/fuel/fuel_tank_pump_on")
simDR_eng_mode_sel						= find_dataref("sim/cockpit2/engine/actuators/eng_mode_selector")

simDR_engine_n3							= find_dataref("sim/cockpit2/engine/indicators/N2_percent")
simDR_generator_on						= find_dataref("sim/cockpit2/electrical/generator_on")

--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_battery1_toggle					= find_command("sim/electrical/battery_1_toggle")
simCMD_battery2_toggle					= find_command("sim/electrical/battery_2_toggle")
simCMD_yaw_damper_tog					= find_command("sim/systems/yaw_damper_toggle")
simCMD_crew_oxy_toggle					= find_command("sim/oxy/crew_valve_toggle")
simCMD_beacon_light_on					= find_command("sim/lights/beacon_lights_on")
simCMD_apu_bleed						= find_command("sim/bleed_air/apu_toggle")

simCMD_generator1_toggle				= find_command("sim/electrical/generator_1_toggle")
simCMD_generator2_toggle				= find_command("sim/electrical/generator_2_toggle")

simCMD_hydraulic_eng1A_toggle			= find_command("sim/flight_controls/hydraulic_eng1A_tog")
simCMD_hydraulic_eng1C_toggle			= find_command("sim/flight_controls/hydraulic_eng1C_tog")
simCMD_hydraulic_eng2B_toggle			= find_command("sim/flight_controls/hydraulic_eng2B_tog")
simCMD_hydraulic_eng2A_toggle			= find_command("sim/flight_controls/hydraulic_eng2A_tog")

simCMD_bleed1_toggle					= find_command("sim/bleed_air/engine_1_toggle")
simCMD_bleed2_toggle					= find_command("sim/bleed_air/engine_2_toggle")

simCMD_pack_left_toggle					= find_command("sim/bleed_air/pack_left_toggle")
simCMD_pack_right_toggle				= find_command("sim/bleed_air/pack_right_toggle")

simCMD_bus_tie_toggle					= find_command("sim/electrical/cross_tie_toggle")
simCMD_master_warn_clear				= find_command("sim/annunciator/clear_master_warning")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

-- INIT

A333DR_init_audio_CD					= find_dataref("laminar/A333/init_CD/audio")
A333DR_init_autopilot_CD				= find_dataref("laminar/A333/init_CD/autopilot")
A333DR_init_chrono_CD					= find_dataref("laminar/A333/init_CD/chrono")
A333DR_init_comms_CD					= find_dataref("laminar/A333/init_CD/comms")
A333DR_init_fire_CD						= find_dataref("laminar/A333/init_CD/fire")
A333DR_init_switches_CD					= find_dataref("laminar/A333/init_CD/switches")
A333DR_init_systems_CD					= find_dataref("laminar/A333/init_CD/systems")
A333DR_init_transponder_CD				= find_dataref("laminar/A333/init_CD/transponder")

-- AUTOBOARD / START

A333DR_eng_master1_lift					= find_dataref("laminar/A333/switches/engine1_start_lift")
A333DR_eng_master2_lift					= find_dataref("laminar/A333/switches/engine2_start_lift")
A333DR_galley_pos						= find_dataref("laminar/A333/buttons/galley_pos")
A333DR_commercial_pos					= find_dataref("laminar/A333/buttons/commercial_pos")
A333DR_pax_sys_pos						= find_dataref("laminar/A333/buttons/pax_sys_pos")
A333DR_pax_satcom_pos					= find_dataref("laminar/A333/buttons/pax_satcom_pos")
A333DR_pax_IFEC_pos						= find_dataref("laminar/A333/buttons/pax_IFEC_pos")

A333DR_adirs_knob1_pos					= find_dataref("laminar/A333/buttons/adirs/ir1_knob_pos")
A333DR_adirs_knob2_pos					= find_dataref("laminar/A333/buttons/adirs/ir2_knob_pos")
A333DR_adirs_knob3_pos					= find_dataref("laminar/A333/buttons/adirs/ir3_knob_pos")

A333DR_ir1_pos							= find_dataref("laminar/A333/buttons/adirs/ir1_pos")
A333DR_ir2_pos							= find_dataref("laminar/A333/buttons/adirs/ir2_pos")
A333DR_ir3_pos							= find_dataref("laminar/A333/buttons/adirs/ir3_pos")

A333DR_adr1_pos							= find_dataref("laminar/A333/buttons/adirs/adr1_pos")
A333DR_adr2_pos							= find_dataref("laminar/A333/buttons/adirs/adr2_pos")
A333DR_adr3_pos							= find_dataref("laminar/A333/buttons/adirs/adr3_pos")

A333DR_switch_cover						= find_dataref("laminar/A333/button_switch/cover_position")

A333DR_turb_damp_pos					= find_dataref("laminar/A333/buttons/fcc_turb_damp_pos")
A333DR_prim1_pos						= find_dataref("laminar/A333/buttons/fcc_prim1_pos")
A333DR_prim2_pos						= find_dataref("laminar/A333/buttons/fcc_prim2_pos")
A333DR_prim3_pos						= find_dataref("laminar/A333/buttons/fcc_prim3_pos")
A333DR_sec1_pos							= find_dataref("laminar/A333/buttons/fcc_sec1_pos")
A333DR_sec2_pos							= find_dataref("laminar/A333/buttons/fcc_sec2_pos")

A333DR_main_panel_flood_rheo			= find_dataref("laminar/a333/rheostats/flood_brightness")
A333DR_handles_flap_lift				= find_dataref("laminar/A333/controls/flap_lift_pos")

A333DR_crew_oxy_pos						= find_dataref("laminar/A333/buttons/oxy/crew_valve_pos")

A333DR_gpws_system_pos					= find_dataref("laminar/A333/buttons/gpws/system_toggle_pos")
A333DR_gpws_gs_mode_pos					= find_dataref("laminar/A333/buttons/gpws/glideslope_toggle_pos")
A333DR_gpws_flap_mode_pos				= find_dataref("laminar/A333/buttons/gpws/flap_toggle_pos")
A333DR_gpws_terr_mode_pos				= find_dataref("laminar/A333/buttons/gpws/terrain_toggle_pos")

A333DR_switches_seatbelts				= find_dataref("laminar/A333/switches/fasten_seatbelts")
A333DR_switches_no_smoking				= find_dataref("laminar/A333/switches/no_smoking")

A333DR_transponder_auto_on_off_pos		= find_dataref("laminar/A333/transponder/auto_on_knob_pos")
A333DR_transponder_alt_rpt_pos			= find_dataref("laminar/A333/transponder/alt_rpt_knob_pos")
A333DR_transponder_ta_ra_pos			= find_dataref("laminar/A333/transponder/ta_ra_knob_pos")
A333DR_transponder_thrt_all_abv_blw		= find_dataref("laminar/A333/transponder/thrt_all_abv_blw_pos")

A333DR_nav_lights_pos					= find_dataref("laminar/a333/switches/nav_pos")
A333DR_emergency_exit_pos				= find_dataref("laminar/a333/switches/emer_exit_lt_pos")

A333DR_apu_master_pos					= find_dataref("laminar/A333/buttons/APU_master")
A333DR_apu_start_pos					= find_dataref("laminar/A333/buttons/APU_start")
A333DR_apu_gen_pos						= find_dataref("laminar/A333/buttons/gen_apu_pos")
A333DR_apu_bleed_pos					= find_dataref("laminar/A333/buttons/apu_bleed_pos")

A333DR_fuel_tank_left1_pos				= find_dataref("laminar/A333/fuel/buttons/left1_pump_pos")
A333DR_fuel_tank_left2_pos				= find_dataref("laminar/A333/fuel/buttons/left2_pump_pos")
A333DR_fuel_tank_left_stby_pos			= find_dataref("laminar/A333/fuel/buttons/left_stby_pump_pos")
A333DR_fuel_tank_right1_pos				= find_dataref("laminar/A333/fuel/buttons/right1_pump_pos")
A333DR_fuel_tank_right2_pos				= find_dataref("laminar/A333/fuel/buttons/right2_pump_pos")
A333DR_fuel_tank_right_stby_pos			= find_dataref("laminar/A333/fuel/buttons/right_stby_pump_pos")
A333DR_fuel_tank_ctr_left_pos			= find_dataref("laminar/A333/fuel/buttons/center_left_pump_pos")
A333DR_fuel_tank_ctr_right_pos			= find_dataref("laminar/A333/fuel/buttons/center_right_pump_pos")

A333DR_generator1_pos					= find_dataref("laminar/A333/buttons/gen1_pos")
A333DR_generator2_pos					= find_dataref("laminar/A333/buttons/gen2_pos")

A333DR_elec_green_hyd_pos				= find_dataref("laminar/A330/buttons/hyd/elec_green_tog_pos")
A333DR_elec_blue_hyd_pos				= find_dataref("laminar/A330/buttons/hyd/elec_blue_tog_pos")
A333DR_elec_yellow_hyd_pos				= find_dataref("laminar/A330/buttons/hyd/elec_yellow_tog_pos")

A333DR_eng1_hyd_green					= find_dataref("laminar/A330/buttons/hyd/eng1_pump_green_pos")
A333DR_eng1_hyd_blue					= find_dataref("laminar/A330/buttons/hyd/eng1_pump_blue_pos")
A333DR_eng2_hyd_yellow					= find_dataref("laminar/A330/buttons/hyd/eng2_pump_yellow_pos")
A333DR_eng2_hyd_green					= find_dataref("laminar/A330/buttons/hyd/eng2_pump_green_pos")

A333DR_bleed1_pos						= find_dataref("laminar/A333/buttons/eng_bleed_1_pos")
A333DR_bleed2_pos						= find_dataref("laminar/A333/buttons/eng_bleed_2_pos")

A333DR_pack1_pos						= find_dataref("laminar/A333/buttons/pack_1_pos")
A333DR_pack2_pos						= find_dataref("laminar/A333/buttons/pack_2_pos")

A333DR_bus_tie_pos						= find_dataref("laminar/A333/buttons/bus_tie_pos")

A333DR_hot_air1_pos						= find_dataref("laminar/A333/buttons/hot_air1_pos")
A333DR_hot_air2_pos						= find_dataref("laminar/A333/buttons/hot_air2_pos")

A333_cargo_cond_fwd_isol_valve_pos		= find_dataref("laminar/A333/buttons/cargo_cond/fwd_isol_valve_pos")
A333_cargo_cond_bulk_isol_valve_pos		= find_dataref("laminar/A333/buttons/cargo_cond/bulk_isol_valve_pos")
A333_cargo_cond_hot_air_pos				= find_dataref("laminar/A333/buttons/cargo_cond/hot_air_pos")

A333_ventilation_extract_ovrd_pos		= find_dataref("laminar/A333/buttons/ventilation_extract_ovrd_pos")
A333_cabin_fan_pos						= find_dataref("laminar/A333/buttons/cabin_fan_pos")

A333_ecam_clear_pos						= find_dataref("laminar/A333/buttons/ecam/clr_capt_pos")
A333_capt_mast_warn_pos					= find_dataref("laminar/A333/buttons/capt_master_warn_pos")

--*************************************************************************************--
--** 				              FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--

-- AI

A333CMD_ai_audio_quick_start			= find_command("laminar/A333/ai/audio_quick_start")
A333CMD_ai_autopilot_quick_start		= find_command("laminar/A333/ai/autopilot_quick_start")
A333CMD_ai_chrono_quick_start			= find_command("laminar/A333/ai/chrono_quick_start")
A333CMD_ai_comms_quick_start			= find_command("laminar/A333/ai/comms_quick_start")
A333CMD_ai_fire_quick_start				= find_command("laminar/A333/ai/fire_quick_start")
A333CMD_ai_switches_quick_start			= find_command("laminar/A333/ai/switches_quick_start")
A333CMD_ai_systems_quick_start			= find_command("laminar/A333/ai/systems_quick_start")
A333CMD_ai_transponder_quick_start		= find_command("laminar/A333/ai/transponder_quick_start")

-- AUTOBOARD / START

A333CMD_apu_battery_toggle				= find_command("laminar/A333/buttons/APU_batt_toggle")
A333CMD_galley_power					= find_command("laminar/A333/buttons/galley_toggle")
A333CMD_commercial_power				= find_command("laminar/A333/buttons/commercial_toggle")
A333CMD_pax_system_power				= find_command("laminar/A333/buttons/pax_sys_toggle")
A333CMD_pax_satcom_power				= find_command("laminar/A333/buttons/pax_satcom_toggle")
A333CMD_pax_IFEC_power					= find_command("laminar/A333/buttons/pax_IFEC_toggle")

A333CMD_ir1_toggle						= find_command("laminar/A333/buttons/adirs/ir1_toggle")
A333CMD_ir2_toggle						= find_command("laminar/A333/buttons/adirs/ir2_toggle")
A333CMD_ir3_toggle						= find_command("laminar/A333/buttons/adirs/ir3_toggle")
A333CMD_adr1_toggle						= find_command("laminar/A333/buttons/adirs/adr1_toggle")
A333CMD_adr2_toggle						= find_command("laminar/A333/buttons/adirs/adr2_toggle")
A333CMD_adr3_toggle						= find_command("laminar/A333/buttons/adirs/adr3_toggle")

A333CMD_adirs1_knob_right				= find_command("laminar/A333/knobs/adirs/ir1_knob_right")
A333CMD_adirs1_knob_left				= find_command("laminar/A333/knobs/adirs/ir1_knob_left")
A333CMD_adirs2_knob_right				= find_command("laminar/A333/knobs/adirs/ir2_knob_right")
A333CMD_adirs2_knob_left				= find_command("laminar/A333/knobs/adirs/ir2_knob_left")
A333CMD_adirs3_knob_right				= find_command("laminar/A333/knobs/adirs/ir3_knob_right")
A333CMD_adirs3_knob_left				= find_command("laminar/A333/knobs/adirs/ir3_knob_left")

A333CMD_switch_cover04					= find_command("laminar/A333/button_switch_cover04")
A333CMD_switch_cover05					= find_command("laminar/A333/button_switch_cover05")
A333CMD_switch_cover33					= find_command("laminar/A333/button_switch_cover33")
A333CMD_switch_cover34					= find_command("laminar/A333/button_switch_cover34")
A333CMD_switch_cover35					= find_command("laminar/A333/button_switch_cover35")

A333CMD_fcc_prim1_tog					= find_command("laminar/A333/buttons/fcc/prim1_toggle")
A333CMD_fcc_prim2_tog					= find_command("laminar/A333/buttons/fcc/prim2_toggle")
A333CMD_fcc_prim3_tog					= find_command("laminar/A333/buttons/fcc/prim3_toggle")
A333CMD_fcc_sec1_tog					= find_command("laminar/A333/buttons/fcc/sec1_toggle")
A333CMD_fcc_sec2_tog					= find_command("laminar/A333/buttons/fcc/sec2_toggle")

A333CMD_gpws_sys_toggle					= find_command("laminar/A333/buttons/gpws/sys_toggle")
A333CMD_gpws_gs_toggle					= find_command("laminar/A333/buttons/gpws/gs_mode_toggle")
A333CMD_gpws_flap_toggle				= find_command("laminar/A333/buttons/gpws/flap_mode_toggle")
A333CMD_gpws_terr_toggle				= find_command("laminar/A333/buttons/gpws/terr_toggle")

A333CMD_seatbelt_signs_up				= find_command("laminar/A333/switches/seatbelt_signs_up")
A333CMD_smoking_signs_up				= find_command("laminar/A333/switches/smoking_signs_up")

--

A333CMD_trans_auto_on_off_left			= find_command("laminar/A333/transponder/auto_on_off_left")
A333CMD_trans_auto_on_off_right			= find_command("laminar/A333/transponder/auto_on_off_right")

A333CMD_trans_alt_rpt_off				= find_command("laminar/A333/transponder/alt_rpt_off")
A333CMD_trans_alt_rpt_on				= find_command("laminar/A333/transponder/alt_rpt_on")

A333CMD_trans_ta_ra_left				= find_command("laminar/A333/transponder/ta_ra_left")
A333CMD_trans_ta_ra_right				= find_command("laminar/A333/transponder/ta_ra_right")

A333CMD_trans_thrt_all_abv_blw_l		= find_command("laminar/A333/transponder/thrt_all_abv_blw_left")
A333CMD_trans_thrt_all_abv_blw_r		= find_command("laminar/A333/transponder/thrt_all_abv_blw_right")

--

A333CMD_nav_lights_on					= find_command("laminar/A333/toggle_switch/nav_light_pos_up")
A333CMD_emergency_exit_lights_up		= find_command("laminar/A333/toggle_switch/emer_exit_lt_up")

A333CMD_apu_master_toggle				= find_command("laminar/A333/buttons/APU_master")
A333CMD_apu_start						= find_command("laminar/A333/buttons/APU_start")
A333CMD_apu_gen_toggle					= find_command("laminar/A333/buttons/APU_gen_toggle")

--

A333CMD_fuel_tank_left1_tog				= find_command("laminar/A333/switches/left1_pump_toggle")
A333CMD_fuel_tank_left2_tog				= find_command("laminar/A333/switches/left2_pump_toggle")
A333CMD_fuel_tank_left_stby_tog			= find_command("laminar/A333/switches/left_stby_pump_toggle")
A333CMD_fuel_tank_right1_tog			= find_command("laminar/A333/switches/right1_pump_toggle")
A333CMD_fuel_tank_right2_tog			= find_command("laminar/A333/switches/right2_pump_toggle")
A333CMD_fuel_tank_right_stby_tog		= find_command("laminar/A333/switches/right_stby_pump_toggle")
A333CMD_fuel_tank_center_left_tog		= find_command("laminar/A333/switches/center_left_pump_toggle")
A333CMD_fuel_tank_center_right_tog		= find_command("laminar/A333/switches/center_right_pump_toggle")

--

A333CMD_elec_hyd_green_toggle			= find_command("laminar/A330/buttons/hyd/elec_green_toggle")
A333CMD_elec_hyd_blue_toggle			= find_command("laminar/A330/buttons/hyd/elec_blue_toggle")
A333CMD_elec_hyd_yellow_toggle			= find_command("laminar/A330/buttons/hyd/elec_yellow_toggle")

A333CMD_switch_cover15					= find_command("laminar/A333/button_switch_cover15")
A333CMD_switch_cover17					= find_command("laminar/A333/button_switch_cover17")
A333CMD_switch_cover19					= find_command("laminar/A333/button_switch_cover19")
A333CMD_switch_cover20					= find_command("laminar/A333/button_switch_cover20")

A333CMD_hot_air1_toggle					= find_command("laminar/A333/switches/hot_air1_toggle")
A333CMD_hot_air2_toggle					= find_command("laminar/A333/switches/hot_air2_toggle")

A333CMD_cargo_cond_fwd_isol_valve_tog	= find_command("laminar/A333/buttons/cargo_cond/fwd_isol_valve_tog")
A333CMD_cargo_cond_bulk_isol_valve_tog	= find_command("laminar/A333/buttons/cargo_cond/bulk_isol_valve_tog")
A333CMD_cargo_cond_hot_air_tog			= find_command("laminar/A333/buttons/cargo_cond/hot_air_tog")

A333CMD_ventilation_extract_ovrd_tog	= find_command("laminar/A333/buttons/ventilation_extract_ovrd_tog")
A333CMD_cabin_fan_tog					= find_command("laminar/A333/buttons/cabin_fan_tog")

A333CMD_clear_ECAM_warn					= find_command("laminar/A333/button/ecam/clr_capt")

--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

A333_autoboard_step						= create_dataref("laminar/A333/testing/autoboard_step", "number")

--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--

function sim_autoboard_CMDhandler(phase, duration)
    if phase == 0 then
        print("==> AUTOBOARD COMMAND INVOKED")
        --if simDR_autoboard_in_progress == 0
        --    and simDR_autostart_in_progress == 0
        if autoboard.in_progress == 0
        	and autostart.in_progress == 0
        then
	        if autostart.step < 0 then
            	simDR_autoboard_in_progress = 1
            end
            autoboard.in_progress = 1
            autoboard.step = 0
            autoboard.phase = {}
            autoboard.sequence_timeout = false
        end
    end
end


function sim_autostart_CMDhandler(phase, duration)
    if phase == 0 then
    print("==> AUTOSTART COMMAND INVOKED")
        --if simDR_autoboard_in_progress == 0
        --    and simDR_autostart_in_progress == 0
        if autoboard.in_progress == 0
        	and autostart.in_progress == 0
        then
            autostart.step = 0
            simDR_autostart_in_progress = 1
        end
    end
end


function sim_quick_start_beforeCMDhandler(phase, duration)
	if phase == 0 then
		A333_ai_quick_start()
	end
end
function sim_quick_start_afterCMDhandler(phase, duration) end

--*************************************************************************************--
--** 				             REPLACE X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--

simCMD_autoboard                    = replace_command("sim/operation/auto_board", sim_autoboard_CMDhandler)
simCMD_autostart                    = replace_command("sim/operation/auto_start", sim_autostart_CMDhandler)

--*************************************************************************************--
--** 				              WRAP X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--

simCMD_quick_start         			= wrap_command("sim/operation/quick_start", sim_quick_start_beforeCMDhandler, sim_quick_start_afterCMDhandler)

--*************************************************************************************--
--** 					           OBJECT CONSTRUCTORS         		        		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                  CREATE OBJECTS              	     			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 SYSTEM FUNCTIONS           	    			 **--
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

function A333_print_sequence_status(step, phase, message)
    local msg = string.format("| Step:%02d/Phase:%02d - %s", step, phase, message)
    print(msg)
end

function A333_print_completed_line()
    print("+----------------------------------------------+")
end


----- SEQUENCE TIMERS -------------------------------------------------------------------

	A333_parking_brake_set = function()
		simDR_parking_brake_level = 1
	end

	A333_throttle1_set_10 = function()
		throttle1_target = 0.1
	end

	A333_throttle2_set_10 = function()
		throttle2_target = 0.1
	end

	A333_throttle1_set_idle = function()
		throttle1_target = 0
	end

	A333_throttle2_set_idle = function()
		throttle2_target = 0
	end

	A333_engine_master_lift1 = function()
		A333DR_eng_master1_lift = 0
	end

	A333_engine_master_lift2 = function()
		A333DR_eng_master2_lift = 0
	end

	A333_engine_master1_off = function()
		simDR_engine_master[0] = 0
		A333DR_eng_master1_lift = 0.002
		run_after_time(A333_engine_master_lift1, 0.25)
	end

	A333_engine_master2_off = function()
		simDR_engine_master[1] = 0
		A333DR_eng_master2_lift = 0.002
		run_after_time(A333_engine_master_lift2, 0.25)
	end

	A333_engine_master1_on = function()
		A333DR_eng_master1_lift = 0.002
		simDR_engine_master[0] = 1
		run_after_time(A333_engine_master_lift1, 0.25)
	end

	A333_engine_master2_on = function()
		A333DR_eng_master2_lift = 0.002
		simDR_engine_master[1] = 1
		run_after_time(A333_engine_master_lift2, 0.25)
	end

	A333_battery1_toggle = function()
		if simDR_battery_status[0] == 0 then
			simCMD_battery1_toggle:start()
		end
	end

	A333_battery2_toggle = function()
		if simDR_battery_status[1] == 0 then
			simCMD_battery2_toggle:start()
		end
	end

	A333_apu_batt_toggle = function()
		if simDR_battery_status[2] == 0 then
			A333CMD_apu_battery_toggle:start()
		end
	end

	A333_galley_toggle = function()
		if A333DR_galley_pos == 0 then
			A333CMD_galley_power:start()
		end
	end

	A333_commercial_toggle = function()
		if A333DR_commercial_pos == 0 then
			A333CMD_commercial_power:start()
		end
	end

	A333_pax_sys_toggle = function()
		if A333DR_pax_sys_pos == 0 then
			A333CMD_pax_system_power:start()
		end
	end

	A333_pax_satcom_toggle = function()
		if A333DR_pax_satcom_pos == 0 then
			A333CMD_pax_satcom_power:start()
		end
	end

	A333_pax_IFEC_toggle = function()
		if A333DR_pax_IFEC_pos == 0 then
			A333CMD_pax_IFEC_power:start()
		end
	end

	A333_ir1_toggle = function()
		if A333DR_ir1_pos == 0 then
			A333CMD_ir1_toggle:start()
		end
	end

	A333_ir2_toggle = function()
		if A333DR_ir2_pos == 0 then
			A333CMD_ir2_toggle:start()
		end
	end

	A333_ir3_toggle = function()
		if A333DR_ir3_pos == 0 then
			A333CMD_ir3_toggle:start()
		end
	end

	A333_adr1_toggle = function()
		if A333DR_adr1_pos == 0 then
			A333CMD_adr1_toggle:start()
		end
	end

	A333_adr2_toggle = function()
		if A333DR_adr2_pos == 0 then
			A333CMD_adr2_toggle:start()
		end
	end

	A333_adr3_toggle = function()
		if A333DR_adr3_pos == 0 then
			A333CMD_adr3_toggle:start()
		end
	end

	A333_adirs1_knob_set = function()
		if A333DR_adirs_knob1_pos == 0 then
			A333CMD_adirs1_knob_right:once()
		elseif A333DR_adirs_knob1_pos == 2 then
			A333CMD_adirs1_knob_left:once()
		end
	end

	A333_adirs2_knob_set = function()
		if A333DR_adirs_knob2_pos == 0 then
			A333CMD_adirs2_knob_right:once()
		elseif A333DR_adirs_knob2_pos == 2 then
			A333CMD_adirs2_knob_left:once()
		end
	end

	A333_adirs3_knob_set = function()
		if A333DR_adirs_knob3_pos == 0 then
			A333CMD_adirs3_knob_right:once()
		elseif A333DR_adirs_knob3_pos == 2 then
			A333CMD_adirs3_knob_left:once()
		end
	end

	A333_prim1_toggle = function()
		if A333DR_prim1_pos == 0 then
			A333CMD_fcc_prim1_tog:start()
		end
	end

	A333_prim2_toggle = function()
		if A333DR_prim2_pos == 0 then
			A333CMD_fcc_prim2_tog:start()
		end
	end

	A333_prim3_toggle = function()
		if A333DR_prim3_pos == 0 then
			A333CMD_fcc_prim3_tog:start()
		end
	end

	A333_sec1_toggle = function()
		if A333DR_sec1_pos == 0 then
			A333CMD_fcc_sec1_tog:start()
		end
	end

	A333_sec2_toggle = function()
		if A333DR_sec2_pos == 0 then
			A333CMD_fcc_sec2_tog:start()
		end
	end

	A333_turb_damp_toggle = function()
		if A333DR_turb_damp_pos == 0 then
			simCMD_yaw_damper_tog:start()
		end
	end

	A333_integral_lighting = function()
		simDR_instrument_brightness[13] = 0.008
	end

	A333_ap_integral_lighting = function()
		simDR_instrument_brightness[14] = 0.008
	end

	A333_main_panel_flood_lighting = function()
		A333DR_main_panel_flood_rheo = 1
	end

	A333_flap_handle_drop = function()
		A333DR_handles_flap_lift = 0
	end

	A333_crew_oxy_toggle = function()
		if A333DR_crew_oxy_pos == 0 then
			simCMD_crew_oxy_toggle:start()
		end
	end

	A333_gpws_toggle = function()
		if A333DR_gpws_system_pos == 0 then
			A333CMD_gpws_sys_toggle:start()
		end
	end

	A333_gpws_gs_toggle = function()
		if A333DR_gpws_gs_mode_pos == 0 then
			A333CMD_gpws_gs_toggle:start()
		end
	end

	A333_gpws_flap_toggle = function()
		if A333DR_gpws_flap_mode_pos == 0 then
			A333CMD_gpws_flap_toggle:start()
		end
	end

	A333_gpws_terr_toggle = function()
		if A333DR_gpws_terr_mode_pos == 0 then
			A333CMD_gpws_terr_toggle:start()
		end
	end

	A333_seatbelt_signs_up = function()
		if A333DR_switches_seatbelts == 0 then
			A333CMD_seatbelt_signs_up:start()
		end
	end

	A333_smoking_signs_up = function()
		if A333DR_switches_no_smoking == 0 then
			A333CMD_smoking_signs_up:start()
		end
	end

	A333_transponder_standby = function()
		if A333DR_transponder_auto_on_off_pos == -1 then
		elseif A333DR_transponder_auto_on_off_pos == 0 then
			A333CMD_trans_auto_on_off_left:once()
		elseif A333DR_transponder_auto_on_off_pos == 1 then
			A333CMD_trans_auto_on_off_left:once()
			A333CMD_trans_auto_on_off_left:once()
		end
	end

	A333_ta_ra_standby = function()
		if A333DR_transponder_ta_ra_pos == 0 then
		elseif A333DR_transponder_ta_ra_pos == 1 then
			A333CMD_trans_ta_ra_left:once()
		elseif A333DR_transponder_ta_ra_pos == 2 then
			A333CMD_trans_ta_ra_left:once()
			A333CMD_trans_ta_ra_left:once()
		end
	end

	A333_nav_lights = function()
		if A333DR_nav_lights_pos == 0 then
			A333CMD_nav_lights_on:start()
		end
	end

	A333_beacon_lights = function()
		if simDR_beacon_light_on == 0 then
			simCMD_beacon_light_on:once()
		end
	end

	A333_emer_exit_lights = function()
		if A333DR_emergency_exit_pos == 0 then
			A333CMD_emergency_exit_lights_up:start()
		end
	end

	A333_apu_master = function()
		if A333DR_apu_master_pos == 0 then
			A333CMD_apu_master_toggle:start()
		end
	end

	A333_apu_master_off = function()
		if A333DR_apu_master_pos == 1 then
			A333CMD_apu_master_toggle:start()
		end
	end

	A333_apu_start = function()
		A333CMD_apu_start:start()
	end

	A333_apu_bleed = function()
		if A333DR_apu_bleed_pos == 0 then
			simCMD_apu_bleed:start()
		end
	end

	A333_apu_bleed_off = function()
		if A333DR_apu_bleed_pos == 1 then
			simCMD_apu_bleed:start()
		end
	end

	A333_apu_gen = function()
		if A333DR_apu_gen_pos == 0 then
			A333CMD_apu_gen_toggle:start()
		end
	end

	A333_apu_gen_off = function()
		if A333DR_apu_gen_pos >= 0.995 then
			A333CMD_apu_gen_toggle:start()
		end
	end

	A333_fuel_tank_left1 = function()
		if A333DR_fuel_tank_left1_pos == 0 then
			A333CMD_fuel_tank_left1_tog:start()
		end
	end

	A333_fuel_tank_left2 = function()
		if A333DR_fuel_tank_left2_pos == 0 then
			A333CMD_fuel_tank_left2_tog:start()
		end
	end

	A333_fuel_tank_left_stby = function()
		if A333DR_fuel_tank_left_stby_pos == 0 then
			A333CMD_fuel_tank_left_stby_tog:start()
		end
	end

	A333_fuel_tank_right1 = function()
		if A333DR_fuel_tank_right1_pos == 0 then
			A333CMD_fuel_tank_right1_tog:start()
		end
	end

	A333_fuel_tank_right2 = function()
		if A333DR_fuel_tank_right2_pos == 0 then
			A333CMD_fuel_tank_right2_tog:start()
		end
	end

	A333_fuel_tank_right_stby = function()
		if A333DR_fuel_tank_right_stby_pos == 0 then
			A333CMD_fuel_tank_right_stby_tog:start()
		end
	end

	A333_fuel_tank_ctr_left = function()
		if A333DR_fuel_tank_ctr_left_pos == 0 then
			A333CMD_fuel_tank_center_left_tog:start()
		end
	end

	A333_fuel_tank_ctr_right = function()
		if A333DR_fuel_tank_ctr_right_pos == 0 then
			A333CMD_fuel_tank_center_right_tog:start()
		end
	end

	A333_eng_mode_IGN_START = function()
		simDR_eng_mode_sel = 1
	end

	A333_eng_mode_NORM = function()
		simDR_eng_mode_sel = 0
	end

	A333_generator1_on = function()
		if A333DR_generator1_pos == 0 then
			simCMD_generator1_toggle:start()
		end
	end

	A333_generator2_on = function()
		if A333DR_generator2_pos == 0 then
			simCMD_generator2_toggle:start()
		end
	end

	A333_elec_hyd_green_on = function()
		if A333DR_elec_green_hyd_pos == 0 then
			A333CMD_elec_hyd_green_toggle:start()
		end
	end

	A333_elec_hyd_blue_on = function()
		if A333DR_elec_blue_hyd_pos == 0 then
			A333CMD_elec_hyd_blue_toggle:start()
		end
	end

	A333_elec_hyd_yellow_on = function()
		if A333DR_elec_yellow_hyd_pos == 0 then
			A333CMD_elec_hyd_yellow_toggle:start()
		end
	end

	A333_eng1_hyd_green_on = function()
		if A333DR_eng1_hyd_green == 0 then
			simCMD_hydraulic_eng1A_toggle:start()
		end
	end

	A333_eng1_hyd_blue_on = function()
		if A333DR_eng1_hyd_blue == 0 then
			simCMD_hydraulic_eng1C_toggle:start()
		end
	end

	A333_eng2_hyd_yellow_on = function()
		if A333DR_eng2_hyd_yellow == 0 then
			simCMD_hydraulic_eng2B_toggle:start()
		end
	end

	A333_eng2_hyd_green_on = function()
		if A333DR_eng2_hyd_green == 0 then
			simCMD_hydraulic_eng2A_toggle:start()
		end
	end

	A333_bleed1_on = function()
		if A333DR_bleed1_pos == 0 then
			simCMD_bleed1_toggle:start()
		end
	end

	A333_bleed2_on = function()
		if A333DR_bleed2_pos == 0 then
			simCMD_bleed2_toggle:start()
		end
	end

	A333_pack1_on = function()
		if A333DR_pack1_pos == 0 then
			simCMD_pack_left_toggle:start()
		end
	end

	A333_pack2_on = function()
		if A333DR_pack2_pos == 0 then
			simCMD_pack_right_toggle:start()
		end
	end

	A333_bus_tie_on = function()
		if A333DR_bus_tie_pos == 0 then
			simCMD_bus_tie_toggle:start()
		end
	end

	A333_hot_air1_on = function()
		if A333DR_hot_air1_pos == 0 then
			A333CMD_hot_air1_toggle:start()
		end
	end

	A333_hot_air2_on = function()
		if A333DR_hot_air2_pos == 0 then
			A333CMD_hot_air2_toggle:start()
		end
	end

	A333_cargo_fwd_isol_on = function()
		if A333_cargo_cond_fwd_isol_valve_pos == 0 then
			A333CMD_cargo_cond_fwd_isol_valve_tog:start()
		end
	end

	A333_cargo_bulk_isol_on = function()
		if A333_cargo_cond_bulk_isol_valve_pos == 0 then
			A333CMD_cargo_cond_bulk_isol_valve_tog:start()
		end
	end

	A333_cargo_hot_air_on = function()
		if A333_cargo_cond_hot_air_pos == 0 then
			A333CMD_cargo_cond_hot_air_tog:start()
		end
	end

	A333_vent_ext_ovrd_on = function()
		if A333_ventilation_extract_ovrd_pos == 0 then
			A333CMD_ventilation_extract_ovrd_tog:start()
		end
	end

	A333_cabin_fan_on = function()
		if A333_cabin_fan_pos == 0 then
			A333CMD_cabin_fan_tog:start()
		end
	end

	A333_clear_ECAM = function()
		A333CMD_clear_ECAM_warn:start()
	end

	A333_master_warn = function()
		simCMD_master_warn_clear:start()
	end


----- AUTO-BOARD SEQUENCE ---------------------------------------------------------------

function A333_autoboard_init()
	if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
	    stop_timer(A333_autoboard_phase_timeout)
	end
    autoboard.step = -1
    autoboard.phase = {}
    autoboard.sequence_timeout = false
    autoboard.in_progress = 0
end

function A333_print_autoboard_begin()
    print("+----------------------------------------------+")
    print("|          AUTO-BOARD SEQUENCE BEGIN           |")
    print("+----------------------------------------------+")
end

function A333_print_autoboard_abort()
    print("+----------------------------------------------+")
    print("|         AUTO-BOARD SEQUENCE ABORTED          |")
    print("+----------------------------------------------+")
end

function A333_print_autoboard_completed()
    print("+----------------------------------------------+")
    print("|        AUTO-BOARD SEQUENCE COMPLETED         |")
    print("+----------------------------------------------+")
end

function A333_print_autoboard_monitor(step, phase)
    A333_print_sequence_status(step, phase, "Monitoring...")
end

function A333_print_autoboard_timer_start(step, phase)
    A333_print_sequence_status(step, phase, "Auto-Board Phase Timer Started...")
end

function A333_autoboard_phase_monitor(time)
    if autoboard.phase[autoboard.step] == 2 then
        A333_print_autoboard_monitor(autoboard.step, autoboard.phase[autoboard.step])       -- PRINT THE MONITOR PHASE MESSAGE
        if is_timer_scheduled(A333_autoboard_phase_timeout) == false then                   -- START MONITOR TIMER
            run_after_time(A333_autoboard_phase_timeout, time)
        end
        autoboard.phase[autoboard.step] = 3                                                 -- INCREMENT THE PHASE
        A333_print_autoboard_timer_start(autoboard.step, autoboard.phase[autoboard.step])   -- PRINT THE TIMER MESSAGE
    end
end

function A333_autoboard_step_failed(step, phase)
    A333_print_sequence_status(step, phase, "***  F A I L E D  ***")
    autoboard.sequence_timeout = false
    autoboard.step = 700
end

function A333_autoboard_step_completed(step, phase, message)
    A333_print_sequence_status(step, phase, message)
    A333_print_completed_line()
    autoboard.step = autoboard.step + 1.0
    autoboard.phase[autoboard.step] = 1
end

function A333_autoboard_seq_aborted()
    A333_print_autoboard_abort()
    autoboard.step = 800
    simDR_autoboard_in_progress = 0
    autoboard.in_progress = 0
    simDR_autostart_in_progress = 0
    autostart.in_progress = 0
end

function A333_autoboard_seq_completed()
    A333_print_autoboard_completed()
    autoboard.step = 999
    simDR_autoboard_in_progress = 0
    autoboard.in_progress = 0
end

function A333_autoboard_phase_timeout()
    autoboard.sequence_timeout = true
    A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Step Has Timed Out...")
end


function A333_auto_board()


    ----- AUTO-BOARD STEP 0: COMMAND HAS BEEN INVOKED
    if autoboard.step == 0 then
        A333_print_autoboard_begin()                                                        -- PRINT THE AUTO-BOARD HEADER
        autoboard.step = 1                                                                  -- SET THE STEP
        autoboard.phase[autoboard.step] = 1                                                 -- SET THE PHASE


    ----- AUTO-BOARD STEP 1: INIT COLD & DARK
    elseif autoboard.step == 1 then

        -- PHASE 1: SET THE FLAG
        if autoboard.phase[autoboard.step] == 1 then
           A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "Initialize Aircraft Cold & Dark...")  -- PRINT THE START PHASE MESSAGE

			A333DR_init_audio_CD = 1
			A333DR_init_autopilot_CD = 1
			A333DR_init_chrono_CD = 1
			A333DR_init_comms_CD = 1
			A333DR_init_fire_CD = 1
			A333DR_init_switches_CD = 1
			A333DR_init_systems_CD = 1
			A333DR_init_transponder_CD = 1

 			autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE

        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            --end
            elseif A333DR_init_audio_CD == 2                                                -- PHASE WAS SUCCESSFUL, ALL SCRIPTS HAVE BEEN INITIALIZED TO COLD & DARK
                and A333DR_init_autopilot_CD == 2
                and A333DR_init_chrono_CD == 2
                and A333DR_init_comms_CD == 2
                and A333DR_init_fire_CD == 2
                and A333DR_init_switches_CD == 2
                and A333DR_init_systems_CD == 2
              	and A333DR_init_transponder_CD == 2

            then
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end

					A333DR_init_audio_CD = 0
					A333DR_init_autopilot_CD = 0
					A333DR_init_chrono_CD = 0
					A333DR_init_comms_CD = 0
					A333DR_init_fire_CD = 0
					A333DR_init_switches_CD = 0
					A333DR_init_systems_CD = 0
					A333DR_init_transponder_CD = 0

            autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "Completed, Aircraft is Cold & Dark")
        end



	----- AUTO-BOARD STEP 2: SET PARKING BRAKE
    elseif autoboard.step == 2 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "PARKING BRAKE TO FULL...")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_parking_brake_set, 0.5)										-- SET BRAKE
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(1.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_parking_brake_level == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "PARKING BRAKE SET")
        end

  	----- AUTO-BOARD STEP 3: Throttle 1 to IDLE
    elseif autoboard.step == 3 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "CHECK THROTTLE 1 IDLE...")  -- PRINT THE START PHASE MESSAGE
			A333_throttle1_set_10()														-- PUSH THROTTLE FORWARD
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(3.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_throttle_pos[0] <= 0.101
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "THROTTLE 1 CHECKING")
        end

  	----- AUTO-BOARD STEP 4: Throttle 1 to IDLE
    elseif autoboard.step == 4 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "CHECK THROTTLE 1 IDLE...")  -- PRINT THE START PHASE MESSAGE
			run_after_time(A333_throttle1_set_idle, 1.0)									-- PULL THROTTLE BACK
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_throttle_pos[0] == 0
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "THROTTLE 1 AT IDLE")
        end

  	----- AUTO-BOARD STEP 5: Throttle 2 to IDLE
    elseif autoboard.step == 5 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "CHECK THROTTLE 2 IDLE...")  -- PRINT THE START PHASE MESSAGE
            A333_throttle2_set_10()															-- PUSH THROTTLE FORWARD
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(3.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_throttle_pos[1] <= 0.101
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "THROTTLE 2 CHECKING")
        end

  	----- AUTO-BOARD STEP 6: Throttle 2 to IDLE
    elseif autoboard.step == 6 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "CHECK THROTTLE 2 IDLE...")  -- PRINT THE START PHASE MESSAGE
			run_after_time(A333_throttle2_set_idle, 1.0)									-- PULL THROTTLE BACK
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_throttle_pos[1] == 0
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "THROTTLE 2 AT IDLE")
        end

  	----- AUTO-BOARD STEP 7: Engine Master 1 CHECK OFF
    elseif autoboard.step == 7 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "CHECK ENGINE MASTER 1 OFF..")  -- PRINT THE START PHASE MESSAGE
			run_after_time(A333_engine_master1_off, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_engine_master[0] == 0 and A333DR_eng_master1_lift == 0.002
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ENGINE MASTER 1 OFF")
        end

  	----- AUTO-BOARD STEP 8: Engine Master 2 CHECK OFF
    elseif autoboard.step == 8 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "CHECK ENGINE MASTER 2 OFF..")  -- PRINT THE START PHASE MESSAGE
			run_after_time(A333_engine_master2_off, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_engine_master[1] == 0 and A333DR_eng_master2_lift == 0.002
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ENGINE MASTER 2 OFF")
        end

  	----- AUTO-BOARD STEP 9: BATT 1 ON
    elseif autoboard.step == 9 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "BATT 1 TO ON..")  -- PRINT THE START PHASE MESSAGE
			run_after_time(A333_battery1_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_battery1_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_battery_status[0] == 1
            then	                                                                        -- PHASE WAS SUCCESSFUL
  				simCMD_battery1_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "BATT 1 ON")
        end

  	----- AUTO-BOARD STEP 10: BATT 2 ON
    elseif autoboard.step == 10 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "BATT 2 TO ON..")  -- PRINT THE START PHASE MESSAGE
			run_after_time(A333_battery2_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_battery2_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_battery_status[1] == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
				simCMD_battery2_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "BATT 2 ON")
        end

  	----- AUTO-BOARD STEP 11: APU BATT ON
    elseif autoboard.step == 11 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "APU BATT TO ON..")  -- PRINT THE START PHASE MESSAGE
			run_after_time(A333_apu_batt_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_apu_battery_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_battery_status[2] == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
				A333CMD_apu_battery_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "APU BATT ON")
        end

	----- AUTO-BOARD STEP 12: CLEAR ECAM WARNINGS
    elseif autoboard.step == 12 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "CLEAR ECAM..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_clear_ECAM, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_clear_ECAM_warn:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333_ecam_clear_pos == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_clear_ECAM_warn:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ECAM CLEAR")
        end

	----- AUTO-BOARD STEP 13: CLEAR ECAM WARNINGS
    elseif autoboard.step == 13 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "CLEAR ECAM AGAIN..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_clear_ECAM, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_clear_ECAM_warn:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333_ecam_clear_pos == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_clear_ECAM_warn:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ECAM FULLY CLEAR")
        end


	----- AUTO-BOARD STEP 14: NAV LIGHTS ON
    elseif autoboard.step == 14 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET NAV LIGHTS TO ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_nav_lights, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_nav_lights_on:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_nav_lights_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_nav_lights_on:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "NAV LIGHTS ON")
        end


	----- AUTO-BOARD STEP 15: EMERGENCY EXIT LIGHTS ARM
    elseif autoboard.step == 15 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "ARM EMERGENCY EXIT LIGHTS..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_emer_exit_lights, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_emergency_exit_lights_up:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_emergency_exit_pos == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_emergency_exit_lights_up:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "EMERGENCY EXIT LIGHTS ARMED")
        end



	----- AUTO-BOARD STEP 16: APU MASTER ON
    elseif autoboard.step == 16 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "APU MASTER TO ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_apu_master, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_apu_master_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_apu_master_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_apu_master_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "APU MASTER SWITCH ON")
        end


	----- AUTO-BOARD STEP 17: APU START
    elseif autoboard.step == 17 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "PUSH APU START..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_apu_start, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_apu_start:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_apu_mode == 2
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_apu_start:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "APU START IN PROGRESS")
        end

	----- AUTO-BOARD STEP 18: APU WAIT
    elseif autoboard.step == 18 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "WAIT FOR APU..")  -- PRINT THE START PHASE MESSAGE
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(75.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_apu_N1 > 95
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "APU RUNNING")
        end

	----- AUTO-BOARD STEP 19: APU GENERATOR ON
    elseif autoboard.step == 19 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "TURN ON APU GENERATOR..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_apu_gen, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_apu_gen_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_apu_gen == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_apu_gen_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "APU GENERATOR ON")
        end



  	----- AUTO-BOARD STEP 20: GALLEY TO AUTO
    elseif autoboard.step == 20 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET GALLEY TO AUTO..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_galley_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then	                                    -- PHASE FAILED
            	A333CMD_galley_power:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_galley_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_galley_power:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "GALLEY ON AUTO")
        end

  	----- AUTO-BOARD STEP 21: COMMERCIAL POWER ON
    elseif autoboard.step == 21 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET COMMERCIAL POWER TO ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_commercial_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_commercial_power:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_commercial_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_commercial_power:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "COMMERCIAL POWER ON")
        end

  	----- AUTO-BOARD STEP 22: PAX SYSTEMS POWER ON
    elseif autoboard.step == 22 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET PAX SYSTEMS ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_pax_sys_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_pax_system_power:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_pax_sys_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_pax_system_power:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "PAX SYSTEMS ON")
        end


  	----- AUTO-BOARD STEP 23: SATCOM SYSTEM POWER ON
    elseif autoboard.step == 23 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET SATCOM SYSTEM ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_pax_satcom_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_pax_satcom_power:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_pax_satcom_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_pax_satcom_power:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "SATCOM SYSTEM ON")
        end


  	----- AUTO-BOARD STEP 24: IFEC SYSTEM POWER ON
    elseif autoboard.step == 24 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET IFEC SYSTEM ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_pax_IFEC_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_pax_IFEC_power:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_pax_IFEC_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_pax_IFEC_power:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "IFEC SYSTEM ON")
        end

  	----- AUTO-BOARD STEP 25: VENTILATION EXTRACT TO AUTO
    elseif autoboard.step == 25 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET VENT EXTRACT AUTO..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_vent_ext_ovrd_on, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_ventilation_extract_ovrd_tog:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333_ventilation_extract_ovrd_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_ventilation_extract_ovrd_tog:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "VENT EXTRACT AUTO")
        end

  	----- AUTO-BOARD STEP 26: CABIN FANS ON
    elseif autoboard.step == 26 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET CABIN FANS ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_cabin_fan_on, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_cabin_fan_tog:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333_cabin_fan_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_cabin_fan_tog:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "CABIN FANS ON")
        end


  	----- AUTO-BOARD STEP 27: IR1 ON
    elseif autoboard.step == 27 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET IR1 ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_ir1_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_ir1_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_ir1_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_ir1_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "IR1 ON")
        end

  	----- AUTO-BOARD STEP 28: IR2 ON
    elseif autoboard.step == 28 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET IR2 ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_ir2_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_ir2_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_ir2_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_ir2_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "IR2 ON")
        end

  	----- AUTO-BOARD STEP 29: IR3 ON
    elseif autoboard.step == 29 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET IR3 ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_ir3_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_ir3_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_ir3_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_ir3_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "IR3 ON")
        end

  	----- AUTO-BOARD STEP 30: ADR1 ON
    elseif autoboard.step == 30 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET ADR1 ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_adr1_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_adr1_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_adr1_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_adr1_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ADR1 ON")
        end

  	----- AUTO-BOARD STEP 31: ADR2 ON
    elseif autoboard.step == 31 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET ADR2 ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_adr2_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_adr2_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_adr2_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_adr2_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ADR2 ON")
        end

  	----- AUTO-BOARD STEP 32: ADR3 ON
    elseif autoboard.step == 32 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET ADR3 ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_adr3_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_adr3_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_adr3_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_adr3_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ADR3 ON")
        end

	----- AUTO-BOARD STEP 33: ADIRS1 TO NAV
    elseif autoboard.step == 33 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET ADIRS1 TO NAV..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_adirs1_knob_set, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_adirs_knob1_pos == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ADIRS1 ON NAV")
        end

	----- AUTO-BOARD STEP 34: ADIRS2 TO NAV
    elseif autoboard.step == 34 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET ADIRS2 TO NAV..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_adirs2_knob_set, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_adirs_knob2_pos == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ADIRS2 ON NAV")
        end

	----- AUTO-BOARD STEP 35: ADIRS3 TO NAV
    elseif autoboard.step == 35 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET ADIRS3 TO NAV..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_adirs3_knob_set, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_adirs_knob3_pos == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ADIRS3 ON NAV")
        end

	----- AUTO-BOARD STEP 36: PRIM1 COVER OPEN
    elseif autoboard.step == 36 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "OPEN PRIM1 COVER..")  -- PRINT THE START PHASE MESSAGE
 			A333CMD_switch_cover04:once()
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(3.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_switch_cover[4] == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "PRIM1 COVER OPEN")
        end

	----- AUTO-BOARD STEP 37: PUSH PRIM1 TO ON
    elseif autoboard.step == 37 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "PRIM1 TO ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_prim1_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_fcc_prim1_tog:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_prim1_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_fcc_prim1_tog:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "PRIM1 ON")
        end

	----- AUTO-BOARD STEP 38: SEC1 COVER OPEN
    elseif autoboard.step == 38 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "OPEN SEC1 COVER..")  -- PRINT THE START PHASE MESSAGE
 			A333CMD_switch_cover05:once()
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(3.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_switch_cover[5] == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "SEC1 COVER OPEN")
        end

	----- AUTO-BOARD STEP 39: PUSH SEC1 TO ON
    elseif autoboard.step == 39 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SEC1 TO ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_sec1_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_fcc_sec1_tog:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_sec1_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_fcc_sec1_tog:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "SEC1 ON")
        end

	----- AUTO-BOARD STEP 40: PRIM2 COVER OPEN
    elseif autoboard.step == 40 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "OPEN PRIM2 COVER..")  -- PRINT THE START PHASE MESSAGE
 			A333CMD_switch_cover33:once()
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(3.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_switch_cover[33] == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "PRIM2 COVER OPEN")
        end

	----- AUTO-BOARD STEP 41: PUSH PRIM1 TO ON
    elseif autoboard.step == 41 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "PRIM2 TO ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_prim2_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_fcc_prim2_tog:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_prim2_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_fcc_prim2_tog:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "PRIM2 ON")
        end

	----- AUTO-BOARD STEP 42: SEC1 COVER OPEN
    elseif autoboard.step == 42 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "OPEN SEC2 COVER..")  -- PRINT THE START PHASE MESSAGE
 			A333CMD_switch_cover34:once()
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(3.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_switch_cover[34] == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "SEC2 COVER OPEN")
        end

	----- AUTO-BOARD STEP 43: PUSH SEC1 TO ON
    elseif autoboard.step == 43 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SEC2 TO ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_sec2_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_fcc_sec2_tog:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_sec2_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_fcc_sec2_tog:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "SEC2 ON")
        end

	----- AUTO-BOARD STEP 44: PRIM3 COVER OPEN
    elseif autoboard.step == 44 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "OPEN PRIM3 COVER..")  -- PRINT THE START PHASE MESSAGE
 			A333CMD_switch_cover35:once()
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(3.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_switch_cover[35] == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "PRIM3 COVER OPEN")
        end

	----- AUTO-BOARD STEP 45: PUSH PRIM3 TO ON
    elseif autoboard.step == 45 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "PRIM3 TO ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_prim3_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_fcc_prim3_tog:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_prim3_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_fcc_prim3_tog:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "PRIM3 ON")
        end

	----- AUTO-BOARD STEP 46: TURBULENCE DAMPER ON
    elseif autoboard.step == 46 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "TURB DAMPER TO ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_turb_damp_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_yaw_damper_tog:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_turb_damp_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	simCMD_yaw_damper_tog:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "TURB DAMPER ON")
        end


     ----- AUTO-BOARD STEP 47: ARM ELECTRICAL HYD GREEN
    elseif autoboard.step == 47 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "GREEN ELEC HYDRAULICS TO AUTO..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_elec_hyd_green_on, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_elec_hyd_green_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_elec_green_hyd_pos >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_elec_hyd_green_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "GREEN ELECTRIC HYDRAULICS IN AUTO")
        end

    ----- AUTO-BOARD STEP 48: ARM ELECTRICAL HYD BLUE
    elseif autoboard.step == 48 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "BLUE ELEC HYDRAULICS TO STBY..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_elec_hyd_blue_on, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_elec_hyd_blue_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_elec_blue_hyd_pos >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_elec_hyd_blue_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "BLUE ELECTRIC HYDRAULICS ON STANDBY")
        end

    ----- AUTO-BOARD STEP 49: ARM ELECTRICAL HYD YELLOW
    elseif autoboard.step == 49 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "YELLOW ELEC HYDRAULICS TO AUTO..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_elec_hyd_yellow_on, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_elec_hyd_yellow_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_elec_yellow_hyd_pos >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_elec_hyd_yellow_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "YELLOW ELECTRIC HYDRAULICS IN AUTO")
        end

    ----- AUTO-BOARD STEP 50: OPEN ENGINE 1 GREEN HYDRAULIC COVER
    elseif autoboard.step == 50 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "ENGINE 1 GREEN HYDRAULIC COVER OPEN..")  -- PRINT THE START PHASE MESSAGE
            A333CMD_switch_cover15:once()
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_switch_cover[15] == 1
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "COVER OPEN")
        end

    ----- AUTO-BOARD STEP 51: TURN ON ENGINE 1 GREEN HYDRAULIC PUMP
    elseif autoboard.step == 51 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "ENGINE 1 GREEN HYDRAULIC PUMP TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_eng1_hyd_green_on, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_hydraulic_eng1A_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_eng1_hyd_green >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				simCMD_hydraulic_eng1A_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ENGINE 1 GREEN HYDRAULIC PUMP ON")
        end

    ----- AUTO-BOARD STEP 52: OPEN ENGINE 1 BLUE HYDRAULIC COVER
    elseif autoboard.step == 52 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "ENGINE 1 BLUE HYDRAULIC COVER OPEN..")  -- PRINT THE START PHASE MESSAGE
            A333CMD_switch_cover17:once()
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_switch_cover[17] == 1
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "COVER OPEN")
        end

    ----- AUTO-BOARD STEP 53: TURN ON ENGINE 1 BLUE HYDRAULIC PUMP
    elseif autoboard.step == 53 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "ENGINE 1 BLUE HYDRAULIC PUMP TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_eng1_hyd_blue_on, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_hydraulic_eng1C_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_eng1_hyd_blue >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				simCMD_hydraulic_eng1C_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ENGINE 1 BLUE HYDRAULIC PUMP ON")
        end

    ----- AUTO-BOARD STEP 54: OPEN ENGINE 2 YELLOW HYDRAULIC COVER
    elseif autoboard.step == 54 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "ENGINE 2 YELLOW HYDRAULIC COVER OPEN..")  -- PRINT THE START PHASE MESSAGE
            A333CMD_switch_cover19:once()
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_switch_cover[19] == 1
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "COVER OPEN")
        end

    ----- AUTO-BOARD STEP 55: TURN ON ENGINE 2 YELLOW HYDRAULIC PUMP
    elseif autoboard.step == 55 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "ENGINE 2 YELLOW HYDRAULIC PUMP TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_eng2_hyd_yellow_on, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_hydraulic_eng2B_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_eng2_hyd_yellow >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				simCMD_hydraulic_eng2B_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ENGINE 2 YELLOW HYDRAULIC PUMP ON")
        end

    ----- AUTO-BOARD STEP 56: OPEN ENGINE 2 GREEN HYDRAULIC COVER
    elseif autoboard.step == 56 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "ENGINE 2 GREEN HYDRAULIC COVER OPEN..")  -- PRINT THE START PHASE MESSAGE
            A333CMD_switch_cover20:once()
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_switch_cover[20] == 1
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "COVER OPEN")
        end

    ----- AUTO-BOARD STEP 57: TURN ON ENGINE 2 GREEN HYDRAULIC PUMP
    elseif autoboard.step == 57 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "ENGINE 2 GREEN HYDRAULIC PUMP TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_eng2_hyd_green_on, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_hydraulic_eng2A_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_eng2_hyd_green >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				simCMD_hydraulic_eng2A_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "ENGINE 2 GREEN HYDRAULIC PUMP ON")
        end


	----- AUTO-BOARD STEP 58: SET MAIN INTEGRAL LIGHTING
    elseif autoboard.step == 58 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET INTEGRAL LIGHTING..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_integral_lighting, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_instrument_brightness[13] > 0.005 and simDR_instrument_brightness[13] < 0.01
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "INTEGRAL LIGHTING ON")
        end

	----- AUTO-BOARD STEP 59: SET FCU INTEGRAL LIGHTING
    elseif autoboard.step == 59 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET FCU INTEGRAL LIGHTING..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_ap_integral_lighting, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_instrument_brightness[14] > 0.005 and simDR_instrument_brightness[14] < 0.01
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "FCU LIGHTING SET")
        end

	----- AUTO-BOARD STEP 60: SET MAIN PANEL FLOOD LIGHTING
    elseif autoboard.step == 60 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET MAIN PANEL FLOOD..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_main_panel_flood_lighting, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_generic_brightness[14] >= 0.995
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "MAIN PANEL FLOOD ON")
        end

	----- AUTO-BOARD STEP 61: CHECK MAIN GEAR HANDLE DOWN
    elseif autoboard.step == 61 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "CHECK GEAR HANDLE..")  -- PRINT THE START PHASE MESSAGE
 			simDR_gear_handle_pos = 1
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_gear_handle_pos == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "GEAR HANDLE DOWN")
        end

	----- AUTO-BOARD STEP 62: CHECK FLAPS UP
    elseif autoboard.step == 62 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "CHECK FLAP HANDLE..")  -- PRINT THE START PHASE MESSAGE
 			A333DR_handles_flap_lift = 0.01
 			simDR_flap_handle_pos = 0
 			run_after_time(A333_flap_handle_drop, 0.3)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_flap_handle_pos == 0 and A333DR_handles_flap_lift == 0
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "FLAPS UP")
        end

	----- AUTO-BOARD STEP 63: CHECK SPOILERS RETRACTED
    elseif autoboard.step == 63 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "CHECK SPOILERS..")  -- PRINT THE START PHASE MESSAGE
 			simDR_speedbrake_handle_pos = 0
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif simDR_speedbrake_handle_pos == 0
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "SPOILERS RETRACTED")
        end

	----- AUTO-BOARD STEP 64: CREW OXYGEN ON
    elseif autoboard.step == 64 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET CREW OXYGEN..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_crew_oxy_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                simCMD_crew_oxy_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_crew_oxy_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	simCMD_crew_oxy_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "CREW OXYGEN ON")
        end

	----- AUTO-BOARD STEP 65: GPWS SYSTEM ON
    elseif autoboard.step == 65 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "TURN ON GPWS SYSTEM..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_gpws_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333CMD_gpws_sys_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_gpws_system_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_gpws_sys_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "GPWS SYSTEM ON")
        end

	----- AUTO-BOARD STEP 66: GPWS G/S MODE ON
    elseif autoboard.step == 66 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "TURN ON GPWS G/S MODE..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_gpws_gs_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333CMD_gpws_gs_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_gpws_gs_mode_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_gpws_gs_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "GPWS G/S MODE ON")
        end

	----- AUTO-BOARD STEP 67: GPWS FLAP MODE ON
    elseif autoboard.step == 67 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "TURN ON GPWS FLAP MODE..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_gpws_flap_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333CMD_gpws_flap_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_gpws_flap_mode_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_gpws_flap_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "GPWS FLAP MODE ON")
        end

	----- AUTO-BOARD STEP 68: GPWS TERRAIN MODE ON
    elseif autoboard.step == 68 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "TURN ON GPWS TERRAIN MODE..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_gpws_terr_toggle, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333CMD_gpws_terr_toggle:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_gpws_terr_mode_pos >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_gpws_terr_toggle:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "GPWS TERRAIN MODE ON")
        end

	----- AUTO-BOARD STEP 69: SEATBELT LIGHTS ON
    elseif autoboard.step == 69 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET SEATBELTS TO AUTO..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_seatbelt_signs_up, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333CMD_seatbelt_signs_up:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_switches_seatbelts >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_seatbelt_signs_up:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "SEATBELTS AUTO")
        end

	----- AUTO-BOARD STEP 70: NO SMOKING LIGHTS ON
    elseif autoboard.step == 70 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET NO SMOKING SIGNS TO AUTO..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_smoking_signs_up, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333CMD_smoking_signs_up:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_switches_no_smoking >= 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	A333CMD_smoking_signs_up:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "NO SMOKING SIGNS AUTO")
        end

	----- AUTO-BOARD STEP 71: TRANSPONDER TO STANDBY
    elseif autoboard.step == 71 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET TRANSPONDER TO STANDBY..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_transponder_standby, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_transponder_auto_on_off_pos == -1
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "TRANSPONDER STANDBY")
        end

	----- AUTO-BOARD STEP 72: TRANSPONDER TA/RA TO STANDBY
    elseif autoboard.step == 72 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET TRANSPONDER TA/RA TO STANDBY..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_ta_ra_standby, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333DR_transponder_ta_ra_pos == 0
            then                                                                            -- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "TA/RA TO STANDBY")
        end

	----- AUTO-BOARD STEP 73: MASTER WARN CLEAR
    elseif autoboard.step == 73 then

        -- PHASE 1: SET THE SWITCH
        if autoboard.phase[autoboard.step] == 1 then
            A333_print_sequence_status(autoboard.step, autoboard.phase[autoboard.step], "SET TRANSPONDER TA/RA TO STANDBY..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_master_warn, 0.5)
            autoboard.phase[autoboard.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autoboard_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autoboard.phase[autoboard.step] == 3 then
            if autoboard.sequence_timeout == true then                                      -- PHASE FAILED
                simCMD_master_warn_clear:stop()
                A333_autoboard_step_failed(autoboard.step, autoboard.phase[autoboard.step])
            elseif A333_capt_mast_warn_pos == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	simCMD_master_warn_clear:stop()
                if is_timer_scheduled(A333_autoboard_phase_timeout) == true then
                    stop_timer(A333_autoboard_phase_timeout)                                -- KILL THE TIMER
                end
                autoboard.phase[autoboard.step] = 4                                         -- INCREMENT THE PHASE
            end
         end


        -- PHASE 4: COMPLETE THE STEP
        if autoboard.phase[autoboard.step] == 4 then
            A333_autoboard_step_completed(autoboard.step, autoboard.phase[autoboard.step], "TA/RA TO STANDBY")
        end


   ----- AUTOBOARD SEQUENCE COMPLETED
	elseif autoboard.step == 74 then
		autoboard.step = 888


   ----- AUTO-BOARD STEP 700: ABORT
	elseif autoboard.step == 700 then
        A333_autoboard_seq_aborted()



    ----- AUTO-BOARD STEP 888: SEQUENCE COMPLETED
    elseif autoboard.step == 888 then
        A333_autoboard_seq_completed()
        --A333_autostart_init()

   end  -- AUTO-BOARD STEPS

end -- AUTO-BOARD SEQUENCE



----- AUTO-START SEQUENCE ---------------------------------------------------------------

function A333_autostart_init()
    if is_timer_scheduled(A333_autostart_phase_timeout) == true then
        stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
    end
    autostart.step = -1
    autostart.phase = {}
    autostart.sequence_timeout = false
    autostart.in_progress = 0
end

function A333_print_autostart_begin()
    print("+----------------------------------------------+")
    print("|          AUTO-START SEQUENCE BEGIN           |")
    print("+----------------------------------------------+")
end

function A333_print_autostart_abort()
    print("+----------------------------------------------+")
    print("|         AUTO-START SEQUENCE ABORTED          |")
    print("+----------------------------------------------+")
end

function A333_print_autostart_completed()
    print("+----------------------------------------------+")
    print("|        AUTO-START SEQUENCE COMPLETED         |")
    print("+----------------------------------------------+")
end

function A333_print_autostart_monitor(step, phase)
    A333_print_sequence_status(step, phase, "Monitoring...")
end

function A333_print_autostart_timer_start(step, phase)
    A333_print_sequence_status(step, phase, "Auto-Start Phase Timer Started...")
end

function A333_autostart_phase_monitor(time)
    if autostart.phase[autostart.step] == 2 then
        A333_print_autostart_monitor(autostart.step, autostart.phase[autostart.step])       -- PRINT THE MONITOR PHASE MESSAGE
        if is_timer_scheduled(A333_autostart_phase_timeout) == false then                   -- START MONITOR TIMER
            run_after_time(A333_autostart_phase_timeout, time)
        end
        autostart.phase[autostart.step] = 3                                                 -- INCREMENT THE PHASE
        A333_print_autostart_timer_start(autostart.step, autostart.phase[autostart.step])   -- PRINT THE TIMER MESSAGE
    end
end

function A333_autostart_step_failed(step, phase)
    A333_print_sequence_status(step, phase, "***  F A I L E D  ***")
    autostart.sequence_timeout = false
    autostart.step = 700
end

function A333_autostart_step_completed(step, phase, message)
    A333_print_sequence_status(step, phase, message)
    A333_print_completed_line()
    autostart.step = autostart.step + 1.0
    autostart.phase[autostart.step] = 1
end

function A333_autostart_seq_aborted()
    A333_print_autostart_abort()
    autostart.step = 800
end

function A333_autostart_seq_completed()
    A333_print_autostart_completed()
    autostart.step = -1
    simDR_autostart_in_progress = 0
end

function A333_autostart_phase_timeout()
    autostart.sequence_timeout = true
    A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "Step Has Timed Out...")
end


function A333_auto_start()


    ----- AUTO-START STEP 0: COMMAND HAS BEEN INVOKED
    if autostart.step == 0 then

        -- RUN AUTOBOARD SEQUENCE IF NOT ALREADY PROCESSED
        if autoboard.step < 0 then
            simCMD_autoboard:once()
        else
            -- AUTOBOARD SEQUENCE COMPLETED: BEGIN AUTOSTART
            if autoboard.step == 999 then
                simDR_autostart_in_progress = 1
                A333_print_autostart_begin()
                autostart.step = 1
                autostart.phase[autostart.step] = 1
                A333_autoboard_init()
            end
        end


	----- AUTO-START STEP 1: BEACON ON
    elseif autostart.step == 1 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "SET BEACON ON..")  -- PRINT THE START PHASE MESSAGE
 			run_after_time(A333_beacon_lights, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(2.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_beacon_light_on:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_beacon_light_on == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	simCMD_beacon_light_on:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "BEACON ON")
        end


	----- AUTO-START STEP 2: APU BLEED AIR ON
    elseif autostart.step == 2 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "TURN ON APU BLEED..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_apu_bleed, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(10.0)

        -- PHASE 3: MONITOR THE SIM STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_apu_bleed:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_apu_bleed == 1
            then                                                                            -- PHASE WAS SUCCESSFUL
            	simCMD_apu_bleed:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
         end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "APU BLEED AIR ON")
        end



    ----- AUTO-START STEP 3: Throttle 1 Idle Check
    elseif autostart.step == 3 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "CHECK THROTTLE 1 IDLE..")  -- PRINT THE START PHASE MESSAGE
            A333_throttle1_set_10()															-- PUSH THROTTLE FORWARD SLIGHTLY
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_throttle_pos[0] > 0.09 and simDR_throttle_pos[0] <= 0.101
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "THROTTLE 1 IDLE")
        end

    ----- AUTO-START STEP 4: Throttle 1 to IDLE
    elseif autostart.step == 4 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "CHECK THROTTLE 1 IDLE..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_throttle1_set_idle, 1.0)									-- PULL THROTTLE BACK
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_throttle_pos[0] == 0
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "THROTTLE 1 AT IDLE")
        end

    ----- AUTO-START STEP 5: Throttle 2 Idle Check
    elseif autostart.step == 5 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "CHECK THROTTLE 2 IDLE..")  -- PRINT THE START PHASE MESSAGE
            A333_throttle2_set_10()															-- PUSH THROTTLE FORWARD SLIGHTLY
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_throttle_pos[1] > 0.09 and simDR_throttle_pos[1] <= 0.101
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "THROTTLE 2 IDLE")
        end

    ----- AUTO-START STEP 6: Throttle 2 to IDLE
    elseif autostart.step == 6 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "CHECK THROTTLE 2 IDLE..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_throttle2_set_idle, 1.0)									-- PULL THROTTLE BACK
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_throttle_pos[1] == 0
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "THROTTLE 2 AT IDLE")
        end

    ----- AUTO-START STEP 7: Left 1 Fuel Pump ON
    elseif autostart.step == 7 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "LEFT 1 FUEL PUMP TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_fuel_tank_left1, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(2.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_fuel_tank_left1_tog:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_fuel_tank_pump[0] == 1
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_fuel_tank_left1_tog:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "LEFT 1 FUEL PUMP ON")
        end

    ----- AUTO-START STEP 8: Left 2 Fuel Pump ON
    elseif autostart.step == 8 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "LEFT 2 FUEL PUMP TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_fuel_tank_left2, 0.3)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(2.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_fuel_tank_left2_tog:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333DR_fuel_tank_left2_pos >= 1
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_fuel_tank_left2_tog:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "LEFT 2 FUEL PUMP ON")
        end

    ----- AUTO-START STEP 9: Left Standby Fuel Pump ON
    elseif autostart.step == 9 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "LEFT STANDBY FUEL PUMP TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_fuel_tank_left_stby, 0.3)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(2.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_fuel_tank_left_stby_tog:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333DR_fuel_tank_left_stby_pos >= 1
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_fuel_tank_left_stby_tog:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "LEFT STANDBY FUEL PUMP ON")
        end

    ----- AUTO-START STEP 10: Right 1 Fuel Pump ON
    elseif autostart.step == 10 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "RIGHT 1 FUEL PUMP TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_fuel_tank_right1, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(2.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_fuel_tank_right1_tog:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_fuel_tank_pump[2] == 1
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_fuel_tank_right1_tog:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "RIGHT 1 FUEL PUMP ON")
        end

    ----- AUTO-START STEP 11: Right 2 Fuel Pump ON
    elseif autostart.step == 11 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "RIGHT 2 FUEL PUMP TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_fuel_tank_right2, 0.3)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(2.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_fuel_tank_right2_tog:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333DR_fuel_tank_right2_pos >= 1
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_fuel_tank_right2_tog:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "RIGHT 2 FUEL PUMP ON")
        end

    ----- AUTO-START STEP 12: Right Standby Fuel Pump ON
    elseif autostart.step == 12 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "RIGHT STANDBY FUEL PUMP TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_fuel_tank_right_stby, 0.3)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(2.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_fuel_tank_right_stby_tog:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333DR_fuel_tank_right_stby_pos >= 1
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_fuel_tank_right_stby_tog:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "RIGHT STANDBY FUEL PUMP ON")
        end

    ----- AUTO-START STEP 13: Left Center Fuel Pump ON
    elseif autostart.step == 13 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "LEFT CENTER FUEL PUMP TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_fuel_tank_ctr_left, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(2.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_fuel_tank_center_left_tog:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_fuel_tank_pump[1] == 1
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_fuel_tank_center_left_tog:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "LEFT CENTER FUEL PUMP ON")
        end

    ----- AUTO-START STEP 14: Right Center Fuel Pump ON
    elseif autostart.step == 14 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "RIGHT CENTER FUEL PUMP TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_fuel_tank_ctr_right, 0.3)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(2.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_fuel_tank_center_right_tog:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333DR_fuel_tank_ctr_right_pos >= 1
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_fuel_tank_center_right_tog:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "RIGHT CENTER FUEL PUMP ON")
        end

    ----- AUTO-START STEP 15: ENGINE MODE TO IGN/START
    elseif autostart.step == 15 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "ENGINE MODE SELECTOR TO IGN/START..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_eng_mode_IGN_START, 0.7)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(2.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_eng_mode_sel == 1
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "IGN/START SELECTED")
        end

    ----- AUTO-START STEP 16: ENGINE MASTER 1 TO RUN
    elseif autostart.step == 16 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "ENGINE MASTER 1 TO RUN..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_engine_master1_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(4.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_engine_master[0] == 1 and A333DR_eng_master1_lift == 0
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "ENGINE 1 STARTING")
        end

    ----- AUTO-START STEP 17: MONITOR ENGINE 1 N3
    elseif autostart.step == 17 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "MONITOR ENGINE 1 N3..")  -- PRINT THE START PHASE MESSAGE
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(60.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_engine_n3[0] > 58
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "ENGINE 1 STARTED")
        end

    ----- AUTO-START STEP 18: TURN ON GENERATOR 1
    elseif autostart.step == 18 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "GENERATOR 1 TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_generator1_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_generator1_toggle:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_generator_on[0] == 1
				then                                          								-- PHASE WAS SUCCESSFUL
				simCMD_generator1_toggle:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "GENERATOR 1 ON")
        end

    ----- AUTO-START STEP 19: ENGINE MASTER 2 TO RUN
    elseif autostart.step == 19 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "ENGINE MASTER 2 TO RUN..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_engine_master2_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(4.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_engine_master[1] == 1 and A333DR_eng_master2_lift == 0
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "ENGINE 2 STARTING")
        end

    ----- AUTO-START STEP 20: MONITOR ENGINE 2 N3
    elseif autostart.step == 20 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "MONITOR ENGINE 2 N3..")  -- PRINT THE START PHASE MESSAGE
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(60.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_engine_n3[1] > 58
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "ENGINE 2 STARTED")
        end

    ----- AUTO-START STEP 21: TURN ON GENERATOR 2
    elseif autostart.step == 21 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "GENERATOR 2 TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_generator2_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_generator2_toggle:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_generator_on[1] == 1
				then                                          								-- PHASE WAS SUCCESSFUL
				simCMD_generator2_toggle:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "GENERATOR 2 ON")
        end


    ----- AUTO-START STEP 22: TURN BUS TIE TO AUTO
    elseif autostart.step == 22 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "BUS TIE TO AUTO..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_bus_tie_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(5.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_bus_tie_toggle:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333DR_bus_tie_pos >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				simCMD_bus_tie_toggle:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "BUS TIE AUTO")
        end


    ----- AUTO-START STEP 23: TURN OFF APU BLEED
    elseif autostart.step == 23 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "APU BLEED TO OFF..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_apu_bleed_off, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_apu_bleed:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_apu_bleed == 0
				then                                          								-- PHASE WAS SUCCESSFUL
				simCMD_apu_bleed:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "APU BLEED OFF")
        end

    ----- AUTO-START STEP 24: TURN ON ENGINE 1 BLEED
    elseif autostart.step == 24 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "ENGINE 1 BLEED TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_bleed1_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_bleed1_toggle:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333DR_bleed1_pos >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				simCMD_bleed1_toggle:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "ENGINE 1 BLEED ON")
        end

    ----- AUTO-START STEP 25: TURN ON ENGINE 2 BLEED
    elseif autostart.step == 25 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "ENGINE 2 BLEED TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_bleed2_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_bleed2_toggle:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333DR_bleed2_pos >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				simCMD_bleed2_toggle:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "ENGINE 2 BLEED ON")
        end

    ----- AUTO-START STEP 26: TURN ON ENGINE 1 PACK
    elseif autostart.step == 26 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "ENGINE 1 PACK TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_pack1_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_pack_left_toggle:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333DR_pack1_pos >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				simCMD_pack_left_toggle:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "ENGINE 1 PACK ON")
        end

    ----- AUTO-START STEP 27: TURN ON ENGINE 2 PACK
    elseif autostart.step == 27 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "ENGINE 2 PACK TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_pack2_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	simCMD_pack_right_toggle:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333DR_pack2_pos >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				simCMD_pack_right_toggle:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "ENGINE 2 PACK ON")
        end

    ----- AUTO-START STEP 28: TURN ON HOT AIR 1
    elseif autostart.step == 28 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "HOT AIR 1 TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_hot_air1_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_hot_air1_toggle:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333DR_hot_air1_pos >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_hot_air1_toggle:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "HOT AIR 1 ON")
        end

    ----- AUTO-START STEP 29: TURN ON HOT AIR 2
    elseif autostart.step == 29 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "HOT AIR 2 TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_hot_air2_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_hot_air2_toggle:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333DR_hot_air2_pos >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_hot_air2_toggle:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "HOT AIR 2 ON")
        end


    ----- AUTO-START STEP 30: TURN ON FORWARD CARGO ISOL VALVES
    elseif autostart.step == 30 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "CARGO ISOL VALVES TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_cargo_fwd_isol_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_cargo_cond_fwd_isol_valve_tog:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333_cargo_cond_fwd_isol_valve_pos >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_cargo_cond_fwd_isol_valve_tog:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "CARGO ISOL VALVES ON")
        end


    ----- AUTO-START STEP 31: TURN ON BULK CARGO ISOL VALVES
    elseif autostart.step == 31 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "BULK ISOL VALVES TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_cargo_bulk_isol_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_cargo_cond_bulk_isol_valve_tog:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333_cargo_cond_bulk_isol_valve_pos >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_cargo_cond_bulk_isol_valve_tog:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "BULK ISOL VALVES ON")
        end

    ----- AUTO-START STEP 32: TURN ON BULK HOT AIR
    elseif autostart.step == 32 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "BULK HOT AIR TO ON..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_cargo_hot_air_on, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_cargo_cond_hot_air_tog:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif A333_cargo_cond_hot_air_pos >= 0.995
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_cargo_cond_hot_air_tog:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "BULK HOT AIR ON")
        end

    ----- AUTO-START STEP 33: TURN OFF APU
    elseif autostart.step == 33 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "APU MASTER TO OFF..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_apu_master_off, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
            	A333CMD_apu_master_toggle:stop()
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_apu_mode == 0
				then                                          								-- PHASE WAS SUCCESSFUL
				A333CMD_apu_master_toggle:stop()
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "APU SHUTTING DOWN")
        end

    ----- AUTO-START STEP 34: ENG MODE TO NORM
    elseif autostart.step == 34 then

        -- PHASE 1: SET THE SWITCH
        if autostart.phase[autostart.step] == 1 then
            A333_print_sequence_status(autostart.step, autostart.phase[autostart.step], "ENGINE MODE TO NORM..")  -- PRINT THE START PHASE MESSAGE
            run_after_time(A333_eng_mode_NORM, 0.5)
            autostart.phase[autostart.step] = 2                                             -- INCREMENT THE PHASE
        end

        -- PHASE 2: PRINT MONITOR STATUS AND START PHASE TIMER
        A333_autostart_phase_monitor(3.0)


        -- PHASE 3: MONITOR THE STATUS
        if autostart.phase[autostart.step] == 3 then
            if autostart.sequence_timeout == true then                                      -- PHASE FAILED
                A333_autostart_step_failed(autostart.step, autostart.phase[autostart.step])
            elseif simDR_eng_mode_sel == 0
				then                                          								-- PHASE WAS SUCCESSFUL
                if is_timer_scheduled(A333_autostart_phase_timeout) == true then
                    stop_timer(A333_autostart_phase_timeout)                                -- KILL THE TIMER
                end
                autostart.phase[autostart.step] = 4                                         -- INCREMENT THE PHASE
            end
        end

        -- PHASE 4: COMPLETE THE STEP
        if autostart.phase[autostart.step] == 4 then
            A333_autostart_step_completed(autostart.step, autostart.phase[autostart.step], "ENGINE MODE NORM")
        end



    ----- AUTO-START SEQUENCE COMPLETED
    elseif autostart.step == 35 then
        autostart.step = 888


    ----- AUTO-START STEP 700: ABORT
    elseif autostart.step == 700 then
        A333_autostart_seq_aborted()



    ----- AUTO-START STEP 888: SEQUENCE COMPLETED
    elseif autostart.step == 888 then
        A333_autostart_seq_completed()


    end -- AUTO-START STEPS

end -- AUTO-START SEQUENCE



function A333_ai_quick_start()

	-- AI
	A333_set_ai_all_modes()
	A333_set_ai_CD()
	A333_set_ai_ER()

    -- AUDIO
	A333CMD_ai_audio_quick_start:once()

	-- AUTOPILOT
	A333CMD_ai_autopilot_quick_start:once()

	-- CHRONO
	A333CMD_ai_chrono_quick_start:once()

	-- COMMS
	A333CMD_ai_comms_quick_start:once()

	-- FIRE
	A333CMD_ai_fire_quick_start:once()

	-- SWITCHES
	A333CMD_ai_switches_quick_start:once()

	-- SYSTEMS
	A333CMD_ai_systems_quick_start:once()

	-- TRANSPONDER
	A333CMD_ai_transponder_quick_start:once()


end

function A333_move_throttles()

A333_autoboard_step	= autoboard.step


	if autoboard.step == 3 or autoboard.step == 4 or autoboard.step == 5 or autostart.step == 3 or autostart.step == 4 or autostart.step == 5 then
		simDR_throttle_pos[0] = A333_set_animation_position(simDR_throttle_pos[0], throttle1_target, 0, 1, 8)
	end

	if autoboard.step == 5 or autoboard.step == 6 or autoboard.step == 7 or autostart.step == 5 or autostart.step == 6 or autostart.step == 7 then
		simDR_throttle_pos[1] = A333_set_animation_position(simDR_throttle_pos[1], throttle2_target, 0, 1, 8)
	end

end

----- SET STATE FOR ALL MODES -----------------------------------------------------------
function A333_set_ai_all_modes()

	A333_autoboard_init()
    simDR_autoboard_in_progress = 0
    A333_autostart_init()
    simDR_autostart_in_progress = 0

end





----- SET STATE TO COLD & DARK ----------------------------------------------------------
function A333_set_ai_CD()



end





----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
function A333_set_ai_ER()



end



----- FLIGHT START AI -------------------------------------------------------------------
function A333_flight_start_ai()

    -- ALL MODES ------------------------------------------------------------------------

    	A333_set_ai_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

    	A333_set_ai_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

    	A333_set_ai_ER()


    end

end


--*************************************************************************************--
--** 				               XLUA EVENT CALLBACKS       	        			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

    A333_flight_start_ai()

end

--function flight_crash() end

--function before_physics() end

function after_physics()

    A333_auto_board()
	A333_auto_start()
	A333_move_throttles()

end

--function after_replay() end



--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")



