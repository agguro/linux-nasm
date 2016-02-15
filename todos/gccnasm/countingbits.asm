; name:         libhello.asm
; build:
;               nasm -f elf64 -o libhello.o libhello.asm -l libhello.list
;               ar rcs libhello.a libhello.o
;
; Description:  static library (archivefile) demonstration

%define SYS_EXIT        60
%define SYS_WRITE       1
%define STDOUT          1

bits 64
align 16

global  WriteString
global  Exit

section .text

WriteString:
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
        ret
        
Exit:
        mov     rax, SYS_EXIT
        syscall