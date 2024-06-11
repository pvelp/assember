use16 
org 0x100


mov ax, 0x1234
mov bx, 0x5678
mov cx, 0x9ABC
mov dx, 0xDEF0

pushf 
push bp
push sp
push di
push si
push es
push ds
push ss
push cs
push dx
push cx
push bx
push ax

mov ah, 0x9
mov dx, msgAX
int 0x21
pop bx
call print_reg
mov ax, bx

mov ah, 0x9
mov dx, msgBX
int 0x21
pop bx
call print_reg


mov ah, 0x9
mov dx, msgCX
int 0x21
pop bx
call print_reg
mov cx, bx

mov ah, 0x9
mov dx, msgDX
int 0x21
pop bx
call print_reg
mov dx, bx

mov ah, 0x9
mov dx, msgCS
int 0x21
pop bx
call print_reg

mov ah, 0x9
mov dx, msgSS
int 0x21
pop bx
call print_reg

mov ah, 0x9
mov dx, msgDS
int 0x21
pop bx
call print_reg

mov ah, 0x9
mov dx, msgES
int 0x21
pop bx
call print_reg

mov ah, 0x9
mov dx, msgSI
int 0x21
pop bx
call print_reg

mov ah, 0x9
mov dx, msgDI
int 0x21
pop bx
call print_reg


mov ah, 0x9
mov dx, msgSP
int 0x21
pop bx
call print_reg


mov ah, 0x9
mov dx, msgBP
int 0x21
pop bx
call print_reg


mov ah, 0x9
mov dx, msgFL
int 0x21
pop bx
call print_reg

int 0x16
int 0x20


print_reg:
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
	mov ah, 0x9
	mov dx, msg
	int 0x21
	ret

msg: db 0xD, 0xA, '$'

msgAX: db 'AX=0x$'
msgBX: db 'BX=0x$'
msgCX: db 'CX=0x$'
msgDX: db 'DX=0x$'
msgCS: db 'CS=0x$'
msgSS: db 'SS=0x$'
msgDS: db 'DS=0x$'
msgES: db 'ES=0x$'
msgSI: db 'SI=0x$'
msgDI: db 'DI=0x$' 
msgSP: db 'SP=0x$'
msgBP: db 'BP=0x$'
msgFL: db 'FLAGS=0x$'
