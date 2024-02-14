;name        : calcmeanstdev.asm
;description : MXCSR.RC rounding mode example
;source      : Modern X86 Assembly Language Programming 2nd Edition
;build       : mkdir build && cd build && qmake .. && make
;use         : extern "C" bool CalcMeanStdev_(double* mean, double* stdev, const double* a, int n);
;              returns:      0 = invalid n, 1 = valid n

bits 64

%define real8 qword

global CalcMeanStdev_

section .text

CalcMeanStdev_:
; in : rdi = mean ptr
;      rsi = stdev
;      rdx = a ptr
;      ecx = n

; Make sure 'n' is valid
    xor     eax,eax                     ;set error return code (also i = 0)
    cmp     ecx,2
    jl      InvalidArg                  ;jump if n < 2

; Compute sample mean
    vxorpd  xmm0,xmm0,xmm0              ;sum = 0.0

.loop1:
    vaddsd  xmm0,xmm0,real8 [rdx+rax*8] ;sum += x[i]
    inc     eax                         ;i += 1
    cmp     eax,ecx
    jl      .loop1                      ;jump if i < n

    vcvtsi2sd   xmm1,xmm1,ecx           ;convert n to DPFP
    vdivsd      xmm3,xmm0,xmm1          ;xmm3 = mean (sum / n)
    vmovsd      real8 [rdi],xmm3        ;save mean

; Compute sample stdev
    xor     eax,eax                     ;i = 0
    vxorpd  xmm0,xmm0,xmm0              ;sum2 = 0.0

.loop2:
    vmovsd  xmm1,real8 [rdx+rax*8]      ;xmm1 = x[i]
    vsubsd  xmm2,xmm1,xmm3              ;xmm2 = x[i] - mean
    vmulsd  xmm2,xmm2,xmm2              ;xmm2 = (x[i] - mean) ** 2
    vaddsd  xmm0,xmm0,xmm2              ;sum2 += (x[i] - mean) ** 2
    inc     eax                         ;i += 1
    cmp     eax,ecx
    jl      .loop2                      ;jump if i < n

    dec     ecx                         ;ecx = n - 1
    vcvtsi2sd   xmm1,xmm1,ecx           ;convert n - 1 to DPFP
    vdivsd  xmm0,xmm0,xmm1              ;xmm0 = sum2 / (n - 1)
    vsqrtsd xmm0,xmm0,xmm0              ;xmm0 = stdev
    vmovsd  real8 [rsi],xmm0            ;save stdev

    mov eax,1                           ;set success return code

InvalidArg:
    ret
