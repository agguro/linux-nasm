; Name         pipe2.asm
;
; Build:       nasm -felf64 -o pipe2.o -l pipe2.lst pipe2.asm
;              ld -s -m elf_x86_64 pipe2.o -o pipe2
;
; Description: converted program pipe2.c
;
; Source       https://beej.us/guide/bgipc/html/multi/pipes.html
;
; Remark:      there is no error handling in this example

[list -]
     %include "unistd.inc"
[list +]

bits 64

section .bss
 
    p:
    .read:          resd   1            ; read end of the pipe
    .write:         resd   1            ; write end of the pipe
    buf:            resb   30
    
section .rodata

     msgWriting:    db  " CHILD: writing to the pipe",10
     .length:       equ $-msgWriting
     msgReading:    db  "PARENT: reading from the pipe",10
     .length:       equ $-msgReading
     tstwrite:      db  "test"
     .length:       equ $-tstwrite
     childExit:     db  " CHILD: exiting",10
     .length:       equ $-childExit
     parentRead:    db  "PARENT: read '"
     .length:       equ $-parentRead
     pipeerror:     db  "pipe call error",10
     .length:       equ $-pipeerror
     eol:           db  "'",10     
     
section .text

global _start    
_start:
    syscall     pipe,p
    and         rax,rax
    jns         fork
    syscall     write,stdout,pipeerror,pipeerror.length
    syscall     exit,0
fork:
    syscall     fork
    and         rax,rax
    jz          parent
    jns         child
    syscall     exit,0
child:    
    ; child process
    ; this is additional to let the parent wait a bit longer
    ; it isn't in the original source
    xor         cx,cx
    dec         cx
repeat:    
    loopnz      repeat
    syscall     write,stdout,msgWriting,msgWriting.length
    mov         edi,dword[p.write]
    syscall     write,rdi,tstwrite,tstwrite.length
    syscall     write,stdout,childExit,childExit.length
    syscall     exit,0
    ;parent process
parent:
    syscall     write,stdout,msgReading,msgReading.length
    mov         edi,dword[p.read]
    syscall     read,rdi,buf,tstwrite.length
    syscall     write,stdout,parentRead,parentRead.length
    syscall     write,stdout,buf,tstwrite.length
    syscall     write,stdout,eol,2
    syscall     wait4,0,0,0
    syscall     exit,0
