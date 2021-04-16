;name: pipedemo3.asm
;
;description: In this example a parent process write into the pipe.  The child process then
;             displays the message, processed on screen from the pipe by CHARSTOREAD characters
;             at the time.  The message will be chopped and displayed.
;
;source:      Internet
;             The original source displays also the number of chars read by the child
;             process at the time.  This is removed here.
;

bits 64

%include "../pipedemo3/pipedemo3.inc"

global main

section .bss
;uninitialized read-write data 
    p:
    .read:      resd    1               ;read-end
    .write:     resd    1               ;write-end
    buffer:     resb    20

section .data
;initialized read-write data

section .rodata
;read-only data
    message:        db     "One of the fundamental features that makes Linux and other Unices useful is the 'pipe'."
                    db     "Pipes allow separate processes to communicate without having been designed explicitly "
                    db     "to work together. This allows tools quite narrow in their function to be combined in complex ways."
    .len:           equ    $-message

    eol:            db     10

    pipeerror:      db     "pipe error"
    .len:           equ    $-pipeerror
    forkerror:      db     "fork error"
    .len:           equ    $-forkerror
    childfailed:    db     "Child failed",10
    .len:           equ    $-childfailed
    childsucces:    db     "Child finished",10, 10
    .len:           equ    $-childsucces

section .text

main:
    syscall pipe, p
    jns     .fork
    push    rax
    syscall write,stderr,pipeerror,pipeerror.len
    pop     rax
    ret                             ;return error
.fork:
    syscall fork
    and     rax,rax
    jnz     child
    jns     parent
    push    rax
    syscall write,stderr,pipeerror,pipeerror.len
    pop     rax
    ret                             ;return error
;------------------------------------------------------
; child process
;------------------------------------------------------
child:
    xor     rdi,rdi
    ; close the write end of the pipe
    mov     edi,dword[p.write]
    syscall close,rdi
    ; now read the messages from the pipe
.read:
    mov     edi,dword[p.read]
    syscall read,rdi,buffer,CHARSTOREAD
    mov     r8,rax                          ;nchars read
    and     rax,rax                         ;have we read any bytes?
    jz      .close                          ;if all bytes read,write message and exit
    syscall write,stdout,buffer,r8
    ; write an end of line
    syscall write,stdout,eol,1
    ; sync stdout
    syscall fsync,stdout
    jmp     .read
    ; close the pipe
.close:
    mov     edi,dword[p.read]
    syscall close,rdi
    ; and exit
    xor     rax,rax
    ret                         ;exit is handled by compiler

;------------------------------------------------------
; parent process
;------------------------------------------------------
parent:
    ; close the read end of the pipe
    mov     edi,dword[p.read]
    syscall close,rdi
    ; write the message to the pipe full length
    mov     edi,dword[p.write]
    syscall write,rdi,message,message.len
    ; close the pipe
    mov     edi,dword[p.write]
    syscall close,rdi
    ; wait for the child
    syscall wait4,0,0,0,0
    and     rax,rax
    jnz     .childsuccess
    push    rax
    syscall write,stderr,childfailed,childfailed.len
    pop     rax
    ret
.childsuccess:
    ; following message can be on screen before the child's output has finished
    syscall write,stdout,childsucces,childsucces.len
    xor     rax,rax                 ;return no error
    ret
