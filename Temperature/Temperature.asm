.include "m8535def.inc"
/////////////////////////////////////
.def Acc0   = r16 
.def Acc1   = r17 //existence
.def HBYTE  = r18
.def LBYTE  = r19
.def INT_P  = r20
.def FRAC_P = r21
.def Acc2   = r22
/////////////////////////////////////
.equ FREQ = 1000000
.equ DDR  = DDRC
.equ PORT = PORTC
.equ PIN  = PINC
.equ BIT  = 2
.equ Din  = 1
.equ CLK  = 0
/////////////////////////////////////
.org 0x0
	 rjmp Reset
.org 0x15
/////////////////////////////////////
Reset:
	ldi Acc0, HIGH(RAMEND) 
	out SPH, Acc0
	ldi Acc0, LOW(RAMEND)
	out SPL, Acc0
/////////////////////////////////////
	sbi DDR,CLK
	sbi DDR,Din
/////////////////////////////////////
	rcall CHECK_EX
	cpi Acc1,0
	breq LOOP
	rcall INIT_12BIT
/////////////////////////////////////
MAIN:

	rcall CHECK_EX
	cpi Acc1,0
	breq LOOP

	rcall CONV_TEMP
	rcall Delay2s
	rcall CHECK_EX
	
	rcall READ_DATA
	
	rcall DATA_IN_SEG

	rjmp MAIN
	
/////////////////////////////////////
CHECK_EX://check if sensor is connected

	sbi DDR,BIT
	cbi PORT, BIT

	rcall Delay480us
	cbi DDR, BIT
	rcall Delay70us

	sbis PIN,BIT
	ldi Acc1,1
	sbic PIN,BIT
	ldi Acc1,0

	rcall Delay410us
	
	ret///Acc1=1 if exists else Acc1=0
/////////////////////////////////////
LOOP:
	rjmp LOOP
/////////////////////////////////////
INIT_12BIT:

	ldi Acc0,0xCC//skin address
	rcall WRITE_BYTE

	ldi Acc0,0x4E ///write in eeprom
	rcall WRITE_BYTE

	ldi Acc0,0xFF
	rcall WRITE_BYTE

	ldi Acc0,0xFF
	rcall WRITE_BYTE

	ldi Acc0,0x5F //11 bit
	rcall WRITE_BYTE

	ret
/////////////////////////////////////
WRITE_BYTE:

	push Acc0
	push Acc1

	ldi Acc1,8

WRITE_BYTE_BACK:

	sbi DDR,BIT
	cbi PORT,BIT

	sbrs Acc0,0
	rjmp WRITE_BYTE_0
	rjmp WRITE_BYTE_I

WRITE_BYTE_END:

	lsr Acc0
	dec Acc1
	brne WRITE_BYTE_BACK
		
	pop Acc1
	pop Acc0

	ret

WRITE_BYTE_0:

	rcall Delay60us
	cbi DDR,BIT
	rcall Delay10us
	rjmp WRITE_BYTE_END

WRITE_BYTE_I:

	rcall Delay6us
	cbi DDR,BIT
	rcall Delay64us
	rjmp WRITE_BYTE_END

/////////////////////////////////////
CONV_TEMP:

	ldi Acc0,0xCC
	rcall WRITE_BYTE

	ldi Acc0, 0x44
	rcall WRITE_BYTE

	ret
/////////////////////////////////////
READ_DATA:

	ldi Acc0,0xCC
	rcall WRITE_BYTE

	ldi Acc0,0xBE
	rcall WRITE_BYTE
	
	rcall READ_BYTE
	mov LBYTE,Acc0

	rcall READ_BYTE
	mov HBYTE,Acc0

	ret
/////////////////////////////////////
READ_BYTE:

	ldi Acc1,8
	clr Acc0

READ_BYTE_BACK:

	sbi DDR,BIT
	cbi PORT, BIT

	rcall Delay6us

	cbi DDR,BIT

	rcall Delay9us

	sbic PIN,BIT
	sec
	sbis PIN,BIT
	clc

	ror Acc0

	rcall Delay55us

	dec Acc1

	brne READ_BYTE_BACK

	ret
/////////////////////////////////////
Delay6us:
	nop
	nop
	ret
/////////////////////////////////////
Delay64us:
	ldi XH,HIGH(21)
	ldi XL,LOW(21)
	rcall WORK_DELAY_1
	ret
/////////////////////////////////////
Delay60us:
	ldi XH,HIGH(19)
	ldi XL,LOW(19)
	rcall WORK_DELAY_1
	ret
/////////////////////////////////////
Delay10us:
	nop
	nop
	nop
	nop
	nop
	nop
	ret
/////////////////////////////////////
Delay9us:
	nop
	nop
	nop
	nop
	nop
	ret
/////////////////////////////////////
Delay55us:
	ldi XH,HIGH(17)
	ldi XL,LOW(17)
	rcall WORK_DELAY_1
	ret
/////////////////////////////////////
Delay480us:
	ldi XH,HIGH(187)
	ldi XL,LOW(187)
	rcall WORK_DELAY_1
	ret
/////////////////////////////////////
Delay70us:
	ldi XH,HIGH(23)
	ldi XL,LOW(23)
	rcall WORK_DELAY_1
	ret
/////////////////////////////////////
Delay410us:
	ldi XH,HIGH(159)
	ldi XL,LOW(159)
	rcall WORK_DELAY_1
	ret
/////////////////////////////////////
WORK_DELAY_1:
	sbiw XH:XL , 1
	brne WORK_DELAY_1
	ret
/////////////////////////////////////
Delay2s:
	push Acc1
	push Acc0

	ldi Acc1, 255
	ldi Acc0, 255
	ldi XL,   5

Delay2s_Back:
	dec Acc1
	brne Delay2s_Back

	dec Acc0
	brne Delay2s_Back

	dec XL
	brne Delay2s_Back

	pop Acc0
	pop Acc0

	ret
/////////////////////////////////////
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
/////////////////////////////////////
DATA_IN_SEG:
	push Acc0
	push Acc1

	ldi Acc1,4

	mov INT_P,HBYTE
	mov Acc0,LBYTE

DATA_IN_SEG_BACK:
	
	lsl INT_P

	sbrs Acc0,7
	andi INT_P,0xFE

	sbrc Acc0,7
	ori INT_P,0x01

	lsl Acc0

	dec Acc1
	brne DATA_IN_SEG_BACK

	pop Acc1
	pop Acc0

	mov FRAC_P,LBYTE
	andi FRAC_P,0x0F

	rcall DATA


	ret
/////////////////////////////////////
DATA:
	cln
	push INT_P
	subi INT_P,100
	brpl DATA_HIGHER_100

	sbrs HBYTE,7
	rjmp DATA_PLUS

	sbrc HBYTE,7
	rjmp DATA_MINUS

DATA_BACK_1:
	ldi Acc0,90
	ldi Acc2,9
DATA_BACK_2:
	cln
	cpi Acc0,0
	breq DATA_UNITS

	push INT_P
	sub INT_P,Acc0
	brpl DATA_HIGHER_NEXT

	pop INT_P

	dec Acc2

	subi Acc0,10

	rjmp DATA_BACK_2

DATA_UNITS:
	
	ldi Acc1,0xC0
	rcall SevSeg

	ldi ZH,HIGH(NUMBERS*2)
	ldi ZL,LOW(NUMBERS*2)

	add ZL,INT_P
	lpm
	mov Acc1,R0
	andi Acc1,0x7F
	rcall SevSeg
	rjmp DATA_END
	

DATA_HIGHER_NEXT:
	pop INT_P

	ldi ZH,HIGH(NUMBERS*2)
	ldi ZL,LOW(NUMBERS*2)
	
	add ZL,Acc2
	lpm
	mov Acc1,R0

	rcall SevSeg

	sub INT_P,Acc0

	ldi ZH,HIGH(NUMBERS*2)
	ldi ZL,LOW(NUMBERS*2)

	add ZL,INT_P
	lpm
	mov Acc1,R0
	andi Acc1,0x7F

	rcall SevSeg

	rjmp DATA_END

DATA_HIGHER_100:

	ldi Acc1,0xF9
	rcall SevSeg
	pop INT_P
	subi INT_P,100
	rjmp DATA_BACK_1


DATA_MINUS:
	
	ldi Acc1,0xBF
	rcall SevSeg

	pop INT_P
	rcall DATA_MINUS_TRUE

	rjmp DATA_BACK_1

DATA_PLUS:
	ldi Acc1,0xFF
	rcall SevSeg
	pop INT_P

	rjmp DATA_BACK_1

DATA_END:
	rcall DATA_FRAC 
	ret
/////////////////////////////////////
DATA_FRAC:
	sbrs HBYTE,7
	rjmp DATA_FRAC_PLUS
	sbrc HBYTE,7
	rjmp DATA_FRAC_MINUS

DATA_FRAC_MINUS:
	rcall DATA_MINUS_TRUE
DATA_FRAC_PLUS:
	ldi Acc2,6
	mul Acc2,FRAC_P

	ldi Acc0,90
	ldi Acc2,9
DATA_FRAC_BACK_2:
	cln
	cpi Acc0,0
	breq DATA_FRAC_UNITS

	push R0
	sub R0,Acc0
	brpl DATA_FRAC_HIGHER_NEXT

	pop R0

	dec Acc2

	subi Acc0,10

	rjmp DATA_FRAC_BACK_2

DATA_FRAC_UNITS:
	ldi Acc1,0xC0
	rcall SevSeg
	rjmp DATA_FRAC_END

DATA_FRAC_HIGHER_NEXT:
	pop R0
	
	sbrc HBYTE,7
	rjmp DATA_FRAC_HIGHER_NEXT_MINUS

	ldi ZH,HIGH(NUMBERS*2)
	ldi ZL,LOW(NUMBERS*2)
	
	add ZL,Acc2
	lpm Acc2,Z
	mov Acc1,Acc2

	rcall SevSeg
	rjmp DATA_FRAC_END

DATA_FRAC_HIGHER_NEXT_MINUS:

	ldi ZH,HIGH(NUMBERS_MINUS*2)
	ldi ZL,LOW(NUMBERS_MINUS*2)
	
	add ZL,Acc2
	lpm Acc2,Z
	mov Acc1,Acc2

	rcall SevSeg
	rjmp DATA_FRAC_END


DATA_FRAC_END:
	ret

/////////////////////////////////////
DATA_MINUS_TRUE:

	mov XL,FRAC_P
	mov XH,INT_P
	sbiw XL,1
	ldi Acc2,0xFF
	eor XL,Acc2
	ldi Acc2,0xFF
	eor XH,Acc2
	mov FRAC_P,XL
	mov INT_P,XH

	ret
/////////////////////////////////////
NUMBERS:
.db 0xC0,0xF9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90
NUMBERS_MINUS:
.db 0x90,0x80,0xF8,0x82,0x92,0x99,0xB0,0xA4,0xF9,0xC0
