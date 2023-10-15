%include "unistd.inc"

global _start
extern bytebin2hexascii

section .data
	output:	dw	0
		db	10
	.len:	equ	$-output

section .text

_start:
	mov     rdi,0x3A
	call	bytebin2hexascii
	rol 	ax,8
	mov     word [output],ax
	syscall	write,stdout,output,output.len
	syscall	exit,0
