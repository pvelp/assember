use16
org 0x100

mov ah, 0x9
mov dx, msg1
int 0x21

mov dx,0

mov ax, 0x1E29
mov si, ax
mov dx, si

mov cx, 4
lp1:
	shr dx, 12
	cmp dx, 0x9
	ja m1
	add dx, 0x30
	jmp m2 
m1: 
	add dx, 0x37  
m2:
	mov ah, 0x2 
	shl si, 4
	int 0x21 
	mov dx, si
	loop lp1

mov ah, 0x9
mov dx, msg2
int 0x21

mov dx,0

mov bx, 0x12FA
mov dx, bx

mov cx, 4
lp2:
	shr dx, 12
	cmp dx, 0x9
	ja m3
	add dx, 0x30
	jmp m4 
m3: 
	add dx, 0x37  
m4:
	mov ah, 0x2 
	shl bx, 4
	int 0x21 
	mov dx, bx
	loop lp2
	int 0x20

msg1: db 'AX=0x$'
msg2: db 0xD, 0xA, 'BX=0x$'
