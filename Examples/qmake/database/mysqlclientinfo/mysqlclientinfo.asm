;name: mysqlclientinfo.asm
;
;description: display MySQL Client version

bits 64

%include "../../../qmake/database/mysqlclientinfo/mysqlclientinfo.inc"

global main

section .bss
;uninitialized read-write data 

section .data
;initialized read-write data

section .rodata
;read-only data
    text:   db "MySQL client Version: %s", 10, 0

section .text

main:
    push    rbp
    mov     rbp,rsp

    call      mysql_get_client_info
    mov       rsi, rax        ; pointer to version info in rsi
    mov       rdi, text       ; pointer to text in rdi
    xor       rax, rax        ; no integers to print
    call      printf

    xor     rax,rax             ;return error code
    mov     rsp,rbp
    pop     rbp
    ret                         ;exit is handled by compiler
