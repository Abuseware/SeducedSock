AS = nasm
ASFLAGS = -Ox -f bin

all: build floppy

build:
	$(AS) $(ASFLAGS) stage1.s
	$(AS) $(ASFLAGS) stage2.s

floppy:
	$(AS) $(ASFLAGS) -o boot.img boot.s

test:
	bochs -q
