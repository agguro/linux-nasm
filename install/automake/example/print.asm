;name: print.asm
;description: print a string using syscall write to stdout

[list -]
     %include "unistd.inc"
[list +]
bits 64
global print
section .text

print:
    syscall write, stdout, rdi, rsi

    ret
