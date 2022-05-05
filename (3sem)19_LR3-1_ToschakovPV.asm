use16
org 0x100

; Forbid all interrupts
cli

in  al  , 0x70
or  al  , 0x80
out 0x70, al

; Open A20 gate
in  al  , 0x92
or  al  , 0x2
out 0x92, al

; Set up code bases to be CS
xor eax, eax
mov ax , cs
shl eax, 0x04
mov [CODE_descr+2], al
mov [CODE16_descr+2], al
mov [D_DATAM+2], al
shr eax, 0x08
mov [CODE_descr+3], al
mov [CODE16_descr+3], al
mov [D_DATAM+3], al
mov [CODE_descr+4], ah
mov [CODE16_descr+4], ah
mov [D_DATAM+4], ah

; Calculate GDT linear address
xor eax, eax
mov ax , cs
shl eax, 0x4
add ax , GDT

; Put GDT address in variable
mov dword[GDTR+2], eax

; Load GDTR register
lgdt fword[GDTR]

; Switch to protected mode
mov eax, cr0
or  al , 0x1
mov cr0, eax

jmp far fword[PROT_MODE_PTR]

PROT_MODE_PTR:
PROT_MODE_LA: dd PROT_MODE
              dw 0x8 ; SELECTOR

GDT:
  D_NULL   db 8 dup(0)
  CODE_descr   db 0xFF, 0xFF, 0x00, 0x00, 0x00, 10011010b, 11001111b, 0x00; 0x8
  DATA_descr   db 0xFF, 0xFF, 0x00, 0x00, 0x00, 10010010b, 11001111b, 0x00; 0x10
  CODE16_descr db 0xFF, 0xFF, 0x00, 0x00, 0x00, 10011010b, 00001111b, 0x00; 0x18
  CODE64_descr db 0x00, 0x00, 0x00, 0x00, 0x00, 10011010b, 00100000b, 0x00; 0x20
  DATA64_descr db 0x00, 0x00, 0x00, 0x00, 0x00, 10010010b, 00100000b, 0x00; 0x28
  D_DATAM  db 0xFF, 0xFF, 0x00, 0x00, 0x00, 10010010b, 11001111b, 0x00; 0x30
  GDT_SIZE equ $-GDT

GDTR:
  dw GDT_SIZE
  dd 0x0
  
use32
PROT_MODE:
; Save real mode data/code segment to bx
mov bx, ds
mov word[REAL_MODE_PTR+2], bx


; Set data register to segment registers
mov ax, 0x10
mov ds, ax
mov es, ax

; Turn on PAE (5 in CR4)
mov eax, cr4
bts eax, 5   ; CR4-PAE
mov cr4, eax

; Create pages
; Clear everything
mov edi, 0x100000
mov ecx, 0x0C0000
xor eax, eax
clear_all:
	mov dword[es:edi], eax
loop clear_all

; PML4E
mov dword[0x100000], 0x110000 + 111b

; PDPTE (4GB memory/1 GB catalogue = 4 catalogues)
mov dword[0x110000], 0x120000 + 111b
mov dword[0x110008], 0x121000 + 111b
mov dword[0x110010], 0x122000 + 111b
mov dword[0x110018], 0x123000 + 111b

; PDE (4GB memory/2MB pages = 2048 pages = 0x800 )
mov edi, 0x120000
mov eax, 0x0 + 10000111b
mov ecx, 0x800
generate_pdes:
	mov dword[es:edi], eax
	add edi, 0x8
	add eax, 0x200000
loop generate_pdes

; Load PML4 to CR3
mov eax, 0x100000 ; PML4 address
mov cr3, eax

;Switch LME in EFER
mov ecx, 0x0C0000080 ; EFER
rdmsr
bts eax, 8 ; EFER.LME
wrmsr

; Turn on paging (PG in CR0)
mov eax, cr0
bts eax, 31 ; CR0-PG
mov cr0, eax

; Jump to 64-bit
jmp PROT_MODE64_PTR


PROT_MODE64_PTR:
	dd 0x0
	dw 0x20

PROT_MODE64:
use64
mov ax, 0x28
mov ds, ax
mov es, ax

mov rsi, 0xFFFFFFF0 ; 0x13FFFFFF0
mov rdi, 0x000B8000 + 0xBE0

xor rax, rax

mov rcx, 16
print_loop:
	mov al, byte[ds:rsi]
	shr al, 0x04
	and al, 0x0f
	cmp al, 0x0a
	jl out_1
	add al, 0x07
	out_1:
	add al, 0x30
	mov byte[es:rdi], al
	inc rdi
	mov byte[es:rdi], 0x02
	inc rdi	

	; Print 2nd digit
	mov al, byte[ds:rsi]
	and al, 0x0f
	cmp al, 0x0a
	jl out_2
	add al, 0x07
	out_2:
	add al, 0x30
	mov byte[es:rdi], al
	inc rdi
	mov byte[es:rdi], 0x02
	
	add rdi, 0x3
	inc rsi
loop print_loop

jmp PROT_MODE_BACK_PTR

PROT_MODE_BACK_PTR:
	dq PROT_MODE_BACK
	dw 0x8


PROT_MODE_BACK:
use32
; Turn off paging (PG in CR0)
mov eax, cr0
btr eax, 31 ; CR0-PG
mov cr0, eax

; Switch off LME in EFER
mov ecx, 0x0C0000080 ; EFER
rdmsr
btr eax, 8 ; EFER.LME
wrmsr

; Turn off PAE (5 in CR4)
mov eax, cr4
btr eax, 5   ; CR4-PAE
mov cr4, eax

; Jump to 16-bit code
jmp 0x18:next
next:
use16
; Switch back to real mode
mov eax, cr0
and al, 11111110b
mov cr0, eax

jmp dword[cs:REAL_MODE_PTR]

REAL_MODE_PTR:
dw REAL_MODE
dw 0x0

use16
REAL_MODE:
; Set up segment registers
mov ax, cs
mov es, ax
mov ds, ax

; Allow all interrupts
sti

in  al  , 0x70
and al  , 0x7F
out 0x70, al

; Wait for input
mov ah, 0x0
int 0x16

; Go back to DOS
int 0x20