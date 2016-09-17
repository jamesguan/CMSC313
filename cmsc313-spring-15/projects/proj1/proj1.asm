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
%define UPCALEN 11					; Specifies how many numbers to be read

				SECTION .data	;initialized data

msg1:			db "Enter 12-Digit UPC: "		; user prompt
len1:			equ $-msg1				; length of first message

msg4:   		db 10, "Read error", 10	; error message
len4:   		equ $-msg4				; error message length

valid_msg:		db "This is a valid number."
valid_len:		equ $-valid_msg

invalid_msg:	db "This is NOT a valid UPC number."
invalid_len:


				SECTION .bss			; uninitialized data
				
buf:			resb BUFLEN				; buffer for read
newstr:			resb BUFLEN				; converted string
rlen:			resb 4					; length,


				SECTION .text					; asm code
				global	_start					; let loader see entry point

_start: nop								; Entry point. main basically
start:									; address for gdb
		; prompt user for input
		;
		mov		eax, SYSCALL_WRITE			; write function
		mov		ebx, STDOUT					; Arg1: file descriptor
		mov		ecx, msg1					; Arg2: addr of message
		mov		edx, len1					; Arg3: length of the message
		int		080h						; Ask kernel to write
		
		; read user input
		;
		mov		eax, SYSCALL_READ			; read function
		mov		ebx, STDIN
		mov		ecx, buf
		mov		edx, BUFLEN
		int		080h
		; error check
		;
		mov	[rlen], eax				; save length of string read
		cmp		eax, 0					; check if any chars read
		jg		read_OK					; >0 chars read = OK
		mov		eax, SYSCALL_WRITE		; ow print error messsage
		mov		ebx, STDOUT
		mov		ecx, msg4
		mov		edx, len4
		int		080h
		jmp		exit					; skip over rest
		
read_OK:

		;Loop for upper case conversion
		; assuming rlen > 0
		;
		
L1_init:
		mov		ecx, UPCALEN	; initialize count
		mov		esi, buf		; point to start of buffer
		mov		al, 0			; to hold numbers from input
		mov		bl, 0			; to hold sum of even indexed numbers
		mov		ah, 0			; to serve as a boolean and hold check_sum at the end
		mov		bh, 0			; holds the sum of the odd indexed numbers
		
L1_top:
		mov		al, [esi]		; grab number to al
		inc		esi				; increment
		sub		al, '0'
		cmp		ah, 0			; if even indexed go add the evens
		je		L1_addEven
		cmp		ah, 1			; if odd indexed go add the odds
		je		L1_addOdd
		jmp		exit			; not needed but just to be safe
		
L1_addEven:
		mov		ah, 1			; flip the boolean so it goes to odd next
		add		bl, al			; add the number 3 times
		add		bl, al
		add		bl, al
		cmp		bl, 9			; check if the number is >= 10, if so jump to subtract by 10
		ja		L1_subtractTenEven
		jmp		L1_cont			; if successful, continue
L1_addOdd:
		mov		ah, 0			; flip the boolean so it goes to the even next
		add		bh, al			; add them all together
		cmp		bh, 9			; if it is >= 10, subtract 10
		ja		L1_subtractTenOdd
		jmp		L1_cont			; continue
		
L1_subtractTenEven:
		sub		bl, 10			; subtract by 10 from even sum
		cmp		bl, 10			; if it is still < 10, continue 
		jb		L1_cont			
		sub		bl, 10			; subtract again if it was still >= 10
		jmp		L1_cont
		
L1_subtractTenOdd:
		sub		bh, 10			; simple subtraction for the odd sum
		jmp		L1_cont
		
L1_subtractTenFinal:
		sub		ah, 10			; does the final subtraction of 10 at the end
		cmp		ah, 0			; if sum of odds and evens are >= 10
		ja		L1_subtractFromTen	; does final subtraction from 10
		jmp		L1_checkVictory
		
L1_subtractFromTen:
		mov		bl, 10			; does the final subtraction from 10 to get check-digit
		sub		bl, ah
		mov		ah, bl
		jmp		L1_checkVictory
L1_cont:
		inc		edi				; increment and decrement for the loop
		dec		ecx
		jnz		L1_top
		add		bh, bl			; if loop is over add the sums together
		mov		ah,	bh
		cmp		ah, 9			; if the number is >= 10, do final 10 subtraction
		ja		L1_subtractTenFinal
		jmp		L1_subtractFromTen	; if number is fine, do final subtraction from 10
		
		
L1_checkVictory:
		mov		al, [esi]		; checks if the check-digit is equal to the last number 
		inc		esi				; and print their respective messages
		sub		al,	'0'
		cmp		ah, al
		je		L1_printVictory
		jmp		L1_printInvalid

L1_printVictory:
		mov		eax, SYSCALL_WRITE			; write message for valid UPC-A number
		mov		ebx, STDOUT
		mov		ecx, valid_msg
		mov		edx, valid_len
		int		080h
		jmp		exit
		
L1_printInvalid:
		mov		eax, SYSCALL_WRITE			; write message for invalid UPC-A number
		mov		ebx, STDOUT
		mov		ecx, invalid_msg
		mov		edx, invalid_len
		int		080h
		
		; final exit
		;
exit:	mov		eax, SYSCALL_EXIT			; exit function
		mov		ebx, 0						; exit code, 0=normal
		int		080h						; ask kernel to take over
