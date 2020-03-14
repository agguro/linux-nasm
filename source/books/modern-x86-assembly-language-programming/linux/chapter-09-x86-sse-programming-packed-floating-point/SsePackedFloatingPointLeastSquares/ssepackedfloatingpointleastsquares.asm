; Name:     ssepackedfloatingpointleastsquares.asm
; Source:   Modern x86 Assembly Language Programming p. 254

bits 32
extern LsEpsilon_
global SsePfpLeastSquares_

section .data
align 16			; must be aligned on 16 byte boundary
	PackedFp64Abs: dq 0x7fffffffffffffff,0x7fffffffffffffff

section .text

; extern "C" bool SsePfpLeastSquares_(const double* x, const double* y, int n, double* m, double* b);
; Description:  The following function computes the slope and intercept
;               of a least squares regression line.
; Returns       0 = error (invalid n or improperly aligned array)
;               1 = success
; Requires:     SSE3

%define x [ebp+8]
%define y [ebp+12]
%define n [ebp+16]
%define m [ebp+20]
%define b [ebp+24]

SsePfpLeastSquares_:
    push    ebp
    mov     ebp,esp
    push    ebx
; Load and validate arguments
    xor     eax,eax                     ;set error return code
    mov     ebx,x                       ;ebx = 'x'
    test    ebx,0fh
    jnz     .done                       ;jump if 'x' not aligned
    mov     edx,y                       ;edx ='y'
    test    edx,0fh
    jnz     .done                       ;jump if 'y' not aligned
    mov     ecx,n                       ;ecx = n
    cmp     ecx,2
    jl      .done                       ;jump if n < 2
; Initialize sum registers
    cvtsi2sd xmm3,ecx                   ;xmm3 = DPFP n
    mov     eax,ecx
    and     ecx,0xfffffffe              ;ecx = n / 2 * 2
    and     eax,1                       ;eax = n % 2
    xorpd   xmm4,xmm4                   ;sum_x (both qwords)
    xorpd   xmm5,xmm5                   ;sum_y (both qwords)
    xorpd   xmm6,xmm6                   ;sum_xx (both qwords)
    xorpd   xmm7,xmm7                   ;sum_xy (both qwords)
; Calculate sum variables. Note that two values are processed each cycle.
.@1:
    movapd  xmm0,[ebx]                  ;load next two x values
    movapd  xmm1,[edx]                  ;load next two y values
    movapd  xmm2,xmm0                   ;copy of x
    addpd   xmm4,xmm0                   ;update sum_x
    addpd   xmm5,xmm1                   ;update sum_y
    mulpd   xmm0,xmm0                   ;calc x * x
    addpd   xmm6,xmm0                   ;update sum_xx
    mulpd   xmm2,xmm1                   ;calc x * y
    addpd   xmm7,xmm2                   ;update sum_xy
    add     ebx,16                      ;ebx = next x array value
    add     edx,16                      ;edx = next x array value
    sub     ecx,2                       ;adjust counter
    jnz     .@1                         ;repeat until done
; Update sum variables with final x, y values if 'n' is odd
    or      eax,eax
    jz      .calcFinalSums              ;jump if n is even
    movsd   xmm0,qword[ebx]             ;load final x
    movsd   xmm1,qword[edx]             ;load final y
    movsd   xmm2,xmm0
    addsd   xmm4,xmm0                   ;update sum_x
    addsd   xmm5,xmm1                   ;update sum_y
    mulsd   xmm0,xmm0                   ;calc x * x
    addsd   xmm6,xmm0                   ;update sum_xx
    mulsd   xmm2,xmm1                   ;calc x * y
    addsd   xmm7,xmm2                   ;update sum_xy
; Calculate final sum values
.calcFinalSums:
    haddpd  xmm4,xmm4                   ;xmm4[63:0] = final sum_x
    haddpd  xmm5,xmm5                   ;xmm5[63:0] = final sum_y
    haddpd  xmm6,xmm6                   ;xmm6[63:0] = final sum_xx
    haddpd  xmm7,xmm7                   ;xmm7[63:0] = final sum_xy
; Compute denom and make sure it's valid
; denom = n * sum_xx - sum_x * sum_x
    movsd   xmm0,xmm3                   ;n
    movsd   xmm1,xmm4                   ;sum_x
    mulsd   xmm0,xmm6                   ;n * sum_xx
    mulsd   xmm1,xmm1                   ;sum_x * sum_x
    subsd   xmm0,xmm1                   ;xmm0 = denom
    movsd   xmm2,xmm0
    andpd   xmm2,[PackedFp64Abs]        ;xmm2 = fabs(denom)
    comisd  xmm2,[LsEpsilon_]
    jb      .badDenom                   ;jump if denom < fabs(denom)
; Compute and save slope
; slope = (n * sum_xy - sum_x * sum_y) / denom
    movsd   xmm1,xmm4                   ;sum_x
    mulsd   xmm3,xmm7                   ;n * sum_xy
    mulsd   xmm1,xmm5                   ;sum_x * sum_y
    subsd   xmm3,xmm1                   ;slope_numerator
    divsd   xmm3,xmm0                   ;xmm3 = final slope
    mov     edx,m                       ;edx = 'm'
    movsd   qword[edx],xmm3             ;save slope
; Compute and save intercept
; intercept = (sum_xx * sum_y - sum_x * sum_xy) / denom
    mulsd   xmm6,xmm5                   ;sum_xx * sum_y
    mulsd   xmm4,xmm7                   ;sum_x * sum_xy
    subsd   xmm6,xmm4                   ;intercept_numerator
    divsd   xmm6,xmm0                   ;xmm6 = final intercept
    mov     edx,b                       ;edx = 'b'
    movsd   qword[edx],xmm6             ;save intercept
    mov     eax,1                       ;success return code
.done:
    pop     ebx
    pop     ebp
    ret
; Set 'm' and 'b' to 0.0
.badDenom:
    xor     eax,eax                     ;set error code
    mov     edx,m                       ;eax = 'm'
    mov     [edx],eax
    mov     [edx+4],eax                 ;*m = 0.0
    mov     edx,b                       ;edx = 'b'
    mov     [edx],eax
    mov     [edx+4],eax                 ;*b = 0.0
    jmp     .done
