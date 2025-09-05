--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws410.lua
* Process: FWS "Manual" Mode System Page Selector
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


--print("LOAD: A333.ecam_fws410.lua")

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

local A333_ecp_system_page_pushbutton_counter = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}


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

function A333_ecp_SystemPagePushbuttonProcessing()

	local pushbuttonPulse = {
		ZENGUP,
		ZBLDUP,
		ZPRSUP,
		ZELAUP,
		ZELDUP,
		ZHYDUP,
		ZCBUP,
		ZAPUUP,
		ZCONUP,
		ZDORUP,
		ZWHLUP,
		ZFCLUP,
		ZFULUP,
		}

	for systemPage = 1, 13 do
		if pushbuttonPulse[systemPage] then
			A333_ecp_ProcessManualPushbutton(systemPage)
		end
	end

end

function A333_ecp_ProcessManualPushbutton(systemPage)
	if A333DR_ecp_pushbutton_process_step[systemPage] == 1 then
		A333DR_ecp_pushbutton_process_step[systemPage] = 2
		A333_ecp_SetSystemPageManual(systemPage)
        A333DR_ecp_pushbutton_process_step[systemPage] = 0
	end
end







function A333_ecp_ALL_pushbuttonProcessing()

	if ZALLUP and A333DR_ecp_pushbutton_process_step[14] == 0.5 then
        if not is_timer_scheduled(A333_ecp_ALL_pushbuttonCycleTimer) then
			run_timer(A333_ecp_ALL_pushbuttonCycleTimer, 0.0, 2.0)
        end

    elseif A333DR_ecp_pushbutton_process_step[14] == 0 then
        if is_timer_scheduled(A333_ecp_ALL_pushbuttonCycleTimer) then
            stop_timer(A333_ecp_ALL_pushbuttonCycleTimer)
        end

    end

end

function A333_ecp_ALL_pushbuttonCycleTimer()

	local activeSystemPage = A333DR_ecam_sys_page

	if activeSystemPage == 13
		and A333DR_ecp_pushbutton_process_step[14] == 0.5
	then
		activeSystemPage = 0
	end

	A333DR_ecp_pushbutton_process_step[14] = 1.0

	if activeSystemPage < 13 then
		activeSystemPage = math.min(13, activeSystemPage + 1)
		A333DR_ecp_pushbutton_process_step[activeSystemPage] = 1
		A333_ecp_ProcessManualPushbutton(activeSystemPage)
	end

end








function A333_ecp_SetSystemPageManual(systemPage)

	A333_resetStatusSystemPageData()

    -- INIT THE PB COUNTER ON FIRST PRESS OF A (NEW/DIFF) SYS PAGE PUSHBUTTON
    if A333_ecp_system_page_pushbutton_counter[systemPage] == 0 then
        A333_ecp_InitManualSystemPagePushbuttonCounters()
    end

	-- INCREMENT THE PUSHBUTTON COUNTER
    A333_ecp_system_page_pushbutton_counter[systemPage] = math.min(2, A333_ecp_system_page_pushbutton_counter[systemPage] + 1)

	-- SECOND PRESS OF SYS PAGE PUSHBUTTON
    if A333_ecp_system_page_pushbutton_counter[systemPage] == 2 then
		systemPage = 0
		A333_ecp_InitManualSystemPagePushbuttonCounters()
    end

	A333_ecp_SetManualSystemPage(systemPage)
	A333_ecp_SetManualSystemPageAnnun(systemPage)



end


function A333_ecp_InitManualSystemPagePushbuttonCounters()
    for i = 1, 13 do
        A333_ecp_system_page_pushbutton_counter[i] = 0
    end
end


function A333_ecp_setManualSystemPageToZero()
	A333_ecam_manual_system_page_num = 0
end


function A333_ecp_SetManualSystemPage(systemPage)
	A333_ecam_manual_system_page_num = systemPage
end


function A333_ecp_SetManualSystemPageAnnun(systemPage)
	A333_ecp_initManualSystemPageAnnun()
	for i = 1, 13 do
		if systemPage == i then
			A333DR_ecp_sys_page_pushbutton_annun[systemPage-1] = 1
		end
	end
end


function A333_ecp_initManualSystemPageAnnun()
	for i = 1, 13 do
		A333DR_ecp_sys_page_pushbutton_annun[i-1] = 0
	end
end


function A333_resetManualSystemPageData()
	A333_ecp_setManualSystemPageToZero()
	A333_ecp_InitManualSystemPagePushbuttonCounters()
	A333_ecp_initManualSystemPageAnnun()
end



--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_410()

    A333_ecp_SystemPagePushbuttonProcessing()
	A333_ecp_ALL_pushbuttonProcessing()

end





--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







