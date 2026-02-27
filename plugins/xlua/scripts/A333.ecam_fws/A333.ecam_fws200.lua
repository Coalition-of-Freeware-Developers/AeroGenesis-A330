--[[
*****************************************************************************************
* Script Name :  A333.ecam_fws200.lua
* Process: FWS 	 Global Variable Assignment
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


--print("LOAD: A333.ecam_fws200.lua")

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
local function A333_fws_global_variable_assignment()

    fws_power = ((A333DR_ac_bus2_volts > A333DR_ac_min_volts) or (A333DR_ac_ess_bus_volts > A333DR_ac_min_volts)) and 1 or 0

    AP1CF           = A333DR_pack1_fault == 1
    AP1F            = AP1CF
    AP1FCVFC        = simDR_bleedair_pack1 == 0
    AP1PBOF		    = A333_switches_pack1_pos == 0
    AP2CF           = A333DR_pack2_fault == 1
    AP2F            = AP2CF
    AP2FCVFC        = simDR_bleedair_pack2 == 0
    AP2PBOF		    = A333_switches_pack2_pos == 0
    ARAPBON         = A333_switches_ram_air_pos == 1

    BAPUBPBOF_1     = A333_switches_apu_bleed_pos == 0.0
    BAPUBPBOF_2     = BAPUBPBOF_1
    BAPUBVFC_1      = A333_annun_apu_bleed_on == 0.0
    BAPUBVFC_2      = BAPUBVFC_1
    BE1BPBOF_1      = A333_eng1_bleed_button_pos == 0.0
    BE1BPBOF_2      = BE1BPBOF_1
    BE1LOTEMP_1     = A333_precooler1_temp < 150.0
    BE1LOTEMP_2     = BE1LOTEMP_1
    BE2BPBOF_1      = A333_eng2_bleed_button_pos == 0.0
    BE2BPBOF_2      = BE2BPBOF_1
    BE2LOTEMP_1     = A333_precooler2_temp < 150.0
    BE2LOTEMP_2     = BE2LOTEMP_1
    BXFVFC_1	    = A333_isol_valve_right_pos == 0.0
    BXFVFC_2	    = BXFVFC_1
    BXFVFO_1        = A333_isol_valve_right_pos == 2.0
    BXFVFO_2        = BXFVFO_1

    CAOCMSG         = simDR_company_msg > 0

    CFSBLT          = simDR_switch_seat_belt == 1
    CNOSMOK         = simDR_switch_no_smoking == 1

    DLFCDNC         = simDR_door_open_ratio[0] > 0.0
    DRFCDNC         = simDR_door_open_ratio[1] > 0.0
    DLMCDNC         = simDR_door_open_ratio[2] > 0.0
    DRMCDNC         = simDR_door_open_ratio[3] > 0.0
    DLEEDNC         = simDR_door_open_ratio[4] > 0.0
    DREEDNC         = simDR_door_open_ratio[5] > 0.0
    DLACDNC         = simDR_door_open_ratio[6] > 0.0
    DRACDNC         = simDR_door_open_ratio[7] > 0.0

    EADCGNL         = A333DR_tr1_volts <= 0 and A333DR_tr2_volts <= 0
    EAPUGNF         = simDR_apu_fail == 6
    EAPUGNPBOF      = A333_buttons_gen_apu_pos == 0
    EBA1PBON        = simDR_battery_on[0] == 1
    EBA2PBON        = simDR_battery_on[1] == 1
    EBAT1F          = simDR_fail_battery1 == 6
    EBAT2F          = simDR_fail_battery2 == 6
    EBTIEPBOF       = A333_buttons_bus_tie_pos == 0.0
    EEPWRCON        = A333DR_extA_line_contactor == 1
    EGN1COF         = A333DR_gen1_line_contactor == 0
    EGN2COF         = A333DR_gen2_line_contactor == 0
    EGN1PBOF        = A333_buttons_gen1_pos == 0
    EGN2PBOF        = A333_buttons_gen2_pos == 0
    EIDG1D          = A333_IDG1_status == 0
    EIDG2D          = A333_IDG2_status == 0
    ENG3INOP        = simDR_apu_fail == 6

    FCTP1COF        = A333_ECAM_fuel_center_xfer_any == 0
    FCTP2COF        = A333_ECAM_fuel_center_xfer_any == 0
    FLTP1LP         = simDR_tank_pump_psi[0] < 0.0
    FLTP12F         = A333_left_pump1_pos == 1 and A333_left_pump1_pos == 1.0 and simDR_tank_pump_psi[0] < 1.0
    FLTP1COF        = A333_left_pump1_pos == 0.0
    FLTP2COF        = A333_left_pump2_pos == 0.0
    FLTP2LP         = simDR_tank_pump_psi[0] < 0.0
    FLWTLLA         = simDR_fuel_left_wing < 1100.0
    FLWTLLB         = FLWTLLA
    FRTP1COF        = A333_right_pump1_pos == 0.0
    FRTP12F         = A333_right_pump1_pos == 1 and A333_right_pump2_pos == 1.0 and simDR_tank_pump_psi[1] < 1.0
    FRTP2COF        = A333_right_pump2_pos == 0.0
    FRWTLLA         = simDR_fuel_right_wing < 1100.0
    FRWTLLB         = FRWTLLA
    FXFVFC          = A333_fuel_crossfeed_valve_pos == 0.0
    FXFVPBON	    = A333DR_fuel_wing_crossfeed_pos == 1.0

    local lcl_gear_handle_animation = simDR_gear_handle_animation
    local lcl_gear_deploy_ratio = {}
    local lcl_tire_deflection_mtr = {}
    local lcl_gear_on_ground = {}
    for gear=0,2 do
        lcl_gear_deploy_ratio  [gear] = simDR_gear_deploy_ratio  [gear]
        lcl_tire_deflection_mtr[gear] = simDR_tire_deflection_mtr[gear]
        lcl_gear_on_ground     [gear] = simDR_gear_on_ground     [gear]
    end

    GBFANCON_1      = simDR_brake_fan == 1
    GBFANCON_2      = GBFANCON_1
    GBRK1OVHT       = A333_wheel_brake_temp1 > 300.0
    GBRK2OVHT       = A333_wheel_brake_temp2 > 300.0
    GBRK3OVHT       = A333_wheel_brake_temp3 > 300.0
    GBRK4OVHT       = A333_wheel_brake_temp4 > 300.0
    GBRK5OVHT       = A333_wheel_brake_temp5 > 300.0
    GBRK6OVHT       = A333_wheel_brake_temp6 > 300.0
    GBRK7OVHT       = A333_wheel_brake_temp7 > 300.0
    GBRK8OVHT       = A333_wheel_brake_temp8 > 300.0
    GDLORA_1        = simDR_auto_brake == 3
    GDLORA_2        = GDLORA_1
    GDMDRA_1        = simDR_auto_brake == 4
    GDMDRA_2        = GDMDRA_1
    GDMXRA_1        = simDR_auto_brake == 0 or simDR_auto_brake == 5
    GDMXRA_2        = GDMXRA_1
    GELLGCOMPR		= lcl_tire_deflection_mtr[1] > 0.15
    GGLSD_1         = lcl_gear_handle_animation == 1.0
    GGLSD_2         = GGLSD_1
    GGLSUP_1        = lcl_gear_handle_animation == 0.0
    GGLSUP_2        = GGLSUP_1
    GLDNUPL_1       = lcl_gear_deploy_ratio[1] > 0.1 and lcl_gear_deploy_ratio[1] < 0.9
    GLDNUPL_2       = GLDNUPL_1
    GLGNLUPNSD_1    = lcl_gear_deploy_ratio[1] > 0.0 and lcl_gear_handle_animation < 1.0
    GLGNLUPNSD_2    = GLGNLUPNSD_1
    GLLGC_1			= lcl_gear_on_ground[1] == 1
    GLLGC_2			= GLLGC_1
    GLLGC_1_INV		= false
    GLLGC_2_INV		= false
    GLLGC_1_NCD		= lcl_gear_on_ground[1] < 0 or lcl_gear_on_ground[1] > 1
    GLLGC_2_NCD		= GLLGC_1_NCD
    GLGDL_1			= lcl_gear_deploy_ratio[1] > 0.98 -- L/G DOWNLOCKED
    GLGDL_2			= GLGDL_1
    GLGNLDSD_1      = lcl_gear_deploy_ratio[1] < 1.0 and lcl_gear_handle_animation > 0.95
    GLGNLDSD_2      = GLGNLDSD_1
    GLGNLUP_1       = lcl_gear_deploy_ratio[1] > 0.0
    GLGNLUP_2       = GLGNLUP_1
    GLGNOE_1        = lcl_tire_deflection_mtr[1] > 0.0
    GLGNOE_2        = GLGNOE_1
    GLGUWGD_1       = lcl_gear_deploy_ratio[1] < 0.001 and GLGDL_1
    GLGUWGD_2       = lcl_gear_deploy_ratio[1] < 0.001 and GLGDL_2
    GLLGNOLK        = lcl_gear_deploy_ratio[1] > 0.0 and lcl_gear_deploy_ratio[1] < 1.0
    GMLGC_1         = lcl_tire_deflection_mtr[1] > 0.15 and lcl_tire_deflection_mtr[2] > 0.15
    GMLGC_2         = GMLGC_1
    GNDNUPL_1       = lcl_gear_deploy_ratio[0] > 0.1 and lcl_gear_deploy_ratio[1] < 0.9
    GNDNUPL_2       = GNDNUPL_1
    GNGDL_1			= lcl_gear_deploy_ratio[0] > 0.98
    GNGDL_2			= GNGDL_1
    GNGNLDSD_1      = lcl_gear_deploy_ratio[0] < 1.0 and lcl_gear_handle_animation > 0.95
    GNGNLDSD_2      = GNGNLDSD_1
    GNGNLUP_1       = lcl_gear_deploy_ratio[0] > 0.0
    GNGNLUP_2       = GNGNLUP_1
    GNGNLUPNSD_1    = lcl_gear_deploy_ratio[0] > 0.0 and lcl_gear_handle_animation < 1.0
    GNGNLUPNSD_2    = GNGNLUPNSD_1
    GNGNOE_1        = lcl_tire_deflection_mtr[0] > 0.0
    GNGNOE_2        = GNGNOE_1
    GNGUWGD_1       = lcl_gear_deploy_ratio[0] < 0.001 and GNGDL_1
    GNGUWGD_2       = lcl_gear_deploy_ratio[0] < 0.001 and GNGDL_2
    GNLGNOLK        = lcl_gear_deploy_ratio[0] > 0.0 and lcl_gear_deploy_ratio[0] < 1.0
    GNLLGCOMPR		= lcl_tire_deflection_mtr[1] > 0.15
    GPBRKON         = simDR_park_brake_valve > 0.99
    GRGDL_1			= lcl_gear_deploy_ratio[2] > 0.98
    GRGDL_2			= GRGDL_1
    GRDNUPL_1       = lcl_gear_deploy_ratio[2] > 0.1 and lcl_gear_deploy_ratio[1] < 0.9
    GRDNUPL_2       = GRDNUPL_1
    GRETIN_1		= simDR_gear_retract_fail_1 == 6 or simDR_gear_retract_fail_2 == 6 or simDR_gear_retract_fail_3 == 6
    GRETIN_2		= GRETIN_1
    GRGNLDSD_1      = lcl_gear_deploy_ratio[2] < 1.0 and lcl_gear_handle_animation > 0.95
    GRGNLDSD_2      = GRGNLDSD_1
    GRGNLUP_1       = lcl_gear_deploy_ratio[2] > 0.0
    GRGNLUP_2       = GRGNLUP_1
    GRGNLUPNSD_1    = lcl_gear_deploy_ratio[2] > 0.0 and lcl_gear_handle_animation < 1.0
    GRGNLUPNSD_2    = GRGNLUPNSD_1
    GRGNOE_1        = lcl_tire_deflection_mtr[2] > 0.0
    GRGNOE_2        = GRGNOE_1
    GRGUWGD_1       = lcl_gear_deploy_ratio[2] < 0.001 and GRGDL_1
    GRGUWGD_2       = lcl_gear_deploy_ratio[2] < 0.001 and GRGDL_2
    GRLGC_1		    = lcl_gear_on_ground[2] == 1
    GRLGC_2		    = GRLGC_1
    GRLGNOLK        = lcl_gear_deploy_ratio[2] > 0.0 and lcl_gear_deploy_ratio[2] < 1.0
    GW1SGT_1        = ((simDR_tire_rot_speed_rad_sec[1] * simDR_tire_radius[1]) * 1.94384) > 72.0
    GW1SGT_2        = GW1SGT_1

    local lcl_blue_hydraulic_pressure  = simDR_blue_hydraulic_pressure
    local lcl_green_hydraulic_pressure = simDR_green_hydraulic_pressure
    local lcl_yellow_hydraulic_pressure = simDR_yellow_hydraulic_pressure

    HBEPLP          = lcl_blue_hydraulic_pressure <= 1450.0
    HBEPOF          = simDR_elec_hydraulic_blue_on == 0.0
    HBEPPBOF        = A333_elec_pump_blue_tog_pos == 0.0
    HBRLL           = HBRQ < 5.0
    HBRQ            = BLUE_MAX_LITERS * simDR_blue_fluid_ratio
    HBRQLO          = HBRQ < 5.0
    HBSLP           = lcl_blue_hydraulic_pressure < 1450.0
    HGPLP           = lcl_green_hydraulic_pressure <= 1450.0
    HGPPBOF         = A333_engine1_pump_green_pos == 0.0
    HGRLL           = HGRQ < 8.0
    HGRQ            = GREEN_MAX_LITERS * simDR_green_fluid_ratio
    HGRQLO          = HGRQ < 8.0
    HGSLP           = lcl_green_hydraulic_pressure < 1450.0
    HNVMYEPF        = A333_hyd_elec_yellow_pump_fault == 1
    HNVMBEPF        = A333_hyd_elec_blue_pump_fault == 1
    HNVMGEPF        = A333_hyd_elec_green_pump_fault == 1
    HNVMBPF         = A333_hyd_eng1_blue_pump_fault == 1
    HNVMG1PF        = A333_hyd_eng1_green_pump_fault == 1
    HNVMG2PF        = A333_hyd_eng2_green_pump_fault == 1
    HNVMYPF         = A333_hyd_eng2_yellow_pump_fault == 1
    HPRATPBOF       = A333_rat_man_on_button_pos == 0                  -- A330 Custom
    HRATNFS         = simDR_rat_on > 0
    HYEPPBON        = A333_elec_pump_yellow_tog_pos == 1.0
    HYEPON          = simDR_elec_hydraulic_yellow_on == 1.0
    HYPLP           = lcl_yellow_hydraulic_pressure <= 1450.0
    HYPPBOF         = A333_engine2_pump_yellow_pos == 0.0
    HYRLL           = HYRQ < 5.0
    HYRQ            = YELLOW_MAX_LITERS * simDR_yellow_fluid_ratio
    HYRQLO          = HYRQ < 5.0
    HYSLP           = lcl_yellow_hydraulic_pressure < 1450.0

    IE1AIPBON       = A333_engine_anti_ice1 == 1
    IE1AIVF         = simDR_engine1_anti_ice_fail == 6
    IE1ID           = simDR_engine1_heat > 0.0
    IE2AIPBON       = A333_engine_anti_ice2 == 1
    IE2AIVF         = simDR_engine2_anti_ice_fail == 6
    IE2ID           = simDR_engine1_heat > 0.0
    ILWAILP         = A333_precooler1_psi < 0.25
    ILWAIVC         = A333_wing_heat_valve_pos_left < 0.01
    IRWAILP         = A333_precooler2_psi < 0.25
    IRWAIVC         = A333_wing_heat_valve_pos_right < 0.01
    IWAION		    = simDR_wing_heat_left == 1 and simDR_wing_heat_right == 1
    IWAIPBON        = A333_buttons_wing_anti_ice_ctct_on_off == 1.0

    JML1OFF         = A333_switches_engine1_start_pos == 0.0 and A333_switches_engine1_start_lift == 0.0
    JML1ON			= A333_switches_engine1_start_pos == 1.0 and A333_switches_engine1_start_lift == 0.0
    JML2OFF         = A333_switches_engine2_start_pos == 0.0 and A333_switches_engine2_start_lift == 0.0
    JML2ON			= A333_switches_engine2_start_pos == 1.0 and A333_switches_engine2_start_lift == 0.0

    local lcl_engine_n1_pct = {}
    local lcl_throttle_beta_rev_ratio = {}
    local lcl_engine_throttle_used_ratio = {}
    local lcl_engine_reverse_deploy_ratio = {}
    for engine=0,1 do
        lcl_engine_n1_pct              [engine] = simDR_engine_n1_pct              [engine]
        lcl_throttle_beta_rev_ratio    [engine] = simDR_throttle_beta_rev_ratio    [engine]
        lcl_engine_reverse_deploy_ratio[engine] = simDR_engine_reverse_deploy_ratio[engine]
        lcl_engine_throttle_used_ratio [engine] = simDR_engine_throttle_used_ratio [engine]
    end

    JR1AIDLE_1A		= lcl_engine_n1_pct[0] >= 19.0
    JR1AIDLE_1B		= JR1AIDLE_1A
    JR1AUTOST_1A    = Engine1StartSequenceInProgress()
    JR1AUTOST_1B    = Engine2StartSequenceInProgress()
    JR1CMDREV_1A    = lcl_throttle_beta_rev_ratio[0] <= -1.0
    JR1CMDREV_1B    = lcl_throttle_beta_rev_ratio[0] <= -1.0
    JR1CONTIGN_1A   = simDR_igniter_on[0] == 1.0
    JR1CONTIGN_1B   = JR1CONTIGN_1A
    JR1ESI          = simDR_engine1_igniter[0] == 1
    JR1HGST_1A      = simDR_eng1_hung_start == 6
    JR1HGST_1B      = JR1HGST_1A
    JR1IDLE_1A      = lcl_engine_throttle_used_ratio[0] == 0.0
    JR1IDLE_1B      = JR1IDLE_1A
    JR1IFT          = simDR_fail_rel_ignitr0 == 6
    JRIGNSEL        = simDR_starter_mode == 1
    JR1MINPWR_1A    = lcl_engine_n1_pct[0] > 19.0 and lcl_engine_n1_pct[0] < 22.0
    JR1MINPWR_1B    = JR1MINPWR_1A
    JR1N1_1A		= lcl_engine_n1_pct[0]
    JR1N1_1B		= JR1N1_1A
    JR1OOT_1        = 190.0
    JR1OOT_2        = 190.0
    JR1OLP          = simDR_engine_oil_pressure_psi[0] < 25.0
    JR1OT           = simDR_engine_oil_temp_degC[0]
    JR1OTAD_1       = 170.0
    JR1OTAD_2       = 170.0
    JR1REVD_1A      = lcl_engine_reverse_deploy_ratio[0] > 0.90
    JR1REVD_1B      = JR1REVD_1A
    JR1REVKO        = simDR_engine1_reverse_fail == 6
    JR1REVUNL_1A    = lcl_engine_reverse_deploy_ratio[0] > 0.05
    JR1REVUNL_1B    = JR1REVUNL_1A
    JR1TLA_1A		= simDR_throttle_ratio[0]
    JR1TLA_1B		= JR1TLA_1A

    JR2AIDLE_2A		= lcl_engine_n1_pct[1] >= 19.0
    JR2AIDLE_2B		= JR2AIDLE_2A
    JR2CMDREV_2A    = lcl_throttle_beta_rev_ratio[1] <= -1.0
    JR2CMDREV_2B    = lcl_throttle_beta_rev_ratio[1] <= -1.0
    JR2CONTIGN_2A   = simDR_igniter_on[1] == 1.0
    JR2CONTIGN_2B   = JR2CONTIGN_2A
    JR2ESI          = simDR_engine1_igniter[1] == 1
    JR2IFT          = simDR_fail_rel_ignitr1 == 6
    JR2HGST_2A      = simDR_eng2_hung_start == 6
    JR2HGST_2B      = JR2HGST_2A
    JR2IDLE_2A      = lcl_engine_throttle_used_ratio[1] == 0.0
    JR2IDLE_2B      = JR2IDLE_2A
    JR2MINPWR_2A    = lcl_engine_n1_pct[1] > 19.0 and lcl_engine_n1_pct[1] < 22.0
    JR2MINPWR_2B    = JR2MINPWR_2A
    JR2N1_2A		= lcl_engine_n1_pct[1]
    JR2N1_2B		= JR2N1_2A
    JR2OOT_1        = 190.0
    JR2OOT_2        = 190.0
    JR2OLP          = simDR_engine_oil_pressure_psi[1] < 25.0
    JR2OT           = simDR_engine_oil_temp_degC[1]
    JR2OTAD_1       = 170.0
    JR2OTAD_2       = 170.0
    JR2REVD_2A      = lcl_engine_reverse_deploy_ratio[1] > 0.9
    JR2REVD_2B      = JR2REVD_2A
    JR2REVKO        = simDR_engine2_reverse_fail == 6
    JR2REVUNL_2A    = lcl_engine_reverse_deploy_ratio[1] > 0.05
    JR2REVUNL_2B    = JR2REVUNL_2A
    JR2TLA_2A		= simDR_throttle_ratio[1]
    JR2TLA_2B		= JR2TLA_2A

    KAP1EC_1        = simDR_ap_servos_on == 1
    KAP1EM_1        = simDR_ap_servos_on == 1
    KAP2EC_2        = simDR_ap_servos2_on == 1
    KAP2EM_2        = simDR_ap_servos2_on == 1
    KATHRE			= simDR_ap_autothrottle_on == 1
    KCCE            = A333DR_fws_aural_alert_ccc == 1
    KID1APE         = A333_capt_priority_pos == 1
    KID2APE         = A333_fo_priority_pos == 1
    KLONRJ_1        = simDR_airbus_speed_warn_thro_0 == 1
    KLONRJ_2        = simDR_airbus_speed_warn_thro_1 == 1
    KLTRKM_1		= simDR_ap_approach_status == 2
    KLTRKM_2		= KLTRKM_1
    KRTP_1          = simDR_rudder_trim_ratio * 25.0
    KRTP_2          = KRTP_1
    KSPEEDGEN       = A333DR_fws_aco_speed_playing == 1
    KWINDSD_1       = simDR_windshear_warning == 1
    KWINDSD_2       = KWINDSD_1
    KWINDSGEN       = A333DR_fws_aco_windshear_playing == 1

    LSLPBOF         = A333_strobe_switch_pos == 0

    local lcl_CONF_sel = simDR_CONF_sel
    local lcl_baro_alt_ft_pilot = simDR_baro_alt_ft_pilot
    local lcl_baro_alt_ft_copilot = simDR_baro_alt_ft_copilot

    NALTFBK_1       = lcl_baro_alt_ft_pilot
    NALTFBK_2       = lcl_baro_alt_ft_copilot
    NALTI_1			= lcl_baro_alt_ft_pilot
    NALTI_2			= lcl_baro_alt_ft_copilot
    NALTI_3			= simDR_baro_alt_ft_stby

    NATCALTROF      = A333DR_transponder_alt_rpt_pos == 0
    NATC1F          = A333DR_transponder_failure_flag == 1
    NATC2F          = A333DR_transponder_failure_flag == 2
    NATCSTBY        = A333DR_transponder_auto_on_off_pos == -1

    local baro_setting_std_pilot = simDR_barometer_setting_is_std_pilot
    NBRQ20_1        = baro_setting_std_pilot == 1    -- STD
    NBRQ21_1        = baro_setting_std_pilot == 0    -- QNH

    local baro_setting_std_copilot = simDR_barometer_setting_is_std_copilot
    NBRQ20_2        = baro_setting_std_copilot == 1    -- STD
    NBRQ21_2        = baro_setting_std_copilot == 0    -- QNH

    NCAS_1			= simDR_cas_kts_pilot
    NCAS_1_INV		= simDR_airspeed_fail_pilot == 6
    NCAS_1_NCD		= NCAS_1 > 1024.0
    NCAS_2			= simDR_cas_kts_copilot
    NCAS_2_INV		= simDR_airspeed_fail_copilot == 6
    NCAS_2_NCD		= NCAS_2 > 1024.0
    NCAS_3			= simDR_cas_kts_stby
    NCAS_3_INV		= false
    NCAS_3_NCD		= NCAS_3 > 1024.0
    NCBAC_1         = lcl_baro_alt_ft_pilot
    NFOBAC_2        = lcl_baro_alt_ft_copilot
	NFFMSLDG3       = simDR_fms_landing_flap_config == 3
   -- NFPBLDG3        = simDR_flap_handle_ratio == 0.75 and A333_gpws_flap_status == 1
    NGPWSFMOF       = A333_gpws_flap_tog_pos < 0.01
    NGPWSM          = false -- TODO: a GPWS aural alert 1 thru 5 is playing
    NGSVA           = simDR_gs_annun == 1
    NHUNABGEN		= A333DR_fws_aco_hundred_above_playing == 1

    local adirs_align_status = A333DR_adirs_ir_align_status
    NIRSALG_1       = adirs_align_status[0] == 5 or adirs_align_status[0] == 6
    NIRSALG_2       = adirs_align_status[1] == 5 or adirs_align_status[1] == 6
    NIRS1AL         = adirs_align_status[0] == 99
    NIRS2AL         = adirs_align_status[1] == 99
    NIRS3AL         = adirs_align_status[2] == 99

    NMINGEN         = A333DR_fws_aco_minimum_playing == 1
    NRADH_1			= simDR_radio_alt_ht_pilot
    NRADH_2			= simDR_radio_alt_ht_copilot
    NRADH_1_INV		= simDR_radio_alt_pilot_fail == 6
    NRADH_2_INV		= simDR_radio_alt_copilot_fail == 6
    NRADH_1_NCD		= simDR_radio_alt_ht_pilot > 8192.0
    NRADH_2_NCD		= simDR_radio_alt_ht_copilot > 8192.0
    NSFCONF3NS      = lcl_CONF_sel ~= 6
    NSTALL1         = simDR_stall_warning == 1
    NTCASINIB       = A333_audio_tcas_alert == 1
    NTCASSTBY       = A333DR_transponder_ta_ra_pos == 0
    NVMOW_1         = (simDR_airspeed_kts_pilot > 330.0) or (simDR_airspeed_kts_copilot > 330.0) or (simDR_airspeed_kts_stby > 330.0)

    PALTI           = simDR_pressure_altitude
    PAS12F          = A333DR_pack1_fault == 1 and A333DR_pack2_fault == 1
    PS1F_1          = simDR_hvac_fail == 6
    PS2F_2          = PS1F_1

    QAVAIL          = A333DR_annun_apu_avail == 1.0
    QMSON           = simDR_APU_switch_mode > 0

    SCSSF_1         = simDR_priority_side == 2
    SCSSF_2         = SCSSF_1
    SFLPFY          = SFLPINOP or SFLPLCKD
    SFLPINOP        = simDR_flap_act_failure == 6
    SFLPLCKD        = simDR_flap_1_lft_lock == 6 or simDR_flap_1_rgt_lock == 6 or simDR_flap_2_lft_lock == 6 or simDR_flap_2_rgt_lock == 6
    SFOSSF_1        = simDR_priority_side == 1
    SFOSSF_2        = SFOSSF_1
    SGNDSPLRA_1     = simDR_ctrl_speed_brk_ratio == -0.5
    SGNDSPLRA_2     = SGNDSPLRA_1
    SLELVBA_1       = lcl_blue_hydraulic_pressure >= 200
    SLELVBA_2       = SLELVBA_1
    SLELVGA_1       = lcl_green_hydraulic_pressure >= 200
    SLELVGA_2       = SLELVGA_1
    SPCCMD_1        = simDR_yoke_pitch_ratio_pilot
    SPCCMD_2        = SPCCMD_1
    SPFOCMD_1       = simDR_yoke_pitch_ratio_copilot
    SPFOCMD_2       = SPFOCMD_1
    SRCCMD_1        = simDR_yoke_roll_ratio_pilot
    SRCCMD_2        = SRCCMD_1
    SRFOCMD_1       = simDR_yoke_roll_ratio_copilot
    SRFOCMD_2       = SRFOCMD_1
    SRELVBA_1       = lcl_blue_hydraulic_pressure >= 200
    SRELVBA_2       = SRELVBA_1
    SRELVYA_1       = lcl_yellow_hydraulic_pressure >= 200
    SRELVYA_2       = SRELVYA_1
    --SRFLPPOS		= simDR_flap_deg[1]
    --SRSLTPOS      = math.round95(simDR_slat2_deploy_rat * 23.0)

    SS00F00_1       = lcl_CONF_sel == 0
    SS00F00_2       = lcl_CONF_sel == 0
    SS16F00_1       = lcl_CONF_sel == 1
    SS16F00_2       = lcl_CONF_sel == 1
    SS16F08_1       = lcl_CONF_sel == 2
    SS16F08_2       = lcl_CONF_sel == 2
    SS20F14_1       = lcl_CONF_sel == 4
    SS20F14_2       = lcl_CONF_sel == 4
    SS23F22_1       = lcl_CONF_sel == 6
    SS23F22_2       = lcl_CONF_sel == 6
    SS23F32_1       = lcl_CONF_sel == 7
    SS23F32_2       = lcl_CONF_sel == 7

    SSPBR_1         = simDR_ctrl_speed_brk_ratio > 0.0
    SSPBR_2         = SSPBR_1
    STAB1POS_1      = simDR_stab_deflection_deg
    STAB1POS_2      = simDR_stab_deflection_deg

    UAPUELP         = A333_apu_agent_psi < 300.0
    UAPUFA			= simDR_apu_fire == 6
    UAPUFB			= UAPUFA
    UAPUFPBOUT		= A333_apu_fire_handle_pos > 0.99
    UE1ABLP         = A333_eng1_agent2_psi < 300.0
    UE1FA           = simDR_engine_fire[0] == 1
    UE1FB           = UE1FA
    UE1FBLP         = A333_eng1_agent1_psi < 300.0
    UE1FIRE         = false
    UE1FPBOUT		= A333_eng1_fire_handle_pos > 0.99

    UE2ABLP         = A333_eng2_agent2_psi < 300.0
    UE2FA           = simDR_engine_fire[1] == 1
    UE2FB           = UE2FA
    UE2FBLP         = A333_eng2_agent1_psi < 300.0
    UE2FIRE         = false
    UE2FPBOUT		= A333_eng2_fire_handle_pos > 0.99

    VAVEPBO         = A333_ventilation_extract_ovrd_pos >= 1.0

    WALL_2			= A333_ecam_button_all_pos == 1
    WAPU_2			= A333_ecam_button_apu_pos == 1
    WBLD_2			= A333_ecam_button_bleed_pos == 1
    WCB_2		    = A333_ecam_button_cbs_pos == 1
    WCLR1_2			= A333_ecam_button_clr_capt_pos == 1
    WCLR2_2			= A333_ecam_button_clr_fo_pos == 1
    WCOND_2			= A333_ecam_button_cond_pos == 1
    WDH_1           = simDR_radio_altimeter_bug_ft_pilot
    WDH_1_NCD       = simDR_radio_altimeter_bug_ft_pilot == -1000.0 and simDR_baro_alt_bug_ft_pilot <= 0
    WDH_1_VAL   	= simDR_radio_altimeter_bug_ft_pilot > -1000.0 or simDR_baro_alt_bug_ft_pilot > 0
    WDH100A         = NRHV >= WDH_1 + 100.0
    WDH100B         = NRHV >= WDH_2 + 100.0
    WDH_2           = WDH_1
    WDH_2_NCD       = simDR_radio_altimeter_bug_ft_copilot == -1000.0 and simDR_baro_alt_bug_ft_copilot <= 0
    WDH_2_VAL   	= simDR_radio_altimeter_bug_ft_copilot > -1000.0 or simDR_baro_alt_bug_ft_copilot > 0
    WDH100A         = NRHV >= (WDH_1 + 100.0) and NRHV <= (WDH_1 + 103.0)
    WDH100B         = NRHV >= (WDH_2 + 100.0) and NRHV <= (WDH_2 + 103.0)
    WDHA            = NRHV >= WDH_1
    WDHB            = NRHV >= WDH_2
    WDOOR_2			= A333_ecam_button_door_pos == 1
    WEC_2           = A333_ecam_button_emer_cancel_pos == 1
    WELAC_2			= A333_ecam_button_el_ac_pos == 1
    WELDC_2			= A333_ecam_button_el_dc_pos == 1
    WENG_2			= A333_ecam_button_eng_pos == 1
    WFCTL_2			= A333_ecam_button_f_ctl_pos == 1
    WFUEL_2			= A333_ecam_button_fuel_pos == 1
    WHYD_2			= A333_ecam_button_hyd_pos == 1
    WPRESS_2		= A333_ecam_button_press_pos == 1
    WRCL_2			= A333_ecam_button_rcl_pos == 1
    WSTS_2			= A333_ecam_button_sts_pos == 1
    WTOCT_2         = A333_ecam_button_to_config_pos == 1
    WWHL_2			= A333_ecam_button_wheel_pos == 1

    ZNSTSMSGD       = A333DR_fws_sts_normal_msg_show == 1

end




local function A333_fws_global_to_dataref()

    A333_hyd_green_rsvr_lo_lvl = bool2num[HGRLL]
    A333_hyd_yellow_rsvr_lo_lvl = bool2num[HYRLL]
    A333_hyd_blue_rsvr_lo_lvl = bool2num[HBRLL]

    A333DR_fws_main_gear_comp_L = bool2num[GMLGC_1]
    A333DR_fws_main_gear_comp_R = bool2num[GMLGC_2]

end




--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--
function A333_fws_200()

    A333_fws_global_variable_assignment()
    A333_fws_global_to_dataref()

end



--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







