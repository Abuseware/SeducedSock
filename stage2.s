%include "segments.inc"
%include "memory.inc"
%include "gpu.inc"
%include "gdt.inc"
%include "paging.inc"
%include "debug.inc"

;; Char color code
%define LOGO_COLOR 0x02

;; Position of logo
%define LOGO_X ((FB_W / 2) - 16)
%define LOGO_Y ((FB_H / 2) - 4)
%define LOGO_POS (LOGO_X + (FB_W * LOGO_Y)) * 2

[CPU x64]
[BITS 16]
[segment text vstart=MEM_PROTECT_STAGE2]
start:
	;; Prepare for protected mode
	cli
	lgdt [gdt.gdtr]
	mov eax, cr0
	or al, 1 ; set protected mode (PE)
	mov cr0, eax

	DEBUG
	jmp dword SEG_PROTECT_CS:mode32

[BITS 32]
mode32:
	mov ax, SEG_PROTECT_DS
	mov ds, ax

	mov ax, SEG_PROTECT_ES
	mov es, ax

	mov ax, SEG_PROTECT_SS
	mov ss, ax
	xor esp, esp

	mov ax, SEG_PROTECT_FS
	mov fs, ax

	mov ax, SEG_PROTECT_GS
	mov gs, ax

	;;Prepare paging
	xor eax, eax
	mov edi, MEM_PAGETABLE
	mov ecx, 0x1000
	cld
	rep stosd

	mov eax, MEM_PAGETABLE
	mov dword [eax], PT_P | PT_RW | (MEM_PAGETABLE + 0x1000)
	add eax, 0x1000
	mov dword [eax], PT_P | PT_RW | PT_PS

	;; Prepare for long mode
	mov eax, MEM_PAGETABLE
	mov cr3, eax

	mov eax, cr4
  	or eax, (1 << 5) ; set PAE
  	mov cr4, eax

	mov ecx, 0xC0000080 ; EFER
	rdmsr
	or eax, (1 << 8)
	wrmsr

	mov eax, cr0
	or eax, (1 << 31) ; set paging (PG)
	mov cr0, eax

	lgdt [gdt64.gdtr]
	DEBUG

	jmp dword SEG_LONG_CS:mode64

[BITS 64]
mode64:
	mov ax, SEG_LONG_DS
	mov ds, ax

	mov ax, SEG_LONG_ES
	mov es, ax

	mov ax, SEG_LONG_SS
	mov ss, ax
	xor esp, esp

	mov ax, SEG_LONG_FS
	mov fs, ax

	mov ax, SEG_LONG_GS
	mov gs, ax

logo:
	;; Draw logo
	;; Prepare registers for loading string
	mov edx, FB + LOGO_POS
	mov ebx, 1
	mov esi, data.str

	.write:
	;; Read single char from string
	lodsb
	;; Jump on special chars
	cmp al, 0xA
	jz .new_line ; Make new line on 0xA (\n)
	cmp al, 0x0
	jz .end ; Exit loop on null byte

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

end:
	DEBUG
	jmp $

%if ($ - $$) > 0x199
	%fatal "Stage 2 too big!"
%endif

[segment data start=0x200 vstart=0x20200]
gdt:
	.gdtr:
	istruc gdtr
	at gdtr.size, dw .size
	at gdtr.base, dd .gdt
	iend

	.gdt:
	.gdt_null:
	;; Null segment
	dq 0
	.gdt_code:
	;; Code segment
	istruc gdt_entry
	at gdt_entry.limit, dw 0xffff
	at gdt_entry.base, dw 0
	at gdt_entry.type, dw GDT_TYPE_P | GDT_TYPE_S | GDT_TYPE_CODE_RX
	at gdt_entry.flags, dw 0xf | GDT_FLAG_G | GDT_FLAG_DB | GDT_FLAG_AVL
	iend

	.gdt_data:
	;; Data
	istruc gdt_entry
	at gdt_entry.limit, dw 0xffff
	at gdt_entry.base, dw 0
	at gdt_entry.type, dw GDT_TYPE_P | GDT_TYPE_S | GDT_TYPE_DATA_RW
	at gdt_entry.flags, dw 0xf | GDT_FLAG_G | GDT_FLAG_DB | GDT_FLAG_AVL
	iend

	.size equ $ - .gdt

gdt64:
	.gdtr:
	istruc gdtr
	at gdtr.size, dw .size
	at gdtr.base, dd .gdt
	iend

	.gdt:
	.gdt_null:
	;; Null segment
	dq 0
	.gdt_code:
	;; Code segment
	istruc gdt_entry
	at gdt_entry.limit, dw 0xffff
	at gdt_entry.base, dw 0
	at gdt_entry.type, dw GDT_TYPE_P | GDT_TYPE_S | GDT_TYPE_CODE_RX
	at gdt_entry.flags, dw 0xf | GDT_FLAG_G | GDT_FLAG_L | GDT_FLAG_AVL
	iend

	.gdt_data:
	;; Data
	istruc gdt_entry
	at gdt_entry.limit, dw 0xffff
	at gdt_entry.base, dw 0
	at gdt_entry.type, dw GDT_TYPE_P | GDT_TYPE_S | GDT_TYPE_DATA_RW
	at gdt_entry.flags, dw 0xf | GDT_FLAG_G | GDT_FLAG_L | GDT_FLAG_AVL
	iend

	.size equ $ - .gdt

data:
	.str:
		db '    _/_/_/        _/_/',0xA
		db '   _/    _/    _/        _/_/_/',0xA
		db '  _/_/_/    _/_/_/_/  _/    _/',0xA
		db ' _/    _/    _/      _/    _/',0xA
		db '_/_/_/      _/        _/_/_/',0xA
		db '                         _/',0xA
		db '                        _/',0x0
