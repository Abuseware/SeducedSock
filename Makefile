AS = nasm
ASFLAGS = -Ox -f bin

all: build floppy

build:
	$(AS) $(ASFLAGS) stage1.s
	$(AS) $(ASFLAGS) stage2.s

floppy:
	cat stage1 stage2 > boot.img
	dd bs=512 count=2876 < /dev/zero >> boot.img

test:
	bochs -q
