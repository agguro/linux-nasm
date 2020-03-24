; Name:     calcmeanstdev.asm
;
; Source:   Modern x86 Assembly Language Programming p.112

bits 32
global  CalcMeanStdev_

section .text

; extern "C" bool CalcMeanStdev_(const double* a, int n, double* mean, double* stdev);
;
; Description:  The following function calculates the mean and
;               standard deviation of the values in an array.
;
; Returns:      0 = invalid 'n'
;               1 = valid 'n' 

%define a       [ebp+8]
%define n       [ebp+12]
%define mean    [ebp+16]
%define stdev   [ebp+20]
%define i       [ebp-4]

CalcMeanStdev_:
    push    ebp
    mov     ebp,esp
    sub     esp,4
    ; Make sure 'n' is valid
    xor     eax,eax
    mov     ecx,n
    cmp     ecx,1
    jle     .done                   ;jump if n <= 1
    dec     ecx
    mov     i,ecx                   ;save n - 1 for later
    inc     ecx
    ; Compute sample mean
    mov     edx,a                   ;edx = 'a'
    fldz                            ;sum = 0.0
.l1:
    fadd    qword[edx]              ;sum += *a
    add     edx,8                   ;a++
    dec     ecx
    jnz     .l1
    fidiv   dword n                 ;mean = sum / n
    ; Compute sample stdev
    mov     edx,a                   ;edx = 'a'
    mov     ecx,n                   ;n
    fldz                            ;sum = 0.0, ST(1) = mean
.l2:
    fld     qword [edx]             ;ST(0) = *a,
    fsub    st0,st2                 ;ST(0) = *a - mean
    fmul    st0,st0                 ;ST(0) = (*a - mean) ^ 2
    faddp                           ;update sum
    add     edx,8
    dec     ecx
    jnz     .l2
    fidiv   dword i                 ;var = sum / (n - 1)
    fsqrt                           ;final stdev
    ; Save results
    mov     eax,stdev
    fstp    qword [eax]             ;save stdev
    mov     eax,mean
    fstp    qword [eax]             ;save mean
    mov     eax,1                   ;set success return code
.done:
    mov     esp,ebp
    pop     ebp
    ret
