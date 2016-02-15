%ifndef _ASM_WAITFORKEYPRESS_INC_
%define _ASM_WAITFORKEYPRESS_INC_

    %include "../includes/errors.inc"
    %include "../includes/syscalls.inc"
    %include "../includes/termio.inc"

    %define ASCII_LF    10
    
    %macro BUFFER 1
        .start:     resb %1
        .length:    equ $-.start
    %endmacro
    
    %macro STRING 1
        .start:     db %1
        .length:    equ $-.start
    %endmacro
    
    %macro syscall.write 1
        mov     rsi, %1
        mov     rdx, %1.length
        mov     rdi, STDOUT
        mov     rax, SYS_WRITE
        syscall
    %endmacro
    
    %macro syscall.read 1
        mov     rsi, %1
        mov     rdx, %1.length
        mov     rdi, STDIN
        mov     rax, SYS_READ
        syscall
    %endmacro
    
    %macro syscall.exit 1
    %if %1==0
        xor     rdi, rdi
    %elif
        mov     rdi, %1
    %endif
        mov     rax, SYS_EXIT
        syscall
    %endmacro
    
%elif
    %warning "waitforkeypress.inc already included"
%endif