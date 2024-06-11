use16 
org 100h 

Start: 
jmp init 

ScanCode db 1Eh,30h,2Eh,20h,12h,21h,22h,23h,17h,24h,25h,26h,32h,31h,18h,19h,10h,13h,1Fh,14h,16h,2Fh,11h,2Dh,15h,2Ch,0Bh,02h,03h,04h,05h,06h,07h,08h,09h,0Ah 

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

play: 
push ax 
in al, 0x61 
or al, 00000011b ; Установим 2 младших бита 
out 0x61, al ; Включим динамик 

mov ax, (1190000/440) 
out 0x42, al 
mov al, ah 
out 0x42, al 
call Delay 

in al, 0x61; Сбрасываем 2 младших бита 
and al, 11111100b 
out 0x61, al; Выключим динамик 
pop ax 
ret 


own_int15: 
sti 
push ax 
push ds 
push dx 
pushf 
mov bx, cs 
mov ds, bx 
new_int15: 
mov bx, ScanCode 
mov cx, 36 
lp: 
cmp al, [bx] 
je sound 
inc bx 
loop lp 
jmp exit 
sound: 
call play 
exit: 
popf 
pop dx 
pop ds 
pop ax 
iret 


init: 
mov al, 0xb6 
out 0x43, al 

mov ah, 0x35 
mov al, 0x15 
int 21h 

mov ah, 0x25 
mov al, 0x15 
mov dx, own_int15 
int 21h 

mov dx, init 
int 27h
