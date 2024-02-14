;name        : calcsphereareavolume.asm
;description : Calculates the area and volume of a sphere
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" void CalcSphereAreaVolume_(double r, double* sa, double* vol);

bits 64

%define real8       dq
%define real8ptr    qword

global CalcSphereAreaVolume_

section .rodata

    r8_PI   real8 3.14159265358979323846
    r8_4p0  real8 4.0
    r8_3p0  real8 3.0

section .text

CalcSphereAreaVolume_:
; in : xmm0 = r
; out : sa = surface area
;       vol = volume

; Calculate surface area = 4 * PI * r * r
    vmulsd  xmm1,xmm0,xmm0          ;xmm1 = r * r
    vmulsd  xmm2,xmm1,[r8_PI]       ;xmm2 = r * r * PI
    vmulsd  xmm3,xmm2,[r8_4p0]      ;xmm3 = r * r * PI * 4

; Calculate volume = sa * r / 3
    vmulsd  xmm4,xmm3,xmm0          ;xmm4 = r * r * r * PI * 4
    vdivsd  xmm5,xmm4,[r8_3p0]      ;xmm5 = r * r * r * PI * 4 / 3

; Save results
    vmovsd  real8ptr [rdi],xmm3        ;save surface area
    vmovsd  real8ptr [rsi],xmm5         ;save volume
    ret
