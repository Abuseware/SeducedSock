%include "segments.inc"
%include "memory.inc"
%include "gpu.inc"
%include "interrupts.inc"
%include "paging.inc"
%include "debug.inc"

;; Char color code
%assign LOGO_COLOR 0xA

[CPU x64]
[BITS 64]
[segment text vstart=0x400000]
idte 0x20, int_0

;; Remap PIC
	mov al, 0x11
	out 0x20, al ; Restart PIC1
	out 0xa0, al ; Restart PIC2

	mov al, 0x20 ; PIC1 @32
	out 0x21, al

	add al, 8    ; PIC2 @40
	out 0xa1, al

	mov al, 0x4 ; cascade
	out 0x21, al
	mov al, 0x2
	out 0xa1, al

	mov al, 0x1 ; icw4 80x86
	out 0x21, al
	out 0xa1, al

	;; Disable PIC interrupts
	mov al, 0xff
	out 0x21, al
	out 0xa1, al

	;; Enable RTC interrupt
	in al, 0x21
	and al, ~1 ; PIT
	out 0x21, al

	;; Configure PIT
	mov al, (2 << 1) | (3 << 4)
	out 0x43, al
	mov ax, 59659; Set clock divider, 1193182Hz/59660 = 0.05000(…garbage…)
	out 0x40, al
	shr ax, 8
	out 0x40, al

clear:
	;; Clear whole screen
	mov rdi, FB
	mov rcx, FB_SIZ
	mov rax, 0x0
	rep stosw

logo:
	;; Draw logo
	;; Prepare registers for loading string
	mov r8, FB
	mov r9, 1
	mov rsi, data.str

	;; Read X,Y from data
	xor rax, rax
	xor rbx, rbx
	lodsw ;; Load Y,X to eax
	mov bl, al ;; Move Y to bl
	imul rbx, FB_W ;; Multiply FB_W by Y to get starting line
	shr rax, 8 ;; Move rax one byte to right
	add rbx, rax ;; Add X to starting point
	imul ebx, 2 ;; Multiply by two (2 bytes per char in framebuffer)
	add r8, rbx ;; Add calculated position to framebuffer address

	.write:
	;; Read RLE pair from "string"
	lodsw
	;; Prepare counter
	xor rcx, rcx
	mov cl, ah
	;; Decode RLE
	.rle:
	cmp cl, 0x0
	jz .write
	dec cl
	;; Jump on special chars
	cmp al, 0xA
	jz .new_line ; Make new line on 0xA (\n)
	cmp al, 0x0
	jz .end ; Exit loop on null byte

	;; Write char to framebuffer
	mov ah, LOGO_COLOR
	mov [r8], WORD ax
	add r8, 2
	jmp .rle

	.new_line:

	mov r8, FB_W * 2
	imul r8, r9
	add r8, FB
	add r8, rbx
	inc r9
	jmp .rle

	.end:

end:
	mov al, [data.counter]

	;; Convert time counter to color code (0-15)
	;mov bl, 16
	;div bl
	;shr ax, 8

	;; Fast convert time counter to color code (0-15) - without div
	and al, ~0xf0

	;; Redraw FB with new color
	mov rdx, FB+1
	.loop:
	mov [rdx], BYTE al
	add rdx, 2
	cmp rdx, FB + FB_SIZ + 1
	jnz .loop

	hlt
	jmp end

;; Handle PIT interrupt (timer)
int_0:
	push rax
	push rbx
	push rcx
	push rdx

	xor rax, rax

	;; Keep tick counter running freely
	mov al, [data.ticks]
	inc al
	mov [data.ticks], al

	;; Calculate timer from ticks count
	mov bl, 20 ; Divide ticks by 20: 0.05 * 20 = 1s :)
	div bl
	cmp ah, 0
	ja .end ; Skip if not divisible

	mov al, [data.counter]
	inc al
	mov [data.counter], al

	.end:

	;; Send EOI to PIC
	mov al,0x20
    out 0x20,al

    pop rdx
    pop rcx
    pop rbx
    pop rax
    iretq

[segment data]
data:
	.str:
		%include "logo.asm"
	.ticks: db 0
	.counter: db 0
