; Name:         memoryaddressing.asm
; Source:       Modern x86 Assembly Language Programming p.42

bits 32
global  MemoryAddressing_
global  NumFibVals_

section .data
; Simple lookup table

FibVals:    dd 0, 1, 1, 2, 3, 5, 8, 13
            dd 21, 34, 55, 89, 144, 233, 377, 610 

; extern "C" int NumFibVals_;

NumFibVals_: dd ($ - FibVals) / 4			; sizeof word = 4

section .text

; extern "C" int MemoryAddressing_(int i, int* v1, int* v2, int* v3, int* v4);
; Description:  This function demonstrates various addressing modes
;               that can be used to access operands in memory.
; Returns:      0 = error (invalid table index)
;               1 = success

%define i   dword[ebp+8]
%define v1  dword[ebp+12]
%define v2  dword[ebp+16]
%define v3  dword[ebp+20]
%define v4  dword[ebp+24]
	
MemoryAddressing_:	
    push    ebp
    mov     ebp,esp
    push    ebx
    push    edi
    push    esi
    ; Make sure 'i' is valid
    xor     eax,eax
    mov     edi, i
    cmp     edi, 0
    jl      .invalidIndex           ;jump if i < 0
    cmp     edi,[NumFibVals_]
    jge     .invalidIndex           ;jump if i >= NumFibVals_
    ; Example #1 - base register
    mov     ebx, FibVals            ;rbx = FibVals
    shl     edi, 2                  ;rsi = i * 4
    add     ebx, edi                ;rbx = FibVals + i * 4
    mov     eax, [ebx]              ;Load table value
    mov     esi, v1
    mov     [esi], eax              ;Save to 'v1'
    ; Example #2 - base register + displacement
    ; esi is used as the base register
    mov     esi, i                  ;esi = i
    shl     esi, 2                  ;esi = i * 4
    mov     eax, [esi+FibVals]      ;Load table value
    mov     esi, v2
    mov     [esi],eax               ;Save to 'v2'
    ; Example #3 - base register + index register
    mov     ebx, FibVals            ;ebx = FibVals
    mov     esi, i                  ;esi = i
    shl     esi, 2                  ;esi = i * 4
    mov     eax, [ebx+esi]          ;Load table value
    mov     esi, v3
    mov     [esi],eax               ;Save to 'v3'
    ; Example #4 - base register + index register * scale factor
    mov     ebx, FibVals            ;ebx = FibVals
    mov     esi, i                  ;esi = i
    mov     eax, [ebx+esi*4]        ;Load table value
    mov     esi, v4
    mov     [esi], eax              ;Save to 'v4'
    mov     eax,1                   ;Set return code
.invalidIndex:
    pop     esi
    pop     edi
    pop     ebx
    pop     ebp
    ret
