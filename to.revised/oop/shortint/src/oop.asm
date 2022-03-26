;name: oop.asm
;
;description:
;   test program for classes experiment Nasm

%macro method 1-2
    %if %0 > 1
      mov rdi,%2
    %endif
    %1
%endmacro

%macro new 1
	[section .data]
	%1.old:	dq		0
	%1:		dq		0
	[section .text]
	xor			rdi,rdi
	syscall 	brk
	and 		rax,rax
	mov			[%1.old]
	jz			.@1
	mov			rdi,25
	add			rdi,rax
	syscall		brk
	mov 		[%1],rax
	.@1:
%endmacro

bits 64
[list -]
%include "../src/include/oop.inc"
[list +]
global _start

section .bss

struc t
	.v:	resb 1
endstruc

section .rodata
    msga:   db "value changed",10
    .len:   equ $-msga
    msgb:   db "value changed again",10
    .len:   equ $-msgb

section .data
    SHORTINT a,10,value_changed
    SHORTINT b
    
    d istruc t
		at 	t.v,	db 5
	iend
	
	
section .text

_start:

	mov	al,t_size
	mov rax,d
	mov bl,byte[rax]
	
	
    method b.Set,15
    method b.Get
    mov rdi,rax
    method a.Set
    method a.Set,1
    method a.SetOnChanged,value_changed_again
    method a.Set,15
    method a.Get
    syscall exit,0

value_changed:
    syscall write,stdout,msga,msga.len
    ret
value_changed_again:
    syscall write,stdout,msgb,msgb.len
    ret
