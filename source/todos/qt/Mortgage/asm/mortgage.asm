;name: mortgage.asm
;
;description:
;

bits 64

;%include "../Mortgage/inc/mortgage.inc"

global mortgage

section .data
    tempReal: times 8 db 0
    teststring: db 0,'5',0,'6',0,'7',0,'8',0,0,0,0,0,0,0,0,0,0
section .text

mortgage:
    mov     rax,rdi
    mov     rax,[rax]
    mov     rdi,[teststring]
    mov     [rax],rdi
    ret
