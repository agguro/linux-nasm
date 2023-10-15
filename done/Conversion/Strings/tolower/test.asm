%include "unistd.inc"

global _start
extern tolower

section .data
	string:	    db	"THIS UPPERCASE CHARACTERS TO LOWERCASE"
	.len:		equ	$-string
			    db	0
	lf:		    db	10

section .text

_start:
	syscall write,stdout,string,string.len
	syscall write,stdout,lf,1
	mov	    rdi,string
	call	tolower
	syscall write,stdout,string,string.len
	syscall write,stdout,lf,1
	syscall exit,0
