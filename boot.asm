%include "mbr.inc"
incbin 'stage1'

times 0x1be - ($ - $$) db 0 ; Fill gap before partition table

partitions:

	.first:
		istruc mbr_partition
			at mbr_partition.status, db (1 << 7) ; Active

			at mbr_partition.start_head, db 1
			at mbr_partition.start_sector, db 1
			at mbr_partition.start_cylinder, db 0

			at mbr_partition.type, db 0x6 ; FAT16B (Big)

			at mbr_partition.end_head, db 0
			at mbr_partition.end_sector, db 1
			at mbr_partition.end_cylinder, db 64

			at mbr_partition.lba_start, dd 5
			at mbr_partition.lba_size, dd 20475
		iend


fill:
	;; Fill unused space and partition table
	times 510 - ($ - $$) db 0

	;; Mark as bootable
	dw 0xAA55

incbin 'stage2'
times 2560-($-$$) db 0
incbin 'partition.img'
;times 10485760-($-$$) db 0
