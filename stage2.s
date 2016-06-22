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

start:
	;; Prepare for protected mode
	cli
	lgdt [gdt.gdtr]
	mov eax, cr0
	or al, 1											; set PE
	mov cr0, eax

	jmp dword 0x8:(0x20000 + pmode)

[BITS 32]
pmode:
	mov ax, 0x10

	mov ds, ax
	mov es, ax

	mov ss, ax

	mov fs, ax
	mov gs, ax

logo:
	;; Draw logo
	;; Prepare registers for loading string
	mov edx, FB + LOGO_POS
	mov ebx, 1
	mov esi, 0x20000 + data.str

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
	mov [edx], WORD ax
	add edx, 2
	jmp .write

	.new_line:
	mov edx, FB_W * 2
	imul edx, ebx
	add edx, FB + LOGO_POS
	inc ebx
	jmp .write

	.end:

	jmp $

gdt:
	.gdtr:
	dw .gdt_end - .gdt - 1
	dd 0x20000 + .gdt

	.gdt:
	;; Null segment
	dq 0

	;; Code segment
	dw 0xffff											; Limit low
	dw 0													; Base low
	dw (1 << 15) | (1 << 12) | (10 << 8) ; Flags, type, base mid
	dw 0xf | (1 << 7) | (1 << 6) | (1 << 4)	; Limit high, flags (32bit, 4K pages), base high

	;; Data
	dw 0xffff											; Limit low
	dw 0													; Base low
	dw (1 << 15) | (1 << 12) | (2 << 8) ; Flags, base mid
	dw 0xf | (1 << 7) | (1 << 6) | (1 << 4)	; Limit high, Type (32bit, 4K pages), base high
	.gdt_end:

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
