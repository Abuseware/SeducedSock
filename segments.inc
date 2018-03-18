;; Real mode
%define SEG_REAL_CS 0
%define SEG_REAL_DS 0x2000
%define SEG_REAL_ES 0x2000

%define SEG_REAL_FS 0x2000
%define SEG_REAL_GS 0x2000

%define SEG_REAL_SS 0x1ff0

;; Protected mode
%define SEG_PROTECT_CS 0x8
%define SEG_PROTECT_DS 0x10
%define SEG_PROTECT_ES 0x10

%define SEG_PROTECT_FS 0x10
%define SEG_PROTECT_GS 0x10

%define SEG_PROTECT_SS 0x10

;; Long mode
%define SEG_LONG_CS 0x8
%define SEG_LONG_DS 0x10
%define SEG_LONG_ES 0x10

%define SEG_LONG_FS 0x10
%define SEG_LONG_GS 0x10

%define SEG_LONG_SS 0x10
