;*************************************************************************************************
; Authors: Ian Flury, Carson Free
; Project: Lab11
; Program: Communication with Terminal
; Date Created: April 8, 2017
; Date Modified: November 28, 2017 - removed LCD-related code
;
; Description: this program will read texts from Hypertermial and display them using UART0
; Inputs: the keyboard
; Outputs: the terminal
;*************************************************************************************************

; defining registers
SYSCTL_RCGCGPIO_R       EQU   0x400FE608
SYSCTL_RCGCUART_R       EQU   0x400FE618
SYSCTL_RCC_R            EQU   0x400FE060
GPIO_PORTA_PCTL_R       EQU   0x4000452C

GPIO_PORTA_DIR_R        EQU   	0x40004400
GPIO_PORTA_DEN_R        EQU   	0x4000451C
GPIO_PORTA_DATA_R       EQU   	0x400043FC
GPIO_PORTA_IS_R         EQU   	0x40004404
GPIO_PORTA_IBE_R        EQU   	0x40004408
GPIO_PORTA_IEV_R        EQU   	0x4000440C
GPIO_PORTA_IM_R         EQU   	0x40004410
GPIO_PORTA_RIS_R        EQU   	0x40004414
GPIO_PORTA_MIS_R        EQU   	0x40004418
GPIO_PORTA_ICR_R        EQU   	0x4000441C
GPIO_PORTA_AFSEL_R      EQU   	0x40004420
GPIO_PORTA_AMSEL_R      EQU   	0x40004528

; UART0 registers
;*************************************************************
UART0_DR_R              EQU   0x4000C000
UART0_RSR_R             EQU   0x4000C004
UART0_ECR_R             EQU   0x4000C004
UART0_FR_R              EQU   0x4000C018
UART0_ILPR_R            EQU   0x4000C020
UART0_IBRD_R            EQU   0x4000C024
UART0_FBRD_R            EQU   0x4000C028
UART0_LCRH_R            EQU   0x4000C02C
UART0_CTL_R             EQU   0x4000C030
UART0_IFLS_R            EQU   0x4000C034
UART0_IM_R              EQU   0x4000C038
UART0_RIS_R             EQU   0x4000C03C
UART0_MIS_R             EQU   0x4000C040
UART0_ICR_R             EQU   0x4000C044
UART0_DMACTL_R          EQU   0x4000C048
UART0_LCTL_R            EQU   0x4000C090
UART0_LSS_R             EQU   0x4000C094
UART0_LTIM_R            EQU   0x4000C098
UART0_9BITADDR_R        EQU   0x4000C0A4
UART0_9BITAMASK_R       EQU   0x4000C0A8
UART0_PP_R              EQU   0x4000CFC0
UART0_CC_R              EQU   0x4000CFC8

; special characters
;*************************************************************************************************
CR						EQU	0x0D	; carriage return
LF						EQU	0x0A	; line feed
FF						EQU	0x0C	; form feed
BS						EQU	0x08	; back space
SPC						EQU	0x20	; space character
NULL					EQU	0x00	; Null character

; size of the buffer
;*************************************************************************************************
N						EQU	20	;


; ROM data
;*************************************************************************************************
	AREA  ROMData, DATA, READONLY, ALIGN=2

Msg_Header				DCB		"Universal Asynchronous Receiver Transmitter (UART)", 0x00
Buffer_Prompt			DCB		"Hello, I am your TM4C. This is what I got -> ", 0x00
;LCD_Msg					DCB		"Lab #11 - UART", 0x00

; RAM data
;************************************************************************************************
	AREA MyData, DATA, READWRITE, ALIGN=2

Buffer_Term			SPACE	N+1	; buffer for the message
Counter_Term		DCD		1	; counter
DFlag_Term			DCD		1	; display flag

; Code
;************************************************************************************************
	AREA MyCode, CODE, READONLY, ALIGN=2
	EXPORT	__main

__main
	BL		Init_Clock				; set system clock to main OSC. (16 MHz)
	BL		Init_UART0				; initialize UART0 (19200 baudrate, 8-bit word, 1 stop bit, no-parity)
	BL		Init_Variables_UART0	; clear DFlag_Term, Counter_Term

	MOV		R1, #FF					; sending form feed to clear the terminal's display
	BL		Out_UART0
	LDR		R0, =Msg_Header			; displaying a header message on terminal
	BL		Write_Msg_UART0
	BL		New_line_UART0
	BL		New_line_UART0
Start
	BL		Read_Terminal
	BL		Display_Buffer
	B		Start
	
; subroutine Init_Variables_UART0  clears the DFlag_Term and Counter_Term
;*************************************************************************************
Init_Variables_UART0
	PUSH	{LR, R1, R0}
	MOV		R1, #0x00;
	LDR		R0, =DFlag_Term
	STR		R1, [R0]
	LDR		R0, =Counter_Term
	STR		R1, [R0]
	POP		{LR, R1, R0}
	BX 		LR
	
; subroutine Read_Terminal - reads characters from UART0 and saves them in Buffer_Term
;*************************************************************************************************
Read_Terminal
	PUSH	{R0-R2, LR}

;**********************************************************************************************
; TO DO: Write this subroutine following the flowchart in the lab guide. Note that "Count", 
; "SIZE", and "DFlag" are defined in this template as "Counter_Term", "N" and "DFlag_Term"
; respectively. See the declaration section above.
;**********************************************************************************************

	LDR 	R0, =Counter_Term
	LDR 	R1, [R0]
	
	
	CMP 	R1, #N
	
	BEQ		true
	BL 		In_UART0
	CMP 	R1, #0x00
	BEQ 	last
	
	BL 		Out_UART0
	CMP 	R1, #CR
	BEQ 	true
	
	LDR 	R0, =Counter_Term
	LDR 	R2, [R0]
	LDR 	R0, =Buffer_Term
	STRB 	R1, [R0, R2]
	
	ADD 	R2, #1
	LDR 	R0, =Counter_Term
	STR	  	R2, [R0]
	B 	 	last
		

true
	LDR 	R0, =DFlag_Term
	MOV 	R1, #1
	STR 	R1, [R0]
	
	MOV 	R1, #0x00
	LDR 	R0, =Counter_Term
	LDR 	R2, [R0]
	LDR 	R0, =Buffer_Term
	STR 	R1, [R0, R2]
last

	POP		{R0-R2, LR}
	BX		LR

; subroutine In_UART0 reads a UART0 character and places it in R1
;*************************************************************************************
In_UART0
	; ********************************************************************************
	; To Do: Write this subroutine following the in-class discussion
	; ********************************************************************************
	PUSH	{LR,R0,R2}
	
No_Char
	LDR	 	R0, =UART0_FR_R
	LDR 	R1, [R0]
	AND 	R1, #0x10
	CMP 	R1, #0x00
	BNE 	No_Char
	LDR 	R0, =UART0_DR_R
	LDR 	R1, [R0]
	MOV 	R0, R1
	LDR 	R2, =0xF00
	ANDS 	R1, R2
	BNE 	No_Char
	MOV 	R1, R0
	
	POP		{LR,R0,R2}
	BX		LR
	
; subroutine Out_UART0 send a character in R1 to terminal through UART0
;*************************************************************************************
Out_UART0
	; ********************************************************************************
	; To Do: Write this subroutine following the in-class discussion
	; ********************************************************************************
	PUSH 	{LR,R0-R2}
	
Send_Buffer_Full
	LDR 	R0, =UART0_FR_R
	LDR 	R2, [R0]
	AND 	R2, #0x20
	CMP 	R2, #0x00
	BNE 	Send_Buffer_Full
	LDR 	R0, =UART0_DR_R
	STR 	R1, [R0]
		
	POP		{LR,R0-R2}
	BX		LR
	
;* subroutine Display_Prompt - displays buffer prompt on terminal
;*************************************************************************************************
Display_Prompt
	PUSH	{LR, R0}			
	LDR		R0,	=Buffer_Prompt	
	BL		Write_Msg_UART0						; send the buffer to UART0	
	POP		{LR, R0}				
	BX		LR

;* subroutine Display_Buffer - sends characters of Buffer_Term to UART0.
;*************************************************************************************************
Display_Buffer
	PUSH	{LR, R1, R0} 
	
	; *******************************************************************************************
	; TO DO: Write this subroutine  as specified in the flowchart. You may use the subroutine
	; New_line_UART0 below to output CR & LF to the UART0. Note that, DFlag and Count in the 
	; flow chart are defined in the template as DFlag_Term and Counter_Term.
	; The subroutine Write_Msg is also given in the template as Write_Msg_UART0 below.
	; *******************************************************************************************
	LDR 	R0, =DFlag_Term
	LDR 	R1, [R0]
	CMP 	R1, #1
	BNE 	false
	
	BL 		New_line_UART0
	LDR 	R0, =DFlag_Term
	MOV 	R1, #0
	STR 	R1, [R0]
	
	LDR 	R0, =Counter_Term
	STR 	R1, [R0]
	
	BL 		Display_Prompt
	LDR 	R0, =Buffer_Term
	BL 		Write_Msg_UART0
	
	BL 		New_line_UART0
	
false	
	
	POP		{LR, R1, R0}
	BX		LR

; subroutine New_line_UART0 - sends a new line to UART0
;*************************************************************************************************
New_line_UART0
	PUSH	{LR, R1}
	MOV		R1, #LF						; add a line feed character
	BL		Out_UART0					; send the character to UART0	
	MOV		R1,	#CR						; add a carriage return chacter
	BL		Out_UART0					; send the character to UART0
	POP		{LR, R1}
	BX		LR

; subroutine Write_Msg_UART0 - sends characters from memory location pointed to by R0 to UART0
; until character NULL is encoutered
;*************************************************************************************************
Write_Msg_UART0
	PUSH	{LR, R1, R0}
Write_again
	LDRB	R1, [R0], #1				; post increment of R0
	CMP		R1, #0x00					; check for NULL, the terminating character
	BEQ		Write_Msg_UART0_Done
	BL		Out_UART0					; send to UART0
	B		Write_again
Write_Msg_UART0_Done
	POP		{LR, R1, R0}
	BX		LR

; Init_UART0 subroutine: initializes UART0 for receiving and sending at 19200 baudrate
;*************************************************************************************
Init_UART0
	PUSH	{LR, R1, R0}

;************************************************************************************
; TO DO: Initialize UART0 following the steps we covered in class
;************************************************************************************
	LDR 	R0, =SYSCTL_RCGCUART_R
	LDR 	R1, [R0]
	ORR 	R1, #0x01
	STR 	R1, [R0]
	
	LDR 	R0, =SYSCTL_RCGCGPIO_R
	LDR 	R1, [R0]
	ORR 	R1, #0x01
	STR 	R1, [R0]
	
	LDR 	R0, =GPIO_PORTA_DEN_R
	LDR 	R1, [R0]
	ORR 	R1, #0x03
	STR 	R1, [R0]
	
	LDR 	R0, =GPIO_PORTA_AFSEL_R
	LDR 	R1, [R0]
	ORR 	R1, #0x03
	STR 	R1, [R0]
	
	LDR 	R0, =GPIO_PORTA_PCTL_R
	LDR 	R1, [R0]
	BIC 	R1, #0xFF
	ORR 	R1, #0x11
	STR 	R1, [R0]
	
	LDR 	R0, =UART0_IBRD_R
	MOV 	R1, #0x1A
	STR 	R1, [R0]
	
	LDR 	R0, =UART0_FBRD_R
	MOV 	R1, #0x02
	STR 	R1, [R0]
	
	LDR 	R0, =UART0_LCRH_R
	MOV 	R1, #0x70
	STR 	R1, [R0]
	
	LDR 	R0, =UART0_CTL_R
	LDR 	R1, =0x301
	STR 	R1, [R0]
	
	POP		{LR, R1, R0}
	BX		LR

; Other hardware initialization from previous labs
;***********************************************************************************************	
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

	END