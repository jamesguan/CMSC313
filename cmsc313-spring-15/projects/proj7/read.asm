%define STDIN 0
%define SYSCALL_READ  3

		section .text
		global read
		
read:

		mov		eax, SYSCALL_READ			; read function
		mov		ebx, STDIN
		mov		ecx, buf
		mov		edx, BUFLEN
		int		080h