; Author: James Guan
; Class: CMSC 313
; Professor: Andrew Wiles
; Version Date: 4/16/2015 at 9:07PM US Eastern
; Description: This is a replacement for the 
;		some stdlib c function libraries
;		_start
;
;		int strcmp(const char *buf1, const char *buf2)
;		returns:
;			-1 when buf1 < buf2
;			0 when buf1 == buf2
;			1 when buf1 > buf2
;			
;		int read(int fd, void *buffer, unsigned int size);
;		return: 
;				Length of the string
;
;		int write(int fd, const void *buffer, unsigned int size);
;		returns:
;				Not sure
;  

%define SYSCALL_EXIT  1
%define SYSCALL_READ  3
%define SYSCALL_WRITE 4
%define BUFLEN 256

				SECTION .bss			; uninitialized data
				
				extern	main

				SECTION .text
				global _start


_start:

				call main				; Call's the c program's main
				
				mov		ebx, eax					; exit code, 0=normal
				mov		eax, SYSCALL_EXIT			; exit function
				int		080h						; ask kernel to take over
				
;		int strcmp(const char *buf1, const char *buf2)
;		returns:
;			-1 when buf1 < buf2
;			0 when buf1 == buf2
;			1 when buf1 > buf2
;			
				global strcmp

strcmp:
				push	ebp				; Setting up the stack
				mov		ebp, esp
				
				push 	esi				; Save these registers for later use
				push	ecx
				push 	ebx
				
				mov		esi, [ebp + 8]	; Get address of string 1
				mov		edi, [ebp + 12]	; Get address of string 2
				
compare:		
				mov		al, [esi]
				mov		bl, [edi]
				cmp		al, bl				; compare each character from string 1 and 2
				jne		compare_not_equal	; if it's not equal, check for greater and less
				cmp		al, bl
				je		equal				; go to equal if it is equal
				jmp		increment			; jump to increment to go to the next char of string
increment:

				inc		esi					; next char of string 1
				inc		edi					; next char of string 2
				jmp		compare
				
				
compare_not_equal:
				cmp		al, bl
				jg		greater_than
				jmp		less_than

equal:
				;cmp		al, 0				; check for null terminator
				;mov		eax, 0				; returns 0 for equal
				cmp		al, 0
				je		null_terminating
				cmp		bl, 0
				je		less_than
				
				jmp 	increment
				
null_terminating:

				cmp		al, bl
				jne		greater_than
				jmp		return_equal

return_equal:	
				
				mov 	eax, 0
				jmp 	finish
				
less_than:			
				mov		eax, -1				; returns -1 for less than
				jmp 	finish
greater_than:
				mov		eax, 1				; returns 1 for greater than
				jmp		finish				
				
finish:			
				pop		ebx				; Reset the registers
				pop		ecx
				pop		esi
				mov		esp, ebp		; Stack frame
				pop		ebp
				ret
				
;		int read(int fd, void *buffer, unsigned int size);
;		return: 
;				Length of the string
;

				global read
		
read:
				push	ebp				; Setting up the stack
				mov		ebp, esp
				
				mov		eax, SYSCALL_READ			; read function
				mov		ebx, [ebp+8]				; arg1: Descriptor
				mov		ecx, [ebp+12]				; arg2: address of message
				mov		edx, [ebp+16]				; arg3:	length of message
				int		080h						; interrupt for read
				
				mov		esp, ebp
				pop		ebp							
				ret
	
;		int write(int fd, const void *buffer, unsigned int size);
;		returns:
;				Not sure

				global write
				
write:

				push	ebp				; Setting up the stack
				mov		ebp, esp
				
				mov		eax, SYSCALL_WRITE			; write function
				mov		ebx, [ebp+8]					; Arg1: file descriptor
				mov		ecx, [ebp+12]					; Arg2: address of message
				mov		edx, [ebp+16]					; Arg3: length of the message
				int		080h						; Ask kernel to write
				
				mov		esp, ebp
				pop		ebp
				ret