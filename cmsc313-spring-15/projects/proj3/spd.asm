; File: spd.asm last updated 03/10/2015
; Author: James Guan
; Class: CMSC 313
; Teacher: Wiles
;
; Description:
;	You have just been contracted by the Springfield Police Department (SPD)
;	to write software to assist his officers in the field.
;	You are to write a program that, upon entering a Springfield citizen’s name, 
;	outputs the dates and descriptions of any prior arrests.
;	
; Assemble using NASM:  nasm -f elf -g -F stabs spd.asm
; Link with ld:  ld -melf_i386 -o spd spd.o data.o
; or
; gcc -m32 -g -o spd spd.o data.o

; Defines
%define STDIN 0
%define STDOUT 1
%define SYSCALL_EXIT  1
%define SYSCALL_READ  3
%define SYSCALL_WRITE 4
%define BUFLEN 256

; Offsets for struct citizens
%define OFFSET_LAST_NAME 0
%define OFFSET_FIRST_NAME 20
%define OFFSET_NUM_ARRESTS 40
%define OFFSET_ARRESTS_PTR 44
%define OFFSET_NEXT 48

; Offsets for struct arrests
%define OFFSET_ARREST_YEAR	0
%define OFFSET_ARREST_MONTH 8
%define OFFSET_ARREST_DAY	12
%define OFFSET_ARREST_DESCRIPTION 16
%define SIZEOF_STRUCT_ARRESTS 56


				SECTION .data	;initialized data
				
extern citizens

currentPtr		dd 0	; Stores the address of the current citizens struct

currentArrestsPtr	dd 0	; Stores the memory address of the arrest struct

list:			db	"list", 0
listlen:		equ $-list

msg1:			db "Enter Citizen's Last Name: ", 0			; user prompt for last name
len1:			equ $-msg1

msg2:			db "Enter Citizen's First Name: ", 0		; user prompt for first name
len2:			equ $-msg2				; length of first message

msg3:			db "Unknown last name: ", 0
len3:			equ $-msg3


msg4:   db 10, "Read error", 10         ; error message
len4:   equ $-msg4

msg5:			db "Unknown name: ", 0
len5:			equ $-msg5				

msg6:			db "Arrest record for: ", 0		
len6:			equ $-msg6				

msg7:			db "Arrests: ", 10, 0	
len7:			equ $-msg7				

msg8:			db "No arrests.", 10, 0		
len8:			equ $-msg8				

new_line:		db 10, 0

dash:			db 45, 0

colon:			db 58, 32, 0

comma:			db	44, 32, 0

space:			db  32, 0

				SECTION .bss			; uninitialized data
				
last_name:		resb BUFLEN				; buffer for read last name
first_name:		resb BUFLEN				; buffer for read first name
temp_message:	resb BUFLEN
rlen1:			resb 4					; length1
rlen2:			resb 4					; length2

arrest_num:		resb 1		; a counter for the number of arrests 
							; to know how many arrest structs to go through

bool_continue	resb 1		; This is to jump back to listing the list when
							; a person has no arrests and the way
							; the program works is that it would normally
							; exit after printing that entry but this is
							; to flag when a list is occurring as to not
							; exit.
				
				SECTION .text					; asm code
				
				global	_start			; let loader see entry point
_start: nop								; Entry point. main basically							; address for gdb
                ; prompt user for input
        ;
        mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
        mov     ecx, msg1               ; Arg2: addr of message
        mov     edx, len1               ; Arg3: length of message
        int     080h                    ; ask kernel to write

read_User_Input1:

		; read user input
        ;
        mov     eax, SYSCALL_READ       ; read function
        mov     ebx, STDIN              ; Arg 1: file descriptor
        mov     ecx, last_name                ; Arg 2: address of buffer
        mov     edx, BUFLEN             ; Arg 3: buffer length
        int     080h

		
		mov		[rlen1], eax
		mov		ebx, list
		mov		eax, [rlen1]
		mov		ecx, last_name
		mov		edx, 4
		cmp		eax, 5
		je	check_list					; This will check if the user has
										; input the word "list"
		
continue_program:						; If it is not the list, continue prompting for first name
		mov		ecx, last_name
		mov		edx, citizens
		mov     ebx, citizens
		add		ebx, OFFSET_LAST_NAME
		
		call	check_Last_Name
		jmp		read_User_Input2
		
		
										; This will check if the user has
										; input the word "list"
check_list:
		mov	al, [ebx]
		mov	ah,	[ecx]
		
		cmp edx, 0
		je	print_list_setup			; if list was entered, set up to print
										; the list of arrest records
		
		and     al, 11011111b           ; convert to uppercase
		and     ah, 11011111b           ; convert to uppercase
		cmp	al, ah
		jne	print_Msg4
		
		inc	ebx
		inc	ecx
		
		sub edx, 1
		cmp ebx, byte 0
		jne	check_list
		
		jmp exit
		
print_list_setup:						; point to the first citizen
		
		mov byte [bool_continue], 1
		mov edx, citizens
		mov [currentPtr], edx
		
print_list:

		call	print_people
		call	prepare_print_arrests
		
print_list2:
		
		mov	ebx, [currentPtr]
		add ebx, OFFSET_NEXT
		mov	eax, [ebx]
		cmp eax, byte 0
		je	exit
		
		mov	[currentPtr], eax			; go to the next citizen
		
		jmp	print_list
		
read_User_Input2:

		; prompting for first name
        mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
		mov		ecx, msg2
        mov     edx, len2              ; Arg3: length of message
        int     080h                    ; ask kernel to write
		
		
		; read user input
        ;
        mov     eax, SYSCALL_READ       ; read function
        mov     ebx, STDIN              ; Arg 1: file descriptor
        mov     ecx, first_name             ; Arg 2: address of buffer
        mov     edx, BUFLEN           ; Arg 3: buffer length
        int     080h
		
		mov		[rlen2],	eax
		
		mov		edx, citizens
		mov     ebx, citizens + OFFSET_FIRST_NAME
		call	check_First_Name
		
start_printing:					; this function will call the necessary
								; functions that prints the arrest record

        call	print_people	; prints the person's name
		
		
		call 	prepare_print_arrests	; prints the person's arrest record
		
        ; error check
        ;
        ;mov     [rlen2], eax             ; save length of string read
        ;cmp     eax, 0                  ; check if any chars read
        ;jg      read_OK                 ; >0 chars read = OK
		;mov     ebx, STDOUT
        ;mov     ecx, msg4
        ;mov     edx, len4
        ;int     080h
        jmp     exit                    ; skip over rest
		
print_people:
		mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
        mov     ecx, msg6   ; Arg2: addr of message
        mov     edx, len6              ; Arg3: length of message
        int     080h                    ; ask kernel to write
		
		; prints the last name
		mov     eax, [currentPtr]   
		add		eax, OFFSET_LAST_NAME
		call	print
		
		; prints a comma
		mov		eax, comma
		call	print
		
		; prints the first name
		mov     eax, [currentPtr]   
		add		eax, OFFSET_FIRST_NAME
		call	print
		
		; prints a new line
		mov		eax, new_line
		
		call	print
		
		mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
        mov     ecx, msg7   ; Arg2: addr of message
        mov     edx, len7               ; Arg3: length of message
        int     080h                    ; ask kernel to write
		
		ret
		
		
prepare_print_arrests: 		; sets up for printing the arrest struct data
		mov		eax, [currentPtr]
		mov		cl,  [eax + OFFSET_NUM_ARRESTS]
		cmp		cl, 0
		je		print_no_arrest
		
		
		mov		byte [arrest_num], cl
		call	print_arrests
		ret
	
print_no_arrest:			; this function just prints the no arrests message

		mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
        mov     ecx, msg8   ; Arg2: addr of message
        mov     edx, len8              ; Arg3: length of message
		int     080h                    ; ask kernel to 
		
		cmp	byte [bool_continue], 1
		je	print_list2
		jmp exit
		
		; this function does the actual printing of the arrests struct
print_arrests:
		
		
		mov		ebx, [currentPtr]
		add		ebx, OFFSET_ARRESTS_PTR
		mov		eax, [ebx]
		add		eax, [currentArrestsPtr]
		add		eax, OFFSET_ARREST_YEAR
		call	print
		
		mov		eax, dash
		
		call 	print
		mov		ebx, [currentPtr]
		add		ebx, OFFSET_ARRESTS_PTR
		mov		eax, [ebx]
		add		eax, [currentArrestsPtr]
		add		eax, OFFSET_ARREST_MONTH
		
		call	print
		
		mov		eax, dash
		
		call	print
		
		mov		ebx, [currentPtr]
		add		ebx, OFFSET_ARRESTS_PTR
		mov		eax, [ebx]
		add		eax, [currentArrestsPtr]
		add		eax, OFFSET_ARREST_DAY
		
		call	print
		
		mov		eax, colon
		
		call	print
		
		mov		ebx, [currentPtr]
		add		ebx, OFFSET_ARRESTS_PTR
		mov		eax, [ebx]
		add		eax, [currentArrestsPtr]
		add		eax, OFFSET_ARREST_DESCRIPTION
			
		call	print
		
		mov		eax, new_line
		
		call	print
		
		sub		byte[arrest_num], 1
		
		; moves the pointer to the next arrest struct
		mov		eax, [currentArrestsPtr]
		add		eax, SIZEOF_STRUCT_ARRESTS
		mov		[currentArrestsPtr], eax
		
		cmp		byte [arrest_num], 0
		jne		print_arrests
		
		mov	 dword [currentArrestsPtr], 0 ; reset the arrests ptr for next
											; citizen arrest struct print
		
		ret
		
		; This will compare the last name with the citizen's structs
		; and it would come back if it matches, or else it will print
		; an error message and exit the program
check_Last_Name:
		
		mov		al, [ebx]
		mov 	ah, [ecx]
		
		cmp		ah, 10
		jne		check_Last_Name_Equal
		
		ret
		
		; compares the letters 1 by 1 between the input last name
		; and the data from citizen last names
check_Last_Name_Equal:
		and     al, 11011111b           ; convert to uppercase
		and     ah, 11011111b           ; convert to uppercase
		cmp		al, ah
		jne		check_Next_Person_Name
		
		inc		ebx
		inc 	ecx
		
		jmp 	check_Last_Name
		
		; moves the pointer ahead to check the next citizen in the data
check_Next_Person_Name:
		mov edx, [edx + OFFSET_NEXT]
		mov ebx, edx
		add	ebx, OFFSET_LAST_NAME
		mov ecx, last_name
		
		cmp ebx, byte 0
		jne	check_Last_Name
		jmp print_Msg3

		; does almost exactly what check_Last_Name does except 
		; it will also check the last name again to confirm
check_First_Name:
		mov		al, [ebx]
		mov 	ah, [ecx]
		cmp		ah, 10
		jne		check_First_Name_Equal
		
		mov		[currentPtr], edx
		mov		ecx, last_name
		mov		ebx, [currentPtr]
		call check_Last_Name_Again
		ret
		
		; checks the equality between the first name 
check_First_Name_Equal:
		and     al, 11011111b           ; convert to uppercase
		and     ah, 11011111b           ; convert to uppercase
		cmp		al, ah
		jne		check_Next_Person_First_Name
		
		inc		ebx
		inc 	ecx
		
		jmp 	check_First_Name
		
		; goes to the next citizen's struct
check_Next_Person_First_Name:

		
		mov edx, [edx + OFFSET_NEXT]
		mov ebx, edx
		cmp ebx, byte 0
		je	print_Msg4
		
		add	ebx, OFFSET_FIRST_NAME
		mov ecx, first_name
		
		cmp ebx, byte 0
		jne	check_First_Name
		
		jmp print_Msg4
		
		; if the first name matches, check if the last name matches
check_Last_Name_Again:

		mov			al, [ebx]
		mov			ah, [ecx]
		
		cmp		ah, 10
		jne		check_Last_Name_Equal_Again
		
		
		jmp 	start_printing
		
check_Last_Name_Equal_Again:
		and     al, 11011111b           ; convert to uppercase
		and     ah, 11011111b           ; convert to uppercase
		cmp		al, ah
		jne		check_Next_Person_First_Name
		
		inc		ebx
		inc 	ecx
		
		jmp 	check_Last_Name_Again
		
		; Print that the last name is not matching
print_Msg3:

		mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
        mov     ecx, msg3   ; Arg2: addr of message
        mov     edx, len3               ; Arg3: length of message
        int     080h                    ; ask kernel to write
		jmp		exit
		
		; Print that the first name is not matching
print_Msg4:

		mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
        mov     ecx, msg5   ; Arg2: addr of message
        mov     edx, len5               ; Arg3: length of message
        int     080h                    ; ask kernel to write
		jmp		exit
		
		
print:
        ; find \0 character and count length of string
        ;
        mov     edi, eax                ; use edi as index
        mov     edx, 0                  ; initialize count

count:  cmp     [edi], byte 0           ; null char?
        je      end_count
        inc     edx                     ; update index & count
        inc     edi
        jmp     short count
end_count:

        ; make syscall to write
        ; edx already has length of string
        ;
        mov     ecx, eax                ; Arg3: addr of message
        mov     eax, SYSCALL_WRITE      ; write function
        mov     ebx, STDOUT             ; Arg1: file descriptor
        int     080h                    ; ask kernel to write
        ret                             

; end of subroutine

exit:	mov		eax, SYSCALL_EXIT			; exit function
		mov		ebx, 0						; exit code, 0=normal
		int		080h						; ask kernel to take over
		
