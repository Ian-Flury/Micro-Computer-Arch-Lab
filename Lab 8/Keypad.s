GPIO_PORTD_DATA_R       EQU 	0x400073FC
GPIO_PORTD_DIR_R        EQU 	0x40007400
GPIO_PORTD_DEN_R        EQU		0x4000751C

NUM_POS1				EQU		0x0D
NUM_POS2				EQU		(NUM_POS1+1)

	AREA	RAMData, DATA, READWRITE, ALIGN=2
RFlag			DCD			0	; read flag
Key				DCD			0	; key read from Port A
Key_ASCII		DCD			0	; ASCII Key of the pressed key

	THUMB
	AREA	Keypad_Code, CODE, READONLY, ALIGN=2

	IMPORT SYSCTL_RCGCGPIO_R
	IMPORT GPIO_PORTA_DATA_R
	IMPORT Delay1ms
	IMPORT	Set_Position
	IMPORT	Display_Char 
	IMPORT	Xunit
	IMPORT	Xten
		
	EXPORT Read_Key
	EXPORT Init_Keypad
	
		
; Subroutine Read_Key- Reads a two-digit BCD from the keypad and stores
; the binary values of input keys in Xten and Xunit locations
Read_Key
	PUSH	{LR, R1, R0}
	LDR		R1, =NUM_POS1	;
	BL		Set_Position	;
	BL		Scan_Keypad	; read the first digit
	
	LDR		R0, =Key_ASCII	;
	LDR		R1, [R0]
	BL		Display_Char	; display the first digit
    SUB		R1, #0x30		; get the binary value of key
	LDR		R0, =Xten
	STR		R1, [R0]

	
	LDR		R1,	=NUM_POS2	;
	BL		Set_Position	;
	BL		Scan_Keypad	; read the second digit
	
	LDR		R0, =Key_ASCII	;
	LDR		R1, [R0]
	BL		Display_Char	; display the second digit
	SUB		R1, #0x30
	LDR		R0, =Xunit
	STR		R1, [R0]
	POP		{LR, R1, R0}	
	BX		LR


; Initialize Keypad subroutine
Init_Keypad
	; Port A is already initialized output by LCD port intiazlization
	; Here we do Port D only 
	PUSH	{LR, R1, R0}
	LDR		R0, =SYSCTL_RCGCGPIO_R	; Sending a clock to Port D
	LDR		R1, [R0]
	ORR		R1, #0x08
	STR		R1, [R0]
	
	LDR		R0, =GPIO_PORTD_DIR_R	; Lowest nibble of Port D is input
	LDR		R1, [R0]
	BIC		R1, #0x0F
	STR		R1, [R0]
	
	LDR		R0, =GPIO_PORTD_DEN_R	; Lowest nibble of Port D is digital
	LDR		R1, [R0]
	ORR		R1, #0x0F
	STR		R1, [R0]
	POP		{LR, R1, R0}
	BX		LR
	

; Subroutine Scan_Keypad - scans the whole keypad for a key press
Scan_Keypad
	PUSH	{LR, R1, R0}
Scan_Keypad_Again 
	BL		Scan_Col_0	; PA2 = 1, scan the rows
	LDR		R0, =RFlag
	LDR		R1, [R0]		; check the flag
	CMP		R1, #0x00
	BNE		End_Scan_Keypad	;
	BL		Scan_Col_1	; PA3 = 1, scan the rows
	LDR		R0, =RFlag		; check the flag
	LDR		R1, [R0]
	CMP		R1, #0x00
	BNE		End_Scan_Keypad	;
	BL		Scan_Col_2	; PA4 = 1, scan the rows
	LDR		R0, =RFlag		; check the flag
	LDR		R1, [R0]
	CMP		R1, #0x00
	BNE		End_Scan_Keypad	;
	BL		Scan_Col_3	; PA5 = 1, scan the rows
	LDR		R0, =RFlag		; check the flag
	LDR		R1, [R0]
	CMP		R1, #0x00
	BNE		End_Scan_Keypad	;
	B		Scan_Keypad_Again;
End_Scan_Keypad
	POP		{LR, R1, R0}
	BX		LR

; Subroutine Read_PortD - reads from Port D and implements debouncing key 
;	press
Read_PortD	
	PUSH	{R0-R2, LR}			
	LDR		R0,	=RFlag		; reset the RFlag
	MOV		R1, #0x00
	STR		R1, [R0]
	LDR		R0,	=GPIO_PORTD_DATA_R		; read from Port D
	LDR		R1, [R0]
	LDR		R0, =Key
	STR		R1, [R0] ; save R1 into a temporary variable
	ANDS	R1, #0x0F
	BEQ		Done_Keypad; check for a low value

	MOV		R0, #90		; add 90ms delay for
	BL		Delay1ms	; debouncing the switch
	
	LDR		R0, =GPIO_PORTD_DATA_R		; read from Port D
	LDR		R2, [R0]
	AND		R2, #0x0F
	CMP		R1, R2			; compare R1 and R2
	BNE		Done_Keypad	;
	LDR		R0, =RFlag		; set the flag
	LDR		R1, [R0]
	ADD		R1, #0x01
	STR		R1, [R0]
Done_Keypad
	POP 	{R0-R2,LR}
	BX		LR
	
	LTORG
; Subroutine Scan_Col_0 - scans column 0
;******************************************************************************************
Scan_Col_0
	PUSH	{LR, R1, R0}
	MOV		R1, #0x04	; PA2 = 1
	LDR		R0, =GPIO_PORTA_DATA_R
	STR		R1, [R0]
	
	BL		Read_PortD	;
	LDR		R0, =RFlag		; check the flag
	LDR		R1, [R0]
	CMP		R1, #0x00
	BEQ		Scan_Col_0_done	;
	
	LDR		R0, =Key
	LDR		R1, [R0]
	AND		R1, #0x0F	; we care only about the low nibble of port 
	CMP		R1, #0x01	; check for Row 0
	BEQ		Found_key_1
	CMP		R1, #0x02	; check for Row 1
	BEQ		Found_key_4
	CMP		R1, #0x04	; check for Row	2
	BEQ		Found_key_7
	CMP		R1, #0x08	; check for Row 3
	BEQ		Found_key_star
	B		Scan_Col_0_done	;
Found_key_1
	LDR		R0, =Key_ASCII
	MOV		R1, #0x31
	STR		R1, [R0]
	B		Scan_Col_0_done	; 
Found_key_4
	LDR		R0, =Key_ASCII
	MOV		R1, #0x34
	STR		R1, [R0]
	B		Scan_Col_0_done	;
Found_key_7
	LDR		R0, =Key_ASCII
	MOV		R1, #0x37
	STR		R1, [R0]
	B		Scan_Col_0_done	;
Found_key_star
	LDR		R0, =Key_ASCII
	MOV		R1, #0x2A
	STR		R1, [R0]
Scan_Col_0_done
	POP		{LR, R1, R0}
	BX		LR
	
; Subroutine Scan_Col_1 - scans column 1
;******************************************************************************************
Scan_Col_1
	PUSH	{LR, R1, R0}
	MOV		R1, #0x08	; PA3 = 1
	LDR		R0, =GPIO_PORTA_DATA_R
	STR		R1, [R0]
	
	BL		Read_PortD	;
	LDR		R0, =RFlag		; check the flag
	LDR		R1, [R0]
	CMP		R1, #0x00
	BEQ		Scan_Col_1_done	;
	
	LDR		R0, =Key
	LDR		R1, [R0]
	AND		R1, #0x0F	; we care only about the low nibble of port 
	CMP		R1, #0x01	; check for Row 0
	BEQ		Found_key_2
	CMP		R1, #0x02	; check for Row 1
	BEQ		Found_key_5
	CMP		R1, #0x04	; check for Row	2
	BEQ		Found_key_8
	CMP		R1, #0x08	; check for Row 3
	BEQ		Found_key_0
	B		Scan_Col_1_done	;
Found_key_2
	LDR		R0, =Key_ASCII
	MOV		R1, #0x32
	STR		R1, [R0]
	B		Scan_Col_1_done	; 
Found_key_5
	LDR		R0, =Key_ASCII
	MOV		R1, #0x35
	STR		R1, [R0]
	B		Scan_Col_1_done	;
Found_key_8
	LDR		R0, =Key_ASCII
	MOV		R1, #0x38
	STR		R1, [R0]
	B		Scan_Col_1_done	;
Found_key_0
	LDR		R0, =Key_ASCII
	MOV		R1, #0x30
	STR		R1, [R0]
Scan_Col_1_done
	POP		{LR, R1, R0}
	BX		LR

; Subroutine Scan_Col_2 - scans column 2
;******************************************************************************************
Scan_Col_2
	PUSH	{LR, R1, R0}
	MOV		R1, #0x10	; PA4 = 1
	LDR		R0, =GPIO_PORTA_DATA_R
	STR		R1, [R0]
	
	BL		Read_PortD	;
	LDR		R0, =RFlag		; check the flag
	LDR		R1, [R0]
	CMP		R1, #0x00
	BEQ		Scan_Col_2_done	;
	
	LDR		R0, =Key
	LDR		R1, [R0]
	AND		R1, #0x0F	; we care only about the low nibble of port 
	CMP		R1, #0x01	; check for Row 0
	BEQ		Found_key_3
	CMP		R1, #0x02	; check for Row 1
	BEQ		Found_key_6
	CMP		R1, #0x04	; check for Row	2
	BEQ		Found_key_9
	CMP		R1, #0x08	; check for Row 3
	BEQ		Found_key_pound
	B		Scan_Col_2_done	;
Found_key_3
	LDR		R0, =Key_ASCII
	MOV		R1, #0x33
	STR		R1, [R0]
	B		Scan_Col_0_done	; 
Found_key_6
	LDR		R0, =Key_ASCII
	MOV		R1, #0x36
	STR		R1, [R0]
	B		Scan_Col_0_done	;
Found_key_9
	LDR		R0, =Key_ASCII
	MOV		R1, #0x39
	STR		R1, [R0]
	B		Scan_Col_0_done	;
Found_key_pound
	LDR		R0, =Key_ASCII
	MOV		R1, #0x23
	STR		R1, [R0]
Scan_Col_2_done
	POP		{LR, R1, R0}
	BX		LR
	
; Subroutine Scan_Col_3 - scans column 3
;******************************************************************************************
Scan_Col_3
	PUSH	{LR, R1, R0}
	MOV		R1, #0x20	; PA5 = 1
	LDR		R0, =GPIO_PORTA_DATA_R
	STR		R1, [R0]
	
	BL		Read_PortD	;
	LDR		R0, =RFlag		; check the flag
	LDR		R1, [R0]
	CMP		R1, #0x00
	BEQ		Scan_Col_3_done	;
	
	LDR		R0, =Key
	LDR		R1, [R0]
	AND		R1, #0x0F	; we care only about the low nibble of port 
	CMP		R1, #0x01	; check for Row 0
	BEQ		Found_key_A
	CMP		R1, #0x02	; check for Row 1
	BEQ		Found_key_B
	CMP		R1, #0x04	; check for Row	2
	BEQ		Found_key_C
	CMP		R1, #0x08	; check for Row 3
	BEQ		Found_key_D
	B		Scan_Col_3_done	;
Found_key_A
	LDR		R0, =Key_ASCII
	MOV		R1, #0x41
	STR		R1, [R0]
	B		Scan_Col_3_done	; 
Found_key_B
	LDR		R0, =Key_ASCII
	MOV		R1, #0x42
	STR		R1, [R0]
	B		Scan_Col_3_done	;
Found_key_C
	LDR		R0, =Key_ASCII
	MOV		R1, #0x43
	STR		R1, [R0]
	B		Scan_Col_3_done	;
Found_key_D
	LDR		R0, =Key_ASCII
	MOV		R1, #0x44
	STR		R1, [R0]
Scan_Col_3_done
	POP		{LR, R1, R0}
	BX		LR
	
	END