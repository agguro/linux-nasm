;name        : sigint.asm
;
;build       : nasm "-felf64" sigint.asm -l sigint.lst -o sigint.o
;              ld -s -melf_x86_64 -o sigint sigint.o 
;
;description : A demonstration on signals based on an example from Beej's Guide to IPC.
;
;how to      : start this program in a terminal.
;              type some text and press ctrl-c to interrupt the input then continue input and press enter.
;
; Source     : Beejs guide to IPC - http://beej.us/guide/bgipc/output/html/multipage/signals.html#catchsig
;
; The sigaction structure in assembly language is quit different from the C language.  I spend an hour
; or more to figure it out.  Monitoring the original example with strace reveiled this.
; Also the syscall to RT_SIGACTION needs an additional parameter in r10, NSIG_WORDS which is 8.

bits 64
align 16

[list -]
    %include "unistd.inc"
    %include "signals.inc"
[list +]

section .bss
  
    buffer:     resb    200
    .length:    equ     $-buffer    
    dummy:      resb    1

section .rodata

    ; the messages
    msgSIGINT:          db      10, "Ahhh! SIGINT!", 10
    .length:            equ     $-msgSIGINT
    msgInput:           db      "Enter a string:", 10
    .length:            equ     $-msgInput
    msgAnswer:          db      "You entered: "
    .length:            equ     $-msgAnswer
    msgInterrupted:     db      "Interrupted system call", 10
    .length:            equ     $-msgInterrupted
    ; error message
    msgSignalError:     db      "sigaction error, terminating program.", 10
    .length:            equ     $-msgSignalError

section .data
    
    SIGACTION   sigaction
    
section .text

global  _start
_start:

    ; sa.sa_handler = sigint_handler;
    mov     rax, procSigInt                           ; set handler to pointer to procSigInt
    mov     qword [sigaction.sa_handler], rax          ; in sigaction structure
    
    ; sa.sa_flags = SA_RESTART;
    ; sa.sa_flags = 0 gives a segmentation fault
    
    ; here a zero for sa.flags lead us to a segmentation fault, I still need to figure it out to intercept
    ; the error.
    mov     eax, SA_RESTART | SA_RESTORER             ; sa_flags
    mov     dword [sigaction.sa_flags], eax
    mov     rax, procSigRestorer
    mov     qword [sigaction.sa_restorer], rax
   
    ; sigemptyset(&sa.sa_mask);
    ; not really needed since sa.sa_mask is filled with zero bytes
    
    ;if (sigaction(SIGINT, &sa, NULL) == -1) {
    ;    perror("sigaction");
    ;    exit(1);
    ;}
    mov     r10, NSIG_WORDS                           ; NSIG_WORDS
    syscall rt_sigaction, SIGINT, sigaction, 0
    and     rax, rax
    js      Error
    
    ; printf("Enter a string:\n");
    syscall     write, stdout, msgInput, msgInput.length
    syscall     read, stdin, buffer, buffer.length    
    ; parse status code
    ; keep first three characters and flush rest of characters in buffer
    cmp     rax, buffer.length
    jl      .less
    cmp     byte  [buffer+buffer.length-1], 10
    je      .equal
.flush:                                                 ; to many characters entered, we need to flush
    syscall read, stdin, dummy, 1
    cmp     byte  [rsi], 10
    jne     .flush
.equal:
    mov     rax, buffer.length
.less:   
    mov     byte  [buffer+rax-1], 10
    syscall write, stdout, msgAnswer, msgAnswer.length
    
    mov     byte  [dummy], 0
    mov     rsi, buffer
.repeat:    
    lodsb
    and     al, al
    jz      Exit
    dec     rsi
    syscall write, stdout, rsi, 1
    inc     rsi
    jmp     .repeat
Interrupted:
    syscall write, stdout, msgInterrupted, msgInterrupted.length
Error:
    syscall write, stdout, msgSignalError, msgSignalError.length
Exit:
    syscall exit, 0
    
; The SIGINT handler
procSigInt:
    ; write(0, "Ahhh! SIGINT!\n", 14);
    pop     r8                                      ; interrupt break address from stack, just in case
    syscall write, stdout, msgSIGINT, msgSIGINT.length
    push    r8                                      ; interrupt break address back on stack
    ret
procSigRestorer:
    syscall rt_sigreturn
