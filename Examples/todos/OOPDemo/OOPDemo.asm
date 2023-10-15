;name: OOPDemo.asm
;
;description:
;

bits 64

%include "OOPDemo.inc"

struc INT_STRUC
	.value:	resq	1
	.Get:	resq	1		;;pointer to get the value
	.Set:	resq	1		;;pointer to set the value
	.Write:	resq	1		;;pointer to write function
endstruc

%macro Integer 1-2 0
%1:
istruc INT_STRUC
	at INT_STRUC.value, dq %2
	at INT_STRUC.Get,	dq get_function
	at INT_STRUC.Set,	dq set_function
	at INT_STRUC.Write,	dq 0
iend
%define %1.Get		INT_FUNC_GET	%1
%define %1.Set		INT_FUNC_SET	%1
%define %1.Write	INT_FUNC_WRITE	%1

%endmacro

%macro INT_FUNC_GET 1
	mov		rdi,%1
	call	qword[%1 + INT_STRUC.Get]
%endmacro

%macro INT_FUNC_SET 1
	mov		rsi,rdi							;move value into rsi
	mov		rdi,%1
	call	qword[%1 + INT_STRUC.Set]
%endmacro

%macro INT_FUNC_WRITE 1
	mov		rdi,%1
	call	qword[%1 + INT_STRUC.Write]
%endmacro


global _start

section .bss

section .data
;2struc declaration as data
	Integer a,5
	Integer b,6

section .text

_start:

	a.Get
	b.Get
	mov	rdi,10
	a.Set
	mov	rdi,1254
	b.Set
	a.Get
	b.Get
	mov		rdi,a
	mov		rax,a_print_function
	mov		[rdi+INT_STRUC.Write],rax

	mov		rdi,b
	mov		rax,b_print_function
	mov		[rdi+INT_STRUC.Write],rax

	a.Write
	b.Write
	syscall exit,0

get_function:
	mov		rax,qword[rdi+INT_STRUC.value]
	ret

set_function:
	mov		rax,rsi
	mov		qword[rdi+INT_STRUC.value],rax
	ret

a_print_function:
[section .data]
	msga:	db	"hello from Integer object A",10
	.len:	equ	$-msga
[section .code]
	mov		rdx,msga.len
	mov		rsi,msga
	mov		rdi,stdout
	syscall	write
	ret

b_print_function:
[section .data]
	msgb:	db	"hello from Integer object B",10
	.len:	equ	$-msgb
[section .code]
	mov		rdx,msgb.len
	mov		rsi,msgb
	mov		rdi,stdout
	syscall	write
	ret
