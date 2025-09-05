--[[
*****************************************************************************************
* Script Name : A333.ecam_fws800.lua
* Process: FWS E/WD Generlc Instrument Processing
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


--print("LOAD: A333.ecam_fws800.lua")

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

local ewd_line_L = 0
local ewd_line_R = 0
local prevItemGroup = ""




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

function A333_fws_ewd_generic_inst_L()

	-- CLEAR THE GENERIC TEXT DATA
	for i = 1, 7 do
		A333DR_ecam_ewd_gText_msg_L[i] = ""
	end

	for i = 1, 24 do
		A333DR_ecam_ewd_gTitle_gfxTR_L01[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTR_L02[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTR_L03[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTR_L04[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTR_L05[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTR_L06[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTR_L07[i] = 0

		A333DR_ecam_ewd_gTitle_gfxBR_L01[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBR_L02[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBR_L03[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBR_L04[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBR_L05[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBR_L06[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBR_L07[i] = 0

		A333DR_ecam_ewd_gTitle_gfxLR_L01[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLR_L02[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLR_L03[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLR_L04[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLR_L05[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLR_L06[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLR_L07[i] = 0

		A333DR_ecam_ewd_gTitle_gfxRR_L01[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRR_L02[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRR_L03[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRR_L04[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRR_L05[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRR_L06[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRR_L07[i] = 0


		A333DR_ecam_ewd_gTitle_gfxTA_L01[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTA_L02[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTA_L03[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTA_L04[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTA_L05[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTA_L06[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTA_L07[i] = 0

		A333DR_ecam_ewd_gTitle_gfxBA_L01[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBA_L02[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBA_L03[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBA_L04[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBA_L05[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBA_L06[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBA_L07[i] = 0

		A333DR_ecam_ewd_gTitle_gfxLA_L01[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLA_L02[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLA_L03[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLA_L04[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLA_L05[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLA_L06[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLA_L07[i] = 0

		A333DR_ecam_ewd_gTitle_gfxRA_L01[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRA_L02[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRA_L03[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRA_L04[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRA_L05[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRA_L06[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRA_L07[i] = 0


		A333DR_ecam_ewd_gTitle_gfxTG_L01[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTG_L02[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTG_L03[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTG_L04[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTG_L05[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTG_L06[i] = 0
		A333DR_ecam_ewd_gTitle_gfxTG_L07[i] = 0

		A333DR_ecam_ewd_gTitle_gfxBG_L01[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBG_L02[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBG_L03[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBG_L04[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBG_L05[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBG_L06[i] = 0
		A333DR_ecam_ewd_gTitle_gfxBG_L07[i] = 0

		A333DR_ecam_ewd_gTitle_gfxLG_L01[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLG_L02[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLG_L03[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLG_L04[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLG_L05[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLG_L06[i] = 0
		A333DR_ecam_ewd_gTitle_gfxLG_L07[i] = 0

		A333DR_ecam_ewd_gTitle_gfxRG_L01[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRG_L02[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRG_L03[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRG_L04[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRG_L05[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRG_L06[i] = 0
		A333DR_ecam_ewd_gTitle_gfxRG_L07[i] = 0



		A333DR_ecam_ewd_gWarn_gfxTR_L01[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTR_L02[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTR_L03[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTR_L04[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTR_L05[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTR_L06[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTR_L07[i] = 0

		A333DR_ecam_ewd_gWarn_gfxBR_L01[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBR_L02[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBR_L03[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBR_L04[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBR_L05[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBR_L06[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBR_L07[i] = 0

		A333DR_ecam_ewd_gWarn_gfxLR_L01[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLR_L02[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLR_L03[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLR_L04[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLR_L05[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLR_L06[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLR_L07[i] = 0

		A333DR_ecam_ewd_gWarn_gfxRR_L01[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRR_L02[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRR_L03[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRR_L04[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRR_L05[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRR_L06[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRR_L07[i] = 0


		A333DR_ecam_ewd_gWarn_gfxTA_L01[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTA_L02[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTA_L03[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTA_L04[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTA_L05[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTA_L06[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTA_L07[i] = 0

		A333DR_ecam_ewd_gWarn_gfxBA_L01[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBA_L02[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBA_L03[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBA_L04[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBA_L05[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBA_L06[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBA_L07[i] = 0

		A333DR_ecam_ewd_gWarn_gfxLA_L01[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLA_L02[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLA_L03[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLA_L04[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLA_L05[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLA_L06[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLA_L07[i] = 0

		A333DR_ecam_ewd_gWarn_gfxRA_L01[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRA_L02[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRA_L03[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRA_L04[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRA_L05[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRA_L06[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRA_L07[i] = 0


		A333DR_ecam_ewd_gWarn_gfxTG_L01[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTG_L02[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTG_L03[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTG_L04[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTG_L05[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTG_L06[i] = 0
		A333DR_ecam_ewd_gWarn_gfxTG_L07[i] = 0

		A333DR_ecam_ewd_gWarn_gfxBG_L01[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBG_L02[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBG_L03[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBG_L04[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBG_L05[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBG_L06[i] = 0
		A333DR_ecam_ewd_gWarn_gfxBG_L07[i] = 0

		A333DR_ecam_ewd_gWarn_gfxLG_L01[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLG_L02[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLG_L03[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLG_L04[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLG_L05[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLG_L06[i] = 0
		A333DR_ecam_ewd_gWarn_gfxLG_L07[i] = 0

		A333DR_ecam_ewd_gWarn_gfxRG_L01[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRG_L02[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRG_L03[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRG_L04[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRG_L05[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRG_L06[i] = 0
		A333DR_ecam_ewd_gWarn_gfxRG_L07[i] = 0

	end

	-- INIT THE CONFIG-MEMO GEN INSTRUMENT DATAREFS
	for i = 1, 6 do
		A333DR_ecam_ewd_gText_cfgAction_color_L[i] = 0
		A333DR_ecam_ewd_gText_cfgAction_L[i] = ''
	end


	-- RCL 'NORMAL' MESSAGE (PRIORITIZED OVER CONFIG MEMOS AND MEMOS)
	if A333DR_fws_rcl_normal_msg_show == 1 then
		A333DR_ecam_ewd_gText_msg_L[3] = "               NORMAL    "
		A333DR_ecam_ewd_gText_color_L[3] = 2
	else

		-- INIT THE MSG VISIBILITY
		for _, msg in pairs(A333_ewd_msg) do
			msg.isVisible = false
		end

		prevItemGroup = ""
		for _, v in ipairs(A333_ewd_msg_cue_L) do


			--=========================|  T I T L E  |=========================
			ewd_line_L = ewd_line_L + 1

			local itemTitle = A333_ewd_msg[v.Name].ItemTitle
			local itemTitleLen = string.len(itemTitle)
			local drawItemGraphic = true
			if A333_ewd_msg[v.Name].ItemGroup == prevItemGroup then										-- SAME ITEM GROUP
				itemTitle = string.sub("                                      ", 1, itemTitleLen)		-- BLANK OUT ITEM TITLE
				drawItemGraphic = false																	-- SINCE ITEM TITLE IS BLANK, SKIP GFX
			end
			local title = string.format("%s %s", itemTitle, A333_ewd_msg[v.Name].WarningTitle)
			prevItemGroup = A333_ewd_msg[v.Name].ItemGroup

			A333DR_ecam_ewd_gText_color_L[ewd_line_L] 	= A333_ewd_msg[v.Name].TitleColor
			A333DR_ecam_ewd_gText_msg_L[ewd_line_L] 	= title
			A333_ewd_msg[v.Name].isVisible = true


			--===================|  I T E M   G R A P H I C  |==================
			if drawItemGraphic then

				if A333_ewd_msg[v.Name].ItemGFX == 1 then								-- UNDERLINE
					for pos = 1, string.len(A333_ewd_msg[v.Name].ItemTitle) do

						-- RED
						if A333_ewd_msg[v.Name].TitleColor == 0 then
							if ewd_line_L == 1 then
								A333DR_ecam_ewd_gTitle_gfxBR_L01[pos] = 1
							elseif ewd_line_L == 2 then
								A333DR_ecam_ewd_gTitle_gfxBR_L02[pos] = 1
							elseif ewd_line_L == 3 then
								A333DR_ecam_ewd_gTitle_gfxBR_L03[pos] = 1
							elseif ewd_line_L == 4 then
								A333DR_ecam_ewd_gTitle_gfxBR_L04[pos] = 1
							elseif ewd_line_L == 5 then
								A333DR_ecam_ewd_gTitle_gfxBR_L05[pos] = 1
							elseif ewd_line_L == 6 then
								A333DR_ecam_ewd_gTitle_gfxBR_L06[pos] = 1
							elseif ewd_line_L == 7 then
								A333DR_ecam_ewd_gTitle_gfxBR_L07[pos] = 1
							end

							-- AMBER
						elseif A333_ewd_msg[v.Name].TitleColor == 1 then
							if ewd_line_L == 1 then
								A333DR_ecam_ewd_gTitle_gfxBA_L01[pos] = 1
							elseif ewd_line_L == 2 then
								A333DR_ecam_ewd_gTitle_gfxBA_L02[pos] = 1
							elseif ewd_line_L == 3 then
								A333DR_ecam_ewd_gTitle_gfxBA_L03[pos] = 1
							elseif ewd_line_L == 4 then
								A333DR_ecam_ewd_gTitle_gfxBA_L04[pos] = 1
							elseif ewd_line_L == 5 then
								A333DR_ecam_ewd_gTitle_gfxBA_L05[pos] = 1
							elseif ewd_line_L == 6 then
								A333DR_ecam_ewd_gTitle_gfxBA_L06[pos] = 1
							elseif ewd_line_L == 7 then
								A333DR_ecam_ewd_gTitle_gfxBA_L07[pos] = 1
							end

							-- GREEN
						elseif A333_ewd_msg[v.Name].TitleColor == 2 then
							if ewd_line_L == 1 then
								A333DR_ecam_ewd_gTitle_gfxBG_L01[pos] = 1
							elseif ewd_line_L == 2 then
								A333DR_ecam_ewd_gTitle_gfxBG_L02[pos] = 1
							elseif ewd_line_L == 3 then
								A333DR_ecam_ewd_gTitle_gfxBG_L03[pos] = 1
							elseif ewd_line_L == 4 then
								A333DR_ecam_ewd_gTitle_gfxBG_L04[pos] = 1
							elseif ewd_line_L == 5 then
								A333DR_ecam_ewd_gTitle_gfxBG_L05[pos] = 1
							elseif ewd_line_L == 6 then
								A333DR_ecam_ewd_gTitle_gfxBG_L06[pos] = 1
							elseif ewd_line_L == 7 then
								A333DR_ecam_ewd_gTitle_gfxBG_L07[pos] = 1
							end

						end
					end


				elseif A333_ewd_msg[v.Name].ItemGFX == 2 then							-- BOXED
					for pos = 1, string.len(A333_ewd_msg[v.Name].ItemTitle) do

						-----| RED
						if A333_ewd_msg[v.Name].TitleColor == 0 then

							-- LEFT SIDE
							if pos == 1 then
								if ewd_line_L == 1 then
									A333DR_ecam_ewd_gTitle_gfxLR_L01[pos] = 1
								elseif ewd_line_L == 2 then
									A333DR_ecam_ewd_gTitle_gfxLR_L02[pos] = 1
								elseif ewd_line_L == 3 then
									A333DR_ecam_ewd_gTitle_gfxLR_L03[pos] = 1
								elseif ewd_line_L == 4 then
									A333DR_ecam_ewd_gTitle_gfxLR_L04[pos] = 1
								elseif ewd_line_L == 5 then
									A333DR_ecam_ewd_gTitle_gfxLR_L05[pos] = 1
								elseif ewd_line_L == 6 then
									A333DR_ecam_ewd_gTitle_gfxLR_L06[pos] = 1
								elseif ewd_line_L == 7 then
									A333DR_ecam_ewd_gTitle_gfxLR_L07[pos] = 1
								end
							end

							-- TOP & BOTTOM
							if ewd_line_L == 1 then
								A333DR_ecam_ewd_gTitle_gfxBR_L01[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTR_L01[pos] = 1
							elseif ewd_line_L == 2 then
								A333DR_ecam_ewd_gTitle_gfxBR_L02[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTR_L02[pos] = 1
							elseif ewd_line_L == 3 then
								A333DR_ecam_ewd_gTitle_gfxBR_L03[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTR_L03[pos] = 1
							elseif ewd_line_L == 4 then
								A333DR_ecam_ewd_gTitle_gfxBR_L04[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTR_L04[pos] = 1
							elseif ewd_line_L == 5 then
								A333DR_ecam_ewd_gTitle_gfxBR_L05[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTR_L05[pos] = 1
							elseif ewd_line_L == 6 then
								A333DR_ecam_ewd_gTitle_gfxBR_L06[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTR_L06[pos] = 1
							elseif ewd_line_L == 7 then
								A333DR_ecam_ewd_gTitle_gfxBR_L07[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTR_L07[pos] = 1
							end

							-- RIGHT SIDE
							if pos == (string.len(A333_ewd_msg[v.Name].ItemTitle)) then

								if A333_ewd_msg[v.Name].WarningGFX == 2 and drawItemGraphic then
									-- TOP & BOTTOM CONNECTOR TO WARNING BOX
									if ewd_line_L == 1 then
										A333DR_ecam_ewd_gTitle_gfxBR_L01[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTR_L01[pos+1] = 1
									elseif ewd_line_L == 2 then
										A333DR_ecam_ewd_gTitle_gfxBR_L02[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTR_L02[pos+1] = 1
									elseif ewd_line_L == 3 then
										A333DR_ecam_ewd_gTitle_gfxBR_L03[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTR_L03[pos+1] = 1
									elseif ewd_line_L == 4 then
										A333DR_ecam_ewd_gTitle_gfxBR_L04[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTR_L04[pos+1] = 1
									elseif ewd_line_L == 5 then
										A333DR_ecam_ewd_gTitle_gfxBR_L05[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTR_L05[pos+1] = 1
									elseif ewd_line_L == 6 then
										A333DR_ecam_ewd_gTitle_gfxBR_L06[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTR_L06[pos+1] = 1
									elseif ewd_line_L == 7 then
										A333DR_ecam_ewd_gTitle_gfxBR_L07[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTR_L07[pos+1] = 1
									end

								else
									-- RIGHT SIDE OF TITLE BOX
									if ewd_line_L == 1 then
										A333DR_ecam_ewd_gTitle_gfxRR_L01[pos] = 1
									elseif ewd_line_L == 2 then
										A333DR_ecam_ewd_gTitle_gfxRR_L02[pos] = 1
									elseif ewd_line_L == 3 then
										A333DR_ecam_ewd_gTitle_gfxRR_L03[pos] = 1
									elseif ewd_line_L == 4 then
										A333DR_ecam_ewd_gTitle_gfxRR_L04[pos] = 1
									elseif ewd_line_L == 5 then
										A333DR_ecam_ewd_gTitle_gfxRR_L05[pos] = 1
									elseif ewd_line_L == 6 then
										A333DR_ecam_ewd_gTitle_gfxRR_L06[pos] = 1
									elseif ewd_line_L == 7 then
										A333DR_ecam_ewd_gTitle_gfxRR_L07[pos] = 1
									end
								end
							end

							-----| AMBER
						elseif A333_ewd_msg[v.Name].TitleColor == 1 then

							-- LEFT SIDE
							if pos == 1 then
								if ewd_line_L == 1 then
									A333DR_ecam_ewd_gTitle_gfxLA_L01[pos] = 1
								elseif ewd_line_L == 2 then
									A333DR_ecam_ewd_gTitle_gfxLA_L02[pos] = 1
								elseif ewd_line_L == 3 then
									A333DR_ecam_ewd_gTitle_gfxLA_L03[pos] = 1
								elseif ewd_line_L == 4 then
									A333DR_ecam_ewd_gTitle_gfxLA_L04[pos] = 1
								elseif ewd_line_L == 5 then
									A333DR_ecam_ewd_gTitle_gfxLA_L05[pos] = 1
								elseif ewd_line_L == 6 then
									A333DR_ecam_ewd_gTitle_gfxLA_L06[pos] = 1
								elseif ewd_line_L == 7 then
									A333DR_ecam_ewd_gTitle_gfxLA_L07[pos] = 1
								end
							end

							-- TOP & BOTTOM
							if ewd_line_L == 1 then
								A333DR_ecam_ewd_gTitle_gfxBA_L01[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTA_L01[pos] = 1
							elseif ewd_line_L == 2 then
								A333DR_ecam_ewd_gTitle_gfxBA_L02[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTA_L02[pos] = 1
							elseif ewd_line_L == 3 then
								A333DR_ecam_ewd_gTitle_gfxBA_L03[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTA_L03[pos] = 1
							elseif ewd_line_L == 4 then
								A333DR_ecam_ewd_gTitle_gfxBA_L04[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTA_L04[pos] = 1
							elseif ewd_line_L == 5 then
								A333DR_ecam_ewd_gTitle_gfxBA_L05[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTA_L05[pos] = 1
							elseif ewd_line_L == 6 then
								A333DR_ecam_ewd_gTitle_gfxBA_L06[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTA_L06[pos] = 1
							elseif ewd_line_L == 7 then
								A333DR_ecam_ewd_gTitle_gfxBA_L07[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTA_L07[pos] = 1
							end

							-- RIGHT SIDE
							if pos == (string.len(A333_ewd_msg[v.Name].ItemTitle)) then

								if A333_ewd_msg[v.Name].WarningGFX == 2 and drawItemGraphic then
									-- TOP & BOTTOM CONNECTOR TO WARNING BOX
									if ewd_line_L == 1 then
										A333DR_ecam_ewd_gTitle_gfxBA_L01[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTA_L01[pos+1] = 1
									elseif ewd_line_L == 2 then
										A333DR_ecam_ewd_gTitle_gfxBA_L02[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTA_L02[pos+1] = 1
									elseif ewd_line_L == 3 then
										A333DR_ecam_ewd_gTitle_gfxBA_L03[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTA_L03[pos+1] = 1
									elseif ewd_line_L == 4 then
										A333DR_ecam_ewd_gTitle_gfxBA_L04[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTA_L04[pos+1] = 1
									elseif ewd_line_L == 5 then
										A333DR_ecam_ewd_gTitle_gfxBA_L05[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTA_L05[pos+1] = 1
									elseif ewd_line_L == 6 then
										A333DR_ecam_ewd_gTitle_gfxBA_L06[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTA_L06[pos+1] = 1
									elseif ewd_line_L == 7 then
										A333DR_ecam_ewd_gTitle_gfxBA_L07[pos+1] = 1
										A333DR_ecam_ewd_gTitle_gfxTA_L07[pos+1] = 1
									end

								else
									-- RIGHT SIDE OF TITLE BOX
									if ewd_line_L == 1 then
										A333DR_ecam_ewd_gTitle_gfxRA_L01[pos] = 1
									elseif ewd_line_L == 2 then
										A333DR_ecam_ewd_gTitle_gfxRA_L02[pos] = 1
									elseif ewd_line_L == 3 then
										A333DR_ecam_ewd_gTitle_gfxRA_L03[pos] = 1
									elseif ewd_line_L == 4 then
										A333DR_ecam_ewd_gTitle_gfxRA_L04[pos] = 1
									elseif ewd_line_L == 5 then
										A333DR_ecam_ewd_gTitle_gfxRA_L05[pos] = 1
									elseif ewd_line_L == 6 then
										A333DR_ecam_ewd_gTitle_gfxRA_L06[pos] = 1
									elseif ewd_line_L == 7 then
										A333DR_ecam_ewd_gTitle_gfxRA_L07[pos] = 1
									end
								end
							end


							-----| GREEN
						elseif A333_ewd_msg[v.Name].TitleColor == 2 then

							-- LEFT SIDE
							if pos == 1 then
								if ewd_line_L == 1 then
									A333DR_ecam_ewd_gTitle_gfxLG_L01[pos] = 1
								elseif ewd_line_L == 2 then
									A333DR_ecam_ewd_gTitle_gfxLG_L02[pos] = 1
								elseif ewd_line_L == 3 then
									A333DR_ecam_ewd_gTitle_gfxLG_L03[pos] = 1
								elseif ewd_line_L == 4 then
									A333DR_ecam_ewd_gTitle_gfxLG_L04[pos] = 1
								elseif ewd_line_L == 5 then
									A333DR_ecam_ewd_gTitle_gfxLG_L05[pos] = 1
								elseif ewd_line_L == 6 then
									A333DR_ecam_ewd_gTitle_gfxLG_L06[pos] = 1
								elseif ewd_line_L == 7 then
									A333DR_ecam_ewd_gTitle_gfxLG_L07[pos] = 1
								end
							end

							-- TOP & BOTTOM
							if ewd_line_L == 1 then
								A333DR_ecam_ewd_gTitle_gfxBG_L01[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTG_L01[pos] = 1
							elseif ewd_line_L == 2 then
								A333DR_ecam_ewd_gTitle_gfxBG_L02[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTG_L02[pos] = 1
							elseif ewd_line_L == 3 then
								A333DR_ecam_ewd_gTitle_gfxBG_L03[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTG_L03[pos] = 1
							elseif ewd_line_L == 4 then
								A333DR_ecam_ewd_gTitle_gfxBG_L04[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTG_L04[pos] = 1
							elseif ewd_line_L == 5 then
								A333DR_ecam_ewd_gTitle_gfxBG_L05[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTG_L05[pos] = 1
							elseif ewd_line_L == 6 then
								A333DR_ecam_ewd_gTitle_gfxBG_L06[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTG_L06[pos] = 1
							elseif ewd_line_L == 7 then
								A333DR_ecam_ewd_gTitle_gfxBG_L07[pos] = 1
								A333DR_ecam_ewd_gTitle_gfxTG_L07[pos] = 1
							end

							-- RIGHT SIDE
							if pos == (string.len(A333_ewd_msg[v.Name].ItemTitle)) then
								if A333_ewd_msg[v.Name].WarningGFX < 2 and drawItemGraphic then -- DO NOT CLOSE THE RIGHT SIDE GRAPHIC IF THE WARNING IS BOXED
									if ewd_line_L == 1 then
										A333DR_ecam_ewd_gTitle_gfxRG_L01[pos] = 1
									elseif ewd_line_L == 2 then
										A333DR_ecam_ewd_gTitle_gfxRG_L02[pos] = 1
									elseif ewd_line_L == 3 then
										A333DR_ecam_ewd_gTitle_gfxRG_L03[pos] = 1
									elseif ewd_line_L == 4 then
										A333DR_ecam_ewd_gTitle_gfxRG_L04[pos] = 1
									elseif ewd_line_L == 5 then
										A333DR_ecam_ewd_gTitle_gfxRG_L05[pos] = 1
									elseif ewd_line_L == 6 then
										A333DR_ecam_ewd_gTitle_gfxRG_L06[pos] = 1
									elseif ewd_line_L == 7 then
										A333DR_ecam_ewd_gTitle_gfxRG_L07[pos] = 1
									end
								end
							end

						end

					end--]]

				end

			end




			--=========================|  W A R N I N G   G R A P H I C  |=========================

			if A333_ewd_msg[v.Name].WarningGFX == 1 then							-- UNDERLINE
				for pos = string.len(A333_ewd_msg[v.Name].ItemTitle) + 2, string.len(A333_ewd_msg[v.Name].WarningTitle) do

					-- RED
					if A333_ewd_msg[v.Name].TitleColor == 0 then
						if ewd_line_L == 1 then
							A333DR_ecam_ewd_gWarn_gfxBR_L01[pos] = 1
						elseif ewd_line_L == 2 then
							A333DR_ecam_ewd_gWarn_gfxBR_L02[pos] = 1
						elseif ewd_line_L == 3 then
							A333DR_ecam_ewd_gWarn_gfxBR_L03[pos] = 1
						elseif ewd_line_L == 4 then
							A333DR_ecam_ewd_gWarn_gfxBR_L04[pos] = 1
						elseif ewd_line_L == 5 then
							A333DR_ecam_ewd_gWarn_gfxBR_L05[pos] = 1
						elseif ewd_line_L == 6 then
							A333DR_ecam_ewd_gWarn_gfxBR_L06[pos] = 1
						elseif ewd_line_L == 7 then
							A333DR_ecam_ewd_gWarn_gfxBR_L07[pos] = 1
						end

						--AMBER
					elseif A333_ewd_msg[v.Name].TitleColor == 1 then
						if ewd_line_L == 1 then
							A333DR_ecam_ewd_gWarn_gfxBA_L01[pos] = 1
						elseif ewd_line_L == 2 then
							A333DR_ecam_ewd_gWarn_gfxBA_L02[pos] = 1
						elseif ewd_line_L == 3 then
							A333DR_ecam_ewd_gWarn_gfxBA_L03[pos] = 1
						elseif ewd_line_L == 4 then
							A333DR_ecam_ewd_gWarn_gfxBA_L04[pos] = 1
						elseif ewd_line_L == 5 then
							A333DR_ecam_ewd_gWarn_gfxBA_L05[pos] = 1
						elseif ewd_line_L == 6 then
							A333DR_ecam_ewd_gWarn_gfxBA_L06[pos] = 1
						elseif ewd_line_L == 7 then
							A333DR_ecam_ewd_gWarn_gfxBA_L07[pos] = 1
						end

						--GREEN
					elseif A333_ewd_msg[v.Name].TitleColor == 2 then
						if ewd_line_L == 1 then
							A333DR_ecam_ewd_gWarn_gfxBG_L01[pos] = 1
						elseif ewd_line_L == 2 then
							A333DR_ecam_ewd_gWarn_gfxBG_L02[pos] = 1
						elseif ewd_line_L == 3 then
							A333DR_ecam_ewd_gWarn_gfxBG_L03[pos] = 1
						elseif ewd_line_L == 4 then
							A333DR_ecam_ewd_gWarn_gfxBG_L04[pos] = 1
						elseif ewd_line_L == 5 then
							A333DR_ecam_ewd_gWarn_gfxBG_L05[pos] = 1
						elseif ewd_line_L == 6 then
							A333DR_ecam_ewd_gWarn_gfxBG_L06[pos] = 1
						elseif ewd_line_L == 7 then
							A333DR_ecam_ewd_gWarn_gfxBG_L07[pos] = 1
						end

					end

				end


			elseif A333_ewd_msg[v.Name].WarningGFX == 2 then						-- BOXED
				local left_side = string.len(A333_ewd_msg[v.Name].ItemTitle) + 2
				local right_side = (left_side + string.len(A333_ewd_msg[v.Name].WarningTitle)) - 1
				for pos = left_side, right_side do

					--| RED
					if A333_ewd_msg[v.Name].TitleColor == 0 then

						-- LEFT SIDE
						if pos == left_side then
							if A333_ewd_msg[v.Name].ItemGFX == 2 and drawItemGraphic == false then
								if ewd_line_L == 1 then
									A333DR_ecam_ewd_gTitle_gfxLR_L01[pos] = 1
								elseif ewd_line_L == 2 then
									A333DR_ecam_ewd_gTitle_gfxLR_L02[pos] = 1
								elseif ewd_line_L == 3 then
									A333DR_ecam_ewd_gTitle_gfxLR_L03[pos] = 1
								elseif ewd_line_L == 4 then
									A333DR_ecam_ewd_gTitle_gfxLR_L04[pos] = 1
								elseif ewd_line_L == 5 then
									A333DR_ecam_ewd_gTitle_gfxLR_L05[pos] = 1
								elseif ewd_line_L == 6 then
									A333DR_ecam_ewd_gTitle_gfxLR_L06[pos] = 1
								elseif ewd_line_L == 7 then
									A333DR_ecam_ewd_gTitle_gfxLR_L07[pos] = 1
								end

							elseif A333_ewd_msg[v.Name].ItemGFX < 2 then -- DO NOT INCLUDE THE LEFT SIDE WARNING BOX GRAPHIC IF THE TITLE IS BOXED
								if ewd_line_L == 1 then
									A333DR_ecam_ewd_gTitle_gfxLR_L01[pos] = 1
								elseif ewd_line_L == 2 then
									A333DR_ecam_ewd_gTitle_gfxLR_L02[pos] = 1
								elseif ewd_line_L == 3 then
									A333DR_ecam_ewd_gTitle_gfxLR_L03[pos] = 1
								elseif ewd_line_L == 4 then
									A333DR_ecam_ewd_gTitle_gfxLR_L04[pos] = 1
								elseif ewd_line_L == 5 then
									A333DR_ecam_ewd_gTitle_gfxLR_L05[pos] = 1
								elseif ewd_line_L == 6 then
									A333DR_ecam_ewd_gTitle_gfxLR_L06[pos] = 1
								elseif ewd_line_L == 7 then
									A333DR_ecam_ewd_gTitle_gfxLR_L07[pos] = 1
								end
							end
						end

						-- TOP & BOTTOM
						if ewd_line_L == 1 then
							A333DR_ecam_ewd_gTitle_gfxBR_L01[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTR_L01[pos] = 1
						elseif ewd_line_L == 2 then
							A333DR_ecam_ewd_gTitle_gfxBR_L02[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTR_L02[pos] = 1
						elseif ewd_line_L == 3 then
							A333DR_ecam_ewd_gTitle_gfxBR_L03[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTR_L03[pos] = 1
						elseif ewd_line_L == 4 then
							A333DR_ecam_ewd_gTitle_gfxBR_L04[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTR_L04[pos] = 1
						elseif ewd_line_L == 5 then
							A333DR_ecam_ewd_gTitle_gfxBR_L05[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTR_L05[pos] = 1
						elseif ewd_line_L == 6 then
							A333DR_ecam_ewd_gTitle_gfxBR_L06[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTR_L06[pos] = 1
						elseif ewd_line_L == 7 then
							A333DR_ecam_ewd_gTitle_gfxBR_L07[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTR_L07[pos] = 1
						end

						-- RIGHT SIDE
						if pos == right_side then
							if ewd_line_L == 1 then
								A333DR_ecam_ewd_gTitle_gfxRR_L01[pos] = 1
							elseif ewd_line_L == 2 then
								A333DR_ecam_ewd_gTitle_gfxRR_L02[pos] = 1
							elseif ewd_line_L == 3 then
								A333DR_ecam_ewd_gTitle_gfxRR_L03[pos] = 1
							elseif ewd_line_L == 4 then
								A333DR_ecam_ewd_gTitle_gfxRR_L04[pos] = 1
							elseif ewd_line_L == 5 then
								A333DR_ecam_ewd_gTitle_gfxRR_L05[pos] = 1
							elseif ewd_line_L == 6 then
								A333DR_ecam_ewd_gTitle_gfxRR_L06[pos] = 1
							elseif ewd_line_L == 7 then
								A333DR_ecam_ewd_gTitle_gfxRR_L07[pos] = 1
							end
						end


						--AMBER
					elseif A333_ewd_msg[v.Name].TitleColor == 1 then

						-- LEFT SIDE
						if pos == left_side then
							if A333_ewd_msg[v.Name].ItemGFX == 2 and drawItemGraphic == false then
								if ewd_line_L == 1 then
									A333DR_ecam_ewd_gTitle_gfxLA_L01[pos] = 1
								elseif ewd_line_L == 2 then
									A333DR_ecam_ewd_gTitle_gfxLA_L02[pos] = 1
								elseif ewd_line_L == 3 then
									A333DR_ecam_ewd_gTitle_gfxLA_L03[pos] = 1
								elseif ewd_line_L == 4 then
									A333DR_ecam_ewd_gTitle_gfxLA_L04[pos] = 1
								elseif ewd_line_L == 5 then
									A333DR_ecam_ewd_gTitle_gfxLA_L05[pos] = 1
								elseif ewd_line_L == 6 then
									A333DR_ecam_ewd_gTitle_gfxLA_L06[pos] = 1
								elseif ewd_line_L == 7 then
									A333DR_ecam_ewd_gTitle_gfxLA_L07[pos] = 1
								end

							elseif A333_ewd_msg[v.Name].ItemGFX < 2 then -- DO NOT INCLUDE THE LEFT SIDE WARNING BOX GRAPHIC IF THE TITLE IS BOXED
								if ewd_line_L == 1 then
									A333DR_ecam_ewd_gTitle_gfxLA_L01[pos] = 1
								elseif ewd_line_L == 2 then
									A333DR_ecam_ewd_gTitle_gfxLA_L02[pos] = 1
								elseif ewd_line_L == 3 then
									A333DR_ecam_ewd_gTitle_gfxLA_L03[pos] = 1
								elseif ewd_line_L == 4 then
									A333DR_ecam_ewd_gTitle_gfxLA_L04[pos] = 1
								elseif ewd_line_L == 5 then
									A333DR_ecam_ewd_gTitle_gfxLA_L05[pos] = 1
								elseif ewd_line_L == 6 then
									A333DR_ecam_ewd_gTitle_gfxLA_L06[pos] = 1
								elseif ewd_line_L == 7 then
									A333DR_ecam_ewd_gTitle_gfxLA_L07[pos] = 1
								end
							end
						end

						-- TOP & BOTTOM
						if ewd_line_L == 1 then
							A333DR_ecam_ewd_gTitle_gfxBA_L01[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTA_L01[pos] = 1
						elseif ewd_line_L == 2 then
							A333DR_ecam_ewd_gTitle_gfxBA_L02[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTA_L02[pos] = 1
						elseif ewd_line_L == 3 then
							A333DR_ecam_ewd_gTitle_gfxBA_L03[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTA_L03[pos] = 1
						elseif ewd_line_L == 4 then
							A333DR_ecam_ewd_gTitle_gfxBA_L04[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTA_L04[pos] = 1
						elseif ewd_line_L == 5 then
							A333DR_ecam_ewd_gTitle_gfxBA_L05[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTA_L05[pos] = 1
						elseif ewd_line_L == 6 then
							A333DR_ecam_ewd_gTitle_gfxBA_L06[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTA_L06[pos] = 1
						elseif ewd_line_L == 7 then
							A333DR_ecam_ewd_gTitle_gfxBA_L07[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTA_L07[pos] = 1
						end

						-- RIGHT SIDE
						if pos == right_side then
							if ewd_line_L == 1 then
								A333DR_ecam_ewd_gTitle_gfxRA_L01[pos] = 1
							elseif ewd_line_L == 2 then
								A333DR_ecam_ewd_gTitle_gfxRA_L02[pos] = 1
							elseif ewd_line_L == 3 then
								A333DR_ecam_ewd_gTitle_gfxRA_L03[pos] = 1
							elseif ewd_line_L == 4 then
								A333DR_ecam_ewd_gTitle_gfxRA_L04[pos] = 1
							elseif ewd_line_L == 5 then
								A333DR_ecam_ewd_gTitle_gfxRA_L05[pos] = 1
							elseif ewd_line_L == 6 then
								A333DR_ecam_ewd_gTitle_gfxRA_L06[pos] = 1
							elseif ewd_line_L == 7 then
								A333DR_ecam_ewd_gTitle_gfxRA_L07[pos] = 1
							end
						end

						--| GREEN
					elseif A333_ewd_msg[v.Name].TitleColor == 2 then

						-- LEFT SIDE
						if pos == left_side then
							if A333_ewd_msg[v.Name].ItemGFX == 2 and drawItemGraphic == false then
								if ewd_line_L == 1 then
									A333DR_ecam_ewd_gTitle_gfxLG_L01[pos] = 1
								elseif ewd_line_L == 2 then
									A333DR_ecam_ewd_gTitle_gfxLG_L02[pos] = 1
								elseif ewd_line_L == 3 then
									A333DR_ecam_ewd_gTitle_gfxLG_L03[pos] = 1
								elseif ewd_line_L == 4 then
									A333DR_ecam_ewd_gTitle_gfxLG_L04[pos] = 1
								elseif ewd_line_L == 5 then
									A333DR_ecam_ewd_gTitle_gfxLG_L05[pos] = 1
								elseif ewd_line_L == 6 then
									A333DR_ecam_ewd_gTitle_gfxLG_L06[pos] = 1
								elseif ewd_line_L == 7 then
									A333DR_ecam_ewd_gTitle_gfxLG_L07[pos] = 1
								end

							elseif A333_ewd_msg[v.Name].ItemGFX < 2 then -- DO NOT INCLUDE THE LEFT SIDE WARNING BOX GRAPHIC IF THE TITLE IS BOXED
								if ewd_line_L == 1 then
									A333DR_ecam_ewd_gTitle_gfxLG_L01[pos] = 1
								elseif ewd_line_L == 2 then
									A333DR_ecam_ewd_gTitle_gfxLG_L02[pos] = 1
								elseif ewd_line_L == 3 then
									A333DR_ecam_ewd_gTitle_gfxLG_L03[pos] = 1
								elseif ewd_line_L == 4 then
									A333DR_ecam_ewd_gTitle_gfxLG_L04[pos] = 1
								elseif ewd_line_L == 5 then
									A333DR_ecam_ewd_gTitle_gfxLG_L05[pos] = 1
								elseif ewd_line_L == 6 then
									A333DR_ecam_ewd_gTitle_gfxLG_L06[pos] = 1
								elseif ewd_line_L == 7 then
									A333DR_ecam_ewd_gTitle_gfxLG_L07[pos] = 1
								end
							end
						end

						-- TOP & BOTTOM
						if ewd_line_L == 1 then
							A333DR_ecam_ewd_gTitle_gfxBG_L01[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTG_L01[pos] = 1
						elseif ewd_line_L == 2 then
							A333DR_ecam_ewd_gTitle_gfxBG_L02[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTG_L02[pos] = 1
						elseif ewd_line_L == 3 then
							A333DR_ecam_ewd_gTitle_gfxBG_L03[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTG_L03[pos] = 1
						elseif ewd_line_L == 4 then
							A333DR_ecam_ewd_gTitle_gfxBG_L04[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTG_L04[pos] = 1
						elseif ewd_line_L == 5 then
							A333DR_ecam_ewd_gTitle_gfxBG_L05[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTG_L05[pos] = 1
						elseif ewd_line_L == 6 then
							A333DR_ecam_ewd_gTitle_gfxBG_L06[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTG_L06[pos] = 1
						elseif ewd_line_L == 7 then
							A333DR_ecam_ewd_gTitle_gfxBG_L07[pos] = 1
							A333DR_ecam_ewd_gTitle_gfxTG_L07[pos] = 1
						end

						-- RIGHT SIDE
						if pos == right_side then
							if ewd_line_L == 1 then
								A333DR_ecam_ewd_gTitle_gfxRG_L01[pos] = 1
							elseif ewd_line_L == 2 then
								A333DR_ecam_ewd_gTitle_gfxRG_L02[pos] = 1
							elseif ewd_line_L == 3 then
								A333DR_ecam_ewd_gTitle_gfxRG_L03[pos] = 1
							elseif ewd_line_L == 4 then
								A333DR_ecam_ewd_gTitle_gfxRG_L04[pos] = 1
							elseif ewd_line_L == 5 then
								A333DR_ecam_ewd_gTitle_gfxRG_L05[pos] = 1
							elseif ewd_line_L == 6 then
								A333DR_ecam_ewd_gTitle_gfxRG_L06[pos] = 1
							elseif ewd_line_L == 7 then
								A333DR_ecam_ewd_gTitle_gfxRG_L07[pos] = 1
							end
						end
					end -- TITLE COLOR
				end -- POS ITERATION
			end -- WARNING GFX


			if ewd_line_L == 7 then break end




			--=========================|  A C T I O N   M E S S A G E S  |=========================

			-- INIT THE MSG LINE VISIBILITY
			for i = 1, #A333_ewd_msg[v.Name].MsgLine do
				A333_ewd_msg[v.Name].MsgLine[i].MsgVisible = 0
			end

			-- CONFIG-MEMO ACTION LINES
			if A333_ewd_msg[v.Name].FailType == 5 then

				for i = 1, #A333_ewd_msg[v.Name].MsgLine do

					if A333_ewd_msg[v.Name].MsgLine[i].MsgStatus == 1 then
						if i == 1 then
							A333DR_ecam_ewd_gText_color_L[ewd_line_L] = A333_ewd_msg[v.Name].MsgLine[i].MsgColor
							A333DR_ecam_ewd_gText_msg_L[ewd_line_L] = string.format('%s%s', title, string.sub(A333_ewd_msg[v.Name].MsgLine[i].MsgText, 5, 19))
						end
						if i == 2 then
							A333DR_ecam_ewd_gText_cfgAction_color_L[ewd_line_L] = A333_ewd_msg[v.Name].MsgLine[i].MsgColor
							A333DR_ecam_ewd_gText_cfgAction_L[ewd_line_L] = A333_ewd_msg[v.Name].MsgLine[i].MsgText
						end
						if i == 3 then
							A333DR_ecam_ewd_gText_color_L[ewd_line_L] = A333_ewd_msg[v.Name].MsgLine[i].MsgColor
							A333DR_ecam_ewd_gText_msg_L[ewd_line_L] = string.format('%s%s', title, string.sub(A333_ewd_msg[v.Name].MsgLine[i].MsgText, 5, 19))
						end
						if i == 4
							or i == 6
							or i == 7
							or i == 9
							or i == 10
							or i == 12
							or i == 13
							or i == 15
							or i == 16
							or i == 18
						then  -- 4/6/7/9/10/12/13/15/16/18
							A333DR_ecam_ewd_gText_color_L[ewd_line_L] = A333_ewd_msg[v.Name].MsgLine[i].MsgColor
							A333DR_ecam_ewd_gText_msg_L[ewd_line_L] = A333_ewd_msg[v.Name].MsgLine[i].MsgText
						end
						if i == 5
							or i == 8
							or i == 11
							or i == 14
							or i == 17
						then 	-- 5/8/11/14/17
							A333DR_ecam_ewd_gText_cfgAction_color_L[ewd_line_L] = A333_ewd_msg[v.Name].MsgLine[i].MsgColor
							A333DR_ecam_ewd_gText_cfgAction_L[ewd_line_L] = A333_ewd_msg[v.Name].MsgLine[i].MsgText
						end
						if i == 2
							or i == 3
							or i == 5
							or i == 6
							or i == 8
							or i == 9
							or i == 11
							or i == 12
							or i == 14
							or i == 15
							or i == 17
							or i == 18
						then
							ewd_line_L = ewd_line_L + 1
						end

						A333_ewd_msg[v.Name].MsgLine[i].MsgVisible  = 1

					end

				end



			else -- NON CONFIG-MEMO ACTION LINES

				for i = 1, #A333_ewd_msg[v.Name].MsgLine do
					if A333_ewd_msg[v.Name].MsgLine[i].MsgStatus == 1
						and A333_ewd_msg[v.Name].MsgLine[i].MsgCleared == 0
					then
						ewd_line_L = ewd_line_L + 1
						A333DR_ecam_ewd_gText_color_L[ewd_line_L] 	= A333_ewd_msg[v.Name].MsgLine[i].MsgColor
						A333DR_ecam_ewd_gText_msg_L[ewd_line_L] 	= A333_ewd_msg[v.Name].MsgLine[i].MsgText
						A333_ewd_msg[v.Name].MsgLine[i].MsgVisible  = 1
						if ewd_line_L == 7 then break end
					end
				end
				if ewd_line_L == 7 then break end

			end

		end -- MESSAGE CUE L ITERATION
		ewd_line_L = 0

	end -- RCL 'NORMAL' MESSAGE CHECK

end









function A333_fws_ewd_generic_inst_R()

	for i = 1, 7 do
		A333DR_ecam_ewd_gText_msg_R[i] = ""
	end

	for _, v in ipairs(A333_ewd_msg_cue_R) do

		ewd_line_R = ewd_line_R + 1

		A333DR_ecam_ewd_gText_color_R[ewd_line_R] = A333_ewd_msg[v.Name].TitleColor
		A333DR_ecam_ewd_gText_msg_R[ewd_line_R] = A333_ewd_msg[v.Name].ItemTitle

		if ewd_line_R == 7 then break end

	end
	ewd_line_R = 0

end















--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_800_flight_start()

	A333DR_ecam_ewd_show_sts = 0

end

function A333_fws_800()

	A333_fws_ewd_generic_inst_L()
	A333_fws_ewd_generic_inst_R()

end





--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







