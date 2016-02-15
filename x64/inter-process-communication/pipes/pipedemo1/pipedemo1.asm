; Name:         pipedemo1.asm
; Build:        see makefile
; Run:          ./pipedemo1
 
BITS 64
 
[list -]
     %include "unistd.inc"
[list +]

%define MSGSIZE  8

section .bss
 
     p:
     .0:             resd    1                         ; new STDIN
     .1:             resd    1                         ; new STDOUT
     inbuf:          resb    MSGSIZE
 
section .data

     msg1:           db      "hello #1"
     msg2:           db      "hello #2"
     msg3:           db      "hello #3"
     EOL:            db      10
     pipeerror:      db      "pipe call error"
     .length:        equ     $-pipeerror
 
section .text
     global _start

_start:
     syscall   pipe, p
     and       rax, rax
     jns       startpipe               ; if RAX < 0 then error
     syscall   write, stdout, pipeerror, pipeerror.length
     jmp       exit
      
startpipe:      
     ; write msg1 to the pipe
     mov       edi, DWORD[p.1]
     syscall   write, rdi, msg1, MSGSIZE
     ; write msg2 to the pipe
     mov       edi, DWORD[p.1]
     syscall   write, rdi, msg2, MSGSIZE
     ; write msg3 to the pipe
     mov       edi, DWORD[p.1]
     syscall   write, rdi, msg3, MSGSIZE
     xor       r8, r8                  ; init loopcounter
@1:      
     ; read MSGSIZE bytes from the pipe into the buffer
     mov       edi, DWORD[p.0]
     syscall   read, rdi, inbuf, MSGSIZE
     syscall   write, stdout, inbuf, MSGSIZE
     syscall   write, stdout, EOL, 1
     inc       r8
     cmp       r8, 3
     jl        @1                      ; repeat 2 more times
exit:      
     syscall   exit, 0