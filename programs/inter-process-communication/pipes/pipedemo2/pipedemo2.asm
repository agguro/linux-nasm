; Name:         pipedemo2.asm
; Build:        see makefile
; Run:          ./pipedemo2
; Description:  Same program as pipedemo1, but this time with Fork.
;               The child writes the messages to the pipe. The parent will read the messages
;               from the read-end of the pipe and displays them.

BITS 64

[list -]
    %include "unistd.inc"
[list +]

section .bss
     
     p:
     .0:         resd    1                               ; STDIN
     .1:         resd    1                               ; STDOUT
     inbuf:      resb    childmsg.length*3
        
section .data
        
     childmsg:   db      "hello #1",0x0A
     .length:    equ     $-childmsg
     parentmsg:  db      "Parent received: ",0x0A
     .length:    equ     $-parentmsg
     pipeerror:  db      "pipe call error"
     .length:    equ     $-pipeerror
     forkerror:  db      "fork error"
     .length:    equ     $-forkerror
        
section .text
      global _start
        
_start:

      ; open pipê
      syscall  pipe, p
      jns       fork
      syscall   write, stdout, pipeerror, pipeerror.length
      jmp       exit
      
fork:
      ; fork the process
      syscall   fork
      and       rax, rax
      jz        parent
      jnz       child
      syscall   write, stdout, forkerror, forkerror.length
      jmp       exit
      
; write down pipe
child:
      ; close the read end of the pipe
      syscall   close, rdi
      
      mov       edi, DWORD[p.1]
      ; we will write the same text 3 times, modifying the # each time
      ; so we will write hello #1,0x0A,hello #2,0x0A,hello #3,0x0A to the write-end of the pipe.
      syscall   write, rdi, childmsg, childmsg.length
      inc       BYTE[childmsg+childmsg.length-2]
      syscall   write
      inc       BYTE[childmsg+childmsg.length-2]
      syscall   write
      jmp       exit
      
; parent reads pipe
parent:            
      ; close the write end of the pipe
      mov       edi, DWORD[p.1]
      syscall   close, rdi   
@1:      
      ; read pipe into buffer
      mov       edi, DWORD[p.0]
      syscall   read, rdi, inbuf, childmsg.length*3
      ; write 'parent' message to STDOUT
      syscall   write, stdout, parentmsg, parentmsg.length
      ; write buffer to STDOUT
      syscall   write, stdout, inbuf, childmsg.length*3
      ; wait for the child
      syscall   wait4, 0, 0, 0, 0
      ; and exit      
exit:      
      syscall   exit, 0
      