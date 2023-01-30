
		AREA	demo, CODE, READONLY
		EXPORT	__main
		EXPORT	main
		IMPORT	__scatterload
		IMPORT	number0			;importing necessary images for scoreboard
		IMPORT	number1
		IMPORT	number2
		IMPORT	number3
		IMPORT	number4
		IMPORT	number5
		IMPORT	p
		IMPORT	won
		ALIGN
		ENTRY
__main	PROC
		bl		__scatterload
		ENDP
			
main	PROC
		ldr 	r0, =0x40010000 ;base address for LCD
init	BL		start			;initialising interface
step	ldr		r7, =p1scr		;getting player 1s score to print
		PUSH	{r7}
		BL 		scrbrd
		ldr		r7, =p2scr
		PUSH	{r7}
		BL 		scrbrd
		BL		wallref			;function for ball bouncing
		BL		racket			;printing rackets
		BL		isgoal			;checking goal
		movs	r1, #1
		str		r1, [r0, #0xc]	;refresh lcd
		movs	r1, #2
		str		r1, [r0, #0xc]	;clear lcd buffer
		cmp		r2, #1			;goal register set in the isgoal func
		BEQ		init			;going back to initial position
		b		step
stop	b		stop
		ENDP

;------------------------------------------------------------------
		;initializing function to print the first interface
start	PROC
		;initial position for the ball and rackets
		ldr		r7, =p1cor
		ldr		r6, =121
		str		r6, [r7]
		ldr		r7, =p2cor
		str		r6, [r7]
		ldr		r7, =ballcor
		ldr		r6, =132
		str		r6, [r7]
		ldr		r6, =156
		str		r6, [r7, #4]
		
		;drawing player 1s bar
		ldr		r4, =121		;row register
		
p1brrow	str		r4, [r0]		;update the row register

		ldr		r5, =5			;column counter

p1brcol	str		r5, [r0, #0x4]	;update column register			
		ldr 	r6, =0xffffffff		
		str		r6, [r0, #0x8]	;write color to pixel
		adds	r5, r5, #1		;next column
		ldr		r6, =10	
		cmp		r5, r6			;check if it reached end of column of image
		bne 	p1brcol
		adds	r4, r4, #1
		ldr		r6, =151
		cmp		r4, r6			;check if it reached end of row of image
		bne		p1brrow	
		
		;drawing player 2s bar
		ldr		r4, =121		;row register
		
p2brrow	str		r4, [r0]		;update the row register

		ldr		r5, =308		;column counter

p2brcol	str		r5, [r0, #0x4]	;update column register			
		ldr 	r6, =0xffffffff		
		str		r6, [r0, #0x8]	;write color to pixel
		adds	r5, r5, #1		;next column
		ldr		r6, =313	
		cmp		r5, r6			;check if it reached end of column of image
		bne 	p2brcol
		adds	r4, r4, #1
		ldr		r6, =151
		cmp		r4, r6			;check if it reached end of row of image
		bne		p2brrow
		
		;drawing ball
		ldr		r4, =132		;row register
		
ballrow	str		r4, [r0]		;update the row register

		ldr		r5, =156		;column counter

ballcol	str		r5, [r0, #0x4]	;update column register			
		ldr 	r6, =0xffffffff		
		str		r6, [r0, #0x8]	;write color to pixel
		adds	r5, r5, #1		;next column
		ldr		r6, =164	
		cmp		r5, r6			;check if it reached end of column of image
		bne 	ballcol
		adds	r4, r4, #1
		ldr		r6, =140
		cmp		r4, r6			;check if it reached end of row of image
		bne		ballrow
		BX		LR
		
		ENDP
;-------------------------------------------------------------------------------
		;wall reflection function for reflection dynamics of the ball
wallref	PROC
		;getting ball direction
		ldr		r7, =balldir
		ldr		r6, [r7]
		ldr		r5, [r7, #4]
		ldr		r2, =-1			;reflection coefficient
		
		ldr		r7, =ballcor
		ldr		r4, [r7]		;getting ball row
		
		cmp		r4, #38			;check if it reached upper bar
		BEQ		ref
		cmp		r4, #227		;check if it reached lower bar
		BEQ		ref
		b		brow
		
ref		muls	r6, r2, r6		;reflect the ball
		
			
		
brow	str		r4, [r0]		;update the row register

		ldr		r3, [r7, #4]	;column counter

bcol	str		r3, [r0, #0x4]	;update column register			
		ldr 	r2, =0xffffffff		
		str		r2, [r0, #0x8]	;write color to pixel
		adds	r3, r3, #1		;next column
		ldr		r2, =8
		ldr		r1, [r7, #4]
		adds	r2, r2, r1
		cmp		r3, r2			;check if it reached end of column of image
		bne 	bcol
		adds	r4, r4, #1
		ldr		r2, =8
		ldr		r1, [r7]
		adds	r2, r2, r1
		cmp		r4, r2			;check if it reached end of row of image
		bne		brow	
		
		;correcting ball coordinates in case it went out of the bars
		ldr		r4, [r7]
		ldr		r3, [r7, #4]
		adds	r4, r4, r6
		adds	r3, r3, r5		
		cmp		r4, #227		;lower bar
		BGT		botcrt
		cmp		r4, #38			;upper bar
		BLT		topcrt
		b		store
botcrt	ldr		r4, =227
		b		store
topcrt	ldr		r4, =38		

store	str		r4, [r7]
		str		r3, [r7, #4]
		
		;update ball direction
		ldr		r7, =balldir
		str		r6, [r7]
		
		
		BX		LR
		ENDP
;-------------------------------------------------------------------------------
		;racket function for racket dynamics
racket	PROC
		;drawing racket 1
		ldr		r7, =p1cor
		ldr		r6, [r7]		;row counter
		ldr		r3, [r7]		;register to hold initial row
rac1row	str		r6, [r0]		;update the row register

		ldr		r5, =5			;column counter

rac1col	str		r5, [r0, #0x4]	;update column register			
		ldr 	r4, =0xffffffff		
		str		r4, [r0, #0x8]	;write color to pixel
		adds	r5, r5, #1		;next column
		ldr		r4, =10	
		cmp		r5, r4			;check if it reached end of column of image
		bne 	rac1col
		adds	r6, r6, #1
		ldr		r4, =30
		adds	r4, r4, r3
		cmp		r6, r4			;check if it reached end of row of image
		bne		rac1row			
		
		;check if the ball hit the racket
		ldr		r7, =ballcor
		ldr		r6, [r7, #4]
		cmp		r6, #10			;column of front of the racket
		bne		rac2
		ldr		r6, [r7]
		subs	r3, r3, #7		;upper end of the racket
		cmp		r6, r3			
		BLT		rac2
		adds	r4, r4, #7		;lower end of the racket
		cmp		r6, r4
		BGT		rac2
		
		;reflect the ball and update its direction
		ldr		r5, =-1			
		ldr		r7, =balldir
		ldr		r6, [r7, #4]
		muls	r6, r5, r6
		str		r6, [r7, #4]
		
		;drawing racket 2
rac2	ldr		r7, =p2cor
		ldr		r6, [r7]		;row counter
		ldr		r3, [r7]		;register to hold initial row
rac2row	str		r6, [r0]		;update the row register

		ldr		r5, =308		;column counter

rac2col	str		r5, [r0, #0x4]	;update column register			
		ldr 	r4, =0xffffffff		
		str		r4, [r0, #0x8]	;write color to pixel
		adds	r5, r5, #1		;next column
		ldr		r4, =313	
		cmp		r5, r4			;check if it reached end of column of image
		bne 	rac2col
		adds	r6, r6, #1
		ldr		r4, =30
		adds	r4, r4, r3
		cmp		r6, r4			;check if it reached end of row of image
		bne		rac2row	
		
		;check if the ball hit the racket
		ldr		r7, =ballcor
		ldr		r6, [r7, #4]
		ldr		r5, =300		;column of front of the racket
		cmp		r6, r5
		bne		ext
		ldr		r6, [r7]
		subs	r3, r3, #7		;upper end of the racket
		cmp		r6, r3
		BLT		ext
		adds	r4, r4, #7		;lower end of the racket
		cmp		r6, r4
		BGT		ext
		
		;reflect the ball and update its direction
		ldr		r5, =-1
		ldr		r7, =balldir
		ldr		r6, [r7, #4]
		muls	r6, r5, r6
		str		r6, [r7, #4]
		
		
ext		BX		LR
		ENDP
;-------------------------------------------------------------------------------
		;scoreboard function to print the scoreboard
scrbrd	PROC
		;drawing dash for scoreboard
		ldr		r4, =15			;row counter
		
strrow	str		r4, [r0]		;update the row register

		ldr		r5, =155		;column counter

strclm	str		r5, [r0, #0x4]	;update column register			
		ldr 	r6, =0xffffffff		
		str		r6, [r0, #0x8]	;write color to pixel
		adds	r5, r5, #1		;next column
		ldr		r6, =165	
		cmp		r5, r6			;check if it reached end of column of image
		bne 	strclm
		adds	r4, r4, #1
		ldr		r6, =20
		cmp		r4, r6			;check if it reached end of row of image
		bne		strrow
		
		;drawing upper bar for game area
		ldr		r4, =35			;row counter
		
upbrrow	str		r4, [r0]		;update the row register

		ldr		r5, =0			;column counter

upbrcol	str		r5, [r0, #0x4]	;update column register			
		ldr 	r6, =0xffffffff		
		str		r6, [r0, #0x8]	;write color to pixel
		adds	r5, r5, #1		;next column
		ldr		r6, =320	
		cmp		r5, r6			;check if it reached end of column of image
		bne 	upbrcol
		adds	r4, r4, #1
		ldr		r6, =38
		cmp		r4, r6			;check if it reached end of row of image
		bne		upbrrow	
		
		;drawing lower bar for game area
		ldr		r4, =235 		;row counter
		
lwbrrow	str		r4, [r0]		;update the row register

		ldr		r5, =0			;column counter

lwbrcol	str		r5, [r0, #0x4]	;update column register			
		ldr 	r6, =0xffffffff		
		str		r6, [r0, #0x8]	;write color to pixel
		adds	r5, r5, #1		;next column
		ldr		r6, =320	
		cmp		r5, r6			;check if it reached end of column of image
		bne 	lwbrcol
		adds	r4, r4, #1
		ldr		r6, =238
		cmp		r4, r6			;check if it reached end of row of image
		bne		lwbrrow	
		
		;checking which number would print to the scoreboard
		POP		{r7}			;getting address parameter
		ldr		r6, [r7]
		
		cmp		r6, #0
		BEQ		zero
		b		znext
zero	ldr		r4, =number0
		
znext	cmp		r6, #1
		BEQ		one
		b		onext
one		ldr		r4, =number1
		
onext	cmp		r6, #2
		BEQ		two
		b		twnext
two		ldr		r4, =number2

twnext	cmp		r6, #3
		BEQ		three
		b		thrnext
three	ldr		r4, =number3

thrnext	cmp		r6, #4
		BEQ		four
		b		fonext
four	ldr		r4, =number4

fonext	cmp		r6, #5
		BEQ		five
		b		print
five	ldr		r4, =number5
		
			
print	movs	r1, #0			
		movs	r2, #0		
		ldr		r1, [r7, #4]	;row counter
row		str		r1, [r0]		;update the row register

		ldr		r2, [r7, #8]	;column counter

column	str		r2, [r0, #0x4]	;update column register			
		ldr 	r3, [r4]		
		str		r3, [r0, #0x8]	;write color to pixel
		adds	r4, r4, #4		;next pixel color
		adds	r2, r2, #1		;next column
		ldr		r6, =15	
		ldr		r5, [r7, #8]
		adds	r6, r6, r5
		cmp		r2, r6			;check if it reached end of column of image
		bne 	column
		adds	r1, r1, #1
		ldr		r6, =25
		ldr		r5, [r7, #4]
		adds	r6, r6, r5
		cmp		r1, r6			;check if it reached end of row of image
		bne		row
		
		BX 		LR
			
		ENDP
;--------------------------------------------------------------------------------
		;goal function to find whether it is goal or not
isgoal	PROC
		PUSH	{LR}			;saving lr for another subroutine
		ldr		r2, =0			;reseting goal register
		
		ldr		r7, =ballcor
		ldr		r6, [r7, #4]
		ldr		r5, =320		
		cmp		r6, r5			;check if the ball reached right end of the screen
		BEQ		p1goal
		cmp		r6, #0			;check if the ball reached left end of the screen
		BEQ		p2goal
		;getting lr back if the goal didn't happen
		POP		{r4}
		mov		LR, r4
		BX 		LR
		
		;writing goal 
p2goal	ldr		r7, =p2scr
		ldr		r6, [r7]
		adds	r6, r6, #1		;adding goal
		str		r6, [r7]		;updating goal
		cmp		r6, #5			;check if player wins
		BNE		out
		
		;giving parameters to print if player wins
		ldr		r1, =number2
		ldr		r2, =120
		ldr		r3, =15
		BL		final
		b		win
		
		;writing goal
p1goal	ldr		r7, =p1scr
		ldr		r6, [r7]
		adds	r6, r6, #1		;adding goal
		str		r6, [r7]		;updating goal
		cmp		r6, #5			;check if player wins
		BNE		out
		
		;giving parameters to print if player wins
		ldr		r1, =number1
		ldr		r2, =120
		ldr		r3, =15
		BL		final
		b		win
		
		;updating goal register when there is a goal but not winner
out		ldr		r2, =1
		POP		{r4}
		mov		LR, r4
		BX		LR
		
		;other parameters for winner flag to print
win		ldr		r1, =p
		ldr		r2, =100
		ldr		r3, =15
		BL		final
		ldr		r1, =won
		ldr		r2, =135
		ldr		r3, =85
		BL		final
		movs	r1, #1
		str		r1, [r0, #0xc]	;refresh lcd
		movs	r1, #2
		str		r1, [r0, #0xc]	;clear lcd buffer
		b		stop
		
		ENDP
;----------------------------------------------------------------------
		;final drawing for the winner
final	PROC
		PUSH	{LR}			;saving lr for subroutine
		ldr		r4, =124		;row counter
		
finrow	str		r4, [r0]		;update the row register

		mov		r5, r2			;column counter

fincol	str		r5, [r0, #0x4]	;update column register			
		ldr 	r6, [r1]		
		str		r6, [r0, #0x8]	;write color to pixel
		adds	r1, r1, #4
		adds	r5, r5, #1		;next column
		ldr		r6, =0
		adds	r6, r6, r2
		adds	r6, r6, r3
		cmp		r5, r6			;check if it reached end of column of image
		bne 	fincol
		adds	r4, r4, #1
		ldr		r6, =149
		cmp		r4, r6			;check if it reached end of row of image
		bne		finrow	
		
		;going back to routine
		POP		{r4}
		mov		PC, r4
		ENDP

		AREA	myData, DATA, READWRITE
		EXPORT	p1cor
		EXPORT	p2cor	
p1scr	DCD		0, 5, 135		;score of player 1
p2scr	DCD		0, 5, 170		;score of player 2
balldir	DCD		1, -1			;moving direction of the ball
ballcor	DCD		132, 156		;coordinates of the ball
p1cor	DCD		121				;coordinates of player 1
p2cor	DCD		121				;coordinates of player 2

		END

