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


local

--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_startup_running               = find_dataref("sim/operation/prefs/startup_running")
simDR_transponder_modes				= find_dataref("sim/cockpit2/radios/actuators/transponder_mode")
simDR_gear_on_ground				= find_dataref("sim/flightmodel2/gear/on_ground[1]")
simDR_bus1_volts					= find_dataref("sim/cockpit2/electrical/bus_volts[0]")
simDR_bus2_volts					= find_dataref("sim/cockpit2/electrical/bus_volts[1]")

-- (off=0, stdby=1, on (mode A)=2, alt (mode C)=3, test=4, GND (mode S)=5, ta_only (mode S)=6, ta/ra=7)

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--


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
	elseif phase == 2 then
		A333_transponder0_pos = 0
	end
end

function simCMD_trans1_beforeCMDhandler(phase, duration) end
function simCMD_trans1_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder1_pos = 1
	elseif phase == 2 then
		A333_transponder1_pos = 0
	end
end

function simCMD_trans2_beforeCMDhandler(phase, duration) end
function simCMD_trans2_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder2_pos = 1
	elseif phase == 2 then
		A333_transponder2_pos = 0
	end
end

function simCMD_trans3_beforeCMDhandler(phase, duration) end
function simCMD_trans3_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder3_pos = 1
	elseif phase == 2 then
		A333_transponder3_pos = 0
	end
end

function simCMD_trans4_beforeCMDhandler(phase, duration) end
function simCMD_trans4_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder4_pos = 1
	elseif phase == 2 then
		A333_transponder4_pos = 0
	end
end

function simCMD_trans5_beforeCMDhandler(phase, duration) end
function simCMD_trans5_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder5_pos = 1
	elseif phase == 2 then
		A333_transponder5_pos = 0
	end
end

function simCMD_trans6_beforeCMDhandler(phase, duration) end
function simCMD_trans6_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder6_pos = 1
	elseif phase == 2 then
		A333_transponder6_pos = 0
	end
end

function simCMD_trans7_beforeCMDhandler(phase, duration) end
function simCMD_trans7_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponder7_pos = 1
	elseif phase == 2 then
		A333_transponder7_pos = 0
	end
end

function simCMD_transCLR_beforeCMDhandler(phase, duration) end
function simCMD_transCLR_afterCMDhandler(phase, duration)
	if phase == 0 then
		A333_transponderCLR_pos = 1
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
		end
	end
end

function A333_transponder_atc2_CMDhandler(phase, duration)
	if phase == 0 then
		if A333_transponder_atc12_pos == 0 then
			A333_transponder_atc12_pos = 1
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


function A333_transponder_mode_switching()


-- (off=0, stdby=1, on (mode A)=2, alt (mode C)=3, test=4, GND (mode S)=5, ta_only (mode S)=6, ta/ra=7)

	if A333_transponder_auto_on_off_pos == -1 then
		simDR_transponder_modes	= 1
	elseif A333_transponder_auto_on_off_pos == 0 then
		if simDR_bus1_volts < 5 and simDR_bus2_volts < 5 then
			simDR_transponder_modes	= 0
		elseif simDR_bus1_volts >= 5 and simDR_bus2_volts >= 5 then
			if simDR_gear_on_ground == 1 then
				simDR_transponder_modes	= 5
			elseif simDR_gear_on_ground == 0 then
				if A333_transponder_alt_rpt_pos == 0 then
					simDR_transponder_modes	= 2
				elseif A333_transponder_alt_rpt_pos == 1 then
					if A333_transponder_ta_ra_pos == 0 then
						simDR_transponder_modes	= 3
					elseif A333_transponder_ta_ra_pos == 1 then
						simDR_transponder_modes	= 6
					elseif A333_transponder_ta_ra_pos == 2 then
						simDR_transponder_modes	= 7
					end
				end
			end
		end
	elseif A333_transponder_auto_on_off_pos == 1 then
		if A333_transponder_alt_rpt_pos == 0 then
			simDR_transponder_modes	= 2
		elseif A333_transponder_alt_rpt_pos == 1 then
			if A333_transponder_ta_ra_pos == 0 then
				simDR_transponder_modes	= 3
			elseif A333_transponder_ta_ra_pos == 1 then
				simDR_transponder_modes	= 6
			elseif A333_transponder_ta_ra_pos == 2 then
				simDR_transponder_modes	= 7
			end
		end
	end

end

----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function A333_transponder_monitor_AI()

    if A333DR_init_transponder_CD == 1 then
        A333_set_transponder_all_modes()
        A333_set_transponder_CD()
        A333DR_init_transponder_CD = 2
    end

end


----- SET STATE FOR ALL MODES -----------------------------------------------------------
function A333_set_transponder_all_modes()

	A333DR_init_transponder_CD = 0


end


----- SET STATE TO COLD & DARK ----------------------------------------------------------
function A333_set_transponder_CD()

	A333_transponder_auto_on_off_pos = -1
	A333_transponder_atc12_pos = 0
	A333_transponder_alt_rpt_pos = 0

	A333_transponder_thrt_all_abv_blw = 0
	A333_transponder_ta_ra_pos = 0

end


----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
function A333_set_transponder_ER()

	A333_transponder_auto_on_off_pos = 0
	A333_transponder_atc12_pos = 0
	A333_transponder_alt_rpt_pos = 1

	A333_transponder_thrt_all_abv_blw = 0
	A333_transponder_ta_ra_pos = 2

end


----- FLIGHT START ---------------------------------------------------------------------
function A333_flight_start_transponder()

    -- ALL MODES ------------------------------------------------------------------------
    A333_set_transponder_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        A333_set_transponder_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		A333_set_transponder_ER()

    end

end


--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

function A333_ALL_transponder()

	A333_transponder_monitor_AI()
	A333_transponder_mode_switching()

end

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



