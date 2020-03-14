; Name:			ssescalarfloatingpointconversions.asm
; Source:		Modern x86 Assembly Language Programming p. 217

bits 32
global	SseSfpConversion
global	SseGetMxcsr
global	SseSetMxcsr
global	SseGetMxcsrRoundingMode
global	SseSetMxcsrRoundingMode

section .data
align 4
; The order of values in following table must match the enum CvtOp
; that's defined in SseScalarFloatingPointConversions.cpp
CvtOpTable:		dd SseSfpConversion.SseCvtsi2ss
				dd SseSfpConversion.SseCvtss2si
				dd SseSfpConversion.SseCvtsi2sd
				dd SseSfpConversion.SseCvtsd2si
				dd SseSfpConversion.SseCvtss2sd
				dd SseSfpConversion.SseCvtsd2ss
CvtOpTableCount:	equ ($ - CvtOpTable) / 4		; 4 is size dword
MxcsrRcMask:		equ 9fffh                      ;bit pattern for MXCSR.RC
MxcsrRcShift:		equ 13                         ;shift count for MXCSR.RC

section .text
; extern "C" bool SseSfpConversion_(XmmScalar* des, const XmmScalar* src, CvtOp cvt_op);
; Description:  The following function demonstrates use of the x86-SSE
;               scalar floating-point conversion instructions.
; Requires:     SSE2

SseSfpConversion:
	%define des	[ebp+8]
	%define src	[ebp+12]
	%define cvt_op	[ebp+16]
	
	push 	 ebp
	mov		ebp,esp
; Load argument values and make sure cvt_op is valid
	mov		eax,cvt_op                ;cvt_op
	mov		ecx,src                   ;ptr to src
	mov		edx,des                   ;ptr to des
	cmp		eax,CvtOpTableCount
	jae		.badCvtOp                 ;jump if cvt_op is invalid
	jmp		[CvtOpTable+eax*4]        ;jump to specified conversion

.SseCvtsi2ss:
	mov    	eax,[ecx]                 ;load integer value
	cvtsi2ss	xmm0,eax                  ;convert to float
	movss	dword[edx],xmm0           ;save result
	mov		eax,1
	pop		ebp
	ret
.SseCvtss2si:
	movss	xmm0,dword[ecx]           ;load float value
	cvtss2si	eax,xmm0                  ;convert to integer
	mov		[edx],eax                 ;save result
	mov		eax,1
	pop		ebp
	ret
.SseCvtsi2sd:
	mov		eax,[ecx]                 ;load integer value
	cvtsi2sd	xmm0,eax                  ;convert to double
	movsd 	qword[edx],xmm0           ;save result
	mov		eax,1
	pop		ebp
	ret
.SseCvtsd2si:
	movsd	xmm0,qword[ecx]           ;load double value
	cvtsd2si	eax,xmm0                  ;convert to integer
	mov		[edx],eax                 ;save result
	mov		eax,1
	pop		ebp
	ret
.SseCvtss2sd:
	movss	xmm0,dword[ecx]           ;load float value
	cvtss2sd	xmm1,xmm0                 ;convert to double
	movsd 	qword[edx],xmm1           ;save result
	mov		eax,1
	pop		ebp
	ret
.SseCvtsd2ss:
	movsd	xmm0,qword[ecx]           ;load double value
	cvtsd2ss	xmm1,xmm0                 ;convert to float
	movss 	dword[edx],xmm1           ;save result
	mov		eax,1
	pop		ebp
	ret
.badCvtOp:
	xor		eax,eax                   ;set error return code
	pop		ebp
	ret

; extern "C" Uint32 SseGetMxcsr_(void);
; Description:  The following function obtains the current contents of
;               the MXCSR register.
; Requires:     SSE2
; Returns:      Contents of MXCSR

SseGetMxcsr:
	push 	ebp
	mov		ebp,esp
	sub		esp,4
	stmxcsr	[ebp-4]                    ;save mxcsr register
	mov		eax,[ebp-4]                ;move to eax for return
	mov		esp,ebp
	pop		ebp
	ret

; extern "C" Uint32 SseSetMxcsr_(Uint32 mxcsr);
; Description:  The following function loads a new value into the
;               MXCSR register.
; Requires:     SSE2

SseSetMxcsr:
	%define mxcsr	[ebp+8]
	push		ebp
	mov		ebp,esp
	sub		esp,4
	mov		eax,mxcsr                  ;eax = new mxcsr value
	and		eax,0xffff                 ;bits mxcsr[31:16] must be 0
	mov		[ebp-4],eax
	ldmxcsr	[ebp-4]                    ;load mxcsr register
	mov		esp,ebp
	pop		ebp
	ret

; extern "C" SseRm SseGetMxcsrRoundingMode_(void);
; Description:  The following function obtains the current x86-SSE
;               floating-point rounding mode from MXCSR.RC.
; Requires:     SSE2
; Returns:      Current x86-SSE rounding mode.

SseGetMxcsrRoundingMode:
	push 	ebp
	mov		ebp,esp
	sub		esp,4
	stmxcsr	[ebp-4]                    ;save mxcsr register
	mov		eax,[ebp-4]
	shr		eax,MxcsrRcShift           ;eax[1:0] = MXCSR.RC bits
	and		eax,3                      ;masked out unwanted bits
	mov		esp,ebp
	pop		ebp
	ret

; extern "C" void SseSetMxcsrRoundingMode_(SseRm rm);
; Description:  The following function updates the rounding mode
;               value in MXCSR.RC.
; Requires:     SSE2

SseSetMxcsrRoundingMode:
	%define rm	[ebp+8]
	push		ebp
	mov		ebp,esp
	sub		esp,4
	mov		ecx,rm                     ;ecx = rm
	and		ecx,3                      ;masked out unwanted bits
	shl		ecx,MxcsrRcShift           ;ecx[14:13] = rm
	stmxcsr	[ebp-4]                    ;save current MXCSR
	mov		eax,[ebp-4]
	and		eax,MxcsrRcMask            ;masked out old MXCSR.RC bits
	or 		eax,ecx                    ;insert new MXCSR.RC bits
	mov		[ebp-4],eax
	ldmxcsr	[ebp-4]                    ;load updated MXCSR
	mov		esp,ebp
	pop		ebp
	ret
