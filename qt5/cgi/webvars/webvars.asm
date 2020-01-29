;name: webvars.asm
;
;description:
;

bits 64

%include "webvars.inc"

global _start

section .bss

section .data

section .text

_start:


    syscall exit,0
