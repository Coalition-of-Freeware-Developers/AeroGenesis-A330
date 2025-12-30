--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws810.lua
* Process: FWS Status Display Generic Instrument Processing
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


--print("LOAD: A333.ecam_fws810.lua")

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

--local sts_line_L = 1
--local lastMsgLine = 0
--local lastType = 0

--local sts_line_R = 1



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

function A333_fws_sts_generic_inst_L()

    -- CLEAR THE GENERIC TEXT DATA
    for i = 1, 18 do
        A333DR_ecam_sd_gText_msg_L[i] = ""
        A333DR_ecam_sd_gText_msg_L2[i] = ""
    end

    local empty_row = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

    A333DR_ecam_sd_gfxBW_L01 = empty_row
    A333DR_ecam_sd_gfxBW_L02 = empty_row
    A333DR_ecam_sd_gfxBW_L03 = empty_row
    A333DR_ecam_sd_gfxBW_L04 = empty_row
    A333DR_ecam_sd_gfxBW_L05 = empty_row
    A333DR_ecam_sd_gfxBW_L06 = empty_row
    A333DR_ecam_sd_gfxBW_L07 = empty_row
    A333DR_ecam_sd_gfxBW_L08 = empty_row
    A333DR_ecam_sd_gfxBW_L09 = empty_row
    A333DR_ecam_sd_gfxBW_L10 = empty_row
    A333DR_ecam_sd_gfxBW_L11 = empty_row
    A333DR_ecam_sd_gfxBW_L12 = empty_row
    A333DR_ecam_sd_gfxBW_L13 = empty_row
    A333DR_ecam_sd_gfxBW_L14 = empty_row
    A333DR_ecam_sd_gfxBW_L15 = empty_row
    A333DR_ecam_sd_gfxBW_L16 = empty_row
    A333DR_ecam_sd_gfxBW_L17 = empty_row
    A333DR_ecam_sd_gfxBW_L18 = empty_row


    local sts_text_color_L  = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    local sts_text_color_L2 = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

    -- STATUS PAGE "NORMAL"
    if A333DR_fws_sts_normal_msg_show == 1 then
        A333DR_ecam_sd_gText_msg_L[8] = "              NORMAL    "
        sts_text_color_L[8] = 2
    else
        A333DR_ecam_sd_gText_msg_L[8] = ""
        sts_text_color_L[8] = 0

        
        -- INIT THE MESSAGE LINE VISIBILITY
        for _, msg in pairs(A333_sts_msg) do
            if msg.Zone == 0 then
                for i = 1, #A333_sts_msg[msg.Name].Msg do
                    A333_sts_msg[msg.Name].Msg[i].Visible = 0
                end
            end
        end


        -- ITERATE THE MESSAGE CUE
        local lastType = 0
        local sts_line_L = 0

        for _, sts in ipairs(A333_sts_msg_cue_L) do

            -- SKIP A LINE IF THE 'TYPE' HAS CHANGED
            if sts_line_L > 1                                                               -- DO NOT CONSIDER IF @ FIRST
                and sts_line_L < 18															-- 		OR @ LAST DISPLAY LINE
                and sts.Type ~= lastType  													-- MESSAGE TYPE (DISPLAY SECTION) HAS CHANGED
            then
                sts_line_L = sts_line_L + 1                                            	 	-- INCREMENT THE LINE COUNTER (DISPLAYS A BLANK LINE)
            end
            lastType = sts.Type
            if sts_line_L == 18 then break end


            -- DISPLAY THE LINE DATA
            local lastMsgLine = 0
            for _, msg in ipairs(A333_sts_msg[sts.Name].Msg) do

                if msg.Status == 1
                    and msg.Cleared == 0
                then
                    if msg.Line == lastMsgLine then

                        -- DO NOT INCREMENT THE LINE COUNTER, MESSAGE IS DISPLAYED ON SAME LINE
                        sts_text_color_L2[sts_line_L] = msg.Color
                        A333DR_ecam_sd_gText_msg_L2[sts_line_L] = msg.Text
                        msg.Visible = 1

                    else

                        sts_line_L = sts_line_L + 1											-- INCREMENT THE LINE COUNTER
                        sts_text_color_L[sts_line_L] = msg.Color
                        A333DR_ecam_sd_gText_msg_L[sts_line_L] = msg.Text
                        msg.Visible = 1

                        if msg.Gfx == 1 then
                            msgText = string.gsub(msg.Text, '[ \t]+%f[\r\n%z]', '')

                            local line = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

                            for pos = 1, string.len(msgText) do
                                line[pos] = 1
                            end

                            if sts_line_L == 1 then
                                A333DR_ecam_sd_gfxBW_L01 = line
                            elseif sts_line_L == 2 then
                                A333DR_ecam_sd_gfxBW_L02 = line
                            elseif sts_line_L == 3 then
                                A333DR_ecam_sd_gfxBW_L03 = line
                            elseif sts_line_L == 4 then
                                A333DR_ecam_sd_gfxBW_L04 = line
                            elseif sts_line_L == 5 then
                                A333DR_ecam_sd_gfxBW_L05 = line
                            elseif sts_line_L == 6 then
                                A333DR_ecam_sd_gfxBW_L06 = line
                            elseif sts_line_L == 7 then
                                A333DR_ecam_sd_gfxBW_L07 = line
                            elseif sts_line_L == 8 then
                                A333DR_ecam_sd_gfxBW_L08 = line
                            elseif sts_line_L == 9 then
                                A333DR_ecam_sd_gfxBW_L09 = line
                            elseif sts_line_L == 10 then
                                A333DR_ecam_sd_gfxBW_L10 = line
                            elseif sts_line_L == 11 then
                                A333DR_ecam_sd_gfxBW_L11 = line
                            elseif sts_line_L == 12 then
                                A333DR_ecam_sd_gfxBW_L12 = line
                            elseif sts_line_L == 13 then
                                A333DR_ecam_sd_gfxBW_L13 = line
                            elseif sts_line_L == 14 then
                                A333DR_ecam_sd_gfxBW_L14 = line
                            elseif sts_line_L == 15 then
                                A333DR_ecam_sd_gfxBW_L15 = line
                            elseif sts_line_L == 16 then
                                A333DR_ecam_sd_gfxBW_L16 = line
                            elseif sts_line_L == 17 then
                                A333DR_ecam_sd_gfxBW_L17 = line
                            elseif sts_line_L == 18 then
                                A333DR_ecam_sd_gfxBW_L18 = line
                            end
                        end
                    end
                end
                lastMsgLine = msg.Line
            end
            if sts_line_L == 18 then break end

        end


    end
    A333DR_ecam_sd_gText_color_L  = sts_text_color_L
    A333DR_ecam_sd_gText_color_L2 = sts_text_color_L2

end










function A333_fws_sts_generic_inst_R()

    local sts_line_R = 1

    -- CLEAR THE GENERIC TEXT DATA
    for i = 1, 18 do
        A333DR_ecam_sd_gText_msg_R[i] = ""
    end

    -- CLEAR THE GENERIC ZONE 1 GRAPHICS
    local sd2_gfxBW = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

    -- STATUS PAGE "NORMAL"
    if A333DR_fws_sts_normal_msg_show == 0 then

        local sts_text_color_R = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

        -- INIT THE MESSAGE LINE VISIBILITY
        for _, msg in pairs(A333_sts_msg) do
            if msg.Zone == 1 then
                for i = 1, #A333_sts_msg[msg.Name].Msg do
                    A333_sts_msg[msg.Name].Msg[i].Visible = 0
                end
            end
        end


        -- SET THE ZONE TITLE
        if #A333_sts_msg_cue_R > 0 then
            sts_text_color_R[sts_line_R] = 3
            A333DR_ecam_sd_gText_msg_R[sts_line_R] = '  INOP SYS  '
            for i = 3, 10 do
                sd2_gfxBW[i] = 1
            end
            sts_line_R = sts_line_R + 1
        end


        -- ITERATE THE MESSAGE CUE
        for _, sts in ipairs(A333_sts_msg_cue_R) do

            for _, msg in ipairs(A333_sts_msg[sts.Name].Msg) do

                if msg.Status == 1
                    and msg.Cleared == 0
                then

                    sts_text_color_R[sts_line_R] = msg.Color
                    A333DR_ecam_sd_gText_msg_R[sts_line_R] = msg.Text

                    msg.Visible = 1
                    sts_line_R = sts_line_R + 1
                    if sts_line_R == 19 then break end

                end
            end
            if sts_line_R == 19 then break end

        end

        A333DR_ecam_sd_gText_color_R = sts_text_color_R
    end

    A333DR_ecam_sd2_gfxBW_L01 = sd2_gfxBW
end




















--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_810()

    A333_fws_sts_generic_inst_L()
    A333_fws_sts_generic_inst_R()

end





--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







