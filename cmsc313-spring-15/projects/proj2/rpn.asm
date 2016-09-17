; File: proj2.asm last updated 02/26/2015
; Author: James Guan
; Class: CMSC 313
; Teacher: Wiles
; Post fix calculator
; Description:
;	The assignment is to write an RPN (Post fix) calculator in assembly language.  
;	
; Assemble using NASM:  nasm -f elf -g -F stabs proj2.asm
; Link with ld:  ld -melf_32 -o proj2 proj2.o
;

; Defines
%define STDIN 0
%define STDOUT 1
%define SYSCALL_EXIT  1
%define SYSCALL_READ  3
%define SYSCALL_WRITE 4
%define BUFLEN 256

				SECTION .data	;initialized data
msg1:			db "Expression to calculate: "		; user prompt
len1:			equ $-msg1				; length of first message

msg4:   db 10, "Read error", 10         ; error message
len4:   equ $-msg4
				
print_str:	db "Returned number: %d", 10, 0
										; Format string for printf
										; Note the use of the newline (10) and NULL (0)
										; characters.

				SECTION .bss			; uninitialized data
				
buf:			resb BUFLEN				; buffer for read
rlen:			resb 4					; length
extern printf							; Request access to printf
extern atoi								; Request access to atoi
				
				SECTION .text					; asm code
				
				global	main			; let loader see entry point
				
main: nop								; Entry point. main basically							; address for gdb
                ; prompt user for input
        ;
        mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
        mov     ecx, msg1               ; Arg2: addr of message
        mov     edx, len1               ; Arg3: length of message
        int     080h                    ; ask kernel to write

        ; read user input
        ;
        mov     eax, SYSCALL_READ       ; read function
        mov     ebx, STDIN              ; Arg 1: file descriptor
        mov     ecx, buf                ; Arg 2: address of buffer
        mov     edx, BUFLEN             ; Arg 3: buffer length
        int     080h

        ; error check
        ;
        mov     [rlen], eax             ; save length of string read
        cmp     eax, 0                  ; check if any chars read
        jg      read_OK                 ; >0 chars read = OK
		mov     ebx, STDOUT
        mov     ecx, msg4
        mov     edx, len4
        int     080h
        jmp     exit                    ; skip over rest
read_OK:


        ; Initialize for looping
        ;
L1_init:
        mov     ebx, [rlen]             ; initialize count
        mov     esi, buf                ; point to start of buffer
		jmp		L1_getNumbers
		
		; Skips all the bytes that have a number
		; because a number has already been pushed into the stack
		; by atoi and we are just incrementing through that same number
		; until we hit an operand or space to denote that a new number
		; needs to be found
L1_checkByte1:
		
		mov 	dl, [esi]
		cmp		dl, 43
		je		L1_add
		cmp		dl, 45
		je		L1_sub
		cmp		dl, 42
		je		L1_mul
		cmp		dl, 47
		je		L1_div
		cmp		dl, 32
		je		L1_inc2
		cmp		dl, 48
		je		L1_inc
		cmp		dl, 49
		je		L1_inc
		cmp		dl, 50
		je		L1_inc
		cmp		dl, 51
		je		L1_inc
		cmp		dl, 52
		je		L1_inc
		cmp		dl, 53
		je		L1_inc
		cmp		dl, 54
		je		L1_inc
		cmp		dl, 55
		je		L1_inc
		cmp		dl, 56
		je		L1_inc
		cmp		dl, 57
		je		L1_inc
		jmp		L1_print
		
		; This is the second increment where it points to checkByte2
		; for the purpose of incrementing for that function
		;
		;
		
L1_inc2:

		inc 	esi
		dec		ebx
		cmp		ebx, 0
		je 		L1_print
		jmp 	L1_checkByte2

		; Loops through checkByte2 until it finds a new number or handles
		; other operands.
		;
		;
		
L1_checkByte2:
		
		mov 	dl, [esi]
		cmp		dl, 43
		je		L1_add
		cmp		dl, 45
		je		L1_sub
		cmp		dl, 42
		je		L1_mul
		cmp		dl, 47
		je		L1_div
		cmp		dl, 32
		je		L1_inc2
		cmp		dl, 48
		je		L1_getNumbers
		cmp		dl, 49
		je		L1_getNumbers
		cmp		dl, 50
		je		L1_getNumbers
		cmp		dl, 51
		je		L1_getNumbers
		cmp		dl, 52
		je		L1_getNumbers
		cmp		dl, 53
		je		L1_getNumbers
		cmp		dl, 54
		je		L1_getNumbers
		cmp		dl, 55
		je		L1_getNumbers
		cmp		dl, 56
		je		L1_getNumbers
		cmp		dl, 57
		je		L1_getNumbers
		jmp		L1_print
		
		; Handles the addition operand
		;
		;
		
L1_add:
		pop 	ecx
		pop 	edx
		add 	ecx, edx
		push 	ecx
		jmp		L1_inc2
		
		; Handles the subtraction operand
		;
		;
		
L1_sub:

		pop 	edx
		pop 	ecx	
		sub 	ecx, edx
		push 	ecx
		jmp		L1_inc2

		; Handles the idiv operand 
		;
		;
L1_div:

		
		mov		edx, 0
		;pop 	eax
		;pop 	edx
		pop 	ecx
		pop		eax
		idiv 	ecx
		;mov		ecx, [eax]
		push 	eax
		jmp		L1_inc2
		
		; Handles the imul operand
		;
		;

L1_mul:

		pop 	ecx
		pop 	edx
		imul	ecx, edx
		push 	ecx
		jmp		L1_inc2
		
		
		; This pushes fresh numbers into the stack using atoi to convert
		; from ascii to numbers
		; 
		;
L1_getNumbers:

		push	esi
		call	atoi
		
		add		esp, 4
		push	eax
		
		jmp		L1_checkByte1
		
		; increment function to increment for first checkByte
		
L1_inc:
		inc		esi
		dec		ebx
		cmp		ebx, 0
		je		L1_print
		jmp		L1_checkByte1
		
		; prints the final output
		
L1_print:

        push	print_str				; Push the address of the formatted string onto the stack
        call	printf					; Call printf on the string
        								; Output should be: Returned number: 52
        add		esp, 8					; Remove message and previous atoi conversion from the stack


exit:	mov		eax, SYSCALL_EXIT			; exit function
		mov		ebx, 0						; exit code, 0=normal
		int		080h						; ask kernel to take over