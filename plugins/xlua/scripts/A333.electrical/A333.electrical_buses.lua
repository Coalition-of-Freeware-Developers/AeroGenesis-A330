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
local s = string
local tonumber = tonumber

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

local dc_tie = 0




local bus_data = {
    ["ac_bus1"] = { volts=0, amps=0 },
    ["ac_bus2"] = { volts=0, amps=0 },
    ["ac_ess_feed_bus"] = { volts=0, amps=0 },
    ["ac_ess_bus"] = { volts=0, amps=0 },
    ["ac_ess_shed_bus"] = { volts=0, amps=0 },
    ["ac_ess_grnd_bus"] = { volts=0, amps=0 },
    ["ac_land_rcvry_bus"] = { volts=0, amps=0 },
    ["dc_bat1_hot_bus"] = { volts=0, amps=0 },
    ["dc_bat2_hot_bus"] = { volts=0, amps=0 },
    ["dc_bat_bus"] = { volts=0, amps=0 },
    ["dc_apu_bat_bus"] = { volts=0, amps=0 },
    ["dc_apu_bat_hot_bus"] = { volts=0, amps=0 },
    ["dc_bus1"] = { volts=0, amps=0 },
    ["dc_bus2"] = { volts=0, amps=0 },
    ["dc_ess_bus"] = { volts=0, amps=0 },
    ["dc_ess_shed_bus"] = { volts=0, amps=0 },
    ["dc_land_rcvry_bus"] = { volts=0, amps=0 },
    ["dc_shed_land_rcvry_bus"] = { volts=0, amps=0 }
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
--==========| BUS |======================================================================
local bus = {}
bus.__index = bus

-- OBJECT CONSTRUCTOR -------------------------------------------------------------------
function bus.new(name, id)

    local self = setmetatable({}, bus, id)

    -- CLASS PROPERTIES -----------------------------------------------------------------
    self.name = name
    self.id = id
    self.isFailed = false
    self.volts = 0
    self.amps = 0

    return self

end


-- CLASS METHODS ------------------------------------------------------------------------
function bus.inputs(self)
    self.volts = bus_data[self.name].volts
    self.amps = bus_data[self.name].amps
end




function bus.update(self)
    self:inputs()
end



--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--
ac_bus1 = bus.new("ac_bus1", "1XP")
ac_bus2 = bus.new("ac_bus2", "3XP")
ac_ess_feed_bus = bus.new("ac_ess_feed_bus", "9XP")
ac_ess_bus = bus.new("ac_ess_bus", "9XP")
ac_ess_shed_bus = bus.new("ac_ess_shed_bus", "4XP")
ac_ess_shed_bus2 = bus.new("ac_ess_shed_bus", "401XP")
ac_ess_grnd_bus = bus.new("ac_ess_grnd_bus", "905XP")
ac_land_rcvry_bus = bus.new("ac_land_rcvry_bus", "903XP")
ac_service_bus1 = bus.new("ac_service_bus1", "116XP")
ac_service_bus2 = bus.new("ac_service_bus2", "216XP")

dc_bat1_hot_bus = bus.new("dc_bat1_hot_bus", "701PP")
dc_bat2_hot_bus = bus.new("dc_bat2_hot_bus", "702PP")
dc_hot_bus_apu = bus.new("dc_hot_bus_apu", "709PP")
dc_bat_bus = bus.new("dc_bat_bus", "3PP")
dc_apu_bat_bus = bus.new("dc_apu_bat_bus", "309PP")
dc_apu_bat_hot_bus = bus.new("dc_apu_bat_hot_bus", "709PP")
dc_bus1 = bus.new("dc_bus1", "1PP")
dc_bus2 = bus.new("dc_bus2", "2PP")
dc_ess_bus = bus.new("dc_ess_bus", "4PP")
dc_ess_shed_bus = bus.new("dc_ess_shed_bus", "8PP")
dc_land_rcvry_bus = bus.new("dc_land_rcvry_bus", "407PP")
dc_shed_land_rcvry_bus = bus.new("dc_shed_land_rcvry_bus", "805PP")
dc_service_bus = bus.new("dc_service_bus","6PP")



--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--
local function A333_elec_bus_cache_globals()

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




local function A333_update_dc_bat1_hot_bus()
    local bat1_hot_bus_volts = tonumber(s.format("%.2f", simDR_elec_bat1_volts))
    return bat1_hot_bus_volts, simDR_elec_bat1_amps
end



local function A333_update_dc_bat2_hot_bus()
    local bat2_hot_bus_volts = tonumber(s.format("%.2f", simDR_elec_bat2_volts))
    return bat2_hot_bus_volts, simDR_elec_bat2_amps
end



local function A333_update_dc_apu_bat_hot_bus()
    local apu_hot_bus_volts = tonumber(s.format("%.2f", simDR_elec_bat3_volts))
    return apu_hot_bus_volts, simDR_elec_bat3_amps
end



local function A333_update_ac_bus1()
    return simDR_elec_bus1_volts, simDR_elec_bus1_amps
end



local function A333_update_ac_bus2()
    return simDR_elec_bus2_volts, simDR_elec_bus2_amps
end



local function A333_update_dc_bus1()

    local dc_bus_1_volts = 0
    local dc_bus_1_amps = 0

    if tr1_contactor.pos == CLOSED then
        dc_bus_1_volts = tr1.volts
        dc_bus_1_amps = tr1.amps

    elseif tr1_contactor.pos == OPEN
        and dc1_tie_contactor.pos == CLOSED
        and dc2_tie_contactor.pos == CLOSED
    then
        dc_bus_1_volts = dc_bat_bus.volts
        dc_bus_1_amps = dc_bat_bus.amps

    end

    return tonumber(s.format("%.2f", dc_bus_1_volts)), dc_bus_1_amps

end



local function A333_update_dc_bus2()

    local dc_bus_2_volts = 0
    local dc_bus_2_amps = 0

    if tr2_contactor.pos == CLOSED then
        dc_bus_2_volts = tr2.volts
        dc_bus_2_amps = tr2.amps

    elseif tr2_contactor.pos == OPEN
        and dc1_tie_contactor.pos == CLOSED
        and dc2_tie_contactor.pos == CLOSED
    then
        dc_bus_2_volts = dc_bat_bus.volts
        dc_bus_2_amps = dc_bat_bus.amps

    end

    return tonumber(s.format("%.2f", dc_bus_2_volts)), dc_bus_2_amps

end



local function A333_update_dc_bat_bus()

    local dc_tie = A330DR_elec_dc_tie_status
    local dc_bat_bus_volts = 0
    local dc_bat_bus_amps = 0

    if dc_tie <= 1 then
        dc_bat_bus_volts = dc_bus1.volts
        dc_bat_bus_amps = 0

    elseif dc_tie == 2 then
        dc_bat_bus_volts = dc_bus2.volts
        dc_bat_bus_amps = 0

    elseif dc_tie == 3 then
        dc_bat_bus_volts = simDR_elec_bus4_volts
        dc_bat_bus_amps = simDR_elec_bus4_amps

    end

    return tonumber(s.format("%.2f", dc_bat_bus_volts)), dc_bat_bus_amps

end



local function A333_update_dc_apu_bat_bus()

    local apuBat1_volts = apu_tr.volts
    local apuBat2_volts = simDR_elec_bat3_volts * apu_bat_contactor.pos
    local dc_apu_bat_bus_volts = m.max(apuBat1_volts, apuBat2_volts)

    return tonumber(s.format("%.2f", dc_apu_bat_bus_volts)), simDR_elec_bus5_amps

end



local function A333_update_ac_ess_feed_bus()

    local ac_ess_feed1_volts = ac_bus1.volts * ac_ess_feed_contactor1.pos
    local ac_ess_feed2_volts = ac_bus2.volts * ac_ess_feed_contactor2.pos
    local ac_ess_feed3_volts = simDR_elec_emer_gen_volts * emer_gen_contactor.pos
    local ac_ess_feed_bus_volts = tonumber(s.format("%.2f", m.max(ac_ess_feed1_volts, ac_ess_feed2_volts, ac_ess_feed3_volts)))

    local ac_ess_feed_bus_amps = (ac_ess_feed_bus_volts > 0) and simDR_elec_bus3_amps or 0

    return ac_ess_feed_bus_volts, ac_ess_feed_bus_amps

end



local function A333_update_ac_ess_shed_bus()
    return tonumber(s.format("%.2f", (ac_ess_feed_bus.volts * (1 - ac_ess_shed_switch.pos)))), 0
end




local function A333_update_ac_ess_bus()
    return ((ac_ess_switch.pos == OPEN) and ac_ess_feed_bus.volts) or inverter.volts, 0
end





local function A333_update_dc_ess_bus()

    local dc_ess_volts = 0
    
    if batteries_only_supply then
        local bat1_volts = simDR_elec_bat1_volts * dc_bat1_ess_contactor.pos
        local bat2_volts = simDR_elec_bat2_volts * dc_bat2_ess_contactor.pos
        dc_ess_volts = m.max(bat1_volts, bat2_volts)

    elseif ess_tr_contactor.pos == CLOSED then
        dc_ess_volts = ess_tr.volts

    elseif ess_tr_contactor.pos == 0
        and ((tr1.volts > ac_min_volts) and (tr2.volts > ac_min_volts))
    then
        dc_ess_volts = dc_bat_bus.volts * dc_ess_tie_contactor.pos
    end

    return tonumber(s.format("%.2f", dc_ess_volts)), 0

end




local function A333_update_ac_ess_grnd_bus()
    return tonumber(s.format("%.2f", (ac_ess_bus.volts * (1 - ac_ess_grnd_switch.pos)))), 0
end



local function A333_update_ac_land_rcvry_bus()

    local gear_extended = bool2num[simDR_nose_gear_deploy_status == 1
        and simDR_left_gear_deploy_status == 1
        and simDR_right_gear_deploy_status == 1]

    local ac_land_rcvry_volts = 0

    if ac_ess_land_rcvry_switch.pos == OPEN then
        ac_land_rcvry_volts = ac_ess_bus.volts * (1 - ac_ess_land_rcvry_switch.pos)
    else
        ac_land_rcvry_volts = ac_ess_bus.volts * (1 - (A333_buttons_land_rcvry_ctct_open_closed * gear_extended))
    end

    return tonumber(s.format("%.2f", ac_land_rcvry_volts)), 0

end



local function A333_update_dc_ess_shed_bus()
    return tonumber(s.format("%.2f", (dc_ess_bus.volts * (1 - dc_ess_shed_switch.pos)))), 0
end



local function A333_update_dc_land_rcvry_bus()

    local gear_extended = simDR_nose_gear_deploy_status == 1
        and simDR_left_gear_deploy_status == 1
        and simDR_right_gear_deploy_status == 1

    local dc_lnd_rcvy_volts = 0

    if dc_ess_land_rcvry_switch.pos == CLOSED then
        if A333_buttons_land_rcvry_ctct_open_closed == CLOSED and gear_extended then
            dc_lnd_rcvy_volts = dc_ess_bus.volts
        end

    elseif dc_ess_land_rcvry_switch.pos == OPEN then
        dc_lnd_rcvy_volts = dc_ess_bus.volts
    end

    return tonumber(s.format("%.2f", dc_lnd_rcvy_volts)), 0

end



local function A333_update_dc_shed_land_rcvry_bus()

    local gear_extended = simDR_nose_gear_deploy_status == 1
        and simDR_left_gear_deploy_status == 1
        and simDR_right_gear_deploy_status == 1

    local dc_shed_lnd_rcvy_volts = 0

    if dc_ess_shed_land_rcvry_switch.pos == CLOSED then
        if A333_buttons_land_rcvry_ctct_open_closed == CLOSED and gear_extended then
            dc_shed_lnd_rcvy_volts = dc_ess_shed_bus.volts
        end

    elseif dc_ess_shed_land_rcvry_switch.pos == OPEN then
        dc_shed_lnd_rcvy_volts = dc_ess_shed_bus.volts
    end

    return tonumber(s.format("%.2f", dc_shed_lnd_rcvy_volts)), 0

end



local function A333_elec_ac_ess_sources()

    local ac_ess_source = 0

    if ac_ess_switch.pos == OPEN then

        if ac_ess_feed_contactor1.pos == CLOSED then
            ac_ess_source = 1   -- Essential Feed Contactor 1 (3XC-A)

        elseif ac_ess_feed_contactor2.pos == CLOSED then
            ac_ess_source = 2   -- Essential Feed Contactor 2 (3XC-B)

        elseif emer_gen_contactor.pos == CLOSED then
            ac_ess_source = 3   -- Emergency Gen Contactor (2XE)

        end

    elseif ac_ess_switch.pos == CLOSED then
        ac_ess_source = 4   -- Static Inverter

    end

    A333DR_elec_ac_ess_source = ac_ess_source

end



local function A333_elec_ac_ess_tr_sources()

    local ac_ess_tr_source = 0

    if ac_ess_feed_contactor1.pos == CLOSED then
        ac_ess_tr_source = 1   -- Essential Feed Contactor 1 (3XC-A)

    elseif ac_ess_feed_contactor2.pos == CLOSED then
        ac_ess_tr_source = 2   -- Essential Feed Contactor 2 (3XC-B)

    elseif emer_gen_contactor.pos == CLOSED then
        ac_ess_tr_source = 3   -- Emergency Gen Contactor (2XE)

    end

    A333DR_elec_ac_ess_tr_source = ac_ess_tr_source

end



local function A333_elec_bus_update_data()

    bus_data.ac_bus1.volts, bus_data.ac_bus1.amps = A333_update_ac_bus1()
    bus_data.ac_bus2.volts, bus_data.ac_bus2.amps = A333_update_ac_bus2()
    bus_data.ac_ess_feed_bus.volts, bus_data.ac_ess_feed_bus.amps = A333_update_ac_ess_feed_bus()
    bus_data.ac_ess_bus.volts, bus_data.ac_ess_bus.amps = A333_update_ac_ess_bus()
    bus_data.ac_ess_shed_bus.volts, bus_data.ac_ess_shed_bus.amps = A333_update_ac_ess_shed_bus()
    bus_data.ac_ess_grnd_bus.volts, bus_data.ac_ess_grnd_bus.amps = A333_update_ac_ess_grnd_bus()
    bus_data.ac_land_rcvry_bus.volts, bus_data.ac_land_rcvry_bus.amps = A333_update_ac_land_rcvry_bus()

    bus_data.dc_bat1_hot_bus.volts, bus_data.dc_bat1_hot_bus.amps = A333_update_dc_bat1_hot_bus()
    bus_data.dc_bat2_hot_bus.volts, bus_data.dc_bat2_hot_bus.amps = A333_update_dc_bat2_hot_bus()
    bus_data.dc_bat_bus.volts, bus_data.dc_bat_bus.amps = A333_update_dc_bat_bus()
    bus_data.dc_apu_bat_bus.volts, bus_data.dc_apu_bat_bus.amps = A333_update_dc_apu_bat_bus()
    bus_data.dc_apu_bat_hot_bus.volts, bus_data.dc_apu_bat_hot_bus.amps = A333_update_dc_apu_bat_hot_bus()
    bus_data.dc_bus1.volts, bus_data.dc_bus1.amps = A333_update_dc_bus1()
    bus_data.dc_bus2.volts, bus_data.dc_bus2.amps = A333_update_dc_bus2()
    bus_data.dc_ess_bus.volts, bus_data.dc_ess_bus.amps = A333_update_dc_ess_bus()
    bus_data.dc_ess_shed_bus.volts, bus_data.dc_ess_shed_bus.amps = A333_update_dc_ess_shed_bus()
    bus_data.dc_land_rcvry_bus.volts, bus_data.dc_land_rcvry_bus.amps = A333_update_dc_land_rcvry_bus()
    bus_data.dc_shed_land_rcvry_bus.volts, bus_data.dc_shed_land_rcvry_bus.amps = A333_update_dc_shed_land_rcvry_bus()

end



local function A333_elec_bus_update_datarefs()

    A333DR_extA_ground_service_bus_volts, A333DR_extA_ground_service_bus_amps = simDR_elec_gpu_gen_volts, simDR_elec_gpu_gen_amps

    A333DR_ac_bus1_volts, A333DR_ac_bus1_amps = ac_bus1.volts, ac_bus1.amps
    A333DR_ac_bus2_volts, A333DR_ac_bus2_amps = ac_bus2.volts, ac_bus2.amps
    A333DR_ac_ess_bus_volts, A333DR_ess_bus_amps = ac_ess_bus.volts, ac_ess_bus.amps
    A333DR_ac_ess_shed_bus_volts, A333DR_ac_ess_shed_bus_amps = ac_ess_shed_bus.volts, ac_ess_shed_bus.amps
    A333DR_ac_ess_grnd_bus_volts, A333DR_ac_ess_grnd_bus_amps = ac_ess_grnd_bus.volts, ac_ess_grnd_bus.amps
    A333DR_ac_land_rcvry_bus_volts, A333DR_ac_land_rcvry_bus_amps = ac_land_rcvry_bus.volts, ac_land_rcvry_bus.amps

    A333DR_dc_bat1_hot_bus_volts, A333DR_dc_bat1_hot_bus_amps = dc_bat1_hot_bus.volts, dc_bat1_hot_bus.amps
    A333DR_dc_bat2_hot_bus_volts, A333DR_dc_bat2_hot_bus_amps = dc_bat2_hot_bus.volts, dc_bat2_hot_bus.amps
    A333DR_dc_bat_bus_volts, A333DR_dc_bat_bus_amps = dc_bat_bus.volts, dc_bat_bus.amps
    A333DR_dc_apu_bat_bus_volts, A333DR_dc_apu_bat_bus_amps = dc_apu_bat_bus.volts, dc_apu_bat_bus.amps
    A333DR_dc_apu_bat_hot_bus_volts, A333DR_dc_apu_bat_hot_bus_amps = dc_apu_bat_hot_bus.volts, dc_apu_bat_hot_bus.amps
    A333DR_dc_bus1_volts, A333DR_dc_bus1_amps = dc_bus1.volts, dc_bus1.amps
    A333DR_dc_bus2_volts, A333DR_dc_bus2_amps = dc_bus2.volts, dc_bus2.amps
    A333DR_dc_ess_bus_volts, A333DR_dc_ess_bus_amps = dc_ess_bus.volts, dc_ess_bus.amps
    A333DR_dc_ess_shed_bus_volts, A333DR_dc_ess_shed_bus_amps = dc_ess_shed_bus.volts, dc_ess_shed_bus.amps
    A333DR_dc_land_rcvry_bus_volts, A333DR_dc_land_rcvry_bus_amps = dc_land_rcvry_bus.volts, dc_land_rcvry_bus.amps
    A333DR_dc_shed_land_rcvry_bus_volts, A333DR_dc_shed_land_rcvry_bus_amps = dc_shed_land_rcvry_bus.volts, dc_shed_land_rcvry_bus.amps


    A333DR_extA_ground_service_bus_has_power = (simDR_elec_gpu_gen_volts > ac_min_volts) and 1 or 0
    A333DR_ac_bus1_has_power = (ac_bus1.volts > ac_min_volts) and 1 or 0
    A333DR_ac_bus2_has_power = (ac_bus2.volts > ac_min_volts) and 1 or 0
    A333DR_ac_ess_bus_has_power = (ac_ess_bus.volts > ac_min_volts) and 1 or 0
    A333DR_ac_ess_shed_bus_has_power = (ac_ess_shed_bus.volts > ac_min_volts) and 1 or 0
    A333DR_ac_ess_grnd_bus_has_power = (ac_ess_grnd_bus.volts > ac_min_volts) and 1 or 0
    A333DR_ac_land_rcvry_bus_has_power = (ac_land_rcvry_bus.volts > ac_min_volts) and 1 or 0

    A333DR_dc_bat1_hot_bus_has_power = (dc_bat1_hot_bus.volts > 0) and 1 or 0
    A333DR_dc_bat2_hot_bus_has_power = (dc_bat2_hot_bus.volts > 0) and 1 or 0
    A333DR_dc_bat_bus_has_power = (dc_bat_bus.volts > dc_min_volts) and 1 or 0
    A333DR_dc_apu_bat_bus_has_power = (dc_apu_bat_bus.volts > dc_min_volts) and 1 or 0
    A333DR_dc_apu_bat_hot_bus_has_power = (dc_apu_bat_hot_bus.volts > dc_min_volts) and 1 or 0
    A333DR_dc_bus1_has_power = (dc_bus1.volts > dc_min_volts) and 1 or 0
    A333DR_dc_bus2_has_power = (dc_bus2.volts > dc_min_volts) and 1 or 0
    A333DR_dc_ess_bus_has_power = (dc_ess_bus.volts > dc_min_volts) and 1 or 0
    A333DR_dc_ess_shed_bus_has_power = (dc_ess_shed_bus.volts > dc_min_volts) and 1 or 0
    A333DR_dc_land_rcvry_bus_has_power = (dc_land_rcvry_bus.volts > dc_min_volts) and 1 or 0
    A333DR_dc_shed_land_rcvry_bus_has_power = (dc_shed_land_rcvry_bus.volts > dc_min_volts) and 1 or 0

end



--*************************************************************************************--
--** 				                     PROCESSING             	    			 **--
--*************************************************************************************--

--===| INIT ALL |========================================================================
function A333_elec_bus_init_all()



end




--===| INIT ER |=========================================================================
function A333_elec_bus_init_ER()



end




--===| INIT CD |=========================================================================
function A333_elec_bus_init_CD()

    

end




--===| DEFERRED INITIALIZATION |=========================================================
function A333_elec_bus_deferred_init()




end



--===| DEFERRED PROCESSING |=============================================================
function A333_elec_bus_deferred_processing()



end




--=== AIRCRAFT LOAD =====================================================================
function A333_elec_bus_aircraft_load()



end



--=== FLIGHT START ======================================================================
function A333_elec_bus_flight_start()



end



--=== BEFORE PHYSICS ====================================================================
function A333_elec_bus_before_physics()



end



--=== AFTER PHYSICS =====================================================================
function A333_elec_bus_after_physics()

    A333_elec_bus_cache_globals()
    A333_elec_bus_update_data()

    dc_bat1_hot_bus:update()
    dc_bat2_hot_bus:update()
    dc_apu_bat_hot_bus:update()

    ac_bus1:update()
    ac_bus2:update()

    dc_bus1:update()
    dc_bus2:update()

    dc_bat_bus:update()
    dc_apu_bat_bus:update()
    
    ac_ess_feed_bus:update()
    ac_ess_bus:update()
    dc_ess_bus:update()

    ac_ess_shed_bus:update()
    ac_ess_grnd_bus:update()
    ac_land_rcvry_bus:update()

    dc_ess_shed_bus:update()
    dc_land_rcvry_bus:update()
    dc_shed_land_rcvry_bus:update()

    A333_elec_ac_ess_sources()
    A333_elec_ac_ess_tr_sources()

    A333_elec_bus_update_datarefs()

end




--=== FLIGHT CRASH ======================================================================
function A333_elec_bus_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_elec_bus_aircraft_unload()



end




--=== AIRCRAFT UNLOAD ===================================================================
function A333_elec_bus_after_replay()

    A333_elec_bus_cache_globals()
    A333_elec_bus_update_data()

    dc_bat1_hot_bus:update()
    dc_bat2_hot_bus:update()
    dc_apu_bat_hot_bus:update()

    ac_bus1:update()
    ac_bus2:update()

    dc_bus1:update()
    dc_bus2:update()

    dc_bat_bus:update()
    dc_apu_bat_bus:update()

    ac_ess_feed_bus:update()
    ac_ess_bus:update()
    dc_ess_bus:update()

    ac_ess_shed_bus:update()
    ac_ess_grnd_bus:update()
    ac_land_rcvry_bus:update()

    dc_ess_shed_bus:update()
    dc_land_rcvry_bus:update()
    dc_shed_land_rcvry_bus:update()

    A333_elec_ac_ess_sources()
    A333_elec_ac_ess_tr_sources()

    A333_elec_bus_update_datarefs()

end



--*************************************************************************************--
--** 				                 SUB-SCRIPT LOADING            	     			 **--
--*************************************************************************************--



