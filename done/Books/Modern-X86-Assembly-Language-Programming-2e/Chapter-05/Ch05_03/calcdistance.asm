;name        : calcdistance.asm
;description : Calculates the distance of two three-dimensional point (x1,y1,z1) and (x2,y2,z2)
;              the distance is defined as sqrt((x2-x1)²+(y2-y1)²+(z2-z1)²)
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" double CalcDistance_(double x1, double y1, double z1, double x2, double y2, double z2)

bits 64

global CalcDistance_

section .text

CalcDistance_:
; in : xmm0 = x1
;      xmm1 = y1
;      xmm2 = z1
;      xmm3 = x2
;      xmm4 = y2
;      xmm5 = z2
; out : xmm0 = distance between the 2 points

; Calculate squares of coordinate distances
    vsubsd  xmm0,xmm3,xmm0      ;xmm0 = x2 - x1
    vmulsd  xmm0,xmm0,xmm0      ;xmm0 = (x2 - x1) * (x2 - x1)

    vsubsd  xmm1,xmm4,xmm1      ;xmm1 = y2 - y1
    vmulsd  xmm1,xmm1,xmm1      ;xmm1 = (y2 - y1) * (y2 - y1)

    vsubsd  xmm2,xmm5,xmm2      ;xmm2 = z2 - z1
    vmulsd  xmm2,xmm2,xmm2      ;xmm2 = (z2 - z1) * (z2 - z1)

; Calculate final distance
    vaddsd  xmm3,xmm0,xmm1
    vaddsd  xmm4,xmm2,xmm3      ;xmm4 = sum of squares
    vsqrtsd xmm0,xmm0,xmm4      ;xmm0 = final distance value
    ret
