; Name:         avxscalarfloatingpointarithmetic.asm
;
; Build:        g++ -c -m32 main.cpp -o main.o
;               nasm -f elf32 -o avxscalarfloatingpointarithmetic.o avxscalarfloatingpointarithmetic.asm
;               g++ -m32 -o avxpackedfloatingpointarithmetic avxpackedfloatingpointarithmetic.o main.o ../../commonfiles/ymmval.o
;
; Source:       Modern x86 Assembly Language Programming p. 378

global AvxPfpArithmeticFloat
global AvxPfpArithmeticDouble

section .data
align 16

; Mask value for packed SPFP absolute value
AbsMask dd 0x7fffffff,0x7fffffff,0x7fffffff,0x7fffffff
        dd 0x7fffffff,0x7fffffff,0x7fffffff,0x7fffffff

; Mask value for packed SPFP negation
NegMask dd 0x80000000,0x80000000,0x80000000,0x80000000
        dd 0x80000000,0x80000000,0x80000000,0x80000000

section .text

; extern "C" void AvxPfpArithmeticFloat_(const YmmVal* a, const YmmVal* b, YmmVal c[6]);
;
; Description:  The following function illustrates how to use common
;               packed SPFP arithmetic instructions using the YMM
;               registers.
;
; Requires:     AVX

%define a   [ebp+8]
%define b   [ebp+12]
%define c   [ebp+16]

AvxPfpArithmeticFloat:
    push    ebp
    mov     ebp,esp

; Load argument values.  Note that the vmovaps instruction
; requires proper aligment of operands in memory.
    mov     eax,a                       ;eax = ptr to a
    mov     ecx,b                       ;ecx = ptr to b
    mov     edx,c                       ;edx = ptr to c
    vmovaps ymm0,[eax]                  ;ymm0 = a
    vmovaps ymm1,[ecx]                  ;ymm1 = b

; Perform packed SPFP addition, subtraction, multiplication,
; and division
    vaddps  ymm2,ymm0,ymm1              ;a + b
    vmovaps [edx],ymm2

    vsubps  ymm3,ymm0,ymm1              ;a - b
    vmovaps [edx+32],ymm3

    vmulps  ymm4,ymm0,ymm1              ;a * b
    vmovaps [edx+64],ymm4

    vdivps  ymm5,ymm0,ymm1              ;a / b
    vmovaps [edx+96],ymm5

; Compute packed SPFP absolute value
    vmovups ymm6,[AbsMask]              ;ymm6 = AbsMask
    vandps  ymm7,ymm0,ymm6              ;ymm7 = packed fabs
    vmovaps [edx+128],ymm7

; Compute packed SPFP negation
    vxorps  ymm7,ymm0,[NegMask]         ;ymm7 = packed neg.
    vmovaps [edx+160],ymm7

; Zero upper 128-bit of all YMM registers to avoid potential x86-AVX
; to x86-SSE transition penalties.
    vzeroupper

    pop     ebp
    ret

; extern "C" void AvxPfpArithmeticDouble_(const YmmVal* a, const YmmVal* b, YmmVal c[5]);
;
; Description:  The following function illustrates how to use common
;               packed DPFP arithmetic instructions using the YMM
;               registers.
;
; Requires:     AVX

%define a   [ebp+8]
%define b   [ebp+12]
%define c   [ebp+16]

AvxPfpArithmeticDouble:
    push    ebp
    mov     ebp,esp

; Load argument values.  Note that the vmovapd instruction
; requires proper aligment of operands in memory.
    mov     eax,a                       ;eax = ptr to a
    mov     ecx,b                       ;ecx = ptr to b
    mov     edx,c                       ;edx = ptr to c
    vmovapd ymm0,[eax]                  ;ymm0 = a
    vmovapd ymm1,[ecx]                  ;ymm1 = b

; Compute packed min, max and square root
    vminpd  ymm2,ymm0,ymm1
    vmaxpd  ymm3,ymm0,ymm1
    vsqrtpd ymm4,ymm0

; Perform horizontal addition and subtraction
    vhaddpd ymm5,ymm0,ymm1
    vhsubpd ymm6,ymm0,ymm1

; Save the results
    vmovapd [edx],ymm2
    vmovapd [edx+32],ymm3
    vmovapd [edx+64],ymm4
    vmovapd [edx+96],ymm5
    vmovapd [edx+128],ymm6

; Zero upper 128-bit of all YMM registers to avoid potential x86-AVX
; to x86-SSE transition penalties.
    vzeroupper

    pop     ebp
    ret
