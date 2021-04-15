;name: testlibs.asm
;
;description: test file for dynamic library
;

bits 64

%include "../libtest.inc"

global main

section .bss
;uninitialized read-write data

section .data
;initialized read-write data
    ;versionstring from shared library
    version:  dq     versionstring1

section .rodata
;read-only data

section .text

main:
    push    rbp
    mov     rbp,rsp

    ;static library call
    call    writestring

    ;dynamic library calls
    call    getversion
    call    getversionstring1
    call    getversionstring2
    call    printversionstring1
    call    printversionstring2

    xor     rax,rax             ;return error code
    mov     rsp,rbp
    pop     rbp
    ret                         ;exit is handled by compiler
