jit.off()
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
*       					     COPYRIGHT © 2021, 2022
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

function A333_fws_global_variable_assignment()

    AP1CF           = A333DR_pack1_fault == 1
    AP1F            = A333DR_pack1_fault == 1
    AP1FCVFC        = simDR_bleedair_pack1 == 0
    AP1PBOF		    = A333_switches_pack1_pos == 0
    AP2CF           = A333DR_pack2_fault == 1
    AP2F            = A333DR_pack2_fault == 1
    AP2FCVFC        = simDR_bleedair_pack2 == 0
    AP2PBOF		    = A333_switches_pack2_pos == 0
    ARAPBON         = A333_switches_ram_air_pos == 1

    BAPUBPBOF_1     = A333_switches_apu_bleed_pos == 0.0
    BAPUBPBOF_2     = A333_switches_apu_bleed_pos == 0.0
    BAPUBVFC_1      = A333_annun_apu_bleed_on == 0.0
    BAPUBVFC_2      = A333_annun_apu_bleed_on == 0.0
    BE1BPBOF_1      = A333_eng1_bleed_button_pos == 0.0
    BE1BPBOF_2      = A333_eng1_bleed_button_pos == 0.0
    BE1LOTEMP_1     = A333_precooler1_temp < 150.0
    BE1LOTEMP_2     = A333_precooler1_temp < 150.0
    BE2BPBOF_1      = A333_eng2_bleed_button_pos == 0.0
    BE2BPBOF_2      = A333_eng2_bleed_button_pos == 0.0
    BE2LOTEMP_1     = A333_precooler2_temp < 150.0
    BE2LOTEMP_2     = A333_precooler2_temp < 150.0
    BXFVFC_1	    = A333_isol_valve_right_pos == 0.0
    BXFVFC_2	    = A333_isol_valve_right_pos == 0.0
    BXFVFO_1        = A333_isol_valve_right_pos == 2.0
    BXFVFO_2        = A333_isol_valve_right_pos == 2.0

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

    EAC1OF          = simDR_bus_volts[0] < 1.0
    EAC2OF          = simDR_bus_volts[1] < 1.0
    EACSOF          = (simDR_ESS_bus_assign == 1 and simDR_bus_volts[0] < 1.0) or (simDR_ESS_bus_assign == 2 and simDR_bus_volts[1] < 1.0)
    EADCGNL         = simDR_elec_gen1_fail == 6 and simDR_elec_gen2_fail == 6
    EAPUGNF         = simDR_apu_fail == 6
    EAPUGNPBOF      = A333_buttons_gen_apu_pos == 0
    EBA1PBON        = simDR_battery_on[0] == 1
    EBA2PBON        = simDR_battery_on[1] == 1
    EBAT1F          = simDR_fail_battery1 == 6
    EBAT2F          = simDR_fail_battery2 == 6
    EBTIEPBOF       = A333_buttons_bus_tie_pos == 0.0
    EDC1OF          = simDR_bus_volts[0] < 1.0
    EDC2OF          = simDR_bus_volts[1] < 1.0
    EDCSOF          = simDR_bus_volts[3] < 1.0
    EEPWRCON        = simDR_gpu_on == 1
    EGN1COF         = A333_buttons_gen1_pos == 0
    EGN2COF         = A333_buttons_gen2_pos == 0
    EGN1PBOF        = A333_buttons_gen1_pos == 0
    EGN2PBOF        = A333_buttons_gen2_pos == 0
    EIDG1D          = A333_buttons_idg1_discon_pos == 0 or simDR_elec_gen1_fail == 6
    EIDG2D          = A333_buttons_idg2_discon_pos == 0 or simDR_elec_gen2_fail == 6
    ENG1INOP        = simDR_elec_gen1_fail == 6
    ENG2INOP        = simDR_elec_gen2_fail == 6
    ENG3INOP        = simDR_apu_fail == 6

    FCTP1COF        = A333_ECAM_fuel_center_xfer_any == 0
    FCTP2COF        = A333_ECAM_fuel_center_xfer_any == 0
    FLTP1LP         = simDR_tank_pump_psi[0] < 0.0
    FLTP12F         = A333_left_pump1_pos == 1 and A333_left_pump1_pos == 1.0 and simDR_tank_pump_psi[0] < 1.0
    FLTP1COF        = A333_left_pump1_pos == 0.0
    FLTP2COF        = A333_left_pump2_pos == 0.0
    FLTP2LP         = simDR_tank_pump_psi[0] < 0.0
    FLWTLLA         = simDR_fuel_left_wing < 1100.0
    FLWTLLB         = simDR_fuel_left_wing < 1100.0
    FRTP1COF        = A333_right_pump1_pos == 0.0
    FRTP12F         = A333_right_pump1_pos == 1 and A333_right_pump2_pos == 1.0 and simDR_tank_pump_psi[1] < 1.0
    FRTP2COF        = A333_right_pump2_pos == 0.0
    FRWTLLA         = simDR_fuel_right_wing < 1100.0
    FRWTLLB         = simDR_fuel_right_wing < 1100.0
    FXFVFC          = A333_fuel_crossfeed_valve_pos == 0.0
    FXFVPBON	    = A333DR_fuel_wing_crossfeed_pos == 1.0

    GBFANCON_1      = simDR_brake_fan == 1
    GBFANCON_2      = simDR_brake_fan == 1
    GBRK1OVHT       = A333_wheel_brake_temp1 > 300.0
    GBRK2OVHT       = A333_wheel_brake_temp2 > 300.0
    GBRK3OVHT       = A333_wheel_brake_temp3 > 300.0
    GBRK4OVHT       = A333_wheel_brake_temp4 > 300.0
    GBRK5OVHT       = A333_wheel_brake_temp5 > 300.0
    GBRK6OVHT       = A333_wheel_brake_temp6 > 300.0
    GBRK7OVHT       = A333_wheel_brake_temp7 > 300.0
    GBRK8OVHT       = A333_wheel_brake_temp8 > 300.0
    GDLORA_1        = simDR_auto_brake == 4
    GDLORA_2        = simDR_auto_brake == 4
    GDMDRA_1        = simDR_auto_brake == 5
    GDMDRA_2        = simDR_auto_brake == 5
    GDMXRA_1        = simDR_auto_brake == 0
    GDMXRA_2        = simDR_auto_brake == 0
    GELLGCOMPR		= simDR_tire_deflection_mtr[1] > 0.15
    GGLSD_1         = simDR_gear_handle_animation == 1.0
    GGLSD_2         = simDR_gear_handle_animation == 1.0
    GGLSUP_1        = simDR_gear_handle_animation == 0.0
    GGLSUP_2        = simDR_gear_handle_animation == 0.0
    GLDNUPL_1       = simDR_gear_deploy_ratio[1] > 0.1 and simDR_gear_deploy_ratio[1] < 0.9
    GLDNUPL_2       = simDR_gear_deploy_ratio[1] > 0.1 and simDR_gear_deploy_ratio[1] < 0.9
    GLGNLUPNSD_1    = simDR_gear_deploy_ratio[1] > 0.0 and simDR_gear_handle_animation < 1.0
    GLGNLUPNSD_2    = simDR_gear_deploy_ratio[1] > 0.0 and simDR_gear_handle_animation < 1.0
    GLLGC_1			= toboolean(simDR_gear_on_ground[1])
    GLLGC_2			= toboolean(simDR_gear_on_ground[1])
    GLLGC_1_INV		= false
    GLLGC_2_INV		= false
    GLLGC_1_NCD		= simDR_gear_on_ground[1] < 0 or simDR_gear_on_ground[1] > 1
    GLLGC_2_NCD		= simDR_gear_on_ground[1] < 0 or simDR_gear_on_ground[1] > 1
    GLGDL_1			= simDR_gear_deploy_ratio[1] > 0.98 -- L/G DOWNLOCKED
    GLGDL_2			= simDR_gear_deploy_ratio[1] > 0.98
    GLGNLDSD_1      = simDR_gear_deploy_ratio[1] < 1.0 and simDR_gear_handle_animation > 0.95
    GLGNLDSD_2      = simDR_gear_deploy_ratio[1] < 1.0 and simDR_gear_handle_animation > 0.95
    GLGNLUP_1       = simDR_gear_deploy_ratio[1] > 0.0
    GLGNLUP_2       = simDR_gear_deploy_ratio[1] > 0.0
    GLGNOE_1        = simDR_tire_deflection_mtr[1] > 0.0
    GLGNOE_2        = simDR_tire_deflection_mtr[1] > 0.0
    GLGUWGD_1       = simDR_gear_deploy_ratio[1] < 0.001 and GLGDL_1
    GLGUWGD_2       = simDR_gear_deploy_ratio[1] < 0.001 and GLGDL_2
    GLLGNOLK        = simDR_gear_deploy_ratio[1] > 0.0 and simDR_gear_deploy_ratio[1] < 1.0
    GMLGC_1         = simDR_tire_deflection_mtr[1] > 0.15 and simDR_tire_deflection_mtr[2] > 0.15
    GMLGC_2         = simDR_tire_deflection_mtr[1] > 0.15 and simDR_tire_deflection_mtr[2] > 0.15
    GNDNUPL_1       = simDR_gear_deploy_ratio[0] > 0.1 and simDR_gear_deploy_ratio[1] < 0.9
    GNDNUPL_2       = simDR_gear_deploy_ratio[0] > 0.1 and simDR_gear_deploy_ratio[1] < 0.9
    GNGDL_1			= simDR_gear_deploy_ratio[0] > 0.98
    GNGDL_2			= simDR_gear_deploy_ratio[0] > 0.98
    GNGNLDSD_1      = simDR_gear_deploy_ratio[0] < 1.0 and simDR_gear_handle_animation > 0.95
    GNGNLDSD_2      = simDR_gear_deploy_ratio[0] < 1.0 and simDR_gear_handle_animation > 0.95
    GNGNLUP_1       = simDR_gear_deploy_ratio[0] > 0.0
    GNGNLUP_2       = simDR_gear_deploy_ratio[0] > 0.0
    GNGNLUPNSD_1    = simDR_gear_deploy_ratio[0] > 0.0 and simDR_gear_handle_animation < 1.0
    GNGNLUPNSD_1    = simDR_gear_deploy_ratio[0] > 0.0 and simDR_gear_handle_animation < 1.0
    GNGNOE_1        = simDR_tire_deflection_mtr[0] > 0.0
    GNGNOE_2        = simDR_tire_deflection_mtr[0] > 0.0
    GNGUWGD_1       = simDR_gear_deploy_ratio[0] < 0.001 and GNGDL_1
    GNGUWGD_2       = simDR_gear_deploy_ratio[0] < 0.001 and GNGDL_2
    GNLGNOLK        = simDR_gear_deploy_ratio[0] > 0.0 and simDR_gear_deploy_ratio[0] < 1.0
    GNLLGCOMPR		= simDR_tire_deflection_mtr[1] > 0.15
    GPBRKON         = simDR_park_brake >= 0.5
    GRGDL_1			= simDR_gear_deploy_ratio[2] > 0.98
    GRGDL_2			= simDR_gear_deploy_ratio[2] > 0.98
    GRDNUPL_1       = simDR_gear_deploy_ratio[2] > 0.1 and simDR_gear_deploy_ratio[1] < 0.9
    GRDNUPL_2       = simDR_gear_deploy_ratio[2] > 0.1 and simDR_gear_deploy_ratio[1] < 0.9
    GRETIN_1		= simDR_gear_retract_fail_1 == 6 or simDR_gear_retract_fail_2 == 6 or simDR_gear_retract_fail_3 == 6
    GRETIN_2		= simDR_gear_retract_fail_1 == 6 or simDR_gear_retract_fail_2 == 6 or simDR_gear_retract_fail_3 == 6
    GRGNLDSD_1      = simDR_gear_deploy_ratio[2] < 1.0 and simDR_gear_handle_animation > 0.95
    GRGNLDSD_2      = simDR_gear_deploy_ratio[2] < 1.0 and simDR_gear_handle_animation > 0.95
    GRGNLUP_1       = simDR_gear_deploy_ratio[2] > 0.0
    GRGNLUP_2       = simDR_gear_deploy_ratio[2] > 0.0
    GRGNLUPNSD_1    = simDR_gear_deploy_ratio[2] > 0.0 and simDR_gear_handle_animation < 1.0
    GRGNLUPNSD_1    = simDR_gear_deploy_ratio[2] > 0.0 and simDR_gear_handle_animation < 1.0
    GRGNOE_1        = simDR_tire_deflection_mtr[2] > 0.0
    GRGNOE_2        = simDR_tire_deflection_mtr[2] > 0.0
    GRGUWGD_1       = simDR_gear_deploy_ratio[2] < 0.001 and GRGDL_1
    GRGUWGD_2       = simDR_gear_deploy_ratio[2] < 0.001 and GRGDL_2
    GRLGC_1		    = toboolean(simDR_gear_on_ground[2])
    GRLGC_2		    = toboolean(simDR_gear_on_ground[2])
    GRLGNOLK        = simDR_gear_deploy_ratio[2] > 0.0 and simDR_gear_deploy_ratio[2] < 1.0
    GW1SGT_1        = ((simDR_tire_rot_speed_rad_sec[1] * simDR_tire_radius[1]) * 1.94384) > 70.0
    GW1SGT_2        = ((simDR_tire_rot_speed_rad_sec[1] * simDR_tire_radius[1]) * 1.94384) > 70.0

    HBEPLP          = simDR_blue_hydraulic_pressure <= 1450.0
    HBEPOF          = simDR_elec_hydraulic_blue_on == 0.0
    HBEPPBOF        = A333_elec_pump_blue_tog_pos == 0.0
    HBRLL           = HBRQ < 5.0
    HBRQ            = BlueMaxLiters * simDR_blue_fluid_ratio
    HBRQLO          = HBRQ < 5.0
    HBSLP           = simDR_blue_hydraulic_pressure < 1450.0
    HGPLP           = simDR_green_hydraulic_pressure <= 1450.0
    HGPPBOF         = A333_engine1_pump_green_pos == 0.0
    HGRLL           = HGRQ < 8.0
    HGRQ            = GreenMaxLiters * simDR_green_fluid_ratio
    HGRQLO          = HGRQ < 8.0
    HGSLP           = simDR_green_hydraulic_pressure < 1450.0
    HNVMYEPF        = A333_hyd_elec_yellow_pump_fault == 1
    HNVMBEPF        = A333_hyd_elec_blue_pump_fault == 1
    HNVMGEPF        = A333_hyd_elec_green_pump_fault == 1
    HNVMBPF         = A333_hyd_eng1_blue_pump_fault == 1
    HNVMG1PF        = A333_hyd_eng1_green_pump_fault == 1
    HNVMG2PF        = A333_hyd_eng2_green_pump_fault == 1
    HNVMYPF         = A333_hyd_eng2_yellow_pump_fault == 1
    HPRATPBOF       = A333_rat_button_pos == 0
    HRATNFS         = simDR_rat_on > 0
    HYEPPBON        = A333_elec_pump_yellow_tog_pos == 1.0
    HYEPON          = simDR_elec_hydraulic_yellow_on == 1.0
    HYPLP           = simDR_yellow_hydraulic_pressure <= 1450.0
    HYPPBOF         = A333_engine2_pump_yellow_pos == 0.0
    HYRLL           = HYRQ < 5.0
    HYRQ            = YellowMaxLiters * simDR_yellow_fluid_ratio
    HYRQLO          = HYRQ < 5.0
    HYSLP           = simDR_yellow_hydraulic_pressure < 1450.0

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
    IWAIPBON        = A333_wing_anti_ice == 1.0

    JML1OFF         = A333_switches_engine1_start_pos == 0.0 and A333_switches_engine1_start_lift == 0.0
    JML1ON			= A333_switches_engine1_start_pos == 1.0 and A333_switches_engine1_start_lift == 0.0
    JML2OFF         = A333_switches_engine2_start_pos == 0.0 and A333_switches_engine2_start_lift == 0.0
    JML2ON			= A333_switches_engine2_start_pos == 1.0 and A333_switches_engine2_start_lift == 0.0


    JR1AIDLE_1A		= simDR_engine_n1_pct[0] >= 19.0
    JR1AIDLE_1B		= simDR_engine_n1_pct[0] >= 19.0
    JR1AUTOST_1A    = Engine1StartSequenceInProgress()
    JR1AUTOST_1B    = Engine2StartSequenceInProgress()
    JR1CMDREV_1A    = (simDR_throttle_beta_rev_ratio[0] <= -1.0)
    JR1CMDREV_1B    = (simDR_throttle_beta_rev_ratio[0] <= -1.0)
    JR1CONTIGN_1A   = simDR_igniter_on[0] == 1.0
    JR1CONTIGN_1B   = simDR_igniter_on[0] == 1.0
    JR1ESI          = simDR_engine1_igniter[0] == 1
    JR1HGST_1A      = simDR_eng1_hung_start == 6
    JR1HGST_1B      = simDR_eng1_hung_start == 6
    JR1IDLE_1A      = simDR_engine_throttle_used_ratio[0] == 0.0
    JR1IDLE_1B      = simDR_engine_throttle_used_ratio[0] == 0.0
    JR1IFT          = simDR_fail_rel_ignitr0 == 6
    JRIGNSEL        = simDR_starter_mode == 1
    JR1MINPWR_1A    = simDR_engine_n1_pct[0] > 19.0 and simDR_engine_n1_pct[0] < 22.0
    JR1MINPWR_1B    = simDR_engine_n1_pct[0] > 19.0 and simDR_engine_n1_pct[0] < 22.0
    JR1N1_1A		= simDR_engine_n1_pct[0]
    JR1N1_1B		= simDR_engine_n1_pct[0]
    JR1OOT_1        = 190.0
    JR1OOT_2        = 190.0
    JR1OLP          = simDR_engine_oil_pressure_psi[0] < 25.0
    JR1OT           = simDR_engine_oil_temp_degC[0]
    JR1OTAD_1       = 170.0
    JR1OTAD_2       = 170.0
    JR1REVD_1A      = simDR_engine_reverse_deploy_ratio[0] > 0.90
    JR1REVD_1B      = simDR_engine_reverse_deploy_ratio[0] > 0.90
    JR1REVKO        = simDR_engine1_reverse_fail == 6
    JR1REVUNL_1A    = simDR_engine_reverse_deploy_ratio[0] > 0.05
    JR1REVUNL_1B    = simDR_engine_reverse_deploy_ratio[0] > 0.05
    JR1TLA_1A		= simDR_throttle_ratio[0]
    JR1TLA_1B		= simDR_throttle_ratio[0]

    JR2AIDLE_2A		= simDR_engine_n1_pct[1] >= 19.0
    JR2AIDLE_2B		= simDR_engine_n1_pct[1] >= 19.0
    JR2CMDREV_2A    = (simDR_throttle_beta_rev_ratio[1] <= -1.0)
    JR2CMDREV_2B    = (simDR_throttle_beta_rev_ratio[1] <= -1.0)
    JR2CONTIGN_2A   = simDR_igniter_on[1] == 1.0
    JR2CONTIGN_2B   = simDR_igniter_on[1] == 1.0
    JR2ESI          = simDR_engine1_igniter[1] == 1
    JR2IFT          = simDR_fail_rel_ignitr1 == 6
    JR2HGST_2A      = simDR_eng2_hung_start == 6
    JR2HGST_2B      = simDR_eng2_hung_start == 6
    JR2IDLE_2A      = simDR_engine_throttle_used_ratio[1] == 0.0
    JR2IDLE_2B      = simDR_engine_throttle_used_ratio[1] == 0.0
    JR2MINPWR_2A    = simDR_engine_n1_pct[1] > 19.0 and simDR_engine_n1_pct[1] < 22.0
    JR2MINPWR_2B    = simDR_engine_n1_pct[1] > 19.0 and simDR_engine_n1_pct[1] < 22.0
    JR2N1_2A		= simDR_engine_n1_pct[1]
    JR2N1_2B		= simDR_engine_n1_pct[1]
    JR2OOT_1        = 190.0
    JR2OOT_2        = 190.0
    JR2OLP          = simDR_engine_oil_pressure_psi[1] < 25.0
    JR2OT           = simDR_engine_oil_temp_degC[1]
    JR2OTAD_1       = 170.0
    JR2OTAD_2       = 170.0
    JR2REVD_2A      = simDR_engine_reverse_deploy_ratio[1] > 0.90
    JR2REVD_2B      = simDR_engine_reverse_deploy_ratio[1] > 0.90
    JR2REVKO        = simDR_engine2_reverse_fail == 6
    JR2REVUNL_2A    = simDR_engine_reverse_deploy_ratio[1] > 0.05
    JR2REVUNL_2B    = simDR_engine_reverse_deploy_ratio[1] > 0.05
    JR2TLA_2A		= simDR_throttle_ratio[1]
    JR2TLA_2B		= simDR_throttle_ratio[1]

    KAP1EC_1        = toboolean(simDR_ap_servos_on == 1)
    KAP1EM_1        = toboolean(simDR_ap_servos_on == 1)
    KAP2EC_2        = toboolean(simDR_ap_servos2_on == 1)
    KAP2EM_2        = toboolean(simDR_ap_servos2_on == 1)
    KATHRE			= simDR_ap_autothrottle_on == 1
    KCCE            = toboolean(A333DR_fws_aural_alert_ccc == 1)
    KID1APE         = toboolean(A333_capt_priority_pos == 1)
    KID2APE         = toboolean(A333_fo_priority_pos == 1)
    KLONRJ_1        = simDR_airbus_speed_warn_thro_0 == 1
    KLONRJ_2        = simDR_airbus_speed_warn_thro_1 == 1
    KLTRKM_1		= simDR_ap_approach_status == 2
    KLTRKM_2		= simDR_ap_approach_status == 2
    KRTP_1          = simDR_rudder_trim_ratio * 25.0
    KRTP_2          = simDR_rudder_trim_ratio * 25.0
    KSPEEDGEN       = A333DR_fws_aco_speed_playing == 1
    KWINDSD_1       = simDR_windshear_warning == 1
    KWINDSD_2       = simDR_windshear_warning == 1
    KWINDSGEN       = A333DR_fws_aco_windshear_playing == 1

    LSLPBOF         = A333_strobe_switch_pos == 0

    NALTFBK_1       = simDR_baro_alt_ft_pilot
    NALTFBK_2       = simDR_baro_alt_ft_copilot
    NALTI_1			= simDR_baro_alt_ft_pilot
    NALTI_2			= simDR_baro_alt_ft_copilot
    NALTI_3			= simDR_baro_alt_ft_stby
    NBRQ20_1        = toboolean(simDR_barometer_setting_is_std_pilot)
    NBRQ21_1        = not(toboolean(simDR_barometer_setting_is_std_pilot))
    NBRQ20_2        = toboolean(simDR_barometer_setting_is_std_copilot)
    NBRQ21_2        = not(toboolean(simDR_barometer_setting_is_std_copilot))
    NCAS_1			= simDR_cas_kts_pilot
    NCAS_1_INV		= simDR_airspeed_fail_pilot == 6
    NCAS_1_NCD		= NCAS_1 > 1024.0
    NCAS_2			= simDR_cas_kts_copilot
    NCAS_2_INV		= simDR_airspeed_fail_copilot == 6
    NCAS_2_NCD		= NCAS_2 > 1024.0
    NCAS_3			= simDR_cas_kts_stby
    NCAS_3_INV		= false
    NCAS_3_NCD		= NCAS_3 > 1024.0
    NCBAC_1         = simDR_baro_alt_ft_pilot
    NFFMSLDG3       = simDR_fms_landing_flap_config == 3
    NFOBAC_2        = simDR_baro_alt_ft_copilot
    NFPBLDG3        = simDR_flap_handle_ratio == 0.75 and A333_gpws_flap_status == 1 -- for A333 see NFFMSLDG3
    NGPWSFMOF       = A333_gpws_flap_tog_pos < 0.01
    NGPWSM          = false -- TODO: a GPWS aural alert 1 thru 5 is playing
    NGSVA           = toboolean(simDR_gs_annun)
    NHUNABGEN		= A333DR_fws_aco_hundred_above_playing == 1
    NMINGEN         = A333DR_fws_aco_minimum_playing == 1
    NRADH_1			= simDR_radio_alt_ht_pilot
    NRADH_2			= simDR_radio_alt_ht_copilot
    NRADH_1_INV		= simDR_radio_alt_pilot_fail == 6
    NRADH_2_INV		= simDR_radio_alt_copilot_fail == 6
    NRADH_1_NCD		= simDR_radio_alt_ht_pilot > 8192.0
    NRADH_2_NCD		= simDR_radio_alt_ht_copilot > 8192.0
    NSFCONF3NS      = simDR_CONF_sel ~= 6
    NSTALL1         = simDR_stall_warning == 1
    NTCASINIB       = toboolean(A333_audio_tcas_alert == 1)
    NVMOW_1         = (simDR_airspeed_kts_pilot > 330.0) or (simDR_airspeed_kts_copilot > 330.0) or (simDR_airspeed_kts_stby > 330.0)

    PALTI           = simDR_pressure_altitude
    PAS12F          = toboolean(A333DR_pack1_fault == 1 and A333DR_pack2_fault == 1)
    PS1F_1          = simDR_hvac_fail == 6
    PS2F_2          = simDR_hvac_fail == 6

    QAVAIL          = A333DR_fws_apu_avail == 1.0
    QMSON           = simDR_apu_switch > 0

    SCSSF_1         = toboolean(simDR_priority_side == 2)
    SCSSF_2         = toboolean(simDR_priority_side == 2)
    --SDUALSSI        = toboolean(A333_dual_input == 1)
    SFLPFY          = bOR(SFLPINOP, SFLPLCKD)
    SFLPINOP        = simDR_flap_act_failure == 6
    SFLPLCKD        = simDR_flap_1_lft_lock == 6 or simDR_flap_1_rgt_lock == 6 or simDR_flap_2_lft_lock == 6 or simDR_flap_2_rgt_lock == 6
    SFOSSF_1        = toboolean(simDR_priority_side == 1)
    SFOSSF_2        = toboolean(simDR_priority_side == 1)
    SGNDSPLRA_1     = simDR_ctrl_speed_brk_ratio == -0.5
    SGNDSPLRA_2     = simDR_ctrl_speed_brk_ratio == -0.5
    SLELVBA_1       = simDR_blue_hydraulic_pressure >= 200
    SLELVBA_2       = simDR_blue_hydraulic_pressure >= 200
    SLELVGA_1       = simDR_green_hydraulic_pressure >= 200
    SLELVGA_2       = simDR_green_hydraulic_pressure >= 200
    --SLFLPPOS		= simDR_flap_deg[0]
    --SLSLTPOS        = math.round95(simDR_slat2_deploy_rat * 23.0)
    SPCCMD_1        = simDR_yoke_pitch_ratio_pilot
    SPCCMD_2        = simDR_yoke_pitch_ratio_pilot
    SPFOCMD_1       = simDR_yoke_pitch_ratio_copilot
    SPFOCMD_2       = simDR_yoke_pitch_ratio_copilot
    SRCCMD_1        = simDR_yoke_roll_ratio_pilot
    SRCCMD_2        = simDR_yoke_roll_ratio_pilot
    SRFOCMD_1       = simDR_yoke_roll_ratio_copilot
    SRFOCMD_2       = simDR_yoke_roll_ratio_copilot
    SRELVBA_1       = simDR_blue_hydraulic_pressure >= 200
    SRELVBA_2       = simDR_blue_hydraulic_pressure >= 200
    SRELVYA_1       = simDR_yellow_hydraulic_pressure >= 200
    SRELVYA_2       = simDR_yellow_hydraulic_pressure >= 200
    --SRFLPPOS		= simDR_flap_deg[1]
    --SRSLTPOS      = math.round95(simDR_slat2_deploy_rat * 23.0)

    SS00F00_1       = simDR_CONF_sel == 0
    SS00F00_2       = simDR_CONF_sel == 0
    SS16F00_1       = simDR_CONF_sel == 1
    SS16F00_2       = simDR_CONF_sel == 1
    SS16F08_1       = simDR_CONF_sel == 2
    SS16F08_2       = simDR_CONF_sel == 2
    SS20F14_1       = simDR_CONF_sel == 4
    SS20F14_2       = simDR_CONF_sel == 4
    SS23F22_1       = simDR_CONF_sel == 6
    SS23F22_2       = simDR_CONF_sel == 6
    SS23F32_1       = simDR_CONF_sel == 7
    SS23F32_2       = simDR_CONF_sel == 7

    SSPBR_1         = simDR_ctrl_speed_brk_ratio > 0.0
    SSPBR_2         = simDR_ctrl_speed_brk_ratio > 0.0
    STAB1POS_1      = simDR_stab_deflection_deg
    STAB1POS_2      = simDR_stab_deflection_deg

    UAPUELP         = A333_apu_agent_psi < 300.0
    UAPUFA			= simDR_apu_fire == 6
    UAPUFB			= simDR_apu_fire == 6
    UAPUFPBOUT		= A333_apu_fire_handle_pos > 0.99
    UE1ABLP         = A333_eng1_agent2_psi < 300.0
    UE1FA           = toboolean(simDR_engine_fire[0])
    UE1FB           = toboolean(simDR_engine_fire[0])
    UE1FBLP         = A333_eng1_agent1_psi < 300.0
    UE1FIRE         = false
    UE1FPBOUT		= A333_eng1_fire_handle_pos > 0.99

    UE2ABLP         = A333_eng2_agent2_psi < 300.0
    UE2FA           = toboolean(simDR_engine_fire[1])
    UE2FB           = toboolean(simDR_engine_fire[1])
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
    WDH_1_NCD       = simDR_radio_altimeter_bug_ft_pilot == -1000.0 and simDR_baro_alt_bug_ft_pilot <= 0
    WDH_1_VAL   	= simDR_radio_altimeter_bug_ft_pilot > -1000.0 or simDR_baro_alt_bug_ft_pilot > 0
    WDH_2_NCD       = simDR_radio_altimeter_bug_ft_copilot == -1000.0 and simDR_baro_alt_bug_ft_copilot <= 0
    WDH_2_VAL   	= simDR_radio_altimeter_bug_ft_copilot > -1000.0 or simDR_baro_alt_bug_ft_copilot > 0
    WDH100A         = NRHV >= WDH_1 + 100.0
    WDH100B         = NRHV >= WDH_2 + 100.0
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

    ZNMLSTSPD       = toboolean(A333DR_fws_sts_normal_msg_show)

end







--*************************************************************************************--
--** 				                   PROCESSING             	     	  			 **--
--*************************************************************************************--

function A333_fws_200()

    A333_fws_global_variable_assignment()

end






--*************************************************************************************--
--** 				                 EVENT CALLBACKS           	    	 			 **--
--*************************************************************************************--



--*************************************************************************************--
--** 				               SUB-SCRIPT LOADING             	     			 **--
--*************************************************************************************--

-- dofile("fileName.lua")







