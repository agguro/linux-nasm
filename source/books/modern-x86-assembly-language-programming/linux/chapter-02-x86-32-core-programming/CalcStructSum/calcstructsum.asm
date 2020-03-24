; Name:     calcstructsum.asm
; Source:   Modern x86 Assembly Language Programming p.68

; the structure in nasm

struc TEST_STRUC
    .Val8:     resb    1
    .Pad8:     resb    1
    .Val16:    resw    1
    .Val32:    resd    1
    .Val64:    resq    1
    .size:
endstruc

; ts must be in esi
%define ts.Val8          byte[esi+TEST_STRUC.Val8]
%define ts.Val16         word[esi+TEST_STRUC.Val16]
%define ts.Val32         dword[esi+TEST_STRUC.Val32]
%define ts.Val64.low     dword[esi+TEST_STRUC.Val64]
%define ts.Val64.high    dword[esi+TEST_STRUC.Val64+4]
%define ts			[ebp+8]

bits 32
global  CalcStructSum_
section .text

; extern "C" int64_t CalcStructSum_(const TestStruct* ts);
; Description:  This function sums the members of a TestStruc.
; Returns:      Sum of 'ts' members as a 64-bit integer.

CalcStructSum_:
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
