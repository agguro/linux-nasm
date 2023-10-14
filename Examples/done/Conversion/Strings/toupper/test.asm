%include "unistd.inc"

global _start
extern toupper

section .data
	string:	    db	"this lowercase characters to uppercase"
	.len:		equ	$-string
			    db	0
	lf:		    db	10

section .text

_start:
	syscall write,stdout,string,string.len
	syscall write,stdout,lf,1
	mov	    rdi,string
	call	toupper
	syscall write,stdout,string,string.len
	syscall write,stdout,lf,1
	syscall exit,0
