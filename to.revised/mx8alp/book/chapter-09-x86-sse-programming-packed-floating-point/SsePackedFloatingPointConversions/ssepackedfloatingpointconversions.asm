; Name:     ssepackedfloatingpointconversions.asm
;
; Build:    g++ -c -m32 main.cpp -o main.o -std=c++11
;           nasm -f elf32 -o ssepackedfloatingpointconversions.o ssepackedfloatingpointconversions.asm
;           g++ -m32 -o ssepackedfloatingpointconversions ssepackedfloatingpointconversions.o main.o ../../commonfiles/xmmval.o
;
; Source:   Modern x86 Assembly Language Programming p. 249

global	SsePfpConvert

section .data
; The order of values in the following table must match the enum CvtOp
; that's defined in SsePackedFloatingPointConversions.cpp.
align 4

CvtOpTable: dd SsePfpConvert.sseCvtdq2ps
            dd SsePfpConvert.sseCvtdq2pd
            dd SsePfpConvert.sseCvtps2dq
            dd SsePfpConvert.sseCvtpd2dq
            dd SsePfpConvert.sseCvtps2pd
            dd SsePfpConvert.sseCvtpd2ps

CvtOpTableCount: equ ($ - CvtOpTable) / 4  ; size dword = 4

section .text

; extern "C" void SsePfpConvert(const XmmVal* a, XmmVal* b, CvtOp cvt_op);
;
; Description:  The following function demonstrates use of the packed
;               floating-point conversion instructions.
;
; Requires:     SSE2

SsePfpConvert:
        push     ebp
        mov      ebp,esp
; Load arguments and make sure 'cvt_op' is valid
        mov      eax,[ebp+8]                     ;eax = 'a'
        mov      ecx,[ebp+12]                    ;ecx = 'b'
        mov      edx,[ebp+16]                    ;edx =cvt_op
        cmp      edx,CvtOpTableCount
        jae      .badCvtOp
        jmp      [CvtOpTable+edx*4]              ;jump to specified conversion
; Convert packed doubleword signed integers to packed SPFP values
.sseCvtdq2ps:
        movdqa   xmm0,[eax]
        cvtdq2ps xmm1,xmm0
        movaps   [ecx],xmm1
        pop      ebp
        ret
; Convert packed doubleword signed integers to packed DPFP values
.sseCvtdq2pd:
        movdqa   xmm0,[eax]
        cvtdq2pd xmm1,xmm0
        movapd   [ecx],xmm1
        pop      ebp
        ret
; Convert packed SPFP values to packed doubleword signed integers
.sseCvtps2dq:
        movaps   xmm0,[eax]
        cvtps2dq xmm1,xmm0
        movdqa   [ecx],xmm1
        pop      ebp
        ret
; Convert packed DPFP values to packed doubleword signed integers
.sseCvtpd2dq:
        movapd   xmm0,[eax]
        cvtpd2dq xmm1,xmm0
        movdqa   [ecx],xmm1
        pop      ebp
        ret
; Convert packed SPFP to packed DPFP
.sseCvtps2pd:
        movaps   xmm0,[eax]
        cvtps2pd xmm1,xmm0
        movapd   [ecx],xmm1
        pop      ebp
        ret
; Convert packed DPFP to packed SPFP
.sseCvtpd2ps:
        movapd   xmm0,[eax]
        cvtpd2ps xmm1,xmm0
        movaps   [ecx],xmm1
        pop      ebp
        ret
.badCvtOp:
        pop      ebp
        ret
