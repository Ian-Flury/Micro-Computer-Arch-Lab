;**********************************************************************************************
; Author: Ian Flury
; Lab 1: Arithmetic Computation
; Date Created: January 25th, 2022 
; Last Modified: January 25th, 2022 
; Description: This program preforms basic arithmetic functions such as addition, 
;			   multiplication, and division using the most basic op-codes.
; Outputs: none.
;**********************************************************************************************

	AREA	MyData, DATA, READWRITE, ALIGN=2
Vx	RN		R7;
Vy	DCB		0;
Vz	DCB		0;
	AREA	MyCode, CODE, READONLY, ALIGN=2
	EXPORT __main

__main
	MOV		Vx,	#10		;move 10 into Vx
	MOV		R5,	Vx		;make a copy of Vx in R5
	
	LSL		R5,	#3		;shift the value in R5 left by 3 (multiply by 8)
	SUB		R5,	R5,	Vx	;subtract Vx from R5
	ADD		R5,	#120	;add 120 to the value in R5
	
	LDR		R0,	=Vy		;load the memory address of Vy into R0
	STR		R5,	[R0]	;store the data in R5 in the memory address that
						;is stored in R0.
	
	LSR		R5, #3		;shift the value in R5 to the right by 3 (divide by 8)
	ADD		R5, #25		;add 25 to the value stored in R5
	
	LDR		R0, =Vz		;load the memory address into the register R0.
	STR		R5, [R0]	;send the data in R5 to the memory address that is
						;stored in the register R0.
	
	END