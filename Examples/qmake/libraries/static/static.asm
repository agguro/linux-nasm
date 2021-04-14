;name: static.asm
;
;description:
;

bits 64

%include "../../../qmake/libraries/static/static.inc"

global writestring

section .bss
;uninitialized read-write data 

section .data
;initialized read-write data

section .rodata
;read-only data
    hello:  db  "hello, you are in the static library",10
    .len:   equ $-hello

section .text

writestring:
    push    rbp
    mov     rbp,rsp

    syscall write,stdout,hello,hello.len

    xor     rax,rax             ;return error code
    mov     rsp,rbp
    pop     rbp
    ret                         ;exit is handled by compiler
