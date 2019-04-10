DEBUG ?= 0
MTOOLSRC ?= $(PWD)/.mtoolsrc

AS = nasm
ASFLAGS = -Wall -f bin -DEBUG=$(DEBUG)

CC = x86_64-elf-gcc
CFLAGS = -std=c11 -O0 -nostdlib -m64 -march=athlon64 -masm=intel -ffreestanding

PY = python

.PHONY: all

.SUFFIXES: .txt .asm

.asm:
	$(AS) $(ASFLAGS) $<

.asm.o:
	$(AS) $(ASFLAGS) -f elf64 -o $@ $^

.txt.asm:
	$(PY) rle.py $<

all: build boot.img

build: stage1 stage2 stage3 kernel

stage2: logo.asm

kernel:
	$(CC) $(CFLAGS) -Wl,-s,--nmagic,--script=kernel.ld -o kernel kernel.c

partition.img: kernel
	dd if=/dev/zero of=partition.img bs=1024 count=10238
	env MTOOLSRC=$(MTOOLSRC) mformat c:
	env MTOOLSRC=$(MTOOLSRC) mlabel c:OS
	env MTOOLSRC=$(MTOOLSRC) mcopy kernel c:\kernel

boot.img: partition.img boot
	cp boot boot.img

clean:
	rm -f logo.asm stage1 stage2 kernel boot *.img
