struc mbr_partition
	.status:			resb 1

	.start_head:		resb 1
	.start_sector:		resb 1
	.start_cylinder:	resb 1

	.type:				resb 1

	.end_head:			resb 1
	.end_sector:		resb 1
	.end_cylinder:		resb 1

	.lba_start:			resb 4
	.lba_size:			resb 4
endstruc
