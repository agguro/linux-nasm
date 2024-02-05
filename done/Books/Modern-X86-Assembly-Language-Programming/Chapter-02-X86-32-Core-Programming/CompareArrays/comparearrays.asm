; Name:     comparearrays.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o comparearrays.o comparearrays.asm
;           g++ -m32 -o comparearrays comparearrays.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.81

global  CompareArrays

section .text

; extern "C" int CompareArrays(int* y, const int* x, int n);
;
; Description:  This function compares two integer arrays element
;               by element for equality
;
; Returns:      -1          Value of 'n' is invalid
;               0 <= i < n  Index of first non-matching element
;               n           All elements match

%define y   [ebp+8]
%define x   [ebp+12]
%define n   [ebp+16]

CompareArrays:
    push    ebp
    mov     ebp,esp
    push    esi
    push    edi
    ; Load arguments and validate 'n'
    mov     eax,-1              ;invalid 'n' return code
    mov     esi,x               ;esi = 'x'
    mov     edi,y               ;edi = 'y'
    mov     ecx,n               ;ecx = 'n'
    test    ecx,ecx
    jle     .l1                 ;jump if 'n' <= 0
    mov     eax,ecx             ;eax = 'n
    ; Compare the arrays for equality
    repe    cmpsd
    je      .l1                 ;arrays are equal
    ; Calculate index of unequal elements
    sub     eax,ecx
    dec     eax                 ;eax = index of mismatch
.l1:
    pop     edi
    pop     esi
    pop     ebp
    ret
