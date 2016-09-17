;org 100h


SECTION .data
 mssg  db 10,13, "Enter the number: %d”, 10 ,13
 mssg1 db 10,13, “The result is: %d”,10,13
	
SECTION .bss
 num1 resb 1
 num2 resb 1
 temp resb 1
 result resb 2

	
SECTION .text
 
start:
 mov ah,09h
 mov dx,mssg              ;prompt to input
 int 21h
 
 call read                ;call to read input
 
 mov [num1],bl            ;save input
 
 mov ah,09h
 mov dx,mssg              ;prompt to input
 int 21h
 
 call read                ;call to read input
 mov [num2],bl            ;save input
 
 call booth               ; call booth’s algorithm
 
 mov [result],ax          ; save result
 mov bx,ax
 
 mov dx,mssg1             ;print  ‘The result is’
 mov ah,09h
 int 21h
 
 call write              ; display result
 
 mov ah,4ch
 int 21h
 
 hlt
 
read:                       ;read input
 mov bl,00h              ;initialise bl
 mov [temp],bl           ;initialise temp
LP:
 mov ah,01h              ;DOS function code to read input from keyboard
 int 21h                 ;call DOS
 cmp al,0dh              ;check newline?
 je RT                   ;if newline jump to RT
 mov cl,al               ;input that read is in al,copy it to cl
 sub cl,30h              ;convert to ASCII to decimal
 mov al,[temp]           ;copy temp to al
 mov bl,0ah              ;set bl as 10
 mul bl                  ;multiply al with bl (10)
 mov [temp],al           ;save al
 add [temp],cl           ;add input digit to temp
 jmp LP                  ;jump to read next digit
RT:
 mov bl,[temp]           ;copy input number to bl
 ret                     ;return
 
booth:                     ;booths algorithm starts here
 mov ah,0                ;since AX used as product reg,initialise ah as 0  and
 mov al,[num1]           ;copy multiplicant to al
 mov cx,8                ;set count
 mov bh,[num2]           ;copy multiplier to bl
 clc                     ;clear carry flag
LP1:mov bl,al               ;copy al to bl (to check LSB)
 and bl,1                ;bitwise ‘and’ bl with 1 ,if LSB is 1 bl becomes 1 ,if LSB is 0 bl becomes 0
 jnz LP2                 ;if LSB =1 jumpt to LP2
 JNC LP3                 ;if carry flag is 0 jump to LP3
 sub ah,bh               ;
 jmp LP3
LP2:jc LP3
 add ah,bh
LP3:
 shr ax,1
 loop LP1
 ret

write:
 mov al,bl
 lea di,[result]
 mov bh,0ah
 mov cl,24h
 mov [di],cl
 dec di
LP4:
 mov ah,00h
 div bh
 add ah,30h
 mov [di],ah
 dec di
 cmp al,00h
 jnz LP4
 inc di
 mov ah,09h
 mov dx,di
 int 21h
 ret
 
