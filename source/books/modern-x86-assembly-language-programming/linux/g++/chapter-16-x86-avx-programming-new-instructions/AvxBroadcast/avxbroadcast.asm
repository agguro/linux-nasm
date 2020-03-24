; Name:     avxbroadcast.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o
;           nasm -f elf32 -o avxbroadcast.o avxbroadcast.asm
;           g++ -m32 -o avxbroadcast avxbroadcast.o main.o
;
; Source:   Modern x86 Assembly Language Programming p. 447

global AvxBroadcastIntegerYmm
global AvxBroadcastFloat
global AvxBroadcastDouble

section .data
; The order of values in the following table must match the enum Brop
; that's defined in AvxBroadcast.cpp.

align 4
    BropTable dd AvxBroadcastIntegerYmm.bropByte
              dd AvxBroadcastIntegerYmm.bropWord
              dd AvxBroadcastIntegerYmm.bropDword
              dd AvxBroadcastIntegerYmm.bropQword
    BropTableCount equ ($ - BropTable) / 4			; 4 = size of dword in bytes

section .text

; extern "C" void AvxBroadcastIntegerYmm(YmmVal* des, const XmmVal* src, Brop op);
;
; Description:  The following function demonstrates use of the
;               vpbroadcastX instruction.
;
; Requires:     AVX2

%define des [ebp+8]
%define op  [ebp+16]
%define src [ebp+12]

AvxBroadcastIntegerYmm:
    push    ebp
    mov     ebp,esp

; Make sure op is valid
    mov     eax,op                      ;eax = op
    cmp     eax,BropTableCount
    jae     .badOp                      ;jump if op is invalid

; Load parameters and jump to specified instruction
    mov     ecx,des                     ;ecx = des
    mov     edx,src                     ;edx = src
    vmovdqa xmm0,[edx]  ;xmm0 = broadcast value (low item)
    mov     edx,[BropTable+eax*4]
    jmp     edx

; Perform byte broadcast
.bropByte:
    vpbroadcastb ymm1,xmm0
    vmovdqa      [ecx],ymm1
    vzeroupper
    pop     ebp
    ret

; Perform word broadcast
.bropWord:
    vpbroadcastw ymm1,xmm0
    vmovdqa      [ecx],ymm1
    vzeroupper
    pop     ebp
    ret

; Perform dword broadcast
.bropDword:
    vpbroadcastd ymm1,xmm0
    vmovdqa      [ecx],ymm1
    vzeroupper
    pop     ebp
    ret

; Perform qword broadcast
.bropQword:
    vpbroadcastq ymm1,xmm0
    vmovdqa      [ecx],ymm1
    vzeroupper
    pop     ebp
    ret
.badOp:
    pop     ebp
    ret

; extern "C" void AvxBroadcastFloat(YmmVal* des, float val);
;
; Description:  The following function demonstrates use of the
;               vbroadcastss instruction.
;
; Requires:     AVX

%define des [ebp+12]
%define val [ebp+8]

AvxBroadcastFloat:
    push    ebp
    mov     ebp,esp
; Broadcast val to all elements of des
    mov     eax,val
    vbroadcastss ymm0,dword des
    vmovaps      [eax],ymm0
    vzeroupper
    pop     ebp
    ret

; extern "C" void AvxBroadcastDouble(YmmVal* des, double val);
;
; Description:  The following function demonstrates use of the
;               vbroadcastsd instruction.
;
; Requires:     AVX

%define des [ebp+12]
%define val [ebp+8]

AvxBroadcastDouble:
    push    ebp
    mov     ebp,esp
; Broadcast val to all elements of des.
    mov     eax,val
    vbroadcastsd ymm0,qword des
    vmovapd      [eax],ymm0
    vzeroupper
    pop     ebp
    ret
