--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws400.lua
* Process: FWS "Normal" Mode (Auto-Flight Phase) System Page Selector
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


--print("LOAD: A333.ecam_fws400.lua")

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
local APUshowPageTimeout = 0
local APUpageIsVisible = false
local engineStartInProgress = {false, false}
local showEnginePage = false
local monitorStartSwitchAction = false

local m = math


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
local function APUpageVisibilityTimeout()
    APUshowPageTimeout = 1
end




local function ShowAPUpage()

    local APUswitchIsOn = simDR_APU_switch_mode > 0

    if APUswitchIsOn then

        if APUshowPageTimeout == 0 then
            APUpageIsVisible = true
        end
    else
        if is_timer_scheduled(APUpageVisibilityTimeout) then
            stop_timer(APUpageVisibilityTimeout)
        end
        APUshowPageTimeout = 0
        APUpageIsVisible = false
    end

    if simDR_APU_n1_pct >= 95.0 then
        if APUshowPageTimeout == 0 then
            if not is_timer_scheduled(APUpageVisibilityTimeout) then
                run_after_time(APUpageVisibilityTimeout, 10.0)
            end
        else
            APUpageIsVisible = false
        end
    end

    return APUpageIsVisible

end




local function SideStickIsDeflected()
    return m.abs(simDR_yoke_pitch_ratio_pilot) > 0.1875
        or m.abs(simDR_yoke_roll_ratio_pilot) > 0.15
        or m.abs(simDR_yoke_pitch_ratio_copilot) > 0.1875
        or m.abs(simDR_yoke_roll_ratio_copilot) > 0.15
end




local function RudderIsDeflected22Degrees()
    return m.abs(simDR_rudder1_deg[0]) > 22.0
end





local function FlightControlMovementIsDetected()
    return SideStickIsDeflected() or RudderIsDeflected22Degrees()
end




local function FltCtlSystemPageDisplaytimeout() end




local function BaroAltitudeLessThan15000()

    local baro_altitude_threshold1 = (NALTI_1 < 15000.0)
    local baro_altitude_threshold2 = (NALTI_2 < 15000.0)
    local baro_altitude_threshold3 = (NALTI_3 < 15000.0)

    return baro_altitude_threshold1 or baro_altitude_threshold2 or baro_altitude_threshold3

end




local function LandingGearDownAndLocked()
    return GLGDL_1 and GLGDL_2 and GNGDL_1 and GNGDL_2 and GRGDL_1 and GRGDL_2
end




local function GearExtendedAndBaroAltLessThan15000()
    return LandingGearDownAndLocked() and BaroAltitudeLessThan15000()
end





local function startLeverActionTimeout()
    showEnginePage = false
    monitorStartSwitchAction = false
end




local function showEnginePageTimeout()
    showEnginePage = false
    monitorStartSwitchAction = false
end




local function setShowEnginePage()

    if simDR_starter_mode ~= 0 then		-- CRANK or IGN/START

        if ZR12NORUN then -- no engines running

            if showEnginePage == false then

                showEnginePage = true
                monitorStartSwitchAction = true
                if is_timer_scheduled(startLeverActionTimeout) then
                    stop_timer(startLeverActionTimeout)
                end
                if not is_timer_scheduled(startLeverActionTimeout) then
                    run_after_time(startLeverActionTimeout, 30.0)
                end

            end

        elseif (not JR1NORUN and JR2NORUN)	-- one engine running
            or (not JR2NORUN and JR1NORUN)
        then

            showEnginePage = true
            monitorStartSwitchAction = false
            if is_timer_scheduled(startLeverActionTimeout) then
                stop_timer(startLeverActionTimeout)
            end

        elseif not JR1NORUN and not JR2NORUN then -- both engines running

            if showEnginePage == true then
                if not is_timer_scheduled(showEnginePageTimeout) then
                    run_after_time(showEnginePageTimeout, 15.0)
                end

            end

        end

    else

        showEnginePage = false
        monitorStartSwitchAction = false
        if is_timer_scheduled(startLeverActionTimeout) then
            stop_timer(startLeverActionTimeout)
        end
        if is_timer_scheduled(showEnginePageTimeout) then
            stop_timer(showEnginePageTimeout)
        end

    end


end





local function GetNormalSystemPage()

	setShowEnginePage()

    if FlightPhaseIsValid then              -- ZPH** = FLIGHT PHASE #

        if ZPH1 then
			if showEnginePage then
                return ENGINE
            elseif ShowAPUpage() then
                return APU
            else
                return DOOR
            end
        end

        if ZPH2 then
            if FlightControlMovementIsDetected() then
                run_after_time(FltCtlSystemPageDisplaytimeout, 20.0)
            end

			if showEnginePage then
                return ENGINE
            elseif is_timer_scheduled(FltCtlSystemPageDisplaytimeout) then
                return FLTCTL
            else
                return WHEEL
            end
        end

        if ZPH3 then return ENGINE end

        if ZPH4 then return ENGINE end

        if ZPH5 then return ENGINE end

        if ZPH6 then
            if GearExtendedAndBaroAltLessThan15000() then
                return WHEEL
            else
                return CRUISE
            end
        end

        if ZPH7 then return WHEEL end

        if ZPH8 then return WHEEL end

        if ZPH9 then return WHEEL end

        if ZPH10 then return DOOR end

    else
        return 0    -- NO FLIGHT PHASE PAGE TO DISPLAY
    end

end




local function A333_setECAMnormalSystemPage()
    A333_ecam_normal_system_page_num = GetNormalSystemPage()
end

























local function Engine1N1IsAboveIdle()
    return JR1AIDLE_1A and JR1AIDLE_1B
end




local function Engine2N1IsAboveIdle()
    return JR2AIDLE_2A and JR2AIDLE_2B
end




local function Engine1StartSequenceHasBegun()
    return simDR_engine_starter_is_running[0] == 1 and (not engineStartInProgress[1])
end




local function Engine1StartSequenceHasEnded()
    return simDR_engine_starter_is_running[0] == 0 and Engine1N1IsAboveIdle() and engineStartInProgress[1]
end




local function Engine2StartSequenceHasBegun()
    return simDR_engine_starter_is_running[1] == 1 and (not engineStartInProgress[2])
end




local function Engine2StartSequenceHasEnded()
    return simDR_engine_starter_is_running[1] == 0 and Engine2N1IsAboveIdle() and engineStartInProgress[2]
end




function monitorStartSwitches()
	if monitorStartSwitchAction then
		if A333_switches_engine1_start_pos == 1 and A333_switches_engine1_start_lift == 0
			or A333_switches_engine2_start_pos == 1 and A333_switches_engine2_start_lift == 0
		then
			if is_timer_scheduled(startLeverActionTimeout) then
				stop_timer(startLeverActionTimeout)
			end
			monitorStartSwitchAction = false
		end
	end
end









function Engine1StartSequenceInProgress()
    if Engine1StartSequenceHasEnded() then
        engineStartInProgress[1] = false
    elseif Engine1StartSequenceHasBegun() then
        engineStartInProgress[1] = true
    end
    return engineStartInProgress[1]
end




function Engine2StartSequenceInProgress()
    if Engine2StartSequenceHasEnded() then
        engineStartInProgress[2] = false
    elseif Engine2StartSequenceHasBegun() then
        engineStartInProgress[2] = true
    end
    return engineStartInProgress[2]
end










--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_400()

	A333_setECAMnormalSystemPage()

end



--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")
