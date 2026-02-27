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


local animate = animate
local rescale = rescale


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
local emer_gen_on_rat = false

local bus0 = 2^0    -- 1  APU/GPU
local bus1 = 2^1    -- 2  AC1
local bus2 = 2^2    -- 4  AC2
local bus3 = 2^3    -- 8  ESS, RAT/EMER GEN
local bus4 = 2^4    -- 16 BATTERIES
local bus5 = 2^5    -- 32 APU BATTERY

local dc_tie = 0

local apu_gen_avail = 0
local extA_gen_avail = 0
local extB_gen_avail = 0

local power_source_contactor_priority = 0

local ac_ess_feed1 = 1
local ac_ess_feed2 = 0

local ac_bus1 = ac_bus1
local ac_bus2 = ac_bus2
local ac_ess_feed_bus = ac_ess_feed_bus
local ac_ess_bus = ac_ess_bus
local ac_ess_shed_bus = ac_ess_shed_bus
local ac_ess_grnd_bus = ac_ess_grnd_bus
local ac_land_rcvry_bus = ac_land_rcvry_bus
local dc_hot_bus1 = dc_hot_bus1
local dc_hot_bus2 = dc_hot_bus2
local dc_bat_bus = dc_bat_bus
local dc_apu_bat_bus = dc_apu_bat_bus
local dc_bus1 = dc_bus1
local dc_bus2 = dc_bus2
local dc_ess_bus = dc_ess_bus
local dc_ess_shed_bus = dc_ess_shed_bus
local dc_land_rcvry_bus = dc_land_rcvry_bus
local dc_shed_land_rcvry_bus = dc_shed_land_rcvry_bus
local dc_service_bus = dc_service_bus

local tr1 = tr1
local tr2 = tr2
local ess_tr = ess_tr
local apu_tr = apu_tr

local bcl1 = bcl1
local bcl2 = bcl2
local apu_bcl = apu_bcl

local inverter = inverter

local apu_door_motor_amps = 0
local last_apu_door_pos = 0
local apu_starter_motor_amps = 0





--| DATA TABLES |------------------------------------------------------------------------

local contactor_priority_schedule = {
    --        AC1 BUS TIE,      EXTB        APU             MAIN BUS TIE        EXTA            AC2 BUS TIE
    [0] =   { OPEN,             OPEN,       OPEN,           OPEN,               OPEN,           OPEN   },   -- NONE
    [1] =   { CLOSED,           OPEN,       CLOSED,         CLOSED,             OPEN,           CLOSED },   -- APU
    [2] =   { CLOSED,           OPEN,       OPEN,           CLOSED,             CLOSED,         CLOSED },   -- EXTA
    [3] =   { CLOSED,           OPEN,       CLOSED,         OPEN,               CLOSED,         CLOSED },   -- APU+EXTA
    [4] =   { CLOSED,           CLOSED,     OPEN,           CLOSED,             OPEN,           CLOSED },   -- EXTB
    [5] =   { CLOSED,           OPEN,       CLOSED,         CLOSED,             OPEN,           CLOSED },   -- APU+EXTB
    [6] =   { CLOSED,           CLOSED,     OPEN,           OPEN,               CLOSED,         CLOSED },   -- EXTA+EXTB
    [7] =   { CLOSED,           OPEN,       CLOSED,         OPEN,               CLOSED,         CLOSED },   -- APU+EXTA+EXTB

    [8] =   { CLOSED,           OPEN,       OPEN,           CLOSED,             OPEN,           CLOSED },   -- GEN1
    [9] =   { OPEN,             OPEN,       CLOSED,         CLOSED,             OPEN,           CLOSED },   -- GEN1+APU
    [10] =  { OPEN,             OPEN,       OPEN,           OPEN,               CLOSED,         CLOSED },   -- GEN1+EXTA
    [11] =  { OPEN,             OPEN,       OPEN,           OPEN,               CLOSED,         CLOSED },   -- GEN1+APU+EXTA
    [12] =  { OPEN,             CLOSED,     OPEN,           CLOSED,             OPEN,           CLOSED },   -- GEN1+EXTB
    [13] =  { OPEN,             OPEN,       CLOSED,         CLOSED,             OPEN,           CLOSED },   -- GEN1+APU+EXTB
    [14] =  { OPEN,             OPEN,       OPEN,           OPEN,               CLOSED,         CLOSED },   -- GEN1+EXTA+EXTB
    [15] =  { OPEN,             OPEN,       OPEN,           OPEN,               CLOSED,         CLOSED },   -- GEN1+APU+EXTA+EXTB

    [16] =  { CLOSED,           OPEN,       OPEN,           CLOSED,             OPEN,           CLOSED },   -- GEN2
    [17] =  { CLOSED,           OPEN,       CLOSED,         OPEN,               OPEN,           OPEN   },   -- GEN2+APU
    [18] =  { CLOSED,           OPEN,       OPEN,           CLOSED,             CLOSED,         OPEN   },   -- GEN2+EXTA
    [19] =  { CLOSED,           OPEN,       CLOSED,         OPEN,               OPEN,           OPEN   },   -- GEN2+APU+EXTA
    [20] =  { CLOSED,           CLOSED,     OPEN,           OPEN,               OPEN,           OPEN   },   -- GEN2+EXTB
    [21] =  { CLOSED,           OPEN,       CLOSED,         OPEN,               OPEN,           OPEN   },   -- GEN2+APU+EXTB
    [22] =  { CLOSED,           CLOSED,     OPEN,           OPEN,               OPEN,           OPEN   },   -- GEN2+EXTA+EXTB
    [23] =  { CLOSED,           OPEN,       CLOSED,         OPEN,               OPEN,           OPEN   },   -- GEN2+APU+EXTA+EXTB

    [24] =  { OPEN,             OPEN,       OPEN,           OPEN,               OPEN,           OPEN   }    -- GEN1+GEN2
}



local bus_tie_pattern_schedule = {
    --        BUS TIE SEL           CROSS TIE   -- SOURCE(S) AVAIL      AC BUS 1 SUPPLY     AC BUS 2 SUPPLY
    --                                          -- ———————————————      ———————————————     ———————————————
    [0] =   { 0,                    OPEN   },   -- NONE
    [1] =   { (bus0 + bus1 + bus2), CLOSED },   -- APU                  APU                 APU
    [2] =   { (bus0 + bus1 + bus2), CLOSED },   -- EXTA                 EXTA                EXTA
    [3] =   { (bus0 + bus1 + bus2), CLOSED },   -- APU+EXTA             APU                 EXTA
    [4] =   { (bus0 + bus1 + bus2), CLOSED },   -- EXTB                 APU                 EXTA
    [5] =   { (bus0 + bus1 + bus2), CLOSED },   -- APU+EXTB             APU                 APU
    [6] =   { (bus0 + bus1 + bus2), CLOSED },   -- EXTA+EXTB            EXTB                EXTA
    [7] =   { (bus0 + bus1 + bus2), CLOSED },   -- APU+EXTA+EXTB        APU                 EXTA
    [8] =   { (bus1 + bus2),        CLOSED },   -- GEN1                 GEN1                GEN1
    [9] =   { (bus0 + bus2),        CLOSED },   -- GEN1+APU             GEN1                APU
    [10] =  { (bus0 + bus2),        CLOSED },   -- GEN1+EXTA            GEN1                EXTA
    [11] =  { (bus0 + bus2),        CLOSED },   -- GEN1+APU+EXTA        GEN1                EXTA
    [12] =  { (bus0 + bus2),        CLOSED },   -- GEN1+EXTB            GEN1                EXTA
    [13] =  { (bus0 + bus2),        CLOSED },   -- GEN1+APU+EXTB        GEN1                APU
    [14] =  { (bus0 + bus2),        CLOSED },   -- GEN1+EXTA+EXTB       GEN1                EXTA
    [15] =  { (bus0 + bus2),        CLOSED },   -- GEN1+APU+EXTA+EXTB   GEN1                EXTA
    [16] =  { (bus1 + bus2),        CLOSED },   -- GEN2                 GEN2                GEN2
    [17] =  { (bus0 + bus1),        CLOSED },   -- GEN2+APU             APU                 GEN2
    [18] =  { (bus0 + bus1),        CLOSED },   -- GEN2+EXTA            EXTA                GEN2
    [19] =  { (bus0 + bus1),        CLOSED },   -- GEN2+APU+EXTA        APU                 GEN2
    [20] =  { (bus0 + bus1),        CLOSED },   -- GEN2+EXTB            EXTB                GEN2
    [21] =  { (bus0 + bus1),        CLOSED },   -- GEN2+APU+EXTB        APU                 GEN2
    [22] =  { (bus0 + bus1),        CLOSED },   -- GEN2+EXTA+EXTB       EXTB                GEN2
    [23] =  { (bus0 + bus1),        CLOSED },   -- GEN2+APU+EXTA+EXTB   APU                 GEN2
    [24] =  { 0,                    OPEN   }    -- GEN1+GEN2            APU                 GEN2
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
local contactor = {}
contactor.__index = contactor

-- OBJECT CONSTRUCTOR ---------------------------------------------------------
function contactor.new(name, id)

    local self = setmetatable({}, contactor)

    -- CLASS PROPERTIES -------------------------------------------------------
    self.name = name
    self.id = id
    self.pos = OPEN
    
    return self

end


-- CLASS METHODS --------------------------------------------------------------
function contactor.set_position(self, position)
    self.pos = position
end







--=============================================================================






local switch = {}
switch.__index = switch

-- OBJECT CONSTRUCTOR ---------------------------------------------------------
function switch.new(name)

    local self = setmetatable({}, switch)

    -- CLASS PROPERTIES -------------------------------------------------------
    self.name = name
    self.pos = OPEN

    return self

end


-- CLASS METHODS --------------------------------------------------------------
function switch.set_position(self, position)
    self.pos = position
end







--=============================================================================





local electrical_contactor_management_unit = {}
electrical_contactor_management_unit.__index = electrical_contactor_management_unit

-- OBJECT CONSTRUCTOR ---------------------------------------------------------
function electrical_contactor_management_unit.new(name, id)

    local self = setmetatable({}, electrical_contactor_management_unit)

    -- CLASS PROPERTIES -------------------------------------------------------
    self.name = name
    self.id = id



    return self

end


-- CLASS METHODS --------------------------------------------------------------






--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--

--| CONTACTORS
bat1_contactor = contactor.new("bat1_contactor", "6PB1")
bat2_contactor = contactor.new("bat2_contactor", "6PB2")
gen1_contactor = contactor.new("gen1_contactor", "9XU1")
gen2_contactor = contactor.new("gen2_contactor", "9XU2")

exta_contactor = contactor.new("exta_contactor", "3XG")
extb_contactor = contactor.new("extb_contactor", "4XG")
apu_gen_contactor = contactor.new("apu_gen_contactor", "3XS")
emer_gen_contactor = contactor.new("emer_gen_contactor", "2XE")
apu_bat_contactor = contactor.new("apu_bat_contactor", "5PB")
apu_start_contactor = contactor.new("apu_start_contactor", "5KA")

system_isolation_contactor = contactor.new("system_isolation_contactor", "SIC")
ac1_bus_tie_contactor = contactor.new("ac1_bus_tie_contactor", "BTC1")
ac2_bus_tie_contactor = contactor.new("ac2_bus_tie_contactor", "BTC2")

ac_ess_feed_contactor1 = contactor.new("ac_ess_feed_contactor1", "3XC-A")
ac_ess_feed_contactor2 = contactor.new("ac_ess_feed_contactor2", "3XC-B")

tr1_contactor = contactor.new("tr1_contactor", "5PU1")
tr2_contactor = contactor.new("tr2_contactor", "5PU2")
ess_tr_contactor = contactor.new("ess_tr_contactor", "3PE")
apu_tr_contactor = contactor.new("apu_tr_contactor", "7PU")

dc1_tie_contactor = contactor.new("dc1_tie_contactor", "1PC1")
dc2_tie_contactor = contactor.new("dc2_tie_contactor", "1PC2")
dc_ess_tie_contactor = contactor.new("dc_ess_tie_contactor", "4PC")
dc_bat1_ess_contactor = contactor.new("dc_bat1_ess_contactor", "3PC")
dc_bat2_ess_contactor = contactor.new("dc_bat2_ess_contactor", "2PC")



-- SERVICE BUSES
ac_exta_tr2_contactor = contactor.new("ac_exta_tr2_contactor", "6XX")
ac_ac2_tr2_contactor = contactor.new("ac_ac2_tr2_contactor", "2PU")

ac_service_bus1_contactor1 = contactor.new("ac_service_bus1_contactor1", "6XN1")
ac_service_bus1_contactor2 = contactor.new("ac_service_bus1_contactor2", "7XN1")

ac_service_bus2_contactor1 = contactor.new("ac_service_bus2_contactor1", "6XN2")
ac_service_bus2_contactor2 = contactor.new("ac_service_bus2_contactor2", "7XN2")

dc_service_bus_contactor1 = contactor.new("dc_service_bus_contactor1", "1PX")
dc_service_bus_contactor2 = contactor.new("dc_service_bus_contactor1", "1PN")




--| SWITCHES
ac_ess_shed_switch = switch.new("ac_ess_shed_switch", "16XH")
ac_ess_switch = switch.new("ac_ess_switch", "3XB")
ac_ess_grnd_switch = switch.new("ac_ess_grnd_switch", "3XB")
ac_ess_land_rcvry_switch = switch.new("ac_ess_land_rcvry_switch", "")

dc_ess_shed_switch = switch.new("dc_ess_shed_switch", "1PH")
dc_ess_shed_land_rcvry_switch = switch.new("dc_ess_shed_land_rcvry_switch", "")
dc_ess_land_rcvry_switch = switch.new("dc_ess_land_rcvry_switch", "")




--| ELECTRICAL CONTACTOR MANAGEMENT UNITS
ecmu1 = electrical_contactor_management_unit.new("ecmu1")
ecmu2 = electrical_contactor_management_unit.new("ecmu2")




--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--
local function getBit(bitfield, position)
    local mask = position
    return (bitfield % (mask + mask) >= mask) and 1 or 0
end



local function A333_elec_ecmu_cache_globals()

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
    emer_gen_on_rat = simDR_RAT_extended and simDR_elec_emer_gen_on
    
end



--[[
function A333_elec_ecmu_update_bus_tie_pattern_schedule(bus1_fail, bus2_fail)   -- bus fail not modeled future feature

    bus_tie_pattern_schedule = {
        [0] =   { 0,                              OPEN   },
        [1] =   { (bus0 + bus1_fail + bus2_fail), CLOSED },
        [2] =   { (bus0 + bus1_fail + bus2_fail), CLOSED },
        [3] =   { (bus0 + bus1_fail + bus2_fail), CLOSED },
        [4] =   { (bus0 + bus1_fail + bus2_fail), CLOSED },
        [5] =   { (bus0 + bus1_fail + bus2_fail), CLOSED },
        [6] =   { (bus0 + bus1_fail + bus2_fail), CLOSED },
        [7] =   { (bus0 + bus1_fail + bus2_fail), CLOSED },
        [8] =   { (bus1_fail + bus2_fail),        CLOSED },
        [9] =   { (bus0 + bus2_fail),             CLOSED },
        [10] =  { (bus0 + bus2_fail),             CLOSED },
        [11] =  { (bus0 + bus2_fail),             CLOSED },
        [12] =  { (bus0 + bus2_fail),             CLOSED },
        [13] =  { (bus0 + bus2_fail),             CLOSED },
        [14] =  { (bus0 + bus2_fail),             CLOSED },
        [15] =  { (bus0 + bus2_fail),             CLOSED },
        [16] =  { (bus1_fail + bus2_fail),        CLOSED },
        [17] =  { (bus0 + bus1_fail),             CLOSED },
        [18] =  { (bus0 + bus1_fail),             CLOSED },
        [19] =  { (bus0 + bus1_fail),             CLOSED },
        [20] =  { (bus0 + bus1_fail),             CLOSED },
        [21] =  { (bus0 + bus1_fail),             CLOSED },
        [22] =  { (bus0 + bus1_fail),             CLOSED },
        [23] =  { (bus0 + bus1_fail),             CLOSED },
        [24] =  { 0,                              OPEN   }
    }
    
end
--]]


local function A333_elec_ecmu_bus_failure()         -- TODO: not modeled future feature

    -- DO NOT allow bus failures, unknown behavior
    simDR_bus0_failure = 0
    simDR_bus1_failure = 0
    simDR_bus2_failure = 0
    simDR_bus3_failure = 0
    simDR_bus4_failure = 0
    simDR_bus5_failure = 0

end



local function A333_elec_ecmu_gen1_contactor()

    return (A333_gen1_button_ctct_open_closed == CLOSED
        and A333_eng1_fire_handle_pos == 0
        and A333_gen1_hertz > 395.0
        and simDR_elec_gen1_volts >= ac_min_volts
        and simDR_gen1_hi_voltage < 6
        and simDR_gen1_lo_voltage < 6
        and simDR_gen1_fail < 6
        and simDR_bus1_failure < 6
        and A333DR_IDG1_status == 1)
        and CLOSED or OPEN

end



local function A333_elec_ecmu_gen2_contactor()

    return (A333_gen2_button_ctct_open_closed == CLOSED
        and A333_eng2_fire_handle_pos == 0
        and A333_gen2_hertz > 395.0
        and simDR_elec_gen2_volts >= ac_min_volts
        and simDR_gen2_hi_voltage < 6
        and simDR_gen2_lo_voltage < 6
        and simDR_gen2_fail < 6
        and simDR_bus2_failure < 6
        and A333DR_IDG2_status == 1)
        and CLOSED or OPEN

end



local function A333_elec_ecmu_apu_gen_avail()

    apu_gen_avail = (simDR_elec_apu_running == 1
        and (simDR_elec_apu_N1 >= 95.0
        and simDR_elec_apu_gen_volts >= ac_min_volts))
        and 1 or 0

end



local function A333_elec_ecmu_exta_gen_avail()

    extA_gen_avail = (simDR_elec_gpu_gen_volts >= ac_min_volts) and 1 or 0

    -- Reset the button contactor if "request for GPU" is cancelled
    if extA_gen_avail == 0 and A333_extA_button_ctct_open_closed == CLOSED then
        A333_extA_button_ctct_open_closed = OPEN
    end

end



local function A333_elec_ecmu_extb_gen_avail()

    extB_gen_avail = 0 -- (simDR_elec_gpu2_gen_volts >= ac_min_volts)   -- TODO: not modeled future feature
        -- and 1 or 0

    -- Reset the button contactor if "request for GPU" is cancelled
    if extB_gen_avail == 0 and A333_extB_button_ctct_open_closed == CLOSED then
        A333_extB_button_ctct_open_closed = OPEN
    end

end





local function A333_elec_ecmu_ac_power_source_supply()

    --| GET POWER SOURCE SUPPLY AVAILABLE
    local apu  = ((apu_gen_avail == 1) and 2^0) or 0                -- 1 or 0
    local extA = ((extA_gen_avail == 1 and A333_extA_button_ctct_open_closed == 1) and 2^1) or 0               -- 2 or 0
    local extB = ((extB_gen_avail == 1 and A333_extB_button_ctct_open_closed == 1) and 2^2) or 0               -- 4 or 0
    local gen1 = ((gen1_contactor.pos == CLOSED) and 2^3) or 0      -- 8 or 0
    local gen2 = ((gen2_contactor.pos == CLOSED) and 2^4) or 0      -- 16 or 0

    local power_source_avail_index = m.min(24, (apu + extA + extB + gen1 + gen2)) * A333_bus_tie_button_ctct_open_closed

    power_source_contactor_priority = contactor_priority_schedule[power_source_avail_index]

end



local function A333_elec_ecmu_apu_gen_contactor()
    return power_source_contactor_priority[3] * A333_apu_gen_button_ctct_open_closed
end



local function A333_elec_ecmu_extA_gen_contactor()
    return power_source_contactor_priority[5] * A333_extA_button_ctct_open_closed
end




local function A333_elec_ecmu_extB_gen_contactor()
    return 0                                                    -- not modeled future feature
end




local function A333_elec_emergency_generator_line_contactor()
    return simDR_elec_emer_gen_on
end




local function A333_elec_ecmu_ac_ess_general_switching()

    if elec_emer_config
        or batteries_only_supply
        or (A333DR_emer_gen_test_button_pos == 1 and simDR_elec_emer_gen_on == 1)
    then
        ac_ess_feed1 = 0
        ac_ess_feed2 = 0
    else
        if A333_buttons_ess_feed_ctct_on_off == 1 then  -- NORMAL
            if ac_bus1.volts >= ac_min_volts then
                ac_ess_feed1 = 1
                ac_ess_feed2 = 0
            elseif ac_bus1.volts < ac_min_volts then
                if ac_bus2.volts >= ac_min_volts then
                    ac_ess_feed1 = 0
                    ac_ess_feed2 = 1
                end
            end
        elseif A333_buttons_ess_feed_ctct_on_off == 0 then  -- ALTN
            if ac_bus2.volts >= ac_min_volts then
                ac_ess_feed1 = 0
                ac_ess_feed2 = 1
            end
        end
    end

    ac_ess_feed_contactor1:set_position(ac_ess_feed1)
    ac_ess_feed_contactor2:set_position(ac_ess_feed2)

end





local function A333_elec_ecmu_dc_normal_generation_switching()

    if tr1_contactor.pos == 1 then

        if tr2_contactor.pos == 1 then
            dc1_tie_contactor:set_position(1)
            dc2_tie_contactor:set_position(0)
            dc_tie = 0  -- (Norm: DC1 -> DC_BAT_BUS)

        elseif tr2_contactor.pos == 0 then
            dc1_tie_contactor:set_position(1)
            dc2_tie_contactor:set_position(1)
            dc_tie = 1  -- (TR2 Lost: DC1 -> DC_BAT_BUS -> DC2)
        end

    elseif tr1_contactor.pos == 0 then

        if tr2_contactor.pos == 1 then
            dc1_tie_contactor:set_position(1)
            dc2_tie_contactor:set_position(1)
            dc_tie = 2  -- (TR1 Lost: DC2 -> DC_BAT_BUS -> DC1)

        elseif tr2_contactor.pos == 0 then
            dc1_tie_contactor:set_position(0)
            dc2_tie_contactor:set_position(0)
            dc_tie = 3  -- (TR1+TR2 Lost: NO AC TO DC SUPPLY

        end
    end

    A330DR_elec_dc_tie_status = dc_tie

end




local function A333_elec_ecmu_bus_tie_manager()

    local cross_tie = 0

    --| GET PRIMARY POWER SOURCE(S) ---------------------------------------------------------
    local apu  = ((apu_gen_contactor.pos == CLOSED) and 2^0) or 0   -- 1 or 0
    local extA = ((exta_contactor.pos == CLOSED) and 2^1) or 0      -- 2 or 0
    local extB = ((extb_contactor.pos == CLOSED) and 2^2) or 0      -- 4 or 0
    local gen1 = ((gen1_contactor.pos == CLOSED) and 2^3) or 0      -- 8 or 0
    local gen2 = ((gen2_contactor.pos == CLOSED) and 2^4) or 0      -- 16 or 0

    local power_source_connected_index = m.min(24, (apu + extA + extB + gen1 + gen2)) * A333_bus_tie_button_ctct_open_closed

    local bus_tie_pattern = bus_tie_pattern_schedule[power_source_connected_index][1]
    

    --| A333 BUS TIE CONTACTORS -------------------------------------------------------------
    ac1_bus_tie_contactor.pos = ((contactor_priority_schedule[power_source_connected_index][1] == 1) and (A333_bus_tie_button_ctct_open_closed == 1)) and 1 or 0
    ac2_bus_tie_contactor.pos = ((contactor_priority_schedule[power_source_connected_index][6] == 1) and (A333_bus_tie_button_ctct_open_closed == 1)) and 1 or 0
    system_isolation_contactor.pos = ((contactor_priority_schedule[power_source_connected_index][4] == 1) and (A333_bus_tie_button_ctct_open_closed == 1)) and 1 or 0


    -- Ties for DC Normal Generation Switching
    local bus0_tied = getBit(bus_tie_pattern, 1)
    local bus1_tied = getBit(bus_tie_pattern, 2)
    local bus2_tied = getBit(bus_tie_pattern, 4)
    local bus3_tied = getBit(bus_tie_pattern, 8)
    local bus4_tied = getBit(bus_tie_pattern, 16)
    local bus5_tied = getBit(bus_tie_pattern, 32)


    if dc_tie == 0 or dc_tie == 1 then     -- (Norm: DC1 -> DC_BAT_BUS) or (TR2 Lost: DC1 -> DC_BAT_BUS -> DC2)
        if (A333_bus_tie_button_ctct_open_closed == 0 and gen1_contactor.pos == 1) or A333_bus_tie_button_ctct_open_closed == 1 then
            if bus1_tied == 0 then bus_tie_pattern = bus_tie_pattern + bus1 end
            if bus4_tied == 0 then bus_tie_pattern = bus_tie_pattern + bus4 end
        end


    elseif dc_tie == 2 then -- (TR1 Lost: DC2 -> DC_BAT_BUS -> DC1)
        if (A333_bus_tie_button_ctct_open_closed == 0 and gen2_contactor.pos == 1) or A333_bus_tie_button_ctct_open_closed == 1 then
            if bus2_tied == 0 then bus_tie_pattern = bus_tie_pattern + bus2 end
            if bus4_tied == 0 then bus_tie_pattern = bus_tie_pattern + bus4 end
        end

    end


    
    -- Ties for AC2 -> APU Battery Bus Supply
    if tr1_contactor.pos == 1 then

        bus0_tied = getBit(bus_tie_pattern, 1)
        bus1_tied = getBit(bus_tie_pattern, 2)
        bus2_tied = getBit(bus_tie_pattern, 4)
        bus3_tied = getBit(bus_tie_pattern, 8)
        bus4_tied = getBit(bus_tie_pattern, 16)
        bus5_tied = getBit(bus_tie_pattern, 32)

        if (A333_bus_tie_button_ctct_open_closed == 0 and gen2_contactor.pos == 1) or A333_bus_tie_button_ctct_open_closed == 1 then
            if bus2_tied == 0 then bus_tie_pattern = bus_tie_pattern + bus2 end
            if bus5_tied == 0 then bus_tie_pattern = bus_tie_pattern + bus5 end
        end

    end
    
    
    --| SET SIM BUS TIE  --------------------------------------------------------------------
    simDR_elec_bus_tie_selective = bus_tie_pattern

    if bus_tie_pattern_schedule[power_source_connected_index][2] > 0    -- Primary Power Sources, 0 if bus tie switch off
        or bus_tie_pattern > 0  -- Primary Power Sources + Supplemental Buses (Note: Supplemental Sources do not take into account bus tie switch status)
    then
        cross_tie = 1
    end
    simDR_elec_cross_tie = cross_tie


    --| ASSIGN DATAREF VALUES
    A330DR_elec_sys_isol_contactor = system_isolation_contactor.pos
    A330DR_elec_ac1_bus_tie_contactor = ac1_bus_tie_contactor.pos
    A330DR_elec_ac2_bus_tie_contactor = ac2_bus_tie_contactor.pos

    --[[ DEBUG
    A330DR_elec_sim_bus_tied[0] = getBit(bus_tie_pattern, 1)
    A330DR_elec_sim_bus_tied[1] = getBit(bus_tie_pattern, 2)
    A330DR_elec_sim_bus_tied[2] = getBit(bus_tie_pattern, 4)
    A330DR_elec_sim_bus_tied[3] = getBit(bus_tie_pattern, 8)
    A330DR_elec_sim_bus_tied[4] = getBit(bus_tie_pattern, 16)
    A330DR_elec_sim_bus_tied[5] = getBit(bus_tie_pattern, 32)
    --]]

end



local function A333_elec_ecmu_tr1_contactor()
    return (tr1.volts > dc_min_volts) and 1 or 0
end



local function A333_elec_ecmu_tr2_contactor()
    return (tr2.volts > dc_min_volts) and 1 or 0
end



local function A333_elec_ecmu_ess_tr_contactor()
    return (ess_tr.volts > dc_min_volts) and 1 or 0
end



local function A333_elec_ecmu_apu_tr_contactor()
    return (apu_tr.volts > dc_min_volts) and 1 or 0
end



local function A333_elec_ecmu_dc_bat1_ess_contactor()

    return (battery_only_supply_on_ground or battery_only_supply_in_flight) and 1 or 0

end



local function A333_elec_ecmu_dc_bat2_ess_contactor()
    return (battery_only_supply_on_ground or battery_only_supply_in_flight) and 1 or 0
end



local function A333_elec_ecmu_dc_ess_tie_contactor()        -- 4PC
     return (ess_tr_contactor.pos == 0 and tr1_contactor.pos == 1 and tr2_contactor.pos == 1) and 1 or 0
end



local function A333_elec_ecmu_ac_ess_shed_switch()
    return emer_gen_on_rat or batteries_only_supply and 1 or 0

end



local function A333_elec_ecmu_ac_ess_switch()
    return batteries_only_supply and 1 or 0
end



local function A333_elec_ecmu_ac_ess_grnd_switch()
    return (((simDR_elec_emer_gen_on == 1) and (simDR_elec_emer_gen_volts > ac_min_volts))
        or (battery_only_supply_in_flight))
        and 1 or 0
end



local function A333_elec_ecmu_ac_ess_land_rcvry_switch()
    return (simDR_elec_emer_gen_on == 1) and 1 or 0
end



local function A333_elec_ecmu_dc_ess_shed_switch()
    return (not emer_gen_on_rat) and (not batteries_only_supply) and 1 or 0
end


local function A333_elec_ecmu_dc_ess_shed_land_rcvry_switch()
    return ((simDR_elec_emer_gen_on == 1 and (simDR_elec_emer_gen_volts > ac_min_volts))
        or batteries_only_supply)
        and 1 or 0
end



local function A333_elec_ecmu_dc_ess_land_rcvry_switch()
    return (simDR_elec_emer_gen_on == 1 and (simDR_elec_emer_gen_volts > ac_min_volts))
        and 1 or 0
end




local function A333_elec_apu_door_motor_amps()

    local apu_door_motor_amps_target = 0
    local apu_door_pos = simDR_elec_apu_door

    if apu_door_pos ~= last_apu_door_pos then
        apu_door_motor_amps_target = 2.5
    else
        apu_door_motor_amps_target = 0.0
    end
    apu_door_motor_amps = animate(apu_door_motor_amps, apu_door_motor_amps_target, 10.0)

    simDR_plugin_bus_amps[4] = apu_door_motor_amps

    last_apu_door_pos = apu_door_pos

end




local function A333_elec_apu_starter_motor_amps()

    local apu_starter_motor_amps_target = 0

    if simDR_elec_apu_switch <= 1 then
        apu_starter_motor_amps_target = 0

    elseif simDR_elec_apu_switch == 2 then

        if simDR_elec_apu_N1 < 1.5 then
    --		apu_starter_motor_amps_target = rescale(0, 0, 1.499, 785, simDR_elec_apu_N1)
			apu_starter_motor_amps_target = rescale(0, 0, 1.249, 385, simDR_elec_apu_N1)
        elseif simDR_elec_apu_N1 < 5 then
    --		apu_starter_motor_amps_target = rescale(1.5, 785, 4.999, 455, simDR_elec_apu_N1)
			apu_starter_motor_amps_target = rescale(1.250, 385, 4.999, 245, simDR_elec_apu_N1)
        elseif simDR_elec_apu_N1 < 10 then
    -- 		apu_starter_motor_amps_target = rescale(5, 455, 9.999, 385, simDR_elec_apu_N1)
			apu_starter_motor_amps_target = rescale(5, 245, 9.999, 190, simDR_elec_apu_N1)
        elseif simDR_elec_apu_N1 < 20 then
    --      apu_starter_motor_amps_target = rescale(10, 385, 19.999, 320, simDR_elec_apu_N1)
			apu_starter_motor_amps_target = rescale(10, 190, 19.999, 130, simDR_elec_apu_N1)
        elseif simDR_elec_apu_N1 < 30 then
	--      apu_starter_motor_amps_target = rescale(20.0, 320, 29.999, 270, simDR_elec_apu_N1)
			apu_starter_motor_amps_target = rescale(20.0, 130, 29.999, 90, simDR_elec_apu_N1)
        elseif simDR_elec_apu_N1 < 40 then
	--		apu_starter_motor_amps_target = rescale(30.0, 270, 39.999, 240, simDR_elec_apu_N1)
			apu_starter_motor_amps_target = rescale(30.0, 90, 39.999, 60, simDR_elec_apu_N1)
        elseif simDR_elec_apu_N1 < 50 then
	--		apu_starter_motor_amps_target = rescale(40.0, 240, 49.999, 215, simDR_elec_apu_N1)
            apu_starter_motor_amps_target = rescale(40.0, 60, 49.999, 40, simDR_elec_apu_N1)
        elseif simDR_elec_apu_N1 < 60 then
 	--		apu_starter_motor_amps_target = rescale(50.0, 215, 59.999, 120, simDR_elec_apu_N1)
            apu_starter_motor_amps_target = rescale(50.0, 40, 59.999, 0, simDR_elec_apu_N1)
        end
 
    end

    apu_starter_motor_amps = animate(apu_starter_motor_amps, apu_starter_motor_amps_target, 10.0)
    simDR_plugin_bus_amps[5] = apu_starter_motor_amps

end




local function A333_elec_ecmu_update_contacts()

    bat1_contactor:set_position(bcl1.battery_contactor_control_signal)

    bat2_contactor:set_position(bcl2.battery_contactor_control_signal)

    apu_bat_contactor:set_position(apu_bcl.battery_contactor_control_signal)

    gen1_contactor:set_position(A333_elec_ecmu_gen1_contactor())

    gen2_contactor:set_position(A333_elec_ecmu_gen2_contactor())

    apu_gen_contactor:set_position(A333_elec_ecmu_apu_gen_contactor())

    exta_contactor:set_position(A333_elec_ecmu_extA_gen_contactor())

    extb_contactor:set_position(A333_elec_ecmu_extB_gen_contactor())

    tr1_contactor:set_position(A333_elec_ecmu_tr1_contactor())

    tr2_contactor:set_position(A333_elec_ecmu_tr2_contactor())

    ess_tr_contactor:set_position(A333_elec_ecmu_ess_tr_contactor())

    apu_tr_contactor:set_position(A333_elec_ecmu_apu_tr_contactor())

    dc_bat1_ess_contactor:set_position(A333_elec_ecmu_dc_bat1_ess_contactor())

    dc_bat2_ess_contactor:set_position(A333_elec_ecmu_dc_bat2_ess_contactor())

    dc_ess_tie_contactor:set_position(A333_elec_ecmu_dc_ess_tie_contactor())

    ac_ess_shed_switch:set_position(A333_elec_ecmu_ac_ess_shed_switch())

    ac_ess_switch:set_position(A333_elec_ecmu_ac_ess_switch())

    ac_ess_grnd_switch:set_position(A333_elec_ecmu_ac_ess_grnd_switch())

    ac_ess_land_rcvry_switch:set_position(A333_elec_ecmu_ac_ess_land_rcvry_switch())

    dc_ess_shed_switch:set_position(A333_elec_ecmu_dc_ess_shed_switch())

    dc_ess_shed_land_rcvry_switch:set_position(A333_elec_ecmu_dc_ess_shed_land_rcvry_switch())

    dc_ess_land_rcvry_switch:set_position(A333_elec_ecmu_dc_ess_land_rcvry_switch())

    emer_gen_contactor:set_position(A333_elec_emergency_generator_line_contactor())

end




local function A333_elec_ecmu_essential_bus_ties()

    local ess_bus_ties = 0                              -- [DEFAULT] Fed by Emergency Generator (contactor closed)

    if ac_ess_feed_contactor1.pos == CLOSED then
        ess_bus_ties = bus1                             -- AC BUS 1 (BIT 2)

    elseif ac_ess_feed_contactor2.pos == CLOSED then
        ess_bus_ties = bus2                             -- AC BUS 2 (BIT 4)

    elseif batteries_only_supply then
        if emer_gen_contactor.pos == OPEN then
            ess_bus_ties = bus4                         -- BATTERIES (BIT 16) (Until EMER Generator is online)
        end
    end

    simDR_elec_ac_ess_ties = ess_bus_ties

end




local function A333_elec_ecmu_update_datarefs()

    A333DR_status_gpu_avail = ((A333_extA_button_ctct_open_closed == OPEN) and (extA_gen_avail == 1)) and 1 or 0
    A333DR_status_gpu2_avail  = ((A333_extB_button_ctct_open_closed == OPEN) and (extB_gen_avail == 1)) and 1 or 0       -- TODO: not modeled future feature



    simDR_elec_bat1_on = bat1_contactor.pos
    simDR_elec_bat2_on = bat2_contactor.pos
    simDR_elec_bat3_on = apu_bat_contactor.pos

    simDR_elec_gen1_on = gen1_contactor.pos
    simDR_elec_gen2_on = gen2_contactor.pos

    simDR_elec_apu_gen_on = apu_gen_contactor.pos
    simDR_elec_gpu_gen_on = exta_contactor.pos
    simDR_elec_gpu2_gen_on = extb_contactor.pos




    A333DR_bat1_line_contactor = bat1_contactor.pos
    A333DR_bat2_line_contactor = bat2_contactor.pos
    A333DR_apu_bat_line_contactor = apu_bat_contactor.pos

    A333DR_gen1_line_contactor = gen1_contactor.pos
    A333DR_gen2_line_contactor = gen2_contactor.pos

    A333DR_extA_line_contactor = exta_contactor.pos
    A333DR_extB_line_contactor = extb_contactor.pos
    A333DR_apu_gen_line_contactor = apu_gen_contactor.pos

    A330DR_elec_sys_isol_contactor = system_isolation_contactor.pos
    A330DR_elec_ac1_bus_tie_contactor = ac1_bus_tie_contactor.pos
    A330DR_elec_ac2_bus_tie_contactor = ac2_bus_tie_contactor.pos

    A333DR_emer_gen_line_contactor = emer_gen_contactor.pos

    A333DR_ess_feed_line_contactor1 = ac_ess_feed_contactor1.pos
    A333DR_ess_feed_line_contactor2 = ac_ess_feed_contactor2.pos

    A333DR_tr1_line_contactor = tr1_contactor.pos
    A333DR_tr2_line_contactor = tr2_contactor.pos
    A333DR_ess_tr_line_contactor = ess_tr_contactor.pos
    A333DR_apu_tr_line_contactor = apu_tr_contactor.pos

    A333DR_dc1_tie_contactor = dc1_tie_contactor.pos
    A333DR_dc2_tie_contactor = dc2_tie_contactor.pos
    A333DR_dc_ess_tie_contactor = dc_ess_tie_contactor.pos
    A333DR_dc_bat1_ess_tie_contactor = dc_bat1_ess_contactor.pos
    A333DR_dc_bat2_ess_tie_contactor = dc_bat2_ess_contactor.pos

    A333DR_ac_ess_shed_switch = ac_ess_shed_switch.pos
    A333DR_ac_ess_switch = ac_ess_switch.pos
    A333DR_ac_ess_ground_switch = ac_ess_grnd_switch.pos
    A333DR_ac_ess_land_rcvry_switch = ac_ess_land_rcvry_switch.pos

    A333DR_dc_ess_shed_switch = dc_ess_shed_switch.pos
    A333DR_dc_ess_shed_land_rcvry_switch = dc_ess_shed_land_rcvry_switch.pos
    A333DR_dc_ess_land_rcvry_switch = dc_ess_land_rcvry_switch.pos

end





--*************************************************************************************--
--** 				                     PROCESSING             	    			 **--
--*************************************************************************************--

--===| INIT ALL |========================================================================
function A333_elec_ecmu_init_all()



end




--===| INIT ER |=========================================================================
function A333_elec_ecmu_init_ER()



end




--===| INIT CD |=========================================================================
function A333_elec_ecmu_init_CD()



end




--===| DEFERRED INITIALIZATION |=========================================================
function A333_elec_bus_deferred_init()




end



--===| DEFERRED PROCESSING |=============================================================
function A333_elec_ecmu_deferred_processing()



end




--=== AIRCRAFT LOAD =====================================================================
function A333_elec_ecmu_aircraft_load()



end



--=== FLIGHT START ======================================================================
function A333_elec_ecmu_flight_start()



end



--=== BEFORE PHYSICS ====================================================================
function A333_elec_ecmu_before_physics()



end



--=== AFTER PHYSICS =====================================================================
function A333_elec_ecmu_after_physics()

    A333_elec_ecmu_cache_globals()

    A333_elec_ecmu_apu_gen_avail()
    A333_elec_ecmu_exta_gen_avail()
    A333_elec_ecmu_extb_gen_avail()

    A333_elec_ecmu_ac_power_source_supply()

    A333_elec_ecmu_ac_ess_general_switching()

    A333_elec_ecmu_dc_normal_generation_switching()

    A333_elec_ecmu_bus_tie_manager()
    
    A333_elec_apu_door_motor_amps()
    A333_elec_apu_starter_motor_amps()

    A333_elec_ecmu_update_contacts()

    A333_elec_ecmu_essential_bus_ties()
    
    A333_elec_ecmu_update_datarefs()

end




--=== FLIGHT CRASH ======================================================================
function A333_elec_ecmu_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_elec_ecmu_aircraft_unload()



end




--=== AIRCRAFT UNLOAD ===================================================================
function A333_elec_ecmu_after_replay()

    A333_elec_ecmu_cache_globals()

    A333_elec_ecmu_apu_gen_avail()
    A333_elec_ecmu_exta_gen_avail()
    A333_elec_ecmu_extb_gen_avail()

    A333_elec_ecmu_ac_power_source_supply()

    A333_elec_ecmu_ac_ess_general_switching()

    A333_elec_ecmu_dc_normal_generation_switching()

    A333_elec_ecmu_bus_tie_manager()

    A333_elec_apu_door_motor_amps()
    A333_elec_apu_starter_motor_amps()

    A333_elec_ecmu_update_contacts()

    A333_elec_ecmu_essential_bus_ties()

    A333_elec_ecmu_update_datarefs()

end



--*************************************************************************************--
--** 				                 SUB-SCRIPT LOADING            	     			 **--
--*************************************************************************************--



