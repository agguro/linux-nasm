; Name:         helloworld.asm
; Build:        see makefile
; Run:          ./helloworld
; Description:  Writes 'Hello world!" to STDOUT
;
; build: nasm "-felf64" hello.asm -l hello.lst -o hello.o
;        ld -s -melf_x86_64 -o hello hello.o 
;
; definitly not the shortest code but it's a _start

[list -]
     %include "unistd.inc"
[list +]

BITS 64

section .data

     message:   db "Hello world!",10
     .length:	equ $-message
        
section .text
     global _start
_start:
     mov        rdi, STDOUT
     mov        rsi, message
     mov        rdx, message.length
     mov        rax, SYS_WRITE
     syscall
     xor        rdi, rdi
     mov        rax, SYS_EXIT
     syscall
