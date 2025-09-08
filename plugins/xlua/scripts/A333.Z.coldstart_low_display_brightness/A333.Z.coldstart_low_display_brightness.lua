jit.off()
--[[Thanks to https://github.com/telephono for letting us use his C&D mod
]]
sim_startup_running  = find_dataref("sim/operation/prefs/startup_running")

pfd_brightness_pilot = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[0]")
pfd_brightness_copilot = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[5]")

nd_brightness_pilot = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[1]")
nd_brightness_copilot = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[4]")

ecam_upper_brightness = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[2]")
ecam_lower_brightness = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[3]")

mcdu_brightness_pilot = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[6]")
mcdu_brightness_copilot = find_dataref("sim/cockpit2/switches/instrument_brightness_ratio[7]")

function A333_lower_display_brightness()
    pfd_brightness_pilot = 0.35
    nd_brightness_pilot = 0.35
    ecam_upper_brightness = 0.35
    ecam_lower_brightness = 0.35
    pfd_brightness_copilot = 0.35
    nd_brightness_copilot = 0.35
    mcdu_brightness_pilot = 0.1
    mcdu_brightness_copilot = 0.1
end

function flight_start()
    if sim_startup_running == 0 then
        A333_lower_display_brightness()
    end
end
