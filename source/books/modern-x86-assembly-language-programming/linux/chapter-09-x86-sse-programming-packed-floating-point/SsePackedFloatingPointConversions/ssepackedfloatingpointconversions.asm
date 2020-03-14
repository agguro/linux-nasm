; Name:     ssepackedfloatingpointconversions.asm
; Source:   Modern x86 Assembly Language Programming p. 249

bits 32
global	SsePfpConvert_

section .data
; The order of values in the following table must match the enum CvtOp
; that's defined in SsePackedFloatingPointConversions.cpp.
align 4

CvtOpTable: dd SsePfpConvert_.sseCvtdq2ps
            dd SsePfpConvert_.sseCvtdq2pd
            dd SsePfpConvert_.sseCvtps2dq
            dd SsePfpConvert_.sseCvtpd2dq
            dd SsePfpConvert_.sseCvtps2pd
            dd SsePfpConvert_.sseCvtpd2ps
CvtOpTableCount: equ ($ - CvtOpTable) / 4  ; size dword = 4

section .text

; extern "C" void SsePfpConvert(const XmmVal* a, XmmVal* b, CvtOp cvt_op);
; Description:  The following function demonstrates use of the packed
;               floating-point conversion instructions.
; Requires:     SSE2

SsePfpConvert_:
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
