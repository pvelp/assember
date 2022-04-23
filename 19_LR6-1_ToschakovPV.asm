use16
org 0x100

main:
	mov dx, Msg1                   ;Вывод сообщения на экран	
	mov ah, 9                      ;Press filename
	int 0x21 					
		
	mov ah, 0xa                    ;Ввод имени файла с клавиатуры
	mov dx, MaxLen                 ;Максимальная длина имени файла
	int 0x21 					
		
	xor bx, bx 					  ;Обнуляем bx	
	mov bl, [InputLen] 		      ;В BL длину введенного имени файла
	mov [Filename + bx], byte 0    ;Терминируем строку (дописываем 0 в конец 
	;введенного имени файла)

	mov ah, 0x3c                   ;Открыть файл
	mov dx, Filename              ;c именем "Filename"
	mov cx, 0            
	int 0x21
	jnc .M1

	mov    dx, ErrMsg
	mov    ah, 9 
	int    0x21 
	jmp    Exit 

.M1:
	mov [Desc], ax

	call fill_buffer

	mov bx, [Desc]
	mov cx, 800
	mov ah, 0x40
	mov dx, Buffer
	int 0x21
	; pop dx

Exit:
	mov    ax, 0x4c00                 ;Возврат в DOS с
	int    0x21    


fill_buffer:
	pusha
	mov si, 0
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
	call fill_reg
	pop bx
	pop cx
	loop lp1

	pop cx
	mov [Buffer+si], 0xD
	inc si
	mov [Buffer+si], 0xA
	inc si
	loop lp
	popa
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
	mov [Buffer+si], bl
	inc si
	mov bl, dl
	loop lp2
	mov bl, 0x20
	mov [Buffer+si], bl
	inc si
	ret


Msg1        db 'Press filename', 0dh, 0ah, '$'
ErrMsg     db 'Error create file', 0dh, 0ah, '$'

MaxLen      db 80            ;Максимальная длина имени файла
InputLen    db 0             ;Длина введенного имени файла
Filename    db 81 dup (0)
Desc  		dw 0
Buffer      db 800 dup (0)