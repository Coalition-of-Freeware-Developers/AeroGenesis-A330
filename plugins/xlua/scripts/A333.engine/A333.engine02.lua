jit.off()
--[[
*****************************************************************************************
* Script Name :  A333.engine02.lua
*
* Author Name :	 Jim Gregory
*
* Revisions:
* -- DATE --  --- REV NO ---  --- DESCRIPTION -------------------------------------------
*
*
*
*
*
*****************************************************************************************
*       						   COPYRIGHT © 2021
*					 	   L A M I N A R   R E S E A R C H
*								  ALL RIGHTS RESERVED
*****************************************************************************************
--]]



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

local airConOn			= {0.0, 0.0}



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
local EPRtestFlag = 0
function A333_EPR_test_CMDhandler(phase, duration)

	if phase == 0 then
		EPRtestFlag = 1 - EPRtestFlag
	end

end

--*************************************************************************************--
--** 				             CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--

A333CMD_test_epr	= create_command("laminar/A333/test/epr", "EPR TEST TOGGLE", A333_EPR_test_CMDhandler)



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

function A333_engine_aircon_status()

	airConOn = {0.0, 0.0}

	-- ENGINE 1
	if simDR_engines_running[0] == 1
		and A333DR_eng1_bleed_button_pos == 1
		-- and APU OFF ????
	then
		if A333DR_pack1_flow_ratio > 0 then
			airConOn[1] = airConOn[1] + 1
		end
		if (simDR_engines_running[1] == 0
			and A333DR_pack_isol_valve_pos == 1
			and A333DR_pack2_flow_ratio > 0)
		then
			airConOn[1] = airConOn[1] + 1
		end
	end


	-- ENGINE 2
	if simDR_engines_running[1] == 1
		and A333DR_eng2_bleed_button_pos == 1
	then
		if A333DR_pack2_flow_ratio > 0 then
			airConOn[2] = airConOn[2] + 1
		end
		if (simDR_engines_running[0] == 0
			and A333DR_pack_isol_valve_pos == 1
			and A333DR_pack1_flow_ratio > 0)
			-- and APU OFF ????
		then
			airConOn[2] = airConOn[2] + 1
		end
	end


end




function A333_epr_TO()

	local eprAdjAirConOn	= {-0.006, -0.010}
	local oatAdjAInacelleOn	= {0.9, 1.20}
	local oatAdjAIwingOn	= {0.8, 1.30}
	local oatAdjAC			= rescale(7500.0, eprAdjAirConOn[1], 8500.0, eprAdjAirConOn[2], simDR_altitude_msl)
	local oatAdjAInacelle	= rescale(7500.0, oatAdjAInacelleOn[1], 8500.0, oatAdjAInacelleOn[2], simDR_altitude_msl)
	local oatAdjAIwing		= rescale(7500.0, oatAdjAIwingOn[1], 8500.0, oatAdjAIwingOn[2], simDR_altitude_msl)
	local oatAdjusted		= {0.0, 0.0}
	local oatLOindex		= {0.0, 0.0}
	local oatHIindex		= {0.0, 0.0}
	local altLOindex		= 0.0
	local altHIindex		= 0.0
	local oatDeltaRatio		= {0.0, 0.0}
	local altDeltaRatio 	= 0.0
	local eprAltLO			= {0.0, 0.0}
	local eprAltHI			= {0.0, 0.0}
	local eprTO				= {0.0, 0.0}


	-- GET HI AND LO ALTITUDE TABLE INDEXES
	if simDR_altitude_msl <= -2000.0 then
		altLOindex = -2000.0
	else
		for index = -2000.0, 15000.0, 1000.0 do
			if index <= simDR_altitude_msl then
				altLOindex = index
			end
		end
	end
	altHIindex = altLOindex + 1000.0


	-- GET ENGINE SPECIFIC VALUES
	for i = 1, 2 do

		-- ADJUST TEMP FOR ENGINE NACELLE AND WING ANTI-ICE ON
		oatAdjusted[i] 		= simDR_OAT +
							  (simDR_engine_inlet_heat[i-1] * oatAdjAInacelle) +
							  (simDR_wing_surface_heat * oatAdjAIwing)


		-- GET HI AND LO TEMP TABLE INDEXES
		if oatAdjusted[i]   < -8.0 then
			oatHIindex[i] 	= -8.0
			oatLOindex[i] 	= -60.0
		else
			for index = -8.0, 56.0, 2.0 do
				if index <= oatAdjusted[i] then
					oatLOindex[i] = index
					oatHIindex[i] = oatLOindex[i] + 2.0
				end
			end
		end


		-- CALC TEMP DELTA RATIO
		oatDeltaRatio[i]	= rescale2(oatLOindex[i], 0.0, oatHIindex[i], 1.0, oatAdjusted[i])
		altDeltaRatio		= rescale2(altLOindex, 0.0, altHIindex, 1.0, simDR_altitude_msl)



		-- CALC LO/HI EPR VALUES
		eprAltLO[i]			= rescale(0.0, A333_epr_takeoff[oatLOindex[i]][altLOindex], 1.0, A333_epr_takeoff[oatHIindex[i]][altLOindex], oatDeltaRatio[i])
		eprAltHI[i]			= rescale(0.0, A333_epr_takeoff[oatLOindex[i]][altHIindex], 1.0, A333_epr_takeoff[oatHIindex[i]][altHIindex], oatDeltaRatio[i])


		-- CALC EPR
		eprTO[i] 			= rescale(0.0, eprAltLO[i], 1.0, eprAltHI[i], altDeltaRatio)


		-- ADJUST EPR FOR AIR CON
		eprTO[i] 			= eprTO[i] + (airConOn[i] * oatAdjAC)

	end


	-- SET THE EPR DATAREF VALUES
	A333DR_epr_limit_to[0] 	= eprTO[1]
	A333DR_epr_limit_to[1] 	= eprTO[2]
	A333DR_epr_limit_to[2]	= (eprTO[1] + eprTO[2]) * 0.50

end






function A333_epr_FLEX()

	local eprAdjAirConOn	= {-0.006, -0.010}
	local oatAdjAInacelleOn	= {0.9, 1.20}
	local oatAdjAIwingOn	= {0.8, 1.30}
	local oatAdjAC			= rescale(7500.0, eprAdjAirConOn[1], 8500.0, eprAdjAirConOn[2], simDR_altitude_msl)
	local oatAdjAInacelle	= rescale(7500.0, oatAdjAInacelleOn[1], 8500.0, oatAdjAInacelleOn[2], simDR_altitude_msl)
	local oatAdjAIwing		= rescale(7500.0, oatAdjAIwingOn[1], 8500.0, oatAdjAIwingOn[2], simDR_altitude_msl)
	local oatAdjusted		= {0.0, 0.0}
	local oatLOindex		= {0.0, 0.0}
	local oatHIindex		= {0.0, 0.0}
	local altLOindex		= 0.0
	local altHIindex		= 0.0
	local oatDeltaRatio		= {0.0, 0.0}
	local altDeltaRatio 	= 0.0
	local eprAltLO			= {0.0, 0.0}
	local eprAltHI			= {0.0, 0.0}
	local eprFLEX			= {0.0, 0.0}


	-- GET HI AND LO ALTITUDE TABLE INDEXES
	if simDR_altitude_msl <= -2000.0 then
		altLOindex = -2000.0
	else
		for index = -2000.0, 15000.0, 1000.0 do
			if index <= simDR_altitude_msl then
				altLOindex = index
			end
		end
	end
	altHIindex = altLOindex + 1000.0


	-- GET ENGINE SPECIFIC VALUES
	for i = 1, 2 do

		-- ADJUST TEMP FOR ENGINE NACELLE AND WING ANTI-ICE ON
		oatAdjusted[i] 		= simDR_flex_temp[i-1] +
							  (simDR_engine_inlet_heat[i-1] * oatAdjAInacelle) +
							  (simDR_wing_surface_heat * oatAdjAIwing)


		-- GET HI AND LO TEMP TABLE INDEXES
		if oatAdjusted[i]   < -8.0 then
			oatHIindex[i] 	= -8.0
			oatLOindex[i] 	= -60.0
		else
			for index = -8.0, 76.0, 2.0 do
				if index <= oatAdjusted[i] then
					oatLOindex[i] = index
					oatHIindex[i] = oatLOindex[i] + 2.0
				end
			end
		end


		-- CALC TEMP DELTA RATIO
		oatDeltaRatio[i]	= rescale2(oatLOindex[i], 0.0, oatHIindex[i], 1.0, oatAdjusted[i])
		altDeltaRatio		= rescale2(altLOindex, 0.0, altHIindex, 1.0, simDR_altitude_msl)



		-- CALC LO/HI EPR VALUES
		eprAltLO[i]			= rescale(0.0, A333_epr_takeoff[oatLOindex[i]][altLOindex], 1.0, A333_epr_takeoff[oatHIindex[i]][altLOindex], oatDeltaRatio[i])
		eprAltHI[i]			= rescale(0.0, A333_epr_takeoff[oatLOindex[i]][altHIindex], 1.0, A333_epr_takeoff[oatHIindex[i]][altHIindex], oatDeltaRatio[i])


		-- CALC EPR
		eprFLEX[i] 			= rescale(0.0, eprAltLO[i], 1.0, eprAltHI[i], altDeltaRatio)


		-- ADJUST EPR FOR AIR CON
		eprFLEX[i] 			= eprFLEX[i] + (airConOn[i] * oatAdjAC)

	end


	-- SET THE EPR DATAREF VALUES
	A333DR_epr_limit_flex[0] 	= eprFLEX[1]
	A333DR_epr_limit_flex[1] 	= eprFLEX[2]
	A333DR_epr_limit_flex[2]	= (eprFLEX[1] + eprFLEX[2]) * 0.50

end






function A333_epr_MC()

	local tatAdjAC			= 0.019
	local tatAdjAInacelle	= 1.20
	local tatAdjAIwing		= 1.30
	local tatAdjusted		= {0.0, 0.0}
	local tatLOindex		= {0.0, 0.0}
	local tatHIindex		= {0.0, 0.0}
	local altLOindex		= 0.0
	local altHIindex		= 0.0
	local tatDeltaRatio		= {0.0, 0.0}
	local altDeltaRatio 	= 0.0
	local eprAltLO			= {0.0, 0.0}
	local eprAltHI			= {0.0, 0.0}
	local eprMC				= {0.0, 0.0}
	local airConOff 		= {0, 0}


	-- GET HI AND LO ALTITUDE TABLE INDEXES
	if simDR_altitude_msl <= -1000.0 then
		altLOindex = -1000.0
	else
		for index = -1000.0, 35000.0, 4000.0 do
			if index <= simDR_altitude_msl then
				altLOindex = index
			end
		end
	end
	altHIindex = altLOindex + 4000.0


	-- GET ENGINE SPECIFIC VALUES
	for i = 1, 2 do

		-- ADJUST TEMP FOR ENGINE NACELLE AND WING ANTI-ICE ON
		tatAdjusted[i] 		= simDR_TAT +
							  (simDR_engine_inlet_heat[i-1] * tatAdjAInacelle) +
							  (simDR_wing_surface_heat * tatAdjAIwing)



		-- GET HI AND LO TEMP TABLE INDEXES
		if tatAdjusted[i] 	< -38.0 then
			tatLOindex[i] 	= -60.0
			tatHIindex[i] 	= -38.0
		else
			for index = -38.0, 60.0, 4.0 do
				if index >= 50.0 then					-- (50.0 / 54.0 / 58.0 / 62.0)
					local idx = index + 2				-- = (52.0 / 56.0 / 60.0/ 64.0)   ADJUST DUE TO INCREMENT CHANGE @ 52.0
					if idx <= tatAdjusted[i] then
						tatLOindex[i] = idx
						tatHIindex[i] = tatLOindex[i] + 4.0
					end
				else
					if index <= tatAdjusted[i] then
						tatLOindex[i] = index
						tatHIindex[i] = tatLOindex[i] + 4.0
					end
				end
			end
		end


		-- CALC TEMP DELTA RATIO
		tatDeltaRatio[i]	= rescale2(tatLOindex[i], 0.0, tatHIindex[i], 1.0, tatAdjusted[i])
		altDeltaRatio		= rescale2(altLOindex, 0.0, altHIindex, 1.0, simDR_altitude_msl)

		-- CALC LO/HI EPR VALUES
		eprAltLO[i]			= rescale(0.0, A333_epr_max_cont[tatLOindex[i]][altLOindex], 1.0, A333_epr_max_cont[tatHIindex[i]][altLOindex], tatDeltaRatio[i])
		eprAltHI[i]			= rescale(0.0, A333_epr_max_cont[tatLOindex[i]][altHIindex], 1.0, A333_epr_max_cont[tatHIindex[i]][altHIindex], tatDeltaRatio[i])


		-- CALC EPR
		eprMC[i] 			= rescale(0.0, eprAltLO[i], 1.0, eprAltHI[i], altDeltaRatio)


		-- ADJUST EPR FOR AIR CON
		if airConOn[i] < 1 then airConOff[i] = 1 end
		eprMC[i] 			= eprMC[i] + (airConOff[i] * tatAdjAC)

	end


	-- SET THE EPR DATAREF VALUES
	A333DR_epr_limit_mc[0] 	= eprMC[1]
	A333DR_epr_limit_mc[1] 	= eprMC[2]
	A333DR_epr_limit_mc[2]	= (eprMC[1] + eprMC[2]) * 0.50

end








function A333_epr_GA()

	local eprAdjAirConOn	= {0.008, 0.010}
	local tatAdjAInacelleOn	= {0.9, 1.20}
	local tatAdjAIwingOn	= {0.8, 1.20}
	local tatAdjAC			= rescale(7500.0, eprAdjAirConOn[1], 8500.0, eprAdjAirConOn[2], simDR_altitude_msl)
	local tatAdjAInacelle	= rescale(7500.0, tatAdjAInacelleOn[1], 8500.0, tatAdjAInacelleOn[2], simDR_altitude_msl)
	local tatAdjAIwing		= rescale(7500.0, tatAdjAIwingOn[1], 8500.0, tatAdjAIwingOn[2], simDR_altitude_msl)
	local tatAdjusted		= {0.0, 0.0}
	local tatLOindex		= {0.0, 0.0}
	local tatHIindex		= {0.0, 0.0}
	local altLOindex		= 0.0
	local altHIindex		= 0.0
	local tatDeltaRatio		= {0.0, 0.0}
	local altDeltaRatio 	= 0.0
	local eprAltLO			= {0.0, 0.0}
	local eprAltHI			= {0.0, 0.0}
	local eprGA				= {0.0, 0.0}
	local airConOff 		= {0, 0}


	-- GET HI AND LO ALTITUDE TABLE INDEXES
	if simDR_altitude_msl <= -2000.0 then
		altLOindex = -2000.0
	else
		for index = -2000.0, 15000.0, 1000.0 do
			if index <= simDR_altitude_msl then
				altLOindex = index
			end
		end
	end
	altHIindex = altLOindex + 1000.0


	-- GET ENGINE SPECIFIC VALUES
	for i = 1, 2 do

		-- ADJUST TEMP FOR ENGINE NACELLE AND WING ANTI-ICE ON
		tatAdjusted[i] 		= simDR_TAT +
							  (simDR_engine_inlet_heat[i-1] * tatAdjAInacelle) +
							  (simDR_wing_surface_heat * tatAdjAIwing)


		-- GET HI AND LO TEMP TABLE INDEXES
		if tatAdjusted[i]   < -8.0 then
			tatHIindex[i] 	= -8.0
			tatLOindex[i] 	= -60.0
		else
			for index = -8.0, 60.0, 2.0 do
				if index <= tatAdjusted[i] then
					tatLOindex[i] = index
					tatHIindex[i] = tatLOindex[i] + 2.0
				end
			end
		end


		-- CALC TEMP DELTA RATIO
		tatDeltaRatio[i]	= rescale2(tatLOindex[i], 0.0, tatHIindex[i], 1.0, tatAdjusted[i])
		altDeltaRatio		= rescale2(altLOindex, 0.0, altHIindex, 1.0, simDR_altitude_msl)


		-- CALC LO/HI EPR VALUES
		eprAltLO[i]			= rescale(0.0, A333_epr_go_around[tatLOindex[i]][altLOindex], 1.0, A333_epr_go_around[tatHIindex[i]][altLOindex], tatDeltaRatio[i])
		eprAltHI[i]			= rescale(0.0, A333_epr_go_around[tatLOindex[i]][altHIindex], 1.0, A333_epr_go_around[tatHIindex[i]][altHIindex], tatDeltaRatio[i])


		-- CALC EPR
		eprGA[i] 			= rescale(0.0, eprAltLO[i], 1.0, eprAltHI[i], altDeltaRatio)

		-- ADJUST EPR FOR AIR CON
		if airConOn[i] < 1 then airConOff[i] = 1 end
		eprGA[i] 			= eprGA[i] + (airConOff[i] * tatAdjAC)

	end


	-- SET THE EPR DATAREF VALUES
	A333DR_epr_limit_ga[0] 	= eprGA[1]
	A333DR_epr_limit_ga[1] 	= eprGA[2]
	A333DR_epr_limit_ga[2]	= (eprGA[1] + eprGA[2]) * 0.50

end



















--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_ALL_engine02()

	A333_engine_aircon_status()
	A333_epr_TO()
	A333_epr_FLEX()
	A333_epr_MC()
	A333_epr_GA()

end

--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--

--function aircraft_load() end

--function aircraft_unload() end

--function flight_start() end

--function flight_crash() end

--function before_physics() end

function A333_engine02_after_physics()

	A333_ALL_engine02()

end

function A333_engine02_after_replay()

	A333_ALL_engine02()

end





--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







