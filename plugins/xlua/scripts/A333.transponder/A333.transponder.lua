--[[
*****************************************************************************************
* Program Script Name	:	A333.switches
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


--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--

local transponder_accel_timer = 0
local transponder_decel_timer = 0
local TA_mode_ground = 0
local startup_timer = 0
local fail_index = 0 -- 0 = none, 1 = ATC1 FAIL, 2 = ATC2 FAIL, 3 = ALL FAIL
local clear_timer = 0
local saved_code = 0

--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
simDR_startup_running               = find_dataref("sim/operation/prefs/startup_running")
simDR_transponder_modes				= find_dataref("sim/cockpit2/radios/actuators/transponder_mode")
simDR_gear_on_ground				= find_dataref("sim/flightmodel2/gear/on_ground[1]")

simDR_rad_alt_capt					= find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_pilot")
simDR_rad_alt_fo					= find_dataref("sim/cockpit2/gauges/indicators/radio_altimeter_height_ft_copilot")
simDR_airspeed_capt					= find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
simDR_airspeed_fo					= find_dataref("sim/cockpit2/gauges/indicators/airspeed_kts_copilot")
simDR_windshear_alert				= find_dataref("sim/cockpit2/annunciators/windshear_warning_systems") -- 0 = no warning, 1 = predictive advisory, 2 = predictive caution, 3 = predictive warning t/o, 4 = predictive warning approach, 5 = reactive warning
simDR_GPWS_alert					= find_dataref("sim/cockpit2/annunciators/GPWS")

simDR_tcas_fail						= find_dataref("sim/operation/failures/rel_xpndr")
simDR_xponder_code					= find_dataref("sim/cockpit2/radios/actuators/transponder_code")

-- (off=0, stdby=1, on (mode A)=2, alt (mode C)=3, test=4, GND (mode S)=5, ta_only (mode S)=6, ta/ra=7)

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

A333DR_stall_warn					= find_dataref("laminar/A333/fws/aco_stall")
A333DR_ac_bus1_has_power			= find_dataref("laminar/A333/elec/ac_bus1_has_power")

--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
A333_transponder0_pos				= create_dataref("laminar/A333/transponder/0_pos", "number")
A333_transponder1_pos				= create_dataref("laminar/A333/transponder/1_pos", "number")
A333_transponder2_pos				= create_dataref("laminar/A333/transponder/2_pos", "number")
A333_transponder3_pos				= create_dataref("laminar/A333/transponder/3_pos", "number")
A333_transponder4_pos				= create_dataref("laminar/A333/transponder/4_pos", "number")
A333_transponder5_pos				= create_dataref("laminar/A333/transponder/5_pos", "number")
A333_transponder6_pos				= create_dataref("laminar/A333/transponder/6_pos", "number")
A333_transponder7_pos				= create_dataref("laminar/A333/transponder/7_pos", "number")
A333_transponderCLR_pos				= create_dataref("laminar/A333/transponder/CLR_pos", "number")
A333_transponder_ident_pos			= create_dataref("laminar/A333/transponder/ident_pos", "number")

A333_transponder_auto_on_off_pos	= create_dataref("laminar/A333/transponder/auto_on_knob_pos", "number")
A333_transponder_alt_rpt_pos		= create_dataref("laminar/A333/transponder/alt_rpt_knob_pos", "number")
A333_transponder_atc12_pos			= create_dataref("laminar/A333/transponder/atc12_knob_pos", "number")
A333_transponder_ta_ra_pos			= create_dataref("laminar/A333/transponder/ta_ra_knob_pos", "number")
A333_transponder_thrt_all_abv_blw	= create_dataref("laminar/A333/transponder/thrt_all_abv_blw_pos", "number")

A333_tcas_startup					= create_dataref("laminar/A333/PFD/TCAS_startup", "number")
A333_failure_flag					= create_dataref("laminar/A333/transponder/failure_flag", "number") -- 0 = all working, 1 = 1 fail, 2 = 2 fail, 3 = all fail

A333_digits_showing					= create_dataref("laminar/A333/transponder/digits_showing", "number")

----- AI --------------------------------------------------------------------------------
A333DR_init_transponder_CD           	= create_dataref("laminar/A333/init_CD/transponder", "number")

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
function simCMD_trans0_beforeCMDhandler(phase, duration) end
function simCMD_trans0_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder0_pos = 1
		if A333_digits_showing < 4 then
			A333_digits_showing = A333_digits_showing + 1
			clear_timer = 0
		end
	elseif phase == 2 then
		A333_transponder0_pos = 0
	end
end

function simCMD_trans1_beforeCMDhandler(phase, duration) end
function simCMD_trans1_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder1_pos = 1
		if A333_digits_showing < 4 then
			A333_digits_showing = A333_digits_showing + 1
			clear_timer = 0
		end
	elseif phase == 2 then
		A333_transponder1_pos = 0
	end
end

function simCMD_trans2_beforeCMDhandler(phase, duration) end
function simCMD_trans2_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder2_pos = 1
		if A333_digits_showing < 4 then
			A333_digits_showing = A333_digits_showing + 1
			clear_timer = 0
		end
	elseif phase == 2 then
		A333_transponder2_pos = 0
	end
end

function simCMD_trans3_beforeCMDhandler(phase, duration) end
function simCMD_trans3_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder3_pos = 1
		if A333_digits_showing < 4 then
			A333_digits_showing = A333_digits_showing + 1
			clear_timer = 0
		end
	elseif phase == 2 then
		A333_transponder3_pos = 0
	end
end

function simCMD_trans4_beforeCMDhandler(phase, duration) end
function simCMD_trans4_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder4_pos = 1
		if A333_digits_showing < 4 then
			A333_digits_showing = A333_digits_showing + 1
			clear_timer = 0
		end
	elseif phase == 2 then
		A333_transponder4_pos = 0
	end
end

function simCMD_trans5_beforeCMDhandler(phase, duration) end
function simCMD_trans5_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder5_pos = 1
		if A333_digits_showing < 4 then
			A333_digits_showing = A333_digits_showing + 1
			clear_timer = 0
		end
	elseif phase == 2 then
		A333_transponder5_pos = 0
	end
end

function simCMD_trans6_beforeCMDhandler(phase, duration) end
function simCMD_trans6_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder6_pos = 1
		if A333_digits_showing < 4 then
			A333_digits_showing = A333_digits_showing + 1
			clear_timer = 0
		end
	elseif phase == 2 then
		A333_transponder6_pos = 0
	end
end

function simCMD_trans7_beforeCMDhandler(phase, duration) end
function simCMD_trans7_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder7_pos = 1
		if A333_digits_showing < 4 then
			A333_digits_showing = A333_digits_showing + 1
			clear_timer = 0
		end
	elseif phase == 2 then
		A333_transponder7_pos = 0
	end
end

function simCMD_transCLR_beforeCMDhandler(phase, duration) end
function simCMD_transCLR_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponderCLR_pos = 1
		saved_code = simDR_xponder_code
		A333_digits_showing = 0
		clear_timer = 0
	elseif phase == 2 then
		A333_transponderCLR_pos = 0
	end
end

function simCMD_trans_ident_beforeCMDhandler(phase, duration) end
function simCMD_trans_ident_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder_ident_pos = 1
	elseif phase == 2 then
		A333_transponder_ident_pos = 0
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
simCMD_transponder_0		= wrap_command("sim/transponder/transponder_digit_0", simCMD_trans0_beforeCMDhandler, simCMD_trans0_afterCMDhandler)
simCMD_transponder_1		= wrap_command("sim/transponder/transponder_digit_1", simCMD_trans1_beforeCMDhandler, simCMD_trans1_afterCMDhandler)
simCMD_transponder_2		= wrap_command("sim/transponder/transponder_digit_2", simCMD_trans2_beforeCMDhandler, simCMD_trans2_afterCMDhandler)
simCMD_transponder_3		= wrap_command("sim/transponder/transponder_digit_3", simCMD_trans3_beforeCMDhandler, simCMD_trans3_afterCMDhandler)
simCMD_transponder_4		= wrap_command("sim/transponder/transponder_digit_4", simCMD_trans4_beforeCMDhandler, simCMD_trans4_afterCMDhandler)
simCMD_transponder_5		= wrap_command("sim/transponder/transponder_digit_5", simCMD_trans5_beforeCMDhandler, simCMD_trans5_afterCMDhandler)
simCMD_transponder_6		= wrap_command("sim/transponder/transponder_digit_6", simCMD_trans6_beforeCMDhandler, simCMD_trans6_afterCMDhandler)
simCMD_transponder_7		= wrap_command("sim/transponder/transponder_digit_7", simCMD_trans7_beforeCMDhandler, simCMD_trans7_afterCMDhandler)
simCMD_transponder_CLR		= wrap_command("sim/transponder/transponder_CLR", simCMD_transCLR_beforeCMDhandler, simCMD_transCLR_afterCMDhandler)

simCMD_transponder_ident	= wrap_command("sim/transponder/transponder_ident", simCMD_trans_ident_beforeCMDhandler, simCMD_trans_ident_afterCMDhandler)



--*************************************************************************************--
--** 				               FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--


--*************************************************************************************--
--** 				              CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--
function A333_trans_auto_on_off_left_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_transponder_auto_on_off_pos == 1 then
			A333_transponder_auto_on_off_pos = 0
		elseif A333_transponder_auto_on_off_pos == 0 then
			A333_transponder_auto_on_off_pos = -1
		end
	end
end

function A333_trans_auto_on_off_right_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_transponder_auto_on_off_pos == -1 then
			A333_transponder_auto_on_off_pos = 0
		elseif A333_transponder_auto_on_off_pos == 0 then
			A333_transponder_auto_on_off_pos = 1
		end
	end
end

function A333_trans_alt_rpt_off_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_transponder_alt_rpt_pos == 1 then
			A333_transponder_alt_rpt_pos = 0
		end
	end
end

function A333_trans_alt_rpt_on_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_transponder_alt_rpt_pos == 0 then
			A333_transponder_alt_rpt_pos = 1
		end
	end
end

function A333_transponder_atc1_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_transponder_atc12_pos == 1 then
			A333_transponder_atc12_pos = 0
			if fail_index == 1 or fail_index == 3 then
				simDR_tcas_fail = 6
			else simDR_tcas_fail = 0
			end
		end
	end
end

function A333_transponder_atc2_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_transponder_atc12_pos == 0 then
			A333_transponder_atc12_pos = 1
			if fail_index == 2 or fail_index == 3 then
				simDR_tcas_fail = 6
			else simDR_tcas_fail = 0
			end
		end
	end
end

function A333_trans_ta_ra_left_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_transponder_ta_ra_pos == 2 then
			A333_transponder_ta_ra_pos = 1
		elseif A333_transponder_ta_ra_pos == 1 then
			A333_transponder_ta_ra_pos = 0
		end
	end
end

function A333_trans_ta_ra_right_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_transponder_ta_ra_pos == 0 then
			A333_transponder_ta_ra_pos = 1
		elseif A333_transponder_ta_ra_pos == 1 then
			A333_transponder_ta_ra_pos = 2
		end
	end
end

function A333_trans_thrt_all_abv_blw_l_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_transponder_thrt_all_abv_blw == 3 then
			A333_transponder_thrt_all_abv_blw = 2
		elseif A333_transponder_thrt_all_abv_blw == 2 then
			A333_transponder_thrt_all_abv_blw = 1
		elseif A333_transponder_thrt_all_abv_blw == 1 then
			A333_transponder_thrt_all_abv_blw = 0
		end
	end
end

function A333_trans_thrt_all_abv_blw_r_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_transponder_thrt_all_abv_blw == 0 then
			A333_transponder_thrt_all_abv_blw = 1
		elseif A333_transponder_thrt_all_abv_blw == 1 then
			A333_transponder_thrt_all_abv_blw = 2
		elseif A333_transponder_thrt_all_abv_blw == 2 then
			A333_transponder_thrt_all_abv_blw = 3
		end
	end
end



-- AI
function A333_ai_transponder_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	A333_set_transponder_all_modes()
	  	A333_set_transponder_CD()
	  	A333_set_transponder_ER()
	end
end



--*************************************************************************************--
--** 				                 CUSTOM COMMANDS                			     **--
--*************************************************************************************--
A333CMD_trans_auto_on_off_left		= create_command("laminar/A333/transponder/auto_on_off_left", "Transponder AUTO ON OFF knob Left", A333_trans_auto_on_off_left_CMDhandler)
A333CMD_trans_auto_on_off_right		= create_command("laminar/A333/transponder/auto_on_off_right", "Transponder AUTO ON OFF knob Right", A333_trans_auto_on_off_right_CMDhandler)

A333CMD_trans_alt_rpt_off			= create_command("laminar/A333/transponder/alt_rpt_off", "Transponder Altitude Reporting Off", A333_trans_alt_rpt_off_CMDhandler)
A333CMD_trans_alt_rpt_on			= create_command("laminar/A333/transponder/alt_rpt_on", "Transponder Altitude Reporting On", A333_trans_alt_rpt_on_CMDhandler)

A333CMD_transponder_atc1			= create_command("laminar/A333/transponder/atc1", "Transponder ATC 1", A333_transponder_atc1_CMDhandler)
A333CMD_transponder_atc2			= create_command("laminar/A333/transponder/atc2", "Transponder ATC 2", A333_transponder_atc2_CMDhandler)

A333CMD_trans_ta_ra_left			= create_command("laminar/A333/transponder/ta_ra_left", "Transponder STBY TA TA/RA Mode Left", A333_trans_ta_ra_left_CMDhandler)
A333CMD_trans_ta_ra_right			= create_command("laminar/A333/transponder/ta_ra_right", "Transponder STBY TA TA/RA Mode Right", A333_trans_ta_ra_right_CMDhandler)

A333CMD_trans_thrt_all_abv_blw_l	= create_command("laminar/A333/transponder/thrt_all_abv_blw_left", "TCAS Mode Threat ALL Above Below Left", A333_trans_thrt_all_abv_blw_l_CMDhandler)
A333CMD_trans_thrt_all_abv_blw_r	= create_command("laminar/A333/transponder/thrt_all_abv_blw_right", "TCAS Mode Threat ALL Above Below Right", A333_trans_thrt_all_abv_blw_r_CMDhandler)




-- AI
A333CMD_ai_transponder_quick_start	= create_command("laminar/A333/ai/transponder_quick_start", "AI Transponder", A333_ai_transponder_quick_start_CMDhandler)



--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--
local function A333_transponder_mode_switching()

	local transponder_auto_on_off_pos = A333_transponder_auto_on_off_pos
	local ac1_powered = A333DR_ac_bus1_has_power
	local gear_on_ground = simDR_gear_on_ground
	local transponder_alt_rpt_pos = A333_transponder_alt_rpt_pos
	local transponder_ta_ra_pos = A333_transponder_ta_ra_pos

	local TA_reversion = 0
	local airspeed = 0
	local altitude = 0
	
	if A333_transponder_atc12_pos == 0 then
		airspeed = simDR_airspeed_capt
		altitude = simDR_rad_alt_capt
	else airspeed = simDR_airspeed_fo
		altitude = simDR_rad_alt_fo
	end


	if airspeed > 15 then
		if transponder_accel_timer < 10 then
			transponder_accel_timer = transponder_accel_timer + SIM_PERIOD
		elseif transponder_accel_timer >= 10 then
			transponder_accel_timer = 10
			TA_mode_ground = 1
		end
	elseif airspeed <= 15 then
		transponder_accel_timer = 0
	end

	if airspeed < 15 then
		if transponder_decel_timer < 10 then
			transponder_decel_timer = transponder_decel_timer + SIM_PERIOD
		elseif transponder_decel_timer >= 10 then
			transponder_decel_timer = 10
			TA_mode_ground = 0
		end
	elseif airspeed >= 15 then
		transponder_decel_timer = 0
	end

		
	if altitude > 1000 and TA_mode_ground == 1 and A333DR_stall_warn == 0 and simDR_windshear_alert < 3 and simDR_GPWS_alert == 0 then
		TA_reversion = 0
	else TA_reversion = 1
	end

-- (off=0, stdby=1, on (mode A)=2, alt (mode C)=3, test=4, GND (mode S)=5, ta_only (mode S)=6, ta/ra=7)

	
	if simDR_tcas_fail == 6 then
		simDR_transponder_modes	= 0
	else


	if transponder_auto_on_off_pos == -1 then
		if ac1_powered == 0 then
			simDR_transponder_modes	= 0
		else simDR_transponder_modes = 1
		end
	elseif transponder_auto_on_off_pos == 0 then
		if ac1_powered == 0 then
			simDR_transponder_modes	= 0
		else
		
			if gear_on_ground == 1 then
				if transponder_ta_ra_pos == 0 then
					simDR_transponder_modes	= 1
				else 
					if TA_mode_ground == 0 then
						simDR_transponder_modes = 5
					else simDR_transponder_modes = 6
					end
				end
			elseif gear_on_ground == 0 then
				if transponder_alt_rpt_pos == 0 then
					if transponder_ta_ra_pos == 0 then
						simDR_transponder_modes	= 1
					else simDR_transponder_modes = 2
					end
				elseif transponder_alt_rpt_pos == 1 then
					if transponder_ta_ra_pos == 0 then
						simDR_transponder_modes	= 1
					elseif transponder_ta_ra_pos == 1 then
						simDR_transponder_modes	= 6
					elseif transponder_ta_ra_pos == 2 then
						simDR_transponder_modes	= (7 - TA_reversion)
					end
				end
			end
			
		end
		
	elseif transponder_auto_on_off_pos == 1 then
		if ac1_powered == 0 then
			simDR_transponder_modes	= 0
		else
		
			if transponder_alt_rpt_pos == 0 then
				if transponder_ta_ra_pos == 0 then
					simDR_transponder_modes	= 1
				else simDR_transponder_modes = 2
				end
			elseif transponder_alt_rpt_pos == 1 then
				if transponder_ta_ra_pos == 0 then
					simDR_transponder_modes	= 1
				elseif transponder_ta_ra_pos == 1 then
					simDR_transponder_modes	= 6
				elseif transponder_ta_ra_pos == 2 then
					simDR_transponder_modes	= (7 - TA_reversion)
				end
			end

		end
	end

	end

end

local function A333_transponder_startup()

	if simDR_transponder_modes >= 1 then
		if startup_timer < 3 then
			startup_timer = startup_timer + SIM_PERIOD
		else startup_timer = 3
		end
	elseif simDR_transponder_modes == 0 then
		startup_timer = 0
	end
	
	A333_tcas_startup = (startup_timer >= 3 and 1) or 0
	
end


local function A333_transponder_switching_fail_handler()


	if fail_index == 0 then

		if simDR_tcas_fail == 6 then
			if A333_transponder_atc12_pos == 0 then
				fail_index = 1
			elseif A333_transponder_atc12_pos == 1 then
				fail_index = 2
			end
		end
		
	elseif fail_index == 1 then
		if A333_transponder_atc12_pos == 1 and simDR_tcas_fail == 6 then
			fail_index = 3
		end
		if A333_transponder_atc12_pos == 0 and simDR_tcas_fail == 0 then
			fail_index = 0
		end
		
		
	elseif fail_index == 2 then
		if A333_transponder_atc12_pos == 0 and simDR_tcas_fail == 6 then
			fail_index = 3
		end
		if A333_transponder_atc12_pos == 1 and simDR_tcas_fail == 0 then
			fail_index = 0
		end

	elseif fail_index == 3 then
		if A333_transponder_atc12_pos == 0 and simDR_tcas_fail == 0 then
			fail_index = 2
		elseif A333_transponder_atc12_pos == 1 and simDR_tcas_fail == 0 then
			fail_index = 1
		end
		
	end

	A333_failure_flag = fail_index

end

local function A333_clear_key_timer()

	if A333_digits_showing < 4 then
		clear_timer = clear_timer + SIM_PERIOD
	end
	
	if clear_timer > 10 then
		A333_digits_showing = 4
		simDR_xponder_code = saved_code
		clear_timer = 0
	end



end


----- SET STATE TO COLD & DARK ----------------------------------------------------------
local function A333_set_transponder_CD()

	A333_transponder_auto_on_off_pos = -1
	A333_transponder_atc12_pos = 0
	A333_transponder_alt_rpt_pos = 1

	A333_transponder_thrt_all_abv_blw = 0
	A333_transponder_ta_ra_pos = 0

end




----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
local function A333_set_transponder_ER()

	A333_transponder_auto_on_off_pos = 0
	A333_transponder_atc12_pos = 0
	A333_transponder_alt_rpt_pos = 1

	A333_transponder_thrt_all_abv_blw = 0
	A333_transponder_ta_ra_pos = 2

end




----- SET STATE FOR ALL MODES -----------------------------------------------------------
local function A333_set_transponder_all_modes()

	A333DR_init_transponder_CD = 0

end




----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
local function A333_transponder_monitor_AI()

	if A333DR_init_transponder_CD == 1 then
		A333_set_transponder_all_modes()
		A333_set_transponder_CD()
		A333DR_init_transponder_CD = 2
	end

end




----- FLIGHT START ---------------------------------------------------------------------
local function A333_flight_start_transponder()

    -- ALL MODES ------------------------------------------------------------------------
    A333_set_transponder_all_modes()

	A333_digits_showing = 4

    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        A333_set_transponder_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		A333_set_transponder_ER()
		startup_timer = 3

    end

end




local function A333_ALL_transponder()

	A333_transponder_monitor_AI()
	A333_transponder_mode_switching()
	A333_transponder_startup()
	A333_transponder_switching_fail_handler()
	A333_clear_key_timer()

end



--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--
--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

	A333_flight_start_transponder()

end

--function flight_crash() end

--function before_physics()

function after_physics()

	A333_ALL_transponder()

end

function after_replay()

	A333_ALL_transponder()

end



