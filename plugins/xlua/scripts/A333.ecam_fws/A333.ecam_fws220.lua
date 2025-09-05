jit.off()
--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws220.lua
* Process: FWS ECP Pushbutton Signals
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


--print("LOAD: A333.ecam_fws220.lua")

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

local emcx_pulseR01 = newLeadingEdgePulse("emcx_pulseR01")
local emcx_pulseR02 = newLeadingEdgePulse("emcx_pulseR02")
local emcx_pulseF03 = newFallingEdgePulse("emcx_pulseF03")
local emcx_pulseF04 = newFallingEdgePulse("emcx_pulseF04")

local clr_pulseR01 = newLeadingEdgePulse("clr_pulseR01")
local clr_pulseR02 = newLeadingEdgePulse("clr_pulseR02")
local clr_pulseR03 = newLeadingEdgePulse("clr_pulseR03")

local rcl_pulsePush01 = newLeadingEdgePulse("rcl_pulsePush01")
local rcl_pulsePush02 = newLeadingEdgePulse("rcl_pulsePush02")
local rcl_pulseRelease03 = newFallingEdgePulse("rcl_pulseRelease03")
local rcl_pulseRelease04 = newFallingEdgePulse("rcl_pulseRelease04")
local rcl_mTrigPush01 = newLeadingEdgeTrigger("rcl_mTrigPush01", 0.5)
local rcl_mTrigRelease02 = newLeadingEdgeTrigger("rcl_mTrigRelease02", 0.5)

local sts_pulseR01 = newLeadingEdgePulse("sts_pulseR01")
local sts_pulseR02 = newLeadingEdgePulse("sts_pulseR02")
local sts_pulseF03 = newFallingEdgePulse("sts_pulseF03")
local sts_pulseF04 = newFallingEdgePulse("sts_pulseF04")

local all_pulseR01 = newLeadingEdgePulse("all_pulseR01")
local all_pulseR02 = newFallingEdgePulse("all_pulseR02")

local eng_pulseR01 = newLeadingEdgePulse("eng_pulseR01")
local bld_pulseR01 = newLeadingEdgePulse("bld_pulseR01")
local press_pulseR01 = newLeadingEdgePulse("press_pulseR01")
local elac_pulseR01 = newLeadingEdgePulse("elac_pulseR01")
local eldc_pulseR01 = newLeadingEdgePulse("eldc_pulseR01")
local hyd_pulseR01 = newLeadingEdgePulse("hyd_pulseR01")
local cb_pulseR01 = newLeadingEdgePulse("cb_pulseR01")
local apu_pulseR01 = newLeadingEdgePulse("apu_pulseR01")
local cond_pulseR01 = newLeadingEdgePulse("cond_pulseR01")
local door_pulseR01 = newLeadingEdgePulse("door_pulseR01")
local whl_pulseR01 = newLeadingEdgePulse("whl_pulseR01")
local fctl_pulseR01 = newLeadingEdgePulse("fctl_pulseR01")
local fuel_pulseR01 = newLeadingEdgePulse("fuel_pulseR01")


local emcx_mTrigR01 = newLeadingEdgeTrigger("emcx_mTrigR01", 0.5)
local emcx_mTrigR02 = newLeadingEdgeTrigger("emcx_mTrigR02", 0.5)

local clr_mTrigR01 = newLeadingEdgeTrigger("clr_mTrigR01", 0.5)

local sts_mTrigR01 = newLeadingEdgeTrigger("sts_mTrigR01", 0.5)
local sts_mTrigR02 = newLeadingEdgeTrigger("sts_mTrigR02", 0.5)

local eng_mTrigR01 = newLeadingEdgeTrigger("eng_mTrigR01", 0.5)
local bld_mTrigR01 = newLeadingEdgeTrigger("bld_mTrigR01", 0.5)
local press_mTrigR01 = newLeadingEdgeTrigger("press_mTrigR01", 0.5)
local elac_mTrigR01 = newLeadingEdgeTrigger("elac_mTrigR01", 0.5)
local eldc_mTrigR01 = newLeadingEdgeTrigger("eldc_mTrigR01", 0.5)
local hyd_mTrigR01 = newLeadingEdgeTrigger("hyd_mTrigR01", 0.5)
local cb_mTrigR01 = newLeadingEdgeTrigger("cb_mTrigR01", 0.5)
local apu_mTrigR01 = newLeadingEdgeTrigger("apu_mTrigR01", 0.5)
local cond_mTrigR01 = newLeadingEdgeTrigger("cond_mTrigR01", 0.5)
local door_mTrigR01 = newLeadingEdgeTrigger("door_mTrigR01", 0.5)
local whl_mTrigR01 = newLeadingEdgeTrigger("whl_mTrigR01", 0.5)
local fctl_mTrigR01 = newLeadingEdgeTrigger("fctl_mTrigR01", 0.5)
local fuel_mTrigR01 = newLeadingEdgeTrigger("fuel_mTrigR01", 0.5)

local all_mTrigR01 = newLeadingEdgeTrigger("all_mTrigR01", 0.5)




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

function A333_fws_ecp_EMER_CANC()

	emcx_pulseR01:update(WEC_2)
	emcx_pulseR02:update(WEMERC)
	emcx_pulseF03:update(WEC_2)
	emcx_pulseF04:update(WEMERC)
	emcx_mTrigR01:update(bOR(emcx_pulseR01.OUT, emcx_pulseR02.OUT))
	emcx_mTrigR02:update(bOR(emcx_pulseF03.OUT, emcx_pulseF04.OUT))

	ZECUP = emcx_mTrigR01.OUT
	ZECDN = emcx_mTrigR02.OUT

end



function A333_fws_ecp_CLR()

	clr_pulseR01:update(WCLR1_2)
	clr_pulseR02:update(WCLR2_2)
	clr_pulseR03:update(WCLR)
	clr_mTrigR01:update(bOR3(clr_pulseR01.OUT, clr_pulseR02.OUT, clr_pulseR03.OUT))

	ZCLRUP = clr_mTrigR01.OUT

end



function A333_fws_ecp_STS()

	sts_pulseR01:update(WSTS_2)
	sts_pulseR02:update(WSTS)
	sts_pulseF03:update(WSTS_2)
	sts_pulseF04:update(WSTS)
	sts_mTrigR01:update(bOR(sts_pulseR01.OUT, sts_pulseR02.OUT))
	sts_mTrigR02:update(bOR(sts_pulseF03.OUT, sts_pulseF04.OUT))

	ZSTSUP = sts_mTrigR01.OUT
	ZSTSDN = sts_mTrigR02.OUT

end



function A333_fws_ecp_RCL()

	rcl_pulsePush01:update(WRCL_2)
	rcl_pulsePush02:update(WRCL)
	rcl_pulseRelease03:update(WRCL_2)
	rcl_pulseRelease04:update(WRCL)

	local a = {E1 = rcl_pulsePush01.OUT, E2 = rcl_pulsePush02.OUT}
	a.S = bOR(a.E1, a.E2)

	local b = {E1 = rcl_pulseRelease03.OUT, E2 = rcl_pulseRelease04.OUT}
	b.S = bOR(b.E1, b.E2)


	rcl_mTrigPush01:update(a.S)
	rcl_mTrigRelease02:update(b.S)

	local c = {E1 = WRCL_2_INV, E2 = WRCL_INV}
	c.S = bOR(c.E1, c.E2)

	local d = {E1 = rcl_mTrigRelease02, E2 = bNOT(c.S)}
	d.S = bAND(d.E1, d.E2)

	ZRCLUP = rcl_mTrigPush01.OUT	-- BUTTON PUSH
	ZRCLDN = rcl_mTrigRelease02.OUT	-- BUTTON RELEASE

end



function A333_fws_ecp_ENG()

	eng_pulseR01:update(WENG_2)
	eng_mTrigR01:update(eng_pulseR01.OUT)

	ZENGUP = eng_mTrigR01.OUT

end



function A333_fws_ecp_BLEED()

	bld_pulseR01:update(WBLD_2)
	bld_mTrigR01:update(bld_pulseR01.OUT)

	ZBLDUP = bld_mTrigR01.OUT

end



function A333_fws_ecp_PRESS()

	press_pulseR01:update(WPRESS_2)
	press_mTrigR01:update(press_pulseR01.OUT)

	ZPRSUP = press_mTrigR01.OUT

end



function A333_fws_ecp_EL_AC()

	elac_pulseR01:update(WELAC_2)
	elac_mTrigR01:update(elac_pulseR01.OUT)

	ZELAUP = elac_mTrigR01.OUT

end



function A333_fws_ecp_EL_DC()

	eldc_pulseR01:update(WELDC_2)
	eldc_mTrigR01:update(eldc_pulseR01.OUT)

	ZELDUP = eldc_mTrigR01.OUT

end



function A333_fws_ecp_HYD()

	hyd_pulseR01:update(WHYD_2)
	hyd_mTrigR01:update(hyd_pulseR01.OUT)

	ZHYDUP = hyd_mTrigR01.OUT

end



function A333_fws_ecp_CB()

	cb_pulseR01:update(WCB_2)
	cb_mTrigR01:update(cb_pulseR01.OUT)

	ZCBUP = cb_mTrigR01.OUT

end



function A333_fws_ecp_APU()

	apu_pulseR01:update(WAPU_2)
	apu_mTrigR01:update(apu_pulseR01.OUT)

	ZAPUUP = apu_mTrigR01.OUT

end



function A333_fws_ecp_COND()

	cond_pulseR01:update(WCOND_2)
	cond_mTrigR01:update(cond_pulseR01.OUT)

	ZCONUP = cond_mTrigR01.OUT

end



function A333_fws_ecp_DOOR()

	door_pulseR01:update(WDOOR_2)
	door_mTrigR01:update(door_pulseR01.OUT)

	ZDORUP = door_mTrigR01.OUT

end



function A333_fws_ecp_WHEEL()

	whl_pulseR01:update(WWHL_2)
	whl_mTrigR01:update(whl_pulseR01.OUT)

	ZWHLUP = whl_mTrigR01.OUT

end



function A333_fws_ecp_F_CTL()

	fctl_pulseR01:update(WFCTL_2)
	fctl_mTrigR01:update(fctl_pulseR01.OUT)

	ZFCLUP = fctl_mTrigR01.OUT

end



function A333_fws_ecp_FUEL()

	fuel_pulseR01:update(WFUEL_2)
	fuel_mTrigR01:update(fuel_pulseR01.OUT)

	ZFULUP = fuel_mTrigR01.OUT

end



function A333_fws_ecp_ALL()

	all_pulseR01:update(WALL_2)
	all_pulseR02:update(WALL)
	all_mTrigR01:update(bOR(all_pulseR01.OUT, all_pulseR02.OUT))

	ZALLUP = all_mTrigR01.OUT

end





--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_220()

	A333_fws_ecp_EMER_CANC()
	A333_fws_ecp_CLR()
	A333_fws_ecp_STS()
	A333_fws_ecp_RCL()

	A333_fws_ecp_ENG()
	A333_fws_ecp_BLEED()
	A333_fws_ecp_PRESS()
	A333_fws_ecp_EL_AC()
	A333_fws_ecp_EL_DC()
	A333_fws_ecp_HYD()
	A333_fws_ecp_CB()
	A333_fws_ecp_APU()
	A333_fws_ecp_COND()
	A333_fws_ecp_DOOR()
	A333_fws_ecp_WHEEL()
	A333_fws_ecp_F_CTL()
	A333_fws_ecp_FUEL()
	A333_fws_ecp_ALL()

end





--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







