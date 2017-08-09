; Name:         pagesize.asm
;
; Build:        nasm "-felf64" pagesize.asm -l pagesize.lst -o pagesize.o 
;
; Description:  Get the pagesize programmatically of a platform
;
; Source:       https://stackoverflow.com/questions/3351940/detecting-the-memory-page-size/3351960#3351960

bits 64

[list -]
    %include "unistd.inc"
    %include "sys/mman.inc"
[list +]

global pagesize
    
section .text
    global _start
    
_start:
    call    pagesize
    syscall exit,0
    
pagesize:
    push        r15
    push        r14
    push        r10
    push        r9
    push        r8
    push        rdx
    push        rsi
    push        rdi   
    
    xor         r14,r14
    inc         r14
    mov         r15,r14
.repeat:    
    shl         r15,1                                                   
    syscall     mmap,0,r15,PROT_NONE,MAP_ANONYMOUS | MAP_PRIVATE,-1,0
    and         rax,rax
    js          .failed
    mov         rdx,rax
    mov         r15,rax
    add         r15,r14
    syscall     munmap,r15,r14
    mov         r8,rax                     ;save error code
    mov         r15,r14
    shl         r15,1
    syscall     munmap,rdx,r15
    mov         rax,r14
    and         r8,r8
    jz          .exit
    shl         r14,1
    jmp         .repeat
.failed:
    mov         rax,-1
.exit:
    push        rdi
    push        rsi
    push        rdx
    push        r8
    push        r9
    push        r10
    push        r14
    push        r15
    ret