;*************************************************************************************
; Authors: Ian Flury, Carson Free
; Template by: John Tadrous on 02/09/2018, Modified 02/08/2019
; Project: Lab 3
; Program: Subroutines and loops
; Date Created: 2/7/2022
;
; Description: this program will create and test subroutines and loops
; Inputs: none
; Outputs: none
;*************************************************************************************

	AREA	MyData, DATA, READWRITE, ALIGN=2
X		RN	R5
N		RN	R7

	THUMB
	AREA	MyCode, CODE, READONLY, ALIGN=2
	EXPORT	__main


__main

		BL		BCD_to_bin		; call the BCD_To_Bin
		;TO DO: Call the Absolute_value subroutine here
		BL		Absolute_value
		;TO DO: Call the Parity_adder
		BL		Parity_adder
stayHere	B	stayHere
		


; BCD_to_bin - converts a two-digit BCD number in R5 into its equivalent binary 
; which is returned through R6 
BCD_to_bin
		PUSH	{R0, X, LR}	; PUSH registers containing important data
		; Convert Xten and Xunit from BCD to Binary
		MOV		R0, X			; copy back the value of R1
		AND		X, #0xF0		; set the LSB to zero
		LSR		X, #1			; R5 = 8 * (MSD of Number)
		ADD		X, X, LSR #2	; R5 = 8 * (MSD of Number)+ 2 * (MSD of Number)
		AND		R0, #0x0F		; R0 = (LSD of Number)
		ADD		R6, X, R0			; R1 = binary of number 
		POP		{R0, X, LR}
		BX		LR	

; Absolute_value - given a number in R7, return its absolute value in R8
Absolute_value
		; TO DO: PUSH	important registers
		PUSH	{R0, N, LR}
		; TO DO: Copy N into R8
		MOV		R0, N
		; TO DO: Check if N is a negative number (you may use CMP instruction)
		CMP		R0, #0
		BGE		positive
		NEG		R8, R0
positive
		POP		{LR, R0, N}
		BX 		LR
		; TO TO: If non-negative, skip to POPing the pushed registers and return
		
		; TO DO: Else negate N and put the result in R8
		; TO DO: POP the pushed registers
		; TO DO: Return from subroutine	

; Parity_adder - Loops over the numbers from 1 to 100, accumulates the odd numbers 
; in register R9 and even numbers in register R10
Parity_adder
		; TO DO: 1) Push relevant registers
		PUSH	{LR, R0, R1}
		; TO DO: 2) Initialize R9 and R10 to zero each. These are your accumulators.
		MOV		R9, #0
		MOV		R10, #0
		; TO DO: 3) Initialize a register other than R9, R10 to 1 (this will be your loop index
		; 			and also the current number to be considered)
		MOV		R0, #1
		; TO DO: 4) Copy that register (containing the current number)
		;			into another register (again not R9 or R10)

loop	CMP		R0, #101
		BHS		done
		MOV		R1, R0
		; To DO: 5) Shift the number one time to the right and update flags
		LSRS	R1, #1
		; TO DO: 6) Check the carry flag to determine the parity
		BHS		odd		;if the number is odd branch to the odd instructions
		ADD		R10, R0	;if the odd branch doesn't happen, execute the even code.
		
		B		skipOdd	;if the even code executed, jump over the odd code.
odd
		ADD		R9, R0
		
skipOdd
		
		ADD		R0, #1	;add 1 to i regardless of whether it is even or odd
		
		B		loop	;redo everything
		
done
		POP {LR, R0, R1}	;pop the registers that we pushed in the beginning
		BX		LR			;return to __main.
		END			