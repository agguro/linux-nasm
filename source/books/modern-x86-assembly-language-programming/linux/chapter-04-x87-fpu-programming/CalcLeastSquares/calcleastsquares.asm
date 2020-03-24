; Name:     calcleastsquares.asm
;
; Source:   Modern x86 Assembly Language Programming p.124

bits 32
global CalcLeastSquares_
global LsEpsilon_

section .data

    LsEpsilon_: dq 1.0e-12                ;epsilon for valid denom test

section .text

; extern "C" bool CalcLeastSquares_(const double* x, const double* y, int n, double* m, double* b);
;
; Description:  The following function computes the slope and intercept
;               of a least squares regression line.
;
; Returns       0 = error
;               1 = success

%define x       [ebp+8]
%define y       [ebp+12]
%define n       [ebp+16]
%define m       [ebp+20]
%define b       [ebp+24]
%define denom   qword[ebp-8]

CalcLeastSquares_:
    push    ebp
    mov     ebp,esp
    sub     esp,8                   ;space for denom
    xor     eax,eax                 ;set error return code
    mov     ecx,n                   ;n
    test    ecx,ecx
    jle     .done                   ;jump if n <= 0
    mov     eax,x                   ;ptr to x
    mov     edx,y                   ;ptr to y
    ; Initialize all sum variables to zero
    fldz                            ;sum_xx
    fldz                            ;sum_xy
    fldz                            ;sum_y
    fldz                            ;sum_x
    ;STACK: sum_x, sum_y, sum_xy, sum_xx
.l1:
    fld     qword[eax]              ;load next x
    fld     st0
    fld     st0
    fld     qword[edx]              ;load next y
    ;STACK: y, x, x, x, sum_x, sum_y, sum_xy, sum_xx
    fadd    st5,st0                 ;sum_y += y
    fmulp
    ;STACK: xy, x, x, sum_xm sum_y, sum_xy, sum_xx
    faddp   st5,st0                 ;sum_xy += xy
    ;STACK: x, x, sum_x, sum_y, sum_xy, sum_xx
    fadd    st2,st0                 ;sum_x += x
    fmulp
    ;STACK: xx, sum_x, sum_y, sum_xy, sum_xx
    faddp   st4,st0                 ;sum_xx += xx
    ;STACK: sum_x, sum_y, sum_xy, sum_xx
    ; Update pointers and repeat until elements have been processed.
    add     eax,8
    add     edx,8
    dec     ecx
    jnz     .l1
    ; Compute denom = n * sum_xx - sum_x * sum_x
    fild    dword n                 ;n
    fmul    st0,st4                 ;n * sum_xx
    ;STACK: n * sum_xx, sum_x, sum_y, sum_xy, sum_xx
    fld     st1
    fld     st0
    ;STACK: sum_x, sum_x, n * sum_xx, sum_x, sum_y, sum_xy, sum_xx
    fmulp
    fsubp
    fst     denom                   ;save denom
    ;STACK: denom, sum_x, sum_y, sum_xy, sum_xx
    ; Verify that denom is valid
    fabs                            ;fabs(denom)
    fld     qword[LsEpsilon_]
    fcomip  st0,st1                 ;compare epsilon and fabs(demon)
    fstp    st0                     ;remove fabs(denom) from stack
    jae     .invalidDenom           ;jump if LsEpsilon_ >= fabs(denom)
    ;STACK: sum_x, sum_y, sum_xy, sum_xx
    ; Compute slope = (n * sum_xy - sum_x * sum_y) / denom
    fild    dword n
    ;STACK: n, sum_x, sum_y, sum_xy, sum_xx
    fmul    st0,st3                 ;n * sum_xy
    fld     st2                     ;sum_y
    fld     st2                     ;sum_x
    fmulp                           ;sum_x * sum_y
    fsubp                           ;n * sum_xy - sum_x * sum_y
    fdiv    denom                   ;calculate slope
    mov     eax,dword m
    fstp    qword[eax]              ;save slope
    ;STACK: sum_x, sum_y, sum_xy, sum_xx
    ; Calculate intercept = (sum_xx * sum_y - sum_x * sum_xy) / denom
    fxch    st3
    ;STACK: sum_xx, sum_y, sum_xy, sum_x
    fmulp
    fxch    st2
    ;STACK: sum_x, sum_xy, sum_xx * sum_y
    fmulp
    fsubp
    ;STACK: sum_xx * sum_y - sum_x * sum_xy
    fdiv    denom                   ;calculate intercept
    mov     eax,b
    fstp    qword[eax]              ;save intercept
    mov     eax,1                   ;set success return code
.done:
    mov     esp,ebp
    pop     ebp
    ret
.invalidDenom:
    ; Cleanup x87 FPU register stack
    fstp    st0
    fstp    st0
    fstp    st0
    fstp    st0
    xor     eax,eax                 ;set error return code
    mov     esp,ebp
    pop     ebp
    ret
