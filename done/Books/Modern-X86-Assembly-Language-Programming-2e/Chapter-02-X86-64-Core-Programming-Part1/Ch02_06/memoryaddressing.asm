;name        : memoryaddressing.asm
;description : memoryaddressing example
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" int MemoryAddressing_(int i, int* v1, int* v2, int* v3, int* v4);
;              returns: 0 = error (invalid table index), 1 = success
;              extern "C" int NumFibVals_, FibValsSum_;
;              declare NumFibVals_ and FibValsSum_ as external variables

bits 64

%define SIZEOF_DWORD 4

global MemoryAddressing_
global FibValsSum_:data FibValsSum_.end - FibValsSum_
global NumFibVals_:data NumFibVals_.end - NumFibVals_

; Simple lookup table (.rodata section data is read only)
section .rodata

FibVals:        dd 0, 1, 1, 2, 3, 5, 8, 13
                dd 21, 34, 55, 89, 144, 233, 377, 610, 987, 1597

NumFibVals_:    dd ($ - FibVals) / SIZEOF_DWORD
.end:

; Data section (data is read/write)
section .data

    FibValsSum_:    dd  0             ;value to demo RIP-relative addressing
    .end:

section .text

MemoryAddressing_:
; in : edi = i
;      rsi = v1 ptr
;      rdx = v2 ptr
;      rcx = v3 ptr
;      r8  = v4 ptr
; out: rax = 0 : invalid table index
;            1 : success
; Make sure 'i' is valid
        cmp     edi,0
        jl      InvalidIndex            ;jump if i < 0
        cmp     edi,[NumFibVals_]
        jge     InvalidIndex            ;jump if i >= NumFibVals_

; Sign extend i for use in address calculations
        movsxd rdi,edi                  ;sign extend i

; Example #1 - base register
        mov     r11,FibVals             ;r11 = FibVals
        shl     rdi,2                   ;rcx = i * 4
        add     r11,rdi                 ;r11 = FibVals + i * 4
        shr     rdi,2                   ;restore i to previous value
        mov     eax,[r11]               ;eax = FibVals[i]
        mov     [rsi],eax               ;save to v1

; Example #2 - base register + index register
        mov     r11,FibVals             ;r11 = FibVals
        shl     rdi,2                   ;rcx = i * 4
        mov eax,[r11+rdi]               ;eax = FibVals[i]
        shr     rdi,2                   ;restore i ro previous value
        mov     [rdx],eax               ;save to v2

; Example #3 - base register + index register * scale factor
        mov     r11,FibVals             ;r11 = FibVals
        mov     eax,[r11+rdi*4]         ;eax = FibVals[i]
        mov     [rcx],eax               ;save to v3

; Example #4 - base register + index register * scale factor + disp
        mov     r11,FibVals-42          ;r11 = FibVals - 42
        mov     eax,[r11+rdi*4+42]      ;eax = FibVals[i]
        mov     [r8],eax                ;save to v4

; Example #5 - RIP relative
        add     [FibValsSum_],eax       ;update sum

        mov eax,1                       ;set success return code
        ret

InvalidIndex:
        xor eax,eax                     ;set error return code
        ret
