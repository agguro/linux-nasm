; Name          : pipedemo3.asm
;
; Build         : nasm -felf64 pipedemo3.asm -l pipedemo3.lst -o pipedemo3.o
;                 ld -s -melf_x86_64 -o pipedemo3 pipedemo3.o
;
; Description   : In this example a parent process write into the pipe.  The child process then
;                 displays the message, processed on screen from the pipe by CHARSTOREAD characters
;                 at the time.  The message will be chopped and displayed.
;
; Source        : This was an C example I found on the internet, don't know where
;                 The original source displays also the number of chars read by the child
;                 process at the time.  This is removed here.

bits 64

[list -]
        %include "unistd.inc"
        %define CHARSTOREAD  40
[list +]

section .bss
        
        p:
        .read:          resd    1                               ; read-end
        .write:         resd    1                               ; write-end
        buffer:         resb    20

section .data

        message:        db      "One of the fundamental features that makes Linux and other Unices useful is the 'pipe'."
                        db      "Pipes allow separate processes to communicate without having been designed explicitly "
                        db      "to work together. This allows tools quite narrow in their function to be combined in complex ways."                        
        .length:        equ     $-message
        
        eol:            db      10
        
        pipeerror:      db      "pipe error"
        .length:        equ     $-pipeerror
        forkerror:      db      "fork error"
        .length:        equ     $-forkerror
        childfailed:    db      "Child failed",10
        .length:        equ     $-childfailed
        childsucces:    db      "Child finished",10, 10
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
      mov       edi, dword[p.write]
      syscall   close, rdi
      ; now read the messages from the pipe

readBytes:
      mov       edi, dword[p.read]
      syscall   read, rdi, buffer, CHARSTOREAD
      mov       r8, rax                         ; nchars read
      cmp       rax, 0                          ; have we read any bytes?
      je        .closePipe                      ; if all bytes read, then close pipe and exit
      
      ; write the message, store rax in r8
      ; print the buffer contents
      syscall   write, stdout, buffer, r8
      ; write an end of line
      syscall   write, stdout, eol, 1
      ; sync STDOUT 
      syscall   fsync, stdout           
      jmp       readBytes
      ; close the pipe
.closePipe:
      mov       edi, dword[p.read]
      syscall   close, rdi
      ; and exit
      jmp       exit
;------------------------------------------------------
; parent process
;------------------------------------------------------
parent:
      ; close the read end of the pipe
      mov       edi, dword[p.read]
      syscall   close, rdi
      ; write the message to the pipe full length
      mov       edi, dword[p.write]
      syscall   write, rdi, message, message.length
      ; close the pipe
      mov       edi, dword[p.write]
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
