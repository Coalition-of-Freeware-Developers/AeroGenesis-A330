--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws270.lua
* Process: FWS ECP STS PROCESSING
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


--print("LOAD: A333.ecam_fws270.lua")

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

local DoStatusContentCheck = false
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

function A333_fws_STS()

	if ZSTSUP then	-- STS BUTTON PRESS (PULSE)
		if A333DR_ecp_pushbutton_process_step[15] == 1 then
			A333DR_ecp_pushbutton_process_step[15] = 2
			A333_ecp_ProcessSTS()
			A333DR_ecp_pushbutton_process_step[15] = 0
		end
	end

end




function A333_ecp_ProcessSTS()

	A333_resetManualSystemPageData()

	-----| NO COMPUTED STATUS (STATUS EMPTY)
	if A333_fws_status_is_empty() then							-- NO STATUS MESSAGES IN CUE
		A333_fws_sts_normal_msg()								-- SHOW THE 'NORMAL' STATUS MESSAGE




	-----| STATUS IS COMPUTED (STATUS NOT EMPTY)
	else

		-- CANX NORMAL MESSAGE IF DISPLAYED
		if A333DR_fws_sts_normal_msg_show == 1 then
			A333_resetStatusSystemPageData()
		end


		-- STATUS PAGE IS NOT CURRENLY DISPLAYED
		if not ZSTSPD then
			ZMSTSPD = true										-- SET MANUAL STATUS PAGE FLAG


		-- STATUS PAGE IS CURRENTLY DISPLAYED
		else

			-- PRESS OF CLR OR STS KEY MUST RESULT IN A SEQUENTIAL DISPLAY OF COMPLETE STATUS
			-- THEREFORE, IF THERE ARE MESSAGES OVERFLOWING THE SD WE DO A CLEAR (CLR)
			if SDzone0HasMsgsToClear() then
				ClearSDzone0('STS')
			elseif SDzone1HasMsgsToClear() then
				ClearSDzone1('STS')


			-- STATUS MANUALLY DEACTIVATED:
			else
				ZMSTSPD = false									-- RESET MANUAL STATUS PAGE FLAG TO 'DEACTIVATED'
				ZASTSPD = false									-- STATUS PAGE WAS PREVIOUSLY OPENED AUTOMATICALLY, RESET FLAG TO 'DEACTIVATED'
			end

		end


	end
end






function A333_fws_status_auto_deactivate()

	if not A333_fws_status_is_empty() then						-- STATUS HAS MESSAGES
		DoStatusContentCheck = true								-- SET THE FLAG
	end

	if DoStatusContentCheck then
		if ZSTSPD												-- STATUS PAGE IS DISPLAYED
			and A333DR_ecp_pushbutton_process_step[15] == 0		-- STS PUSHBUTTON IS NOT BEING PROCESSED
			and A333_fws_status_is_empty()						-- STATUS HAS BECOME EMPTY

		then
			A333_fws_sts_normal_msg()							-- SHOW THE 'NORMAL' STATUS MESSAGE
			DoStatusContentCheck = false						-- RESET THE FLAG
		end
	end

end









-- STATUS PAGE 'NORMAL' MESSAGE PROCESSING
function A333_fws_sts_normal_msg()
	A333DR_fws_sts_normal_msg_show = 1 - A333DR_fws_sts_normal_msg_show
	if A333DR_fws_sts_normal_msg_show == 1 then
		run_after_time(A333_fws_show_sts_normal_timeout, 3.0)
	else
		A333_resetStatusSystemPageData()
	end
end

function A333_fws_show_sts_normal_timeout()
	A333_resetStatusSystemPageData()
end








function A333_resetStatusSystemPageData()
	if is_timer_scheduled(A333_fws_show_sts_normal_timeout) then
		stop_timer(A333_fws_show_sts_normal_timeout)
	end
	A333DR_fws_sts_normal_msg_show = 0
	ZMSTSPD = false
end






-- GET MANUAL STATUS EMPTY
function A333_fws_status_is_empty()
	return (#A333_sts_msg_cue_L + #A333_sts_msg_cue_R) <= 0
end









-----| STS PUSHBUTTON ANNUNCIATOR
-----------------------------------------------------------------------------------------
function A333_fws_STS_annun()
	A333DR_ecp_sts_pushbutton_annun = bool2num[ZSTSPD]
end










--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_270()

	A333_fws_STS()
	A333_fws_status_auto_deactivate()
	A333_fws_STS_annun()

end



--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







