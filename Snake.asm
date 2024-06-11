use16
org 0x100

mov ax, 0xb800
mov es, ax
run:
	mov di, 0xE60
	mov dx, 0x1180 ;значение, при котором верхний символ, который ушел за границы строки, будет на самой нижней строчке
					;как и каждый следующий
	mov cx, 25
lp:
	push cx
	push dx 
	call print
	call print_null ;очистим 
	call Delay
	call Delay ; чтобы было приятнее смотреть
	pop dx
	cmp di, 0x280
	jl next
	jmp a
next:
	push di
	mov di, dx
	push dx
	call print
	call print_null
	pop dx
	sub dx, 0xA0
	pop di
a:
	pop cx
	loop lp
	jmp run

mov ax, 0
int 0x16
int 0x20

print_null:
	add di, 0x3C0 ;вернемся на 5 символов назад 
	mov cx,5
lp4:
	mov dx, 0x20
	mov [es:di], dx
	add di, 0xA0
	loop lp4
	sub di, 0x460 ;продолжим рисовать 
 	ret

print:
mov si, msg
mov cx, 5
lp2:
	movsw
	sub di, 0xA0
	sub di, 2
	loop lp2
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

 msg: dw 0xE24C, 0xE245, 0xE256, 0xE241, 0xE250
