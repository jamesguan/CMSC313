; File: extracredit.asm last updated 02/26/2015
; Author: James Guan
; Class: CMSC 313
; Teacher: Wiles
; Booth's Algorithm
; Description:
;	This will multiply two 32-bit integers into a 64-bit product
;	This works as long as you have at least 1 even number
;	for some odd reason.

; Defines
%define STDIN 0
%define STDOUT 1
%define SYSCALL_EXIT  1
%define SYSCALL_READ  3
%define SYSCALL_WRITE 4
%define BUFLEN 256

				SECTION .data	;initialized data
msg1:			db "Enter first number to multiply: ", 0		; user prompt
len1:			equ $-msg1				; length of first message

msg2:			db "Enter second number to multiply: ", 0	; user prompt
len2:			equ $-msg2				; length of first message

msg4:   db 10, "Read error", 10         ; error message
len4:   equ $-msg4
				
print_str:	db "Returned number: %d", 10, 0

print_str64:	db "Returned number: %lld", 10, 0
										; Format string for printf
										; Note the use of the newline (10) and NULL (0)
										; characters.

				SECTION .bss			; uninitialized data
				
buf1:			resb BUFLEN				; buffer for read
rlen1:			resb 4
rlen2:			resb 4
buf2:			resb BUFLEN

num1:			resb 4
num2:			resb 4

multiplicand:	resb 4

upper:			resb 4
lower:			resb 4

previous:		resb 4
current:		resb 4

product:		resb 8

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
        mov     ecx, buf1                ; Arg 2: address of buffer
        mov     edx, BUFLEN             ; Arg 3: buffer length
        int     080h

        ; error check
        ;
        mov     [rlen1], eax             ; save length of string read
        cmp     eax, 0                  ; check if any chars read
        jg      read_OK                 ; >0 chars read = OK
		mov     ebx, STDOUT
        mov     ecx, msg4
        mov     edx, len4
        int     080h
        jmp     exit                    ; skip over rest
		
read_OK:

                ; prompt user for input
        ;
        mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
        mov     ecx, msg2               ; Arg2: addr of message
        mov     edx, len2               ; Arg3: length of message
        int     080h                    ; ask kernel to write

        ; read user input
        ;
        mov     eax, SYSCALL_READ       ; read function
        mov     ebx, STDIN              ; Arg 1: file descriptor
        mov     ecx, buf2                ; Arg 2: address of buffer
        mov     edx, BUFLEN             ; Arg 3: buffer length
        int     080h

        ; error check
        ;
        mov     [rlen2], eax             ; save length of string read
        cmp     eax, 0                  ; check if any chars read
        jg      read_OK2                 ; >0 chars read = OK
		mov     ebx, STDOUT
        mov     ecx, msg4
        mov     edx, len4
        int     080h
        jmp     exit                    ; skip over rest
        ; Initialize for looping
        ;
		
read_OK2:


L1_init:
		mov		eax, 0
		mov		[product], eax
		
		mov		eax, 0
		mov		[upper], eax
		mov		[previous], eax
		
		mov		ecx, buf1
		push	ecx
		
		call	atoi
		
		mov		ecx, eax
		
		add		esp, 4
		
		mov		[num1], ecx
		
		;push	ecx
		
		;push	print_str
		
		;call	printf
		
		;add		esp, 8
		
		mov		ecx, buf2
		push	ecx
		
		call	atoi
		
		mov		ecx, eax
		
		add		esp, 4
		
		mov		[num2], ecx
		mov		[lower], ecx
		
		;push	ecx
		
		;push	print_str
		
		;call	printf
		
		;add		esp, 8
		
		mov		ecx, [num1]
		
		mov		[multiplicand], ecx
		; Skips all the bytes that have a number
		; because a number has already been pushed into the stack
		; by atoi and we are just incrementing through that same number
		; until we hit an operand or space to denote that a new number
		; needs to be found
		
		mov		dl, 0
		
check_first_bit:
		mov		eax, [lower]
		and 	eax, 1
		mov		[current], eax
		cmp		eax, 1
		je		check_previous_1
		jmp		check_previous_0
		
check_previous_1:
		
		mov		eax, [previous]
		cmp		eax, 0
		je		subtract
		jmp		increment
		
check_previous_0:
		mov		eax, [previous]
		cmp		eax, 1
		je		addition
		jmp		increment
		
right_shift:
		mov		eax, [lower]
		shr		eax, 1
		mov		[lower], eax
		
		mov		ecx, [upper]
		mov		ebx, ecx
		and		ebx, 1
		cmp		ebx, 1
		je		right_shift1
		jmp		right_shift0
		
right_shift0:
		mov		ecx, [upper]
		sar		ecx, 1
		mov		[upper], ecx
		jmp		check_first_bit
right_shift1:
		mov		eax, [lower]
		or		eax, 7e37be2022c091
		mov		[lower], eax
		mov		ecx, [upper]
		sar		ecx, 1
		mov		[upper], ecx
		jmp		check_first_bit
		
;right_shift_rotation:	
		;mov		ecx, [lower]
		;shr		ecx, 1
		;mov		[lower], ecx
		
;check_lower:
		
		;mov		ecx, [lower]
		;and		ecx, 3
		;cmp		ecx, 2
		;je		subtract
		;cmp		ecx, 1
		;je		addition
		;jmp		increment
		
addition:
		mov		eax, [upper]
		mov		ecx, [multiplicand]
		
		add		eax, ecx
		
		mov		[upper], eax
		jmp		increment
		
subtract:

		mov		eax, [upper]
		mov		ecx, [multiplicand]
		
		sub		eax, ecx
		
		mov		[upper], eax
	
		jmp		increment

		
increment:
		inc 	dl
		
		mov		ebx, [current]
		mov		[previous], ebx
		cmp		dl, 32
		jg		print
		jmp 	right_shift
print:
		
		mov		eax, [upper]
		mov		ebx, [lower]
		
		push	eax
		push	ebx

	
		
        push	print_str64				; Push the address of the formatted string onto the stack
        call	printf					; Call printf on the string
        								; Output should be: Returned number: 52
        add		esp, 12					; Remove message and previous atoi conversion from the stack


exit:	mov		eax, SYSCALL_EXIT			; exit function
		mov		ebx, 0						; exit code, 0=normal
		int		080h						; ask kernel to take over