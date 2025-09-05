jit.off()
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
*       					     COPYRIGHT © 2021, 2022
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

	local a = {E1 = HBDF, E2 = EEGNCON}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = a.S, E2 = HRATNFS}
	b.S = bAND(b.E1, b.E2)

	A333_sts_msg.MIN_RAT_SPEED.Video.IN = bool2num[b.S]

end



function A333_sts_msg.MAX_SPEED_280.Monitor()

	local a = {E1 = GBGFT, E2 = GBRKOVHT}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = GLGDNLKD, E2 = a.S}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = b.S, E2 = GGUPENG, E3 = GLGNUP, E4 = GSAF}
	c.S = bOR4(c.E1, c.E2, c.E3, c.E4)

	local d = {E1 = c.S, E2 = bNOT(GDNC), E3 = bNOT(ZGND)}
	d.S = bAND3(d.E1, d.E2, d.E3)

	A333_sts_msg.MAX_SPEED_280.Video.IN = bool2num[d.S]

end



function A333_sts_msg.MAX_SPEED_300.Monitor()

	local a = {E1 = JR1REVULK, E2 = JR2REVULK}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = bNOT(ZGND), E2 = a.S}
	b.S = bAND(b.E1, b.E2)

	A333_sts_msg.MAX_SPEED_300.Video.IN = bool2num[b.S]

end



function A333_sts_msg.IF_BUFFET.Monitor()

	local a = {E1 = JR1REVULK, E2 = JR2REVULK}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = bNOT(ZGND), E2 = a.S}
	b.S = bAND(b.E1, b.E2)

	A333_sts_msg.IF_BUFFET.Video.IN = bool2num[b.S]

end



function A333_sts_msg.MAX_SPEED_240.Monitor()

	local a = {E1 = JR1REVULK, E2 = JR2REVULK}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = bNOT(ZGND), E2 = a.S}
	b.S = bAND(b.E1, b.E2)

	A333_sts_msg.MAX_SPEED_240.Video.IN = bool2num[b.S]

end



function A333_sts_msg.MAX_SPEED_320_77.Monitor()

	local a = {E1 = HTHOUT, E2 = SLRELVFT, E3 = SPBUL}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = ZPH1, E2 = ZPH10}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = a.S, E2 = bNOT(b.S)}
	c.S = bAND(c.E1, c.E2)

	A333_sts_msg.MAX_SPEED_320_77.Video.IN = c.S

end



function A333_sts_msg.DOORS_NOT_CLOSED.Monitor()

	A333_sts_msg.DOORS_NOT_CLOSED.Video.IN = bool2num[GDNC]


end



function A333_sts_msg.LG_KEEP_DOWN.Monitor()

	local a = {E1 = GGUPENG, E2 = GBGFT, E3 = GSAF}
	a.S = bOR3(a.E1, a.E2, a.E3)

	A333_sts_msg.LG_KEEP_DOWN.Video.IN = bool2num[a.S]

end



function A333_sts_msg.AVOID_ICING_CONDITIONS.Monitor()

	local a = {E1 = UE1FPBOUT, E2 = UE2FPBOUT}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = IE1NVNO, E2 = IE2NVNO}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = BBAIC, E2 = IWAIAIC, E3 = IWAIE, E4 = a.S}
	c.S = bOR4(c.E1, c.E2, c.E3, c.E4)

	local d = {E1 = b.S, E2 = c.S}
	d.S = bOR(d.E1, d.E2)

	IWAIC = c.S

	A333_sts_msg.AVOID_ICING_CONDITIONS.Video.IN = bool2num[d.S]

end
















function A333_sts_msg.MAX_BRK_PR.Monitor()

	local a = {E1 = HGSYSLP, E2 = HYSYSLP}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = GASF, E2 = GASKDOFF, E3 = EEMER, E4 = EDC12OF, E5 = a.S}
	b.S = bOR5(b.E1, b.E2, b.E3, b.E4, b.E5)

	A333_sts_msg.MAX_BRK_PR.Video.IN = bool2num[b.S]

end



function A333_sts_msg.L_R_FUEL_GRVTY_FEED.Monitor()

	local a = {E1 = FRGFEED, E2 = FLGFEED}
	a.S = bAND(a.E1, a.E2)

	FLRGFEED = a.S

	A333_sts_msg.L_R_FUEL_GRVTY_FEED.Video.IN = bool2num[a.S]

end








function A333_sts_msg.AVOID_ADVERSE_CONDITIONS.Monitor()

	local a = {E1 = JR1IFT, E2 = JR2IFT}
	a.S = bOR4(a.E1, a.E2)

	A333_sts_msg.AVOID_ADVERSE_CONDITIONS.Video.IN = bool2num[a.S]

end








function A333_sts_msg.AP_DUAL_HYD_LO_GB.Monitor()

	local a = {E1 = HNVMBEPF, E2 = HBRLL}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = HGRLL, E2 = HNVMG1PF}
	b.S = bOR(a.E1, a.E2)

	local c = {E1 = HBSYSLP, E2 = HGSYSLP}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = bNOT(ZGND), E2 = c.S, E3 = bNOT(d.S)}
	e.S = bAND3(e.E1, e.E2, e.E3)

	A333_sts_msg.AP_DUAL_HYD_LO_GB.Video.IN = bool2num[e.S]

end



function A333_sts_msg.AP_DUAL_HYD_LO_BY.Monitor()

	local a = {E1 = HNVMBPF, E2 = HBRLL}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = HYRLL, E2 = HNVMYEPF}
	b.S = bOR(a.E1, a.E2)

	local c = {E1 = HBSYSLP, E2 = HYSYSLP}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = bNOT(ZGND), E2 = c.S, E3 = bNOT(d.S)}
	e.S = bAND3(e.E1, e.E2, e.E3)

	A333_sts_msg.AP_DUAL_HYD_LO_BY.Video.IN = bool2num[e.S]

end












function A333_sts_msg.L_TK_GRVTY_FEED_ONLY.Monitor()

	local a = {E1 = USKD, E2 = bNOT(EGN1COF)}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = EEMER, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = ZPH1, E2 = ZPH10}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = FLTP12F, E2 = EDCEC, E3 = b.S}
	d.S = bOR(d.E1, d.E2, d.E3)

	local e = {E1 = bNOT(c.S), E2 = d.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = bNOT(FLRGFEED), E2 = e.S}
	f.S = bAND(f.E1, f.E2)

	FLGFEED = e.S

	A333_sts_msg.L_TK_GRVTY_FEED_ONLY.Video.IN = bool2num[f.S]

end




function A333_sts_msg.R_TK_GRVTY_FEED_ONLY.Monitor()

	local a = {E1 = USKD, E2 = bNOT(EGN1COF)}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = EEMER, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = ZPH1, E2 = ZPH10}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = FRTP12F, E2 = EDCEC, E3 = b.S}
	d.S = bOR(d.E1, d.E2, d.E3)

	local e = {E1 = bNOT(c.S), E2 = d.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = bNOT(FLRGFEED), E2 = e.S}
	f.S = bAND(f.E1, f.E2)

	FRGFEED = e.S

	A333_sts_msg.R_TK_GRVTY_FEED_ONLY.Video.IN = bool2num[f.S]

end




function A333_sts_msg.PITCH_MECH_BACK_UP.Monitor()

	local a = {E1 = ZPH1, E2 = ZPH10}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = SLRELVFT, E2 = bNOT(a.S)}
	b.S = bAND(b.E1, b.E2)

	A333_sts_msg.PITCH_MECH_BACK_UP.Video.IN = bool2num[b.S]

end



function A333_sts_msg.ROLL_DIRECT_LAW.Monitor()

	A333_sts_msg.ROLL_DIRECT_LAW.Video.IN = bool2num[SLRELVFT]

end






function A333_sts_msg.BAT_ONLY.Monitor()

	local a = {E1 = ZPH1, E2 = ZPH10}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = bNOT(WENA330EMERC), E2 = EEMER, E3 = WA330, E4 = bNOT(a.S)}
	b.S = bAND4(b.E1, b.E2, b.E3, b.E4)

	A333_sts_msg.BAT_ONLY.Video.IN = bool2num[b.S]


end












function A333_sts_msg.ONE_PACK_ONLY_IF_WAI_ON.Monitor()

	local a = {E1 = BB1NA, E2 = BB2NA}
	a.S = bXOR(a.E1, a.E2)

	local b = {E1 = JR1SD, E2 = JR2SD}
	b.S = bXOR(b.E1, b.E2)

	local c = {E1 = AP1PBOF, E2 = AP2PBOF}
	c.S = bXOR(c.E1, c.E2)

	local d = {E1 = a.S, E2 = b.S}
	d.S = bOR(d.E1, d.E2)

	local e = {E1 = IWAION, E2 = c.S}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = bNOT(IWAIC), E2 = d.S, E3 = bNOT(e.S), E4 = bNOT(ZGND)}
	f.S = bAND4(f.E1, f.E2, f.E3, f.E4)

	A333_sts_msg.ONE_PACK_ONLY_IF_WAI_ON.Video.IN = bool2num[f.S]

end








function A333_sts_msg.HYD_GY_SYS_INOP.Monitor()

	local a = {E1 = HYSYSLP, E2 = HGSYSLP}
	a.S = bAND(a.E1, a.E2)

	A333_sts_msg.HYD_GY_SYS_INOP.Video.IN = bool2num[a.S]

end


function A333_sts_msg.HYD_GB_SYS_INOP.Monitor()

	local a = {E1 = HBSYSLP, E2 = HGSYSLP}
	a.S = bAND(a.E1, a.E2)

	A333_sts_msg.HYD_GB_SYS_INOP.Video.IN = bool2num[a.S]

end


function A333_sts_msg.HYD_G_SYS_INOP.Monitor()

	local a = {E1 = HGSYSLP, E2 = bNOT(HYSYSLP), E3 = bNOT(HBSYSLP)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	A333_sts_msg.HYD_G_SYS_INOP.Video.IN = bool2num[a.S]

end


function A333_sts_msg.HYD_B_SYS_INOP.Monitor()

	local a = {E1 = HBSYSLP, E2 = bNOT(HGSYSLP), E3 = bNOT(HYSYSLP)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	A333_sts_msg.HYD_B_SYS_INOP.Video.IN = bool2num[a.S]

end


function A333_sts_msg.HYD_Y_SYS_INOP.Monitor()

	local a = {E1 = HYSYSLP, E2 = bNOT(HBSYSLP), E3 = bNOT(HGSYSLP)}
	a.S = bAND3(a.E1, a.E2, a.E3)

	A333_sts_msg.HYD_Y_SYS_INOP.Video.IN = bool2num[a.S]

end


function A333_sts_msg.STABILIZER_INOP.Monitor()

	local a = {E1 = HGSLP, E2 = HYSLP}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = ZPH1, E2 = ZPH10}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = STHSJAMEC_1, E2 = STHSJAMEC_2, E3 = a.S}
	c.S = bOR3(c.E1, c.E2, c.E3)

	local d = {E1 = c.S, E2 = bNOT(b.S)}
	d.S = bAND(d.E1, d.E2)

	STHSJAM = d.S

	A333_sts_msg.STABILIZER_INOP.Video.IN = bool2num[d.S]

end


function A333_sts_msg.L_R_ELEV.Monitor()

	A333_sts_msg.L_R_ELEV.Video.IN = bool2num[SLRELVFT]

end


function A333_sts_msg.L_ELEV.Monitor()

	local a = {E1 = ZPH1, E2 = ZPH10}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = a.S, E2 = HBSLP, E3 = HGSLP}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = SLELVBA_1_VAL, E2 = bNOT(SLELVBA_1)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = SLELVBA_2_VAL, E2 = bNOT(SLELVBA_2)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = SLELVGA_1_VAL, E2 = bNOT(SLELVGA_1)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = SLELVGA_2_VAL, E2 = bNOT(SLELVGA_2)}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = c.S, E2 = d.S}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = e.S, E2 = f.S}
	h.S = bOR(h.E1, h.E2)

	local i = {E1 = SLRELVFT, E2 = b.S}
	i.S = bOR(i.E1, i.E2)

	local j = {E1 = g.S, E2 = h.S}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = bNOT(i.S), E2 = j.S}
	k.S = bAND(k.E1, k.E2)

	SLELNA = j.S

	A333_sts_msg.L_ELEV.Video.IN = bool2num[k.S]

end


function A333_sts_msg.R_ELEV.Monitor()

	local a = {E1 = ZPH1, E2 = ZPH10}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = a.S, E2 = HBSLP, E3 = HYSLP}
	b.S = bAND3(b.E1, b.E2, b.E3)

	local c = {E1 = SRELVBA_1_VAL, E2 = bNOT(SRELVBA_1)}
	c.S = bAND(c.E1, c.E2)

	local d = {E1 = SRELVBA_2_VAL, E2 = bNOT(SRELVBA_2)}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = SRELVYA_1_VAL, E2 = bNOT(SRELVYA_1)}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = SRELVYA_2_VAL, E2 = bNOT(SRELVYA_2)}
	f.S = bAND(f.E1, f.E2)

	local g = {E1 = c.S, E2 = d.S}
	g.S = bOR(g.E1, g.E2)

	local h = {E1 = e.S, E2 = f.S}
	h.S = bOR(h.E1, h.E2)

	local i = {E1 = SLRELVFT, E2 = b.S}
	i.S = bOR(i.E1, i.E2)

	local j = {E1 = g.S, E2 = h.S}
	j.S = bAND(j.E1, j.E2)

	local k = {E1 = bNOT(i.S), E2 = j.S}
	k.S = bAND(k.E1, k.E2)

	SRELNA = j.S

	A333_sts_msg.R_ELEV.Video.IN = bool2num[k.S]

end








function A333_sts_msg.PACK_1_2.Monitor()

	local a = {E1 = AP1I, E2 = AP2I}
	a.S = bAND(a.E1, a.E2)

	AP12INOP = a.S

	A333_sts_msg.PACK_1_2.Video.IN = bool2num[a.S]

end

function A333_sts_msg.PACK_1.Monitor()

	local a = {E1 = EEMER, E2 = JR1SD}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = ZPH1, E2 = ZPH10}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = bNOT(EEMER), E2 = JR1SD, E3 = AP1FCVFC}
	c.S = bAND3(c.E1, c.E2, c.E3)

	local d = {E1 = AP1FCVFC, E2 = bNOT(a.S), E3 = bNOT(AB1AVAIL), E4 = bNOT(AP1PBOF), E5 = bNOT(b.S)}
	d.S = bAND5(d.E1, d.E2, d.E3, d.E4, d.E5)

	local e = {E1 = bNOT(b.S), E2 = AP1PBOF}
	e.S = bAND(e.E1, e.E2)

	local f = {E1 = AP12FT, E2 = AP12INOP }
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = c.S, E2 = d.S, E3 = e.S, E4 = AP1OHT, E5 = AP1F}
	g.S = bOR5(g.E1, g.E2, g.E3, g.E4, g.E5)

	local h = {E1 = g.S, E2 = bNOT(f.S)}
	h.S = bAND(h.E1, h.E2)

	AP1I = g.S

	A333_sts_msg.PACK_1.Video.IN = bool2num[h.S]

end

function A333_sts_msg.PACK_2.Monitor()

	local a = {E1 = ZPH1, E2 = ZPH10}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = AP2FCVFC, E2 = JR2SD}
	b.S = bAND(b.E1, b.E2)

	local c = {E1 = AP2FCVFC, E2 = bNOT(AB2AVAIL), E3 = bNOT(AP2PBOF), E4 = bNOT(a.S)}
	c.S = bAND4(c.E1, c.E2, c.E3, c.E4)

	local d = {E1 = bNOT(a.S), E2 = AP2PBOF}
	d.S = bAND(d.E1, d.E2)

	local e = {E1 = b.S, E2 = c.S, E3 = d.S, E4 = AP2OHT, E5 = AP2F}
	e.S = bOR5(e.E1, e.E2, e.E3, e.E4, e.E5)

	local f = {E1 = AP12FT, E2 = AP12INOP }
	f.S = bOR(f.E1, f.E2)

	local g = {E1 = e.S, E2 = bNOT(f.S)}
	g.S = bAND(g.E1, g.E2)

	AP2I = e.S

	A333_sts_msg.PACK_2.Video.IN = bool2num[g.S]

end








function A333_sts_msg.BAT_1.Monitor()

	A333_sts_msg.BAT_1.Video.IN = bool2num[EBAT1F]

end

function A333_sts_msg.BAT_2.Monitor()

	A333_sts_msg.BAT_2.Video.IN = bool2num[EBAT2F]

end



function A333_sts_msg.GEN_1.Monitor()

	local a = {E1 = EGN1COF, E2 = JR1SD}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = ENG1INOP, E2 = a.S}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = b.S, E2 = bNOT(EEMER)}
	c.S = bAND(c.E1, c.E2)

	A333_sts_msg.GEN_1.Video.IN = bool2num[c.S]

end

function A333_sts_msg.GEN_2.Monitor()

	local a = {E1 = EGN2COF, E2 = JR2SD}
	a.S = bAND(a.E1, a.E2)

	local b = {E1 = ENG2INOP, E2 = a.S}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = b.S, E2 = bNOT(EEMER)}
	c.S = bAND(c.E1, c.E2)

	A333_sts_msg.GEN_2.Video.IN = c.S

end

function A333_sts_msg.APU_GEN.Monitor()

	A333_sts_msg.APU_GEN.Video.IN = bool2num[ENG3INOP]

end







function A333_sts_msg.B_ELEC_PUMP.Monitor()

	local a = {E1 = EEMER, E2 = ZPH1, E3 = ZPH10}
	a.S = bOR3(a.E1, a.E2, a.E3)

	local b = {E1 = HBEPPBOF, E2 = HNVMBPF}
	b.S = bOR(b.E1, b.E2)

	local c = {E1 = bNOT(a.S), E2 = b.S}
	c.S = bAND(c.E1, c.E2)

	A333_sts_msg.B_ELEC_PUMP.Video.IN = c.S

end

function A333_sts_msg.Y_ELEC_PUMP.Monitor()

	A333_sts_msg.Y_ELEC_PUMP.Video.IN = bool2num[HNVMYEPF]

end

















function A333_fws_sts_monitor_functions()

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







