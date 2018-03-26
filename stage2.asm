%include "segments.inc"
%include "memory.inc"
%include "gpu.inc"
%include "gdt.inc"
%include "idt.inc"
%include "interrupts.inc"
%include "paging.inc"
%include "debug.inc"

;; Char color code
%assign LOGO_COLOR 0xA

;; Position of logo

[CPU x64]
[BITS 16]
[segment text vstart=MEM_PROTECT_STAGE2]
start:
	;; Prepare for protected mode
	cli
	load_segments REAL
	xor sp, sp

	;; Load GDT for protected mode
	lgdt [gdt32.gdtr]

	;; set protected mode (PE)
	mov eax, cr0
	or al, 1
	mov cr0, eax

	jmp dword SEG_PROTECT_CS:mode32

[BITS 32]
mode32:
	load_segments PROTECT
	mov esp, MEM_PROTECT_STAGE2 - 0x10

	;;Prepare paging
	xor eax, eax
	mov edi, MEM_PAGETABLE
	mov ecx, 4096
	rep stosd

	mov eax, MEM_PAGETABLE
	mov DWORD [eax], PT_P | PT_RW | (MEM_PAGETABLE + 0x1000)
	add eax, 0x1000
	mov DWORD [eax], PT_P | PT_RW | (MEM_PAGETABLE + 0x2000)
	add eax, 0x1000
	mov DWORD [eax], PT_P | PT_RW | PT_PS

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

	jmp DWORD SEG_LONG_CS:mode64

[BITS 64]
mode64:
	load_segments LONG
	mov rsp, MEM_PROTECT_STAGE2 - 0x10

	push rsp

	;; Disable NMI
	in al, 0x70
	or al, 0x80
	out 0x70, al

	;; Prepare IDT
	xor rax, rax
	mov rdi, MEM_IDT
	mov rcx, 16 * 256
	rep stosb

	DEBUG
	;; Fill IDT
	mov rcx, 0
	idt_loop:
		mov rdx, rcx
		imul rdx, 16 ; Each entry is 16 bytes wide
		add rdx, MEM_IDT ; Add starting point
		mov rax, int_default
		mov WORD [rdx], ax ; put low 16 bits of addr
		mov WORD [rdx + 2], SEG_LONG_CS ; selector
		;mov BYTE [rax + 4], 0; IST
		mov BYTE [rdx + 5], 0x8e ; entry type and flags
		shr rax, 0x10 ; get and put middle 16 bits of addr
		mov WORD [rdx + 6], ax
		shr rax, 0x10 ; get and put upper 32 bits of addr
		mov DWORD [rdx + 8], eax
		;mov DWORD [rax + 12], 0

		inc rcx
		cmp rcx, 256
		jnz idt_loop

	idte 0x20, int_0

	DEBUG
	lidt [idtr64]

	;; Remap PIC
	mov al, 0x11
	out 0x20, al ; Restart PIC1
	out 0xa0, al ; Restart PIC2

	mov al, 0x20 ; PIC1 @32
	out 0x21, al

	add al, 8    ; PIC2 @40
	out 0xa1, al

	mov al, 0x4 ; cascade
	out 0x21, al
	mov al, 0x2
	out 0xa1, al

	mov al, 0x1 ; icw4 80x86
	out 0x21, al
	out 0xa1, al

	;; Disable PIC interrupts
	mov al, 0xff
	out 0x21, al
	out 0xa1, al

	;; Enable RTC interrupt
	in al, 0x21
	and al, ~1 ; PIT
	out 0x21, al

	;; Configure PIT
	mov al, (2 << 1) | (3 << 4)
	out 0x43, al
	mov ax, 59659; Set clock divider, 1193182Hz/59660 = 0.05000(…garbage…)
	out 0x40, al
	shr ax, 8
	out 0x40, al


	DEBUG
	sti

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
	mov al, [data.counter]
	;; Convert time counter to color code (1-15)
	mov bl, 15
	div bl
	shr ax, 8
	add al, 1

	;; Redraw FB with new color, skipping first char (for cursor hiding)
	mov rdx, FB+1
	.loop:
	mov [rdx], BYTE al
	add rdx, 2
	cmp rdx, FB + FB_SIZ + 1
	jnz .loop

	hlt
	jmp end

;; Default interrupt handler
int_default:
	push rax

	;mov al, 0xa
	;out 0x20, al
	;out 0xa0, al
	;in al, 0xa0
	;shl al, 8
	;in al, 0x20

	mov al, 0x20
    out 0x20, al
    out 0xa0, al
    pop rax
	iretq

;; Handle PIT interrupt (timer)
int_0:
	push rax
	push rbx
	push rcx
	push rdx

	xor rax, rax

	;; Keep tick counter running freely
	mov al, [data.ticks]
	inc al
	mov [data.ticks], al

	;; Calculate timer from ticks count
	mov bl, 20 ; Divide ticks by 20: 0.05 * 20 = 1s :)
	div bl
	cmp ah, 0
	ja .end ; Skip if not divisible

	mov al, [data.counter]
	inc al
	mov [data.counter], al

	.end:

	;; Send EOI to PIC
	mov al,0x20
    out 0x20,al

    pop rdx
    pop rcx
    pop rbx
    pop rax
    iretq


%if ($ - $$) > 0x499
	%fatal "Stage 2 too big!"
%endif

[segment data start=0x500 vstart=0x20500]
%include "gdt.asm"

align 4
idtr64:
istruc idtr
at idtr.limit, dw (256 * 16) - 1
at idtr.base, dq MEM_IDT
iend

data:
	.str:
		%include "logo.asm"
	.ticks: db 0
	.counter: db 0
