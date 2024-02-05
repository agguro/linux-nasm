;name: strlen_simd.asm
;
;build: 
;
;description: demo to determine stringlength of a zero terminated string with simd instructions
;
;TODO: determine length of larger strings

%include "unistd.inc"

section .data
    the_string: db "this",0," is a damn large string",0

section .text
    global _start

_start:

    mov rdi,the_string
    call    strlen_simd
    syscall exit,0

strlen_simd:    
    pxor xmm4, xmm4
    pcmpeqb xmm4, [rdi]
    pmovmskb eax, xmm4
    test eax, eax                 ; ZF=0 if there are any set bits = any matches
    jnz .found_a_zero
    ret
.found_a_zero:
    shr eax,1
    ret
