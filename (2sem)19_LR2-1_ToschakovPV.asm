org 100h
macro DEFINE_GATE _address, _code_selector, _type
{
dw _address and 0FFFFh, _code_selector, _type, _address shr 16
}
STACK equ 200000h
start:
use16
; очистка экрана
	mov ax, 3 
	int 10
; открываем линию A20:
	in al, 92h
	or al, 2
	out 92h, al

	mov [real_seg], cs

	mov bx, cs
	shl bx, 4
	mov [CODE_descr + 2], bl
	mov [CODE16_descr + 2], bl
	mov ax, cs
	shr ax, 4
	mov [CODE_descr+3], al
	mov [CODE16_descr+3], al
	mov [CODE_descr+4], ah
	mov [CODE16_descr+4], ah

	mov bx, ds
	shl bx, 4
	mov [DATA_descr + 2], bl
	mov ax, ds
	shr ax, 4
	mov [DATA_descr+3], al
	mov [DATA_descr+4], ah

; вычисление линейного адреса GDT
	xor	eax,eax
	mov	ax,cs
	shl	eax,4
	add	ax, GDT

; линейный адрес GDT кладем в заранее подготовленную переменную
	mov	dword[GDRT+2], eax
	lgdt fword [GDRT]
; вычисление линейного адреса IDT
	xor eax, eax 
	mov ax, ds
	shl eax, 4
	mov ebp, eax
	add ebp, IDT

; линейный адрес IDT кладем в заранее подготовленную переменную
	mov dword[IDTR+2], ebp
    sidt fword [idtr_backup]

	; загрузка регистра IDTR
    lidt fword [IDTR]

    cli
	in	al,70h
	or	al,80h
	out	70h,al
	
; переключение в защищенный режим
	mov	eax,cr0
	or	al,1
	mov	cr0,eax

    jmp far 0x8:prot32_mode
    ; db 66h
	; db 0EAh
	; ENTRY_OFF:
	; dd prot32_mode
	; dw 0x8



prot32_mode:
use32
	mov ax, 16
	mov bx, ds
	mov ds, ax
	mov ax, 24
	mov es, ax
	mov esp, STACK
    sti
    int 51
    cli
    jmp far 0x20:prot16_mode
	; db 0EAh
	; ENTRY_OFF2:
	; dd prot16_mode
	; dw 0x20


GP_handler:
    pop eax
    pusha
    mov edx, 400
	inc word[es:edx]	
    popa

OWN_handler:
    pusha
    mov esi, 0xFFFFFFF0
	mov bx, 0xBE0
	mov cx, 2
	xor ax, ax
	mov al, 0x51

	m1:
		push cx

		xor dx, dx
		mov dl, al

		and dl, 0xf0
		shr dl, 4
		add dl, 0x30
		cmp dl, 0x39

		jbe m0
		add dl, 0x7

	m0:
		mov dh, 35h
		mov [es:bx], dx
		add bx, 0x2
		shl al, 4

		pop cx
	loop m1
    popa
    iretd

prot16_mode:
use16
    mov eax, cr0
	and al, 0FEh
	mov cr0, eax
	
	db 0EAh
	offset dw real_mode
	real_seg dw 0

real_mode:
    use16

	in al, 70h
	and al, 7Fh
	out 70h, al


    lidt [idtr_backup]
    sti
	int 0x16
    int 0x20


align 8
GDT:
NULL_descr db 8 dup(0)
CODE_descr db 0FFh, 0FFh, 00h, 00h, 00h, 10011010b, 11001111b, 00h
DATA_descr db 0FFh, 0FFh, 00h, 00h, 00h, 10010010b, 11001111b, 00h
VIDEO_descr db 0FFh, 0FFh, 00h, 80h, 0Bh, 10010010b, 01000000b, 00h
CODE16_descr db 0FFh, 0FFh, 00h, 00h, 00h, 10011010b, 10001111b, 00h

GDT_size equ $-GDT

label GDRT fword
	dw GDT_size-1
	dd ?

align 8
IDT:
	dq 0 ;0
	dq 0
	dq 0 ;2
 	dq 0 ;3
 	dq 0 ;4
 	dq 0 ;5
 	dq 0 ;6
 	dq 0 ;7
 	dq 0 ;8
	dq 0 ;9
 	dq 0 ;10
 	dq 0 ;11
 	dq 0 ;12
 	DEFINE_GATE GP_handler, 8, 1000111000000000b ;13 #GP
 	dq 0 ;14
 	dq 0 ;15
 	dq 0 ;16
 	dq 0 ;17
 	dq 0 ;18
 	dq 0 ;19
 	dq 0 ;20
 	dq 0 ;21
 	dq 0 ;22
 	dq 0 ;23
 	dq 0 ;24
 	dq 0 ;25
 	dq 0 ;26
 	dq 0 ;27
 	dq 0 ;28
 	dq 0 ;29
 	dq 0 ;30
 	dq 0 ;31
	dq 0 ;32
	dq 0 ;33
	dq 0 ;34
	dq 0 ;35
	dq 0 ;36 
	dq 0 ;37
	dq 0 ;38
	dq 0 ;39
	dq 0 ;40
 	dq 0 ;41
	dq 0 ;42
	dq 0 ;43
	dq 0 ;44
	dq 0 ;45
	dq 0 ;46 
	dq 0 ;47
	dq 0 ;48
	dq 0 ;49
	dq 0 ;50
	DEFINE_GATE OWN_handler, 8, 1000111000000000b
IDT_size equ $-IDT

label IDTR fword 
	dw IDT_size - 1
	dd ?

idtr_backup:
    dw  0
    dd  0

