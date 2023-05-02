;*************************************************************************************************
; Author: John Tadrous
; Project: Lab9
; Program: 16-bit Caculator
; Date Created: March 18, 2017
; Date Modified (by J. Tadrous):  April 10, 2021
;								  Enhanced the clearing operation.
; Description: this program will implement a calculator. 
; Inputs: the keypad
; Outputs: LCD
;*************************************************************************************************



; TO DO: Read carefully all the definitions below and make sure you understand them
; you will need these definitions throughout the project

; Special characters and their positions on LCD for calculator
;*************************************************************************************************
BLANK		EQU	0x20	; ASCII value for " "
POUND_SIGN	EQU	0x23	; ASCII value for "#"
ASTERISK	EQU	0x2A	; ASCII value for "*"
NULL		EQU	0x00	; ASCII value for NULL
LetterA		EQU	0x41	; ASCII value for A
LetterB		EQU	0x42	; ASCII value for B
LetterC		EQU	0x43	; ASCII value for C
LetterD		EQU	0x44	; ASCII value for D

; Positions for the number and the result on LCD (calculator)
;*************************************************************************************************
Size_Cal				EQU	5		; size for result buffer
POS_Ready_Cal			EQU	0x00	; display position for message prompt
POS_Operand1_Cal		EQU	0x03	; display position for the number
POS_Operand_msg_Cal		EQU	0x40	; display position for the operand prompt message
POS_Operation_msg_Cal	EQU	0x40	; display position for the operation message
POS_Error_msg_Cal		EQU	0x40	; display position for the error message
POS_Result_msg_Cal		EQU	0x40	; display position for the result message
POS_Result_Cal			EQU	0x4B	; display position for the result value

; Constant Strings - ROM
;**************************************************************************************************
	AREA Strings, DATA, READONLY, ALIGN=2
Ready_Cal				DCB		"<<            >>", 0;	
Add_msg_Cal				DCB		"+", 0	;
Sub_msg_Cal				DCB		"-", 0	;
Mult_msg_Cal			DCB		"*", 0	;
Div_msg_Cal				DCB		"/", 0	;
Error_msg_Cal			DCB		"Error! Re-enter ", 0	;
Result_msg_Cal			DCB		"Result:         ", 0	;
Blank_line_Cal			DCB		"                ", 0;
Error_blank_Cal			DCB		"       ",0;
Operand1_msg_Cal		DCB		"Input Oprnd1..  ", 0;
Operand2_msg_Cal		DCB		"Input Oprnd2..  ",0;
Operation_msg_Cal		DCB		"Input Oprtn..   ", 0;
; Flags and Variables
;*************************************************************************************************
	AREA 	MyData, DATA, READWRITE, ALIGN=2
Key_ASCII			DCD		0		; ASCII value of the pressed key
Operand1_Cal		DCD		0		; first operand entered from the keypad
Operand2_Cal		DCD		0		; second operand entered from the keypad
Result_Cal			DCD		0		; result of arithmetic operation
ErFlag_Cal			DCD		0		; error flag
ClrFlag_Cal			DCD		0		; clear flag
Mode_Cal			DCD		0		; operation flag
Buffer_Number		SPACE	Size_Cal+1	; String of BCD digit from the keypad
POS_Operation_Cal	DCD		0		; last display position on line 1
POS_Operand2_Cal	DCD		0	; display position for the second operand


; CODE
;**************************************************************************************************
	AREA	MyCode, CODE, READONLY, ALIGN=2
	IMPORT	Scan_Keypad
	IMPORT	Init_Keypad
	IMPORT	Delay1ms
	IMPORT	Set_Position
	IMPORT	Display_Msg
	IMPORT	Display_Char 
	IMPORT	Init_Clock
	IMPORT	Init_LCD_Ports
	IMPORT	Init_LCD
	
	EXPORT	Key_ASCII
	EXPORT	__main

__main
	BL		Init_Hardware_Lab9		; Clock, LCD, Delay, and Keypad
Clear
	BL		Init_Vars_Cal			; initializing variables and flags
	LDR		R1, =POS_Ready_Cal		; set the message prompt
	BL		Set_Position	; 
	LDR		R0,	=Ready_Cal	; display the message prompt
	BL		Display_Msg	;
	
Start
	BL  Get_Operand1_Cal
	LDR	R0, =ClrFlag_Cal
	LDR	R1, [R0]
	CMP	R1, #0x01
	BEQ	Clear
Re_enter
	BL	Get_Operation_Cal		; get and display the operation 
	LDR	R0, =ClrFlag_Cal
	LDR	R1, [R0]
	CMP	R1, #0x01
	BEQ	Clear
	BL	Get_Operand2_Cal		; 
	LDR	R0, =ClrFlag_Cal
	LDR	R1, [R0]
	CMP	R1, #0x01
	BEQ	Clear
	BL	Operation_Cal			; perform arithmetic operation
	BL	Display_Result_Cal		; display the result
	BL	Wait_for_Clear
	B	Start		
	LTORG

; Subroutine Get_Operand1_Cal- gets the first BCD number as operand and stores its hex equivalent in Operand1_Cal
Get_Operand1_Cal
	; TO DO: Write the subroutine here.
	PUSH 	{LR,R0-R5}
	
	LDR 	R1, =POS_Operand_msg_Cal
	BL 		Set_Position
	
	LDR 	R0, =Operand1_msg_Cal
	BL 		Display_Msg
	
	MOV 	R1, #POS_Operand1_Cal
	BL 		Set_Position
	
	MOV 	R4, #0 	;loop index
start
	BL 		Scan_Keypad
	
	;Preform the operand check logic to see if the ascii val in mem is = # or C
	
	LDR 	R0, =Key_ASCII
	LDR 	R2, [R0]
	
	CMP 	R2, #POUND_SIGN
	BEQ 	pound
	CMP 	R2, #LetterC
	BEQ 	letterC
	
	CMP 	R2, #0x30
	BLO 	start
	CMP 	R2, #0x39
	BHI 	start
	
	LDR 	R3, =Buffer_Number
	STRB 	R2, [R3, R4]
	
	MOV 	R1, R2
	BL 		Display_Char
	
	ADD 	R4, #1
	CMP 	R4, #Size_Cal
	BNE 	start
	
	B 		beginEnd

	
pound
	CMP 	R4, #0
	BEQ 	start
	B 		beginEnd

letterC
	LDR 	R0, =ClrFlag_Cal
	MOV 	R5, #1
	STR 	R5, [R0]
	B 		done
	
beginEnd	
	MOV 	R5, #NULL
	STRB 	R5, [R3, R4]
	LDR 	R0, =Buffer_Number
	BL 		String_ASCII_BCD2Hex_Lib
	LDR 	R0, =Operand1_Cal
	STR 	R1, [R0]
	
	MOV 	R1, #POS_Operand1_Cal
	LDR 	R0, =POS_Operation_Cal
	ADD 	R2, R4, R1
	STR 	R2, [R0]
	
done
	
	POP 	{LR,R0-R5}
	BX		LR
	
	
	
	
; Get_Operand2_Cal Subroutine- Similar to Get_Operand1_Cal
Get_Operand2_Cal
	; TO DO: Write the subroutine here.
	PUSH 	{LR,R0-R5}
	
	LDR 	R1, =POS_Operation_msg_Cal
	BL 		Set_Position
	
	LDR 	R0, =Operand2_msg_Cal
	BL 		Display_Msg
	
	LDR 	R0, =POS_Operation_Cal
	LDR 	R1, [R0]
	BL 		Set_Position
	
	MOV 	R4, #0 	;loop index
start2
	BL 		Scan_Keypad
	
	;Preform the operand check logic to see if the ascii val in mem is = # or C
	
	LDR 	R0, =Key_ASCII
	LDR 	R2, [R0]
	
	CMP 	R2, #POUND_SIGN
	BEQ 	pound2
	CMP 	R2, #LetterC
	BEQ 	letterC2
	
	CMP 	R2, #0x30
	BLO 	start2
	CMP 	R2, #0x39
	BHI 	start2
	
	LDR 	R3, =Buffer_Number
	STRB 	R2, [R3, R4]
	
	MOV 	R1, R2
	BL 		Display_Char
	
	ADD 	R4, #1
	CMP 	R4, #Size_Cal
	BNE 	start2
	
	B 		beginEnd2

	
pound2
	CMP 	R4, #0
	BEQ 	start2
	B 		beginEnd2

letterC2
	LDR 	R0, =ClrFlag_Cal
	MOV 	R5, #1
	STR 	R5, [R0]
	B 		done2
	
beginEnd2
	MOV 	R5, #NULL
	STRB 	R5, [R3, R4]
	LDR 	R0, =Buffer_Number
	BL 		String_ASCII_BCD2Hex_Lib
	LDR 	R0, =Operand2_Cal
	STR 	R1, [R0]
	
done2
	
	POP 	{LR,R0-R5}
	BX		LR
	LTORG

; Subroutine String_ASCII_BCD2Hex_Lib- Converts a string of BCD characters pointed to by R0
; to a hex equivalent value in R1
String_ASCII_BCD2Hex_Lib
	PUSH	{R0,R2, LR}
	MOV		R2, #0x00						; initialize R2
String_ASCII_BCD2Hex_Lib_Again
	MOV		R1, #0x00						; initialize R1
	LDRB	R1, [R0]						; R1 <- digit in the string
	ADD		R0, #1							; increment base address
	CMP		R1, #0x00
	BEQ		End_String_ASCII_BCD2Hex_Lib	;
	SUB		R1,	#0x30						; convert to decimal digit
	ADD		R2, R1							; R2 <-- R2 + R1
	MOV		R1, R2							; R1 <-- R2
	MOV		R3, #0x00
	LDRB	R3, [R0]
	CMP		R3, #0x00						; check the next digit in the string before multiplying by 10
	BEQ		End_String_ASCII_BCD2Hex_Lib	;
	MOV		R2, #10							; R2 <- 10
	MUL		R1, R2							; R1=10*R1
	MOV		R2, R1							; copy the result in R2
	B		String_ASCII_BCD2Hex_Lib_Again
End_String_ASCII_BCD2Hex_Lib	
	POP		{R0,R2, LR}
	BX		LR


; Subroutine Hex2DecChar_Lib- Converts a hex value in R1 into an ASCII string of BCD characters in location
; pointed to by R0
Hex2DecChar_Lib
	PUSH	{R0-R5, LR}
	MOV		R2, #0x20    			; blanking the content before writing the string the BCD digits
	MOV		R3, #Size_Cal
Blank_digit
	SUB		R3, #1
	STRB	R2, [R0, R3]			; writing a blank
	CMP		R3, #0x00
	BHI		Blank_digit
	STRB	R3, [R0, #Size_Cal]		; here R3 is NULL so we simply NULL the last byte of the string
	MOV		R3, #Size_Cal
Attach_digit	
	MOV		R2, R1					; quotient in R2
	CMP		R2, #10
	BLO		Last_digit
	MOV		R4, #10					; R4 is temporarily used to hold #10
	UDIV	R1, R2, R4				; R1=floor(R2/10)
	MUL		R5, R1, R4
	SUB		R4, R2, R5				; remainder in R4
	ADD		R4, #0x30				; ASCII
	SUB		R3, #1
	STRB	R4, [R0, R3]			; store the ASCII code of BCD digit
	CMP		R3, #0x00
	BEQ		End_Hex2DecChar_Lib		; typically this will not be executed unless we have an overflow (c.f. Lab7)
	B		Attach_digit
Last_digit							; here we store the quotient as the most significant BCD digit
	ADD		R2, #0x30
	SUB		R3, #1
	STRB	R2, [R0, R3]
End_Hex2DecChar_Lib
	POP		{R0-R5, LR}
	BX		LR
	

; Subroutine Init_Vars_Cal - initializes variables and flags
Init_Vars_Cal
	PUSH	{LR, R1, R0}
	LDR		R0, =Mode_Cal
	MOV		R1, #0x00
	STR		R1, [R0]			; clear operation flag
	LDR		R0, =Operand1_Cal
	STR		R1, [R0]			; clear operand1
	LDR		R0, =Operand2_Cal
	STR		R1, [R0]			; clear operand2
	LDR		R0, =Result_Cal
	STR		R1, [R0]			; clear the result
	LDR		R0, =ErFlag_Cal
	STR		R1, [R0]			; clear the error flag
	LDR		R0, =ClrFlag_Cal
	STR		R1, [R0]			; clear the clear flag
	POP		{LR, R1, R0}
	BX		LR

; Get_Operation_Cal subroutine- Receives and displays the operation
Get_Operation_Cal
; TO DO: Write the subroutine here.
	PUSH 	{LR,R0-R4}
	
	LDR 	R1, =POS_Operation_msg_Cal
	BL 		Set_Position
	
	LDR 	R0, =Operation_msg_Cal
	BL 		Display_Msg
	
	LDR 	R0, =POS_Operation_Cal
	LDR 	R1, [R0]
	BL 		Set_Position
	
start3
	BL 		Scan_Keypad
	LDR 	R0, =Key_ASCII
	LDR 	R1, [R0]
	
	CMP 	R1, #0x41
	BEQ   	plus
	
	CMP 	R1, #0x42
	BEQ 	minus
	
	CMP 	R1, #0x2A
	BEQ 	star
	
	CMP 	R1, #0x44
	BEQ 	divide
	
	CMP 	R1, #0x42
	BNE 	start3
	;set the clear flag
	LDR  	R2, =ClrFlag_Cal
	MOV 	R3, #1
	STR 	R3, [R2]
	
	B 		doneClear

	
	

plus
	LDR 	R4, =Add_msg_Cal
	B 		done3
minus
	LDR 	R4, =Sub_msg_Cal
	B 		done3
star
	LDR 	R4, =Mult_msg_Cal
	B 		done3
divide
	LDR 	R4, =Div_msg_Cal

done3

	MOV	 	R0, R4
	BL 		Display_Msg

	LDR 	R0, =Mode_Cal
	STR 	R1, [R0]

	LDR 	R0, =POS_Operation_Cal
	LDR 	R1, [R0]
	ADD 	R2, R1, #1
	STR 	R2, [R0]

doneClear	



	POP 	{LR,R0-R4}
	BX		LR

; Operation_Cal Subroutine- Carries out the specified operation
Operation_Cal
; TO DO: Write the subroutine here.
	PUSH 	{LR, R0-R5}
	LDR 	R5, =65535
	
	LDR 	R0, =Operand1_Cal
	LDR 	R1, [R0] 			;R1 holds the first operand
	
	LDR 	R0, =Operand2_Cal
	LDR 	R2, [R0]			;R2 holds the second operand
	
	LDR 	R0, =Mode_Cal
	LDR 	R3, [R0] 			;R0 holds the operation to be preformed.
	
	CMP 	R3, #0x41 			;check if the operation is addition
	BEQ 	addition
	
	CMP 	R3, #0x42
	BEQ 	subtraction
	
	CMP 	R3, #0x44
	BEQ 	division
	
	;else, we are multiplying
	MUL 	R4, R1, R2
	CMP 	R4, R5
	BHI 	err
	B 		Done3
	
addition
	ADD 	R4, R1, R2
	CMP 	R4, R5
	BHI 	err
	B 		Done3
	
subtraction
	CMP 	R1, R2
	BLO 	err
	SUB 	R4, R1, R2
	CMP 	R4, R5
	BHI 	err
	B 		Done3
	
division
	CMP 	R2, #0
	BEQ		err
	UDIV 	R4, R1, R2
	CMP 	R4, R5
	BHI 	err
	B 		Done3

	
err 	;load the error flag and set it to 1
	LDR 	R0, =ErFlag_Cal
	MOV 	R2, #1
	STR 	R2, [R0]

Done3
	LDR 	R0, =Result_Cal
	STR 	R4, [R0]
	
	POP		{LR, R0-R5}
	BX		LR
	
	
; Display_Result_Cal Subroutine- Display the final outcome
Display_Result_Cal
; TO DO: Write the subroutine here.
	PUSH	{LR,R0,R1}
	
	LDR 	R0, =ErFlag_Cal
	LDR 	R1, [R0]
	CMP 	R1, #1
	BEQ 	is_err
	
	LDR 	R0, =Result_Cal
	LDR 	R1, [R0]
	LDR 	R0, =Buffer_Number
	BL 		Hex2DecChar_Lib
	
	MOV 	R1, #POS_Result_msg_Cal
	BL 		Set_Position
	LDR	 	R0, =Result_msg_Cal
	BL 		Display_Msg
	
	MOV 	R1, #POS_Result_Cal
	BL 		Set_Position
	LDR 	R0, =Buffer_Number
	BL	 	Display_Msg
	
	B 		Done4
	
is_err
	MOV 	R1, #POS_Error_msg_Cal
	BL 		Set_Position
	
	LDR 	R0, =Error_msg_Cal
	BL 		Display_Msg
	
	MOV  	R0, #2000
	BL 		Delay1ms 	;delay 2 secs
	
	BL		Init_Vars_Cal			; initializing variables and flags
	LDR		R1, =POS_Ready_Cal		; set the message prompt
	BL		Set_Position	; 
	LDR		R0,	=Ready_Cal	; display the message prompt
	BL		Display_Msg	;
	
	POP 	{LR,R0,R1}
	B 		Start
	
Done4

	POP		{LR,R0,R1}
	BX		LR
	
;Subroutine Wait_for_Clear- scans keypad and clears everything only when 'C' is pressed	
Wait_for_Clear
	PUSH	{LR, R1, R0}
Keep_waiting
	BL		Scan_Keypad
	LDR		R0, =Key_ASCII
	LDRB	R1, [R0]
	CMP		R1, #LetterC
	BNE		Keep_waiting
	POP		{LR, R1, R0}
	B		Clear
	
; Init_Hardware_Lab9 subroutine	
Init_Hardware_Lab9
	PUSH	{LR}
	BL		Init_Clock
	BL		Init_LCD_Ports
	BL		Init_LCD
	BL		Init_Keypad
	POP		{LR}
	BX		LR
	END
