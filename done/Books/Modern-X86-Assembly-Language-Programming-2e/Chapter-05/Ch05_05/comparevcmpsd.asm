;name        : comparevcmpsd.asm
;description : Compare 2 Scalar Double-Precision Floating-Point Values
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" void CompareVCMPSD_(double a, double b, bool* results)

%include "cmpequ.inc"

global CompareVCMPSD_

section .text

CompareVCMPSD_:
; in : xmm0 = a
;      xmm1 = b
;      rdi = results ptr
; out : rdi contains results as boolean values

; Perform compare for equality
    vcmpsd  xmm2,xmm0,xmm1,CMP_EQ       ;perform compare operation
    vmovq   rax,xmm2                    ;rax = compare result (all 1s or 0s)
    and     al,1                        ;mask out unneeded bits
    mov     byte [rdi],al               ;save result as C++ bool

; Perform compare for inequality
    vcmpsd  xmm2,xmm0,xmm1,CMP_NEQ
    vmovq   rax,xmm2
    and     al,1
    mov     byte [rdi+1],al

; Perform compare for less than
    vcmpsd  xmm2,xmm0,xmm1,CMP_LT
    vmovq   rax,xmm2
    and     al,1
    mov     byte [rdi+2],al

; Perform compare for less than or equal
    vcmpsd  xmm2,xmm0,xmm1,CMP_LE
    vmovq   rax,xmm2
    and     al,1
    mov     byte [rdi+3],al

; Perform compare for greater than
    vcmpsd  xmm2,xmm0,xmm1,CMP_GT
    vmovq   rax,xmm2
    and     al,1
    mov     byte [rdi+4],al

; Perform compare for greater than or equal
    vcmpsd  xmm2,xmm0,xmm1,CMP_GE
    vmovq   rax,xmm2
    and     al,1
    mov     byte [rdi+5],al

; Perform compare for ordered
    vcmpsd  xmm2,xmm0,xmm1,CMP_ORD
    vmovq   rax,xmm2
    and     al,1
    mov     byte [rdi+6],al

; Perform compare for unordered
    vcmpsd  xmm2,xmm0,xmm1,CMP_UNORD
    vmovq   rax,xmm2
    and     al,1
    mov     byte [rdi+7],al

    ret
