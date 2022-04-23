use16
org 0x100

mov bx, Buffer
mov al, 0x1
mov ah, 0x2
mov ch, 0x0
mov cl, 0x1
mov dh, 0x0
mov dl, 0x80
int 0x13

call fill_buff

mov ah, 0x3c                   ;Открыть файл
mov dx, Filename         ;c именем "Filename"
mov cx, 0            
int 0x21
jnc .M1

mov    dx, ErrMsg
mov    ah, 9 
int    0x21 
jmp    Exit 

.M1:
	mov [Desc], ax
	mov bx, [Desc]
	mov cx, 1600
	mov ah, 0x40
	mov dx, Result
	int 0x21

Exit:
	mov    ax, 0x4c00                 ;Возврат в DOS с
	int    0x21    


fill_buff:
	mov si, 0
	mov cx, 32
lp:
	push cx
	mov cx, 16
lp1:
	mov dl, [bx]
	inc bx
	push bx
	push cx
	call fill_reg
	pop cx
	pop bx
	loop lp1

	pop cx
	mov [Result+si], 0xD
	inc si
	mov [Result+si], 0xA
	inc si
	loop lp
	ret


fill_reg:
	mov bl, dl
	mov cx, 2
lp2:
	shr bl, 4
	cmp bl, 0x9
	ja m3
	add bl, 0x30
	jmp m4 
m3: 
	add bl, 0x37  
m4:
	shl dl, 4
	mov [Result+si], bl
	inc si
	mov bl, dl
	loop lp2
	mov bl, 0x20
	mov [Result+si], bl
	inc si
	ret

ErrMsg     db 'Error create file', 0dh, 0ah, '$'
Filename    db 'file.txt','$'
Desc  		dw 0
Buffer      db 512 dup (0)
Result 		db 1600 dup (0) ; примерно 50 байт в строке, таких строк 32