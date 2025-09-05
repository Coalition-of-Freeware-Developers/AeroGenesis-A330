jit.off()
--[[
*****************************************************************************************
* Program Script Name	:	A333.annunciators_4
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
*        COPYRIGHT © 2021, 2022 Alex Unruh / LAMINAR RESEARCH - ALL RIGHTS RESERVED	    *
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

NUM_CAPT_LISTENING_LIGHTS = 16
NUM_FO_LISTENING_LIGHTS = 16
NUM_OBS_LISTENING_LIGHTS = 16

--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--

local com1_timer = 0
local com2_timer = 0

--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_flight_time					= find_dataref("sim/time/total_flight_time_sec")

simDR_annun_brightness				= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_manual[15]")
simDR_annun_brightness2				= find_dataref("sim/cockpit2/electrical/instrument_brightness_ratio_manual[16]")

--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--

A333_ann_light_switch_pos			= find_dataref("laminar/a333/switches/ann_light_pos")

-- AUDIO PANELS

	-- CAPTAIN MIC LIGHT STATUS

A333DR_audio_panel_capt_mic1_status		= find_dataref("laminar/A333/audio/capt/mic_status1")
A333DR_audio_panel_capt_mic2_status		= find_dataref("laminar/A333/audio/capt/mic_status2")
A333DR_audio_panel_capt_mic3_status		= find_dataref("laminar/A333/audio/capt/mic_status3")
A333DR_audio_panel_capt_mic4_status		= find_dataref("laminar/A333/audio/capt/mic_status4")
A333DR_audio_panel_capt_mic5_status		= find_dataref("laminar/A333/audio/capt/mic_status5")
A333DR_audio_panel_capt_mic6_status		= find_dataref("laminar/A333/audio/capt/mic_status6")
A333DR_audio_panel_capt_mic7_status		= find_dataref("laminar/A333/audio/capt/mic_status7")
A333DR_audio_panel_capt_mic8_status		= find_dataref("laminar/A333/audio/capt/mic_status8")
A333DR_audio_panel_capt_mic9_status		= find_dataref("laminar/A333/audio/capt/mic_status9")
A333DR_audio_panel_capt_mic10_status	= find_dataref("laminar/A333/audio/capt/mic_status10")

	-- FIRST OFFICER MIC LIGHT STATUS

A333DR_audio_panel_fo_mic1_status		= find_dataref("laminar/A333/audio/fo/mic_status1")
A333DR_audio_panel_fo_mic2_status		= find_dataref("laminar/A333/audio/fo/mic_status2")
A333DR_audio_panel_fo_mic3_status		= find_dataref("laminar/A333/audio/fo/mic_status3")
A333DR_audio_panel_fo_mic4_status		= find_dataref("laminar/A333/audio/fo/mic_status4")
A333DR_audio_panel_fo_mic5_status		= find_dataref("laminar/A333/audio/fo/mic_status5")
A333DR_audio_panel_fo_mic6_status		= find_dataref("laminar/A333/audio/fo/mic_status6")
A333DR_audio_panel_fo_mic7_status		= find_dataref("laminar/A333/audio/fo/mic_status7")
A333DR_audio_panel_fo_mic8_status		= find_dataref("laminar/A333/audio/fo/mic_status8")
A333DR_audio_panel_fo_mic9_status		= find_dataref("laminar/A333/audio/fo/mic_status9")
A333DR_audio_panel_fo_mic10_status		= find_dataref("laminar/A333/audio/fo/mic_status10")

	-- OBSERVER MIC LIGHT STATUS

A333DR_audio_panel_obs_mic1_status		= find_dataref("laminar/A333/audio/obs/mic_status1")
A333DR_audio_panel_obs_mic2_status		= find_dataref("laminar/A333/audio/obs/mic_status2")
A333DR_audio_panel_obs_mic3_status		= find_dataref("laminar/A333/audio/obs/mic_status3")
A333DR_audio_panel_obs_mic4_status		= find_dataref("laminar/A333/audio/obs/mic_status4")
A333DR_audio_panel_obs_mic5_status		= find_dataref("laminar/A333/audio/obs/mic_status5")
A333DR_audio_panel_obs_mic6_status		= find_dataref("laminar/A333/audio/obs/mic_status6")
A333DR_audio_panel_obs_mic7_status		= find_dataref("laminar/A333/audio/obs/mic_status7")
A333DR_audio_panel_obs_mic8_status		= find_dataref("laminar/A333/audio/obs/mic_status8")
A333DR_audio_panel_obs_mic9_status		= find_dataref("laminar/A333/audio/obs/mic_status9")
A333DR_audio_panel_obs_mic10_status		= find_dataref("laminar/A333/audio/obs/mic_status10")

A333DR_audio_panel_capt_voice_status	= find_dataref("laminar/A333/audio/capt_voice_status")
A333DR_audio_panel_fo_voice_status		= find_dataref("laminar/A333/audio/fo_voice_status")
A333DR_audio_panel_obs_voice_status		= find_dataref("laminar/A333/audio/obs_voice_status")

A333DR_audio_panel_capt_listen_status	= find_dataref("laminar/A333/audio/capt/listen_status")
A333DR_audio_panel_fo_listen_status		= find_dataref("laminar/A333/audio/fo/listen_status")
A333DR_audio_panel_obs_listen_status	= find_dataref("laminar/A333/audio/obs/listen_status")

A333DR_capt_call_reset					= find_dataref("laminar/A333/audio/capt_call_reset_pos")
A333DR_fo_call_reset					= find_dataref("laminar/A333/audio/fo_call_reset_pos")
A333DR_obs_call_reset					= find_dataref("laminar/A333/audio/obs_call_reset_pos")

-- PRIORITY LIGHTS

A333_capt_priority_status				= find_dataref("laminar/A333/sidestick/capt_prior_annun")
A333_fo_priority_status					= find_dataref("laminar/A333/sidestick/fo_prior_annun")
A333_capt_arrow_status					= find_dataref("laminar/A333/sidestick/capt_arrow_annun")
A333_fo_arrow_status					= find_dataref("laminar/A333/sidestick/fo_arrow_annun")
A333_dual_input							= find_dataref("laminar/A333/sidestick/dual_input") -- 1 = dual input, used to determine FLASHER status of CAPT/FO lights

--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

-- AUDIO PANELS

	-- CAPTAIN MIC LIGHT STATUS

A333DR_audio_panel_capt_mic1_annun		= create_dataref("laminar/A333/audio/capt/mic_annun1", "number")
A333DR_audio_panel_capt_mic2_annun		= create_dataref("laminar/A333/audio/capt/mic_annun2", "number")
A333DR_audio_panel_capt_mic3_annun		= create_dataref("laminar/A333/audio/capt/mic_annun3", "number")
A333DR_audio_panel_capt_mic4_annun		= create_dataref("laminar/A333/audio/capt/mic_annun4", "number")
A333DR_audio_panel_capt_mic5_annun		= create_dataref("laminar/A333/audio/capt/mic_annun5", "number")
A333DR_audio_panel_capt_mic6_annun		= create_dataref("laminar/A333/audio/capt/mic_annun6", "number")
A333DR_audio_panel_capt_mic7_annun		= create_dataref("laminar/A333/audio/capt/mic_annun7", "number")
A333DR_audio_panel_capt_mic8_annun		= create_dataref("laminar/A333/audio/capt/mic_annun8", "number")
A333DR_audio_panel_capt_mic9_annun		= create_dataref("laminar/A333/audio/capt/mic_annun9", "number")
A333DR_audio_panel_capt_mic10_annun		= create_dataref("laminar/A333/audio/capt/mic_annun10", "number")

	-- FIRST OFFICER MIC LIGHT annun

A333DR_audio_panel_fo_mic1_annun		= create_dataref("laminar/A333/audio/fo/mic_annun1", "number")
A333DR_audio_panel_fo_mic2_annun		= create_dataref("laminar/A333/audio/fo/mic_annun2", "number")
A333DR_audio_panel_fo_mic3_annun		= create_dataref("laminar/A333/audio/fo/mic_annun3", "number")
A333DR_audio_panel_fo_mic4_annun		= create_dataref("laminar/A333/audio/fo/mic_annun4", "number")
A333DR_audio_panel_fo_mic5_annun		= create_dataref("laminar/A333/audio/fo/mic_annun5", "number")
A333DR_audio_panel_fo_mic6_annun		= create_dataref("laminar/A333/audio/fo/mic_annun6", "number")
A333DR_audio_panel_fo_mic7_annun		= create_dataref("laminar/A333/audio/fo/mic_annun7", "number")
A333DR_audio_panel_fo_mic8_annun		= create_dataref("laminar/A333/audio/fo/mic_annun8", "number")
A333DR_audio_panel_fo_mic9_annun		= create_dataref("laminar/A333/audio/fo/mic_annun9", "number")
A333DR_audio_panel_fo_mic10_annun		= create_dataref("laminar/A333/audio/fo/mic_annun10", "number")

	-- OBSERVER MIC LIGHT annun

A333DR_audio_panel_obs_mic1_annun		= create_dataref("laminar/A333/audio/obs/mic_annun1", "number")
A333DR_audio_panel_obs_mic2_annun		= create_dataref("laminar/A333/audio/obs/mic_annun2", "number")
A333DR_audio_panel_obs_mic3_annun		= create_dataref("laminar/A333/audio/obs/mic_annun3", "number")
A333DR_audio_panel_obs_mic4_annun		= create_dataref("laminar/A333/audio/obs/mic_annun4", "number")
A333DR_audio_panel_obs_mic5_annun		= create_dataref("laminar/A333/audio/obs/mic_annun5", "number")
A333DR_audio_panel_obs_mic6_annun		= create_dataref("laminar/A333/audio/obs/mic_annun6", "number")
A333DR_audio_panel_obs_mic7_annun		= create_dataref("laminar/A333/audio/obs/mic_annun7", "number")
A333DR_audio_panel_obs_mic8_annun		= create_dataref("laminar/A333/audio/obs/mic_annun8", "number")
A333DR_audio_panel_obs_mic9_annun		= create_dataref("laminar/A333/audio/obs/mic_annun9", "number")
A333DR_audio_panel_obs_mic10_annun		= create_dataref("laminar/A333/audio/obs/mic_annun10", "number")

	-- CALL LIGHTS

A333DR_audio_panel_call_light_vhf1		= create_dataref("laminar/A333/audio/vhf1_call_light", "number")
A333DR_audio_panel_call_light_vhf2		= create_dataref("laminar/A333/audio/vhf2_call_light", "number")
A333DR_audio_panel_call_light_gen		= create_dataref("laminar/A333/audio/gen_call_light", "number")

	-- VOICE LIGHTS

A333DR_audio_panel_capt_voice_annun		= create_dataref("laminar/A333/audio/capt_voice_annun", "number")
A333DR_audio_panel_fo_voice_annun		= create_dataref("laminar/A333/audio/fo_voice_annun", "number")
A333DR_audio_panel_obs_voice_annun		= create_dataref("laminar/A333/audio/obs_voice_annun", "number")

	-- CAPTAIN LISTENING LIGHTS

A333DR_audio_panel_capt_listen_annun	= create_dataref("laminar/A333/audio/capt_listening_annun", "array[" .. tostring(NUM_CAPT_LISTENING_LIGHTS) .. "]")
A333DR_audio_panel_fo_listen_annun		= create_dataref("laminar/A333/audio/fo_listening_annun", "array[" .. tostring(NUM_FO_LISTENING_LIGHTS) .. "]")
A333DR_audio_panel_obs_listen_annun		= create_dataref("laminar/A333/audio/obs_listening_annun", "array[" .. tostring(NUM_OBS_LISTENING_LIGHTS) .. "]")

	-- PRIORITY LIGHTS

A333DR_capt_priority_light_annun		= create_dataref("laminar/A333/annun/capt_sidestick_prior", "number")
A333DR_capt_priority_arrow_light_annun	= create_dataref("laminar/A333/annun/capt_sidestick_prior_arrow", "number")
A333DR_fo_priority_light_annun			= create_dataref("laminar/A333/annun/fo_sidestick_prior", "number")
A333DR_fo_priority_arrow_light_annun	= create_dataref("laminar/A333/annun/fo_sidestick_prior_arrow", "number")


--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--

function selcal_com1_receive_DLhandler() end
function selcal_com2_receive_DLhandler() end
function selcal_com1_transmit_DLhandler() end
function selcal_com2_transmit_DLhandler() end

--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--

-- SELCAL IN/OUT
	
A333DR_com1_receive					= create_dataref("laminar/A333/selcal/com1_receive", "number", selcal_com1_receive_DLhandler)
A333DR_com2_receive					= create_dataref("laminar/A333/selcal/com2_receive", "number", selcal_com2_receive_DLhandler)
A333DR_com1_acknowledge				= create_dataref("laminar/A333/selcal/com1_acknowledge", "number", selcal_com1_transmit_DLhandler)
A333DR_com2_acknowledge				= create_dataref("laminar/A333/selcal/com2_acknowledge", "number", selcal_com2_transmit_DLhandler)

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

local audio_panel_capt_mic1_annun = 0
local audio_panel_capt_mic2_annun = 0
local audio_panel_capt_mic3_annun = 0
local audio_panel_capt_mic4_annun = 0
local audio_panel_capt_mic5_annun = 0
local audio_panel_capt_mic6_annun = 0
local audio_panel_capt_mic7_annun = 0
local audio_panel_capt_mic8_annun = 0
local audio_panel_capt_mic9_annun = 0
local audio_panel_capt_mic10_annun = 0

local audio_panel_fo_mic1_annun = 0
local audio_panel_fo_mic2_annun = 0
local audio_panel_fo_mic3_annun = 0
local audio_panel_fo_mic4_annun = 0
local audio_panel_fo_mic5_annun = 0
local audio_panel_fo_mic6_annun = 0
local audio_panel_fo_mic7_annun = 0
local audio_panel_fo_mic8_annun = 0
local audio_panel_fo_mic9_annun = 0
local audio_panel_fo_mic10_annun = 0

local audio_panel_obs_mic1_annun = 0
local audio_panel_obs_mic2_annun = 0
local audio_panel_obs_mic3_annun = 0
local audio_panel_obs_mic4_annun = 0
local audio_panel_obs_mic5_annun = 0
local audio_panel_obs_mic6_annun = 0
local audio_panel_obs_mic7_annun = 0
local audio_panel_obs_mic8_annun = 0
local audio_panel_obs_mic9_annun = 0
local audio_panel_obs_mic10_annun = 0

local audio_panel_capt_mic2_annun_target = 0
local audio_panel_capt_mic3_annun_target = 0
local audio_panel_capt_mic4_annun_target = 0
local audio_panel_capt_mic5_annun_target = 0
local audio_panel_capt_mic6_annun_target = 0
local audio_panel_capt_mic7_annun_target = 0
local audio_panel_capt_mic8_annun_target = 0
local audio_panel_capt_mic9_annun_target = 0
local audio_panel_capt_mic10_annun_target = 0

local audio_panel_fo_mic1_annun_target = 0
local audio_panel_fo_mic2_annun_target = 0
local audio_panel_fo_mic3_annun_target = 0
local audio_panel_fo_mic4_annun_target = 0
local audio_panel_fo_mic5_annun_target = 0
local audio_panel_fo_mic6_annun_target = 0
local audio_panel_fo_mic7_annun_target = 0
local audio_panel_fo_mic8_annun_target = 0
local audio_panel_fo_mic9_annun_target = 0
local audio_panel_fo_mic10_annun_target = 0

local audio_panel_obs_mic1_annun_target = 0
local audio_panel_obs_mic2_annun_target = 0
local audio_panel_obs_mic3_annun_target = 0
local audio_panel_obs_mic4_annun_target = 0
local audio_panel_obs_mic5_annun_target = 0
local audio_panel_obs_mic6_annun_target = 0
local audio_panel_obs_mic7_annun_target = 0
local audio_panel_obs_mic8_annun_target = 0
local audio_panel_obs_mic9_annun_target = 0
local audio_panel_obs_mic10_annun_target = 0

local audio_panel_call_light_vhf1 = 0
local audio_panel_call_light_vhf2 = 0
local audio_panel_call_light_gen = 0

local audio_panel_call_light_vhf1_target = 0
local audio_panel_call_light_vhf2_target = 0
local audio_panel_call_light_gen_target = 0

local audio_panel_capt_voice_annun = 0
local audio_panel_fo_voice_annun = 0
local audio_panel_obs_voice_annun = 0

local audio_panel_capt_voice_annun_target = 0
local audio_panel_fo_voice_annun_target = 0
local audio_panel_obs_voice_annun_target = 0

local com1_activated = 0
local com2_activated = 0

local audio_panel_capt_listen_annun = {}
for i = 0, NUM_CAPT_LISTENING_LIGHTS-1 do
	audio_panel_capt_listen_annun[i] = 0
end

local audio_panel_fo_listen_annun = {}
for i = 0, NUM_FO_LISTENING_LIGHTS-1 do
	audio_panel_fo_listen_annun[i] = 0
end

local audio_panel_obs_listen_annun = {}
for i = 0, NUM_OBS_LISTENING_LIGHTS-1 do
	audio_panel_obs_listen_annun[i] = 0
end

local audio_panel_capt_listen_annun_target = {}
for i = 0, NUM_CAPT_LISTENING_LIGHTS-1 do
	audio_panel_capt_listen_annun_target[i] = 0
end

local audio_panel_fo_listen_annun_target = {}
for i = 0, NUM_FO_LISTENING_LIGHTS-1 do
	audio_panel_fo_listen_annun_target[i] = 0
end

local audio_panel_obs_listen_annun_target = {}
for i = 0, NUM_OBS_LISTENING_LIGHTS-1 do
	audio_panel_obs_listen_annun_target[i] = 0
end

-- ANNUNCIATOR FUNCTIONS

function A333_annunciators_AUDIO_CAPT()

local flasher = 0
local sim_time_factor = math.fmod(simDR_flight_time, 0.6)


	if sim_time_factor >= 0 and sim_time_factor <= 0.3 then
		flasher = 1
	end

	if A333_ann_light_switch_pos <= 1 then

		audio_panel_capt_mic1_annun_target = A333DR_audio_panel_capt_mic1_status
		audio_panel_capt_mic2_annun_target = A333DR_audio_panel_capt_mic2_status
		audio_panel_capt_mic3_annun_target = A333DR_audio_panel_capt_mic3_status
		audio_panel_capt_mic4_annun_target = A333DR_audio_panel_capt_mic4_status
		audio_panel_capt_mic5_annun_target = A333DR_audio_panel_capt_mic5_status
		audio_panel_capt_mic6_annun_target = A333DR_audio_panel_capt_mic6_status
		audio_panel_capt_mic7_annun_target = A333DR_audio_panel_capt_mic7_status
		audio_panel_capt_mic8_annun_target = A333DR_audio_panel_capt_mic8_status * flasher
		audio_panel_capt_mic9_annun_target = A333DR_audio_panel_capt_mic9_status * flasher
		audio_panel_capt_mic10_annun_target = A333DR_audio_panel_capt_mic10_status
		audio_panel_capt_voice_annun_target = A333DR_audio_panel_capt_voice_status

		if A333DR_capt_call_reset == 1 or A333DR_fo_call_reset == 1 or A333DR_obs_call_reset == 1 then
			com1_activated = 0
			com2_activated = 0
			A333DR_com1_receive = 0
			A333DR_com2_receive = 0
		end

		if A333DR_com1_receive == 1 then
			com1_activated = 1
		end

		if com1_activated == 1 then
			audio_panel_call_light_vhf1_target = flasher
			if A333DR_com1_acknowledge == 1 then
			A333DR_com1_receive = 0
			com1_activated = 0
			end
		elseif com1_activated == 0 then
			audio_panel_call_light_vhf1_target = 0
		end

		if A333DR_com2_receive == 1 then
			com2_activated = 1
		end

		if com2_activated == 1 then
			audio_panel_call_light_vhf2_target = flasher
			if A333DR_com2_acknowledge == 1 then
			A333DR_com2_receive = 0
			com2_activated = 0
			end
		elseif com2_activated == 0 then
			audio_panel_call_light_vhf2_target = 0
		end

		if A333DR_com1_acknowledge == 1 then
			com1_timer = com1_timer + SIM_PERIOD
		end

		if com1_timer > 5 then
			A333DR_com1_acknowledge = 0
			com1_timer = 0
		end
		
		if A333DR_com2_acknowledge == 1 then
			com2_timer = com2_timer + SIM_PERIOD
		end
	
		if com2_timer > 5 then
			A333DR_com2_acknowledge = 0
			com2_timer = 0
		end

		audio_panel_call_light_gen_target = 0

	elseif A333_ann_light_switch_pos == 2 then

		audio_panel_capt_mic1_annun_target = 1
		audio_panel_capt_mic2_annun_target = 1
		audio_panel_capt_mic3_annun_target = 1
		audio_panel_capt_mic4_annun_target = 1
		audio_panel_capt_mic5_annun_target = 1
		audio_panel_capt_mic6_annun_target = 1
		audio_panel_capt_mic7_annun_target = 1
		audio_panel_capt_mic8_annun_target = 1
		audio_panel_capt_mic9_annun_target = 1
		audio_panel_capt_mic10_annun_target = 1
		audio_panel_capt_voice_annun_target = 1

		audio_panel_call_light_vhf1_target = 1
		audio_panel_call_light_vhf2_target = 1
		audio_panel_call_light_gen_target = 1

	end

-- annunciator fade in --

	audio_panel_capt_mic1_annun = A333_set_animation_position(audio_panel_capt_mic1_annun, audio_panel_capt_mic1_annun_target, 0, 1, 20)
	audio_panel_capt_mic2_annun = A333_set_animation_position(audio_panel_capt_mic2_annun, audio_panel_capt_mic2_annun_target, 0, 1, 20)
	audio_panel_capt_mic3_annun = A333_set_animation_position(audio_panel_capt_mic3_annun, audio_panel_capt_mic3_annun_target, 0, 1, 20)
	audio_panel_capt_mic4_annun = A333_set_animation_position(audio_panel_capt_mic4_annun, audio_panel_capt_mic4_annun_target, 0, 1, 20)
	audio_panel_capt_mic5_annun = A333_set_animation_position(audio_panel_capt_mic5_annun, audio_panel_capt_mic5_annun_target, 0, 1, 20)
	audio_panel_capt_mic6_annun = A333_set_animation_position(audio_panel_capt_mic6_annun, audio_panel_capt_mic6_annun_target, 0, 1, 20)
	audio_panel_capt_mic7_annun = A333_set_animation_position(audio_panel_capt_mic7_annun, audio_panel_capt_mic7_annun_target, 0, 1, 20)
	audio_panel_capt_mic8_annun = A333_set_animation_position(audio_panel_capt_mic8_annun, audio_panel_capt_mic8_annun_target, 0, 1, 20)
	audio_panel_capt_mic9_annun = A333_set_animation_position(audio_panel_capt_mic9_annun, audio_panel_capt_mic9_annun_target, 0, 1, 20)
	audio_panel_capt_mic10_annun = A333_set_animation_position(audio_panel_capt_mic10_annun, audio_panel_capt_mic10_annun_target, 0, 1, 20)
	audio_panel_capt_voice_annun = A333_set_animation_position(audio_panel_capt_voice_annun, audio_panel_capt_voice_annun_target, 0, 1, 20)

	audio_panel_call_light_vhf1 = A333_set_animation_position(audio_panel_call_light_vhf1, audio_panel_call_light_vhf1_target, 0, 1, 20)
	audio_panel_call_light_vhf2 = A333_set_animation_position(audio_panel_call_light_vhf2, audio_panel_call_light_vhf2_target, 0, 1, 20)
	audio_panel_call_light_gen = A333_set_animation_position(audio_panel_call_light_gen, audio_panel_call_light_gen_target, 0, 1, 20)


-- annunciator brightness --

	A333DR_audio_panel_capt_mic1_annun = audio_panel_capt_mic1_annun * simDR_annun_brightness2
	A333DR_audio_panel_capt_mic2_annun = audio_panel_capt_mic2_annun * simDR_annun_brightness2
	A333DR_audio_panel_capt_mic3_annun = audio_panel_capt_mic3_annun * simDR_annun_brightness2
	A333DR_audio_panel_capt_mic4_annun = audio_panel_capt_mic4_annun * simDR_annun_brightness2
	A333DR_audio_panel_capt_mic5_annun = audio_panel_capt_mic5_annun * simDR_annun_brightness2
	A333DR_audio_panel_capt_mic6_annun = audio_panel_capt_mic6_annun * simDR_annun_brightness2
	A333DR_audio_panel_capt_mic7_annun = audio_panel_capt_mic7_annun * simDR_annun_brightness2
	A333DR_audio_panel_capt_mic8_annun = audio_panel_capt_mic8_annun * simDR_annun_brightness2
	A333DR_audio_panel_capt_mic9_annun = audio_panel_capt_mic9_annun * simDR_annun_brightness2
	A333DR_audio_panel_capt_mic10_annun = audio_panel_capt_mic10_annun * simDR_annun_brightness2
	A333DR_audio_panel_capt_voice_annun = audio_panel_capt_voice_annun * simDR_annun_brightness2

	A333DR_audio_panel_call_light_vhf1 = audio_panel_call_light_vhf1 * simDR_annun_brightness2
	A333DR_audio_panel_call_light_vhf2 = audio_panel_call_light_vhf2 * simDR_annun_brightness2
	A333DR_audio_panel_call_light_gen = audio_panel_call_light_gen * simDR_annun_brightness2

end

function A333_annunciators_AUDIO_FO()

local flasher2 = 0
local sim_time_factor2 = math.fmod(simDR_flight_time, 0.59)

	if sim_time_factor2 >= 0 and sim_time_factor2 <= 0.295 then
		flasher2 = 1
	end

	if A333_ann_light_switch_pos <= 1 then

		audio_panel_fo_mic1_annun_target = A333DR_audio_panel_fo_mic1_status
		audio_panel_fo_mic2_annun_target = A333DR_audio_panel_fo_mic2_status
		audio_panel_fo_mic3_annun_target = A333DR_audio_panel_fo_mic3_status
		audio_panel_fo_mic4_annun_target = A333DR_audio_panel_fo_mic4_status
		audio_panel_fo_mic5_annun_target = A333DR_audio_panel_fo_mic5_status
		audio_panel_fo_mic6_annun_target = A333DR_audio_panel_fo_mic6_status
		audio_panel_fo_mic7_annun_target = A333DR_audio_panel_fo_mic7_status
		audio_panel_fo_mic8_annun_target = A333DR_audio_panel_fo_mic8_status * flasher2
		audio_panel_fo_mic9_annun_target = A333DR_audio_panel_fo_mic9_status * flasher2
		audio_panel_fo_mic10_annun_target = A333DR_audio_panel_fo_mic10_status
		audio_panel_fo_voice_annun_target = A333DR_audio_panel_fo_voice_status

	elseif A333_ann_light_switch_pos == 2 then

		audio_panel_fo_mic1_annun_target = 1
		audio_panel_fo_mic2_annun_target = 1
		audio_panel_fo_mic3_annun_target = 1
		audio_panel_fo_mic4_annun_target = 1
		audio_panel_fo_mic5_annun_target = 1
		audio_panel_fo_mic6_annun_target = 1
		audio_panel_fo_mic7_annun_target = 1
		audio_panel_fo_mic8_annun_target = 1
		audio_panel_fo_mic9_annun_target = 1
		audio_panel_fo_mic10_annun_target = 1
		audio_panel_fo_voice_annun_target = 1

	end

-- annunciator fade in --

	audio_panel_fo_mic1_annun = A333_set_animation_position(audio_panel_fo_mic1_annun, audio_panel_fo_mic1_annun_target, 0, 1, 20)
	audio_panel_fo_mic2_annun = A333_set_animation_position(audio_panel_fo_mic2_annun, audio_panel_fo_mic2_annun_target, 0, 1, 20)
	audio_panel_fo_mic3_annun = A333_set_animation_position(audio_panel_fo_mic3_annun, audio_panel_fo_mic3_annun_target, 0, 1, 20)
	audio_panel_fo_mic4_annun = A333_set_animation_position(audio_panel_fo_mic4_annun, audio_panel_fo_mic4_annun_target, 0, 1, 20)
	audio_panel_fo_mic5_annun = A333_set_animation_position(audio_panel_fo_mic5_annun, audio_panel_fo_mic5_annun_target, 0, 1, 20)
	audio_panel_fo_mic6_annun = A333_set_animation_position(audio_panel_fo_mic6_annun, audio_panel_fo_mic6_annun_target, 0, 1, 20)
	audio_panel_fo_mic7_annun = A333_set_animation_position(audio_panel_fo_mic7_annun, audio_panel_fo_mic7_annun_target, 0, 1, 20)
	audio_panel_fo_mic8_annun = A333_set_animation_position(audio_panel_fo_mic8_annun, audio_panel_fo_mic8_annun_target, 0, 1, 20)
	audio_panel_fo_mic9_annun = A333_set_animation_position(audio_panel_fo_mic9_annun, audio_panel_fo_mic9_annun_target, 0, 1, 20)
	audio_panel_fo_mic10_annun = A333_set_animation_position(audio_panel_fo_mic10_annun, audio_panel_fo_mic10_annun_target, 0, 1, 20)
	audio_panel_fo_voice_annun = A333_set_animation_position(audio_panel_fo_voice_annun, audio_panel_fo_voice_annun_target, 0, 1, 20)

-- annunciator brightness --

	A333DR_audio_panel_fo_mic1_annun = audio_panel_fo_mic1_annun * simDR_annun_brightness2
	A333DR_audio_panel_fo_mic2_annun = audio_panel_fo_mic2_annun * simDR_annun_brightness2
	A333DR_audio_panel_fo_mic3_annun = audio_panel_fo_mic3_annun * simDR_annun_brightness2
	A333DR_audio_panel_fo_mic4_annun = audio_panel_fo_mic4_annun * simDR_annun_brightness2
	A333DR_audio_panel_fo_mic5_annun = audio_panel_fo_mic5_annun * simDR_annun_brightness2
	A333DR_audio_panel_fo_mic6_annun = audio_panel_fo_mic6_annun * simDR_annun_brightness2
	A333DR_audio_panel_fo_mic7_annun = audio_panel_fo_mic7_annun * simDR_annun_brightness2
	A333DR_audio_panel_fo_mic8_annun = audio_panel_fo_mic8_annun * simDR_annun_brightness2
	A333DR_audio_panel_fo_mic9_annun = audio_panel_fo_mic9_annun * simDR_annun_brightness2
	A333DR_audio_panel_fo_mic10_annun = audio_panel_fo_mic10_annun * simDR_annun_brightness2
	A333DR_audio_panel_fo_voice_annun = audio_panel_fo_voice_annun * simDR_annun_brightness2

end

function A333_annunciators_AUDIO_OBS()

local flasher3 = 0
local sim_time_factor3 = math.fmod(simDR_flight_time, 0.61)

	if sim_time_factor3 >= 0 and sim_time_factor3 <= 0.305 then
		flasher3 = 1
	end

	if A333_ann_light_switch_pos <= 1 then

		audio_panel_obs_mic1_annun_target = A333DR_audio_panel_obs_mic1_status
		audio_panel_obs_mic2_annun_target = A333DR_audio_panel_obs_mic2_status
		audio_panel_obs_mic3_annun_target = A333DR_audio_panel_obs_mic3_status
		audio_panel_obs_mic4_annun_target = A333DR_audio_panel_obs_mic4_status
		audio_panel_obs_mic5_annun_target = A333DR_audio_panel_obs_mic5_status
		audio_panel_obs_mic6_annun_target = A333DR_audio_panel_obs_mic6_status
		audio_panel_obs_mic7_annun_target = A333DR_audio_panel_obs_mic7_status
		audio_panel_obs_mic8_annun_target = A333DR_audio_panel_obs_mic8_status * flasher3
		audio_panel_obs_mic9_annun_target = A333DR_audio_panel_obs_mic9_status * flasher3
		audio_panel_obs_mic10_annun_target = A333DR_audio_panel_obs_mic10_status
		audio_panel_obs_voice_annun_target = A333DR_audio_panel_obs_voice_status

	elseif A333_ann_light_switch_pos == 2 then

		audio_panel_obs_mic1_annun_target = 1
		audio_panel_obs_mic2_annun_target = 1
		audio_panel_obs_mic3_annun_target = 1
		audio_panel_obs_mic4_annun_target = 1
		audio_panel_obs_mic5_annun_target = 1
		audio_panel_obs_mic6_annun_target = 1
		audio_panel_obs_mic7_annun_target = 1
		audio_panel_obs_mic8_annun_target = 1
		audio_panel_obs_mic9_annun_target = 1
		audio_panel_obs_mic10_annun_target = 1
		audio_panel_obs_voice_annun_target = 1

	end

-- annunciator fade in --

	audio_panel_obs_mic1_annun = A333_set_animation_position(audio_panel_obs_mic1_annun, audio_panel_obs_mic1_annun_target, 0, 1, 20)
	audio_panel_obs_mic2_annun = A333_set_animation_position(audio_panel_obs_mic2_annun, audio_panel_obs_mic2_annun_target, 0, 1, 20)
	audio_panel_obs_mic3_annun = A333_set_animation_position(audio_panel_obs_mic3_annun, audio_panel_obs_mic3_annun_target, 0, 1, 20)
	audio_panel_obs_mic4_annun = A333_set_animation_position(audio_panel_obs_mic4_annun, audio_panel_obs_mic4_annun_target, 0, 1, 20)
	audio_panel_obs_mic5_annun = A333_set_animation_position(audio_panel_obs_mic5_annun, audio_panel_obs_mic5_annun_target, 0, 1, 20)
	audio_panel_obs_mic6_annun = A333_set_animation_position(audio_panel_obs_mic6_annun, audio_panel_obs_mic6_annun_target, 0, 1, 20)
	audio_panel_obs_mic7_annun = A333_set_animation_position(audio_panel_obs_mic7_annun, audio_panel_obs_mic7_annun_target, 0, 1, 20)
	audio_panel_obs_mic8_annun = A333_set_animation_position(audio_panel_obs_mic8_annun, audio_panel_obs_mic8_annun_target, 0, 1, 20)
	audio_panel_obs_mic9_annun = A333_set_animation_position(audio_panel_obs_mic9_annun, audio_panel_obs_mic9_annun_target, 0, 1, 20)
	audio_panel_obs_mic10_annun = A333_set_animation_position(audio_panel_obs_mic10_annun, audio_panel_obs_mic10_annun_target, 0, 1, 20)
	audio_panel_obs_voice_annun = A333_set_animation_position(audio_panel_obs_voice_annun, audio_panel_obs_voice_annun_target, 0, 1, 20)

-- annunciator brightness --

	A333DR_audio_panel_obs_mic1_annun = audio_panel_obs_mic1_annun * simDR_annun_brightness2
	A333DR_audio_panel_obs_mic2_annun = audio_panel_obs_mic2_annun * simDR_annun_brightness2
	A333DR_audio_panel_obs_mic3_annun = audio_panel_obs_mic3_annun * simDR_annun_brightness2
	A333DR_audio_panel_obs_mic4_annun = audio_panel_obs_mic4_annun * simDR_annun_brightness2
	A333DR_audio_panel_obs_mic5_annun = audio_panel_obs_mic5_annun * simDR_annun_brightness2
	A333DR_audio_panel_obs_mic6_annun = audio_panel_obs_mic6_annun * simDR_annun_brightness2
	A333DR_audio_panel_obs_mic7_annun = audio_panel_obs_mic7_annun * simDR_annun_brightness2
	A333DR_audio_panel_obs_mic8_annun = audio_panel_obs_mic8_annun * simDR_annun_brightness2
	A333DR_audio_panel_obs_mic9_annun = audio_panel_obs_mic9_annun * simDR_annun_brightness2
	A333DR_audio_panel_obs_mic10_annun = audio_panel_obs_mic10_annun * simDR_annun_brightness2
	A333DR_audio_panel_obs_voice_annun = audio_panel_obs_voice_annun * simDR_annun_brightness2

end

function A333_annunciators_VOLUME_CAPT()

	if A333_ann_light_switch_pos <= 1 then

		for i = 0, NUM_CAPT_LISTENING_LIGHTS-1 do
			audio_panel_capt_listen_annun_target[i] = A333DR_audio_panel_capt_listen_status[i]
		end

	elseif A333_ann_light_switch_pos == 2 then

		for i = 0, NUM_CAPT_LISTENING_LIGHTS-1 do
			audio_panel_capt_listen_annun_target[i] = 1
		end

	end

-- annunciator fade in --

	for i = 0, NUM_CAPT_LISTENING_LIGHTS-1 do
		audio_panel_capt_listen_annun[i] = A333_set_animation_position(audio_panel_capt_listen_annun[i], audio_panel_capt_listen_annun_target[i], 0, 1, 18)
	end

-- annunciator brightness --

	for i = 0, NUM_CAPT_LISTENING_LIGHTS-1 do
		A333DR_audio_panel_capt_listen_annun[i] = audio_panel_capt_listen_annun[i] * simDR_annun_brightness2
	end


end

function A333_annunciators_VOLUME_FO()

	if A333_ann_light_switch_pos <= 1 then

		for i = 0, NUM_FO_LISTENING_LIGHTS-1 do
			audio_panel_fo_listen_annun_target[i] = A333DR_audio_panel_fo_listen_status[i]
		end

	elseif A333_ann_light_switch_pos == 2 then

		for i = 0, NUM_FO_LISTENING_LIGHTS-1 do
			audio_panel_fo_listen_annun_target[i] = 1
		end

	end

-- annunciator fade in --

	for i = 0, NUM_FO_LISTENING_LIGHTS-1 do
		audio_panel_fo_listen_annun[i] = A333_set_animation_position(audio_panel_fo_listen_annun[i], audio_panel_fo_listen_annun_target[i], 0, 1, 18)
	end

-- annunciator brightness --

	for i = 0, NUM_FO_LISTENING_LIGHTS-1 do
		A333DR_audio_panel_fo_listen_annun[i] = audio_panel_fo_listen_annun[i] * simDR_annun_brightness2
	end


end

function A333_annunciators_VOLUME_OBS()

	if A333_ann_light_switch_pos <= 1 then

		for i = 0, NUM_OBS_LISTENING_LIGHTS-1 do
			audio_panel_obs_listen_annun_target[i] = A333DR_audio_panel_obs_listen_status[i]
		end

	elseif A333_ann_light_switch_pos == 2 then

		for i = 0, NUM_OBS_LISTENING_LIGHTS-1 do
			audio_panel_obs_listen_annun_target[i] = 1
		end

	end

-- annunciator fade in --

	for i = 0, NUM_OBS_LISTENING_LIGHTS-1 do
		audio_panel_obs_listen_annun[i] = A333_set_animation_position(audio_panel_obs_listen_annun[i], audio_panel_obs_listen_annun_target[i], 0, 1, 18)
	end

-- annunciator brightness --

	for i = 0, NUM_OBS_LISTENING_LIGHTS-1 do
		A333DR_audio_panel_obs_listen_annun[i] = audio_panel_obs_listen_annun[i] * simDR_annun_brightness2
	end


end

local capt_priority_light_annun = 0
local fo_priority_light_annun = 0
local capt_priority_arrow_annun = 0
local fo_priority_arrow_annun = 0

local capt_priority_light_annun_target = 0
local fo_priority_light_annun_target = 0
local capt_priority_arrow_annun_target = 0
local fo_priority_arrow_annun_target = 0

function A333_annunciators_sidestick_priority()

local flasher4 = 0
local sim_time_factor4 = math.fmod(simDR_flight_time, 0.57)

	if sim_time_factor4 >= 0 and sim_time_factor4 <= 0.28 then
		flasher4 = 1
	end

	if A333_ann_light_switch_pos <= 1 then

		capt_priority_arrow_annun_target = A333_capt_arrow_status
		fo_priority_arrow_annun_target = A333_fo_arrow_status

		if A333_dual_input == 1 then
			capt_priority_light_annun_target = A333_capt_priority_status * flasher4
			fo_priority_light_annun_target = A333_fo_priority_status * flasher4
		elseif A333_dual_input == 0 then
			capt_priority_light_annun_target = A333_capt_priority_status
			fo_priority_light_annun_target = A333_fo_priority_status
		end

	elseif A333_ann_light_switch_pos == 2 then

		capt_priority_light_annun_target = 1
		fo_priority_light_annun_target = 1
		capt_priority_arrow_annun_target = 1
		fo_priority_arrow_annun_target = 1

	end

-- annunciator fade in --

	capt_priority_light_annun = A333_set_animation_position(capt_priority_light_annun, capt_priority_light_annun_target, 0, 1, 20)
	fo_priority_light_annun = A333_set_animation_position(fo_priority_light_annun, fo_priority_light_annun_target, 0, 1, 20)
	capt_priority_arrow_annun = A333_set_animation_position(capt_priority_arrow_annun, capt_priority_arrow_annun_target, 0, 1, 20)
	fo_priority_arrow_annun = A333_set_animation_position(fo_priority_arrow_annun, fo_priority_arrow_annun_target, 0, 1, 20)

-- annunciator brightness --

	A333DR_capt_priority_light_annun = capt_priority_light_annun * simDR_annun_brightness2
	A333DR_fo_priority_light_annun = fo_priority_light_annun * simDR_annun_brightness2
	A333DR_capt_priority_arrow_light_annun = capt_priority_arrow_annun * simDR_annun_brightness2
	A333DR_fo_priority_arrow_light_annun = fo_priority_arrow_annun * simDR_annun_brightness2

end



--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

function A333_ALL_annunciators_4()

	A333_annunciators_AUDIO_CAPT()
	A333_annunciators_AUDIO_FO()
	A333_annunciators_AUDIO_OBS()
	A333_annunciators_VOLUME_CAPT()
	A333_annunciators_VOLUME_FO()
	A333_annunciators_VOLUME_OBS()
	A333_annunciators_sidestick_priority()

end

--function aircraft_load() end

--function aircraft_unload() end

--function flight_start() end

	com1_activated = 0
	com2_activated = 0

--function flight_crash() end

--function before_physics()

function after_physics()

	A333_ALL_annunciators_4()

end

function after_replay()

	A333_ALL_annunciators_4()

end
