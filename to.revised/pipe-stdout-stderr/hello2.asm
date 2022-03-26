; Name:         hello2.asm
; Description:  Writes “STDOUT: Hello world!” to stdout
;                      “STDERR: Hello World!” to stderr
;
; build: nasm "-felf64" hello.asm -l hello.lst -o hello.o
;        ld -s -melf_x86_64 -o hello hello.o 

[list -]
     %include "unistd.inc"
[list +]

bits 64

section .data

     msg2stdout:   db "STDOUT: Hello world! nice and clean.",10
     .len: 	       equ $-msg2stdout
     msg2stderr:   db "STDERR: Hello world! full of bugs.",10
     .len: 	       equ $-msg2stderr
     buffer:	times 1024 db 0
        
section .text
     global _start
     
_start:
	syscall	write,stdout,msg2stdout,msg2stdout.len
	syscall	write,stderr,msg2stderr,msg2stderr.len
	syscall	exit,0
