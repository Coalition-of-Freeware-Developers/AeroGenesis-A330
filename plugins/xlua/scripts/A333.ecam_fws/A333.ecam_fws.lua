jit.off()
--[[
*****************************************************************************************
* Script Name :	A333.ecam_fws.lua
* Process: FWS Script Loader
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
*       						COPYRIGHT © 2021, 2022
*					 	   L A M I N A R   R E S E A R C H
*								  ALL RIGHTS RESERVED
*****************************************************************************************
--]]


--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

XLuaReloadOnFlightChange()

--| DATA STORGE
dofile("A333.ecam_fws100.lua")	-- GLOBAL CONSTANTS & VARIABLES
dofile("A333.ecam_fws110.lua")	-- GLOBAL SIM & CUSTOM DATAREFS
dofile("A333.ecam_fws120.lua")	-- GLOBAL GENERAL FUNCTION DEFINITIONS
dofile("A333.ecam_fws150.lua")	-- GLOBAL EWD MESSAGE TABLE
dofile("A333.ecam_fws170.lua")	-- GLOBAL STATUS MESSAGE TABLE
dofile("A333.ecam_fws180.lua")  --
--| DATA PROCESSING
dofile("A333.ecam_fws200.lua")	-- GLOBAL VARIABLE ASSIGNMENT
dofile("A333.ecam_fws210.lua")	-- GENERAL DATA
dofile("A333.ecam_fws220.lua")	-- ECP PUSHBUTTON SIGNALS
dofile("A333.ecam_fws250.lua")	-- ECP CLR PROCESSING
dofile("A333.ecam_fws255.lua")	-- ECP RCL PROCESSING
dofile("A333.ecam_fws270.lua")	-- ECP STS PROCESSING
dofile("A333.ecam_fws290.lua")	-- MW/MC PROCESSING

--| WARNING MONITOR
dofile("A333.ecam_fws300.lua")	-- WARNING MESSAGE TRIGGER (INPUT) PROCESSING
dofile("A333.ecam_fws320.lua")	-- WARNING MONITOR (OUTPUT) PROCESSING
dofile("A333.ecam_fws370.lua")	-- STATUS MESSAGE TRIGGER (INPUT) PROCESSING
dofile("A333.ecam_fws380.lua")	-- STATUS MONITOR (OUTPUT) PROCESSING

--| STATUS DISPLAY PAGE PROCESSING
dofile("A333.ecam_fws400.lua")	-- NORMAL (AUTO FLIGHT PHASE) SYSTEM PAGE SELECTOR
dofile("A333.ecam_fws410.lua")	-- MANUAL SYSTEM PAGE SELECTOR
dofile("A333.ecam_fws420.lua")	-- ADVISORY SYSTEM PAGE SELECTOR
dofile("A333.ecam_fws430.lua")	-- FAILURE SYSTEM PAGE SELECTOR
dofile("A333.ecam_fws470.lua")	-- STATUS SYSTEM PAGE SELECTOR
dofile("A333.ecam_fws490.lua")	-- SYSTEM PAGE MANAGER

--| EW/D MESSAGE PROCESSING
dofile("A333.ecam_fws500.lua")	-- WARNING MESSAGE ACTION FUNCTIONS
dofile("A333.ecam_fws510.lua")	-- WARNING MESSAGE CUE

--| SD MESSAGE PROCESSING
dofile("A333.ecam_fws600.lua")	-- STATUS PAGE MESSAGE ACTION FUNCTIONS
dofile("A333.ecam_fws610.lua")	-- STATUS MESSAGE CUE

--| WARNING SYSTEM SOUND PROCESSING
dofile("A333.ecam_fws700.lua")	-- ALTITUDE CALL OUT AUDIO PROCESSING
dofile("A333.ecam_fws710.lua")	-- AURAL MONITOR (OUTPUT) PROCESSING

--| GENERIC INSTRUMENT PROCESSING
dofile("A333.ecam_fws800.lua")	-- ENGINE/WARNING GENERIC INSTRUMENTS
dofile("A333.ecam_fws810.lua")	-- STATUS GENERIC INSTRUMENTS

--| EVENT PROCESSING
dofile("A333.ecam_fws999.lua")




