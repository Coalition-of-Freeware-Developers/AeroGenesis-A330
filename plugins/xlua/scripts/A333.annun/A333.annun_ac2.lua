--[[
*****************************************************************************************
* Program Script Name	:	A333.annun_ac2.lua
* Author Name			:	Jim Gregory
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2025-08-29	0.01				Start of Dev
*
*
*
*
*****************************************************************************************
*       						   COPYRIGHT © 2025
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


--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local lcl_SIM_PERIOD = 0

local m = math

local _, frac = m.modf(os.clock())
local seed = m.random(1, frac*1000.0)
m.randomseed(seed)

local toilet = {
    time_between_occupied = m.random(4, 18),
    time_occupied = m.random(3),
    occupied_timer = 0,
    time_between_timer = 0,
    occupied_running = 0
}

local cockpit_door_fault_blink = 0


local annun_cockpit_door_open = 0
local annun_cockpit_door_fault = 0
local annun_prim2_off = 0
local annun_prim3_off = 0
local annun_sec2_off = 0
local annun_adirs_on_bat = 0
local annun_landing_gear_brake_fan_hot = 0
local annun_landing_gear_brake_fan_on = 0
local annun_ecp_system_page_pushbutton = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
local annun_ecp_clr_pushbutton = 0
local annun_ecp_sts_pushbutton = 0
local annun_master_caution = 0
local annun_master_warning = 0
local annun_flt_rcdr_gnd_ctl_on = 0
local annun_hyd_elec_yellow_pump_fault = 0
local annun_hyd_elec_yellow_pump_off = 0
local annun_hyd_elec_yellow_pump_on = 0
local annun_hyd_eng2_yellow_pump_fault = 0
local annun_hyd_eng2_yellow_pump_off = 0
local annun_elec_ext_a_on = 0
local annun_elec_ext_b_auto = 0
local annun_elec_ac_ess_feed_altn = 0
local annun_elec_ac_ess_feed_fault = 0
local annun_auto_land = 0
local annun_eng2_bleed_fault = 0
local annun_eng2_bleed_off = 0
local annun_pack2_fault = 0
local annun_pack2_off = 0
local annun_apu_bleed_on = 0
local annun_apu_bleed_fault = 0
local annun_ram_air_on = 0
local annun_pack1_fault = 0
local annun_pack1_off = 0
local annun_misc_toilet_occpd = 0
local annun_fuel_pump_ctr_tank_L_fault = 0
local annun_fuel_pump_ctr_tank_L_off = 0
local annun_fuel_pump_L2_fault = 0
local annun_fuel_pump_L2_off = 0
local annun_fuel_pump_R2_fault = 0
local annun_fuel_pump_R2_off = 0
local annun_fuel_outr_tk_xfr_fault = 0
local annun_fuel_outr_tk_xfr_on = 0
local annun_rtp_R_offside_tuning = 0
local annun_rtp_R_vhf_1 = 0
local annun_rtp_R_vhf_2 = 0
local annun_rtp_R_vhf_3 = 0
local annun_rtp_R_hf_1 = 0
local annun_rtp_R_am = 0
local annun_rtp_R_hf_2 = 0
local annun_rtp_R_no_op = 0
local audio_panel_fo_call_light_vhf1 = 0
local audio_panel_fo_call_light_vhf2 = 0
local audio_panel_fo_call_light_att = 0
local audio_panel_fo_call_light_gen = 0

local lcl = {
    annun_audio_panel_fo_mic1 = 0,
    annun_audio_panel_fo_mic2 = 0,
    annun_audio_panel_fo_mic3 = 0,
    annun_audio_panel_fo_mic4 = 0,
    annun_audio_panel_fo_mic5 = 0,
    annun_audio_panel_fo_mic6 = 0,
    annun_audio_panel_fo_mic7 = 0,
    annun_audio_panel_fo_mic8 = 0,
    annun_audio_panel_fo_mic9 = 0,
    annun_audio_panel_fo_mic10 = 0,
    annun_audio_panel_fo_voice = 0,

    annun_audio_panel_fo_listen = {},

    annun_fo_priority_light = 0,
    annun_fo_priority_arrow_light = 0,

    annun_flt_ctl_sec2_fault = 0,
    annun_flt_ctl_sec3_fault = 0,
    annun_flt_ctl_prim2_fault = 0,
    annun_flt_ctl_prim3_fault = 0,

    annun_window_probe_heat = 0,

    annun_fuel_inr_tk_on_L = 0,
    annun_fuel_inr_tk_shut_L = 0,
    annun_fuel_inr_tk_on_R = 0,
    annun_fuel_inr_tk_shut_R = 0,

    annun_eng1_fadec_grnd_power_on = 0,
    annun_eng2_fadec_grnd_power_on = 0,

    annun_cockpit_door_video_off = 0,

    annun_cockpit_door_ctl_strike_top = 0,
    annun_cockpit_door_ctl_strike_mid = 0,
    annun_cockpit_door_ctl_strike_btm = 0,
    annun_cockpit_door_ctl_channel1 = 0,
    annun_cockpit_door_ctl_channel2 = 0,

    annun_hyd_leak_msrmnt_g_off = 0,
    annun_hyd_leak_msrmnt_b_off = 0,
    annun_hyd_leak_msrmnt_y_off = 0,

    annun_mcdu2_fail_fm = 0,
    annun_mcdu2_mcdu_menu = 0,
    annun_mcdu2_fm1 = 0,
    annun_mcdu2_fm2 = 0,
    annun_mcdu2_ind = 0,
    annun_mcdu2_rdy = 0,
    annun_mcdu2_line = 0

}

for i = 0, 16-1 do
    lcl.annun_audio_panel_fo_listen[i] = 0
end


--*************************************************************************************--
--** 				            LOCAL UTILITY FUNCTIONS          			    	 **--
--*************************************************************************************--






--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--


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
local function A333_annun_ac2_cache_globals()

	lcl_SIM_PERIOD = SIM_PERIOD

end




function A333_toilet_time_processing()

    if toilet.time_between_timer > toilet.time_between_occupied then
        toilet.time_between_timer = 0
        toilet.occupied_running = 1
        toilet.time_between_occupied = m.random(4, 18)
    elseif toilet.time_between_timer <= toilet.time_between_occupied then
        toilet.time_between_timer = toilet.time_between_timer + lcl_SIM_PERIOD/60
    end

    if toilet.occupied_timer > toilet.time_occupied then
        toilet.occupied_timer = 0
        toilet.occupied_running = 0
        toilet.time_occupied = m.random(3)
    elseif toilet.occupied_timer <= toilet.time_occupied then
        if toilet.occupied_running == 1 then
            toilet.occupied_timer = toilet.occupied_timer + lcl_SIM_PERIOD/60
        elseif toilet.occupied_running == 0 then
            toilet.occupied_timer = 0
        end
    end

    -- FOR TESTING ONLY:
--    A333DR_toilet_occupied = toilet.occupied_running
--    A333DR_toilet_period = toilet.occupied_timer
--    A333DR_toilet_waitbetween	= toilet.time_between_timer
--    A333DR_toilet_random_period = toilet.time_occupied
--    A333DR_toilet_random_wait = toilet.time_between_occupied
    
end




local function A333_annun_ac2_processing()

    local NUM_FO_LISTENING_LIGHTS = 16

    local bool2num = {[true] = 1, [false] = 0}
    local animate = animate

    local annun_light_switch_dim_or_brt = A333DR_ann_light_switch_pos <= 1
    local annun_ac2_brightness = A333DR_annun_brightness_ac2
    local annun_ac1_ac2_acess_brightness = m.max(A333DR_annun_brightness_ac1, A333DR_annun_brightness_ac2, A333DR_annun_brightness_ac_ess)
    local annun_ac2_2_brightness = A333DR_annun_brightness_ac2_2
    local annun_ac2_or_ac_ess_shed_brightness = A333DR_annun_brightness_ac2_or_ac_ess_shed
    local annun_light_switch_test = A333DR_dc_bus2_has_power
    local sim_time_factor = m.fmod(simDR_flight_time, 0.6)
    local call_flasher = (sim_time_factor >= 0 and sim_time_factor <= 0.3) and 1 or 0
    local sim_time_factor2 = m.fmod(simDR_flight_time, 0.59)
    local flasher2 = (sim_time_factor2 >= 0 and sim_time_factor2 <= 0.295) and 1 or 0
    local sim_time_factor4 = m.fmod(simDR_flight_time, 0.57)
    local flasher4 = (sim_time_factor4 >= 0 and sim_time_factor4 <= 0.28) and 1 or 0

    local cockpit_door_open = simDR_door_open_ratio[11] > 0
    local cockpit_door_closed = not cockpit_door_open
    local cockpit_door_lock_switch_pos = A333DR_cockpit_door_lock_switch_pos          -- switch: -1=LOCK, 0=NORM , 1=UNLOCK
    local cockpit_door_lock_mode = A333DR_door_locked_status          -- status: 0=UNLOCKED, 1=NORM (locked), 2=LOCKED
    local cockpit_door_lock_mode = A333DR_cockpit_door_lock_mode          -- status: 0=UNLOCKED, 1=NORM (locked), 2=LOCKED
    local cockpit_door_lock_unlocked = cockpit_door_lock_mode == 0
    local cockpit_door_lock_norm = cockpit_door_lock_mode == 0
    local cockpit_door_lock_locked = cockpit_door_lock_mode == 2
    local ecp_system_page_pushbutton_annun = A333DR_ecp_sys_page_pushbutton_annun
    local ecp_system_page_pushbutton_annun_target   = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    local gear_on_ground = simDR_gear_on_ground[1] == 1
    local engine_hyd_yellow_pump_actuator = simDR_engine_hyd_yellow_pump_actuator     --indexed
    local elec_hyd_yellow_pump_actuator = simDR_elec_hydraulic_yellow_pump_actuator
	local elec_pump_yellow_contactor = A333DR_elec_pump_yellow_contactor
    local engine_is_burning_fuel = simDR_engine_is_burning_fuel
    local engine1_is_running = engine_is_burning_fuel[0] == 1
    local engine2_is_running = engine_is_burning_fuel[1] == 1
    local engine2_hyd_yellow_pump_on = engine_hyd_yellow_pump_actuator[1] == 1
    local apu_bleed_switch_ctct_on_off = A333DR_apu_bleed_switch_ctct_on_off
    local eng2_bleed_switch_ctct_on_off = A333DR_eng2_bleed_switch_ctct_on_off
    local pack2_switch_ctct_on_off = A333DR_pack2_switch_ctct_on_off
    local pack1_switch_ctct_on_off = A333DR_pack1_switch_ctct_on_off
    local center_left_fuel_pump_button_pos = A333DR_center_left_pump_pos
    local fuel_tank_qty = simDR_fuel_qty
    local right_fuel_pump2_button_pos = A333DR_right_pump2_pos
    local outer_fuel_tank_xfr_button_pos = A333DR_fuel_outer_tank_xfr_pos
    local rtp_R_is_on = A333DR_rtp_R_off_status == 0
    local audio_panel_fo_listen_annun_target = {}
    local audio_panel_fo_listen_status = A333DR_audio_panel_fo_listen_status
    local fo_priority_status = A333DR_fo_priority_status


    -- SET ANNUNCIATOR STATUS (0/1)
    local cockpit_door_open_annun_target = 0
    if annun_light_switch_dim_or_brt then
        if A333DR_cockpit_door_on_flash == 1 then
            cockpit_door_open_annun_target = flasher2
        else
            cockpit_door_open_annun_target = bool2num[cockpit_door_open or (cockpit_door_closed and cockpit_door_lock_mode == 0)]
        end
    else
        cockpit_door_open_annun_target = annun_light_switch_test
    end

    cockpit_door_fault_blink = animate(cockpit_door_fault_blink, cockpit_door_lock_switch_pos, 50)
    local cockpit_door_fault_annun_target = annun_light_switch_dim_or_brt
        and bool2num[cockpit_door_lock_switch_pos == 0 and (cockpit_door_fault_blink ~= 0 and cockpit_door_fault_blink ~= 1)]
        or annun_light_switch_test

    local prim2_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_prim2_pos == 0] or annun_light_switch_test
    local prim3_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_prim3_pos == 0] or annun_light_switch_test
    local sec2_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_sec2_pos == 0] or annun_light_switch_test
    local adirs_on_bat_annun_target = annun_light_switch_dim_or_brt and A333DR_adirs_on_bat_status or annun_light_switch_test
    local landing_gear_brake_fan_hot_annun_target = annun_light_switch_dim_or_brt and A333DR_wheel_brake_warn or annun_light_switch_test
    local landing_gear_brake_fan_on_annun_target = annun_light_switch_dim_or_brt and simDR_brake_fan or annun_light_switch_test

    for i = 1, 13 do
        ecp_system_page_pushbutton_annun_target[i] = annun_light_switch_dim_or_brt and ecp_system_page_pushbutton_annun[i-1] or annun_light_switch_test
    end

    local ecp_clr_pushbutton_annun_target = annun_light_switch_dim_or_brt and A333DR_ecp_clr_pushbutton_annun or annun_light_switch_test
    local ecp_sts_pushbutton_annun_target = annun_light_switch_dim_or_brt and A333DR_ecp_sts_pushbutton_annun or annun_light_switch_test
    local master_caution_annun_target = annun_light_switch_dim_or_brt and simDR_master_caution_anunn or annun_light_switch_test
    local master_warning_annun_target = annun_light_switch_dim_or_brt and bool2num[simDR_master_warning_anunn >= 1 and flasher2 == 1] or annun_light_switch_test
    local flt_rcdr_gnd_ctl_on_annun_target = annun_light_switch_dim_or_brt and (((A333DR_flight_recorder_mode_on == 1) and 1) or 0) or annun_light_switch_test
    local hyd_elec_yellow_pump_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[simDR_elec_hyd_yellow_fault == 6] or annun_light_switch_test
    local hyd_elec_yellow_pump_off_annun_target = annun_light_switch_dim_or_brt and bool2num[elec_pump_yellow_contactor == 0] or annun_light_switch_test
    local hyd_elec_yellow_pump_on_annun_target = annun_light_switch_dim_or_brt and bool2num[elec_hyd_yellow_pump_actuator == 1] or annun_light_switch_test

    local hyd_eng2_yellow_pump_fault_annun_target = annun_light_switch_dim_or_brt
        and bool2num[((simDR_engine2_hyd_pump_fault == 6) or (engine2_hyd_yellow_pump_on and ((engine2_is_running or (not gear_on_ground)) and simDR_yellow_pressure < 2000)))]
            or annun_light_switch_test

    local hyd_eng2_yellow_pump_off_annun_target = annun_light_switch_dim_or_brt and bool2num[not engine2_hyd_yellow_pump_on] or annun_light_switch_test
    local elec_ext_a_on_annun_target = annun_light_switch_dim_or_brt and A333DR_extA_line_contactor or annun_light_switch_test
    local elec_ext_b_auto_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_buttons_extB_ctct_on_off == 1] or annun_light_switch_test
    local elec_ac_ess_feed_altn_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_buttons_ACESS_FEED_pos == 0] or annun_light_switch_test
    local elec_ac_ess_feed_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[not A333DR_ac_ess_bus_has_power]  or annun_light_switch_test
    local auto_land_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test   -- TODO (warning System logic)

    local eng2_bleed_fault_annun_target = annun_light_switch_dim_or_brt
        and bool2num[(simDR_engine_bleed_sov_status[1] > 0 and (simDR_engine_starter_running[1] == 1 or (apu_bleed_switch_ctct_on_off == 1 and simDR_apu_running == 1)))
        or simDR_engine_bleed2_fail == 6]
        or annun_light_switch_test

    local eng2_bleed_off_annun_target = annun_light_switch_dim_or_brt and bool2num[eng2_bleed_switch_ctct_on_off == 0] or annun_light_switch_test
    local pack2_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[pack2_switch_ctct_on_off == 1 and simDR_bleed_air_avail_right <= 0.5] or annun_light_switch_test
    local pack2_off_annun_target = annun_light_switch_dim_or_brt and bool2num[pack2_switch_ctct_on_off == 0] or annun_light_switch_test
    local apu_bleed_on_annun_target = annun_light_switch_dim_or_brt and apu_bleed_switch_ctct_on_off or annun_light_switch_test
    local apu_bleed_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[simDR_apu_bleed_fail == 6] or annun_light_switch_test
    local ram_air_on_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_switches_ram_air_pos >= 1] or annun_light_switch_test
    local annun_pack1_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[pack1_switch_ctct_on_off == 1 and simDR_bleed_air_avail_left <= 0.5] or annun_light_switch_test
    local annun_pack1_off_annun_target = annun_light_switch_dim_or_brt and bool2num[pack1_switch_ctct_on_off == 0] or annun_light_switch_test

    local annun_misc_toilet_occpd_annun_target = (annun_light_switch_dim_or_brt and
        bool2num[(gear_on_ground == 1 and engine1_is_running == 0 and engine2_is_running == 0)
        or (gear_on_ground == 0 and simDR_altitude >= 10000 and simDR_belts_on == 0)])
        and toilet.occupied_running or annun_light_switch_test

    local fuel_pump_ctr_tank_L_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[center_left_fuel_pump_button_pos >= 1 and A333_ECAM_fuel_center_xfer_any == 1 and fuel_tank_qty[1] < 250] or annun_light_switch_test
    local fuel_pump_ctr_tank_L_off_annun_target = annun_light_switch_dim_or_brt and bool2num[center_left_fuel_pump_button_pos == 0] or annun_light_switch_test
    local fuel_pump_L2_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_left_pump1_pos >= 1 and fuel_tank_qty[0] < 150] or annun_light_switch_test
    local fuel_pump_L2_off_annun_target = annun_light_switch_dim_or_brt and bool2num[A333DR_left_pump2_pos == 0] or annun_light_switch_test
    local fuel_pump_R2_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[right_fuel_pump2_button_pos >= 1 and fuel_tank_qty[2] < 140] or annun_light_switch_test
    local fuel_pump_R2_off_annun_target = annun_light_switch_dim_or_brt and bool2num[right_fuel_pump2_button_pos == 0] or annun_light_switch_test
    local fuel_outr_tk_xfr_fault_annun_target = annun_light_switch_dim_or_brt and bool2num[outer_fuel_tank_xfr_button_pos == 1 and (fuel_tank_qty[3] < 75 or fuel_tank_qty[4] < 75)] or annun_light_switch_test
    local fuel_outr_tk_xfr_on_annun_target = annun_light_switch_dim_or_brt and outer_fuel_tank_xfr_button_pos or annun_light_switch_test
    local rtp_R_offside_tuning_annun_target = annun_light_switch_dim_or_brt and (rtp_R_is_on and A333DR_rtp_R_offside_tuning_status or 0) or annun_light_switch_test
    local rtp_R_vhf_1_annun_target = annun_light_switch_dim_or_brt and (rtp_R_is_on and A333DR_rtp_R_vhf_1_status or 0) or annun_light_switch_test
    local rtp_R_vhf_2_annun_target = annun_light_switch_dim_or_brt and (rtp_R_is_on and A333DR_rtp_R_vhf_2_status or 0) or annun_light_switch_test
    local rtp_R_vhf_3_annun_target = annun_light_switch_dim_or_brt and (rtp_R_is_on and A333DR_rtp_R_vhf_3_status or 0) or annun_light_switch_test
    local rtp_R_hf_1_annun_target = annun_light_switch_dim_or_brt and (rtp_R_is_on and A333DR_rtp_R_hf_1_status or 0) or annun_light_switch_test
    local rtp_R_am_annun_target = annun_light_switch_dim_or_brt and (rtp_R_is_on and A333DR_rtp_R_hf_2_status or 0) or annun_light_switch_test
    local rtp_R_hf_2_annun_target = annun_light_switch_dim_or_brt and (rtp_R_is_on and A333DR_rtp_R_am_status or 0) or annun_light_switch_test
    local rtp_R_no_op_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test

    local audio_panel_fo_mic1_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_fo_mic1_status or annun_light_switch_test
    local audio_panel_fo_mic2_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_fo_mic2_status or annun_light_switch_test
    local audio_panel_fo_mic3_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_fo_mic3_status or annun_light_switch_test
    local audio_panel_fo_mic4_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_fo_mic4_status or annun_light_switch_test
    local audio_panel_fo_mic5_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_fo_mic5_status or annun_light_switch_test
    local audio_panel_fo_mic6_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_fo_mic6_status or annun_light_switch_test
    local audio_panel_fo_mic7_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_fo_mic7_status or annun_light_switch_test
    local audio_panel_fo_mic8_annun_target = annun_light_switch_dim_or_brt and (A333DR_audio_panel_fo_mic8_status * flasher2) or annun_light_switch_test
    local audio_panel_fo_mic9_annun_target = annun_light_switch_dim_or_brt and (A333DR_audio_panel_fo_mic9_status * flasher2) or annun_light_switch_test
    local audio_panel_fo_mic10_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_fo_mic10_status or annun_light_switch_test
    local audio_panel_fo_voice_annun_target = annun_light_switch_dim_or_brt and A333DR_audio_panel_fo_voice_status or annun_light_switch_test

    local audio_panel_fo_call_light_vhf1_target = annun_light_switch_dim_or_brt and (call_flasher * A333DR_fo_com1_activated) or annun_light_switch_test
    local audio_panel_fo_call_light_vhf2_target = annun_light_switch_dim_or_brt and (call_flasher * A333DR_fo_com2_activated) or annun_light_switch_test
    local audio_panel_fo_call_light_att_target = annun_light_switch_dim_or_brt and (call_flasher * A333DR_fo_att_activated) or annun_light_switch_test
    local audio_panel_fo_call_light_gen_target = annun_light_switch_dim_or_brt and (call_flasher * A333DR_fo_gen_activated) or annun_light_switch_test

    for i = 0, NUM_FO_LISTENING_LIGHTS-1 do
        audio_panel_fo_listen_annun_target[i] = annun_light_switch_dim_or_brt and audio_panel_fo_listen_status[i] or annun_light_switch_test
    end

    local fo_priority_light_annun_target = annun_light_switch_dim_or_brt
        and (A333DR_dual_input ==1 and (fo_priority_status * flasher4) or fo_priority_status)
        or annun_light_switch_test

    local fo_priority_arrow_light_annun_target = annun_light_switch_dim_or_brt and A333DR_fo_arrow_status or annun_light_switch_test

    local flt_ctl_sec2_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local flt_ctl_sec3_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local flt_ctl_prim2_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local flt_ctl_prim3_fault_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test

    local window_probe_heat_annun_target = annun_light_switch_dim_or_brt and A333DR_probe_window_heat_monitor or annun_light_switch_test

    local fuel_inr_tk_on_L_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local fuel_inr_tk_shut_L_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local fuel_inr_tk_on_R_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local fuel_inr_tk_shut_R_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local eng1_fadec_grnd_power_on_annun_target = annun_light_switch_dim_or_brt and A333DR_eng1_fadec_ground_powered or annun_light_switch_test
    local eng2_fadec_grnd_power_on_annun_target = annun_light_switch_dim_or_brt and A333DR_eng2_fadec_ground_powered or annun_light_switch_test
    local cockpit_door_video_off_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cockpit_door_ctl_strike_top_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cockpit_door_ctl_strike_mid_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cockpit_door_ctl_strike_btm_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cockpit_door_ctl_channel1_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local cockpit_door_ctl_channel2_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local hyd_leak_msrmnt_g_off_annun_target = annun_light_switch_dim_or_brt and A333DR_green_leak_measure_status or annun_light_switch_test
    local hyd_leak_msrmnt_b_off_annun_target = annun_light_switch_dim_or_brt and A333DR_blue_leak_measure_status or annun_light_switch_test
    local hyd_leak_msrmnt_y_off_annun_target = annun_light_switch_dim_or_brt and A333DR_yellow_leak_measure_status or annun_light_switch_test
    local mcdu2_fail_fm_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu2_mcdu_menu_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu2_fm1_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu2_fm2_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu2_ind_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu2_rdy_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test
    local mcdu2_line_annun_target = annun_light_switch_dim_or_brt and 0 or annun_light_switch_test


    -- SET ANNUNCIATOR FADE IN/OUT
    annun_cockpit_door_open = animate(annun_cockpit_door_open, cockpit_door_open_annun_target, 13)
    annun_cockpit_door_fault = animate(annun_cockpit_door_fault, cockpit_door_fault_annun_target, 13)
    annun_prim2_off = animate(annun_prim2_off, prim2_off_annun_target, 13)
    annun_prim3_off = animate(annun_prim3_off, prim3_off_annun_target, 13)
    annun_sec2_off = animate(annun_sec2_off, sec2_off_annun_target, 13)
    annun_adirs_on_bat = animate(annun_adirs_on_bat, adirs_on_bat_annun_target, 13)
    annun_landing_gear_brake_fan_hot = animate(annun_landing_gear_brake_fan_hot, landing_gear_brake_fan_hot_annun_target, 13)
    annun_landing_gear_brake_fan_on = animate(annun_landing_gear_brake_fan_on, landing_gear_brake_fan_on_annun_target, 13)

    for i = 1, 13 do
        annun_ecp_system_page_pushbutton[i] = animate(annun_ecp_system_page_pushbutton[i], ecp_system_page_pushbutton_annun_target[i], 13)
    end

    annun_ecp_clr_pushbutton = animate(annun_ecp_clr_pushbutton, ecp_clr_pushbutton_annun_target, 13)
    annun_ecp_sts_pushbutton = animate(annun_ecp_sts_pushbutton, ecp_sts_pushbutton_annun_target, 13)
    annun_master_caution = animate(annun_master_caution, master_caution_annun_target, 13)
    annun_master_warning = animate(annun_master_warning, master_warning_annun_target, 13)
    annun_flt_rcdr_gnd_ctl_on = animate(annun_flt_rcdr_gnd_ctl_on, flt_rcdr_gnd_ctl_on_annun_target, 13)
    annun_hyd_elec_yellow_pump_fault = animate(annun_hyd_elec_yellow_pump_fault, hyd_elec_yellow_pump_fault_annun_target, 13)
    annun_hyd_elec_yellow_pump_off = animate(annun_hyd_elec_yellow_pump_off, hyd_elec_yellow_pump_off_annun_target, 13)
    annun_hyd_elec_yellow_pump_on = animate(annun_hyd_elec_yellow_pump_on, hyd_elec_yellow_pump_on_annun_target, 13)
    annun_hyd_eng2_yellow_pump_fault = animate(annun_hyd_eng2_yellow_pump_fault, hyd_eng2_yellow_pump_fault_annun_target, 13)
    annun_hyd_eng2_yellow_pump_off = animate(annun_hyd_eng2_yellow_pump_off, hyd_eng2_yellow_pump_off_annun_target, 13)
    annun_elec_ext_a_on = animate(annun_elec_ext_a_on, elec_ext_a_on_annun_target, 13)
    annun_elec_ext_b_auto = animate(annun_elec_ext_b_auto, elec_ext_b_auto_annun_target, 13)
    annun_elec_ac_ess_feed_altn = animate(annun_elec_ac_ess_feed_altn, elec_ac_ess_feed_altn_annun_target, 13)
    annun_elec_ac_ess_feed_fault = animate(annun_elec_ac_ess_feed_fault, elec_ac_ess_feed_fault_annun_target, 13)
    annun_auto_land = animate(annun_auto_land, auto_land_annun_target, 13)
    annun_eng2_bleed_fault = animate(annun_eng2_bleed_fault, eng2_bleed_fault_annun_target, 13)
    annun_eng2_bleed_off = animate(annun_eng2_bleed_off, eng2_bleed_off_annun_target, 13)
    annun_pack2_fault = animate(annun_pack2_fault, pack2_fault_annun_target, 13)
    annun_pack2_off = animate(annun_pack2_off, pack2_off_annun_target, 13)
    annun_apu_bleed_on = animate(annun_apu_bleed_on, apu_bleed_on_annun_target, 13)
    annun_apu_bleed_fault = animate(annun_apu_bleed_fault, apu_bleed_fault_annun_target, 13)
    annun_ram_air_on = animate(annun_ram_air_on, ram_air_on_annun_target, 13)
    annun_pack1_fault = animate(annun_pack1_fault, annun_pack1_fault_annun_target, 13)
    annun_pack1_off = animate(annun_pack1_off, annun_pack1_off_annun_target, 13)
    annun_misc_toilet_occpd = animate(annun_misc_toilet_occpd, annun_misc_toilet_occpd_annun_target, 13)
    annun_fuel_pump_ctr_tank_L_fault = animate(annun_fuel_pump_ctr_tank_L_fault, fuel_pump_ctr_tank_L_fault_annun_target, 13)
    annun_fuel_pump_ctr_tank_L_off = animate(annun_fuel_pump_ctr_tank_L_off, fuel_pump_ctr_tank_L_off_annun_target, 13)
    annun_fuel_pump_L2_fault = animate(annun_fuel_pump_L2_fault, fuel_pump_L2_fault_annun_target, 13)
    annun_fuel_pump_L2_off = animate(annun_fuel_pump_L2_off, fuel_pump_L2_off_annun_target, 13)
    annun_fuel_pump_R2_fault = animate(annun_fuel_pump_R2_fault, fuel_pump_R2_fault_annun_target, 13)
    annun_fuel_pump_R2_off = animate(annun_fuel_pump_R2_off, fuel_pump_R2_off_annun_target, 13)
    annun_fuel_outr_tk_xfr_fault = animate(annun_fuel_outr_tk_xfr_fault, fuel_outr_tk_xfr_fault_annun_target, 13)
    annun_fuel_outr_tk_xfr_on = animate(annun_fuel_outr_tk_xfr_on, fuel_outr_tk_xfr_on_annun_target, 13)
    annun_rtp_R_offside_tuning = animate(annun_rtp_R_offside_tuning, rtp_R_offside_tuning_annun_target, 13)
    annun_rtp_R_vhf_1 = animate(annun_rtp_R_vhf_1, rtp_R_vhf_1_annun_target, 13)
    annun_rtp_R_vhf_2 = animate(annun_rtp_R_vhf_2, rtp_R_vhf_2_annun_target, 13)
    annun_rtp_R_vhf_3 = animate(annun_rtp_R_vhf_3, rtp_R_vhf_3_annun_target, 13)
    annun_rtp_R_hf_1 = animate(annun_rtp_R_hf_1, rtp_R_hf_1_annun_target, 13)
    annun_rtp_R_am = animate(annun_rtp_R_am, rtp_R_am_annun_target, 13)
    annun_rtp_R_hf_2 = animate(annun_rtp_R_hf_2, rtp_R_hf_2_annun_target, 13)
    annun_rtp_R_no_op = animate(annun_rtp_R_no_op, rtp_R_no_op_annun_target, 13)
    lcl.annun_audio_panel_fo_mic1 = animate(lcl.annun_audio_panel_fo_mic1, audio_panel_fo_mic1_annun_target, 13)
    lcl.annun_audio_panel_fo_mic2 = animate(lcl.annun_audio_panel_fo_mic2, audio_panel_fo_mic2_annun_target, 13)
    lcl.annun_audio_panel_fo_mic3 = animate(lcl.annun_audio_panel_fo_mic3, audio_panel_fo_mic3_annun_target, 13)
    lcl.annun_audio_panel_fo_mic4 = animate(lcl.annun_audio_panel_fo_mic4, audio_panel_fo_mic4_annun_target, 13)
    lcl.annun_audio_panel_fo_mic5 = animate(lcl.annun_audio_panel_fo_mic5, audio_panel_fo_mic5_annun_target, 13)
    lcl.annun_audio_panel_fo_mic6 = animate(lcl.annun_audio_panel_fo_mic6, audio_panel_fo_mic6_annun_target, 13)
    lcl.annun_audio_panel_fo_mic7 = animate(lcl.annun_audio_panel_fo_mic7, audio_panel_fo_mic7_annun_target, 13)
    lcl.annun_audio_panel_fo_mic8 = animate(lcl.annun_audio_panel_fo_mic8, audio_panel_fo_mic8_annun_target, 13)
    lcl.annun_audio_panel_fo_mic9 = animate(lcl.annun_audio_panel_fo_mic9, audio_panel_fo_mic9_annun_target, 13)
    lcl.annun_audio_panel_fo_mic10 = animate(lcl.annun_audio_panel_fo_voice, audio_panel_fo_mic10_annun_target, 13)
    lcl.annun_audio_panel_fo_voice = animate(lcl.annun_audio_panel_fo_voice, audio_panel_fo_voice_annun_target, 13)
    audio_panel_fo_call_light_vhf1 = animate(audio_panel_fo_call_light_vhf1, audio_panel_fo_call_light_vhf1_target, 13)
    audio_panel_fo_call_light_vhf2 = animate(audio_panel_fo_call_light_vhf2, audio_panel_fo_call_light_vhf2_target, 13)
    audio_panel_fo_call_light_att = animate(audio_panel_fo_call_light_att, audio_panel_fo_call_light_att_target, 13)
    audio_panel_fo_call_light_gen = animate(audio_panel_fo_call_light_gen, audio_panel_fo_call_light_gen_target, 13)

    for i = 0, NUM_FO_LISTENING_LIGHTS-1 do
        lcl.annun_audio_panel_fo_listen[i] = animate(lcl.annun_audio_panel_fo_listen[i], audio_panel_fo_listen_annun_target[i], 13)
    end

    lcl.annun_fo_priority_light = animate(lcl.annun_fo_priority_light, fo_priority_light_annun_target, 13)
    lcl.annun_fo_priority_arrow_light = animate(lcl.annun_fo_priority_arrow_light, fo_priority_arrow_light_annun_target, 13)
    lcl.annun_flt_ctl_sec2_fault = animate(lcl.annun_flt_ctl_sec2_fault, flt_ctl_sec2_fault_annun_target, 13)
    lcl.annun_flt_ctl_sec3_fault = animate(lcl.annun_flt_ctl_sec3_fault , flt_ctl_sec3_fault_annun_target, 13)
    lcl.annun_flt_ctl_prim2_fault = animate(lcl.annun_flt_ctl_prim2_fault , flt_ctl_prim2_fault_annun_target, 13)
    lcl.annun_flt_ctl_prim3_fault = animate(lcl.annun_flt_ctl_prim3_fault , flt_ctl_prim3_fault_annun_target, 13)

    lcl.annun_window_probe_heat =  animate(lcl.annun_window_probe_heat , window_probe_heat_annun_target, 13)

    lcl.annun_fuel_inr_tk_on_L = animate(lcl.annun_fuel_inr_tk_on_L, fuel_inr_tk_on_L_annun_target    , 13)
    lcl.annun_fuel_inr_tk_shut_L = animate( lcl.annun_fuel_inr_tk_shut_L, fuel_inr_tk_shut_L_annun_target, 13)
    lcl.annun_fuel_inr_tk_on_R = animate(lcl.annun_fuel_inr_tk_on_R, fuel_inr_tk_on_R_annun_target    , 13)
    lcl.annun_fuel_inr_tk_shut_R = animate( lcl.annun_fuel_inr_tk_shut_R, fuel_inr_tk_shut_R_annun_target, 13)
    lcl.annun_eng1_fadec_grnd_power_on = animate(lcl.annun_eng1_fadec_grnd_power_on, eng1_fadec_grnd_power_on_annun_target, 13)
    lcl.annun_eng2_fadec_grnd_power_on = animate(lcl.annun_eng2_fadec_grnd_power_on, eng2_fadec_grnd_power_on_annun_target, 13)
    lcl.annun_cockpit_door_video_off = animate(lcl.annun_cockpit_door_video_off, cockpit_door_video_off_target, 13)
    lcl.annun_cockpit_door_ctl_strike_top = animate(lcl.annun_cockpit_door_ctl_strike_top, cockpit_door_ctl_strike_top_annun_target, 13)
    lcl.annun_cockpit_door_ctl_strike_mid = animate(lcl.annun_cockpit_door_ctl_strike_mid, cockpit_door_ctl_strike_mid_annun_target, 13)
    lcl.annun_cockpit_door_ctl_strike_btm = animate(lcl.annun_cockpit_door_ctl_strike_btm, cockpit_door_ctl_strike_btm_annun_target, 13)
    lcl.annun_cockpit_door_ctl_channel1 = animate(lcl.annun_cockpit_door_ctl_channel1, cockpit_door_ctl_channel1_annun_target, 13)
    lcl.annun_cockpit_door_ctl_channel2 = animate(lcl.annun_cockpit_door_ctl_channel2, cockpit_door_ctl_channel2_annun_target, 13)
    lcl.annun_hyd_leak_msrmnt_g_off = animate(lcl.annun_hyd_leak_msrmnt_g_off, hyd_leak_msrmnt_g_off_annun_target, 13)
    lcl.annun_hyd_leak_msrmnt_b_off = animate(lcl.annun_hyd_leak_msrmnt_b_off, hyd_leak_msrmnt_b_off_annun_target, 13)
    lcl.annun_hyd_leak_msrmnt_y_off = animate(lcl.annun_hyd_leak_msrmnt_y_off, hyd_leak_msrmnt_y_off_annun_target, 13)
    lcl.annun_mcdu2_fail_fm = animate(lcl.annun_mcdu2_fail_fm, mcdu2_fail_fm_annun_target, 13)
    lcl.annun_mcdu2_mcdu_menu = animate(lcl.annun_mcdu2_mcdu_menu, mcdu2_mcdu_menu_annun_target, 13)
    lcl.annun_mcdu2_fm1 = animate(lcl.annun_mcdu2_fm1, mcdu2_fm1_annun_target, 13)
    lcl.annun_mcdu2_fm2 = animate(lcl.annun_mcdu2_fm2, mcdu2_fm2_annun_target, 13)
    lcl.annun_mcdu2_ind = animate(lcl.annun_mcdu2_ind, mcdu2_ind_annun_target, 13)
    lcl.annun_mcdu2_rdy = animate(lcl.annun_mcdu2_rdy, mcdu2_rdy_annun_target, 13)
    lcl.annun_mcdu2_line = animate(lcl.annun_mcdu2_line, mcdu2_line_annun_target, 13)


    -- SET ANNUNCIATOR BRIGHTNESS AND ASSIGN TO DATAREF
    A333DR_annun_cockpit_door_open = annun_cockpit_door_open * annun_ac2_brightness
    A333DR_annun_cockpit_door_fault = annun_cockpit_door_fault * annun_ac2_brightness
    A333DR_annun_flt_ctl_prim2_off = annun_prim2_off * annun_ac2_brightness
    A333DR_annun_flt_ctl_prim3_off = annun_prim3_off * annun_ac2_brightness
    A333DR_annun_flt_ctl_sec2_off = annun_sec2_off * annun_ac2_brightness
    A333DR_annun_adirs_on_bat = annun_adirs_on_bat * annun_ac2_brightness
    A333DR_annun_landing_gear_brake_fan_hot = annun_landing_gear_brake_fan_hot * annun_ac2_brightness
    A333DR_annun_landing_gear_brake_fan_on = annun_landing_gear_brake_fan_on * annun_ac2_brightness
    A333DR_annun_ecp_eng = annun_ecp_system_page_pushbutton[1] * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_bleed = annun_ecp_system_page_pushbutton[2] * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_press = annun_ecp_system_page_pushbutton[3] * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_el_ac = annun_ecp_system_page_pushbutton[4] * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_el_dc = annun_ecp_system_page_pushbutton[5] * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_hyd = annun_ecp_system_page_pushbutton[6] * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_c_b = annun_ecp_system_page_pushbutton[7] * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_apu = annun_ecp_system_page_pushbutton[8] * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_cond = annun_ecp_system_page_pushbutton[9] * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_door = annun_ecp_system_page_pushbutton[10] * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_wheel = annun_ecp_system_page_pushbutton[11] * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_f_ctl = annun_ecp_system_page_pushbutton[12] * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_fuel = annun_ecp_system_page_pushbutton[13] * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_clr = annun_ecp_clr_pushbutton * annun_ac1_ac2_acess_brightness
    A333DR_annun_ecp_sts = annun_ecp_sts_pushbutton * annun_ac1_ac2_acess_brightness
    A333DR_annun_rcdr_gnd_ctl_on = annun_flt_rcdr_gnd_ctl_on * annun_ac2_brightness
    A333DR_annun_hyd_elec_yellow_pump_fault = annun_hyd_elec_yellow_pump_fault * annun_ac2_brightness
    A333DR_annun_hyd_elec_yellow_pump_off = annun_hyd_elec_yellow_pump_off * annun_ac2_brightness
    A333DR_annun_hyd_elec_yellow_pump_on = annun_hyd_elec_yellow_pump_on * annun_ac2_brightness
    A333DR_annun_hyd_eng2_yellow_pump_fault = annun_hyd_eng2_yellow_pump_fault * annun_ac2_brightness
    A333DR_annun_hyd_eng2_yellow_pump_off = annun_hyd_eng2_yellow_pump_off * annun_ac2_brightness
    A333DR_annun_elec_ext_a_on = annun_elec_ext_a_on * annun_ac2_brightness
    A333DR_annun_elec_ext_b_auto = annun_elec_ext_b_auto * annun_ac2_brightness
    A333DR_annun_elec_ac_ess_feed_altn = annun_elec_ac_ess_feed_altn * annun_ac2_brightness
    A333DR_annun_elec_ac_ess_feed_fault = annun_elec_ac_ess_feed_fault * annun_ac2_brightness
    A333DR_annun_eng2_bleed_fault = annun_eng2_bleed_fault * annun_ac2_brightness
    A333DR_annun_eng2_bleed_off = annun_eng2_bleed_off * annun_ac2_brightness
    A333DR_annun_pack2_fault = annun_pack2_fault * annun_ac2_brightness
    A333DR_annun_pack2_off = annun_pack2_off * annun_ac2_brightness
    A333DR_annun_apu_bleed_on = annun_apu_bleed_on * annun_ac2_brightness
    A333DR_annun_apu_bleed_fault = annun_apu_bleed_fault * annun_ac2_brightness
    A333DR_annun_ram_air_on = annun_ram_air_on * annun_ac2_brightness
    A333DR_annun_misc_toilet_occpd = annun_misc_toilet_occpd * annun_ac2_brightness
    A333DR_annun_fuel_pump_ctr_tank_L_fault = annun_fuel_pump_ctr_tank_L_fault * annun_ac2_brightness
    A333DR_annun_fuel_pump_ctr_tank_L_off = annun_fuel_pump_ctr_tank_L_off * annun_ac2_brightness
    A333DR_annun_fuel_pump_L2_fault = annun_fuel_pump_L2_fault * annun_ac2_brightness
    A333DR_annun_fuel_pump_L2_off = annun_fuel_pump_L2_off * annun_ac2_brightness
    A333DR_annun_fuel_pump_R2_fault = annun_fuel_pump_R2_fault * annun_ac2_brightness
    A333DR_annun_fuel_pump_R2_off = annun_fuel_pump_R2_off * annun_ac2_brightness
    A333DR_annun_fuel_outr_tk_xfr_fault = annun_fuel_outr_tk_xfr_fault * annun_ac2_brightness
    A333DR_annun_fuel_outr_tk_xfr_on = annun_fuel_outr_tk_xfr_on * annun_ac2_brightness
    A333DR_audio_panel_fo_mic1_annun = lcl.annun_audio_panel_fo_mic1 * annun_ac2_brightness
    A333DR_audio_panel_fo_mic2_annun = lcl.annun_audio_panel_fo_mic2 * annun_ac2_brightness
    A333DR_audio_panel_fo_mic3_annun = lcl.annun_audio_panel_fo_mic3 * annun_ac2_brightness
    A333DR_audio_panel_fo_mic4_annun = lcl.annun_audio_panel_fo_mic4 * annun_ac2_brightness
    A333DR_audio_panel_fo_mic5_annun = lcl.annun_audio_panel_fo_mic5 * annun_ac2_brightness
    A333DR_audio_panel_fo_mic6_annun = lcl.annun_audio_panel_fo_mic6 * annun_ac2_brightness
    A333DR_audio_panel_fo_mic7_annun = lcl.annun_audio_panel_fo_mic7 * annun_ac2_brightness
    A333DR_audio_panel_fo_mic8_annun = lcl.annun_audio_panel_fo_mic8 * annun_ac2_brightness
    A333DR_audio_panel_fo_mic9_annun = lcl.annun_audio_panel_fo_mic9 * annun_ac2_brightness
    A333DR_audio_panel_fo_mic10_annun = lcl.annun_audio_panel_fo_mic10 * annun_ac2_brightness
    A333DR_audio_panel_fo_voice_annun = lcl.annun_audio_panel_fo_voice * annun_ac2_brightness
    A333DR_audio_panel_fo_call_light_vhf1 = audio_panel_fo_call_light_vhf1 * annun_ac2_brightness
    A333DR_audio_panel_fo_call_light_vhf2 = audio_panel_fo_call_light_vhf2 * annun_ac2_brightness
    A333DR_audio_panel_fo_call_light_att = audio_panel_fo_call_light_att * annun_ac2_brightness 
    A333DR_audio_panel_fo_call_light_gen = audio_panel_fo_call_light_gen * annun_ac2_brightness
    A333DR_annun_flt_ctl_sec2_fault = lcl.annun_flt_ctl_sec2_fault * annun_ac2_brightness
    A333DR_annun_flt_ctl_sec3_fault = lcl.annun_flt_ctl_sec3_fault * annun_ac2_brightness
    A333DR_annun_flt_ctl_prim2_fault = lcl.annun_flt_ctl_prim2_fault * annun_ac2_brightness
    A333DR_annun_flt_ctl_prim3_fault = lcl.annun_flt_ctl_prim3_fault * annun_ac2_brightness
    A333DR_annun_window_probe_heat = lcl.annun_window_probe_heat * annun_ac2_brightness
    A333DR_annun_fuel_inr_tk_on_L = lcl.annun_fuel_inr_tk_on_L * annun_ac2_brightness
    A333DR_annun_fuel_inr_tk_shut_L = lcl.annun_fuel_inr_tk_shut_L * annun_ac2_brightness
    A333DR_annun_fuel_inr_tk_on_R = lcl.annun_fuel_inr_tk_on_R * annun_ac2_brightness
    A333DR_annun_fuel_inr_tk_shut_R = lcl.annun_fuel_inr_tk_shut_R * annun_ac2_brightness
    A333DR_annun_eng1_fadec_grnd_power_on = lcl.annun_eng1_fadec_grnd_power_on * annun_ac2_brightness
    A333DR_annun_eng2_fadec_grnd_power_on = lcl.annun_eng2_fadec_grnd_power_on * annun_ac2_brightness
    A333DR_annun_cockpit_door_video_off = lcl.annun_cockpit_door_video_off * annun_ac2_brightness
    A333DR_annun_cockpit_door_ctl_strike_top = lcl.annun_cockpit_door_ctl_strike_top * annun_ac2_brightness
    A333DR_annun_cockpit_door_ctl_strike_mid = lcl.annun_cockpit_door_ctl_strike_mid * annun_ac2_brightness
    A333DR_annun_cockpit_door_ctl_strike_btm = lcl.annun_cockpit_door_ctl_strike_btm * annun_ac2_brightness
    A333DR_annun_cockpit_door_ctl_channel1 = lcl.annun_cockpit_door_ctl_channel1 * annun_ac2_brightness
    A333DR_annun_cockpit_door_ctl_channel2 = lcl.annun_cockpit_door_ctl_channel2 * annun_ac2_brightness
    A333DR_annun_hyd_leak_msrmnt_g_off = lcl.annun_hyd_leak_msrmnt_g_off * annun_ac2_brightness
    A333DR_annun_hyd_leak_msrmnt_b_off = lcl.annun_hyd_leak_msrmnt_b_off * annun_ac2_brightness
    A333DR_annun_hyd_leak_msrmnt_y_off = lcl.annun_hyd_leak_msrmnt_y_off * annun_ac2_brightness
    A333DR_annun_mcdu2_fail_fm = lcl.annun_mcdu2_fail_fm * annun_ac2_brightness
    A333DR_annun_mcdu2_mcdu_menu = lcl.annun_mcdu2_mcdu_menu * annun_ac2_brightness
    A333DR_annun_mcdu2_fm1 = lcl.annun_mcdu2_fm1 * annun_ac2_brightness
    A333DR_annun_mcdu2_fm2 = lcl.annun_mcdu2_fm2 * annun_ac2_brightness
    A333DR_annun_mcdu2_ind = lcl.annun_mcdu2_ind * annun_ac2_brightness
    A333DR_annun_mcdu2_rdy = lcl.annun_mcdu2_rdy * annun_ac2_brightness
    A333DR_annun_mcdu2_line = lcl.annun_mcdu2_line * annun_ac2_brightness

    A333DR_annun_master_caution = annun_master_caution * annun_ac2_2_brightness
    A333DR_annun_master_warning = annun_master_warning * annun_ac2_2_brightness
    A333DR_annun_rtp_R_offside_tuning = annun_rtp_R_offside_tuning * annun_ac2_2_brightness
    A333DR_annun_rtp_R_vhf_1 = annun_rtp_R_vhf_1 * annun_ac2_2_brightness
    A333DR_annun_rtp_R_vhf_2 = annun_rtp_R_vhf_2 * annun_ac2_2_brightness
    A333DR_annun_rtp_R_vhf_3 = annun_rtp_R_vhf_3 * annun_ac2_2_brightness
    A333DR_annun_rtp_R_hf_1 = annun_rtp_R_hf_1 * annun_ac2_2_brightness
    A333DR_annun_rtp_R_am = annun_rtp_R_am * annun_ac2_2_brightness
    A333DR_annun_rtp_R_hf_2 = annun_rtp_R_hf_2 * annun_ac2_2_brightness
    A333DR_annun_rtp_R_no_op = annun_rtp_R_no_op * annun_ac2_2_brightness


    local br = {}
    for i = 0, NUM_FO_LISTENING_LIGHTS-1 do
        br[i] = lcl.annun_audio_panel_fo_listen[i] * annun_ac2_2_brightness
    end
    A333DR_audio_panel_fo_listen_annun = br

    A333DR_fo_priority_light_annun = lcl.annun_fo_priority_light * annun_ac2_2_brightness
    A333DR_fo_priority_arrow_light_annun = lcl.annun_fo_priority_arrow_light * annun_ac2_2_brightness



    A333DR_annun_auto_land = annun_auto_land * annun_ac2_or_ac_ess_shed_brightness
    A333DR_annun_pack1_fault = annun_pack1_fault * annun_ac2_or_ac_ess_shed_brightness
    A333DR_annun_pack1_off = annun_pack1_off * annun_ac2_or_ac_ess_shed_brightness






end




local function A333_fws_hyd_pump_fault()

    A333DR_hyd_elec_yellow_pump_fault = annun_hyd_elec_yellow_pump_fault
    A333DR_hyd_eng2_yellow_pump_fault = annun_hyd_eng2_yellow_pump_fault

end


--*************************************************************************************--
--** 				                     PROCESSING             	    			 **--
--*************************************************************************************--

--===| INIT ALL |========================================================================
function A333_annun_ac2_init_all()



end




--===| INIT ER |=========================================================================
function A333_annun_ac2_init_ER()



end




--===| INIT CD |=========================================================================
function A333_annun_ac2_init_CD()



end




--===| DEFERRED INITIALIZATION |=========================================================
function A333_annun_ac2_deferred_init()




end



--===| DEFERRED PROCESSING |=============================================================
function A333_annun_ac2_deferred_processing()



end




--=== AIRCRAFT LOAD =====================================================================
function A333_annun_ac2_aircraft_load()



end



--=== FLIGHT START ======================================================================
function A333_annun_ac2_flight_start()



end



--=== BEFORE PHYSICS ====================================================================
function A333_annun_ac2_before_physics()



end



--=== AFTER PHYSICS =====================================================================
function A333_annun_ac2_after_physics()

    A333_annun_ac2_cache_globals()
    A333_toilet_time_processing()
    A333_annun_ac2_processing()
    A333_fws_hyd_pump_fault()

end




--=== FLIGHT CRASH ======================================================================
function A333_annun_ac2_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_annun_ac2_aircraft_unload()



end




--=== AIRCRAFT UNLOAD ===================================================================
function A333_annun_ac2_after_replay()

    A333_annun_ac2_cache_globals()
    A333_toilet_time_processing()
    A333_annun_ac2_processing()
    A333_fws_hyd_pump_fault()

end



--*************************************************************************************--
--** 				                 SUB-SCRIPT LOADING            	     			 **--
--*************************************************************************************--



