DEBUG ?= 0

AS = nasm
ASFLAGS = -f bin -DEBUG=$(DEBUG)

PY = python

.PHONY: all

.SUFFIXES: .txt .s

.s:
	$(AS) $(ASFLAGS) $<

.txt.s:
	$(PY) rle.py $<

all: build floppy

build: stage1 stage2

stage2: logo.s

floppy: boot
	mv boot boot.img

clean:
	rm -f logo.s stage1 stage2 boot
