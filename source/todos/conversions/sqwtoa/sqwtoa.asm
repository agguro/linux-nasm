;sqwtoa.asm
;	signed qword to ascii conversion
;
;source: http://www.ray.masmcode.com/fpu.html
;
;remark:
;	dec 23, 2019
;		- rewritten for nasm on Linux systems.
;todos:
;		- in later versions the program will extend with output options.

bits 64
%include "unistd.inc"

section .bss
	buffer:	resb 20
section .rodata
	crlf:	db	10

section .text
	global _start
	global sqwtoa

_start:
	;the last bit (bit 63) is the sign bit.
	;1 means a negative qword integer, 0 a positive
	;example data in rdi
	mov		rdi,0x7FFFFFFFFFFFFFFF
	;pointer to buffer in rsi, this buffer must be 20 bytes long
	mov		rsi,buffer
	;here we call the sqwtoa procedure
	call 	sqwtoa
	;rdi and rsi are unchanged, rax contains the length of the converted integer
	syscall write,stdout,rsi,rax
	syscall write,stdout,crlf,1
	;terminate
	syscall exit, 0

sqwtoa:
	;rsi has the pointer to the buffer, rdi the qword to convert in ASCII
	add 	rsi,20				;end of buffer
	push    rsi
	mov		rax,rdi
	test 	rax,rax
	jns 	.@F
	neg 	rax					;make rax positive
.@F:
	;convert the positive value in rax
	xor 	rdx,rdx
	mov 	rcx,0xCCCCCCCCCCCCCCCD
	mov		rbx,10
.@B:
	mul		rcx					;multiply by magic number
	shrd	rax,rdx,3			;binary fractional "remainder" back in rax
	shr		rdx,3				;rdx = quotient
	inc		rax					;precaution against occasional "underflow"
	push	rdx					;save current quotient for next division
	mul		rbx					;x10 gets "decimal" remainder into rdx
	add		dl,0x30				;convert remainder to ascii
	mov		[rsi],dl			;insert it into buffer
	dec		rsi
	pop		rax					;retrieve current quotient
	test	rax,rax				;test if done
	jnz		.@B					;continue if not done
	mov		rax,rdi
	test 	rax,rax
	jns 	.done
	mov		byte[rsi],'-'
	dec		rsi
.done:	
	;here we can decide to add/remove a plus sign in the ASCII expression
	pop		rax					;last byte of string
	sub 	rax,rsi				;subtract first byte of string
	inc     rsi
	ret
