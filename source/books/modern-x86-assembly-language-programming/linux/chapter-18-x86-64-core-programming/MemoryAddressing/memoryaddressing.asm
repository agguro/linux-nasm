; Name:         memoryaddressing.asm
;
; Source:       Modern x86 Assembly Language Programming p.512

bits 64
extern _GLOBAL_OFFSET_TABLE_
global MemoryAddressing_:function
global FibVals_:data (FibVals_.end - FibVals_)
global NumFibVals_:data (NumFibVals_.end - NumFibVals_)

section .bss
;value to demo RIP-relative addressing
common FibValsSum_ 4         ;one dword to store result
                            ;memory is global and shared amongst other modules

section .data
; Simple lookup table
FibVals_:   dd  0,  1,  1,   2,   3,   5,   8,  13,   21
            dd 34, 55, 89, 144, 233, 377, 610, 987, 1597
.end:
NumFibVals_: dd ($ - FibVals_) / 4    ; sizeof dword = 4 bytes
.end:

section .text

; extern "C" int MemoryAddressing_(int i, int* v1, int* v2, int* v3, int* v4);
;
; Returns:      0 = error (invalid table index)
;               1 = success

MemoryAddressing_:
    push      rbp
    mov       rbp,rsp
    push      rbx
    call      .get_GOT
.get_GOT:
    pop       rbx
    add       rbx,_GLOBAL_OFFSET_TABLE_+$$-.get_GOT wrt ..gotpc
; Make sure 'i' is valid
    cmp     edi,0
    jl      .invalidIndex               ;jump if i < 0
    mov     rax,[rbx + NumFibVals_ wrt ..got]
    cmp     edi,[rax]
    jge     .invalidIndex               ;jump if i >= NumFibVals_
; Sign extend i for use in address calculations
    movsxd  rdi,edi                     ;sign extend i
    mov     r9,rdi                      ;save copy of i
; Example #1 - base register
    mov     r11,[rbx + FibVals_ wrt ..got]                 ;r11 = FibVals
    shl     rdi,2                       ;rdi = i * 4
    add     r11,rdi                     ;r11 = FibVals + i * 4
    mov     eax,[r11]                   ;eax = FibVals[i]
    mov     [rsi],eax                   ;Save to v1
; Example #2 - base register + index register
    mov     r11,[rbx + FibVals_ wrt ..got]                 ;r11 = FibVals
    mov     rdi,r9                      ;rdi = i
    shl     rdi,2                       ;rdi = i * 4
    mov     eax,[r11+rdi]               ;eax = FibVals[i]
    mov     [rdx],eax                   ;Save to v2
; Example #3 - base register + index register * scale factor
    mov     r11,[rbx + FibVals_ wrt ..got]                 ;r11 = FibVals
    mov     rdi,r9                      ;rdi = i
    mov     eax,[r11+rdi*4]             ;eax = FibVals[i]
    mov     [rcx],eax                   ;Save to v3
; Example #4 - base register + index register * scale factor + disp
    mov     rax, FibVals_ wrt ..got
    mov     r11,[rbx + rax]             ;r11 = FibVals
    sub     r11, 42                     ;r11 = FibVals - 42
    mov     rdi,r9                      ;rdi = i
    mov     eax,[r11 + rdi*4 + 42]      ;eax = FibVals[i]
    mov     [r8],eax                    ;Save to v4
; Example #5 - RIP relative
    default rel
    mov     r11, FibValsSum_
    add     dword [r11],eax            ;Update sum
;valid index
    mov     eax,1                       ;set success return code
    jmp     .done
.invalidIndex:
    xor     eax,eax                     ;set error return code
.done:
    mov     rbx,[rbp-8]
    mov     rsp,rbp
    pop     rbp
    ret
