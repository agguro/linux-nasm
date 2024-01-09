;name: easter.asm
;
;description: calculates the Easter day and month of a given year.
;source: 
;verified with: https://www.astro.oma.be/nl/informatie/wetenschappelijke-inlichtingen/wanneer-het-pasen/de-paasdata-van-1583-tot-3000/
;
;build: nasm -felf64 easter.asm -o easter.o
;   ld -melf_x86_64 easter.o -o easter  

bits 64

    %include "unistd.inc"

    %define STARTYEAR 1583
    %define NYEARS 3000-1583+1
    
global _start

section .bss
    buffer:    resb 20                  ;reserve 20 bytes as a buffer
        
section .rodata

section .data

    output:
    .dayt:      db  0x0
    .dayu:      db  0x0
                db  "/"
    .montht:    db  0x0
    .monthu:    db  0x0
                db  0x0A
    .len:       equ $-output
            
section .text

_start:

    mov     rcx,NYEARS

    mov     rdi, STARTYEAR
.repeat:
    call    easter
    dec     rdi
    push    rcx
    push    rdi
    mov     rax,r14                     ;month
    mov     rdx,0
    mov     rbx,10
    div     rbx
    add     rax,0x30
    add     rdx,0x30
    mov     byte[output.montht],al
    mov     byte[output.monthu],dl
    mov     rax,r15                     ;day
    mov     rdx,0
    mov     rbx,10
    div     rbx
    add     rax,0x30
    add     rdx,0x30
    mov     byte[output.dayt],al
    mov     byte[output.dayu],dl
    
    syscall write,stdout,output,output.len
    pop     rdi
    pop     rcx
    loopnz   .repeat
    
    syscall exit, rax

easter:

    ret
