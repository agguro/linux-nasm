;name: shortint.asm
;
;build: /usr/bin/nasm -f elf64 -F dwarf -g shortint.asm -o shortint.o
;       ld -melf_x86_64 -o shortint shortint.o

;description: demo attempt to implement OOP style assembly code


%macro method 1-2
    %if %0 > 1
    [section .text]
      mov rdi,%2
    %endif
%endmacro

%macro new 1-2
	[section .data]
    SHORTINT    %1,%2
	%1.old: 	dq		0
	%1.new:  	dq		0
	[section .text]
	xor			rdi,rdi
	syscall 	brk
	and 		rax,rax
	mov			[%1.old],rax
	jz			.@1
	mov			rdi,25
	add			rdi,rax
	syscall		brk
	mov 		qword[%1.new],rax
	.@1:
    mov         qword[%1.old],%2
%endmacro

bits 64
[list -]
%include "unistd.inc"
%include "shortint.class.inc"

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
;    SHORTINT a,10,value_changed
;    SHORTINT b
    
    d istruc t
		at 	t.v,	db 5
	iend
	
	
section .text

_start:
    nop
    new a,0
    nop
    mov rax,a.value
;    method a.Set
;    method a.SetOnChanged,value_changed

;    method a.Set,1
;    method a.Set,15
    
;    method a.Get
        

;	mov	al,t_size
;	mov rax,d
;	mov bl,byte[rax]
	
	
;    method b.Set,15
;    method b.Get
;    mov rdi,rax
;    method a.Set
;    method a.Set,1
;    method a.SetOnChanged,value_changed_again
;    method a.Set,15
;    method a.Get
    syscall exit,0

value_changed:
    syscall write,stdout,msga,msga.len
    ret
value_changed_again:
    syscall write,stdout,msgb,msgb.len
    ret
