;name: exeapp3.asm
;
;description: Demonstration on how to execute a bash script from a program and the environment parameters.
;             be sure that the script is set executable with chmod +x
;             We set an environment parameter TESTVAR to a value and read it out with the script test.sh.
;             Running the script directly doesn't display the TESTVAR value. (unless someone has defined it already)
;             It's pretty much the same as running an executable. The script must be marked as executable.

bits 64

%include "../exeapp3/exeapp3.inc"

global main

section .bss
;uninitialized read-write data 

section .data
;initialized read-write data

section .rodata
;read-only data
    filename:       db  "test.sh",0
    .len:           equ $-filename
    ;... put more arguments here
    envp1:          db  "TESTVAR=123456",0
    ;... put more environment paraters here
    argvPtr:        dq  filename
    ; more pointers to arguments here
                    dq  0                               ; terminate the list of pointers with 0
    envPtr:         dq  envp1
                    dq  0
    forkerror:      db  "fork error",10
    .len:           equ $-forkerror
    execveerror:    db  "execve error(not expected)",10
    .len:           equ $-execveerror
    wait4error:     db  "wait4 error",10
    .len:           equ $-wait4error

section .text

main:
    push    rbp
    mov     rbp,rsp

    ;TODO: put your code here...

    xor     rax,rax             ;return error code
    mov     rsp,rbp
    pop     rbp
    ret                         ;exit is handled by compiler
