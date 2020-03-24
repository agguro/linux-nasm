; Name:     avxpackedfloatingpointcompare.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o
;           nasm -f elf32 -o avxpackedfloatingpointcompare.o avxpackedfloatingpointcompare.asm
;           g++ -m32 -o avxpackedfloatingpointcompare avxpackedfloatingpointcompare.o main.o ../../commonfiles/ymmval.o
;
; Source:   Modern x86 Assembly Language Programming p. 386

global AvxPfpCompare

section .text

; extern "C" void AvxPfpCompare_(const YmmVal* a, const YmmVal* b, YmmVal c[8]);
;
; Description:  The following function demonstrates use of the
;               x86-AVX compare instruction vcmppd.
;
; Requires:     AVX

%define a   [ebp+8]
%define b   [ebp+12]
%define c   [ebp+16]

AvxPfpCompare:
    push    ebp
    mov     ebp,esp

; Load argument values
    mov     eax,a               ;eax = ptr to a
    mov     ecx,b               ;ecx = ptr to b
    mov     edx,c               ;edx = ptr to c
    vmovapd ymm0,[eax]          ;ymm0 = a
    vmovapd ymm1,[ecx]          ;ymm1 = b

; Compare for equality
    vcmpeqpd ymm2,ymm0,ymm1
    vmovapd  [edx],ymm2

; Compare for inequality
    vcmpneqpd ymm2,ymm0,ymm1
    vmovapd   [edx+32],ymm2

; Compare for less than
    vcmpltpd ymm2,ymm0,ymm1
    vmovapd  [edx+64],ymm2

; Compare for less than or equal
    vcmplepd ymm2,ymm0,ymm1
    vmovapd  [edx+96],ymm2

; Compare for greater than
    vcmpgtpd ymm2,ymm0,ymm1
    vmovapd  [edx+128],ymm2

; Compare for greater than or equal
    vcmpgepd ymm2,ymm0,ymm1
    vmovapd  [edx+160],ymm2

; Compare for ordered
    vcmpordpd ymm2,ymm0,ymm1
    vmovapd   [edx+192],ymm2

; Compare for unordered
    vcmpunordpd ymm2,ymm0,ymm1
    vmovapd     [edx+224],ymm2

; Zero upper 128-bit of all YMM registers to avoid potential x86-AVX
; to x86-SSE transition penalties.
    vzeroupper
    pop     ebp
    ret
