;****************************************************************************************************
; Author:  Ian Flury
; Lab 0: RGB LED Demonstration                  
; Date Created: Jan. 18, 2022             
; Last Modified: Jan. 18, 2022                                                    
; Description: this program will display RGB LED according to the value stored in a variable 
;	Register R7. The variable Counter will be incremented each time.
; Inputs: values in the variable Counter
; Outputs: RGB LED
;****************************************************************************************************
SYSCTL_RCC_R            EQU   0x400FE060	
	THUMB
	AREA MyCode, CODE, READONLY, ALIGN=2
	EXPORT __main
__main
	; enable clock to GPIOF at clock gating register
	BL		Init_Clock
	LDR 	R0, =0x400FE608; RCGC register address
	LDR		R1, [R0]
	ORR		R1, #0x20
	STR		R1, [R0]
	
	; set PORTF pins 3-1 as output pins
	LDR		R0, =0x40025400
			; DIR register address
	MOV		R1, #0x0E
	STR		R1, [R0]
	
	; set PORTF pins 3-1 as digital pins
	LDR		R0, =0x4002551C
			; digital enable register address
	MOV		R1, 0x0E
	STR		R1, [R0]

	; initialize color index in R3
	MOV		R7, #00
loop
	
	; write PORTF to turn on the RGB led with selected color
	LDR 	R0, =0x400253FC
			; PORTF address
	STR		R7, [R0]
	
	; delay a little while
	LDR 	R0, =1000
	BL		delayMs ; call delayMs
	
	; write PORTF to turn off all LEDS
	LDR		R0, =0x400253FC
	MOV 	R1, #0
	STR		R1, [R0]
	
	; delay a little while
	LDR		R0, =1000
	BL		delayMs
	ADD		R7,	R7,	#02
	; repeat the loop
	B		loop
	
	; this subroutine performs a delay of n ms
	; n is the value in R0
	
delayMs
	MOVS	R3, R0
	BNE		L1; if n=0, return
	BX		LR; return

L1	LDR		R4, =5336
			; do inner loop 5336 times (16 MHz CPU clock)
L2	SUBS	R4, R4,#1
	BNE		L2
	SUBS	R3, R3, #1
	BNE		L1
	BX		LR

; Initializing the clock signal to 16MHz	
Init_Clock
	; Bypass the PLL to operate at main 16MHz Osc.
	PUSH	{LR}
	LDR		R0, =SYSCTL_RCC_R
	LDR		R1, [R0]
	BIC		R1, #0x00400000 ; Clearing bit 22 (USESYSDIV)
	BIC		R1, #0x00000030	; Clearing bits 4 and 5 (OSCSRC) use main OSC
	ORR		R1, #0x00000800 ; Bypassing PLL
	
	STR		R1, [R0]
	POP		{LR}
	BX		LR	
	
	END
	