;name        : celsius2fahrenheit.asm
;description : Temperature conversion Fahrenheit - Celsius
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" float ConvertFtoC_(float deg_f);
;              returns: xmm0[31:0] = temperature in Celsius.
;              extern "C" float ConvertCtoF_(float deg_c);
;              returns: xmm0[31:0] = temperature in Fahrenheit.

bits 64

%define float dd

global ConvertCtoF_
global ConvertFtoC_

section .rodata
    r4_5p0:     float 5.0
    r4_9p0:     float 9.0
    r4_32p0:    float 32.0

section .text

ConvertCtoF_:
; in : xmm0 : degrees Celsius
; out : xmm0 : degrees Fahrenheit

    vmulss  xmm0,xmm0,[r4_9p0]
    vdivss  xmm0,xmm0,[r4_5p0]
    vaddss  xmm0,xmm0,[r4_32p0]          ;xmm0 = c * 9 / 5 + 32
    ret

ConvertFtoC_:
; in : xmm0 : degrees Fahrenheit
; out : xmm0 : degrees Celsius

    vsubss  xmm0,xmm0,[r4_32p0]
    vdivss  xmm0,xmm0,[r4_9p0]
    vmulss  xmm0,xmm0,[r4_5p0]               ;xmm0 = (f - 32) * 5 / 9
    ret
