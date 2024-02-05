; Name:		avxblend.asm
;
; Build:	g++ -c -m32 main.cpp -o main.o
;			nasm -f elf32 -o avxblend.o avxblend.asm
;			g++ -m32 -o avxblend avxblend.o main.o
;
; Source:	Modern x86 Assembly Language Programming p. 453

global AvxBlendFloat
global AvxBlendByte

section .text

; extern "C" void AvxBlendFloat(YmmVal* des, YmmVal* src1, YmmVal* src2, YmmVal* src3);
;
; Description:  The following function demonstrates used of the vblendvps
;               instruction using YMM registers.
;
; Requires:     AVX

%define des  [ebp+8]
%define src1 [ebp+12]
%define src3 [ebp+16]
%define src2 [ebp+20]

AvxBlendFloat:
    push      ebp
    mov       ebp,esp

; Load argument values
    mov       eax,src1                  ;eax = ptr to src1
    mov       ecx,src2                  ;ecx = ptr to src2
    mov       edx,src3                  ;edx = ptr to src3

    vmovaps   ymm1,[eax]                ;ymm1 = src1
    vmovaps   ymm2,[ecx]                ;ymm2 = src2
    vmovdqa   ymm3,[edx]                ;ymm3 = src3

; Perform variable SPFP blend
    vblendvps ymm0,ymm1,ymm2,ymm3       ;ymm0 = blend result
    mov       eax,[ebp+8]
    vmovaps   [eax],ymm0                ;save blend result

    vzeroupper
    pop       ebp
    ret

; extern "C" void AvxBlendByte(YmmVal* des, YmmVal* src1, YmmVal* src2, YmmVal* src3);
;
; Description:  The following function demonstrates use of the vpblendvb
;               instruction.
;
; Requires:     AVX2

%define des  [ebp+8]
%define src1 [ebp+12]
%define src3 [ebp+16]
%define src2 [ebp+20]

AvxBlendByte:
    push    ebp
    mov     ebp,esp

; Load argument values
    mov     eax,src1                    ;eax = ptr to src1
    mov     ecx,src2                    ;ecx = ptr to src2
    mov     edx,src3                    ;edx = ptr to src3

    vmovdqa   ymm1,[eax]                ;ymm1 = src1
    vmovdqa   ymm2,[ecx]                ;ymm2 = src2
    vmovdqa   ymm3,[edx]                ;ymm3 = src3

; Perform variable byte blend
    vpblendvb ymm0,ymm1,ymm2,ymm3       ;ymm0 = blend result
    mov       eax,des
    vmovdqa   [eax],ymm0                ;save blend result
    vzeroupper
    pop       ebp
    ret
