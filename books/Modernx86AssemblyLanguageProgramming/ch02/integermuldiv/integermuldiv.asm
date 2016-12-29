; extern "C" int IntegerMulDiv(int a, int b, int* prod, int* quo, int* rem);
;
; Name:         integermuldiv.asm
;
; Description:  This function demonstrates use of the imul and idiv
;               instructions.  It also illustrates pointer usage.
;
; Returns:      0   Error (divisor is zero)
;               1   Success (divisor is zero)
;
; Computes:     *prod = a * b;
;               *quo = a / b
;               *rem = a % b
;
; Source:       Modern x86 Assembly Language Programming p.33

global  IntegerMulDiv

section .text

IntegerMulDiv:
    ; registry values at entry
    ; edi : a
    ; esi : b
    ; rdx : pointer to product
    ; rcx : pointer to quotient
    ; r8  : pointer to remainder
    mov     eax, esi            ; eax = b
    or      eax, eax            ; b = 0 ?
    jz      InvalidDivisor
    imul    eax, edi            ; prod = a * b
    mov     dword [rdx], eax    ; save product
    mov     eax, edi
    cdq
    idiv    esi                 ; quo = a / b in eax, rem = a % b in edx
    mov     dword [rcx], eax    ; save quotient
    mov     dword [r8], edx     ; save remainder
    mov     eax, 1              ; rc = 1 = succes
InvalidDivisor:
    ; rax = 0 when b is zero
    ret
