variable radius
variable iterations
variable zoom
variable roff
variable ioff

decimal
: fix 26 << ; : unfix 26 >> ;

4 fix radius !

: fix* m* 6 << swap 26 >> 1 6 << 1 - and or ;
: fixsq dup fix* ;

: csq ( r i -- r i )
over fixsq over fixsq - >r
fix* 1 << r> swap ;

: zabs ( r i -- n )
dup 0 < if negate then swap
dup 0 < if negate then + ;

: c+ ( r i r i -- r i )
swap >r + swap r> + swap ;

: zn ( cr ci zr zi )
csq 2over c+ ;

: divp ( cr ci -- n)
0 >r 0 0 begin
zn
2dup zabs radius @ > if 2drop 2drop r> exit then
r> 1+ dup >r iterations @ > if 2drop 2drop r> drop 0 exit then
again ;

: mset
xdim 1- begin
." ."
ydim 1- begin
2dup
ydim 1 >> - zoom @ * roff @ +
swap xdim 1 >> - zoom @ * ioff @ +
divp
0= if 2dup setp then
1- dup 0= until drop
1- dup 0= until drop
;

: cell+ cell + ;
: @+dup cell+ dup @ ;


\ iterations roff ioff zoom --
: fractal <builds , , , ,
does>
 dup @ 3 fix swap / ydim / zoom ! cell +
 dup @ ioff ! cell +
 dup @ roff ! cell +
 dup @ iterations ! cell +
drop ; 

@+dup zoom

: save <builds
   lssa @ ,
does> @ lssa ! ;

: new here lssa ! 4800 allot cls ;

16 -1 fix 0 fix 1
fractal entire

60 -39817688 -33292653 4600
fractal pretty

60 -38306646 37746640 200
fractal spiral

70 -49353771 -15639236 9000
fractal deep

35 -75072314 20395872 245
fractal bolt

60 -55606285 14428028 2000
fractal dragon

100 -50162660 -9096344 700
fractal horses

100 27787769 14156046 600
fractal antenna

160 -50013170 -7587480 9500
fractal tail

100 -17343002 44280635 3000
fractal spots
