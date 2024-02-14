; Name:     callingconvention.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o callingconvention.o callingconvention.asm
;           g++ -m32 -o callingconvention callingconvention.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.37

global  CalculateSums

section .text

; extern "C" void CalculateSums(int a, int b, int c, int* s1, int* s2, int* s3);
;
; Description:  This function demonstrates a complete assembly language
;               prolog and epilog.
;
; Returns:      None.
;
; Computes:     *s1 = a + b + c
;               *s2 = a * a + b * b + c * c
;               *s3 = a * a * a + b * b * b + c * c * c

%define a       [ebp+8]
%define b       [ebp+12]
%define c       [ebp+16]
%define ptrS1   [ebp+20]
%define ptrS2   [ebp+24]
%define ptrS3   [ebp+28]

CalculateSums:
    push    ebp
    mov     ebp, esp
    push    ecx
    mov     eax, a
    add     eax, b
    add     eax, c                      ;a+b+c
    mov     ecx, ptrS1
    mov     [ecx], eax                  ;store result in s1
    mov     ecx, ptrS2                  ;result s2
    mov     eax, a
    imul    eax, eax                    ;a*a
    mov     [ecx], eax                  ;s1 = a*a
    mov     ecx, ptrS3                  ;result s3
    imul    eax, a                      ;a*a*a
    mov     [ecx], eax                  ;s3 = a*a*a
    mov     ecx, ptrS2                  ;result s2
    mov     eax, b
    imul    eax, eax                    ;b*b
    add     [ecx], eax                  ;s2 = a*a + b*b
    mov     ecx, ptrS3                  ;result s3
    imul    eax, b                      ;b*b*b
    add     [ecx], eax                  ;s3 = a*a*a + b*b*b
    mov     ecx, ptrS2                  ;result s2
    mov     eax, c
    imul    eax, eax                    ;c*c
    add     [ecx], eax                  ;s2 = a*a + b*b + c*c
    mov     ecx, ptrS3                  ;result s3
    imul    eax, c                      ;c*c*c
    add     [ecx], eax                  ;s3 = a*a*a + b*b*b + c*c*c
    pop     ecx
    mov     esp, ebp
    pop     ebp
    ret
