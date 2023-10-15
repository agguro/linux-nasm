; Name:         avx64calcellipsoid_.asm
;
; Source:       Modern x86 Assembly Language Programming p.590

bits 64
align 16

global Avx64CalcEllipsoid_

extern pow
extern  _GLOBAL_OFFSET_TABLE_
    
section .bss

section .data
	r8_1p0:   dq 1.0
	r8_3p0:   dq 3.0
	r8_4p0:   dq 4.0
	r8_pi:    dq 3.14159265358979323846

section .text

;extern "C" bool Avx64CalcEllipsoid_(const double* a, const double* b, const double* c, int n, double p, double* sa, double* vol);
;
;Description:  The following function calculates the surface area
;              and volume of an ellipsoid
;
;Requires:     x86-64, AVX
;registers: rdi  :const double* a
;           rsi  :const double* b
;           rdx  :const double* c
;	    ecx  :int n (isn't saved because of single use)
;	    xmm0 :double p
;	    r8   :double* sa  (result)
;	    r9   :double* vol (result)

%define STK_TOTAL 0x60

;stack must be kept aligned to 16 bytes (0x10).
;12 local variables = 12 x 8 = 96 (or 0x60) bytes needed. We don't need padding because we have 6 non-volatile
;registers pushed on the stack. 6 x 8 = 48 (or 0x30) which is also aligned to 16 bytes.

%macro PROLOGUE 0
        push	r12
        push	r13
        push	r14
        push	r15
        push	rbx
        push    rbp 
        mov     rbp,rsp 
        push    rbx 
        call    .get_GOT 
    .get_GOT: 
        pop     rbx 
        add     rbx,_GLOBAL_OFFSET_TABLE_+$$-.get_GOT wrt ..gotpc
        sub	rsp,STK_TOTAL
%endmacro

%macro EPILOGUE 0
        add	rsp,STK_TOTAL
        mov     rbx,[rbp-8] 
        mov     rsp,rbp 
        pop     rbp
        pop	rbx
        pop	r15
        pop	r14
        pop	r13
        pop	r12
        ret
%endmacro

Avx64CalcEllipsoid_:
    PROLOGUE
    mov	    [rsp],rdi		    ;pointer to a[]
    mov	    [rsp+0x8],rsi	    ;pointer to b[]
    mov	    [rsp+0x10],rdx	    ;pointer to c[]
    movsd   [rsp+0x18],xmm0	    ;p
    mov	    [rsp+0x20],r8	    ;pointer to surface[]
    mov	    [rsp+0x28],r9	    ;pointer to volume[]

    ;first calculate constant values outside the loop
    ;calculate 4*pi
	vmovsd  xmm0,qword[r8_4p0]
	vmulsd  xmm0,xmm0,qword[r8_pi]
    vmovsd  [rsp+0x30],xmm0		;save 4*pi
    ;calculate 4*pi/3
	vdivsd  xmm0,xmm0,qword[r8_3p0]	;4*pi/3 in xmm2 for volume
    vmovsd  [rsp+0x38],xmm0		;save 4*pi/3
    ;calculate 1/p
	vmovsd  xmm0,qword[r8_1p0]		;1 in xmm0
    vmovsd  xmm1,[rsp+0x18]		;p in xmm1
    vdivsd  xmm0,xmm0,xmm1		;1/p
    vmovsd  [rsp+0x40],xmm0		;save 1/p

    test    ecx,ecx		    ;is n <= 0
    jle	    .error
    mov	    r15d,ecx
    xor	    r11,r11
.repeat:
    ;*** Calculate the ellipsoid's volume ***
    ;vol = (4*pi*a*b*c)/3
    ;xmm0 = 4*pi/3
    vmovsd  xmm0,[rsp+0x38]		;load 4*pi/3
    mov	    r12,qword[rsp]		;a[]
    mov	    r13,qword[rsp+0x8]		;b[]
    mov	    r14,qword[rsp+0x10]		;c[]
    vmulsd  xmm0,xmm0,[r12+r11]		;a*4*pi/3
    vmulsd  xmm0,xmm0,[r13+r11]		;a*b*4*pi/3
    vmulsd  xmm0,xmm0,[r14+r11]		;a*b*c*pi/3
    mov	    r9,qword[rsp+0x28]		;vol[]
    vmovsd  qword[r9+r11],xmm0		;save ellipsoid volume
    mov	    r8,qword[rsp+0x20]		;vol[]
    vmovsd  qword[r8+r11],xmm0
    
    ;*** Calculate surface  ***
    ;surface = 4*pi*(((a^p*b^p+a^p*c^p+b^p*c^p)/3)^(1/p))
    movsd   xmm0,[r12+r11]		;a
    vmovsd  xmm1,qword[rsp+0x18]	;p
    call    pow
    vmovsd  [rsp+0x48],xmm0		;a^p
    
    vmovsd  xmm0,[r13+r11]		;b
    vmovsd  xmm1,qword[rsp+0x18]	;p
    call    pow
    vmovsd  [rsp+0x50],xmm0		;b^p
    
    vmovsd  xmm0,[r14+r11]		;c
    vmovsd  xmm1,qword[rsp+0x18]	;p
    call    pow
    vmovsd  [rsp+0x58],xmm0		;c^p
    
    vmovsd  xmm0,qword[rsp+0x48]	;a^p
    vmovsd  xmm1,qword[rsp+0x50]	;b^p
    vmulsd  xmm0,xmm0,xmm1		;a^p*b^p
    vmovsd  xmm1,qword[rsp+0x50]	;b^p
    vmovsd  xmm2,qword[rsp+0x58]	;c^p
    vmulsd  xmm1,xmm1,xmm2		;b^p*c^p
    vmovsd  xmm2,qword[rsp+0x48]	;a^p
    vmovsd  xmm3,qword[rsp+0x58]	;c^p
    vmulsd  xmm2,xmm2,xmm3		;a^p*c^p
    vaddsd  xmm0,xmm0,xmm1		;a^p*b^p+b^p*c^p
    vaddsd  xmm0,xmm0,xmm2		;a^p*b^p+b^p*c^p+a^p*c^p    
    vdivsd  xmm0,xmm0,qword[r8_3p0]	;(a^p*b^p+b^p*c^p+a^p*c^p)/3
    
    vmovsd  xmm1,[rsp+0x40]		;1/p
    call    pow				;((a^p*b^p+b^p*c^p+a^p*c^p)/3)^(1/p)
    
    vmovsd  xmm1,[rsp+0x30]		;4*pi
    vmulsd  xmm0,xmm0,xmm1		;4*pi*(((a^p*b^p+b^p*c^p+a^p*c^p)/3)^(1/p))
    mov	    r8,qword[rsp+0x20]		;sa[]
    vmovsd  qword[r8+r11],xmm0		;save 
    
    add	    r11,8
    sub	    r15d,1
    jnz	    .repeat
    mov	    rax,1
    jmp	    .done
.error:
    xor	    rax,rax
.done:    
	EPILOGUE

