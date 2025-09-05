-- *******************************************************************
-- Helper datarefs for use on the sound system
-- Daniela Rodríguez Careri <daniela@x-plane.com>
-- Laminar Research
-- *******************************************************************

throttle_lever_1 = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[0]")
throttle_lever_2 = find_dataref("sim/cockpit2/engine/actuators/throttle_ratio[1]")
n1_1 = find_dataref("sim/flightmodel2/engines/N1_percent[0]")
n1_2 = find_dataref("sim/flightmodel2/engines/N1_percent[1]")
thrust_delta = create_dataref("laminar/A333/sound/thrust_delta", "array[2]")
n2_1 = find_dataref("laminar/A333/trent700/n2_eng1")
n2_2 = find_dataref("laminar/A333/trent700/n2_eng2")
engine_n2 = create_dataref("laminar/A333/sound/trent_N2_percent", "array[2]")
burning_fuel_1 = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[0]")
burning_fuel_2 = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel[1]")

pack_1 = find_dataref("sim/cockpit2/bleedair/actuators/pack_left")
pack_2 = find_dataref("sim/cockpit2/bleedair/actuators/pack_right")
pack_actuators = create_dataref("laminar/A333/sound/packs_actuators", "array[2]")

pack_flow_1 = find_dataref("laminar/A333/pressurization/pack_flow1_ratio")
pack_flow_2 = find_dataref("laminar/A333/pressurization/pack_flow2_ratio")
pack_flow = create_dataref("laminar/A333/sound/packs_flow", "array[2]")

shade_1 = find_dataref("laminar/a333/misc/capt_visor")
shade_2 = find_dataref("laminar/a333/misc/fo_visor")
cockpit_shades = create_dataref("laminar/A333/sound/cockpit_shades", "array[2]")

bus_volts_1 = find_dataref("sim/cockpit2/electrical/bus_volts[0]")
bus_volts_2 = find_dataref("sim/cockpit2/electrical/bus_volts[1]")
is_energized = create_dataref("laminar/a333/sound/is_energized", "number")

vol_pilot_0 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav1")
vol_pilot_1 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav2")
vol_pilot_2 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_adf1")
vol_pilot_3 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_adf2")
vol_pilot_4 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_dme")
vol_pilot_5 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_dme1")
vol_pilot_6 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_dme2")
vol_pilot_7 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_mark")
vol_pilot_8 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav3")
vol_pilot_9 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav4")

vol_copilot_0 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav1_copilot")
vol_copilot_1 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav2_copilot")
vol_copilot_2 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_adf1_copilot")
vol_copilot_3 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_adf2_copilot")
vol_copilot_4 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_dme_copilot")
vol_copilot_5 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_dme1_copilot")
vol_copilot_6 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_dme2_copilot")
vol_copilot_7 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_mark_copilot")
vol_copilot_8 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav3_copilot")
vol_copilot_9 = find_dataref("sim/cockpit2/radios/actuators/audio_volume_nav4_copilot")

radio_vol_pilot = create_dataref("laminar/A333/sound/radio_volume_pilot", "array[10]")
radio_vol_copilot = create_dataref("laminar/A333/sound/radio_volume_copilot", "array[10]")

function A333_set_radio_volumes()

	-- I hate this.
	radio_vol_pilot[0] = vol_pilot_0
	radio_vol_pilot[1] = vol_pilot_1
	radio_vol_pilot[2] = vol_pilot_2
	radio_vol_pilot[3] = vol_pilot_3
	radio_vol_pilot[4] = vol_pilot_4
	radio_vol_pilot[5] = vol_pilot_5
	radio_vol_pilot[6] = vol_pilot_6
	radio_vol_pilot[7] = vol_pilot_7
	radio_vol_pilot[8] = vol_pilot_8
	radio_vol_pilot[9] = vol_pilot_9

	radio_vol_copilot[0] = vol_copilot_0
	radio_vol_copilot[1] = vol_copilot_1
	radio_vol_copilot[2] = vol_copilot_2
	radio_vol_copilot[3] = vol_copilot_3
	radio_vol_copilot[4] = vol_copilot_4
	radio_vol_copilot[5] = vol_copilot_5
	radio_vol_copilot[6] = vol_copilot_6
	radio_vol_copilot[7] = vol_copilot_7
	radio_vol_copilot[8] = vol_copilot_8
	radio_vol_copilot[9] = vol_copilot_9
end

function A333_set_thrust_delta()
	if (burning_fuel_1 > 0) then
		thrust_delta[0] = throttle_lever_1 - ( (n1_1 - 20) * (1 / 83) ) -- 105-22 (n1 throttle range)
	else
		thrust_delta[0] = 0
	end
	if (burning_fuel_2 > 0) then
		thrust_delta[1] = throttle_lever_2 - ( (n1_2 - 20) * (1 / 83) )
	else
		thrust_delta[1] = 0
	end
end

function A333_set_n2_array()
	engine_n2[0] = n2_1
	engine_n2[1] = n2_2
end

function A333_set_packs_array()
	pack_actuators[0] = pack_1
	pack_actuators[1] = pack_2
	pack_flow[0] = pack_flow_1
	pack_flow[1] = pack_flow_2
end

function A333_set_shades_array()
	cockpit_shades[0] = shade_1
	cockpit_shades[1] = shade_2
end

function A333_set_energized_status()
	if (bus_volts_1 > 20 or bus_volts_2 > 20) then
		is_energized = 1
	else
		is_energized = 0
	end
end

-- *******************************************************************
-- Hooks
-- *******************************************************************

function update_datarefs()
	A333_set_thrust_delta()
	A333_set_n2_array()
	A333_set_packs_array()
	A333_set_shades_array()
	A333_set_energized_status()
	A333_set_radio_volumes()
end

function after_physics()
	update_datarefs()
end

function after_replay()
	update_datarefs()
end
