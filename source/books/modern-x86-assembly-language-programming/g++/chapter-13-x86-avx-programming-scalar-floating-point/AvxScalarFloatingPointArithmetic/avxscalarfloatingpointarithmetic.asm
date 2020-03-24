; Name:     avxscalarfloatingpointarithmetic.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o
;           nasm -f elf32 -o avxscalarfloatingpointarithmetic.o avxscalarfloatingpointarithmetic.asm
;           g++ -m32 -o avxscalarfloatingpointarithmetic avxscalarfloatingpointarithmetic.o main.o
;
; Source:   Modern x86 Assembly Language Programming p. 352

global AvxSfpArithmetic

section .data
align 16
	AbsMask: dq 0x7fffffffffffffff, 0x7fffffffffffffff

section .text

; extern "C" void AvxSfpArithmetic(double a, double b, double results[8]);
;
; Description:  The following function demonstrates how to use basic
;               scalar DPFP arithmetic instructions.
;
; Requires:     AVX

%define a       [ebp+8]
%define b       [ebp+16]
%define results [ebp+24]

AvxSfpArithmetic:
    push    ebp
    mov     ebp,esp

; Load argument values
    mov     eax,results                 ;eax = ptr to results array
    vmovsd  xmm0,a                      ;xmm0 = a
    vmovsd  xmm1,b                      ;xmm1 = b

; Perform basic arithmetic using AVX scalar DPFP instructions
    vaddsd  xmm2,xmm0,xmm1              ;xmm2 = a + b
    vsubsd  xmm3,xmm0,xmm1              ;xmm3 = a - b
    vmulsd  xmm4,xmm0,xmm1              ;xmm4 - a * b
    vdivsd  xmm5,xmm0,xmm1              ;xmm5 = a / b
    vmovsd  [eax+0],xmm2                ;save a + b
    vmovsd  [eax+8],xmm3                ;save a - b
    vmovsd  [eax+16],xmm4               ;save a * b
    vmovsd  [eax+24],xmm5               ;save a / b

; Compute min(a, b), max(a, b), sqrt(a) and fabs(b)
    vminsd  xmm2,xmm0,xmm1              ;xmm2 = min(a, b)
    vmaxsd  xmm3,xmm0,xmm1              ;xmm3 = max(a, b)
    vsqrtsd xmm4,xmm0,xmm0              ;xmm4 = sqrt(a)
    vandpd  xmm5,xmm1,[AbsMask]         ;xmm5 = fabs(b)
    vmovsd  [eax+32],xmm2               ;save min(a, b)
    vmovsd  [eax+40],xmm3               ;save max(a, b)
    vmovsd  [eax+48],xmm4               ;save sqrt(a)
    vmovsd  [eax+56],xmm5               ;save trunc(sqrt(a))

    pop     ebp
    ret
