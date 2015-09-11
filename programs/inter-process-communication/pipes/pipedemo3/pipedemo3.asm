; Name:         pipedemo3.asm
; Build:        see makefile
; Run:          ./pipedemo3

BITS 64

[list -]
        %include "unistd.inc"
        %define CHARSTOREAD  8                         ; don't make this bigger than 9
[list +]

section .bss
        
        p:
        .0:             resd    1                               ; STDIN
        .1:             resd    1                               ; STDOUT
        buffer:         resb    20

section .data

        message:        db      "One of the fundamental features that makes Linux and other Unices useful is the 'pipe'."
                        db      "Pipes allow separate processes to communicate without having been designed explicitly "
                        db      "to work together. This allows tools quite narrow in their function to be combined in complex ways."
        .length:        equ     $-message
        out1:
        .nchars:        db      "  chars | "
        .length:        equ     $-out1
        out2:           db      " | received by child",10
        .length:        equ     $-out2

        pipeerror:      db      "pipe error"
        .length:        equ     $-pipeerror
        forkerror:      db      "fork error"
        .length:        equ     $-forkerror
        childfailed:    db      "Child failed",10
        .length:        equ     $-childfailed
        childsucces:    db      "Child finished",10
        .length:        equ     $-childsucces

section .text
     global _start
     
_start:

      syscall   pipe, p
      js        error.pipe
      ; fork the process
      syscall   fork
      cmp       rax, 0
      je        parent
      jl        error.fork
;------------------------------------------------------
; child process
;------------------------------------------------------
child:

      xor       rdi, rdi
      ; close the write end of the pipe
      mov       edi, DWORD[p.1]
      syscall   close, rdi
      ; now read the messages from the pipe

readBytes:

      mov       edi, DWORD[p.0]
      syscall   read, rdi, buffer, CHARSTOREAD
      mov       r8, rax                         ; nchars read
      cmp       rax, 0                          ; have we read any bytes?
      je        .closePipe                      ; if all bytes read, then close pipe and exit
      ; convert AL to ASCII
      add       al, 0x30
      mov       BYTE[out1.nchars], al
      ; now write the message, store rax in r8
      ; first print the first part
      syscall   write, stdout, out1, out1.length
      ; then print the buffer contents
      syscall   write, stdout, buffer, r8
      ; write the last part of the message
      syscall   write, stdout, out2, out2.length
      ; sync STDOUT 
      syscall   fsync, stdout           
      jmp       readBytes
      ; close the pipe
.closePipe:
      mov       edi, DWORD[p.0]
      syscall   close, rdi
      ; and exit
      jmp       exit
;------------------------------------------------------
; parent process
;------------------------------------------------------
parent:
      ; close the read end of the pipe
      mov       edi, DWORD[p.0]
      syscall   close, rdi
      ; write the message to the pipe
      mov       edi, DWORD[p.1]
      syscall   write, rdi, message, message.length
      ; close the pipe
      mov       edi, DWORD[p.1]
      syscall   close, rdi
      ; wait for the child
      syscall   wait4, 0, 0, 0, 0
      and       rax, rax
      jz        error.childFailed
      
      ; following message can be on screen before the child's output has finished
      syscall   write, stdout, childsucces, childsucces.length
      jmp       exit
error:
.pipe:
      mov       rsi, pipeerror
      mov       rdx, pipeerror.length
      jmp       error.write

.fork:
      mov       rsi, forkerror
      mov       rdx, forkerror.length
      jmp       error.write
.childFailed:
      mov       rsi, childfailed
      mov       rdx, childfailed.length
.write:
      syscall   write, stderr
exit:
      syscall   exit, 0
