--[[
*****************************************************************************************
* Program Script Name	:	A333.audio
*
* Author Name			:	Alex Unruh
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*
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
local NUM_CAPT_LISTENING_KNOBS = 16
local NUM_FO_LISTENING_KNOBS = 16
local NUM_OBS_LISTENING_KNOBS = 16



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local A333_audio_capt_listen_press_CMDhandler = {}
local A333_audio_fo_listen_press_CMDhandler = {}
local A333_audio_obs_listen_press_CMDhandler = {}



--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--
simDR_startup_running       = find_dataref("sim/operation/prefs/startup_running")

simDR_capt_transmit_mode	= find_dataref("sim/cockpit2/radios/actuators/audio_com_selection_man")
simDR_fo_transmit_mode		= find_dataref("sim/cockpit2/radios/actuators/audio_com_selection_man_copilot")

simDR_capt_com1_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_com1")
simDR_capt_com2_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_com2")
simDR_capt_LS_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav1")
simDR_capt_nav1_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav3")
simDR_capt_nav2_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav4")
simDR_capt_adf1_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_adf1")
simDR_capt_adf2_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_adf2")
simDR_capt_mkr_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_marker_enabled")

simDR_fo_com1_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_com1_copilot")
simDR_fo_com2_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_com2_copilot")
simDR_fo_LS_listen			= find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav2_copilot")
simDR_fo_nav1_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav3_copilot")
simDR_fo_nav2_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_nav4_copilot")
simDR_fo_adf1_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_adf1_copilot")
simDR_fo_adf2_listen		= find_dataref("sim/cockpit2/radios/actuators/audio_selection_adf2_copilot")
simDR_fo_mkr_listen			= find_dataref("sim/cockpit2/radios/actuators/audio_marker_enabled_copilot")



--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--




--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--
A333DR_init_audio_CD				= create_dataref("laminar/A333/init_CD/audio", "number")

A333DR_com1_receive					= create_dataref("laminar/A333/selcal/com1_receive", "number")
A333DR_com2_receive					= create_dataref("laminar/A333/selcal/com2_receive", "number")
A333DR_com1_acknowledge				= create_dataref("laminar/A333/selcal/com1_acknowledge", "number")
A333DR_com2_acknowledge				= create_dataref("laminar/A333/selcal/com2_acknowledge", "number")

-- CAPTAIN MIC SELECTOR POSITION
A333DR_audio_panel_capt_mic1_pos		= create_dataref("laminar/A333/audio/capt/mic_button1", "number")
A333DR_audio_panel_capt_mic2_pos		= create_dataref("laminar/A333/audio/capt/mic_button2", "number")
A333DR_audio_panel_capt_mic3_pos		= create_dataref("laminar/A333/audio/capt/mic_button3", "number")
A333DR_audio_panel_capt_mic4_pos		= create_dataref("laminar/A333/audio/capt/mic_button4", "number")
A333DR_audio_panel_capt_mic5_pos		= create_dataref("laminar/A333/audio/capt/mic_button5", "number")
A333DR_audio_panel_capt_mic6_pos		= create_dataref("laminar/A333/audio/capt/mic_button6", "number")
A333DR_audio_panel_capt_mic7_pos		= create_dataref("laminar/A333/audio/capt/mic_button7", "number")
A333DR_audio_panel_capt_mic8_pos		= create_dataref("laminar/A333/audio/capt/mic_button8", "number")
A333DR_audio_panel_capt_mic9_pos		= create_dataref("laminar/A333/audio/capt/mic_button9", "number")
A333DR_audio_panel_capt_mic10_pos		= create_dataref("laminar/A333/audio/capt/mic_button10", "number")

-- CAPTAIN MIC LIGHT STATUS
A333DR_audio_panel_capt_mic1_status		= create_dataref("laminar/A333/audio/capt/mic_status1", "number")
A333DR_audio_panel_capt_mic2_status		= create_dataref("laminar/A333/audio/capt/mic_status2", "number")
A333DR_audio_panel_capt_mic3_status		= create_dataref("laminar/A333/audio/capt/mic_status3", "number")
A333DR_audio_panel_capt_mic4_status		= create_dataref("laminar/A333/audio/capt/mic_status4", "number")
A333DR_audio_panel_capt_mic5_status		= create_dataref("laminar/A333/audio/capt/mic_status5", "number")
A333DR_audio_panel_capt_mic6_status		= create_dataref("laminar/A333/audio/capt/mic_status6", "number")
A333DR_audio_panel_capt_mic7_status		= create_dataref("laminar/A333/audio/capt/mic_status7", "number")
A333DR_audio_panel_capt_mic8_status		= create_dataref("laminar/A333/audio/capt/mic_status8", "number")
A333DR_audio_panel_capt_mic9_status		= create_dataref("laminar/A333/audio/capt/mic_status9", "number")
A333DR_audio_panel_capt_mic10_status	= create_dataref("laminar/A333/audio/capt/mic_status10", "number")

-- FIRST OFFICER MIC SELECTOR POSITION
A333DR_audio_panel_fo_mic1_pos			= create_dataref("laminar/A333/audio/fo/mic_button1", "number")
A333DR_audio_panel_fo_mic2_pos			= create_dataref("laminar/A333/audio/fo/mic_button2", "number")
A333DR_audio_panel_fo_mic3_pos			= create_dataref("laminar/A333/audio/fo/mic_button3", "number")
A333DR_audio_panel_fo_mic4_pos			= create_dataref("laminar/A333/audio/fo/mic_button4", "number")
A333DR_audio_panel_fo_mic5_pos			= create_dataref("laminar/A333/audio/fo/mic_button5", "number")
A333DR_audio_panel_fo_mic6_pos			= create_dataref("laminar/A333/audio/fo/mic_button6", "number")
A333DR_audio_panel_fo_mic7_pos			= create_dataref("laminar/A333/audio/fo/mic_button7", "number")
A333DR_audio_panel_fo_mic8_pos			= create_dataref("laminar/A333/audio/fo/mic_button8", "number")
A333DR_audio_panel_fo_mic9_pos			= create_dataref("laminar/A333/audio/fo/mic_button9", "number")
A333DR_audio_panel_fo_mic10_pos			= create_dataref("laminar/A333/audio/fo/mic_button10", "number")

-- FIRST OFFICER MIC LIGHT STATUS
A333DR_audio_panel_fo_mic1_status		= create_dataref("laminar/A333/audio/fo/mic_status1", "number")
A333DR_audio_panel_fo_mic2_status		= create_dataref("laminar/A333/audio/fo/mic_status2", "number")
A333DR_audio_panel_fo_mic3_status		= create_dataref("laminar/A333/audio/fo/mic_status3", "number")
A333DR_audio_panel_fo_mic4_status		= create_dataref("laminar/A333/audio/fo/mic_status4", "number")
A333DR_audio_panel_fo_mic5_status		= create_dataref("laminar/A333/audio/fo/mic_status5", "number")
A333DR_audio_panel_fo_mic6_status		= create_dataref("laminar/A333/audio/fo/mic_status6", "number")
A333DR_audio_panel_fo_mic7_status		= create_dataref("laminar/A333/audio/fo/mic_status7", "number")
A333DR_audio_panel_fo_mic8_status		= create_dataref("laminar/A333/audio/fo/mic_status8", "number")
A333DR_audio_panel_fo_mic9_status		= create_dataref("laminar/A333/audio/fo/mic_status9", "number")
A333DR_audio_panel_fo_mic10_status		= create_dataref("laminar/A333/audio/fo/mic_status10", "number")

-- OBSERVER MIC SELECTOR POSITION
A333DR_audio_panel_obs_mic1_pos			= create_dataref("laminar/A333/audio/obs/mic_button1", "number")
A333DR_audio_panel_obs_mic2_pos			= create_dataref("laminar/A333/audio/obs/mic_button2", "number")
A333DR_audio_panel_obs_mic3_pos			= create_dataref("laminar/A333/audio/obs/mic_button3", "number")
A333DR_audio_panel_obs_mic4_pos			= create_dataref("laminar/A333/audio/obs/mic_button4", "number")
A333DR_audio_panel_obs_mic5_pos			= create_dataref("laminar/A333/audio/obs/mic_button5", "number")
A333DR_audio_panel_obs_mic6_pos			= create_dataref("laminar/A333/audio/obs/mic_button6", "number")
A333DR_audio_panel_obs_mic7_pos			= create_dataref("laminar/A333/audio/obs/mic_button7", "number")
A333DR_audio_panel_obs_mic8_pos			= create_dataref("laminar/A333/audio/obs/mic_button8", "number")
A333DR_audio_panel_obs_mic9_pos			= create_dataref("laminar/A333/audio/obs/mic_button9", "number")
A333DR_audio_panel_obs_mic10_pos		= create_dataref("laminar/A333/audio/obs/mic_button10", "number")

-- OBSERVER MIC LIGHT STATUS
A333DR_audio_panel_obs_mic1_status		= create_dataref("laminar/A333/audio/obs/mic_status1", "number")
A333DR_audio_panel_obs_mic2_status		= create_dataref("laminar/A333/audio/obs/mic_status2", "number")
A333DR_audio_panel_obs_mic3_status		= create_dataref("laminar/A333/audio/obs/mic_status3", "number")
A333DR_audio_panel_obs_mic4_status		= create_dataref("laminar/A333/audio/obs/mic_status4", "number")
A333DR_audio_panel_obs_mic5_status		= create_dataref("laminar/A333/audio/obs/mic_status5", "number")
A333DR_audio_panel_obs_mic6_status		= create_dataref("laminar/A333/audio/obs/mic_status6", "number")
A333DR_audio_panel_obs_mic7_status		= create_dataref("laminar/A333/audio/obs/mic_status7", "number")
A333DR_audio_panel_obs_mic8_status		= create_dataref("laminar/A333/audio/obs/mic_status8", "number")
A333DR_audio_panel_obs_mic9_status		= create_dataref("laminar/A333/audio/obs/mic_status9", "number")
A333DR_audio_panel_obs_mic10_status		= create_dataref("laminar/A333/audio/obs/mic_status10", "number")

-- CALL RESET BUTTONS
A333DR_audio_panel_capt_call_reset		= create_dataref("laminar/A333/audio/capt_call_reset_pos", "number")
A333DR_audio_panel_fo_call_reset		= create_dataref("laminar/A333/audio/fo_call_reset_pos", "number")
A333DR_audio_panel_obs_call_reset		= create_dataref("laminar/A333/audio/obs_call_reset_pos", "number")

-- VOICE BUTTONS
A333DR_audio_panel_capt_voice_pos		= create_dataref("laminar/A333/audio/capt_voice_pos", "number")
A333DR_audio_panel_fo_voice_pos			= create_dataref("laminar/A333/audio/fo_voice_pos", "number")
A333DR_audio_panel_obs_voice_pos		= create_dataref("laminar/A333/audio/obs_voice_pos", "number")

A333DR_audio_panel_capt_voice_status	= create_dataref("laminar/A333/audio/capt_voice_status", "number")
A333DR_audio_panel_fo_voice_status		= create_dataref("laminar/A333/audio/fo_voice_status", "number")
A333DR_audio_panel_obs_voice_status		= create_dataref("laminar/A333/audio/obs_voice_status", "number")

-- CAPT VOLUME
A333DR_audio_panel_capt_listen_pos		= create_dataref("laminar/A333/audio/capt/listen_pos", "array[" .. tostring(NUM_CAPT_LISTENING_KNOBS) .. "]")
A333DR_audio_panel_capt_listen_status	= create_dataref("laminar/A333/audio/capt/listen_status", "array[" .. tostring(NUM_CAPT_LISTENING_KNOBS) .. "]")

-- FO VOLUME
A333DR_audio_panel_fo_listen_pos		= create_dataref("laminar/A333/audio/fo/listen_pos", "array[" .. tostring(NUM_FO_LISTENING_KNOBS) .. "]")
A333DR_audio_panel_fo_listen_status		= create_dataref("laminar/A333/audio/fo/listen_status", "array[" .. tostring(NUM_FO_LISTENING_KNOBS) .. "]")

-- OBS VOLUME
A333DR_audio_panel_obs_listen_pos		= create_dataref("laminar/A333/audio/obs/listen_pos", "array[" .. tostring(NUM_OBS_LISTENING_KNOBS) .. "]")
A333DR_audio_panel_obs_listen_status	= create_dataref("laminar/A333/audio/obs/listen_status", "array[" .. tostring(NUM_OBS_LISTENING_KNOBS) .. "]")



--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--
local A333_audio_panel_capt_volume_DRhandler = {}
for i = 0, NUM_CAPT_LISTENING_KNOBS-1 do
	A333_audio_panel_capt_volume_DRhandler[i] = function() end
end

local A333_audio_panel_fo_volume_DRhandler = {}
for i = 0, NUM_FO_LISTENING_KNOBS-1 do
	A333_audio_panel_fo_volume_DRhandler[i] = function() end
end

local A333_audio_panel_obs_volume_DRhandler = {}
for i = 0, NUM_OBS_LISTENING_KNOBS-1 do
	A333_audio_panel_obs_volume_DRhandler[i] = function() end
end



--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--
A333DR_audio_panel_capt_volume = {}
for i = 0, NUM_CAPT_LISTENING_KNOBS-1 do
	A333DR_audio_panel_capt_volume[i] = create_dataref(string.format("laminar/A333/audio/capt/volume_pos_%d", i), "number", A333_audio_panel_capt_volume_DRhandler[i])
end

A333DR_audio_panel_fo_volume = {}
for i = 0, NUM_FO_LISTENING_KNOBS-1 do
	A333DR_audio_panel_fo_volume[i] = create_dataref(string.format("laminar/A333/audio/fo/volume_pos_%d", i), "number", A333_audio_panel_fo_volume_DRhandler[i])
end

A333DR_audio_panel_obs_volume = {}
for i = 0, NUM_OBS_LISTENING_KNOBS-1 do
	A333DR_audio_panel_obs_volume[i] = create_dataref(string.format("laminar/A333/audio/obs/volume_pos_%d", i), "number", A333_audio_panel_obs_volume_DRhandler[i])
end




--*************************************************************************************--
--** 				               LOCALIZED DATAREFS                                **--
--*************************************************************************************--
local CLDR_audio_panel_capt_listen_status = A333DR_audio_panel_capt_listen_status
local CLDR_audio_panel_fo_listen_status = A333DR_audio_panel_fo_listen_status
local CLDR_audio_panel_obs_listen_status = A333DR_audio_panel_obs_listen_status



--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                 X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				              CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--

-- AUDIO PANEL MIC SELECTOR COMMAND HANDLERS

-- CAPT
local function set_capt_mic_status(...)
	local args = {...}
	assert(#args == 10, "function set_capt_mic_status() args ~= 10")
	A333DR_audio_panel_capt_mic1_status = args[1]
	A333DR_audio_panel_capt_mic2_status = args[2]
	A333DR_audio_panel_capt_mic3_status = args[3]
	A333DR_audio_panel_capt_mic4_status = args[4]
	A333DR_audio_panel_capt_mic5_status = args[5]
	A333DR_audio_panel_capt_mic6_status = args[6]
	A333DR_audio_panel_capt_mic7_status = args[7]
	A333DR_audio_panel_capt_mic8_status = args[8]
	A333DR_audio_panel_capt_mic9_status = args[9]
	A333DR_audio_panel_capt_mic10_status = args[10]
end



local function A333_capt_push_mic1_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_capt_mic1_pos = 1
		if A333DR_audio_panel_capt_mic1_status == 1 then
			if A333DR_com1_receive == 0 then
				A333DR_audio_panel_capt_mic1_status = 0
				simDR_capt_transmit_mode = 0
			elseif A333DR_com1_receive == 1 then
				A333DR_com1_acknowledge = 1
			end
		elseif A333DR_audio_panel_capt_mic1_status == 0 then
			simDR_capt_transmit_mode = 6
			A333DR_com1_acknowledge = 1
			set_capt_mic_status(1, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_capt_mic1_pos = 0
	end
end




local function A333_capt_push_mic2_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_capt_mic2_pos = 1
		if A333DR_audio_panel_capt_mic2_status == 1 then
			if A333DR_com2_receive == 0 then
				A333DR_audio_panel_capt_mic2_status = 0
				simDR_capt_transmit_mode = 0
			elseif A333DR_com2_receive == 1 then
				A333DR_com2_acknowledge = 1
			end
		elseif A333DR_audio_panel_capt_mic2_status == 0 then
			simDR_capt_transmit_mode = 7
			A333DR_com2_acknowledge = 1
			set_capt_mic_status(0, 1, 0, 0, 0, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_capt_mic2_pos = 0
	end
end




local function A333_capt_push_mic3_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_capt_mic3_pos = 1
		if A333DR_audio_panel_capt_mic3_status == 1 then
			A333DR_audio_panel_capt_mic3_status = 0
		elseif A333DR_audio_panel_capt_mic3_status == 0 then
			simDR_capt_transmit_mode = 0
			set_capt_mic_status(0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_capt_mic3_pos = 0
	end
end




local function A333_capt_push_mic4_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_capt_mic4_pos = 1
		if A333DR_audio_panel_capt_mic4_status == 1 then
			A333DR_audio_panel_capt_mic4_status = 0
		elseif A333DR_audio_panel_capt_mic4_status == 0 then
			simDR_capt_transmit_mode = 0
			set_capt_mic_status(0, 0, 0, 1, 0, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_capt_mic4_pos = 0
	end
end




local function A333_capt_push_mic5_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_capt_mic5_pos = 1
		if A333DR_audio_panel_capt_mic5_status == 1 then
			A333DR_audio_panel_capt_mic5_status = 0
		elseif A333DR_audio_panel_capt_mic5_status == 0 then
			simDR_capt_transmit_mode = 0
			set_capt_mic_status(0, 0, 0, 0, 1, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_capt_mic5_pos = 0
	end
end




local function A333_capt_push_mic6_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_capt_mic6_pos = 1
		if A333DR_audio_panel_capt_mic6_status == 1 then
			A333DR_audio_panel_capt_mic6_status = 0
		elseif A333DR_audio_panel_capt_mic6_status == 0 then
			simDR_capt_transmit_mode = 0
			set_capt_mic_status(0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_capt_mic6_pos = 0
	end
end




local function A333_capt_push_mic7_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_capt_mic7_pos = 1
		if A333DR_audio_panel_capt_mic7_status == 1 then
			A333DR_audio_panel_capt_mic7_status = 0
		elseif A333DR_audio_panel_capt_mic7_status == 0 then
			simDR_capt_transmit_mode = 0
			set_capt_mic_status(0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_capt_mic7_pos = 0
	end
end




local function A333_capt_push_mic8_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_capt_mic8_pos = 1
		if A333DR_audio_panel_capt_mic8_status == 1 then
			A333DR_audio_panel_capt_mic8_status = 0
		elseif A333DR_audio_panel_capt_mic8_status == 0 then
			simDR_capt_transmit_mode = 0
			set_capt_mic_status(0, 0, 0, 0, 0, 0, 0, 1, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_capt_mic8_pos = 0
	end
end




local function A333_capt_push_mic9_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_capt_mic9_pos = 1
		if A333DR_audio_panel_capt_mic9_status == 1 then
			A333DR_audio_panel_capt_mic9_status = 0
		elseif A333DR_audio_panel_capt_mic9_status == 0 then
			simDR_capt_transmit_mode = 0
			set_capt_mic_status(0, 0, 0, 0, 0, 0, 0, 0,1, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_capt_mic9_pos = 0
	end
end




local function A333_capt_push_mic10_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_capt_mic10_pos = 1
		if A333DR_audio_panel_capt_mic10_status == 1 then
			A333DR_audio_panel_capt_mic10_status = 0
		elseif A333DR_audio_panel_capt_mic10_status == 0 then
			simDR_capt_transmit_mode = 0
			set_capt_mic_status(0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
		end
	elseif phase == 2 then
		A333DR_audio_panel_capt_mic10_pos = 0
		A333DR_audio_panel_capt_mic10_status = 0
	end
end




-- FIRST OFFICER
local function set_fo_mic_status(...)
	local args = {...}
	assert(#args == 10, "function set_fo_mic_status() args ~= 10")
	A333DR_audio_panel_fo_mic1_status = args[1]
	A333DR_audio_panel_fo_mic2_status = args[2]
	A333DR_audio_panel_fo_mic3_status = args[3]
	A333DR_audio_panel_fo_mic4_status = args[4]
	A333DR_audio_panel_fo_mic5_status = args[5]
	A333DR_audio_panel_fo_mic6_status = args[6]
	A333DR_audio_panel_fo_mic7_status = args[7]
	A333DR_audio_panel_fo_mic8_status = args[8]
	A333DR_audio_panel_fo_mic9_status = args[9]
	A333DR_audio_panel_fo_mic10_status = args[10]
end



local function A333_fo_push_mic1_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_fo_mic1_pos = 1
		if A333DR_audio_panel_fo_mic1_status == 1 then
			if A333DR_com1_receive == 0 then
				A333DR_audio_panel_fo_mic1_status = 0
				simDR_fo_transmit_mode = 0
			elseif A333DR_com1_receive == 1 then
				A333DR_com1_acknowledge = 1
			end
		elseif A333DR_audio_panel_fo_mic1_status == 0 then
			simDR_fo_transmit_mode = 6
			A333DR_com1_acknowledge = 1
			set_fo_mic_status(1, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_fo_mic1_pos = 0
	end
end




local function A333_fo_push_mic2_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_fo_mic2_pos = 1
		if A333DR_audio_panel_fo_mic2_status == 1 then
			if A333DR_com2_receive == 0 then
				A333DR_audio_panel_fo_mic2_status = 0
				simDR_fo_transmit_mode = 0
			elseif A333DR_com2_receive == 1 then
				A333DR_com2_acknowledge = 1
			end
		elseif A333DR_audio_panel_fo_mic2_status == 0 then
			simDR_fo_transmit_mode = 7
			A333DR_com2_acknowledge = 1
			set_fo_mic_status(0, 1, 0, 0, 0, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_fo_mic2_pos = 0
	end
end




local function A333_fo_push_mic3_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_fo_mic3_pos = 1
		if A333DR_audio_panel_fo_mic3_status == 1 then
			A333DR_audio_panel_fo_mic3_status = 0
		elseif A333DR_audio_panel_fo_mic3_status == 0 then
			simDR_fo_transmit_mode = 0
			set_fo_mic_status(0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_fo_mic3_pos = 0
	end
end




local function A333_fo_push_mic4_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_fo_mic4_pos = 1
		if A333DR_audio_panel_fo_mic4_status == 1 then
			A333DR_audio_panel_fo_mic4_status = 0
		elseif A333DR_audio_panel_fo_mic4_status == 0 then
			simDR_fo_transmit_mode = 0
			set_fo_mic_status(0, 0, 0, 1, 0, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_fo_mic4_pos = 0
	end
end




local function A333_fo_push_mic5_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_fo_mic5_pos = 1
		if A333DR_audio_panel_fo_mic5_status == 1 then
			A333DR_audio_panel_fo_mic5_status = 0
		elseif A333DR_audio_panel_fo_mic5_status == 0 then
			simDR_fo_transmit_mode = 0
			set_fo_mic_status(0, 0, 0, 0, 1, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_fo_mic5_pos = 0
	end
end




local function A333_fo_push_mic6_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_fo_mic6_pos = 1
		if A333DR_audio_panel_fo_mic6_status == 1 then
			A333DR_audio_panel_fo_mic6_status = 0
		elseif A333DR_audio_panel_fo_mic6_status == 0 then
			simDR_fo_transmit_mode = 0
			set_fo_mic_status(0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_fo_mic6_pos = 0
	end
end




local function A333_fo_push_mic7_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_fo_mic7_pos = 1
		if A333DR_audio_panel_fo_mic7_status == 1 then
			A333DR_audio_panel_fo_mic7_status = 0
		elseif A333DR_audio_panel_fo_mic7_status == 0 then
			set_fo_mic_status(0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_fo_mic7_pos = 0
	end
end




local function A333_fo_push_mic8_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_fo_mic8_pos = 1
		if A333DR_audio_panel_fo_mic8_status == 1 then
			A333DR_audio_panel_fo_mic8_status = 0
		elseif A333DR_audio_panel_fo_mic8_status == 0 then
			simDR_fo_transmit_mode = 0
			set_fo_mic_status(0, 0, 0, 0, 0, 0, 0, 1, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_fo_mic8_pos = 0
	end
end




local function A333_fo_push_mic9_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_fo_mic9_pos = 1
		if A333DR_audio_panel_fo_mic9_status == 1 then
			A333DR_audio_panel_fo_mic9_status = 0
		elseif A333DR_audio_panel_fo_mic9_status == 0 then
			simDR_fo_transmit_mode = 0
			set_fo_mic_status(0, 0, 0, 0, 0, 0, 0, 0, 1, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_fo_mic9_pos = 0
	end
end




local function A333_fo_push_mic10_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_fo_mic10_pos = 1
		if A333DR_audio_panel_fo_mic10_status == 1 then
			A333DR_audio_panel_fo_mic10_status = 0
		elseif A333DR_audio_panel_fo_mic10_status == 0 then
			simDR_fo_transmit_mode = 0
			set_fo_mic_status(0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
		end
	elseif phase == 2 then
		A333DR_audio_panel_fo_mic10_pos = 0
		A333DR_audio_panel_fo_mic10_status = 0
	end
end




-- OBSERVER
local function set_obs_mic_status(...)
	local args = {...}
	assert(#args == 10, "function set_obs_mic_status() args ~= 10")
	A333DR_audio_panel_obs_mic1_status = args[1]
	A333DR_audio_panel_obs_mic2_status = args[2]
	A333DR_audio_panel_obs_mic3_status = args[3]
	A333DR_audio_panel_obs_mic4_status = args[4]
	A333DR_audio_panel_obs_mic5_status = args[5]
	A333DR_audio_panel_obs_mic6_status = args[6]
	A333DR_audio_panel_obs_mic7_status = args[7]
	A333DR_audio_panel_obs_mic8_status = args[8]
	A333DR_audio_panel_obs_mic9_status = args[9]
	A333DR_audio_panel_obs_mic10_status = args[10]
end



local function A333_obs_push_mic1_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_obs_mic1_pos = 1
		if A333DR_audio_panel_obs_mic1_status == 1 then
			if A333DR_com1_receive == 0 then
				A333DR_audio_panel_obs_mic1_status = 0
			elseif A333DR_com1_receive == 1 then
				A333DR_com1_acknowledge = 1
			end
		elseif A333DR_audio_panel_obs_mic1_status == 0 then
			A333DR_com1_acknowledge = 1
			set_obs_mic_status(1, 0, 0, 0, 0, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_obs_mic1_pos = 0
	end
end




local function A333_obs_push_mic2_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_obs_mic2_pos = 1
		if A333DR_audio_panel_obs_mic2_status == 1 then
			if A333DR_com2_receive == 0 then
				A333DR_audio_panel_obs_mic2_status = 0
			elseif A333DR_com2_receive == 1 then
				A333DR_com2_acknowledge = 1
			end
		elseif A333DR_audio_panel_obs_mic2_status == 0 then
			A333DR_com2_acknowledge = 1
			set_obs_mic_status(0, 1, 0, 0, 0, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_obs_mic2_pos = 0
	end
end




local function A333_obs_push_mic3_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_obs_mic3_pos = 1
		if A333DR_audio_panel_obs_mic3_status == 1 then
			A333DR_audio_panel_obs_mic3_status = 0
		elseif A333DR_audio_panel_obs_mic3_status == 0 then
			set_obs_mic_status(0, 0, 1, 0, 0, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_obs_mic3_pos = 0
	end
end




local function A333_obs_push_mic4_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_obs_mic4_pos = 1
		if A333DR_audio_panel_obs_mic4_status == 1 then
			A333DR_audio_panel_obs_mic4_status = 0
		elseif A333DR_audio_panel_obs_mic4_status == 0 then
			set_obs_mic_status(0, 0, 0, 1, 0, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_obs_mic4_pos = 0
	end
end




local function A333_obs_push_mic5_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_obs_mic5_pos = 1
		if A333DR_audio_panel_obs_mic5_status == 1 then
			A333DR_audio_panel_obs_mic5_status = 0
		elseif A333DR_audio_panel_obs_mic5_status == 0 then
			set_obs_mic_status(0, 0, 0, 0, 1, 0, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_obs_mic5_pos = 0
	end
end




local function A333_obs_push_mic6_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_obs_mic6_pos = 1
		if A333DR_audio_panel_obs_mic6_status == 1 then
			A333DR_audio_panel_obs_mic6_status = 0
		elseif A333DR_audio_panel_obs_mic6_status == 0 then
			set_obs_mic_status(0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_obs_mic6_pos = 0
	end
end




local function A333_obs_push_mic7_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_obs_mic7_pos = 1
		if A333DR_audio_panel_obs_mic7_status == 1 then
			A333DR_audio_panel_obs_mic7_status = 0
		elseif A333DR_audio_panel_obs_mic7_status == 0 then
			set_obs_mic_status(0, 0, 0, 0, 0, 0, 1, 0, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_obs_mic7_pos = 0
	end
end




local function A333_obs_push_mic8_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_obs_mic8_pos = 1
		if A333DR_audio_panel_obs_mic8_status == 1 then
			A333DR_audio_panel_obs_mic8_status = 0
		elseif A333DR_audio_panel_obs_mic8_status == 0 then
			set_obs_mic_status(0, 0, 0, 0, 0, 0, 0, 1, 0, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_obs_mic8_pos = 0
	end
end




local function A333_obs_push_mic9_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_obs_mic9_pos = 1
		if A333DR_audio_panel_obs_mic9_status == 1 then
			A333DR_audio_panel_obs_mic9_status = 0
		elseif A333DR_audio_panel_obs_mic9_status == 0 then
			set_obs_mic_status(0, 0, 0, 0, 0, 0, 0, 0, 1, 0)
		end
	elseif phase == 2 then
		A333DR_audio_panel_obs_mic9_pos = 0
	end
end




local function A333_obs_push_mic10_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_obs_mic10_pos = 1
		if A333DR_audio_panel_obs_mic10_status == 1 then
			A333DR_audio_panel_obs_mic10_status = 0
		elseif A333DR_audio_panel_obs_mic10_status == 0 then
			set_obs_mic_status(0, 0, 0, 0, 0, 0, 0, 0, 0, 1)
		end
	elseif phase == 2 then
		A333DR_audio_panel_obs_mic10_pos = 0
		A333DR_audio_panel_obs_mic10_status = 0
	end
end




-- RESET
local function A333_capt_push_reset_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_capt_call_reset = 1
	elseif phase == 2 then
		A333DR_audio_panel_capt_call_reset = 0
	end
end



local function A333_fo_push_reset_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_fo_call_reset = 1
	elseif phase == 2 then
		A333DR_audio_panel_fo_call_reset = 0
	end
end



local function A333_obs_push_reset_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_obs_call_reset = 1
	elseif phase == 2 then
		A333DR_audio_panel_obs_call_reset = 0
	end
end



-- VOICE
local function A333_capt_push_voice_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_capt_voice_pos = 1
		A333DR_audio_panel_capt_voice_status = 1 - A333DR_audio_panel_capt_voice_status
	elseif phase == 2 then
		A333DR_audio_panel_capt_voice_pos = 0
	end
end



local function A333_fo_push_voice_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_fo_voice_pos = 1
		A333DR_audio_panel_fo_voice_status = 1 - A333DR_audio_panel_fo_voice_status
	elseif phase == 2 then
		A333DR_audio_panel_fo_voice_pos = 0
	end
end



local function A333_obs_push_voice_CMDhandler(phase, duration)
	if phase == 0 then
		A333DR_audio_panel_obs_voice_pos = 1
		A333DR_audio_panel_obs_voice_status = 1 - A333DR_audio_panel_obs_voice_status
	elseif phase == 2 then
		A333DR_audio_panel_obs_voice_pos = 0
	end
end



-- LISTENING MODES
for i = 0, NUM_CAPT_LISTENING_KNOBS-1 do

    -- CREATE THE COVER HANDLER FUNCTIONS
	A333_audio_capt_listen_press_CMDhandler[i] = function(phase, duration)

        if phase == 0 then
 			if A333DR_audio_panel_capt_listen_pos[i] == 0 then
 				A333DR_audio_panel_capt_listen_pos[i] = -0.2
				CLDR_audio_panel_capt_listen_status[i] = 1
 			elseif A333DR_audio_panel_capt_listen_pos[i] == 1 then
				A333DR_audio_panel_capt_listen_pos[i] = -0.2
				CLDR_audio_panel_capt_listen_status[i] = 0
			end
		elseif phase == 2 then
			if CLDR_audio_panel_capt_listen_status[i] == 1 then
				A333DR_audio_panel_capt_listen_pos[i] = 1
			elseif CLDR_audio_panel_capt_listen_status[i] == 0 then
				A333DR_audio_panel_capt_listen_pos[i] = 0
			end
         end
    end
end



for i = 0, NUM_FO_LISTENING_KNOBS-1 do

    -- CREATE THE COVER HANDLER FUNCTIONS
	A333_audio_fo_listen_press_CMDhandler[i] = function(phase, duration)

        if phase == 0 then
 			if A333DR_audio_panel_fo_listen_pos[i] == 0 then
 				A333DR_audio_panel_fo_listen_pos[i] = -0.2
				CLDR_audio_panel_fo_listen_status[i] = 1
 			elseif A333DR_audio_panel_fo_listen_pos[i] == 1 then
				A333DR_audio_panel_fo_listen_pos[i] = -0.2
				CLDR_audio_panel_fo_listen_status[i] = 0
			end
		elseif phase == 2 then
			if CLDR_audio_panel_fo_listen_status[i] == 1 then
				A333DR_audio_panel_fo_listen_pos[i] = 1
			elseif CLDR_audio_panel_fo_listen_status[i] == 0 then
				A333DR_audio_panel_fo_listen_pos[i] = 0
			end
		end

    end
end



for i = 0, NUM_OBS_LISTENING_KNOBS-1 do

    -- CREATE THE COVER HANDLER FUNCTIONS
	A333_audio_obs_listen_press_CMDhandler[i] = function(phase, duration)

        if phase == 0 then
 			if A333DR_audio_panel_obs_listen_pos[i] == 0 then
 				A333DR_audio_panel_obs_listen_pos[i] = -0.2
				CLDR_audio_panel_obs_listen_status[i] = 1
 			elseif A333DR_audio_panel_obs_listen_pos[i] == 1 then
				A333DR_audio_panel_obs_listen_pos[i] = -0.2
				CLDR_audio_panel_obs_listen_status[i] = 0
			end
		elseif phase == 2 then
			if CLDR_audio_panel_obs_listen_status[i] == 1 then
				A333DR_audio_panel_obs_listen_pos[i] = 1
			elseif CLDR_audio_panel_obs_listen_status[i] == 0 then
				A333DR_audio_panel_obs_listen_pos[i] = 0
			end
         end
    end
end



-- AI
local function A333_ai_audio_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	A333_set_audio_all_modes()
	  	A333_set_audio_CD()
	  	A333_set_audio_ER()
	end
end




--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--

-- AI
A333CMD_ai_audio_quick_start	= create_command("laminar/A333/ai/audio_quick_start", "number", A333_ai_audio_quick_start_CMDhandler)

-- AUDIO PANEL MIC SELECTOR COMMANDS

-- CAPT
A333CMD_capt_push_mic1			= create_command("laminar/A333/audio/capt/mic_push1", "Captain VHF1 Mic", A333_capt_push_mic1_CMDhandler)
A333CMD_capt_push_mic2			= create_command("laminar/A333/audio/capt/mic_push2", "Captain VHF2 Mic", A333_capt_push_mic2_CMDhandler)
A333CMD_capt_push_mic3			= create_command("laminar/A333/audio/capt/mic_push3", "Captain VHF3 Mic", A333_capt_push_mic3_CMDhandler)
A333CMD_capt_push_mic4			= create_command("laminar/A333/audio/capt/mic_push4", "Captain HF1 Mic", A333_capt_push_mic4_CMDhandler)
A333CMD_capt_push_mic5			= create_command("laminar/A333/audio/capt/mic_push5", "Captain HF2 Mic", A333_capt_push_mic5_CMDhandler)
A333CMD_capt_push_mic6			= create_command("laminar/A333/audio/capt/mic_push6", "Captain INT Mic", A333_capt_push_mic6_CMDhandler)
A333CMD_capt_push_mic7			= create_command("laminar/A333/audio/capt/mic_push7", "Captain CAB Mic", A333_capt_push_mic7_CMDhandler)
A333CMD_capt_push_mic8			= create_command("laminar/A333/audio/capt/mic_push8", "Captain SAT1 Mic", A333_capt_push_mic8_CMDhandler)
A333CMD_capt_push_mic9			= create_command("laminar/A333/audio/capt/mic_push9", "Captain SAT2 Mic", A333_capt_push_mic9_CMDhandler)
A333CMD_capt_push_mic10			= create_command("laminar/A333/audio/capt/mic_push10", "Captain PA Mic", A333_capt_push_mic10_CMDhandler)

A333CMD_capt_push_reset			= create_command("laminar/A333/audio/capt/reset_push", "Captain CALL RESET", A333_capt_push_reset_CMDhandler)
A333CMD_capt_push_voice			= create_command("laminar/A333/audio/capt/voice_push", "Captain CALL VOICE", A333_capt_push_voice_CMDhandler)


-- F/O
A333CMD_fo_push_mic1			= create_command("laminar/A333/audio/fo/mic_push1", "First Officer VHF1 Mic", A333_fo_push_mic1_CMDhandler)
A333CMD_fo_push_mic2			= create_command("laminar/A333/audio/fo/mic_push2", "First Officer VHF2 Mic", A333_fo_push_mic2_CMDhandler)
A333CMD_fo_push_mic3			= create_command("laminar/A333/audio/fo/mic_push3", "First Officer VHF3 Mic", A333_fo_push_mic3_CMDhandler)
A333CMD_fo_push_mic4			= create_command("laminar/A333/audio/fo/mic_push4", "First Officer HF1 Mic", A333_fo_push_mic4_CMDhandler)
A333CMD_fo_push_mic5			= create_command("laminar/A333/audio/fo/mic_push5", "First Officer HF2 Mic", A333_fo_push_mic5_CMDhandler)
A333CMD_fo_push_mic6			= create_command("laminar/A333/audio/fo/mic_push6", "First Officer INT Mic", A333_fo_push_mic6_CMDhandler)
A333CMD_fo_push_mic7			= create_command("laminar/A333/audio/fo/mic_push7", "First Officer CAB Mic", A333_fo_push_mic7_CMDhandler)
A333CMD_fo_push_mic8			= create_command("laminar/A333/audio/fo/mic_push8", "First Officer SAT1 Mic", A333_fo_push_mic8_CMDhandler)
A333CMD_fo_push_mic9			= create_command("laminar/A333/audio/fo/mic_push9", "First Officer SAT2 Mic", A333_fo_push_mic9_CMDhandler)
A333CMD_fo_push_mic10			= create_command("laminar/A333/audio/fo/mic_push10", "First Officer PA Mic", A333_fo_push_mic10_CMDhandler)

A333CMD_fo_push_reset			= create_command("laminar/A333/audio/fo/reset_push", "First Officer CALL RESET", A333_fo_push_reset_CMDhandler)
A333CMD_fo_push_voice			= create_command("laminar/A333/audio/fo/voice_push", "First Officer CALL VOICE", A333_fo_push_voice_CMDhandler)


-- OBS
A333CMD_obs_push_mic1			= create_command("laminar/A333/audio/obs/mic_push1", "Observer VHF1 Mic", A333_obs_push_mic1_CMDhandler)
A333CMD_obs_push_mic2			= create_command("laminar/A333/audio/obs/mic_push2", "Observer VHF2 Mic", A333_obs_push_mic2_CMDhandler)
A333CMD_obs_push_mic3			= create_command("laminar/A333/audio/obs/mic_push3", "Observer VHF3 Mic", A333_obs_push_mic3_CMDhandler)
A333CMD_obs_push_mic4			= create_command("laminar/A333/audio/obs/mic_push4", "Observer HF1 Mic", A333_obs_push_mic4_CMDhandler)
A333CMD_obs_push_mic5			= create_command("laminar/A333/audio/obs/mic_push5", "Observer HF2 Mic", A333_obs_push_mic5_CMDhandler)
A333CMD_obs_push_mic6			= create_command("laminar/A333/audio/obs/mic_push6", "Observer INT Mic", A333_obs_push_mic6_CMDhandler)
A333CMD_obs_push_mic7			= create_command("laminar/A333/audio/obs/mic_push7", "Observer CAB Mic", A333_obs_push_mic7_CMDhandler)
A333CMD_obs_push_mic8			= create_command("laminar/A333/audio/obs/mic_push8", "Observer SAT1 Mic", A333_obs_push_mic8_CMDhandler)
A333CMD_obs_push_mic9			= create_command("laminar/A333/audio/obs/mic_push9", "Observer SAT2 Mic", A333_obs_push_mic9_CMDhandler)
A333CMD_obs_push_mic10			= create_command("laminar/A333/audio/obs/mic_push10", "Observer PA Mic", A333_obs_push_mic10_CMDhandler)

A333CMD_obs_push_reset			= create_command("laminar/A333/audio/obs/reset_push", "Observer CALL RESET", A333_obs_push_reset_CMDhandler)
A333CMD_obs_push_voice			= create_command("laminar/A333/audio/obs/voice_push", "Observer CALL VOICE", A333_obs_push_voice_CMDhandler)


-- VOLUME
A333CMD_audio_capt_listen_press = {}
for i = 0, NUM_CAPT_LISTENING_KNOBS-1 do
    A333CMD_audio_capt_listen_press[i] = create_command("laminar/A333/audio/capt/listen_press" .. string.format("%02d", i), "Captain Audio Mode LISTENING" .. string.format("%02d", i), A333_audio_capt_listen_press_CMDhandler[i])
end

A333CMD_audio_fo_listen_press = {}
for i = 0, NUM_FO_LISTENING_KNOBS-1 do
    A333CMD_audio_fo_listen_press[i] = create_command("laminar/A333/audio/fo/listen_press" .. string.format("%02d", i), "First Officer Audio Mode LISTENING" .. string.format("%02d", i), A333_audio_fo_listen_press_CMDhandler[i])
end

A333CMD_audio_obs_listen_press = {}
for i = 0, NUM_OBS_LISTENING_KNOBS-1 do
    A333CMD_audio_obs_listen_press[i] = create_command("laminar/A333/audio/obs/listen_press" .. string.format("%02d", i), "Observer Audio Mode LISTENING" .. string.format("%02d", i), A333_audio_obs_listen_press_CMDhandler[i])
end



--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--
local function A333_audio_selections()

	-- SET THE SIM RADIO AUDIO STATUS
	simDR_capt_com1_listen = CLDR_audio_panel_capt_listen_status[0]
	simDR_capt_com2_listen = CLDR_audio_panel_capt_listen_status[1]
	simDR_capt_LS_listen = CLDR_audio_panel_capt_listen_status[7]
	simDR_capt_nav1_listen = CLDR_audio_panel_capt_listen_status[9]
	simDR_capt_nav2_listen = CLDR_audio_panel_capt_listen_status[10]
	simDR_capt_adf1_listen = CLDR_audio_panel_capt_listen_status[11]
	simDR_capt_adf2_listen = CLDR_audio_panel_capt_listen_status[12]
	simDR_capt_mkr_listen = CLDR_audio_panel_capt_listen_status[8]

	simDR_fo_com1_listen = CLDR_audio_panel_fo_listen_status[0]
	simDR_fo_com2_listen = CLDR_audio_panel_fo_listen_status[1]
	simDR_fo_LS_listen = CLDR_audio_panel_fo_listen_status[7]
	simDR_fo_nav1_listen = CLDR_audio_panel_fo_listen_status[9]
	simDR_fo_nav2_listen = CLDR_audio_panel_fo_listen_status[10]
	simDR_fo_adf1_listen = CLDR_audio_panel_fo_listen_status[11]
	simDR_fo_adf2_listen = CLDR_audio_panel_fo_listen_status[12]
	simDR_fo_mkr_listen = CLDR_audio_panel_fo_listen_status[8]

end



----- AIRCRAFT LOAD ---------------------------------------------------------------------





----- SET STATE FOR ALL MODES -----------------------------------------------------------
local function A333_set_audio_all_modes()

	A333DR_init_audio_CD = 0

	-- XPD-13105: DEFAULT TO "ON" AT AIRCRAFT LOAD -----
	if A333DR_audio_panel_capt_listen_status[0] == 0.0 then
		A333CMD_audio_capt_listen_press[0]:once()
	end
	if A333DR_audio_panel_capt_mic1_status == 0 then
		A333CMD_capt_push_mic1:once()
	end
	if A333DR_audio_panel_capt_listen_status[1] == 0.0 then
		A333CMD_audio_capt_listen_press[1]:once()
	end
	if A333DR_audio_panel_obs_listen_status[15] == 0.0 then
		A333CMD_audio_obs_listen_press[15]:once()
	end
	----------------------------------------------------





end


----- SET STATE TO COLD & DARK ----------------------------------------------------------
local function A333_set_audio_CD()


end


----- SET STATE TO ENGINES RUNNING ------------------------------------------------------

local function A333_set_audio_ER()


end


----- FLIGHT START ---------------------------------------------------------------------

local function A333_flight_start_audio()

    -- ALL MODES ------------------------------------------------------------------------
    A333_set_audio_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        A333_set_audio_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		A333_set_audio_ER()

    end

end





----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
local function A333_audio_monitor_AI()

	if A333DR_init_audio_CD == 1 then
		A333_set_audio_all_modes()
		A333_set_audio_CD()
		A333DR_init_audio_CD = 2
	end

end




--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

local function A333_ALL_audio()

	A333_audio_selections()
	A333_audio_monitor_AI()


end

function aircraft_load()

    A333_flight_start_audio()

end

--function aircraft_unload() end

--function flight_start() end

--function flight_crash() end

--function before_physics() end

function after_physics()

	A333_ALL_audio()

end

function after_replay()

	A333_ALL_audio()

end

