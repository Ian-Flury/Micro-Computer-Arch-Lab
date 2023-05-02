;**********************************************************************************************
; Authors: Ian Flury, Carson Free
; Lab 2: Data Conversion and Signed Numbers
; Date Created: February 1st, 2022 
; Last Modified: February 1st, 2022 
; Description: This program...
; Outputs: 
;**********************************************************************************************
X			RN		R7;
			AREA	MyData, DATA, READWRITE, ALIGN=2
Xten		DCB		0;
Xunit		DCB		0;
Xten_ascii	DCB		0;
Xunit_ascii	DCB 	0;
Xbin 		DCB 	0;
Ybin		DCB 	0;
			AREA	MyCode, CODE, READONLY, ALIGN=2	
			EXPORT __main
		
__main
	MOV		X, #0x26
	
	;get the Xten value...
	MOV		R8, X
	LSR		R8, #4
	LDR		R9, =Xten
	STRB	R8, [R9]
	ADD		R8, #0x30
	LDR		R9, =Xten_ascii
	STRB	R8,[R9]
	
	;get the Xunit value...
	MOV		R9, X
	AND		R9, #0x0F
	LDR		R6, =Xunit
	STRB	R9, [R6]
	ADD		R9, #0x30
	LDR		R6, =Xunit_ascii
	STRB	R9,[R6]
	
	;convert to pos number rep.
	LDR		R0, =Xunit
	LDR		R1, =Xten
	LDR		R3, [R0]
	LDR		R4, [R1]
	MOV		R5, R4
	LSL		R4, #3
	ADD		R4, R5
	ADD		R4, R5
	ADD		R6, R4, R3
	LDR		R4, =Xbin
	STRB	R6, [R4]
	
	;calculate Ybin
	LDR		R3, =Xbin
	LDR		R6, [R3]
	MOV		R0, R6
	LSL		R0, #2
	SUB		R0, R6
	MOV		R1, #50
	SUB		R1, R0
	LDR		R2, =Ybin
	STRB	R1, [R2]

	END
		