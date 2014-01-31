%define TERM_W 80
%define TERM_H 25
%define LOGO_X 48
%define LOGO_Y 17


[BITS 16]
org 0x7C00
jmp main

data:
    .str:
        db '    _/_/_/        _/_/',0xA
        db '   _/    _/    _/        _/_/_/',0xA
        db '  _/_/_/    _/_/_/_/  _/    _/',0xA
        db ' _/    _/    _/      _/    _/',0xA
        db '_/_/_/      _/        _/_/_/',0xA
        db '                         _/',0xA
        db ' Big fucking question.  _/',0x0

    .fill:
        times 224 - ( $ - $$ ) db 0x90

main:
    mov bx, 0x8
    mov cx, 1

clear:
    mov al, " "
    .putch:
        mov ah, 2
        int 0x10
        mov ah, 9
        inc dl
        int 0x10
        cmp dl, TERM_W
        jnz clear.putch
        xor dl, dl
        inc dh
        cmp dh, TERM_H
        jnz clear.putch

logo:
    mov dl, LOGO_X
    mov dh, LOGO_Y
    mov ah, 2
    int 0x10
    mov si, data.str
    .print_char:
        lodsb
        cmp al, 0xA
        jz logo.new_line
        cmp al, 0x0
        jz end
        mov ah, 9
        int 0x10
        inc dl
        mov ah, 2
        int 0x10
        jmp logo.print_char
    .new_line:
        inc dh
        mov dl, LOGO_X
        mov ah, 2
        int 0x10
        jmp logo.print_char

end:
    xor dx, dx
    mov ah, 2
    int 0x10
    xor ax,ax
    int 0x16
    mov bx, 0x40
    mov ds, bx
    mov word [ds:0x72], 0x1234
    jmp 0xffff:0
    
    .fill:
        times 510 - ( $ - $$ ) db 0x90
    .bootflag:
        dw 0xAA55
