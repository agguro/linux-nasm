; Name:     calcsumtest.asm
; Source:   Modern x86 Assembly Language Programming p.29

bits 32
global  CalcSum_
section .text

; extern "C" int CalcSum_(int a, int b, int c);
; Description:  This function demonstrates passing arguments between
;               a C++ function and an assembly language function in
;               Linux with gcc and nasm.
; Returns:      a + b + c

%define a   [ebp+8]
%define b   [ebp+12]
%define c   [ebp+16]

CalcSum_:
    push    ebp
    mov     ebp,esp
    mov     eax,a
    add     eax,b
    add     eax,c
    pop     ebp
    ret