; Name:         memoryaddressing.asm
;
; Build:        g++ -c main.cpp -o main.o
;               nasm -f elf64 -o memoryaddressing.o memoryaddressing.asm
;               g++ -o memoryaddressing memoryaddressing.o main.o
;
; Source:       Modern x86 Assembly Language Programming p.512

bits 64

global MemoryAddressing
global FibVals
global NumFibVals

section .bss
    ;value to demo RIP-relative addressing
    common FibValsSum 4         ;one dword to store result
                                ;memory is global and shared amongst other modules

section .data

; Simple lookup table
FibVals:    dd  0,  1,  1,   2,   3,   5,   8,  13,   21
            dd 34, 55, 89, 144, 233, 377, 610, 987, 1597
NumFibVals: dd ($ - FibVals) / 4    ; sizeof dword = 4 bytes

section .code

; extern "C" int MemoryAddressing(int i, int* v1, int* v2, int* v3, int* v4);
;
; Description:  This function demonstrates various addressing modes
;               that can be used to access operands in memory.
;
; Returns:      0 = error (invalid table index)
;               1 = success

MemoryAddressing:
    ; Make sure 'i' is valid
    cmp     edi,0
    jl      .invalidIndex               ;jump if i < 0
    cmp     edi,[NumFibVals]
    jge     .invalidIndex               ;jump if i >= NumFibVals_

    ; Sign extend i for use in address calculations
    movsxd  rdi,edi                     ;sign extend i
    mov     r9,rdi                      ;save copy of i
    ; Example #1 - base register
    mov     r11,FibVals                 ;r11 = FibVals
    shl     rdi,2                       ;rdi = i * 4
    add     r11,rdi                     ;r11 = FibVals + i * 4
    mov     eax,[r11]                   ;eax = FibVals[i]
    mov     [rsi],eax                   ;Save to v1
    ; Example #2 - base register + index register
    mov     r11,FibVals                 ;r11 = FibVals
    mov     rdi,r9                      ;rdi = i
    shl     rdi,2                       ;rdi = i * 4
    mov     eax,[r11+rdi]               ;eax = FibVals[i]
    mov     [rdx],eax                   ;Save to v2
    ; Example #3 - base register + index register * scale factor
    mov     r11,FibVals                 ;r11 = FibVals
    mov     rdi,r9                      ;rdi = i
    mov     eax,[r11+rdi*4]             ;eax = FibVals[i]
    mov     [rcx],eax                   ;Save to v3
    ; Example #4 - base register + index register * scale factor + disp
    mov     r11,FibVals-42              ;r11 = FibVals - 42
    mov     rdi,r9                      ;rdi = i
    mov     eax,[r11+rdi*4+42]          ;eax = FibVals[i]
    mov     [r8],eax                    ;Save to v4
    ; Example #5 - RIP relative
    add     [FibValsSum],eax            ;Update sum
    mov     eax,1                       ;set success return code
    ret
.invalidIndex:
    xor     eax,eax                     ;set error return code
    ret
