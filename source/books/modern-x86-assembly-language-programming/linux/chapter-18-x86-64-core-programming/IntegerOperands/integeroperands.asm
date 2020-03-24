; Name:         integeroperands.asm
;
; Source:       Modern x86 Assembly Language Programming p.514

bits 64
extern  _GLOBAL_OFFSET_TABLE_

global CalcLogical_

; The following structure must match the structure that's
; declared in IntegerOperands.cpp. Note the version below
; includes "pad" bytes, which are needed to account for the
; member alignments performed by the C++ compiler.
struc ClVal
    .a8:    resb 1
    .pad1:  resb 1
    .a16:   resw 1
    .a32:   resd 1
    .a64:   resq 1
    .b8:    resb 1
    .pad2:  resb 1
    .b16:   resw 1
    .b32:   resd 1
    .b64:   resq 1
endstruc

section .text

; extern "C" void CalcLogical_(ClVal* cl_val, Uint8 c8[3], Uint16 c16[3], Uint32 c32[3], Uint64 c64[3]);
;
; Description:  The following function demonstrates logical operations
;               using different sizes of integers.

CalcLogical_:
    ; 8-bit logical operations
    mov r10b,[rdi+ClVal.a8]             ;r10b = a8
    mov r11b,[rdi+ClVal.b8]             ;r11b = b8
    mov al,r10b
    and al,r11b                         ;calc a8 & b8
    mov [rsi],al
    mov al,r10b
    or al,r11b                          ;calc a8 | b8
    mov [rsi+1],al
    mov al,r10b
    xor al,r11b                         ;calc a8 ^ b8
    mov [rsi+2],al

; 16-bit logical operations
    mov r10w,[rdi+ClVal.a16]            ;r10w = a16
    mov r11w,[rdi+ClVal.b16]            ;r11w = b16
    mov ax,r10w
    and ax,r11w                         ;calc a16 & b16
    mov [rdx],ax
    mov ax,r10w
    or ax,r11w                          ;calc a16 | b16
    mov [rdx+2],ax
    mov ax,r10w
    xor ax,r11w                         ;calc a16 ^ b16
    mov [rdx+4],ax

; 32-bit logical operations
    mov r10d,[rdi+ClVal.a32]            ;r10d = a32
    mov r11d,[rdi+ClVal.b32]            ;r11d = b32
    mov eax,r10d
    and eax,r11d                        ;calc a32 & b32
    mov [rcx],eax
    mov eax,r10d
    or eax,r11d                         ;calc a32 | b32
    mov [rcx+4],eax
    mov eax,r10d
    xor eax,r11d                        ;calc a32 ^ b32
    mov [rcx+8],eax

; 64-bit logical operations
    mov r10,[rdi+ClVal.a64]             ;r10 = a64
    mov r11,[rdi+ClVal.b64]             ;r11 = b64
    mov rax,r10
    and rax,r11                         ;calc a64 & b64
    mov [r8],rax
    mov rax,r10
    or rax,r11                          ;calc a64 | b64
    mov [r8+8],rax
    mov rax,r10
    xor rax,r11                         ;calc a64 ^ b64
    mov [r8+16],rax
    ret
