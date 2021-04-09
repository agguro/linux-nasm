;name: hello.asm
;
;description: A less simple (however) hello world example.
;

bits 64

    %include "../../../qmake/basics/hello/hello.inc"

global main

section .bss
;uninitialized read-write data 

section .data
;initialized read-write data

section .rodata
;read-only data
    msg:    db  "Hello world with qtcreator",10
    .len:   equ $-msg

section .text

main:
    push    rbp
    mov     rbp,rsp

    syscall write,stdout,msg,msg.len

    xor     rax,rax             ;return error code
    mov     rsp,rbp
    pop     rbp
    ret                         ;exit is handled by compiler
