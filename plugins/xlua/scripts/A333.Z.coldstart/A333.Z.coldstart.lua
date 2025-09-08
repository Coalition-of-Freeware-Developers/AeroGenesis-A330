jit.off()
--[[Thanks to https://github.com/telephono for letting us use his C&D mod
]]
sim_startup_running  = find_dataref("sim/operation/prefs/startup_running")

adirs_adr1_toggle = find_command("laminar/A333/buttons/adirs/adr1_toggle")
adirs_adr2_toggle = find_command("laminar/A333/buttons/adirs/adr2_toggle")
adirs_adr3_toggle = find_command("laminar/A333/buttons/adirs/adr3_toggle")

adirs_ir1_toggle = find_command("laminar/A333/buttons/adirs/ir1_toggle")
adirs_ir2_toggle = find_command("laminar/A333/buttons/adirs/ir2_toggle")
adirs_ir3_toggle = find_command("laminar/A333/buttons/adirs/ir3_toggle")

fcc_prim1_toggle = find_command("laminar/A333/buttons/fcc/prim1_toggle")
fcc_prim2_toggle = find_command("laminar/A333/buttons/fcc/prim2_toggle")
fcc_prim3_toggle = find_command("laminar/A333/buttons/fcc/prim3_toggle")
fcc_sec1_toggle = find_command("laminar/A333/buttons/fcc/sec1_toggle")
fcc_sec2_toggle = find_command("laminar/A333/buttons/fcc/sec2_toggle")

gpws_ter_toggle = find_command("laminar/A333/buttons/gpws/terr_toggle")
gpws_sys_toggle = find_command("laminar/A333/buttons/gpws/sys_toggle")
gpws_gs_mode_toggle = find_command("laminar/A333/buttons/gpws/gs_mode_toggle")
gpws_flap_mode_toggle = find_command("laminar/A333/buttons/gpws/flap_mode_toggle")

turb_damp_toggle = find_command("sim/systems/yaw_damper_toggle")

hyd_eng1_green_toggle = find_command("sim/flight_controls/hydraulic_eng1A_tog")
hyd_eng1_blue_toggle = find_command("sim/flight_controls/hydraulic_eng1C_tog")
hyd_eng2_green_toggle = find_command("sim/flight_controls/hydraulic_eng2A_tog")
hyd_eng2_yellow_toggle = find_command("sim/flight_controls/hydraulic_eng2B_tog")

hyd_elec_yellow_toggle = find_command("laminar/A330/buttons/hyd/elec_yellow_toggle")
hyd_elec_blue_toggle = find_command("laminar/A330/buttons/hyd/elec_blue_toggle")
hyd_elec_green_toggle = find_command("laminar/A330/buttons/hyd/elec_green_toggle")

apu_gen_toggle = find_command("laminar/A333/buttons/APU_gen_toggle")
eng1_gen_toggle = find_command("sim/electrical/generator_1_toggle")
eng2_gen_toggle = find_command("sim/electrical/generator_2_toggle")
bus_tie_toggle = find_command("sim/electrical/cross_tie_toggle")
galley_toggle = find_command("laminar/A333/buttons/galley_toggle")
commercial_toggle = find_command("laminar/A333/buttons/commercial_toggle")

pack1_toggle = find_command("sim/bleed_air/pack_left_toggle")
pack2_toggle = find_command("sim/bleed_air/pack_right_toggle")
eng1_bleed_toggle = find_command("sim/bleed_air/engine_1_toggle")
eng2_bleed_toggle = find_command("sim/bleed_air/engine_2_toggle")
hot_air1_toggle = find_command("laminar/A333/switches/hot_air1_toggle")
hot_air2_toggle = find_command("laminar/A333/switches/hot_air2_toggle")

pax_sys_toggle = find_command("laminar/A333/buttons/pax_sys_toggle")
pax_satcom_toggle = find_command("laminar/A333/buttons/pax_satcom_toggle")
pax_ifec_toggle = find_command("laminar/A333/buttons/pax_IFEC_toggle")

cargo_fwd_isol_valve_toggle = find_command("laminar/A333/buttons/cargo_cond/fwd_isol_valve_tog")
cargo_bulk_isol_valve_toggle = find_command("laminar/A333/buttons/cargo_cond/bulk_isol_valve_tog")
cargo_hot_air_toggle = find_command("laminar/A333/buttons/cargo_cond/hot_air_tog")

ventilation_extract_ovrd_toggle = find_command("laminar/A333/buttons/ventilation_extract_ovrd_tog")
cabin_fan_toggle = find_command("laminar/A333/buttons/cabin_fan_tog")

efis_capt_knob_right = find_command("laminar/A333/knobs/capt_EFIS_knob_right")
efis_fo_knob_right = find_command("laminar/A333/knobs/fo_EFIS_knob_right")

baro_capt_hPa = find_command("laminar/A333/knob/baro/capt_hPa")
baro_fo_hPa = find_command("laminar/A333/knob/baro/fo_hPa")

autopilot_alt_step_right = find_command("laminar/A333/autopilot/alt_step_right")

battery_display_up = find_command("laminar/A333/switches/battery_display_up")

map_zoom_in = find_command("sim/instruments/map_zoom_in")
map_copilot_zoom_in = find_command("sim/instruments/map_copilot_zoom_in")

transponder_mode_left = find_command("laminar/A333/transponder/auto_on_off_left")

audio_capt_mic_vhf1 = find_command("laminar/A333/audio/capt/mic_push1")
audio_fo_mic_vhf2 = find_command("laminar/A333/audio/fo/mic_push2")

audio_capt_listen_vhf1 = find_command("laminar/A333/audio/capt/listen_press00")
audio_capt_listen_vhf2 = find_command("laminar/A333/audio/capt/listen_press01")

fdir_command_bars_pilot = find_command("sim/autopilot/fdir_command_bars_toggle")
fdir_command_bars_copilot = find_command("sim/autopilot/fdir2_command_bars_toggle")

rtp_L_off_switch = find_command("laminar/A333/rtp_L/off_switch")
rtp_R_off_switch = find_command("laminar/A333/rtp_R/off_switch")
rtp_C_off_switch = find_command("laminar/A333/rtp_C/off_switch")

efis_1_selection_pilot = find_dataref("sim/cockpit2/EFIS/EFIS_1_selection_pilot")
efis_2_selection_pilot = find_dataref("sim/cockpit2/EFIS/EFIS_2_selection_pilot")
efis_1_selection_copilot = find_dataref("sim/cockpit2/EFIS/EFIS_1_selection_copilot")
efis_2_selection_copilot = find_dataref("sim/cockpit2/EFIS/EFIS_2_selection_copilot")

autopilot_altitude = find_dataref("sim/cockpit/autopilot/altitude")
elevator_trim = find_dataref("sim/flightmodel2/controls/elevator_trim")
transponder_code = find_dataref("sim/cockpit/radios/transponder_code")

-- added Chock on at C&D ~quack
set_chocks = find_command("durantula/tablet_click_page2_chocks")

function A333_setup_cold_and_dark()
    adirs_adr1_toggle:once()
    adirs_adr2_toggle:once()
    adirs_adr3_toggle:once()

    adirs_ir1_toggle:once()
    adirs_ir2_toggle:once()
    adirs_ir3_toggle:once()

    fcc_prim1_toggle:once()
    fcc_prim2_toggle:once()
    fcc_prim3_toggle:once()
    fcc_sec1_toggle:once()
    fcc_sec2_toggle:once()

    gpws_ter_toggle:once()
    gpws_sys_toggle:once()
    gpws_gs_mode_toggle:once()
    gpws_flap_mode_toggle:once()

    turb_damp_toggle:once()

    hyd_eng1_green_toggle:once()
    hyd_eng1_blue_toggle:once()
    hyd_eng2_green_toggle:once()
    hyd_eng2_yellow_toggle:once()

    hyd_elec_yellow_toggle:once()
    hyd_elec_blue_toggle:once()
    hyd_elec_green_toggle:once()

    apu_gen_toggle:once()
    eng1_gen_toggle:once()
    eng2_gen_toggle:once()
    bus_tie_toggle:once()
    galley_toggle:once()
    commercial_toggle:once()

    pack1_toggle:once()
    pack2_toggle:once()
    eng1_bleed_toggle:once()
    eng2_bleed_toggle:once()
    hot_air1_toggle:once()
    hot_air2_toggle:once()

    pax_sys_toggle:once()
    pax_satcom_toggle:once()
    pax_ifec_toggle:once()

    cargo_fwd_isol_valve_toggle:once()
    cargo_bulk_isol_valve_toggle:once()
    cargo_hot_air_toggle:once()

    ventilation_extract_ovrd_toggle:once()
    cabin_fan_toggle:once()

    efis_capt_knob_right:once()
    efis_capt_knob_right:once()
    efis_capt_knob_right:once()
    efis_fo_knob_right:once()
    efis_fo_knob_right:once()
    efis_fo_knob_right:once()

    baro_capt_hPa:once()
    baro_fo_hPa:once()

    autopilot_alt_step_right:once()

    battery_display_up:once()
    battery_display_up:once()

    map_zoom_in:once()
    map_zoom_in:once()
    map_copilot_zoom_in:once()
    map_copilot_zoom_in:once()

    transponder_mode_left:once()

    audio_capt_mic_vhf1:once()
    audio_fo_mic_vhf2:once()
    audio_fo_mic_vhf2:once()    -- second push necessary to get the dataref right... 

    audio_capt_listen_vhf1:once()
    audio_capt_listen_vhf2:once()

    fdir_command_bars_pilot:once()
    fdir_command_bars_copilot:once()

    rtp_L_off_switch:once()
    rtp_R_off_switch:once()
    rtp_C_off_switch:once()

    set_chocks:once()

    efis_1_selection_pilot = 1
    efis_2_selection_pilot = 1
    efis_1_selection_copilot = 1
    efis_2_selection_copilot = 1

    transponder_code = 2000
    autopilot_altitude = 5000
    elevator_trim = -0.75
end

function flight_start()
    if sim_startup_running == 0 then
        A333_setup_cold_and_dark()
    end
end
