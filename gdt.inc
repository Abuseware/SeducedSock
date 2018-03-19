%assign GDT_TYPE_DPL0 (0 << 13) | (0 << 14)
%assign GDT_TYPE_DPL1 (1 << 13)
%assign GDT_TYPE_DPL2 (2 << 13)
%assign GDT_TYPE_DPL3 (3 << 13)
%assign GDT_TYPE_P (1 << 15)
%assign GDT_TYPE_S (1 << 12)

%assign GDT_TYPE_DATA_RO (0 << 8)
%assign GDT_TYPE_DATA_ROA (1 << 8)
%assign GDT_TYPE_DATA_RW (2 << 8)
%assign GDT_TYPE_DATA_RWA (3 << 8)
%assign GDT_TYPE_DATA_RO_ED (4 << 8)
%assign GDT_TYPE_DATA_ROA_ED (5 << 8)
%assign GDT_TYPE_DATA_RW_ED (6 << 8)
%assign GDT_TYPE_DATA_RWA_ED (7 << 8)

%assign GDT_TYPE_CODE_X (8 << 8)
%assign GDT_TYPE_CODE_XA (9 << 8)
%assign GDT_TYPE_CODE_RX (10 << 8)
%assign GDT_TYPE_CODE_RXA (11 << 8)
%assign GDT_TYPE_CODE_XC (12 << 8)
%assign GDT_TYPE_CODE_XCA (13 << 8)
%assign GDT_TYPE_CODE_RXC (14 << 8)
%assign GDT_TYPE_CODE_RXCA (15 << 8)

%assign GDT_FLAG_L (1 << 5)
%assign GDT_FLAG_AVL (1 << 4)
%assign GDT_FLAG_DB (1 << 6)
%assign GDT_FLAG_G (1 << 7)

struc gdtr
	.size:	resw 1
	.base:	resd 1
endstruc

struc gdt_entry
	.limit:	resw 1
	.base:	resw 1
	.type:			resw 1
	.flags:			resw 1
endstruc
