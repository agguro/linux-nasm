; Name:         floatingpointarithmetic_.asm
;
; Source:       Modern x86 Assembly Language Programming p.519

global CalcSum_
global CalcDist_

section .text

; extern "C" double CalcSum_(float a, double b, float c, double d, float e, double f);
;
; Description:  The following function demonstrates how to access
;               floating-point argument values in an x86-64 function.

CalcSum_:
    ; registers: xmm0 = a
    ;            xmm1 = b
    ;            xmm2 = c
    ;            xmm3 = d
    ;            xmm4 = e
    ;            xmm5 = f
    ; Sum the argument values
    cvtss2sd xmm0,xmm0                  ;promote a to DPFP
    addsd    xmm0,xmm1                  ;xmm0 = a + b
    cvtss2sd xmm2,xmm2                  ;promote c to DPFP
    addsd    xmm0,xmm2                  ;xmm0 = a + b + c
    addsd    xmm0,xmm3                  ;xmm0 = a + b + c + d
    cvtss2sd xmm4,xmm4                  ;promote e to DPFP
    addsd    xmm0,xmm4                  ;xmm0 = a + b + c + d + e
    addsd    xmm0,xmm5                  ;xmm0 =  a + b + c + d + e + f
    ret

; extern "C" double CalcDist(int x1, double x2, long long y1, double y2, float z1, short z2);
;
; Description:  The following function demonstrates how to access mixed
;               floating-point and integer arguments values in an
;               x86-64 function.

CalcDist_:
    ; registers: edi  = x1
    ;            xmm0 = x2
    ;            rsi  = y1
    ;            xmm1 = y2
    ;            xmm2 = z1
    ;            dl   = z2  (in reality z2 is stored in edx)
    ; Calculate xd = (x2 - x1) * (x2 - x1)
    cvtsi2sd xmm3,edi                   ;convert x1 to DPFP
    subsd    xmm0,xmm3                  ;xmm0 = x2 - x1
    mulsd    xmm0,xmm0                  ;xmm0 = xd

    ; Calculate yd = (y2 - y1) * (y2 - y1)
    cvtsi2sd xmm4,rsi                   ;convert y1 to DPFP
    subsd    xmm1,xmm4                  ;xmm1 = y2 - y1
    mulsd    xmm1,xmm1                  ;xmm1 = yd

    ; Calculate zd = (z2 - z1) * (z2 - z1)
    ;movss xmm0,real4 ptr [rsp+40]      ;xmm=0  = z1
    cvtss2sd xmm3,xmm2                  ;convert z1 to DPFP
    movsx    eax,dl                     ;eax = sign-extend z2
    cvtsi2sd xmm2,eax                   ;convert z2 to DPFP
    subsd    xmm2,xmm3                  ;xmm2 = z2 - z1
    mulsd    xmm2,xmm2                  ;xmm2 = zd

    ; Calculate final distance sqrt(xd + yd + zd)
    addsd    xmm0,xmm1                  ;xmm0 = xd + yd
    addsd    xmm0,xmm2                  ;xmm0 = xd + yd + zd
    sqrtsd   xmm0,xmm0                  ;xmm0 = sqrt(xd + yd + zd)
    ret
