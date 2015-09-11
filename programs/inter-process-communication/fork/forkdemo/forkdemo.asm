; Name:         forkdemo
; Build:        see makefile
; Run:          ./forkdemo
; Description:  An example of forking two childprocesses.
;               This program is a first attempt to fork two processes and display output to STDOUT in an
;               organized way. This will not work when using in terminals without escape keys to reposition
;               the cursor. If used in such terminals the output will be unpredictable. It's a nice demonstration
;               but better still to find another way to write to STDOUT.
;
;               The parent starts, forks two childprocesses and each of them will repeatedly shows 0 or 1 on screen.
;               Each process will do this with a different interval. The parent has to stop first domenstrating the
;               system call wait4 on all childprocesses. If all childs are terminated the parent terminbates the
;               entire program.
;
; How-to:       start the program with ./forkdemo in a terminal
;               

BITS 64

[list -]
        %include "unistd.inc"
        %include "time.inc"

        STRUC PROCESS_STRUC
          .address:     resq    1
          .PID:         resq    1
          .pidok:       resb    1
          .timer:       resq    1
          .iterations:  resq    1
        ENDSTRUC

        %macro PROCESS 5
          %define %1.address          %1+PROCESS_STRUC.address
          %define %1.PID              %1+PROCESS_STRUC.PID
          %define %1.pidok            %1+PROCESS_STRUC.pidok
          %define %1.timer            %1+PROCESS_STRUC.timer
          %define %1.iterations       %1+PROCESS_STRUC.iterations
          
          TIMESPEC timer%1,%4,%5
          
          %1: ISTRUC PROCESS_STRUC
            at    PROCESS_STRUC.address,    dq %2
            at    PROCESS_STRUC.PID,        dq 0
            at    PROCESS_STRUC.pidok,      db 0
            at    PROCESS_STRUC.timer,      dq timer%1
            at    PROCESS_STRUC.iterations, dq %3
          IEND 
        %endmacro
[list +]

section .bss

section .data

sParentWaiting: db 0x1B,"[H",0x1B,"[30C(waiting for childs to finish)",0x1B,"[H"
       .length: equ $-sParentWaiting

sAllChildsDone: db 0x1B,"[H",0x1B,"[30CAll childs are done, program terminated.",0x1B,"[H",0x1B,"[3B",0x1B,"[?25h"
       .length: equ $-sAllChildsDone

sParent: db 0x1B,"[HParent: [PID: "
   .pID: times 20 db 0                         ; space for decimal PID
         db "] "
.buffer: db "0"
         db 0,0,0                              ; extra bytes for "done" "d" goes in offset .buffer
         db 0x1B,"[H"
.length: equ $-sParent

sChild1: db 0x1B,"[H",0x1B,"[1BChild1: [PID: "
   .pID: times 20 db 0                         ; space for decimal PID
         db  "] "
.buffer: db  "0"
         db 0,0,0                              ; extra bytes for "done" "d" goes in offset .buffer
         db 0x1B,"[H"
.length: equ $-sChild1

sChild2: db 0x1B,"[H",0x1B,"[2BChild2: [PID: "
   .pID: times 20 db 0                         ; space for decimal PID
         db  "] "
.buffer: db  "0"
         db 0,0,0                              ; extra bytes for "done" "d" goes in offset .buffer
         db 0x1B,"[H"
.length: equ $-sChild2

; clear screen and hide cursor
sClearScreen: db 0x1B,"[H",0x1B,"[2J",0x1B,"[?25l"
     .length: equ $-sClearScreen

; this error should be more in detail
 sError: db "An error occured",10
.length: equ $-sError
 
; define process by name, pointer to routine, iterations, seconds, nanoseconds
PROCESS Parent,ParentProcess,15,1,0
PROCESS Child1,Child1Process,21,0,500000000
PROCESS Child2,Child2Process,15,2,0
  
section .text
        global _start
_start:
        mov     rsi, sClearScreen
        mov     rdx, sClearScreen.length
        call    Write
        mov     rax, SYS_fork
        syscall                                     ; invoke fork() get pid in rax
        push    rax
        cmp     rax, 0                              ; if pid < 0 then we have an error
        jl      .error
        jnz     .forkChild2                         ; run child1 routine
        jmp     QWORD[Child1.address]
.forkChild2:
        mov     rax, SYS_fork                       ; fork the second child
        syscall
        cmp     rax,0                               ; if pid < 0 then we have an error         
        jl      .error
        jnz     .runParent
        jmp     QWORD[Child2.address]
.runParent:
        jmp     QWORD[Parent.address]               ; run parent routine
.error:    
        mov     rsi, sError
        mov     rdx, sError.length
        call    Write
        jmp     Exit
    
; ParentProcess
; This is just example code, the same as for the other two childs.
; If you should change the name of this routine, then change it in the structure too!

ParentProcess:
        cmp     BYTE[Parent.pidok], 1               ; if this value is 1
        je      .start                              ; then the PID is already calculated
        mov     rax, SYS_getpid                     ; else get PID
        syscall
        mov     QWORD[Parent.PID], rax              ; store PID
        mov     rdi, sParent.pID                    ; buffer to store decimal PID
        call    ConvertToDecimal                    ; convert RAX to decimal
        mov     BYTE[Parent.pidok], 1               ; set flag
.start:    
        mov     rcx, QWORD[Parent.iterations]
.repeat:
        mov     rsi, sParent
        mov     rdx, sParent.length
        call    Write
        mov     rdi, QWORD[Parent.timer]
        call    Sleep
        xor     BYTE[sParent.buffer], 1
        loop    .repeat
        mov     DWORD[sParent.buffer],"done"
        mov     rsi, sParent
        mov     rdx, sParent.length
        call    Write       
        mov     rsi, sParentWaiting
        mov     rdx, sParentWaiting.length
        call    Write
        mov     rcx, 2
.waitForChilds:
        call    WaitForChild                        ; when one has finished wait for the next
        loop    .waitForChilds                       
        mov     rsi, sAllChildsDone                 ; until all childs are done
        mov     rdx, sAllChildsDone.length
        call    Write
        jmp     Exit

; Child1Process
; This is just example code, the same as for the other child and the parent process.
; If you should change the name of this routine, then change it in the structure too!

Child1Process:
        cmp     BYTE[Child1.pidok], 1               ; same as for parent
        je      .start
        mov     rax, SYS_getpid
        syscall
        mov     QWORD[Child1.PID], rax
        mov     rdi, sChild1.pID
        call    ConvertToDecimal
        mov     BYTE[Child1.pidok], 1
.start:    
        mov     rcx, QWORD[Child1.iterations]
.repeat:
        mov     rsi, sChild1
        mov     rdx, sChild1.length
        call    Write
        mov     rdi, QWORD[Child1.timer]
        call    Sleep
        xor     BYTE[sChild1.buffer], 1             ; toggle value in buffer
        loop    .repeat
        mov     DWORD[sChild1.buffer],"done"
        mov     rsi, sChild1
        mov     rdx, sChild1.length
        call    Write
        jmp     Exit


; Child2Process
; This is just example code, the same as for the other child and the parent process.
; If you should change the name of this routine, then change it in the structure too!

Child2Process:
        cmp     BYTE[Child2.pidok], 1               ; same as for parent
        je      .start
        mov     rax, SYS_getpid
        syscall
        mov     QWORD[Child2.PID], rax
        mov     rdi, sChild2.pID
        call    ConvertToDecimal
        mov     BYTE[Child2.pidok], 1
.start:    
        mov     rcx, QWORD[Child2.iterations]
.repeat:
        mov     rsi, sChild2
        mov     rdx, sChild2.length
        call    Write
        mov     rdi, QWORD[Child2.timer]
        call    Sleep
        xor     BYTE[sChild2.buffer], 1             ; toggle value
        loop    .repeat
        mov     DWORD[sChild2.buffer],"done"
        mov     rsi, sChild2
        mov     rdx, sChild2.length
        call    Write
        jmp     Exit    


; WaitForChild
; Wait for any child that is still running, if any.

WaitForChild:
        push    rax
        push    rcx
        push    rdx
        push    rsi
        push    rdi
        xor     rcx, rcx
        xor     rsi, rsi
        xor     rdi, rdi
        xor     rdx, rdx
        mov     rax, SYS_wait4                      ; wait for child to terminate
        syscall
        pop     rdi
        pop     rsi
        pop     rdx
        pop     rcx
        pop     rax
        ret

; Write
; Writes a string in RSI with length RDX to STDOUT.
; All registers are restored.

Write:
        push    rax
        push    rcx
        push    rdi
        mov     rdi, stdout
        mov     rax, SYS_write
        syscall
        pop     rdi
        pop     rcx
        pop     rax
        ret

; Sleep:
; RDI contains a pointer to the TIMESPEC structure. Here we don't use the *rem timespec
; structure to store the remaining time. (in RSI).
; All registers are restored.

Sleep:
        push    rax
        push    rcx
        push    rsi
        xor     rsi, rsi
        mov     rax, SYS_nanosleep
        syscall
        pop     rsi
        pop     rcx
        pop     rax
        ret

; ConvertToDecimal
; Converts a hexadecimal value in RAX and stores it in the buffer pointed by²² RDI.
; All registers return unchanged except RAX.

ConvertToDecimal:
        pushfq
        push    rdi
        push    rax
        push    rbx
        push    rdx
        add     rdi, 19                 ; point to end of buffer
        mov     rbx, 10                 ; base 10
        std
.repeat:    
        xor     rdx, rdx
        idiv    rbx                     ; RAX = quotient, RDX = remainder
        xchg    rax, rdx                ; change quotient and remainder
        or      al, 0x30                ; make ASCII
        stosb
        xchg    rax, rdx                ; restore quotient
        cmp     rax, 0                  ; calculations left?
        jne     .repeat
        pop     rdx
        pop     rbx
        pop     rax
        pop     rdi
        popfq
        ret

Exit:
    xor     rdi, rdi
    mov     rax, SYS_exit
    syscall
