; Name:     calcsum.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o calcsum.o calcsum.asm
;           g++ -m32 -o calcsum calcsum.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.29

global  CalcSum

section .text

; extern "C" int CalcSum(int a, int b, int c);
;
; Description:  This function demonstrates passing arguments between
;               a C++ function and an assembly language function in
;               Linux with gcc and nasm.
;
; Returns:      a + b + c

%define a   [ebp+8]
%define b   [ebp+12]
%define c   [ebp+16]

CalcSum:
    push    ebp
    mov     ebp,esp
    mov     eax,a
    add     eax,b
    add     eax,c
    pop     ebp
    ret
