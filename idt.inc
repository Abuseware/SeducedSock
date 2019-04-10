%assign IDT_ENTRY_P (1 << 7)
%assign IDT_ENTRY_DPL0 0
%assign IDT_ENTRY_DPL1 (1 << 5)
%assign IDT_ENTRY_DPL2 (2 << 5)
%assign IDT_ENTRY_DPL3 (3 << 5)
%assign IDT_ENTRY_S (1 << 4)
%assign IDT_ENTRY_TYPE_TASK 0x5
%assign IDT_ENTRY_TYPE_INT 0xE
%assign IDT_ENTRY_TYPE_TRAP 0xF

struc idtr
    .limit:     resw 1
    .base:      resq 1
endstruc
