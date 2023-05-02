;******************************************************************************************
; Author: John Tadrous
; Project: Lab5
; Program: Initializing LCD
; Date Created: March 05, 2017
; Date Modified: 02/23/2018 - Friendly codes are used as well as modified subroutines
;							  to contain the right sequence of PUSH POP instructions
; Description: this program will setup LCD and display a message on LCD
; Inputs: none
; Outputs: LCD
;******************************************************************************************
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
SYSCTL_RCC_R            EQU   0x400FE060
GPIO_PORTA_DIR_R        EQU   0x40004400
GPIO_PORTA_DATA_R       EQU   0x400043FC
GPIO_PORTA_DEN_R        EQU   0x4000451C
GPIO_PORTC_DIR_R        EQU   0x40006400
GPIO_PORTC_DATA_R       EQU   0x400063FC
GPIO_PORTC_DEN_R        EQU   0x4000651C
GPIO_PORTE_DIR_R        EQU   0x40024400
GPIO_PORTE_DATA_R       EQU   0x400243FC
GPIO_PORTE_DEN_R        EQU   0x4002451C

	AREA	 MyData, DATA, READONLY

Msg_hd1 DCB    "Welcome to Lab 5", 0
Msg_hd2 DCB    "John Tadrous", 0	
	
	AREA	 MyCode, CODE, READONLY, ALIGN=2
	

	EXPORT	__main

__main
	BL		Init_Clock	; sets the processor's clock to 16 MHz
	BL		Init_Ports ;
	BL		Init_LCD
	MOV		R1, ; TO DO: Complete this instruction by setting the position of the first char in line 1
	BL		Set_Position    ; Sets the position for the first line
	LDR		R0, =Msg_hd1	; R0 <- address of the message header 1
	BL		Display_Msg	;
	MOV		R1, ; TO DO: Complete this instruction by setting the position of the first char in line 2
	BL		Set_Position	;
	LDR		R0, =Msg_hd2	; R0 <- address of the message header 2
	BL		Display_Msg	;
end_main
	B		end_main
      
	
	
; Init_Ports - initializes ports A, C, and E for LCD display

Init_Ports
	; Initialize PORTs A,C and E. 
	PUSH	{LR, R2, R3}
	LDR		R2,=SYSCTL_RCGCGPIO_R
	; TO DO: With R2 pointing to SYSCTL_RCGCGPIO_R, activate the clocks of the 
	; three ports A, C, E using a friendly code (three instructions are missing).

	NOP
	NOP
	
	LDR		R2, =GPIO_PORTA_DIR_R
	; TO DO: With R2 pointing to GPIO_PORTA_DIR_R, configure PA5-PA2 as output pins
	; using a friendly code (three instructions needed)
	
	LDR		R2, =GPIO_PORTC_DIR_R
	; TO DO: With R2 pointing to GPIO_PORTC_DIR_R, configure PC6 as an output pin
	; using a friendly code (three instructions needed)
	
	LDR		R2,	=GPIO_PORTE_DIR_R
	; TO DO: With R2 pointing to GPIO_PORTE_DIR_R, configure PE0 as an output pin
	; using a friendly code (three instructions needed)
	
	LDR		R2, =GPIO_PORTA_DEN_R
	LDR		R3, [R2]
	ORR		R3, #0x3C; PA5-PA2 signals are digital
	STR		R3, [R2]
	; TO DO: The previous four instructions enable digital data on PA5-PA2 in a friendly
	; manner. Use a similar approach to enable digital data on PC6 and PE0 (8 instructions)
 	POP		{LR, R2, R3}
	BX		LR	

; Display_Msg - displays the message
; This subroutine iteratively sends ASCII characters to be displayed
; Its input is R0 which points to the base address of the first character in the string
Display_Msg
	PUSH	{LR, R0, R1}
disp_again
	LDRB	R1, [R0] 		; R1 <- ASCII data
	CMP		R1,	#0x00		; check for the end of the string
	BEQ		disp_end			  
	BL		Display_Char	; Here it calls Display_Char subroutine
							; which receives the char to be displayed in R1
	ADD		R0, R0, #1		; increment R0
	B		disp_again	
disp_end
	POP		{LR, R0, R1}
	BX		LR
		
; Display_Char - sends an ASCII value in R1 to LCD

Display_Char
	PUSH	{LR, R0, R1}
	BL		SplitNum	; Returns the upper 4 bits in R1 and lower 4 bits in R0
	BL		WriteData	; Sends 4 bits of data from R1 to LCD
	MOV		R1, R0
	BL		WriteData	; Now send the lower 4 bits of the ASCII byte to LCD
	MOV		R0, #0x01	
	BL		Delay1ms	; wait for 1ms
	POP		{LR, R0, R1}
	BX		LR

; Set_Position - sets the position in R1 for displaying data in LCD

Set_Position
	PUSH	{LR, R1, R0}
	ORR		R1,	#0x80	; set b7 of R1
	BL		SplitNum	
	BL		WriteCMD	; write upper 4 bits of the command
	MOV		R1,	R0
	BL		WriteCMD	; write lower 4 bits of the command
	MOV		R0, #0x01		
	BL		Delay1ms	; wait for 1ms
	POP		{LR, R1, R0}
	BX		LR

; WriteData - sends a data (lower 4 bits) in R1 to LCD.
; Data in R1 must be shifted two times to the left in order to be
; aligned with PA5-PA2, the pins responsible for communicating info

WriteData
	PUSH	{LR, R1, R0}
	LSL		R1, R1, #2		; data from bits 2 - 5
	LDR		R0, =GPIO_PORTA_DATA_R
	STR		R1, [R0]
	LDR		R0, =GPIO_PORTE_DATA_R
	LDR		R1, [R0]
	ORR		R1, #0x01	; Sending data (set PE0)
	STR		R1, [R0]
	LDR		R0,	=GPIO_PORTC_DATA_R
	LDR		R1, [R0]
	BIC		R1, #0x40	; Enabling the LCD (falling edge) on PC6
	STR		R1, [R0]
	NOP
	NOP
	ORR		R1, #0x40	; Raising PC6 in preparation for the next write 
	STR	R1, [R0]
	POP		{LR, R1, R0}
	BX		LR			

; WriteCMD - sends a command (lower 4 bits) in R1 to LCD
; similar to WriteData, the 4 bits must be shifted left twice
; in order to be aligned with PA5-PA2
WriteCMD 
	PUSH	{LR, R1, R0}
	LSL		R1, R1, #2		; data from bits 2 - 5
	LDR		R0, =GPIO_PORTA_DATA_R
	STR		R1, [R0]
	LDR		R0, =GPIO_PORTE_DATA_R
	LDR		R1, [R0]
	BIC		R1, #0x01;		; Clearing PE0 so that RS=0 for sending a command
	STR		R1, [R0]
	LDR		R0,	=GPIO_PORTC_DATA_R
	LDR		R1, [R0]
	BIC		R1, #0x40	; Enabling the LCD (falling edge) on PC6
	STR		R1, [R0]
	NOP
	NOP
	ORR		R1, #0x40	; Raising PC6 in preparation for the next write 
	STR		R1, [R0]
	POP		{LR, R1, R0}
	BX		LR

; SplitNum - separates hex numbers in R1
;	  R1 <- MS digit (the upper 4 bits)
;	  R0 <- LS digit (the lower 4 bits)

SplitNum
	PUSH	{LR}
	MOV		R0, R1
	AND		R0, #0x0F		; mask the upper 4 bits
	LSR		R1,	R1, #4 
	POP		{LR}
	BX		LR

; Init_LCD - initializes LCD according to the initializing sequence indicated
;	  by the manufacturer

Init_LCD
	PUSH	{LR, R0, R1}
	MOV		R0, #30		;
	BL		Delay1ms		; wait 30ms for LCD to power up
	
	; send byte 1 of code to LCD
	MOV		R1,	#0x30		; R1 <- byte #1 of code: $30
	BL		SplitNum	;
	BL		WriteCMD	; write byte #1
	MOV		R0,	#5		;
	BL		Delay1ms	; wait for 5 ms
	
	; send byte 2 of code to LCD
	; TO DO: Refer to your pre-lab table of command bytes and the instructions
	; above to send byte 2.
	
	; send byte 3 of code to LCD
	; TO DO: Refer to your pre-lab table of command bytes and the instructions
	; above to send byte 3.
	
	; send byte 4 of code to LCD
	; TO DO: Refer to your pre-lab table of command bytes and the instructions
	; above to send byte 3.
	
	; send byte 5 of code to LCD (starting from byte 5, we send half a byte at a time)
	MOV		R1,	#0x28		; R1 <- byte #5 of code: $28
				;  db5 = 1, db4 = 0 (DL = 0 - 4 bits), 
				;  db3 = 1 (N = 1 - 2 lines),
				;  db2 = 0 (F = 0 - 5x7 dots).
	BL		SplitNum	;
	BL		WriteCMD	; write upper 4 bits of byte #5
	MOV		R1,R0
	BL		WriteCMD	; write lower 4 bits of byte #5
	MOV		R0,	#1		;
	BL		Delay1ms	; wait for 1ms
	
	; send byte 6 of code to LCD
	; TO DO: Refer to your pre-lab table of command bytes and the instructions
	; above for sending byte 5 to send byte 6.
	
	; send byte 7 of code to LCD
	; TO DO: Refer to your pre-lab table of command bytes and the instructions
	; above for sending byte 5 to send byte 7.
	
	; send byte 8 of code to LCD
	; TO DO: Refer to your pre-lab table of command bytes and the instructions
	; above for sending byte 5 to send byte 6.
	POP		{LR, R0, R1}
	BX		LR


Init_Clock
	; Bypass the PLL to operate at main 16MHz Osc.
	PUSH	{LR, R1, R0}
	LDR		R0, =SYSCTL_RCC_R
	LDR		R1, [R0]
	BIC		R1, #0x00400000 ; Clearing bit 22 (USESYSDIV)
	BIC		R1, #0x00000030	; Clearing bits 4 and 5 (OSCSRC) use main OSC
	ORR		R1, #0x00000800 ; Bypassing PLL
	
	STR		R1, [R0]
	POP		{LR, R1, R0}
	BX		LR

;Delay milliseconds
Delay1ms
	PUSH	{LR, R0, R3, R4}
	MOVS	R3, R0
	BNE		L1; if n=0, return
	BX		LR; return

L1	LDR		R4, =5336
			; do inner loop 5336 times (16 MHz CPU clock)
L2	SUBS	R4, R4,#1
	BNE		L2
	SUBS	R3, R3, #1
	BNE		L1
	POP		{LR, R0, R3, R4}
	BX		LR
	
	END