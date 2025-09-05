--[[
*****************************************************************************************
* Program Script Name	:	A333.comms
* Author Name			:	Alex Unruh
*
*   Revisions:
*   -- DATE --	--- REV NO ---		--- DESCRIPTION ---
*
*
*
*
*
*****************************************************************************************
*        COPYRIGHT © 2021, 2022 ALEX UNRUH / LAMINAR RESEARCH - ALL RIGHTS RESERVED
*****************************************************************************************
--]]



--*************************************************************************************--
--** 					              XLUA GLOBALS              				     **--
--*************************************************************************************--

--[[

SIM_PERIOD - this contains the duration of the current frame in seconds (so it is alway a
fraction).  Use this to normalize rates,  e.g. to add 3 units of fuel per second in a
per-frame callback you’d do fuel = fuel + 3 * SIM_PERIOD.

IN_REPLAY - evaluates to 0 if replay is off, 1 if replay mode is on

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




--*************************************************************************************--
--** 				                X-PLANE DATAREFS            			    	 **--
--*************************************************************************************--

simDR_startup_running       = find_dataref("sim/operation/prefs/startup_running")





--*************************************************************************************--
--** 				              FIND CUSTOM DATAREFS             			    	 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				        CREATE READ-ONLY CUSTOM DATAREFS               	         **--
--*************************************************************************************--

-- RADIO TUNING PANEL LEFT
A333DR_rtp_L_offside_tuning_status  = create_dataref("laminar/A333/comm/rtp_L/offside_tuning_status", "number")
A333DR_rtp_L_off_status             = create_dataref("laminar/A333/comm/rtp_L/off_status", "number")
A333DR_rtp_L_vhf_1_status           = create_dataref("laminar/A333/comm/rtp_L/vhf_1_status", "number")
A333DR_rtp_L_vhf_2_status           = create_dataref("laminar/A333/comm/rtp_L/vhf_2_status", "number")
A333DR_rtp_L_vhf_3_status           = create_dataref("laminar/A333/comm/rtp_L/vhf_3_status", "number")
A333DR_rtp_L_hf_1_status            = create_dataref("laminar/A333/comm/rtp_L/hf_1_status", "number")
A333DR_rtp_L_am_status              = create_dataref("laminar/A333/comm/rtp_L/am_status", "number")
A333DR_rtp_L_hf_2_status            = create_dataref("laminar/A333/comm/rtp_L/hf_2_status", "number")
A333DR_rtp_L_freq_MHz_sel_dial_pos  = create_dataref("laminar/A333/comm/rtp_L/freq_MHz/sel_dial_pos", "number")
A333DR_rtp_L_freq_khz_sel_dial_pos  = create_dataref("laminar/A333/comm/rtp_L/freq_khz/sel_dial_pos", "number")
A333DR_rtp_L_lcd_to_display         = create_dataref("laminar/A333/comm/rtp_L/lcd_to_display", "number")

A333DR_rtp_L_freq_switch_pos		= create_dataref("laminar/A333/comm/push_button/rtp_L_freq_swap", "number")

A333DR_rtp_L_vhf_1_pos				= create_dataref("laminar/A333/comm/push_button/rtp_L_vhf_1_pos", "number")
A333DR_rtp_L_vhf_2_pos				= create_dataref("laminar/A333/comm/push_button/rtp_L_vhf_2_pos", "number")
A333DR_rtp_L_vhf_3_pos				= create_dataref("laminar/A333/comm/push_button/rtp_L_vhf_3_pos", "number")
A333DR_rtp_L_hf_1_pos				= create_dataref("laminar/A333/comm/push_button/rtp_L_hf_1_pos", "number")
A333DR_rtp_L_hf_2_pos				= create_dataref("laminar/A333/comm/push_button/rtp_L_hf_2_pos", "number")
A333DR_rtp_L_am_pos					= create_dataref("laminar/A333/comm/push_button/rtp_L_am_pos", "number")


-- RADIO TUNING PANEL RIGHT
A333DR_rtp_R_offside_tuning_status  = create_dataref("laminar/A333/comm/rtp_R/offside_tuning_status", "number")
A333DR_rtp_R_off_status             = create_dataref("laminar/A333/comm/rtp_R/off_status", "number")
A333DR_rtp_R_vhf_1_status           = create_dataref("laminar/A333/comm/rtp_R/vhf_1_status", "number")
A333DR_rtp_R_vhf_2_status           = create_dataref("laminar/A333/comm/rtp_R/vhf_2_status", "number")
A333DR_rtp_R_vhf_3_status           = create_dataref("laminar/A333/comm/rtp_R/vhf_3_status", "number")
A333DR_rtp_R_hf_1_status            = create_dataref("laminar/A333/comm/rtp_R/hf_1_status", "number")
A333DR_rtp_R_am_status              = create_dataref("laminar/A333/comm/rtp_R/am_status", "number")
A333DR_rtp_R_hf_2_status            = create_dataref("laminar/A333/comm/rtp_R/hf_2_status", "number")
A333DR_rtp_R_freq_MHz_sel_dial_pos  = create_dataref("laminar/A333/comm/rtp_R/freq_MHz/sel_dial_pos", "number")
A333DR_rtp_R_freq_khz_sel_dial_pos  = create_dataref("laminar/A333/comm/rtp_R/freq_khz/sel_dial_pos", "number")
A333DR_rtp_R_lcd_to_display         = create_dataref("laminar/A333/comm/rtp_R/lcd_to_display", "number")

A333DR_rtp_R_freq_switch_pos		= create_dataref("laminar/A333/comm/push_button/rtp_R_freq_swap", "number")

A333DR_rtp_R_vhf_1_pos				= create_dataref("laminar/A333/comm/push_button/rtp_R_vhf_1_pos", "number")
A333DR_rtp_R_vhf_2_pos				= create_dataref("laminar/A333/comm/push_button/rtp_R_vhf_2_pos", "number")
A333DR_rtp_R_vhf_3_pos				= create_dataref("laminar/A333/comm/push_button/rtp_R_vhf_3_pos", "number")
A333DR_rtp_R_hf_1_pos				= create_dataref("laminar/A333/comm/push_button/rtp_R_hf_1_pos", "number")
A333DR_rtp_R_hf_2_pos				= create_dataref("laminar/A333/comm/push_button/rtp_R_hf_2_pos", "number")
A333DR_rtp_R_am_pos					= create_dataref("laminar/A333/comm/push_button/rtp_R_am_pos", "number")

-- RADIO TUNING PANEL CENTER
A333DR_rtp_C_offside_tuning_status  = create_dataref("laminar/A333/comm/rtp_C/offside_tuning_status", "number")
A333DR_rtp_C_off_status             = create_dataref("laminar/A333/comm/rtp_C/off_status", "number")
A333DR_rtp_C_vhf_1_status           = create_dataref("laminar/A333/comm/rtp_C/vhf_1_status", "number")
A333DR_rtp_C_vhf_2_status           = create_dataref("laminar/A333/comm/rtp_C/vhf_2_status", "number")
A333DR_rtp_C_vhf_3_status           = create_dataref("laminar/A333/comm/rtp_C/vhf_3_status", "number")
A333DR_rtp_C_hf_1_status            = create_dataref("laminar/A333/comm/rtp_C/hf_1_status", "number")
A333DR_rtp_C_am_status              = create_dataref("laminar/A333/comm/rtp_C/am_status", "number")
A333DR_rtp_C_hf_2_status            = create_dataref("laminar/A333/comm/rtp_C/hf_2_status", "number")
A333DR_rtp_C_freq_MHz_sel_dial_pos  = create_dataref("laminar/A333/comm/rtp_C/freq_MHz/sel_dial_pos", "number")
A333DR_rtp_C_freq_khz_sel_dial_pos  = create_dataref("laminar/A333/comm/rtp_C/freq_khz/sel_dial_pos", "number")
A333DR_rtp_C_lcd_to_display         = create_dataref("laminar/A333/comm/rtp_C/lcd_to_display", "number")

A333DR_rtp_C_freq_switch_pos		= create_dataref("laminar/A333/comm/push_button/rtp_C_freq_swap", "number")

A333DR_rtp_C_vhf_1_pos				= create_dataref("laminar/A333/comm/push_button/rtp_C_vhf_1_pos", "number")
A333DR_rtp_C_vhf_2_pos				= create_dataref("laminar/A333/comm/push_button/rtp_C_vhf_2_pos", "number")
A333DR_rtp_C_vhf_3_pos				= create_dataref("laminar/A333/comm/push_button/rtp_C_vhf_3_pos", "number")
A333DR_rtp_C_hf_1_pos				= create_dataref("laminar/A333/comm/push_button/rtp_C_hf_1_pos", "number")
A333DR_rtp_C_hf_2_pos				= create_dataref("laminar/A333/comm/push_button/rtp_C_hf_2_pos", "number")
A333DR_rtp_C_am_pos					= create_dataref("laminar/A333/comm/push_button/rtp_C_am_pos", "number")

----

A333DR_init_comms_CD				= create_dataref("laminar/A333/init_CD/comms", "number")


--*************************************************************************************--
--** 				       READ-WRITE CUSTOM DATAREF HANDLERS     	        	     **--
--*************************************************************************************--


--*************************************************************************************--
--** 				       CREATE READ-WRITE CUSTOM DATAREFS                         **--
--*************************************************************************************--


--*************************************************************************************--
--** 				             X-PLANE COMMAND HANDLERS               	    	 **--
--*************************************************************************************--


--*************************************************************************************--
--** 				                 X-PLANE COMMANDS                   	    	 **--
--*************************************************************************************--

simCMD_com1_stby_coarse_up  = find_command("sim/radios/stby_com1_coarse_up")
simCMD_com1_stby_coarse_dn  = find_command("sim/radios/stby_com1_coarse_down")
simCMD_com2_stby_coarse_up  = find_command("sim/radios/stby_com2_coarse_up")
simCMD_com2_stby_coarse_dn  = find_command("sim/radios/stby_com2_coarse_down")

simCMD_com1_stby_fine_up    = find_command("sim/radios/stby_com1_fine_up_833")
simCMD_com1_stby_fine_dn    = find_command("sim/radios/stby_com1_fine_down_833")
simCMD_com2_stby_fine_up    = find_command("sim/radios/stby_com2_fine_up_833")
simCMD_com2_stby_fine_dn    = find_command("sim/radios/stby_com2_fine_down_833")

simCMD_com1_stby_flip       = find_command("sim/radios/com1_standy_flip")
simCMD_com2_stby_flip       = find_command("sim/radios/com2_standy_flip")



--*************************************************************************************--
--** 				              CUSTOM COMMAND HANDLERS            			     **--
--*************************************************************************************--

-- RADIO TUNING PANEL LEFT
function A333_rtp_L_off_switch_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_L_off_status == 0 then
            A333DR_rtp_L_off_status = 1
            A333DR_rtp_L_lcd_to_display = 90
        elseif A333DR_rtp_L_off_status == 1 then
            A333DR_rtp_L_off_status = 0
            A333_lcd_display_status()
        end
    end
end

function A333_rtp_L_vhf_1_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(0, 1, 0, 0, 0, 0, 0)
        A333DR_rtp_L_vhf_1_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_L_vhf_1_pos = 0
    end
end

function A333_rtp_L_vhf_2_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(0, 0, 1, 0, 0, 0, 0)
        A333DR_rtp_L_vhf_2_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_L_vhf_2_pos = 0
    end
end

function A333_rtp_L_vhf_3_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(0, 0, 0, 1, 0, 0, 0)
		A333DR_rtp_L_vhf_3_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_L_vhf_3_pos = 0
    end
end

function A333_rtp_L_hf_1_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
		A333_radio_sel_swap(0, 0, 0, 0, 1, 0, 0)
		A333DR_rtp_L_hf_1_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_L_hf_1_pos = 0
    end
end

function A333_rtp_L_am_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(0, 0, 0, 0, 0, 1, 0)
		A333DR_rtp_L_am_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_L_am_pos = 0
    end
end

function A333_rtp_L_hf_2_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(0, 0, 0, 0, 0, 0, 1)
		A333DR_rtp_L_hf_2_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_L_hf_2_pos = 0
    end
end

function A333_rtp_L_freq_txfr_switch_CMDhandler(phase, duration)
    if phase == 0 then
    	A333DR_rtp_L_freq_switch_pos = 1
        if A333DR_rtp_L_lcd_to_display == 0 then
            simCMD_com1_stby_flip:once()
    	elseif A333DR_rtp_L_lcd_to_display == 1 then
            simCMD_com2_stby_flip:once()
        end
    elseif phase == 2 then
      	A333DR_rtp_L_freq_switch_pos = 0
    end
end

function A333_rtp_L_freq_MHz_sel_dial_up_CMDhandler(phase, duration)

    if phase == 0 then
        if A333DR_rtp_L_off_status == 0 then
            if A333DR_rtp_L_lcd_to_display == 0 then
                simCMD_com1_stby_coarse_up:once()
            elseif A333DR_rtp_L_lcd_to_display == 1 then
                simCMD_com2_stby_coarse_up:once()
            end
        end
        A333DR_rtp_L_freq_MHz_sel_dial_pos = A333DR_rtp_L_freq_MHz_sel_dial_pos + 1
    elseif phase == 1 then
        if duration > 0.5 then
            if A333DR_rtp_L_off_status == 0 then
                if A333DR_rtp_L_lcd_to_display == 0 then
                    simCMD_com1_stby_coarse_up:once()
                elseif A333DR_rtp_L_lcd_to_display == 1 then
                    simCMD_com2_stby_coarse_up:once()
                end
            end
            A333DR_rtp_L_freq_MHz_sel_dial_pos = A333DR_rtp_L_freq_MHz_sel_dial_pos + 1
        end
    end

end

function A333_rtp_L_freq_MHz_sel_dial_dn_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_L_off_status == 0 then
            if A333DR_rtp_L_lcd_to_display == 0 then
                simCMD_com1_stby_coarse_dn:once()
            elseif A333DR_rtp_L_lcd_to_display == 1 then
                simCMD_com2_stby_coarse_dn:once()
            end
        end
        A333DR_rtp_L_freq_MHz_sel_dial_pos = A333DR_rtp_L_freq_MHz_sel_dial_pos - 1
    elseif phase == 1 then
        if duration > 0.5 then
            if A333DR_rtp_L_off_status == 0 then
                if A333DR_rtp_L_lcd_to_display == 0 then
                    simCMD_com1_stby_coarse_dn:once()
                elseif A333DR_rtp_L_lcd_to_display == 1 then
                    simCMD_com2_stby_coarse_dn:once()
                end
            end
            A333DR_rtp_L_freq_MHz_sel_dial_pos = A333DR_rtp_L_freq_MHz_sel_dial_pos - 1
        end
    end
end

function A333_rtp_L_freq_khz_sel_dial_up_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_L_off_status == 0 then
            if A333DR_rtp_L_lcd_to_display == 0 then
                simCMD_com1_stby_fine_up:once()
            elseif A333DR_rtp_L_lcd_to_display == 1 then
                simCMD_com2_stby_fine_up:once()
            end
        end
        A333DR_rtp_L_freq_khz_sel_dial_pos = A333DR_rtp_L_freq_khz_sel_dial_pos + 1
    elseif phase == 1 then
        if duration > 0.5 then
            if A333DR_rtp_L_off_status == 0 then
                if A333DR_rtp_L_lcd_to_display == 0 then
                    simCMD_com1_stby_fine_up:once()
                elseif A333DR_rtp_L_lcd_to_display == 1 then
                    simCMD_com2_stby_fine_up:once()
                end
            end
            A333DR_rtp_L_freq_khz_sel_dial_pos = A333DR_rtp_L_freq_khz_sel_dial_pos + 1
        end
    end
end

function A333_rtp_L_freq_khz_sel_dial_dn_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_L_off_status == 0 then
            if A333DR_rtp_L_lcd_to_display == 0 then
                simCMD_com1_stby_fine_dn:once()
            elseif A333DR_rtp_L_lcd_to_display == 1 then
                simCMD_com2_stby_fine_dn:once()
            end
        end
        A333DR_rtp_L_freq_khz_sel_dial_pos = A333DR_rtp_L_freq_khz_sel_dial_pos - 1
    elseif phase == 1 then
        if duration > 0.5 then
            if A333DR_rtp_L_off_status == 0 then
                if A333DR_rtp_L_lcd_to_display == 0 then
                    simCMD_com1_stby_fine_dn:once()
                elseif A333DR_rtp_L_lcd_to_display == 1 then
                    simCMD_com2_stby_fine_dn:once()
                end
            end
            A333DR_rtp_L_freq_khz_sel_dial_pos = A333DR_rtp_L_freq_khz_sel_dial_pos - 1
        end
    end
end


-- RADIO TUNING PANEL RIGHT
function A333_rtp_R_off_switch_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_R_off_status == 0 then
            A333DR_rtp_R_off_status = 1
            A333DR_rtp_R_lcd_to_display = 90
        elseif A333DR_rtp_R_off_status == 1 then
            A333DR_rtp_R_off_status = 0
            A333_lcd_display_status()
        end
    end
end

function A333_rtp_R_vhf_1_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(1, 1, 0, 0, 0, 0, 0)
        A333DR_rtp_R_vhf_1_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_R_vhf_1_pos = 0
    end
end

function A333_rtp_R_vhf_2_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(1, 0, 1, 0, 0, 0, 0)
        A333DR_rtp_R_vhf_2_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_R_vhf_2_pos = 0
    end
end

function A333_rtp_R_vhf_3_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(1, 0, 0, 1, 0, 0, 0)
		A333DR_rtp_R_vhf_3_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_R_vhf_3_pos = 0
    end
end

function A333_rtp_R_hf_1_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
		A333_radio_sel_swap(1, 0, 0, 0, 1, 0, 0)
		A333DR_rtp_R_hf_1_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_R_hf_1_pos = 0
    end
end

function A333_rtp_R_am_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(1, 0, 0, 0, 0, 1, 0)
		A333DR_rtp_R_am_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_R_am_pos = 0
    end
end

function A333_rtp_R_hf_2_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(1, 0, 0, 0, 0, 0, 1)
		A333DR_rtp_R_hf_2_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_R_hf_2_pos = 0
    end
end

function A333_rtp_R_freq_txfr_switch_CMDhandler(phase, duration)
    if phase == 0 then
    	A333DR_rtp_R_freq_switch_pos = 1
		if A333DR_rtp_R_lcd_to_display == 0 then
			simCMD_com1_stby_flip:once()
		elseif A333DR_rtp_R_lcd_to_display == 1 then
			simCMD_com2_stby_flip:once()
        end
	elseif phase == 2 then
		A333DR_rtp_R_freq_switch_pos = 0
    end
end

function A333_rtp_R_freq_MHz_sel_dial_up_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_R_off_status == 0 then
            if A333DR_rtp_R_lcd_to_display == 0 then
                simCMD_com1_stby_coarse_up:once()
            elseif A333DR_rtp_R_lcd_to_display == 1 then
                simCMD_com2_stby_coarse_up:once()
            end
        end
        A333DR_rtp_R_freq_MHz_sel_dial_pos = A333DR_rtp_R_freq_MHz_sel_dial_pos + 1
    elseif phase == 1 then
        if duration > 0.5 then
            if A333DR_rtp_R_off_status == 0 then
                if A333DR_rtp_R_lcd_to_display == 0 then
                    simCMD_com1_stby_coarse_up:once()
                elseif A333DR_rtp_R_lcd_to_display == 1 then
                    simCMD_com2_stby_coarse_up:once()
                end
            end
            A333DR_rtp_R_freq_MHz_sel_dial_pos = A333DR_rtp_R_freq_MHz_sel_dial_pos + 1
        end
    end
end

function A333_rtp_R_freq_MHz_sel_dial_dn_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_R_off_status == 0 then
            if A333DR_rtp_R_lcd_to_display == 0 then
                simCMD_com1_stby_coarse_dn:once()
            elseif A333DR_rtp_R_lcd_to_display == 1 then
                simCMD_com2_stby_coarse_dn:once()
            end
        end
        A333DR_rtp_R_freq_MHz_sel_dial_pos = A333DR_rtp_R_freq_MHz_sel_dial_pos - 1
    elseif phase == 1 then
        if duration > 0.5 then
            if A333DR_rtp_R_lcd_to_display == 0 then
                simCMD_com1_stby_coarse_dn:once()
            elseif A333DR_rtp_R_lcd_to_display == 1 then
                simCMD_com2_stby_coarse_dn:once()
            end
            A333DR_rtp_R_freq_MHz_sel_dial_pos = A333DR_rtp_R_freq_MHz_sel_dial_pos - 1
        end
    end
end

function A333_rtp_R_freq_khz_sel_dial_up_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_R_off_status == 0 then
            if A333DR_rtp_R_lcd_to_display == 0 then
                simCMD_com1_stby_fine_up:once()
            elseif A333DR_rtp_R_lcd_to_display == 1 then
                simCMD_com2_stby_fine_up:once()
            end
        end
        A333DR_rtp_R_freq_khz_sel_dial_pos = A333DR_rtp_R_freq_khz_sel_dial_pos + 1
    elseif phase == 1 then
        if duration > 0.5 then
            if A333DR_rtp_R_off_status == 0 then
                if A333DR_rtp_R_lcd_to_display == 0 then
                    simCMD_com1_stby_fine_up:once()
                elseif A333DR_rtp_R_lcd_to_display == 1 then
                    simCMD_com2_stby_fine_up:once()
                end
            end
            A333DR_rtp_R_freq_khz_sel_dial_pos = A333DR_rtp_R_freq_khz_sel_dial_pos + 1
        end
    end
end

function A333_rtp_R_freq_khz_sel_dial_dn_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_R_off_status == 0 then
            if A333DR_rtp_R_lcd_to_display == 0 then
                simCMD_com1_stby_fine_dn:once()
            elseif A333DR_rtp_R_lcd_to_display == 1 then
                simCMD_com2_stby_fine_dn:once()
            end
        end
        A333DR_rtp_R_freq_khz_sel_dial_pos = A333DR_rtp_R_freq_khz_sel_dial_pos - 1
    elseif phase == 1 then
        if duration > 0.5 then
            if A333DR_rtp_R_off_status == 0 then
                if A333DR_rtp_R_lcd_to_display == 0 then
                    simCMD_com1_stby_fine_dn:once()
                elseif A333DR_rtp_R_lcd_to_display == 1 then
                    simCMD_com2_stby_fine_dn:once()
                end
            end
            A333DR_rtp_R_freq_khz_sel_dial_pos = A333DR_rtp_R_freq_khz_sel_dial_pos - 1
        end
    end
end


-- RADIO TUNING PANEL CENTER
function A333_rtp_C_off_switch_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_C_off_status == 0 then
            A333DR_rtp_C_off_status = 1
            A333DR_rtp_C_lcd_to_display = 90
        elseif A333DR_rtp_C_off_status == 1 then
            A333DR_rtp_C_off_status = 0
            A333_lcd_display_status()
        end
    end
end

function A333_rtp_C_vhf_1_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(2, 1, 0, 0, 0, 0, 0)
        A333DR_rtp_C_vhf_1_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_C_vhf_1_pos = 0
    end
end

function A333_rtp_C_vhf_2_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(2, 0, 1, 0, 0, 0, 0)
        A333DR_rtp_C_vhf_2_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_C_vhf_2_pos = 0
    end
end

function A333_rtp_C_vhf_3_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(2, 0, 0, 1, 0, 0, 0)
		A333DR_rtp_C_vhf_3_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_C_vhf_3_pos = 0
    end
end

function A333_rtp_C_hf_1_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
		A333_radio_sel_swap(2, 0, 0, 0, 1, 0, 0)
		A333DR_rtp_C_hf_1_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_C_hf_1_pos = 0
    end
end

function A333_rtp_C_am_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(2, 0, 0, 0, 0, 1, 0)
		A333DR_rtp_C_am_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_C_am_pos = 0
    end
end

function A333_rtp_C_hf_2_sel_switch_CMDhandler(phase, duration)
    if phase == 0 then
        A333_radio_sel_swap(2, 0, 0, 0, 0, 0, 1)
		A333DR_rtp_C_hf_2_pos = 1
    elseif phase == 2 then
    	A333DR_rtp_C_hf_2_pos = 0
    end
end

function A333_rtp_C_freq_txfr_switch_CMDhandler(phase, duration)
    if phase == 0 then
    	A333DR_rtp_C_freq_switch_pos = 1
		if A333DR_rtp_C_lcd_to_display == 0 then
			simCMD_com1_stby_flip:once()
		elseif A333DR_rtp_C_lcd_to_display == 1 then
			simCMD_com2_stby_flip:once()
        end
	elseif phase == 2 then
		A333DR_rtp_C_freq_switch_pos = 0
    end
end

function A333_rtp_C_freq_MHz_sel_dial_up_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_C_off_status == 0 then
            if A333DR_rtp_C_lcd_to_display == 0 then
                simCMD_com1_stby_coarse_up:once()
            elseif A333DR_rtp_C_lcd_to_display == 1 then
                simCMD_com2_stby_coarse_up:once()
            end
        end
        A333DR_rtp_C_freq_MHz_sel_dial_pos = A333DR_rtp_C_freq_MHz_sel_dial_pos + 1
    elseif phase == 1 then
        if duration > 0.5 then
            if A333DR_rtp_C_off_status == 0 then
                if A333DR_rtp_C_lcd_to_display == 0 then
                    simCMD_com1_stby_coarse_up:once()
                elseif A333DR_rtp_C_lcd_to_display == 1 then
                    simCMD_com2_stby_coarse_up:once()
                end
            end
            A333DR_rtp_C_freq_MHz_sel_dial_pos = A333DR_rtp_C_freq_MHz_sel_dial_pos + 1
        end
    end
end

function A333_rtp_C_freq_MHz_sel_dial_dn_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_C_off_status == 0 then
            if A333DR_rtp_C_lcd_to_display == 0 then
                simCMD_com1_stby_coarse_dn:once()
            elseif A333DR_rtp_C_lcd_to_display == 1 then
                simCMD_com2_stby_coarse_dn:once()
            end
        end
        A333DR_rtp_C_freq_MHz_sel_dial_pos = A333DR_rtp_C_freq_MHz_sel_dial_pos - 1
    elseif phase == 1 then
        if duration > 0.5 then
            if A333DR_rtp_C_lcd_to_display == 0 then
                simCMD_com1_stby_coarse_dn:once()
            elseif A333DR_rtp_C_lcd_to_display == 1 then
                simCMD_com2_stby_coarse_dn:once()
            end
            A333DR_rtp_C_freq_MHz_sel_dial_pos = A333DR_rtp_C_freq_MHz_sel_dial_pos - 1
        end
    end
end

function A333_rtp_C_freq_khz_sel_dial_up_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_C_off_status == 0 then
            if A333DR_rtp_C_lcd_to_display == 0 then
                simCMD_com1_stby_fine_up:once()
            elseif A333DR_rtp_C_lcd_to_display == 1 then
                simCMD_com2_stby_fine_up:once()
            end
        end
        A333DR_rtp_C_freq_khz_sel_dial_pos = A333DR_rtp_C_freq_khz_sel_dial_pos + 1
    elseif phase == 1 then
        if duration > 0.5 then
            if A333DR_rtp_C_off_status == 0 then
                if A333DR_rtp_C_lcd_to_display == 0 then
                    simCMD_com1_stby_fine_up:once()
                elseif A333DR_rtp_C_lcd_to_display == 1 then
                    simCMD_com2_stby_fine_up:once()
                end
            end
            A333DR_rtp_C_freq_khz_sel_dial_pos = A333DR_rtp_C_freq_khz_sel_dial_pos + 1
        end
    end
end

function A333_rtp_C_freq_khz_sel_dial_dn_CMDhandler(phase, duration)
    if phase == 0 then
        if A333DR_rtp_C_off_status == 0 then
            if A333DR_rtp_C_lcd_to_display == 0 then
                simCMD_com1_stby_fine_dn:once()
            elseif A333DR_rtp_C_lcd_to_display == 1 then
                simCMD_com2_stby_fine_dn:once()
            end
        end
        A333DR_rtp_C_freq_khz_sel_dial_pos = A333DR_rtp_C_freq_khz_sel_dial_pos - 1
    elseif phase == 1 then
        if duration > 0.5 then
            if A333DR_rtp_C_off_status == 0 then
                if A333DR_rtp_C_lcd_to_display == 0 then
                    simCMD_com1_stby_fine_dn:once()
                elseif A333DR_rtp_C_lcd_to_display == 1 then
                    simCMD_com2_stby_fine_dn:once()
                end
            end
            A333DR_rtp_C_freq_khz_sel_dial_pos = A333DR_rtp_C_freq_khz_sel_dial_pos - 1
        end
    end
end


-- AI

function A333_ai_comms_quick_start_CMDhandler(phase, duration)
    if phase == 0 then
	  	A333_set_comms_all_modes()
	  	A333_set_comms_CD()
	  	A333_set_comms_ER()
	end
end


--*************************************************************************************--
--** 				              CREATE CUSTOM COMMANDS              			     **--
--*************************************************************************************--

-- RADIO TUNING PANEL LEFT
A333CMD_rtp_L_off_switch            = create_command("laminar/A333/rtp_L/off_switch", "Radio Tuning Panel Left ON/OFF Switch", A333_rtp_L_off_switch_CMDhandler)
A333CMD_rtp_L_vhf_1_sel_switch      = create_command("laminar/A333/rtp_L/vhf_1/sel_switch", "Radio Tuning Panel Left VHF L Sel Switch", A333_rtp_L_vhf_1_sel_switch_CMDhandler)
A333CMD_rtp_L_vhf_2_sel_switch      = create_command("laminar/A333/rtp_L/vhf_2/sel_switch", "Radio Tuning Panel Left VHF C Sel Switch", A333_rtp_L_vhf_2_sel_switch_CMDhandler)
A333CMD_rtp_L_vhf_3_sel_switch      = create_command("laminar/A333/rtp_L/vhf_3/sel_switch", "Radio Tuning Panel Left VHF R Sel Switch", A333_rtp_L_vhf_3_sel_switch_CMDhandler)
A333CMD_rtp_L_hf_1_sel_switch       = create_command("laminar/A333/rtp_L/hf_1/sel_switch", "Radio Tuning Panel Left HF L SelSwitch", A333_rtp_L_hf_1_sel_switch_CMDhandler)
A333CMD_rtp_L_am_sel_switch         = create_command("laminar/A333/rtp_L/am/sel_switch", "Radio Tuning Panel Left AM Sel Switch", A333_rtp_L_am_sel_switch_CMDhandler)
A333CMD_rtp_L_hf_2_sel_switch       = create_command("laminar/A333/rtp_L/hf_2/sel_switch", "Radio Tuning Panel Left HF R Sel Switch", A333_rtp_L_hf_2_sel_switch_CMDhandler)
A333CMD_rtp_L_freq_txfr_switch      = create_command("laminar/A333/rtp_L/freq_txfr/sel_switch", "Radio Tuning Panel Left Freq Txfr Switch", A333_rtp_L_freq_txfr_switch_CMDhandler)

A333CMD_rtp_L_freq_MHz_sel_dial_up  = create_command("laminar/A333/rtp_L/freq_MHz/sel_dial_up", "Radio Tuning Panel Left Freq MHz Sel Up", A333_rtp_L_freq_MHz_sel_dial_up_CMDhandler)
A333CMD_rtp_L_freq_MHz_sel_dial_dn  = create_command("laminar/A333/rtp_L/freq_MHz/sel_dial_dn", "Radio Tuning Panel Left Freq MHz Sel Down", A333_rtp_L_freq_MHz_sel_dial_dn_CMDhandler)

A333CMD_rtp_L_freq_khz_sel_dial_up  = create_command("laminar/A333/rtp_L/freq_khz/sel_dial_up", "Radio Tuning Panel Left Freq khz Sel Up", A333_rtp_L_freq_khz_sel_dial_up_CMDhandler)
A333CMD_rtp_L_freq_khz_sel_dial_dn  = create_command("laminar/A333/rtp_L/freq_khz/sel_dial_dn", "Radio Tuning Panel Left Freq khz Sel Down", A333_rtp_L_freq_khz_sel_dial_dn_CMDhandler)


-- RADIO TUNING PANEL RIGHT
A333CMD_rtp_R_off_switch            = create_command("laminar/A333/rtp_R/off_switch", "Radio Tuning Panel Right ON/OFF Switch", A333_rtp_R_off_switch_CMDhandler)
A333CMD_rtp_R_vhf_1_sel_switch      = create_command("laminar/A333/rtp_R/vhf_1/sel_switch", "Radio Tuning Panel Right VHF L Sel Switch", A333_rtp_R_vhf_1_sel_switch_CMDhandler)
A333CMD_rtp_R_vhf_2_sel_switch      = create_command("laminar/A333/rtp_R/vhf_2/sel_switch", "Radio Tuning Panel Right VHF C Sel Switch", A333_rtp_R_vhf_2_sel_switch_CMDhandler)
A333CMD_rtp_R_vhf_3_sel_switch      = create_command("laminar/A333/rtp_R/vhf_3/sel_switch", "Radio Tuning Panel Right VHF R Sel Switch", A333_rtp_R_vhf_3_sel_switch_CMDhandler)
A333CMD_rtp_R_hf_1_sel_switch       = create_command("laminar/A333/rtp_R/hf_1/sel_switch", "Radio Tuning Panel Right HF L SelSwitch", A333_rtp_R_hf_1_sel_switch_CMDhandler)
A333CMD_rtp_R_am_sel_switch         = create_command("laminar/A333/rtp_R/am/sel_switch", "Radio Tuning Panel Right AM Sel Switch", A333_rtp_R_am_sel_switch_CMDhandler)
A333CMD_rtp_R_hf_2_sel_switch       = create_command("laminar/A333/rtp_R/hf_2/sel_switch", "Radio Tuning Panel Right HF R Sel Switch", A333_rtp_R_hf_2_sel_switch_CMDhandler)
A333CMD_rtp_R_freq_txfr_switch      = create_command("laminar/A333/rtp_R/freq_txfr/sel_switch", "Radio Tuning Panel Right Freq Txfr Switch", A333_rtp_R_freq_txfr_switch_CMDhandler)

A333CMD_rtp_R_freq_MHz_sel_dial_up  = create_command("laminar/A333/rtp_R/freq_MHz/sel_dial_up", "Radio Tuning Panel Right Freq MHz Sel Up", A333_rtp_R_freq_MHz_sel_dial_up_CMDhandler)
A333CMD_rtp_R_freq_MHz_sel_dial_dn  = create_command("laminar/A333/rtp_R/freq_MHz/sel_dial_dn", "Radio Tuning Panel Right Freq MHz Sel Down", A333_rtp_R_freq_MHz_sel_dial_dn_CMDhandler)

A333CMD_rtp_R_freq_khz_sel_dial_up  = create_command("laminar/A333/rtp_R/freq_khz/sel_dial_up", "Radio Tuning Panel Right Freq khz Sel Up", A333_rtp_R_freq_khz_sel_dial_up_CMDhandler)
A333CMD_rtp_R_freq_khz_sel_dial_dn  = create_command("laminar/A333/rtp_R/freq_khz/sel_dial_dn", "Radio Tuning Panel Right Freq khz Sel Down", A333_rtp_R_freq_khz_sel_dial_dn_CMDhandler)


-- RADIO TUNING PANEL CENTER
A333CMD_rtp_C_off_switch            = create_command("laminar/A333/rtp_C/off_switch", "Radio Tuning Panel Center ON/OFF Switch", A333_rtp_C_off_switch_CMDhandler)
A333CMD_rtp_C_vhf_1_sel_switch      = create_command("laminar/A333/rtp_C/vhf_1/sel_switch", "Radio Tuning Panel Center VHF L Sel Switch", A333_rtp_C_vhf_1_sel_switch_CMDhandler)
A333CMD_rtp_C_vhf_2_sel_switch      = create_command("laminar/A333/rtp_C/vhf_2/sel_switch", "Radio Tuning Panel Center VHF C Sel Switch", A333_rtp_C_vhf_2_sel_switch_CMDhandler)
A333CMD_rtp_C_vhf_3_sel_switch      = create_command("laminar/A333/rtp_C/vhf_3/sel_switch", "Radio Tuning Panel Center VHF R Sel Switch", A333_rtp_C_vhf_3_sel_switch_CMDhandler)
A333CMD_rtp_C_hf_1_sel_switch       = create_command("laminar/A333/rtp_C/hf_1/sel_switch", "Radio Tuning Panel Center HF L SelSwitch", A333_rtp_C_hf_1_sel_switch_CMDhandler)
A333CMD_rtp_C_am_sel_switch         = create_command("laminar/A333/rtp_C/am/sel_switch", "Radio Tuning Panel Center AM Sel Switch", A333_rtp_C_am_sel_switch_CMDhandler)
A333CMD_rtp_C_hf_2_sel_switch       = create_command("laminar/A333/rtp_C/hf_2/sel_switch", "Radio Tuning Panel Center HF R Sel Switch", A333_rtp_C_hf_2_sel_switch_CMDhandler)
A333CMD_rtp_C_freq_txfr_switch      = create_command("laminar/A333/rtp_C/freq_txfr/sel_switch", "Radio Tuning Panel Center Freq Txfr Switch", A333_rtp_C_freq_txfr_switch_CMDhandler)

A333CMD_rtp_C_freq_MHz_sel_dial_up  = create_command("laminar/A333/rtp_C/freq_MHz/sel_dial_up", "Radio Tuning Panel Center Freq MHz Sel Up", A333_rtp_C_freq_MHz_sel_dial_up_CMDhandler)
A333CMD_rtp_C_freq_MHz_sel_dial_dn  = create_command("laminar/A333/rtp_C/freq_MHz/sel_dial_dn", "Radio Tuning Panel Center Freq MHz Sel Down", A333_rtp_C_freq_MHz_sel_dial_dn_CMDhandler)

A333CMD_rtp_C_freq_khz_sel_dial_up  = create_command("laminar/A333/rtp_C/freq_khz/sel_dial_up", "Radio Tuning Panel Center Freq khz Sel Up", A333_rtp_C_freq_khz_sel_dial_up_CMDhandler)
A333CMD_rtp_C_freq_khz_sel_dial_dn  = create_command("laminar/A333/rtp_C/freq_khz/sel_dial_dn", "Radio Tuning Panel Center Freq khz Sel Down", A333_rtp_C_freq_khz_sel_dial_dn_CMDhandler)

-- AI

A333CMD_ai_comms_quick_start		= create_command("laminar/A333/ai/comms_quick_start", "AI Comms", A333_ai_comms_quick_start_CMDhandler)

--*************************************************************************************--
--** 					            OBJECT CONSTRUCTORS         		    		 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               CREATE SYSTEM OBJECTS            				 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				                  SYSTEM FUNCTIONS           	    			 **--
--*************************************************************************************--

----- RESCALE ---------------------------------------------------------------------------
function A333_rescale(in1, out1, in2, out2, x)

    if x < in1 then return out1 end
    if x > in2 then return out2 end
    return out1 + (out2 - out1) * (x - in1) / (in2 - in1)

end





----- ANIMATION UNILITY -----------------------------------------------------------------
function A333_set_animation_position(current_value, target, min, max, speed)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * (speed * SIM_PERIOD))
    end

end




----- LCD DISPLAY STATUS ----------------------------------------------------------------
function A333_lcd_display_status()

    -- SET WHICH LCD TO DISPLAY (PLANEMAKER HIDE/SHOW)
    if A333DR_rtp_L_off_status == 0 then
        if A333DR_rtp_L_vhf_1_status == 1 then
            A333DR_rtp_L_lcd_to_display = 0
        elseif A333DR_rtp_L_vhf_2_status == 1 then
            A333DR_rtp_L_lcd_to_display = 1
        else
            A333DR_rtp_L_lcd_to_display = 99
        end
    end


    if A333DR_rtp_R_off_status == 0 then
        if A333DR_rtp_R_vhf_1_status == 1 then
            A333DR_rtp_R_lcd_to_display = 0
        elseif A333DR_rtp_R_vhf_2_status == 1 then
            A333DR_rtp_R_lcd_to_display = 1
        else
            A333DR_rtp_R_lcd_to_display = 99
        end
    end

    if A333DR_rtp_C_off_status == 0 then
        if A333DR_rtp_C_vhf_1_status == 1 then
            A333DR_rtp_C_lcd_to_display = 0
        elseif A333DR_rtp_C_vhf_2_status == 1 then
            A333DR_rtp_C_lcd_to_display = 1
        else
            A333DR_rtp_C_lcd_to_display = 99
        end
    end


end




----- RADIO PANEL RADIO SELECTOR SWAP ---------------------------------------------------
function A333_radio_sel_swap(radio, vhf_1, vhf_2, vhf_3, hf_1, am, hf_2)

    -- SET SELECTED RADIO STATUS
    if radio == 0 then
        A333DR_rtp_L_vhf_1_status   = vhf_1
        A333DR_rtp_L_vhf_2_status   = vhf_2
        A333DR_rtp_L_vhf_3_status   = vhf_3
        A333DR_rtp_L_hf_1_status    = hf_1
        A333DR_rtp_L_am_status      = am
        A333DR_rtp_L_hf_2_status    = hf_2

    elseif radio == 1 then
        A333DR_rtp_R_vhf_1_status   = vhf_1
        A333DR_rtp_R_vhf_2_status   = vhf_2
        A333DR_rtp_R_vhf_3_status   = vhf_3
        A333DR_rtp_R_hf_1_status    = hf_1
        A333DR_rtp_R_am_status      = am
        A333DR_rtp_R_hf_2_status    = hf_2

     elseif radio == 2 then
        A333DR_rtp_C_vhf_1_status   = vhf_1
        A333DR_rtp_C_vhf_2_status   = vhf_2
        A333DR_rtp_C_vhf_3_status   = vhf_3
        A333DR_rtp_C_hf_1_status    = hf_1
        A333DR_rtp_C_am_status      = am
        A333DR_rtp_C_hf_2_status    = hf_2


    end


    -- SET OFFSIDE TUNING STATUS
    A333DR_rtp_L_offside_tuning_status = 0
    A333DR_rtp_R_offside_tuning_status = 0
	A333DR_rtp_C_offside_tuning_status = 0


    --  LEFT RADIO
    if (A333DR_rtp_L_vhf_1_status == 0)
        or A333DR_rtp_C_vhf_1_status == 1
        or A333DR_rtp_R_vhf_1_status == 1
    then
        A333DR_rtp_L_offside_tuning_status = 1
    end

    --  CENTER RADIO
    if (A333DR_rtp_C_vhf_3_status == 0 and A333DR_rtp_C_hf_1_status == 0)
        or A333DR_rtp_L_vhf_3_status == 1
        or A333DR_rtp_R_vhf_3_status == 1
        or A333DR_rtp_L_hf_1_status == 1
        or A333DR_rtp_R_hf_1_status == 1
    then
        A333DR_rtp_C_offside_tuning_status = 1
    end

    --  RIGHT RADIO
    if (A333DR_rtp_R_vhf_2_status == 0)
        or A333DR_rtp_C_vhf_2_status == 1
        or A333DR_rtp_L_vhf_2_status == 1
    then
        A333DR_rtp_R_offside_tuning_status = 1
    end

    -- UPDATE LCD DISPLAY STATUS
    A333_lcd_display_status()

end








----- AIRCRAFT LOAD ---------------------------------------------------------------------


----- MONITOR AI FOR AUTO-BOARD CALL ----------------------------------------------------
function A333_comms_monitor_AI()

    if A333DR_init_comms_CD == 1 then
        A333_set_comms_all_modes()
        A333_set_comms_CD()
        A333DR_init_comms_CD = 2
    end

end


----- SET STATE FOR ALL MODES -----------------------------------------------------------
function A333_set_comms_all_modes()

	A333DR_init_comms_CD = 0

	A333CMD_rtp_L_vhf_1_sel_switch:once()
    A333CMD_rtp_R_vhf_2_sel_switch:once()
    A333CMD_rtp_C_vhf_3_sel_switch:once()




end


----- SET STATE TO COLD & DARK ----------------------------------------------------------
function A333_set_comms_CD()


end


----- SET STATE TO ENGINES RUNNING ------------------------------------------------------

function A333_set_comms_ER()


end


----- FLIGHT START ---------------------------------------------------------------------

function A333_flight_start_comms()

    -- ALL MODES ------------------------------------------------------------------------
    A333_set_comms_all_modes()


    -- COLD & DARK ----------------------------------------------------------------------
    if simDR_startup_running == 0 then

        A333_set_comms_CD()


    -- ENGINES RUNNING ------------------------------------------------------------------
    elseif simDR_startup_running == 1 then

		A333_set_comms_ER()

    end

end




--*************************************************************************************--
--** 				                  EVENT CALLBACKS           	    			 **--
--*************************************************************************************--

function aircraft_load()

    A333_flight_start_comms()

end

--function aircraft_unload() end

--function flight_start() end

--function flight_crash() end

--function before_physics() end

function after_physics()

	A333_comms_monitor_AI()

end

function after_replay()

	A333_comms_monitor_AI()

end



