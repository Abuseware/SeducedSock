%include "segments.inc"
%include "memory.inc"
%include "paging.inc"
%include "gdt.inc"
%include "idt.inc"
%include "interrupts.inc"
%include "debug.inc"

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

	DEBUG
	lidt [idtr64]
	sti

end:
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

%if ($ - $$) > 1536
	%fatal "Stage 2 too big!"
%endif
