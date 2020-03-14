; Name:     avxpackedintegerunpack.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o -std=c++11
;           nasm -f elf32 -o avxpackedintegerunpack.o avxpackedintegerunpack.asm
;           g++ -m32 -o avxpackedintegerunpack avxpackedintegerunpack.o main.o ../../commonfiles/ymmval.o
;
; Source:   Modern x86 Assembly Language Programming p. 412

global AvxPiUnpackDQ
global AvxPiPackDW

section .text

; extern "C" void AvxPiUnpackDQ(YmmVal* a, YmmVal* b, YmmVal c[2]);
;
; Description:  The following function demonstrates use of the
;               vpunpckldq and vpunpckhdq instructions using
;               256-bit wide operands.
;
; Requires:     AVX2

%define a   [ebp+8]
%define b   [ebp+12]
%define c   [ebp+16]

AvxPiUnpackDQ:
    push    ebp
    mov     ebp,esp

; Load argument values
    mov     eax,a                           ;eax = ptr to a
    mov     ecx,b                           ;ecx = ptr to b
    mov     edx,c                           ;edx = ptr to c
    vmovdqa ymm0,[eax]                      ;ymm0 = a
    vmovdqa ymm1,[ecx]                      ;ymm1 = b

; Perform dword to qword unpacks
    vpunpckldq ymm2,ymm0,ymm1           ;unpack low doublewords
    vpunpckhdq ymm3,ymm0,ymm1           ;unpack high doublewords
    vmovdqa    [edx],ymm2               ;save low result
    vmovdqa    [edx+32],ymm3            ;save high result

    vzeroupper
    pop     ebp
    ret

; extern "C" void AviPiPackDW(YmmVal* a, YmmVal* b, YmmVal* c);
;
; Description:  The following function demonstrates use of the
;               vpackssdw using 256-bit wide operands.
;
; Requires:     AVX2

%define a   [ebp+8]
%define b   [ebp+12]
%define c   [ebp+16]

AvxPiPackDW:
    push    ebp
    mov     ebp,esp

; Load argument values
    mov     eax,a                           ;eax = ptr to a
    mov     ecx,b                           ;ecx = ptr to b
    mov     edx,c                           ;edx = ptr to c
    vmovdqa ymm0,[eax]                      ;ymm0 = a
    vmovdqa ymm1,[ecx]                      ;ymm1 = b

; Perform pack dword to word with signed saturation
    vpackssdw ymm2,ymm0,ymm1                ;ymm2 = packed words
    vmovdqa   [edx],ymm2                    ;save result
    vzeroupper
    pop     ebp
    ret
