--[[
*****************************************************************************************
* Script Name:  A333.electrical_emer_gen.lua
*
* Script Description:
*
* Author Name: Jim Gregory
*
* Revisions:
* -- DATE --  --- REV NO ---  --- DESCRIPTION -------------------------------------------
* 10/08/2025                  Initial Development
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
--*************************************************************************************--
local sim_period = 0

local num2bool = {[0] = false, [1] = true}
local bool2num = {[true] = 1, [false] = 0}

local on_ground = false
local elec_emer_config_level1 = false
local elec_emer_config_level2 = false
local elec_emer_config = false
local battery_only_supply_on_ground = false
local battery_only_supply_in_flight = false
local batteries_only_supply = false
local emer_gen_test_button_pos = 0



--*************************************************************************************--
--** 				            LOCAL UTILITY FUNCTIONS          			    	 **--
--*************************************************************************************--



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
local function A333_elec_emer_gen_cache_globals()

    sim_period = SIM_PERIOD
    simDR_override_getting_elec_ADG = 1

    on_ground = num2bool[A333DR_gear_on_ground]
    elec_emer_config = num2bool[A333DR_elec_emer_config]
    elec_emer_config_level1 = num2bool[A333DR_elec_emer_config_level1]
    elec_emer_config_level2 = num2bool[A333DR_elec_emer_config_level2]
    battery_only_supply_on_ground = num2bool[A333DR_batteries_only_supply_on_ground]
    battery_only_supply_in_flight = num2bool[A333DR_batteries_only_supply_in_flight]
    batteries_only_supply = num2bool[A333DR_batteries_only_supply]
    emer_gen_test_button_pos = A333DR_emer_gen_test_button_pos

end




local function A333_emer_gen_gcu_activation()

    local a = (A333DR_trent700_n3_eng1 < 50) and (A333DR_trent700_n3_eng2 < 50)
    local b = (emer_gen_test_button_pos == 1 and (not on_ground)) or (elec_emer_config_level1)
    local c = (emer_gen_test_button_pos == 1 and (not on_ground)) or (not on_ground)
    local m = A333DR_emer_gen_man_on_button_pos == 1
    local s = (simDR_slat1_deploy_ratio > 0) or (simDR_slat2_deploy_ratio > 0)

    local deactivation1 = a and (not c)
    local deactivation2 = a and c and s and b
    local deactivation = deactivation1 or deactivation2

    local activation = ((b and c) or m) and (not deactivation)

    return activation

end



local function A333_emer_gen_on()

    local rat_deployed = A333DR_hyd_rat_actuator_deploy_angle_deg >= A333DR_hyd_rat_actuator_deploy_angle_target_deg

    simDR_RAT_extended = (rat_deployed or A333_emer_gen_gcu_activation()) and 1 or 0
    simDR_elec_emer_gen_on = (A333_emer_gen_gcu_activation() and (simDR_green_hydraulic_pressure > 1450.00)) and 1 or 0

end



--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--


--===| INIT ALL |========================================================================
local function A333_elec_emer_gen_init_all() end



--===| INIT CD |=========================================================================
local function A333_elec_emer_gen_init_CD() end



--===| INIT ER |=========================================================================
local function A333_elec_emer_gen_init_ER() end



--===| DEFERRED INITIALIZATION |=========================================================
function A333_elec_emer_gen_deferred_init() end



--===| DEFERRED PROCESSING |=============================================================
function A333_elec_emer_gen_deferred_processing() end





--=== AIRCRAFT LOAD =====================================================================
function A333_elec_emer_gen_aircraft_load() end



--=== FLIGHT START ======================================================================
function A333_elec_emer_gen_flight_start() end



--=== BEFORE PHYSICS ====================================================================
function A333_elec_emer_gen_before_physics() end



--=== AFTER PHYSICS =====================================================================
function A333_elec_emer_gen_after_physics()

    A333_elec_emer_gen_cache_globals()
    A333_emer_gen_gcu_activation()
    A333_emer_gen_on()

end




--=== FLIGHT CRASH ======================================================================
function A333_elec_emer_gen_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_elec_emer_gen_aircraft_unload()

    simDR_override_getting_elec_ADG = 0

end




--=== AFTER REPLAY ==================================---=================================
function A333_elec_emer_gen_after_replay()

    A333_elec_emer_gen_cache_globals()
    A333_emer_gen_gcu_activation()
    A333_emer_gen_on()

end
