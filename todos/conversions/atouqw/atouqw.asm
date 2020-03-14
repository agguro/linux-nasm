;atouqw.asm
;	ascii to unsigned qword conversion
;
;source: http://www.ray.masmcode.com/fpu.html
;
;remark:
;	dec 23, 2019
;		- rewritten for nasm on Linux systems.

bits 64
%include "unistd.inc"

section .bss
	buffer:	resb 8
section .rodata
	crlf:	db	10
	uqword:	db	"18446744073709551615",0
	
section .text
global _start
global atouqwt

_start:
	;example data in rdi
	mov		rdi,uqword
	;pointer to buffer in rsi, this buffer must be 8 bytes long
	mov		rsi,buffer
	;here we call the qwtoa procedure
	call 	atouqw
	;rdi and rsi are unchanged, rax contains the length of the converted integer
	syscall write,stdout,rsi,rax
	syscall write,stdout,crlf,1
	;terminate for now
	syscall exit, 0

atouqw:
	;rsi has the pointer to the buffer, rdi the pointer to the ASCII uqword zero terminated string

	ret
