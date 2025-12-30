--[[
*****************************************************************************************
* Script Name:
*
* Script Description:
*
* Author Name:
*
* Revisions:
* -- DATE --  --- REV NO ---  --- DESCRIPTION -------------------------------------------
*
*
*
*
*
*****************************************************************************************
*       						   COPYRIGHT © 2025 
*					 	    L A M I N A R   R E S E A R C H
*								  ALL RIGHTS RESERVED
*****************************************************************************************
--]]



--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--[[

SIM_PERIOD: this contains the duration of the current frame in seconds (so it is always
a fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you would do fuel = fuel + 3 * SIM_PERIOD.


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
local ewd_line_L = 0
local ewd_line_R = 0
local prevItemGroup = ""


--*************************************************************************************--
--** 				            LOCAL UTILITY FUNCTIONS          			    	 **--
--*************************************************************************************--



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
--** 				  CREATE READ-WRITE CUSTOM DATAREFS & HANDLERS                   **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE CUSTOM COMMANDS & HANDLERS					     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				      X-PLANE 'FILTER' COMMANDS & HANDLERS            			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				       X-PLANE 'WRAP' COMMANDS & HANDLERS               	     **--
--*************************************************************************************--



--*************************************************************************************--
--** 				     X-PLANE 'REPLACE' COMMANDS & HANDLERS              	  	 **--
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
function A333_fws_ewd_zone0_generic_inst()

    --| INITIALIZE |----------------------------------------------------------------------------------------------------
    local lcl_ecam_ewd_gText_msg_L = { "", "", "", "", "", "", "" }     -- WARNING MESSAGE LINE TEXT
    local lcl_ecam_ewd_gText_color_L = { 0, 0, 0, 0, 0, 0, 0 }          -- WARNING MESSAGE LINE COLOR

    local lcl_ecam_ewd_gText_cfgAction_L = { '', '', '', '', '', '' }   -- CONFIG-MEMO ACTIONS TEXT
    local lcl_ecam_ewd_gText_cfgAction_color_L = { 0, 0, 0, 0, 0, 0 }   -- CONFIG-MEMO ACTIONS COLOR


    local empty_row = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

    A333DR_ecam_ewd_gTitle_gfxT_L01 = empty_row
    A333DR_ecam_ewd_gTitle_gfxT_L02 = empty_row
    A333DR_ecam_ewd_gTitle_gfxT_L03 = empty_row
    A333DR_ecam_ewd_gTitle_gfxT_L04 = empty_row
    A333DR_ecam_ewd_gTitle_gfxT_L05 = empty_row
    A333DR_ecam_ewd_gTitle_gfxT_L06 = empty_row
    A333DR_ecam_ewd_gTitle_gfxT_L07 = empty_row

    A333DR_ecam_ewd_gTitle_gfxB_L01 = empty_row
    A333DR_ecam_ewd_gTitle_gfxB_L02 = empty_row
    A333DR_ecam_ewd_gTitle_gfxB_L03 = empty_row
    A333DR_ecam_ewd_gTitle_gfxB_L04 = empty_row
    A333DR_ecam_ewd_gTitle_gfxB_L05 = empty_row
    A333DR_ecam_ewd_gTitle_gfxB_L06 = empty_row
    A333DR_ecam_ewd_gTitle_gfxB_L07 = empty_row

    A333DR_ecam_ewd_gTitle_gfxL_L01 = empty_row
    A333DR_ecam_ewd_gTitle_gfxL_L02 = empty_row
    A333DR_ecam_ewd_gTitle_gfxL_L03 = empty_row
    A333DR_ecam_ewd_gTitle_gfxL_L04 = empty_row
    A333DR_ecam_ewd_gTitle_gfxL_L05 = empty_row
    A333DR_ecam_ewd_gTitle_gfxL_L06 = empty_row
    A333DR_ecam_ewd_gTitle_gfxL_L07 = empty_row

    A333DR_ecam_ewd_gTitle_gfxR_L01 = empty_row
    A333DR_ecam_ewd_gTitle_gfxR_L02 = empty_row
    A333DR_ecam_ewd_gTitle_gfxR_L03 = empty_row
    A333DR_ecam_ewd_gTitle_gfxR_L04 = empty_row
    A333DR_ecam_ewd_gTitle_gfxR_L05 = empty_row
    A333DR_ecam_ewd_gTitle_gfxR_L06 = empty_row
    A333DR_ecam_ewd_gTitle_gfxR_L07 = empty_row


    for _, msg in pairs(A333_ewd_msg) do
        msg.isVisible = false
    end

    prevItemGroup = ""
    ewd_line_L = 0


    --| DISPLAY "NORMAL" MESSAGE WHEN RCL PRESSED AND NO INDEPENDENT/PRIMARY/SECONDARY WARNINGS ARE ACTIVE -------------
    if A333DR_fws_rcl_normal_msg_show == 1 then
        A333DR_ecam_ewd_gText_msg_L[3] = "               NORMAL    "
        A333DR_ecam_ewd_gText_color_L[3] = 2


    --| PROCESS WARNINGS |----------------------------------------------------------------------------------------------
    else

        --| GET MESSAGE CUE DATA
        for _, v in ipairs(A333_ewd_msg_cue_L) do


            --===================================| ITEM & WARNING TITLE(S) TEXT |=======================================--
            local this_ewd_msg = A333_ewd_msg[v.Name]   -- Localize to prevent (expensive) namespace lookups

            local itemTitle = this_ewd_msg.ItemTitle
            local itemTitleLen = string.len(itemTitle)
            local drawItemTitleGraphic = true

            -- Blank the "Item Title" after first line of same "Item Group"
            if this_ewd_msg.ItemGroup == prevItemGroup then
                itemTitle = string.sub("                                      ", 1, itemTitleLen)
                drawItemTitleGraphic = false
            end
            prevItemGroup = this_ewd_msg.ItemGroup


            local warningTitle = this_ewd_msg.WarningTitle
            local warningTitleLen = string.len(warningTitle)
            local title = string.format("%s %s", itemTitle, warningTitle)
            local titleLen = itemTitleLen + warningTitleLen

            if titleLen > 0 then
                ewd_line_L = ewd_line_L + 1
                lcl_ecam_ewd_gText_color_L[ewd_line_L] = this_ewd_msg.TitleColor
                lcl_ecam_ewd_gText_msg_L[ewd_line_L] = title
                this_ewd_msg.isVisible = true
            end


            --=========================================| TITLE GRAPHICS |=============================================--
            local titleT = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
            local titleB = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
            local titleL = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
            local titleR = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }

            local gfxColor = this_ewd_msg.TitleColor + 1


            --| ITEM TITLE
            if itemTitleLen > 0 and drawItemTitleGraphic then

                if this_ewd_msg.ItemGFX == 1 then                   -- Underline
                    for pos = 1, itemTitleLen do
                        titleB[pos] = gfxColor
                    end

                elseif this_ewd_msg.ItemGFX == 2 then               -- Boxed

                    for pos = 1, itemTitleLen do

                        -- LEFT SIDE
                        if pos == 1 then
                            titleL[pos] = gfxColor
                        end

                        -- TOP & BOTTOM
                        titleB[pos] = gfxColor
                        titleT[pos] = gfxColor

                        -- RIGHT SIDE
                        if pos == itemTitleLen then

                            -- TITLE/WARNING BOX CONNECTOR
                            if this_ewd_msg.WarningGFX == 2 then    -- Warning Graphic is Boxed
                                titleB[pos+1] = gfxColor            -- Bottom connector to warning box
                                titleT[pos+1] = gfxColor            -- Top connector to warning box

                            else
                                -- RIGHT SIDE OF TITLE BOX
                                titleR[pos] = gfxColor
                            end

                        end -- Right Side
                    end -- Position Iteration
                end -- Item GFX
            end -- Item Title Len & drawItemTitleGraphic check


            --| WARNING TITLE
            if warningTitleLen > 0 then

                if this_ewd_msg.WarningGFX == 1 then						-- Underline
                    for pos = itemTitleLen + 2, string.len(this_ewd_msg.WarningTitle) do
                        titleB[pos] = gfxColor
                    end

                elseif this_ewd_msg.WarningGFX == 2 then					-- Boxed
                    local left_side = itemTitleLen + 2
                    local right_side = (left_side + string.len(this_ewd_msg.WarningTitle)) - 1
                    for pos = left_side, right_side do

                        -- LEFT SIDE
                        if pos == left_side then
                            if this_ewd_msg.ItemGFX == 2 and drawItemGraphic == false then
                                titleL[pos] = gfxColor

                            elseif this_ewd_msg.ItemGFX < 2 then            -- if the title is boxed, do not display the left side warning box gfx
                                titleL[pos] = gfxColor
                            end
                        end

                        -- TOP & BOTTOM
                        titleB[pos] = gfxColor
                        titleT[pos] = gfxColor

                        -- RIGHT SIDE
                        if pos == right_side then
                            titleR[pos] = gfxColor
                        end

                    end -- Position iteration
                end -- Warning GFX
            end -- Warning Title Length


            --| BULK COPY LOCAL RESULTS INTO DATAREFS
            if ewd_line_L == 1 then
                A333DR_ecam_ewd_gTitle_gfxT_L01 = titleT
                A333DR_ecam_ewd_gTitle_gfxB_L01 = titleB
                A333DR_ecam_ewd_gTitle_gfxL_L01 = titleL
                A333DR_ecam_ewd_gTitle_gfxR_L01 = titleR
            elseif ewd_line_L == 2 then
                A333DR_ecam_ewd_gTitle_gfxT_L02 = titleT
                A333DR_ecam_ewd_gTitle_gfxB_L02 = titleB
                A333DR_ecam_ewd_gTitle_gfxL_L02 = titleL
                A333DR_ecam_ewd_gTitle_gfxR_L02 = titleR
            elseif ewd_line_L == 3 then
                A333DR_ecam_ewd_gTitle_gfxT_L03 = titleT
                A333DR_ecam_ewd_gTitle_gfxB_L03 = titleB
                A333DR_ecam_ewd_gTitle_gfxL_L03 = titleL
                A333DR_ecam_ewd_gTitle_gfxR_L03 = titleR
            elseif ewd_line_L == 4 then
                A333DR_ecam_ewd_gTitle_gfxT_L04 = titleT
                A333DR_ecam_ewd_gTitle_gfxB_L04 = titleB
                A333DR_ecam_ewd_gTitle_gfxL_L04 = titleL
                A333DR_ecam_ewd_gTitle_gfxR_L04 = titleR
            elseif ewd_line_L == 5 then
                A333DR_ecam_ewd_gTitle_gfxT_L05 = titleT
                A333DR_ecam_ewd_gTitle_gfxB_L05 = titleB
                A333DR_ecam_ewd_gTitle_gfxL_L05 = titleL
                A333DR_ecam_ewd_gTitle_gfxR_L05 = titleR
            elseif ewd_line_L == 6 then
                A333DR_ecam_ewd_gTitle_gfxT_L06 = titleT
                A333DR_ecam_ewd_gTitle_gfxB_L06 = titleB
                A333DR_ecam_ewd_gTitle_gfxL_L06 = titleL
                A333DR_ecam_ewd_gTitle_gfxR_L06 = titleR
            elseif ewd_line_L == 7 then
                A333DR_ecam_ewd_gTitle_gfxT_L07 = titleT
                A333DR_ecam_ewd_gTitle_gfxB_L07 = titleB
                A333DR_ecam_ewd_gTitle_gfxL_L07 = titleL
                A333DR_ecam_ewd_gTitle_gfxR_L07 = titleR
            end

            if ewd_line_L == 7 then break end



            --=====================================| ACTION MESSAGE LINES |===========================================--

            --| INITIALIZE
            for i = 1, #this_ewd_msg.MsgLine do
                this_ewd_msg.MsgLine[i].MsgVisible = 0
            end

            --| CONFIG MEMOS
            if this_ewd_msg.FailType == 5 then

                for line, this_ewd_MsgLine in ipairs(this_ewd_msg.MsgLine) do

                    if this_ewd_MsgLine.MsgStatus == 1 then

                        if line == 1 then
                            lcl_ecam_ewd_gText_color_L[ewd_line_L] = this_ewd_MsgLine.MsgColor
                            lcl_ecam_ewd_gText_msg_L[ewd_line_L] = string.format('%s%s', title, string.sub(this_ewd_MsgLine.MsgText, 5, 19))
                        end
                        if line == 2 then
                            lcl_ecam_ewd_gText_cfgAction_color_L[ewd_line_L] = this_ewd_MsgLine.MsgColor
                            lcl_ecam_ewd_gText_cfgAction_L[ewd_line_L] = this_ewd_MsgLine.MsgText
                        end
                        if line == 3 then
                            lcl_ecam_ewd_gText_color_L[ewd_line_L] = this_ewd_MsgLine.MsgColor
                            lcl_ecam_ewd_gText_msg_L[ewd_line_L] = string.format('%s%s', title, string.sub(this_ewd_MsgLine.MsgText, 5, 19))
                        end
                        if line == 4
                            or line == 6
                            or line == 7
                            or line == 9
                            or line == 10
                            or line == 12
                            or line == 13
                            or line == 15
                            or line == 16
                            or line == 18
                        then
                            lcl_ecam_ewd_gText_color_L[ewd_line_L] = this_ewd_MsgLine.MsgColor
                            lcl_ecam_ewd_gText_msg_L[ewd_line_L] = this_ewd_MsgLine.MsgText
                        end
                        if line == 5
                            or line == 8
                            or line == 11
                            or line == 14
                            or line == 17
                        then
                            lcl_ecam_ewd_gText_cfgAction_color_L[ewd_line_L] = this_ewd_MsgLine.MsgColor
                            lcl_ecam_ewd_gText_cfgAction_L[ewd_line_L] = this_ewd_MsgLine.MsgText
                        end
                        if line == 2
                            or line == 3
                            or line == 5
                            or line == 6
                            or line == 8
                            or line == 9
                            or line == 11
                            or line == 12
                            or line == 14
                            or line == 15
                            or line == 17
                            or line == 18
                        then
                            ewd_line_L = ewd_line_L + 1
                        end

                        this_ewd_MsgLine.MsgVisible  = 1

                    end -- Message Line Status Active

                end -- Message line interation


            --| NOT CONFIG-MEMO
            else

                for _, this_ewd_MsgLine in ipairs(this_ewd_msg.MsgLine) do

                    if this_ewd_MsgLine.MsgStatus == 1
                        and this_ewd_MsgLine.MsgCleared == 0
                    then
                        ewd_line_L = ewd_line_L + 1
                        lcl_ecam_ewd_gText_color_L[ewd_line_L] 	= this_ewd_MsgLine.MsgColor
                        lcl_ecam_ewd_gText_msg_L[ewd_line_L]	= this_ewd_MsgLine.MsgText
                        this_ewd_MsgLine.MsgVisible  = 1
                        if ewd_line_L == 7 then break end
                    end

                end
                if ewd_line_L == 7 then break end

            end -- Warning message fail type

        end -- Message Cue L iteration

        A333DR_ecam_ewd_gText_color_L = lcl_ecam_ewd_gText_color_L


    end -- "NORMAL" message check

    A333DR_ecam_ewd_gText_cfgAction_color_L = lcl_ecam_ewd_gText_cfgAction_color_L

    for i = 1, 6 do
        A333DR_ecam_ewd_gText_cfgAction_L[i] = lcl_ecam_ewd_gText_cfgAction_L[i]
    end
    for i = 1, 7 do
        A333DR_ecam_ewd_gText_msg_L[i] = lcl_ecam_ewd_gText_msg_L[i]
    end

end




function A333_fws_ewd_zone1_generic_inst()

    local lcl_ecam_ewd_gText_msg_R = { "", "", "", "", "", "", "" }
    local lcl_ecam_ewd_gText_color_R = { 0, 0, 0, 0, 0, 0, 0 }

    for _, v in ipairs(A333_ewd_msg_cue_R) do

        ewd_line_R = ewd_line_R + 1

        A333_ewd_msg[v.Name].isVisible = true

        lcl_ecam_ewd_gText_color_R[ewd_line_R] = A333_ewd_msg[v.Name].TitleColor
        lcl_ecam_ewd_gText_msg_R[ewd_line_R] = A333_ewd_msg[v.Name].ItemTitle

        if ewd_line_R == 7 then break end

    end

    A333DR_ecam_ewd_gText_color_R = lcl_ecam_ewd_gText_color_R
    for i = 1, 7 do
        A333DR_ecam_ewd_gText_msg_R[i] = lcl_ecam_ewd_gText_msg_R[i]
    end

    ewd_line_R = 0

end







--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--


















--===| FLIGHT START COLD & DARK |========================================================
-- function XXX_flight_start_CD() end



--===| FLIGHT START ENGINES RUNNING |====================================================
-- function XXX_flight_start_ER() end



--===| DEFERRED INITIALIZATION |=========================================================
--function XXX_deferred_init() end



--===| DEFERRED PROCESSING |=============================================================
--function XXX_deferred_processing() end



--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--

--===| AIRCRAFT LOAD |===================================================================
--function aircraft_load() end



--=== FLIGHT START ======================================================================
function A333_fws_800_flight_start()

    A333DR_ecam_ewd_show_sts = 0

end



--===| BEFORE PHYSICS |==================================================================
-- function before_physics() end



--=== AFTER PHYSICS =====================================================================
function A333_fws_800()

    A333_fws_ewd_zone0_generic_inst()
    A333_fws_ewd_zone1_generic_inst()

end



--===| AFTER REPLAY |====================================================================
-- function after_replay() end



--===| FLIGHT CRASH |====================================================================
-- function flight_crash() end



--===| AIRCRAFT UNLOAD |=================================================================
-- function aircraft_unload() end




--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







