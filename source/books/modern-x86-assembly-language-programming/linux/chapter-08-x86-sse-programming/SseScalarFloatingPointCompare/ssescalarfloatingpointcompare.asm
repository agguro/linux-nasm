; Name:		ssescalarfloatingpointcompare.asm
; Source:		Modern x86 Assembly Language Programming p. 212

bits 32
global	SseSfpCompareFloat_
global	SseSfpCompareDouble_
section .text

; extern "C" void SseSfpCompareFloat_(float a, float b, bool* results);
; Description:  The following function demonstrates use of the comiss
;               instruction.
; Requires      SSE

SseSfpCompareFloat_:
	%define	a		dword[ebp+8]
	%define b		dword[ebp+12]
	%define results	[ebp+16]
	push 	ebp
	mov		ebp,esp
; Load argument values
	movss 	xmm0,a                         ;xmm0 = a
	movss 	xmm1,b                         ;xmm1 = b
	mov		edx,results                    ;edx = results array
; Set result flags based on compare status
	comiss 	xmm0,xmm1
	setp 	byte[edx]                      ;EFLAGS.PF = 1 if unordered
	jnp		.@1
	xor		al,al
	mov		byte[edx+1],al                 ;Use default result values
	mov		byte[edx+2],al
	mov		byte[edx+3],al
	mov		byte[edx+4],al
	mov		byte[edx+5],al
	mov		byte[edx+6],al
	jmp		.done
.@1:     
	setb 	byte[edx+1]                    ;set byte if a < b
	setbe 	byte[edx+2]                    ;set byte if a <= b
	sete 	byte[edx+3]                    ;set byte if a == b
	setne 	byte[edx+4]                    ;set byte if a != b
	seta 	byte[edx+5]                    ;set byte if a > b
	setae 	byte[edx+6]                    ;set byte if a >= b
.done:
	pop		ebp
	ret

; extern "C" void SseSfpCompareDouble_(double a, double b, bool* results);
; Description:  The following function demonstrates use of the comisd
;               instruction.
; Requires      SSE2

SseSfpCompareDouble_:
	%define	a		qword[ebp+8]
	%define	b		qword[ebp+16]
	%define results	[ebp+24]
	push 	ebp
	mov		ebp,esp
; Load argument values
	movsd 	xmm0,a                         ;xmm0 = a
	movsd 	xmm1,b                         ;xmm1 = b
	mov		edx,results                    ;edx = results array
; Set result flags based on compare status
	comisd 	xmm0,xmm1
	setp 	byte[edx]                      ;EFLAGS.PF = 1 if unordered
	jnp		.@1
	xor		al,al
	mov		byte[edx+1],al                 ;Use default result values
	mov		byte[edx+2],al
	mov		byte[edx+3],al
	mov		byte[edx+4],al
	mov		byte[edx+5],al
	mov		byte[edx+6],al
	jmp		.done
.@1:
	setb 	byte[edx+1]                    ;set byte if a < b
	setbe 	byte[edx+2]                    ;set byte if a <= b
	sete 	byte[edx+3]                    ;set byte if a == b
	setne 	byte[edx+4]                    ;set byte if a != b
	seta 	byte[edx+5]                    ;set byte if a > b
	setae 	byte[edx+6]                    ;set byte if a >= b
.done:
	pop 	ebp
	ret