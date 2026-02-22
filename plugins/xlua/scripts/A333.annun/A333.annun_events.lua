--[[
*****************************************************************************************
* Program Script Name	:	A333.annun_events
* Author Name			:	Jim Gregory
*
* Author Name: Jim Gregory
*
* Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2025-08-29	0.01				Start of Dev
*
*
*
*
*****************************************************************************************
*       						   COPYRIGHT © 2022
*					 	   L A M I N A R   R E S E A R C H
*								  ALL RIGHTS RESERVED
*****************************************************************************************
--]]


--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--[[

SIM_PERIOD: this contains the duration of the current frame in seconds (so it is always
a fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you would do fuel = fuel + 3 * SIM_PERIOD.


IN_REPLAY: evaluates to 0 if replay is off, 1 if replay mode is on

--]]


--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************local --


--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				             FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				             FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				             FIND CUSTOM COMMANDS								**--
--*************************************************************************************--


--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--


--*************************************************************************************--
--** 				  CREATE READ-WRITE CUSTOM DATAREFS & HANDLERS                   **--
--*************************************************************************************--


--*************************************************************************************--
--** 				        CREATE CUSTOM COMMANDS & HANDLERS					     **--
--*************************************************************************************--


--*************************************************************************************--
--** 				      X-PLANE 'FILTER' COMMANDS & HANDLERS            			 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				       X-PLANE 'WRAP' COMMANDS & HANDLERS               	     **--
--*************************************************************************************--


--*************************************************************************************--
--** 				     X-PLANE 'REPLACE' COMMANDS & HANDLERS              	  	 **--
--*************************************************************************************--

--*************************************************************************************--
--** 					          OBJECT CONSTRUCTORS         		        		 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                 CREATE OBJECTS              	     			 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				              FUNCTION DEFINITIONS         	    				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--
local function A333_annun_init_all()

    A333DR_init_annun_CD = 0

end




local function A333_annun_init_ER()



end




local function A333_annun_init_CD()



end




--===| MONITOR AI FOR AUTO-BOARD CALL |==================================================
local function A333_annun_monitor_AI()

    if A333DR_init_annun_CD == 1 then
        A333_annun_init_all()
        A333_annun_init_CD()
        A333DR_init_annun_CD = 2
    end

end





--===| FLIGHT START COLD & DARK |========================================================
local function A333_elec_flight_start_CD()

    A333_annun_init_CD()

end



--===| FLIGHT START ENGINES RUNNING |====================================================
local function A333_elec_flight_start_ER()

    A333_annun_init_ER()

end



--===| DEFERRED INITIALIZATION |=========================================================
local function A333_annun_deferred_init()




end



--===| DEFERRED PROCESSING |=============================================================
local function A333_annun_deferred_processing()

    if deferred_processing then

        -- do stuff




    end

end




local function A333_annun_flight_start()




end




local function A333_annun_processing()

    A333_annun_monitor_AI()

    A333_annun_data_after_physics()
    A333_annun_ac1_after_physics()
    A333_annun_ac2_after_physics()
    A333_annun_ac_ess_after_physics()
    A333_annun_ac_ess_shed_after_physics()
    A333_annun_ac_ess_grnd_after_physics()
    A333_annun_ac_ess_land_rcvry_after_physics()
    A333_annun_dc_bat_after_physics()

end



local function A333_annun_replay_processing()

    A333_annun_data_after_physics()
    A333_annun_ac1_after_physics()
    A333_annun_ac2_after_physics()
    A333_annun_ac_ess_after_physics()
    A333_annun_ac_ess_shed_physics()

end



--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--

--===| AIRCRAFT LOAD |===================================================================
--function aircraft_load() end



--===| FLIGHT START |====================================================================
function flight_start()

    A333_annun_flight_start()

    if simDR_startup_running == 0 then A333_annun_flight_start_CD() end
    if simDR_startup_running == 1 then A333_annun_flight_start_ER() end
    run_after_time(A333_annun_deferred_init, 2.0)
    run_after_time(function() deferred_processing = true end, 3.0)

end



--===| BEFORE PHYSICS |==================================================================
-- function before_physics() end



--===| AFTER PHYSICS |===================================================================
function after_physics()

    lcl_SIM_PERIOD = SIM_PERIOD

    A333_annun_processing()
    A333_annun_deferred_processing()

end


--===| AFTER REPLAY |====================================================================
function after_replay()

    lcl_SIM_PERIOD = SIM_PERIOD

	A333_annun_processing()
	A333_annun_deferred_processing()

end



--===| FLIGHT CRASH |====================================================================
-- function flight_crash() end



--===| AIRCRAFT UNLOAD |=================================================================
--function aircraft_unload() --end










