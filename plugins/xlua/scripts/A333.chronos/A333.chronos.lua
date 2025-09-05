--[[
*****************************************************************************************
* Program Script Name	:	A333.chronos
*
* Author Name			:	Alex Unruh
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



--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_et_running			= find_dataref("sim/cockpit2/clock_timer/elapsed_running[0]")
simDR_startup_running       = find_dataref("sim/operation/prefs/startup_running")



--*************************************************************************************--
--** 				               FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              FIND CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

A333DR_ET_run_stop_reset_pos			= create_dataref("laminar/A333/clock/ET_run_stop_reset_pos", "number")
A333DR_current_year						= create_dataref("laminar/A333/clock/year", "number")
A333DR_init_chrono_CD					= create_dataref("laminar/A333/init_CD/chrono", "number")

--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--

function A333_ET_run_stop_reset_upCMDhandler(phase, duration)
	if phase == 0 then
		if A333DR_ET_run_stop_reset_pos == 1 then
			A333DR_ET_run_stop_reset_pos = 0
		elseif A333DR_ET_run_stop_reset_pos == 0 then
			if simDR_et_running == 0 then
				simCMD_timer_start_stop:once()
			end
			A333DR_ET_run_stop_reset_pos = -1
		end
	end
end

function A333_ET_run_stop_reset_dnCMDhandler(phase, duration)
	if phase == 0 then
		if A333DR_ET_run_stop_reset_pos == -1 then
			if simDR_et_running == 1 then
				simCMD_timer_start_stop:once()
			end
			A333DR_ET_run_stop_reset_pos = 0
		elseif A333DR_ET_run_stop_reset_pos == 0 then
			simCMD_timer_reset:once()
			A333DR_ET_run_stop_reset_pos = 1
		end
	elseif phase == 2 then
		if A333DR_ET_run_stop_reset_pos == 1 then
			A333DR_ET_run_stop_reset_pos = 0
		end
	end
end


-- AI

function A333_ai_chrono_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	A333_set_chrono_all_modes()
	  	A333_set_chrono_CD()
	  	A333_set_chrono_ER()
	end
end

--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--

A333CMD_ET_run_stop_reset_up		= create_command("laminar/A333/clock/ET_run_stop_reset_up", "RUN / STOP / RESET Up", A333_ET_run_stop_reset_upCMDhandler)
A333CMD_ET_run_stop_reset_dn		= create_command("laminar/A333/clock/ET_run_stop_reset_dn", "RUN / STOP / RESET Down", A333_ET_run_stop_reset_dnCMDhandler)

-- AI

A333CMD_ai_chrono_quick_start		= create_command("laminar/A333/ai/chrono_quick_start", "AI Chrono", A333_ai_chrono_quick_start_CMDhandler)

--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--



function A333_et_reset_beforeCMDhandler(phase, duration) end
function A333_et_reset_afterCMDhandler(phase, duration)
	if phase == 0 then
		if simDR_et_running == 1 then
			simCMD_timer_start_stop:once()
		end
	end
end

function A333_timer_start_stop_beforeCMDhandler(phase, duration) end
function A333_timer_start_stop_afterCMDhandler(phase, duration)
	if phase == 0 then
		if simDR_et_running == 0 then
			A333DR_ET_run_stop_reset_pos = 0
		elseif simDR_et_running == 1 then
			A333DR_ET_run_stop_reset_pos = -1
		end
	end
end

--*************************************************************************************--
--** 				             REPLACE X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--




--*************************************************************************************--
--** 				              WRAP X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--

simCMD_timer_reset					= wrap_command("sim/instruments/elapsed1_reset", A333_et_reset_beforeCMDhandler, A333_et_reset_afterCMDhandler)
simCMD_timer_start_stop				= wrap_command("sim/instruments/elapsed1_start_stop", A333_timer_start_stop_beforeCMDhandler, A333_timer_start_stop_afterCMDhandler)

--*************************************************************************************--
--** 					           OBJECT CONSTRUCTORS         		        		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                  CREATE OBJECTS              	     			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--

--[[SIM_PERIOD - this contains the duration of the current frame in seconds (so it is alway a
fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you’d do fuel = fuel + 3 * SIM_PERIOD.]]--



function A333_chrono_year()

	A333DR_current_year = string.sub(os.date('%Y'), 3, 4)

end










----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function A333_chrono_monitor_AI()

    if A333DR_init_chrono_CD == 1 then
        A333_set_chrono_all_modes()
        A333_set_chrono_CD()
        A333DR_init_chrono_CD = 2
    end

end


----- SET STATE FOR ALL MODES -----------------------------------------------------------
function A333_set_chrono_all_modes()

	A333DR_init_chrono_CD = 0


end


----- SET STATE TO COLD & DARK ----------------------------------------------------------
function A333_set_chrono_CD()


end


----- SET STATE TO ENGINES RUNNING ------------------------------------------------------

function A333_set_chrono_ER()


end


----- FLIGHT START ---------------------------------------------------------------------

function A333_flight_start_chrono()

    -- ALL MODES ------------------------------------------------------------------------
    A333_set_chrono_all_modes()

	if simDR_et_running == 1 then
		simCMD_timer_start_stop:once()
	end
	simCMD_timer_reset:once()
	A333DR_ET_run_stop_reset_pos = 0

    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        A333_set_chrono_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		A333_set_chrono_ER()

    end

end


--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

function A333_ALL_chronos()

	A333_chrono_year()
	A333_chrono_monitor_AI()

end

function aircraft_load()

	A333_flight_start_chrono()

end

--function aircraft_unload() end

--function flight_start() end

--function flight_crash() end

--function before_physics()	end

function after_physics()

	A333_ALL_chronos()

end

function after_replay()

	A333_ALL_chronos()

end




--*************************************************************************************--
--** 				               SUB-MODULE PROCESSING       	        			 **--
--*************************************************************************************--

-- dofile("")



