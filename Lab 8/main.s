;******************************************************************************************
; Authors: Carson Free, Ian Flury
; Project: Lab8
; Program: Math Routines and Fixed Point Arithmetic
; Date Created: March 25, 2017
; Date Modified: October 27, 2017 - separate the code into different files (e.g., LCD.s
; Keypad.s)
; Date Modified: March 30, 2018 by John Tadrous, rearrange the subroutines in main.s, LCD.s 
; and Keypad.s so that LCD.s and Keypad.s can be used together independent of main.s.
; Description: this program will perform arithmetic operations for 24-bit numbers
; Inputs: Keypad
; Outputs: LCD
;******************************************************************************************

; Display Positions
;******************************************************************************************
MSG_RES_POS				EQU		0x40
RESULT_POS				EQU		0x49
MSG_POS					EQU		0x00


; ROM Data
;*******************************************************************************************
	AREA	ROMData, DATA, READONLY, ALIGN=2
Const			DCB		0x48	; fractional part
				DCB		0x9F	; low byte of integer part
				DCB		0x01	; high byte of integer part
;Const			DCD		0x0019F48
Msg_prompt		DCB		"Key Entered:", 0	;
Msg_Result		DCB		"Result: ", 0	;
Msg_blank		DCB		"        ", 0	;

; RAM Data: Flags and Variables
;******************************************************************************************
	AREA	RAMData, DATA, READWRITE, ALIGN=2
Xunit			DCD			0	; units digit is stored in X_unit
Xten			DCD			0	; tens digit is stored in X_ten	
Output_Z		DCD			0	; three bytes for the output buffer
Result_Buf		SPACE		8	; result buffer for displaying on LCD

; TO DO: Answer this question in your lab report. Why does "Result_Buf" have a size of 8 bytes?


;	Code
;******************************************************************************************
	AREA	MyCode, CODE, READONLY, ALIGN=2
	EXPORT	__main

	EXPORT	Xten	; Xten and Xunit are exported because they are being used by the Keypad.s
	EXPORT	Xunit
		
	IMPORT	Init_Clock
	IMPORT	Init_LCD_Ports
	IMPORT	Init_LCD
	IMPORT	Init_Keypad
	IMPORT	Set_Position
	IMPORT	Display_Msg
	IMPORT	Display_Char 
	IMPORT	Read_Key
	
__main
	BL		Init_Hardware_Lab8
	BL		Init_Vars
Start
	BL		Read_Number
	BL		Compute_Z
	BL		Display_Z
	B		Start

;********************************************************************************************



; Subroutine Read_Number- Gets a two-digit BCD number from the keypad and returns its binary
; value in the middle two bytes of R1
Read_Number
	PUSH	{LR, R0, R2}
	BL		Read_Key	; Reads the BCD number from keypad and stores the tens 
						; and units digits respectively in Xten and Xunit
						
	
	
	
	; TO DO: Convert Xten and Xunit from BCD to binary value Num
	; and place Num in the two ++>> middle bytes <<++ of R1
	; Note that Xten and Xunit are defined as 32-bit word each
	; not a single byte each as in Lab 2.
	LDR 	R0, =Xten
	LDR 	R1, [R0]
	MOV 	R2, R1
	LSL 	R1, #3
	ADD 	R1, R2
	ADD 	R1, R2
	
	
	LDR 	R0, =Xunit
	LDR 	R2, [R0]
	ADD  	R1, R2
	
	LSL 	R1, #8
	
	POP		{LR, R0, R2}
	BX		LR

; Subroutine Compute_Z- Computes Z according to the formula Z=24.513*Num (in R1)-415.285
Compute_Z
	PUSH	{R0-R3, LR}
	; TO DO: Given Num in R1, compute the integer part 24*Num in R2 and do not
	; make changes to R1
	
	; TO DO: With R1 still holding Num, compute the fractional part 0.513*Num in R3
	; which is equivalent to Num/2+Num/2^7+Num/2^8+Num/2^10+Num/2^12
	MOV 	R2, #0
	
	MOV 	R0, R1
	ADD 	R2, R0, LSL #3
	ADD 	R2, R0, LSL #4
	
	MOV 	R0, #0
	ADD 	R0, R1, LSR #1
	ADD 	R0, R1, LSR #7
	ADD 	R0, R1, LSR #8
	ADD 	R0, R1, LSR #10
	ADD 	R0, R1, LSR #12	
	
	MOV 	R3, #0
	; TO DO: Add R2 to R3 so that R3 has 24.513*Num
	ADD 	R3, R0, R2
	; TO DO: Subtract the 3-byte constant Const from R3 to obtain Z and
	; store the result in Output_Z
	LDR 	R0, =Const
	LDR 	R1,[R0]
	LSL 	R1, #8
	LSR 	R1, #8
	SUB 	R3, R3, R1
	
	LDR 	R0, =Output_Z
	STR 	R3, [R0]
	
	POP		{R0-R3, LR}
	BX		LR

; Subroutine Display_Z- Computes the ACII of every digit in Output_Z and displays it
Display_Z
	PUSH	{LR, R1, R0}
	
	LDR		R0, =Output_Z
	LDRB	R1, [R0]			; R1 has the fractional part of Output_Z
	BL		Bin2ASCII			; returns in R2 the ACII codes of the byte in R1
	LDR		R0, =Result_Buf		;
	STRB	R2, [R0, #6]		; LSB
	LSR		R2, #8				; the ASCII code of the higher digit is in the LSB of R2
	STRB	R2, [R0, #5]
	
	LDR		R0, =Output_Z		
	LDRB	R1, [R0, #1]		; R1 has the LSB of the integer part of Output_Z
	BL		Bin2ASCII
	LDR		R0, =Result_Buf
	STRB	R2, [R0, #3]		; recall that location Result_Buf+4 is reserved for the fractional point
	LSR		R2, #8
	STRB	R2, [R0, #2]
	
	; TO DO: Follow the same approach as above to store the
	; ASCIIs of third byte of Output_Z in their respective order
	; in Result_Buf
	LDR		R0, =Output_Z		
	LDRB	R1, [R0, #2]		; R1 has the LSB of the integer part of Output_Z
	BL		Bin2ASCII
	LDR		R0, =Result_Buf
	STRB	R2, [R0, #1]		; recall that location Result_Buf+4 is reserved for the fractional point
	LSR		R2, #8
	STRB	R2, [R0]
	
	
	; display on LCD
	MOV		R1, #RESULT_POS
	BL		Set_Position
	LDR		R0, =Result_Buf
	BL		Display_Msg
	POP		{LR, R1, R0}
	BX		LR

; Subroutine Bin2ASCII- Takes a two-digit HEX number in R1 and returns the ASCII codes of
; these two digits in the two lower bytes of R2 such that the ASCII of the high nibble is
; in byte 1 of R2 and ASCII of the low nibble is in byte 0 of R2
Bin2ASCII
	PUSH	{LR, R1, R0}
	
	AND		R2, #0x00			; clearing R2
	MOV		R0, R1				; copy R1 in R0  0x31
	
	LSR 	R1, #4 		 	;R1 = 3
	AND 	R0, #0x000F  	;R0 = 1
	
	
	CMP 	R1, #0x09
	BHI		greater_than1
	ADD 	R1, #0x30
	B 		skip1
greater_than1
	ADD 	R1, #0x37
skip1

	CMP 	R0, #0x09
	BHI		greater_than2
	ADD 	R0, #0x30
	B 		skip2
greater_than2
	ADD 	R0, #0x37
skip2
	
	; TO DO: Complete the subroutine and keep in mind that. The ASCII code of a HEX digit 
	; that is between 0 and 9 is the HEX digit plus 0x30 whereas the ASCII code of a HEX digit
	; that is between A and F is the HEX digit plus 0x37
	

	LSL 	R1, #8
	AND 	R1, #0xFF00
	AND 	R0, #0x00FF
	ORR 	R2, R1, R0
	
	POP		{LR, R1, R0}
	BX		LR
	


; Subroutine Init_Vars- Prompts for number input and initialize the results buffer
Init_Vars
	PUSH	{LR, R0, R1}
	MOV		R1, #MSG_POS	;
	BL		Set_Position	;
	LDR		R0,	=Msg_prompt	;
	BL		Display_Msg	;
	
	MOV		R1, #MSG_RES_POS	;
	BL		Set_Position	;
	LDR		R0, =Msg_Result	;
	BL		Display_Msg	;	  
	
	LDR		R0, =Result_Buf+4
	MOV		R1, #0x2E			; set the "." character
	STRB	R1, [R0]
	LDR		R0,	=Result_Buf+7
	MOV		R1, #0x00			; add Null character for the string
	POP		{LR, R0, R1}
	BX		LR


;********************************************************************************************
; Subroutine Init_Hardware_Lab7- Initializes clock, LCD and Keypad
Init_Hardware_Lab8
	PUSH	{LR}
	BL		Init_Clock
	BL		Init_LCD_Ports
	BL		Init_LCD
	BL		Init_Keypad
	POP		{LR}
	BX		LR

	
	END