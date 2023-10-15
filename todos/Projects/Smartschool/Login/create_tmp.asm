;project:       Webservices
;name:          definitions.asm
;build:         nasm -felf64 definitions.asm -l definitions.lst -o definitions.o
;               ld -melf_x86_64 -g --dynamic-linker /lib64/ld-linux-x86-64.so.2 -o definitions definitions.o `pkg-config --libs openssl`
;description:   Get Smartschool definitions

    %include "unistd.inc"               ;syscalls
    %include "sys/stat.inc"             ;S_IRUSR, S_IWUSR
    %include "asm-generic/mman.inc"     ;O_RDWR, O_CREAT
    %include "sys/time.inc"

section .data
    filename:   db      '/tmp/file.text',00
    fd:         dq      0
    text:       db      "This the output file",0x0A,0x0D
    text_len:   equ     $-text
    TIMESPEC    time

section .text
global _start

_start:

        call    GetTime
        mov     qword[time.tv_sec],rdx
        mov     qword[time.tv_nsec],rax
        mov     rdi, time
                
        ;call    createFilename
        

        syscall open,filename, O_RDWR | O_CREAT , S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP
        
        mov       qword [fd], rax         ; write resulting file descriptor in EBX
        syscall write,fd,text,text_len
        syscall exit

;GetTime
;This subroutine returns the time in RDX:RAX
;IN  : none
;OUT : RDX = seconds
;      RAX = nanoseconds

GetTime:
    push    rsi
    push    rdi
    push    rcx
    push    rbp
    mov     rbp,rsp
    sub     rsp,16                          ;reserve 2 QWORDS
    syscall clock_gettime,CLOCK_REALTIME,rsp
    mov     rdx,[rsp]                       ;seconds
    mov     rax,[rsp+8]                     ;nanoseconds
    mov     rsp,rbp
    pop     rbp
    pop     rcx
    pop     rdi
    pop     rsi
    ret
