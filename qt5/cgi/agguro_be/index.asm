;name: agguro_be.asm
;
;description:
;

bits 64

%include "index.inc"
section .text

global _start

_start:

    syscall write, stdout, page, page.end
    syscall exit,0
