jit.off()
--[[
*****************************************************************************************
* Program Script Name	:	A333.annunciators_3
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



--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_flight_time					= find_dataref("sim/time/total_flight_time_sec")

simDR_annun_brightness				= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_manual[15]")
simDR_annun_brightness2				= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_manual[16]")

simDR_fuel_left_wing				= find_dataref("sim/cockpit2/fuel/fuel_quantity[0]")
simDR_fuel_center_tank				= find_dataref("sim/cockpit2/fuel/fuel_quantity[1]")
simDR_fuel_right_wing				= find_dataref("sim/cockpit2/fuel/fuel_quantity[2]")

simDR_fuel_aux_tank_L				= find_dataref("sim/cockpit2/fuel/fuel_quantity[3]")
simDR_fuel_aux_tank_R				= find_dataref("sim/cockpit2/fuel/fuel_quantity[4]")
simDR_fuel_trim_tank				= find_dataref("sim/cockpit2/fuel/fuel_quantity[5]")

simDR_engine1_fire					= find_dataref("sim/cockpit2/annunciators/engine_fires[0]")
simDR_engine2_fire					= find_dataref("sim/cockpit2/annunciators/engine_fires[1]")
simDR_apu_fire						= find_dataref("sim/operation/failures/rel_apu_fire")

simDR_smoke_in_cockpit				= find_dataref("sim/operation/failures/rel_smoke_cpit")

simDR_engine1_fire_spill			= find_dataref("sim/cockpit2/switches/generic_lights_switch[16]")
simDR_engine2_fire_spill			= find_dataref("sim/cockpit2/switches/generic_lights_switch[17]")
simDR_apu_fire_spill				= find_dataref("sim/cockpit2/switches/generic_lights_switch[18]")

simDR_north_ref						= find_dataref("sim/cockpit2/EFIS/true_north") -- 0 = mag, 1 = tru

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

A333_ann_light_switch_pos			= find_dataref("laminar/a333/switches/ann_light_pos")

A333_left_pump1_pos					= find_dataref("laminar/A333/fuel/buttons/left1_pump_pos")
A333_left_pump2_pos					= find_dataref("laminar/A333/fuel/buttons/left2_pump_pos")
A333_left_standby_pump_pos			= find_dataref("laminar/A333/fuel/buttons/left_stby_pump_pos")

A333_right_pump1_pos				= find_dataref("laminar/A333/fuel/buttons/right1_pump_pos")
A333_right_pump2_pos				= find_dataref("laminar/A333/fuel/buttons/right2_pump_pos")
A333_right_standby_pump_pos			= find_dataref("laminar/A333/fuel/buttons/right_stby_pump_pos")

A333_center_left_pump_pos			= find_dataref("laminar/A333/fuel/buttons/center_left_pump_pos")
A333_center_right_pump_pos			= find_dataref("laminar/A333/fuel/buttons/center_right_pump_pos")

A333_fuel_wing_crossfeed_pos		= find_dataref("laminar/A333/fuel/buttons/wing_x_feed_pos")

A333_fuel_center_xfr_pos			= find_dataref("laminar/A333/fuel/buttons/center_xfr_pos")
A333_fuel_trim_xfr_pos				= find_dataref("laminar/A333/fuel/buttons/trim_xfr_pos")
A333_fuel_outer_tank_xfr_pos		= find_dataref("laminar/A333/fuel/buttons/outer_tank_xfr_pos")

A333_ECAM_fuel_center_xfer_any		= find_dataref("laminar/A333/ecam/fuel/status_center_xfer")

-- FIRE

A333_apu_fire_test					= find_dataref("laminar/A333/fire/apu_test_on")
A333_engine_fire_test				= find_dataref("laminar/A333/fire/engine_test_on")
A333_cargo_fire_test				= find_dataref("laminar/A333/fire/cargo_test_on")

A333_eng1_fire_handle_pos			= find_dataref("laminar/A333/fire/switches/eng1_handle")
A333_eng2_fire_handle_pos			= find_dataref("laminar/A333/fire/switches/eng2_handle")
A333_apu_fire_handle_pos			= find_dataref("laminar/A333/fire/switches/apu_handle")

A333_eng1_agent1_psi				= find_dataref("laminar/A333/fire/status/eng1_agent1_psi")
A333_eng1_agent2_psi				= find_dataref("laminar/A333/fire/status/eng1_agent2_psi")
A333_eng2_agent1_psi				= find_dataref("laminar/A333/fire/status/eng2_agent1_psi")
A333_eng2_agent2_psi				= find_dataref("laminar/A333/fire/status/eng2_agent2_psi")
A333_apu_agent_psi					= find_dataref("laminar/A333/fire/status/apu_agent_psi")

A333_cargo_fire_test_timer			= find_dataref("laminar/A333/fire/timer/cargo_test")
A333_cargo_fire_test_pos			= find_dataref("laminar/A333/fire/buttons/cargo_test_pos")

-- RADIOS

A333DR_rtp_L_offside_tuning_status  = find_dataref("laminar/A333/comm/rtp_L/offside_tuning_status")
A333DR_rtp_L_off_status             = find_dataref("laminar/A333/comm/rtp_L/off_status")
A333DR_rtp_L_vhf_1_status           = find_dataref("laminar/A333/comm/rtp_L/vhf_1_status")
A333DR_rtp_L_vhf_2_status           = find_dataref("laminar/A333/comm/rtp_L/vhf_2_status")
A333DR_rtp_L_vhf_3_status           = find_dataref("laminar/A333/comm/rtp_L/vhf_3_status")
A333DR_rtp_L_hf_1_status            = find_dataref("laminar/A333/comm/rtp_L/hf_1_status")
A333DR_rtp_L_am_status              = find_dataref("laminar/A333/comm/rtp_L/am_status")
A333DR_rtp_L_hf_2_status            = find_dataref("laminar/A333/comm/rtp_L/hf_2_status")

A333DR_rtp_R_offside_tuning_status  = find_dataref("laminar/A333/comm/rtp_R/offside_tuning_status")
A333DR_rtp_R_off_status             = find_dataref("laminar/A333/comm/rtp_R/off_status")
A333DR_rtp_R_vhf_1_status           = find_dataref("laminar/A333/comm/rtp_R/vhf_1_status")
A333DR_rtp_R_vhf_2_status           = find_dataref("laminar/A333/comm/rtp_R/vhf_2_status")
A333DR_rtp_R_vhf_3_status           = find_dataref("laminar/A333/comm/rtp_R/vhf_3_status")
A333DR_rtp_R_hf_1_status            = find_dataref("laminar/A333/comm/rtp_R/hf_1_status")
A333DR_rtp_R_am_status              = find_dataref("laminar/A333/comm/rtp_R/am_status")
A333DR_rtp_R_hf_2_status            = find_dataref("laminar/A333/comm/rtp_R/hf_2_status")

A333DR_rtp_C_offside_tuning_status  = find_dataref("laminar/A333/comm/rtp_C/offside_tuning_status")
A333DR_rtp_C_off_status             = find_dataref("laminar/A333/comm/rtp_C/off_status")
A333DR_rtp_C_vhf_1_status           = find_dataref("laminar/A333/comm/rtp_C/vhf_1_status")
A333DR_rtp_C_vhf_2_status           = find_dataref("laminar/A333/comm/rtp_C/vhf_2_status")
A333DR_rtp_C_vhf_3_status           = find_dataref("laminar/A333/comm/rtp_C/vhf_3_status")
A333DR_rtp_C_hf_1_status            = find_dataref("laminar/A333/comm/rtp_C/hf_1_status")
A333DR_rtp_C_am_status              = find_dataref("laminar/A333/comm/rtp_C/am_status")
A333DR_rtp_C_hf_2_status            = find_dataref("laminar/A333/comm/rtp_C/hf_2_status")

--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

A333_annun_fuel_ctr_tank_L_fault		= create_dataref("laminar/A333/annun/fuel/ctr_tank_L_fault","number")
A333_annun_fuel_ctr_tank_L_off			= create_dataref("laminar/A333/annun/fuel/ctr_tank_L_off","number")
A333_annun_fuel_ctr_tank_R_fault		= create_dataref("laminar/A333/annun/fuel/ctr_tank_R_fault","number")
A333_annun_fuel_ctr_tank_R_off			= create_dataref("laminar/A333/annun/fuel/ctr_tank_R_off","number")
A333_annun_fuel_ctr_tank_xfr_fault		= create_dataref("laminar/A333/annun/fuel/ctr_tank_xfr_fault","number")
A333_annun_fuel_ctr_tank_xfr_man		= create_dataref("laminar/A333/annun/fuel/ctr_tank_xfr_man","number")
A333_annun_fuel_L_stby_fault			= create_dataref("laminar/A333/annun/fuel/L_stby_fault","number")
A333_annun_fuel_L_stby_off				= create_dataref("laminar/A333/annun/fuel/L_stby_off","number")
A333_annun_fuel_L1_fault				= create_dataref("laminar/A333/annun/fuel/L1_fault","number")
A333_annun_fuel_L1_off					= create_dataref("laminar/A333/annun/fuel/L1_off","number")
A333_annun_fuel_L2_fault				= create_dataref("laminar/A333/annun/fuel/L2_fault","number")
A333_annun_fuel_L2_off					= create_dataref("laminar/A333/annun/fuel/L2_off","number")
A333_annun_fuel_outr_tk_xfr_fault		= create_dataref("laminar/A333/annun/fuel/outr_tk_xfr_fault","number")
A333_annun_fuel_outr_tk_xfr_on			= create_dataref("laminar/A333/annun/fuel/outr_tk_xfr_on","number")
A333_annun_fuel_R_stby_fault			= create_dataref("laminar/A333/annun/fuel/R_stby_fault","number")
A333_annun_fuel_R_stby_off				= create_dataref("laminar/A333/annun/fuel/R_stby_off","number")
A333_annun_fuel_R1_fault				= create_dataref("laminar/A333/annun/fuel/R1_fault","number")
A333_annun_fuel_R1_off					= create_dataref("laminar/A333/annun/fuel/R1_off","number")
A333_annun_fuel_R2_fault				= create_dataref("laminar/A333/annun/fuel/R2_fault","number")
A333_annun_fuel_R2_off					= create_dataref("laminar/A333/annun/fuel/R2_off","number")
A333_annun_fuel_t_tank_mode_fault		= create_dataref("laminar/A333/annun/fuel/t_tank_mode_fault","number")
A333_annun_fuel_t_tank_mode_fwd			= create_dataref("laminar/A333/annun/fuel/t_tank_mode_fwd","number")
A333_annun_fuel_wing_x_feed_on			= create_dataref("laminar/A333/annun/fuel/wing_x_feed_on","number")
A333_annun_fuel_wing_x_feed_open		= create_dataref("laminar/A333/annun/fuel/wing_x_feed_open","number")

A333_annun_fire_eng1_handle				= create_dataref("laminar/A333/annun/fire/eng1_handle", "number")
A333_annun_fire_eng2_handle				= create_dataref("laminar/A333/annun/fire/eng2_handle", "number")
A333_annun_fire_apu_handle				= create_dataref("laminar/A333/annun/fire/apu_handle", "number")

A333_annun_cargo_aft_agent_smoke		= create_dataref("laminar/A333/annun/cargo/aft_agent_smoke","number")
A333_annun_cargo_aft_agent_squib		= create_dataref("laminar/A333/annun/cargo/aft_agent_squib","number")
A333_annun_cargo_disch_btl1				= create_dataref("laminar/A333/annun/cargo/disch_btl1","number")
A333_annun_cargo_disch_btl2				= create_dataref("laminar/A333/annun/cargo/disch_btl2","number")
A333_annun_cargo_fwd_agent_smoke		= create_dataref("laminar/A333/annun/cargo/fwd_agent_smoke","number")
A333_annun_cargo_fwd_agent_squib		= create_dataref("laminar/A333/annun/cargo/fwd_agent_squib","number")
A333_annun_ventilation_avionics_smoke	= create_dataref("laminar/A333/annun/ventilation/avionics_smoke","number")

A333_annun_fire_apu_disch				= create_dataref("laminar/A333/annun/fire/apu_disch","number")
A333_annun_fire_apu_squib				= create_dataref("laminar/A333/annun/fire/apu_squib","number")
A333_annun_fire_eng1_agent1_disch		= create_dataref("laminar/A333/annun/fire/eng1_agent1_disch","number")
A333_annun_fire_eng1_agent1_squib		= create_dataref("laminar/A333/annun/fire/eng1_agent1_squib","number")
A333_annun_fire_eng1_agent2_disch		= create_dataref("laminar/A333/annun/fire/eng1_agent2_disch","number")
A333_annun_fire_eng1_agent2_squib		= create_dataref("laminar/A333/annun/fire/eng1_agent2_squib","number")
A333_annun_fire_eng2_agent1_disch		= create_dataref("laminar/A333/annun/fire/eng2_agent1_disch","number")
A333_annun_fire_eng2_agent1_squib		= create_dataref("laminar/A333/annun/fire/eng2_agent1_squib","number")
A333_annun_fire_eng2_agent2_disch		= create_dataref("laminar/A333/annun/fire/eng2_agent2_disch","number")
A333_annun_fire_eng2_agent2_squib		= create_dataref("laminar/A333/annun/fire/eng2_agent2_squib","number")

A333_annun_rtp_L_offside_tuning			= create_dataref("laminar/A333/annun/comm/rtp_L/offside_tuning_active","number")
A333_annun_rtp_L_vhf_1					= create_dataref("laminar/A333/annun/comm/rtp_L/vhf_1_active","number")
A333_annun_rtp_L_vhf_2					= create_dataref("laminar/A333/annun/comm/rtp_L/vhf_2_active","number")
A333_annun_rtp_L_vhf_3					= create_dataref("laminar/A333/annun/comm/rtp_L/vhf_3_active","number")
A333_annun_rtp_L_hf_1					= create_dataref("laminar/A333/annun/comm/rtp_L/hf_1_active","number")
A333_annun_rtp_L_am						= create_dataref("laminar/A333/annun/comm/rtp_L/am_active","number")
A333_annun_rtp_L_hf_2					= create_dataref("laminar/A333/annun/comm/rtp_L/hf_2_active","number")
A333_annun_rtp_L_no_op					= create_dataref("laminar/A333/annun/comm/rtp_L/no_op","number")

A333_annun_rtp_R_offside_tuning			= create_dataref("laminar/A333/annun/comm/rtp_R/offside_tuning_active","number")
A333_annun_rtp_R_vhf_1					= create_dataref("laminar/A333/annun/comm/rtp_R/vhf_1_active","number")
A333_annun_rtp_R_vhf_2					= create_dataref("laminar/A333/annun/comm/rtp_R/vhf_2_active","number")
A333_annun_rtp_R_vhf_3					= create_dataref("laminar/A333/annun/comm/rtp_R/vhf_3_active","number")
A333_annun_rtp_R_hf_1					= create_dataref("laminar/A333/annun/comm/rtp_R/hf_1_active","number")
A333_annun_rtp_R_am						= create_dataref("laminar/A333/annun/comm/rtp_R/am_active","number")
A333_annun_rtp_R_hf_2					= create_dataref("laminar/A333/annun/comm/rtp_R/hf_2_active","number")
A333_annun_rtp_R_no_op					= create_dataref("laminar/A333/annun/comm/rtp_R/no_op","number")

A333_annun_rtp_C_offside_tuning			= create_dataref("laminar/A333/annun/comm/rtp_C/offside_tuning_active","number")
A333_annun_rtp_C_vhf_1					= create_dataref("laminar/A333/annun/comm/rtp_C/vhf_1_active","number")
A333_annun_rtp_C_vhf_2					= create_dataref("laminar/A333/annun/comm/rtp_C/vhf_2_active","number")
A333_annun_rtp_C_vhf_3					= create_dataref("laminar/A333/annun/comm/rtp_C/vhf_3_active","number")
A333_annun_rtp_C_hf_1					= create_dataref("laminar/A333/annun/comm/rtp_C/hf_1_active","number")
A333_annun_rtp_C_am						= create_dataref("laminar/A333/annun/comm/rtp_C/am_active","number")
A333_annun_rtp_C_hf_2					= create_dataref("laminar/A333/annun/comm/rtp_C/hf_2_active","number")
A333_annun_rtp_C_no_op					= create_dataref("laminar/A333/annun/comm/rtp_C/no_op","number")

A333_fuel_crossfeed_valve_pos			= create_dataref("laminar/A333/fuel/crossfeed_valve_pos", "number")

--

A333_annun_true_north					= create_dataref("laminar/A333/annun/north_ref", "number")

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

local annun_fuel_ctr_tank_L_fault = 0
local annun_fuel_ctr_tank_L_off = 0
local annun_fuel_ctr_tank_R_fault = 0
local annun_fuel_ctr_tank_R_off = 0
local annun_fuel_ctr_tank_xfr_fault = 0
local annun_fuel_ctr_tank_xfr_man = 0

local annun_fuel_L_stby_fault = 0
local annun_fuel_L_stby_off = 0
local annun_fuel_L1_fault = 0
local annun_fuel_L1_off = 0
local annun_fuel_L2_fault = 0
local annun_fuel_L2_off = 0

local annun_fuel_outr_tk_xfr_fault = 0
local annun_fuel_outr_tk_xfr_on = 0

local annun_fuel_R_stby_fault = 0
local annun_fuel_R_stby_off = 0
local annun_fuel_R1_fault = 0
local annun_fuel_R1_off = 0
local annun_fuel_R2_fault = 0
local annun_fuel_R2_off = 0

local annun_fuel_t_tank_mode_fault = 0
local annun_fuel_t_tank_mode_fwd = 0
local annun_fuel_wing_x_feed_on = 0
local annun_fuel_wing_x_feed_open = 0

local annun_fuel_ctr_tank_L_fault_target = 0
local annun_fuel_ctr_tank_L_off_target = 0
local annun_fuel_ctr_tank_R_fault_target = 0
local annun_fuel_ctr_tank_R_off_target = 0
local annun_fuel_ctr_tank_xfr_fault_target = 0
local annun_fuel_ctr_tank_xfr_man_target = 0

local annun_fuel_L_stby_fault_target = 0
local annun_fuel_L_stby_off_target = 0
local annun_fuel_L1_fault_target = 0
local annun_fuel_L1_off_target = 0
local annun_fuel_L2_fault_target = 0
local annun_fuel_L2_off_target = 0

local annun_fuel_outr_tk_xfr_fault_target = 0
local annun_fuel_outr_tk_xfr_on_target = 0

local annun_fuel_R_stby_fault_target = 0
local annun_fuel_R_stby_off_target = 0
local annun_fuel_R1_fault_target = 0
local annun_fuel_R1_off_target = 0
local annun_fuel_R2_fault_target = 0
local annun_fuel_R2_off_target = 0

local annun_fuel_t_tank_mode_fault_target = 0
local annun_fuel_t_tank_mode_fwd_target = 0
local annun_fuel_wing_x_feed_on_target = 0
local annun_fuel_wing_x_feed_open_target = 0

local crossfeed_valve_open = 0
local crossfeed_valve_open_target = 0

local annun_fire_eng1_handle = 0
local annun_fire_eng2_handle = 0
local annun_fire_apu_handle = 0
local annun_fire_eng1_handle_target = 0
local annun_fire_eng2_handle_target = 0
local annun_fire_apu_handle_target = 0

local annun_cargo_aft_agent_smoke = 0
local annun_cargo_aft_agent_squib = 0
local annun_cargo_disch_btl1 = 0
local annun_cargo_disch_btl2 = 0
local annun_cargo_fwd_agent_smoke = 0
local annun_cargo_fwd_agent_squib = 0
local avionics_bay_smoke_annun = 0
local annun_cargo_aft_agent_smoke_target = 0
local annun_cargo_aft_agent_squib_target = 0
local annun_cargo_disch_btl1_target = 0
local annun_cargo_disch_btl2_target = 0
local annun_cargo_fwd_agent_smoke_target = 0
local annun_cargo_fwd_agent_squib_target = 0
local avionics_bay_smoke_annun_target = 0

local annun_fire_apu_disch = 0
local annun_fire_apu_squib = 0
local annun_fire_eng1_agent1_disch = 0
local annun_fire_eng1_agent1_squib = 0
local annun_fire_eng1_agent2_disch = 0
local annun_fire_eng1_agent2_squib = 0
local annun_fire_eng2_agent1_disch = 0
local annun_fire_eng2_agent1_squib = 0
local annun_fire_eng2_agent2_disch = 0
local annun_fire_eng2_agent2_squib = 0

local annun_fire_apu_disch_target = 0
local annun_fire_apu_squib_target = 0
local annun_fire_eng1_agent1_disch_target = 0
local annun_fire_eng1_agent1_squib_target = 0
local annun_fire_eng1_agent2_disch_target = 0
local annun_fire_eng1_agent2_squib_target = 0
local annun_fire_eng2_agent1_disch_target = 0
local annun_fire_eng2_agent1_squib_target = 0
local annun_fire_eng2_agent2_disch_target = 0
local annun_fire_eng2_agent2_squib_target = 0

local annun_rtp_L_offside_tuning = 0
local annun_rtp_L_vhf_1 = 0
local annun_rtp_L_vhf_2 = 0
local annun_rtp_L_vhf_3 = 0
local annun_rtp_L_hf_1 = 0
local annun_rtp_L_hf_2 = 0
local annun_rtp_L_am = 0
local annun_rtp_L_no_op = 0

local annun_rtp_L_offside_tuning_target = 0
local annun_rtp_L_vhf_1_target = 0
local annun_rtp_L_vhf_2_target = 0
local annun_rtp_L_vhf_3_target = 0
local annun_rtp_L_hf_1_target = 0
local annun_rtp_L_hf_2_target = 0
local annun_rtp_L_am_target = 0
local annun_rtp_L_no_op_target = 0

local annun_rtp_R_offside_tuning = 0
local annun_rtp_R_vhf_1 = 0
local annun_rtp_R_vhf_2 = 0
local annun_rtp_R_vhf_3 = 0
local annun_rtp_R_hf_1 = 0
local annun_rtp_R_hf_2 = 0
local annun_rtp_R_am = 0
local annun_rtp_R_no_op = 0

local annun_rtp_R_offside_tuning_target = 0
local annun_rtp_R_vhf_1_target = 0
local annun_rtp_R_vhf_2_target = 0
local annun_rtp_R_vhf_3_target = 0
local annun_rtp_R_hf_1_target = 0
local annun_rtp_R_hf_2_target = 0
local annun_rtp_R_am_target = 0
local annun_rtp_R_no_op_target = 0

local annun_rtp_C_offside_tuning = 0
local annun_rtp_C_vhf_1 = 0
local annun_rtp_C_vhf_2 = 0
local annun_rtp_C_vhf_3 = 0
local annun_rtp_C_hf_1 = 0
local annun_rtp_C_hf_2 = 0
local annun_rtp_C_am = 0
local annun_rtp_C_no_op = 0

local annun_rtp_C_offside_tuning_target = 0
local annun_rtp_C_vhf_1_target = 0
local annun_rtp_C_vhf_2_target = 0
local annun_rtp_C_vhf_3_target = 0
local annun_rtp_C_hf_1_target = 0
local annun_rtp_C_hf_2_target = 0
local annun_rtp_C_am_target = 0
local annun_rtp_C_no_op_target = 0

local annun_north_ref = 0
local annun_north_ref_target = 0

-- ANNUNCIATOR FUNCTIONS

function A333_annunciators_FUEL()

	if A333_ann_light_switch_pos <= 1 then

		if A333_center_left_pump_pos == 0 then
			annun_fuel_ctr_tank_L_off_target = 1
			annun_fuel_ctr_tank_L_fault_target = 0
		elseif A333_center_left_pump_pos >= 1 then
			annun_fuel_ctr_tank_L_off_target = 0
			if A333_ECAM_fuel_center_xfer_any == 1 then
				if simDR_fuel_center_tank < 250 then
					annun_fuel_ctr_tank_L_fault_target = 1
				elseif simDR_fuel_center_tank >= 250 then
					annun_fuel_ctr_tank_L_fault_target = 0
				end
			elseif A333_ECAM_fuel_center_xfer_any == 0 then
				annun_fuel_ctr_tank_L_fault_target = 0
			end
		end

		if A333_center_right_pump_pos == 0 then
			annun_fuel_ctr_tank_R_off_target = 1
			annun_fuel_ctr_tank_R_fault_target = 0
		elseif A333_center_right_pump_pos >= 1 then
			annun_fuel_ctr_tank_R_off_target = 0
			if A333_ECAM_fuel_center_xfer_any == 1 then
				if simDR_fuel_center_tank < 250 then
					annun_fuel_ctr_tank_R_fault_target = 1
				elseif simDR_fuel_center_tank >= 250 then
					annun_fuel_ctr_tank_R_fault_target = 0
				end
			elseif A333_ECAM_fuel_center_xfer_any == 0 then
				annun_fuel_ctr_tank_R_fault_target = 0
			end
		end

		if A333_left_pump1_pos == 0 then
			annun_fuel_L1_off_target = 1
			annun_fuel_L1_fault_target = 0
		elseif A333_left_pump1_pos >= 1 then
			annun_fuel_L1_off_target = 0
			if simDR_fuel_left_wing < 150 then
				annun_fuel_L1_fault_target = 1
			elseif simDR_fuel_left_wing >= 150 then
				annun_fuel_L1_fault_target = 0
			end
		end

		if A333_left_pump2_pos == 0 then
			annun_fuel_L2_off_target = 1
			annun_fuel_L2_fault_target = 0
		elseif A333_left_pump2_pos >= 1 then
			annun_fuel_L2_off_target = 0
			if simDR_fuel_left_wing < 140 then
				annun_fuel_L2_fault_target = 1
			elseif simDR_fuel_left_wing >= 140 then
				annun_fuel_L2_fault_target = 0
			end
		end

		if A333_left_standby_pump_pos == 0 then
			annun_fuel_L_stby_off_target = 1
			annun_fuel_L_stby_fault_target = 0
		elseif A333_left_standby_pump_pos >= 1 then
			annun_fuel_L_stby_off_target = 0
			if simDR_fuel_left_wing < 125 then
				annun_fuel_L_stby_fault_target = 1
			elseif simDR_fuel_left_wing >= 125 then
				annun_fuel_L_stby_fault_target = 0
			end
		end

		if A333_right_pump1_pos == 0 then
			annun_fuel_R1_off_target = 1
			annun_fuel_R1_fault_target = 0
		elseif A333_right_pump1_pos >= 1 then
			annun_fuel_R1_off_target = 0
			if simDR_fuel_right_wing < 150 then
				annun_fuel_R1_fault_target = 1
			elseif simDR_fuel_right_wing >= 150 then
				annun_fuel_R1_fault_target = 0
			end
		end

		if A333_right_pump2_pos == 0 then
			annun_fuel_R2_off_target = 1
			annun_fuel_R2_fault_target = 0
		elseif A333_right_pump2_pos >= 1 then
			annun_fuel_R2_off_target = 0
			if simDR_fuel_right_wing < 140 then
				annun_fuel_R2_fault_target = 1
			elseif simDR_fuel_right_wing >= 140 then
				annun_fuel_R2_fault_target = 0
			end
		end

		if A333_right_standby_pump_pos == 0 then
			annun_fuel_R_stby_off_target = 1
			annun_fuel_R_stby_fault_target = 0
		elseif A333_right_standby_pump_pos >= 1 then
			annun_fuel_R_stby_off_target = 0
			if simDR_fuel_right_wing < 125 then
				annun_fuel_R_stby_fault_target = 1
			elseif simDR_fuel_right_wing >= 125 then
				annun_fuel_R_stby_fault_target = 0
			end
		end

		if A333_fuel_center_xfr_pos == 0 then
			annun_fuel_ctr_tank_xfr_man_target = 0
			annun_fuel_ctr_tank_xfr_fault_target = 0
		elseif A333_fuel_center_xfr_pos == 1 then
			annun_fuel_ctr_tank_xfr_man_target = 1
			if simDR_fuel_center_tank < 150 then
				annun_fuel_ctr_tank_xfr_fault_target = 1
			elseif simDR_fuel_center_tank >= 150 then
				annun_fuel_ctr_tank_xfr_fault_target = 0
			end
		end

		if A333_fuel_trim_xfr_pos == 0 then
			annun_fuel_t_tank_mode_fwd_target = 0
			annun_fuel_t_tank_mode_fault_target = 0
		elseif A333_fuel_trim_xfr_pos == 1 then
			annun_fuel_t_tank_mode_fwd_target = 1
			if simDR_fuel_trim_tank < 100 then
				annun_fuel_t_tank_mode_fault_target = 1
			elseif simDR_fuel_trim_tank >= 100 then
				annun_fuel_t_tank_mode_fault_target = 0
			end
		end

		if A333_fuel_outer_tank_xfr_pos == 0 then
			annun_fuel_outr_tk_xfr_on_target = 0
			annun_fuel_outr_tk_xfr_fault_target = 0
		elseif A333_fuel_outer_tank_xfr_pos == 1 then
			annun_fuel_outr_tk_xfr_on_target = 1
			if simDR_fuel_aux_tank_L < 75 or simDR_fuel_aux_tank_R < 75 then
				annun_fuel_outr_tk_xfr_fault_target = 1
			elseif simDR_fuel_aux_tank_L >= 75 and simDR_fuel_aux_tank_R >= 75 then
				annun_fuel_outr_tk_xfr_fault_target = 0
			end
		end

		if A333_fuel_wing_crossfeed_pos >= 1 then
			annun_fuel_wing_x_feed_on_target = 1
			crossfeed_valve_open_target = 1
		elseif A333_fuel_wing_crossfeed_pos == 0 then
			annun_fuel_wing_x_feed_on_target = 0
			crossfeed_valve_open_target = 0
		end

		crossfeed_valve_open = A333_set_animation_position(crossfeed_valve_open, crossfeed_valve_open_target, 0, 1, 3) -- crossfeed valve open time

		if crossfeed_valve_open == 1 then
			annun_fuel_wing_x_feed_open_target = 1
		elseif crossfeed_valve_open ~= 1 then
			annun_fuel_wing_x_feed_open_target = 0
		end


	elseif A333_ann_light_switch_pos == 2 then

		annun_fuel_ctr_tank_L_off_target = 1
		annun_fuel_ctr_tank_R_off_target = 1
		annun_fuel_ctr_tank_L_fault_target = 1
		annun_fuel_ctr_tank_R_fault_target = 1

		annun_fuel_L1_off_target = 1
		annun_fuel_L2_off_target = 1
		annun_fuel_L_stby_off_target = 1
		annun_fuel_L1_fault_target = 1
		annun_fuel_L2_fault_target = 1
		annun_fuel_L_stby_fault_target = 1

		annun_fuel_R1_off_target = 1
		annun_fuel_R2_off_target = 1
		annun_fuel_R_stby_off_target = 1
		annun_fuel_R1_fault_target = 1
		annun_fuel_R2_fault_target = 1
		annun_fuel_R_stby_fault_target = 1

		annun_fuel_ctr_tank_xfr_man_target = 1
		annun_fuel_ctr_tank_xfr_fault_target = 1
		annun_fuel_t_tank_mode_fault_target = 1
		annun_fuel_t_tank_mode_fwd_target = 1
		annun_fuel_outr_tk_xfr_fault_target = 1
		annun_fuel_outr_tk_xfr_on_target = 1
		annun_fuel_wing_x_feed_on_target = 1
		annun_fuel_wing_x_feed_open_target = 1

	end

-- annunciator fade in --

	annun_fuel_ctr_tank_L_fault = A333_set_animation_position(annun_fuel_ctr_tank_L_fault, annun_fuel_ctr_tank_L_fault_target, 0, 1, 13)
	annun_fuel_ctr_tank_L_off = A333_set_animation_position(annun_fuel_ctr_tank_L_off, annun_fuel_ctr_tank_L_off_target, 0, 1, 13)
	annun_fuel_ctr_tank_R_fault = A333_set_animation_position(annun_fuel_ctr_tank_R_fault, annun_fuel_ctr_tank_R_fault_target, 0, 1, 13)
	annun_fuel_ctr_tank_R_off = A333_set_animation_position(annun_fuel_ctr_tank_R_off, annun_fuel_ctr_tank_R_off_target, 0, 1, 13)
	annun_fuel_ctr_tank_xfr_fault = A333_set_animation_position(annun_fuel_ctr_tank_xfr_fault, annun_fuel_ctr_tank_xfr_fault_target, 0, 1, 13)
	annun_fuel_ctr_tank_xfr_man = A333_set_animation_position(annun_fuel_ctr_tank_xfr_man, annun_fuel_ctr_tank_xfr_man_target, 0, 1, 13)

	annun_fuel_L_stby_fault = A333_set_animation_position(annun_fuel_L_stby_fault, annun_fuel_L_stby_fault_target, 0, 1, 13)
	annun_fuel_L_stby_off = A333_set_animation_position(annun_fuel_L_stby_off, annun_fuel_L_stby_off_target, 0, 1, 13)
	annun_fuel_L1_fault = A333_set_animation_position(annun_fuel_L1_fault, annun_fuel_L1_fault_target, 0, 1, 13)
	annun_fuel_L1_off = A333_set_animation_position(annun_fuel_L1_off, annun_fuel_L1_off_target, 0, 1, 13)
	annun_fuel_L2_fault = A333_set_animation_position(annun_fuel_L2_fault, annun_fuel_L2_fault_target, 0, 1, 13)
	annun_fuel_L2_off = A333_set_animation_position(annun_fuel_L2_off, annun_fuel_L2_off_target, 0, 1, 13)

	annun_fuel_outr_tk_xfr_fault = A333_set_animation_position(annun_fuel_outr_tk_xfr_fault, annun_fuel_outr_tk_xfr_fault_target, 0, 1, 13)
	annun_fuel_outr_tk_xfr_on = A333_set_animation_position(annun_fuel_outr_tk_xfr_on, annun_fuel_outr_tk_xfr_on_target, 0, 1, 13)

	annun_fuel_R_stby_fault = A333_set_animation_position(annun_fuel_R_stby_fault, annun_fuel_R_stby_fault_target, 0, 1, 13)
	annun_fuel_R_stby_off = A333_set_animation_position(annun_fuel_R_stby_off, annun_fuel_R_stby_off_target, 0, 1, 13)
	annun_fuel_R1_fault = A333_set_animation_position(annun_fuel_R1_fault, annun_fuel_R1_fault_target, 0, 1, 13)
	annun_fuel_R1_off = A333_set_animation_position(annun_fuel_R1_off, annun_fuel_R1_off_target, 0, 1, 13)
	annun_fuel_R2_fault = A333_set_animation_position(annun_fuel_R2_fault, annun_fuel_R2_fault_target, 0, 1, 13)
	annun_fuel_R2_off = A333_set_animation_position(annun_fuel_R2_off, annun_fuel_R2_off_target, 0, 1, 13)

	annun_fuel_t_tank_mode_fault = A333_set_animation_position(annun_fuel_t_tank_mode_fault, annun_fuel_t_tank_mode_fault_target, 0, 1, 13)
	annun_fuel_t_tank_mode_fwd = A333_set_animation_position(annun_fuel_t_tank_mode_fwd, annun_fuel_t_tank_mode_fwd_target, 0, 1, 13)
	annun_fuel_wing_x_feed_on = A333_set_animation_position(annun_fuel_wing_x_feed_on, annun_fuel_wing_x_feed_on_target, 0, 1, 13)
	annun_fuel_wing_x_feed_open = A333_set_animation_position(annun_fuel_wing_x_feed_open, annun_fuel_wing_x_feed_open_target, 0, 1, 13)

-- annunciator brightness --

	A333_annun_fuel_ctr_tank_L_fault = annun_fuel_ctr_tank_L_fault * simDR_annun_brightness
	A333_annun_fuel_ctr_tank_L_off = annun_fuel_ctr_tank_L_off * simDR_annun_brightness
	A333_annun_fuel_ctr_tank_R_fault = annun_fuel_ctr_tank_R_fault * simDR_annun_brightness
	A333_annun_fuel_ctr_tank_R_off = annun_fuel_ctr_tank_R_off * simDR_annun_brightness
	A333_annun_fuel_ctr_tank_xfr_fault = annun_fuel_ctr_tank_xfr_fault * simDR_annun_brightness
	A333_annun_fuel_ctr_tank_xfr_man = annun_fuel_ctr_tank_xfr_man * simDR_annun_brightness

	A333_annun_fuel_L_stby_fault = annun_fuel_L_stby_fault * simDR_annun_brightness
	A333_annun_fuel_L_stby_off = annun_fuel_L_stby_off * simDR_annun_brightness
	A333_annun_fuel_L1_fault = annun_fuel_L1_fault * simDR_annun_brightness
	A333_annun_fuel_L1_off = annun_fuel_L1_off * simDR_annun_brightness
	A333_annun_fuel_L2_fault = annun_fuel_L2_fault * simDR_annun_brightness
	A333_annun_fuel_L2_off = annun_fuel_L2_off * simDR_annun_brightness

	A333_annun_fuel_outr_tk_xfr_fault = annun_fuel_outr_tk_xfr_fault * simDR_annun_brightness
	A333_annun_fuel_outr_tk_xfr_on = annun_fuel_outr_tk_xfr_on * simDR_annun_brightness

	A333_annun_fuel_R_stby_fault = annun_fuel_R_stby_fault * simDR_annun_brightness
	A333_annun_fuel_R_stby_off = annun_fuel_R_stby_off * simDR_annun_brightness
	A333_annun_fuel_R1_fault = annun_fuel_R1_fault * simDR_annun_brightness
	A333_annun_fuel_R1_off = annun_fuel_R1_off * simDR_annun_brightness
	A333_annun_fuel_R2_fault = annun_fuel_R2_fault * simDR_annun_brightness
	A333_annun_fuel_R2_off = annun_fuel_R2_off * simDR_annun_brightness

	A333_annun_fuel_t_tank_mode_fault = annun_fuel_t_tank_mode_fault * simDR_annun_brightness
	A333_annun_fuel_t_tank_mode_fwd = annun_fuel_t_tank_mode_fwd * simDR_annun_brightness
	A333_annun_fuel_wing_x_feed_on = annun_fuel_wing_x_feed_on * simDR_annun_brightness
	A333_annun_fuel_wing_x_feed_open = annun_fuel_wing_x_feed_open * simDR_annun_brightness

	A333_fuel_crossfeed_valve_pos = crossfeed_valve_open

end

function A333_annunciators_FIRE()

	if A333_ann_light_switch_pos <= 1 then

		annun_fire_eng1_handle_target = simDR_engine1_fire
		annun_fire_eng2_handle_target = simDR_engine2_fire

		if A333_apu_fire_test == 0 then
			if simDR_apu_fire == 6 then
				annun_fire_apu_handle_target = 1
			elseif simDR_apu_fire ~= 6 then
				annun_fire_apu_handle_target = 0
			end
		elseif A333_apu_fire_test == 1 then
			annun_fire_apu_handle_target = 1
		end

		annun_cargo_disch_btl1_target = A333_cargo_fire_test_pos
		annun_cargo_disch_btl2_target = A333_cargo_fire_test_pos

		if A333_cargo_fire_test_timer == 0 then
			annun_cargo_aft_agent_squib_target = 0
			annun_cargo_fwd_agent_squib_target = 0
		elseif A333_cargo_fire_test_timer > 0 and A333_cargo_fire_test_timer < 6 then
			annun_cargo_fwd_agent_squib_target = 1
			annun_cargo_aft_agent_squib_target = 1
		elseif A333_cargo_fire_test_timer >= 6 then
			annun_cargo_fwd_agent_squib_target = 0
			annun_cargo_aft_agent_squib_target = 0
		end

		if A333_cargo_fire_test_timer <= 4 then
			annun_cargo_aft_agent_smoke_target = 0
			annun_cargo_fwd_agent_smoke_target = 0
		elseif A333_cargo_fire_test_timer > 4 then
			annun_cargo_aft_agent_smoke_target = 1
			annun_cargo_fwd_agent_smoke_target = 1
		end


		if simDR_smoke_in_cockpit == 6 then
			avionics_bay_smoke_annun_target = 1
		elseif simDR_smoke_in_cockpit <= 5 then
			if A333_cargo_fire_test_timer > 4.5 then
				avionics_bay_smoke_annun_target = 1
			else avionics_bay_smoke_annun_target = 0
			end
		end

		if A333_apu_fire_test == 1 then
			annun_fire_apu_disch_target = 1
			if A333_apu_agent_psi > 0 then
				annun_fire_apu_squib_target = 1
			elseif A333_apu_agent_psi == 0 then
				annun_fire_apu_squib_target = 0
			end
		elseif A333_apu_fire_test == 0 then
			if A333_apu_fire_handle_pos == 1 then
				if A333_apu_agent_psi > 0 then
					annun_fire_apu_squib_target = 1
				elseif A333_apu_agent_psi == 0 then
					annun_fire_apu_squib_target = 0
				end
				if A333_apu_agent_psi < 300 then
					annun_fire_apu_disch_target = 1
				elseif A333_apu_agent_psi == 300 then
					annun_fire_apu_disch_target = 0
				end
			elseif A333_apu_fire_handle_pos == 0 then
				annun_fire_apu_squib_target = 0
				if A333_apu_agent_psi < 300 then
					annun_fire_apu_disch_target = 1
				elseif A333_apu_agent_psi == 300 then
					annun_fire_apu_disch_target = 0
				end
			end
		end

		if A333_engine_fire_test == 1 then
			annun_fire_eng1_agent1_disch_target = 1
			annun_fire_eng1_agent2_disch_target = 1
			if A333_eng1_agent1_psi > 0 then
				annun_fire_eng1_agent1_squib_target = 1
			elseif A333_eng1_agent1_psi == 0 then
				annun_fire_eng1_agent1_squib_target = 0
			end
			if A333_eng1_agent2_psi > 0 then
				annun_fire_eng1_agent2_squib_target = 1
			elseif A333_eng1_agent2_psi == 0 then
				annun_fire_eng1_agent2_squib_target = 0
			end
		elseif A333_engine_fire_test == 0 then
			if A333_eng1_fire_handle_pos == 1 then
				if A333_eng1_agent1_psi > 0 then
					annun_fire_eng1_agent1_squib_target = 1
				elseif A333_eng1_agent1_psi == 0 then
					annun_fire_eng1_agent1_squib_target = 0
				end
				if A333_eng1_agent2_psi > 0 then
					annun_fire_eng1_agent2_squib_target = 1
				elseif A333_eng1_agent2_psi == 0 then
					annun_fire_eng1_agent2_squib_target = 0
				end
				if A333_eng1_agent1_psi < 300 then
					annun_fire_eng1_agent1_disch_target = 1
				elseif A333_eng1_agent1_psi == 300 then
					annun_fire_eng1_agent1_disch_target = 0
				end
				if A333_eng1_agent2_psi < 300 then
					annun_fire_eng1_agent2_disch_target = 1
				elseif A333_eng1_agent2_psi == 300 then
					annun_fire_eng1_agent2_disch_target = 0
				end
			elseif A333_eng1_fire_handle_pos == 0 then
				annun_fire_eng1_agent1_squib_target = 0
				annun_fire_eng1_agent2_squib_target = 0
				if A333_eng1_agent1_psi < 300 then
					annun_fire_eng1_agent1_disch_target = 1
				elseif A333_eng1_agent1_psi == 300 then
					annun_fire_eng1_agent1_disch_target = 0
				end
				if A333_eng1_agent2_psi < 300 then
					annun_fire_eng1_agent2_disch_target = 1
				elseif A333_eng1_agent2_psi == 300 then
					annun_fire_eng1_agent2_disch_target = 0
				end
			end
		end

		if A333_engine_fire_test == 1 then
			annun_fire_eng2_agent1_disch_target = 1
			annun_fire_eng2_agent2_disch_target = 1
			if A333_eng2_agent1_psi > 0 then
				annun_fire_eng2_agent1_squib_target = 1
			elseif A333_eng2_agent1_psi == 0 then
				annun_fire_eng2_agent1_squib_target = 0
			end
			if A333_eng2_agent2_psi > 0 then
				annun_fire_eng2_agent2_squib_target = 1
			elseif A333_eng2_agent2_psi == 0 then
				annun_fire_eng2_agent2_squib_target = 0
			end
		elseif A333_engine_fire_test == 0 then
			if A333_eng2_fire_handle_pos == 1 then
				if A333_eng2_agent1_psi > 0 then
					annun_fire_eng2_agent1_squib_target = 1
				elseif A333_eng2_agent1_psi == 0 then
					annun_fire_eng2_agent1_squib_target = 0
				end
				if A333_eng2_agent2_psi > 0 then
					annun_fire_eng2_agent2_squib_target = 1
				elseif A333_eng2_agent2_psi == 0 then
					annun_fire_eng2_agent2_squib_target = 0
				end
				if A333_eng2_agent1_psi < 300 then
					annun_fire_eng2_agent1_disch_target = 1
				elseif A333_eng2_agent1_psi == 300 then
					annun_fire_eng2_agent1_disch_target = 0
				end
				if A333_eng2_agent2_psi < 300 then
					annun_fire_eng2_agent2_disch_target = 1
				elseif A333_eng2_agent2_psi == 300 then
					annun_fire_eng2_agent2_disch_target = 0
				end
			elseif A333_eng2_fire_handle_pos == 0 then
				annun_fire_eng2_agent1_squib_target = 0
				annun_fire_eng2_agent2_squib_target = 0
				if A333_eng2_agent1_psi < 300 then
					annun_fire_eng2_agent1_disch_target = 1
				elseif A333_eng2_agent1_psi == 300 then
					annun_fire_eng2_agent1_disch_target = 0
				end
				if A333_eng2_agent2_psi < 300 then
					annun_fire_eng2_agent2_disch_target = 1
				elseif A333_eng2_agent2_psi == 300 then
					annun_fire_eng2_agent2_disch_target = 0
				end
			end
		end

	elseif A333_ann_light_switch_pos == 2 then


		annun_fire_eng1_handle_target = 1
		annun_fire_eng2_handle_target = 1
		annun_fire_apu_handle_target = 1

		annun_cargo_aft_agent_smoke_target = 1
		annun_cargo_aft_agent_squib_target = 1
		annun_cargo_disch_btl1_target = 1
		annun_cargo_disch_btl2_target = 1
		annun_cargo_fwd_agent_smoke_target = 1
		annun_cargo_fwd_agent_squib_target = 1
		avionics_bay_smoke_annun_target = 1

		annun_fire_apu_disch_target = 1
		annun_fire_apu_squib_target = 1
		annun_fire_eng1_agent1_disch_target = 1
		annun_fire_eng1_agent1_squib_target = 1
		annun_fire_eng1_agent2_disch_target = 1
		annun_fire_eng1_agent2_squib_target = 1
		annun_fire_eng2_agent1_disch_target = 1
		annun_fire_eng2_agent1_squib_target = 1
		annun_fire_eng2_agent2_disch_target = 1
		annun_fire_eng2_agent2_squib_target = 1

	end

-- annunciator fade in --

	annun_fire_eng1_handle = A333_set_animation_position(annun_fire_eng1_handle, annun_fire_eng1_handle_target, 0, 1, 13)
	annun_fire_eng2_handle = A333_set_animation_position(annun_fire_eng2_handle, annun_fire_eng2_handle_target, 0, 1, 13)
	annun_fire_apu_handle = A333_set_animation_position(annun_fire_apu_handle, annun_fire_apu_handle_target, 0, 1, 13)

	annun_cargo_aft_agent_smoke = A333_set_animation_position(annun_cargo_aft_agent_smoke, annun_cargo_aft_agent_smoke_target, 0, 1, 13)
	annun_cargo_aft_agent_squib = A333_set_animation_position(annun_cargo_aft_agent_squib, annun_cargo_aft_agent_squib_target, 0, 1, 13)
	annun_cargo_disch_btl1 = A333_set_animation_position(annun_cargo_disch_btl1, annun_cargo_disch_btl1_target, 0, 1, 13)
	annun_cargo_disch_btl2 = A333_set_animation_position(annun_cargo_disch_btl2, annun_cargo_disch_btl2_target, 0, 1, 13)
	annun_cargo_fwd_agent_smoke = A333_set_animation_position(annun_cargo_fwd_agent_smoke, annun_cargo_fwd_agent_smoke_target, 0, 1, 13)
	annun_cargo_fwd_agent_squib = A333_set_animation_position(annun_cargo_fwd_agent_squib, annun_cargo_fwd_agent_squib_target, 0, 1, 13)
	avionics_bay_smoke_annun = A333_set_animation_position(avionics_bay_smoke_annun, avionics_bay_smoke_annun_target, 0, 1, 13)

	annun_fire_apu_disch = A333_set_animation_position(annun_fire_apu_disch, annun_fire_apu_disch_target, 0, 1, 13)
	annun_fire_apu_squib = A333_set_animation_position(annun_fire_apu_squib, annun_fire_apu_squib_target, 0, 1, 13)
	annun_fire_eng1_agent1_disch = A333_set_animation_position(annun_fire_eng1_agent1_disch, annun_fire_eng1_agent1_disch_target, 0, 1, 13)
	annun_fire_eng1_agent1_squib = A333_set_animation_position(annun_fire_eng1_agent1_squib, annun_fire_eng1_agent1_squib_target, 0, 1, 13)
	annun_fire_eng1_agent2_disch = A333_set_animation_position(annun_fire_eng1_agent2_disch, annun_fire_eng1_agent2_disch_target, 0, 1, 13)
	annun_fire_eng1_agent2_squib = A333_set_animation_position(annun_fire_eng1_agent2_squib, annun_fire_eng1_agent2_squib_target, 0, 1, 13)
	annun_fire_eng2_agent1_disch = A333_set_animation_position(annun_fire_eng2_agent1_disch, annun_fire_eng2_agent1_disch_target, 0, 1, 13)
	annun_fire_eng2_agent1_squib = A333_set_animation_position(annun_fire_eng2_agent1_squib, annun_fire_eng2_agent1_squib_target, 0, 1, 13)
	annun_fire_eng2_agent2_disch = A333_set_animation_position(annun_fire_eng2_agent2_disch, annun_fire_eng2_agent2_disch_target, 0, 1, 13)
	annun_fire_eng2_agent2_squib = A333_set_animation_position(annun_fire_eng2_agent2_squib, annun_fire_eng2_agent2_squib_target, 0, 1, 13)

-- annunciator brightness --

	A333_annun_fire_eng1_handle = annun_fire_eng1_handle * simDR_annun_brightness2
	A333_annun_fire_eng2_handle = annun_fire_eng2_handle * simDR_annun_brightness2
	A333_annun_fire_apu_handle = annun_fire_apu_handle * simDR_annun_brightness2

	simDR_engine1_fire_spill = A333_annun_fire_eng1_handle
	simDR_engine2_fire_spill = A333_annun_fire_eng2_handle
	simDR_apu_fire_spill = A333_annun_fire_apu_handle

	A333_annun_cargo_aft_agent_smoke = annun_cargo_aft_agent_smoke * simDR_annun_brightness2
	A333_annun_cargo_aft_agent_squib = annun_cargo_aft_agent_squib * simDR_annun_brightness
	A333_annun_cargo_disch_btl1 = annun_cargo_disch_btl1 * simDR_annun_brightness
	A333_annun_cargo_disch_btl2 = annun_cargo_disch_btl2 * simDR_annun_brightness
	A333_annun_cargo_fwd_agent_smoke = annun_cargo_fwd_agent_smoke * simDR_annun_brightness2
	A333_annun_cargo_fwd_agent_squib = annun_cargo_fwd_agent_squib * simDR_annun_brightness
	A333_annun_ventilation_avionics_smoke = avionics_bay_smoke_annun * simDR_annun_brightness2

	A333_annun_fire_apu_disch = annun_fire_apu_disch * simDR_annun_brightness
	A333_annun_fire_apu_squib = annun_fire_apu_squib * simDR_annun_brightness
	A333_annun_fire_eng1_agent1_disch = annun_fire_eng1_agent1_disch * simDR_annun_brightness
	A333_annun_fire_eng1_agent1_squib = annun_fire_eng1_agent1_squib * simDR_annun_brightness
	A333_annun_fire_eng1_agent2_disch = annun_fire_eng1_agent2_disch * simDR_annun_brightness
	A333_annun_fire_eng1_agent2_squib = annun_fire_eng1_agent2_squib * simDR_annun_brightness
	A333_annun_fire_eng2_agent1_disch = annun_fire_eng2_agent1_disch * simDR_annun_brightness
	A333_annun_fire_eng2_agent1_squib = annun_fire_eng2_agent1_squib * simDR_annun_brightness
	A333_annun_fire_eng2_agent2_disch = annun_fire_eng2_agent2_disch * simDR_annun_brightness
	A333_annun_fire_eng2_agent2_squib = annun_fire_eng2_agent2_squib * simDR_annun_brightness

end


function A333_annunciators_extras()

	if A333_ann_light_switch_pos <= 1 then
	
		annun_north_ref_target = simDR_north_ref
		
	elseif A333_ann_light_switch_pos == 2 then
	
		annun_north_ref_target = 1
	
	end
	
-- annunciator fade in --

	annun_north_ref = A333_set_animation_position(annun_north_ref, annun_north_ref_target, 0, 1, 13)	

-- annunciator brightness --

	A333_annun_true_north = annun_north_ref * simDR_annun_brightness
	
end


function A333_annunciators_RADIOS()

	if A333_ann_light_switch_pos <= 1 then

		annun_rtp_L_no_op_target = 0
		annun_rtp_R_no_op_target = 0
		annun_rtp_C_no_op_target = 0

		if A333DR_rtp_L_off_status == 1 then
			annun_rtp_L_offside_tuning_target = 0
			annun_rtp_L_vhf_1_target = 0
			annun_rtp_L_vhf_2_target = 0
			annun_rtp_L_vhf_3_target = 0
			annun_rtp_L_hf_1_target = 0
			annun_rtp_L_hf_2_target = 0
			annun_rtp_L_am_target = 0
		elseif A333DR_rtp_L_off_status == 0 then
			annun_rtp_L_offside_tuning_target = A333DR_rtp_L_offside_tuning_status
			annun_rtp_L_vhf_1_target = A333DR_rtp_L_vhf_1_status
			annun_rtp_L_vhf_2_target = A333DR_rtp_L_vhf_2_status
			annun_rtp_L_vhf_3_target = A333DR_rtp_L_vhf_3_status
			annun_rtp_L_hf_1_target = A333DR_rtp_L_hf_1_status
			annun_rtp_L_hf_2_target = A333DR_rtp_L_hf_2_status
			annun_rtp_L_am_target = A333DR_rtp_L_am_status
		end

		if A333DR_rtp_R_off_status == 1 then
			annun_rtp_R_offside_tuning_target = 0
			annun_rtp_R_vhf_1_target = 0
			annun_rtp_R_vhf_2_target = 0
			annun_rtp_R_vhf_3_target = 0
			annun_rtp_R_hf_1_target = 0
			annun_rtp_R_hf_2_target = 0
			annun_rtp_R_am_target = 0
		elseif A333DR_rtp_R_off_status == 0 then
			annun_rtp_R_offside_tuning_target = A333DR_rtp_R_offside_tuning_status
			annun_rtp_R_vhf_1_target = A333DR_rtp_R_vhf_1_status
			annun_rtp_R_vhf_2_target = A333DR_rtp_R_vhf_2_status
			annun_rtp_R_vhf_3_target = A333DR_rtp_R_vhf_3_status
			annun_rtp_R_hf_1_target = A333DR_rtp_R_hf_1_status
			annun_rtp_R_hf_2_target = A333DR_rtp_R_hf_2_status
			annun_rtp_R_am_target = A333DR_rtp_R_am_status
		end

		if A333DR_rtp_C_off_status == 1 then
			annun_rtp_C_offside_tuning_target = 0
			annun_rtp_C_vhf_1_target = 0
			annun_rtp_C_vhf_2_target = 0
			annun_rtp_C_vhf_3_target = 0
			annun_rtp_C_hf_1_target = 0
			annun_rtp_C_hf_2_target = 0
			annun_rtp_C_am_target = 0
		elseif A333DR_rtp_C_off_status == 0 then
			annun_rtp_C_offside_tuning_target = A333DR_rtp_C_offside_tuning_status
			annun_rtp_C_vhf_1_target = A333DR_rtp_C_vhf_1_status
			annun_rtp_C_vhf_2_target = A333DR_rtp_C_vhf_2_status
			annun_rtp_C_vhf_3_target = A333DR_rtp_C_vhf_3_status
			annun_rtp_C_hf_1_target = A333DR_rtp_C_hf_1_status
			annun_rtp_C_hf_2_target = A333DR_rtp_C_hf_2_status
			annun_rtp_C_am_target = A333DR_rtp_C_am_status
		end

	elseif A333_ann_light_switch_pos == 2 then

		if A333DR_rtp_L_off_status == 1 then
			annun_rtp_L_offside_tuning_target = 0
			annun_rtp_L_vhf_1_target = 0
			annun_rtp_L_vhf_2_target = 0
			annun_rtp_L_vhf_3_target = 0
			annun_rtp_L_hf_1_target = 0
			annun_rtp_L_hf_2_target = 0
			annun_rtp_L_am_target = 0
			annun_rtp_L_no_op_target = 0
		elseif A333DR_rtp_L_off_status == 0 then
			annun_rtp_L_offside_tuning_target = 1
			annun_rtp_L_vhf_1_target = 1
			annun_rtp_L_vhf_2_target = 1
			annun_rtp_L_vhf_3_target = 1
			annun_rtp_L_hf_1_target = 1
			annun_rtp_L_hf_2_target = 1
			annun_rtp_L_am_target = 1
			annun_rtp_L_no_op_target = 1
		end

		if A333DR_rtp_R_off_status == 1 then
			annun_rtp_R_offside_tuning_target = 0
			annun_rtp_R_vhf_1_target = 0
			annun_rtp_R_vhf_2_target = 0
			annun_rtp_R_vhf_3_target = 0
			annun_rtp_R_hf_1_target = 0
			annun_rtp_R_hf_2_target = 0
			annun_rtp_R_am_target = 0
			annun_rtp_R_no_op_target = 0
		elseif A333DR_rtp_R_off_status == 0 then
			annun_rtp_R_offside_tuning_target = 1
			annun_rtp_R_vhf_1_target = 1
			annun_rtp_R_vhf_2_target = 1
			annun_rtp_R_vhf_3_target = 1
			annun_rtp_R_hf_1_target = 1
			annun_rtp_R_hf_2_target = 1
			annun_rtp_R_am_target = 1
			annun_rtp_R_no_op_target = 1
		end

		if A333DR_rtp_C_off_status == 1 then
			annun_rtp_C_offside_tuning_target = 0
			annun_rtp_C_vhf_1_target = 0
			annun_rtp_C_vhf_2_target = 0
			annun_rtp_C_vhf_3_target = 0
			annun_rtp_C_hf_1_target = 0
			annun_rtp_C_hf_2_target = 0
			annun_rtp_C_am_target = 0
			annun_rtp_C_no_op_target = 0
		elseif A333DR_rtp_C_off_status == 0 then
			annun_rtp_C_offside_tuning_target = 1
			annun_rtp_C_vhf_1_target = 1
			annun_rtp_C_vhf_2_target = 1
			annun_rtp_C_vhf_3_target = 1
			annun_rtp_C_hf_1_target = 1
			annun_rtp_C_hf_2_target = 1
			annun_rtp_C_am_target = 1
			annun_rtp_C_no_op_target = 1
		end

	end

-- annunciator fade in --

	annun_rtp_L_offside_tuning = A333_set_animation_position(annun_rtp_L_offside_tuning, annun_rtp_L_offside_tuning_target, 0, 1, 20)
	annun_rtp_L_vhf_1 = A333_set_animation_position(annun_rtp_L_vhf_1, annun_rtp_L_vhf_1_target, 0, 1, 20)
	annun_rtp_L_vhf_2 = A333_set_animation_position(annun_rtp_L_vhf_2, annun_rtp_L_vhf_2_target, 0, 1, 20)
	annun_rtp_L_vhf_3 = A333_set_animation_position(annun_rtp_L_vhf_3, annun_rtp_L_vhf_3_target, 0, 1, 20)
	annun_rtp_L_hf_1 = A333_set_animation_position(annun_rtp_L_hf_1, annun_rtp_L_hf_1_target, 0, 1, 20)
	annun_rtp_L_hf_2 = A333_set_animation_position(annun_rtp_L_hf_2, annun_rtp_L_hf_2_target, 0, 1, 20)
	annun_rtp_L_am = A333_set_animation_position(annun_rtp_L_am, annun_rtp_L_am_target, 0, 1, 20)
	annun_rtp_L_no_op = A333_set_animation_position(annun_rtp_L_no_op, annun_rtp_L_no_op_target, 0, 1, 20)

	annun_rtp_R_offside_tuning = A333_set_animation_position(annun_rtp_R_offside_tuning, annun_rtp_R_offside_tuning_target, 0, 1, 20)
	annun_rtp_R_vhf_1 = A333_set_animation_position(annun_rtp_R_vhf_1, annun_rtp_R_vhf_1_target, 0, 1, 20)
	annun_rtp_R_vhf_2 = A333_set_animation_position(annun_rtp_R_vhf_2, annun_rtp_R_vhf_2_target, 0, 1, 20)
	annun_rtp_R_vhf_3 = A333_set_animation_position(annun_rtp_R_vhf_3, annun_rtp_R_vhf_3_target, 0, 1, 20)
	annun_rtp_R_hf_1 = A333_set_animation_position(annun_rtp_R_hf_1, annun_rtp_R_hf_1_target, 0, 1, 20)
	annun_rtp_R_hf_2 = A333_set_animation_position(annun_rtp_R_hf_2, annun_rtp_R_hf_2_target, 0, 1, 20)
	annun_rtp_R_am = A333_set_animation_position(annun_rtp_R_am, annun_rtp_R_am_target, 0, 1, 20)
	annun_rtp_R_no_op = A333_set_animation_position(annun_rtp_R_no_op, annun_rtp_R_no_op_target, 0, 1, 20)

	annun_rtp_C_offside_tuning = A333_set_animation_position(annun_rtp_C_offside_tuning, annun_rtp_C_offside_tuning_target, 0, 1, 20)
	annun_rtp_C_vhf_1 = A333_set_animation_position(annun_rtp_C_vhf_1, annun_rtp_C_vhf_1_target, 0, 1, 20)
	annun_rtp_C_vhf_2 = A333_set_animation_position(annun_rtp_C_vhf_2, annun_rtp_C_vhf_2_target, 0, 1, 20)
	annun_rtp_C_vhf_3 = A333_set_animation_position(annun_rtp_C_vhf_3, annun_rtp_C_vhf_3_target, 0, 1, 20)
	annun_rtp_C_hf_1 = A333_set_animation_position(annun_rtp_C_hf_1, annun_rtp_C_hf_1_target, 0, 1, 20)
	annun_rtp_C_hf_2 = A333_set_animation_position(annun_rtp_C_hf_2, annun_rtp_C_hf_2_target, 0, 1, 20)
	annun_rtp_C_am = A333_set_animation_position(annun_rtp_C_am, annun_rtp_C_am_target, 0, 1, 20)
	annun_rtp_C_no_op = A333_set_animation_position(annun_rtp_C_no_op, annun_rtp_C_no_op_target, 0, 1, 20)

-- annunciator brightness --

	A333_annun_rtp_L_offside_tuning = annun_rtp_L_offside_tuning * simDR_annun_brightness2
	A333_annun_rtp_L_vhf_1 = annun_rtp_L_vhf_1 * simDR_annun_brightness2
	A333_annun_rtp_L_vhf_2 = annun_rtp_L_vhf_2 * simDR_annun_brightness2
	A333_annun_rtp_L_vhf_3 = annun_rtp_L_vhf_3 * simDR_annun_brightness2
	A333_annun_rtp_L_hf_1 = annun_rtp_L_hf_1 * simDR_annun_brightness2
	A333_annun_rtp_L_hf_2 = annun_rtp_L_hf_2 * simDR_annun_brightness2
	A333_annun_rtp_L_am = annun_rtp_L_am * simDR_annun_brightness2
	A333_annun_rtp_L_no_op = annun_rtp_L_no_op * simDR_annun_brightness2


	A333_annun_rtp_R_offside_tuning = annun_rtp_R_offside_tuning * simDR_annun_brightness2
	A333_annun_rtp_R_vhf_1 = annun_rtp_R_vhf_1 * simDR_annun_brightness2
	A333_annun_rtp_R_vhf_2 = annun_rtp_R_vhf_2 * simDR_annun_brightness2
	A333_annun_rtp_R_vhf_3 = annun_rtp_R_vhf_3 * simDR_annun_brightness2
	A333_annun_rtp_R_hf_1 = annun_rtp_R_hf_1 * simDR_annun_brightness2
	A333_annun_rtp_R_hf_2 = annun_rtp_R_hf_2 * simDR_annun_brightness2
	A333_annun_rtp_R_am = annun_rtp_R_am * simDR_annun_brightness2
	A333_annun_rtp_R_no_op = annun_rtp_R_no_op * simDR_annun_brightness2

	A333_annun_rtp_C_offside_tuning = annun_rtp_C_offside_tuning * simDR_annun_brightness2
	A333_annun_rtp_C_vhf_1 = annun_rtp_C_vhf_1 * simDR_annun_brightness2
	A333_annun_rtp_C_vhf_2 = annun_rtp_C_vhf_2 * simDR_annun_brightness2
	A333_annun_rtp_C_vhf_3 = annun_rtp_C_vhf_3 * simDR_annun_brightness2
	A333_annun_rtp_C_hf_1 = annun_rtp_C_hf_1 * simDR_annun_brightness2
	A333_annun_rtp_C_hf_2 = annun_rtp_C_hf_2 * simDR_annun_brightness2
	A333_annun_rtp_C_am = annun_rtp_C_am * simDR_annun_brightness2
	A333_annun_rtp_C_no_op = annun_rtp_C_no_op * simDR_annun_brightness2

end

--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

function A333_ALL_annunciators_3()

	A333_annunciators_FUEL()
	A333_annunciators_FIRE()
	A333_annunciators_RADIOS()
	A333_annunciators_extras()
	
end

--function aircraft_load() end

--function aircraft_unload() end

--function flight_start() end

--function flight_crash() end

--function before_physics()

function after_physics()

	A333_ALL_annunciators_3()

end

function after_replay()

	 A333_ALL_annunciators_3()

end
