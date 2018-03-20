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

all: build hdd

build: stage1 stage2

stage2: logo.s

hdd: boot
	mv boot boot.img

clean:
	rm -f logo.s stage1 stage2 boot boot.img
