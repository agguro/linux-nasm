;name: exit.asm
;description: exit program

[list -]
     %include "unistd.inc"
[list +]
bits 64

section .text
global exit
exit:
    syscall exit,rdi
    ;never run to a 'ret' instruction
