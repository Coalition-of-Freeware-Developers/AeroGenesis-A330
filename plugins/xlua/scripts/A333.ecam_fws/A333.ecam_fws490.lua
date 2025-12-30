--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws490.lua
* Process: FWS System Page Manager
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


--print("LOAD: A333.ecam_fws490.lua")

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
local ecam_du_config = 0


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
local function fws_ecp_sts_local_cache()
    ecam_du_config = A333DR_ecam_du_config
end




local function A333_system_display_manager()

	local displayPage = 0

    if ecam_du_config == 1 then -- Only one ECAM display is "ON" (MONO Mode)

        if A333_ecam_manual_system_page_num > 0 then						-- SYSTEM PAGE MANUALLY SELECTED
            displayPage = A333_ecam_manual_system_page_num
        end

        if A333_ecam_status_system_page_num > 0 then						-- STATUS PAGE SELECTED
            displayPage = A333_ecam_status_system_page_num
        end

        local ecam_show_ew_image = displayPage == 0 and 1 or 0
        A333DR_ecam_ew_image_on_du = A333DR_ecam_ew_image_du_config * ecam_show_ew_image


    elseif ecam_du_config == 2 then -- Both ECAM display units are "ON"

        A333DR_ecam_ew_image_on_du = 1

        if A333_ecam_normal_system_page_num > 0 then						-- FLIGHT PHASE PAGE COMPUTED
            displayPage = A333_ecam_normal_system_page_num
        end

        if A333_ecam_manual_system_page_num > 0 then						-- SYSTEM PAGE MANUALLY SELECTED
            displayPage = A333_ecam_manual_system_page_num
        end


        if A333_ecam_status_system_page_num > 0 then						-- STATUS PAGE SELECTED
            displayPage = A333_ecam_status_system_page_num
        end


        if A333_ecam_advisory_system_page_num > 0 then						-- ADVISORY ACTIVATED (NOTE: NOT CURRENTLY IMPLEMENTED
            if A333_ecam_manual_system_page_num == 0 						-- THIS IS RESET TO ZERO WHEN THE FAIL SYS PAGE CHANGES
                and A333_ecam_status_system_page_num == 0					-- THIS IS RESET TO ZERO WHEN THE FAIL SYS PAGE CHANGES
            then
                displayPage = A333_ecam_failure_system_page_num
            end
        end

        if A333_ecam_failure_system_page_num > 0 then						-- FAILURE WARNING ACTIVATED
            if A333_ecam_manual_system_page_num == 0 						-- THIS IS RESET TO ZERO WHEN THE FAIL SYS PAGE CHANGES
                and A333_ecam_status_system_page_num == 0					-- THIS IS RESET TO ZERO WHEN THE FAIL SYS PAGE CHANGES
            then
                if not(ZSYSPCI) then										-- SYSTEM PAGE AUTO CALL INHIBIT
                    displayPage = A333_ecam_failure_system_page_num
                end
            end
        end

    end

	A333DR_ecam_sys_page = displayPage

end








--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_490()

    fws_ecp_sts_local_cache()
	A333_system_display_manager()

end


--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







