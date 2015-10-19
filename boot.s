%define TERM_W 80
%define TERM_H 25

%define TERM_COLOR 0x02

%define LOGO_X 48
%define LOGO_Y 17

%define GPU 0xB8000
%define GPU_END GPU + (TERM_W) * (TERM_H) * 2
%define LOGO_POS + (LOGO_X + (TERM_W * LOGO_Y)) * 2

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
    mov dx, 0x3D4 ;Prepare to send higher bits
    mov al, 14
    out dx, al
    mov dx, 0x3D5 ;Send 0
    mov al, 0
    out dx, al
    mov dx, 0x3D4 ;Prepare to send lower bits
    mov al, 15
    out dx, al
    mov dx, 0x3D5 ;Send 0
    mov al, 0
    out dx, al

clear:
    mov edx, GPU ;Store GPU memory position
    .write:
    	mov [edx], BYTE " " ;Write space at current memory position
    	mov [edx+1], BYTE TERM_COLOR ;Write color code
        add edx, 2 ;Jump to next position
        cmp edx, GPU_END ;Compare next position with end of GPU memory
        jnz clear.write ;Repeat if not ended

logo:
    mov edx, GPU + LOGO_POS ;Store starting position
    mov ebx, 1 ;Store line counter
    mov si, data.str ;Put string address for lodsb
    .print_char:
        lodsb ;Load char from [si]
        cmp al, 0xA ;Check for new line
        jz logo.new_line ;Make cariage return
        cmp al, 0x0 ;Check for string end
        jz end ;Finish
        mov [edx], BYTE al ;Write char
        add edx, 2 ;Jump to next position of memory
        jmp logo.print_char ;Repeat
    .new_line:
    	mov edx, TERM_W * 2 ;Store terminal width
    	imul edx, ebx ;Calculate position of line from counter
    	add edx, GPU + LOGO_POS ;Add starting position
    	inc ebx ;Increment counter
        jmp logo.print_char ;Repeat

end:
    jmp end ;Loop forever
    
    .fill:
        times 510 - ( $ - $$ ) db 0x90
    .bootflag:
        dw 0xAA55
