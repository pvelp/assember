use16 
org 0x100


begin:
	call GreetingMsg ; запрос пароля
	call Input ; ввод пароля
	jmp parse_buffer ; подготовка к сравнению 

parse_buffer:
	mov di, dx 
	add di, 2 ; чисто введенный пароль без первых двух байт информации о длине
	mov si, true_pass ; настоящий пароль
	mov cx, passLen ; длина пароля с 0Dh
	dec cx ; т.к. учтен 0Dh
	jmp check ; проверка

check:
	pusha
	repe cmpsb ; сравниваем ds:si с es:di cx раз или до первого несовпадения
	je correct_pass
	jmp wrong_pass

correct_pass: ; если попали в "верно"" - выводим соотв. сообщение и прыгаем в финиш
	push dx
	call TrueMsg
	pop dx
	popa
	jmp finish

wrong_pass: ; если попали в "неверно" - выводим соотв. сообщение и прыгаем в начало
	push dx
	call WrongMsg
	pop dx
	popa
	jmp begin

finish:
	mov ax,0
	int 0x16
	int 0x20
; ___________________________________________________________________________________________ ;

Input:
	mov dx, buffer
	mov ah, 0x0A
	int 0x21
	ret

GreetingMsg:
	mov ah, 0x9
	mov dx, InputMsg
	int 0x21
	ret

WrongMsg:
	mov ah, 0x9
	mov dx, MsgWrongPass
	int 0x21
	ret

TrueMsg:
	mov ah, 0x9
	mov dx, MsgTruePass
	int 0x21
	ret
; ___________________________________________________________________________________________ ;

true_pass db "20U096$"
passLen=$-true_pass
buffer db passLen,?,passLen dup (0)
InputMsg db 'Enter password: $'
MsgWrongPass db "Wrong password, try again :-(", 0xD, 0xA, '$'
MsgTruePass db 0xD, 0xA, "You are welcome! :-)$"
