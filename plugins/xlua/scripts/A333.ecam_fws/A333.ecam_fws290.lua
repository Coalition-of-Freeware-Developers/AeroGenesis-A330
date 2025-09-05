jit.off()
--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws290.lua
* Process: FWS Master Warning/Master Caution Processing
*
* Author Name :	Jim Gregory
*
* Revisions:
* -- DATE --  --- REV NO ---  --- DESCRIPTION -------------------------------------------
*
*
*
*
*
*****************************************************************************************
*       					     COPYRIGHT © 2021, 2022
*					 	   L A M I N A R   R E S E A R C H
*								  ALL RIGHTS RESERVED
*****************************************************************************************
--]]


--print("LOAD: A333.ecam_fws290.lua")

--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--[[

SIM_PERIOD: this contains the duration of the current frame in seconds (so it is alway a
fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you’d do fuel = fuel + 3 * SIM_PERIOD.


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
--**********************************************************************************--

local gcPulse01 = newLeadingEdgePulse('gcPulse01')
local gcPulse02 = newLeadingEdgePulse('gcPulse02')
local gcPulse03 = newLeadingEdgePulse('gcPulse03')
local gcPulse04 = newLeadingEdgePulse('gcPulse04')



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
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--



--*************************************************************************************--
--** 				            CUSTOM COMMAND HANDLERS            				     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				             CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				          X-PLANE WRAP COMMAND HANDLERS              	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				              WRAP X-PLANE COMMANDS                  	    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				         X-PLANE REPLACE COMMAND HANDLERS              	    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				            REPLACE X-PLANE COMMANDS                  	    	 **--
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

function A333_fws_general_cancel()

	gcPulse01:update(WFOMWC)
	gcPulse02:update(WCMWC)
	gcPulse03:update(WFOMCC)
	gcPulse04:update(WCMCC)

	local a = {E1 = gcPulse01.OUT, E2 = gcPulse02.OUT}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = gcPulse03.OUT, E2 = gcPulse04.OUT}
	b.S = bOR(b.E1, b.E2)

	ZMWCANUP = a.S		-- MASTER WARNING CANCEL
	ZMCCANUP = b.S		-- MASTER CAUTION CANCEL

end



function A333_fws_master_warning_cancel()

	if ZMWCANUP then

		if simDR_plugin_master_warning == 1 then										-- THE MASTER WARNING IS ACTIVE

			for _, msg in ipairs(A333_ewd_msg_cue_L) do									-- ITERATE THE EWD MESSAGE CUE ZONE 0

				if string.find(A333_ewd_msg[msg.Name].CmdInputs, 'C') then				-- THIS MESSAGE IS AUTHORIZED FOR 'CANCEL'

					-- CONTINUOUS LEVEL 3 SOUNDS ARE CLEARED ONE AFTER THE OTHER
					if A333_ewd_msg[msg.Name].Monitor.audio.OUT == 1					-- ALERT SOUND IS PLAYING
						and A333_aural_alert[A333_ewd_msg[msg.Name].Aural].type == 2	-- CONTINUOUS PLAY ALERT
						and A333_ewd_msg[msg.Name].Level == 3							-- LEVEL 3 (RED) ALERT
					then
						A333_ewd_msg[msg.Name].Monitor.audio.OUT = 2					-- SET AUDIO STATUS TO 'CANCEL'
						simDR_plugin_master_warning = 0									-- TURN OFF THE MASTER WARNING ANNUNCIATOR LIGHT

						-- AFTER EACH CANCEL THERE IS ONE SECOND OF SILENCE.
						masterCancelSilence = true
						if is_timer_scheduled(masterCancelAlertDelay) then
							stop_timer(masterCancelAlertDelay)
						end
						run_after_time(masterCancelAlertDelay, 1.0)

						break															-- ONLY CANX ONE ALERT AT A TIME

					end
				end
			end
		end

	end

end



function A333_fws_master_caution_cancel()

	if ZMCCANUP then

		if simDR_plugin_master_caution == 1 then										-- THE MASTER CAUTION IS ACTIVE

			for _, msg in ipairs(A333_ewd_msg_cue_L) do									-- ITERATE THE EWD MESSAGE CUE ZONE 0

				if string.find(A333_ewd_msg[msg.Name].CmdInputs, 'C') then				-- THIS MESSAGE IS AUTHORIZED FOR 'CANCEL'

					-- CONTINUOUS LEVEL 1/2 ALERTS ARE CLEARED ONE AFTER THE OTHER
					if A333_aural_alert[A333_ewd_msg[msg.Name].Aural].type == 2			-- CONTINUOUS PLAY ALERT
						and A333_ewd_msg[msg.Name].Monitor.audio.OUT == 1				-- ALERT SOUND IS PLAYING
						and A333_ewd_msg[msg.Name].Level ~= 3							-- LEVEL 1/2 (AMBER) ALERT
					then
						A333_ewd_msg[msg.Name].Monitor.audio.OUT = 2					-- SET AUDIO STATUS TO 'CANCEL'
						simDR_plugin_master_caution = 0									-- TURN OFF THE MASTER CAUTION ANNUNCIATOR LIGHT

						-- AFTER EACH CANCEL THERE IS ONE SECOND OF SILENCE.
						masterCancelSilence = true
						if is_timer_scheduled(masterCancelAlertDelay) then
							stop_timer(masterCancelAlertDelay)
						end
						run_after_time(masterCancelAlertDelay, 1.0)

						break															-- ONLY CANX ONE ALERT AT A TIME

					else -- SINGLE PLAY ALERT
						simDR_plugin_master_caution = 0									-- TURN OFF THE MASTER CAUTION ANNUNCIATOR LIGHT
						break															-- ONLY CANX ONE ALERT AT A TIME
					end
				end
			end
		end

	end

end








function resetMasterAnnunciator()

	local resetWarning = true
	local resetCaution = true

	for _, msg in pairs(A333_ewd_msg) do

		if msg.Monitor.video.OUT == 1 or msg.Monitor.audio.OUT == 1 then
			if msg.MasterType == 1 then resetWarning = false end
			if msg.MasterType == 2 then resetCaution = false end
		end

	end

	if resetCaution and simDR_plugin_master_caution == 1 then
		simDR_plugin_master_caution = 0
		simCMD_master_caut_canx:once()
	end


	if resetWarning and simDR_plugin_master_warning == 1 then
		simDR_plugin_master_warning = 0
		simCMD_master_warn_canx:once()
	end

end







function masterCancelAlertDelay()
	masterCancelSilence = false
end






--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_290()

	A333_fws_general_cancel()
	A333_fws_master_warning_cancel()
	A333_fws_master_caution_cancel()

end



--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







