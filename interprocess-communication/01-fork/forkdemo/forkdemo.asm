; Name:         forkdemo.asm
;
; Build:        nasm "-felf64" exeapp4.asm -l exeapp4.lst -o exeapp4.o
;               ld -s -melf_x86_64 -o exeapp4 exeapp4.o
;
; Description:  
;               This is my first attempt to play around with the fork syscall.
;               When the program starts the parent process executes, create a child process which
;               in turn fork a second child process.  Each process either parent, child1 and child2 acts like
;               a binary counter each with their own time interval and number of iterations.  Each process has
;               its own process id (what else is new) a pidok flag which indicates that the pid is already
;               converted into decimal (speed it up) and an address in memory where the routine for each process
;               respectively starts.  All this together is put in a datastructure PROCESS_STRUC.
;               The aim is to demonstrate how a parent waits to exit until all childs have finished his (or hers) job.
;
; Remark:
; This example was made on Ubuntu 14.  The escape codes works in my terminal. If you should encounter a bad
; layout on screen, try changing the escape codes.

bits 64

[list -]
        %include "unistd.inc"
        %include "sys/time.inc"

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
.buffer: db "0"                                ; don't replace with db 0
         db 0,0,0                              ; extra bytes for "done" "d" goes in offset .buffer
         db 0x1B,"[H"
.length: equ $-sParent

sChild1: db 0x1B,"[H",0x1B,"[1BChild1: [PID: "
   .pID: times 20 db 0                         ; space for decimal PID
         db  "] "
.buffer: db  "0"                               ; don't replace with db 0
         db 0,0,0                              ; extra bytes for "done" "d" goes in offset .buffer
         db 0x1B,"[H"
.length: equ $-sChild1

sChild2: db 0x1B,"[H",0x1B,"[2BChild2: [PID: "
   .pID: times 20 db 0                         ; space for decimal PID
         db  "] "
.buffer: db  "0"                               ; don't replace with db 0
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
; don't mess with next declarations, unless the iterations, seconds and nanoseconds

PROCESS Parent,ParentProcess,15,1,0
PROCESS Child1,Child1Process,21,0,500000000
PROCESS Child2,Child2Process,15,2,0
  
section .text
        global _start
_start:
        mov     rsi, sClearScreen
        mov     rdx, sClearScreen.length
        call    Write
        syscall fork                                ; fork first child
        push    rax
        cmp     rax, 0                              ; if pid < 0 then we have an error
        jl      .error
        jnz     .forkChild2                         ; run child1 routine
        jmp     qword[Child1.address]
.forkChild2:
        syscall fork                                ; fork the second child
        cmp     rax,0                               ; if pid < 0 then we have an error         
        jl      .error
        jnz     .runParent
        jmp     qword[Child2.address]
.runParent:
        jmp     qword[Parent.address]               ; run parent routine
.error:    
        mov     rsi, sError
        mov     rdx, sError.length
        call    Write
        jmp     Exit
    
; ParentProcess
; This is just example code, the same as for the other two childs.
; If you should change the name of this routine, then change it in the structure too!

ParentProcess:
        cmp     byte[Parent.pidok], 1               ; if this value is 1
        je      .start                              ; then the PID is already calculated
        syscall getpid
        mov     qword[Parent.PID], rax              ; store PID
        mov     rdi, sParent.pID                    ; buffer to store decimal PID
        call    ConvertToDecimal                    ; convert RAX to decimal
        mov     byte[Parent.pidok], 1               ; set flag
.start:    
        mov     rcx, qword[Parent.iterations]
.repeat:
        mov     rsi, sParent
        mov     rdx, sParent.length
        call    Write
        mov     rdi, qword[Parent.timer]
        call    Sleep                               ; sleep 
        xor     byte[sParent.buffer], 1
        loop    .repeat
        mov     dword[sParent.buffer],"done"
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
        cmp     byte[Child1.pidok], 1               ; same as for parent
        je      .start
        syscall getpid
        mov     qword[Child1.PID], rax
        mov     rdi, sChild1.pID
        call    ConvertToDecimal
        mov     byte[Child1.pidok], 1
.start:    
        mov     rcx, qword[Child1.iterations]
.repeat:
        mov     rsi, sChild1
        mov     rdx, sChild1.length
        call    Write
        mov     rdi, qword[Child1.timer]
        call    Sleep
        xor     byte[sChild1.buffer], 1             ; toggle value in buffer
        loop    .repeat
        mov     dword[sChild1.buffer],"done"
        mov     rsi, sChild1
        mov     rdx, sChild1.length
        call    Write
        jmp     Exit


; Child2Process
; This is just example code, the same as for the other child and the parent process.
; If you should change the name of this routine, then change it in the structure too!

Child2Process:
        cmp     byte[Child2.pidok], 1               ; same as for parent
        je      .start
        syscall getpid
        mov     qword[Child2.PID], rax
        mov     rdi, sChild2.pID
        call    ConvertToDecimal
        mov     byte[Child2.pidok], 1
.start:    
        mov     rcx, qword[Child2.iterations]
.repeat:
        mov     rsi, sChild2
        mov     rdx, sChild2.length
        call    Write
        mov     rdi, qword[Child2.timer]
        call    Sleep
        xor     byte[sChild2.buffer], 1             ; toggle value
        loop    .repeat
        mov     dword[sChild2.buffer],"done"
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
        syscall wait4                      ; wait for child to terminate
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
        syscall write, stdout
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
        syscall nanosleep
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
        syscall exit, 0
