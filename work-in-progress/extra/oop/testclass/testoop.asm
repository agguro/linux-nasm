;name: testoop.asm
;
;description: test object instantiation

bits 64
global _start

%include "unistd.inc"
%include "./test.class.nasm"

section .bss


section .rodata


section .data


section .text

_start:

exit:
    syscall exit,0
    
