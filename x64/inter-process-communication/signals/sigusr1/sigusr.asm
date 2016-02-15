; sigusr.asm
;
; Source : Beejs guide to IPC - http://beej.us/guide/bgipc/output/html/multipage/signals.html#catchsig
;
; August 28, 2014 : assembler 64 bit version
;
; Description:
; A demonstration on signals based on an example from Beej's Guide to IPC.
;
; Disclaimer:
; GNU GENERAL PUBLIC LICENSE 3
;
; HOW TO: start this program in a terminal
;         open a second terminal, be sure not to cover the first one
;         type: kill -STOP pidnumber
;         type: kill -CONT pidnumber
;         type  kill -USR1 pidnumber
;
; The sigaction structure in assembly language is quit different from the C language.  I spend an hour
; or more to figure it out.  Monitoring the original example with trace reveiled this.
;
; Also the syscall to RT_SIGACTION needs an additional parameter in R10, NSIG_WORDS which is 8.  Still dunno why,
; but the example works.  A good exercise is comparing the C source with the assembly program.
;
; TO-DO: rewrite integer conversion for smaller numbers
;        rewrite integer store routine for smaller numbers
;        keep track of time the child is running and display it when killed by USR1

BITS 64
ALIGN 16

[list -]
    %include "unistd.inc"
    %include "time.inc"
    %include "signals.inc"
[list +]

%define SECONDS         1
%define NANOSECONDS     0

section .bss
  
section .data
    
    SIGACTION   sigaction
    TIMESPEC    timer
    
    got_usr1:           db      0
    
    ; the messages
    msgPID:             db      "PID "
    
    .pid:               times   21 db 0
    .length:            dq      0
    
    msgWorkingHard      db      ": Working hard...", 10
    .length:            equ     $-msgWorkingHard
    
    msgDone:            db      "Done by SIGUSR1!", 10
    .length:            equ     $-msgDone
    
    ; error message
    msgSignalError:     db      "sigaction error, terminating program.", 10
    .length:            equ     $-msgSignalError

section .txt
global  _start
_start:

    ; get the programs PID
    syscall     getpid
    ; convert to decimal and ...
    call        Hex2Dec
    mov         rdi, msgPID.pid
    ; ... store the pid in the message
    call        StoreDecimal
    mov         r8, rdx                                   ; length pid in r8
    add         r8, 4                                     ; message length "PID "
    mov         QWORD[msgPID.length], r8                  ; save length
    
    ; initialize SIGUSR1 handler
    mov         rax, procSigUSR1                          ; set handler to pointer to procSigInt
    mov         QWORD[sigaction.sa_handler], rax          ; in sigaction structure        
    mov         eax, SA_RESTART | SA_RESTORER             ; sa_flags
    mov         DWORD[sigaction.sa_flags], eax
    mov         rax, procSigRestorer
    mov         QWORD[sigaction.sa_restorer], rax
    
    ; initialize the signal handler for SIGUSR1
    mov         r10, NSIG_WORDS                           ; NSIG_WORDS
    syscall     rt_sigaction, SIGUSR1, sigaction, 0
    
    ; if rax < 0 , we got an error, rax should be zero
    and         rax, rax
    js          Error

    ; repeat displaying the message "PID xxxxx: Working hard..."
.repeat:
    syscall     write, stdout, msgPID, QWORD[msgPID.length]
    syscall     write, stdout, msgWorkingHard, msgWorkingHard.length
    
    ; here is the hard work
    call        Sleep
    ; if got_usr1 = 0 then we repeat the cycle
    mov         al, BYTE[got_usr1]
    and         al, al
    jz          .repeat
    
    ; interrupt has been caught, got_usr1 is not zero so exit with a last message
    ; "Done in by SIGUSR1!"
    syscall     write, stdout, msgDone, msgDone.length
    
    ; and exit the program
    jmp         Exit
    
    ; in case we have an error
Error:
    syscall     write, stdout, msgSignalError, msgSignalError.length

    ; exit the program
Exit:
    syscall     exit, 0
    
; The SIGUSR1 handler
procSigUSR1:
    pop         r8                                      ; interrupt break address from stack, just in case
    mov         BYTE[got_usr1], 1                       ; just put 1 in got_usr1
    push        r8                                      ; interrupt break address back on stack
    ret                                                 ; we can also jump to another location in the main program,
                                                        ; we just have to restore the stack.                                            
; return from signal handler and cleanup stack frame                                                        
procSigRestorer:                                        
    syscall     rt_sigreturn
    
; Pause program execution for 1 second
Sleep:
    mov QWORD [timer.tv_sec], SECONDS
    mov QWORD [timer.tv_nsec], NANOSECONDS
    ;mov     rdi, QWORD timer
    ;xor     rsi, rsi
    ;mov     rax, SYS_NANOSLEEP
    syscall     nanosleep, QWORD timer, 0
    ret

; convert hexadecimal in RAX to decimal in r10:r9:r8
; this routine is a bit overkill for small values, but I didn't want to re-invent the wheel.
Hex2Dec:
    ; r10:r9:r8 = decimal(rax)
    xor         r10, r10                ; R10:R9:R8 will hold the decimal value of RAX
    xor         r9, r9                  
    xor         r8, r8
    mov         rbx, 10                 ; base 10 for decimal
    clc
.repeat:        
    xor         rdx, rdx                ; clear remainder register
    idiv        rbx
    or          dl, "0"
    mov         rcx, 8
.shift:        
    rcr         dl, 1                   ; rotate ASCII decimal in R10:R9:R8
    rcr         r10, 1
    rcr         r9, 1
    rcr         r8, 1
    dec         rcx
    and         rcx, rcx
    jnz         .shift
    and         rax, rax                ; if quotient is zero, nothing to be done anymore
    jnz         .repeat                 ; if not repeat procedure
    ret

; store decimal in R10:R9:R8 in buffer pointed by RDI and return pointer to first byte
; after the buffer in RDI and length of decimal in RDX.
StoreDecimal:
    ; RDI = pointer to buffer
    ; R10:R9:R8 = decimal value in ASCII
    ; return:
    ; RDX = length of decimal number
    ; RDI = offset to byte right after the stored integer
    
    clc
    xor         rdx, rdx
.repeat:
    inc         rdx
    mov         rcx, 8
.shift:        
    rcl         r8, 1
    rcl         r9, 1
    rcl         r10, 1
    rcl         rax, 1
    dec         rcx
    and         rcx, rcx
    jnz         .shift
    and         al, al
    jz          .done
    stosb
    jmp         .repeat
.done:
    dec         rdx                     ; adjust length
    ret    