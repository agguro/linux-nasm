; extern "C" int CalcSum(int a, int b, int c);
;
; Name:         CalcSum
;
; Description:  This function demonstrates passing arguments between
;               a C++ function and an assembly language function in
;               Linux with gcc and nasm.
;
; Returns:      a + b + c
;
; Source:       Modern x86 Assembly Language Programming p.29

global  CalcSum

section .text

CalcSum:
    mov     eax, edi    ; a = edi
    add     eax, esi    ; b = esi
    add     eax, edx    ; c = edx
    ret
