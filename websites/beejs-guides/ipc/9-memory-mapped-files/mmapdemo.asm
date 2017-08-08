; Name:         mmapdemo.asm
;
; Build:        nasm "-felf64" mmapdemo.asm -l mmapdemo.lst -o mmapdemo.o
;               ld -s -melf_x86_64 -o mmapdemo mmapdemo.o 
;
; Description:  Demonstration on memory mapped files based on an example from Beej's Guide to IPC.
;
; Source:       http://beej.us/guide/bgipc/output/html/multipage/mmap.html

bits 64

[list -]
    %include "unistd.inc"
    %include "fcntl.inc"
    %include "sys/mman.inc"
    %include "sys/stat.inc"
    %include "sys/page.inc"
[list +]

section .bss
    
    fd:     resq    1
    offset: resq    1
    data:   resq    1
    buffer: resb    1
    
section .data

    STAT            stat
    file:           db  "mmapdemo.asm",0
    
    msgByte:        db  "byte at offset is "     
    .length:        equ $-msgByte
    
    msgMmap:        db  "mmap error",10
    .length:        equ $-msgMmap
    
    msgOffset:      db  "mmapdemo: offset must be in the range 0-"
    .length:        equ $-msgOffset
    
    msgOpenFile:    db  "Cannot open file or file not found",10
    .length:        equ $-msgOpenFile
    
    msgUsage:       db  "usage: mmapdemo offset",10
    .length:        equ $-msgUsage
    
    msgStatus:      db  "File status error",10
    .length:        equ $-msgStatus
    
    eol:            db  10
    
section .text
    global _start:
_start:
    
    pop     rax                                 ;get argc from stack
    cmp     rax,2
    jne     error.usage
    
    syscall open,file,O_RDONLY
    and     rax,rax
    js      error.openfile
    mov     qword[fd],rax
    
    syscall fstat,rax,stat
    and     rax,rax
    js      error.status
    
    pop     rdi
    pop     rdi                                 ;argument from stack
    call    atoi                                ;convert to integer in rax
    and     rax,rax
    js      error.illegaloffset
    mov     rdx,qword[stat.st_size]
    dec     rdx
    cmp     rax,rdx
    jg      error.illegaloffset
    mov     qword[offset],rax
    
    syscall mmap,0,qword[stat.st_size],PROT_READ,MAP_SHARED,qword[fd],0
    and     rax,rax
    js      error.mmap
    mov     qword[data],rax
    
    syscall write,stdout,msgByte,msgByte.length
    mov     rax,qword[data]
    add     rax,qword[offset]
    mov     al,byte[rax]
    mov     byte[buffer],al
    syscall write,stdout,buffer,1
    syscall write,stdout,eol,1
    syscall exit,0
    
error:
.usage:
    syscall write,stderr,msgUsage,msgUsage.length
    syscall exit,1
.openfile:
    syscall write,stderr,msgOpenFile,msgOpenFile.length
    syscall exit,1
.mmap:
    syscall write,stderr,msgMmap,msgMmap.length
    syscall exit,1
.illegaloffset:
    syscall write,stderr,msgOffset,msgOffset.length
    syscall exit,1
.status:
    syscall write,stderr,msgStatus,msgStatus.length
    syscall exit,1

atoi:
    ;ascii to integer conversion
    ;in  : rdi = pointer to asciiz string
    ;out : rax = value in hexadecimal of asciiz string or -1 if illegal
    mov     rax,100                     ;return 0    
    ret
    