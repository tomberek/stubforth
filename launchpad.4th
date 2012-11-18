hex

000 constant tmcfg
004 constant tmtamr
008 constant tmtbmr
00c constant tmctl
010 constant tmsync
018 constant tmimr
01c constant tmris
020 constant tmmis
024 constant tmicr
028 constant tmtailr
02c constant tmtbilr
030 constant tmtamatchr
034 constant tmtbmatchr
038 constant tmtapr
03c constant tmtbpr
040 constant tmtapmr
044 constant tmtbpmr
048 constant tmtar
04c constant tmtbr
050 constant tmtav
054 constant tmtbv
058 constant tmrtcpd
05c constant tmtaps
060 constant tmtbps
064 constant tmtapv
068 constant tmtbpv
fc0 constant tmpp

40030000 constant timer0
40031000 constant timer1
40032000 constant timer2
40033000 constant timer3
40034000 constant timer4
40035000 constant timer5
40036000 constant widetimer0
40037000 constant widetimer1
4004c000 constant widetimer2
4004d000 constant widetimer3
4004e000 constant widetimer4
4004f000 constant widetimer5

: red 8 << tmtbmatchr timer0 + ! ;
: green 8 << tmtbmatchr timer1 + ! ;
: blue 8 << tmtamatchr timer1 + ! ;

: col
	dup 10 >> ff and red
	dup 8 >> ff and green
	ff and blue
;

\ rcc
\ sample = 24e0540
\ default = 7803ad1
\ 00000010010011100000010101000000
\ rrrr|   ||rrrrrrrr|r|    | |rr|^moscdis
\     ^ACG|usesysdiv| |    | |  ^-ioscdis
\         ^-sysdiv  | |    | ^-oscsrc = MOSC
\            => /5  | |    ^-xtal = 16MHz
\                   | ^--pll bypass
\                   ^--pll pwrdn

hex
400fe000 constant rcc_base
7c rcc_base + constant moscctl
60 rcc_base + constant rcc
70 rcc_base + constant rcc2
10 rcc_base + constant dc1

e000e010 constant syst_csr
e000e014 constant syst_rvr
e000e018 constant syst_cvr
e000e01c constant syst_calib

e000ed14 constant ccr

decimal
400000 syst_rvr !
: ms 10 / >r tick @ begin wfi tick @ over - r@ > until r> 2drop ;
: heartbeat begin 900 ms [ hex ] 300000 col [ decimal ] 100 ms [ hex ] 000000 col again ;
