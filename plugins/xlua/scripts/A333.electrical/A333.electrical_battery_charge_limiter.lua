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

local apu_was_started = false




local bcl_data = {
    ["bcl1"] = { volts=0, amps=0, button_cntor_state=OPEN },
    ["bcl2"] = { volts=0, amps=0, button_cntor_state=OPEN  },
    ["apu_bcl"] = { volts=0, amps=0, button_cntor_state=OPEN  }
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

--==========| BATTERY CHARGE LIMITER |===================================================
local main_battery_charge_limiter = {}
main_battery_charge_limiter.__index = main_battery_charge_limiter

-- OBJECT CONSTRUCTOR -------------------------------------------------------------------
function main_battery_charge_limiter.new(name, id)

    local self = setmetatable({}, main_battery_charge_limiter)

    -- CLASS PROPERTIES -----------------------------------------------------------------
    self.name = name
    self.id = id

    self.battery_volts = 0
    self.battery_amps = 0
    self.battery_button_contactor_state = OPEN
    self.battery_contactor_control_signal = OPEN
    self.battery_charge_lo_current_limit = 0
    self.battery_charge_hi_current_limit = 0
    self.battery_low_volt_16seconds = false
    self.battery_complete_discharge = {
        verification = function()
            if self.battery_button_contactor_state == CLOSED
                and on_ground
                and self:power_supply_cutoff()
                and self.battery_volts < 23.0
            then
                self.battery_low_volt_16seconds = true
            end
        end,
        stop_verification = function()
            if is_timer_scheduled(self.battery_complete_discharge.verification) then
                stop_timer(self.battery_complete_discharge.verification)
            end
            self.battery_low_volt_16seconds = false
        end
    }
    self.battery_charge = {
        in_progress = false,
        stop_delay_time_seconds = 0,
        last_stop_delay_time_seconds = 0,
        stop = function()
            self.battery_charge.in_progress = false
            self.battery_charge.stop_delay_time_seconds = 0
            self.battery_charge.last_stop_delay_time_seconds = 0
        end
    }

    return self

end


-- CLASS METHODS ------------------------------------------------------------------------
function main_battery_charge_limiter.inputs(self)
    self.battery_button_contactor_state = bcl_data[self.name].button_cntor_state
    self.battery_volts = bcl_data[self.name].volts
    self.battery_amps = bcl_data[self.name].amps
end




function main_battery_charge_limiter.battery_only_supply_on_grnd(self)

    return on_ground
        and simDR_ind_airspeed < 50
        and tr1_contactor.pos == OPEN
        and tr2_contactor.pos == OPEN
        and ess_tr_contactor.pos == OPEN

end




function main_battery_charge_limiter.battery_only_supply_in_flt(self)

    return not on_ground
        and tr1_contactor.pos == OPEN
        and tr2_contactor.pos == OPEN
        and ess_tr_contactor.pos == OPEN

end




function main_battery_charge_limiter.apu_start(self)
    return simDR_elec_apu_switch == 2
end




function main_battery_charge_limiter.battery_charging(self)

    if not self.battery_charge.in_progress then

        if self.battery_volts < 26.5 then

            if (dc1_tie_contactor.pos == CLOSED or dc2_tie_contactor == CLOSED)
                and A333DR_dc_bat_bus_has_power == 1

            then -- We have sufficient DC power to charge the battery

                if is_timer_scheduled(self.battery_charge.stop) then
                    stop_timer(self.battery_charge.stop)
                end

                self.battery_charge.in_progress = true

            end

        end


    elseif self.battery_charge.in_progress then

        -- CHARGING COMPLETED
        if self.battery_volts >= simDR_acf_nom_bat_volt then

            if is_timer_scheduled(self.battery_charge.begin) then
                stop_timer(self.battery_charge.begin)
            end

            if not is_timer_scheduled(self.battery_charge.stop) then
                if on_ground then
                    self.battery_charge.stop_delay_time_seconds = 10.0

                elseif not on_ground or apu_was_started then
                    self.battery_charge.stop_delay_time_seconds = 1800.0
                    apu_was_started = false
                end
                run_after_time(self.battery_charge.stop, self.battery_charge.stop_delay_time_seconds)
            end

        end

    end

    return self.battery_charge.in_progress

end




function main_battery_charge_limiter.power_supply_cutoff()

    return A333DR_ac_bus1_volts <= 0
        and A333DR_ac_bus2_volts <= 0

end




function main_battery_charge_limiter.discharge_protection(self)

    if self.battery_button_contactor_state == OPEN then
        if is_timer_scheduled(self.battery_complete_discharge.verification) then
            stop_timer(self.battery_complete_discharge.verification)
        end
        self.battery_low_volt_16seconds = false


    elseif self.battery_button_contactor_state == CLOSED
        and on_ground
        and self:power_supply_cutoff()
        and self.battery_volts < 23.0

    then
        if not self.battery_low_volt_16seconds then
            if not (is_timer_scheduled(self.battery_complete_discharge.verification)) then
                run_after_time(self.battery_complete_discharge.verification, 16.0)
            end
        end
    end

    return self.battery_low_volt_16seconds

end




function main_battery_charge_limiter.battery_contactor_control(self)

    self.battery_contactor_control_signal = (self.battery_button_contactor_state == CLOSED
        and (self:battery_only_supply_on_grnd()
        or self:battery_only_supply_in_flt()
        or self:apu_start()
        or self:battery_charging())
        and not self:discharge_protection())
        and 1 or 0

    if self.name == "bcl1" then A333DR_bat1_is_charging = bat_is_charging and 1 or 0 end
    if self.name == "bcl2" then A333DR_bat2_is_charging = bat_is_charging and 1 or 0 end

end




function main_battery_charge_limiter.rat_csmg_fault_control(self)

    --[[
    In case of AC normal busbars failure (loss of AC main generation) the
    red FAULT legend of the EMER GEN pushbutton switch on the ELEC
    EMER PWR section of the overhead panel comes on until the
    emergency generator is available (operational). The FAULT legend is
    inhibited when the landing gear is extended.
    --]]

    A333DR_elec_emer_gen_fault =
        (elec_emer_config
        and ess_tr_contactor.pos == OPEN    -- TODO: CHANGE TO EMER_GEN NOT ONLINE WHEN CODE IS READY
        and simDR_nose_gear_deploy_status == 0
        and simDR_left_gear_deploy_status == 0
        and simDR_right_gear_deploy_status == 0)
        and ON or OFF

end




function main_battery_charge_limiter.update(self)

    self:inputs()
    self:battery_contactor_control()
    self:rat_csmg_fault_control()

end






--==========| APU BATTERY CHARGE LIMITER |===============================================
local apu_battery_charge_limiter = {}
apu_battery_charge_limiter.__index = apu_battery_charge_limiter

-- OBJECT CONSTRUCTOR -------------------------------------------------------------------
function apu_battery_charge_limiter.new(name, id)

    local self = setmetatable({}, apu_battery_charge_limiter)

    -- CLASS PROPERTIES -----------------------------------------------------------------
    self.name = name
    self.id = id
    self.battery_volts = 0
    self.battery_amps = 0
    self.battery_button_contactor_state = OPEN
    self.battery_contactor_control_signal = 0

    self.battery_charge = {
        in_progress = false,
        begin = function()
            self.battery_charge.in_progress = true
        end,
        stop = function()
            if is_timer_scheduled(self.battery_charge.begin) then
                stop_timer(self.battery_charge.begin)
            end
            self.battery_charge.in_progress = false
        end
    }

    self.battery_complete_discharge = {
        verification = {
            at_9_5v_for_1_5s = false,
            timer_9_5v_for_1_5s = function()
                self.battery_complete_discharge.verification.at_9_5v_for_1_5s = true
            end,
            stop_9_5v_for_1_5s = function()
                if is_timer_scheduled(self.battery_complete_discharge.verification.timer_9_5v_for_1_5s) then
                    stop_timer(self.battery_complete_discharge.verification.timer_9_5v_for_1_5s)
                end
                self.battery_complete_discharge.verification.at_9_5v_for_1_5s = false
            end,
            at_12v_for_15s = false,
            timer_12v_for_15s = function()
                self.battery_complete_discharge.verification.at_12v_for_15s = true
            end,
            stop_12v_for_15s = function()
                if is_timer_scheduled(self.battery_complete_discharge.verification.timer_12v_for_15s) then
                    stop_timer(self.battery_complete_discharge.verification.timer_12v_for_15s)
                end
                self.battery_complete_discharge.verification.at_12v_for_15s = false
            end
        }
    }

    return self

end



function apu_battery_charge_limiter.inputs(self)

    self.battery_button_contactor_state = bcl_data[self.name].button_cntor_state
    self.battery_volts = bcl_data[self.name].volts
    self.battery_amps = bcl_data[self.name].amps

end




function apu_battery_charge_limiter.battery_charge_reqd(self)

    if not self.battery_charge.in_progress then             -- BATTERY CHARGE CYCLE BEGIN
        if self.battery_volts < 26.5						-- Battery low voltage threshold
            and dc_apu_bat_bus.volts > 27.0					    -- DC battery bus power required for charging
        then
            if not is_timer_scheduled(self.battery_charge.begin) then
                run_after_time(self.battery_charge.begin, 0.225)
            end
        end

    else                                                    -- BATTERY CHARGE CYCLE END
        if self.battery_volts > simDR_acf_nom_bat_volt then
            self.battery_charge:stop()

        end
    end

    return self.battery_charge.in_progress

end




function apu_battery_charge_limiter.complete_discharge(self)

    if self.battery_button_contactor_state == OPEN then
        if self.battery_complete_discharge.verification.at_12v_for_15s == true then self.battery_complete_discharge.verification.at_12v_for_15s = false end
        if self.battery_complete_discharge.verification.at_9_5v_for_1_5s == true then self.battery_complete_discharge.verification.at_9_5v_for_1_5s = false end


    elseif self.battery_button_contactor_state == CLOSED then

        if self.battery_volts < 12.0 then
            if not (is_timer_scheduled(self.battery_complete_discharge.verification.timer_12v_for_15s)) then
                run_after_time(self.battery_complete_discharge.verification.timer_12v_for_15s, 15.0)
            end
        end

        if self.battery_volts < 9.5 then
            if not (is_timer_scheduled(self.battery_complete_discharge.verification.timer_9_5v_for_1_5s)) then
                run_after_time(self.battery_complete_discharge.verification.timer_9_5v_for_1_5s, 1.5)
            end
        end

    end

    return self.battery_complete_discharge.verification.at_12v_for_15s or self.battery_complete_discharge.verification.at_9_5v_for_1_5s

end



function apu_battery_charge_limiter.apu_start_sequence_initiated(self)
    return simDR_elec_apu_switch == 2
end




function apu_battery_charge_limiter.battery_contactor_control(self)

    if self.battery_button_contactor_state == OPEN then
        self.battery_charge:stop()
        self.battery_complete_discharge.verification:stop_9_5v_for_1_5s()
        self.battery_complete_discharge.verification:stop_12v_for_15s()
        self.battery_contactor_control_signal = OPEN

    elseif (self.battery_button_contactor_state == CLOSED)
        and ((self:battery_charge_reqd() or self:apu_start_sequence_initiated())
        and not(self:complete_discharge()))
    then
        self.battery_contactor_control_signal = CLOSED
    else
        self.battery_contactor_control_signal = OPEN
    end

    local bat_is_charging = self.battery_contactor_control_signal == 1
        and self:battery_charge_reqd()
        and (simDR_elec_bus5_volts > ac_min_volts)

    A333DR_apu_bat_is_charging = bat_is_charging and 1 or 0

end




function apu_battery_charge_limiter.update(self)

    self:inputs()
    self:battery_contactor_control()

end








--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--
bcl1 = main_battery_charge_limiter.new("bcl1", "1PB1")
bcl2 = main_battery_charge_limiter.new("bcl2", "1PB2")

apu_bcl = apu_battery_charge_limiter.new("apu_bcl", "1PB3")



--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--
local function A333_elec_bcl_cache_globals()

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



local function A333_update_bcl1()
    return simDR_elec_bat1_volts, simDR_elec_bat1_amps, A333_bat1_button_ctct_open_closed
end



local function A333_update_bcl2()
    return simDR_elec_bat2_volts, simDR_elec_bat2_amps, A333_bat2_button_ctct_open_closed
end



local function A333_update_apu_bcl()
    return simDR_elec_bat3_volts, simDR_elec_bat3_amps, A333_apu_bat_button_ctct_open_closed
end



local function A333_elec_bcl_update_data()

    if simDR_elec_apu_switch == 2 then apu_was_started = true end

    bcl_data.bcl1.volts, bcl_data.bcl1.amps, bcl_data.bcl1.button_cntor_state = A333_update_bcl1()
    bcl_data.bcl2.volts, bcl_data.bcl2.amps, bcl_data.bcl2.button_cntor_state = A333_update_bcl2()
    bcl_data.apu_bcl.volts, bcl_data.apu_bcl.amps, bcl_data.apu_bcl.button_cntor_state = A333_update_apu_bcl()

end



--*************************************************************************************--
--** 				                     PROCESSING             	    			 **--
--*************************************************************************************--

--===| INIT ALL |========================================================================
function A333_elec_bcl_init_all()



end




--===| INIT ER |=========================================================================
function A333_elec_bcl_init_ER()



end




--===| INIT CD |=========================================================================
function A333_elec_bcl_init_CD()



end




--===| DEFERRED INITIALIZATION |=========================================================
function A333_elec_bcl_deferred_init()




end



--===| DEFERRED PROCESSING |=============================================================
function A333_elec_bcl_deferred_processing()



end




--=== AIRCRAFT LOAD =====================================================================
function A333_elec_bcl_aircraft_load()



end



--=== FLIGHT START ======================================================================
function A333_elec_bcl_flight_start()

    apu_was_started = false

end



--=== BEFORE PHYSICS ====================================================================
function A333_elec_bcl_before_physics()



end



--=== AFTER PHYSICS =====================================================================
function A333_elec_bcl_after_physics()

    A333_elec_bcl_cache_globals()
    A333_elec_bcl_update_data()

    bcl1:update()
    bcl2:update()
    apu_bcl:update()

end




--=== FLIGHT CRASH ======================================================================
function A333_elec_bcl_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_elec_bcl_aircraft_unload()



end




--=== AIRCRAFT UNLOAD ===================================================================
function A333_elec_bus_after_replay()

    A333_elec_bcl_cache_globals()
    A333_elec_bcl_update_data()

    bcl1:update()
    bcl2:update()
    apu_bcl:update()

end



--*************************************************************************************--
--** 				                 SUB-SCRIPT LOADING            	     			 **--
--*************************************************************************************--



