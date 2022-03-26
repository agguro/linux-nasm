; Name:     avxgather.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o
;           nasm -f elf32 -o avxgather.o avxgather.asm
;           g++ -m32 -o avxgather avxgather.o main.o
;
; Source:   Modern x86 Assembly Language Programming p. 463

global AvxGatherFloat
global AvxGatherI64

section .text

; extern "C" void AvxGatherFloat(YmmVal* des, YmmVal* indices, YmmVal* mask, const float* x);
;
; Description:  The following function demonstrates use of the
;               vgatherdps instruction.
;
; Requires:     AVX2

%define des     [ebp+8]
%define indices [ebp+12]
%define mask    [ebp+16]
%define x       [ebp+20]

AvxGatherFloat:
    push    ebp
    mov     ebp,esp
    push    ebx

; Load argument values. The contents of des are loaded into ymm0
; prior to execution of the vgatherdps instruction in order to
; demonstrate the conditional effects of the control mask.
    mov        eax,des                         ;eax = ptr to des
    mov        ebx,indices                     ;ebx = ptr to indices
    mov        ecx,mask                        ;ecx = ptr to mask
    mov        edx,x                           ;edx = ptr to x
    vmovaps    ymm0,[eax]                      ;ymm0 = des (initial values)
    vmovdqa    ymm1,[ebx]                      ;ymm1 = indices
    vmovdqa    ymm2,[ecx]                      ;ymm2 = mask

; Perform the gather operation and save the results.
    vgatherdps ymm0,[edx+ymm1*4],ymm2          ;ymm0 = gathered elements
    vmovaps    [eax],ymm0                      ;save des
    vmovdqa    [ebx],ymm1                      ;save indices (unchanged)
    vmovdqa    [ecx],ymm2                      ;save mask (all zeros)

    vzeroupper
    pop     ebx
    pop     ebp
    ret

; extern "C" void AvxGatherI64(YmmVal* des, XmmVal* indices, YmmVal* mask, const Int64* x);
;
; Description:  The following function demonstrates use of the vpgatherdq
;               instruction.
;
; Requires:     AVX2

%define des     [ebp+8]
%define indices [ebp+12]
%define mask    [ebp+16]
%define x       [ebp+20]

AvxGatherI64:
    push    ebp
    mov     ebp,esp
    push    ebx

; Load argument values. Note that the indices are loaded
; into register XMM1.
    mov        eax,des                         ;eax = ptr to des
    mov        ebx,indices                     ;ebx = ptr to indices
    mov        ecx,mask                        ;ecx = ptr to mask
    mov        edx,x                           ;edx = ptr to x
    vmovdqa    ymm0,[eax]                      ;ymm0 = des (initial values)
    vmovdqa    xmm1,[ebx]                      ;xmm1 = indices
    vmovdqa    ymm2,[ecx]                      ;ymm2 = mask

; Perform the gather and save the results.  Note that the
; scale factor matches the size of the gathered elements.
    vpgatherdq ymm0,[edx+xmm1*8],ymm2          ;ymm0 = gathered elements
    vmovdqa    [eax],ymm0                      ;save des
    vmovdqa    [ebx],xmm1                      ;save indices (unchanged)
    vmovdqa    [ecx],ymm2                      ;save mask (all zeros)

    vzeroupper
    pop     ebx
    pop     ebp
    ret
