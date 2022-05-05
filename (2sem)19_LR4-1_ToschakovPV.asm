format pe64 efi
entry main

section '.text' code executable readable
main:

	mov [system_table], rdx

	sub rsp, 8 + (4 * 8)

	mov rcx, [rdx + 64]
	call qword[rcx + 48]

	mov rdx, [system_table]
	mov rcx, [rdx + 64]
	mov rdx, 0
	mov r8, 19
	call qword[rcx + 56]
	
	mov rdx, [system_table]
	mov rcx, [rdx + 64]
	mov rdx, 0x12
	call qword[rcx + 40]

	mov rdx, [system_table]
	mov rcx, [rdx + 64]
	mov rdx, string
	call qword[rcx + 8]
	
	mov rdx, [system_table]
    mov rcx, [rdx + 64]
    mov rdx, 111b
    call qword[rcx + 40] 
    
    add rsp, 8 + (4 * 8)
    xor rax, rax
	ret 


section '.data' data readable writeable

	system_table dq 0x0
	string du 'Pavel Toschakov ', 13, 10, 0