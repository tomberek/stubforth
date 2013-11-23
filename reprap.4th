.( Loading reprap.4th...) lf

hex

\ stepper z
	
f gpiodr8r pd !
f gpioden pd !
f gpiodir pd !
: sz gpiodata pd f 2 << + ! ;

\ stepper x
	
f0 gpiodr8r pc !
f0 gpioden pc !
f0 gpiodir pc !
: sx 4 << gpiodata pc f0 2 << + ! ;

\ stepper y
	
f gpiodr8r pb !
f gpioden pb !
f gpiodir pb !
: sy gpiodata pb f 2 << + ! ;

\ stepper e
	
f gpiodr8r pe !
f gpioden pe !
f gpiodir pe !
: se gpiodata pe f 2 << + ! ;

\ current half-step (0..7)
variable xpos
variable ypos
variable zpos
variable epos

: halfstep ( 0..7 -- 0..16 )
	7 and
	case
		0 of 1 endof
		1 of 3 endof
		2 of 2 endof
		3 of 6 endof
		4 of 4 endof
		5 of c endof
		6 of 8 endof
		7 of 9 endof
	endcase
;

: xc xpos @ halfstep sx ;
: yc ypos @ halfstep sy ;
: zc zpos @ 7 swap - halfstep sz ;
: ec epos @ 7 swap - halfstep se ;

: off 0 sx 0 sy 0 sz 0 se ;
: on xc yc zc ec ;

: xmove ( pos -- )
	begin
		dup xpos @
		= 0= while
		dup xpos @ > if
			1 xpos +!
		else
			-1 xpos +!
		then
		xc
		9 ms
    repeat drop ;

: ymove ( pos -- )
	begin
		dup ypos @
		= 0= while
		dup ypos @ > if
			1 ypos +!
		else
			-1 ypos +!
		then
		yc
		9 ms
    repeat drop ;

: zmove ( pos -- )
	begin
		dup zpos @
		= 0= while
		dup zpos @ > if
			1 zpos +!
		else
			-1 zpos +!
		then
		zc
		10 ms
    repeat drop ;

: emove ( pos -- )
	begin
		dup epos @
		<> while
		dup epos @ > if
			1 epos +!
		else
			-1 epos +!
		then
		ec
		7 ms
    repeat drop ;

: home
	begin
	xpos @ ypos @ zpos @ + +
	while
			xpos @ if -1 xpos +! xc then
			ypos @ if -1 ypos +! yc then
			zpos @ if -1 zpos +! zc then
			10 ms
	repeat
    0 epos ! ;

: x+ 1 xpos +! xc ;
: y+ 1 ypos +! yc ;
: z+ 1 zpos +! zc ;

: 2rel ypos @ - swap xpos @ - swap ;
: 2abs abs swap abs swap ;

: mkline ( x1 y1 x2 y2 -- b dx dy )
	2dup 2>r
	3 pick * swap / - swap drop
	2r>
;

variable xline 3 cells allot
variable yline 3 cells allot
variable zline 3 cells allot
variable eline 3 cells allot

: line! ( b dx dy a -- )
	tuck ! cell+ tuck ! cell+ ! ;
	
: line@ ( a -- b dx dy )
	dup @ swap cell+ dup @ swap cell+ @ swap 2 roll ;

: leval ( b dx dy x -- y )
	* swap / + ;

: line. ( a -- )
	line@ ." line: dy=" . ." dx=" . ." b=" . lf ;

: move ( x y -- )
	2dup 2rel > if
		." constraining axis: X" lf
		0 1 1 xline line!
		xpos @ ypos @ 2swap mkline
		yline line! \ y=f(x)
	else
		." constraining axis: Y" lf
		0 1 1 yline line!
		swap ypos @ xpos @ 2swap mkline
		\ x=f(y)
		xline line!
	then
;
