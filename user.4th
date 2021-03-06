\ bit flipping

: flip ( c a -- ) 
  tuck c@ xor swap c! ;
: set ( c a -- )
  tuck c@ or swap c! ;
: clear ( c a -- )
  tuck c@ swap ~ and swap c! ;

hex

: ehex
  dup 4 >> f and hexchars + c@ emit
  f and hexchars + c@ emit ;

: dumpaddr ( addr n -- )
over cell begin 1-
2dup 8 * >> ff and ehex
dup 0= until
2drop ." : " ;

: dump8 ( addr n )
8 begin
2dup 0= 0= swap 0= 0= and while
2 pick c@ ehex bl
rot 1+ rot 1- rot 1-
repeat drop ;

: dump ( addr n -- )
begin dup while
dumpaddr dump8
dup 0= if exit then
bl dump8 lf repeat lf
2drop ;

: dumpraw ( addr n -- )
over + swap
begin
dup c@ emit
1 + 2dup <
until
lf ;

decimal

?word hexchars @ constant &&docon
?word hi @ constant &&enter

: buildsnothing <builds does> ;
buildsnothing doesnothing
?word doesnothing @
forget buildsnothing
constant &&dodoes

variable somevar
?word somevar @
forget somevar
constant &&dovar

666 42 2constant 2con ?word 2con @ forget 2con
constant &&do2con

\ xt &word -- \ throws 1 if found
: xtp1 begin 2dup >code = if 1 throw then >link @ dup 0= until ;

\ xt -- t/f \ check if xt is in the dictionary
: xtp context @ ['] xtp1 catch if 2drop 1 else 2drop 0 then ;

: xttype >word >name @ type bl ;

\ addr -- \ disassemble thread

\ check for end of thread
: eotp \ &cfa -- &cfa t/f
dup @ ['] exit =
over cell - @ ['] lit =
2 pick cell + @ xtp
or 0= and ;

\ pretty print a cell value
: .pretty ( cell -- )
  dup xtp if
    xttype
  else
    case
      &&enter of ." &&enter" endof
      &&docon of ." &&docon" endof
      &&dodoes of ." &&dodoes" endof
      &&dovar of ." &&dovar" endof
      &&do2con of ." &&do2con" endof
      ." .i = " r@ .
    endcase
  then
;

: disas
  begin dup . dup @ .pretty lf eotp 0= while
  dup @ ['] dostr = if
    cell +
    dup .
    [char] " emit
    dup type
    [char] " emit
    lf
    dup strlen + 1+ aligned
  else
    cell +
  then
repeat drop ;

: see
  ?word
  ." .code: " dup @ .pretty lf
  ." .immediate: " dup immediatep . lf
  ." .data: "
  dup cell +
  over @ case
    &&enter of lf disas endof
    &&docon of @ .pretty lf endof
    &&dovar of @ .pretty lf endof
    &&dodoes of ." does>" lf @ disas endof
    drop lf
  endcase
  2drop
; 

: octal 8 base c! ;
: binary 2 base c! ;

: do postpone swap postpone 2>r postpone begin postpone 2r@ postpone > postpone while ; immediate
: loop postpone r> postpone 1+ postpone >r postpone repeat postpone 2r> postpone 2drop ; immediate
: i postpone r@ ; immediate
