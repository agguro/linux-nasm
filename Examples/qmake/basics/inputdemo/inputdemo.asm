;name: inputdemo.asm
;
;description: The program asks for some input and writes it to stdout.
;
;Thanks to GunnerInc (DreamInCode) for the routine to clear the buffer.

bits 64

    %include "../../../qmake/basics/inputdemo/inputdemo.inc"

global main

section .bss
;uninitialized read-write data 
buffer:
    .start: resb    BUFFERLENGTH
    .dummy: resb    1		    ; help buffer to clear STDIN on buffer overflow
    .length equ     $-buffer.start

section .data
;initialized read-write data

section .rodata
;read-only data
question:
    .start:   db      "Enter some text, only first 15 characters will be replied: "
    .length   equ     $-question.start

section .text

main:
    push    rbp
    mov     rbp,rsp

    ;print the QUESTION
    syscall write,stdout,question,question.length
    ;read the answer
    syscall read,stdin,buffer,buffer.length
    push    rax                                 ;save bytes read
    ;check if more characters are given than the length of the buffer
    cmp     rax,buffer.length                   ;are there more characters than allowed?
    jl      WriteAnswer                         ;no, so write buffercontent to STDOUT
    cmp     byte[rsi+rdx-1],10                  ;last character is EOL?
    je      WriteAnswer                         ;yes, also write the buffercontent to STDOUT
    mov     byte[rsi+rdx-1],13                  ;no, put carriage-return in place
clearSTDIN:                                     ;Check for extra characters in the buffer
    syscall read,stdin,buffer.dummy,1           ;read next byte from buffer
    cmp     byte[rsi],10                        ;is it EOL?
    jne     clearSTDIN                          ;no continue with the next
    ;at this point we've read all the remaining bytes
WriteAnswer:
    syscall write,stdout,buffer,buffer.length

    xor     rax,rax             ;return error code
    mov     rsp,rbp
    pop     rbp
    ret                         ;exit is handled by compiler
