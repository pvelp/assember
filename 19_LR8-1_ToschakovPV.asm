use16
org 0x100

mov	al, 0xb6
out	0x43, al

mov si, 0
mov bx, 0

call turn_on

start:

call fill
push dx
mov dx, [music+si]
cmp dx, 0h
je finish

pop dx
add si, 2

call Delay
call Delay
call Delay
call Delay
call Delay

jmp start

finish:
call turn_off
int 0x16
int 0x20


turn_on:
	in	al, 0x61		
	or	al, 00000011b 	; Установим 2 младших бита
	out	0x61, al		; Включим динами
	ret

turn_off:
	in	al, 0x61	                    ; Сбрасываем 2 младших бита
	and	al, 11111100b	
	out	0x61, al		; Выключим динамик
	ret



Delay:
 	mov ah, 0

 	int 0x1a
 aWait:
 	push dx
 	mov ah, 0
 	int 0x1a
 	pop bx
 	cmp bx, dx
 	je aWait
 	ret

fill:
	mov ax, [music+si]
 	out	0x42, al   
 	mov al, ah
 	out 0x42, al
 	ret


music dw 1190000/329, 1190000/311, 1190000/329, 1190000/311, 1190000/329, 1190000/246, 1190000/293, 1190000/261, 1190000/220, 1190000/130, 1190000/164, 1190000/220, 1190000/246, 1190000/164, 1190000/207, 1190000/246, 1190000/261, 1190000/164, 1190000/329, 1190000/311, 1190000/329, 1190000/311, 1190000/329, 1190000/246, 1190000/293, 1190000/261, 1190000/220, 1190000/130, 1190000/164, 1190000/220, 1190000/246, 1190000/146, 1190000/261, 1190000/246, 1190000/220, 1190000/220, 0h