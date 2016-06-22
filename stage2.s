%include "gpu.inc"
%include "bochs.inc"

;; Char color code
%define LOGO_COLOR 0x02

;; Position of logo
%define LOGO_X ((FB_W / 2) - 16)
%define LOGO_Y ((FB_H / 2) - 4)
%define LOGO_POS (LOGO_X + (FB_W * LOGO_Y)) * 2

[BITS 16]
[CPU 586]
;; [org 0x0000]

start:
	;; Prepare segments
	mov ax, 0x2000
	mov ds, ax
	mov es, ax

	mov ax, 0x1000
	mov ss, ax
	xor sp, sp

	mov ax, (FB / 0x10)
	mov fs, ax
	mov gs, ax

logo:
	;; Draw logo
	;; Prepare registers for loading string
	mov edx, LOGO_POS
	mov ebx, 1
	mov si, data.str

.write:
	;; Read single char from string
	lodsb

	;; Jump on special chars
	cmp al, 0xA
	jz .new_line								;	Make new line on 0xA (\n)
	cmp al, 0x0
	jz .end											;	Exit loop on null byte

	;; Write char to framebuffer
	mov ah, LOGO_COLOR
	mov [gs:edx], WORD ax
	add edx, 2
	jmp .write
.new_line:
	mov edx, FB_W * 2
	imul edx, ebx
	add edx, LOGO_POS
	inc ebx
	jmp .write
.end:

end:
	;; Loop forever
	jmp $

data:
.str:
	db '    _/_/_/        _/_/',0xA
	db '   _/    _/    _/        _/_/_/',0xA
	db '  _/_/_/    _/_/_/_/  _/    _/',0xA
	db ' _/    _/    _/      _/    _/',0xA
	db '_/_/_/      _/        _/_/_/',0xA
	db '                         _/',0xA
	db '                        _/',0x0

fill:	
	;; Fill to 1.5kB
	%if ($ - $$) > 1535
		%fatal "Code too fat!"
	%endif
	times 1536 - ($ - $$) db 0
