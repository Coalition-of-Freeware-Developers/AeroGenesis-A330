--[[
*****************************************************************************************
* Program Script Name	:	A333.systems
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
local STD = 0
local FAST = 1

local OFF = 0
local NAV = 1
local ATT = 2
local ON = 1
local IN_PROGRESS = 1
local IN_PROGRESS_STD = 5
local IN_PROGRESS_FAST = 6

local ALIGNED = 99
local COMPLETE = 99





--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local sim_period = 0
local last_mode_sel_pos = {0, 0, 0}
local adirs_instant_align = false
local adirs_instant_align_timer = 0
local irIndex =  {["ir1"] = 1, ["ir2"] = 2, ["ir3"] = 3}
local irDRindex = {["ir1"] = 0, ["ir2"] = 1, ["ir3"] = 2}
local adrIndex = {["adr1"] = 1, ["adr2"] = 2, ["adr3"] = 3}
local adiru_ac_volts = { 0, 0, 0 }
local adiru_dc_volts = { 0, 0, 0 }
local ir_mode_sel_knob_pos = {0, 0, 0}
local ir_data_switch_status = {0, 0, 0}
local adr_data_switch_status = {0, 0, 0}





--*************************************************************************************--
--** 				            LOCAL UTILITY FUNCTIONS          			    	 **--
--*************************************************************************************--
local m = math

local function rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end



--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
simDR_startup_running = find_dataref("sim/operation/prefs/startup_running")
simDR_flight_time = find_dataref("sim/time/total_flight_time_sec")
simDR_pos_latitude = find_dataref("sim/flightmodel/position/latitude")

simDR_adc1_fail = find_dataref("sim/operation/failures/rel_adc_comp")
simDR_adc2_fail = find_dataref("sim/operation/failures/rel_adc_comp_2")
simDR_ahars1_fail = find_dataref("sim/operation/failures/rel_g_arthorz")
simDR_ahars2_fail = find_dataref("sim/operation/failures/rel_g_arthorz_2")
simDR_lrn1_fail = find_dataref("sim/operation/failures/rel_lrn1")
simDR_lrn2_fail = find_dataref("sim/operation/failures/rel_lrn2")



--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--
A333_adirs_ir1_knob_pos	= find_dataref("laminar/A333/buttons/adirs/ir1_knob_pos")       -- Set in switches.lua
A333_adirs_ir2_knob_pos	= find_dataref("laminar/A333/buttons/adirs/ir2_knob_pos")       -- Set in switches.lua
A333_adirs_ir3_knob_pos	= find_dataref("laminar/A333/buttons/adirs/ir3_knob_pos")       -- Set in switches.lua

A333_adirs_ir1_data_status = find_dataref("laminar/A333/adirs/ir1_status")              -- Set in switches.lua
A333_adirs_ir2_data_status = find_dataref("laminar/A333/adirs/ir2_status")              -- Set in switches.lua
A333_adirs_ir3_data_status = find_dataref("laminar/A333/adirs/ir3_status")              -- Set in switches.lua

A333_adirs_adr1_data_status = find_dataref("laminar/A333/adirs/adr1_status")            -- Set in switches.lua
A333_adirs_adr2_data_status = find_dataref("laminar/A333/adirs/adr2_status")            -- Set in switches.lua
A333_adirs_adr3_data_status = find_dataref("laminar/A333/adirs/adr3_status")            -- Set in switches.lua

A333DR_ac_bus1_volts = find_dataref("laminar/A333/elec/ac_bus1_volts")
A333DR_ac_bus2_volts = find_dataref("laminar/A333/elec/ac_bus2_volts")
A333DR_ac_ess_bus_volts = find_dataref("laminar/A333/elec/ac_ess_bus_volts")
A333DR_dc_bat1_hot_bus_volts = find_dataref("laminar/A333/elec/dc_hot_bus1_volts")
A333DR_dc_bat2_hot_bus_volts = find_dataref("laminar/A333/elec/dc_hot_bus2_volts")

A333DR_ac_min_volts = find_dataref("laminar/A333/elec/ac_min_volts")
A333DR_dc_min_volts = find_dataref("laminar/A333/elec/dc_min_volts")

A333DR_elec_ac_dc_transform_factor = find_dataref("laminar/A333/elec/ac_dc_transform_factor")
A333DR_elec_dc_ac_inversion_factor = find_dataref("laminar/A333/elec/dc_ac_transform_factor")


--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
A333DR_adirs_ir_align_fast_mode_override = create_dataref("laminar/A333/adirs/align_mode_override", "array[3]")    -- Set in switches
A333_adirs_on_bat_status = create_dataref("laminar/A333/adirs/on_bat_status", "number")    -- Used in annun

A333DR_adirs1_align_time = create_dataref("laminar/A333/adirs1/align_time", "array[3]")      -- Used in FWS
A333DR_adirs2_align_time = create_dataref("laminar/A333/adirs2/align_time", "array[3]")      -- Used in FWS
A333DR_adirs3_align_time = create_dataref("laminar/A333/adirs3/align_time", "array[3]")      -- Used in FWS
A333DR_adirs_ir_align_status = create_dataref("laminar/A333/adirs/align_status", "array[3]")           -- Used in FWS

A333DR_init_adirs_CD = create_dataref("laminar/A333/init_CD/adirs", "number")              -- set by AI

A333DR_adiru1_adr_status = create_dataref("laminar/A333/adiru1/adr_status", "number")
A333DR_adiru1_att_status = create_dataref("laminar/A333/adiru1/att_status", "number")
A333DR_adiru1_hdg_status = create_dataref("laminar/A333/adiru1/hdg_status", "number")
A333DR_adiru1_lrn_status = create_dataref("laminar/A333/adiru1/lrn_status", "number")

A333DR_adiru2_adr_status = create_dataref("laminar/A333/adiru2/adr_status", "number")
A333DR_adiru2_att_status = create_dataref("laminar/A333/adiru2/att_status", "number")
A333DR_adiru2_hdg_status = create_dataref("laminar/A333/adiru2/hdg_status", "number")
A333DR_adiru2_lrn_status = create_dataref("laminar/A333/adiru2/lrn_status", "number")

A333DR_adiru3_adr_status = create_dataref("laminar/A333/adiru3/adr_status", "number")
A333DR_adiru3_att_status = create_dataref("laminar/A333/adiru3/att_status", "number")
A333DR_adiru3_hdg_status = create_dataref("laminar/A333/adiru3/hdg_status", "number")
A333DR_adiru3_lrn_status = create_dataref("laminar/A333/adiru3/lrn_status", "number")



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
--** 				               REPLACE X-PLANE COMMANDS                   	     **--
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
local function A333_adirs_instant_align_CMDhandler(phase, _)
    if phase == 0 then
        adirs_instant_align = true
    end
end



local function A333_ai_adirs_quick_start_CMDhandler(phase, _)
    if phase == 0 then
        A333_set_adirs_all_modes()
        A333_set_adirs_CD()
        A333_set_adirs_ER()
    end
end



--*************************************************************************************--
--** 				                 CUSTOM COMMANDS                			     **--
--*************************************************************************************--
A333CMD_instant_irs_align = create_command("laminar/A333/adirs_instant_align", "Align ADIRS Instantly", A333_adirs_instant_align_CMDhandler)
A333CMD_ai_adirs_quick_start = create_command("laminar/A333/ai/adirs_quick_start", "AI ADIRS", A333_ai_adirs_quick_start_CMDhandler)



--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--

--===| ADR |=============================================================================
local adr = {}
adr.__index = adr

-- OBJECT CONSTRUCTOR
function adr.new(name)

    local self = setmetatable({}, adr)

    -- CLASS PROPERTIES
    self.name = name
    self.power = 0
    self.data_output_switch = OFF         -- 0=OFF, 1=ON

    self.init = {
        status = OFF,                     -- 0=OFF, 1=IN_PROGRESS, 99=COMPLETE
        timer_duration = 10,
        timer = function()
            self.init.status = COMPLETE
        end,
        timer_stop = function()
            if is_timer_scheduled(self.init.timer) then
                stop_timer(self.init.timer)
            end
            self.init.status = OFF
        end
    }

    self.fail = {
        is_adr_controlled = true,
    }
    self.is_failed = false
    self.last_is_failed = false

    return self

end


-- CLASS METHODS
function adr.control_status(self)
    self.data_output_switch = adr_data_switch_status[adrIndex[self.name]]
end




function adr.power_supply(self)
    self.power = (ir_mode_sel_knob_pos[adrIndex[self.name]] > 0) and adiru_ac_volts[adrIndex[self.name]] or 0
end




function adr.initialize(self)

    if self.power > A333DR_ac_min_volts then

        if adirs_instant_align then

            if self.name == "adr1" then
                simDR_adc1_fail = 0
            elseif self.name == "adr2" then
                simDR_adc2_fail = 0
            end
            self.init:timer_stop()
            self.init.status = COMPLETE

        else
            if self.init.status == OFF then

                if self.name == "adr1" then
                    simDR_adc1_fail = 0
                elseif self.name == "adr2" then
                    simDR_adc2_fail = 0
                end

                if not is_timer_scheduled(self.init.timer) then
                    local _, frac = m.modf(os.clock())
                    local seed = m.random(1, frac*1000.0)
                    m.randomseed(seed)
                    self.init.timer_duration = m.random(7, 10)
                    run_after_time(self.init.timer, self.init.timer_duration)
                    self.init.status = IN_PROGRESS
                end

            end
        end
    else
        self.init:timer_stop()

    end

end




function adr.failure_control(self)

    if self.init.status < COMPLETE
        or self.data_output_switch == 0
    then

        if self.name == "adr1" then
            simDR_adc1_fail = 6
        end
        if self.name == "adr2" then simDR_adc2_fail = 6 end
        self.is_failed = true
        self.fail.is_adr_controlled = true

    elseif self.init.status == COMPLETE
        and self.data_output_switch == 1
    then

        if self.fail.is_adr_controlled then
            if self.name == "adr1" then
                simDR_adc1_fail = 0
            end
            if self.name == "adr2" then simDR_adc2_fail = 0 end
            self.is_failed = false
            self.fail.is_adr_controlled = false
        end

    end


    if (not self.fail.is_adr_controlled) then

        if self.name == "adr1" then
            self.is_failed = simDR_adc1_fail == 6

            if (not self.is_failed) and self.last_is_failed then
                self.init.status = OFF                          -- Init is failure has been reset
            end

            self.last_is_failed = self.is_failed

        end

        if self.name == "adr2" then
            self.is_failed = simDR_adc2_fail == 6

            if (not self.is_failed) and self.last_is_failed then
                self.init.status = OFF                          -- Init is failure has been reset
            end

            self.last_is_failed = self.is_failed

        end

    end

end




function adr.update(self)

    self:control_status()
    self:power_supply()
    self:initialize()
    self:failure_control()

end


--===| END ADR |=========================================================================





--===| IR |==============================================================================
local ir = {}
ir.__index = ir

-- OBJECT CONSTRUCTOR
function ir.new(name)

    local self = setmetatable({}, ir)

    -- CLASS PROPERTIES
    self.name = name
    self.power = 0
    self.mode_sel_knob_pos = OFF            -- 0=OFF, 1=NAV, 2=ATT
    self.data_output_switch = OFF           -- 0=OFF, 1=ON

    self.init = {
        status = OFF,                       -- 0=OFF, 1=IN_PROGRESS, 99=COMPLETE
        power_off = OFF                     -- 0=OFF, 1=IN_PROGRESS, 99=COMPLETE
    }

    self.align = {
        duration = 600.0,
        status = OFF,                       -- 0=OFF, 5=IN PROGRESS(STD), 6=IN PROGRESS(30), 99=ALIGNED
        mode = STD,                         -- STD=alignment time is per Aibus docs (let/lon dependent), FAST=30 seconds
        mode_override = {
            timer = function()
                self.align.mode = STD
                A333DR_adirs_ir_align_fast_mode_override[irDRindex[self.name]] = 0
            end,
            timer_stop = function()
                if is_timer_scheduled(self.align.mode_override.timer) then
                    stop_timer(self.align.mode_override.timer)
                end
                self.align.status = OFF
                self.align.mode = STD
            end,
        },
        fast = {
            duration = 30.0,
            timer = function()
                self.align.status = ALIGNED
            end,
            timer_stop = function()
                if is_timer_scheduled(self.align.fast.timer) then
                    stop_timer(self.align.fast.timer)
                end
                self.align.status = OFF
            end,
            elapsed_time = 0
        },
        std = {
        duration = 600.0,
        timer = function()
            self.align.status = ALIGNED
        end,
        timer_stop = function()
            if is_timer_scheduled(self.align.std.timer) then
                stop_timer(self.align.std.timer)
            end
            self.align.status = OFF
        end,
        elapsed_time = 0
        }
    }

    self.on_bat = {
        test = {
           status = OFF,                    -- 0=OFF, 1=IN_PROGRESS, 99=COMPLETE
           timer = function()
               self.on_bat.test.status = COMPLETE
           end,
           timer_stop = function()
               if is_timer_scheduled(self.on_bat.test.timer) then
                   stop_timer(self.on_bat.test.timer)
               end
               self.on_bat.test.status = OFF
           end
        },
        supply = OFF                        -- 0=OFF, 1=ON
    }

    self.fail = {
        ahars = {
            is_ir_controlled = true
        },
        lrn = {
            is_ir_controlled = true
        }
    }
    self.ahars_is_failed = false
    self.last_ahars_is_failed = false
    self.lrn_is_failed = false
    self.last_lrn_is_failed = false

    return self

end


-- CLASS METHODS
function ir.control_status(self)

    self.mode_sel_knob_pos = ir_mode_sel_knob_pos[irIndex[self.name]]
    self.data_output_switch = ir_data_switch_status[irIndex[self.name]]

    if last_mode_sel_pos[irIndex[self.name]] == OFF and self.mode_sel_knob_pos > OFF then
        self.init.status = OFF
    end

    if last_mode_sel_pos[irIndex[self.name]] > OFF and self.mode_sel_knob_pos == OFF then
        self.init.power_off = OFF
    end

    last_mode_sel_pos[irIndex[self.name]] = self.mode_sel_knob_pos

end




function ir.power_supply(self)

    self.power = self.mode_sel_knob_pos > 0
        and m.max(adiru_ac_volts[irIndex[self.name]] * A333DR_elec_ac_dc_transform_factor, adiru_dc_volts[irIndex[self.name]]) or 0

end




function ir.init_alignment_duration(self)
    
        local latitude = m.abs(simDR_pos_latitude)

        --| FAST ALIGN
        local _, frac = m.modf(os.clock())
        local seed = m.random(1, frac*1000.0) + m.random(5,10) + frac
        m.randomseed(seed)
        self.align.fast.duration = 30.0 + m.random(-2, 2) + frac


        --| STANDARD ALIGN
        local base_align_time = 0

        if latitude < 73.0 then
            base_align_time = rescale(0, 300, 73.0, 600, latitude)

        elseif latitude >= 73.0 and latitude <= 82.0 then
            base_align_time = 960

        else
            base_align_time = 999999.99  -- ADIRS cannot be aligned
        end

        local _, frac = m.modf(os.clock())
        local seed = m.random(1, frac*1000.0) + m.random(5, 10) + frac
        m.randomseed(seed)
        self.align.std.duration = base_align_time + m.random(-6, 6) + frac
    
end




function ir.initialize(self)

    if self.power > A333DR_dc_min_volts then

        if self.init.status == OFF then

            self.init.status = IN_PROGRESS

            if self.name == "ir1" then
                simDR_ahars1_fail = 0
                simDR_lrn1_fail = 0
                A333DR_adirs_ir_align_fast_mode_override[0] = 0

            elseif self.name == "ir2" then
                simDR_ahars2_fail = 0
                simDR_lrn2_fail = 0
                A333DR_adirs_ir_align_fast_mode_override[1] = 0

            elseif self.name == "ir3" then
                A333DR_adirs_ir_align_fast_mode_override[2] = 0
            end

            self.align.status = OFF
            self.align.mode = STD
            self.align.fast.timer_stop()
            self.align.fast.duration = 30.0
            self.align.std.timer_stop()
            self.align.std.duration = 600.0
            self:init_alignment_duration()
            self.align.std.elapsed_time = 0
            self.on_bat.test:timer_stop()
            self.on_bat.supply = OFF
            self.fail.is_adr_controlled = true
            self.is_failed = false

            self.init.status = COMPLETE

        end

    else
        if self.init.power_off == OFF then

            self.init.power_off = IN_PROGRESS

            if self.name == "ir1" then
                simDR_ahars1_fail = 0
                simDR_lrn1_fail = 0

            elseif self.name == "ir2" then
                simDR_ahars2_fail = 0
                simDR_lrn2_fail = 0
            end

            self.align.status = OFF
            self.align.mode = STD
            self.align.fast.timer_stop()
            self.align.fast.duration = 30.0
            self.align.std.timer_stop()
            self.align.std.duration = 600.0
            self.align.fast.elapsed_time = 0
            self.align.std.elapsed_time = 0
            self.on_bat.test:timer_stop()
            self.on_bat.supply = OFF
            self.fail.is_adr_controlled = true
            self.is_failed = false

            self.init.power_off = 99

        end

    end

end




function ir.align_mode_override(self)

    local align_mode_fast_override = A333DR_adirs_ir_align_fast_mode_override       -- Set in switches.lua

    if self.mode_sel_knob_pos == OFF then

        if align_mode_fast_override[irDRindex[self.name]] == ON then             
            if not is_timer_scheduled(self.align.mode_override.timer) then
                run_after_time(self.align.mode_override.timer, 5)                   -- Disallow FAST mode after 5 seconds
            end
        end


    elseif self.mode_sel_knob_pos == NAV then

        if align_mode_fast_override[irDRindex[self.name]] == ON then
            if is_timer_scheduled(self.align.mode_override.timer) then
                self.align.mode_override:timer_stop()
            end
            self.align.mode = FAST
            A333DR_adirs_ir_align_fast_mode_override[irDRindex[self.name]] = OFF

        end

    end

end




function ir.alignment(self)

    local latitude = m.abs(simDR_pos_latitude)

    if latitude <= 82.0 then                -- Latitude must be <= 82.0 (North or South) in order to align IRS

        if self.power > A333DR_dc_min_volts then

            if adirs_instant_align then

                if self.align.status < COMPLETE then
                    self.align.mode_override:timer_stop()
                    self.align.fast:timer_stop()
                    self.align.fast.elapsed_time = self.align.fast.duration
                    self.align.std:timer_stop()
                    self.align.std.elapsed_time = self.align.std.duration
                    self.align.status = COMPLETE

                end

            else
                if self.init.status == COMPLETE then

                    if self.mode_sel_knob_pos == NAV then

                        if self.align.status == OFF then

                            if self.align.mode == FAST then
                                self.align.std:timer_stop()
                                if not is_timer_scheduled(self.align.fast.timer) then
                                    run_after_time(self.align.fast.timer, self.align.fast.duration)
                                    self.align.status = IN_PROGRESS_FAST
                                end

                            elseif self.align.mode == STD then
                                self.align.fast:timer_stop()
                                if is_timer_scheduled(self.align.std.timer) then
                                    stop_timer(self.align.std.timer)
                                end
                                if not is_timer_scheduled(self.align.std.timer) then
                                    run_after_time(self.align.std.timer, self.align.std.duration)
                                    self.align.status = IN_PROGRESS_STD
                                end
                            end -- self.align.mode

                        end -- self.align.status

                    else
                        self.align.fast:timer_stop()
                        self.align.std:timer_stop()

                    end -- self.mode_sel_knob_pos

                end -- self.init.status check

            end -- adirs_instant_align check

        end -- self.power

    else

        if self.align.status > OFF then
            self.align.mode_override:timer_stop()
            self.align:timerFast_stop()
            self.align:timerStd_stop()
        end

    end -- Latitude check

end




function ir.align_elapsed_time(self)

    if is_timer_scheduled(self.align.std.timer) then
        self.align.std.elapsed_time = self.align.std.duration - get_timer_remaining(self.align.std.timer)
    end

    if is_timer_scheduled(self.align.fast.timer) then
        self.align.fast.elapsed_time = self.align.fast.duration - get_timer_remaining(self.align.fast.timer)
    end

end





function ir.on_bat_test(self)

    if self.power > 0 then

        if (self.align.status == IN_PROGRESS_FAST or self.align.status == IN_PROGRESS_STD)
            and self.on_bat.test.status == OFF
        then
            self.on_bat.test.status = IN_PROGRESS
            if not is_timer_scheduled(self.on_bat.test.timer) then
                run_after_time(self.on_bat.test.timer, 5.0)
            end
        end
    else
        self.on_bat.test:timer_stop()
    end

end




function ir.on_bat_supply(self)

    self.on_bat.supply = self.mode_sel_knob_pos > OFF
        and ((self.on_bat.test.status == IN_PROGRESS)
        or (((adiru_ac_volts[irIndex[self.name]] * 0.243478) <= 0) and (adiru_dc_volts[irIndex[self.name]] > 0)))
        and ON or OFF

end




function ir.ahars_failure_control(self)

    if ((self.align.mode == STD and self.align.std.elapsed_time < 30.0)
        or (self.align.mode == FAST and self.align.status < ALIGNED)
        or (self.data_output_switch == 0))
    then
        if self.name == "ir1" then simDR_ahars1_fail = 6 end
        if self.name == "ir2" then simDR_ahars2_fail = 6 end
        self.ahars_is_failed = true
        self.fail.ahars.is_ir_controlled = true

    elseif (((self.align.mode == STD and self.align.std.elapsed_time >= 30.0)
        or (self.align.mode == FAST and self.align.status == ALIGNED))
        and (self.data_output_switch == 1))
    then
        if self.fail.ahars.is_ir_controlled then
            if self.name == "ir1" then simDR_ahars1_fail = 0 end
            if self.name == "ir2" then simDR_ahars2_fail = 0 end
            self.ahars_is_failed = false
            self.fail.ahars.is_ir_controlled = false
        end
    end

    if self.name == "ir1" then
        self.ahars_is_failed = ((not self.fail.ahars.is_ir_controlled) and simDR_ahars1_fail == 6)

    elseif self.name == "ir2" then
        self.ahars_is_failed = ((not self.fail.ahars.is_ir_controlled) and simDR_ahars2_fail == 6)

    end

end




function ir.lrn_failure_control(self)

    if self.align.status < ALIGNED
        or self.data_output_switch == 0
    then
        if self.name == "ir1" then simDR_lrn1_fail = 6 end
        if self.name == "ir2" then simDR_lrn2_fail = 6 end
        self.lrn_is_failed = true
        self.fail.lrn.is_ir_controlled = true

    elseif self.align.status == ALIGNED
        and self.data_output_switch == 1
    then
        if self.fail.lrn.is_ir_controlled then
            if self.name == "ir1" then simDR_lrn1_fail = 0 end
            if self.name == "ir2" then simDR_lrn2_fail = 0 end
            self.lrn_is_failed = false
            self.fail.lrn.is_ir_controlled = false
        end
    end

    if self.name == "ir1" then
        self.lrn_is_failed = ((not self.fail.lrn.is_ir_controlled) and simDR_lrn1_fail == 6)

    elseif self.name == "ir2" then
        self.lrn_is_failed = ((not self.fail.lrn.is_ir_controlled) and simDR_lrn2_fail == 6)

    end

end




function ir.update(self)

    self:control_status()
    self:power_supply()
    self:initialize()
    self:align_mode_override()
    self:alignment()
    self:align_elapsed_time()
    self:on_bat_test()
    self:on_bat_supply()
    self:ahars_failure_control()
    self:lrn_failure_control()

end



--===| END IR |==========================================================================





--===| ADIRU |===========================================================================
local adiru = {}
adiru.__index = adiru

-- OBJECT CONSTRUCTOR
function adiru.new(name)

    local self = setmetatable({}, adiru)

    -- CLASS PROPERTIES
    self.name = name
    self.AC_power = 0
    self.DC_power = 0

    if self.name == "adiru1" then
        self.adr = adr.new("adr1")
        self.ir = ir.new("ir1")
    elseif self.name == "adiru2" then
        self.adr = adr.new("adr2")
        self.ir = ir.new("ir2")
    elseif self.name == "adiru3" then
        self.adr = adr.new("adr3")
        self.ir = ir.new("ir3")
    end

    if self.name == "adiru2" then
        self.DC_power_control = {
            status = ON,
            timer = function()
                self.DC_power_control.status = OFF
            end,
            timer_stop = function()
                if is_timer_scheduled(self.DC_power_control.timer) then
                    stop_timer(self.DC_power_control.timer)
                end
                self.DC_power_control.status = ON
            end
        }
    end

    return self

end


-- CLASS METHODS
function adiru.power_supply(self)

    if self.name == "adiru1" then
        adiru_ac_volts[1] = ((A333DR_ac_ess_bus_volts > A333DR_ac_min_volts) and A333DR_ac_ess_bus_volts) or 0
        adiru_dc_volts[1] = ((A333DR_dc_bat1_hot_bus_volts >= A333DR_dc_min_volts) and A333DR_dc_bat1_hot_bus_volts) or 0 -- Hot battery backup
        self.AC_power = adiru_ac_volts[1]
        self.DC_power = adiru_dc_volts[1]


    elseif self.name == "adiru2" then

        adiru_ac_volts[2] = ((A333DR_ac_bus2_volts > A333DR_ac_min_volts) and A333DR_ac_bus2_volts) or 0

        if self.AC_power <= 0 then
            if A333DR_dc_bat2_hot_bus_volts >= A333DR_dc_min_volts then -- Hot battery backup
                if not is_timer_scheduled(self.DC_power_control.timer) then
                    run_after_time(self.DC_power_control.timer, 300.0) -- Hot battery backup supply is limited to 5 min
                end
            end
        else
            self.DC_power_control:timer_stop()
        end
        adiru_dc_volts[2] = ((self.DC_power_control.status == 1 and (A333DR_dc_bat2_hot_bus_volts >= A333DR_dc_min_volts)) and A333DR_dc_bat2_hot_bus_volts) or 0

        self.AC_power = adiru_ac_volts[2]
        self.DC_power = adiru_dc_volts[2]


    elseif self.name == "adiru3" then
        adiru_ac_volts[3] = (((A333DR_ac_bus1_volts > A333DR_ac_min_volts) and A333DR_ac_bus1_volts) or (((A333DR_ac_bus1_volts < A333DR_ac_min_volts) and (A333DR_ac_ess_bus_volts > A333DR_ac_min_volts)) and A333DR_ac_ess_bus_volts)) or 0
        adiru_dc_volts[3] = ((A333DR_dc_bat2_hot_bus_volts >= A333DR_dc_min_volts) and A333DR_dc_bat2_hot_bus_volts) or 0 -- Hot battery backup
        self.AC_power = adiru_ac_volts[3]
        self.DC_power = adiru_dc_volts[3]
    end


end




function adiru.update(self)

    self:power_supply()
    self.adr:update()
    self.ir:update()

end



--===| END ADIRU |=======================================================================





--===| ADIRS |===========================================================================
local adirs = {}
adirs.__index = adirs

-- OBJECT CONSTRUCTOR
function adirs.new(name)

    local self = setmetatable({}, adirs)

    -- CLASS PROPERTIES
    self.name = name
    self.on_bat_status = OFF

    self.adiru1 = adiru.new("adiru1")
    self.adiru2 = adiru.new("adiru2")
    self.adiru3 = adiru.new("adiru3")

    return self

end


-- CLASS METHODS
function adirs.on_bat(self)
    self.on_bat_status = (self.adiru1.ir.on_bat.supply == ON or self.adiru2.ir.on_bat.supply == ON or self.adiru3.ir.on_bat.supply == ON) and ON or OFF
end




function adirs.update(self)

    self.adiru1:update()
    self.adiru2:update()
    self.adiru3:update()
    self:on_bat()

end





--===| END ADIRU |=======================================================================




--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--
local A333_adirs = adirs.new("A333_adirs")



--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--
local function A333_adirs_cache_globals()

    sim_period = SIM_PERIOD

    ir_data_switch_status[1] = A333_adirs_ir1_data_status
    ir_data_switch_status[2] = A333_adirs_ir2_data_status
    ir_data_switch_status[3] = A333_adirs_ir3_data_status

    ir_mode_sel_knob_pos[1] = A333_adirs_ir1_knob_pos
    ir_mode_sel_knob_pos[2] = A333_adirs_ir2_knob_pos
    ir_mode_sel_knob_pos[3] = A333_adirs_ir3_knob_pos

    adr_data_switch_status[1] = A333_adirs_adr1_data_status
    adr_data_switch_status[2] = A333_adirs_adr2_data_status
    adr_data_switch_status[3] = A333_adirs_adr3_data_status

end




local function A333_reset_instant_align()

    if adirs_instant_align then

        if A333_adirs.adiru1.ir.align.status == ALIGNED
            and A333_adirs.adiru1.adr.init.status == COMPLETE

            and A333_adirs.adiru2.ir.align.status == ALIGNED
            and A333_adirs.adiru2.adr.init.status == COMPLETE

            and A333_adirs.adiru3.ir.align.status == ALIGNED
            and A333_adirs.adiru3.adr.init.status == COMPLETE

        then
            adirs_instant_align_timer = adirs_instant_align_timer + sim_period

        end

    end

    if adirs_instant_align_timer > 0.3 then
        adirs_instant_align = false
        adirs_instant_align_timer = 0
    end

end





local function A333_adirs_dataref_update()

    A333_adirs_on_bat_status = A333_adirs.on_bat_status

    -- ADR
    A333DR_adiru1_adr_status = (A333_adirs.adiru1.adr.power > A333DR_ac_min_volts
        and A333_adirs.adiru1.adr.init.status == COMPLETE
        and (not A333_adirs.adiru1.adr.is_failed)
        and A333_adirs.adiru1.adr.data_output_switch == 1)
        and 1 or 0

    A333DR_adiru2_adr_status = (A333_adirs.adiru2.adr.power > A333DR_ac_min_volts
        and A333_adirs.adiru2.adr.init.status == COMPLETE
        and (not A333_adirs.adiru2.adr.is_failed)
        and A333_adirs.adiru2.adr.data_output_switch == 1)
        and 1 or 0

    A333DR_adiru3_adr_status = (A333_adirs.adiru3.adr.power > A333DR_ac_min_volts
        and A333_adirs.adiru3.adr.init.status == COMPLETE
        and (not A333_adirs.adiru3.adr.is_failed)
        and A333_adirs.adiru3.adr.data_output_switch == 1)
        and 1 or 0


    -- ATT
    A333DR_adiru1_att_status = (A333_adirs.adiru1.ir.power > A333DR_dc_min_volts
        and ((A333_adirs.adiru1.ir.align.mode == STD and A333_adirs.adiru1.ir.align.std.elapsed_time >= 30.0)
            or (A333_adirs.adiru1.ir.align.mode == FAST and A333_adirs.adiru1.ir.align.status == ALIGNED))
        and (not A333_adirs.adiru1.ir.ahars_is_failed)
        and A333_adirs.adiru1.ir.data_output_switch == 1)
        and 1 or 0

    A333DR_adiru2_att_status = (A333_adirs.adiru2.ir.power > A333DR_dc_min_volts
        and ((A333_adirs.adiru2.ir.align.mode == STD and A333_adirs.adiru2.ir.align.std.elapsed_time >= 30.0)
            or (A333_adirs.adiru2.ir.align.mode == FAST and A333_adirs.adiru2.ir.align.status == ALIGNED))
        and (not A333_adirs.adiru2.ir.ahars_is_failed)
        and A333_adirs.adiru2.ir.data_output_switch == 1)
        and 1 or 0

    A333DR_adiru3_att_status = (A333_adirs.adiru3.ir.power > A333DR_dc_min_volts
        and ((A333_adirs.adiru3.ir.align.mode == STD and A333_adirs.adiru3.ir.align.std.elapsed_time >= 30.0)
            or (A333_adirs.adiru3.ir.align.mode == FAST and A333_adirs.adiru3.ir.align.status == ALIGNED))
        and (not A333_adirs.adiru3.ir.ahars_is_failed)
        and A333_adirs.adiru3.ir.data_output_switch == 1)
        and 1 or 0


    -- HDG
    A333DR_adiru1_hdg_status = (A333_adirs.adiru1.ir.power > A333DR_dc_min_volts
        and ((A333_adirs.adiru1.ir.align.mode == STD and A333_adirs.adiru1.ir.align.std.elapsed_time > (A333_adirs.adiru1.ir.align.std.duration * 0.65))
            or (A333_adirs.adiru1.ir.align.mode == FAST and A333_adirs.adiru1.ir.align.status == ALIGNED))
        and (not A333_adirs.adiru1.ir.ahars_is_failed)
        and A333_adirs.adiru1.ir.data_output_switch == 1)
        and 1 or 0

    A333DR_adiru2_hdg_status = (A333_adirs.adiru2.ir.power > A333DR_dc_min_volts
        and ((A333_adirs.adiru2.ir.align.mode == STD and A333_adirs.adiru2.ir.align.std.elapsed_time > (A333_adirs.adiru2.ir.align.std.duration * 0.65))
            or (A333_adirs.adiru2.ir.align.mode == FAST and A333_adirs.adiru2.ir.align.status == ALIGNED))
        and (not A333_adirs.adiru2.ir.ahars_is_failed)
        and A333_adirs.adiru2.ir.data_output_switch == 1)
        and 1 or 0

    A333DR_adiru3_hdg_status = (A333_adirs.adiru3.ir.power > A333DR_dc_min_volts
        and ((A333_adirs.adiru3.ir.align.mode == STD and A333_adirs.adiru3.ir.align.std.elapsed_time > (A333_adirs.adiru3.ir.align.std.duration * 0.65))
            or (A333_adirs.adiru3.ir.align.mode == FAST and A333_adirs.adiru3.ir.align.status == ALIGNED))
        and (not A333_adirs.adiru3.ir.ahars_is_failed)
        and A333_adirs.adiru3.ir.data_output_switch == 1)
        and 1 or 0


    -- LRN
    A333DR_adiru1_lrn_status = (A333_adirs.adiru1.ir.power > A333DR_dc_min_volts
        and A333_adirs.adiru1.ir.align.status == ALIGNED
        and (not A333_adirs.adiru1.ir.lrn_is_failed)
        and A333_adirs.adiru1.ir.data_output_switch == 1)
        and 1 or 0

    A333DR_adiru2_lrn_status = (A333_adirs.adiru2.ir.power > A333DR_dc_min_volts
        and A333_adirs.adiru2.ir.align.status == ALIGNED
        and (not A333_adirs.adiru2.ir.lrn_is_failed)
        and A333_adirs.adiru2.ir.data_output_switch == 1)
        and 1 or 0

    A333DR_adiru3_lrn_status = (A333_adirs.adiru3.ir.power > A333DR_dc_min_volts
        and A333_adirs.adiru3.ir.align.status == ALIGNED
        and (not A333_adirs.adiru3.ir.lrn_is_failed)
        and A333_adirs.adiru3.ir.data_output_switch == 1)
        and 1 or 0

end




local function A333_irs_fwc_data()

    A333DR_adirs_ir_align_status[0] = A333_adirs.adiru1.ir.align.status
    A333DR_adirs_ir_align_status[1] = A333_adirs.adiru2.ir.align.status
    A333DR_adirs_ir_align_status[2] = A333_adirs.adiru3.ir.align.status
    
    
    local ir1_fast_align_time_remaining = get_timer_remaining(A333_adirs.adiru1.ir.align.fast.timer)
    local ir1_fast_align_minutes = ((((type(ir1_fast_align_time_remaining) == "number" and ir1_fast_align_time_remaining >= 0) and ir1_fast_align_time_remaining) or 0)) / 60.0

    local ir1_std_align_time_remaining = get_timer_remaining(A333_adirs.adiru1.ir.align.std.timer)
    local ir1_std_align_minutes = ((((type(ir1_std_align_time_remaining) == "number" and ir1_std_align_time_remaining >= 0) and ir1_std_align_time_remaining) or 0)) / 60.0

    local ir1_align_time_min = m.max(ir1_fast_align_minutes, ir1_std_align_minutes)

    if ir1_align_time_min > 6 then
        A333DR_adirs1_align_time[0] = 1
        A333DR_adirs1_align_time[1] = 1
        A333DR_adirs1_align_time[2] = 1
    elseif ir1_align_time_min > 5 and ir1_align_time_min <= 6 then
        A333DR_adirs1_align_time[0] = 1
        A333DR_adirs1_align_time[1] = 1
        A333DR_adirs1_align_time[2] = 0
    elseif ir1_align_time_min > 4 and ir1_align_time_min <= 5 then
        A333DR_adirs1_align_time[0] = 1
        A333DR_adirs1_align_time[1] = 0
        A333DR_adirs1_align_time[2] = 1
    elseif ir1_align_time_min > 3 and ir1_align_time_min <= 4 then
        A333DR_adirs1_align_time[0] = 1
        A333DR_adirs1_align_time[1] = 0
        A333DR_adirs1_align_time[2] = 0
    elseif ir1_align_time_min > 2 and ir1_align_time_min <= 3 then
        A333DR_adirs1_align_time[0] = 0
        A333DR_adirs1_align_time[1] = 1
        A333DR_adirs1_align_time[2] = 1
    elseif ir1_align_time_min > 1 and ir1_align_time_min <= 2 then
        A333DR_adirs1_align_time[0] = 0
        A333DR_adirs1_align_time[1] = 1
        A333DR_adirs1_align_time[2] = 0
    elseif ir1_align_time_min > 0 and ir1_align_time_min <= 1 then
        A333DR_adirs1_align_time[0] = 0
        A333DR_adirs1_align_time[1] = 0
        A333DR_adirs1_align_time[2] = 1
    elseif ir1_align_time_min == 0 then
        A333DR_adirs1_align_time[0] = 0
        A333DR_adirs1_align_time[1] = 0
        A333DR_adirs1_align_time[2] = 0
    end


    
    local ir2_fast_align_time_remaining = get_timer_remaining(A333_adirs.adiru2.ir.align.fast.timer)
    local ir2_fast_align_minutes = ((((type(ir2_fast_align_time_remaining) == "number" and ir2_fast_align_time_remaining >= 0) and ir2_fast_align_time_remaining) or 0)) / 60.0

    local ir2_std_align_time_remaining = get_timer_remaining(A333_adirs.adiru2.ir.align.std.timer)
    local ir2_std_align_minutes = ((((type(ir2_std_align_time_remaining) == "number" and ir2_std_align_time_remaining >= 0) and ir2_std_align_time_remaining) or 0)) / 60.0

    local ir2_align_time_min = m.max(ir2_fast_align_minutes, ir2_std_align_minutes)

    if ir2_align_time_min > 6 then
        A333DR_adirs2_align_time[0] = 1
        A333DR_adirs2_align_time[1] = 1
        A333DR_adirs2_align_time[2] = 1
    elseif ir2_align_time_min > 5 and ir2_align_time_min <= 6 then
        A333DR_adirs2_align_time[0] = 1
        A333DR_adirs2_align_time[1] = 1
        A333DR_adirs2_align_time[2] = 0
    elseif ir2_align_time_min > 4 and ir2_align_time_min <= 5 then
        A333DR_adirs2_align_time[0] = 1
        A333DR_adirs2_align_time[1] = 0
        A333DR_adirs2_align_time[2] = 1
    elseif ir2_align_time_min > 3 and ir2_align_time_min <= 4 then
        A333DR_adirs2_align_time[0] = 1
        A333DR_adirs2_align_time[1] = 0
        A333DR_adirs2_align_time[2] = 0
    elseif ir2_align_time_min > 2 and ir2_align_time_min <= 3 then
        A333DR_adirs2_align_time[0] = 0
        A333DR_adirs2_align_time[1] = 1
        A333DR_adirs2_align_time[2] = 1
    elseif ir2_align_time_min > 1 and ir2_align_time_min <= 2 then
        A333DR_adirs2_align_time[0] = 0
        A333DR_adirs2_align_time[1] = 1
        A333DR_adirs2_align_time[2] = 0
    elseif ir2_align_time_min > 0 and ir2_align_time_min <= 1 then
        A333DR_adirs2_align_time[0] = 0
        A333DR_adirs2_align_time[1] = 0
        A333DR_adirs2_align_time[2] = 1
    elseif ir2_align_time_min == 0 then
        A333DR_adirs2_align_time[0] = 0
        A333DR_adirs2_align_time[1] = 0
        A333DR_adirs2_align_time[2] = 0
    end



    local ir3_fast_align_time_remaining = get_timer_remaining(A333_adirs.adiru3.ir.align.fast.timer)
    local ir3_fast_align_minutes = ((((type(ir3_fast_align_time_remaining) == "number" and ir3_fast_align_time_remaining >= 0) and ir3_fast_align_time_remaining) or 0)) / 60.0

    local ir3_std_align_time_remaining = get_timer_remaining(A333_adirs.adiru3.ir.align.std.timer)
    local ir3_std_align_minutes = ((((type(ir3_std_align_time_remaining) == "number" and ir3_std_align_time_remaining >= 0) and ir3_std_align_time_remaining) or 0)) / 60.0

    local ir3_align_time_min = m.max(ir3_fast_align_minutes, ir3_std_align_minutes)

    if ir3_align_time_min > 6 then
        A333DR_adirs3_align_time[0] = 1
        A333DR_adirs3_align_time[1] = 1
        A333DR_adirs3_align_time[2] = 1
    elseif ir3_align_time_min > 5 and ir3_align_time_min <= 6 then
        A333DR_adirs3_align_time[0] = 1
        A333DR_adirs3_align_time[1] = 1
        A333DR_adirs3_align_time[2] = 0
    elseif ir3_align_time_min > 4 and ir3_align_time_min <= 5 then
        A333DR_adirs3_align_time[0] = 1
        A333DR_adirs3_align_time[1] = 0
        A333DR_adirs3_align_time[2] = 1
    elseif ir3_align_time_min > 3 and ir3_align_time_min <= 4 then
        A333DR_adirs3_align_time[0] = 1
        A333DR_adirs3_align_time[1] = 0
        A333DR_adirs3_align_time[2] = 0
    elseif ir3_align_time_min > 2 and ir3_align_time_min <= 3 then
        A333DR_adirs3_align_time[0] = 0
        A333DR_adirs3_align_time[1] = 1
        A333DR_adirs3_align_time[2] = 1
    elseif ir3_align_time_min > 1 and ir3_align_time_min <= 2 then
        A333DR_adirs3_align_time[0] = 0
        A333DR_adirs3_align_time[1] = 1
        A333DR_adirs3_align_time[2] = 0
    elseif ir3_align_time_min > 0 and ir3_align_time_min <= 1 then
        A333DR_adirs3_align_time[0] = 0
        A333DR_adirs3_align_time[1] = 0
        A333DR_adirs3_align_time[2] = 1
    elseif ir3_align_time_min == 0 then
        A333DR_adirs3_align_time[0] = 0
        A333DR_adirs3_align_time[1] = 0
        A333DR_adirs3_align_time[2] = 0
    end

end











----- SET STATE FOR ALL MODES -----------------------------------------------------------
local function A333_set_adirs_all_modes()

    A333DR_init_adirs_CD = 0

end




----- SET STATE TO COLD & DARK ----------------------------------------------------------
local function A333_set_adirs_CD()
    adirs_instant_align = false
end



----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
local function A333_set_adirs_ER()
    adirs_instant_align = true
end




----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
local function A333_adirs_monitor_AI()

    if A333DR_init_adirs_CD == 1 then
        A333_set_adirs_all_modes()
        A333_set_adirs_CD()
        A333DR_init_adirs_CD = 2
    end

end



----- FLIGHT START ---------------------------------------------------------------------
local function A333_flight_start_adirs()

    -- ALL MODES ------------------------------------------------------------------------
    A333_set_adirs_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then
        A333_set_adirs_CD()



        -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then
        A333_set_adirs_ER()

    end

end





--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--
--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

    A333_flight_start_adirs()

end


--function flight_crash() end

--function before_physics()

function after_physics()

    A333_adirs_cache_globals()
    A333_adirs:update()
    A333_reset_instant_align()
    A333_adirs_dataref_update()
    A333_irs_fwc_data()
    A333_adirs_monitor_AI()

end

function after_replay()

    A333_adirs_cache_globals()
    A333_adirs:update()
    A333_reset_instant_align()
    A333_adirs_dataref_update()
    A333_irs_fwc_data()
    A333_adirs_monitor_AI()

end

