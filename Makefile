AS = nasm
ASFLAGS = -f bin

.PHONY: all

.s:
	$(AS) $(ASFLAGS) $<

all: build floppy

build: stage1 stage2

floppy: boot

clean:
	rm -f stage1 stage2 boot
