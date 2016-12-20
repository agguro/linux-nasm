; name:         libhello.asm
; build:
;               nasm -f elf64 -o libhello.o libhello.asm -l libhello.list
;               ar rcs libhello.a libhello.o
;
; Description:  static library (archivefile) demonstration

[list -]
    %include "unistd.inc"
[list +]     

bits 64
align 16

global  WriteString
global  Exit

section .text

WriteString:
    ; string and length is already in RSI, RDX
    syscall write, stdout, rsi, rdx
    ret
        
Exit:
    syscall exit, 0
