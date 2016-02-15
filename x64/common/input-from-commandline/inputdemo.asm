; Name:         inputdemo
; Build:        see makefile
; Run:          ./inputdemo
; Description:  The program asks for your name and writes it to STDOUT.
; Remark:       Thanks to GunnerInc (DreamInCode) for the routine to clear the buffer.

BITS 64

[list -]
      %include "unistd.inc"
[list +]

%define     BUFFERLENGTH    15  ; number of bytes to read into the buffer

section .bss

buffer:
        .start:   resb    BUFFERLENGTH
        .dummy:   resb    1           ; help buffer to clear STDIN on buffer overflow
        .length   equ     $-buffer.start
      
section .data

question:
        .start:   db      "What's your name? [only first 15 will be replied] "
        .length   equ     $-question.start
answer:
        .start:   db      "Hello "
        .length   equ     $-answer.start
      
section .text
        global _start
_start:
        ; print the QUESTION
        mov     rsi, question                       ; start of message
        mov     rdx, question.length                ; the length of the message to display
        call    Write
        ; read the answer
        mov     rsi, buffer                         ; offset of the buffer to store input
        mov     rdx, buffer.length                  ; the length of the buffer 
        mov     rdi, STDIN
        mov     rax, SYS_READ
        syscall
        push    rax                                 ; save bytes read
        ; check if more characters are given than the length of the buffer
        cmp     rax, buffer.length                  ; are there more characters than allowed?
        jl      WriteAnswer                         ; no, so write buffercontent to STDOUT
        cmp     byte[rsi+rdx-1],10                  ; last character is EOL?
        je      WriteAnswer                         ; yes, also write the buffercontent to STDOUT
        mov     byte[rsi+rdx-1],13                  ; no, put carriage-return in place
clearSTDIN:                                         ; Check for extra characters in the buffer
        push    STDIN                               ; prepare to read from STDIN the remaining input
        pop     rdi
        mov     rsi, buffer.dummy                   ; using this small dummy buffer
        xor     rdx, rdx                            ; length of the dummy buffer
        inc     rdx                                 ; equals 1 byte
        mov     rax, SYS_READ
        syscall                                     ; read next byte from buffer
        cmp     byte[rsi], 10                       ; is it EOL?
        jne     clearSTDIN                          ; no continue with the next
        ; at this point we've read all the remaining bytes
WriteAnswer:   
        mov     rsi, answer                         ; start of message
        mov     rdx, answer.length                  ; the length of the message to display
        call    Write
        mov     rsi, buffer
        mov     rdx, buffer.length
        call    Write
        xor     rdi, rdi
        mov     rax, SYS_EXIT
        syscall
Write:
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
        ret