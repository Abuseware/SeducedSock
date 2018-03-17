DEBUG ?= 0

AS = nasm
ASFLAGS = -f bin -DEBUG=$(DEBUG)

.PHONY: all

.s:
	$(AS) $(ASFLAGS) $<

all: build floppy

build: stage1 stage2

floppy: boot
	mv boot boot.img

clean:
	rm -f stage1 stage2 boot
