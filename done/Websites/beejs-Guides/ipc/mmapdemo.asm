;name        : mmapdemo.asm
;
;build       : nasm "-felf64" mmapdemo.asm -l mmapdemo.lst -o mmapdemo.o
;              ld -s -melf_x86_64 -o mmapdemo mmapdemo.o 
;
;description : Demonstration on memory mapped files based on an example from Beej's Guide to IPC.
;              If the byte read is 0x0A the response in the terminal leads to an extra end of line.
;              Better should be that the result byte is displayed in hexadecimal.
;
;source      : http://beej.us/guide/bgipc/output/html/multipage/mmap.html

bits 64

[list -]
    %include "unistd.inc"
    %include "sys/fcntl.inc"
    %include "asm-generic/mman.inc"
    %include "sys/stat.inc"
    %include "sys/page.inc"
[list +]

section .bss
    
    fd:                 resq    1
    offset:             resq    1
    data:               resq    1
    buffer:             resb    20
    ptrOffsetAscii:     resq    1

section .rodata

    file:           db  "mmapdemo.asm",0 
    msgByte:        db  "byte at offset "
    .length:        equ $-msgByte
    msgByte1:       db  " is: '"
    .length:        equ $-msgByte1
    msgMmap:        db  "mmap error",10
    .length:        equ $-msgMmap
    msgMunmap:      db  "munmap error",10
    .length:        equ $-msgMunmap
    msgOffset:      db  "mmapdemo: offset must be in the range 0-"
    .length:        equ $-msgOffset
    msgOpenFile:    db  "Cannot open file mmapdemo.asm or file not found",10
    .length:        equ $-msgOpenFile
    msgUsage:       db  "usage: mmapdemo offset",10
    .length:        equ $-msgUsage
    msgStatus:      db  "File status error",10
    .length:        equ $-msgStatus
    eol:            db  "'"
                    db  10

section .data

    STAT            stat

    
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
    call    atoui                                ;convert to integer in rax
    and     rax,rax
    js      error.illegaloffset
    mov     rdx,qword[stat.st_size]
    dec     rdx
    cmp     rax,rdx
    jg      error.illegaloffset
    mov     qword[offset],rax                   ;save decimal value
    mov     qword[ptrOffsetAscii],rdi           ;save pointer to inputstring
                                                ;so we don't have to use itoa
    syscall mmap,0,qword[stat.st_size],PROT_READ,MAP_SHARED,qword[fd],0
    and     rax,rax
    js      error.mmap
    mov     qword[data],rax
    
    syscall write,stdout,msgByte,msgByte.length
    mov     rdi,qword[ptrOffsetAscii]
    call    printAsciizString
    syscall write,stdout,msgByte1,msgByte1.length
    
    mov     rax,qword[data]
    add     rax,qword[offset]
    mov     al,byte[rax]
    mov     byte[buffer],al
    syscall write,stdout,buffer,1
    syscall write,stdout,eol,2
    
    ;now unmap the mapped file
    syscall munmap,qword[data],qword[stat.st_size]
    js      error.munmap
    syscall exit,0
    
error:
.usage:
    syscall write,stderr,msgUsage,msgUsage.length       ;print message
    syscall exit,1
.openfile:
    syscall write,stderr,msgOpenFile,msgOpenFile.length ;print message
    syscall exit,1
.mmap:
    syscall write,stderr,msgMmap,msgMmap.length         ;print message
    syscall exit,1
.illegaloffset:
    syscall write,stderr,msgOffset,msgOffset.length     ;print first part of the message
    mov     rdi,qword[stat.st_size]                     ;size in rdi minus one
    dec     rdi                                         ;because we start counting from zero
    call    uitoa                                       ;convert number
    syscall write,stderr,rax,rdx                        ;print the number
    syscall write,stderr,eol+1,1                        ;print end of line
    syscall exit,1
.status:
    syscall write,stderr,msgStatus,msgStatus.length     ;print message
    syscall exit,1
.munmap:
    syscall write,stderr,msgMunmap,msgMunmap.length     ;print message
    syscall exit,1

atoui:
    ;ascii to unsigned integer conversion
    ;in  : rdi = pointer to asciiz string
    ;out : rax = value in hexadecimal of asciiz string or -1 if illegal
    push    rsi
    push    rdi
    push    r8
    push    r9
    push    rdx
    mov     rsi,rdi                     ;pointer in rsi
    xor     rdx,rdx
    xor     r8,r8
.continue:    
    lodsb
    and     al,al
    jz      .done
    cmp     al,"0"
    jb      .error
    cmp     al,"9"
    ja      .error
    ;un-ascii
    and     al,0x0F
    ;multiply what we already have by 10
    xor     r9,r9                       ;clear temp result
    shl     r8,1                        ;multiply by 2
    add     r9,r8
    shl     r8,2                        ;multiply by 8
    add     r9,r8
    add     r9,rax
    mov     r8,r9                       ;store temp result
    jmp     .continue
.done:
    mov     rax,r8                      ;final result in rax
    jmp     .exit
.error:
    xor     rax,rax
    dec     rax
.exit:    
    pop     rdx
    pop     r9
    pop     r8
    pop     rdi
    pop     rsi
    ret

uitoa:
    ;unsigned integer to ascii conversion
    ;in  : rdi = unsigned integer value
    ;out : rax = pointer to ascii string of converted unsigned integer
    ;      rdx = length of ascii string
    push    rbx
    push    rdi
    mov     rax,rdi
    mov     rdi,buffer+19
    mov     rbx,10
.repeat:    
    xor     rdx,rdx
    idiv    rbx
    or      dl,0x30
    mov     byte[rdi],dl
    dec     rdi
    and     rax,rax
    jnz     .repeat
    mov     rdx,buffer+19
    sub     rdx,rdi
    inc     rdi
    mov     rax,rdi
    pop     rdi
    pop     rbx
    ret
    
printAsciizString:
    mov     rsi,rdi
.continue:
    mov     rdi,buffer
    lodsb
    and     al,al
    jz      .done
    stosb
    push    rsi
    push    rdi
    syscall write,stdout,buffer,1
    pop     rdi
    pop     rsi
    jmp     .continue
.done:    
    ret
