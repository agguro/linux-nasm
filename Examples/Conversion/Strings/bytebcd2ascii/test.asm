%include "unistd.inc"

global _start
extern bytebcd2ascii

section .data
	output:	dw	0
		db	10
	.len:	equ	$-output

section .text

_start:
	mov     rdi,25
	call	bytebcd2ascii
	rol 	ax,8
	mov	word [output],ax
	syscall	write,stdout,output,output.len
	syscall	exit,0
