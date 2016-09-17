%define SYSCALL_WRITE 4


		mov		eax, SYSCALL_WRITE			; write function
		mov		ebx, STDOUT					; Arg1: file descriptor
		mov		ecx, msg1					; Arg2: addr of message
		mov		edx, len1					; Arg3: length of the message
		int		080h						; Ask kernel to write