; Name:     calcarraysquares.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o calcarraysquares.o calcarraysquares.asm
;           g++ -m32 -o calcarraysquares calcarraysquares.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.56

global  CalcArraySquares

section .text

; extern "C" int CalcArraySquares(int* y, const int* x, int n);
;
; Description:   This function cComputes y[i] = x[i] * x[i].
;
; Returns:      Sum of the elements in array y.

%define y    [ebp+8]
%define x    [ebp+12]
%define n    [ebp+16]
    
CalcArraySquares:
    push    ebp
    mov     ebp,esp
    push    ebx
    push    esi
    push    edi
    ; Load arguments
    mov     edi,y                ;edi = 'y'
    mov     esi,x                ;esi = 'x'
    mov     ecx,n                ;ecx = 'n'
    ; Initialize array sum register, calculate size of array in bytes,
    ; and initialize element offset register.
    xor     eax,eax              ;eax = sum of 'y' array
    cmp     ecx,0
    jle     .emptyArray
    shl     ecx,2                ;ecx = size of array in bytes
    xor     ebx,ebx              ;ebx = array element offset
    ; Repeat loop until finished
.l1:
    mov     edx,[esi+ebx]        ;load next x[i]
    imul    edx,edx              ;compute x[i] * x[i]
    mov     [edi+ebx],edx        ;save result to y[i]
    add     eax,edx              ;update running sum
    add     ebx,4                ;update array element offset
    cmp     ebx,ecx
    jl      .l1                  ;jump if not finished
.emptyArray:
    pop     edi
    pop     esi
    pop     ebx
    pop     ebp
    ret
