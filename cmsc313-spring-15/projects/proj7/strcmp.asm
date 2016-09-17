;		int strcmp(const char *buf1, const char *buf2)
;		returns:
;			-1 when buf1 < buf2
;			0 when buf1 == buf2
;			1 when buf1 > buf2
;			

				SECTION .data	;initialized data

				SECTION .text
				global strcmp

strcmp:
buf1 = 8
buf2 = buf1 + 4
				push	ebp				; Setting up the stack
				mov		ebp, esp
				
				push 	esi				; Save these registers for later use
				;push	ecx
				push 	ebx
				
				mov		esi, buf1[ebp]	; Get address of string 1
				mov		edi, buf2[ebp]	; Get address of string 2
				
compare:		
				mov		al, [esi]
				mov		bl, [edi]
				cmp		al, bl
				jne		compare_not_equal
				cmp		al, bl
				je		equal
				jmp		increment
increment:

				inc		esi
				inc		edi
				jmp		compare
				
				
compare_not_equal:
				cmp		al, bl
				jg		greater_than
				mov		eax, -1
				jmp 	finish
equal:
				mov		eax, 0
				jmp 	finish

greater_than:
				mov		eax, 1
				jmp		finish
				
finish:			
				pop		ebx				; Reset the registers
				;pop		ecx
				pop		esi
				mov		esp, ebp		; Stack frame
				pop		ebp
				mov		eax, edi		; Store the return value
				ret