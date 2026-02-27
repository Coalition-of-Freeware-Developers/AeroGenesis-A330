--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws510.lua
* Process: FWS Warning Message Cue
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


--print("LOAD: A333.ecam_fws510.lua")

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
local deepTableCopyT = deepTableCopyT
local sort_on_values_ascending = sort_on_values_ascending
local A333_ewd_sort_msg_cue_R = A333_ewd_sort_msg_cue_R
local fwc_has_power = false


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
local function get_fwc_power()
    fwc_has_power = fws_power == 1
end




local function A333_fws_build_msg_cue_L()

	local ewd_msg_cue_L = {}

    if fwc_has_power then

        for _, message in pairs(A333_ewd_msg) do
            if message.Zone == 0 then
                if message.Monitor.video.OUT == 1 then
                    table.insert(ewd_msg_cue_L, {Name = message.Name, Ftype = message.FailType, Level = message.Level, Priority = message.Priority})
                end
            end
        end

        sort_on_values_ascending(ewd_msg_cue_L, 'Priority')

    end

	A333_ewd_msg_cue_L = {}
	A333_ewd_msg_cue_L = deepTableCopyT(ewd_msg_cue_L, seen)

end




local function A333_fws_ewd_left_zone_warning_title_overflow(MsgCueR)

    local lineCounter = 0
    local exclusionTitles = {}
    local priority = 0

    for _, msg in ipairs(A333_ewd_msg_cue_L) do

        if msg.Ftype == 1 or msg.Ftype == 2 then										-- ONLY CONSIDER PRIMARY OR INDEPENDENT FAILURES

            -- Reference and skip the namespace/array lookups
            local lcl_this_ewd_msg = A333_ewd_msg[msg.Name]

            lineCounter = lineCounter + 1

            if lineCounter <= 7 then

                -- BUILD A TABLE OF ITEM TITLES THAT ARE VISIBLE IN THE LEFT CUE
                local AddTitleToTable = true
                for _, title in ipairs(exclusionTitles) do
                    if lcl_this_ewd_msg.ItemTitle == title.name
                        and lcl_this_ewd_msg.TitleColor == title.color
                    then
                        AddTitleToTable = false
                    end
                end
                if AddTitleToTable then
                    table.insert(exclusionTitles, {name = lcl_this_ewd_msg.ItemTitle, color = lcl_this_ewd_msg.TitleColor})
                end

                -- INCREMENT THE LINE COUNTER BASED ON THE VISIBLE ACTION LINES
                if lcl_this_ewd_msg.MsgLine then
                    for i = 1, #lcl_this_ewd_msg.MsgLine do
                        if lcl_this_ewd_msg.MsgLine[i].MsgVisible == 1 then
                            lineCounter = lineCounter + 1
                        end
                    end
                end

            else
                local addTitleToCue = true
                for _, title in ipairs(exclusionTitles) do
                    addTitleToCue = true
                    if lcl_this_ewd_msg.ItemTitle == title.name
                        and lcl_this_ewd_msg.TitleColor == title.color
                    then
                        addTitleToCue = false
                        break
                    end
                end
                if addTitleToCue then
                    table.insert(MsgCueR, {Name = lcl_this_ewd_msg.Name, Ftype = 3, Level = lcl_this_ewd_msg.Level, Priority = priority+1})
                    table.insert(exclusionTitles, {name = lcl_this_ewd_msg.ItemTitle, color = lcl_this_ewd_msg.TitleColor})
                end
            end

        end
    end
end




local function A333_fws_build_msg_cue_R()

    local groupList = {}
	local ewd_msg_cue_R = {}
	local groupNotInCue = true

    if fwc_has_power then

        for _, message in pairs(A333_ewd_msg) do
            if message.Zone == 1 then
                if message.Monitor.video.OUT == 1 then

                    if message.FailType == 4 then
                        groupNotInCue = true
                        for i = 1, #groupList do
                            if message.ItemGroup == groupList[i] then
                                groupNotInCue = false
                            end
                        end
                    end

                    if message.FailType ~= 4
                        or
                        (message.FailType == 4 and groupNotInCue)			-- 'groupNotInCue' PREVENTS INSERTION OF IDENTICAL SECONDARY FAILURE GROUPS INTO CUE
                    then
                        table.insert(ewd_msg_cue_R, {Name = message.Name, Ftype = message.FailType, Level = message.Level, Priority = message.Priority})
                        table.insert(groupList, message.ItemGroup)

                    end
                end
            end
        end

        A333_fws_ewd_left_zone_warning_title_overflow(ewd_msg_cue_R)

        A333_ewd_sort_msg_cue_R(ewd_msg_cue_R, 'Ftype', 'Level', 'Priority')

    end

	A333_ewd_msg_cue_R = {}
	A333_ewd_msg_cue_R = deepTableCopyT(ewd_msg_cue_R, seen)

end





--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_510()

    get_fwc_power()
	A333_fws_build_msg_cue_L()
	A333_fws_build_msg_cue_R()

end




--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







