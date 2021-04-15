;name: exeapp2.asm
;
;description: Demonstration on how to execute a program with commandline arguments
;             from within a program.
;             This example, as extension of exeapp2, shows how to pass arguments.
;             Assumed is the presence of the program arguments.

bits 64

%include "../exeapp2/exeapp2.inc"

global main

section .bss
;uninitialized read-write data 

section .data
;initialized read-write data

section .rodata
;read-only data
    filename:       db  "arguments",0                   ; full path!
    .length:        equ $-filename
    argv1:          db  "hello", 0                      ; a first argument to pass
    argv2:          db  "world", 0                      ; a second argument to pass
    ;... put more arguments here

    argvPtr:        dq  filename
                    dq  argv1
                    dq  argv2
                    ; more pointers to arguments here
    envPtr:         dq  0                            ; terminate the list of pointers with 0
        ; envPtr is put at the end of the argv pointer list to safe some bytes

    forkerror:      db  "fork error",10
    .len:           equ $-forkerror
    execveerror:    db  "execve error(not expected)",10
    .len:           equ $-execveerror
    wait4error:     db  "wait4 error",10
    .len:           equ $-wait4error

section .text

main:

    syscall fork
    and     rax,rax
    jns     .continue
    syscall write,stderr,forkerror,forkerror.len
    jmp     .exit
.continue:
    jz      .runchild
    ; wait for child to terminate
    syscall wait4, 0, 0, 0, 0
    jns     .exit
    syscall write,stderr,wait4error,wait4error.len
    jmp     .exit
.runchild:
    syscall execve,filename,argvPtr,envPtr
    jns     .exit
    syscall write,stderr,execveerror,execveerror.len
.exit:
    xor     rax,rax             ;return error code
    ret                         ;exit is handled by compiler
