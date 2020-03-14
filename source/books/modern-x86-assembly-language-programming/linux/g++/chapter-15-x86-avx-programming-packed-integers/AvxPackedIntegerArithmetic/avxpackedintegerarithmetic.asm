; Name:     avxpackedintegerarithmetic.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o -std=c++11
;           nasm -f elf32 -o avxpackedintegerarithmetic.o avxpackedintegerarithmetic.asm
;           g++ -m32 -o avxpackedintegerarithmetic avxpackedintegerarithmetic.o main.o ../../commonfiles/ymmval.o
;
; Source:   Modern x86 Assembly Language Programming p. 406

global AvxPiI16
global AvxPiI32

section .text

; extern "C" void AvxPiI16(YmmVal* a, YmmVal* b, YmmVal c[6]);
;
; Description:  The following function illustrates use of various
;               packed 16-bit integer arithmetic instructions
;               using 256-bit wide operands.
;
; Requires:     AVX2

%define a   [ebp+8]
%define b   [ebp+12]
%define c   [ebp+16]

AvxPiI16:
    push    ebp
    mov     ebp,esp

; Load argument values
    mov     eax,a                    ;eax = ptr to a
    mov     ecx,b                    ;ecx = ptr to b
    mov     edx,c                    ;edx = ptr to c

; Load a and b, which must be properly aligned
    vmovdqa ymm0,[eax]               ;ymm0 = a
    vmovdqa ymm1,[ecx]               ;ymm1 = b

; Perform packed arithmetic operations
    vpaddw  ymm2,ymm0,ymm1           ;add
    vpaddsw ymm3,ymm0,ymm1           ;add with signed saturation
    vpsubw  ymm4,ymm0,ymm1           ;sub
    vpsubsw ymm5,ymm0,ymm1           ;sub with signed saturation
    vpminsw ymm6,ymm0,ymm1           ;signed minimums
    vpmaxsw ymm7,ymm0,ymm1           ;signed maximums

; Save results
    vmovdqa [edx],ymm2               ;save vpaddw result
    vmovdqa [edx+32],ymm3            ;save vpaddsw result
    vmovdqa [edx+64],ymm4            ;save vpsubw result
    vmovdqa [edx+96],ymm5            ;save vpsubsw result
    vmovdqa [edx+128],ymm6           ;save vpminsw result
    vmovdqa [edx+160],ymm7           ;save vpmaxsw result

    vzeroupper
    pop     ebp
    ret

; extern "C" void AvxPiI32(YmmVal* a, YmmVal* b, YmmVal c[5]);
;
; Description:  The following function illustrates use of various
;               packed 32-bit integer arithmetic instructions
;               using 256-bit wide operands.
;
; Requires:     AVX2

%define a   [ebp+8]
%define b   [ebp+12]
%define c   [ebp+16]

AvxPiI32:
    push ebp
    mov ebp,esp

; Load argument values
    mov     eax,a                    ;eax = ptr to a
    mov     ecx,b                    ;ecx = ptr to b
    mov     edx,c                    ;edx = ptr to c

; Load a and b, which must be properly aligned
    vmovdqa ymm0,[eax]               ;ymm0 = a
    vmovdqa ymm1,[ecx]               ;ymm1 = b

; Perform packed arithmetic operations
    vphaddd ymm2,ymm0,ymm1           ;horizontal add
    vphsubd ymm3,ymm0,ymm1           ;horizontal sub
    vpmulld ymm4,ymm0,ymm1           ;signed mul (low 32 bits)
    vpsllvd ymm5,ymm0,ymm1           ;shift left logical
    vpsravd ymm6,ymm0,ymm1           ;shift right arithmetic

; Save results
    vmovdqa [edx],ymm2               ;save vphaddd result
    vmovdqa [edx+32],ymm3            ;save vphsubd result
    vmovdqa [edx+64],ymm4            ;save vpmulld result
    vmovdqa [edx+96],ymm5            ;save vpsllvd result
    vmovdqa [edx+128],ymm6           ;save vpsravd result

    vzeroupper
    pop     ebp
    ret
