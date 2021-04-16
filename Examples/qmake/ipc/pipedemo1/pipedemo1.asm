;name: pipedemo1.asm
;
;description: The program creates a pipe, writes three message in it,
;             read on the other end of the pipe and displayed on stdout.
;
;source       Internet

bits 64

%include "../pipedemo1/pipedemo1.inc"

global main

section .bss
;uninitialized read-write data 
    p:
    .read:      resd    1            ; read end of the pipe
    .write:     resd    1            ; write end of the pipe
    inbuf:      resb    MSGSIZE

section .data
;initialized read-write data

section .rodata
;read-only data
    msg1:       db      "hello #1",10
    msg2:       db      "hello #2",10
    msg3:       db      "hello #3",10
    eol:        db      EOL
    pipeerror:  db      "pipe error"
    .length:    equ     $-pipeerror

section .text

main:
    syscall pipe, p
    and     rax, rax
    jns     startpipe                        ; if RAX < 0 then error
    syscall write, stdout, pipeerror, pipeerror.length
    jmp     exit
startpipe:
    ; write msg1 to the pipe
    mov     edi, dword[p.write]
    syscall write, rdi, msg1, MSGSIZE
    ; write msg2 to the pipe
    mov     edi, dword[p.write]
    syscall write, rdi, msg2, MSGSIZE
    ; write msg3 to the pipe
    mov     edi, dword[p.write]
    syscall write, rdi, msg3, MSGSIZE

    xor     r8, r8                           ; init loopcounter
.repeat:
    ; read MSGSIZE bytes from the pipe into the buffer
    mov     edi, dword[p.read]
    syscall read, rdi, inbuf, MSGSIZE
    syscall write, stdout, inbuf, MSGSIZE
    syscall write, stdout, EOL, 1
    inc     r8
    cmp     r8, 3
    jl      .repeat                          ; repeat 2 more times
exit:
    xor     rax,rax             ;return error code
    ret                         ;exit is handled by compiler
