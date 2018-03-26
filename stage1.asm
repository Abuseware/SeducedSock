%include "segments.inc"
%include "memory.inc"
%include "gpu.inc"
%include "mbr.inc"
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

times 0x1be - ($ - $$) db 0 ; Fill gap before partition table

partitions:

	.first:
		istruc mbr_partition
			at mbr_partition.status, db (1 << 7) ; Active

			at mbr_partition.start_head, db 1
			at mbr_partition.start_sector, db 1
			at mbr_partition.start_cylinder, db 0

			at mbr_partition.type, db 0x4 ; FAT16 (Small)

			at mbr_partition.end_head, db 0
			at mbr_partition.end_sector, db 1
			at mbr_partition.end_cylinder, db 64

			at mbr_partition.lba_start, dd 1
			at mbr_partition.lba_size, dd 2048
		iend


fill:
	;; Fill unused space and partition table
	times 510 - ($ - $$) db 0

	;; Mark as bootable
	dw 0xAA55
