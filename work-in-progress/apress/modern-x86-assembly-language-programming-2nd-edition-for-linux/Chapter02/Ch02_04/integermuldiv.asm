;name        : integermuldiv.asm
;description : integer multiplication and division
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" int IntegerMulDiv_(int a, int b, int* prod, int* quo, int* rem);
;returns     : 0 = error (divisor equals zero), 1 = success

bits 64

global IntegerMulDiv_

section .text

IntegerMulDiv_:
;in : edi = a
;     esi = b
;     rdx = prod ptr
;     rcx = quo ptr
;     r8  = rem ptr
    mov     eax,esi             ;eax = b
    or      eax,eax             ;logical OR sets status flags
    jz      InvalidDivisor      ;jump if b is zero

; Calculate product and save result
    imul    eax,edi             ;eax = a * b
    mov     [rdx],eax           ;save product

; Make sure the divisor is not zero
    mov     r10d,esi            ;r10d = b
    mov     eax,edi             ;eax = a
    cdq                         ;edx:eax contains 64-bit dividend
    idiv    r10d                ;eax = quotient, edx = remainder
    mov     [rcx],eax           ;save quotient
; Linux stores the rem ptr in r8when the main program calls this routine.
; That's why the instructions
;       mov     rax,[rsp+40]        ;rax = 'rem'
;       mov     [rax],edx           ;save remainder
; are replaced here
    mov     [r8],edx            ;save remainder
    mov     eax,1               ;set success return code

InvalidDivisor:
    ret                         ;return to caller
