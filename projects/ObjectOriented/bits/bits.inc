%ifndef _ASM_BITS_INC_
%define _ASM_BITS_INC_

%include "../../includes/syscalls.inc"
%include "../../includes/termio.inc"
%include "../../includes/errors.inc"
%include "../classes/bit.class"

%macro syscall.write 1
    mov     rdi, STDOUT
    mov     rsi, %1
    mov     rdx, %1.length
    mov     rax, SYS_WRITE
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
    %warning "bits.inc already included"
%endif