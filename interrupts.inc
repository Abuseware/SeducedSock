%macro idte 2
	mov rax, %2
	mov WORD [MEM_IDT + (%1 * 16)], ax
	shr rax, 0x10
	mov WORD [MEM_IDT + (%1 * 16) + 6], ax
	shr rax, 0x10
	mov DWORD [MEM_IDT + (%1 * 16) + 8], eax
%endmacro
