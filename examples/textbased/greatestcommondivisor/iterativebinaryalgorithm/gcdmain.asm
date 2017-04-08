; Name: gcdmain.asm
; Date: Fri Apr  7 07:26:26 CEST 2017
; Description: demo program for binary gcd algorithm
;
; Build:
;   nasm -felf64 gcdmain.asm
;   nasm -felf64 gcd.asm
;   nasm -felf64 hextodec.asm
;   ld -o gcd gcdmain.o gcd.o hextodec.o
 
%include "unistd.inc"

extern GreatestCommonDivisor
extern Swap
extern SimplifyFraction
extern sHexToDecAscii
extern uHexToDecAscii
extern AbsoluteValue

extern DecimalToString

bits 64

section .bss
    buffer:     resb    20

section .data
    numbers:    dq  57,95,800,75,751,0,0,478,0,0
    .len:       equ $-numbers
    ;output
    output:
    .part1:     db  "gcd("
    .part1.len: equ $-output.part1
    .part2:     db  ","
    .part2.len: equ $-output.part2
    .part3:     db  ") = "
    .part3.len: equ $-output.part3
    .part4:     db  10                  ;end of line
    .part4.len: equ $-output.part4
    
section .text

global  _start:

_start:
    ;initialize counter
    mov     rcx,numbers.len
    shr     rcx,3                       ;number of pairs
    mov     rbx,0                       ;n=0
.process:
    push    rcx                         ;rcx is modified by syscalls
    ;write part1 of output
    syscall write,stdout,output.part1,output.part1.len
    ;convert number and write to stdout
    mov     rdi,[numbers+rbx*8]           ;rdi=numbers[n]
    mov     rsi,buffer
    call    sHexToDecAscii
    syscall write,stdout,rax,rdx
    ;write part2 of output
    syscall write,stdout,output.part2,output.part2.len
    ;convert next number and write to stdout
    mov     rdi,[numbers+rbx*8+8]         ;rdi=numbers[n+1]
    mov     rsi,buffer
    call    sHexToDecAscii
    syscall write,stdout,rax,rdx
    ;write part3 of output
    syscall write,stdout,output.part3,output.part3.len
    ;get numbers again and calculate gcd

    mov     rdi,[numbers+rbx*8]             ;rdi=numbers[n]
    mov     rsi,[numbers+rbx*8+8]         ;rsi=numbers[n+1]
    call    GreatestCommonDivisor
    ;convert result to human readable number
    mov     rdi,rax
    mov     rsi,buffer
    call    sHexToDecAscii
    ;write result to stdout
    syscall write,stdout,rax,rdx
    ;write last part of output to stdout
    syscall write,stdout,output.part4,output.part4.len
    pop     rcx
    inc     rbx                         ;process next two numbers
    inc     rbx
    cmp     rbx,rcx
    jne     .process
    syscall exit,0
