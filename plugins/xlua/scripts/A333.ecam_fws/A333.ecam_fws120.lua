--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws120.lua
* Process: FWS General Functions
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


--print("LOAD: A333.ecam_fws120.lua")

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

-----| E/WD WARNING MESSAGE
function newEWDwarningMessage(name, itemGroup, itemTitle, warningTitle, itemGfx, warningGfx, titleColor, zone, failType, level, master, sysPage, aural, priority)

	local msg = {}

	msg.Name 					= name
	msg.ItemGroup				= itemGroup
	msg.ItemTitle				= itemTitle
	msg.WarningTitle			= warningTitle
	msg.ItemGFX					= itemGfx		-- 0=NONE, 1=UNDERLINE, 2=BOXED
	msg.WarningGFX				= warningGfx	-- 0=NONE, 1=UNDERLINE, 2=BOXED
	msg.TitleColor				= titleColor	-- 0=RED, 1=AMBER, 2=GREEN, 3=WHITE, 4=CYAN, 5=MAGENTA
	msg.Zone					= zone			-- 0=LEFT, 1=RIGHT
	msg.FailType				= failType		-- 0=SPECIAL LINES, 1=INDEPENDENT, 2=PRIMARY, 3=ZONE 1 OVERFLOW, 4-SECONDARY, 5=CONFIG MEMO, 6=MEMO
	msg.Level					= level			-- 0=NONE, 1=AMBER CAUTION (MONITOR), 2=AMBER CAUTION (AWARE), 3=RED WARNING (IMMEDIATE)
	msg.MasterType				= master		-- 0=NONE, 1=WARNING, 2=CAUTION
	msg.SysPage					= sysPage		-- 0=NONE, 1=ENGINE, 2=BLEED, 3=CAB PRESS, 4=ELEC AC, 5=ELEC DC, 6=HYD, 7=C/B, 8=APU, 9=COND, 10=DOOR/OCY, 11=WHEEL, 12=F/CTL, 13=FUEL, 14=CRUISE, 15=STATUS
	msg.Aural					= aural			-- 0=NONE, 1=CONTINUOUS REPETITIVE CHIME, 2=SINGLE CHIME, 3=CAVALRY CHARGE, 4=CONTIUOUS CAVALRY CHAGE, 5=TRIPLE CLICK, 6=CRICKET+"STALL", 7=INTERMITTENT BUZZER, 8=BUZZER, 9=C CHORD, 10=AUTO CALLOUT (SYNTHETIC VOICE), 11=GROUND PROXIMITY WARNING (SYNTHETIC VOICE), 12=WINDSHEAR” (SYNTHETIC VOICE), 13=	msg.Aural					= aural			-- 0=NONE, 1=CONTINUOUS REPETITIVE CHIME, 2=SINGLE CHIME, 3=CAVALRY CHARGE, 4=CONTIUOUS CAVALRY CHAGE, 5=TRIPLE CLICK, 6=CRICKET+"STALL", 7=INTERMITTENT BUZZER, 8=BUZZER, 9=C CHORD, 10=AUTO CALLOUT (SYNTHETIC VOICE), 11=GROUND PROXIMITY WARNING (SYNTHETIC VOICE), 12=WINDSHEAR” (SYNTHETIC VOICE), 13=“PRIORITY LEFT” / “PRIORITY RIGHT” (SYNTHETIC VOICE)
	msg.Priority				= priority		-- Manually Assigned
	msg.Inhibit					= {0,0,0,0,0,0,0,0,0,0}
	msg.CmdInputs				= ':CLR:RCL:C:EC:STS:'
	msg.isVisible				= false
	msg.Monitor					= {}
	msg.Monitor.audio			= {}
	msg.Monitor.audio.IN		= 0
	msg.Monitor.audio.INlast	= 0
	msg.Monitor.audio.OUT		= 0
	msg.Monitor.video			= {}
	msg.Monitor.video.IN		= 0
	msg.Monitor.video.INlast	= 0
	msg.Monitor.video.OUT		= 0
	msg.MsgLine					= {}

	return msg

end








-----| STATUS WARNING MESSAGE
function newSTSMessage(name, zone, type, sequence)

	local msg = {}

	msg.Name 			= name
	msg.Zone			= zone			-- 0=LEFT, 1=RIGHT
	msg.Type			= type			-- 0=LIMITATION, 1=APPR PROCEDURE, 2=PROCEDURE, 3=INFO, 4=CANCELLED CAUTION, 5=INOP SYSTEM, 6 = MAINTENANCE
	msg.Sequence		= sequence
	msg.Inhibit			= {0,0,0,0,0,0,0,0,0,0}
	msg.CmdInputs		= ':CLR:RCL:C:EC:STS:'
	msg.Video			= {}
	msg.Video.IN		= 0
	msg.Video.OUT		= 0

	return msg

end










-----| WARNING MESSAGE VARIABLE TEXT
function newVariableText(name, from, to, step, upORdn, clock)

	local vl = {}

	vl.name		= name
	vl.start	= false
	vl.from		= from
	vl.to 		= to
	vl.step		= step
	vl.upORdn	= upORdn
	vl.out		= vl.from
	vl.s1       = false
	vl.s2		= false
	vl.clock 	= clock
	vl.func 	= function()
		if vl.upORdn == "up" then
			vl.out = vl.out + vl.step
		elseif vl.upORdn == "dn" then
			vl.out = vl.out - vl.step
		end
	end

	function vl:update(input)
		self.start = input
		if self.start then
			self.s1 = true
			self:startTimer()
		end
		if self.out == self.to
			or self.start == false
		then
			stop_timer(self.func)
			self.start = false
			self.s1 = false
			self.s2 = true
		end
	end

	function vl:startTimer()
		if self.out == self.from then
			if not is_timer_scheduled(self.func) then
				run_at_interval(self.func, self.clock)
			end
		end
	end

	function vl:resetTimer()
		if is_timer_scheduled(self.func) then
			stop_timer(self.func)
		end
	end

	function vl:init()
		self:resetTimer()
		self.start = false
		self.out = self.from
		self.s1 = false
		self.s2 = false
	end

	return vl

end









-----| LEADING EDGE PULSE PROCESSOR (COMPUTATION TIME = 1 FRAME)
function newLeadingEdgePulse(name)

	local pulse = {}

	pulse.name		= name
	pulse.IN 		= false
	pulse.lastIN 	= false
	pulse.OUT		= false

	function pulse:update(input)
		self.IN 	= input
		self.OUT 	= bAND(bXOR(self.IN, self.lastIN), self.IN)
		self.lastIN = self.IN
	end

	return pulse

end




-----| FALLING EDGE PULSE PROCESSOR (COMPUTATION TIME = 1 FRAME)
function newFallingEdgePulse(name)

	local pulse = {}

	pulse.name		= name
	pulse.IN 		= false
	pulse.lastIN 	= false
	pulse.OUT		= false

	function pulse:update(input)
		self.IN 	= input
		self.OUT 	= bAND(bXOR(self.IN, self.lastIN), not self.IN)
		self.lastIN	= self.IN
	end

	return pulse

end




-----| LEADING EDGE MONOSTABLE TRIGGER
function newLeadingEdgeTrigger(name, duration)

	local trigger = {}

	trigger.name			= name
	trigger.IN 				= false
	trigger.lastIN 			= false
	trigger.START			= false
	trigger.OUT				= false
	trigger.timerFunc		= function() trigger.OUT = false end
	trigger.timerDuration	= duration

	function trigger:update(input)
		self.IN = input
		self.START = bAND(bXOR(self.IN, self.lastIN), self.IN)
		if self.START then
			self.OUT = true
			self:startTimer()
		end
		self.lastIN = self.IN
	end

	function trigger:startTimer()
		if not is_timer_scheduled(self.timerFunc) then
			run_after_time(self.timerFunc, self.timerDuration)
		end
	end

	function trigger:resetTimer()
		if is_timer_scheduled(self.timerFunc) then
			stop_timer(self.timerFunc)
		end
		self.OUT = false
	end

	return trigger

end



-----| FALLING EDGE MONOSTABLE TRIGGER
function newFallingEdgeTrigger(name, duration)

	local trigger = {}

	trigger.name			= name
	trigger.IN 				= false
	trigger.lastIN 			= false
	trigger.START			= false
	trigger.OUT				= false
	trigger.timerFunc		= function() trigger.OUT = false end
	trigger.timerDuration	= duration

	function trigger:update(input)
		self.IN = input
		self.START = bAND(bXOR(self.IN, self.lastIN), not self.IN)
		if self.START then
			self.OUT = true
			self:startTimer()
		end
		self.lastIN = self.IN
	end

	function trigger:startTimer()
		if not is_timer_scheduled(self.timerFunc) then
			run_after_time(self.timerFunc, self.timerDuration)
		end
	end

	return trigger

end



-----| LEADING EDGE MONOSTABLE TRIGGER (RE-TRIGGERABLE)
function newLeadingEdgeTriggerReTrigger(name, duration)

	local trigger = {}

	trigger.name			= name
	trigger.IN 				= false
	trigger.lastIN 			= false
	trigger.START			= false
	trigger.OUT				= false
	trigger.timerFunc		= function() trigger.OUT = false end
	trigger.timerDuration	= duration

	function trigger:update(input)
		self.IN = input
		self.START = bAND(bXOR(self.IN, self.lastIN), self.IN)
		if self.START then
			self.OUT = true
			self:startTimer()
		end
		self.lastIN = self.IN
	end

	function trigger:startTimer()
		run_after_time(self.timerFunc, self.timerDuration)
	end

	return trigger

end



-----| LEADING EDGE DELAYED CONFIRMATION
function newLeadingEdgeDelayedConfirmation(name, duration)

	local conf = {}

	conf.name			= name
	conf.IN 			= false
	conf.lastIN 		= false
	conf.START			= false
	conf.OUT			= false
	conf.timerFunc		= function() conf.OUT = true end
	conf.timerDuration	= duration

	function conf:update(input)
		self.IN = input
		self.START = bAND3(bXOR(self.IN, self.lastIN), self.IN, not self.OUT)
		if self.START then
			self:startTimer()
		end
		if not self.IN
			and
			(self.OUT == true or is_timer_scheduled(self.timer))
		then
			self:resetTimer()
		end
		self.lastIN = self.IN
	end

	function conf:startTimer()
		if not is_timer_scheduled(self.timerFunc) then
			run_after_time(self.timerFunc, self.timerDuration)
		end
	end

	function conf:resetTimer()
		if is_timer_scheduled(self.timerFunc) then
			stop_timer(self.timerFunc)
		end
		self.OUT = false
	end

	return conf

end



----- | FALLING EDGE DELAYED CONFIRMATION
function newFallingEdgeDelayedConfirmation(name, duration)

	local conf = {}

	conf.name			= name
	conf.IN 			= false
	conf.lastIN 		= false
	conf.START			= false
	conf.OUT			= false
	conf.timerFunc		= function() conf.OUT = false end
	conf.timerDuration	= duration

	function conf:update(input)
		self.IN = input
		self.START = bAND3(bXOR(self.IN, self.lastIN), not self.IN, self.OUT)
		if self.START then
			self:startTimer()
		end
		if self.IN
			and
			(self.OUT == false or is_timer_scheduled(self.timer))
		then
			self:resetTimer()
		end
		self.lastIN = self.IN
	end

	function conf:startTimer()
		if not is_timer_scheduled(self.timerFunc) then
			run_after_time(self.timerFunc, self.timerDuration)
		end
	end

	function conf:resetTimer()
		if is_timer_scheduled(self.timerFunc) then
			stop_timer(self.timerFunc)
		end
		self.OUT = true
	end

	return conf

end



----- | MARGIN SENSOR
--[[
Square brackets, [ ], are used to denote an interval.
The notation [a, c[ is used to indicate an interval from
a to c that is inclusive of a but exclusive of c. That is, [5, 12[ would
be the set of all real numbers between 5 and 12, including 5 but not 12.
Here, the numbers may come as close as they like to 12, including 11.999
and so forth (with any finite number of 9s), but 12.0 is not included.

--]]

-- [x, y] = INCLUSIVE x,  INCLUSIVE y
-- [x, y[ = INCLUSIVE x,  EXLUSIVE y
-- ]x, y] = EXCLUSIVE x,  INCLUSIVE y
-- ]x, y[ = EXCLUSIVE x,  EXLUSIVE y

function newMarginSensor(name, dnOperator, upOperator, dn, up)

	local sensor = {}

	sensor.name			= name
	sensor.input		= false
	sensor.dnOperator	= dnOperator
	sensor.upOperator	= upOperator
	sensor.dn			= dn
	sensor.up			= up
	sensor.output		= false

	function sensor:update(input)
		self.input = input
		if self.dnOperator == '[' then
			if self.upOperator == ']' then
				self.output = bAND(self.dn <= self.input, self.input <= self.up)
			elseif self.upOperator == '[' then
				self.output = bAND(self.dn <= self.input, self.input < self.up)
			end
		elseif self.dnOperator == ']' then
			if self.upOperator == ']' then
				self.output = bAND(self.dn < self.input, self.input <= self.up)
			elseif self.upOperator == '[' then
				self.output = bAND(self.dn < self.input, self.input < self.up)
			end
		end
	end

	return sensor

end





----- | SR LATCH WITH SET PRIORITY
function newSRlatchSetPriority(name)

	local srS = {}

	srS.name	= name
	srS.S		= false
	srS.R		= false
	srS.gate1 	= {E1 = false, E2 = false, OUT = false}
	srS.gate2 	= {E1 = false, E2 = false, OUT = false}
	srS.gate3 	= {E1 = false, E2 = false, OUT = false}
	srS.Q		= false
	srS.notQ	= false

	function srS:update(s, r)
		self.S = s
		self.R = r

		self.gate1.E1	= bNOT(self.S)
		self.gate1.E2	= self.R
		self.gate1.OUT	= bAND(self.gate1.E1, self.gate1.E2)

		self.gate2.E1	= self.S
		self.gate2.E2	= self.gate3.OUT
		self.gate2.OUT	= bNOR(self.gate2.E1, self.gate2.E2)

		self.gate3.E1	= self.gate2.OUT
		self.gate3.E2	= self.gate1.OUT
		self.gate3.OUT	= bNOR(self.gate3.E1, self.gate3.E2)

		self.Q			= self.gate3.OUT
		self.notQ		= self.gate2.OUT
	end

	function srS:reset()
		self.S		= false
		self.R		= false
		self.gate1 	= {E1 = false, E2 = false, OUT = false}
		self.gate2 	= {E1 = false, E2 = false, OUT = false}
		self.gate3 	= {E1 = false, E2 = false, OUT = false}
		self.Q		= false
		self.notQ	= false
	end

	return srS

end





----- | SR LATCH WITH RESET PRIORITY
function newSRlatchResetPriority(name)

	local srR = {}

	srR.name	= name
	srR.S		= false
	srR.R		= false
	srR.gate1 	= {E1 = false, E2 = false, OUT = false}
	srR.gate2 	= {E1 = false, E2 = false, OUT = false}
	srR.gate3 	= {E1 = false, E2 = false, OUT = false}
	srR.Q		= false
	srR.notQ	= false

	function srR:update(s, r)
		self.S = s
		self.R = r

		self.gate1.E1	= self.S
		self.gate1.E2	= bNOT(self.R)
		self.gate1.OUT	= bAND(self.gate1.E1, self.gate1.E2)

		self.gate3.E1	= self.gate1.OUT
		self.gate3.E2	= self.gate2.OUT
		self.gate3.OUT	= bNOR(self.gate3.E1, self.gate3.E2)

		self.gate2.E1	= self.gate3.OUT
		self.gate2.E2	= self.R
		self.gate2.OUT	= bNOR(self.gate2.E1, self.gate2.E2)

		self.Q			= self.gate2.OUT
		self.notQ		= self.gate3.OUT
	end

	function srR:reset()
		self.S		= false
		self.R		= false
		self.gate1 	= {E1 = false, E2 = false, OUT = false}
		self.gate2 	= {E1 = false, E2 = false, OUT = false}
		self.gate3 	= {E1 = false, E2 = false, OUT = false}
		self.Q		= false
		self.notQ	= false
	end

	return srR

end





----- | THREE POLE SWITCH, 2 IN, 1 OUT
function newAnalogSwitch2in1out(name)

	local switch = {}

	switch.name		= name
	switch.control 	= false
	switch.in1		= 0
	switch.in2		= 0
	switch.out 		= 0

	function switch:update(control, in1, in2)
		self.control = control
		self.in1 = in1
		self.in2 = in2
		local output = self.in2
		if self.control then
			output = self.in1
		end
		self.out = output
	end

	return switch

end








----- | DISCRETE SWITCH
function newDiscreteSwitch(name)

	local switch = {}

	switch.name 	= name
	switch.control 	= false
	switch.in1		= false
	switch.in2		= false
	switch.out		= false

	function switch:update(control, in1, in2)
		self.control = control
		self.in1 = in1
		self.in2 = in2
		local output = self.in2
		if self.control then
			output = self.in1
		end
		self.out = output

	end

	return switch

end





----- | SLOPE THRESHOLD
function newSlopeThreshold(name, operator, threshold, unit)

	local st = {}

	st.name 		= name
	st.input		= 0
	st.operator		= operator
	st.threshold	= threshold
	st.unit			= unit
	st.out			= false
	st.lastIn		= 0

	function st:update(input)
		self.input = input
		if SIM_PERIOD > 0.0 then
			local curRate = (self.input - self.lastIn) / SIM_PERIOD
			if self.operator == '>' then
				self.out = curRate > self.threshold
			elseif self.operator == '>=' then
				self.out = curRate >= self.threshold
			elseif self.operstor == '<' then
				self.out = curRate < self.threshold
			elseif self.operator == '<=' then
				self.out = curRate <= self.threshold
			end
		end
		self.lastIn = self.input
	end

	return st

end




----- | COMPARISON
function newComparison(name, operator)

	local comp = {}

	comp.name 		= name
	comp.in1		= 0
	comp.in2		= 0
	comp.operator 	= operator
	comp.out 		= false

	function comp:update(in1, in2)
		self.in1 = in1
		self.in2 = in2
		self.out = false
		if self.operator == '<' then
			if self.in1 < self.in2 then
				self.out = true
			end
		elseif self.operator == '<=' then
			if self.in1 <= self.in2 then
				self.out = true
			end
		elseif self.operator == '>' then
			if self.in1 > self.in2 then
				self.out = true
			end
		elseif self.operator == '>=' then
			if self.in1 >= self.in2 then
				self.out = true
			end
		end
	end

	return comp

end




----- | NUMERICAL INCREMENT/DECREMENT
function newNumerical(name, sign1, sign2)

	local num = {}

	num.name	= name
	num.sign1	= sign1
	num.sign2	= sign2
	num.in1		= 0
	num.in2		= 0
	num.out		= 0

	function num:update(in1, in2)
		self.in1 = in1
		self.in2 = in2
		local output = 0
		if self.sign1 == '+' then
			if self.sign2 == '+' then
				output = self.in1 + self.in2
			elseif self.sign2 == '-' then
				output = self.sign1 - self.sign2
			end
		elseif self.sign1 == '-' then
			if self.sign2 == '+' then
				output = self.in2 - self.in1
			elseif self.sign2 == '-' then
				output = 9999  -- TODO: INVALID ??
			end
		end
		num.out = output
	end

	return num

end






----- | THRESHOLD
function newThreshold(name, operator, threshold)

	local th = {}

	th.name 		= name
	th.input 		= 0
	th.operator 	= operator
	th.threshold	= threshold
	th.out 			= false

	function th:update(in1)
		self.input = in1
		local output
		if self.operator == '<' then
			output = self.input < self.threshold
		elseif self.operator == '<=' then
			output = self.input <= self.threshold
		elseif self.operator == '>=' then
			output = self.input >= self.threshold
		elseif self.operator == '>' then
			output = self.input > self.threshold
		end
		self.out = output
	end

	return th

end







----- | HYSTERESIS
function newHysteresis(name, dn, up)

	local hyst = {}

	hyst.name 	= name
	hyst.input	= 0
	hyst.dn		= dn
	hyst.up		= up
	hyst.out	= false

	function hyst:update(input)
		self.input = input
		if self.input >= self.up
			and self.out == false
		then
			self.out = true
		elseif input <= self.dn
			and self.out == true
		then
			self.out = false
		end
	end

	return hyst

end













-----| UTIL: RESCALE/NORMALIZE
function rescale(in1, out1, in2, out2, x)

	if x < in1 then return out1 end
	if x > in2 then return out2 end
	if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
	return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end

function rescale2(in1, out1, in2, out2, x)

	if in2 - in1 == 0 then return out1 + (out2 - out1) * (x - in1) end
	return out1 + (out2 - out1) * (x - in1) / (in2 - in1)
end





-----| UTIL: ROUND NUMBER TO DESIRED DECIMAL PLACE
function math.round(number, precision)
	local fmtStr = string.format('%%0.%sf', precision)                                    -- ie.  IF DESIRED OUTPUT = X.XXX THEN PRECISION PARAMETER = 3
	return tonumber(string.format(fmtStr, number))
end





function math.round95(value)

	local i, f = math.modf(value)

	if f > 0.95 then
		return i+1
	else
		return value
	end

end






-----| UTIL: CONVERT TO TRADITIONAL BOOLEAN
function toboolean(v)
	return v ~= nil and v ~= false and v ~= 0
end





-----| UTIL: BOOLEAN "NOT"
--		a		return
--	 	false	true
--		true	false
--
function bNOT(a)
	return (not a)
end




-----| UTIL: BOOLEAN "AND"
--		a		b		return
--	 	false	false	false
--		false	true	false
--		true	false	false
--		true	true	true
--
function bAND(a, b)
	return (a and b)
end

function bAND3(a, b, c)
	return (a and b and c)
end

function bAND4(a, b, c, d)
	return (a and b and c and d)
end

function bAND5(a, b, c, d, e)
	return (a and b and c and d and e)
end

function bAND6(a, b, c, d, e, f)
	return (a and b and c and d and e and f)
end

function bAND7(a, b, c, d, e, f, g)
	return (a and b and c and d and e and f and g)
end

function bAND8(a, b, c, d, e, f, g, h)
	return (a and b and c and d and e and f and g and h)
end

function bAND10(a, b, c, d, e, f, g, h, i, j)
	return (a and b and c and d and e and f and g and h and i and j)
end



-----| UTIL: BOOLEAN "NAND"
--     	a		b		return
--		false	false	true
-- 		false	true	true
--		true	false	true
--		true    true	false
function bNAND(a, b)
	return not(a and b)
end

function bNAND4(a, b, c, d)
	return not(a and b and c and d)
end





-----| UTIL: BOOLEAN "OR"
--		a		b		return
--	 	false	false	false
--		false	true	true
--		true	false	true
--		true	true	true
--
function bOR(a, b)
	return (a or b)
end

function bOR3(a, b, c)
	return (a or b or c)
end

function bOR4(a, b, c, d)
	return (a or b or c or d)
end

function bOR5(a, b, c, d, e)
	return (a or b or c or d or e)
end

function bOR6(a, b, c, d, e, f)
	return (a or b or c or d or e or f)
end

function bOR7(a, b, c, d, e, f, g)
	return (a or b or c or d or e or f or g)
end

function bOR8(a, b, c, d, e, f, g, h)
	return (a or b or c or d or e or f or g or h)
end




-----| UTIL: BOOLEAN "NOR"
--        a			b       return
--        false    	false	true
--        false    	true	false
--        true    	false   false
--        true    	true    false
function bNOR(a, b)
	return not(a or b)
end

function bNOR4(a, b, c, d)
	return not(a or b or c or d)
end




-----| UTIL: BOOLEAN "XOR"
--		a		b		return
--	 	false	false	false
--		false	true	true
--		true	false	true
--		true	true	false
--
function bXOR(a, b)
	return (a ~= b)
end





-----| UTIL:  ARGS == TRUE == (INPUT) > X
function bMT(x, ...)
	local args = {...}
	local counter = 0
	for i = 1, #args do
		if args[i] then
			counter = counter + 1
		end
	end
	if counter > x then
		return true
	else
		return false
	end
end
























--[[
THIS VERSION OF TABLE COPY WILL COPY THE USUAL KEY-VALUE
PAIRS BUT NOT COPY TABLES WITHIN THE SOURCE TABLE, RATHER
IT WILL ACTUALLY PUT THOSE SUB-TABLES INTO THE DESTINATION
TABLE. THIS MEANS CHANGES TO THE NEW SUB-TABLE WILL AFFECT
THE ORIGINAL.
--]]
function shallowTableCopy(srcTbl)

	local newTabl = {}

	for k, v in pairs(srcTbl) do
		newTabl[k] = v
	end

	return newTabl

end







--[[
IN ADDITION TO COPYING THE USUAL KEY-VALUE PAIRS, THIS
VERSION OF THE DEEP COPY FUNCTION WILL ACTUALLY "COPY"
TABLES IN THE SOURCE TABLE TO THE DESTINATION TABLE THEREFORE
ALLOWING SIDE EFFECTS TO THE NEW TABLE WITHOUT AFFECTING
THE ORIGINAL.
--]]
function deepTableCopy(srcTbl)

	local newTabl = {}

	for k, v in pairs(srcTbl) do
		k = type(k) == "table" and deepTableCopy(k) or k
		v = type(v) == "table" and deepTableCopy(v) or v
		newTabl[k] = v
	end

	return newTabl

end





-----|UTIL: DEEP TABLE COPY (T)
--[[
THIS VERSION OF THE DEEP COPY FUNCTION PREVENTS TABLES THAT
APPEAR MORE THAN ONCE IN THE SOURCE TABLE FROM SHOWING UP
AS DIFFERENT TABLES IN THE DESTINATION TABLE _AND_ TAKES
INTO ACCOUNT IF THE SOURCE TABLE CONTAINS ANY TABLE THAT
DIRECTLY OR INDIRECTLY CONTAINS ITSELF (CYCLE).  (THE
"seen" ARGUMENT IS ONLY FOR RECURSIVE CALLS.)
--]]
function deepTableCopyT(srcTbl, seen)

	local newTabl

	if seen then
		newTabl = seen[srcTbl]
	else
		seen = {}
	end

	if not newTabl then
		newTabl = {}
		seen[srcTbl] = newTabl
		for k, v in pairs(srcTbl) do
			k = type(k) == "table" and deepTableCopyT(k, seen) or k
			v = type(v) == "table" and deepTableCopyT(v, seen) or v
			newTabl[k] = v
		end
	end

	return newTabl

end









function sort_on_values_ascending(t,...)
	local a = {...}
	table.sort(t, function (u,v)
		for i = 1, #a do
			if u[a[i]] > v[a[i]] then return false end
			if u[a[i]] < v[a[i]] then return true end
		end
	end)
end







-----| TABLE SORT SPECIFIC TO A333 E/WD MSG CUE R
-----| SORT MESSAGES CUE TABLE BY: 1.) TYPE (ascending), 2.) LEVEL (descending) 3.) PRIORITY (ascending)
function A333_ewd_sort_msg_cue_R(t,...)
	local a = {...}
	table.sort(t, function (u,v)
		for i = 1, #a do
			if i == 2 then
				if u[a[i]] < v[a[i]] then return false end
				if u[a[i]] > v[a[i]] then return true end
			else
				if u[a[i]] > v[a[i]] then return false end
				if u[a[i]] < v[a[i]] then return true end
			end
		end
	end)
end


















--[[
-----| DIAGNOSTIC:  DUMP THE SORTED LEFT MESSAGE CUE TABLE
function A333_ecam_ewd_dump_left_cue_table()

	print()
	print("+-------------------------------------------------------------------------------+")
	---[[
	print("A333_ewd_msg_cue_L (Sorted):")
	print(#A333_ewd_msg_cue_L)
	for index, msgData in ipairs(A333_ewd_msg_cue_L) do
		print(string.format("INDEX: %d   NAME: %-24s  TYPE: %d   LEVEL: %d   PRIORITY: %3d   VISIBLE: %s", index, msgData.Name, msgData.Ftype, msgData.Level, msgData.Priority, A333_ewd_msg[msgData.Name].isVisible))
		--if A333_ewd_msg[msgData.Name].MsgLine then
			--for i = 1, #A333_ewd_msg[msgData.Name].MsgLine do
			--	print(string.format("   MESSAGE: %s  VISIBLE: %d  CLEARED: %d  STATUS: %d", A333_ewd_msg[msgData.Name].MsgLine[i].MsgText, A333_ewd_msg[msgData.Name].MsgLine[i].MsgVisible, A333_ewd_msg[msgData.Name].MsgLine[i].MsgCleared, A333_ewd_msg[msgData.Name].MsgLine[i].MsgStatus))
			--end
		--end
		--print(string.format('VISIBLE: %s', A333_ewd_msg[msgData.Name].isVisible))
	end



end


function A333_testTrigger_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_ewd_dump_left_cue_table()


	end
end


A333CMD_testTrigger = create_command("laminar/A333/testTrigger", "Test Trigger", A333_testTrigger_CMDhandler)
--]]



--[[
-----| DIAGNOSTIC:  DUMP THE SORTED RIGHT MESSAGE CUE TABLE
function A333_ecam_ewd_dump_right_cue_table()

	print()
	print("+-------------------------------------------------------------------------------+")
	print("A333_ewd_msg_cue_R (Sorted):")
	print(#A333_ewd_msg_cue_R)
	for index, msgData in ipairs(A333_ewd_msg_cue_R) do
		print(string.format("INDEX: %d   NAME: %-24s   TYPE: %d   LEVEL: %d   PRIORITY: %3d", index, msgData.Name, msgData.Ftype, msgData.Level, msgData.Priority))
	end
	print()



end



function A333_testTrigger2_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_ewd_dump_right_cue_table()

	end
end

A333CMD_testTrigger2 = create_command("laminar/A333/testTrigger2", "Test Trigge 2", A333_testTrigger2_CMDhandler)









-----| DIAGNOSTIC:  DUMP THE SD ZONE 0 (LEFT) MSG CUE TABLE
function A333_ecam_sd_dump_left_cue_table()

	print()
	print("+-------------------------------------------------------------------------------+")
	print("A333_sts_msg_cue_L (Sorted):")
	print('TABLE SIZE: ', #A333_sts_msg_cue_L)
	for index, msg in ipairs(A333_sts_msg_cue_L) do
		print(string.format("INDEX: %d   NAME: %-24s  ZONE: %d   TYPE: %d   SEQUENCE: %3d", index, msg.Name, msg.Zone, msg.Type, msg.Sequence))
		for i = 1, #A333_sts_msg[msg.Name].Msg do
			print(string.format("   LINE: %d  MESSAGE: %s  COLOR: %d  STATUS: %d  CLEARED: %d VISIBLE: %d", A333_sts_msg[msg.Name].Msg[i].Line, A333_sts_msg[msg.Name].Msg[i].Text, A333_sts_msg[msg.Name].Msg[i].Color, A333_sts_msg[msg.Name].Msg[i].Status, A333_sts_msg[msg.Name].Msg[i].Cleared, A333_sts_msg[msg.Name].Msg[i].Visible))
		end
	end

end

function A333_testTrigger3_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_sd_dump_left_cue_table()
	end
end
A333CMD_testTrigger3 = create_command("laminar/A333/testTrigger3", "Test Trigger 3", A333_testTrigger3_CMDhandler)







-----| DIAGNOSTIC:  DUMP THE SD ZONE 1 (RIGHT) MSG CUE TABLE
function A333_ecam_sd_dump_right_cue_table()

	print()
	print("+-------------------------------------------------------------------------------+")
	print("A333_sts_msg_cue_R (Sorted):")
	print('TABLE SIZE: ', #A333_sts_msg_cue_R)
	for index, msg in ipairs(A333_sts_msg_cue_R) do
		print(string.format("INDEX: %d   NAME: %-24s  ZONE: %d   TYPE: %d   VIDEO IN: %d    VIDEO OUT: %d    SEQUENCE: %3d", index, msg.Name, msg.Zone, msg.Type, A333_sts_msg[msg.Name].Video.IN, A333_sts_msg[msg.Name].Video.OUT, msg.Sequence))
		for i = 1, #A333_sts_msg[msg.Name].Msg do
			print(string.format("   LINE: %d  MESSAGE: %s  COLOR: %d  STATUS: %d  VISIBLE: %d", A333_sts_msg[msg.Name].Msg[i].Line, A333_sts_msg[msg.Name].Msg[i].Text, A333_sts_msg[msg.Name].Msg[i].Color, A333_sts_msg[msg.Name].Msg[i].Status, A333_sts_msg[msg.Name].Msg[i].Visible))
		end
	end

end

function A333_testTrigger4_CMDhandler(phase, duration)
	if phase == 0 then
		A333_ecam_sd_dump_right_cue_table()
	end
end
A333CMD_testTrigger4 = create_command("laminar/A333/testTrigger4", "Test Trigger 4", A333_testTrigger4_CMDhandler)

--]]



--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







