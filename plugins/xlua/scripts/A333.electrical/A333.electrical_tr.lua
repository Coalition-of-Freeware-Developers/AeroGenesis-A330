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





local tr_data = {
    ["tr1"] = { volts_in=0,  amps_in = 0},
    ["tr2"] = { volts_in=0,  amps_in = 0},
    ["ess_tr"] = { volts_in=0,  amps_in = 0},
    ["apu_tr"] = { volts_in=0,  amps_in = 0}
}




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
local transformer_rectifier = {}
transformer_rectifier.__index = transformer_rectifier

-- OBJECT CONSTRUCTOR ---------------------------------------------------------
function transformer_rectifier.new(name)

    local self = setmetatable({}, transformer_rectifier)

    -- CLASS PROPERTIES -------------------------------------------------------
    self.name = name
    self.isFailed = false
    self.input_volts = 0
    self.input_amps = 0
    self.volts = 0
    self.amps = 0
    self.hz = 0
    self.amps = 0

    return self

end


-- CLASS METHODS --------------------------------------------------------------
function transformer_rectifier.inputs(self)
    self.input_volts = tr_data[self.name].volts_in
    self.input_amps = tr_data[self.name].amps_in
end




function transformer_rectifier.outputs(self)
    self.volts = self.input_volts * A333DR_elec_ac_dc_transform_factor * (1 - bool2num[self.isFailed])
    self.amps = self.input_amps * (1 - bool2num[self.isFailed])
end




function transformer_rectifier.update(self)

    self:inputs()
    self:outputs()

end





--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--
tr1 = transformer_rectifier.new('tr1')
tr2 = transformer_rectifier.new('tr2')
ess_tr = transformer_rectifier.new('ess_tr')
apu_tr = transformer_rectifier.new('apu_tr')



--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--
local function A333_elec_tr_cache_globals()

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



local function A333_update_tr1()
    return ac_bus1.volts, (ac_bus1.volts > 0) and ac_bus1.amps or 0
end



local function A333_update_tr2()
    return ac_bus2.volts, (ac_bus2.volts > 0) and ac_bus2.amps or 0
end



local function A333_update_ess_tr()
    return ac_ess_feed_bus.volts, ac_ess_feed_bus.amps
end



local function A333_update_apu_tr()
    return ac_bus2.volts, simDR_elec_bus5_amps
end



local function A333_elec_tr_update_data()

   tr_data.tr1.volts_in, tr_data.tr1.amps_in = A333_update_tr1()
   tr_data.tr2.volts_in, tr_data.tr2.amps_in = A333_update_tr2()
   tr_data.ess_tr.volts_in, tr_data.ess_tr.amps_in = A333_update_ess_tr()
   tr_data.apu_tr.volts_in, tr_data.apu_tr.amps_in = A333_update_apu_tr()

end



local function A333_elec_tr_update_datarefs()

    A333DR_tr1_volts, A333DR_tr1_amps = tr1.volts, tr1.amps
    A333DR_tr2_volts, A333DR_tr2_amps = tr2.volts, tr2.amps
    A333DR_ess_tr_volts, A333DR_ess_tr_amps = ess_tr.volts, ess_tr.amps
    A333DR_apu_tr_volts, A333DR_apu_tr_amps = apu_tr.volts, apu_tr.amps

end


--*************************************************************************************--
--** 				                     PROCESSING             	    			 **--
--*************************************************************************************--

--===| INIT ALL |========================================================================
function A333_elec_tr_init_all()



end




--===| INIT ER |=========================================================================
function A333_elec_tr_init_ER()



end




--===| INIT CD |=========================================================================
function A333_elec_tr_init_CD()



end




--===| DEFERRED INITIALIZATION |=========================================================
function A333_elec_tr_deferred_init()




end



--===| DEFERRED PROCESSING |=============================================================
function A333_elec_tr_deferred_processing()



end




--=== AIRCRAFT LOAD =====================================================================
function A333_elec_tr_aircraft_load()



end



--=== FLIGHT START ======================================================================
function A333_elec_tr_flight_start()



end



--=== BEFORE PHYSICS ====================================================================
function A333_elec_tr_before_physics()



end



--=== AFTER PHYSICS =====================================================================
function A333_elec_tr_after_physics()

    A333_elec_tr_cache_globals()
    A333_elec_tr_update_data()

    tr1:update()
    tr2:update()
    ess_tr:update()
    apu_tr:update()

    A333_elec_tr_update_datarefs()

end




--=== FLIGHT CRASH ======================================================================
function A333_elec_bus_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_elec_tr_aircraft_unload()



end




--=== AIRCRAFT UNLOAD ===================================================================
function A333_elec_tr_after_replay()

    A333_elec_tr_cache_globals()
    A333_elec_tr_update_data()

    tr1:update()
    tr2:update()
    ess_tr:update()
    apu_tr:update()

    A333_elec_tr_update_datarefs()

end



--*************************************************************************************--
--** 				                 SUB-SCRIPT LOADING            	     			 **--
--*************************************************************************************--



