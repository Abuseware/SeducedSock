%include "segments.inc"
%include "memory.inc"
%include "debug.inc"

[CPU x64]
[BITS 16]
[org 0x7c00]

jmp WORD SEG_STAGE1_CS:start ; Unify the segment:offset between BIOSes

start:
	;; Disable interupts
	cli

	;; Enable A20
	mov ax, 0x2401 ; BIOS version
	int 0x15

	in al, 0x92 ; Fast A20
	or al, 2
	out 0x92, al

	;; Prepare segments
	load_segments STAGE1
	xor sp, sp

	;; Set cursor position to (0,0)
	push dx ; Store DX - contains disk id
	mov dx, 0x3D4
	mov al, 14
	out dx, al

	inc dx ; 0x3D5
	mov al, 0
	out dx, al

	dec dx ; 0x3D4
	mov al, 15
	out dx, al

	inc dx ; 0x3D5
	mov al, 0
	out dx, al

	;; Disable cursor
	mov ah, 1
	mov ch, 0x3f
	int 0x10

	;; Clear screen
	mov ah, 0
	mov al, 0x3 ; 80x25 8bit
	int 0x10

	pop dx ; Restore DX for later use

loader:
	;; Read stage2 to ES:BX
	mov ah, 2 ; INT 0x13/0x2 DISK - READ SECTOR(S) INTO MEMORY
	mov al, 4 ; Number of sectors
	mov ch, 0 ; Cylinder
	mov cl, 2 ; Sector
	mov dh, 0 ; Head
	xor bx, bx

	int 0x13

	cmp ah, 0
	jz bootstrap

reboot:
	;; Warm reset if loading stage2 fails
	mov ax, 0x40
	mov es, ax
	mov di, 0x72
	mov ax, 0x1234
	stosw
	jmp WORD 0xFFFF:0x0000

bootstrap:
	jmp WORD MEM_REAL_STAGE2:0 ; Jump to stage2

;; Check if bootstrap size is less than required 446 bytes
%if ($ - $$) > 446
	%fatal "Bootstrap too fat!"
%endif
