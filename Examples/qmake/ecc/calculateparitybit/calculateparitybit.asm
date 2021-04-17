;name: calculateparitybit.asm
;
;description: calculate parity bit
;
;source: Hacker's Delight - 5.2 page 98

bits 64

%include "../calculateparitybit/calculateparitybit.inc"

global main

section .bss
;uninitialized read-write data 
    buffer: resb


section .data
;initialized read-write data

section .rodata
;read-only data

    message:    db  " has parity "
    .len:       equ $-message
    .odd:       db  "odd"
    .odd.len:   equ $-message.odd
    .even:      db  "even"
    .even.len:  equ $-message.even
    .end:       db  ".", 0x0A
    .end.len:   equ $-message.end

section .text

main:
    push    rbp
    mov     rbp,rsp

    mov     rax, 0xE  ;value we calculate parity of
    call    printBinary             ;print in binary on screen
    call    parity                  ;calculate parity bit (in RAX)
    push    rax                     ;save parity bit on stack
    mov     rsi, message            ;write first part of message
    mov     rdx, message.len
    call    print
    pop     rax                     ; parity bit from stack
    and     rax, rax                ;test if bit is zero or one
    jnz     oddparity               ;in case 1 then odd parity
    mov     rsi, message.even       ;print second part of message (parity even)
    mov     rdx, message.even.len
    jmp     write
oddparity:
    mov     rsi, message.odd        ;print second part of message (parity odd)
    mov     rdx, message.odd.len
write:
    call    print
    mov     rsi, message.end        ;print the trailing dot
    mov     rdx, message.end.len
    call    print

    xor     rax,rax             ;return error code
    mov     rsp,rbp
    pop     rbp
    ret                         ;exit is handled by compiler

parity:                             ;calculate parity bit 0 = even, 1 is odd
    mov     rcx, 32
repeat:
    mov     rbx, rax
    shr     rbx, cl
    xor     rax, rbx
    shr     rcx, 1
    cmp     rcx, 0
    jne     repeat
    and     rax, 1                  ;rightmost bit is parity bit
    ret

printBinary:
    push    rax
    mov     rcx, 64                 ;64 bits to display
    clc                             ;clear carry flag
.repeat:
    rcl     rax, 1                  ;start with leftmost bit
    adc     byte [buffer],0x30      ;make it ASCII
    push    rcx
    push    rax
    call    printBuffer
    pop     rax
    pop     rcx
    loop    .repeat
    pop     rax
    ret

printBuffer:
    mov     rsi, buffer
    mov     rdx, 1
print:
    syscall write, stdout
    and     byte [buffer],0         ;clear buffer
    ret
