;name:         hello.asm
;description:  Writes “Hello GOOD world!” to STDOUT and
;                     “Hello BAD world!” to STDERR
;
; build: nasm -felf64 hello.asm -o hello.o && ld -s -melf_x86_64 -o hello hello.o 

[list -]
     %include "unistd.inc"
[list +]

bits 64

section .data

    msggood:   db "to STDOUT : Hello GOOD world!",10
    .len: 	equ $-msggood
    msgbad:   db "to STDERR : Hello BAD world!",10
    .len: 	equ $-msgbad
        
section .text
    global _start
     
_start:
    syscall	write,stdout,msggood,msggood.len
    syscall	write,stderr,msgbad,msgbad.len
    syscall	exit,0
