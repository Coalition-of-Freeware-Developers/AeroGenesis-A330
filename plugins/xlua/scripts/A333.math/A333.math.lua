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
local lcl_SIM_PERIOD = 0

--*************************************************************************************--
--** 					               CONSTANTS                    				 **--
--*************************************************************************************--

local N3_IDLE = 62.8
local N2_IDLE = 49.0

local LATENCY_SEC = 2.0
local LATENCY_LEVEL = 0.07



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local m = math

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
simDR_wheel_brake_ratio		 	= find_dataref("sim/cockpit2/controls/wheel_brake_ratio")
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
local function A333_set_animation_position(current_value, target, min, max, speed)

	local fps_factor = m.min(1.0, speed * lcl_SIM_PERIOD)

	if target >= (max - 0.001) and current_value >= (max - 0.01) then
		return max
	elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
		return min
	else
		return current_value + ((target - current_value) * fps_factor)
	end

end




----- RESCALE ---------------------------------------------------------------------------
local function rescale(in1, out1, in2, out2, x)
    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)
end




----- ENGINE SPOOL MATH FUNCTIONS -------------------------------------------------------
local function clamp(x,min_val,max_val)
	if x < min_val then
		return min_val
	end
	if x > max_val then
		return max_val
	end
	return x
end




local function lerp(now_val, term_val, blend_rat)
	return now_val + ((term_val - now_val) * blend_rat)
end




local function speed_constant_from_time_and_cutoff(total_time, cutoff)
	return -m.log(cutoff) / total_time
end



local function lerp_ratio_for_time_and_speed(speed_constant)
	return 1.0 - m.exp(-speed_constant * lcl_SIM_PERIOD)
end




---- RUNTIME FUNCTIONS
local k1 = m.log((N2_IDLE / 100.0), (N3_IDLE / 100.0))
local k2 = speed_constant_from_time_and_cutoff(LATENCY_SEC,LATENCY_LEVEL)




local function calc_ideal_n2_from_n3(val)
	return 103.3 * m.pow(val / 100.0, k1)
end




-- init n2 FROM n3 for test purposes
local eng1_n2 = calc_ideal_n2_from_n3(eng1_n3)
local eng2_n2 = calc_ideal_n2_from_n3(eng2_n3)

local function update_n2_from_n3()

	blend_ratio = lerp_ratio_for_time_and_speed(k2)

	eng1_n2_target = calc_ideal_n2_from_n3(clamp(eng1_n3, 0.0, 100.0))
	eng2_n2_target = calc_ideal_n2_from_n3(clamp(eng2_n3, 0.0, 100.0))

	eng1_n2 = lerp(eng1_n2, eng1_n2_target, blend_ratio)
	eng2_n2 = lerp(eng2_n2, eng2_n2_target, blend_ratio)

	A333DR_trent700_n2_eng1 = eng1_n2
	A333DR_trent700_n2_eng2 = eng2_n2

	A333DR_trent700_n3_eng1	= eng1_n3
	A333DR_trent700_n3_eng2 = eng2_n3

end


local function A333_nacelle_temperature()
	
	local EGT1 = simDR_EGT1
	local EGT2 = simDR_EGT2

	if EGT1 <= 700 then
		nacelle_temp_eng1_target = rescale(0, 0, 700, 170, EGT1)
	elseif EGT1 > 700 then
		nacelle_temp_eng1_target = rescale(700, 170, 1200, 350, EGT1)
	end

	if EGT2 <= 700 then
		nacelle_temp_eng2_target = rescale(0, 0, 700, 170, EGT2)
	elseif EGT2 > 700 then
		nacelle_temp_eng2_target = rescale(700, 170, 1200, 350, EGT2)
	end

	A333DR_nacelle_temp_eng1 = A333_set_animation_position(A333DR_nacelle_temp_eng1, nacelle_temp_eng1_target, 0, 350, 0.025)
	A333DR_nacelle_temp_eng2 = A333_set_animation_position(A333DR_nacelle_temp_eng2, nacelle_temp_eng2_target, 0, 350, 0.025)

end




local function A333_sin_output()

	-- local vars
	local sim_time = simDR_sim_time
	local engine1_N1 = simDR_engine1_N1
	local engine2_N1 = simDR_engine2_N1
	local reverse_left = simDR_reverse_left
	local reverse_right = simDR_reverse_right
	local flap_left = simDR_flap_left
	local flap_right = simDR_flap_right
	local groundspeed = simDR_groundspeed

	local N1_max = 0
	local brake_factor_target = 0

	local time_modulator = m.sin(sim_time) / 7			-- frequency variable
	local time_modulator2 = m.sin(sim_time) / 9			-- frequency variable
	local time_modulator3 = m.sin(sim_time) / 5

	local vibration_time = sim_time + time_modulator		-- sim time + frequency var. Fractionally modulates the sim time to result in a subtle frequency sweep back and forth
	local vibration_time2 = sim_time + time_modulator2
	local vibration_time3 = sim_time + 2 + time_modulator2
	
	local vibration_time4 = sim_time + time_modulator3
	local vibration_time5 = sim_time + 1 + time_modulator
	local vibration_time6 = sim_time + 2 + time_modulator3
	
	local vibration_time7 = sim_time + 2 + time_modulator
	local vibration_time8 = sim_time + 5 + time_modulator

	local vibration_time9 = sim_time + 4.5 + time_modulator2
	local vibration_time10 = sim_time + 6.5 + time_modulator3
	local vibration_time11 = sim_time + 3.5 + time_modulator2



	-- tail amp vars
	N1_max = m.max(engine1_N1, engine2_N1)
	local equiv_airspeed = simDR_equiv_airspeed

	local speed_amp_factor = rescale(15, 1, 70, 0, groundspeed)					-- amplitude var with groundspeed
	local speed_amp_factor2 = rescale(30, 1, 175, 0, equiv_airspeed)					-- amplitude var for engines with airspeed
	local speed_amp_factor3 = rescale(30, 1, 90, 0, equiv_airspeed)						-- amplitude var for wings with airspeed
	local n1_amp_factor = rescale(60, 0, 100, 1, N1_max)								-- amplitude var with N1

	if simDR_on_ground == 1 then														-- amplitude var with brake + onground status
		brake_factor_target = rescale(0, 0.55, 0.3, 1, simDR_wheel_brake_ratio)
	else
		brake_factor_target = 0.55
	end

	brake_factor = A333_set_animation_position(brake_factor, brake_factor_target, 0.5, 1, 1.5)

	local amplitude_factor = speed_amp_factor * n1_amp_factor * brake_factor			-- sim conditions amplitude factor calculation. All factors are normalized to 1.0


	-- flap amp vars
	local speed_flap_fac = rescale(15, 1, 150, 0.5, groundspeed)

	local n1_left_fac = rescale(60, 0, 100, 1.1, engine1_N1)
	local n1_right_fac = rescale(60, 0, 100, 1.1, engine2_N1)
	
	local n1_left_fac2 = rescale(55, 0, 100, 1.1, engine1_N1)
	local n1_right_fac2 = rescale(55, 0, 100, 1.1, engine2_N1)

	local reverse1_fac = rescale(0, 0.8, 1, 1.25, reverse_left)
	local reverse2_fac = rescale(0, 0.8, 1, 1.25, reverse_right)
	
	local reverse1_fac2 = rescale(0, 0.8, 1, 2, reverse_left)
	local reverse2_fac2 = rescale(0, 0.8, 1, 2, reverse_right)

	local flap_l_deploy_fac = rescale(2, 0, 32, 1.3, flap_left)
	local flap_r_deploy_fac = rescale(2, 0, 32, 1.3, flap_right)

	local left_flap_amp_fac = speed_flap_fac * n1_left_fac * reverse1_fac * flap_l_deploy_fac
	local right_flap_amp_fac = speed_flap_fac * n1_right_fac * reverse2_fac * flap_r_deploy_fac


	-- engine amp vars
	local right_engine_fac = n1_right_fac2 * reverse2_fac2
	local left_engine_fac = n1_left_fac2 * reverse1_fac2
	
	local right_engine_fac_wing = m.max(right_engine_fac, 0.3 * left_engine_fac)
	local left_engine_fac_wing = m.max(left_engine_fac, 0.3 * right_engine_fac)


	-- sin outputs
	local sin_output = m.sin(vibration_time * vibration_speed)									-- base sine constructed out of running simtime and base frequency for tail
	local sin_output2 = m.sin(vibration_time2 * vibration_speed2)								-- base sine constructed out of running simtime and base frequency for left flaps
	local sin_output3 = m.sin(vibration_time3 * vibration_speed2)								-- base sine constructed out of running simtime and base frequency for right flaps

	local sin_output4 = m.sin(vibration_time2 * vibration_speed3)								-- base sine constructed out of running simtime and base frequency for left flaps
	local sin_output5 = m.sin(vibration_time3 * vibration_speed3)								-- base sine constructed out of running simtime and base frequency for right flaps

	local sin_output6 = m.sin(vibration_time4 * vibration_speed4)
	local sin_output7 = m.sin(vibration_time5 * vibration_speed5)
	local sin_output8 = m.sin(vibration_time6 * vibration_speed6)

	local sin_output9 = m.sin(vibration_time7 * vibration_speed7)
	local sin_output10 = m.sin(vibration_time8 * vibration_speed8)

	local sin_output11 = m.sin(vibration_time9 * vibration_speed9)
	local sin_output12 = m.sin(vibration_time10 * vibration_speed10)
	local sin_output13 = m.sin(vibration_time11 * vibration_speed11)

	local sin_output_mod = m.sin(sim_time * 5)										-- sine amplitude vars, uses prime numbers in the frequency var to maximally spread out peaks
	local sin_output_mod2 = m.sin(sim_time * 11)
	local sin_output_mod3 = m.sin(sim_time * 17)
	local sin_output_mod4 = m.sin(sim_time * 13)
	local sin_output_mod5 = m.sin(sim_time * 7)

	local sin_output_mod_amp_fac = rescale(-1, 0.6, 1, 1.1, sin_output_mod)					-- sine amplitude vars normalized for amplitude multiplication
	local sin_output_mod_amp_fac2 = rescale(-1, 0.6, 1, 1.1, sin_output_mod2)
	local sin_output_mod_amp_fac3 = rescale(-1, 0.6, 1, 1.1, sin_output_mod3)
	local sin_output_mod_amp_fac4 = rescale(-1, 0.6, 1, 1.1, sin_output_mod4)
	local sin_output_mod_amp_fac5 = rescale(-1, 0.6, 1, 1.1, sin_output_mod5)


	-- CALCULATIONS FOR FLEX INDUCED ENGINE SHAKE
	local wing_tip_def = simDR_wing_tip_def
	local wing_flex_var = A333DR_wing_flex_var

	A333DR_wing_test = wing_init

	if wing_init == 0 then
		wing_tip_def_delta_loop = wing_tip_def[0]
		wing_init = 1

	elseif wing_init == 1 then

		wing_tip_def_delta = wing_tip_def[0] - wing_tip_def_delta_loop

		wing_flex_var = m.abs(wing_tip_def_delta / lcl_SIM_PERIOD) -- determines change over cycle loop of wingflex

		wing_tip_def_delta_loop = wing_tip_def[0]
	
		if wing_flex_var > wing_flex_timer then
			wing_flex_timer = m.min(wing_flex_var, 15)
		else
			wing_flex_timer = m.abs(wing_flex_timer - lcl_SIM_PERIOD * 3)
		end
	
		A333DR_wing_flex_timer = wing_flex_timer

	end


	-- DR outputs
	A333DR_tail_sin_wave = sin_output * amplitude_factor * sin_output_mod_amp_fac * sin_output_mod_amp_fac2 * sin_output_mod_amp_fac3 * 0.85

	A333DR_flapl_sin_wave = sin_output2 * left_flap_amp_fac * sin_output_mod_amp_fac5 * sin_output_mod_amp_fac4
	A333DR_flapr_sin_wave = sin_output3 * right_flap_amp_fac * sin_output_mod_amp_fac5 * sin_output_mod_amp_fac2
	A333DR_flapl_sin_wave2 = sin_output4 * left_flap_amp_fac * sin_output_mod_amp_fac * sin_output_mod_amp_fac4 * 2
	A333DR_flapr_sin_wave2 = sin_output5 * right_flap_amp_fac * sin_output_mod_amp_fac * sin_output_mod_amp_fac2 * 2

	A333DR_nacelleR_x_vib = sin_output6	* m.max( (rescale(0.1, 0, 15, 0.8, wing_flex_timer)) , (right_engine_fac * speed_amp_factor2 * 0.5) )
	A333DR_navelleR_y_vib = sin_output7	* m.max( (rescale(0.1, 0, 15, 0.8, wing_flex_timer)) , (right_engine_fac * speed_amp_factor2 * 0.5) )
	A333DR_nacelleR_z_vib = sin_output8	* m.max( (rescale(0.1, 0, 15, 0.8, wing_flex_timer)) , (right_engine_fac * speed_amp_factor2 * 0.5) )

	A333DR_wing_flex_right = wing_tip_def[1] + 0.25 * (sin_output9 * right_engine_fac_wing * speed_amp_factor3) -- need to add sympathetic factor for differential thrust
	A333DR_wing_flex_left = wing_tip_def[0] + 0.25 * (sin_output10 * left_engine_fac_wing * speed_amp_factor3)

	A333DR_nacelleL_x_vib = sin_output11 * m.max( (rescale(0.1, 0, 15, 0.8, wing_flex_timer)) , (left_engine_fac * speed_amp_factor2 * 0.5) )
	A333DR_navelleL_y_vib = sin_output12 * m.max( (rescale(0.1, 0, 15, 0.8, wing_flex_timer)) , (left_engine_fac * speed_amp_factor2 * 0.5) )
	A333DR_nacelleL_z_vib = sin_output13 * m.max( (rescale(0.1, 0, 15, 0.8, wing_flex_timer)) , (left_engine_fac * speed_amp_factor2 * 0.5) )

end




local function A333_gear_geo()

	local gear_deflect_left = rescale(0, 0, 1.75, 1.75, simDR_gear_deflect_left)
	local gear_deflect_right = rescale(0, 0, 1.75, 1.75, simDR_gear_deflect_right)
	local eagle_theta_left = rescale(-8, -8, 26, 26, simDR_eagle_theta_left)
	local eagle_theta_right = rescale(-8, -8, 26, 26, simDR_eagle_theta_right)

	A333DR_lenAvar_left = (strut_vert_extended - gear_deflect_left) * vertical_def_ratio
	A333DR_lenAvar_right = (strut_vert_extended - gear_deflect_right) * vertical_def_ratio

	A333DR_lenBvar_left = m.sqrt(lenCc^2 + A333DR_lenAvar_left^2)
	A333DR_lenBvar_right = m.sqrt(lenCc^2 + A333DR_lenAvar_right^2)

	thetai_l = eagle_claw_constant - eagle_theta_left
	thetaii_l = m.deg(m.tan(lenCc / A333DR_lenAvar_left))
	thetaiii_l = thetai_l - thetaii_l

	A333DR_thetai_left = thetai_l
	A333DR_thetaii_left = thetaii_l
	A333DR_thetaiii_left = thetaiii_l

	thetai_r = eagle_claw_constant - eagle_theta_right
	thetaii_r = m.deg(m.tan(lenCc / A333DR_lenAvar_right))
	thetaiii_r = thetai_r - thetaii_r

	A333DR_thetai_right = thetai_r
	A333DR_thetaii_right = thetaii_r
	A333DR_thetaiii_right = thetaiii_r

	local lcl_lenEvar_left_preClamp = m.sqrt(lenDc^2 + A333DR_lenBvar_left^2 - (2 * (lenDc * A333DR_lenBvar_left * m.cos(m.rad(A333DR_thetaiii_left)))))
	local lcl_lenEvar_right_preClamp = m.sqrt(lenDc^2 + A333DR_lenBvar_right^2 - (2 * (lenDc * A333DR_lenBvar_right * m.cos(m.rad(A333DR_thetaiii_right)))))
	local lcl_lenEvar_left = rescale(0, 0, 1.38665, 1.38665, lcl_lenEvar_left_preClamp)
	local lcl_lenEvar_right = rescale(0, 0, 1.38665, 1.38665, lcl_lenEvar_right_preClamp)

	A333DR_lenEvar_left = lcl_lenEvar_left
	A333DR_lenEvar_right = lcl_lenEvar_right

	local theta2_l = m.deg(m.acos((lcl_lenEvar_left^2 + lenFc^2 - lenGc^2) / (2 * (lcl_lenEvar_left * lenFc))))
	local theta3_l = m.deg(m.acos((lcl_lenEvar_left^2 + lenGc^2 - lenFc^2) / (2 * (lcl_lenEvar_left * lenGc))))

	local theta2_r = m.deg(m.acos((lcl_lenEvar_right^2 + lenFc^2 - lenGc^2) / (2 * (lcl_lenEvar_right * lenFc))))
	local theta3_r = m.deg(m.acos((lcl_lenEvar_right^2 + lenGc^2 - lenFc^2) / (2 * (lcl_lenEvar_right * lenGc))))

	local theta4_l = m.deg(m.acos((lcl_lenEvar_left^2 + lenDc^2 - A333DR_lenBvar_left^2) / (2 * (lcl_lenEvar_left * lenDc))))
	local theta5_l = 270 - theta4_l - A333DR_thetai_left

	local theta4_r = m.deg(m.acos((lcl_lenEvar_right^2 + lenDc^2 - A333DR_lenBvar_right^2) / (2 * (lcl_lenEvar_right * lenDc))))
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



local function A333_init_math_all_modes()
	wing_init = 0
end



local function A333_init_math_CD() end



local function A333_init_math_ER() end




----- FLIGHT START ---------------------------------------------------------------------
local function A333_flight_start_math()

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

local function A333_ALL_math()

	lcl_SIM_PERIOD = SIM_PERIOD

	update_n2_from_n3()
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



