%assign MEM_REAL_STAGE2 0x2000
%assign MEM_PROTECT_STAGE2 (MEM_REAL_STAGE2 * 0x10)

%assign MEM_PAGETABLE 0x1000
%assign MEM_IDT 0x10000
%assign MEM_IDT_PTR (MEM_IDT + (16 * 256))
