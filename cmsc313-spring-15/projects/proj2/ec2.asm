; File: proj1.asm last updated 02/19/2015
; Author: James Guan
; Class: CMSC 313
; Teacher: Wiles
; Check for valid 12-digit UPC-A number
; Description:
;	This program calculates the UPC-A as follows:
;	1. Add all the even numbers together, adding each one
;		three times and then subtracting by 10 until it 
;		goes below 10 and repeat that process until all the 
;		even indexed values are added together
;	2. Then the program adds all the odd digit numbers together,
;		subtracting 10 every time the sum gets above 10.
;	3. Adds both the even and odd sums together, and subtracts by 10,
;		until it goes below 10, and then subtract that number from 10
;		to get the check-digit. No DIV or MUL was used in this process.
;
; Assemble using NASM:  nasm -f elf -g -F stabs proj1.asm
; Link with ld:  ld -o proj1 proj1.o -melf_i386
;

; Defines
%define STDIN 0
%define STDOUT 1
%define SYSCALL_EXIT  1
%define SYSCALL_READ  3
%define SYSCALL_WRITE 4
%define BUFLEN 256

				SECTION .data	;initialized data
msg1:			db "Enter 12-Digit UPC FUCK: "		; user prompt
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


        ; Loop for upper case conversion
        ; assuming rlen > 0
        ;
L1_init:
        mov     ebx, [rlen]             ; initialize count
        mov     esi, buf                ; point to start of buffer
		jmp		L1_getNumbers
		
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
		
L1_inc2:

		inc esi
		dec	ebx
		cmp		ebx, 0
		je L1_print
		jmp L1_checkByte2

		
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
		
L1_add:
		pop 	ecx
		pop 	edx
		add 	ecx, edx
		push 	ecx
		jmp		L1_inc2
		
L1_sub:

		pop 	edx
		pop 	ecx	
		sub 	ecx, edx
		push 	ecx
		jmp		L1_inc2

L1_div:

		mov		eax, 0
		pop 	edx
		pop 	ecx
		idiv 	ecx
		mov		ecx, [eax]
		push 	ecx
		jmp		L1_inc2

L1_mul:

		pop 	ecx
		pop 	edx
		imul	ecx, edx
		push 	ecx
		jmp		L1_inc2
		
L1_getNumbers:

		push	esi
		call	atoi
		
		add		esp, 4
		push	eax
		
		;jmp		exit
		jmp		L1_checkByte1
		;push	print_str
		;call	printf
		;add	esp, 8					; Remove message and previous atoi conversion from the stack

		;inc		esi
		
L1_inc:
		inc		esi
		dec		ebx
		cmp		ebx, 0
		je		L1_print
		jmp		L1_checkByte1
		
L1_print:

		;mov     esi, numbers			; Get address of numbers string
        ;push	esi						; Push address onto stack
        ;call	atoi					; Call atoi
        								; The resulting number is in eax
        ;add		esp, 4					; Remove esi from the stack
        ;push	eax						; Push the result of atoi onto the stack
        push	print_str				; Push the address of the formatted string onto the stack
        call	printf					; Call printf on the string
        								; Output should be: Returned number: 52
        add		esp, 8					; Remove message and previous atoi conversion from the stack


exit:	mov		eax, SYSCALL_EXIT			; exit function
		mov		ebx, 0						; exit code, 0=normal
		int		080h						; ask kernel to take over