;name          : pipe1.asm
;
;build         : nasm -felf64 -o pipe1.o -l pipe1.lst pipe1.asm
;                ld -s -m elf_x86_64 pipe1.o -o pipe1
;
;description   : converted program pipe1.c
;
;source        : file:///home/agguro/Repository/Work/Beejs-guides/bgipc/pipes.html

[list -]
     %include "unistd.inc"
[list +]

bits 64

section .bss
 
    p:
    .read:         resd   1            ; read end of the pipe
    .write:        resd   1            ; write end of the pipe
    buf:           resb   30
    asciidword:    resb   4
    
section .rodata

    msgWriting:    db  "writing to file descriptor 0x"
    .length:       equ $-msgWriting
    msgReading:    db  "reading from file descriptor 0x"
    .length:       equ $-msgReading
    tstwrite:      db  "test"
    .length:       equ $-tstwrite
    msgRead:       db  "read '"
    .length:       equ $-msgRead
    pipeerror:     db  "pipe call error", 10
    .length:       equ $-pipeerror
    apostrophe:    db  "'"
    eol:           db  10
    
section .text

global _start    
_start:

    syscall     pipe,p
    and         rax,rax
    jns         startpipe
    syscall     write,stdout,pipeerror,pipeerror.length
    syscall     exit,0
startpipe:
    syscall     write,stdout,msgWriting,msgWriting.length
    mov         edi,dword[p.write]
    call        DwordToASCII
    syscall     write,stdout,asciidword,4
    syscall     write,stdout,eol,1
    
    mov         edi,dword[p.write]
    syscall     write,rdi,tstwrite,tstwrite.length
    
    syscall     write,stdout,msgReading,msgReading.length
    mov         edi,dword[p.read]
    call        DwordToASCII
    syscall     write,stdout,asciidword,4
    syscall     write,stdout,eol,1
    
    mov         edi,dword[p.read]
    syscall     read,rdi,buf,tstwrite.length
    
    syscall     write,stdout,msgRead,msgRead.length
    syscall     write,stdout,buf,tstwrite.length
    syscall     write,stdout,apostrophe,1
    syscall     write,stdout,eol,1

    syscall     exit,0
    
DwordToASCII:
    mov         eax,edi
    mov         cl,5
    or          eax,0x30303030
.back:
    cmp         al,"9"
    jbe         .nextbyte
    add         al,6
.nextbyte:
    ror         eax,8
    dec         cl
    cmp         cl,0
    jnz         .back
    mov         dword[asciidword],eax
    ret
