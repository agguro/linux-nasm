; Name          : pipedemo5.asm
;
; Build         : nasm -felf64 pipedemo5.asm -l pipedemo5.lst -o pipedemo5.o
;                 ld -s -melf_x86_64 -o pipedemo5 pipedemo5.o
;
; Description   : A demonstration on pipes and fork based on an example from Beej's Guide to IPC
;                 This is the same example as pipedemo4.asm but with that difference that the
;                 programs forks, the child process writes into the pipe and the parent process reads
;                 from the pipe.
;
; Source        : Beejs guide to IPC - http://beej.us/guide/bgipc/output/html/multipage/pipes.html
;
;
; August 24, 2014 : assembler 64 bits version
 
bits 64
 
[list -]
    %include "unistd.inc"
[list +]

    %define         DATA    "this is the test sentence"
        
section .bss
    ; pdfs
    pdfs:
    .read:          resd    1
    .write:         resd    1
 
section .data

    data:           db      DATA
    .length:        equ     $-data
  
    Child:
    .msg1:          db      " CHILD: writing to the pipe", 10
    .msg1.length:   equ     $-Child.msg1
    .msg2:          db      " CHILD: exiting", 10
    .msg2.length:   equ     $-Child.msg2
    
    Parent:
    .msg1:          db      "PARENT: reading from pipe", 10
    .msg1.length:   equ     $-Parent.msg1
    .msg2:          db      "PARENT: read ", 0x22
    .buffer:        times   data.length db 0
                    db      0x22, 10
    .msg2.length:   equ     $-Parent.msg2                    
    
    pipeerror:      db      "Pipe error"
    .length:        equ     $-pipeerror
    
    forkerror:      db      "Fork error"
    .length:        equ     $-forkerror
    
section .text
    global _start

_start:
    
    ; create pipe, pdfs is an array to the READ and WRITE ends of the pipe
    syscall     pipe, pdfs
    and         rax, rax
    js          Error.Pipe
    ; fork the process
    syscall     fork
    and         rax, rax
    js          Error.Fork
    jnz         ParentProcess
    ; write message msg1
    syscall     write, stdout, Child.msg1, Child.msg1.length
    ; write to the pipe
    mov         edi, dword[pdfs.write]
    syscall     write, rdi, data, data.length
    ; write message msg2
    syscall     write, stdout, Child.msg2, Child.msg2.length
    jmp         Exit
    
ParentProcess:    
    ; write output with buffer to STDOUT
    syscall     write, stdout, Parent.msg1, Parent.msg1.length
    ; read from pipe
    mov         edi, dword[pdfs.read]
    syscall     read, rdi, Parent.buffer, data.length
    ; write output with buffer to STDOUT
    syscall     write, stdout, Parent.msg2, Parent.msg2.length
    ; wait for child to terminate
    syscall     wait4, 0, 0, 0, 0
    jmp         Exit
    
Error:
.Fork:
    mov         rsi, forkerror
    mov         rdx, forkerror.length
    jmp         Write
.Pipe:
    mov         rsi, pipeerror
    mov         rdx, pipeerror.length
Write:    
    syscall     write, stdout
Exit:      
    syscall     exit, 0
