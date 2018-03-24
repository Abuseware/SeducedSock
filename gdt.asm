gdt32:
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
