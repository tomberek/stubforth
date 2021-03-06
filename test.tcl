#!/usr/bin/expect

spawn ./stubforth

sleep 0.1
set timeout 0

send "decimal \n"

expect plzflushkthx
expect *

set timeout 1

proc test {tx rx} {
    send "$tx\n"

    expect \
	timeout { error timeout } \
	-re abort { error abort } \
	-re $rx
    send_user " \[OK\]\n"
}

set true {-1 $}
set false {\s0 $}
set name {stubforth [0-9a-f]+}

test "hi\n" $name

send_user "the following should abort...\n"
send "should-abort\n"
expect {
    timeout { error }
    -re abort.*
}

send ".\n"
expect {
    timeout { error }
    -re abort.*
}

test "85 1 + ." {86 $}

send "hex\n"

test "1 2 3 4 5 * + * + ." {2f $}

test "key A ." {41 $}

test "1 2 3 4 5 6 7 8 9 swap mod + * xor or swap - hex ." {32 $}

test "1 2 3 4 5 6 7 8 9 << >> << swap / ." {99 $}

test "1234 2345 max 9999 min 11 + ." {2356 $}

test "55 emit 1234 2345 dup = 30 + emit = 30 + emit " {U10$}
test "55 emit 1234 2345 swap dup < 30 + emit < 30 + emit " {U01$}
test "55 emit 8 2345 dup dup and 0= 30 + emit and 0= 30 + emit " {U01$}

send "decimal : testsuite-marker 85 emit ;\n"
test "testsuite-marker" {U$}

send "decimal : ifelsethen 85 emit if 64 emit else 65 emit then 85 emit ;\n"

test "1 ifelsethen" U@U
test "0 ifelsethen" UAU

send ": fib dup 0= if else dup 1 = if else 1 - dup recurse swap 1 - recurse + then then ;\n"
test "20 fib ." 6765

send ": gcd dup if tuck mod recurse else drop then ;\n"

test "decimal 11111 12341 gcd ." {41 $}

send "hex\n"

send ": tloop begin 1 - dup 8 < if exit then again ;\n"
test "100 tloop ." {7 $}

send ": tuntil begin 1 - dup 197 < until ;\n"
test " 999 tuntil ." {196 $}

send "decimal\n"

send ": twhile 85 emit begin 64 emit 1 - dup 10 > while 65 emit repeat 85 emit ;\n"
test "16 twhile" {U@A@A@A@A@A@U$}

send "hex\n"

test "variable foo F6F 1 + foo ! foo ?" {f70 $}
test "2ff 1 + constant foo foo ." {300 $}

test "word fubar type" {fubar$}

send "0 variable scratch 10 allot\n"
test "scratch 10 55 fill scratch 8 + c@ 11 + ." {66 $}

test "8 base c! 777 1 + ." {1000 $}
send "decimal "

test "word \[ find drop immediatep ." $true
test "word : find drop immediatep ." $false

test "' hi execute" $name
test {: foo ['] hi execute ; foo} $name

test " -3 3- * ." {9 $}
test " -3 3 * ." {-9 $}

send ": foo 666 throw ; "
send {: bar ['] foo catch 666 = if 85 emit else 65 then ; }
test bar {U$}

test ": foo 99 13 /mod . . ; foo" {7 8 $}

test "create foo 66 ,  foo @ 2 * . ;" {132 $}

send ": cst <builds , does> @ ;\n"
test "666 cst moo moo 1+ ." {667 $}

test ": t 7 8 2dup . . . . ; t" {8 7 8 7 $}
test ": t 1 2 3 4 2over . . . . . . ; t" {2 1 4 3 2 1 $}
test ": t 1 2 3 4 2swap . . . . ; t" {2 1 4 3 $}

send "abort\n" ;
expect -re abort.*

test "depth 1 2 3 666 5 .s" {#6 0 1 2 3 666 5}

send ": w2345678 ;\n"
test "here word w2345678 find drop drop here = ." {1 $}

test {" fox" " quick brown " type type} {quick brown fox$}
test {: t ," lazy dog" ," jumps over the " type type ; t} {jumps over the lazy dog$}

test {decimal : t 85 emit ." moo" 85 emit ; t} {UmooU$}

test {: t 1 if ." moo" else ." bar" then ; t} {moo$}

send {: t case 0 of ." looks like zero" endof 1 of ." looks like one" endof 2 of ." looks like two" endof ." i dunno" endcase lf ; }

test "4 t" {i dunno}
test "1 t" {looks like one}

send ": t postpone if ; immediate\n"
test {: t2 1 t ." moo" else ." bar" then ; t2} {moo$}

send ": t postpone hi ; immediate\n"
test {: t2 t ; t2} $name

test { " foo" " barz" compare .} {1 $}
test { " 999" " ba" compare .} {-1 $}
test { " hmm" " hmm" compare .} {0 $}

test { here " foo" drop" here = .} {1 $}

# send {here }
# test { 1 [if] 85 emit bl [else] 64 emit bl [then] } {U $}
# test { 0 [if] 85 emit bl [else] 64 emit bl [then] } {@ $}
# test { here = . } { 1$}

test {: t 85 emit try 666 throw catch> 1+ . endtry 64 emit ; t } {U667 @$}
test {: t 125 try 666 1 throw catch> drop endtry 1+ . ; t } {126 $}
test {: t 125 try 666 catch> drop endtry 1+ . ; t } {667 $}

test {.( moo)} {moo}

test { " asdf" " moo" over 3 move type } {moof$}

test { 64 1 putchar call 85 1 putchar call } {@U$}

test { " 667 1 + 0 redirect ! " redirect ! . } {668 $}
test { " 668 1 + . " evaluate } {669 $}

test { : x ?dup if 65 emit 1- restart then ; 666 4 64 emit x 85 emit . } {@AAAAU666 $}

test { -2 666 u< . } {0 $}
test { -2 666 < . } {1 $}
test { -2 666 u> -1 666 > <> 0<> . } {1 $}

# send " : within ( n1|u1 n2|u2 n3|u3 -- flag )  over - >r - r> u< ; "

test {  0  0  0  within . } {0 $}
test {  2  6  5  within . } {1 $}
test {  2  6  2  within . } {0 $}
test {  2  6  6  within . } {0 $}
test { -6 -2 -4  within . } {1 $}
test { -2 -6 -4  within . } {0 $}
test { -6 -2 -2  within . } {0 $}
test { -6 -2 -6  within . } {0 $}
test { -1  2  1  within . } {1 $}
test { -1  2  2  within . } {0 $}
test { -1  2 -1  within . } {0 $}
test {  0 -1  1  within . } {1 $}


test { marker oblivious  : oblivion 666 . ; oblivion } {666 $}
send { oblivious oblivion
}

expect {
    timeout { error }
    -re abort:.*$
}

test { 5 7 2constant twocon twocon twocon . . . . } {7 5 7 5 $}

test {  1 1 <> . } {0 $}

test {  1 2 3 4 3 roll . . . . } {1 4 3 2 $}
test {  1 2 3 4 0 roll . . . . } {4 3 2 1 $}

test {  variable bitfiddle
    aa bitfiddle ! bitfiddle ? }  {aa $}

test {  50 bitfiddle |! bitfiddle ?
        5a bitfiddle &! bitfiddle ?
        a5 bitfiddle &! bitfiddle ?
        aa bitfiddle ^! bitfiddle ?
        a5 bitfiddle ^! bitfiddle ?
   }  {fa 5a 0 aa f $}

test {  a0 bitfiddle |! bitfiddle ?
        55 bitfiddle ~&! bitfiddle ?
   }  {af aa $}

send "forget testsuite-marker bye\n"

interact
