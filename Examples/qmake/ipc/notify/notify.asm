;name: notify.asm
;
;description: This example comes from stackoverflow (https://stackoverflow.com/questions/20317417/nasm-notify-send/64191219#64191219).
;             You must install libnotify-dev to have this one build.
;             The program sends from a terminal a notification message to linux desktop (GUI) wich pops up at the upper right corner in my case.
;

bits 64

%include "../notify/notify.inc"

global main

section .bss
;uninitialized read-write data 

section .data
;initialized read-write data

section .rodata
;read-only data
    name            db  "Sample Notification", 0
    title           db  "Just a test", 0

section .text

main:
    push    rbp
    mov     rbp,rsp

    mov     rdi, name
    call    notify_init

    mov     rdx, 0
    mov     rsi, title
    mov     rdi, name
    call    notify_notification_new

    mov     rsi, 0
    mov     rdi, rax
    call    notify_notification_show

    call    notify_uninit

    xor     rax,rax             ;return error code
    mov     rsp,rbp
    pop     rbp
    ret                         ;exit is handled by compiler
