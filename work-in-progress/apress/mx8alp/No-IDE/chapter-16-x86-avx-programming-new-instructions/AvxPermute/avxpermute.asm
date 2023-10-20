; Name:     avxpermute.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o
;           nasm -f elf32 -o avxpermute.o avxpermute.asm
;           g++ -m32 -o avxpermute avxpermute.o main.o
;
; Source:   Modern x86 Assembly Language Programming p. 458

global AvxPermuteInt32
global AvxPermuteFloat
global AvxPermuteFloatIl

section .text

; extern "C" void AvxPermuteInt32(YmmVal* des, YmmVal* src, YmmVal* ind);
;
; Description:  The following function demonstrates use of the
;               vpermd instruction.
;
; Requires:     AVX2

%define des [ebp+8]
%define src [ebp+12]
%define ind [ebp+16]

AvxPermuteInt32:
    push    ebp
    mov     ebp,esp

; Load argument values
    mov     eax,des                    ;eax = ptr to des
    mov     ecx,src                    ;ecx = ptr to src
    mov     edx,ind                    ;edx = ptr to ind

; Perform dword permutation
    vmovdqa ymm1,[edx]                 ;ymm1 = ind
    vpermd  ymm0,ymm1,[ecx]
    vmovdqa [eax],ymm0                 ;save result
    vzeroupper
    pop     ebp
    ret

; extern "C" void AvxPermuteFloat(YmmVal* des, YmmVal* src, YmmVal* ind);
;
; Description:  The following function demonstrates use of the 
;               vpermps instruction.
;
; Requires:     AVX2

%define des [ebp+8]
%define src [ebp+12]
%define ind [ebp+16]

AvxPermuteFloat:
    push    ebp
    mov     ebp,esp

; Load argument values
    mov     eax,des                    ;eax = ptr to des
    mov     ecx,src                    ;ecx = ptr to src
    mov     edx,ind                    ;edx = ptr to ind

; Perform SPFP permutation
    vmovdqa ymm1,[edx]                 ;ymm1 = ind
    vpermps ymm0,ymm1,[ecx]
    vmovaps [eax],ymm0                 ;save result

    vzeroupper
    pop     ebp
    ret

; extern "C" void AvxPermuteFloatIl(YmmVal* des, YmmVal* src, YmmVal* ind);
;
; Description:  The following function demonstrates use of the 
;               vpermilps instruction.
;
; Requires:     AVX2

%define des [ebp+8]
%define src [ebp+12]
%define ind [ebp+16]

AvxPermuteFloatIl:
    push    ebp
    mov     ebp,esp

; Load argument values
    mov     eax,des                    ;eax = ptr to des
    mov     ecx,src                    ;ecx = ptr to src
    mov     edx,ind                    ;edx = ptr to ind

; Perform in-lane SPFP permutation.  Note that the second source
; operand of vpermilps specifies the indices.
    vmovdqa   ymm1,[ecx]               ;ymm1 = src
    vpermilps ymm0,ymm1,[edx]
    vmovaps   [eax],ymm0               ;save result

    vzeroupper
    pop     ebp
    ret
