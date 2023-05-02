;*************************************************************************************
; Authors: Ian Flury, Carson Free
; Template by: John Tadrous on 02/09/2018, Modified 02/08/2019
; Project: Lab 4
; Program: Indexed Addressing and Pointers
; Date Created: 2/15/2022
;
; Description: This program creates space in memory for three arrays and adds the 
;			   content of the first two into the third.
; Inputs: length of the arrays
; Outputs: the resultant arrays ArrayA, arrayB, and ArrayC
;*************************************************************************************

N		EQU		100	; maximum size of the arrays

; Defining length, pointers, and arrays
	AREA	MyData, DATA, READWRITE, ALIGN=2
		
Length	DCB		0	; Length of arrays
PtrA	SPACE	4	; Pointer for ArrayA
PtrB	SPACE	4	; Pointer for ArrayB
PtrC	SPACE	4	; Pointer for ArrayC
ArrayA	SPACE	N	; the arrayA
ArrayB	SPACE	N	; the arrayB
ArrayC	SPACE	N	; the arrayC


	AREA	MyCode, CODE, READONLY, ALIGN=2
	EXPORT	__main
		

__main
	MOV		R1, #0x23	; A two-digit BCD number representing Length
	BL		Set_Length	; set the length of the arrays
	BL		Clear_Arrays; clear all arrays
	BL		Set_ArrayA	; set the array A
	BL		Set_ArrayB	; set the array B
	BL		Set_ArrayC	; set the array C
Stop
	B		Stop

; Set_Length - sets the length of the array by getting the binary equivalent
; of the two-digit BCD number in R1 and store it in Length in the memory
; Note Length is a one byte value defined in the RAM.

; TO DO: Write the Set_Length subroutine here
Set_Length
	PUSH	{LR,R1,R2,R3,R4}
	AND		R2,R1,#0x0F	;units into R2
	LSR		R3,R1,#4	;tens into R3
	LSL		R4,R3,#3	;x8
	ADD		R4,R3		;x9
	ADD		R4,R3		;x10
	
	ADD		R4,R2	;result
	LDR		R3,=Length
	STRB	R4,[R3]	;store the result in length
	
	POP 	{LR,R1,R2,R3,R4}
	BX		LR


; Clear_All_Arrays - initializes the N possible elements of the arrays to zeros 
Clear_Arrays
	PUSH	{LR, R2, R0}
	; clear the array A
	LDR		R0, =ArrayA		; R0 gets the array address 
	MOV		R2, #N			; R2 gets the max array size
	BL		Reset_Array		; Reset_Array is a subroutine that takes the base
							; address of the array to be cleared in R0
							; and the max number of elements N in R2 and clears the array
	
	; clear the array	;
	; TO DO: use the subroutine Reset_Array to clear the other
	LDR		R0, =ArrayB		 
	MOV		R2, #N			
	BL		Reset_Array

	LDR		R0, =ArrayC		; R0 gets the array address 
	MOV		R2, #N			; R2 gets the max array size
	BL		Reset_Array	
	; two arrays ArrayB and ArrayC
	POP		{LR, R2, R0}	
	BX		LR

; Reset_Array - initializes all elements of the array to zeros
;	input: R2 <- length of the array
;	R0 <- address of the array
;*************************************************************************************
Reset_Array
	PUSH	{R0-R2, LR}			; save the value of relevant registers
	MOV		R1, #0x00			; zeros to clear the array
Reset_Again
	SUBS	R2, #1
	BEQ		Reset_done
	STRB	R1, [R0]		   ; clear the element
	ADD		R0, #1				; point to the next element
	B	Reset_Again	;

Reset_done
	STRB	R1, [R0]		; clear the last element
	POP 	{R0-R2, LR}			; restore the value of pushed registers
	BX		LR

; Set_ArrayA - sets the array A
Set_ArrayA
	PUSH	{R0-R4, LR}		; push relevant registers
	; TO DO: R0 points to ArrayA's first element (base address)
	LDR		R0,=ArrayA

	; TO DO: R1 has the index - initialize it to 0
	MOV		R1,#0
	
	; TO DO: Load the length of the array in R4 (two instructions)
	LDR		R3,=Length
	LDRB	R4,[R3]

Set_ArrayA_Again
	; TO DO: Add 5 to the current index and store the result in R2
	ADD		R2,R1,#5
	STRB	R2, [R0,R1]		; ArrayA[i] <- i + 5
	; TO DO: Incremet the current index by 1
	ADD		R1,#1
	; TO DO: Compare the new index with the value of Length in R4
	CMP		R1,R4
	; TO DO: Branch to Set_ArrayA_Again if the loop condition is true	
	BLO		Set_ArrayA_Again
	
	POP		{R0-R4, LR}	; restore the registers	
	BX		LR

; Set_ArrayB - sets the array B
Set_ArrayB
	PUSH	{R0-R4, LR}		; push relevant registers
	; TO DO: Set R0 to point to the base address of ArrayB
	LDR		R0,=ArrayB
	; TO DO: R1 is the current index - initialize it to 0
	MOV		R1,#0
	; TO DO: Load the length of the array in R4 (two instructions)
	LDR		R3,=Length
	LDRB	R4,[R3]
	
Set_ArrayB_Again
	MOV		R2, R1			; R2 <- R1 (index)
	LSRS	R2, #1			; pushing the rightmost bit in the carry flag
	BCC		Even_index		; carry clear implies an even index
	; TO DO: Compute R2=2*current index
	LSL		R2,R1,#1
	STRB	R2, [R0, R1]	; ArrayB[i] <- 2 * i, i is odd

Even_index
	; TO DO: Increment the current index by 1
	ADD		R1,#1
	; TO DO: Compare the new index with the value of Length in R4
	CMP		R1,R4
	; TO DO: Branch to Set_ArrayB_Again if the loop condition is true
	BLO 	Set_ArrayB_Again
	
	POP		{R0-R4, LR}
	BX		LR

; Set_ArrayC - sets the array C
;*************************************************************************************
Set_ArrayC
	PUSH	{R0-R5, LR}
							
	; TO DO: Store the base address of arrays ArrayA, ArrayB and ArrayC
	; in memory locations PtrA, PtrB and PtrC respectively. This step requires 
	; a number of instructions.
	LDR		R0,=ArrayA
	LDR		R4,=PtrA
	STR		R0,[R4]
		
	LDR		R0,=ArrayB
	LDR		R2,=PtrB
	STR		R0,[R2]

	LDR		R0,=ArrayC
	LDR		R3,=PtrC
	STR		R0,[R3]



	; TO DO: Use R1 as the current iteration index- initialize it to 0
	MOV		R1,#0
	
Set_ArrayC_Again
	LDR		R0, =PtrA		; Load the current element from ArrayA
	LDR		R4, [R0]		; in R2. First fetch the pointer from PtrA in R4
	LDRB	R2, [R4]		; then get the element in R2
	
	ADD		R4, #1			; Update pointer for ArrayA
	STR		R4, [R0]
	
	; TO DO: Use the same approach as above to load the current element
	; from ArrayB into R5 and update pointer PtrB for the next element (5 instructions)
	LDR		R0,=PtrB
	LDR		R4,[R0]
	LDRB	R5,[R4]
	ADD		R4,#1
	STR		R4,[R0]
	
	; TO DO: Add the current element of ArrayB to the current element 
	; of ArrayA and keep the result in R2
	ADD		R2,R2,R5
	
	; TO DO: Use pointer PtrC to write the value in R2 into the current element of
	; ArrayC and update PtrC for the next element (5 instructions)
	LDR		R0,=PtrC
	LDR		R3,[R0]
	STR		R2,[R3]
	ADD		R3,#1
	STR		R3,[R0]
	
	
	LDR		R0, =Length
	LDRB	R4, [R0]
	; TO DO: Increment the current index by 1
	ADD		R1,#1
	; TO DO: Compare the new index with the value of Length in R4
	CMP		R1,R4
	; TO DO: Branch to Set_ArrayC_Again if the loop condition is true
	BLO		Set_ArrayC_Again
	
	POP		{R0-R5, LR}
	BX		LR
	
	END