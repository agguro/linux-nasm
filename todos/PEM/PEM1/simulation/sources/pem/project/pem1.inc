%ifndef _ASM_SLEEP_
%define _ASM_SLEEP_

%include "../includes/syscalls.inc"
%include "../includes/termio.inc"
%include "../includes/time.inc"
%include "../includes/errors.inc"

%define SECONDS         1
%define NANOSECONDS     0

%macro STRING 1
.start:     db      %1
.length:    equ     $-.start
%endmacro

%macro syscall.write 1
        mov     rsi, %1
        mov     rdi, STDOUT
        mov     rdx, %1.length
        mov     rax, SYS_WRITE
        syscall
%endmacro

%macro syscall.nanosleep 2
        mov     rdi, QWORD %1
%if %2==0    
        xor     rsi, rsi
%elif
        mov     rsi, %2
%endif
        mov     rax, SYS_NANOSLEEP
        syscall
%endmacro

%macro syscall.exit 1
%if %1==0    
        xor     rdi, rdi
%elif
        mov     rdi, %2
%endif
        mov     rax, SYS_EXIT
        syscall
%endmacro

%elif
        %warning "sleep.inc already included"
%endif