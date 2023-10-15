%include "unistd.inc"

global _start
extern switchcase

section .data
	string:	    db	"ChAnGe UPPERcase CHARActers tO lowerCASE and vice VERSA."
	.len:		equ	$-string
			    db	0
	lf:		    db	10

section .text

_start:
	syscall write,stdout,string,string.len
	syscall write,stdout,lf,1
	mov	    rdi,string
	call	switchcase
	syscall write,stdout,string,string.len
	syscall write,stdout,lf,1
	syscall exit,0
