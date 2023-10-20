; Name:     calcstructsum.asm
;
; Build:    g++ -m32 -c main.cpp -o main.o
;           nasm -f elf32 -o calcstructsum.o calcstructsum.asm
;           g++ -m32 -o calcstructsum calcstructsum.o main.o
;
; Source:   Modern x86 Assembly Language Programming p.68

global  CalcStructSum

; the structure in nasm

struc TEST_STRUC
    .Val8:     resb    1
    .Pad8:     resb    1
    .Val16:    resw    1
    .Val32:    resd    1
    .Val64:    resq    1
    .size:
endstruc

; assuming that ts is represented in esi
%define ts.Val8         byte[esi+TEST_STRUC.Val8]
%define ts.Val16        word[esi+TEST_STRUC.Val16]
%define ts.Val32        dword[esi+TEST_STRUC.Val32]
%define ts.Val64.low    dword[esi+TEST_STRUC.Val64]
%define ts.Val64.high   dword[esi+TEST_STRUC.Val64+4]

section .text

; extern "C" int64_t CalcStructSum(const TestStruct* ts);
;
; Description:  This function sums the members of a TestStruc.
;
; Returns:      Sum of 'ts' members as a 64-bit integer.

%define ts  [ebp+8]

CalcStructSum:
    push    ebp
    mov     ebp,esp
    push    ebx
    push    esi
    ; Compute ts->Val8 + ts->Val16, note sign extension to 32-bits
    mov     esi,ts
    movsx   eax,ts.Val8
    movsx   ecx,ts.Val16
    add     eax,ecx
    ; Sign extend previous sum to 64 bits, save result to ebx:ecx
    cdq
    mov     ebx,eax
    mov     ecx,edx
    ; Add ts->Val32 to sum
    mov     eax,ts.Val32
    cdq
    add     eax,ebx
    adc     edx,ecx
    ; Add ts->Val64 to sum
    add     eax,ts.Val64.low
    adc     edx,ts.Val64.high
    pop     esi
    pop     ebx
    pop     ebp
    ret
