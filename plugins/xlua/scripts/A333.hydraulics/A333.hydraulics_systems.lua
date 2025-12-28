--[[
*****************************************************************************************
* Program Script Name	:	A333.hydraulic
* Author Name			:	Alex Unruh
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2019-06-13	0.01a				Start of Dev
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

-- Shadow SIM_PERIOD locally to avoid expensive namespace lookups


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

local m = math
local engine_out_status = 0
local gear_deploy_max = 0
local green_timer = 0
local green_gear_trigger = 0
local yellow_trigger_cargo = 0
local yellow_trigger_inflight = 0
local blue_trigger_inflight = 0
local yellow_timer = 0
local door_speedC1 = 45
local door_speedC2 = 45

local green_pump_has_power = 0
local blue_pump_has_power = 0
local yellow_pump_has_power = 0
local ping_pong = 0




--*************************************************************************************--
--** 				            LOCAL UTILITY FUNCTIONS          			    	 **--
--*************************************************************************************--
local animate = animate
local rescale = rescale



--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--
--[[
You have three new datarefs now:
sim/operation/override/override_hydr_RAT
sim/operation/override/getting_elec_ADG
can override either of the automatic RAT extension (hydraulic extends upon loss of
all hydraulic pressure, electric extends upon loss of all generators).

sim/cockpit2/electrical/RAT_generator_on    -- controls the relay

while...
sim/cockpit2/electrical/RAT_generator_extended  -- controls the physical extension of the thing that spins.

Normally, the extension happens when weight-off-wheels and no generators,
and the relay closes when the thing is extended and spinning fast
enough to make power (i.e. faster than clean stall speed).

For compatibility
sim/cockpit2/electrical/air_driven_generator_on
triggers both.
But with the override set, you can control both individually.
--]]

--[[

laminar/A330/buttons/hyd/rat_man_on			(momentary)                 -- HYD
laminar/A330/buttons/hyd/rat_man_on_button_pos                          -- HYD

--]]



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
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                 X-PLANE COMMANDS                   	    	 **--
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


--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--
local function A333_gear_deploy_min()

    gear_deploy_max = m.max(simDR_gear_deploy_rat[0], simDR_gear_deploy_rat[1], simDR_gear_deploy_rat[2])

    if simDR_gear_handle_request < gear_deploy_max then
        green_gear_trigger = 1
    end

end




local function A333_engine_status()

    if simDR_equiv_airspeed > 100 and simDR_on_ground == 0 then

        if simDR_eng1_N2 >= 50 and simDR_eng2_N2 >= 50 then
            engine_out_status = 0
        elseif simDR_eng1_N2 < 50 and simDR_eng2_N2 >= 50 then
            engine_out_status = 1
        elseif simDR_eng1_N2 >= 50 and simDR_eng2_N2 < 50 then
            engine_out_status = 2
        else engine_out_status = 3
        end

    else engine_out_status = 0
    end

end




local function A333_elec_hyd_auto_green()


    green_pump_has_power = ((A333DR_ac_bus1_has_power == 1 and A333DR_dc_bus1_has_power == 1) and 1) or 0


    if A333_elec_pump_green_contactor == 0 then
        simDR_green_elec_pump_on = 0
    elseif A333_elec_pump_green_contactor == 1 then
        if A333_elec_pump_green_override_on == 1 then
            if green_pump_has_power == 1 then
                simDR_green_elec_pump_on = 1
            else simDR_green_elec_pump_on = 0
            end
        else

            if engine_out_status == 1 or engine_out_status == 2 then
                if green_gear_trigger == 1 then
                    if green_timer < 26 then
                        green_timer = green_timer + sim_period
                    else
                    end
                    if green_timer < 25 then
                        if green_pump_has_power == 1 then
                            simDR_green_elec_pump_on = 1
                        else simDR_green_elec_pump_on = 0
                        end
                    else simDR_green_elec_pump_on = 0
                        green_gear_trigger = 0
                        green_timer = 0
                    end
                else simDR_green_elec_pump_on = 0
                end
            elseif engine_out_status == 0 or engine_out_status == 3 then
                green_timer = 0
                simDR_green_elec_pump_on = 0
            end
        end
    end

end


local function A333_elec_hyd_stby_blue()

    blue_pump_has_power = ((A333DR_ac_bus2_has_power == 1 and A333DR_dc_bus1_has_power == 1) and 1) or 0

    blue_trigger_inflight = ((engine_out_status == 1 and simDR_flap_deploy_request > 0.05 and (A333_prim1_status == 0 or A333_prim3_status == 0)) and 1) or 0

    if A333_elec_pump_blue_contactor == 0 then
        simDR_blue_elec_pump_on = 0
    elseif A333_elec_pump_blue_contactor == 1 then
        if A333_elec_pump_blue_override_on == 1 then
            if blue_pump_has_power == 1 then
                simDR_blue_elec_pump_on = 1
            else simDR_blue_elec_pump_on = 0
            end
        else
            if blue_trigger_inflight == 1 then
                if blue_pump_has_power == 1 then
                    simDR_blue_elec_pump_on = 1
                else simDR_blue_elec_pump_on = 0
                end
            else simDR_blue_elec_pump_on = 0
            end

        end
    end

end


local function A333_elec_hyd_auto_yellow()

    yellow_pump_has_power = (((A333DR_ac_bus1_has_power == 1 or A333DR_extA_grd_service_bus_pwr == 1) and (A333DR_dc_bus2_has_power == 1 or A333DR_tr2_volts > A333DR_dc_min_volts or A333DR_status_gpu_avail == 1)) and 1) or 0

    local cargo_door_loop_active = (((simDR_door_ratio[8] > 0 and simDR_door_ratio[8] < 0.999) or (simDR_door_ratio[9] > 0 and simDR_door_ratio[9] < 0.999)) and 1) or 0

    if cargo_door_loop_active == 1 then
        yellow_timer = 0
        if yellow_pump_has_power == 1 then
            yellow_trigger_cargo = 1
        else yellow_trigger_cargo = 0
        end
    end

    if yellow_trigger_cargo == 1 then
        if cargo_door_loop_active == 0 then
            if yellow_timer <= 10 then
                yellow_timer = yellow_timer + sim_period
            else yellow_trigger_cargo = 0
            end
        end
    end

    if engine_out_status == 2 and simDR_flap_deploy_request > 0.05 then
        if green_gear_trigger == 0 then
            yellow_trigger_inflight = 1
        else yellow_trigger_inflight = 0
        end
    end

    if A333_flight_phase == 10 or engine_out_status == 3 then
        yellow_trigger_inflight = 0
    end

    if A333_elec_pump_yellow_contactor == 0 then
        simDR_yellow_elec_pump_on = 0
        yellow_trigger_inflight = 0
    elseif A333_elec_pump_yellow_contactor == 1 then
        if A333_elec_pump_yellow_override_on == 1 then
            if yellow_pump_has_power == 1 then
                simDR_yellow_elec_pump_on = 1
            else simDR_yellow_elec_pump_on = 0
            end
        else
            if yellow_trigger_cargo == 1 or yellow_trigger_inflight == 1 then
                if yellow_pump_has_power == 1 then
                    simDR_yellow_elec_pump_on = 1
                else simDR_yellow_elec_pump_on = 0
                end
            else simDR_yellow_elec_pump_on = 0
            end

        end
    end

    local sim_time_factor = m.fmod(simDR_sim_time, 1.2)
    local ping_pong = ((sim_time_factor >= 0 and sim_time_factor <= 0.6) and 1) or 5

    if simDR_yellow_hydraulic_pressure > 5 then
        door_speedC1 = rescale(5, 35, 1750, 15, simDR_yellow_hydraulic_pressure)
        door_speedC2 = rescale(5, 35, 1750, 15, simDR_yellow_hydraulic_pressure)
    else
        door_speedC1 = 35 * ping_pong
        door_speedC2 = 35 * ping_pong
    end

    simDR_doorC1 = animate(simDR_doorC1, door_speedC1, 6)
    simDR_doorC2 = animate(simDR_doorC2, door_speedC2, 6)

    A333DR_yellow_trigger_cargo = yellow_trigger_cargo

    A333DR_hydraulic_power_ac1 = ((simDR_yellow_elec_pump_on == 1 and A333DR_ac_bus1_has_power == 1) and 25) or 0 -- plugin_bus_amps[1]
    A333DR_hydraulic_power_ac2 = ((simDR_yellow_elec_pump_on == 1 and A333DR_dc_bus2_has_power == 1) and 1) or 0 -- plugin_bus_amps[2]

end





--*************************************************************************************--
--** 				                     PROCESSING             	    			 **--
--*************************************************************************************--

--===| INIT ALL |========================================================================
local function A333_hydraulics_systems_init_all() end



--===| INIT CD |=========================================================================
local function A333_hydraulics_systems_init_CD() end



--===| INIT ER |=========================================================================
local function A333_hydraulics_systems_init_ER() end



--===| DEFERRED INITIALIZATION |=========================================================
function A333_hydraulics_systems_deferred_init() end



--===| DEFERRED PROCESSING |=============================================================
function A333_hydraulics_systems_deferred_processing() end





--=== AIRCRAFT LOAD =====================================================================
function A333_hydraulics_systems_aircraft_load() end



--=== FLIGHT START ======================================================================
function A333_hydraulics_systems_flight_start() end



--=== BEFORE PHYSICS ====================================================================
function A333_hydraulics_systems_before_physics() end



--=== AFTER PHYSICS =====================================================================
function A333_hydraulics_systems_after_physics()

    sim_period = SIM_PERIOD

    A333_gear_deploy_min()
    A333_engine_status()
    A333_elec_hyd_auto_green()
    A333_elec_hyd_stby_blue()
    A333_elec_hyd_auto_yellow()

end




--=== FLIGHT CRASH ======================================================================
function A333_hydraulics_systems_flight_crash()



end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_hydraulics_systems_aircraft_unload()



end




--=== AFTER REPLAY ======================================================================
function A333_hydraulics_systems_after_replay()

    A333_gear_deploy_min()
    A333_engine_status()
    A333_elec_hyd_auto_green()
    A333_elec_hyd_stby_blue()
    A333_elec_hyd_auto_yellow()

end
















--[[


function A333_hydraulics_flight_start()

    -- ALL MODES ------------------------------------------------------------------------
    A333_init_hydraulics_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        A333_init_hydraulics_CD()


        -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

        A333_init_hydraulics_ER()

    end

end




function A333_hydraulics()

    A333_cache_globals()
    A333_gear_deploy_min()
    A333_engine_status()
    A333_elec_hyd_auto_green()
    A333_elec_hyd_stby_blue()
    A333_elec_hyd_auto_yellow()

end




function A333_hydraulics_replay()

    A333_hydraulics()

end

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

    print("hydraulics")
    A333_flight_start_hydraulic()

end

--function flight_crash() end

--function before_physics()

function after_physics()

    A333_ALL_hydraulic()

end

function after_replay()

    A333_ALL_hydraulic()

end




--]]




