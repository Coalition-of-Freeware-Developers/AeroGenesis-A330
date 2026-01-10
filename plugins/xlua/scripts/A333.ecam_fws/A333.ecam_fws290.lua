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
*       					 COPYRIGHT © 2021, 2022, 2025
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

local function A333_fws_general_cancel()

	gcPulse01:update(WFOMWC)
	gcPulse02:update(WCMWC)
	gcPulse03:update(WFOMCC)
	gcPulse04:update(WCMCC)

	local a = gcPulse01.OUT or gcPulse02.OUT
	local b = gcPulse03.OUT or gcPulse04.OUT

	ZMWCANUP = a		-- MASTER WARNING CANCEL
	ZMCCANUP = b		-- MASTER CAUTION CANCEL

end



local function A333_fws_master_warning_cancel()

	if ZMWCANUP then

		if simDR_plugin_master_warning == 1 then										-- THE MASTER WARNING IS ACTIVE

			for _, msg in ipairs(A333_ewd_msg_cue_L) do									-- ITERATE THE EWD MESSAGE CUE ZONE 0
				-- Reference and skip the namespace/array lookups
				local lcl_this_ewd_msg = A333_ewd_msg[msg.Name]

				if string.find(lcl_this_ewd_msg.CmdInputs, 'C') then				-- THIS MESSAGE IS AUTHORIZED FOR 'CANCEL'

					-- CONTINUOUS LEVEL 3 SOUNDS ARE CLEARED ONE AFTER THE OTHER
					if lcl_this_ewd_msg.Monitor.audio.OUT == 1					-- ALERT SOUND IS PLAYING
						and lcl_this_ewd_msg.Level == 3							-- LEVEL 3 (RED) ALERT
						and A333_aural_alert[lcl_this_ewd_msg.Aural].type == 2	-- CONTINUOUS PLAY ALERT
					then
						lcl_this_ewd_msg.Monitor.audio.OUT = 2					-- SET AUDIO STATUS TO 'CANCEL'
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



local function A333_fws_master_caution_cancel()

	if ZMCCANUP then

		if simDR_plugin_master_caution == 1 then										-- THE MASTER CAUTION IS ACTIVE

			for _, msg in ipairs(A333_ewd_msg_cue_L) do									-- ITERATE THE EWD MESSAGE CUE ZONE 0
				-- Reference and skip the namespace/array lookups
				local lcl_this_ewd_msg = A333_ewd_msg[msg.Name]

				if string.find(lcl_this_ewd_msg.CmdInputs, 'C') then				-- THIS MESSAGE IS AUTHORIZED FOR 'CANCEL'

					-- CONTINUOUS LEVEL 1/2 ALERTS ARE CLEARED ONE AFTER THE OTHER
					if A333_aural_alert[lcl_this_ewd_msg.Aural].type == 2			-- CONTINUOUS PLAY ALERT
						and lcl_this_ewd_msg.Monitor.audio.OUT == 1				-- ALERT SOUND IS PLAYING
						and lcl_this_ewd_msg.Level ~= 3							-- LEVEL 1/2 (AMBER) ALERT
					then
						lcl_this_ewd_msg.Monitor.audio.OUT = 2					-- SET AUDIO STATUS TO 'CANCEL'
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







