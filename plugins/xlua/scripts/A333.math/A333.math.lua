jit.off()
--[[
*****************************************************************************************
* Program Script Name	:	A333.math
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
*        COPYRIGHT © 2019 Alex Unruh / LAMINAR RESEARCH - ALL RIGHTS RESERVED	        *
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

n3_idle = 62.8
n2_idle = 49.0

latency_sec = 2.0
latency_level = 0.07

--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--

local sin_output = 1
local vibration_speed = 33
local vibration_speed2 = 58
local vibration_speed3 = 53

local vibration_speed4 = 14
local vibration_speed5 = 13
local vibration_speed6 = 12

local vibration_speed7 = 7
local vibration_speed8 = 7

local vibration_speed9 = 14
local vibration_speed10 = 13
local vibration_speed11 = 12

local brake_factor = 0

local vertical_def_ratio = 1.0131
local eagle_claw_constant = 68.235
local strut_vert_extended = 1.679
local theta2c = 98.999093
local theta3c = 47.011433
local theta4c = 119.728168
local theta5c = 108.286832

local lenCc = 0.2848
local lenGc = 0.6007
local lenFc = 0.786
local lenDc = 0.9315

local nacelle_temp_eng1_target = 0
local nacelle_temp_eng2_target = 0

local wing_tip_def_delta = 0
local wing_tip_def_delta_loop = 0
local wing_flex_timer = 0
local engine_flex_fade = 0
local wing_init = 0


--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_sim_time				= find_dataref("sim/time/total_running_time_sec")
simDR_engine1_N1			= find_dataref("sim/flightmodel2/engines/N1_percent[0]")
simDR_engine2_N1			= find_dataref("sim/flightmodel2/engines/N1_percent[1]")
simDR_groundspeed			= find_dataref("sim/flightmodel/position/groundspeed")
simDR_equiv_airspeed		= find_dataref("sim/flightmodel/position/equivalent_airspeed")
simDR_park_brake		 	= find_dataref("sim/cockpit2/controls/parking_brake_ratio")
simDR_on_ground				= find_dataref("sim/flightmodel/failures/onground_any")
simDR_flap_left				= find_dataref("sim/flightmodel2/wing/flap1_deg[0]")							-- min 14 max 32
simDR_flap_right			= find_dataref("sim/flightmodel2/wing/flap1_deg[1]")
simDR_reverse_left			= find_dataref("sim/flightmodel2/engines/thrust_reverser_deploy_ratio[0]")		-- 1.0 when deployed
simDR_reverse_right			= find_dataref("sim/flightmodel2/engines/thrust_reverser_deploy_ratio[1]")

simDR_gear_deflect_left		= find_dataref("sim/flightmodel2/gear/tire_vertical_deflection_mtr[1]")
simDR_gear_deflect_right	= find_dataref("sim/flightmodel2/gear/tire_vertical_deflection_mtr[2]")

simDR_eagle_theta_left		= find_dataref("sim/flightmodel2/gear/eagle_claw_angle_deg[1]")
simDR_eagle_theta_right		= find_dataref("sim/flightmodel2/gear/eagle_claw_angle_deg[2]")

eng1_n3						= find_dataref("sim/flightmodel2/engines/N2_percent[0]")
eng2_n3						= find_dataref("sim/flightmodel2/engines/N2_percent[1]")

simDR_TAT					= find_dataref("sim/weather/aircraft/temperature_leadingedge_deg_c")
simDR_EGT1					= find_dataref("sim/flightmodel2/engines/EGT_deg_cel[0]")
simDR_EGT2					= find_dataref("sim/flightmodel2/engines/EGT_deg_cel[1]")

simDR_wing_tip_def			= find_dataref("sim/flightmodel2/wing/wing_tip_deflection_deg")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

A333DR_tail_sin_wave		= create_dataref("laminar/A333/tail/vibration", "number")
A333DR_flapl_sin_wave		= create_dataref("laminar/A333/flap/vibration_left", "number")
A333DR_flapr_sin_wave		= create_dataref("laminar/A333/flap/vibration_right", "number")
A333DR_flapl_sin_wave2		= create_dataref("laminar/A333/flap/vibration_left2", "number")
A333DR_flapr_sin_wave2		= create_dataref("laminar/A333/flap/vibration_right2", "number")

A333DR_lenAvar_left			= create_dataref("laminar/A333/length/side_A_left", "number")
A333DR_lenBvar_left			= create_dataref("laminar/A333/length/side_B_left", "number")
A333DR_lenEvar_left			= create_dataref("laminar/A333/length/side_E_left", "number")

A333DR_thetai_left			= create_dataref("laminar/A333/theta/i_left", "number")
A333DR_thetaii_left			= create_dataref("laminar/A333/theta/ii_left", "number")
A333DR_thetaiii_left		= create_dataref("laminar/A333/theta/iii_left", "number")

A333DR_theta2var_left		= create_dataref("laminar/A333/angle/theta_2_left", "number")
A333DR_theta3var_left		= create_dataref("laminar/A333/angle/theta_3_left", "number")
A333DR_theta4var_left		= create_dataref("laminar/A333/angle/theta_4_left", "number")
A333DR_theta5var_left		= create_dataref("laminar/A333/angle/theta_5_left", "number")

A333DR_lenAvar_right		= create_dataref("laminar/A333/length/side_A_right", "number")
A333DR_lenBvar_right		= create_dataref("laminar/A333/length/side_B_right", "number")
A333DR_lenEvar_right		= create_dataref("laminar/A333/length/side_E_right", "number")

A333DR_thetai_right			= create_dataref("laminar/A333/theta/i_right", "number")
A333DR_thetaii_right		= create_dataref("laminar/A333/theta/ii_right", "number")
A333DR_thetaiii_right		= create_dataref("laminar/A333/theta/iii_right", "number")

A333DR_theta2var_right		= create_dataref("laminar/A333/angle/theta_2_right", "number")
A333DR_theta3var_right		= create_dataref("laminar/A333/angle/theta_3_right", "number")
A333DR_theta4var_right		= create_dataref("laminar/A333/angle/theta_4_right", "number")
A333DR_theta5var_right		= create_dataref("laminar/A333/angle/theta_5_right", "number")

A333DR_trent700_n2_eng1		= create_dataref("laminar/A333/trent700/n2_eng1", "number")
A333DR_trent700_n2_eng2		= create_dataref("laminar/A333/trent700/n2_eng2", "number")

A333DR_trent700_n3_eng1		= create_dataref("laminar/A333/trent700/n3_eng1", "number")
A333DR_trent700_n3_eng2		= create_dataref("laminar/A333/trent700/n3_eng2", "number")

A333DR_nacelle_temp_eng1	= create_dataref("laminar/A333/trent700/nacelle_temp1", "number")
A333DR_nacelle_temp_eng2	= create_dataref("laminar/A333/trent700/nacelle_temp2", "number")

A333DR_nacelleL_x_vib		= create_dataref("laminar/A333/engineL/vibration_x", "number")
A333DR_navelleL_y_vib		= create_dataref("laminar/A333/engineL/vibration_y", "number")
A333DR_nacelleL_z_vib		= create_dataref("laminar/A333/engineL/vibration_z", "number")

A333DR_nacelleR_x_vib		= create_dataref("laminar/A333/engineR/vibration_x", "number")
A333DR_navelleR_y_vib		= create_dataref("laminar/A333/engineR/vibration_y", "number")
A333DR_nacelleR_z_vib		= create_dataref("laminar/A333/engineR/vibration_z", "number")

A333DR_wing_flex_var		= create_dataref("laminar/A333/math/wing_flex_delta", "number")
A333DR_wing_flex_timer		= create_dataref("laminar/A333/math/wing_flex_timer", "number")

A333DR_wing_flex_right		= create_dataref("laminar/A333/math/wing_flex_right", "number")
A333DR_wing_flex_left		= create_dataref("laminar/A333/math/wing_flex_left", "number")

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

----- ENGINE SPOOL MATH FUNCTIONS -------------------------------------------------------

function clamp(x,min_val,max_val)
	if x < min_val then
		return min_val
	end
	if x > max_val then
		return max_val
	end
	return x
end

function lerp(now_val,term_val,blend_rat)
	return now_val + ((term_val - now_val) * blend_rat)
end

function speed_constant_from_time_and_cutoff(total_time, cutoff)
	return -math.log(cutoff) / total_time
end

function lerp_ratio_for_time_and_speed(SIM_PERIOD, speed_constant)
	return 1.0 - math.exp(-speed_constant * SIM_PERIOD)
end

---- RUNTIME FUNCTIONS

k1 = math.log((n2_idle / 100.0),(n3_idle / 100.0))
k2 = speed_constant_from_time_and_cutoff(latency_sec,latency_level)

function calc_ideal_n2_from_n3(val)
	return 103.3 * math.pow(val / 100.0, k1)
end


-- init n2 FROM n3 for test purposes
eng1_n2 = calc_ideal_n2_from_n3(eng1_n3)
eng2_n2 = calc_ideal_n2_from_n3(eng2_n3)


function update_n2_from_n3(SIM_PERIOD)

	blend_ratio = lerp_ratio_for_time_and_speed(SIM_PERIOD,k2)

	eng1_n2_target = calc_ideal_n2_from_n3(clamp(eng1_n3,0.0,100.0))
	eng2_n2_target = calc_ideal_n2_from_n3(clamp(eng2_n3,0.0,100.0))

	eng1_n2 = lerp(eng1_n2,eng1_n2_target,blend_ratio)
	eng2_n2 = lerp(eng2_n2,eng2_n2_target,blend_ratio)

	A333DR_trent700_n2_eng1 = eng1_n2
	A333DR_trent700_n2_eng2 = eng2_n2

	A333DR_trent700_n3_eng1	= eng1_n3
	A333DR_trent700_n3_eng2 = eng2_n3

end


function A333_nacelle_temperature()

	if simDR_EGT1 <= 700 then
		nacelle_temp_eng1_target = A333_rescale(0, 0, 700, 170, simDR_EGT1)
	elseif simDR_EGT1 > 700 then
		nacelle_temp_eng1_target = A333_rescale(700, 170, 1200, 350, simDR_EGT1)
	end

	if simDR_EGT2 <= 700 then
		nacelle_temp_eng2_target = A333_rescale(0, 0, 700, 170, simDR_EGT2)
	elseif simDR_EGT2 > 700 then
		nacelle_temp_eng2_target = A333_rescale(700, 170, 1200, 350, simDR_EGT2)
	end

	A333DR_nacelle_temp_eng1 = A333_set_animation_position(A333DR_nacelle_temp_eng1, nacelle_temp_eng1_target, 0, 350, 0.025)
	A333DR_nacelle_temp_eng2 = A333_set_animation_position(A333DR_nacelle_temp_eng2, nacelle_temp_eng2_target, 0, 350, 0.025)

end


-----

function A333_sin_output()

	-- local vars

	local N1_max = 0
	local brake_factor_target = 0

	local time_modulator = math.sin(simDR_sim_time) / 7										-- frequency variable
	local time_modulator2 = math.sin(simDR_sim_time) / 9									-- frequency variable
	local time_modulator3 = math.sin(simDR_sim_time) / 5			

	local vibration_time = simDR_sim_time + time_modulator									-- sim time + frequency var. Fractionally modulates the sim time to result in a subtle frequency sweep back and forth
	local vibration_time2 = simDR_sim_time + time_modulator2
	local vibration_time3 = simDR_sim_time + 2 + time_modulator2
	
	local vibration_time4 = simDR_sim_time + time_modulator3
	local vibration_time5 = simDR_sim_time + 1 + time_modulator
	local vibration_time6 = simDR_sim_time + 2 + time_modulator3
	
	local vibration_time7 = simDR_sim_time + 2 + time_modulator
	local vibration_time8 = simDR_sim_time + 5 + time_modulator

	local vibration_time9 = simDR_sim_time + 4.5 + time_modulator2
	local vibration_time10 = simDR_sim_time + 6.5 + time_modulator3
	local vibration_time11 = simDR_sim_time + 3.5 + time_modulator2

	-- tail amp vars

	N1_max = math.max(simDR_engine1_N1, simDR_engine2_N1)

	local speed_amp_factor = A333_rescale(15, 1, 70, 0, simDR_groundspeed)					-- amplitude var with groundspeed
	local speed_amp_factor2 = A333_rescale(30, 1, 175, 0, simDR_equiv_airspeed)				-- amplitude var for engines with airspeed
	local speed_amp_factor3 = A333_rescale(30, 1, 90, 0, simDR_equiv_airspeed)				-- amplitude var for wings with airspeed
	local n1_amp_factor = A333_rescale(60, 0, 100, 1, N1_max)								-- amplitude var with N1

	if simDR_on_ground == 1 then															-- amplitude var with brake + onground status
		brake_factor_target = A333_rescale(0, 0.55, 0.3, 1, simDR_park_brake)
	else brake_factor_target = 0.55
	end

	brake_factor = A333_set_animation_position(brake_factor, brake_factor_target, 0.5, 1, 1.5)

	local amplitude_factor = speed_amp_factor * n1_amp_factor * brake_factor				-- sim conditions amplitude factor calculation. All factors are normalized to 1.0

	-- flap amp vars

	local speed_flap_fac = A333_rescale(15, 1, 150, 0.5, simDR_groundspeed)

	local n1_left_fac = A333_rescale(60, 0, 100, 1.1, simDR_engine1_N1)
	local n1_right_fac = A333_rescale(60, 0, 100, 1.1, simDR_engine2_N1)
	
	local n1_left_fac2 = A333_rescale(55, 0, 100, 1.1, simDR_engine1_N1)
	local n1_right_fac2 = A333_rescale(55, 0, 100, 1.1, simDR_engine2_N1)

	local reverse1_fac = A333_rescale(0, 0.8, 1, 1.25, simDR_reverse_left)
	local reverse2_fac = A333_rescale(0, 0.8, 1, 1.25, simDR_reverse_right)
	
	local reverse1_fac2 = A333_rescale(0, 0.8, 1, 2, simDR_reverse_left)
	local reverse2_fac2 = A333_rescale(0, 0.8, 1, 2, simDR_reverse_right)

	local flap_l_deploy_fac = A333_rescale(2, 0, 32, 1.3, simDR_flap_left)
	local flap_r_deploy_fac = A333_rescale(2, 0, 32, 1.3, simDR_flap_right)

	local left_flap_amp_fac = speed_flap_fac * n1_left_fac * reverse1_fac * flap_l_deploy_fac
	local right_flap_amp_fac = speed_flap_fac * n1_right_fac * reverse2_fac * flap_r_deploy_fac

	-- engine amp vars
	
	local right_engine_fac = n1_right_fac2 * reverse2_fac2
	local left_engine_fac = n1_left_fac2 * reverse1_fac2
	
	local right_engine_fac_wing = math.max(right_engine_fac, 0.3 * left_engine_fac)
	local left_engine_fac_wing = math.max(left_engine_fac, 0.3 * right_engine_fac)

	-- sin outputs

	sin_output = math.sin(vibration_time * vibration_speed)									-- base sine constructed out of running simtime and base frequency for tail
	sin_output2 = math.sin(vibration_time2 * vibration_speed2)								-- base sine constructed out of running simtime and base frequency for left flaps
	sin_output3 = math.sin(vibration_time3 * vibration_speed2)								-- base sine constructed out of running simtime and base frequency for right flaps

	sin_output4 = math.sin(vibration_time2 * vibration_speed3)								-- base sine constructed out of running simtime and base frequency for left flaps
	sin_output5 = math.sin(vibration_time3 * vibration_speed3)								-- base sine constructed out of running simtime and base frequency for right flaps

	sin_output6 = math.sin(vibration_time4 * vibration_speed4)
	sin_output7 = math.sin(vibration_time5 * vibration_speed5)
	sin_output8 = math.sin(vibration_time6 * vibration_speed6)
	
	sin_output9 = math.sin(vibration_time7 * vibration_speed7)
	sin_output10 = math.sin(vibration_time8 * vibration_speed8)
	
	sin_output11 = math.sin(vibration_time9 * vibration_speed9)
	sin_output12 = math.sin(vibration_time10 * vibration_speed10)
	sin_output13 = math.sin(vibration_time11 * vibration_speed11)


	local sin_output_mod = math.sin(simDR_sim_time * 5)										-- sine amplitude vars, uses prime numbers in the frequency var to maximally spread out peaks
	local sin_output_mod2 = math.sin(simDR_sim_time * 11)
	local sin_output_mod3 = math.sin(simDR_sim_time * 17)
	local sin_output_mod4 = math.sin(simDR_sim_time * 13)
	local sin_output_mod5 = math.sin(simDR_sim_time * 7)

	sin_output_mod_amp_fac = A333_rescale(-1, 0.6, 1, 1.1, sin_output_mod)					-- sine amplitude vars normalized for amplitude multiplication
	sin_output_mod_amp_fac2 = A333_rescale(-1, 0.6, 1, 1.1, sin_output_mod2)
	sin_output_mod_amp_fac3 = A333_rescale(-1, 0.6, 1, 1.1, sin_output_mod3)
	sin_output_mod_amp_fac4 = A333_rescale(-1, 0.6, 1, 1.1, sin_output_mod4)
	sin_output_mod_amp_fac5 = A333_rescale(-1, 0.6, 1, 1.1, sin_output_mod5)

	-- CALCULATIONS FOR FLEX INDUCED ENGINE SHAKE

	A333DR_wing_test = wing_init

	if wing_init == 0 then
		wing_tip_def_delta_loop = simDR_wing_tip_def[0]
		wing_init = 1
	elseif wing_init == 1 then

		wing_tip_def_delta = simDR_wing_tip_def[0] - wing_tip_def_delta_loop
	
		A333DR_wing_flex_var = math.abs(wing_tip_def_delta / SIM_PERIOD) -- determines change over cycle loop of wingflex

		wing_tip_def_delta_loop = simDR_wing_tip_def[0]
	
		if A333DR_wing_flex_var > wing_flex_timer then
			wing_flex_timer = math.min(A333DR_wing_flex_var, 15)
		else wing_flex_timer = math.abs(wing_flex_timer - SIM_PERIOD * 3)
		end
	
		A333DR_wing_flex_timer = wing_flex_timer

	end

	-- DR outputs

	A333DR_tail_sin_wave = sin_output * amplitude_factor * sin_output_mod_amp_fac * sin_output_mod_amp_fac2 * sin_output_mod_amp_fac3 * 0.85

	A333DR_flapl_sin_wave = sin_output2 * left_flap_amp_fac * sin_output_mod_amp_fac5 * sin_output_mod_amp_fac4
	A333DR_flapr_sin_wave = sin_output3 * right_flap_amp_fac * sin_output_mod_amp_fac5 * sin_output_mod_amp_fac2
	A333DR_flapl_sin_wave2 = sin_output4 * left_flap_amp_fac * sin_output_mod_amp_fac * sin_output_mod_amp_fac4 * 2
	A333DR_flapr_sin_wave2 = sin_output5 * right_flap_amp_fac * sin_output_mod_amp_fac * sin_output_mod_amp_fac2 * 2

	A333DR_nacelleR_x_vib = sin_output6	* math.max( (A333_rescale(0.1, 0, 15, 0.8, wing_flex_timer)) , (right_engine_fac * speed_amp_factor2 * 0.5) )
	A333DR_navelleR_y_vib = sin_output7	* math.max( (A333_rescale(0.1, 0, 15, 0.8, wing_flex_timer)) , (right_engine_fac * speed_amp_factor2 * 0.5) )
	A333DR_nacelleR_z_vib = sin_output8	* math.max( (A333_rescale(0.1, 0, 15, 0.8, wing_flex_timer)) , (right_engine_fac * speed_amp_factor2 * 0.5) )

	A333DR_wing_flex_right = simDR_wing_tip_def[1] + 0.25 * (sin_output9 * right_engine_fac_wing * speed_amp_factor3) -- need to add sympathetic factor for differential thrust
	A333DR_wing_flex_left = simDR_wing_tip_def[0] + 0.25 * (sin_output10 * left_engine_fac_wing * speed_amp_factor3)

	A333DR_nacelleL_x_vib = sin_output11 * math.max( (A333_rescale(0.1, 0, 15, 0.8, wing_flex_timer)) , (left_engine_fac * speed_amp_factor2 * 0.5) )
	A333DR_navelleL_y_vib = sin_output12 * math.max( (A333_rescale(0.1, 0, 15, 0.8, wing_flex_timer)) , (left_engine_fac * speed_amp_factor2 * 0.5) )
	A333DR_nacelleL_z_vib = sin_output13 * math.max( (A333_rescale(0.1, 0, 15, 0.8, wing_flex_timer)) , (left_engine_fac * speed_amp_factor2 * 0.5) )

end


function A333_gear_geo()

	A333DR_lenAvar_left = (strut_vert_extended - simDR_gear_deflect_left) * vertical_def_ratio
	A333DR_lenAvar_right = (strut_vert_extended - simDR_gear_deflect_right) * vertical_def_ratio

	A333DR_lenBvar_left = math.sqrt(lenCc^2 + A333DR_lenAvar_left^2)
	A333DR_lenBvar_right = math.sqrt(lenCc^2 + A333DR_lenAvar_right^2)

	thetai_l = eagle_claw_constant - simDR_eagle_theta_left
	thetaii_l = math.deg(math.tan(lenCc / A333DR_lenAvar_left))
	thetaiii_l = thetai_l - thetaii_l

	A333DR_thetai_left = thetai_l
	A333DR_thetaii_left = thetaii_l
	A333DR_thetaiii_left = thetaiii_l

	thetai_r = eagle_claw_constant - simDR_eagle_theta_right
	thetaii_r = math.deg(math.tan(lenCc / A333DR_lenAvar_right))
	thetaiii_r = thetai_r - thetaii_r

	A333DR_thetai_right = thetai_r
	A333DR_thetaii_right = thetaii_r
	A333DR_thetaiii_right = thetaiii_r

	A333DR_lenEvar_left = math.sqrt(lenDc^2 + A333DR_lenBvar_left^2 - (2 * (lenDc * A333DR_lenBvar_left * math.cos(math.rad(A333DR_thetaiii_left)))))
	A333DR_lenEvar_right = math.sqrt(lenDc^2 + A333DR_lenBvar_right^2 - (2 * (lenDc * A333DR_lenBvar_right * math.cos(math.rad(A333DR_thetaiii_right)))))

	local theta2_l = math.deg(math.acos((A333DR_lenEvar_left^2 + lenFc^2 - lenGc^2) / (2 * (A333DR_lenEvar_left * lenFc))))
	local theta3_l = math.deg(math.acos((A333DR_lenEvar_left^2 + lenGc^2 - lenFc^2) / (2 * (A333DR_lenEvar_left * lenGc))))

	local theta2_r = math.deg(math.acos((A333DR_lenEvar_right^2 + lenFc^2 - lenGc^2) / (2 * (A333DR_lenEvar_right * lenFc))))
	local theta3_r = math.deg(math.acos((A333DR_lenEvar_right^2 + lenGc^2 - lenFc^2) / (2 * (A333DR_lenEvar_right * lenGc))))

	local theta4_l = math.deg(math.acos((A333DR_lenEvar_left^2 + lenDc^2 - A333DR_lenBvar_left^2) / (2 * (A333DR_lenEvar_left * lenDc))))
	local theta5_l = 270 - theta4_l - A333DR_thetai_left

	local theta4_r = math.deg(math.acos((A333DR_lenEvar_right^2 + lenDc^2 - A333DR_lenBvar_right^2) / (2 * (A333DR_lenEvar_right * lenDc))))
	local theta5_r = 270 - theta4_r - A333DR_thetai_right

	A333DR_theta2var_left = 180 - theta2_l - theta3_l - theta2c
	A333DR_theta3var_left = theta3_l - theta3c + theta5_l - theta5c

	A333DR_theta2var_right = 180 - theta2_r - theta3_r - theta2c
	A333DR_theta3var_right = theta3_r - theta3c + theta5_r - theta5c

	A333DR_theta4var_left = theta4_l - theta4c
	A333DR_theta5var_left = theta5_l - theta5c

	A333DR_theta4var_right = theta4_r - theta4c
	A333DR_theta5var_right = theta5_r - theta5c

end


function A333_init_math_all_modes() 

	wing_init = 0

end

function A333_init_math_CD() end

function A333_init_math_ER() end


----- FLIGHT START ---------------------------------------------------------------------
function A333_flight_start_math()

    -- ALL MODES ------------------------------------------------------------------------
    A333_init_math_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        A333_init_math_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		A333_init_math_ER()

    end

end


--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

function A333_ALL_math()

	update_n2_from_n3(SIM_PERIOD)
	A333_sin_output()
	A333_gear_geo()
	A333_nacelle_temperature()

end

--function aircraft_load() end

--function aircraft_unload() end

function flight_start()

	A333_flight_start_math()
	
end

--function flight_crash() end

--function before_physics()

function after_physics()

	A333_ALL_math()

end

function after_replay()

	A333_ALL_math()

end



