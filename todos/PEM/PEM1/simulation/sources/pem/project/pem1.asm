; Name: pem1.asm
; Build: see makefile or
; Description:  PEM1 microprocessor simulation

%include "pem1.inc"

BITS 64

section .bss
    
section .data

    message1 STRING {"sleeping for 5 seconds...", 10}
    message2 STRING {"back up and running.", 10}
    message3 STRING {"0",10}
    TIMESPEC timer

section .text
    global _start
_start:
    
    mov QWORD[timer.tv_sec], SECONDS
    mov QWORD[timer.tv_nsec], NANOSECONDS
    mov     rcx, 10                             ; loop 10 times
.repeat:    
    push    rcx
    or      BYTE[message3], "1"
    syscall.write message3
    syscall.nanosleep timer, 0
    and     BYTE[message3], "0"
    syscall.write message3
    syscall.nanosleep timer, 0
    pop     rcx
    loop    .repeat
    
    
    ; syscall.write message2
    syscall.exit ENOERR