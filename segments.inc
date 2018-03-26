%macro load_segments 1
	%ifdef SEG_%1_DS
		mov ax, SEG_%1_DS
		mov ds, ax
	%endif

	%ifdef SEG_%1_ES
		mov ax, SEG_%1_ES
		mov es, ax
	%endif

	%ifdef SEG_%1_SS
		mov ax, SEG_%1_SS
		mov ss, ax
	%endif

	%ifdef SEG_%1_FS
		mov ax, SEG_%1_FS
		mov fs, ax
	%endif

	%ifdef SEG_%1_GS
		mov ax, SEG_%1_GS
		mov gs, ax
	%endif
%endmacro

;; Stage1 segments
%assign SEG_STAGE1_CS 0
%assign SEG_STAGE1_DS 0
%assign SEG_STAGE1_ES 0x2000

%assign SEG_STAGE1_SS 0x1ff0

;; Real mode
%assign SEG_REAL_CS 0
%assign SEG_REAL_DS 0x2000
%assign SEG_REAL_ES 0x2000

%assign SEG_REAL_FS 0x2000
%assign SEG_REAL_GS 0x2000

%assign SEG_REAL_SS 0x1ff0

;; Protected mode
%assign SEG_PROTECT_CS 0x8
%assign SEG_PROTECT_DS 0x10
%assign SEG_PROTECT_ES 0x10

%assign SEG_PROTECT_FS 0x10
%assign SEG_PROTECT_GS 0x10

%assign SEG_PROTECT_SS 0x10

;; Long mode
%assign SEG_LONG_CS 0x8
%assign SEG_LONG_DS 0x10
%assign SEG_LONG_ES 0x10

%assign SEG_LONG_FS 0x10
%assign SEG_LONG_GS 0x10

%assign SEG_LONG_SS 0x10
