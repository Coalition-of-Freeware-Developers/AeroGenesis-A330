--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws370.lua
* Process: FWS Status Message Trigger Logic
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


--print("LOAD: A333.ecam_fws370.lua")

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
function A333_sts_msg.MIN_RAT_SPEED.Monitor()

	local a = HBDF or EEGNCON
	local b = a and HRATNFS

	A333_sts_msg.MIN_RAT_SPEED.Video.IN = bool2num[b]

end




function A333_sts_msg.MAX_SPEED_280.Monitor()

    local a = GBGFT or GBRKOVHT
    local b = GLGDNLKD and a
    local c = b or GGUPENG or GLGNUP or GSAF
    local d = c and (not GDNC) and (not ZGND)

	A333_sts_msg.MAX_SPEED_280.Video.IN = bool2num[d]

end




function A333_sts_msg.MAX_SPEED_300.Monitor()

	local a = JR1REVULK or JR2REVULK
	local b = (not ZGND) and a

	A333_sts_msg.MAX_SPEED_300.Video.IN = bool2num[b]

end




function A333_sts_msg.IF_BUFFET.Monitor()

	local a = JR1REVULK or JR2REVULK
	local b = (not ZGND) and a

	A333_sts_msg.IF_BUFFET.Video.IN = bool2num[b]

end




function A333_sts_msg.MAX_SPEED_240.Monitor()

	local a = JR1REVULK or JR2REVULK
	local b = (not ZGND) and a

	A333_sts_msg.MAX_SPEED_240.Video.IN = bool2num[b]

end




function A333_sts_msg.MAX_SPEED_320_77.Monitor()

	local a = HTHOUT or SLRELVFT or SPBUL
	local b = ZPH1 or ZPH10
	local c = a and (not b)

	A333_sts_msg.MAX_SPEED_320_77.Video.IN = c

end




function A333_sts_msg.DOORS_NOT_CLOSED.Monitor()

	A333_sts_msg.DOORS_NOT_CLOSED.Video.IN = bool2num[GDNC]

end




function A333_sts_msg.LG_KEEP_DOWN.Monitor()

	local a = GGUPENG or GBGFT or GSAF

	A333_sts_msg.LG_KEEP_DOWN.Video.IN = bool2num[a]

end




function A333_sts_msg.AVOID_ICING_CONDITIONS.Monitor()

    local a =  UE1FPBOUT or UE2FPBOUT
    local b = IE1NVNO or IE2NVNO
    local c = BBAIC or IWAIAIC or IWAIE or a
    local d = b or c

	IWAIC = c

	A333_sts_msg.AVOID_ICING_CONDITIONS.Video.IN = bool2num[d]

end




function A333_sts_msg.MAX_BRK_PR.Monitor()

	local a =  HGSYSLP and HYSYSLP
	local b = GASF or GASKDOFF or EEMER or EDC12OF or a

	A333_sts_msg.MAX_BRK_PR.Video.IN = bool2num[b]

end




function A333_sts_msg.L_R_FUEL_GRVTY_FEED.Monitor()

	local a = FRGFEED and FLGFEED

	FLRGFEED = a

	A333_sts_msg.L_R_FUEL_GRVTY_FEED.Video.IN = bool2num[a]

end




function A333_sts_msg.AVOID_ADVERSE_CONDITIONS.Monitor()

	local a = JR1IFT or JR2IFT

	A333_sts_msg.AVOID_ADVERSE_CONDITIONS.Video.IN = bool2num[a]

end




function A333_sts_msg.AP_DUAL_HYD_LO_GB.Monitor()

    local a = HNVMBEPF or HBRLL
    local b = HGRLL or HNVMG1PF
    local c = HBSYSLP and HGSYSLP
    local d = a and b
    local e = (not ZGND) and c and (not d)

	A333_sts_msg.AP_DUAL_HYD_LO_GB.Video.IN = bool2num[e]

end




function A333_sts_msg.AP_DUAL_HYD_LO_BY.Monitor()

    local a = HNVMBPF or HBRLL
    local b = HYRLL or HNVMYEPF
    local c = HBSYSLP and HYSYSLP
    local d = a and b
    local e = (not ZGND) and c and (not d)

	A333_sts_msg.AP_DUAL_HYD_LO_BY.Video.IN = bool2num[e]

end




function A333_sts_msg.L_TK_GRVTY_FEED_ONLY.Monitor()

    local a =  USKD and (not EGN1COF)
    local b = EEMER and (not a)
    local c = ZPH1 or ZPH10
    local d = FLTP12F or EDCEC or b
    local e = (not c) and d
    local f = (not FLRGFEED) and e

	FLGFEED = e

	A333_sts_msg.L_TK_GRVTY_FEED_ONLY.Video.IN = bool2num[f]

end




function A333_sts_msg.R_TK_GRVTY_FEED_ONLY.Monitor()

    local a =  USKD and (not EGN1COF)
    local b = EEMER and (not a)
    local c = ZPH1 or ZPH10
    local d = FRTP12F or EDCEC or b
    local e = (not c) and d
    local f = (not FLRGFEED) and e

	FRGFEED = e

	A333_sts_msg.R_TK_GRVTY_FEED_ONLY.Video.IN = bool2num[f]

end




function A333_sts_msg.PITCH_MECH_BACK_UP.Monitor()

	local a = ZPH1 or ZPH10
	local b = SLRELVFT and not a

	A333_sts_msg.PITCH_MECH_BACK_UP.Video.IN = bool2num[b]

end




function A333_sts_msg.ROLL_DIRECT_LAW.Monitor()

	A333_sts_msg.ROLL_DIRECT_LAW.Video.IN = bool2num[SLRELVFT]

end




function A333_sts_msg.BAT_ONLY.Monitor()

	local a = ZPH1 or ZPH10
	local b = (not WENA330EMERC) and EEMER and WA330 and (not a)

	A333_sts_msg.BAT_ONLY.Video.IN = bool2num[b]

end




function A333_sts_msg.ONE_PACK_ONLY_IF_WAI_ON.Monitor()

    local a = BB1NA ~= BB2NA
    local b = JR1SD ~= JR2SD
    local c = AP1PBOF ~= AP2PBOF
    local d = a or b
    local e = IWAION and c
    local f = (not IWAIC) and d and (not e) and (not ZGND)

	A333_sts_msg.ONE_PACK_ONLY_IF_WAI_ON.Video.IN = bool2num[f]

end




function A333_sts_msg.HYD_GY_SYS_INOP.Monitor()

	local a = HYSYSLP and HGSYSLP

	A333_sts_msg.HYD_GY_SYS_INOP.Video.IN = bool2num[a]

end


function A333_sts_msg.HYD_GB_SYS_INOP.Monitor()

	local a = HBSYSLP and HGSYSLP

	A333_sts_msg.HYD_GB_SYS_INOP.Video.IN = bool2num[a]

end


function A333_sts_msg.HYD_G_SYS_INOP.Monitor()

	local a = GSYSLP and (not HYSYSLP) and (not HBSYSLP)

	A333_sts_msg.HYD_G_SYS_INOP.Video.IN = bool2num[a]

end




function A333_sts_msg.HYD_B_SYS_INOP.Monitor()

	local a = HBSYSLP and (not HGSYSLP) and (not HYSYSLP)

	A333_sts_msg.HYD_B_SYS_INOP.Video.IN = bool2num[a]

end




function A333_sts_msg.HYD_Y_SYS_INOP.Monitor()

	local a = HYSYSLP and (not HBSYSLP) and (not HGSYSLP)

	A333_sts_msg.HYD_Y_SYS_INOP.Video.IN = bool2num[a]

end




function A333_sts_msg.STABILIZER_INOP.Monitor()

    local a = HGSLP and HYSLP
    local b = ZPH1 or ZPH10
    local c = STHSJAMEC_1 or STHSJAMEC_2 or a
    local d = c and (not b)

	STHSJAM = d

	A333_sts_msg.STABILIZER_INOP.Video.IN = bool2num[d]

end




function A333_sts_msg.L_R_ELEV.Monitor()

	A333_sts_msg.L_R_ELEV.Video.IN = bool2num[SLRELVFT]

end




function A333_sts_msg.L_ELEV.Monitor()

    local a = ZPH1 or ZPH10
    local b = a and HBSLP and HGSLP
    local c = SLELVBA_1_VAL and (not SLELVBA_1)
    local d = SLELVBA_2_VAL and (not SLELVBA_2)
    local e = SLELVGA_1_VAL and (not SLELVGA_1)
    local f = SLELVGA_2_VAL and (not SLELVGA_2)
    local g = c or d
    local h = e or f
    local i = SLRELVFT or b
    local j = g and h
    local k = (not i) and j

	SLELNA = j

	A333_sts_msg.L_ELEV.Video.IN = bool2num[k]

end




function A333_sts_msg.R_ELEV.Monitor()

    local a = ZPH1 or ZPH10
    local b = a and HBSLP and HYSLP
    local c = SRELVBA_1_VAL and (not SRELVBA_1)
    local d = SRELVBA_2_VAL and (not SRELVBA_2)
    local e = SRELVYA_1_VAL and (not SRELVYA_1)
    local f = SRELVYA_2_VAL and (not SRELVYA_2)
    local g = c or d
    local h = e or f
    local i = SLRELVFT or b
    local j = g and h
    local k = (not i) and j

	SRELNA = j

	A333_sts_msg.R_ELEV.Video.IN = bool2num[k]

end




function A333_sts_msg.PACK_1_2.Monitor()

	local a = AP1I and AP2I

	AP12INOP = a

	A333_sts_msg.PACK_1_2.Video.IN = bool2num[a]

end




function A333_sts_msg.PACK_1.Monitor()
    local a = EEMER and JR1SD
    local b = ZPH1 or ZPH10
    local c = (not EEMER) and JR1SD and AP1FCVFC
    local d = AP1FCVFC and (not a) and (not AB1AVAIL) and (not AP1PBOF) and (not b)
    local e = not b and AP1PBOF
    local f = AP12FT or AP12INOP
    local g = c or d or e or AP1OHT or AP1F
    local h = g and not f

	AP1I = g

	A333_sts_msg.PACK_1.Video.IN = bool2num[h]

end




function A333_sts_msg.PACK_2.Monitor()

    local a = ZPH1 or ZPH10
    local b = AP2FCVFC and JR2SD
    local c = AP2FCVFC and (not AB2AVAIL) and (not AP2PBOF) and (not a)
    local d = (not a) and AP2PBOF
    local e = b or c or d or AP2OHT or AP2F
    local f = AP12FT or AP12INOP
    local g = e and (not f)

	AP2I = e

	A333_sts_msg.PACK_2.Video.IN = bool2num[g]

end




function A333_sts_msg.BAT_1.Monitor()

	A333_sts_msg.BAT_1.Video.IN = bool2num[EBAT1F]

end




function A333_sts_msg.BAT_2.Monitor()

	A333_sts_msg.BAT_2.Video.IN = bool2num[EBAT2F]

end




function A333_sts_msg.GEN_1.Monitor()

	local a = EGN1COF and JR1SD
	local b = ENG1INOP or a
	local c = b and (not EEMER)

	A333_sts_msg.GEN_1.Video.IN = bool2num[c]

end




function A333_sts_msg.GEN_2.Monitor()

	local a = EGN2COF and JR2SD
	local b = ENG2INOP or a
	local c = b and (not EEMER)

	A333_sts_msg.GEN_2.Video.IN = bool2num[c]

end




function A333_sts_msg.APU_GEN.Monitor()

	A333_sts_msg.APU_GEN.Video.IN = bool2num[ENG3INOP]

end




function A333_sts_msg.B_ELEC_PUMP.Monitor()

	local a = EEMER or ZPH1 or ZPH10
	local b = HBEPPBOF or HNVMBPF
	local c = (not a) and b

	A333_sts_msg.B_ELEC_PUMP.Video.IN = c

end




function A333_sts_msg.Y_ELEC_PUMP.Monitor()

	A333_sts_msg.Y_ELEC_PUMP.Video.IN = bool2num[HNVMYEPF]

end

















local function A333_fws_sts_monitor_functions()

	for _, msg in pairs(A333_sts_msg) do
		if msg.Monitor then
			msg.Monitor()
		end
	end

end



--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--

function A333_fws_370()

	A333_fws_sts_monitor_functions()

end




--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







