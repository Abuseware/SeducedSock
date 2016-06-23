%include "segments.inc"
%include "memory.inc"
%include "gpu.inc"
%include "debug.inc"

[BITS 16]
[CPU 586]
[org 0x7c00]

jmp WORD SEG_REAL_CS:start			; Unify the segment:offset between BIOSes

start:
	;; Disable interupts
	cli

	;; Enable A20
	mov ax, 0x2401 								; BIOS version
	int 0x15

	in al, 0x92										; Fast A20
	or al, 2
	out 0x92, al

	;; Prepare segments
	mov ax, SEG_REAL_DS
	mov ds, ax

	mov ax, SEG_REAL_ES
	mov es, ax

	mov ax, SEG_REAL_SS
	mov ss, ax
	xor sp, sp

	mov ax, SEG_REAL_FS
	mov fs, ax

	mov ax, SEG_REAL_GS
	mov gs, ax

	;; Set cursor position to (0,0)
	push dx 											; Store DX - contains disk id
	mov dx, 0x3D4
	mov al, 14
	out dx, al

	inc dx 												; 0x3D5
	mov al, 0
	out dx, al

	dec dx												; 0x3D4
	mov al, 15
	out dx, al

	inc dx												; 0x3D5
	mov al, 0
	out dx, al
	pop dx												; Restore DX for later use

clear:
	;; Clear whole screen
	;; Prepare ES
	push es
	push di
	mov ax, FB / 0x10
	mov es, ax
	xor di,di

	;; Clear
	mov cx, FB_SIZ
	mov ax, 0x20
	rep stosw

	;; Restore ES
	pop di
	pop es

loader:
	;; Read stage2 to ES:BX
	mov ah, 2											; INT 0x13/0x2 DISK - READ SECTOR(S) INTO MEMORY
	mov al, 2											; Number of sectors
	mov ch, 0											; Cylinder
	mov cl, 2											; Sector
	mov dh, 0											; Head
	xor bx, bx

	int 0x13

	cmp ah, 0
	DEBUG
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
	DEBUG
	jmp WORD MEM_REAL_STAGE2:0						;Jump to stage2

fill:
	;; Check if bootstrap size is less than required 446 bytes
	%if ($ - $$) > 446
		%fatal "Bootstrap too fat!"
	%endif

	;; Fill unused space and partition table
	times 510 - ($ - $$) db 0

	;; Mark as bootable
	dw 0xAA55
