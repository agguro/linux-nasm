; Name:     avxscalarfloatingpointquadequ.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o
;           nasm -f elf32 -o avxscalarfloatingpointquadequ.o avxscalarfloatingpointquadequ.asm
;           g++ -m32 -o avxscalarfloatingpointquadequ avxscalarfloatingpointquadequ.o main.o
;
; Source:   Modern x86 Assembly Language Programming p. 361

global AvxSfpQuadEqu

section .data
align 16

    FpNegateMask:    dq 8000000000000000h,0   ;mask to negate DPFP value
    FpAbsMask:       dq 7FFFFFFFFFFFFFFFh,-1  ;mask to compute fabs()
    r8_0p0:          dq 0.0
    r8_2p0:          dq 2.0
    r8_4p0:          dq 4.0

section .text


; extern "C" void AvxSfpQuadEqu(const double coef[3], double roots[2], double epsilon, int* dis);
;
; Description:  The following function calculates the roots of a
;               quadratic equation using the quadratic formula.
;
; Requires:     AVX

%define coef    [ebp+8]
%define roots   [ebp+12]
%define epsilon [ebp+16]
%define dis     [ebp+24]

AvxSfpQuadEqu:
    push    ebp
    mov     ebp,esp

; Load argument values
    mov     eax,coef                    ;eax = ptr to coeff array
    mov     ecx,roots                   ;ecx = ptr to roots array
    mov     edx,dis                     ;edx = ptr to dis
    vmovsd  xmm0,[eax]                  ;xmm0 = a
    vmovsd  xmm1,[eax+8]                ;xmm1 = b
    vmovsd  xmm2,[eax+16]               ;xmm2 = c
    vmovsd  xmm7,epsilon                ;xmm7 = epsilon

; Make sure coefficient a is valid
    vandpd  xmm6,xmm0,[FpAbsMask]       ;xmm2 = fabs(a)
    vcomisd xmm6,xmm7
    jb      .error                      ;jump if fabs(a) < epsilon

; Compute intermediate values
    vmulsd  xmm3,xmm1,xmm1              ;xmm3 = b * b
    vmulsd  xmm4,xmm0,[r8_4p0]          ;xmm4 = 4 * a
    vmulsd  xmm4,xmm4,xmm2              ;xmm4 = 4 * a * c
    vsubsd  xmm3,xmm3,xmm4              ;xmm3 = b * b - 4 * a * c
    vmulsd  xmm0,xmm0,[r8_2p0]          ;xmm0 = 2 * a
    vxorpd  xmm1,xmm1,[FpNegateMask]    ;xmm1 = -b

; Test delta to determine root type
    vandpd  xmm2,xmm3,[FpAbsMask]       ;xmm2 = fabs(delta)
    vcomisd xmm2,xmm7
    jb      .identicalRoots             ;jump if fabs(delta) < epsilon
    vcomisd xmm3,[r8_0p0]
    jb      .complexRoots               ;jump if delta < 0.0

; Distinct real roots
; r1 = (-b + sqrt(delta)) / 2 * a, r2 = (-b - sqrt(delta)) / 2 * a
    vsqrtsd xmm3,xmm3,xmm3              ;xmm3 = sqrt(delta)
    vaddsd  xmm4,xmm1,xmm3              ;xmm4 = -b + sqrt(delta)
    vsubsd  xmm5,xmm1,xmm3              ;xmm5 = -b - sqrt(delta)
    vdivsd  xmm4,xmm4,xmm0              ;xmm4 = final r1
    vdivsd  xmm5,xmm5,xmm0              ;xmm5 = final r2
    vmovsd  [ecx],xmm4                  ;save r1
    vmovsd  [ecx+8],xmm5                ;save r2
    mov     dword[edx],1                ;*dis = 1
    jmp     .done

; Identical roots
; r1 = r2 = -b / 2 * a
.identicalRoots:
    vdivsd  xmm4,xmm1,xmm0              ;xmm4 = -b / 2 * a
    vmovsd  [ecx],xmm4                  ;save r1
    vmovsd  [ecx+8],xmm4                ;save r2
    mov     dword[edx],0                ;*dis = 0
    jmp     .done

; Complex roots
;  real = -b / 2 * a, imag = sqrt(-delta) / 2 * a
;  final roots: r1 = (real, imag), r2 = (real, -imag)
.complexRoots:
    vdivsd  xmm4,xmm1,xmm0              ;xmm4 = -b / 2 * a
    vxorpd  xmm3,xmm3,[FpNegateMask]    ;xmm3 = -delta
    vsqrtsd xmm3,xmm3,xmm3              ;xmm3 = sqrt(-delta)
    vdivsd  xmm5,xmm3,xmm0              ;xmm5 = sqrt(-delta) / 2 * a
    vmovsd  [ecx],xmm4                  ;save real part
    vmovsd  [ecx+8],xmm5                ;save imaginary part
    mov     dword[edx],-1               ;*dis = -1

.done:
    pop     ebp
    ret

.error:
    mov     dword[edx],9999              ;*dis = 9999 (error code)
    pop     ebp
    ret
