

section .data
    the_string: db "this",0," is a damn large string",0

section .text
    global _start

_start:

mov rdi,the_string
pxor xmm4, xmm4
pcmpeqb xmm4, [rdi]
pmovmskb eax, xmm4
test eax, eax                 ; ZF=0 if there are any set bits = any matches
jnz .found_a_zero
    nop
.found_a_zero:
    shr eax,1
    ret
