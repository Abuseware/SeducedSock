 DEBUG ?= 0

AS = nasm
ASFLAGS = -Wall -f bin -DEBUG=$(DEBUG)

PY = python

.PHONY: all

.SUFFIXES: .txt .asm

.asm:
	$(AS) $(ASFLAGS) $<

.txt.asm:
	$(PY) rle.py $<

all: build hdd

build: stage1 stage2

stage2: logo.asm

hdd: boot
	mv boot boot.img

clean:
	rm -f logo.asm stage1 stage2 boot boot.img
