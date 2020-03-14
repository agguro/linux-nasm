;name: %{FileName}.asm
;
;description:
;

bits 64

%include "%{FileName}.inc"

global _start

section .bss

section .data

section .text

_start:


    syscall exit,0
