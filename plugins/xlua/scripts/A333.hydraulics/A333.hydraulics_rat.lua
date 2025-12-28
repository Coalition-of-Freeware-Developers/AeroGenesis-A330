--[[
*****************************************************************************************
* Script Name:  A333.hydraulics_rat.lua
*
* Script Description:
*
* Author Name: Jim Gregory
*
* Revisions:
* -- DATE --  --- REV NO ---  --- DESCRIPTION -------------------------------------------
** 10/08/2025                  Initial Development
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
local DEPLOY_TIME = 3.5
local DEPLOY_ANGLE = 100.0  -- Angle of deployment at full extension from retracted angle of zero (0)
local DEPLOY_PROP_START_ANGLE = 95.0

local PROP_SPINUP_TIME = 2.0
local PROP_RPM_RANGE = 6000.0
local PROP_MIN_RPM_AIRSPEED = 0.0 -- Vso set at flight_start
local PROP_MAX_RPM_AIRSPEED = 0.0 -- Vso + 15 set at flight_start

local PROP_ANGLE_UPDATE_FREQ = 0.1
local PROP_ANGLE_RANGE = 80000.0

math.randomseed(os.clock())
local PROP_TARGET_RPM = math.random(5398, 5401) + math.random()



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local sim_period = 0


local bool2num = {[true] = 1, [false] = 0}
local num2bool = {[0] = false, [1] = true}



--*************************************************************************************--
--** 				            LOCAL UTILITY FUNCTIONS          			    	 **--
--*************************************************************************************--
local m = math
local rescale = rescale


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
local linear_animation = {}
linear_animation.__index = linear_animation

-- OBJECT CONSTRUCTOR ---------------------------------------------------------
function linear_animation.new(name, duration, range)

    local self = setmetatable({}, linear_animation)

    -- CLASS PROPERTIES -------------------------------------------------------
    self.name           = name
    self.duration		= duration			-- in seconds
    self.range		    = range
    self.target		    = 0.0
    self.delta		    = 0.0
    self.inTransit	    = false
    self.direction	    = 0
    self.pause		    = false
    self.isHot		    = 1					-- option to plug the animation into a power source
    self.timeStep		= range / duration	-- time step is in 'units per second'
    self.output		    = 0.0

    return self

end

-- CLASS METHODS --------------------------------------------------------------
function linear_animation.setDurationAndRange(self, duration, range)
    if range then
        self.range = range
    end
    if duration then
        self.duration = duration
    end
    self.timeStep = self.range / self.duration
end

function linear_animation.setDuration(self, duration)
    if duration then
        self.duration = duration
    end
    self.timeStep = self.range / self.duration
end

function linear_animation.setTimeStep(self, timeStep)
    if timeStep then
        self.timeStep = timeStep
    end
end

function linear_animation.setTarget(self, target)
    if target then
        self.target = target
    end
end

function linear_animation.setDelay(self, delay)
    if delay then
        self.delay = delay
    end
end

function linear_animation.sync(self, syncValue)
    if syncValue then
        self.target = syncValue
        self.output = syncValue
    end
end

function linear_animation.setPause(self, trueORfalse)
    self.pause = trueORfalse
end

function linear_animation.setPower(self, hotValue)
    if hotValue then
        self.isHot = hotValue
    end
end

function linear_animation.update(self)
    if simDR_paused == 0
        and not self.pause
        and self.isHot == 1
        and self.target
    then
        self.delta = self.target - self.output
        if m.abs(self.delta) <= self.timeStep * sim_period then
            self.output = self.target
            self.direction = 0
            self.inTransit = false
        else
            self.inTransit = true
            if self.delta < 0 then
                self.output = self.output - (self.timeStep * sim_period)
                self.direction = -1
            else
                self.output = self.output + (self.timeStep * sim_period)
                self.direction = 1
            end  -- animation incrementation
        end  -- delta test
    end -- not paused and is hot
end  -- animation update






local ram_air_turbine = {}
ram_air_turbine.__index = ram_air_turbine

-- OBJECT CONSTRUCTOR ---------------------------------------------------------
function ram_air_turbine.new(name)

    local self = setmetatable({}, ram_air_turbine)

    -- CLASS PROPERTIES -------------------------------------------------------
    self.name = name
    self.deploy = false
    self.solenoid1 = {
        is_energized = false
    }
    self.solenoid2 = {
        is_energized = false
    }
    self.deploy_actuator = {
        anm = linear_animation.new(name .. "_actuator_anm", DEPLOY_TIME, DEPLOY_ANGLE)
    }
    self.prop = {
        rpm_anm = linear_animation.new(name .. "_prop_anm", PROP_SPINUP_TIME, PROP_RPM_RANGE),
        angle_anm = linear_animation.new(name .. "_prop_angle_anm", PROP_ANGLE_UPDATE_FREQ, PROP_ANGLE_RANGE)
    }



    return self

end


-- CLASS METHODS --------------------------------------------------------------
function ram_air_turbine.solenoid1_update(self)     -- HYD RAT MAN ON P/B

    local a = A333DR_dc_bat1_hot_bus_has_power == 1 or A333DR_dc_bat2_hot_bus_has_power == 1
    local b = A333DR_buttons_rat_man_on_ctct_on_off == 1

    self.solenoid1.is_energized = a and b

end



function ram_air_turbine.solenoid2_update(self)     -- AUTO-DEPLOY [EMER ELEC CONFIG LEVEL 2]

    local in_flight = simDR_on_ground == 0
    local HGRLL = A333DR_hyd_green_rsvr_lo_lvl

    local a = HGRLL == 1 and A333DR_hyd_yellow_rsvr_lo_lvl == 1
    local b = HGRLL == 1 and A333DR_hyd_blue_rsvr_lo_lvl == 1
    local c = A333DR_trent700_n3_eng1 < 50 and A333DR_trent700_n3_eng2 < 50
    local d = in_flight
    local e = simDR_airspeed > 100
    local f = A333DR_dc_ess_bus_has_power == 1

    self.solenoid2.is_energized = (a or b or c) and d and e and f

end




function ram_air_turbine.deploy_animation(self)

    if self.solenoid1.is_energized or self.solenoid2.is_energized then
        self.deploy = true                          -- Extend the RAT: cannot be retracted, must reload aircraft
    end

    if self.deploy then
        self.deploy_actuator.anm:setTarget(DEPLOY_ANGLE)
    end
    self.deploy_actuator.anm:update()

    A333DR_hyd_rat_actuator_deploy_angle_target_deg = DEPLOY_ANGLE
    A333DR_hyd_rat_actuator_deploy_angle_deg = self.deploy_actuator.anm.output

end




function ram_air_turbine.prop_animation(self)

    --[ RPM ]--
    local prop_RPM_target = 0
    if self.deploy_actuator.anm.output >= DEPLOY_PROP_START_ANGLE then	-- Start spinning up RAT prop if RAT is extended past (deploy) prop start angle
        prop_RPM_target = rescale(PROP_MIN_RPM_AIRSPEED, 0.0, PROP_MAX_RPM_AIRSPEED, PROP_TARGET_RPM, simDR_indicated_airspeed) --simDR_indicated_airspeed)  testing @180.0
    end
    self.prop.rpm_anm:setTarget(prop_RPM_target)
    self.prop.rpm_anm:update()

    A333DR_hyd_rat_prop_rpm = self.prop.rpm_anm.output


    --[ ANGLE ]--
    self.prop.angle_anm:setTarget(800000)
    self.prop.angle_anm:setTimeStep(self.prop.rpm_anm.output * 6)  --[ 1 rpm = 360 deg/min = 6 deg/sec ]
    self.prop.angle_anm:update()
    if self.prop.angle_anm.output > 720000.0 then self.prop.angle_anm.output = self.prop.angle_anm.output - 720000.0 end

    A333DR_hyd_rat_prop_angle_deg = m.fmod(self.prop.angle_anm.output, 360)

end




function ram_air_turbine.hyd_pump(self)
    simDR_RAT_hyd_pump_on = self.prop.rpm_anm.output > 0 and 1 or 0
end




function ram_air_turbine.update(self)

    self:solenoid1_update()
    self:solenoid2_update()

    self:deploy_animation()
    self:prop_animation()

    self:hyd_pump()

end





--*************************************************************************************--
--** 				                 CREATE OBJECTS              	     			 **--
--*************************************************************************************--
rat = ram_air_turbine.new("rat")



--*************************************************************************************--
--** 				              FUNCTION DEFINITIONS         	    				 **--
--*************************************************************************************--
local function A333_hydr_rat_cache_globals()

    sim_period = SIM_PERIOD
    simDR_override_hydr_RAT = 1

end




--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

--===| INIT ALL |========================================================================
local function A333_hydraulics_rat_init_all() end



--===| INIT CD |=========================================================================
local function A333_hydraulics_rat_init_CD() end



--===| INIT ER |=========================================================================
local function A333_hydraulics_rat_init_ER() end



--===| DEFERRED INITIALIZATION |=========================================================
function A333_hydraulics_rat_deferred_init() end



--===| DEFERRED PROCESSING |=============================================================
function A333_hydraulics_rat_deferred_processing() end





--=== AIRCRAFT LOAD =====================================================================
function A333_hydraulics_rat_aircraft_load() end



--=== FLIGHT START ======================================================================
function A333_hydraulics_rat_flight_start()

    PROP_MIN_RPM_AIRSPEED = simDR_Vso
    PROP_MAX_RPM_AIRSPEED = PROP_MIN_RPM_AIRSPEED + 15.0

end



--=== BEFORE PHYSICS ====================================================================
function A333_hydraulics_rat_before_physics() end



--=== AFTER PHYSICS =====================================================================
function A333_hydraulics_rat_after_physics()

    A333_hydr_rat_cache_globals()

    rat:update()


end




--=== FLIGHT CRASH ======================================================================
function A333_hydraulics_rat_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_hydraulics_rat_aircraft_unload()

    simDR_override_hydr_RAT = 0

end




--=== AFTER REPLAY ==================================---=================================
function A333_hydraulics_rat_after_replay()

    A333_hydr_rat_cache_globals()

    rat:update()

end


