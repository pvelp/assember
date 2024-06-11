use16 
org 0x100

mov ax, 0
mov es, ax
mov bx, 0xBE0

mov cx, 16
lp:
	push cx
	mov cx, 16
lp1:
	mov dl, [es:bx]
	inc bx
	push cx
	push bx
	call print_reg
	pop bx
	pop cx
	loop lp1

	pop cx
	push dx
	push ax
	mov ah, 0x9
	mov dx, msg1
	int 0x21
	pop ax
	pop dx
	loop lp

int 16h
int 20h

print_reg:
	mov bl, dl
	mov cx, 2
lp2:
	shr dl, 4
	cmp dl, 0x9
	ja m3
	add dl, 0x30
	jmp m4 
m3: 
	add dl, 0x37  
m4:
	mov ah, 0x2 
	shl bl, 4
	int 0x21 
	mov dl, bl
	loop lp2
	mov ah, 0x9
	mov dx, msg
	int 0x21
	ret


msg: db 0x20, '$'
msg1: db 0xD, 0xA, '$'
