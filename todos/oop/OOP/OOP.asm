;name: OOP.asm
;
;description:
;   test program for classes experiment Nasm

%macro method 1-2
    %if %0 > 1
      mov rdi,%2
    %endif
    %1
%endmacro

bits 64
[list -]
%include "OOP.inc"
[list +]
global _start

section .bss
section .rodata
    msga:   db "value changed",10
    .len:   equ $-msga
    msgb:   db "value changed again",10
    .len:   equ $-msgb

section .data
    CBYTE a,10,value_changed
    CBYTE b

section .text

_start:
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
