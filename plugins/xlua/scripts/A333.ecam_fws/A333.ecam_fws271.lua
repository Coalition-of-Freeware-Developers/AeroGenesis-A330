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
local bool2num = {[true] = 1, [false] = 0}
local fws_sts_button_timeout = false
local fws_sts_ok_to_display_next_page = true
local ecam_du_config = 0


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

--[[

ENGINE = 1
BLEED = 2
PRESS = 3
ELECAC = 4
ELECDC = 5
HYDRLC = 6
CRCBKR = 7
APU	 = 8
COND = 9
DOOR = 10
WHEEL = 11
FLTCTL = 12
FUEL = 13
CRUISE = 14
STATUS = 15

--]]

--*************************************************************************************--
--** 				              FUNCTION DEFINITIONS         	    				 **--
--*************************************************************************************--
local function fws_ecp_sts_local_cache()
    ecam_du_config = A333DR_ecam_du_config
end




local function fws_status_cue_has_no_messages()
    return (#A333_sts_msg_cue_L + #A333_sts_msg_cue_R) <= 0
end




local function fws_sts_normal_msg_timeout()

    ZMSTSPD = false
    ZSTSNMLD = false

end




local function fs_sts_mono_button_hold_timeout()

    fws_sts_button_timeout = true
    ZSTSNMLD = false
    ZMSTSPD = false

end




local function fws_sts_next_page_display_timeout()

    fws_sts_ok_to_display_next_page = false
    ZMSTSPD = false

end




local function fws_sts_normal_message()

    if ZMSTSPD and not ZSTSNMLD then
        if is_timer_scheduled(fws_sts_normal_msg_timeout) then
            stop_timer(fws_sts_normal_msg_timeout)
        end
        ZSTSNMLD = true
        run_after_time(fws_sts_normal_msg_timeout, 5.0)
    end

end




local function fws_sts_mono_display_control()

    A333_resetManualSystemPageData()
    A333_fws_reset_status_system_page_data()

    if not ZMSTSPD then ZMSTSPD = true end

    if fws_status_cue_has_no_messages() then
        fws_sts_normal_message()

    else -- FWS status cue has messages

        if is_timer_scheduled(fws_sts_normal_msg_timeout) then
            stop_timer(fws_sts_normal_msg_timeout)
        end
        ZSTSNMLD = false

        if ZMSTSPD and fws_sts_ok_to_display_next_page then

            if SDzone0HasMsgsToClear() then
                ClearSDzone0('STS')
                
            elseif SDzone1HasMsgsToClear() then
                ClearSDzone1('STS')
            end

            fws_sts_ok_to_display_next_page = false
            
        end

    end

end




local function fws_sts_display_control()

    A333_resetManualSystemPageData()

    if ZSTSNMLD then        -- Clear "NORMAL" on second button press if alreadydislpayed
        ZSTSNMLD = false
        ZMSTSPD = false

    elseif not ZMSTSPD then
        ZMSTSPD = true

    end



    if fws_status_cue_has_no_messages() then
        fws_sts_normal_message()

    else -- FWS status cue has messages

        if ZMSTSPD then

            --| PRESS OF STS KEY MUST RESULT IN A SEQUENTIAL DISPLAY OF COMPLETE STATUS.
            --| THEREFORE, IF THE STATUS MESSAGE LINES ARE OVERFLOWING THE DISPLAY WE DO A
            --| CLR UNTIL ALL MESSSAGES ARE CLEARED
            if SDzone0HasMsgsToClear() then
                ClearSDzone0('STS')

            elseif SDzone1HasMsgsToClear() then
                ClearSDzone1('STS')


            --| STOP DISPLAYING THE STATUS PAGE
            else
                ZMSTSPD = false
            end

        end -- STATUS PAGE DISPLAY CONDITION

    end -- STATUS CUE CONTENT CONDITION

end




local function fws_ecp_process_sts_button()

    if ecam_du_config == 1 then   -- ECAM display is in "MONO" Mode

        if ZSTSUP then -- STS Button "PRESSED" (Signal Up))

            if not is_timer_scheduled(fs_sts_mono_button_hold_timeout) then
                run_after_time(fs_sts_mono_button_hold_timeout, 180.0)          -- Only allow 3 minute button "HOLD"
            end

            fws_sts_mono_display_control()

        end


        if ZSTSLVL then -- STS Button "HELD" down

        end


        if ZSTSDN then -- STS Button "RELEASED" (Signal Down)

            ZMSTSPD = false

            fws_sts_button_timeout = false
            if is_timer_scheduled(fs_sts_mono_button_hold_timeout) then
                stop_timer(fs_sts_mono_button_hold_timeout)
            end

            fws_sts_ok_to_display_next_page = true
            if not is_timer_scheduled(fws_sts_next_page_display_timeout) then
                run_after_time(fws_sts_next_page_display_timeout, 2.0)
            end

        end




    elseif ecam_du_config == 2 then     -- Both ECAM display units are "ON"

        if ZSTSUP then                  -- STS button press (single pulse)

            if A333DR_ecp_pushbutton_process_step[15] == 1 then
                A333DR_ecp_pushbutton_process_step[15] = 2
                fws_sts_display_control()
                A333DR_ecp_pushbutton_process_step[15] = 0
            end

        end

    end -- DU CONFIG CONDITION

end




local function fws_set_status_page_datarefs()
    A333DR_fws_sts_normal_msg_show = bool2num[ZSTSNMLD]
end




function A333_fws_reset_status_system_page_data()
    if is_timer_scheduled(A333_fws_sts_normal_msg_timeout) then
        stop_timer(A333_fws_sts_normal_msg_timeout)
    end
    ZMSTSPD = false
    ZSTSNMLD = false
end





--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--
function A333_fws_270()

    fws_ecp_sts_local_cache()
    fws_ecp_process_sts_button()
    fws_set_status_page_datarefs()

end

















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
--function flight_start() end



--===| BEFORE PHYSICS |==================================================================
-- function before_physics() end



--=== AFTER PHYSICS =====================================================================
-- function after_physics() end



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







