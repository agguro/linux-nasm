; Name:         hello.asm
; Description:  Writes "Hello world!" to stdout
;
; build: nasm "-felf64" hello.asm -l hello.lst -o hello.o
;        ld -s -melf_x86_64 -o hello hello.o 

[list -]
     %include "unistd.inc"
[list +]

bits 64

section .data

     msg:   db "Hello world!",10
     .len: 	equ $-msg
        
section .text
     global _start
     
_start:
	syscall	write,stdout,msg,msg.len
	syscall	exit,0
