%include "segments.inc"
%include "memory.inc"
%include "gpu.inc"
%include "gdt.inc"
%include "paging.inc"
%include "debug.inc"

;; Char color code
%assign LOGO_COLOR 0x02

;; Position of logo

[CPU x64]
[BITS 16]
[segment text vstart=MEM_PROTECT_STAGE2]
start:
	;; Prepare for protected mode
	cli
	load_segments REAL

	;; Load GDT for protected mode
	lgdt [gdt32.gdtr]

	;; set protected mode (PE)
	mov eax, cr0
	or al, 1
	mov cr0, eax

	DEBUG
	jmp dword SEG_PROTECT_CS:mode32

[BITS 32]
mode32:
	load_segments PROTECT

	;;Prepare paging
	xor eax, eax
	mov edi, MEM_PAGETABLE
	mov ecx, 0x4000
	rep stosd

	mov eax, MEM_PAGETABLE
	mov dword [eax], PT_P | PT_RW | (MEM_PAGETABLE + 0x1000)
	add eax, 0x1000
	mov dword [eax], PT_P | PT_RW | (MEM_PAGETABLE + 0x2000)
	add eax, 0x1000
	mov dword [eax], PT_P | PT_RW | PT_PS

	;; Prepare for long mode
	mov eax, MEM_PAGETABLE
	mov cr3, eax

	;; Set PAE
	mov eax, cr4
  	or eax, (1 << 5)
  	mov cr4, eax

  	;; Set EFER
	mov ecx, 0xC0000080
	rdmsr
	or eax, (1 << 8)
	wrmsr

	;; Set paging (PG)
	mov eax, cr0
	or eax, (1 << 31)
	mov cr0, eax

	;; Load GDT for long mode
	lgdt [gdt64.gdtr]
	DEBUG

	jmp dword SEG_LONG_CS:mode64

[BITS 64]
mode64:
	load_segments LONG

clear:
	;; Clear whole screen
	mov rdi, FB
	mov rcx, FB_SIZ
	mov rax, 0x0
	rep stosw

logo:
	;; Draw logo
	;; Prepare registers for loading string
	mov r8, FB
	mov r9, 1
	mov rsi, data.str

	;; Read X,Y from data
	xor rax, rax
	xor rbx, rbx
	lodsw ;; Load Y,X to eax
	mov bl, al ;; Move Y to bl
	imul rbx, FB_W ;; Multiply FB_W by Y to get starting line
	shr rax, 8 ;; Move rax one byte to right
	add rbx, rax ;; Add X to starting point
	imul ebx, 2 ;; Multiply by two (2 bytes per char in framebuffer)
	add r8, rbx ;; Add calculated position to framebuffer address

	.write:
	;; Read RLE pair from "string"
	lodsw
	;; Prepare counter
	xor rcx, rcx
	mov cl, ah
	;; Decode RLE
	.rle:
	cmp cl, 0x0
	jz .write
	dec cl
	;; Jump on special chars
	cmp al, 0xA
	jz .new_line ; Make new line on 0xA (\n)
	cmp al, 0x0
	jz .end ; Exit loop on null byte

	;; Write char to framebuffer
	mov ah, LOGO_COLOR
	mov [r8], WORD ax
	add r8, 2
	jmp .rle

	.new_line:
	mov r8, FB_W * 2
	imul r8, r9
	add r8, FB
	add r8, rbx
	inc r9
	jmp .rle

	.end:

end:
	DEBUG
	jmp $

%if ($ - $$) > 0x199
	%fatal "Stage 2 too big!"
%endif

[segment data start=0x200 vstart=0x20200]
%include "gdt.asm"

data:
	.str:
		%include "logo.asm"
