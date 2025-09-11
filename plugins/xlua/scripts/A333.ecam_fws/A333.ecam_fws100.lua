jit.off()
--[[
*****************************************************************************************
* Script Name : A333.ecam_fws100.lua
* Process: FWS Global Constants & Variables
*
* Author Name :	Jim Gregory
*
* Revisions:
* -- DATE --  --- REV NO ---  --- DESCRIPTION -------------------------------------------
* 10/09/2025   AG330 v1.2.0   add ADRALGN & ADRTIME variable for ADIRS ALIGN EWD MSG
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


--print("LOAD: A333.ecam_fws100.lua")

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

ENGINE = 1
BLEED = 2
PRESS = 3
ELECAC = 4
ELECDC = 5
HYDRLC = 6
CRCBKR = 7
APU	 = 8
COND = 9
DOOR = 10
WHEEL = 11
FLTCTL = 12
FUEL = 13
CRUISE = 14
STATUS = 15

SPECIAL_LINE = 0
INDEPENDENT	= 1
PRIMARY = 1
SECONDARY = 2
CONFIG_MEMO	= 3
MEMO = 4

BlueMaxLiters	= 32.0
GreenMaxLiters	= 47.0
YellowMaxLiters	= 12.0



--*************************************************************************************--
--** 					            GLOBAL VARIABLES                				 **--
--*************************************************************************************--

fws_debug = false

raw_table('A333_ewd_msg')
A333_ewd_msg = {}

raw_table('A333_ewd_msg_cue_L')
A333_ewd_msg_cue_L = {}

raw_table('A333_ewd_msg_cue_R')
A333_ewd_msg_cue_R = {}


raw_table('A333_sts_msg')
A333_sts_msg = {}

raw_table('A333_sts_msg_cue_L')
A333_sts_msg_cue_L = {}

raw_table('A333_sts_msg_cue_R')
A333_sts_msg_cue_R = {}


raw_table('A333_aural_alert')
A333_aural_alert = {}


A333_ecam_normal_system_page_num	= 0			-- FLIGHT PHASES
A333_ecam_manual_system_page_num	= 0			-- ECP BUTTON PRESS
A333_ecam_status_system_page_num	= 0			-- ECP BUTTON PRESS
A333_ecam_advisory_system_page_num	= 0			-- ADVISORY SYSTEM
A333_ecam_failure_system_page_num	= 0			-- FAILED SYSTEM


A333_fws_process_rcl_normal = false
A333_fws_process_sts_normal	= false

FlightPhaseIsValid = false

masterCancelSilence = false

ADRALGN             = false         -- [AG330] ADIRS IS ALIGNED
ADRTIME             = 12

AB1AVAIL			= false			-- AIR BLEED 1 AVAIL
AB1WAIAV			= false			-- AIR BLEED 1 WAI AVAIL
AB2AVAIL			= false			-- AIR BLEED 2 AVAIL
AB2WAIAV			= false			-- AIR BLEED 2 WAI AVAIL
AUDIOATT			= false			-- AUDIO ATTENUATION
AP12FT				= false			-- AP12FT
AP12INOP			= false			-- PACK 1+2 INOP
AP1CF				= false 		-- PACK 1 CONT FAULT
AP1F 				= false			-- PACK 1 FAULT
AP1FCVFC			= false			-- PACK 1 FLOW CTL VALVE FC
AP1I				= false			-- PACK 1 INOP
AP1OHT				= false			-- PACK 1 OVHT
AP1PBOF				= false			-- PACK 1 P/B OFF
AP2CF				= false			-- PACK 2 CONT FAULT
AP2F 				= false			-- PACK 2 FAULT
AP2FCVFC			= false			-- PACK 1 FLOW CTL VALVE FC
AP2I				= false			-- PACK 2 INOP
AP2OHT				= false			-- PACK 2 OVHT
AP2PBOF				= false			-- PACK 2 P/B OFF
ARAPBON				= false			-- RAM AIR P/B ON

BAPUBPBOF_1			= false			-- APU BLEED P/B OFF
BAPUBPBOF_1_VAL		= true			-- APU BLEED P/B OFF VALID
BAPUBPBOF_2			= false			-- APU BLEED P/B OFF
BAPUBPBOF_2_VAL		= true			-- APU BLEED P/B OFF VALID
BAPUBVFC_1			= false			-- APU BLEED VALVE FC
BAPUBVFC_2			= false			-- APU BLEED VALVE FC
BB1NA				= false			-- BLEED 1 NOT AVAIL
BB2NA				= false			-- BLEED 2 NOT AVAIL
BBAIC				= false			-- BLEED AVOID ICING COND
BBNA				= false			-- BLEED NOT AVAIL
BE1BPBOF_1			= false			-- ENG1 BLEED P/B OFF
BE1BPBOF_2			= false			-- ENG1 BLEED P/B OFF
BE1LOTEMP_1			= false			-- ENG2 BLEED LO TEMP
BE1LOTEMP_2			= false			-- ENG2 BLEED LO TEMP
BE1PRVACC_1			= false			-- ENG1 PRV AUTO-CLOSURE CTL
BE1PRVACC_2			= false			-- ENG1 PRV AUTO-CLOSURE CTL
BE1PRVD_1			= false			-- ENG1 PRESS REG VALVE DISAGREE
BE1PRVD_2			= false			-- ENG1 PRESS REG VALVE DISAGREE
BE1PRVFC_1			= false			-- ENG1 PRESS REG VALVE FC
BE1PRVFC_2			= false			-- ENG1 PRESS REG VALVE FC
BE2BPBOF_1			= false			-- ENG2 BLEED P/B OFF
BE2BPBOF_2			= false			-- ENG2 BLEED P/B OFF
BE2LOTEMP_1			= false			-- ENG2 BLEED LO TEMP
BE2LOTEMP_2			= false			-- ENG2 BLEED LO TEMP
BE2PRVACC_1			= false			-- ENG2 PRV AUTO-CLOSURE CTL
BE2PRVACC_2			= false			-- ENG2 PRV AUTO-CLOSURE CTL
BE2PRVD_1			= false			-- ENG2 PRESS REG VALVE DISAGREE
BE2PRVD_2			= false			-- ENG2 PRESS REG VALVE DISAGREE
BE2PRVFC_1			= false			-- ENG1 PRESS REG VALVE FC
BE2PRVFC_2			= false			-- ENG1 PRESS REG VALVE FC
BPE1LM_1			= false			-- PYLON ENG1 LEAK MEMORIZED
BPE1LM_2			= false			-- PYLON ENG1 LEAK MEMORIZED
BPE2LM_1			= false			-- PYLON ENG2 LEAK MEMORIZED
BPE2LM_2			= false			-- PYLON ENG2 LEAK MEMORIZED
BLPL				= false			-- L PYLON LEAK
BLWL				= false			-- LEFT WING LEAK
BRPL				= false			-- R PYLON LEAK
BRWL				= false			-- RIGHT WING LEAK
BXFDOD				= false			-- X FEED OPEN DISAGREE
BXFDOMD				= false			-- XFEED OPEN MAN DISAGREE
BXFVFC_1			= false			-- XFEED VALVE FC
BXFVFC_1_VAL		= false			-- XFEED VALVE FC VALID SIGNAL
BXFVFC_1_INV		= false			-- XFEED VALVE FC VALID SIGNAL DATA FAIL
BXFVFC_2			= false			-- XFEED VALVE FC
BXFVFC_2_VAL		= false			-- XFEED VALVE FC VALID SIGNAL
BXFVFC_2_INV		= false			-- XFEED VALVE FC VALID SIGNAL DATA FAIL
BXFVCAD_1			= false			-- XFEED VALVE CLOSED AUTO DISAGREE
BXFVCAD_2			= false			-- XFEED VALVE CLOSED AUTO DISAGREE
BXFVCD				= false			-- XFEED VALVE CLOSED DISAGREE
BXFVCMD_1			= false			-- XFEED VALVE CLOSED MAN DISAGREE
BXFVCMD_2			= false			-- XFEED VALVE CLOSED MAN DISAGREE
BXFVFO_1			= false			-- XFEED VALVE FO
BXFVFO_2			= false			-- XFEED VALVE FO
BXFVOAD_1			= false			-- XFEED VALVE OPEN AUTO DISAGREE
BXFVOAD_2			= false			-- XFEED VALVE OPEN AUTO DISAGREE
BXFVOMD_1			= false			-- XFEED VALVE OPEN MAN DISAGREE
BXFVOMD_2			= false			-- XFEED VALVE OPEN MAN DISAGREE
BXFVSOP_1			= false			-- XFEED VALVE SELECTOR OPEN
BXFVSOP_2			= false			-- XFEED VALVE SELECTOR OPEN
BXFVSSH_1			= false			-- XFEED VALVE SELECTOR SHUT
BXFVSSH_2			= false			-- XFEED VALVE SELECTOR SHUT

CAOCMSG             = false         -- A/L MSG RECEIVED
CATSUHF1VAL         = false         -- HFDR1 VALID
CATSUHF1VF          = false         -- HFDR1 VOICE MODE
CATSUHF2VAL         = false         -- HFDR2 VALID
CATSUHF2VF          = false         -- HFDR2 VOICE MODE
CATSUMSGACT         = false         -- FLIGHT PHASE ATSU MESSAGE ACTIVATION
CCABR				= false			-- CABIN READY
CCR1				= false			-- CABIN READY
CCR2				= false			-- CABIN READY
CFSBLT				= false			-- FASTEN SEAT BELT ON
CHFDRVOICE          = false
CNOSMOK				= false			-- NO SMOKING ON
CSIGNSONP			= false			-- SIGNS ON PROC

DAVCDNC				= false			-- AVIONICS/CARGO DOOR NOT CLOSED
DLACDNC				= false			-- LH AFT CABIN DOOR
DLEEDNC				= false			-- LH EMERG EXIT DOOR
DLFCDNC				= false			-- LH FWD CABIN DOOR
DLMCDNC				= false			-- LH MID CABIN DOOR
DODNC				= false			-- ONE DOOR NOT CLOSED
DRACDNC				= false			-- RH AFT CABIN DOOR
DRAVDNC				= false			-- RH AVIONICS DOOR NOT CLOSED
DREEDNC				= false			-- RH EMERG EXIT DOOR
DRFCDNC				= false			-- RH FWD CABIN DOOR
DRMCDNC				= false			-- RH MID CABIN DOOR
DTOCTPH3			= false			-- T.O CONFIG OR PHASE3


EAC1OF				= false			-- AC1 BUS OFF
EAC2OF				= false			-- AC2 BUS OFF
EACSOF				= false			-- AC ESS BUS OFF
EADCGNL				= false			-- ALL DC GEN LOST
EAPUGNF				= false			-- APU GEN FAULT
EAPUGNPBOF			= false			-- APU GEN P/B OFF
EBA1PBON			= false			-- BAT1 P/B ON
EBA2PBON			= false			-- BAT2 P/B ON
EBAT1F				= false			-- BAT1 FAULT
EBAT2F				= false			-- BAT1 FAULT
EBTIEPBOF			= false			-- BUS TIE P/B OFF
EDC12OF				= false			-- DC BUS 1+2 OFF
EDC1OF				= false			-- DC1 BUS OFF
EDC2OF				= false			-- DC2 BUS OFF
EDCBSSCOF			= false			-- DC BATT/DC ESS SHED CNTOR OFF
EDCEC				= false			-- DC EMER CONFIG
EDCSOF				= false			-- DC ESS BUS OFF
EEGNCON				= false			-- EMER GEN LINE CNTOR ON
EEMER				= false			-- EMER ELEC
EEPWRCON			= false			-- EXT PWR LINE CNTOR ON
EG1FM				= false			-- GEN 1 FAULT MEM
EG2FM				= false			-- GEN 2 FAULT MEM
EGAPUM				= false			-- GEN APU MEM
EGEN12R				= false			-- GEN 1+2 RESET
EGENRESET			= false			-- GEN RESET
EGN1COF				= false			-- GEN1 LINE CNTOR OFF
EGN1PBOF 			= false			-- GEN1 P/B OFF
EGN2COF				= false			-- GEN2 LINE CNTOR OFF
EIDG1D				= false			-- IDG1 DISCONNECTED
EIDG2D				= false			-- IDG2 DISCONNECTED
ENG1INOP			= false			-- GEN 1 INOP
ENG2INOP			= false			-- GEN 2 INOP
EGN2PBOF			= false			-- GEN 2 P/B OFF
ENG3INOP			= false			-- GEN APU INOP

FCTI_1				= true			-- CENTRE TANK INSTALLED
FCTI_2				= true			-- CENTRE TANK INSTALLED
FCTP1COF			= false			-- CTR TK PUMP1 CNTOR OFF
FCTP1COF_INV		= false			-- CTR TK PUMP1 CNTOR OFF  DATA FAIL
FCTP12F				= false			-- CTR TK PUMP 1+2 FAULT
FCTP2COF			= false			-- CTR TK PUMP2 CNTOR OFF
FCTP2COF_INV		= false			-- CTR TK PUMP2 CNTOR OFF  DATA FAIL
FLGFEED				= false			-- L GRVTY FEED
FLRGFEED			= false			-- L+R GRVTY FEED
FLRWLL				= false			-- L+R WING LO LEVEL
FLTP1COF			= false			-- LH TK PUMP1 CNTOR OFF
FLTP1LP				= 0				-- LH TK PUMP1 LO PR
FLTP12F				= false			-- L TK PUMP 1+2 FAULT
FLTP2COF			= false			-- LH TK PUMP2 CNTOR OFF
FLTP2LP				= 0				-- LH TK PUMP2 LO PR
FLTP1LP				= 0				-- LH TK PUMP1 LO PR
FLWLL				= false			-- L WING LO LVL
FMITD				= false			-- FUEL MOD INSTALLED
FMNITD				= true			-- FUEL MOD NOT INSTALLED
FRGFEED				= false			-- R GRVTY FEED
FRWLL				= false			-- R WING LO LVL
FLWTLLA				= false			-- RH WING TK LO LEVEL CH.A
FLWTLLB				= false			-- RH WING TK LO LEVEL CH.B
FRTP1COF			= false			-- RH TK PUMP1 CNTOR OFF
FLTP12F				= false 		-- R TK PUMP 1+2 FAULT
FRTP2COF			= false			-- RH TK PUMP2 CNTOR OFF
FRWTLLA				= false			-- RH WING TK LO LEVEL CH.A
FRWTLLB				= false			-- RH WING TK LO LEVEL CH.B
FXFVFC 				= false			-- FUEL XFEED VALVE FC
FXFVPBON			= false			-- FUEL XFEED VALVE P/B ON

GABRKF_1			= false			-- AUTOBRAKE FAULT
GABRKF_2			= false			-- AUTOBRAKE FAULT
GASF                = false         -- ANTI SKID FAULT
GASKDOFF			= false			-- ANTI SKID OFF
GBFANCON_1			= false			-- BRK FAN CTL ON
GBFANCON_1_NCD		= false			-- BRK FAN CTL ON DATA OUT-OF-RANGE
GBFANCON_2			= false			-- BRK FAN CTL ON
GBFANCON_2_NCD		= false			-- BRK FAN CTL ON DATA OUT-OF-RANGE
GBGFT				= false			-- BOGIE FAULT
GBFI_1				= true			-- BRAKES FAN INSTALLED
GBFI_2				= true			-- BRAKES FAN INSTALLED
GBI_1				= true			-- BOGGIE INSTALLED
GBI_2				= true			-- BOGGIE INSTALLED
GBRKOVHT			= false			-- BRAKE OVHT
GBRK1OVHT			= false			-- BRAKE 1 OVHT
GBRK2OVHT			= false			-- BRAKE 2 OVHT
GBRK3OVHT			= false			-- BRAKE 3 OVHT
GBRK4OVHT			= false			-- BRAKE 4 OVHT
GBRK5OVHT			= false			-- BRAKE 5 OVHT
GBRK6OVHT			= false			-- BRAKE 6 OVHT
GBRK7OVHT			= false			-- BRAKE 7 OVHT
GBRK8OVHT			= false			-- BRAKE 8 OVHT
GDLORA_1			= false			-- DECEL LO RATE ARMED
GDLORA_1_NCD		= false			-- DECEL LO RATE ARMED DATA OUT-OF-RANGE
GDLORA_2			= false			-- DECEL LO RATE ARMED
GDLORA_2_NCD		= false			-- DECEL LO RATE ARMED DATA OUT-OF-RANGE
GDMDRA_1			= false			-- DECEL MED RATE ARMED
GDMDRA_1_NCD		= false			-- DECEL MED RATE ARMED DATA OUT-OF-RANGE
GDMDRA_2			= false			-- DECEL MED RATE ARMED
GDMDRA_2_NCD		= false			-- DECEL MED RATE ARMED DATA OUT-OF-RANGE
GDMXRA_1			= false			-- DECEL MAX RATE ARMED
GDMXRA_1_NCD		= false			-- DECEL MAX RATE ARMED DATA OUT-OF-RANGE
GDMXRA_2			= false			-- DECEL MAX RATE ARMED
GDMXRA_2_NCD		= false			-- DECEL MAX RATE ARMED DATA OUT-OF-RANGE
GDNC				= false			-- DOORS NOT CLOSED
GEBF				= false			-- ELEC BRK FAULT
GELLGCOMPR			= false			-- ESS LH L/G COMPRESSED
GGLSD_1				= false			-- GEAR LEVER SELECT DOWN
GGLSD_1_INV			= false			-- GEAR LEVER SELECT DOWN DATA FAIL
GGLSD_2				= false			-- GEAR LEVER SELECT DOWN
GGLSD_2_INV			= false			-- GEAR LEVER SELECT DOWN DATA FAIL
GGLSUP_1			= false			-- GEAR LEVER SELECT UP
GGLSUP_1_INV		= false			-- GEAR LEVER SELECT UP DATA FAIL
GGLSUP_2			= false			-- GEAR LEVER SELECT UP
GGLSUP_2_INV		= false			-- GEAR LEVER SELECT UP DATA FAIL
GGLUP				= false			-- GEAR LOCKED UP
GGNLUPANSD 			= false			-- GEAR NOT LOCK UP AND NOT SELECT DOWN
GGUPENG				= false			-- GEAR UPLOCK ENGAGED
GLDNUPL_1			= false			-- ESS LH L/G COMPRESSED
GLDNUPL_1_INV		= false			-- ESS LH L/G COMPRESSED DATA FAIL
GLDNUPL_2			= false			-- ESS LH L/G COMPRESSED
GLDNUPL_2_INV		= false			-- ESS LH L/G COMPRESSED DATA FAIL
GLGCIU1FT			= false			-- LGCIU 1 FAULT
GLGCIU2FT			= false			-- LGCIU 2 FAULT
GLGDL_1             = false         -- LH GEAR DOWN LOCK
GLGDL_2             = false         -- LH GEAR DOWN LOCK
GLGDNLKD			= false			-- L/G DOWNLOCKED
GLGE				= false 		-- LH GEAR EXTEND
GLGEXT 				= false			-- GEAR EXTEND
GLGNDNE				= false			-- L/G NOT DOWN NOT EFFACABLE
GLGNDOWN			= false			-- L/G NOT DOWN
GLGNLKD				= false			-- L/G NOT LKD
GLGNOE_1			= false			-- LH GEAR NOT EXTEND
GLGNOE_2			= false			-- LH GEAR NOT EXTEND
GLGNUP				= false			-- L/G NOT UPLOCKED
GLGLUP 				= false			-- LH GEAR LOCKED UP
GLGNE				= false			-- GEAR NOT EXTEND
GLGNLUP_1			= false 		-- LH GEAR NOT LOCK UP
GLGNLUP_2			= false 		-- LH GEAR NOT LOCK UP
GLGNLUPNSD_1		= false			-- LH GEAR NOT LOCK UP AND NOT SELECT DOWN
GLGNLUPNSD_2		= false			-- LH GEAR NOT LOCK UP AND NOT SELECT DOWN
GLGNLDSD			= false			-- GEAR NOT DOWNLOCKED AND SELECT DOWN
GLGNLDSD_1			= false			-- LH GEAR NOT LOCK DOWN AND SELECT DOWN
GLGNLDSD_2			= false			-- LH GEAR NOT LOCK DOWN AND SELECT DOWN
GLGNUM				= false			-- L/G NOT UPLOCKED MEM
GLGUWGD_1			= false			-- LH GEAR UPLOCK WITH GEAR DOWN LOCK
GLGUWGD_2			= false			-- LH GEAR UPLOCK WITH GEAR DOWN LOCK
GLLGC_1				= false			-- LH L/G COMPRESSED
GLLGC_1_INV			= false			-- LH L/G WOW SWITCH FAILURE
GLLGC_1_NCD			= false			-- LH L/G DATA OUT-OF-RANGE
GLLGC_2				= false			-- LH L/G COMPRESSED
GLLGC_2_INV			= false			-- LH L/G WOW SWITCH FAILURE
GLLGC_2_NCD			= false			-- LH L/G DATA OUT-OF-RANGE
GLLGNOLK			= false			-- LH L/G NOT LKD
GMLGC_1				= false			-- MAIN L/G COMPRESSED
GMLGC_2				= false			-- MAIN L/G COMPRESSED
GNABF				= false			-- NORM+ALTN BRK FAULT
GNDNUPL_1			= false			-- NOSE DOOR NOT UPLOCK
GNDNUPL_1_INV		= false			-- NOSE DOOR NOT UPLOCK DATA FAIL
GNDNUPL_2			= false			-- NOSE DOOR NOT UPLOCK
GNDNUPL_2_INV		= false			-- NOSE DOOR NOT UPLOCK DATA FAIL
GNGDL_1             = false         -- NOSE GEAR DOWN LOCK
GNGDL_2             = false         -- NOSE GEAR DOWN LOCK
GNGNLUP_1			= false 		-- RH GEAR NOT LOCK UP
GNGNLUP_2			= false 		-- RH GEAR NOT LOCK UP
GNGNLUPNSD_1		= false  		-- NOSE GEAR NOT LOCK DOWN AND SELECT DOWN
GNGNLUPNSD_2		= false  		-- NOSE GEAR NOT LOCK DOWN AND SELECT DOWN
GNGNOE_1			= false			-- NOSE GEAR NOT EXTEND
GNGNOE_2			= false			-- NOSE GEAR NOT EXTEND
GNGNLDSD_1			= false			-- NOSE GEAR NOT LOCK DOWN AND SELECT DOWN
GNGNLDSD_2			= false			-- NOSE GEAR NOT LOCK DOWN AND SELECT DOWN
GNGNLUPNSD_1		= false			-- NOSE GEAR NOT LOCK UP AND NOT SELECT DWN
GNGNLUPNSD_2		= false			-- NOSE GEAR NOT LOCK UP AND NOT SELECT DWN
GNGUWGD_1			= false			-- NOSE GEAR UPLOCK WITH GEAR DOWN LOCK
GNGUWGD_2			= false			-- NOSE GEAR UPLOCK WITH GEAR DOWN LOCK
GNLGNOLK			= false			-- NOSE L/G NOT LKD
GNLLGCOMPR			= false 		-- NORM LH L/G COMPRESSED
GPBRKON				= false			-- PARK BRAKE ON
GRDNUPL_1			= false			-- RH DOOR NOT UPLOCK
GRDNUPL_1_INV		= false			-- RH DOOR NOT UPLOCK DATA FAIL
GRDNUPL_2			= false			-- RH DOOR NOT UPLOCK
GRDNUPL_2_INV		= false			-- RH DOOR NOT UPLOCK DATA FAIL
GRETIN_1			= false			-- L/G RETRACTION INHIBIT
GRETIN_1_INV		= false			-- L/G RETRACTION INHIBIT DATA FAIL
GRETIN_2			= false			-- L/G RETRACTION INHIBIT
GRETIN_2_INV		= false			-- L/G RETRACTION INHIBIT DATA FAIL
GRGDL_1             = false         -- RH GEAR DOWN LOCK
GRGDL_2             = false         -- RH GEAR DOWN LOCK
GRGE				= false			-- RH GEAR EXTEND
GRGLUP				= false			-- RH GEAR LOCKED UP
GRGNLDSD_1			= false			-- RH GEAR NOT LOCK DOWN AND SELECT DOWN
GRGNLDSD_2			= false			-- RH GEAR NOT LOCK DOWN AND SELECT DOWN
GRGNLUP_1			= false 		-- NOSE GEAR NOT LOCK UP
GRGNLUP_2			= false 		-- NOSE GEAR NOT LOCK UPHGPPBOF
GRGNLUPNSD_1		= false			-- RH GEAR NOT LOCK UP AND NOT SELECT DOWN
GRGNLUPNSD_2		= false			-- RH GEAR NOT LOCK UP AND NOT SELECT DOWN
GRGNOE_1			= false			-- RH GEAR NOT EXTEND
GRGNOE_2			= false			-- RH GEAR NOT EXTEND
GRGUWGD_1			= false			-- RH GEAR UPLOCK WITH GEAR DOWN LOCK
GRGUWGD_2			= false			-- RH GEAR UPLOCK WITH GEAR DOWN LOCK
GRLGC_1				= false			-- RH L/G COMPRESSED
GRLGC_2				= false			-- RH L/G COMPRESSED
GRLGNOLK			= false			-- RH L/G NOT LKD
GSAF				= false			-- SHOCK ABSORBER FAULT
GW1SGT_1			= false			-- WHEEL 1 SPEED GREATER THAN 70 KTS
GW1SGT_2			= false			-- WHEEL 1 SPEED GREATER THAN 70 KTS
GW2SGT_1			= false			-- WHEEL 1 SPEED GREATER THAN 70 KTS
GW2SGT_2			= false			-- WHEEL 1 SPEED GREATER THAN 70 KTS

HBEPLP				= false			-- BLUE ELEC PUMP LO PR
HBEPOF				= false			-- BLUE ELEC PUMP OFF
HBEPPBOF			= false			-- BLUE ELEC PUMP P/B OFF
HBGLP				= false			-- HYD G+B LO PR
HBRLAP				= false			-- BLUE RSVR LO AIR PR			TODO-INPUT
HBRLL				= false			-- BLUE RSVR LO LEVEL
HBROVHT				= false			-- BLUE RSVR OVHT				TODO-INPUT
HBRQ				= 0				-- BLUE RSVR QTY
HBRQLO				= false			-- BLUE RSVR QTY < 5 L
HBRT				= 0				-- BLUE RSVR TEMP				TODO-INPUT
HBRTUP				= false			-- BLUE RSVR TEMP > 98 DEG.C	TODO 1918
HBSLP				= false			-- BLUE SYS LO PR
HBSYSLP				= false			-- BLUE SYS ABNORM LO PR
HBYLP				= false			-- HYD B+Y LO PR
HGBLP				= false 		-- G+B LO PR
HGPLP				= false			-- GREEN ENG PUMP LO PR
HGPPBOF				= false			-- GREEN ENG PUMP P/B OFF
HGPWSFOP			= false			-- GPWS FLAP OFF PROC
HGRLAP				= false			-- GREEN RSVR LO AIR PR			TODO-INPUT
HGRLL				= false			-- GREEN RSVR LO LEVEL
HGROVHT				= false			-- GREEN RSVR OVHT				TODO-INPUT
HGRQ				= 0				-- GREEN RSVR QTY
HGRQLO				= false			-- GREEN RSVR QTY < 8 L
HGRT				= 0				-- GREEN RSVR TEMP				TODO-INPUT
HGRTUP				= false			-- GREEN RSVR TEMP > 98 DEG.C	TODO 1918
HGSLP				= false			-- GREEN SYS LO PR
HGSYSLP				= false			-- GREEN SYS ABNORM LO PR
HNVMBEPF			= false			-- NVM BLUE ELEC PUMP FAIL						-- A320 = HNVMBPF
HNVMBPF				= false			-- NVM BLUE ENG 1 PUMP FAIL
HNVMG1PF			= false			-- NVM GREEN ENG 1 PUMP FAIL					-- A320 = HNVMGPF
HNVMG2PF			= false			-- NVM GREEN ENG 2 PUMP FAIL
HNVMGEPF			= false			-- NVM GREEN ELEC PUMP FAIL
HNVMYEPF			= false			-- NVM YELLOW ELEC PUMP FAIL
HNVMYPF				= false			-- NVM YELLOW ENG 2 PUMP FAIL
HPRATPBOF			= false			-- HYD RAT P/B OFF
HRATNFS				= false			-- RAT NOT FULLY STOWED
HTHOUT				= false			-- TWO HYD OUT
HYEPPBON			= false			-- YELLOW ELEC PUMP P/B ON
HYEPON				= false			-- YELLOW ELEC PUMP ON
HYGLP				= false			-- HYD G+Y LO PR
HYPLP				= false			-- YELLOW ENG PUMP LO PR
HYPPBOF				= false			-- YELLOW ENG PUMP P/B OFF
HYRLAP				= false			-- YELLOW RSVR LO AIR PR		TODO-INPUT
HYRLL				= false			-- YELLOW RSVR LO LEVEL
HYROVHT				= false			-- YELLOW RSVR OVHT				TODO-INPUT
HYRQ				= 0				-- YELLOW RSVR QTY
HYRQLO				= false			-- YELLOW RSVR QTY < 5 L
HYRT				= 0				-- YELLOW RSVR TEMP				TODO-INPUT
HYRTUP				= false			-- YELLOW RSVR TEMP > 98 DEG.C	TODO 1918
HYSLP				= false			-- YELLOW SYS LO PR
HYSYSLP				= false			-- YELLOW SYS ABNORM LO PR

IE1AIPBON			= false			-- ENG1 ANTI ICE P/B ON
IE1AIVF				= false			-- ENG1 ANTI ICE VALVE FAULT
IE1ID				= false			-- ENG1 ICE DETECTED
IE1IDF				= false			-- ENG1 ICE DETECTION FAULT
IE1NVNO				= false			-- ENG 1 NAC VALVE NOT OPEN
IE2AIPBON			= false			-- ENG2 ANTI ICE P/B ON
IE2AIVF				= false			-- ENG2 ANTI ICE VALVE FAULT
IE2ID				= false 		-- ENG2 ICE DETECTED
IE2IDF				= false			-- ENG1 ICE DETECTION FAULT
ILVCLSDF			= false			-- L VALVE CLOSED FAULT
ILWAILP				= false			-- RH WING ANTI ICE LO PR
ILWAIVC				= false			-- LH WING ANTI ICE VALVE CLOSED
IPROCWAIESD			= false			-- PROC WAI ENG SHUT DOWN
IRVCLSDF			= false			-- R VALVE CLOSED FAULT
IRWAILP				= false			-- LH WING ANTI ICE LO PR
IRWAIVC				= false			-- RH WING ANTI ICE VALVE CLOSED
IWAIAIC				= false			-- WAI AVOID ICING CONDITIONS
IWAIC				= false			-- WING AVOID ICING CONDITIONS
IWAIE				= false			-- WAI ETOPS
IWAION				= false			-- WING ANTI ICE ON
IWAIPBON			= false			-- WING ANTI ICE P/B ON
IXBAIC				= false			-- X BLEED AVOID ICING COND







JEFLEX 				= false			-- CFM FLEX

JENGSOUT			= false			-- ENGINES OUT RRT
JENGSOUTR			= false			-- ENGINES OUT RRT

JIFLEX				= false			-- IAE FLEX

JML1OFF				= false			-- ENG 1 MASTER LEVER SELECT OFF
JML1ON				= false			-- ENG 1 MASTER LEVER SELECT ON
JML1ON_INV			= false			-- ENG 1 MASTER LEVER DATA FAILURE
JML1ON_VAL			= true			-- ENG 1 MASTER LEVER SELECT VALID SIGNAL
JML2OFF				= false			-- ENG 2 MASTER LEVER SELECT OFF
JML2ON				= false			-- ENG 2 MASTER LEVER SELECT ON
JML2ON_INV			= false			-- ENG 2 MASTER LEVER DATA FAILURE
JML2ON_VAL			= true			-- ENG 2 MASTER LEVER SELECT VALID SIGNAL

JR1OT 				= 0				-- ENG1 OIL TEMP
JR1OT_INV 			= false			-- ENG1 OIL TEMP DATA FAILURE
JR1OT_NCD 			= false			-- ENG1 OIL TEMP DATA OUT-OF-RANGE
JR1AIDLE_1A			= false 		-- ENG 1 ABOVE IDLE
JR1AIDLE_1A_INV		= false 		-- ENG 1 ABOVE IDLE DATA FAIL
JR1AIDLE_1B			= false 		-- ENG 1 ABOVE IDLE
JR1AIDLE_1B_INV		= false 		-- ENG 1 ABOVE IDLE DATA FAIL
JR1AUTOST_1A		= false			-- ENG1 MAN START ACTIVE
JR1AUTOST_1B		= false			-- ENG1 MAN START ACTIVE
JR1CMDREV_1A        = false         -- ENG1 CMD REVERSE
JR1CMDREV_1B        = false         -- ENG1 CMD REVERSE
JR1CONTIGN_1A		= false			-- ENG1 CONT IGN
JR1CONTIGN_1B		= false			-- ENG1 CONT IGN
JR1DTOSEL			= false		 	-- ENG 1 DERATE TO SELECTED *
JR1DTOSELI			= false		 	-- ENG 1 DTO SELECTED *
JR1ESI 				= false			-- IGNITION SELECTED
JR1FAIL				= false			-- ENG 1 FAIL
JR1FTOMD			= false			-- ENG 1 FTO MODE *
JR1FXMOD			= false			-- ENG 1 FLEX MODE
JR1HGST_1A			= false			-- ENG1 HUNG START
JR1HGST_1B			= false			-- ENG1 HUNG START
JR1IDLE_1A			= false			-- ENG1 SET TO IDLE
JR1IDLE_1B			= false			-- ENG1 SET TO IDLE
JR1IFT				= false			-- ENG 1 IGN FAULT
JRIGNSEL 			= false			-- ENG IGN SEL
JR1MANST_1A			= false			-- ENG1 MAN START ACTIVE
JR1MANST_1B			= false			-- ENG1 MAN START ACTIVE
JR1MINPWR_1A		= false			-- ENG1 MIN POWER
JR1MINPWR_1A_VAL	= true			-- ENG1 MIN POWER VALID
JR1MINPWR_1B		= false			-- ENG1 MIN POWER
JR1MINPWR_1B_VAL	= true			-- ENG1 MIN POWER VALID
JR1N1_1A			= 0				-- ENG 1 N1 *
JR1N1_1A_INV		= false			-- ENG 1 N1 DATA FAIL *
JR1N1_1A_NCD		= false			-- ENG 1 N1 DATA OUT-OF-RANGE *
JR1N1_1A_VAL		= true			-- ENG 1 N1 DATA VALID
JR1N1_1B			= 0				-- ENG 1 N1 *
JR1N1_1B_INV		= false			-- ENG 1 N1 DATA FAIL *
JR1N1_1B_NCD		= false			-- ENG 1 N1 DATA OUT-OF-RANGE *
JR1N1_1B_VAL		= true			-- ENG 1 N1 DATA VALID
JR1NORUN			= false			-- ENG 1 NOT RUNNING *
JR1OLP				= false		 	-- ENG 1 OIL LO PR
JR1OOT				= false			-- ENG 1 OIL OVERTEMP
JR1OOT_1			= 0				-- ENG 1 OIL OVERTEMP
JR1OOT_1_INV		= false			-- ENG 1 OIL OVERTEMP DATA FAIL
JR1OOT_1_NCD		= false			-- ENG 1 OIL OVERTEMP DATA OUT-OF-RANGE
JR1OOT_2			= 0				-- ENG 1 OIL OVERTEMP
JR1OOT_2_INV		= false			-- ENG 1 OIL OVERTEMP DATA FAIL
JR1OOT_2_NCD		= false			-- ENG 1 OIL OVERTEMP DATA OUT-OF-RANGE
JR1OT				= 0				-- ENG 1 OIL TEMP
JR1OT_INV			= false			-- ENG 1 OIL TEMP DATA FAILURE
JR1OT_NCD			= false			-- ENG 1 OIL TEMP DATA OUT-OF-RANGE
JR1OTAD_1			= 0				-- ENG 1 OIL TEMP ADVISORY
JR1OTAD_1_INV		= false			-- ENG 1 OIL TEMP ADVISORY DATA FAILURE
JR1OTAD_1_NCD		= false			-- ENG 1 OIL TEMP ADVISORY DATA OUT-OF-RANGE
JR1OTAD_2			= 0				-- ENG 1 OIL TEMP ADVISORY
JR1OTAD_2_INV		= false			-- ENG 1 OIL TEMP ADVISORY DATA FAILURE
JR1OTAD_2_NCD		= false			-- ENG 1 OIL TEMP ADVISORY DATA OUT-OF-RANGE
JR1OTAD				= false			-- ENG 1 OIL TEMP ADV

JR1REVD_1A			= false			-- ENG 1 REV DEPLOYED
JR1REVD_1B			= false			-- ENG 1 REV DEPLOYED
JR1REVKO			= false			-- ENG 1 REVERSER FAULT
JR1REVULK			= false			-- ENG 1 REVERSE  UNLK
JR1REVUNL_1A		= false			-- ENG1 REV UNLOCKED
JR1REVUNL_1B		= false			-- ENG1 REV UNLOCKED
JR1REVUNLK			= false			-- ENG 1 REVERSE UNLOCKED
JR1RUSTWD			= false			-- ENG 1 REVERSE UNSTOWED
JR1SD				= false			-- ENG 1 SHUT DOWN
JR1START			= false			-- ENG 1 START
JR1SUPMCT			= false			-- ENG 1 SUP MCT RR TRENT *
JR1TGMD				= false			-- ENG 1 TOGA MODE *
JR1TLA_1A			= 0				-- ENG 1 TLA *
JR1TLA_1A_INV		= false			-- ENG 1 TLA DATA FAILURE *
JR1TLA_1A_NCD		= false			-- ENG 1 TLA DATA OUT-OF-RANGE *
JR1TLA_1A_VAL		= true			-- ENG 1 TLA VALID *
JR1TLA_1B			= 0				-- ENG 1 TLA *
JR1TLA_1B_INV		= false			-- ENG 1 TLA DATA FAILURE *
JR1TLA_1B_NCD		= false			-- ENG 1 TLA DATA OUT-OF-RANGE *
JR1TLA_1B_VAL		= true			-- ENG 1 TLA VALID *
JR1TLACL			= false			-- ENG 1 TLA CL
JR1TLADISC			= false			-- ENG 1 TLA DISCREPANCY
JR1TLAFF			= false			-- ENG 1 TLA FAULT FLIGHT
JR1TLAFG			= false			-- ENG 2 TLA FAULT GROUND
JR1TLAI				= false			-- ENG 1 TLA IDLE
JR1TLAKO			= false			-- ENG 1 TLA FAULT
JR1TLAMCT			= false			-- ENG 1 TLA MCT RR TRENT *
JR1TLFPWR			= false			-- ENG 1 TLA FULL PWR RR TRENT *
JR1TLREV			= false			-- ENG 1 TLA REVERSE RR TRENT *
JR1TLASCL			= false			-- ENG 1 TLA SUP CL
JR1TOFF				= false			-- ENG 1 T.O RR TRENT *
JR1TRMDB19_1A		= false			-- ENG 1 TR MODE IDLE SELECTED *
JR1TRMDB20_1A		= false			-- ENG 1 TR MODE MAX CLIMB SELECTED *
JR1TRMDB21_1A		= false			-- ENG 1 TR MODE FLEX TAKE OFF SELECTED *
JR1TRMDB19_1B		= false			-- ENG 2 TR MODE IDLE SELECTED *
JR1TRMDB20_1B		= false			-- ENG 2 TR MODE MAX CLIMB SELECTED *
JR1TRMDB21_1B		= false			-- ENG 2 TR MODE FLEX TAKE OFF SELECTED *

JR2OT 				= 0				-- ENG2 OIL TEMP
JR2OT_INV 			= false			-- ENG2 OIL TEMP DATA FAILURE
JR2OT_NCD 			= false			-- ENG2 OIL TEMP DATA OUT-OF-RANGE
JR2AIDLE_2A			= false 		-- ENG 2 ABOVE IDLE
JR2AIDLE_2A_INV		= false 		-- ENG 2 ABOVE IDLE DATA FAIL
JR2AIDLE_2B			= false 		-- ENG 2 ABOVE IDLE
JR2AIDLE_2B_INV		= false 		-- ENG 2 ABOVE IDLE DATA FAIL
JR2AUTOST_1A		= false			-- ENG2 MAN START ACTIVE
JR2AUTOST_1B		= false			-- ENG2 MAN START ACTIVE
JR2CMDREV_2A        = false         -- ENG2 CMD REV REVERSE
JR2CMDREV_2B        = false         -- ENG2 CMD REV REVERSE
JR2CONTIGN_2A		= false			-- ENG1 CONT IGN
JR2CONTIGN_2B		= false			-- ENG1 CONT IGN
JR2DTOSEL			= false		 	-- ENG 2 DERATE TO SELECTED *
JR2DTOSELI			= false		 	-- ENG 1 DTO SELECTED *
JR2ESI				= false			-- IGNITION SELECTED
JR2FAIL				= false			-- ENG 2 FAIL
JR2FTOMD			= false		 	-- ENG 2 FTO MODE *
JR2FXMOD			= false		 	-- ENG 2 FLEX MODE
JR2HGST_2A			= false			-- ENG 2 HUNG START
JR2HGST_2B			= false			-- ENG 2 HUNG START
JR2IDLE_2A			= false			-- ENG1 SET TO IDLE
JR2IDLE_2B			= false			-- ENG1 SET TO IDLE
JR2IFT				= false			-- ENG 2 IGN FAULT
JR2MANST_1A			= false			-- ENG1 MAN START ACTIVE
JR2MANST_1B			= false			-- ENG1 MAN START ACTIVE
JR2MINPWR_2A		= false			-- ENG2 MIN POWER
JR2MINPWR_2A_VAL	= true			-- ENG2 MIN POWER VALID
JR2MINPWR_2B		= false			-- ENG2 MIN POWER
JR2MINPWR_2B_VAL	= true			-- ENG2 MIN POWER VALID
JR2N1_2A			= 0		 		-- ENG 2 N1 *
JR2N1_2A_INV		= false			-- ENG 2 N1 DATA FAIL *
JR2N1_2A_NCD		= false			-- ENG 2 N1 DATA OUT-OF-RANGE *
JR2N1_2A_VAL		= true			-- ENG 2 N1 DATA VALID
JR2N1_2B			= 0		 		-- ENG 2 N1 *
JR2N1_2B_INV		= false			-- ENG 2 N1 DATA FAIL *
JR2N1_2B_NCD		= false			-- ENG 2 N1 DATA OUT-OF-RANGE *
JR2N1_2B_VAL		= true			-- ENG 2 N1 DATA VALID
JR2NORUN			= false			-- ENG 2 NOT RUNNING *
JR2OLP				= false		 	-- ENG 2 OIL LO PR
JR2OOT				= false			-- ENG 2 OIL OVERTEMP
JR2OOT_1			= 0				-- ENG 2 OIL OVERTEMP
JR2OOT_1_INV		= false			-- ENG 2 OIL OVERTEMP DATA FAIL
JR2OOT_1_NCD		= false			-- ENG 2 OIL OVERTEMP DATA OUT-OF-RANGE
JR2OOT_2			= 0				-- ENG 2 OIL OVERTEMP
JR2OOT_2_INV		= false			-- ENG 2 OIL OVERTEMP DATA FAIL
JR2OOT_2_NCD		= false			-- ENG 2 OIL OVERTEMP DATA OUT-OF-RANGE
JR2OT				= 0				-- ENG 2 OIL TEMP
JR2OT_INV			= false			-- ENG 2 OIL TEMP DATA FAILURE
JR2OT_NCD			= false			-- ENG 2 OIL TEMP DATA OUT-OF-RANGE
JR2OTAD_1			= 0				-- ENG 2 OIL TEMP ADVISORY
JR2OTAD_1_INV		= false			-- ENG 2 OIL TEMP ADVISORY DATA FAILURE
JR2OTAD_1_NCD		= false			-- ENG 2 OIL TEMP ADVISORY DATA OUT-OF-RANGE
JR2OTAD_2			= 0				-- ENG 2 OIL TEMP ADVISORY
JR2OTAD_2_INV		= false			-- ENG 2 OIL TEMP ADVISORY DATA FAILURE
JR2OTAD_2_NCD		= false			-- ENG 1 OIL TEMP ADVISORY DATA OUT-OF-RANGE
JR2OTAD				= false			-- ENG 2 OIL TEMP ADV
JR2REVD_2A			= false			-- ENG 2 REV DEPLOYED
JR2REVD_2B			= false			-- ENG 2 REV DEPLOYED
JR2REVKO			= false			-- ENG 2 REVERSER FAULT
JR2REVULK			= false			-- ENG 2 REVERSE UNLK
JR2REVUNL_2A		= false			-- ENG 2 REV UNLOCKED
JR2REVUNL_2B		= false			-- ENG 2 REV UNLOCKED
JR2REVUNLK			= false			-- ENG 2 REVERSE UNLOCKED
JR2RUSTWD			= false			-- ENG 2 REVERSE UNSTOWED
JR2SD				= false			-- ENG 2 SHUT DOWN
JR2START			= false			-- ENG 2 START
JR2SUPMCT			= false			-- ENG 2 SUP MCT RR TRENT *
JR2TGMD				= false		 	-- ENG 2 TOGA MODE *
JR2TLA_2A			= 0 			-- ENG 2 TLA *
JR2TLA_2A_INV		= false			-- ENG 2 TLA DATA FAILURE *
JR2TLA_2A_NCD		= false			-- ENG 2 TLA DATA OUT-OF-RANGE *
JR2TLA_2A_VAL		= true			-- ENG 2 TLA VALID *
JR2TLA_2B			= 0				-- ENG 2 TLA *
JR2TLA_2B_INV		= false			-- ENG 2 TLA DATA FAILURE *
JR2TLA_2B_NCD		= false			-- ENG 2 TLA DATA OUT-OF-RANGE *
JR2TLA_2B_VAL		= true			-- ENG 2 TLA VALID *
JR2TLACL			= true			-- ENG 2 TLA CL
JR2TLADISC			= false			-- ENG 2 TLA DISCREPANCY
JR2TLAFF			= false			-- ENG 2 TLA FAULT FLIGHT
JR2TLAFG			= false			-- ENG 2 TLA FAULT GROUND
JR2TLAI				= false			-- ENG 2 TLA IDLE
JR2TLAKO			= false			-- ENG 2 TLA FAULT
JR2TLAMCT			= false			-- ENG 2 TLA MCT RR TRENT *
JR2TLFPWR			= false			-- ENG 2 TLA FULL PWR RR TRENT *
JR2TLREV			= false			-- ENG 2 TLA REVERSE RR TRENT *
JR2TLASCL			= false			-- ENG 2 TLA SUP CL
JR2TOFF				= false			-- ENG 2 T.O RR TRENT *
JR2TRMDB19_2A		= false			-- ENG2 TR MODE IDLE SELECTED *
JR2TRMDB20_2A		= false			-- ENG2 TR MODE MAX CLIMB SELECTED *
JR2TRMDB21_2A		= false			-- ENG2 TR MODE FLEX TAKE OFF SELECTED *
JR2TRMDB19_2B		= false			-- ENG2 TR MODE IDLE SELECTED *
JR2TRMDB20_2B		= false			-- ENG2 TR MODE MAX CLIMB SELECTED *
JR2TRMDB21_2B		= false			-- ENG2 TR MODE FLEX TAKE OFF SELECTED *

JR12IDLE			= false			-- ENG 1+2 IDLE
JR12MCL				= false			-- ENG 1+2 MCL *

JRDTOFINST_1A		= false			-- ENG1 DERATE TO FUNCTION INSTALLED *
JRDTOFINST_1B		= false			-- ENG1 DERATE TO FUNCTION INSTALLED *
JRDTOFINST_2A		= false			-- ENG2 DERATE TO FUNCTION INSTALLED *
JRDTOFINST_2B		= false			-- ENG2 DERATE TO FUNCTION INSTALLED *
JRDTOI				= false			-- DTO IAE INSTALLED *
JRDTOSEL_1A			= false			-- ENG 1 DERATE TO SELECTED *
JRDTOSEL_1B			= false			-- ENG 1 DERATE TO SELECTED *
JRDTOSEL_2A			= false			-- ENG 2 DERATE TO SELECTED *
JRDTOSEL_2B			= false			-- ENG 2 DERATE TO SELECTED *
JRFLEX				= false			-- RR TRENT FLEX
JRN1AP				= false			-- N1 APPROACH
JRTOGA				= false			-- RETARD TOGA
JTCASTANS			= false			-- TCAS TA NOT SELECTED
JTLAINH				= false			-- TLA INHIBITION
JTML1ON 			= false			-- ENG1 MASTER LEVER SELECT ON
JTML2ON 			= false			-- ENG2 MASTER LEVER SELECT ON
JTOGA				= false			-- TOGA
JTOGAIN				= false			-- TOGA INHIBITION

KAP1E				= false			-- AP 1 ENGD
KAP1EC_1			= false			-- AP1 ENGD COM
KAP1EM_1			= false			-- AP1 ENGD MON
KAP2E				= false			-- AP2 ENGD
KAP2EC_2			= false			-- AP2 ENGD COM
KAP2EM_2			= false			-- AP2 ENGD MON
KAPMW				= false			-- AP MW
KAPOA				= false			-- AP OFF AUDIO
KAPOMW				= false			-- AP OFF MW
KAPOR				= false			-- AP OFF RESET
KAPUNVOFF			= false			-- AP UNVOL OFF
KATHRE				= false			-- A/THR ENGAGED
KCCE				= false			-- CAVALRY CHARGE EMITTED
KFACNOH_1			= false			-- FAC1 NO HEALTHY
KFACNOH_2			= false			-- FAC2 NO HEALTHY
KFCU1H              = true          -- FCU1 HEALTHY
KFCU2H              = true          -- FCU2 HEALTHY
KID1APE				= false			-- INSTINC DISCNCT 1AP ENGD
KID2APE				= false			-- INSTINC DISCNCT 2AP ENGD
KLONRJ_1			= false			-- LO ENERGY
KLONRJ_2			= false			-- LO ENERGY
KLTRKM_1			= false			-- LAND TRK MODE ON
KLTRKM_2			= false			-- LAND TRK MODE ON
KOAPE				= false   		-- ONE AP ENGD
KRTLLC_1			= true 			-- RTL LOG COM
KRTP_1				= 0				-- RUDDER TRIM POSITION
KRTP_1_INV			= false			-- RUDDER TRIM POSITION DATA FAILURE
KRTP_1_NCD			= false			-- RUDDER TRIM POSITION DATA OUT-OF-RANGE
KRTP_2				= 0				-- RUDDER TRIM POSITION
KRTP_2_INV			= false			-- RUDDER TRIM POSITION DATA FAILURE
KRTP_2_NCD			= false			-- RUDDER TRIM POSITION DATA OUT-OF-RANGE
KRUDLC_1			= true			-- RUD LOG COM
KSPEEDGEN       	= false			-- SPEED GENERATED
KWINDSD_1			= false			-- WINDSHEAR DETECTION
KWINDSD_2			= false			-- WINDSHEAR DETECTION
KWINDSDV_1			= true			-- WINDSHEAR DETECTION VALID
KWINDSDV_2			= true			-- WINDSHEAR DETECTION VALID
KWINDSGEN			= false			-- WINDSHEAR GENERATED
KYAWLC_1			= true			-- YAW LOG COM

LSLPBOF				= false			-- STROBE LIGHTS P/B OFF

NA005				= false			-- AUDIO 05
NA010				= false			-- AUDIO 10
NA020				= false			-- AUDIO 20
NA030				= false			-- AUDIO 30
NA040				= false			-- AUDIO 40
NA050				= false			-- AUDIO 50
NACOINIB			= true			-- AUTO CALL OUT INHIB
NALTBD              = false         -- ALTI BARO DISCREPANCY
NALTFBK_1           = 0             -- ALTITUDE FEEDBACK
NALTFBK_1_INV       = false         -- ALTITUDE FEEDBACK
NALTFBK_1_NCD       = false         -- ALTITUDE FEEDBACK
NALTFBK_2           = 0             -- ALTITUDE FEEDBACK
NALTFBK_2_INV       = false         -- ALTITUDE FEEDBACK
NALTFBK_2_NCD       = false         -- ALTITUDE FEEDBACK
NALTI_1             = 0             -- ALTITUDE
NALTI_1_INV         = false         -- ALTITUDE DATA FAILURE
NALTI_1_NCD         = false         -- ALTITUDE DATA OUT-OF-RANGE
NALTI_2             = 0             -- ALTITUDE
NALTI_2_INV         = false         -- ALTITUDE DATA FAILURE
NALTI_2_NCD         = false         -- ALTITUDE DATA OUT-OF-RANGE
NALTI_3             = 0             -- ALTITUDE
NALTI_3_INV         = false         -- ALTITUDE DATA FAILURE
NALTI_3_NCD         = false         -- ALTITUDE DATA OUT-OF-RANGE
NALTSTDD            = false         -- ALTI STD DISCREPANCY
NAPPRAL				= false			-- APPR PROC ALTN LAW
NASS184 			= false			-- NS SUP 184
NASS190 			= false			-- NS SUP 190
NASS200 			= false			-- NS SUP 200
NASS204 			= false			-- NS SUP 200
NASS209 			= false			-- NS SUP 204
NASS219 			= false			-- NS SUP 219
NASS244 			= false			-- NS SUP 244
NASS250 			= false			-- NS SUP 250
NATEST				= false			-- ALPHA TEST
NBAROSEL1           = false         -- BARO SELECTION
NBAROSEL2           = false         -- BARO SELECTION
NBAROSEL3           = false         -- BARO SELECTION
NBAROSEL4           = false         -- BARO SELECTION
NBRQ20_1            = false         -- BARO REF CODING BIT 11
NBRQ20_2            = false         -- BARO REF CODING BIT 11
NBRQ21_1            = false         -- BARO REF CODING BIT 12
NBRQ21_1_VAL        = true         -- BARO REF CODING BIT 12 DATA VALID
NBRQ21_1_NCD        = false         -- BARO REF CODING BIT 12 DATA OUT-OF-RANGE
NBRQ21_2            = false         -- BARO REF CODING BIT 12
NBRQ21_2_VAL        = true         -- BARO REF CODING BIT 12 DATA VALID
NBRQ21_2_NCD        = false         -- BARO REF CODING BIT 12 DATA OUT-OF-RANGE
NCAS_1				= 0				-- COMPUTED SPEED 1
NCAS_1_INV			= false			-- CAPTAIN AIRSPEED INDICATOR FAILURE
NCAS_1_NCD			= false			-- CAPTAIN AIRSPEED INDICATOR DATA OUT-OF-RANGE
NCAS_1_FT			= true			-- FUNCTIONAL TEST
NCAS_2				= 0				-- COMPUTED SPEED 2
NCAS_2_INV			= false			-- F/O AIRSPEED INDICATOR FAILURE
NCAS_2_NCD			= false			-- F/O AIRSPEED INDICATOR DATA OUT-OF-RANGE
NCAS_2_FT			= true			-- FUNCTIONAL TEST
NCAS_3				= 0				-- COMPUTED SPEED 3
NCAS_3_INV			= false			-- STBY AIRSPEED INDICATOR FAILURE
NCAS_3_NCD			= false			-- STBY AIRSPEED INDICATOR DATA OUT-OF-RANGE
NCAS_3_FT			= true			-- FUNCTIONAL TEST
NCBAC_1             = 0             -- CAPT BARO ALTI CORRECTED
NCBAC_1_INV			= false			-- CAPT BARO ALTI CORRECTED FAILURE
NCBAC_1_NCD			= false			-- CAPT BARO ALTI CORRECTED DATA OUT-OF-RANGE
NDHGEN				= false			-- DH GENERATED
NDHHABOVE			= false			-- DH HUNDRED ABOVE
NDHINHIB			= false			-- DH INHIBITION
NDHPO				= false			-- DH POSITIVE
NDHV				= 0				-- DECISION HEIGHT VAL
NDINV				= false			-- NDINV
NDMCLQFE            = false         -- DMC L QFE
NDMCLQNH            = false         -- DMC L QNH
NDMCLS              = false         -- DMC L STD
NDMCRQFE            = false         -- DMC R QFE
NDMCRQNH            = false         -- DMC R QNH
NDMCRS              = false         -- DMC R STD
NFFMSLDG3           = false         -- FMS LANDING CONFIG FLAP SELECTION
NFOBAC_2            = 0             -- F/O BARO ALTI CORRECTED
NFOBAC_2_INV			= false			-- F/O BARO ALTI CORRECTED FAILURE
NFOBAC_2_NCD			= false			-- F/O BARO ALTI CORRECTED DATA OUT-OF-RANGE
NFPBLDG3			= false			-- GPWS FLAPS P/B IN LDG CONFIG 3  -- for A333 see NFFMSLDGCFG3
NGPWSFMOF			= false			-- GPWS FLAP MODE P/B OFF
NGPWSINHIB			= false			-- GPWS INHIBITION
NGPWSM				= false			-- GPWS MODES ON
NGSVA				= false			-- G/S VISUAL ALERT ON
NHIE3				= false			-- ALT INF 3 FT
NH5					= false			-- ALT 5 FT
NHI10				= false			-- ALT INF 10 FT
NH10				= false			-- ALT 10 FT
NHI20				= false			-- ALT INF 20 FT
NH20				= false			-- ALT 20 FT
NH30				= false			-- ALT 30 FT
NH40				= false			-- ALT 40 FT
NH50				= false			-- ALT 50 FT
NHS50				= false			-- ALT SUP 50 FT
NH100				= false			-- ALT 100 FT
NH200				= false			-- ALT 200 FT
NH300				= false			-- ALT 300 FT
NH400				= false			-- ALT 400 FT
NHSE410				= false			-- ALT SUP 410 FT
NHUNABGEN			= false			-- HUNDRED ABOVE GENERATED
NMINGEN				= false 		-- MINIMUM GENERATED
NRADH_1				= 0				-- CAPTAIN RADIO ALTIMETER (FEET)
NRADH_1_APPR      	= nil			-- 3 & 10 NM USER SELECTED APPROACH
NRADH_1_INV			= false			-- CAPTAIN RADIO ALTIMETER FAILURE
NRADH_1_NCD			= false			-- CAPTAIN RADIO ALTIMETER DATA OUT-OF-RANGE
NRADH_1_FT			= false			-- CAPTAIN RADIO ALTIMETER FUNCTIONAL TEST
NRADH_1_VAL			= true			-- CAPTAIN RADIO ALTIMETER DATA VALID
NRADH_2	 			= 0				-- F/O RADIO ALTIMETER (FEET)
NRADH_2_APPR      	= nil			-- 3 & 10 NM USER SELECTED APPROACH
NRADH_2_INV 		= false			-- F/O RADIO ALTIMETER FAILURE
NRADH_2_NCD			= false			-- F/O RADIO ALTIMETER DATA OUT-OF-RANGE
NRADH_2_FT			= false			-- F/O RADIO ALTIMETER FUNCTIONAL TEST
NRADH_2_VAL			= true			-- F/O RADIO ALTIMETER DATA VALID
NRAFT				= false			-- RA FUNCTIONAL TEST
NRAH				= 0				-- RADIO HEIGHT
NRAINV				= false			-- RA INVALID
NRANCD				= false			-- RA NO COMPUTED DATA
NRDINH				= false			-- RETARD INHIBITION
NRENV1				= false 		-- REFERENCE 1
NRENV2				= false			-- REFERENCE 2
NRENV3				= false			-- REFERENCE 3
NRETINIB			= false			-- RETARD INHIB
NRHV				= 0	 			-- RADIO HEIGHT VAL
NS005				= false			-- THRESHOLD 5 FT
NS010				= false			-- THRESHOLD 10 FT
NS020				= false			-- THRESHOLD 20 FT
NS030				= false			-- THRESHOLD 30 FT
NS040				= false			-- THRESHOLD 40 FT
NS050				= false			-- THRESHOLD 50 FT
NS100				= false			-- THRESHOLD 100 FT
NS200				= false			-- THRESHOLD 200 FT
NS300				= false			-- THRESHOLD 300 FT
NS400				= false			-- THRESHOLD 400 FT
NS500				= false			-- THRESHOLD 500 FT
NS1000				= false			-- THRESHOLD 1000 FT
NS2000				= false			-- THRESHOLD 2000 FT
NS2500B				= false			-- THRESHOLD 2500B FT
NS2500				= false			-- THRESHOLD 2500 FT
NSFCONF3NS			= false			-- S/F CONF3 NOT SELECTED
NSLTIB				= false			-- SLATS INF B
NSPDO				= false			-- SPEED ON
NSTALL1				= false			-- ALPHA 1 STALL
NSTALLW				= false			-- STALL WARN
NSTALLWO			= false			-- STALL WARN ON
NTCASINIB			= false			-- TCAS AURAL ADVISORY OUTPUT
NTHDEC				= false			-- THRESHOLD DETECTION
NTOAGD				= false			-- T.O AND GROUND DETECTION
NVFE1				= false 		-- VFE 1
NVFE2				= false 		-- VFE 2
NVFE3				= false 		-- VFE 3
NVFE4				= false 		-- VFE 4
NVFE5				= false 		-- VFE 5
NVFE6				= false 		-- VFE 6
NVMOW_1				= false			-- OVERSPEED WARNING
NVMOW_1_FT			= false			-- OVERSPEED WARNING FUNCTIONAL TEST
NVMOW_1_INV			= false			-- OVERSPEED WARNING FAILURE
NVMOW_2				= false			-- OVERSPEED WARNING
NVMOW_2_FT			= false			-- OVERSPEED WARNING FUNCTIONAL TEST
NVMOW_2_INV			= false			-- OVERSPEED WARNING FAILURE
NVMOW_3				= false			-- OVERSPEED WARNING
NVMOW_3_FT			= false			-- OVERSPEED WARNING FUNCTIONAL TEST
NVMOW_3_INV			= false			-- OVERSPEED WARNING FAILURE

PALTI				= false			-- ALTITUDE
PAS12F 				= false			-- AUTO SYS1+2 FAULT
PEXCA_1				= false			-- EXCESSIVE CAB ALT
PEXCA_2				= false			-- EXCESSIVE CAB ALT
PEXCA_3				= false			-- EXCESSIVE CAB ALT
PLESM_1				= false			-- LDG ELEV SELECTOR MANUAL
PLESM_2				= false			-- LDG ELEV SELECTOR MANUAL
PS1F_1				= false			-- PNEU SYS1 FAIL
PS1F_1_INV			= false			-- PNEU SYS1 FAIL SIGNAL FAILURE
PS2F_2				= false			-- PNEU SYS2 FAIL
PS2F_2_INV			= false			-- PNEU SYS2 FAIL SIGNAL FAILURE
PSCPR				= false			-- SEC CAB PR

QAVAIL				= false			-- APU AVAIL
QBLEED				= false			-- APU BLEED ON
QMSON				= false			-- APU MASTER SW P/B ON

SALLGSSI            = false         -- ALL GND SPLRS INOP
SASPDBRK			= false			-- AMBER SPD BRK
SCSSF_1 			= false			-- CAPT SIDE STICK INOP
SCSSF_1_INV 		= false			-- CAPT SIDE STICK INOP INV
SCSSF_1_NCD 		= false			-- CAPT SIDE STICK INOP NCD
SCSSF_2 			= false			-- CAPT SIDE STICK INOP
SDUALSSI			= false			-- DUAL SIDE STICK INPUT
SE1F				= false			-- ELAC 1 FAULT
SE2F				= false			-- ELAC 2 FAULT
SFCLA				= false			-- FLT CTL LAND ASAP
SFLPDSLTC			= false			-- FLAP D SLAT C
SFLPFY				= false			-- FLAPS FAULTY
SFLPIA				= false			-- FLAPS 1 (8˚)
SFLPINOP			= false			-- FLAPS INOP
SFLPLCKD			= false			-- FLAPS LOCKED
SFLPNTO				= false			-- FLAPS NOT T.O.
SFLPSB				= false			-- FLAPS
SFLPSC				= false			-- FLAPS
SFLPSD				= false			-- FLAPS
SFLPSE				= false			-- FLAPS
SFLPSF				= false			-- FLAPS
SFLPVAL				= true			-- FLAP VALID
SFOSSF_1			= false			-- F/O SIDE STICK INOP
SFOSSF_2			= false			-- F/O SIDE STICK INOP
SGNDSPLRA_1			= false			-- GROUND SPOILER ARMED
SGNDSPLRA_2			= false			-- GROUND SPOILER ARMED
SLELNA				= false			-- L ELEV NOT AVAIL
SLELVBA_1			= false			-- LH ELEV B AVAIL 1
SLELVBA_1_VAL		= false			-- LH ELEV B AVAIL 1
SLELVBA_2			= false			-- LH ELEV B AVAIL 1
SLELVBA_2_VAL		= false			-- LH ELEV B AVAIL 1
SLELVGA_1			= false			-- LH ELEV G AVAIL 2
SLELVGA_1_VAL		= false			-- LH ELEV G AVAIL 2
SLELVGA_2			= false			-- LH ELEV G AVAIL 2
SLELVGA_2_VAL		= false			-- LH ELEV G AVAIL 2
SLFLPPOS			= 0				-- LEFT WING FLAP POSITION
SLFLPPOS_NCD		= false			-- LEFT WING FLAP POS DATA OUT-OF-RANGE
SLFLPPOS_VAL		= true			-- LEFT WING FLAP POS VALID
SLRELVFT			= false			-- L+R ELEV FAULT
SLSLTPOS			= 0				-- LEFT WING SLAT1 POSITION
SLSLTPOS_NCD		= false			-- LEFT WING SLAT1 POS DATA OUT-OF-RANGE
SLSLTPOS_VAL		= true			-- LEFT WING SLAT1 POS VALID
SLSLTPOS_INV		= false			-- LEFT WING SLAT1 POS INVALID
SSLTC 				= false			-- SLAT C POS
SPBUL				= false			-- PITCH BACK UP LAW
SPCCMD_1			= 0				-- PITCH CAPT CMD POS
SPCCMD_1_INV		= false			-- PITCH CAPT CMD INV
SPCCMD_1_NCD		= false			-- PITCH CAPT CMD NCD
SPCCMD_2			= 0				-- PITCH CAPT CMD POS
SPCCMD_2_INV		= false			-- PITCH CAPT CMD INV
SPCCMD_2_NCD		= false			-- PITCH CAPT CMD NCD
SPCT1A330			= false			-- PITCH CONFIG 1 A330
SPCT2A330			= false			-- PITCH CONFIG 1 A330
SPFOCMD_1			= 0				-- PITCH F/O CMD POS
SPFOCMD_1_INV		= false			-- PITCH F/O CMD INV
SPFOCMD_1_NCD		= false			-- PITCH F/O CMD NCD
SPFOCMD_2			= 0				-- PITCH F/O CMD POS
SPFOCMD_2_INV		= false			-- PITCH F/O CMD INV
SPFOCMD_2_NCD		= false			-- PITCH F/O CMD NCD
SPTNTO				= false			-- PITCH TRIM NOT T.O.
SRCCMD_1			= 0				-- ROLL CAPT CMD POS
SRCCMD_1_INV		= false			-- ROLL CAPT CMD INV
SRCCMD_1_NCD		= false			-- ROLL CAPT CMD NCD
SRCCMD_2			= 0				-- ROLL CAPT CMD POS
SRCCMD_2_INV		= false			-- ROLL CAPT CMD INV
SRCCMD_2_NCD		= false			-- ROLL CAPT CMD NCD
SRELVBA_1			= false			-- RH ELEV B AVAIL 1
SRELVBA_1_VAL		= false			-- RH ELEV B AVAIL 1
SRELVBA_2			= false			-- RH ELEV B AVAIL 1
SRELVBA_2_VAL		= false			-- RH ELEV B AVAIL 1
SRELVYA_1			= false			-- RH ELEV Y AVAIL 2
SRELVYA_1_VAL		= false			-- RH ELEV Y AVAIL 2
SRELVYA_2			= false			-- RH ELEV Y AVAIL 2
SRELVYA_2_VAL		= false			-- RH ELEV Y AVAIL 2
SRFLPPOS			= 0				-- RIGHT WING FLAP POSITION
SRFLPPOS_NCD		= false			-- LEFT WING FLAP POS DATA OUT-OF-RANGE
SRFLPPOS_VAL		= true			-- LEFT WING FLAP POS VALID
SRFOCMD_1			= 0				-- ROLL F/O CMD POS
SRFOCMD_1_INV		= false			-- ROLL F/O CMD INV
SRFOCMD_1_NCD		= false			-- ROLL F/O CMD NCD
SRFOCMD_2			= 0				-- ROLL F/O CMD POS
SRFOCMD_2_INV		= false			-- ROLL F/O CMD INV
SRFOCMD_2_NCD		= false			-- ROLL F/O CMD NCD
SRSLTPOS			= 0				-- RIGHT WING SLAT1 POSITION
SRSLTPOS_NCD		= false			-- RIGHT WING SLAT1 POS DATA OUT-OF-RANGE
SRSLTPOS_VAL		= true			-- RIGHT WING SLAT1 POS VALID
SRSLTPOS_INV		= false			-- RIGHT WING SLAT1 POS INVALID
SRUDTC				= false			-- RUD TRIM CONFIG
SRUDTNTO			= false			-- RUD TRIM NOT T.O.
SS00F00_1 = false			-- S/F SELECTED S0/F0
SS0F0_1_INV			= false			-- S/F SELECTED S0/F0 DATA FAILURE
SS0F0_1_NCD			= false			-- S/F SELECTED S0/F0 DATA OUT-OF-RANGE
SS00F00_2 = false			-- S/F SELECTED S0/F0
SS0F0_2_INV			= false			-- S/F SELECTED S0/F0 DATA FAILURE
SS0F0_2_NCD			= false			-- S/F SELECTED S0/F0 DATA OUT-OF-RANGE
SS1FT				= false			-- SEC 1 FAULT
SS2FT				= false			-- SEC 2 FAULT
SS16F08_1			= false			-- S/F SELECTED S16/8
SS16F08_2			= false			-- S/F SELECTED S16/8
SS20F14_1			= false			-- S/F SELECTED S20/14
SS20F14_2			= false			-- S/F SELECTED S20/14
SS23F22_1			= false			-- S/F SELECTED S23/22
SS23F22_2			= false			-- S/F SELECTED S23/22
SS23F32_1			= false			-- S/F SELECTED S23/32
SS23F32_2			= false			-- S/F SELECTED S23/32
SSBNTO				= false			-- SPEED BRK NOT T.O.
SSLTFY              = false         -- SLATS FAULTY
SSLTID				= false			-- SLATS POS
SSLTIE				= false			-- SLATS POS
SSLTNTO				= false			-- SLATS NOT T.O.
SSLTSA				= false			-- SLATS POS
--SSLTSB				= false			-- SLATS POS
SSLTSC				= false			-- SLATS POS
--SSLTSD				= false			-- SLATS POS
--SSLTSE				= false			-- SLATS POS
SSLTSF				= false			-- SLATS POS
SSLTSG				= false			-- SLATS POS
SSLTVAL				= true			-- SLAT VALID
SSPBR_1				= false			-- SPEEDBRAKE COMMAND
SSPBR_2				= false			-- SPEEDBRAKE COMMAND
SSPDBRKC			= false			-- SPD BRK CAUTION
SSTTO				= false			-- SIDESTICK TO
STAB1POS_1			= 0				-- STABILIZER 1 POS
STAB1POS_1_INV		= false			-- STABILIZER 1 POS DATA FAILURE
STAB1POS_1_NCD		= false			-- STABILIZER 1 POS DATA OUT-OF-RANGE
STAB1POS_2			= 0				-- STABILIZER 1 POS
STAB1POS_2_INV		= false			-- STABILIZER 1 POS DATA FAILURE
STAB1POS_2_NCD		= false			-- STABILIZER 1 POS DATA OUT-OF-RANGE
STHSJAM				= false			-- THS JAM
STHSJAMEC_1			= false			-- T.H.S MECH JAM
STHSJAMEC_2			= false			-- T.H.S MECH JAM

UACSDI				= false			-- AFT CARGO SMOKE DET INSTALLED
UACSDI_1			= false			-- AFT CARGO SMOKE DET INSTALLED
UACSDI_2			= false			-- AFT CARGO SMOKE DET INSTALLED
UAPUELP				= false			-- APU FIRE EXTING LO PR
UAPUFA				= false			-- APU FIRE-CH A
UAPUFB				= false			-- APU FIRE-CH B
UAPUFPBOUT			= false			-- UAPUFPBOUT
UAPUFIRE			= false			-- APU FIRE
UAPULAF				= false			-- APU LOOP A INOP
UAPULBF				= false			-- APU LOOP B INOP
UCB1LP_1			= false			-- CARGO BTL 1 LO PR
UCB1LP_2			= false			-- CARGO BTL 1 LO PR
UE1ABLP				= false			-- ENG 1 BOTTLE 2 LO PR
UE1FBLP				= false			-- ENG 1 BOTTLE 1 LO PR
UE1FPBOUT			= false			-- ENG 1 FIRE P/B OUT
UE1FA               = false         -- ENG 1 FIRE-CH A
UE1FB               = false         -- ENG 1 FIRE-CH B
UE1FIRE				= false			-- ENG 1 FIRE
UE1LAF				= false			-- ENG 1 LOOP A INOP
UE1LBF				= false			-- ENG 1 LOOP B INOP
UE2ABLP         	= false			-- ENG 2 BOTTLE 2 LO PR
UE2FBLP         	= false			-- ENG 2 BOTTLE 1 LO PR
UE2FIRE				= false			-- ENG 2 FIRE
UE2LAF				= false			-- ENG 2 LOOP A INOP
UE2LBF				= false			-- ENG 2 LOOP B INOP
UE2FPBOUT			= false			-- ENG 2 FIRE P/B OUT
UE2FA               = false         -- ENG 2 FIRE-CH A
UE2FB               = false         -- ENG 2 FIRE-CH B
UFCSDI				= false			-- FWD CARGO SMOKE DET INSTALLED
UFCSDI_1			= false			-- FWD CARGO SMOKE DET INSTALLED
UFCSDI_2			= false			-- FWD CARGO SMOKE DET INSTALLED
UFEB1I_1			= false			-- FIRE EXT BTL 1 INSTALLED
UFEB1I_2			= false			-- FIRE EXT BTL 1 INSTALLED
UFEB2I_1			= false			-- FIRE EXT BTL 2 INSTALLED
UFEB2I_2			= false			-- FIRE EXT BTL 2 INSTALLED
UG1LPBOF			= false			-- GEN1 LINE P/B OFF
USALC_1				= false			-- SMOKE AFT LOWER CARGO
USALC_2				= false			-- SMOKE AFT LOWER CARGO
USFLC_1				= false			-- SMOKE FWD LOWER CARGO
USFLC_2				= false			-- SMOKE FWD LOWER CARGO
USKD				= false			-- SMOKE DETECTED

VACDNIVFC			= false			-- AFT CARGO DOWNSTREAM ISOL VALVE FC
VACIVPBOF			= false			-- FWD CARGO ISOL VALVEP/B OFF
VACUPIVFC			= false			-- FWD CARGO UPSTREAM ISOL VALVE FC
VAVEF				= false			-- AVIONICS VENT EXTRACT FAULT
VAVEPBO				= false			-- AVIONICS VENT EXTRACT P/B OVRD
VFCDNIVFC			= false			-- FWD CARGO DOWNSTREAM ISOL VALVE FC
VFCIVPBOF			= false			-- FWD CARGO ISOL VALVEP/B OFF
VFCUPIVFC			= false			-- FWD CARGO UPSTREAM ISOL VALVE FC


W10RETARD			= false			-- TEN RETARD
W20RETARD			= false			-- TWENTY RETARD
WA330				= true			-- A330 A/C
WAC5				= true			-- AUTO CALL OUT 5 FT		SET THESE TO ENABLE THE CALLOUT AUDIO
WAC10				= true			-- AUTO CALL OUT 10 FT						"
WAC20				= true			-- AUTO CALL OUT 20 FT						"
WAC30				= true			-- AUTO CALL OUT 30 FT						"
WAC40				= true			-- AUTO CALL OUT 40 FT						"
WAC50				= true			-- AUTO CALL OUT 50 FT						"
WAC100				= true			-- AUTO CALL OUT 100 FT						"
WAC200				= true			-- AUTO CALL OUT 200 FT						"
WAC300				= true			-- AUTO CALL OUT 300 FT						"
WAC400				= true			-- AUTO CALL OUT 400 FT						"
WAC500				= true			-- AUTO CALL OUT 500 FT						"
WAC500C				= false			-- AUTO CALL OUT 500C FT					"
WAC1000				= true			-- AUTO CALL OUT 1000 FT					"
WAC2000				= true			-- AUTO CALL OUT 2000 FT					"
WAC2500B			= false			-- AUTO CALL OUT 2500B FT					"
WAC2500				= true			-- AUTO CALL OUT 2500 FT					"
WACO5				= false			-- ACO 5
WACO10				= false			-- ACO 10
WACO20				= false			-- ACO 20
WACO30				= false			-- ACO 30
WACO40				= false			-- ACO 40
WACO50				= false			-- ACO 50
WACO100				= false			-- ACO 100
WACO200				= false			-- ACO 200
WACO300				= false			-- ACO 300
WALL                = false         -- ECP-ALL
WALL_2              = false         -- ALL
WAPOT				= false			-- AP OFF TEXT
WAPU                = false         -- ECP-APU
WAPU_2              = false         -- APU
WATSUINS            = true          -- ATSU INSTALLED
WBLD                = false         -- ECP-BLEED
WBLD_2              = false         -- BLEED
WBRACSW				= false			-- RED ARROW ON L/G CTL LEVER SELECTOR ON
WRACSW_S			= false			-- RED ARROW ON L/G CTL LEV SEL STEADY ON
WBSTALL				= false			-- STALL ON
WSDUALI				= true			-- DUAL-INPUT INSTALLED
WSTALL_S			= false			-- STALL STEADY ON
WCABNR				= true			-- CABIN NOT READY
WCABR				= false			-- CABIN READY
WCB                 = false         -- ECP-CIRCUIT BREAKERS
WCB_2               = false         -- C/B
WCHFDR1I            = false         -- HFDR1 INSTALLED
WCHFDR2I            = false         -- HFDR2 INSTALLED
WCLR                = false         -- ECP-CLEAR
WCLR1_2             = false         -- CLR 1
WCLR2_2             = false         -- CLR 2
WCMWC 				= false			-- CAPT MW CANCEL ON
WCMCC 				= false			-- CAPT MC CANCEL ON
WCOND               = false         -- ECP-CONDITIONING
WCOND_2             = false         -- COND
WDH_1				= 0				-- DECISION HEIGHT (PILOT)
WDH_1_INV			= false			-- DECISION HEIGHT DATA FAILURE (PILOT)
WDH_1_NCD   		= false			-- DECISION HEIGHT DATA OUT-OF-RANGE (PILOT)
WDH_1_VAL           = false         -- DECISION HEIGHT VALID
WDH_2				= 0				-- DECISION HEIGHT (COPILOT)
WDH_2_INV			= false			-- DECISION HEIGHT DATA FAILURE (COPILOT)
WDH_2_NCD   		= false			-- DECISION HEIGHT DATA OUT-OF-RANGE (COPILOT)
WDH_2_VAL           = false         -- DECISION HEIGHT VALID
WDHA 				= false			-- DECISION HEIGHT CODE A
WDHB 				= false			-- DECISION HEIGHT CODE B
WDH100A				= false			-- DECISION HEIGHT + 100 FT CODE A
WDH100B				= false			-- DECISION HEIGHT + 100 FT CODE B
WDH2SELEC			= false			-- DH2 SELEC
WDHGENERATED		= false			-- DH GENERATED
WDHINF3FT			= false			-- DH INF 3FT
WDHMTRIG			= false			-- DH MTRIG
WDHPOSITIVE			= false			-- DH POSITIVE
WDOOR               = false         -- ECP-DOOR
WDOOR_2             = false         -- DOOR
WE1OHT				= false			-- ENG 1 OIL HI TEMP
WE2OHT				= false			-- ENG 2 OIL HI TEMP
WEC_2               = false         -- EMER CANC
WELAC               = false         -- ECP-ELECTRIC A/C
WELAC_2             = false         -- EL/AC
WELDC               = false         -- ECP-ELECTRIC D/C
WELDC_2             = false         -- EL/DC
WEMERC              = false         -- ECP-EMER CANCEL ON
WEMERC_2            = false         -- EMER CANC
WENA330EMERC		= false			-- NEW A320 ELECTRICAL EMER CONFIG
WENG                = false         -- ECP-ENGINE
WENG_2              = false         -- ENG
WETOPS				= false			-- ETOPS
WFCTL               = false         -- ECP-FLIGHT CONTROLS
WFCTL_2             = false         -- F/CTL
WFOMCC 				= false			-- F/O MC CANCEL ON
WFOMWC 				= false			-- F/O MW CANCEL ON
WFUEL               = false         -- ECP-FUEL
WFUEL_2             = false         -- FUEL
WHAGENERATED		= false			-- HA GENERATED
WHACOMP				= false			-- HA COMPUTED
WHAMTRIG			= false			-- HA MTRIG
WHYD                = false         -- ECP-HYDRAULIC
WHYD_2              = false         -- HYD
WIDID				= true			-- ICE DETECTOR INSTALLED
WJTOGA				= false			-- CALCUL TOGA
WMBE				= false			-- ELEC MODIF APPLIED
WMTRGPWS			= false			-- MTRIG GPWS
WNCMLI				= false			-- NEW CABIN MEMO LOGIC
WPREC100			= false			-- PREC 100
WPREC200			= false			-- PREC 200
WPREC300			= false			-- PREC 300
WPRESS              = false         -- ECP-PRESSURE
WPRESS_2            = false         -- PRESS
WPULSE30			= false			-- PULSE 30
WPULSE40			= false			-- PULSE 40
WRA1INV				= false			-- RA 1 INV
WRCL                = false         -- ECP-RECALL
WRCL_INV            = false         -- ECP-RECALL INV
WRCL_2              = false         -- RCL
WRCL_2_INV          = false         -- RCL INV
WRENVOI1			= false			-- REFERENCE 1 INHIB
WRENVOI2			= false			-- REFERENCE 2 INHIB
WRETARD				= false			-- RETARD
WRETTOGA			= false			-- CAL RET TOGA
WRETINHIB			= false			-- RETARD INHIB
WRRT				= true			-- RR TRENT INSTALLED
WSDACF				= false			-- SDAC FAULT
WSFLPLVRNOT0		= true			-- FLAP LVR NOT ZERO OPTION INSTALLED
WSORMT				= false			-- SORTIE MTRIG
WSTO				= false			-- STALL ON
WSTS				= false			-- ECP-STATUS
WSTS_2				= false			-- STS
WTOCNORM			= false			-- T.O. CONFIG NORMAL
WTOCT               = false         -- TO CONFIG TEST
WTOCT_2             = false         -- ECP TO CONFIG
WVLE				= false			-- VLE OVERSPEED
WVMOMMO				= false			-- VMO/MMO OVERSPEED
WWALTBD             = false         -- ALTI BARO DISCREPANCY
WWALTSTDD           = false         -- ALTI STD DISCREPANCY
WWAPOFW				= false			-- AP OFF WARNING
WWAPUFI				= false			-- APU FIRE
WWE1FI				= false			-- ENG 1 FIRE
WWE2FI				= false			-- ENG 2 FIRE
WWHL                = false         -- ECP-WHEEL
WWHL_2              = false         -- WHEEL
WWINDSDON			= false			-- WINDSHEAR ON
WWKCCE				= false			-- CAVALRY CHARGE EMITTED
WWLRELVFT			= false			-- L+R ELEV FAULT
WWSNTOC				= false			-- SURF NOT IN TO CONFIG

XAACGHT				= false			-- AFT CARGO HEATING INSTALLED
XAACGVENT			= false			-- AFT CARGO VENT INSTALLED
XAFCGHT				= false			-- FWD CARGO HEATING INSTALLED
XAFCGVENT			= false			-- FORWARD CARGO VENT INSTALLED
XCNOPEDINS			= true			-- NO PORTABLE DEVICES SW INSTALLED

ZACS80KT			= false			-- A/C SPEED > 80 KT
ZADCTI				= false			-- ADC TEST INHIB
ZALLUP 				= false         -- ALL PULSE UP
ZAPSTSC				= false			-- APPR PROC STATUS COMPUTED
ZAPUUP 				= false         -- APU PULSE UP
ZASTSPD				= false			-- AUTO STATUS PAGE DISPLAYED
ZBLDUP 				= false         -- BLEED PULSE UP
ZCBUP 				= false         -- C/B PULSE UP
ZCCSTSC				= false			-- CANCELLED CAUTION STATUS COMPUTED
ZCLRUP              = false         -- CLR PULSE UP
ZCMEMC				= false			-- CONFIG MEMO COMPUTED
ZCMEMD				= false			-- CONFIG MEMO DISPLAYED
ZCONUP 				= false         -- COND PULSE UP
ZDORUP 				= false         -- DOOR PULSE UP
ZECDN               = false         -- EMER CANC PULSE DN
ZECUP               = false         -- EMER CANC PULSE UP
ZELAUP 				= false         -- EL/AC PULSE UP
ZELDUP 				= false         -- EL/DC PULSE UP
ZENGUP              = false         -- ENG PULSE UP
ZFCLRSTS			= false			-- FWC CLEAR STS
ZFCLUP 				= false         -- F/CTL PULSE UP
ZFPION              = false         -- FLIGHT PHASE INHIB OVRD
ZFULUP 				= false         -- FUEL PULSE UP
ZGND				= false			-- GROUND
ZGNDI				= false			-- GROUND IMMEDIATE
ZGNDRU				= false			-- GROUND REV UNLOCKED
ZH1500FT			= false			-- RADIO ALT > 1500 FT
ZH800FT				= false			-- RADIO ALT > 800 FT
ZHFAIL				= false			-- RADIO ALT FAIL
ZHYDUP 				= false         -- HYD PULSE DNJ
ZISTSC				= false			-- INOP SYS STATUS COMPUTED
ZLAPR				= false			-- LAND ASAP RED
ZLDGMEM             = false         -- LDFG MEMO
ZLG12INV			= false			-- LGCIU 1/2 INV
ZLMEMD				= false			-- LEFT MEMO DISPLAYED
ZLSTSC				= false			-- LIMITATION STATUS COMPUTED
ZMCCANUP			= false			-- MC CANCEL PULSE UP
ZMSTSC				= false			-- MAINTENANCE STATUS COMPUTED
ZMSTSPD				= false			-- MANUAL STATUS PAGE DISPLAYED
ZMWCANUP			= false			-- MW CANCEL PULSE UP
ZNMLSTSPD			= false			-- 'NORMAL' STATUS  PAGE DISPLAY
ZNEWGND				= false			-- NEW GROUND
ZNOSTSREM			= false			-- NO STS REMINDER
ZOERG				= false			-- ONE ENG RUNNING
ZPH0				= false			-- PHASE 0 *
ZPH1				= false			-- PHASE 1
ZPH2				= false			-- PHASE 2
ZPH3				= false			-- PHASE 3
ZPH4				= false			-- PHASE 4
ZPH5				= false			-- PHASE 5
ZPH6				= false			-- PHASE 6
ZPH7				= false			-- PHASE 7
ZPH8				= false			-- PHASE 8
ZPH9				= false			-- PHASE 9
ZPH10				= false			-- PHASE 10
ZPRSUP 				= false         -- PRESS PULSE UP
ZPSTSC				= false			-- PROC STATUS COMPUTED
ZR1O2RUN			= false			-- ENG 1 OR 2 RUNNING *
ZR1O2TOPWR			= false			-- ENG 1 OR 2 TO PWR *
ZR12NORUN			= false 		-- ENG 1 AND 2 NOT RUNNING *
ZRCLUP              = false         -- RCL PULSE UP
ZRCLDN              = false         -- RCL PULSE DN
ZRMEMD				= false			-- RIGHT MEMO DISPLAYED
ZSINGDIS			= false			-- SINGLE DISPLAY
ZSTSCAPPR			= false			-- STS CALL IN APPR
ZSTSDN              = false         -- STS PULSE DN
ZSTSOEBPC			= false			-- STATUS OEB PROC COMPUTED
ZSTSPD				= false			-- STS PAGE DISPLAYED
ZSTSREMP			= false			-- ZSTSREMP
ZSTSREMS			= false			-- STS REMINDER STEADY
ZSTSRPSD			= false 		-- STS REM PULSING IN SINGLE DISPLAY
ZSTSUP              = false         -- STS PULSE UP
ZSYSPCI				= false			-- SYS PAGE CALL INHIB
ZTOMEMC				= false			-- T.O MEMO COMPUTED
ZWHLUP 				= false         -- WHEEL PULSE UP





--*************************************************************************************--
--** 					            LOCAL VARIABLES                 				 **--
--*************************************************************************************--



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







