use16
org 0x100

	mov ebx, 0
.start:
	mov ax, 0xE820
	mov edx, 534D4150h
	mov ecx, 20
	mov di, Buffer
	int 15h
	call print_buf
	cmp ebx, 0
	je .finish
	jmp .start

.finish:
	int 16h
	int 20h

print_buf:
	push ecx
	push ebx
	call print16b
	inc di
	call print16b
	inc di
	call print8b
	pop ebx
	pop ecx
	mov dl, 0xA
	mov dx, STRING
	mov ah, 0x9
	int 21h
	ret

print16b: ; прямая запись битов (big endian)
	add di, 7
	mov cx, 8
lp16h:
	mov bl, [di]
	dec di
	push cx
	call print_reg
	pop cx
	loop lp16h
	add di, 8
	push dx
	mov dl, 0x20
	mov ah, 0x2
	int 0x21
	pop dx
	ret

print8b: ; прямая запись битов (big endian)
	add di, 3
	mov cx, 4
lp8h:
	mov bl, [di]
	dec di
	push cx
	call print_reg
	pop cx
	loop lp8h
	add di, 4
	push dx
	mov dl, 0x20
	mov ah, 0x2
	int 0x21
	pop dx
	ret

print_reg:
	mov dl, bl
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
	ret

Buffer db 20 dup (0)
STRING db 0xA, 0xD, "$"