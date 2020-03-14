; Name:     avxfloatingpointcompare.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o
;           nasm -f elf32 -o avxfloatingpointcompare.o avxfloatingpointcompare.asm
;           g++ -m32 -o avxfloatingpointcompare avxfloatingpointcompare.o main.o
;
; Source:   Modern x86 Assembly Language Programming p. 355

global AvxSfpCompare

section .text

; extern "C" void AvxSfpCompare(double a, double b, bool results[8]);
;
; Description:  The following function demonstrates use of the
;               x86-AVX compare instruction vcmpsd.
;
; Requires:     AVX

%define a       [ebp+8]
%define b       [ebp+16]
%define results [ebp+24]

AvxSfpCompare:
    push    ebp
    mov     ebp,esp

; Load argument values
    vmovsd  xmm0,a       ;xmm0 = a
    vmovsd  xmm1,b      ;xmm1 = b;
    mov     eax,results                    ;eax= ptr to results array

; Perform compare for equality
    vcmpeqsd  xmm2,xmm0,xmm1             ;perform compare operation
    vmovmskpd ecx,xmm2                  ;move result to bit 0 of ecx
    test      ecx,1                          ;test bit result
    setnz     byte[eax+0]              ;save result as C++ bool

; Perform compare for inequality.  Note that vcmpneqsd returns true
; if used with QNaN or SNaN operand values.
    vcmpneqsd xmm2,xmm0,xmm1
    vmovmskpd ecx,xmm2
    test      ecx,1
    setnz byte[eax+1]

; Perform compare for less than
    vcmpltsd xmm2,xmm0,xmm1
    vmovmskpd ecx,xmm2
    test ecx,1
    setnz byte[eax+2]

; Perform compare for less than or equal
    vcmplesd xmm2,xmm0,xmm1
    vmovmskpd ecx,xmm2
    test ecx,1
    setnz byte[eax+3]

; Perform compare for greater than
    vcmpgtsd xmm2,xmm0,xmm1
    vmovmskpd ecx,xmm2
    test ecx,1
    setnz byte[eax+4]

; Perform compare for greater than or equal
    vcmpgesd xmm2,xmm0,xmm1
    vmovmskpd ecx,xmm2
    test ecx,1
    setnz byte[eax+5]

; Perform compare for ordered
    vcmpordsd xmm2,xmm0,xmm1
    vmovmskpd ecx,xmm2
    test ecx,1
    setnz byte[eax+6]

; Perform compare for unordered
    vcmpunordsd xmm2,xmm0,xmm1
    vmovmskpd ecx,xmm2
    test ecx,1
    setnz byte[eax+7]

    pop ebp
    ret
