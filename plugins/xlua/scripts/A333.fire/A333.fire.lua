jit.off()
--[[
*****************************************************************************************
* Program Script Name	:	A333.fire
* Author Name			:	Alex Unruh
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*   2021-06-09	0.01a				Start of Dev
*
*
*
*
*****************************************************************************************
*        COPYRIGHT © 2021, 2022 Alex Unruh / LAMINAR RESEARCH - ALL RIGHTS RESERVED
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

local engine1_handle_target = 0
local engine2_handle_target = 0
local apu_handle_target = 0

local engine1_handle_status = 0
local engine2_handle_status = 0
local apu_handle_status = 0

local cargo_fire_test_timer = 0
local cargo_fire_test_seq = 0
local cargo_test_trigger = 0

local engine1_agent1_discharge = 0
local engine1_agent2_discharge = 0
local engine2_agent1_discharge = 0
local engine2_agent2_discharge = 0
local apu_agent_discharge = 0

--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_startup_running               = find_dataref("sim/operation/prefs/startup_running")

simDR_fire_ext_eng1					= find_dataref("sim/cockpit2/engine/actuators/fire_extinguisher_on[0]")
simDR_fire_ext_eng2					= find_dataref("sim/cockpit2/engine/actuators/fire_extinguisher_on[1]")

simDR_apu_fire						= find_dataref("sim/operation/failures/rel_apu_fire")

-- failure modes

simDR_IDG1_disconnect				= find_dataref("sim/operation/failures/rel_genera0")
simDR_IDG2_disconnect				= find_dataref("sim/operation/failures/rel_genera1")
simDR_FADEC1_status					= find_dataref("sim/operation/failures/rel_fadec_0")
simDR_FADEC2_status					= find_dataref("sim/operation/failures/rel_fadec_1")
simDR_FADEC1_off					= find_dataref("sim/cockpit2/engine/actuators/fadec_on[0]")
simDR_FADEC2_off					= find_dataref("sim/cockpit2/engine/actuators/fadec_on[1]")
simDR_eng1_bleed					= find_dataref("sim/operation/failures/rel_bleed_air_lft")
simDR_eng2_bleed					= find_dataref("sim/operation/failures/rel_bleed_air_rgt")
simDR_eng1_hydraulics				= find_dataref("sim/operation/failures/rel_hydpmp")
simDR_eng2_hydraulics				= find_dataref("sim/operation/failures/rel_hydpmp2")
simDR_eng1_fuel_pump_fail			= find_dataref("sim/operation/failures/rel_fuepmp0")
simDR_eng2_fuel_pump_fail			= find_dataref("sim/operation/failures/rel_fuepmp1")
simDR_eng1_fuel_pump_off			= find_dataref("sim/cockpit2/engine/actuators/fuel_pump_on[0]")
simDR_eng2_fuel_pump_off			= find_dataref("sim/cockpit2/engine/actuators/fuel_pump_on[1]")
simDR_pack1_status					= find_dataref("sim/cockpit2/bleedair/actuators/pack_left")
simDR_pack2_status					= find_dataref("sim/cockpit2/bleedair/actuators/pack_right")

simDR_apu_bleed						= find_dataref("sim/operation/failures/rel_APU_press")
simDR_apu_fail						= find_dataref("sim/operation/failures/rel_apu")
simDR_apu_gen						= find_dataref("sim/cockpit2/electrical/APU_generator_on")
simDR_bleed_cross_feed_valve		= find_dataref("sim/cockpit2/bleedair/actuators/isol_valve_right")
simDR_apu_running					= find_dataref("sim/cockpit/engine/APU_running")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

A333_eng1_fire_cover_pos			= find_dataref("laminar/A333/button_switch/guard_cover_pos[8]")
A333_eng2_fire_cover_pos			= find_dataref("laminar/A333/button_switch/guard_cover_pos[9]")
A333_apu_fire_cover_pos				= find_dataref("laminar/A333/button_switch/guard_cover_pos[3]")

A333_IDG1_status					= find_dataref("laminar/A333/status/elec/IDG1") -- 0 if OFF, 1 if ON
A333_IDG2_status					= find_dataref("laminar/A333/status/elec/IDG2") -- 0 if OFF, 1 if ON

--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

A333DR_init_fire_CD           		= create_dataref("laminar/A333/init_CD/fire", "number")

A333_apu_fire_test					= create_dataref("laminar/A333/fire/apu_test_on", "number")
A333_engine_fire_test				= create_dataref("laminar/A333/fire/engine_test_on", "number")
A333_cargo_fire_test				= create_dataref("laminar/A333/fire/cargo_test_on", "number")

A333_apu_fire_test_pos				= create_dataref("laminar/A333/fire/buttons/apu_test_pos", "number")
A333_engine_fire_test_pos			= create_dataref("laminar/A333/fire/buttons/engine_test_pos", "number")
A333_cargo_fire_test_pos			= create_dataref("laminar/A333/fire/buttons/cargo_test_pos", "number")

A333_eng1_fire_handle_pos			= create_dataref("laminar/A333/fire/switches/eng1_handle", "number")
A333_eng2_fire_handle_pos			= create_dataref("laminar/A333/fire/switches/eng2_handle", "number")
A333_apu_fire_handle_pos			= create_dataref("laminar/A333/fire/switches/apu_handle", "number")

A333_eng1_agent1_pos				= create_dataref("laminar/A333/fire/buttons/eng1_agent1_pos", "number")
A333_eng1_agent2_pos				= create_dataref("laminar/A333/fire/buttons/eng1_agent2_pos", "number")
A333_eng2_agent1_pos				= create_dataref("laminar/A333/fire/buttons/eng2_agent1_pos", "number")
A333_eng2_agent2_pos				= create_dataref("laminar/A333/fire/buttons/eng2_agent2_pos", "number")
A333_apu_agent_pos					= create_dataref("laminar/A333/fire/buttons/apu_agent_pos", "number")

A333_eng1_agent1_psi				= create_dataref("laminar/A333/fire/status/eng1_agent1_psi", "number")
A333_eng1_agent2_psi				= create_dataref("laminar/A333/fire/status/eng1_agent2_psi", "number")
A333_eng2_agent1_psi				= create_dataref("laminar/A333/fire/status/eng2_agent1_psi", "number")
A333_eng2_agent2_psi				= create_dataref("laminar/A333/fire/status/eng2_agent2_psi", "number")
A333_apu_agent_psi					= create_dataref("laminar/A333/fire/status/apu_agent_psi", "number")

A333_cargo_fire_test_timer			= create_dataref("laminar/A333/fire/timer/cargo_test", "number")

A333_eng1_hyd_fire_valve_pos		= create_dataref("laminar/A333/fire/hydraulic_fire_valve1_pos", "number")
A333_eng2_hyd_fire_valve_pos		= create_dataref("laminar/A333/fire/hydraulic_fire_valve2_pos", "number")

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

simCMD_fire_test_eng1			= find_command("sim/annunciator/test_fire_1_annun")
simCMD_fire_test_eng2			= find_command("sim/annunciator/test_fire_2_annun")
simCMD_master_warning_accept	= find_command("sim/annunciator/clear_master_warning")




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

function A333_apu_fire_test_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_apu_fire_test_pos = 1
		A333_apu_fire_test = 1
	elseif phase == 2 then
		A333_apu_fire_test_pos = 0
		A333_apu_fire_test = 0
	end
end

function A333_eng_fire_test_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_engine_fire_test_pos = 1
		A333_engine_fire_test = 1
		simCMD_fire_test_eng1:start()
		simCMD_fire_test_eng2:start()
	elseif phase == 2 then
		A333_engine_fire_test_pos = 0
		A333_engine_fire_test = 0
		simCMD_fire_test_eng1:stop()
		simCMD_fire_test_eng2:stop()
	end
end

function A333_cargo_fire_test_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_cargo_fire_test_pos = 1
	elseif phase == 1 then
		cargo_fire_test_timer = cargo_fire_test_timer + SIM_PERIOD
	elseif phase == 2 then
		A333_cargo_fire_test_pos = 0
		cargo_fire_test_timer = 0
	end
end

function A333_engine1_fire_handle_pushCMDhandler(phase, duration)
	if phase == 0 then
		if A333_eng1_fire_cover_pos >= 0.99 then
			if engine1_handle_target == 0 then
				engine1_handle_target = 0.1
				engine1_handle_status = 1
			elseif engine1_handle_target == 1 then
				engine1_handle_target = 0.1
				engine1_handle_status = 0
			end
		elseif A333_eng1_fire_cover_pos < 0.99 then
			engine1_handle_target = 0
		end
	elseif phase == 2 then
		engine1_handle_target = engine1_handle_status
	end
end

function A333_engine2_fire_handle_pushCMDhandler(phase, duration)
	if phase == 0 then
		if A333_eng2_fire_cover_pos >= 0.99 then
			if engine2_handle_target == 0 then
				engine2_handle_target = 0.1
				engine2_handle_status = 1
			elseif engine2_handle_target == 1 then
				engine2_handle_target = 0.1
				engine2_handle_status = 0
			end
		elseif A333_eng2_fire_cover_pos < 0.99 then
			engine2_handle_target = 0
		end
	elseif phase == 2 then
		engine2_handle_target = engine2_handle_status
	end
end

function A333_apu_fire_handle_pushCMDhandler(phase, duration)
	if phase == 0 then
		if A333_apu_fire_cover_pos >= 0.99 then
			if apu_handle_target == 0 then
				apu_handle_target = 0.1
				apu_handle_status = 1
			elseif apu_handle_target == 1 then
				apu_handle_target = 0.1
				apu_handle_status = 0
			end
		elseif A333_apu_fire_cover_pos < 0.99 then
			apu_handle_target = 0
		end
	elseif phase == 2 then
		apu_handle_target = apu_handle_status
	end
end

function A333_eng1_agent1_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_eng1_agent1_pos = 1
		if A333_eng1_fire_handle_pos == 1 then
			engine1_agent1_discharge = 1
		end
	elseif phase == 2 then
		A333_eng1_agent1_pos = 0
	end
end

function A333_eng1_agent2_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_eng1_agent2_pos = 1
		if A333_eng1_fire_handle_pos == 1 then
			engine1_agent2_discharge = 1
		end
	elseif phase == 2 then
		A333_eng1_agent2_pos = 0
	end
end

function A333_eng2_agent1_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_eng2_agent1_pos = 1
		if A333_eng2_fire_handle_pos == 1 then
			engine2_agent1_discharge = 1
		end
	elseif phase == 2 then
		A333_eng2_agent1_pos = 0
	end
end

function A333_eng2_agent2_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_eng2_agent2_pos = 1
		if A333_eng2_fire_handle_pos == 1 then
			engine2_agent2_discharge = 1
		end
	elseif phase == 2 then
		A333_eng2_agent2_pos = 0
	end
end

function A333_apu_agent_pushCMDhandler(phase, duration)
	if phase == 0 then
		A333_apu_agent_pos = 1
		if A333_apu_fire_handle_pos == 1 then
			apu_agent_discharge = 1
		end
	elseif phase == 2 then
		A333_apu_agent_pos = 0
	end
end


-- AI

function A333_ai_fire_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	A333_set_fire_all_modes()
	  	A333_set_fire_CD()
	  	A333_set_fire_ER()
	end
end

--*************************************************************************************--
--** 				                 CUSTOM COMMANDS                			     **--
--*************************************************************************************--

A333CMD_apu_fire_test_push			= create_command("laminar/A333/fire/buttons/apu_fire_test_push", "APU Fire Test", A333_apu_fire_test_pushCMDhandler)
A333CMD_eng_fire_test_push			= create_command("laminar/A333/fire/buttons/eng_fire_test_push", "ENGINES Fire Test", A333_eng_fire_test_pushCMDhandler)
A333CMD_cargo_fire_test_push		= create_command("laminar/A333/fire/buttons/cargo_fire_test_push", "CARGO Fire Test", A333_cargo_fire_test_pushCMDhandler)

A333CMD_engine1_fire_handle_push	= create_command("laminar/A333/fire/switches/engine1_fire_push", "ENGINE 1 FIRE Handle", A333_engine1_fire_handle_pushCMDhandler)
A333CMD_engine2_fire_handle_push	= create_command("laminar/A333/fire/switches/engine2_fire_push", "ENGINE 2 FIRE Handle", A333_engine2_fire_handle_pushCMDhandler)
A333CMD_apu_fire_handle_push		= create_command("laminar/A333/fire/switches/apu_fire_push", "APU FIRE Handle", A333_apu_fire_handle_pushCMDhandler)

A333CMD_eng1_agent1_push			= create_command("laminar/A333/fire/buttons/eng1_agent1_push", "Engine 1 Agent 1 Discharge", A333_eng1_agent1_pushCMDhandler)
A333CMD_eng1_agent2_push			= create_command("laminar/A333/fire/buttons/eng1_agent2_push", "Engine 1 Agent 2 Discharge", A333_eng1_agent2_pushCMDhandler)
A333CMD_eng2_agent1_push			= create_command("laminar/A333/fire/buttons/eng2_agent1_push", "Engine 2 Agent 1 Discharge", A333_eng2_agent1_pushCMDhandler)
A333CMD_eng2_agent2_push			= create_command("laminar/A333/fire/buttons/eng2_agent2_push", "Engine 2 Agent 2 Discharge", A333_eng2_agent2_pushCMDhandler)
A333CMD_apu_agent_push				= create_command("laminar/A333/fire/buttons/apu_agent_push", "APU Agent Discharge", A333_apu_agent_pushCMDhandler)

-- AI

A333CMD_ai_fire_quick_start		= create_command("laminar/A333/ai/fire_quick_start", "AI Fire", A333_ai_fire_quick_start_CMDhandler)

--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--

----- ANIMATION UTILITY -----------------------------------------------------------------
function A333_set_animation_position(current_value, target, min, max, speed)

    local fps_factor = math.min(1.0, speed * SIM_PERIOD)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
       return min
    else
        return current_value + ((target - current_value) * fps_factor)
    end

end

----- RESCALE ---------------------------------------------------------------------------
function A333_rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end


function A333_fire_handle_animation()

	A333_eng1_fire_handle_pos = A333_set_animation_position(A333_eng1_fire_handle_pos, engine1_handle_target, 0, 1, 8)
	A333_eng2_fire_handle_pos = A333_set_animation_position(A333_eng2_fire_handle_pos, engine2_handle_target, 0, 1, 8)
	A333_apu_fire_handle_pos = A333_set_animation_position(A333_apu_fire_handle_pos, apu_handle_target, 0, 1, 8)

end

function A333_cargo_fire_test_seq()

	if cargo_fire_test_timer >= 3 then
		cargo_test_trigger = 1
	elseif cargo_fire_test_timer < 3 then
	end

	if cargo_test_trigger == 1 then
		cargo_fire_test_seq = cargo_fire_test_seq + SIM_PERIOD
	elseif cargo_test_trigger == 0 then
		cargo_fire_test_seq = 0
	end

	if cargo_fire_test_seq > 10 then
		cargo_test_trigger = 0
	end

	if cargo_fire_test_seq > 0 then
		A333_cargo_fire_test = 1
	elseif cargo_fire_test_seq == 0 then
		A333_cargo_fire_test = 0
	end

	A333_cargo_fire_test_timer = cargo_fire_test_seq

end

function A333_extinguisher_agent_discharge()

local extinguisher1a = 0
local extinguisher1b = 0
local extinguisher2a = 0
local extinguisher2b = 0
local extinguisher_apu_trigger = 0

	-- AGENT DISCHARGES

	if engine1_agent1_discharge == 1 then
		A333_eng1_agent1_psi = math.max(0, A333_eng1_agent1_psi - (40.0 * SIM_PERIOD))
	end

	if engine1_agent2_discharge == 1 then
		A333_eng1_agent2_psi = math.max(0, A333_eng1_agent2_psi - (40.0 * SIM_PERIOD))
	end

	if engine2_agent1_discharge == 1 then
		A333_eng2_agent1_psi = math.max(0, A333_eng2_agent1_psi - (40.0 * SIM_PERIOD))
	end

	if engine2_agent2_discharge == 1 then
		A333_eng2_agent2_psi = math.max(0, A333_eng2_agent2_psi - (40.0 * SIM_PERIOD))
	end

	if apu_agent_discharge == 1 then
		A333_apu_agent_psi = math.max(0, A333_apu_agent_psi - (40.0 * SIM_PERIOD))
	end

	-- RUNNING SIM EXTINGUISHERS

	if engine1_agent1_discharge == 1 then
		if A333_eng1_agent1_psi > 0 then
			extinguisher1a = 1
		elseif A333_eng1_agent1_psi == 0 then
			extinguisher1a = 0
			engine1_agent1_discharge = 0
		end
	elseif engine1_agent1_discharge == 0 then
		extinguisher1a = 0
	end

	if engine1_agent2_discharge == 1 then
		if A333_eng1_agent2_psi > 0 then
			extinguisher1b = 1
		elseif A333_eng1_agent2_psi == 0 then
			extinguisher1b = 0
			engine1_agent2_discharge = 0
		end
	elseif engine1_agent2_discharge == 0 then
		extinguisher1b = 0
	end

	if engine2_agent1_discharge == 1 then
		if A333_eng2_agent1_psi > 0 then
			extinguisher2a = 1
		elseif A333_eng2_agent1_psi == 0 then
			extinguisher2a = 0
			engine2_agent1_discharge = 0
		end
	elseif engine2_agent1_discharge == 0 then
		extinguisher2a = 0
	end

	if engine2_agent2_discharge == 1 then
		if A333_eng2_agent2_psi > 0 then
			extinguisher2b = 1
		elseif A333_eng2_agent2_psi == 0 then
			extinguisher2b = 0
			engine2_agent2_discharge = 0
		end
	elseif engine2_agent2_discharge == 0 then
		extinguisher2b = 0
	end

	if extinguisher1a == 1 or extinguisher1b == 1 then
		simDR_fire_ext_eng1 = 1
	elseif extinguisher1a == 0 and extinguisher1b == 0 then
		simDR_fire_ext_eng1 = 0
	end

	if extinguisher2a == 1 or extinguisher2b == 1 then
		simDR_fire_ext_eng2 = 1
	elseif extinguisher2a == 0 and extinguisher2b == 0 then
		simDR_fire_ext_eng2 = 0
	end

	if apu_agent_discharge == 1 then
		if A333_apu_agent_psi < 30 and A333_apu_agent_psi > 25 then
			extinguisher_apu_trigger = 1
		elseif A333_apu_agent_psi <= 25 and A333_apu_agent_psi > 0 then
			extinguisher_apu_trigger = 0
		elseif A333_apu_agent_psi == 0 then
			apu_agent_discharge = 0
		end
	elseif apu_agent_discharge == 0 then
	end

	if extinguisher_apu_trigger	== 1 then
		simDR_apu_fire = 0
	end


end

function A333_kill_systems()

	if A333_eng1_fire_handle_pos == 1 then
		simDR_IDG1_disconnect = 6
		A333_IDG1_status = 0
		simDR_FADEC1_status = 6
		simDR_FADEC1_off = 0
		simDR_eng1_bleed = 6
		simDR_eng1_hydraulics = 6
		simDR_eng1_fuel_pump_fail = 6
		simDR_eng1_fuel_pump_off = 0
		simDR_pack1_status = 0
		A333_eng1_hyd_fire_valve_pos = 1
	end

	if A333_eng2_fire_handle_pos == 1 then
		simDR_IDG2_disconnect = 6
		A333_IDG2_status = 0
		simDR_FADEC2_status = 6
		simDR_FADEC2_off = 0
		simDR_eng2_bleed = 6
		simDR_eng2_hydraulics = 6
		simDR_eng2_fuel_pump_fail = 6
		simDR_eng2_fuel_pump_off = 0
		simDR_pack2_status = 0
		A333_eng2_hyd_fire_valve_pos = 1
	end

	if A333_apu_fire_handle_pos == 1 then
		simDR_apu_bleed	= 6
		simDR_apu_fail = 6
		simDR_apu_gen = 0
		simDR_bleed_cross_feed_valve = 0
		simDR_apu_running = 0
	end

end


----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function A333_fire_monitor_AI()

    if A333DR_init_fire_CD == 1 then
        A333_set_fire_all_modes()
        A333_set_fire_CD()
        A333DR_init_fire_CD = 2
    end

end


----- SET STATE FOR ALL MODES -----------------------------------------------------------
function A333_set_fire_all_modes()

	A333_eng1_agent1_psi = 300
	A333_eng1_agent2_psi = 300
	A333_eng2_agent1_psi = 300
	A333_eng2_agent2_psi = 300
	A333_apu_agent_psi = 300

	engine1_handle_target = 0
	engine2_handle_target = 0
	apu_handle_target = 0

	A333_eng1_fire_handle_pos = 0
	A333_eng2_fire_handle_pos = 0
	A333_apu_fire_handle_pos = 0
	A333_eng1_hyd_fire_valve_pos = 0
	A333_eng2_hyd_fire_valve_pos = 0

end


----- SET STATE TO COLD & DARK ----------------------------------------------------------
function A333_set_fire_CD()

end


----- SET STATE TO ENGINES RUNNING ------------------------------------------------------
function A333_set_fire_ER()

end


----- FLIGHT START ---------------------------------------------------------------------
function A333_flight_start_fire()

    -- ALL MODES ------------------------------------------------------------------------
    A333_set_fire_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        A333_set_fire_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		A333_set_fire_ER()

    end

end


--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

function A333_ALL_fire()

	A333_fire_monitor_AI()
	A333_fire_handle_animation()
	A333_cargo_fire_test_seq()
	A333_extinguisher_agent_discharge()
	A333_kill_systems()

end

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

	A333_flight_start_fire()

end

--function flight_crash() end

--function before_physics()

function after_physics()

	A333_ALL_fire()

end

function after_replay()

	A333_ALL_fire()

end



