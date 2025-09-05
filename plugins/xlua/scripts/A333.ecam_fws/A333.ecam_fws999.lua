jit.off()
jit.off()
--[[
*****************************************************************************************
* Script Name :	A333.ecam_fws99.lua		(Event Processing)
* Process: FWS Event Processing
*
* Author Name :	Jim Gregory
*
* Revisions:
* -- DATE --  --- REV NO ---  --- DESCRIPTION -------------------------------------------
*
*
*
*
*
*****************************************************************************************
*       					     COPYRIGHT © 2021, 2022
*					 	   L A M I N A R   R E S E A R C H
*								  ALL RIGHTS RESERVED
*****************************************************************************************
--]]

--print("LOAD: A333.ecam_fws999.lua")

--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--

local deferred_processing = 0


--*************************************************************************************--
--** 				              FUNCTION DEFINITIONS         	    				 **--
--*************************************************************************************--

function A333_deferred_init()
	deferred_processing = 1
end



----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function A333_fws_autoboard_init()

	if A333_ai_init_fws == 1 then

		A333_fws_init_all_modes()
		A333_fws_init_CD()

		A333_ai_init_fws = 2

	end

end



----- SET STATE FOR ALL MODES -----------------------------------------------------------
function A333_fws_init_all_modes()



end



----- SET STATE TO COLD & DARK ----------------------------------------------------------
function A333_fws_init_CD()



end



----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
function A333_fws_init_ER()

	A333_fws_210_init_ER()
	A333_fws_300_init_ER()

end



--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--

function aircraft_load()

	A333_fws_210_aircraft_load()

end


function aircraft_unload() end


function flight_start()

	A333_fws_init_all_modes()
	if simDR_startup_running == 0 then A333_fws_init_CD() end
	if simDR_startup_running == 1 then A333_fws_init_ER() end

	run_after_time(A333_deferred_init, 5.0)

	A333_fws_210_flight_start()
	A333_fws_300_flight_start()

	simDR_plugin_master_warning = 0
	simDR_plugin_master_caution = 0

end


function flight_crash() end


function before_physics() end


function after_physics()

	A333_fws_200()	-- GLOBAL VARIABLE ASSIGNMENT
	A333_fws_210()	-- GENERAL DATA
	A333_fws_220()	-- ECP PUSHBUTTON SIGNALS
	A333_fws_250()	-- ECP CLR PROCESSING
	A333_fws_255()	-- ECP RCL PROCESSING
	A333_fws_270()	-- ECP STS PROCESSING
	A333_fws_290()	-- MW/MC PROCESSING

	A333_fws_300()	-- WARNING MESSAGE TRIGGER (INPUT) PROCESSING
	A333_fws_320()	-- WARNING MONITOR (OUTPUT) PROCESSING
	A333_fws_370()	-- STATUS MESSAGE TRIGGER (INPUT) PROCESSING
	A333_fws_380()	-- STATUS MESSAGE TRIGGER (INPUT) PROCESSING

	A333_fws_400()	-- NORMAL (AUTO FLIGHT PHASE) SYSTEM PAGE SELECTOR
	A333_fws_410()	-- ECP MANUAL SYSTEM PAGE SELECTOR
	A333_fws_420()	-- ADVISORY SYSTEM PAGE SELECTOR					-- TODO: NOT YET IMPLEMENTED
	A333_fws_430()	-- FAILURE SYSTEM PAGE SELECTOR
	A333_fws_470()	-- STATUS SYSTEM PAGE SELECTOR
	A333_fws_490()	-- SYSTEM PAGE MANAGER

	A333_fws_500()	-- WARNING MESSAGE ACTION FUNCTIONS
	A333_fws_510()	-- WARNING MESSAGE CUE

	A333_fws_600()	-- STATUS PAGE MESSAGE ACTION FUNCTIONS
	A333_fws_610()	-- STATUS MESSAGE CUE

	A333_fws_700()	-- ALTITUDE CALL OUT AUDIO PROCESSING
	A333_fws_710() 	-- AURAL ALERT AUDIO PROCESSING

	A333_fws_800()	-- ENGINE/WARNING GENERIC INSTRUMENTS
	A333_fws_810()	-- STATUS GENERIC INSTRUMENTS


	-- DEFER TO ALLOW DATAREFS TO STABILIZE
	if deferred_processing == 1 then
		A333_fws_210_deferred()
	end

end


function after_replay()
	A333_fws_200()
	A333_fws_210()
end





--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







