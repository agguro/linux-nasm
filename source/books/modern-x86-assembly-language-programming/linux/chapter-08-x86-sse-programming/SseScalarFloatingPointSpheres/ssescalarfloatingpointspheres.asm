; Name:     ssescalarfloatingpointspheres.asm
; Source:   Modern x86 Assembly Language Programming p. 225

bits 32
global SseSfpCalcSphereAreaVolume_

; Constants required to calculate sphere surface area and volume.
section .data

	r8_pi       dq 3.14159265358979323846
	r8_four     dq 4.0
	r8_three    dq 3.0
	r8_neg_one  dq -1.0

section .text

; extern "C" bool SseSfpCalcSphereAreaVolume_(double r, double* sa, double* v);
; Description:  The following function calculates the surface area and
;               volume of a sphere.
; Returns:      0 = invalid radius
;               1 = success
; Requires:     SSE2

SseSfpCalcSphereAreaVolume_:
	%define	r   qword [ebp+8]   ; value
	%define	sa  [ebp+16]        ; pointer
	%define	v   [ebp+20]        ; pointer
	push		ebp
	mov		ebp,esp
    ; Load arguments and make sure radius is valid
	movsd	xmm0,r                ;xmm0 = r
	mov		ecx,sa                ;ecx = sa
	mov		edx,v                 ;edx = v
	xorpd	xmm7,xmm7             ;xmm7 = 0.0
	comisd	xmm0,xmm7             ;compare r against 0.0
	jp		.badRadius            ;jump if r is NAN
	jb		.badRadius            ;jump if r < 0.0
	; Compute the surface area
	movsd	xmm1,xmm0             ;xmm1 = r
	mulsd	xmm1,xmm1             ;xmm1 = r * r
	mulsd	xmm1,[r8_four]        ;xmm1 =  4 * r * r
	mulsd	xmm1,[r8_pi]          ;xmm1 =  4 * pi r * r
	movsd	qword[ecx],xmm1       ;save surface area
	; Compute the volume
	mulsd	xmm1,xmm0             ;xmm1 =  4 * pi * r * r * r
	divsd	xmm1,[r8_three]       ;xmm1 =  4 * pi * r * r * r / 3
	movsd	qword [edx],xmm1      ;save volume
	mov		eax,1                 ;set success return code
	pop		ebp
	ret
	; Invalid radius - set surface area and volume to -1.0
.badRadius:
	movsd	xmm0,[r8_neg_one]     ;xmm0 = -1.0
	movsd	qword [ecx],xmm0      ;*sa = -1.0
	movsd	qword [edx],xmm0      ;*v = -1.0;
	xor		eax,eax               ;set error return code
	pop		ebp
	ret
