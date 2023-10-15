;name: mortgage.asm
;
;description:
;

bits 64

%include "../Mortgage/inc/mortgage.inc"

global mortgage

section .data
    tempReal: times 8 db 0

section .text

mortgage:
    xor     rax, rax
    fld1
    fstp    qword[rdi]
    ret
