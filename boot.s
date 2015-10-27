%define TERM_W 80
%define TERM_H 25

%define TERM_COLOR 0x02

%define LOGO_X 48
%define LOGO_Y 17

%define GPU 0xB8000
%define GPU_END GPU + (TERM_W) * (TERM_H) * 2
%define LOGO_POS (LOGO_X + (TERM_W * LOGO_Y)) * 2

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

cursor: ;Set cursor position to (0,0)
    mov dx, 0x3D4
    mov al, 14
    out dx, al
    
    inc dx ;0x3D5
    mov al, 0
    out dx, al
    
    dec dx ;0x3D4
    mov al, 15
    out dx, al
    
    inc dx ;0x3D5
    mov al, 0
    out dx, al

clear: ;Clear whole screen
    mov edx, GPU
    .write:
    	mov [edx], BYTE " "
    	mov [edx+1], BYTE 0
        add edx, 2
        cmp edx, GPU_END
        jnz clear.write

logo: ;Draw logo
    mov edx, GPU + LOGO_POS
    mov ebx, 1
    mov si, data.str
    .write:
        lodsb
        cmp al, 0xA
        jz logo.new_line
        cmp al, 0x0
        jz end
        mov [edx], BYTE al
        mov [edx+1], BYTE TERM_COLOR
        add edx, 2
        jmp logo.write
    .new_line:
    	mov edx, TERM_W * 2
    	imul edx, ebx
    	add edx, GPU + LOGO_POS
    	inc ebx
        jmp logo.write

end: ;Loop forever
    jmp end
    
    .fill: ;MBR partition table space
        times 510 - ( $ - $$ ) db 0x90
    .bootflag: ;Mark as bootable
        dw 0xAA55
