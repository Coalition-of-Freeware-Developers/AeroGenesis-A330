--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws600.lua
* Process: FWS Status Message Actions
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


--print("LOAD: A333.ecam_fws600.lua")

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
local logic = {}

logic.apdualHydLoGB_srSS01 = newSRlatchSetPriority('apdualHydLoGB_srSS01')
logic.apdualHydLoGB_srSS02 = newSRlatchSetPriority('apdualHydLoGB_srSS02')

logic.apdualHydLoBY_srSS01 = newSRlatchSetPriority('apdualHydLoBY_srSS01')
logic.apdualHydLoBY_srSS02 = newSRlatchSetPriority('apdualHydLoBY_srSS02')

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
function A333_sts_msg.MIN_RAT_SPEED.Action()
	A333_sts_msg.MIN_RAT_SPEED.Msg[1].Status = 1
end




function A333_sts_msg.MAX_SPEED_280.Action()
	A333_sts_msg.MAX_SPEED_280.Msg[1].Status = 1
end




function A333_sts_msg.MAX_SPEED_300.Action()
	A333_sts_msg.MAX_SPEED_300.Msg[1].Status = 1
end




function A333_sts_msg.IF_BUFFET.Action()
	A333_sts_msg.IF_BUFFET.Msg[1].Status = 1
end




function A333_sts_msg.MAX_SPEED_240.Action()
	A333_sts_msg.MAX_SPEED_240.Msg[1].Status = 1
end




function A333_sts_msg.MAX_SPEED_320_77.Action()
	A333_sts_msg.MAX_SPEED_320_77.Msg[1].Status = 1
end




function A333_sts_msg.DOORS_NOT_CLOSED.Action()
	A333_sts_msg.DOORS_NOT_CLOSED.Msg[1].Status = 1
end




function A333_sts_msg.LG_KEEP_DOWN.Action()
	A333_sts_msg.LG_KEEP_DOWN.Msg[1].Status = 1
end




function A333_sts_msg.MAX_BRK_PR.Action()
	A333_sts_msg.MAX_BRK_PR.Msg[1].Status = 1
end




function A333_sts_msg.L_R_FUEL_GRVTY_FEED.Action()
	A333_sts_msg.L_R_FUEL_GRVTY_FEED.Msg[1].Status = 1
end




function A333_sts_msg.AVOID_ICING_CONDITIONS.Action()
	A333_sts_msg.AVOID_ICING_CONDITIONS.Msg[1].Status = 1
end




function A333_sts_msg.AVOID_ADVERSE_CONDITIONS.Action()
	A333_sts_msg.AVOID_ADVERSE_CONDITIONS.Msg[1].Status = 1
end




function A333_sts_msg.AP_DUAL_HYD_LO_GB.Action()

    logic.apdualHydLoGB_srSS01:update(HBROVHT, (not HBEPPBOF))
    logic.apdualHydLoGB_srSS02:update(HGROVHT, (not HGPPBOF))
    local a = HBEPPBOF and HBRLAP
    local b = HGPPBOF and HGRLAP
    local c =  logic.apdualHydLoGB_srSS01.Q or a
    local d = logic.apdualHydLoGB_srSS02.Q or b
    local e = c and (not HBRLL)
    local f = d and (not HGRLL)
    local g = (not HGRLL) and HPRATPBOF
    local h = logic.apdualHydLoGB_srSS01.Q or e or logic.apdualHydLoGB_srSS02.Q or f or g

	A333_sts_msg.AP_DUAL_HYD_LO_GB.Msg[1].Status = h
	A333_sts_msg.AP_DUAL_HYD_LO_GB.Msg[2].Status = h
	A333_sts_msg.AP_DUAL_HYD_LO_GB.Msg[3].Status = logic.apdualHydLoGB_srSS01.Q
	A333_sts_msg.AP_DUAL_HYD_LO_GB.Msg[4].Status = e
	A333_sts_msg.AP_DUAL_HYD_LO_GB.Msg[5].Status = logic.apdualHydLoGB_srSS02.Q
	A333_sts_msg.AP_DUAL_HYD_LO_GB.Msg[6].Status = f
	A333_sts_msg.AP_DUAL_HYD_LO_GB.Msg[7].Status = g
end




function A333_sts_msg.AP_DUAL_HYD_LO_BY.Action()

    logic.apdualHydLoBY_srSS01:update(HBROVHT, (not HBEPPBOF))
    logic.apdualHydLoBY_srSS02:update(HGROVHT, (not HGPPBOF))

    local a = HBEPPBOF and HBRLAP
    local b =  HYPPBOF and HYRLAP
    local c =  logic.apdualHydLoBY_srSS01.Q and a
    local d = logic.apdualHydLoBY_srSS02.Q and b
    local e = c and (not HBRLL)
    local f = d and (not HYRLL)
    local g = (not HYRLL) and HPRATPBOF
    local h = logic.apdualHydLoBY_srSS01.Q or e or logic.apdualHydLoBY_srSS02.Q or f or g

	A333_sts_msg.AP_DUAL_HYD_LO_BY.Msg[1].Status = h
	A333_sts_msg.AP_DUAL_HYD_LO_BY.Msg[2].Status = h
	A333_sts_msg.AP_DUAL_HYD_LO_BY.Msg[3].Status = logic.apdualHydLoBY_srSS01
	A333_sts_msg.AP_DUAL_HYD_LO_BY.Msg[4].Status = e
	A333_sts_msg.AP_DUAL_HYD_LO_BY.Msg[5].Status = logic.apdualHydLoBY_srSS02
	A333_sts_msg.AP_DUAL_HYD_LO_BY.Msg[6].Status = f
	A333_sts_msg.AP_DUAL_HYD_LO_BY.Msg[7].Status = g
end




function A333_sts_msg.L_TK_GRVTY_FEED_ONLY.Action()
	A333_sts_msg.L_TK_GRVTY_FEED_ONLY.Msg[1].Status = 1
end




function A333_sts_msg.R_TK_GRVTY_FEED_ONLY.Action()
	A333_sts_msg.R_TK_GRVTY_FEED_ONLY.Msg[1].Status = 1
end




function A333_sts_msg.PITCH_MECH_BACK_UP.Action()
	A333_sts_msg.PITCH_MECH_BACK_UP.Msg[1].Status = 1
end




function A333_sts_msg.ROLL_DIRECT_LAW.Action()
	A333_sts_msg.ROLL_DIRECT_LAW.Msg[1].Status = 1
end




function A333_sts_msg.BAT_ONLY.Action()
	A333_sts_msg.BAT_ONLY.Msg[1].Status = 1
end




function A333_sts_msg.ONE_PACK_ONLY_IF_WAI_ON.Action()
	A333_sts_msg.ONE_PACK_ONLY_IF_WAI_ON.Msg[1].Status = 1
end




function A333_sts_msg.HYD_GY_SYS_INOP.Action()
	A333_sts_msg.HYD_GY_SYS_INOP.Msg[1].Status = 1
end




function A333_sts_msg.HYD_GB_SYS_INOP.Action()
	A333_sts_msg.HYD_GB_SYS_INOP.Msg[1].Status = 1
end




function A333_sts_msg.HYD_G_SYS_INOP.Action()
	A333_sts_msg.HYD_G_SYS_INOP.Msg[1].Status = 1
end




function A333_sts_msg.HYD_B_SYS_INOP.Action()
	A333_sts_msg.HYD_B_SYS_INOP.Msg[1].Status = 1
end




function A333_sts_msg.HYD_Y_SYS_INOP.Action()
	A333_sts_msg.HYD_Y_SYS_INOP.Msg[1].Status = 1
end




function A333_sts_msg.STABILIZER_INOP.Action()
	A333_sts_msg.STABILIZER_INOP.Msg[1].Status = 1
end




function A333_sts_msg.L_R_ELEV.Action()
	A333_sts_msg.L_R_ELEV.Msg[1].Status = 1
end




function A333_sts_msg.L_ELEV.Action()
	A333_sts_msg.L_ELEV.Msg[1].Status = 1
end




function A333_sts_msg.R_ELEV.Action()
	A333_sts_msg.R_ELEV.Msg[1].Status = 1
end




function A333_sts_msg.PACK_1_2.Action()
	A333_sts_msg.PACK_1_2.Msg[1].Status = 1
end




function A333_sts_msg.PACK_1.Action()
	A333_sts_msg.PACK_1.Msg[1].Status = 1
end




function A333_sts_msg.PACK_2.Action()
	A333_sts_msg.PACK_2.Msg[1].Status = 1
end




function A333_sts_msg.BAT_1.Action()
	A333_sts_msg.BAT_1.Msg[1].Status = 1
end




function A333_sts_msg.BAT_2.Action()
	A333_sts_msg.BAT_2.Msg[1].Status = 1
end




function A333_sts_msg.GEN_1.Action()
	A333_sts_msg.GEN_1.Msg[1].Status = 1
end




function A333_sts_msg.GEN_2.Action()
	A333_sts_msg.GEN_2.Msg[1].Status = 1
end




function A333_sts_msg.APU_GEN.Action()
	A333_sts_msg.APU_GEN.Msg[1].Status = 1
end




function A333_sts_msg.B_ELEC_PUMP.Action()
	A333_sts_msg.B_ELEC_PUMP.Msg[1].Status = 1
end




function A333_sts_msg.Y_ELEC_PUMP.Action()
	A333_sts_msg.Y_ELEC_PUMP.Msg[1].Status = 1
end















local function A333_fws_sts_action_functions()

	for _, msg in ipairs(A333_sts_msg_cue_L) do
		if A333_sts_msg[msg.Name].Action then
			A333_sts_msg[msg.Name].Action()
		end
	end

	for _, msg in ipairs(A333_sts_msg_cue_R) do
		if A333_sts_msg[msg.Name].Action then
			A333_sts_msg[msg.Name].Action()
		end
	end

end





--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_600()

	A333_fws_sts_action_functions()

end


--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







