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


--*************************************************************************************--
--** 				            LOCAL UTILITY FUNCTIONS          			    	 **--
--*************************************************************************************--
local m = math


--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
--[[
You have three new datarefs now:
sim/operation/override/override_hydr_RAT
sim/operation/override/getting_elec_ADG
can override either of the automatic RAT extension (hydraulic extends upon loss of all
hydraulic pressure, electric extends upon loss of all generators).

sim/cockpit2/electrical/RAT_generator_on -- controls the relay, while
sim/cockpit2/electrical/RAT_generator_extended -- controls the physical extension of the thing that spins.

Normally, the extension happens when weight-off-wheels and no generators, and the relay
closes when the thing is extended and spinning fast enough to make power (i.e. faster than clean stall speed).

For compatibility
sim/cockpit2/electrical/air_driven_generator_on --triggers both.

But with the override set, you can control both individually.
--]]




simDR_override_hydr_RAT     = find_dataref("sim/operation/override/override_hydr_RAT")	-- Override RAT auto-extension, for specfiying the behavior of the ram-air turbine powering the hydraulic system
simDR_RAT_extended          = find_dataref("sim/cockpit2/electrical/RAT_generator_extended") -- Controls the physical extension of the thing that spins.
simDR_RAT_hyd_pump_on       = find_dataref("sim/cockpit2/hydraulics/actuators/ram_air_turbine_on")

simDR_startup_running		= find_dataref("sim/operation/prefs/startup_running")
simDR_sim_time				= find_dataref("sim/time/total_running_time_sec")
simDR_paused 				= find_dataref('sim/time/paused')

simDR_Vso                   = find_dataref("sim/aircraft/view/acf_Vso") -- Stall speed dirty
simDR_equiv_airspeed		= find_dataref("sim/flightmodel/position/equivalent_airspeed")
simDR_airspeed              = find_dataref("sim/flightmodel/position/indicated_airspeed")
simDR_on_ground				= find_dataref("sim/flightmodel/failures/onground_any")
simDR_engine1_running		= find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[0]")
simDR_engine2_running		= find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[1]")
simDR_eng1_N2				= find_dataref("sim/flightmodel2/engines/N2_percent[0]")
simDR_eng2_N2				= find_dataref("sim/flightmodel2/engines/N2_percent[1]")
simDR_green_elec_pump_on	= find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump_on")
simDR_blue_elec_pump_on		= find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump2_on")
simDR_yellow_elec_pump_on	= find_dataref("sim/cockpit2/hydraulics/actuators/electric_hydraulic_pump3_on")

simDR_green_hydraulic_pressure		= find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_1")
simDR_yellow_hydraulic_pressure		= find_dataref("sim/cockpit2/hydraulics/indicators/hydraulic_pressure_2")

simDR_doorC1				= find_dataref("sim/flightmodel2/misc/door_cycle_time[8]") -- = 15 when yellow pump on, 45 with hand pump (no power)
simDR_doorC2				= find_dataref("sim/flightmodel2/misc/door_cycle_time[9]")
simDR_door_ratio			= find_dataref("sim/flightmodel2/misc/door_open_ratio") -- cargo doors are [8] and [9]

simDR_gear_handle_request	= find_dataref("sim/cockpit2/controls/gear_handle_request")
simDR_gear_deploy_rat		= find_dataref("sim/flightmodel2/gear/deploy_ratio")
simDR_flap_deploy_request	= find_dataref("sim/cockpit2/controls/flap_handle_request_ratio")

--simDR_plugin_bus_amps		= find_dataref("sim/cockpit2/electrical/plugin_bus_load_amps")

simDR_indicated_airspeed    = find_dataref("sim/flightmodel/position/indicated_airspeed")


--*************************************************************************************--
--** 				             FIND X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

A333_flight_phase					= find_dataref("laminar/A333/data/flight_phase")

A333_elec_pump_green_contactor		= find_dataref("laminar/A333/hyd/elec_green_contactor") -- 1 = AUTO, 0 = OFF
A333_elec_pump_blue_contactor		= find_dataref("laminar/A333/hyd/elec_blue_contactor") -- 1 = STBY, 0 = OFF
A333_elec_pump_yellow_contactor		= find_dataref("laminar/A333/hyd/elec_yellow_contactor") -- 1 = AUTO, 0 = OFF

A333_elec_pump_green_override_on	= find_dataref("laminar/A333/hyd/elec_green_override_on")
A333_elec_pump_blue_override_on		= find_dataref("laminar/A333/hyd/elec_blue_override_on")
A333_elec_pump_yellow_override_on	= find_dataref("laminar/A333/hyd/elec_yellow_override_on")

A333DR_hyd_green_rsvr_lo_lvl        = find_dataref("laminar/A333/hyd/green_rsvr_lo_lvl")
A333DR_hyd_yellow_rsvr_lo_lvl       = find_dataref("laminar/A333/hyd/green_rsvr_lo_lvl")
A333DR_hyd_blue_rsvr_lo_lvl         = find_dataref("laminar/A333/hyd/green_rsvr_lo_lvl")

A333DR_ac_bus1_has_power 			= find_dataref("laminar/A333/elec/ac_bus1_has_power") -- green, yellow
A333DR_ac_bus2_has_power 			= find_dataref("laminar/A333/elec/ac_bus2_has_power") -- blue
A333DR_dc_bus1_has_power 			= find_dataref("laminar/A333/elec/dc_bus1_has_power") -- green, blue
A333DR_dc_bus2_has_power 			= find_dataref("laminar/A333/elec/dc_bus2_has_power") -- yellow
A333DR_status_gpu_avail 			= find_dataref("laminar/A333/status/GPU_avail") -- yellow
A333DR_extA_grd_service_bus_pwr		= find_dataref("laminar/A333/elec/extA_ground_service_bus_has_power")

A333DR_dc_min_volts					= find_dataref("laminar/A333/elec/dc_min_volts")
A333DR_tr2_volts					= find_dataref("laminar/A333/elec/tr2_volts")

A333_prim1_status					= find_dataref("laminar/A333/fcc/prim1_status", "number")
A333_prim3_status					= find_dataref("laminar/A333/fcc/prim3_status", "number")

A333DR_dc_bat1_hot_bus_has_power    = find_dataref("laminar/A333/elec/dc_hot_bus1_has_power")
A333DR_dc_bat2_hot_bus_has_power    = find_dataref("laminar/A333/elec/dc_hot_bus2_has_power")
A333DR_dc_ess_bus_has_power         = find_dataref("laminar/A333/elec/dc_ess_bus_has_power")

A333DR_trent700_n3_eng1		        = find_dataref("laminar/A333/trent700/n3_eng1")
A333DR_trent700_n3_eng2		        = find_dataref("laminar/A333/trent700/n3_eng2")

A333DR_buttons_rat_man_on_ctct_on_off = find_dataref("laminar/A333/buttons/rat_man_on_ctct_on_off")

A333DR_hydraulic_power_ac1			= create_dataref("laminar/A333/plugin_power/hydraulic_ac1", "number")
A333DR_hydraulic_power_ac2			= create_dataref("laminar/A333/plugin_power/hydraulic_ac2", "number")


--*************************************************************************************--
--** 				             FIND CUSTOM COMMANDS								**--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
A333DR_yellow_trigger_cargo			                = create_dataref("laminar/A333/hyd/yellow_elec_cargo_trigger", "number") -- export status to different script to manage leak measurement valve
A333DR_hyd_rat_actuator_deploy_angle_deg            = create_dataref('laminar/A333/hyd/rat_actuator_deploy_angle_deg', 'number')
A333DR_hyd_rat_actuator_deploy_angle_target_deg     = create_dataref('laminar/A333/hyd/rat_actuator_deploy_angle_target_deg', 'number')
A333DR_hyd_rat_prop_rpm				                = create_dataref('laminar/A333/hyd/rat_prop_rpm', 'number')
A333DR_hyd_rat_prop_angle_deg 		                = create_dataref('laminar/A333/hyd/rat_prop_angle_deg', 'number')


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
function animate(current_value, target, speed)

    local fps_factor = m.min(1.0, speed * SIM_PERIOD)
    local delta = m.abs(current_value - target)

    if delta < 0.000001 then
        return target
    else
        return current_value + ((target - current_value) * fps_factor)
    end

end



function rescale(in1, out1, in2, out2, x)
    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)
end





--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--


--===| INIT ALL |========================================================================
local function A333_hyd_data_init_all() end



--===| INIT CD |=========================================================================
local function A333_hyd_data_init_CD() end



--===| INIT ER |=========================================================================
local function A333_hyd_data_init_ER() end



--===| DEFERRED INITIALIZATION |=========================================================
function A333_hyd_data_deferred_init() end



--===| DEFERRED PROCESSING |=============================================================
function A333_hyd_data_deferred_processing() end





--=== AIRCRAFT LOAD =====================================================================
function A333_hyd_data_aircraft_load() end



--=== FLIGHT START ======================================================================
function A333_hyd_data_flight_start() end



--=== BEFORE PHYSICS ====================================================================
function A333_hyd_data_before_physics() end



--=== AFTER PHYSICS =====================================================================
function A333_hyd_data_after_physics() end




--=== FLIGHT CRASH ======================================================================
function A333_hyd_data_flight_crash() end



--=== AIRCRAFT UNLOAD ===================================================================
function A333_hyd_data_aircraft_unload() end




--=== AFTER REPLAY ==================================---=================================
function A333_hyd_data_after_replay() end
