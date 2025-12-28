--[[
*****************************************************************************************
* Program Script Name	:	A333.systems
* Author Name			:	Jim Gregory
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2025-08-11	0.01				Start of Dev
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
local OPEN = 0
local CLOSED = 1

local OFF = 0
local ON = 1



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local sim_period = 0
local m = math

local num2bool = {[0] = false, [1] = true}
local bool2num = {[true] = 1, [false] = 0}

local ac_min_volts = 0
local dc_min_volts = 0
local on_ground = false
local elec_emer_config_level1 = false
local elec_emer_config_level2 = false
local elec_emer_config = false
local battery_only_supply_on_ground = false
local battery_only_supply_in_flight = false
local batteries_only_supply = false


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
local static_inverter = {}
static_inverter.__index = static_inverter

-- OBJECT CONSTRUCTOR ---------------------------------------------------------
function static_inverter.new(name, id)

    local self = setmetatable({}, static_inverter)

    -- CLASS PROPERTIES -------------------------------------------------------
    self.name = name
    self.id = id

    self.input_volts = 0
    self.volts = 0
    self.amps = 0

    return self

end


-- CLASS METHODS --------------------------------------------------------------
function static_inverter.inputs(self)
    self.input_volts = dc_ess_bus.volts
end




function static_inverter.outputs(self)
    self.volts = tonumber(string.format("%.02f", (self.input_volts * A333DR_elec_dc_ac_inversion_factor)))
end




function static_inverter.update(self)

    self:inputs()
    self:outputs()

end

--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--
inverter = static_inverter.new("stat_inverter", "1XB")



--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--
local function A333_elec_inverter_cache_globals()

    sim_period = SIM_PERIOD

    ac_min_volts = A333DR_ac_min_volts
    dc_min_volts = A333DR_dc_min_volts
    on_ground = num2bool[A333DR_gear_on_ground]
    elec_emer_config = num2bool[A333DR_elec_emer_config]
    elec_emer_config_level1 = num2bool[A333DR_elec_emer_config_level1]
    elec_emer_config_level2 = num2bool[A333DR_elec_emer_config_level2]
    battery_only_supply_on_ground = num2bool[A333DR_batteries_only_supply_on_ground]
    battery_only_supply_in_flight = num2bool[A333DR_batteries_only_supply_in_flight]
    batteries_only_supply = num2bool[A333DR_batteries_only_supply]

end



--*************************************************************************************--
--** 				                     PROCESSING             	    			 **--
--*************************************************************************************--

--===| INIT ALL |========================================================================
function A333_elec_inverter_init_all()



end




--===| INIT ER |=========================================================================
function A333_elec_inverter_init_ER()



end




--===| INIT CD |=========================================================================
function A333_elec_inverter_init_CD()



end




--===| DEFERRED INITIALIZATION |=========================================================
function A333_elec_inverter_deferred_init()




end



--===| DEFERRED PROCESSING |=============================================================
function A333_elec_inverter_deferred_processing()



end




--=== AIRCRAFT LOAD =====================================================================
function A333_elec_inverter_aircraft_load()



end



--=== FLIGHT START ======================================================================
function A333_elec_inverter_flight_start()



end



--=== BEFORE PHYSICS ====================================================================
function A333_elec_inverter_before_physics()



end



--=== AFTER PHYSICS =====================================================================
function A333_elec_inverter_after_physics()

    A333_elec_inverter_cache_globals()

    inverter:update()

end




--=== FLIGHT CRASH ======================================================================
function A333_elec_inverter_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_elec_inverter_aircraft_unload()



end




--=== AIRCRAFT UNLOAD ===================================================================
function A333_elec_inverter_after_replay()

	A333_elec_inverter_cache_globals()

	inverter:update()

end



--*************************************************************************************--
--** 				                 SUB-SCRIPT LOADING            	     			 **--
--*************************************************************************************--



