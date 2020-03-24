; Name:     integermuldiv.asm
; Source:   Modern x86 Assembly Language Programming p.33

bits 32
global  IntegerMulDiv_
section .text

; extern "C" int IntegerMulDiv_(int a, int b, int* prod, int* quo, int* rem);
; Description:  This function demonstrates use of the imul and idiv
;               instructions.  It also illustrates pointer usage.
; Returns:      0   Error (divisor is zero)
;               1   Success (divisor is zero)
; Computes:     *prod = a * b;
;               *quo = a / b
;               *rem = a % b

%define a       [ebp+8]
%define b       [ebp+12]
%define prod    [ebp+16]
%define quo     [ebp+20]
%define rem     [ebp+24]

IntegerMulDiv_:
    push    ebp
    mov     ebp, esp
    push    ebx
    push    ecx
    xor     eax, eax
    mov     ebx, b
    or      ebx, ebx            ; b = 0 ?
    jz      .invalidDivisor
    mov     eax, a
    imul    eax, ebx            ; prod = a * b
    mov     ecx, prod
    mov     [ecx], eax          ; save product
    mov     eax, a
    cdq
    mov     ebx, b
    idiv    ebx                 ; quo = a / b in eax, rem = a % b in edx
    mov     ecx, quo
    mov     [ecx], eax          ; save quotient
    mov     ecx, rem
    mov     [ecx], edx          ; save remainder
    mov     eax, 1              ; rc = 1 = succes
.invalidDivisor:
    ; rax = 0 when b is zero
    pop     ecx
    pop     ebx
    pop     ebp
    ret
