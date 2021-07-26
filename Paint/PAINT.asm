.include "m8535def.inc"
///////////////////////////////////////////
.equ CLK=0
.equ Din=1
///////////////////////////////////////////
.def Acc0=r16
.def Acc1=r17
.def SEG=r18
.def Save0=r19
.def Save1=r20
.def Seg1=r21
.def Seg2=r22
.def Seg3=r23
.def Seg4=r24
.def Acc2=r25
///////////////////////////////////////////
#define KEY  XL
#define Acc3 XH
#define Mask YL
///////////////////////////////////////////
.equ Col1=5
.equ Col2=6
.equ Col3=7
///////////////////////////////////////////
.org 0x000 
	rjmp reset
//.org 0x001
//	rjmp EXT_INT0
.org 0x008 
	rjmp TIM1_OVF
.org 0x015
///////////////////////////////////////////
reset:
///////////////////////////////////////////
	ldi Acc0, HIGH(RAMEND)
	out SPH, Acc0
	ldi Acc0, LOW(RAMEND)
	out SPL, Acc0
///////////////////////////////////////////	
	sbi DDRC,Din
	sbi DDRC,CLK
///Init timer/////////////////////////////
	ldi Acc0, (1<<CS11) | (1<<CS10)
	out TCCR1B, Acc0
	
	clr Acc0
	out TCNT1H,Acc0
	out TCNT1L,Acc0

	ldi Acc0,  (1<<TOIE1)
	out  TIMSK, Acc0
///////////////////////////////////////////
	//ldi Acc0,(1<<ISC01) | (1<<ISC00)
	//out MCUCR,Acc0

	//ldi Acc0,(1<<INT0)
	//out GICR,Acc0

	//ldi Acc0,(1<<INTF0)
	//out GIFR,Acc0
///////////////////////////////////////////
	ldi Seg4,0xFF
	ldi Seg3,0xFF
	ldi Seg2,0xFF
	ldi Seg1,0xFF
	
	ldi Acc0, 0xF0
	out DDRB, Acc0

	//sbi DDRD,2
	//cbi PORTD,2

	sbi DDRB,3
	sbi PORTB,3
	

	ldi Save0 ,0x01
	ldi SEG, 1
	ldi Acc0,0

	cbi PORTB,3
	rcall SUPERDELAY
	sbi PORTB,3

	rcall PICTURE
	rcall CHOOSE_T
	sei
///////////////////////////////////////////
LOOP:
	
	rcall KEYBOARD
	cpi Acc0,0
	breq LOOP_END
	rcall CHANGE
LOOP_END:
	rjmp LOOP
///SevSeg//////////////////////////////////
SevSeg:
	push Acc1
	push Acc0

	ldi Acc0, 8
start:
	lsl Acc1
	brcc M1
	sbi PortC, Din
	rjmp M2
M1:
	cbi PortC, Din
M2:
	cbi PortC, CLK
	nop
	nop
	sbi PortC, CLK

	dec Acc0
	brne start

	pop Acc0
	pop Acc1

	ret
////////////////////////////////////////////
CHANGE:
	cli

	cbi PORTB,3
	rcall SUPERDELAY
	sbi PORTB,3
	//rjmp END_CHANGE


	cpi Acc0,12
	breq CHANGE_INVERT_BIT
	cpi Acc0,11
	breq CHANGE_CLR_BIT
	cpi Acc0,10
	breq CHANGE_SET_BIT
	cpi Acc0,9
	breq CHANGE_INVERT_ALL
	cpi Acc0,8
	breq CHANGE_CLR_ALL
	cpi Acc0,7
	breq CHANGE_SET_ALL
	cpi Acc0,6
	breq CHANGE_RIGHT
	cpi Acc0,4
	breq CHANGE_LEFT
	cpi Acc0,3
	breq CHANGE_BACK
	cpi Acc0,1
	breq CHANGE_FOWARD
	rjmp END_CHANGE
CHANGE_INVERT_BIT:
	rcall CHOOSE_INVERT
	rcall CHOOSE_T
	rjmp END_CHANGE

CHANGE_CLR_BIT:
	rcall CHOOSE_CLR
	rcall CHOOSE_T
	rjmp END_CHANGE
		
CHANGE_SET_BIT:
	rcall CHOOSE_SET
	rcall CHOOSE_T
	rjmp END_CHANGE

CHANGE_INVERT_ALL:
	rcall INVERT_ALL
	rcall CHOOSE_T
	rjmp END_CHANGE
CHANGE_CLR_ALL:
	rcall CLR_ALL
	rcall CHOOSE_T
	rjmp END_CHANGE

CHANGE_SET_ALL:
	rcall SET_ALL
	rcall CHOOSE_T
	rjmp END_CHANGE

CHANGE_RIGHT:
	rcall RIGHT
	rcall CHOOSE_T
	rjmp END_CHANGE
CHANGE_LEFT:
	rcall LEFT
	rcall CHOOSE_T
	rjmp END_CHANGE

CHANGE_BACK:
	rcall BACK
	rcall CHOOSE_T
	rjmp END_CHANGE

CHANGE_FOWARD:
	rcall FOWARD
	rcall CHOOSE_T
	rjmp END_CHANGE

END_CHANGE:
	ldi Acc0,0
	cbi PORTD,2
	sei

	ret
//timer interuption/////////////////////////
TIM1_OVF:
	rcall START_TOGGLE
	reti
////////////////////////////////////////////
CLR_SEG:
	push Acc1
	push SEG
	
	ldi SEG,4
CLR_CONT:
	cpi SEG,0
	breq CLR_END
	dec SEG
	ser Acc1
	rcall SevSeg
	rjmp CLR_CONT
CLR_END:
	pop SEG
	pop Acc1

	ret
////////////////////////////////////////////
FOWARD:
	lsl Save0
	ret
////////////////////////////////////////////
BACK:
	lsr Save0
	ret
////////////////////////////////////////////
PICTURE:
	push Acc1

	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	pop Acc1
	ret
////////////////////////////////////////////
TOGGLE1:
	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	//mov Acc1,Seg1
	eor Save1,Save0
	mov Acc1,Save1
	rcall SevSeg

	ret
////////////////////////////////////////////
TOGGLE2:
	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	//mov Acc1,Seg2
	eor Save1,Save0
	mov Acc1,Save1
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg
	ret
////////////////////////////////////////////
TOGGLE3:
	mov Acc1,Seg4
	rcall SevSeg

	//mov Acc1,Seg3
	eor Save1,Save0
	mov Acc1,Save1
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	ret
////////////////////////////////////////////
TOGGLE4:
	//mov Acc1,Seg4
	eor Save1,Save0
	mov Acc1,Save1
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	ret
////////////////////////////////////////////
CHOOSE_T:
////SEG hranit nomer segmenta
	push Acc2
	ldi Acc2, 4

	cp Acc2,SEG
	breq CHOOSE_T_SEG4

	dec Acc2
	cp Acc2,SEG
	breq CHOOSE_T_SEG3

	dec Acc2
	cp Acc2,SEG
	breq CHOOSE_T_SEG2

	dec Acc2
	cp Acc2,SEG
	breq CHOOSE_T_SEG1

	rjmp CHOOSE_T_END

CHOOSE_T_SEG4:
	mov Save1,Seg4
	rjmp CHOOSE_T_END
CHOOSE_T_SEG3:
	mov Save1,Seg3
	rjmp CHOOSE_T_END
CHOOSE_T_SEG2:
	mov Save1,Seg2
	rjmp CHOOSE_T_END
CHOOSE_T_SEG1:
	mov Save1,Seg1
	rjmp CHOOSE_T_END
CHOOSE_T_END:
	pop Acc2

	ret
////////////////////////////////////////////
START_TOGGLE:
	////SEG hranit nomer segmenta
	push Acc2
	ldi Acc2, 4

	cp Acc2,SEG
	breq START_T_SEG4

	dec Acc2
	cp Acc2,SEG
	breq START_T_SEG3

	dec Acc2
	cp Acc2,SEG
	breq START_T_SEG2

	dec Acc2
	cp Acc2,SEG
	breq START_T_SEG1

	rjmp START_T_END

START_T_SEG4:
	rcall TOGGLE4
	rjmp START_T_END
	
START_T_SEG3:
	rcall TOGGLE3
	rjmp START_T_END
	
START_T_SEG2:
	rcall TOGGLE2
	rjmp START_T_END
	
START_T_SEG1:
	rcall TOGGLE1
	rjmp START_T_END

START_T_END:
	pop Acc2

	ret
////////////////////////////////////////////
CHOOSE_SET:
	push Acc0
	ldi Acc0, 4

	cp Acc0,SEG
	breq CHOOSE_SET_SEG4

	dec Acc0
	cp Acc0,SEG
	breq CHOOSE_SET_SEG3

	dec Acc0
	cp Acc0,SEG
	breq CHOOSE_SET_SEG2

	dec Acc0
	cp Acc0,SEG
	breq CHOOSE_SET_SEG1

	rjmp CHOOSE_SET_END

CHOOSE_SET_SEG4:
	rcall SET_SEG4
	rjmp CHOOSE_SET_END
	
CHOOSE_SET_SEG3:
	rcall SET_SEG3
	rjmp CHOOSE_SET_END
	
CHOOSE_SET_SEG2:
	rcall SET_SEG2
	rjmp CHOOSE_SET_END
	
CHOOSE_SET_SEG1:
	rcall SET_SEG1
	rjmp CHOOSE_SET_END

CHOOSE_SET_END:
	pop Acc0
	ret
////////////////////////////////////////////
SET_SEG1:
	push Acc2
	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	ldi Acc2,0xFF
	eor Seg1,Acc2
	or Seg1,Save0
	eor Seg1,Acc2

	mov Acc1,Seg1
	rcall SevSeg
	pop Acc2
	ret
////////////////////////////////////////////
SET_SEG2:
	push Acc2
	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	ldi Acc2,0xFF
	eor Seg2,Acc2
	or Seg2,Save0
	eor Seg2,Acc2

	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	pop Acc2

	ret
////////////////////////////////////////////
SET_SEG3:
	push Acc2
	mov Acc1,Seg4
	rcall SevSeg

	ldi Acc2,0xFF
	eor Seg3,Acc2
	or Seg3,Save0
	eor Seg3,Acc2

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	pop Acc2

	ret
////////////////////////////////////////////
SET_SEG4:
	push Acc2

	ldi Acc2,0xFF
	eor Seg4,Acc2
	or Seg4,Save0
	eor Seg4,Acc2
	
	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	pop Acc2

	ret
////////////////////////////////////////////
CHOOSE_CLR:
	push Acc0
	ldi Acc0, 4

	cp Acc0,SEG
	breq CHOOSE_CLR_SEG4

	dec Acc0
	cp Acc0,SEG
	breq CHOOSE_CLR_SEG3

	dec Acc0
	cp Acc0,SEG
	breq CHOOSE_CLR_SEG2

	dec Acc0
	cp Acc0,SEG
	breq CHOOSE_CLR_SEG1

	rjmp CHOOSE_CLR_END

CHOOSE_CLR_SEG4:
	rcall CLR_SEG4
	rjmp CHOOSE_CLR_END
	
CHOOSE_CLR_SEG3:
	rcall CLR_SEG3
	rjmp CHOOSE_CLR_END
	
CHOOSE_CLR_SEG2:
	rcall CLR_SEG2
	rjmp CHOOSE_CLR_END
	
CHOOSE_CLR_SEG1:
	rcall CLR_SEG1
	rjmp CHOOSE_CLR_END

CHOOSE_CLR_END:
	pop Acc0
	ret
////////////////////////////////////////////
CLR_SEG1:

	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	or Seg1,Save0
	mov Acc1,Seg1
	rcall SevSeg

	ret
////////////////////////////////////////////
CLR_SEG2:

	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	or Seg2,Save0
	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	ret
////////////////////////////////////////////
CLR_SEG3:

	mov Acc1,Seg4
	rcall SevSeg

	or Seg3,Save0
	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	ret
////////////////////////////////////////////
CLR_SEG4:

	or Seg4,Save0
	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	ret
////////////////////////////////////////////
CHOOSE_INVERT:
	push Acc0
	ldi Acc0, 4

	cp Acc0,SEG
	breq CHOOSE_INVERT_SEG4

	dec Acc0
	cp Acc0,SEG
	breq CHOOSE_INVERT_SEG3

	dec Acc0
	cp Acc0,SEG
	breq CHOOSE_INVERT_SEG2

	dec Acc0
	cp Acc0,SEG
	breq CHOOSE_INVERT_SEG1

	rjmp CHOOSE_INVERT_END

CHOOSE_INVERT_SEG4:
	rcall INVERT_SEG4
	rjmp CHOOSE_INVERT_END
	
CHOOSE_INVERT_SEG3:
	rcall INVERT_SEG3
	rjmp CHOOSE_INVERT_END
	
CHOOSE_INVERT_SEG2:
	rcall INVERT_SEG2
	rjmp CHOOSE_INVERT_END
	
CHOOSE_INVERT_SEG1:
	rcall INVERT_SEG1
	rjmp CHOOSE_INVERT_END

CHOOSE_INVERT_END:
	pop Acc0
	ret
////////////////////////////////////////////
INVERT_SEG1:

	push Acc2

	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg
	
	mov Acc2,Save0
	eor Seg1,Acc2
	mov Acc1,Seg1
	rcall SevSeg

	pop Acc2

	ret
////////////////////////////////////////////
INVERT_SEG2:
	push Acc2

	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc2,Save0
	eor Seg2,Acc2
	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	pop Acc2
	ret
////////////////////////////////////////////
INVERT_SEG3:
	push Acc2

	mov Acc1,Seg4
	rcall SevSeg

	mov Acc2,Save0
	eor Seg3,Acc2
	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	pop Acc2
	ret
////////////////////////////////////////////
INVERT_SEG4:
	push Acc2

	mov Acc2,Save0
	eor Seg4,Acc2
	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	pop Acc2
	ret
////////////////////////////////////////////
LEFT:
	cpi SEG,4
	brne LEFT_INC
	ldi SEG,1
	rjmp LEFT_END
LEFT_INC:
	inc SEG
LEFT_END:
	ret
////////////////////////////////////////////
RIGHT:
	cpi SEG,1
	brne RIGHT_DEC
	ldi SEG,4
	rjmp RIGHT_END
RIGHT_DEC:
	dec SEG
RIGHT_END:
	ret
////////////////////////////////////////////
CLR_ALL:
	push Acc1
	
	ldi Seg4,0xFF
	ldi Seg3,0xFF
	ldi Seg2,0xFF
	ldi Seg1,0xFF

	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	pop Acc1
	ret
////////////////////////////////////////////
SET_ALL:
	push Acc1
	
	ldi Seg4,0x00
	ldi Seg3,0x00
	ldi Seg2,0x00
	ldi Seg1,0x00

	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	pop Acc1
	ret
////////////////////////////////////////////
INVERT_ALL:
	push Acc1
	push Acc2

	ldi Acc2,0xFF
	eor Seg4,Acc2
	eor Seg3,Acc2
	eor Seg2,Acc2
	eor Seg1,Acc2

	mov Acc1,Seg4
	rcall SevSeg

	mov Acc1,Seg3
	rcall SevSeg

	mov Acc1,Seg2
	rcall SevSeg

	mov Acc1,Seg1
	rcall SevSeg

	pop Acc2
	pop Acc1
	ret
////////////////////////////////////////////
KEYBOARD:
	clr KEY
	ldi Mask, 0xEF

KEYBOARD_BACK:

	in Acc3, PORTB
	ori Acc3, 0xF0
	and Acc3, Mask
	out PORTB, Acc3

	nop
	nop

	sbis PIND, Col1
	rjmp KEYBOARD_1
	sbis PIND, Col2
	rjmp KEYBOARD_2
	sbis PIND, Col3
	rjmp KEYBOARD_3

	subi KEY, 0xFD

	cpi Mask, 0x7F
	breq  KEYBOARD_4
	sec
	rol Mask

	rjmp KEYBOARD_BACK

KEYBOARD_3:
	inc KEY
KEYBOARD_2:
	inc KEY
KEYBOARD_1:
	inc KEY
	rjmp KEYBOARD_END

KEYBOARD_4: 
	clr KEY
	
KEYBOARD_END:
	mov Acc0,KEY
	ret
////////////////////////////////////////////
DELAY:
	push Acc1
	push Acc0
	clr Acc1
D0: 
	ldi Acc0, 245
D1:	
	nop
	nop
	nop
	nop
	nop
	dec Acc0
	brne D1
	dec Acc1
	brne D0

	pop Acc0
	pop Acc1
	ret
SUPERDELAY:
	rcall DELAY
	rcall DELAY
	rcall DELAY
	rcall DELAY
	rcall DELAY
	//rcall DELAY
	//rcall DELAY
	ret
