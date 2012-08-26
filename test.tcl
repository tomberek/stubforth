#!/usr/bin/expect

set tty [lindex $argv 0]
spawn -open [set port [open $tty "r+"]]

sleep 0.1
set timeout 0

send "decimal \n"

expect plzflushkthx
expect *

set timeout 1

proc test {tx rx} {
    send "$tx\n"

    expect \
	timeout { exit 1 } \
	-re abort: { exit 2 } \
	-re $rx
    send_user " \[OK\]\n"
}

test "hi\n" {stub4th [0-9a-f]+}

send_user "the following should abort...\n"
send "should-abort\n"
expect {
    timeout { exit 1 }
    -re abort:.*
}

send ".\n"
expect {
    timeout { exit 1 }
    -re abort:.*
}

test "85 ." {55 $}

send "hex\n"

test "1 2 3 4 5 * + * + ." {2f $}

test "key A ." {41 $}

test "1 2 3 4 5 6 7 8 9 swap mod + * xor or swap - hex ." {32 $}

test "1 2 3 4 5 6 7 8 9 << >> << swap / ." {99 $}

test "1234 2345 max 9999 min  ." {2345 $}

test "55 emit 1234 2345 dup = 30 + emit = 30 + emit " {U10$}
test "55 emit 1234 2345 swap dup < 30 + emit < 30 + emit " {U01$}
test "55 emit 8 2345 dup dup and 0= 30 + emit and 0= 30 + emit " {U01$}

send "decimal : foo 85 emit ;\n"
test "foo" {U$}

send "decimal : ifelsethen 85 emit if 64 emit else 65 emit then 85 emit ;\n"

test "1 ifelsethen" U@U
test "0 ifelsethen" UAU

send ": fib dup 0= if else dup 1 = if else 1 - dup recurse swap 1 - recurse + then then ;\n"
test "20 fib ." 0*1a6d

send ": tuck swap over ;\n"
send ": gcd dup if tuck mod recurse else drop then ;\n"

test "decimal 11111 12341 gcd . " {29 $}

send "hex\n"

send ": tuntil begin 1 - dup 197 < until ;\n"
test " 999 tuntil ." {196 $}

send "decimal\n"

send ": twhile 85 emit begin 64 emit 1 - dup 10 > while 65 emit repeat 85 emit ;\n"
test "16 twhile" {U@A@A@A@A@A@U$}

send "hex\n"

test "F6F 1 + variable foo foo ?" {f70 $}
test "2ff 1 + constant foo foo ." {300 $}

test "word fubar type" {fubar$}

send "0 variable scratch 10 allot\n"
test "scratch 10 55 fill scratch 8 + c@ ." {55 $}