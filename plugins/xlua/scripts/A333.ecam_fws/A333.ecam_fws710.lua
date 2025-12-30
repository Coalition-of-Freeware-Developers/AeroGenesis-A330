--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws710.lua
* Process: FWS AURAL ALERT Audio

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


--print("LOAD: A333.ecam_fws710.lua")

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
A333_aural_alert = { -- TYPE: 1=CONTINUOUS PLAY, 2=SINGLE PLAY
	{name = 'Continuous Repetitive Chime', type = 2, status = 0},
	{name = 'Single Chime', type = 1, status = 0},
	{name = 'Cavalry Charge', freqtype = 1, status = 0},
	{name = 'Continuous Cavalry Charge', type = 2, status = 0},
	{name = 'Triple Click', type = 1, status = 0},
	{name = 'Cricket + STALL', type = 1, status = 0},
	{name = 'Intermittent Buzzer', type = 2, status = 0},
	{name = 'Buzzer', type = 2, status = 0},
	{name = 'C Chord', type = 1, status = 0}
}



--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--
local bool2num = {[true] = 1, [false] = 0}
local aural_alert_cue = {}


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
local function resetAudioOut()
    for _, msg in pairs(A333_ewd_msg) do
        if msg.Monitor.audio.IN == 0
            and msg.Monitor.audio.OUT > 0
        then
            msg.Monitor.audio.OUT = 0
        end
    end
end




local function auralAlertIsNotPlaying()
    local alertIsNotPlaying = true
    for _, msg in pairs(A333_ewd_msg) do
        if msg.Monitor.audio.OUT == 1 then
            alertIsNotPlaying = false
            break
        end
    end
    return alertIsNotPlaying
end




local function singleChime2SecondLimit() end
run_after_time(singleChime2SecondLimit, 0.1)									-- INITIALIZE THE TIMER FUNCTION




local function initAlertArray()
    for i = 1, 9 do
        A333_aural_alert[i].status = 0
    end
end




local function setAlertDR(auralWarning)

    initAlertArray()

    if auralWarning > 0 then
        A333_aural_alert[auralWarning].status = 1
    end
    A333DR_fws_aural_alert_crc	= A333_aural_alert[1].status
    A333DR_fws_aural_alert_sc	= A333_aural_alert[2].status
    A333DR_fws_aural_alert_cc	= A333_aural_alert[3].status
    A333DR_fws_aural_alert_ccc	= A333_aural_alert[4].status
    A333DR_fws_aural_alert_tc	= A333_aural_alert[5].status
    A333DR_fws_aural_alert_ckt	= A333_aural_alert[6].status
    A333DR_fws_aural_alert_ib	= A333_aural_alert[7].status
    A333DR_fws_aural_alert_b	= A333_aural_alert[8].status
    A333DR_fws_aural_alert_c	= A333_aural_alert[9].status

end




local function A333_get_aural_alert_msgs()

    aural_alert_cue = {}

    -- Get the activated aural alerts for EW/D Zone 1 (Left & Right))
    for _, msg in ipairs(A333_ewd_msg_cue_L) do
        local lcl_this_ewd_msg = A333_ewd_msg[msg.Name]
        if lcl_this_ewd_msg.isVisible										-- WARNING MESSAGE IS VISIBLE ON THE WARNING DISPLAY
            and lcl_this_ewd_msg.Monitor.audio.IN == 1
        then
            table.insert(aural_alert_cue, {name = lcl_this_ewd_msg.Name})
        end
    end

    for _, msg in ipairs(A333_ewd_msg_cue_R) do
        local lcl_this_ewd_msg = A333_ewd_msg[msg.Name]
        if lcl_this_ewd_msg.isVisible										-- WARNING MESSAGE IS VISIBLE ON THE WARNING DISPLAY
            and lcl_this_ewd_msg.Monitor.audio.IN == 1
        then
            table.insert(aural_alert_cue, {name = lcl_this_ewd_msg.Name})
        end
    end

end




local function A333_fws_aural_alert_monitor()

    resetAudioOut()
    resetMasterAnnunciator()

    if fws_power == 0 then
        setAlertDR(0)
        simDR_plugin_master_caution = 0
        simDR_plugin_master_warning = 0
    else

        if auralAlertIsNotPlaying() then

            local auralWarning = 0

            --aural_alert_cue = {}
            A333_get_aural_alert_msgs()

            for _, msg in ipairs(aural_alert_cue) do

                local aural_alert = A333_ewd_msg[msg.name]

                if aural_alert.isVisible then                                               -- WARNING MESSAGE IS VISIBLE ON THE WARNING DISPLAY
                    if aural_alert.Monitor.audio.IN == 1                                    -- WARNING AUDIO HAS BEEN TRIGGERED
                        and not masterCancelSilence											-- ONE SECOND SILENCE AFTER EVERY CANCEL
                        and aural_alert.Monitor.audio.OUT == 0                              -- WARNING AUDIO HAS NOT BEEN PROCESSED
                    then
                        if aural_alert.Aural > 0 then
                            local aural_alert_type = A333_aural_alert[aural_alert.Aural].type

                            if aural_alert_type == 1 then                                   -- SINGLE PLAY ALERT SOUND

                                if aural_alert.Aural == 2 then                              -- 'SINGLE CHIME' ALERT

                                    if not is_timer_scheduled(singleChime2SecondLimit) then	-- ONLY ALLOW A NEW 'SINGLE CHIME' ONCE EVERY 2 SECONDS
                                        aural_alert.Monitor.audio.OUT = 1					-- SET TO 'PLAY'
                                        auralWarning = aural_alert.Aural					-- ASSIGN THE ALERT SOUND
                                        simDR_plugin_master_caution = 1						-- TRIGGER THE MASTER CAUTION
                                        aural_alert.Monitor.audio.OUT = 2					-- SET TO 'PLAYED'
                                        run_after_time(singleChime2SecondLimit, 2.0)		-- SET THE 'SINGLE CHIME LIMIT' (ONCE EVERY 2 SECONDS)
                                        break												-- DO NOT SEARCH ANY FURTHER FOR AN ALERT
                                    end

                                else                                                        -- ALL OTHER SINGLE PLAY ALERT SOUNDS
                                    aural_alert.Monitor.audio.OUT = 1						-- SET TO 'PLAY'
                                    auralWarning = aural_alert.Aural						-- ASSIGN THE ALERT SOUND
                                    simDR_plugin_master_caution = 1							-- TRIGGER THE MASTER CAUTION
                                    aural_alert.Monitor.audio.OUT = 2						-- SET TO 'PLAYED'
                                    break													-- DO NOT SEARCH ANY FURTHER FOR AN ALERT
                                end

                            elseif aural_alert_type == 2 then                               -- CONTINUOUS PLAY ALERT SOUND
                                aural_alert.Monitor.audio.OUT = 1							-- SET TO 'PLAY'
                                auralWarning = aural_alert.Aural							-- ASSIGN THE ALERT SOUND
                                simDR_plugin_master_warning = 1								-- TRIGGER THE MASTER WARNING
                                break

                            end -- aural_alert_type
                        end -- aural_alert.Aural > 0
                    end -- aural_alert.Monitor.audio.IN == 1

                else -- WARNING MESSAGE IS NOT VISIBLE ON THE WARNING DISPLAY

                    if lcl_this_ewd_msg.Monitor.audio.OUT > 0 then
                        lcl_this_ewd_msg.Monitor.audio.OUT = 0							    -- RESET THE AUDIO OUTPUT
                    end

                end -- aural_alert.isVisible
            end -- aural_alert_cue iteration

            if KAPOA then
                auralWarning = 4
            end

            --auralWarning = auralWarning
            setAlertDR(auralWarning)

        end

    end

end




local function A333_fws_general_audio_attenuation()

    local a = JR1NORUN and JR2NORUN and ZGND

    AUDIOATT = a
    A333DR_audio_attenuation = bool2num[AUDIOATT]

end




--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--
function A333_fws_710()

	A333_fws_aural_alert_monitor()
	A333_fws_general_audio_attenuation()

end






--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







