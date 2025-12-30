--[[
*****************************************************************************************
* Program Script Name	:	A333.systems
* Author Name			:	Alex Unruh
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2025-08-08	0.01				Start of Dev
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


--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local lcl_SIM_PERIOD = 0
local m = math

local display_instant_on = false





local function animate(current_value, target, min, max, speed, name)

    local fps_factor = m.min(1.0, speed * lcl_SIM_PERIOD)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * fps_factor)
    end

end



--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
simDR_startup_running = find_dataref("sim/operation/prefs/startup_running")

simDR_PFD1_off_bright_knob  = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[0]")
simDR_ND1_off_bright_knob   = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[1]")
simDR_EWD_off_bright_knob   = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[2]")
simDR_SD_off_bright_knob	= find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[3]")
simDR_ND2_off_bright_knob   = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[4]")
simDR_PFD2_off_bright_knob  = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[5]")
simDR_standby_off_bright_knob  = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[9]")
simDR_acars1_off_bright_knob  = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[18]")
simDR_acars2_off_bright_knob  = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[19]")



--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--
A333DR_ecam_sys_page = find_dataref("laminar/A333/enums/ecam/sys_page")

A333DR_ac_bus1_volts = find_dataref("laminar/A333/elec/ac_bus1_volts")
A333DR_ac_bus2_volts = find_dataref("laminar/A333/elec/ac_bus2_volts")
A333DR_ac_ess_bus_volts = find_dataref("laminar/A333/elec/ac_ess_bus_volts")
A333DR_ac_ess_shed_bus_volts = find_dataref("laminar/A333/elec/ac_ess_shed_bus_volts")
A333DR_ac_ess_grnd_bus_volts = find_dataref("laminar/A333/elec/ac_ess_grnd_bus_volts")
A333DR_ac_land_rcvry_bus_volts = find_dataref("laminar/A333/elec/ac_land_rcvry_bus_volts")

A333DR_dc_bat1_hot_bus_volts = find_dataref("laminar/A333/elec/dc_hot_bus1_volts")
A333DR_dc_bat2_hot_bus_volts = find_dataref("laminar/A333/elec/dc_hot_bus2_volts")
A333DR_dc_bat_bus_volts = find_dataref("laminar/A333/elec/dc_bat_bus_volts")
A333DR_dc_apu_bat_bus_volts = find_dataref("laminar/A333/elec/dc_apu_bat_bus_volts")
A333DR_dc_bus1_volts = find_dataref("laminar/A333/elec/dc_bus1_volts")
A333DR_dc_bus2_volts = find_dataref("laminar/A333/elec/dc_bus2_volts")
A333DR_dc_ess_bus_volts = find_dataref("laminar/A333/elec/dc_ess_bus_volts")
A333DR_dc_ess_shed_bus_volts = find_dataref("laminar/A333/elec/dc_ess_shed_bus_volts")
A333DR_dc_land_rcvry_bus_volts = find_dataref("laminar/A333/elec/dc_land_rcvry_bus_volts")
A333DR_dc_shed_land_rcvry_bus_volts = find_dataref("laminar/A333/elec/dc_shed_land_rcvry_bus_volts")

A333DR_ac_min_volts = find_dataref("laminar/A333/elec/ac_min_volts")
A333DR_dc_min_volts = find_dataref("laminar/A333/elec/dc_min_volts")



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

-- 0=off, 1-has power(warmup), 2=self test in progress, 3=on/graphics display
A333_pfd1_display_state = create_dataref("laminar/A333/pfd1/display_state", "number")
A333_pfd2_display_state = create_dataref("laminar/A333/pfd2/display_state", "number")
A333_nd1_display_state = create_dataref("laminar/A333/nd1/display_state", "number")
A333_nd2_display_state = create_dataref("laminar/A333/nd2/display_state", "number")
A333_ewd_display_state = create_dataref("laminar/A333/ewd/display_state", "number")
A333_sd_display_state = create_dataref("laminar/A333/sd/display_state", "number")
A333_standby_display_state = create_dataref("laminar/A333/standby/display_state", "number")
A333_acars1_display_state = create_dataref("laminar/A333/acars1/display_state", "number")
A333_acars2_display_state = create_dataref("laminar/A333/acars2/display_state", "number")

A333DR_pfd1_display_test_flash = create_dataref("laminar/A333/pfd1/display_test_flash", "number")
A333DR_pfd2_display_test_flash = create_dataref("laminar/A333/pfd2/display_test_flash", "number")
A333DR_nd1_display_test_flash = create_dataref("laminar/A333/nd1/display_test_flash", "number")
A333DR_nd2_display_test_flash = create_dataref("laminar/A333/nd2/display_test_flash", "number")
A333DR_ewd_display_test_flash = create_dataref("laminar/A333/ewd/display_test_flash", "number")
A333DR_sd_display_test_flash = create_dataref("laminar/A333/sd/display_test_flash", "number")
A333DR_standby_display_test_flash = create_dataref("laminar/A333/standby/display_test_flash", "number")
A333DR_acars1_display_test_flash = create_dataref("laminar/A333/acars1/display_test_flash", "number")
A333DR_acars2_display_test_flash = create_dataref("laminar/A333/acars2/display_test_flash", "number")

A333DR_ecam_du_config = create_dataref("laminar/A333/display/ecam_du_config", "number")
A333DR_ecam_ew_image_du_config = create_dataref("laminar/A333/display/ecam_ew_image_du_config", "number")
A333DR_ecam_ss_image_du_config = create_dataref("laminar/A333/display/ecam_ss_image_du_config", "number")

A333DR_standby_countdown = create_dataref("laminar/A333/display/standby_countdown", "number")

A333DR_init_displays_CD = create_dataref("laminar/A333/init_CD/displays", "number")



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
local function A333_instant_instrument_display_CMDhandler(phase, duration)
    if phase == 0 then
        display_instant_on = not(display_instant_on)
    end
end




local function A333_ai_displays_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
        A333_set_displays_all_modes()
        A333_set_displays_CD()
        A333_set_displays_ER()
    end
end




--*************************************************************************************--
--** 				                 CUSTOM COMMANDS                			     **--
--*************************************************************************************--
A333CMD_instant_instrument_display = create_command("laminar/A333/instant_display", "All Instrument Displays ON Instantly", A333_instant_instrument_display_CMDhandler)
A333CMD_ai_displays_quick_start = create_command("laminar/A333/ai/displays_quick_start", "AI ADIRS", A333_ai_displays_quick_start_CMDhandler)



--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--
local display_unit = {}
display_unit.__index = display_unit

-- OBJECT CONSTRUCTOR -------------------------------------------------------------------
function display_unit.new(name, duration_min, duration_max, flash_isEnabled, flash_start)

    local self = setmetatable({}, display_unit)

    -- CLASS PROPERTIES -----------------------------------------------------------------
    self.name = name
    self.volts = 0
    self.off_brt_knob = 0
    self.init_complete = false
    self.state = 0
    
    self.power_supply = {
        volts_in = 0,
        capacitor = {
            volts = 0,
            timer = function()
                self.power_supply.capacitor.volts = 0
            end,
            duration = 1.0
        }
    }

    self.warmup = {
        state = 0,                       -- 0=off, 1=in progress, 2=complete
        duration = 3.0,
        timer = function()
            self.warmup.state = 2
        end
    }
    self.test = {
        state = 0,                       -- 0=off, 1-has power(warmup in progress), 2=self test in progress, 3=on/graphics display
        duration_min = duration_min,
        duration_max = duration_max,
        duration = 40,
        timer = function()
            self.test.state = 2
        end,
        flash = {
            isEnabled = flash_isEnabled,
            start_time = flash_start < 10 and flash_start or 6,
            number_flashes = 2,
            counter = -1,
            state = 1,
            target = 1
        }
    }

    return self

end




function display_unit.init(self)

    self.state = 0
    self.warmup.state = 0
    self.test.flash.state = 1
    self.test.flash.target = 1
    self.test.flash.counter = -1

    if is_timer_scheduled(self.power_supply.capacitor.timer) then
        stop_timer(self.power_supply.capacitor.timer)
    end
    self.power_supply.capacitor.volts = 0

    self.warmup.state = 0
    if is_timer_scheduled(self.warmup.timer) then
        stop_timer(self.warmup.timer)
    end
    local _, frac = m.modf(os.clock())
    local seed = m.random(1, frac*1000.0) + 10 + frac
    m.randomseed(seed)
    self.warmup.duration = m.random(2, 4) + frac

    self.test.state = 0
    if is_timer_scheduled(self.test.timer) then
        stop_timer(self.test.timer)
    end
    local _, frac2 = m.modf(os.clock())
    local seed2 = m.random(1, frac2*1000.0) + 10 + frac2
    m.randomseed(seed2)
    self.test.duration = m.random(self.test.duration_min, self.test.duration_max) + frac2

    self.init_complete = true

end





function display_unit.control_bright_knob_assignment(self)

    if self.name == "A333_du_pfd1" then self.off_brt_knob = simDR_PFD1_off_bright_knob

    elseif self.name == "A333_du_nd1" then self.off_brt_knob = simDR_ND1_off_bright_knob

    elseif self.name == "A333_du_ewd" then self.off_brt_knob = simDR_EWD_off_bright_knob

    elseif self.name == "A333_du_sd" then self.off_brt_knob = simDR_SD_off_bright_knob

    elseif self.name == "A333_du_pfd2" then self.off_brt_knob = simDR_PFD2_off_bright_knob

    elseif self.name == "A333_du_nd2" then self.off_brt_knob = simDR_ND2_off_bright_knob

    elseif self.name == "A333_acars1" then self.off_brt_knob = simDR_acars1_off_bright_knob

    elseif self.name == "A333_acars2" then self.off_brt_knob = simDR_acars2_off_bright_knob

    elseif self.name == "A333_standby" then self.off_brt_knob = simDR_standby_off_bright_knob

    end

end




function display_unit.power_supply_input(self)

    local ac_bus1_volts = A333DR_ac_bus1_volts
    local ac_bus2_volts = A333DR_ac_bus2_volts
    local ac_ess_bus_volts = A333DR_ac_ess_bus_volts
    local ac_ess_shed_bus_volts = A333DR_ac_ess_shed_bus_volts

    if self.name == "A333_du_pfd1" then self.power_supply.volts_in = ac_ess_bus_volts

    elseif self.name == "A333_du_nd1" then self.power_supply.volts_in = ac_ess_shed_bus_volts

    elseif self.name == "A333_du_ewd" then self.power_supply.volts_in = ac_ess_bus_volts

    elseif self.name == "A333_du_sd" then self.power_supply.volts_in = ac_bus1_volts

    elseif self.name == "A333_du_pfd2" then self.power_supply.volts_in = ac_bus2_volts

    elseif self.name == "A333_du_nd2" then self.power_supply.volts_in = ac_bus2_volts

	elseif self.name == "A333_acars1" then self.power_supply.volts_in = ac_bus1_volts

	elseif self.name == "A333_acars2" then self.power_supply.volts_in = ac_bus2_volts

	elseif self.name == "A333_standby" then self.power_supply.volts_in = ac_ess_bus_volts

    end

end



function display_unit.power_supply_capacitor(self)

    if self.power_supply.volts_in > A333DR_ac_min_volts then
        self.power_supply.capacitor.volts = self.power_supply.volts_in

    else
        if self.power_supply.capacitor.volts > 0 then
            if not is_timer_scheduled(self.power_supply.capacitor.timer) then
                run_after_time(self.power_supply.capacitor.timer, self.power_supply.capacitor.duration) -- Capacitor discharge
            end
        end
    end

    self.volts = (self.off_brt_knob > 0.01) and self.power_supply.capacitor.volts or 0

end




function display_unit.instant_on(self)

    if display_instant_on then
        self:init()
        self.state = 3
        self.warmup.state = 2
        self.test.state = 3
        self.test.flash.state = 1
        self.test.flash.target = 1
        self.test.flash.counter = -1
    end

end




function display_unit.state_manager(self)

    if self.volts > A333DR_ac_min_volts then

        if not self.init_complete then
            self:init()
        end

        if self.state == 0 then
            self.state = 1
            self.warmup.state = 1
            if not is_timer_scheduled(self.warmup.timer) then
                run_after_time(self.warmup.timer, self.warmup.duration)
            end

        elseif self.state == 1 and self.warmup.state == 2 then
            self.state = 2
            self.test.state = 1
            if not is_timer_scheduled(self.test.timer) then
                run_after_time(self.test.timer, self.test.duration)
            end

        elseif self.state == 2 and self.test.state == 2 then
            self.state = 3
            self.test.flash.state = 1
            self.test.flash.target = 1
            self.test.flash.counter = -1

        end

    else
        self.init_complete = false
        self:init()

    end

end




function display_unit.test_flash_manager(self)

    if self.test.flash.isEnabled then
        if self.state == 2 then
            if self.test.state == 1 then

                if self.test.flash.counter == -1 then
                    if self.test.duration - get_timer_remaining(self.test.timer) > self.test.flash.start_time then
                        self.test.flash.target = 0
                        self.test.flash.counter = self.test.flash.counter + 1

                    end

                elseif self.test.flash.counter >= 0 and (self.test.flash.counter < self.test.flash.number_flashes) then

                    if self.test.flash.state == 0 then

                        self.test.flash.target = 1
                        self.test.flash.counter = self.test.flash.counter + 1

                    elseif self.test.flash.state == 1 then

                        self.test.flash.target = 0

                    end
                end
            end
        end
        self.test.flash.state = animate(self.test.flash.state, self.test.flash.target, 0.0, 1.0, 20.0, self.name)

    end
end





function display_unit.update(self)

    self:control_bright_knob_assignment()
    self:power_supply_input()
    self:power_supply_capacitor()
    self:instant_on()
    self:state_manager()
    self:test_flash_manager()

end



--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--
local A333_du_pfd1 = display_unit.new("A333_du_pfd1", 15, 39, true,  6)
local A333_du_nd1 = display_unit.new("A333_du_nd1",   15, 39, true,  5)
local A333_du_ewd = display_unit.new("A333_du_ewd",   15, 39, true,  7)
local A333_du_sd = display_unit.new("A333_du_sd",     15, 39, true,  8)
local A333_du_pfd2 = display_unit.new("A333_du_pfd2", 15, 39, true,  5)
local A333_du_nd2 = display_unit.new("A333_du_nd2",   15, 39, true,  6)
local A333_acars1 = display_unit.new("A333_acars1",    6, 10, false, 0)
local A333_acars2 = display_unit.new("A333_acars2",    6, 10, false, 0)
local A333_standby = display_unit.new("A333_standby", 89, 89, false, 0)


--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--
local function A333_standby_countdown_fn()

    local standby_state = A333_standby_display_state

    if standby_state ~= 2 then
        countdown = 90
    else

        if countdown > 0 then
            countdown = countdown - SIM_PERIOD

        end

    end

    A333DR_standby_countdown = countdown

end




local function A333_set_display_state_DR()

    A333_pfd1_display_state = A333_du_pfd1.state
    A333DR_pfd1_display_test_flash = A333_du_pfd1.test.flash.state

    A333_nd1_display_state  = A333_du_nd1.state
    A333DR_nd1_display_test_flash = A333_du_nd1.test.flash.state

    A333_ewd_display_state = A333_du_ewd.state
    A333DR_ewd_display_test_flash = A333_du_ewd.test.flash.state

    A333_sd_display_state = A333_du_sd.state
    A333DR_sd_display_test_flash = A333_du_sd.test.flash.state

    A333_pfd2_display_state = A333_du_pfd2.state
    A333DR_pfd2_display_test_flash = A333_du_pfd2.test.flash.state

    A333_nd2_display_state = A333_du_nd2.state
    A333DR_nd2_display_test_flash = A333_du_nd2.test.flash.state

    A333_acars1_display_state = A333_acars1.state

    A333_acars2_display_state = A333_acars2.state

    A333_standby_display_state = A333_standby.state

end




local function A333_set_ecam_du_cfg()

    local ecam_du_config = 0                    -- Both ECAM display units are "OFF"

    if (A333_du_ewd.state == 3 and A333_du_sd.state < 3)
        or (A333_du_ewd.state < 3 and A333_du_sd.state == 3)
    then
        ecam_du_config = 1                      -- Only one ECAM display unit is "ON" (MONO Mode)
        
    elseif A333_du_ewd.state == 3 and A333_du_sd.state == 3 then
        ecam_du_config = 2                      -- Both ECAM display units are "ON"
        
    end
    A333DR_ecam_du_config = ecam_du_config

end




local function A333_set_ecam_image_du_cfg()

    local ecam_sys_image_du_config = 0              -- System/Status Page is not dislpayed
    local ecam_ew_image_du_config = 0               -- Engine/Warning page is not displayed


    if (A333_du_ewd.state == 3 and A333_du_sd.state == 3)
        or (A333_du_ewd.state < 3  and A333_du_sd.state == 3)
    then
        ecam_sys_image_du_config = 1                -- System/Status Page is displayed on lower ECAM

    elseif (A333_du_ewd.state == 3 and A333_du_sd.state < 3) then
        ecam_sys_image_du_config = 2                -- System/Status Page is displayed on upper ECAM
        
    end
    A333DR_ecam_ss_image_du_config = ecam_sys_image_du_config


    if (A333_du_ewd.state == 3 and A333_du_sd.state == 3)
        or (A333_du_ewd.state == 3 and A333_du_sd.state < 3)
    then
        ecam_ew_image_du_config = 1             -- Engine/Warning page is displayed on upper ECAM

    elseif (A333_du_ewd.state < 3 and A333_du_sd.state == 3) then
        ecam_ew_image_du_config = 2             -- Engine/Warning page is displayed on lower ECAM

    end
    A333DR_ecam_ew_image_du_config = ecam_ew_image_du_config

end






----- SET STATE FOR ALL MODES -----------------------------------------------------------
local function A333_set_displays_all_modes()

    A333DR_init_displays_CD = 0

end




----- SET STATE TO COLD & DARK ----------------------------------------------------------
local function A333_set_displays_CD()



end

local desired_display_instant_on_mode = nil
local function A333_set_display_instant_on()
    if desired_display_instant_on_mode ~= nil then
        display_instant_on = desired_display_instant_on_mode
        desired_display_instant_on_mode = nil
    end
end

----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
local function A333_set_displays_ER()
    desired_display_instant_on_mode = true

    if not is_timer_scheduled(A333_set_display_instant_on) then
        run_after_time(A333_set_display_instant_on, 1.0)
    end
end




----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
local function A333_displays_monitor_AI()

    if A333DR_init_displays_CD == 1 then
        A333_set_displays_all_modes()
        A333_set_displays_CD()
        A333DR_init_displays_CD = 2
    end

end



----- FLIGHT START ---------------------------------------------------------------------
local function A333_flight_start_displays()

    -- ALL MODES ------------------------------------------------------------------------
    A333_set_displays_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then
        A333_set_displays_CD()



        -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then
        A333_set_displays_ER()

    end

end




--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--
--function aircraft_load() end


--function aircraft_unload() end

function flight_start()

    A333_flight_start_displays()

end

--function flight_crash() end

--function before_physics()

function after_physics()

    lcl_SIM_PERIOD = SIM_PERIOD

    if display_instant_on then
        desired_display_instant_on_mode = false
        if not is_timer_scheduled(A333_set_display_instant_on) then
            run_after_time(A333_set_display_instant_on, 1.0)
        end
    end

    A333_du_pfd1:update()
    A333_du_nd1:update()
    A333_du_ewd:update()
    A333_du_sd:update()
    A333_du_pfd2:update()
    A333_du_nd2:update()
    A333_acars1:update()
    A333_acars2:update()
    A333_standby:update()

    A333_set_display_state_DR()
    A333_set_ecam_du_cfg()
    A333_set_ecam_image_du_cfg()

    A333_standby_countdown_fn()

    A333_displays_monitor_AI()

end

function after_replay()

    lcl_SIM_PERIOD = SIM_PERIOD

    A333_du_pfd1:update()
    A333_du_nd1:update()
    A333_du_ewd:update()
    A333_du_sd:update()
    A333_du_pfd2:update()
    A333_du_nd2:update()
    A333_acars1:update()
    A333_acars2:update()
    A333_standby:update()

    A333_set_display_state_DR()
    A333_set_ecam_du_cfg()
    A333_set_ecam_image_du_cfg()

    A333_standby_countdown_fn()

    A333_displays_monitor_AI()

end

