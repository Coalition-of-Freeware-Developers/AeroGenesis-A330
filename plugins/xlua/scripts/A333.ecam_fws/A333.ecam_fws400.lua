jit.off()
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
*       					     COPYRIGHT © 2021, 2022
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

local bool2num = {[true] = 1, [false] = 0}

local APUshowPageTimeout = 0
local APUpageIsVisible = false
local engineStartInProgress = {false, false}

local ign_start_timeout = 30

--local GetNormalSystemPage
--local Engine1or2StartSequenceinProgress
--local ShowAPUpage
--local SideStickIsDeflected
--local RudderIsDeflected22Degrees
--local Engine1StartSequenceInProgress
--local Engine1StartSequenceHasBegun
--local Engine1StartSequenceHasEnded
--local Engine1N1IsAboveIdle
--local Engine2StartSequenceInProgress
--local Engine2StartSequenceHasBegun
--local Engine2StartSequenceHasEnded
--local Engine2N1IsAboveIdle
--local FlightControlMovementIsDetected
--local GearExtendedAndBaroAltLessThan15000
--local LandingGearDownAndLocked
--local BaroAltitudeLessThan15000

local showEnginePage = false
local monitorStartSwitchAction = false



--*************************************************************************************--
--** 				             FIND X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_apu_switch					= find_dataref("sim/cockpit2/electrical/APU_starter_switch")



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

function A333_setECAMnormalSystemPage()
    A333_ecam_normal_system_page_num = GetNormalSystemPage()
end


function GetNormalSystemPage()

	setShowEnginePage()

	--local show_eng_with_IGN = 0

    if FlightPhaseIsValid then              -- ZPH** = FLIGHT PHASE #

		--[[if simDR_starter_mode == 1 then
			if ign_start_timeout > 0 then
				ign_start_timeout = ign_start_timeout - SIM_PERIOD
			elseif ign_start_timeout < 0 then
				ign_start_timeout = 0
			end
		elseif simDR_starter_mode ~= 1 then
			ign_start_timeout = 30
		end

		if ign_start_timeout == 30 or ign_start_timeout == 0 then
			show_eng_with_IGN = 0
		elseif ign_start_timeout < 30 and ign_start_timeout > 0 then
			show_eng_with_IGN = 1
		end--]]


        if ZPH1 then
            --if Engine1or2StartSequenceinProgress() or simDR_starter_mode == -1 or show_eng_with_IGN == 1 then
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
            --if Engine1or2StartSequenceinProgress() or simDR_starter_mode == -1 then
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

function ShowAPUpage()

	local APUswitchIsOn = toboolean(simDR_apu_switch)

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

function APUpageVisibilityTimeout()
	APUshowPageTimeout = 1
end

function FlightControlMovementIsDetected()
	return bOR(SideStickIsDeflected(), RudderIsDeflected22Degrees())
end

function FltCtlSystemPageDisplaytimeout() end

function SideStickIsDeflected()
	return bOR4(math.abs(simDR_yoke_pitch_ratio_pilot) > 0.1875,
	math.abs(simDR_yoke_roll_ratio_pilot) > 0.15,
	math.abs(simDR_yoke_pitch_ratio_copilot) > 0.1875,
	math.abs(simDR_yoke_roll_ratio_copilot) > 0.15)
end

function RudderIsDeflected22Degrees()
	return math.abs(simDR_rudder1_deg[0]) > 22.0
end











---[[
function Engine1or2StartSequenceinProgress()
	return bOR(Engine1StartSequenceInProgress(), Engine2StartSequenceInProgress())
end



function Engine1StartSequenceInProgress()
	if Engine1StartSequenceHasEnded() then
		engineStartInProgress[1] = false
	elseif Engine1StartSequenceHasBegun() then
		engineStartInProgress[1] = true
	end
	return engineStartInProgress[1]
end

function Engine1StartSequenceHasBegun()
	return bAND(simDR_engine_starter_is_running[0] == 1, bNOT(engineStartInProgress[1]))
end

function Engine1StartSequenceHasEnded()
	return bAND3(simDR_engine_starter_is_running[0] == 0, Engine1N1IsAboveIdle(), engineStartInProgress[1])
end



function Engine2StartSequenceInProgress()
	if Engine2StartSequenceHasEnded() then
		engineStartInProgress[2] = false
	elseif Engine2StartSequenceHasBegun() then
		engineStartInProgress[2] = true
	end
	return engineStartInProgress[2]
end

function Engine2StartSequenceHasBegun()
	return bAND(simDR_engine_starter_is_running[1] == 1, bNOT(engineStartInProgress[2]))
end

function Engine2StartSequenceHasEnded()
	return bAND3(simDR_engine_starter_is_running[1] == 0, Engine2N1IsAboveIdle(), engineStartInProgress[2])
end

function Engine1N1IsAboveIdle()
	return bAND(JR1AIDLE_1A, JR1AIDLE_1B)
end

function Engine2N1IsAboveIdle()
	return bAND(JR2AIDLE_2A, JR2AIDLE_2B)
end

--]]







function startLeverActionTimeout()
	showEnginePage = false
	monitorStartSwitchAction = false
end

function showEnginePageTimeout()
	showEnginePage = false
	monitorStartSwitchAction = false
end

function setShowEnginePage()

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



















function GearExtendedAndBaroAltLessThan15000()
	return bAND(LandingGearDownAndLocked(), BaroAltitudeLessThan15000())
end

function LandingGearDownAndLocked()
	return bAND6(GLGDL_1, GLGDL_2, GNGDL_1, GNGDL_2, GRGDL_1, GRGDL_2)
end

function BaroAltitudeLessThan15000()
	local baro_altitude_threshold1 = NALTI_1 < 15000.0
	local baro_altitude_threshold2 = NALTI_2 < 15000.0
	local baro_altitude_threshold3 = NALTI_3 < 15000.0
	return bOR(baro_altitude_threshold1, baro_altitude_threshold2, baro_altitude_threshold3)
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
