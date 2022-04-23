    use16
    org 100h

    mov ax,0xb800
    mov ds,ax
    mov word[ds:0xE60], 0xE150 ; P
    mov word[ds:0xE62], 0xE141 ; A
    mov word[ds:0xE64], 0xE156 ; V
    mov word[ds:0xE66], 0xE145 ; E
    mov word[ds:0xE68], 0xE14C ; L
    mov word[ds:0xE6A], 0xE120 ;
    mov word[ds:0xE6C], 0xE154 ; T
    mov word[ds:0xE6E], 0xE14F ; O
    mov word[ds:0xE70], 0xE153 ; S
    mov word[ds:0xE72], 0xE143 ; C
    mov word[ds:0xE74], 0xE148 ; H
    mov word[ds:0xE76], 0xE141 ; A
    mov word[ds:0xE78], 0xE14B ; K
    mov word[ds:0xE7A], 0xE14F ; O
    mov word[ds:0xE7C], 0xE156 ; V






    mov ax,0
    int 16h
    int 20h


