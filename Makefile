AS=nasm

all:
	${AS} -Ox -f bin -o boot.bin boot.s
