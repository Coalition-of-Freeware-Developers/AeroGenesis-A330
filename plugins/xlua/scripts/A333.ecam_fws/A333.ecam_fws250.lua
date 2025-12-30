--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws250.lua
* Process: FWS ECP CLR PROCESSING
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


--print("LOAD: A333.ecam_fws250.lua")
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
--*************************************************************************************--
local bool2num = {[true] = 1, [false] = 0}
local num2bool = {[0] = false, [1] = true}


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





-----| EWD HAS MESSAGES TO CLEAR
-----------------------------------------------------------------------------------------
local function EWDzone0hasMsgsToClear()
    local msgsToBeCleared = false
    for _, msg in ipairs(A333_ewd_msg_cue_L) do
        if msg.Ftype == 1 or msg.Ftype == 2 then
            msgsToBeCleared = true
            break
        end
    end
    return msgsToBeCleared
end




local function EWDzone1hasMsgsToClear()
    local msgsToBeCleared = false
    for _, msg in ipairs(A333_ewd_msg_cue_R) do
        if msg.Ftype == 4 then
            msgsToBeCleared = true
            break
        end
    end
    return msgsToBeCleared
end




local function EWDhasMsgsToClear()
    return EWDzone0hasMsgsToClear() or EWDzone1hasMsgsToClear()
end





-----| CLEAR SD ZONE 0
-----------------------------------------------------------------------------------------
local function ClearSDzone0(buttonSource)

    if ZSTSPD then

        local type = A333_sts_msg_cue_L[1].Type

        for _, msg in ipairs(A333_sts_msg_cue_L) do

            if msg.Type == type then

                if msg.Type == 0 or msg.Type == 3 or msg.Type == 4 then					-- CLEAR LINES OF 'CLASS': 0=LIMITATION, 3=INFO, 4=CANCELLED CAUTIOn (IF VISIBLE)

                    for i = 1, #A333_sts_msg[msg.Name].Msg do
                        if A333_sts_msg[msg.Name].Msg[i].Visible == 1					-- ACTION LINE IS CURRENTLY VISIBLE
                            and A333_sts_msg[msg.Name].Msg[i].Cleared == 0				-- AND NOT CLEARED
                        then
                            if string.find(A333_ewd_msg[msg.Name].CmdInputs, buttonSource) then		-- THIS MESSAGE HAS 'CLEAR' AUTHORIZATION
                                if A333_sts_msg[msg.Name].Video.OUT == 1 then
                                    A333_sts_msg[msg.Name].Video.OUT = 2					-- SET THE STATUS VIDEO OUT TO 'CLEARED'
                                end
                                A333_sts_msg[msg.Name].Msg[i].Cleared = 1					-- SET THIS ACTION LINE TO 'CLEARED'
                            end
                        end
                    end



                elseif msg.Type == 1 or msg.Type == 2 then								-- CLEAR ALL LINES OF 'STATUS' 1=APPR PROCEDURE, 2=PROCEDURE (IF ALL LINES VISIBLE)

                    -- CHECK FOR OFF SCREEN LINES
                    local thisStatusMsgLinesAreVisible = true
                    for i = 1, #A333_sts_msg[msg.Name].Msg do
                        if A333_sts_msg[msg.Name].Msg[i].Status == 1
                            and A333_sts_msg[msg.Name].Msg[i].Cleared == 0
                            and A333_sts_msg[msg.Name].Msg[i].Visible == 0
                        then
                            thisStatusMsgLinesAreVisible = false
                        end
                    end

                    -- CLEAR THIS STATUS WHEN ALL LINES VISIBLE
                    if thisStatusMsgLinesAreVisible then

                        for i = 1, #A333_sts_msg[msg.Name].Msg do

                            if string.find(A333_ewd_msg[msg.Name].CmdInputs, buttonSource) then		-- THIS MESSAGE HAS 'CLEAR' AUTHORIZATION

                                if A333_sts_msg[msg.Name].Video.OUT == 1 then
                                    A333_sts_msg[msg.Name].Video.OUT = 2				-- SET THE STATUS VIDEO OUT TO 'CLEARED'
                                end
                                if A333_sts_msg[msg.Name].Msg[i].Visible == 1			-- ACTION LINE IS CURRENTLY VISIBLE
                                    and A333_sts_msg[msg.Name].Msg[i].Cleared == 0		-- AND NOT CLEARED
                                then
                                    A333_sts_msg[msg.Name].Msg[i].Cleared = 1			-- SET LINE TO CLEARED
                                end

                            end
                        end
                    end
                end
            end
        end
    end

end


-----| CLEAR SD ZONE 1
-----------------------------------------------------------------------------------------
local function ClearSDzone1(buttonSource)

    if ZSTSPD then

        local lineCount = 0
        for _, msg in ipairs(A333_sts_msg_cue_R) do

            for i = 1, #A333_sts_msg[msg.Name].Msg do

                if A333_sts_msg[msg.Name].Msg[i].Visible == 1							-- ACTION LINE IS CURRENTLY VISIBLE
                    and A333_sts_msg[msg.Name].Msg[i].Cleared == 0						-- AND NOT CLEARED
                then

                    if string.find(A333_ewd_msg[msg.Name].CmdInputs, buttonSource) then		-- THIS MESSAGE HAS 'CLEAR' AUTHORIZATION

                        if A333_sts_msg[msg.Name].Video.OUT == 1 then
                            A333_sts_msg[msg.Name].Video.OUT = 2						-- SET THE STATUS VIDEO OUT TO 'CLEARED'
                        end
                        A333_sts_msg[msg.Name].Msg[i].Cleared = 1
                        lineCount = lineCount + 1

                    end
                end
            end
            if lineCount == 17 then break end
        end
    end

end





-----| EWD OVERFLOW
-----------------------------------------------------------------------------------------
local function ewd_zone0_overflow()

    local msgCount = 0

    for _, msg in ipairs(A333_ewd_msg_cue_L) do

        if msg.Ftype == 1 or msg.Ftype == 2 then  		-- THERE IS NO MEMO OVERFLOW MAMAGEMENT
            -- OVERFLOW ONLY FOR INDEPENDENT AND PRIMARY WARNINGS IN ZONE 0 (LEFT)

            msgCount = msgCount + 1

            for _, MsgLine in ipairs(A333_ewd_msg[msg.Name].MsgLine) do
                if MsgLine.MsgStatus == 1 and MsgLine.MsgCleared == 0
                then
                    msgCount = msgCount + 1
                end
            end

        else
            break

        end

    end

    return msgCount > 7

end




local function ewd_zone1_overflow()

    local msgCount = 0

    for _, msg in ipairs(A333_ewd_msg_cue_R) do
        if msg.Ftype == 0 or msg.Ftype == 4 then 		-- THERE IS NO MEMO OVERFLOW MAMAGEMENT
            -- OVERFLOW ONLY FOR SPECIAL LINES AND SECONDARY FAILURES
            msgCount = msgCount + 1
        end
    end

    return msgCount > 7

end




local function A333_fws_ewd_overflow_symbol()

    A333DR_ecam_ewd_show_overflow_arrow = (ewd_zone0_overflow() or ewd_zone1_overflow()) and 1 or 0
    return num2bool[A333DR_ecam_ewd_show_overflow_arrow]

end






-----| SD HAS MESSAGES TO CLEAR
-----------------------------------------------------------------------------------------
local function SDzone0HasMsgsToClear()

    local lastType = 0
    local sts_line_L = 1
    local msgsToBeCleared

    for _, sts in ipairs(A333_sts_msg_cue_L) do

        if sts_line_L > 1                                                        	-- DO NOT CONSIDER IF @ FIRST OR LAST DISPLAY LINE
            and sts_line_L < 18
        then
            if sts.Type ~= lastType then                                       		-- MESSAGE TYPE (DISPLAY SECTION) HAS CHANGED
                sts_line_L = sts_line_L + 1                        					-- ADD A BLANK LINE
            end
        end
        lastType = sts.Type


        local lastMsgLine = 0

        for i, msg in ipairs(A333_sts_msg[sts.Name].Msg) do

            if msg.Status == 1
                and msg.Cleared == 0
            then
                if msg.Line == lastMsgLine then                                     -- THIS IS THE SECOND MESSAGE ON THIS (SAME) LINE
                    sts_line_L = sts_line_L + 1
                else
                    if i+1 <= #A333_sts_msg[sts.Name].Msg then                      -- IS THERE ANOTHER MSG IN THE TABLE ?
                        if A333_sts_msg[sts.Name].Msg[i+1].Status == 1              -- IS THAT MESSGE ACTIVE ?
                            and A333_sts_msg[sts.Name].Msg[i+1].Line ~= msg.Line    -- IS THAT MESSAGE LINE DIFF FROM THE LAST MESSAGE LINE?
                        then
                            sts_line_L = sts_line_L + 1
                        end
                    else
                        sts_line_L = sts_line_L + 1
                    end
                end
                lastMsgLine = msg.Line
            end
        end
    end

    msgsToBeCleared = (sts_line_L > 18)
    return msgsToBeCleared

end




local function SDzone1HasMsgsToClear()
    local msgsToBeCleared = false
    for _, sts in ipairs(A333_sts_msg_cue_R) do
        if sts.Type == 5 then
            if A333_sts_msg[sts.Name].Monitor.video.OUT	== 1 then
                msgsToBeCleared = true
            end
        end
    end
    return msgsToBeCleared
end




local function SDhasMsgsToBeCleared()
    return SDzone0HasMsgsToClear() or SDzone1HasMsgsToClear()
end





-----|  SD AUTO SHOW
-----------------------------------------------------------------------------------------
local function getSDzone0hasMsgsForAutoShow()
    local SDzone0hasMsgsForAutoShow = false
    for _, msg in ipairs(A333_sts_msg_cue_L) do
        if msg.Type >= 0
            and msg.Type <= 3
        then
            SDzone0hasMsgsForAutoShow = true
            break
        end
    end
    return SDzone0hasMsgsForAutoShow
end




local function getSDzone1hasMsgsForAutoShow()
    local SDzone1hasMsgsForAutoShow = false
    for _, msg in ipairs(A333_sts_msg_cue_R) do
        if msg.Type == 5 then
            SDzone1hasMsgsForAutoShow = true
            break
        end
    end
    return SDzone1hasMsgsForAutoShow
end




local function SDhasMsgsForAutoShow()
    return getSDzone0hasMsgsForAutoShow() or getSDzone1hasMsgsForAutoShow()
end





local function A333_ecp_ProcessCLR()

	A333_fws_hide_rcl_normal_msg()

	local itemGroup
	local displayLines = 0
	local visibleItems = 0
	local visibleWarnings = 0


	-------------------------------------------------------------------------------
	--|                        CLEAR E/WD ZONE 0 (LEFT)							|--
	-------------------------------------------------------------------------------
	if EWDzone0hasMsgsToClear() then

		-- SET THE COUNTERS:
		-- INCREMENTED BY THE CURRENT VISIBLE ITEMS AND VISIBLE WARNINGS
		-- THESE COUNTERS ARE USED TO DETERMINE HOW TO CLEAR WARNINGS (BELOW)
		for _, msg in ipairs(A333_ewd_msg_cue_L) do

			displayLines = displayLines + 1											-- INCREMENT THE (VISIBLE) LINE COUNTER

			-- Reference and skip the namespace/array lookups
			local lcl_this_ewd_msg = A333_ewd_msg[msg.Name]

			if msg.Ftype == 1 or msg.Ftype == 2 then								-- ONLY PRIMARY OR INDEPENDENT FAILURES ARE CONSIDERED

				if lcl_this_ewd_msg.ItemGroup ~= itemGroup then				-- THE ITEM GROUP HAS CHANGED (OR THIS IS THE FIRST ITEM GROUP IN THE CUE)
					visibleItems = visibleItems + 1									-- THIS WILL BE THE # OF ITEM GROUPS THAT ARE BEING DISPLAYED (VISIBLE)
					itemGroup = lcl_this_ewd_msg.ItemGroup
					if visibleItems > 1 then break end								-- WE ONLY NEED TO KNOW IF THERE IS MORE THAN ONE ITEM GROUP VISIBLE
				end

				visibleWarnings = visibleWarnings + 1								-- THIS WILL BE THE # OF (VISIBLE) WARNINGS OF THE FIRST (VISIBLE) ITEM GROUP IN THE CUE

			end

			if lcl_this_ewd_msg.MsgLine then									--|
				for i = 1, #lcl_this_ewd_msg.MsgLine do						--|
					if lcl_this_ewd_msg.MsgLine[i].MsgVisible == 1 then		--|
						displayLines = displayLines + 1								--| INCREMENT THE TOTAL # LINES DISPLAYED BASED ON THE VISIBLE ACTION LINES
					end																--|
				end																	--|
			end																		--|

			if displayLines >= 7 then break end										-- WE ONLY CONSIDER THE FIRST SEVEN LINES IN THE CUE THAT ARE CURRENTLY BEING DISPLAYED

		end




		-- SET THE ITEM GROUP:
		-- DETERMINED BY THE FIRST DISPLAYED WARNING IF IT IS A PRIMARY OR INDEPENDENT FAILURE
		-- THE FOUND ITEM GROUP WILL BE USED TO DETERMINE HOW TO CLEAR WARNINGS FROM ZONE 0 (BELOW)
		displayLines = 0
		for _, msg in ipairs(A333_ewd_msg_cue_L) do

			displayLines = displayLines + 1													-- INCREMENT THE (VISIBLE) LINE COUNTER

			-- Reference and skip the namespace/array lookups
			local lcl_this_ewd_msg = A333_ewd_msg[msg.Name]

			if msg.Ftype == 1 or msg.Ftype == 2 then										-- ONLY PRIMARY OR INDEPENDENT FAILURES ARE CONSIDERED
				itemGroup = lcl_this_ewd_msg.ItemGroup								-- ASSIGN THE ITEM GROUP
				break																		-- WE HAVE FOUND THE ITEM GROUP, END THE SEARCH
			end

			if lcl_this_ewd_msg.MsgLine then											--|
				for i = 1, #lcl_this_ewd_msg.MsgLine do								--|
					if lcl_this_ewd_msg.MsgLine[i].MsgVisible == 1 then				--|
						displayLines = displayLines + 1										--| INCREMENT THE TOTAL # LINES DISPLAYED BASED ON THE VISIBLE ACTION LINES
					end																		--|
				end																			--|
			end																				--|

			if displayLines >= 7 then break end												-- WE ONLY CONSIDER THE FIRST SEVEN LINES IN THE CUE THAT ARE CURRENTLY BEING DISPLAYED

		end




		-- CLEAR PRIMARY & INDEPENDENT FAILURES
		------------------------------------------------------------------------------
		if itemGroup then																	-- A VALID ITEM GROUP OF A PRIMARY OR INDEPENDENT WARNING WAS FOUND

			if not A333_fws_ewd_overflow_symbol() then										-- E/WD MESSAGES ARE NOT OVERFLOWING ZONE 0...

				-- SINCE THERE IS NO OVERFLOW WE CAN CLEAR ALL THE
				-- WARNINGS OF THE CURRENT ITEM GROUP...
				for _, msg in ipairs(A333_ewd_msg_cue_L) do
					-- Reference and skip the namespace/array lookups
					local lcl_this_ewd_msg = A333_ewd_msg[msg.Name]

					if lcl_this_ewd_msg.ItemGroup == itemGroup then					-- CLEAR THE WARNINGS BY ITEM GROUP

						if string.find(lcl_this_ewd_msg.CmdInputs, 'CLR') then		-- THIS MESSAGE HAS 'CLEAR' AUTHORIZATION

							if lcl_this_ewd_msg.Monitor.video.OUT == 1 then
								lcl_this_ewd_msg.Monitor.video.OUT = 2				-- SET THE WARNING TO 'CLEARED'

								for i = 1, #lcl_this_ewd_msg.MsgLine do
									lcl_this_ewd_msg.MsgLine[i].MsgCleared = 0		-- INIT THE MESSAGE ACTION LINES 'CLEARED' FIELD
								end

								if lcl_this_ewd_msg.MasterType == 1 then				-- WARNING
									if lcl_this_ewd_msg.Monitor.audio.IN == 1 then	-- WARNING ALERT IS PLAYING
										lcl_this_ewd_msg.Monitor.audio.OUT = 2		-- SET AUDIO OUT TO CLEARED
										if simDR_plugin_master_warning == 1 then			-- WARNING ANNUNCIATOR IS LIT
											simDR_plugin_master_warning = 0					-- RESET THE ANNUNCIATOR

											-- AFTER EACH CANCEL THERE IS ONE SECOND OF SILENCE.
											masterCancelSilence = true
											if is_timer_scheduled(masterCancelAlertDelay) then
												stop_timer(masterCancelAlertDelay)
											end
											run_after_time(masterCancelAlertDelay, 1.0)
										end
									end

								elseif lcl_this_ewd_msg.MasterType == 2 then			-- CAUTION
									if simDR_plugin_master_caution == 1 then				-- CAUTION ANNUNCIATOR IS LIT
										simDR_plugin_master_caution = 0						-- RESET THE ANNUNCIATOR

										-- AFTER EACH CANCEL THERE IS ONE SECOND OF SILENCE.
										masterCancelSilence = true
										if is_timer_scheduled(masterCancelAlertDelay) then
											stop_timer(masterCancelAlertDelay)
										end
										run_after_time(masterCancelAlertDelay, 1.0)
									end
								end
							end
						end
					end
				end


			elseif A333_fws_ewd_overflow_symbol() then										-- E/WD MESSAGES ARE OVERFLOWING ZONE 0

				-- ONLY ONE ITEM IS DISPLAYED
				if visibleItems == 1 then

					-- ONLY ONE WARNING IS DISPLAYED
					-- WITH OVERFLOW OF THE ACTION LINES
					if visibleWarnings == 1 then

						-- ITEM TITLE HOLDS.
						-- WARNING TITLE HOLDS.
						-- ACTION/PROCEDURE LINES THAT ARE VISIBLE (ALREADY SEEN BY CREW) ARE CLEARED.
						for _, msg in ipairs(A333_ewd_msg_cue_L) do

							-- Reference and skip the namespace/array lookups
							local lcl_this_ewd_msg = A333_ewd_msg[msg.Name]

							if lcl_this_ewd_msg.ItemGroup == itemGroup then

								if string.find(lcl_this_ewd_msg.CmdInputs, 'CLR') then	-- THIS MESSAGE HAS 'CLEAR' AUTHORIZATION

									for i = 1, #lcl_this_ewd_msg.MsgLine do
										if lcl_this_ewd_msg.MsgLine[i].MsgVisible == 1
											and lcl_this_ewd_msg.MsgLine[i].MsgCleared == 0
										then
											lcl_this_ewd_msg.MsgLine[i].MsgCleared = 1
										end
									end

									-- CHECK IF ACTION LINE VISIBILE/CLEARED
									local msgLineVis = false
									for i = 1, #lcl_this_ewd_msg.MsgLine do
										if lcl_this_ewd_msg.MsgLine[i].MsgVisible == 1
											and lcl_this_ewd_msg.MsgLine[i].MsgCleared == 0
										then
											msgLineVis = true
										end
									end

									-- IF ALL ACTION LINES ARE CLEARED THEN CLEAR THE WARNING ITSELF
									if msgLineVis == false then
										if lcl_this_ewd_msg.Monitor.video.OUT == 1 then
											lcl_this_ewd_msg.Monitor.video.OUT = 2
											for i = 1, #lcl_this_ewd_msg.MsgLine do
												lcl_this_ewd_msg.MsgLine[i].MsgCleared = 0		-- INIT THE MESSAGE ACTION LINES
											end
											if lcl_this_ewd_msg.MasterType == 1 then				-- WARNING
												if lcl_this_ewd_msg.Monitor.audio.IN == 1 then	-- WARNING ALERT IS PLAYING
													lcl_this_ewd_msg.Monitor.audio.OUT = 2		-- SET AUDIO OUT TO CLEARED
													if simDR_plugin_master_warning == 1 then			-- WARNING ANNUNCIATOR IS LIT
														simDR_plugin_master_warning = 0					-- RESET THE ANNUNCIATOR
														-- AFTER EACH CANCEL THERE IS ONE SECOND OF SILENCE.
														masterCancelSilence = true
														if is_timer_scheduled(masterCancelAlertDelay) then
															stop_timer(masterCancelAlertDelay)
														end
														run_after_time(masterCancelAlertDelay, 1.0)
													end
												end

											elseif lcl_this_ewd_msg.MasterType == 2 then			-- CAUTION
												if simDR_plugin_master_caution == 1 then				-- CAUTION ANNUNCIATOR IS LIT
													simDR_plugin_master_caution = 0						-- RESET THE ANNUNCIATOR
													-- AFTER EACH CANCEL THERE IS ONE SECOND OF SILENCE.
													masterCancelSilence = true
													if is_timer_scheduled(masterCancelAlertDelay) then
														stop_timer(masterCancelAlertDelay)
													end
													run_after_time(masterCancelAlertDelay, 1.0)
												end
											end
										end
									end
									break  -- ONLY CONSIDER THE FIRST WARNING OF THIS ITEM GROUP

								end
							end
						end



					-- ONLY ONE ITEM IS DISPLAYED (MULTIPLE WARNINGS IN ITEM GROUP ARE VISIBLE)
					elseif visibleWarnings > 1 then

						-- ITEM TITLE HOLDS.
						-- ENTIRE FIRST WARNING (ALL LINES) IS ERASED IF COMPLETELY SEEN BY CREW...
						-- 		NOTE:  SINCE visibleWarnings > 1 THE ENTIRE FIRST WARNING MUST BE VISIBLE SO
						--			   WE SET THE WARNING TO 'CLEARED' AND ALSO INIT THE 'CLEARED' FIELD OF ALL
						--			   MESSAGE LINES OF THAT WARNING.
						for _, msg in ipairs(A333_ewd_msg_cue_L) do
							-- Reference and skip the namespace/array lookups
							local lcl_this_ewd_msg = A333_ewd_msg[msg.Name]

							if lcl_this_ewd_msg.ItemGroup == itemGroup then

								if string.find(lcl_this_ewd_msg.CmdInputs, 'CLR') then		-- THIS MESSAGE HAS 'CLEAR' AUTHORIZATION

									if lcl_this_ewd_msg.Monitor.video.OUT == 1 then
										lcl_this_ewd_msg.Monitor.video.OUT = 2				-- SET THE FIRST WARNING TO 'CLEARED'
										for i = 1, #lcl_this_ewd_msg.MsgLine do
											lcl_this_ewd_msg.MsgLine[i].MsgCleared = 0		-- INIT THE MESSAGE ACTION LINES
										end
										if lcl_this_ewd_msg.MasterType == 1 then				-- WARNING
											if lcl_this_ewd_msg.Monitor.audio.IN == 1 then	-- WARNING ALERT IS PLAYING
												lcl_this_ewd_msg.Monitor.audio.OUT = 2		-- SET AUDIO OUT TO CLEARED
												if simDR_plugin_master_warning == 1 then			-- WARNING ANNUNCIATOR IS LIT
													simDR_plugin_master_warning = 0					-- RESET THE ANNUNCIATOR
													-- AFTER EACH CANCEL THERE IS ONE SECOND OF SILENCE.
													masterCancelSilence = true
													if is_timer_scheduled(masterCancelAlertDelay) then
														stop_timer(masterCancelAlertDelay)
													end
													run_after_time(masterCancelAlertDelay, 1.0)
												end
											end

										elseif lcl_this_ewd_msg.MasterType == 2 then			-- CAUTION
											if simDR_plugin_master_caution == 1 then				-- CAUTION ANNUNCIATOR IS LIT
												simDR_plugin_master_caution = 0						-- RESET THE ANNUNCIATOR
												-- AFTER EACH CANCEL THERE IS ONE SECOND OF SILENCE.
												masterCancelSilence = true
												if is_timer_scheduled(masterCancelAlertDelay) then
													stop_timer(masterCancelAlertDelay)
												end
												run_after_time(masterCancelAlertDelay, 1.0)
											end
										end
										break  -- ONLY CONSIDER THE FIRST WARNING OF THIS ITEM GROUP
									end
								end
							end
						end

						-- THE TITLE OF THE LAST DISPLAYED ITEM GROUP IS TRANSFERRED TO THE RIGHT (ZONE 1) IF AT LEAST ONE		-- TODO: IS THIS ONLY WHEN A CLR IS ISSUED OR AT ALL TIMES ?
						-- WARNING TITLE BELONGING TO THAT GROUP IS NOT DISPLAYED												-- TODO: IS THIS ONLY WHEN A CLR IS ISSUED OR AT ALL TIMES ?

					end



				-- MORE THAN ONE ITEM GROUP IS VISIBLE
				elseif visibleItems > 1 then

					-- THE FIRST ITEM GROUP IS CLEARED
					-- 		NOTE:  SINCE visibleItems > 1 THE ENTIRE FIRST ITEM GROUP MUST BE VISIBLE SO
					--			   WE SET THE WARNING TO 'CLEARED' FOR EVERY WARNING IN THE ITEM GROUP
					--			   AND ALSO INIT THE 'CLEARED' FIELD OF ALL MESSAGE LINES OF THOSE WARNINGS.
					for _, msg in ipairs(A333_ewd_msg_cue_L) do
						-- Reference and skip the namespace/array lookups
						local lcl_this_ewd_msg = A333_ewd_msg[msg.Name]

						if lcl_this_ewd_msg.ItemGroup == itemGroup then

							if string.find(lcl_this_ewd_msg.CmdInputs, 'CLR') then		-- THIS MESSAGE HAS 'CLEAR' AUTHORIZATION

								if lcl_this_ewd_msg.Monitor.video.OUT == 1 then
									lcl_this_ewd_msg.Monitor.video.OUT = 2				-- SET THE WARNING TO 'CLEARED'
									for i = 1, #lcl_this_ewd_msg.MsgLine do
										lcl_this_ewd_msg.MsgLine[i].MsgCleared = 0		-- INIT THE MESSAGE ACTION LINES
									end
									if lcl_this_ewd_msg.MasterType == 1 then				-- WARNING
										if lcl_this_ewd_msg.Monitor.audio.IN == 1 then	-- WARNING ALERT IS PLAYING
											lcl_this_ewd_msg.Monitor.audio.OUT = 2		-- SET AUDIO OUT TO CLEARED
											if simDR_plugin_master_warning == 1 then			-- WARNING ANNUNCIATOR IS LIT
												simDR_plugin_master_warning = 0					-- RESET THE ANNUNCIATOR
												-- AFTER EACH CANCEL THERE IS ONE SECOND OF SILENCE.
												masterCancelSilence = true
												if is_timer_scheduled(masterCancelAlertDelay) then
													stop_timer(masterCancelAlertDelay)
												end
												run_after_time(masterCancelAlertDelay, 1.0)
											end
										end

									elseif lcl_this_ewd_msg.MasterType == 2 then			-- CAUTION
										if simDR_plugin_master_caution == 1 then				-- CAUTION ANNUNCIATOR IS LIT
											simDR_plugin_master_caution = 0						-- RESET THE ANNUNCIATOR
											-- AFTER EACH CANCEL THERE IS ONE SECOND OF SILENCE.
											masterCancelSilence = true
											if is_timer_scheduled(masterCancelAlertDelay) then
												stop_timer(masterCancelAlertDelay)
											end
											run_after_time(masterCancelAlertDelay, 1.0)
										end
									end
								end
							end
						end
					end

					-- THE TITLE OF THE LAST DISPLAYED ITEM GROUP IS TRANSFERRED TO THE RIGHT (ZONE 1) IF AT LEAST ONE		-- TODO: IS THIS ONLY WHEN A CLR IS ISSUED OR AT ALL TIMES ?
					-- WARNING TITLE BELONGING TO THAT GROUP IS NOT DISPLAYED												-- TODO: IS THIS ONLY WHEN A CLR IS ISSUED OR AT ALL TIMES ?

				end
			end
		end


		-- RECHECK FOR ELIGIBLE MESSAGES TO BE CLEARED FROM ZONE 0
		local ewdZone0HasNoMoreMsgsToClear = true
		for _, msg in ipairs(A333_ewd_msg_cue_L) do
			if msg.Ftype == 1 or msg.Ftype == 2 then
				if A333_ewd_msg[msg.Name].Monitor.video.OUT == 1 then
					ewdZone1HasNoMoreMsgsToClear = false
				end
			end
		end

		-- AUTOMATIC DISPLAY OF STATUS PAGE:
		-- OCCURS WHEN ALL WARNINGS HAVE BEEN CLEARED FROM THE EW/D (ZONE 0 AND 1) BY PRESSING THE CLR KEY, UNLESS
		-- THE STATUS ONLY CONTAINS 'CANCELLED CAUTION' AND/OR 'MAINTENTANCE' MESSAGES.
		-- CLR LIGHT REMAINS ON
		-- STS LIGHT COMES ON
		if ewdZone0HasNoMoreMsgsToClear
			and not EWDzone1hasMsgsToClear()
			and SDhasMsgsForAutoShow()
		then
			ZASTSPD = true
		end




	-------------------------------------------------------------------------------
	--|                        CLEAR E/WD ZONE 1 (RIGHT)						|--
	-------------------------------------------------------------------------------
	elseif EWDzone1hasMsgsToClear() then

		local itemGroup2

		-- GET THE ITEM GROUP OF THE FIRST WARNING
		for _, msg in ipairs(A333_ewd_msg_cue_R) do
			if msg.Ftype == 4 then													-- ONLY CLEAR SECONDARY FAILURES
				itemGroup2 = A333_ewd_msg[msg.Name].ItemGroup						-- WITHIN THIS ITEM GROUP
				break																-- WE HAVE FOUND THE ITEM GROUP, END THE SEARCH
			end
		end

		for _, message in pairs(A333_ewd_msg) do
			if message.FailType == 4 then											-- ONLY CLEAR SECONDARY FAILURES
				if message.ItemGroup == itemGroup2 then								-- CLEAR ALL WARNINGS IN THIS ITEM GROUP
					if string.find(A333_ewd_msg[message.Name].CmdInputs, 'CLR') then	-- THIS MESSAGE HAS 'CLEAR' AUTHORIZATION
						if message.Monitor.video.OUT == 1 then
							message.Monitor.video.OUT = 2							-- SET THE WARNING TO 'CLEARED'
						end
					end
				end
			end
		end






		-- RECHECK FOR ELIGIBLE MESSAGES TO BE CLEARED FROM ZONE 1
		local ewdZone1HasNoMoreMsgsToClear = true
		for _, msg in ipairs(A333_ewd_msg_cue_R) do
			if msg.Ftype == 4 then
				if A333_ewd_msg[msg.Name].Monitor.video.OUT == 1 then
					ewdZone1HasNoMoreMsgsToClear = false
				end
			end
		end

		-- AUTOMATIC ACTIVATION OF STATUS PAGE:
		-- OCCURS WHEN ALL WARNINGS HAVE BEEN CLEARED FROM THE EW/D (ZONE 0 AND 1) BY PRESSING THE CLR KEY, UNLESS
		-- THE STATUS ONLY CONTAINS 'CANCELLED CAUTION' AND/OR 'MAINTENTANCE' MESSAGES.
		-- CLR LIGHT REMAINS ON
		-- STS LIGHT COMES ON
		if ewdZone1HasNoMoreMsgsToClear and SDhasMsgsForAutoShow() then
			ZASTSPD = true
		end





	-------------------------------------------------------------------------------
	--|                   CLEAR SD (STATUS) ZONE 0 (LEFT)						|--
	-------------------------------------------------------------------------------
	elseif SDzone0HasMsgsToClear() then

		ClearSDzone0('CLR')



	-------------------------------------------------------------------------------
	--|                   CLEAR SD (STATUS) ZONE 1 (RIGHT)						|--
	-------------------------------------------------------------------------------
	elseif SDzone1HasMsgsToClear() then

		ClearSDzone1('CLR')

	elseif not SDhasMsgsToBeCleared()
		and ZASTSPD
	then
		ZASTSPD = false
	end

end -- END CLR PUSHBUTTON PROCESSING




local function A333_fws_CLR()

    if ZCLRUP then 	-- CLR BUTTON PRESS (PULSE)

        local pb_process_step = A333DR_ecp_pushbutton_process_step

        for i = 0, 20 do
            print(i, pb_process_step[i])
        end

        if pb_process_step[17] == 1 or pb_process_step[20] == 1 then

            WCLR = false
            pb_process_step[17] = 2
            pb_process_step[20] = 2
            A333DR_ecp_pushbutton_process_step = pb_process_step

            A333_ecp_ProcessCLR()

            pb_process_step[17] = 0
            pb_process_step[20] = 0
            A333DR_ecp_pushbutton_process_step = pb_process_step

        end
    end

end




-----| SD OVERFLOW
-----------------------------------------------------------------------------------------
local function sd_zone0_overflow()
	local stsZone0HasOverflow = false
	for _, sts in pairs(A333_sts_msg) do
		if sts.Zone == 0
			and sts.Video.OUT == 1
		then
			for _, msg in ipairs(sts.Msg) do
				if msg.Status == 1
					and msg.Cleared == 0
					and msg.Visible == 0
				then
					stsZone0HasOverflow = true
					break
				end
			end
			if stsZone0HasOverflow then break end
		end
	end
	return stsZone0HasOverflow
end




local function sd_zone1_overflow()
	return #A333_sts_msg_cue_R > 17					-- NOTE: A333_sts_msg_cue_R DOES NOT CURRENTLY INCLUDE MAINTENANCE MESSAGES
end




local function A333_fws_sd_overflow_symbol()
    A333DR_ecam_sd_show_overflow_arrow = (sd_zone0_overflow() or sd_zone1_overflow()) and 1 or 0
end













-----| SD HAS MESSAGES
-----------------------------------------------------------------------------------------
local function SDzone0hasMsgs()
	return #A333_sts_msg_cue_L > 0
end




local function SDzone1hasMsgs()
	return #A333_sts_msg_cue_R > 0
end




local function SDhasMessages()
    return SDzone0hasMsgs() or SDzone1hasMsgs()
end









-----| CLR PUSHBUTTON ANNUNCIATOR
-----------------------------------------------------------------------------------------
local function A333_fws_CLR_annun()

	A333DR_ecp_clr_pushbutton_annun =
		bool2num[(EWDzone0hasMsgsToClear() or EWDzone1hasMsgsToClear() or ZSTSPD) and SDhasMessages()]

end








--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_250()

	A333_fws_CLR()
	A333_fws_sd_overflow_symbol()
	A333_fws_CLR_annun()

end





--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







